import tensorflow as tf
from tensorflow import keras
import numpy as np

from DenseCellPrint import DenseCellPrinter
from DenseScalerPrint import DenseScalerPrinter
from ArgmaxCellPrint import ArgmaxCellPrinter

class ModelHandler:
    def createVerilogForAllLayers(childNode, verilogPrinter, quantizer, inputWires):
        for parent in childNode.parents:
            if parent.value != None:
                outputWires = ModelHandler.createVerilogForGivenLayer(parent.value, verilogPrinter,
                                                                      quantizer, inputWires)
                ModelHandler.createVerilogForAllLayers(parent, verilogPrinter, quantizer, outputWires)

    def denseLayerHandler(layer, outputFile, quantizer, inputWires):
        layerConfig = layer.get_config()
        weightCellPrinter = DenseCellPrinter()
        scalerPrinter = DenseScalerPrinter()
        inputWires.insert(2,"ground")
        
        weights = np.transpose(layer.get_weights()[0])
        
        outputWires = weightCellPrinter.printCells(weights, quantizer.layer_ids[layer],
                                                   quantizer, weights.shape[0], inputWires, outputFile)
        if (layerConfig["use_bias"]):
            raise Exception("Please submit a model which doesn't use biases")
            
        outputWires = scalerPrinter.printScaler(quantizer.layer_ids[layer], quantizer, weights.shape[0], 
                                                outputWires, outputFile)
        
        outputWires = ModelHandler.createVerilogForActivationFunction(layerConfig["activation"], outputFile, 
                                                                      quantizer, weights.shape[0], outputWires)
        return outputWires 

    def defaultLayerHandler(layer, outputFile, quantizer, inputWires):
        raise Exception("Please submit a model which uses the supported Dense layer")

    def createVerilogForGivenLayer(layer, verilogPrinter, quantizer, inputWires):
        layerHandlers = {keras.layers.Dense(1).__class__.__name__ : ModelHandler.denseLayerHandler}
        return layerHandlers.get(layer.__class__.__name__, 
                                 ModelHandler.defaultLayerHandler)(layer,verilogPrinter.output_file,
                                                                   quantizer, inputWires)
    
    def linearFunctionHandler(output_file, quantizer, cell_amount, inputWires):
        return inputWires
        
    def softmaxFunctionHandler(output_file, quantizer, cell_amount, inputWires):
        argmaxCellPrinter = ArgmaxCellPrinter()
        return argmaxCellPrinter.printArgmax(cell_amount, inputWires, output_file)
    
    def defaultFunctionHandler(output_file, quantizer, cell_amount, inputWires):
        raise Exception("Please submit a model which uses the supported activation functions")
    
    def createVerilogForActivationFunction(activation_function, output_file, quantizer, cell_amount, inputWires):
        activationFunctionHandlers = {"linear": ModelHandler.linearFunctionHandler,
                                      "softmax": ModelHandler.softmaxFunctionHandler}
        return activationFunctionHandlers.get(activation_function, 
                                              ModelHandler.defaultFunctionHandler)(output_file, quantizer,
                                                                                   cell_amount, inputWires)