import sys
import tensorflow as tf
from tensorflow import keras
import numpy as np

from TreeNode import TreeNode
from TopologyFinder import TopologyFinder
from VerilogPrinter import VerilogPrinter
from ModelHandler import ModelHandler
from Quantizer import Quantizer

from customDense import CustomDense

if (len(sys.argv)!=3):
    raise Exception("Wrong amount of inputs given. Please specify the name of the model file and the name of the data file.")
   
loaded_model = keras.models.load_model(sys.argv[1])

# Tree of layers, assuming graph only has one output but multiple inputs are fine. 
# It is also lacking any kind of error handling.
treeOfLayers = TreeNode(None)
TopologyFinder.findInputs(treeOfLayers, None, loaded_model.output, loaded_model)

inputLayers = []
treeOfLayers.children[0].fillLeafNodeArray(inputLayers)

print ("Creating verilog for the following graph: ")
TopologyFinder.printTopology(inputLayers)

# Start writing structural verilog.
# The processing needs to have the different processing elements connected with some wires.
# The weights will be fed into some parameters to hard code them into the elements which would end up sitting on the BRAM.
verilogPrinter = VerilogPrinter(open("tensorFlowModel.v","w"))
verilogPrinter.defineClkAndDataWidth(8)

inputWires = ["input_index", "input_value", "input_result", "input_enable"]
verilogPrinter.printInputWires(inputWires)

inputWires = ModelHandler.createVerilogForGivenLayer(0, inputLayers[0].value, verilogPrinter, inputWires)
ModelHandler.createVerilogForAllLayers(inputLayers[0], verilogPrinter, inputWires, 1)
verilogPrinter.output_file.close()

# Get quantization data
quantizer = Quantizer(0,255)
# INTER LAYER QUANTIZATIONS
quantizer.findLayerInputAndOutputRanges(loaded_model, np.loadtxt(sys.argv[2]))
quantizer.findLayerInputAndOutputScales()    
# WEIGHT QUANTIZATIONS
quantizer.findLayerWeightRanges(loaded_model)
quantizer.findLayerWeightScales()
    
quantizer.findFinalScalingConstant(loaded_model, 15)

"""    
# The following is to check the effects of the quantization.
mnist_dataset = keras.datasets.mnist
(train_images, train_labels), (test_images, test_labels) = mnist_dataset.load_data()

test_images = test_images / 255.0
test_images = test_images.reshape(-1,784)

test_loss, test_acc = loaded_model.evaluate(test_images, test_labels, batch_size=32)
print("Test accuracy:", test_acc)    

quantize_model = keras.Sequential([
    CustomDense(100, quantizer.combined_scales[0], quantizer.shift_amounts[0], activation=None, input_shape = (784,), use_bias=False),
    CustomDense(10, quantizer.combined_scales[1], quantizer.shift_amounts[1], activation=None, input_shape = (100,), use_bias=False),
    CustomDense(10, quantizer.combined_scales[2], quantizer.shift_amounts[2], activation=tf.nn.softmax, input_shape = (10,), use_bias=False)
])

quantize_model.compile(optimizer=keras.optimizers.Adam(lr=1e-4), 
              loss="sparse_categorical_crossentropy",
              metrics=["accuracy"])

for layer_index in range(len(loaded_model.layers)):
    weights = loaded_model.layers[layer_index].get_weights()
    quantize_model.layers[layer_index].set_weights(quantizer.quantizeMatrix(weights, quantizer.quantized_weight_scales[layer_index], quantizer.quantized_weight_zeros[layer_index]) - quantizer.quantized_weight_zeros[layer_index])

quantized_test_loss, quantized_test_acc = quantize_model.evaluate(quantizer.quantizeMatrix(test_images, quantizer.quantized_output_scales[0], quantizer.quantized_output_zeros[0]), test_labels, batch_size=32)
print()
print()
print("Quantized test accuracy: ", quantized_test_acc, " vs initial test accuracy: ", test_acc)
"""