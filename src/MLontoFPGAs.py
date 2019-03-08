# Main script of the project which takes a model and some data and then maps
# that model to Verilog code.

import sys
import tensorflow as tf
from tensorflow import keras
import numpy as np
import math

from TreeNode import TreeNode
from TopologyFinder import TopologyFinder
from VerilogPrinter import VerilogPrinter
from ModelHandler import ModelHandler
from Quantizer import Quantizer

# Assert correct input argument amount.
if (len(sys.argv)!=3):
    raise Exception("Wrong amount of inputs given. Please specify the name of the model file and the name of the data file.")
   
# Load the Keras model
loaded_model = keras.models.load_model(sys.argv[1])

# Create a graph of layers to identify the topology of the given graph. 
treeOfLayers = TreeNode(None)
TopologyFinder.findInputs(treeOfLayers, None, loaded_model.output, loaded_model)
inputLayers = []
treeOfLayers.children[0].fillLeafNodeArray(inputLayers)

# Assert that the graph layers have one input and one output.
TopologyFinder.assertSuitableTopology(inputLayers)
"""
print ("Creating verilog for the following graph: ")
TopologyFinder.printTopology(inputLayers)
"""

# Get quantization data
quantizer = Quantizer(loaded_model, np.loadtxt(sys.argv[2]), 0, 255, 15)  
quantizer.quantizeModelWeights()
    
# Start writing structural verilog.
verilogPrinter = VerilogPrinter(open("tensorFlowModel.v","w"))
verilogPrinter.defineClkAndDataWidth(8)
verilogPrinter.printGroundSignal()
inputWires = ["input_index", "input_value", "input_enable"]
verilogPrinter.printInputWires([math.ceil(math.log(inputLayers[0].value.get_weights()[0].shape[0],2)), "`DATA_WIDTH"],
                               inputWires)
inputWires = ModelHandler.createVerilogForGivenLayer(inputLayers[0].value, verilogPrinter, 
                                                     quantizer, inputWires)
ModelHandler.createVerilogForAllLayers(inputLayers[0], verilogPrinter, quantizer, inputWires)
verilogPrinter.output_file.close()
