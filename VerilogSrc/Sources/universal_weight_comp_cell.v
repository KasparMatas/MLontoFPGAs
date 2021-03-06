`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Broken universal cell. In the future this should be fixed to allow layer 
// configurations with varying unit counts.
//////////////////////////////////////////////////////////////////////////////////

module universal_weight_comp_cell #(
        parameter DATA_WIDTH = 8,
        parameter RESULT_WIDTH = 16,
        parameter INDEX_WIDTH = 10,
        parameter WEIGHT_AMOUNT = 4,
        parameter [8*WEIGHT_AMOUNT-1:0] WEIGHTS = {8'd0, 8'd0, 8'd0, 8'd0},
        parameter WEIGHT_OFFSET = 0, // Not implemented yet
        parameter INPUT_OFFSET = 0, // Not implemented yet
        parameter INPUT_AMOUNT = 4
    ) (
        input wire clk,
        input wire [INDEX_WIDTH-1:0] input_index,
        input wire [INPUT_AMOUNT*DATA_WIDTH-1:0] input_value,
        input wire [RESULT_WIDTH:0] input_result,
        input wire input_enable,
        output reg [INDEX_WIDTH-1:0] output_index,
        output reg [INPUT_AMOUNT*DATA_WIDTH-1:0] output_value,
        output reg [RESULT_WIDTH:0] output_result,
        output reg output_enable
    );
    
reg [RESULT_WIDTH-1:0] accumulator;
reg [RESULT_WIDTH:0] result;
wire [(INPUT_AMOUNT+1)*RESULT_WIDTH-1:0] joint_accumulator; 

generate 
    genvar i;
    for (i = 0; i<INPUT_AMOUNT; i = i + 1) begin : mac_block 
        multiply_and_add #(
            .DATA_WIDTH(DATA_WIDTH),
            .RESULT_WIDTH(RESULT_WIDTH)
        ) mac (
            .add_value(joint_accumulator[RESULT_WIDTH*i +: RESULT_WIDTH]),
            .input_value(input_value[DATA_WIDTH*i +: DATA_WIDTH]),
            .weight_value(WEIGHTS[8*(input_index*INPUT_AMOUNT+i) +: 8]),
            .output_value(joint_accumulator[RESULT_WIDTH*(i+1) +: RESULT_WIDTH])
        );
    end
endgenerate

initial begin 
    result = 0; 
    accumulator = 0;
end

assign joint_accumulator[0 +: RESULT_WIDTH] = accumulator;

always @ (posedge clk) begin #1
    if (input_enable) begin
        if (input_index*INPUT_AMOUNT == WEIGHT_AMOUNT-INPUT_AMOUNT && input_result[RESULT_WIDTH]) begin
            result <= {1'b1, joint_accumulator[RESULT_WIDTH*INPUT_AMOUNT +: RESULT_WIDTH]};
            accumulator <= 0; 
        end
        else accumulator <= joint_accumulator[RESULT_WIDTH*INPUT_AMOUNT +: RESULT_WIDTH]; 
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
        else if (input_enable && input_index*INPUT_AMOUNT == WEIGHT_AMOUNT-INPUT_AMOUNT) begin
            output_result <= {1'b1, joint_accumulator[RESULT_WIDTH*INPUT_AMOUNT +: RESULT_WIDTH]};
            accumulator <= 0;
        end
        else output_result <= 0; 
    end
end

endmodule