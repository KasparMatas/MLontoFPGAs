from keras import backend as K
from tensorflow.keras.layers import Dense
import tensorflow as tf

class CustomDense(Dense):

    def __init__(self, units, scale, scale_shift_amount, input_offset, kernel_offset, output_offset, **kwargs):
        self.scale = scale
        self.scale_shift_amount = scale_shift_amount
        self.input_offset = input_offset
        self.kernel_offset = kernel_offset
        self.output_offset = output_offset
        super(CustomDense, self).__init__(units, **kwargs)

    def build(self, input_shape):
        super(CustomDense, self).build(input_shape)

    def call(self, inputs):
        scaling_constant = 2**(31+self.scale_shift_amount)
     
        output = K.dot(inputs - self.input_offset, self.kernel- self.kernel_offset)
        output = output * self.scale 
        output = output / scaling_constant
        output = K.round(output)
        output = output + self.output_offset
        
        if self.use_bias:
            raise Exception('Bias usage is not supported')
        #if self.activation is not None:
             #output = self.activation(output)
        return output

    def compute_output_shape(self, input_shape):
        super(CustomDense, self).build(input_shape)
