# Data structure for storing the layers
class TreeNode:
    def __init__(self, value):
        self.value = value
        self.children = []
        self.parents = []

    # Find a node with the desired value amongs the children of this node
    def findChildNode(self, nodeValue):
        if self.value == nodeValue: 
            return self
        else:
            for child in self.children:
                possibleNode = child.findChildNode(nodeValue)
                if possibleNode != None:
                    return possibleNode
            return None

    # Find all nodes with no children
    def fillLeafNodeArray(self, leafNodeArray):
        if len(self.children) == 0:
            leafNodeArray.append(self)
        else:
            for child in self.children:
                child.fillLeafNodeArray(leafNodeArray)