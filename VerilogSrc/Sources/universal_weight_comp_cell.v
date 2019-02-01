`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.12.2018 17:42:16
// Design Name: 
// Module Name: universal_weight_comp_cell
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

module universal_weight_comp_cell #(
        parameter DATA_WIDTH = 32,
        parameter WEIGHT_AMOUNT = 4,
        parameter [8*WEIGHT_AMOUNT-1:0] WEIGHTS = {8'd0, 8'd0, 8'd0, 8'd0},
        parameter INPUT_AMOUNT = 4
    ) (
        input wire clk,
        input wire [DATA_WIDTH-1:0] input_index,
        input wire [INPUT_AMOUNT*DATA_WIDTH-1:0] input_value,
        input wire [DATA_WIDTH:0] input_result,
        input wire input_enable,
        output reg [DATA_WIDTH-1:0] output_index,
        output reg [INPUT_AMOUNT*DATA_WIDTH-1:0] output_value,
        output reg [DATA_WIDTH:0] output_result,
        output reg output_enable
    );
    
reg [DATA_WIDTH-1:0] accumulator;
reg [DATA_WIDTH:0] result;
wire [(INPUT_AMOUNT+1)*DATA_WIDTH-1:0] joint_accumulator; 

generate 
    genvar i;
    for (i = 0; i<INPUT_AMOUNT; i = i + 1) begin : mac_block 
        multiply_and_add #(
            .DATA_WIDTH(DATA_WIDTH)
        ) uut (
            .add_value(joint_accumulator[DATA_WIDTH*i +: DATA_WIDTH]),
            .input_value(input_value[DATA_WIDTH*i +: DATA_WIDTH]),
            .weight_value(WEIGHTS[8*(input_index+i) +: 8]),
            .output_value(joint_accumulator[DATA_WIDTH*(i+1) +: DATA_WIDTH])
        );
    end
endgenerate

initial begin 
    result = 0; 
    accumulator = 0;
end

assign joint_accumulator[0 +: DATA_WIDTH] = accumulator;

always @ (posedge clk) begin #1
    if (input_enable) begin
        if (input_index == WEIGHT_AMOUNT-INPUT_AMOUNT && input_result[DATA_WIDTH]) begin
            result <= {1'b1, joint_accumulator[DATA_WIDTH*INPUT_AMOUNT +: DATA_WIDTH]};
            accumulator <= 0; 
        end
        else accumulator <= joint_accumulator[DATA_WIDTH*INPUT_AMOUNT +: DATA_WIDTH]; 
        output_value <= input_value;
        output_index <= input_index;
        output_enable <= input_enable;
    end
    else begin
        output_value <= 0;
        output_index <= 0;
        output_enable <= 0;
    end
    
    if (input_result[DATA_WIDTH]) output_result <= input_result;
    else begin
        if (result[DATA_WIDTH]) begin 
            output_result <= result;
            result[DATA_WIDTH] <= 1'b0;
        end
        else if (input_enable && input_index == WEIGHT_AMOUNT-INPUT_AMOUNT) begin
            output_result <= {1'b1, joint_accumulator[DATA_WIDTH*INPUT_AMOUNT +: DATA_WIDTH]};
            accumulator <= 0;
        end
        else output_result <= 0; 
    end
end

//function [DATA_WIDTH-1:0] increase_value(input reg [DATA_WIDTH-1:0] initial_value);
//begin
//    increase_value = 
//    ((((initial_value + input_value[DATA_WIDTH*0 +: DATA_WIDTH] * WEIGHTS[8*(input_index+0) +: 8])
//                      + input_value[DATA_WIDTH*1 +: DATA_WIDTH] * WEIGHTS[8*(input_index+1) +: 8]) 
//                      + input_value[DATA_WIDTH*2 +: DATA_WIDTH] * WEIGHTS[8*(input_index+2) +: 8]) 
//                      + input_value[DATA_WIDTH*3 +: DATA_WIDTH] * WEIGHTS[8*(input_index+3) +: 8]);
//end
//endfunction

//initial begin 
//    result = 0; 
//end
    
//always @ (posedge clk) begin
//    if (input_enable) begin
//        if (input_index == 0) accumulator <= increase_value(0);
//        else if (input_index == WEIGHT_AMOUNT-INPUT_AMOUNT && input_result[DATA_WIDTH]) 
//            result <= {1'b1, increase_value(accumulator)};
//        else accumulator <= increase_value(accumulator);
        
//        output_value <= input_value;
//        output_index <= input_index;
//        output_enable <= input_enable;
//    end
//    else begin
//        output_value <= 0;
//        output_index <= 0;
//        output_enable <= 0;
//    end
    
//    if (input_result[DATA_WIDTH]) output_result <= input_result;
//    else begin
//        if (result[DATA_WIDTH]) begin 
//            output_result <= result;
//            result[DATA_WIDTH] <= 1'b0;
//        end
//        else if (input_enable && input_index == WEIGHT_AMOUNT-INPUT_AMOUNT) 
//            output_result <= {1'b1, increase_value(accumulator)};
//        else output_result <= 0; 
//    end
//end

endmodule