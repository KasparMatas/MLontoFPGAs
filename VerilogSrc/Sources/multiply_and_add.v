`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.01.2019 11:24:23
// Design Name: 
// Module Name: multiply_and_add
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module multiply_and_add #(
    parameter DATA_WIDTH = 32
    ) (
    input wire [DATA_WIDTH-1:0] add_value,
    input wire [DATA_WIDTH-1:0] input_value,
    input wire [7:0] weight_value,
    output wire [DATA_WIDTH-1:0] output_value
    );
    
assign output_value = add_value + input_value * weight_value;

endmodule
