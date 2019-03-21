import tensorflow as tf
from tensorflow import keras
import numpy as np

from DenseWithoutActivation import DenseWithoutActivation

# Class to take the input model and some data to find all of the data necessary 
# to quantize the model into the desired bitlength.

# This quantizer is currently used incorrectly when the final layer uses the softmax activation function since the scales and zero points will be wrong thinking that the output of the layer is only 1 or 0. In the future this should be fixed that the scales and zeros should be found before the classification decision. This doesn't change the output of the model but does fail to quantize the values to the desired space.
class Quantizer:
    # Constructor finding all of the data required for quantization.
    def __init__(self, keras_model, test_data, min_qunatized_value, max_quantized_value, scale_width):
        self.qmin = min_qunatized_value
        self.qmax = max_quantized_value
        
        self.minimum_output_values = []
        self.maximum_output_values = []
        
        self.minimum_weight_values = []
        self.maximum_weight_values = []
        
        self.quantized_weight_scales = []
        self.quantized_weight_zeros = []
        
        self.quantized_output_scales = []
        self.quantized_output_zeros = []
        
        self.combined_scales = []
        self.shift_amounts = [] 
        
        self.layer_ids = {}
        self.keras_model = keras_model
        
        self.initialiseQuantizationData(keras_model, test_data, scale_width)
        self.giveLayersIdsAssumingSequentialModel(keras_model)  
        
    # Function to find all of the data required to quantize the model.    
    def initialiseQuantizationData(self, keras_model, test_data, scale_width):
        observation_model = self.createDenseObservationModelWithoutActivation(keras_model)
    
        self.findLayerInputAndOutputRanges(observation_model, test_data)
        self.findLayerInputAndOutputScales()    
        
        self.findLayerWeightRanges(observation_model)
        self.findLayerWeightScales()
            
        self.findFinalScalingConstant(observation_model, scale_width)
     
    # Function to fill a dictionary of the input model layers with their corresponding index.
    def giveLayersIdsAssumingSequentialModel(self, keras_model):
        for layer_index in range(len(keras_model.layers)):
            self.layer_ids[keras_model.layers[layer_index]] = layer_index
            
    # Function which assumes that the given model consists of Dense keras layers 
    # and that the final layer has softmax activation function. Given these assumtions this function returns
    # another model where the final softmax activation function is removed. 
    # This should be reworked so that the assumtions weren't needed.
    def createDenseObservationModelWithoutActivation(self, keras_model):
        layers=[]
        for layer_id in range(len(keras_model.layers)-1):
            layers.append(keras.layers.Dense.from_config(keras_model.layers[layer_id].get_config()))

        last_layer_config = keras_model.layers[len(keras_model.layers)-1].get_config()
        last_layer_config["activation"] = "linear"
        layers.append(DenseWithoutActivation.from_config(last_layer_config))

        obs_model = keras.Sequential(layers)
                          
        for layer_index in range(len(keras_model.layers)):
            weights = keras_model.layers[layer_index].get_weights()
            obs_model.layers[layer_index].set_weights(weights)

        return obs_model
            
    # Function to change the model weights to the quantized ones.        
    def quantizeModelWeights(self):
        for layer_index in range(len(self.keras_model.layers)):
            weights = self.keras_model.layers[layer_index].get_weights()
            self.keras_model.layers[layer_index].set_weights(
                self.quantizeMatrix(weights, 
                                    self.quantized_weight_scales[layer_index], 
                                    self.quantized_weight_zeros[layer_index]))
     
    # Function to quantize the given matriz with the scale and zero points given. 
    def quantizeMatrix(self, original_values, scale, zero_point):
        transformed_val = zero_point + original_values / scale
        clamped_val = np.maximum(self.qmin, np.minimum(self.qmax, transformed_val))
        return(np.around(clamped_val))

    # Function to get the scale and shift amount given a scale multiplier of all 
    # of the scales used in the current layer
    def getFinalScale(self, real_multiplier, scaler_width):
        if(real_multiplier > 1 or real_multiplier < 0):
            raise ValueError("Scale is outside of the required range: ", real_multiplier)
        
        nudge_factor = 0
        
        while (real_multiplier < 0.5):
            real_multiplier *= 2
            nudge_factor += 1
            
        quanatized_value = round(real_multiplier * (2**scaler_width))
        
        if(quanatized_value > (2**scaler_width)):
            raise ValueError("Something went wrong with scale quantization: ", quanatized_value)
            
        if (quanatized_value == 2**scaler_width):
            quanatized_value /= 2
            nudge_factor-=1
        
        if (nudge_factor<0):
            raise ValueError("Something went wrong with scale quantization: ", nudge_factor)
        if (quanatized_value>=(2**scaler_width)):
            raise ValueError("Something went wrong with scale quantization: ", quanatized_value)
            
        return(quanatized_value, nudge_factor)
        
    # Function to get the scale and zero point given the min and max values of the data.
    def findScaleAndZeroPoint(self, max, min):
        scale = (max - min) / (self.qmax - self.qmin)
        initial_zero_point = self.qmin - min / scale
        
        if (initial_zero_point < self.qmin):
            nudged_zero_point = self.qmin
        elif (initial_zero_point > self.qmax):
            nudged_zero_point = self.qmax
        else:
            nudged_zero_point = round(initial_zero_point)

        return(scale, nudged_zero_point)
        
    # Function to fill the output value arrays for given layers with min and max values.    
    def findLayerInputAndOutputRanges(self, model, test_data):
        self.appendMinToGivenArray(self.minimum_output_values, test_data)
        self.appendMaxToGivenArray(self.maximum_output_values, test_data)

        for layer in model.layers:
            intermediate_layer_model = keras.Model(inputs=model.input, outputs=layer.output)
            intermediate_output = intermediate_layer_model.predict(test_data)
            self.appendMinToGivenArray(self.minimum_output_values, intermediate_output)
            self.appendMaxToGivenArray(self.maximum_output_values, intermediate_output)
    
    # Function to fill the weight value arrays for given weights with min and max values.
    def findLayerWeightRanges(self, model):
        for layer in model.layers:
            self.appendMinToGivenArray(self.minimum_weight_values, layer.get_weights())
            self.appendMaxToGivenArray(self.maximum_weight_values, layer.get_weights())
            
    # Function to get the scaling values for the layer output values.        
    def findLayerInputAndOutputScales(self):
        self.findScaleAndZeroPointForGivenData(self.maximum_output_values, self.minimum_output_values, self.quantized_output_scales, self.quantized_output_zeros)
            
    # Function to get the scaling values for the layer weight values.        
    def findLayerWeightScales(self):
        self.findScaleAndZeroPointForGivenData(self.maximum_weight_values, self.minimum_weight_values, self.quantized_weight_scales, self.quantized_weight_zeros)
    
    # Function to get the combined scaling constant value which can be used in the HW model units.
    def findFinalScalingConstant(self, model, scaler_width):   
        for layer_index in range(len(model.layers)):
            real_multiplier = self.quantized_output_scales[layer_index] * self.quantized_weight_scales[layer_index] / self.quantized_output_scales[layer_index+1]
            quantized_scale, shift_amount = self.getFinalScale(real_multiplier, scaler_width)
            
            self.combined_scales.append(quantized_scale)
            self.shift_amounts.append(shift_amount + scaler_width)
    
    # Function to process the given data and save the scaling and zero point values.
    def findScaleAndZeroPointForGivenData(self, max_values, min_values, scales_array, zeros_array):
        for layer_index in range(len(max_values)):
            scale, nudged_zero_point = self.findScaleAndZeroPoint(max_values[layer_index], min_values[layer_index])

            scales_array.append(scale)
            zeros_array.append(nudged_zero_point)
            
    # Function to append a minimum value which is smaller than 0 to the given array.        
    def appendMinToGivenArray(self, array, data):
        array.append(np.amin(np.array([0, np.amin(data)])))
        
    # Function to append a maximum value which is bigger than 0 to the given array.    
    def appendMaxToGivenArray(self, array, data):
        array.append(np.amax(np.array([0, np.amax(data)])))   

