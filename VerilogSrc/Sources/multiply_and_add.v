`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Multiply and adder which can be generated required amount of times in the 
// universal weight_comp_cell module.
//////////////////////////////////////////////////////////////////////////////////


module multiply_and_add #(
    parameter DATA_WIDTH = 8,
    parameter RESULT_WIDTH = 16
    ) (
    input wire signed [RESULT_WIDTH-1:0] add_value,
    input wire signed [DATA_WIDTH-1:0] input_value,
    input wire signed [7:0] weight_value,
    output wire signed [RESULT_WIDTH-1:0] output_value
    );
    
assign output_value = add_value + input_value * weight_value;

endmodule
