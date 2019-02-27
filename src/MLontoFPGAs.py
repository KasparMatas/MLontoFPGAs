import tensorflow as tf
from tensorflow import keras

from TreeNode import TreeNode
from TopologyFinder import TopologyFinder
from VerilogPrinter import VerilogPrinter
from ModelHandler import ModelHandler

loaded_model = keras.models.load_model("keras_model.h5")

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
