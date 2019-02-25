`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2018 17:26:02
// Design Name: 
// Module Name: relu_cell
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


module relu_cell#(
        parameter DATA_WIDTH = 8,
        parameter RESULT_WIDTH = 16,
        parameter CELL_AMOUNT = 4
    ) (
        input wire clk,
        input wire [RESULT_WIDTH:0] input_result,
        output reg [DATA_WIDTH-1:0] output_index,
        output reg [DATA_WIDTH-1:0] output_value,
        output reg output_enable
    );
    
reg [DATA_WIDTH-1:0] index;
    
initial begin
    index = 0;
end
    
always @ (posedge clk) begin #1
    if (input_result[RESULT_WIDTH]) begin
        if (input_result[RESULT_WIDTH-1]) output_value <= 0;
        else output_value <= input_result[RESULT_WIDTH-1:0];
        if (index == CELL_AMOUNT) begin
            output_index <= 0;
            index <= 1;
        end
        else begin
            output_index <= index;
            index <= index + 1;
        end
        output_enable <= 1;
    end
    else begin 
        output_enable <= 0;
        output_index <= 0;
        output_value <= 0;
    end
end

endmodule
