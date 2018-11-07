# MLontoFPGAs
Python final year Bachelor of Science project which generates custom hardware based on a given tf.keras , TensorFlow's high-level Python API artificial neural network model.

## Goals
MLontoFPGAs is a tool which generates Verilog files based on the given TensorFlow model.
1. Helps better understand how neural networks created with the TensorFlow API could be accelerated on FPGAs.
2. Make accelerating TensorFlow artificial neural network models easier while exploiting FPGA strengths.
3. Create a tool which is easily expandable to create even more optimised hardware for ANNs.

## How to run
Install tensorflow like shown here: https://www.tensorflow.org/install/

After that you save your model into the file named "keras_model.h5" next to the MLontoFPGAs.py file and run it. That should generate a tensorFlowModel.v file which can be synthesised and then uploaded onto a FPGA board. 