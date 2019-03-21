`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Outdated RELU cell which doesn't work with quantization. Needs to get updated.
//////////////////////////////////////////////////////////////////////////////////


module relu_cell#(
        parameter DATA_WIDTH = 8,
        parameter RESULT_WIDTH = 16,
        parameter INDEX_WIDTH = 10,
        parameter CELL_AMOUNT = 4
    ) (
        input wire clk,
        input wire [RESULT_WIDTH:0] input_result,
        output reg [INDEX_WIDTH-1:0] output_index,
        output reg [DATA_WIDTH-1:0] output_value,
        output reg output_enable
    );
    
reg [INDEX_WIDTH-1:0] index;
    
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
