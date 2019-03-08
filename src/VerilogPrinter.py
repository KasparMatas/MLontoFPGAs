# Class to print some initial wires.
class VerilogPrinter:
    # Constructor which saves the output file.
    def __init__(self, output_file):
        self.output_file = output_file
        
    # Function to print the clcok signal and define the base data width.    
    def defineClkAndDataWidth(self, data_width):
        self.output_file.write("`define DATA_WIDTH {}\n".format(data_width))
        self.output_file.write("\n")
        self.output_file.write("reg clk;\n")
        
    # Function to print the input wires.    
    def printInputWires(self, wire_widths, output_wire_names):
        self.output_file.write("wire [{}-1:0] {};\n".format(wire_widths[0], output_wire_names[0]))
        self.output_file.write("wire [{}-1:0] {};\n".format(wire_widths[1], output_wire_names[1]))
        self.output_file.write("wire {};".format(output_wire_names[2]))
        
    # Function to print a ground signal which can be used for input result signals which 
    # aren't used.    
    def printGroundSignal(self):
        self.output_file.write("wire [`DATA_WIDTH*4:0] ground;\n")
        self.output_file.write("assign ground = 0;\n")
