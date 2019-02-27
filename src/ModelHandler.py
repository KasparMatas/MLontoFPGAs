import tensorflow as tf
from tensorflow import keras

from DenseCellPrint import DenseCellPrinter

class ModelHandler:
    def createVerilogForAllLayers(childNode, verilogPrinter, inputWires, layerIndex):
        for parent in childNode.parents:
            if parent.value != None:
                outputWires = ModelHandler.createVerilogForGivenLayer(layerIndex, parent.value, verilogPrinter, inputWires)
                ModelHandler.createVerilogForAllLayers(parent, verilogPrinter, outputWires, layerIndex + 1)

    def denseLayerHandler(layerIndex, layer, outputFile, inputWires):
        layerConfig = layer.get_config()
        weightCellPrinter = DenseCellPrinter()
        outputWires = weightCellPrinter.printCells(layer.get_weights()[0], layerIndex, layerConfig["units"],
                                                   inputWires, outputFile)
        if (layerConfig["use_bias"]):
            outputFile.write("// Processing element for bias addition with biases layer.get_weights()[1]\n")
        outputFile.write("// Processing element for activation function " + layerConfig["activation"] + "\n")
        outputFile.write("\n")
        return outputWires 

    def defaultHandler(layerIndex, layer, outputFile, inputWires):
        outputFile.write("// Some processing elements for " + layer.__class__.__name__ + " layer\n")
        outputFile.write("\n")
        return inputWires

    def createVerilogForGivenLayer(layerIndex, layer, verilogPrinter, inputWires):
        layerHandlers = {keras.layers.Dense(1).__class__.__name__ : ModelHandler.denseLayerHandler}
        return layerHandlers.get(layer.__class__.__name__, ModelHandler.defaultHandler)(layerIndex, layer, verilogPrinter.output_file, inputWires)