class ArgmaxCellPrinter:
    
    def printWires(self, output_file):
        output_file.write("wire [`DATA_WIDTH*5:0] output_result;\n")
    
    def printInitialParameters(self, wire_widths, weight_amount, output_file):
        output_file.write("argmax_cell  #(\n")
        output_file.write("    .DATA_WIDTH({}),\n".format(wire_widths[1]))
        output_file.write("    .RESULT_WIDTH({}),\n".format(wire_widths[2]))
        output_file.write("    .INDEX_WIDTH({}),\n".format(wire_widths[0]))
        output_file.write("    .CELL_AMOUNT({})\n".format(weight_amount))
        
    def printInstanceName(self, output_file):
        output_file.write(") result_cell (\n")    
    
    def printInputsOutputs(self, input_wire_names, output_file):
        output_file.write("    .clk(clk),\n")
        output_file.write("    .input_index({}),\n".format(input_wire_names[0]))
        output_file.write("    .input_value({}),\n".format(input_wire_names[1]))
        output_file.write("    .input_enable({}),\n".format(input_wire_names[2]))
        output_file.write("    .output_result({})\n".format("output_result"))
        output_file.write(");\n")
    
    def printArgmaxCell(self, wire_widths, input_wire_names, amount_of_units_in_a_layer, output_file):
        self.printInitialParameters(wire_widths, amount_of_units_in_a_layer, output_file)
        self.printInstanceName(output_file)
        self.printInputsOutputs(input_wire_names, output_file)
    
    def printArgmax(self, amount_of_units_in_a_layer, wire_widths, input_wire_names, output_file):       
        output_file.write("\n")
        self.printWires(output_file)
        output_file.write("\n")
        self.printArgmaxCell(wire_widths, input_wire_names, amount_of_units_in_a_layer, output_file)
        
        return ["output_result"]
