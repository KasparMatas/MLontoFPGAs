class VerilogPrinter:
    def __init__(self, output_file):
        self.output_file = output_file
        
    def defineClkAndDataWidth(self, data_width):
        self.output_file.write("`define DATA_WIDTH {}\n".format(data_width))
        self.output_file.write("\n")
        self.output_file.write("reg clk;\n")
        
    def printInputWires(self, output_wire_names):
        self.output_file.write("wire [`DATA_WIDTH-1:0] {};\n".format(output_wire_names[0]))
        self.output_file.write("wire [`DATA_WIDTH-1:0] {};\n".format(output_wire_names[1]))
        self.output_file.write("wire [`DATA_WIDTH*2+2:0] {};\n".format(output_wire_names[2]))
        self.output_file.write("wire {};".format(output_wire_names[3]))
        
    def printGroundSignal(self):
        self.output_file.write("wire [`DATA_WIDTH*2+2:0] ground;\n")
        self.output_file.write("assign ground = 0;\n")