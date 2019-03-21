import tensorflow as tf
from tensorflow import keras
import numpy as np
import math

from DenseCellPrint import DenseCellPrinter
from DenseScalerPrint import DenseScalerPrinter
from ArgmaxCellPrint import ArgmaxCellPrinter

# Class to take the given model and the proper quantization data and print the equivalent 
# verilog model.
class ModelHandler:
    # Function to go through all of the layers in the given tree and print appropriate verilog code.
    def createVerilogForAllLayers(childNode, verilogPrinter, quantizer, inputWires):
        for parent in childNode.parents:
            if parent.value != None:
                outputWires = ModelHandler.createVerilogForGivenLayer(parent.value, verilogPrinter,
                                                                      quantizer, inputWires)
                ModelHandler.createVerilogForAllLayers(parent, verilogPrinter, quantizer, outputWires)

    # Function which takes a dense layer and generates appropriate verilog to mimic the dense layer.
    def denseLayerHandler(layer, outputFile, quantizer, inputWires):
        layerConfig = layer.get_config()
        weightCellPrinter = DenseCellPrinter()
        scalerPrinter = DenseScalerPrinter()
        inputWires.insert(2,"ground")
        weights = np.transpose(layer.get_weights()[0])
        wireWidths = [math.ceil(math.log(weights.shape[1],2)), "`DATA_WIDTH", "`DATA_WIDTH*5"]
        
        outputWires = weightCellPrinter.printCells(weights, quantizer.layer_ids[layer], quantizer, 
                                                   weights.shape[0], wireWidths, inputWires, outputFile)
        if (layerConfig["use_bias"]):
            raise Exception("Please submit a model which doesn't use biases")
            
        wireWidths[0] = math.ceil(math.log(weights.shape[0],2))
        outputWires = scalerPrinter.printScaler(quantizer.layer_ids[layer], quantizer, weights.shape[0], wireWidths, 
                                                outputWires, outputFile)
        
        outputWires = ModelHandler.createVerilogForActivationFunction(layerConfig["activation"], outputFile, 
                                                                      quantizer, weights.shape[0], wireWidths,
                                                                      outputWires)
        return outputWires 

    # Function to throw an exception when an unsupported layer was used.
    def defaultLayerHandler(layer, outputFile, quantizer, inputWires):
        raise Exception("Please submit a model which uses the supported Dense layer")

    # Function to identify the given layer and let an appropriate handler print 
    # the verilog for that layer.
    def createVerilogForGivenLayer(layer, verilogPrinter, quantizer, inputWires):
        layerHandlers = {keras.layers.Dense(1).__class__.__name__ : ModelHandler.denseLayerHandler}
        return layerHandlers.get(layer.__class__.__name__, 
                                 ModelHandler.defaultLayerHandler)(layer,verilogPrinter.output_file,
                                                                   quantizer, inputWires)
    
    # Function to support the linear activation function which doesn't modify the output of the layer.
    def linearFunctionHandler(output_file, quantizer, cell_amount, wireWidths, inputWires):
        return inputWires
        
    # Function to support the softmax activation function by printing the argmax cell.    
    def softmaxFunctionHandler(output_file, quantizer, cell_amount, wireWidths, inputWires):
        argmaxCellPrinter = ArgmaxCellPrinter()
        return argmaxCellPrinter.printArgmax(cell_amount, wireWidths, inputWires, output_file)
    
    # Function to throw and exception when an unsupported activation function was used.
    def defaultFunctionHandler(output_file, quantizer, cell_amount, wireWidths, inputWires):
        raise Exception("Please submit a model which uses the supported activation functions")
    
    # Function to identify the activation function used in the layer and use an appropriate handler.
    def createVerilogForActivationFunction(activation_function, output_file, quantizer, cell_amount, wireWidths,
                                           inputWires):
        activationFunctionHandlers = {"linear": ModelHandler.linearFunctionHandler,
                                      "softmax": ModelHandler.softmaxFunctionHandler}
        return activationFunctionHandlers.get(activation_function, 
                                              ModelHandler.defaultFunctionHandler)(output_file, quantizer,
                                                                                   cell_amount, wireWidths, 
                                                                                   inputWires)
