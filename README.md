# MLontoFPGAs
Python final year Bachelor of Science project which generates custom hardware based on a given tf.keras , TensorFlow's high-level Python API artificial neural network model.

## Goals
MLontoFPGAs is a tool which generates Verilog files based on the given TensorFlow model.
1. Helps better understand how neural networks created with the TensorFlow API could be accelerated on FPGAs.
2. Make accelerating TensorFlow artificial neural network models easier while exploiting FPGA strengths.
3. Create a tool which is easily expandable to create even more optimised hardware for ANNs.

## How to run
Install tensorflow like shown here: https://www.tensorflow.org/install/

When you have tensorflow and python installed on your system then you can call MLontoFPGAs.py with to arguments. The first argument is the path to the the keras .h5 file containing the model. Second argument is the path to the np data containing some data to run the given model with. That is to get the ranges of the data going through the model to quantize it according to the following scheme: https://github.com/google/gemmlowp/blob/master/doc/quantization.md?fbclid=IwAR2IzbxUEsPds_RRJSWhPDZOJO3ALB_Q6t2vhranP65ZYGptZCFf9HJJxbA#implementation-of-quantized-matrix-multiplication

Currently models with no biases or activation functions consisting only of Dense layers are supported. Lastly the models need to be decreasing in a sense that the layer i needs to have more units than i+1.
