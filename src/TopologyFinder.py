import tensorflow as tf
from tensorflow import keras

from TreeNode import TreeNode

# Class to help that the input model is supported by this script.
class TopologyFinder:
    # Pointless function if all of the layers are ordered in kerasModel.layers and there is no splitting.
    # But if some layers have multiple inputs/outputs this will construct the proper tree/graph.
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
                    TopologyFinder.findInputs(treeRoot, currentNode, layer.input, kerasModel)

    # Function to print the layers and their parents
    def printLayers(childNode):
        for parent in childNode.parents:
            if childNode.value != None:
                print(childNode.value.__class__.__name__, "->", parent.value.__class__.__name__)
                TopologyFinder.printLayers(parent)
    
    # Function to print the neural network topology 
    def printTopology(arrayOfInputLayers):
        for leafNodeIndex in range (0, len(arrayOfInputLayers)):
            print ("Input", leafNodeIndex)
            TopologyFinder.printLayers(arrayOfInputLayers[leafNodeIndex])
            
    # Method which checks that the given model has a supported topology.
    def assertSuitableTopology(arrayOfInputLayers):
        if(len(arrayOfInputLayers)!=1):
            raise Exception("Please submit a model which only has one input")
        else:
            TopologyFinder.assertOneOutputAndInput(arrayOfInputLayers[0])
            
    # Method which checks that there are no layers with multiple inputs or outputs.
    def assertOneOutputAndInput(childNode):
        if len(childNode.parents) > 1:
            raise Exception("Please submit a sequential model")
        elif len(childNode.parents) == 1:
            TopologyFinder.assertOneOutputAndInput(childNode.parents[0])
