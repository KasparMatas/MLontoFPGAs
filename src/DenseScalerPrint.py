class DenseScalerPrinter:
    
    def printWires(self, output_wire_names, output_file):
        output_file.write("wire [`DATA_WIDTH-1:0] {};\n".format(output_wire_names[0]))
        output_file.write("wire [`DATA_WIDTH-1:0] {};\n".format(output_wire_names[1]))
        output_file.write("wire {};".format(output_wire_names[2]))
    
    def generateOutputWireNames(self, layer_index):
        output_wire_names = []
        output_wire_names.append("scale_index_{0}".format(layer_index))
        output_wire_names.append("scale_value_{0}".format(layer_index))
        output_wire_names.append("scale_enable_{0}".format(layer_index))
        return output_wire_names
    
    def printInitialParameters(self, data_width, quantizer, layer_index, weight_amount, output_file):
        output_file.write("scaler #(\n")
        output_file.write("    .DATA_WIDTH({}),\n".format(data_width))
        output_file.write("    .RESULT_WIDTH({}*2+2),\n".format(data_width))
        output_file.write("    .SCALING_FACTOR({}),\n".format(int(quantizer.combined_scales[layer_index])))
        output_file.write("    .SHIFT_AMOUNT({}),\n".format(int(quantizer.shift_amounts[layer_index])))
        output_file.write("    .OUTPUT_OFFSET({}),\n".format(int(quantizer.quantized_output_zeros[layer_index+1])))
        output_file.write("    .CELL_AMOUNT({}),\n".format(weight_amount))
        
    def printInstanceName(self, layer_index, output_file):
        output_file.write(") scaler_{0} (\n".format(layer_index))    
    
    def printInputsOutputs(self, input_wire_names, output_wire_names, output_file):
        output_file.write("    .clk(clk),\n")
        output_file.write("    .input_result({}),\n".format(input_wire_names[2]))
        output_file.write("    .output_index({}),\n".format(output_wire_names[0]))
        output_file.write("    .output_value({}),\n".format(output_wire_names[1]))
        output_file.write("    .output_enable({})\n".format(output_wire_names[2]))
        output_file.write(");\n")
    
    def printScalerCell(self, layer_index, input_wire_names, output_wire_names, 
                            quantizer, amount_of_units_in_a_layer, output_file):
        self.printInitialParameters("`DATA_WIDTH", quantizer, layer_index, amount_of_units_in_a_layer, output_file)
        self.printInstanceName(layer_index, output_file)
        self.printInputsOutputs(input_wire_names, output_wire_names, output_file)
    
    def printScaler(self, layer_index, quantizer, amount_of_units_in_a_layer, input_wire_names, output_file):
        output_wire_names = self.generateOutputWireNames(layer_index)
        
        output_file.write("\n")
        self.printWires(output_wire_names, output_file)
        output_file.write("\n")
        self.printScalerCell(layer_index, input_wire_names, output_wire_names, quantizer, 
                             amount_of_units_in_a_layer, output_file)
        
        return output_wire_names