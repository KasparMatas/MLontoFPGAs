# Simple program on how to load a model and run it in a session without knowing the input and output tensors.
# No optimisations done. Currently a bunch of hardcoded stuff is given because there is no input parsing. It should be able to do different things with the model given.
# I.e instead of test data accuracy give me just one image and say what it is.
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

def findInputs(tensorName, graphDef):
    for node in graphDef.node:
        if node.name == tensorName:
            for nodeInput in node.input:
                print(tensorName, "<-", nodeInput)
                findInputs(nodeInput, graphDef)

# Get current file path
import os
dir = os.path.dirname(os.path.realpath(__file__))

# Get the hardcoded input data. Could be given as an input to the program.
inputData = []
mnist_data = input_data.read_data_sets("MNIST_data/", one_hot=True) # Deprecated. Too lazy to understand how to do it now (without Keras)
inputData.append(mnist_data.test.images)
inputData.append(mnist_data.test.labels)

# Get tags and tensor signatrue keys to find the right input and output tensors
signature_key = tf.saved_model.signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY # Could be input to the program
modelTag = tf.saved_model.tag_constants.SERVING # Could be input to the program

# Create some lists
inputNames = []
outputNames = []
inputTensors = []
outputTensors = []

# Create a session so that dynamic data (unfrozen weights - variables's data) is loaded in as well. And we can also run it.
# Would be nice to say that the saved model has to be frozen - variables have been made into constants and pointless tensors for inference have been removed but go easy for now.
with tf.Session() as sess:

    meta_graph_def = tf.saved_model.loader.load(sess, [modelTag], dir + '/saver_data')
    
    for key in meta_graph_def.signature_def[signature_key].inputs: # Could be input to the program, i.e give the input keys
        inputNames.append(meta_graph_def.signature_def[signature_key].inputs[key].name)
    for key in meta_graph_def.signature_def[signature_key].outputs: # Could be input to the program, i.e give the output keys
        outputNames.append(meta_graph_def.signature_def[signature_key].outputs[key].name)

    for inputTensorName in inputNames:
        inputTensors.append(sess.graph.get_tensor_by_name(inputTensorName))
    for outputTensorName in outputNames:
        outputTensors.append(sess.graph.get_tensor_by_name(outputTensorName))

    inputFeed = {}
    for inputTensor in inputTensors:
        inputShape = tf.TensorShape(inputTensor.shape)
        for dataSet in inputData:
            dataShape = tf.TensorShape(dataSet.shape)
            if inputShape.is_compatible_with(dataShape):
                inputFeed[inputTensor] = dataSet
        # Assuming no errors here. Needs proper checks
    
    # Hardcoded 1 output. The outputs could also be given as an input to the program.
    # Needs a whole data structure which says which outputs need which inputs and what does the output mean.
    network_accuracy = sess.run(outputTensors[0], feed_dict=inputFeed) 
    print('The accuracy over the MNIST data is {:.2f}%'.format(network_accuracy * 100))

    # Outputs all of the tensors and operations involved to get this output. These tensor and op names will be printed.
    # These names can be used to find the shapes and additional info to help output the verilog file.
    # Again hardcoded for 1 output and we dont care about the name:0 at the end of a tensor name.
    # Here we shouldn't print tensor names but save the tensors into some data structure of our own.
    findInputs(outputTensors[0].name.split(":")[0],  sess.graph.as_graph_def())

    # Now we have all of the names of the tensors which produce our desired output. The problem is that those names can be
    # some custom names. So we can't use the names to determine what does the model do. Therefore we need to use the input
    # tensor to find out which consumers (operations) does it have and use the operation definitions to figure out what
    # does the model do. This is a lot of low level manual work which should be avoided.

    # More explanation on why we need to use the operation definitions. Tensors are simply data structures holding data
    # between operations. They can be any shipe they want and have any name they want. We could assume that the tensors
    # have default names but it isn't necesarrily the case. There fore we need to look at the operation definitions
    # connecting different tensors.

    print("inputTensor #0 consumer #0 type:", inputTensors[0].consumers()[0].op_def.name)
