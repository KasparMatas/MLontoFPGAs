`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Final cell which checks the values of each classification option 
// and outputs the result,
//////////////////////////////////////////////////////////////////////////////////


module argmax_cell#(
        parameter DATA_WIDTH = 8,
        parameter RESULT_WIDTH = 16,
        parameter INDEX_WIDTH = 10,
        parameter CELL_AMOUNT = 4
    ) (
        input wire clk,
        input wire [INDEX_WIDTH-1:0] input_index,
        input wire [DATA_WIDTH-1:0] input_value,
        input wire input_enable,
        output reg [RESULT_WIDTH:0] output_result
    );

reg [DATA_WIDTH-1:0] best_value;
reg [DATA_WIDTH-1:0] best_index;

initial begin
    best_value = 0;
    best_index = 0;
end

always @ (posedge clk) begin #1
    if (input_enable)
        if (input_index == CELL_AMOUNT - 1) begin
            output_result[RESULT_WIDTH] = 1'b1;
            if (best_value <= input_value) output_result[RESULT_WIDTH-1:0] <= input_index;
            else output_result[RESULT_WIDTH-1:0] <= best_index;
            best_value <= 0;
            best_index <= 0;
        end
        else begin
            output_result[RESULT_WIDTH] <= 1'b0;
            if (input_index == 0 || best_value <= input_value) begin
                best_value <= input_value;
                best_index <= input_index;
            end
        end
    else output_result <= 0;
end    

endmodule
