class DenseScalerPrinter:
    
    def printWires(self, wire_widths, output_wire_names, output_file):
        output_file.write("wire [{}-1:0] {};\n".format(wire_widths[0], output_wire_names[0]))
        output_file.write("wire [{}-1:0] {};\n".format(wire_widths[1], output_wire_names[1]))
        output_file.write("wire {};".format(output_wire_names[2]))
    
    def generateOutputWireNames(self, layer_index):
        output_wire_names = []
        output_wire_names.append("scale_index_{}".format(layer_index))
        output_wire_names.append("scale_value_{}".format(layer_index))
        output_wire_names.append("scale_enable_{}".format(layer_index))
        return output_wire_names
    
    def printInitialParameters(self, wire_widths, quantizer, layer_index, weight_amount, output_file):
        output_file.write("scaler #(\n")
        output_file.write("    .DATA_WIDTH({}),\n".format(wire_widths[1]))
        output_file.write("    .RESULT_WIDTH({}),\n".format(wire_widths[2]))
        output_file.write("    .INDEX_WIDTH({}),\n".format(wire_widths[0]))
        output_file.write("    .SCALING_FACTOR({}),\n".format(int(quantizer.combined_scales[layer_index])))
        output_file.write("    .SHIFT_AMOUNT({}),\n".format(int(quantizer.shift_amounts[layer_index])))
        output_file.write("    .OUTPUT_OFFSET({}),\n".format(int(quantizer.quantized_output_zeros[layer_index+1])))
        output_file.write("    .CELL_AMOUNT({})\n".format(weight_amount))
        
    def printInstanceName(self, layer_index, output_file):
        output_file.write(") scaler_{0} (\n".format(layer_index))    
    
    def printInputsOutputs(self, input_wire_names, output_wire_names, output_file):
        output_file.write("    .clk(clk),\n")
        output_file.write("    .input_result({}),\n".format(input_wire_names[2]))
        output_file.write("    .output_index({}),\n".format(output_wire_names[0]))
        output_file.write("    .output_value({}),\n".format(output_wire_names[1]))
        output_file.write("    .output_enable({})\n".format(output_wire_names[2]))
        output_file.write(");\n")
    
    def printScalerCell(self, layer_index, input_wire_names, wire_widths, output_wire_names, 
                            quantizer, amount_of_units_in_a_layer, output_file):
        self.printInitialParameters(wire_widths, quantizer, layer_index, amount_of_units_in_a_layer, output_file)
        self.printInstanceName(layer_index, output_file)
        self.printInputsOutputs(input_wire_names, output_wire_names, output_file)
    
    def printScaler(self, layer_index, quantizer, amount_of_units_in_a_layer, wire_widths, input_wire_names, 
                    output_file):
        output_wire_names = self.generateOutputWireNames(layer_index)
        
        output_file.write("\n")
        self.printWires(wire_widths, output_wire_names, output_file)
        output_file.write("\n")
        self.printScalerCell(layer_index, input_wire_names, wire_widths, output_wire_names, quantizer, 
                             amount_of_units_in_a_layer, output_file)
        
        return output_wire_names