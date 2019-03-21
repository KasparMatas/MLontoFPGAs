`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Base cell from which the systolic array consists of. 
// Takes the input and multiplies with the weight and adds the results together. 
// Finally it passes the results forward.
//////////////////////////////////////////////////////////////////////////////////

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

assign next_add = (input_value - INPUT_OFFSET) * (WEIGHTS[8*input_index +: 8] - WEIGHT_OFFSET);

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
