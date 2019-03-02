class DenseCellPrinter:

  def printWires(self, output_wire_names, output_file):
    output_file.write("wire [`DATA_WIDTH-1:0] {};\n".format(output_wire_names[0]))
    output_file.write("wire [`DATA_WIDTH-1:0] {};\n".format(output_wire_names[1]))
    output_file.write("wire [`DATA_WIDTH*2+2:0] {};\n".format(output_wire_names[2]))
    output_file.write("wire {};".format(output_wire_names[3]))
  
  def printInitialParameters(self, data_width, weight_amount, output_file):
    output_file.write("weight_comp_cell #(\n")
    output_file.write("    .DATA_WIDTH({}),\n".format(data_width))
    output_file.write("    .RESULT_WIDTH({}*2+2),\n".format(data_width))
    output_file.write("    .WEIGHT_AMOUNT({}),\n".format(weight_amount))
  
  def printAdditionalParameters(self, weight_zero_point, input_zero_point, output_file):
    output_file.write("    .WEIGHT_OFFSET({}),\n".format(int(weight_zero_point)))
    output_file.write("    .INPUT_OFFSET({}),\n".format(int(input_zero_point)))
  
  def formatWeights(self, weights):
    weightString = ""
    for weight in weights:
      weightString += "8'd{}, ".format(int(weight))
    weightString = weightString[:-2]
    return weightString
  
  def printWeights(self, weights, output_file):
    output_file.write("    .WEIGHTS({})\n".format(self.formatWeights(weights)))

  def printInstanceName(self, cell_index, layer_index, output_file):
    output_file.write(") cell_{0}_{1} (\n".format(layer_index, cell_index))
  
  def printInputsOutputs(self, input_wire_names, output_wire_names, output_file):
    output_file.write("    .clk(clk),\n")
    output_file.write("    .input_index({}),\n".format(input_wire_names[0]))
    output_file.write("    .input_value({}),\n".format(input_wire_names[1]))
    output_file.write("    .input_result({}),\n".format(input_wire_names[2]))
    output_file.write("    .input_enable({}),\n".format(input_wire_names[3]))
    output_file.write("    .output_index({}),\n".format(output_wire_names[0]))
    output_file.write("    .output_value({}),\n".format(output_wire_names[1]))
    output_file.write("    .output_result({}),\n".format(output_wire_names[2]))
    output_file.write("    .output_enable({})\n".format(output_wire_names[3]))
    output_file.write(");\n")
  
  def generateOutputWireNames(self, cell_index, layer_index):
    output_wire_names = []
    output_wire_names.append("index_{0}_{1}_{2}".format(layer_index, cell_index, cell_index+1))
    output_wire_names.append("value_{0}_{1}_{2}".format(layer_index, cell_index, cell_index+1))
    output_wire_names.append("result_{0}_{1}_{2}".format(layer_index, cell_index, cell_index+1))
    output_wire_names.append("enable_{0}_{1}_{2}".format(layer_index, cell_index, cell_index+1))
    return output_wire_names
  
  def printIndividualCell(self, weights, unit_index, layer_index, input_wire_names, output_wire_names, 
                          quantizer, output_file):
    self.printInitialParameters("`DATA_WIDTH", len(weights[unit_index]), output_file)
    self.printAdditionalParameters(quantizer.quantized_weight_zeros[layer_index], 
                                   quantizer.quantized_output_zeros[layer_index], output_file)
    self.printWeights(weights[unit_index], output_file)
    self.printInstanceName(unit_index, layer_index, output_file)
    self.printInputsOutputs(input_wire_names, output_wire_names, output_file)

  def printCells(self, weights, layer_index, quantizer, amount_of_units_in_a_layer, input_wire_names, output_file):
    for unit_index in range (amount_of_units_in_a_layer):
      output_wire_names = self.generateOutputWireNames(unit_index, layer_index)
    
      output_file.write("\n")
      self.printWires(output_wire_names, output_file)
      output_file.write("\n")
      self.printIndividualCell(weights, unit_index, layer_index, input_wire_names, output_wire_names, 
                               quantizer, output_file)
    
      input_wire_names = output_wire_names
    return input_wire_names

