from keras import backend as K
from tensorflow.keras.layers import Dense
import tensorflow as tf

class CustomDense(Dense):

    def __init__(self, units, scale, scale_shift_amount, **kwargs):
        self.scale = scale
        self.scale_shift_amount = scale_shift_amount
        super(CustomDense, self).__init__(units, **kwargs)

    def build(self, input_shape):
        super(CustomDense, self).build(input_shape)

    def call(self, inputs):
        scaling_constant = 2**(31+self.scale_shift_amount)
     
        output = K.dot(inputs, self.kernel)
        output = output * self.scale 
        output = output / scaling_constant
        output = K.round(output)
        
        if self.use_bias:
            raise Exception('Bias usage is not supported')
        if self.activation is not None:
             output = self.activation(output)
        return output

    def compute_output_shape(self, input_shape):
        super(CustomDense, self).build(input_shape)
