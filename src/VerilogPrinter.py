class VerilogPrinter:
    def __init__(self, output_file):
        self.output_file = output_file
        
    def defineClkAndDataWidth(self, data_width):
        self.output_file.write("`define DATA_WIDTH {}\n".format(data_width))
        self.output_file.write("\n")
        self.output_file.write("reg clk;\n")
        
    def printInputWires(self, wire_widths, output_wire_names):
        self.output_file.write("wire [{}-1:0] {};\n".format(wire_widths[0], output_wire_names[0]))
        self.output_file.write("wire [{}-1:0] {};\n".format(wire_widths[1], output_wire_names[1]))
        self.output_file.write("wire {};".format(output_wire_names[2]))
        
    def printGroundSignal(self):
        self.output_file.write("wire [`DATA_WIDTH*4:0] ground;\n")
        self.output_file.write("assign ground = 0;\n")