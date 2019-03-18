from keras import backend as K
from tensorflow.keras.layers import Dense
import tensorflow as tf

class DenseWithoutActivation(Dense):

    def __init__(self, units, **kwargs):
        super(DenseWithoutActivation, self).__init__(units, **kwargs)

    def call(self, inputs):
        output = K.dot(inputs, self.kernel)
        if self.use_bias:
            output = K.bias_add(output, self.bias, data_format='channels_last')
        return output