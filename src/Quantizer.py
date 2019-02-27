import tensorflow as tf
from tensorflow import keras
import numpy as np

class Quantizer:
    def __init__(self, min_qunatized_value, max_quantized_value):
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
        
    def quantizeMatrix(self, original_values, scale, zero_point):
        transformed_val = zero_point + original_values / scale
        clamped_val = np.maximum(self.qmin, np.minimum(self.qmax, transformed_val))
        return(np.around(clamped_val))

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
        
    def findLayerInputAndOutputRanges(self, model, test_data):
        self.appendMinToGivenArray(self.minimum_output_values, test_data)
        self.appendMaxToGivenArray(self.maximum_output_values, test_data)

        for layer in model.layers:
            intermediate_layer_model = keras.Model(inputs=model.input, outputs=layer.output)
            intermediate_output = intermediate_layer_model.predict(test_data)
            self.appendMinToGivenArray(self.minimum_output_values, intermediate_output)
            self.appendMaxToGivenArray(self.maximum_output_values, intermediate_output)
            
    def findLayerWeightRanges(self, model):
        for layer in model.layers:
            self.appendMinToGivenArray(self.minimum_weight_values, layer.get_weights())
            self.appendMaxToGivenArray(self.maximum_weight_values, layer.get_weights())
            
    def findLayerInputAndOutputScales(self):
        self.findScaleAndZeroPointForGivenData(self.maximum_output_values, self.minimum_output_values, self.quantized_output_scales, self.quantized_output_zeros)
            
    def findLayerWeightScales(self):
        self.findScaleAndZeroPointForGivenData(self.maximum_weight_values, self.minimum_weight_values, self.quantized_weight_scales, self.quantized_weight_zeros)
    
    def findFinalScalingConstant(self, model, scaler_width):   
        for layer_index in range(len(model.layers)):
            real_multiplier = self.quantized_output_scales[layer_index] * self.quantized_weight_scales[layer_index] / self.quantized_output_scales[layer_index+1]
            quantized_scale, shift_amount = self.getFinalScale(real_multiplier, scaler_width)
            
            self.combined_scales.append(quantized_scale)
            self.shift_amounts.append(shift_amount)
    
    def findScaleAndZeroPointForGivenData(self, max_values, min_values, scales_array, zeros_array):
        for layer_index in range(len(max_values)):
            scale, nudged_zero_point = self.findScaleAndZeroPoint(max_values[layer_index], min_values[layer_index])

            scales_array.append(scale)
            zeros_array.append(nudged_zero_point)
            
    def appendMinToGivenArray(self, array, data):
        array.append(np.amin(np.array([0, np.amin(data)])))
        
    def appendMaxToGivenArray(self, array, data):
        array.append(np.amax(np.array([0, np.amax(data)])))   
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        