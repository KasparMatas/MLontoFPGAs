# TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras

from WeightCellPrint import WeightCellPrinter

# For numpy array manipulation
import numpy as np

# Data structure for storing the layers
class TreeNode:
    def __init__(self, value):
        self.value = value
        self.children = []
        self.parents = []

    def findChildNode(self, nodeValue):
        if self.value == nodeValue: 
            return self
        else:
            for child in self.children:
                possibleNode = child.findChildNode(nodeValue)
                if possibleNode != None:
                    return possibleNode
            return None

    def findLeafNodes(self, leafNodes):
        if len(self.children) == 0:
            leafNodes.append(self)
        else:
            for child in self.children:
                child.findLeafNodes(leafNodes)

def findInputs(treeRoot, targetLayerNode, outputTensor, kerasModel):
    for layer in kerasModel.layers:
        if layer.output == outputTensor:
            if targetLayerNode == None:
                targetLayerNode = TreeNode(layer)
                treeRoot.children.append(targetLayerNode)
                currentNode = targetLayerNode
            else:
                currentNode = treeRoot.findChildNode(layer)
                if currentNode == None:
                    currentNode = TreeNode(layer)
                targetLayerNode.children.append(currentNode)
                currentNode.parents.append(targetLayerNode)
            if layer.input != None:
                findInputs(treeRoot, currentNode, layer.input, kerasModel)

def printLayers(childNode):
    for parent in childNode.parents:
        if childNode.value != None:
            print(childNode.value.__class__.__name__, "->", parent.value.__class__.__name__)
            printLayers(parent)

def processLayers(childNode, outputFile, inputWires, layerIndex):
    for parent in childNode.parents:
        if parent.value != None:
            outputWires = createVerilog(layerIndex, parent.value, outputFile, inputWires)
            processLayers(parent, outputFile, outputWires, layerIndex + 1)

def denseHandler(layerIndex, layer, outputFile, inputWires):
    layerConfig = layer.get_config()
    weightCellPrinter = WeightCellPrinter()
    outputWires = weightCellPrinter.printCells(layer.get_weights()[0], layerIndex, layerConfig["units"],
                                               inputWires, outputFile)
    if (layerConfig["use_bias"]):
        outputFile.write("// Processing element for bias addition with biases layer.get_weights()[1]\n")
    outputFile.write("// Processing element for activation function " + layerConfig["activation"] + "\n")
    outputFile.write("\n")
    return outputWires 

def defaultHandler(layerIndex, layer, outputFile, inputWires):
    outputFile.write("// Some processing elements for " + layer.__class__.__name__ + " layer\n")
    outputFile.write("\n")
    return inputWires

def createVerilog(layerIndex, layer, outputFile, inputWires):
    layerHandlers = {keras.layers.Dense(1).__class__.__name__ : denseHandler}
    return layerHandlers.get(layer.__class__.__name__, defaultHandler)(layerIndex, layer, outputFile, inputWires)

loaded_model = keras.models.load_model("keras_model.h5")

# If we wanted to run the model
'''
(train_images, train_labels), (test_images, test_labels) = keras.datasets.mnist.load_data()
test_images = test_images / 255.0
test_images = test_images.reshape([-1,28,28,1])
'''

# Sample on how to evaluate
'''
test_loss, test_acc = loaded_model.evaluate(test_images, test_labels, batch_size=32)
print("Test accuracy:", test_acc)
'''

# Sample on how to predict an image
'''
image_input = np.expand_dims(test_images[0], axis=0)
print("Prediction for number ", test_labels[0], " is: ", loaded_model.predict_classes(image_input)[0])
'''

# Tree of layers, assuming graph only has one output but multiple inputs are fine. 
# It is also lacking any kind of error handling.
treeOfLayers = TreeNode(None)
findInputs(treeOfLayers, None, loaded_model.output, loaded_model)

inputLayers = []
treeOfLayers.children[0].findLeafNodes(inputLayers)

#Currently only working with one input and output
print ("Creating verilog for the following graph: ")
for leafNodeIndex in range (0, len(inputLayers)):
    print ("Input", leafNodeIndex)
    printLayers(inputLayers[leafNodeIndex])


# The processing needs to have the different processing elements connected with some wires.
# The weights will be fed into some parameters to hard code them into the elements which would end up sitting on the BRAM.
# The whole code needs to get split up into different classes and files.
outputVerilogFile = open("tensorFlowModel.v","w")

# Start writining structural verilog.
outputVerilogFile.write("// Some magical memory controller code\n")
outputVerilogFile.write("\n")
outputVerilogFile.write("// Some magical FSM code\n")
outputVerilogFile.write("\n")

inputWires = ["input_index", "input_value", "input_result", "input_enable"]

outputVerilogFile.write("reg clk;\n".format(inputWires[0]))
outputVerilogFile.write("reg [`DATA_WIDTH-1:0] {};\n".format(inputWires[0]))
outputVerilogFile.write("reg [`DATA_WIDTH-1:0] {};\n".format(inputWires[1]))
outputVerilogFile.write("reg [`DATA_WIDTH:0] {};\n".format(inputWires[2]))
outputVerilogFile.write("reg {};\n".format(inputWires[3]))

inputWires = createVerilog(0, inputLayers[0].value, outputVerilogFile, inputWires)
processLayers(inputLayers[0], outputVerilogFile, inputWires, 1)
outputVerilogFile.close()
