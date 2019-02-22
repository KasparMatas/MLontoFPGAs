import numpy as np

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

right = np.random.rand(4,4)
left = np.random.rand(1,4)
result = np.dot(left, right)

print("Input: \n", right)
print("Weights: ", left)
print("Result: ", result)



minimum_values = []
maximum_values = []

minimum_values.append(np.amin(np.array([0, np.amin(right)])))
maximum_values.append(np.amax(np.array([0, np.amax(right)])))
minimum_values.append(np.amin(np.array([0, np.amin(left)])))
maximum_values.append(np.amax(np.array([0, np.amax(left)])))
minimum_values.append(np.amin(np.array([0, np.amin(result)])))
maximum_values.append(np.amax(np.array([0, np.amax(result)])))

print("Mins: ", minimum_values)
print("Maxs: ", maximum_values)

quantized_scales = []
quantized_zeros = []
qmin = 0
qmax = 255

for layer_index in range(len(minimum_values)):
    
    scale, nudged_zero_point = findScaleAndZeroPoint(maximum_values[layer_index], minimum_values[layer_index])

    quantized_scales.append(scale)
    quantized_zeros.append(nudged_zero_point)

print("Scales: ", quantized_scales)
print("Zeroes: ", quantized_zeros)

quantized_right = quantizeMatrix(right, quantized_scales[0], quantized_zeros[0])
quantized_left = quantizeMatrix(left, quantized_scales[1], quantized_zeros[1])

real_multiplier = quantized_scales[1] * quantized_scales[0] / quantized_scales[2]
quantized_scale, shift_amount = getFinalScale(real_multiplier)

print("Scaled scaling constant: ", quantized_scale, " shifted ", shift_amount, " times.")

print("All offline work done now! The following calculations will be done one the fly in the NN.")
# The zero point addition (subtraction) can be optimized.
acc = np.dot(quantized_left - quantized_zeros[1], quantized_right - quantized_zeros[0])
acc = acc * quantized_scale
acc = acc / 2**(31+shift_amount)
acc = np.round(acc)
acc = acc + quantized_zeros[2]

quantized_result = acc

dequantized_result = quantized_scales[2]*(quantized_result - quantized_zeros[2])
print("Result is: ", quantized_result)
print("Dequantized result is: ", dequantized_result)
print("Difference from the real result is: %0.3f%%" % np.average(np.abs(result-dequantized_result)/result*100))

"""
To see how the scale quantization works

#real_value = scale * (quantized_value - zero_point)
print("Correct result: ",0.2 * (22 - 2))
quantized_scale, shift_amount = getFinalScale(0.2)
print(quantized_scale * (22 - 2) / (2**31 * 2**shift_amount))
"""