# Learning files
These files have nothing to do in the implementation of the tool but are created while trying to understand the different aspects of TensorFlow and Keras.

All of these files were crucial to understand before starting working on the project.

### createKerasModel
Python file which creates and saves a model using the Keras API.

### loadKerasModel
Python file which loads the model created by createKerasModel.py and runs it.

### createTensorFlowModel
Python file which creates and saves a model using the SavedModel API.

### loadTensorFlowModel
Python file which loads the model created by createTensorFlowModel.py and runs it and analyses the model as well.

### runTranslatedKerasModel
Python file which just creates a model and runs it. It is the same model as in the createKerasModel.py but made  without the Keras API

### createSimpleKerasModel
This creates a simpler MLP model using Keras which doesn't have biases or activation functions.

### quantizedMatrixDotProduct
File which demonstrates how to quantize floating values into integers and use the new values in a matrix dot product operation with minor changes to the end result

### customDense
A Keras layer model which extends the Keras Dense layer to use the quantized arithmetic instead of the regular dot product logic. 

### runQuantizedSimpleKerasModel
File which takes simple_keras_model.h5 file and creates a new model mimicking the input model but all of the logic is done using integers not floats. 