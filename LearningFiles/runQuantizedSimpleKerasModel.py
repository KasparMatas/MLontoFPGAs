# TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras
import numpy as np

from customDense import CustomDense
from DenseWithoutActivation import DenseWithoutActivation

def quantizeMatrix(original_values, scale, zero_point):
    transformed_val = zero_point + original_values / scale
    clamped_val = np.maximum(0, np.minimum(255, transformed_val))
    return(np.around(clamped_val))

def getFinalScale(real_multiplier):
    if(real_multiplier > 1 or real_multiplier < 0):
        raise ValueError("Scale is outside of the required range: ", real_multiplier)
    
    nudge_factor = 0
    
    while (real_multiplier < 0.5):
        real_multiplier *= 2
        nudge_factor += 1
        
    quanatized_value = round(real_multiplier * (2**31))
    
    if(quanatized_value > (2**31)):
        raise ValueError("Something went wrong with scale quantization: ", quanatized_value)
        
    if (quanatized_value == 2**31):
        quanatized_value /= 2
        nudge_factor-=1
    
    if (nudge_factor<0):
        raise ValueError("Something went wrong with scale quantization: ", nudge_factor)
    if (quanatized_value>=(2**31)):
        raise ValueError("Something went wrong with scale quantization: ", quanatized_value)
        
    return(quanatized_value, nudge_factor)
    
def findScaleAndZeroPoint(max, min):
    qmin = 0
    qmax = 255
    
    scale = (max - min) / (qmax - qmin)
    initial_zero_point = qmin - min / scale
    
    if (initial_zero_point < qmin):
        nudged_zero_point = qmin
    elif (initial_zero_point > qmax):
        nudged_zero_point = qmax
    else:
        nudged_zero_point = round(initial_zero_point)

    return(scale, nudged_zero_point)
    
# LOADING THE INITIAL MODEL
    
mnist_dataset = keras.datasets.mnist
(train_images, train_labels), (test_images, test_labels) = mnist_dataset.load_data()

train_images = train_images / 255.0
test_images = test_images / 255.0

train_images = train_images.reshape(-1,784)
test_images = test_images.reshape(-1,784)

loaded_model = keras.models.load_model("simple_keras_model.h5")
test_loss, test_acc = loaded_model.evaluate(test_images, test_labels, batch_size=32)

# REMOVING FINAL ACTIVATION FUNCTION

layers=[]
for layer_id in range(len(loaded_model.layers)-1):
    layers.append(keras.layers.Dense.from_config(loaded_model.layers[layer_id].get_config()))

last_layer = loaded_model.layers[len(loaded_model.layers)-1]
last_layer.activation = keras.activations.linear
layers.append(DenseWithoutActivation.from_config(last_layer.get_config()))

obs_model = keras.Sequential(layers)
                          
for layer_index in range(len(loaded_model.layers)):
    weights = loaded_model.layers[layer_index].get_weights()
    obs_model.layers[layer_index].set_weights(weights)         
                          
# INTER LAYER QUANTIZATIONS

minimum_output_values = []
maximum_output_values = []

minimum_output_values.append(np.amin(np.array([0, np.amin(train_images)])))
maximum_output_values.append(np.amax(np.array([0, np.amax(train_images)])))

for layer_id in range(len(obs_model.layers)):
    intermediate_layer_model = keras.Model(inputs=obs_model.input,
                                           outputs=obs_model.layers[layer_id].output)
    intermediate_output = intermediate_layer_model.predict(test_images[0:1000])
    minimum_output_values.append(np.amin(np.array([0, np.amin(intermediate_output)])))
    maximum_output_values.append(np.amax(np.array([0, np.amax(intermediate_output)])))

quantized_output_scales = []
quantized_output_zeros = []

for layer_index in range(len(minimum_output_values)):
    
    scale, nudged_zero_point = findScaleAndZeroPoint(maximum_output_values[layer_index], minimum_output_values[layer_index])

    quantized_output_scales.append(scale)
    quantized_output_zeros.append(nudged_zero_point)

# WEIGHT QUANTIZATIONS

minimum_weight_values = []
maximum_weight_values = []

for layer in obs_model.layers:
    
    minimum_weight_values.append(np.amin(np.array([0, np.amin(layer.get_weights())])))
    maximum_weight_values.append(np.amax(np.array([0, np.amax(layer.get_weights())])))
    
quantized_weight_scales = []
quantized_weight_zeros = []
    
for layer_index in range(len(minimum_weight_values)):
    
    scale, nudged_zero_point = findScaleAndZeroPoint(maximum_weight_values[layer_index], minimum_weight_values[layer_index])

    quantized_weight_scales.append(scale)
    quantized_weight_zeros.append(nudged_zero_point)
    
combined_scales = []
shift_amounts = []    
    
for layer_index in range(len(obs_model.layers)):
    real_multiplier = quantized_output_scales[layer_index] * quantized_weight_scales[layer_index] / quantized_output_scales[layer_index+1]
    quantized_scale, shift_amount = getFinalScale(real_multiplier)
    
    combined_scales.append(quantized_scale)
    shift_amounts.append(shift_amount)
    
# QUANTIZED MODEL CREATION
# This is hardcoded to be the same as the given model and should be done differently to work with any model given.

quantize_model = keras.Sequential([
    CustomDense(100, combined_scales[0], shift_amounts[0], quantized_output_zeros[0], quantized_weight_zeros[0], quantized_output_zeros[1], activation=None, input_shape = (784,), use_bias=False),
    CustomDense(10, combined_scales[1], shift_amounts[1], quantized_output_zeros[1], quantized_weight_zeros[1], quantized_output_zeros[2], activation=None, input_shape = (100,), use_bias=False),
    CustomDense(10, combined_scales[2], shift_amounts[2], quantized_output_zeros[2], quantized_weight_zeros[2], quantized_output_zeros[3], activation=tf.nn.softmax, input_shape = (10,), use_bias=False)
])

quantize_model.compile(optimizer=keras.optimizers.Adam(lr=1e-4), 
              loss="sparse_categorical_crossentropy",
              metrics=["accuracy"])

quantized_input = quantizeMatrix(test_images, quantized_output_scales[0], quantized_output_zeros[0])              
              
for layer_index in range(len(obs_model.layers)):
    weights = obs_model.layers[layer_index].get_weights()
    quantize_model.layers[layer_index].set_weights(quantizeMatrix(weights, quantized_weight_scales[layer_index], quantized_weight_zeros[layer_index]))

quantized_test_loss, quantized_test_acc = quantize_model.evaluate(quantized_input, test_labels, batch_size=32)
print()
print()
print("Quantized test accuracy: ", quantized_test_acc, " vs initial test accuracy: ", test_acc)