`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2018 18:03:33
// Design Name: 
// Module Name: weight_comp_cell
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
// NEEDS TO HAVE 0 ENABLE AT THE BEGINNING

module weight_comp_cell #(
        parameter DATA_WIDTH = 8,
        parameter RESULT_WIDTH = 16,
        parameter INDEX_WIDTH = 10,
        parameter WEIGHT_AMOUNT = 4,
        parameter WEIGHT_OFFSET = 0,
        parameter INPUT_OFFSET = 0,
        parameter [8*WEIGHT_AMOUNT-1:0] WEIGHTS = {8'd0, 8'd0, 8'd0, 8'd0}
    ) (
        input wire clk,
        input wire [INDEX_WIDTH-1:0] input_index,
        input wire [DATA_WIDTH-1:0] input_value,
        input wire [RESULT_WIDTH:0] input_result,
        input wire input_enable,
        output reg [INDEX_WIDTH-1:0] output_index,
        output reg [DATA_WIDTH-1:0] output_value,
        output reg [RESULT_WIDTH:0] output_result,
        output reg output_enable
    );
    
reg signed [RESULT_WIDTH-1:0] accumulator;
reg [RESULT_WIDTH:0] result;
wire signed [RESULT_WIDTH-1:0] next_add;
wire signed [RESULT_WIDTH-1:0] next_input;
wire signed [RESULT_WIDTH-1:0] next_rweight;
wire signed [RESULT_WIDTH-1:0] next_qweight;

assign next_add = (input_value - INPUT_OFFSET) * (WEIGHTS[8*input_index +: 8] - WEIGHT_OFFSET);
assign next_input = (input_value - INPUT_OFFSET);
assign next_rweight = (WEIGHTS[8*input_index +: 8] - WEIGHT_OFFSET);
assign next_qweight = WEIGHTS[8*input_index +: 8];

initial begin 
    result = 0; 
end
    
always @ (posedge clk) begin #1
    if (input_enable) begin
        if (input_index == 0) accumulator <= 0 + next_add;
        else if (input_index == WEIGHT_AMOUNT-1 && input_result[RESULT_WIDTH]) 
            result <= {1'b1, accumulator + next_add};
        else accumulator <= accumulator + next_add;
        
        output_value <= input_value;
        output_index <= input_index;
        output_enable <= input_enable;
    end
    else begin
        output_value <= 0;
        output_index <= 0;
        output_enable <= 0;
    end
    
    if (input_result[RESULT_WIDTH]) output_result <= input_result;
    else begin
        if (result[RESULT_WIDTH]) begin 
            output_result <= result;
            result[RESULT_WIDTH] <= 1'b0;
        end
        else if (input_enable && input_index == WEIGHT_AMOUNT-1) 
            output_result <= {1'b1, accumulator + next_add};
        else output_result <= 0; 
    end
end

endmodule
