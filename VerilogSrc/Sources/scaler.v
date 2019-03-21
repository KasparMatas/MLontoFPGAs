`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Scaler cell to scale the results back into the desired data width.
//////////////////////////////////////////////////////////////////////////////////


module scaler#(
        parameter DATA_WIDTH = 8,
        parameter RESULT_WIDTH = 16,
        parameter INDEX_WIDTH = 10,
        parameter SCALING_FACTOR = 19661,
        parameter SHIFT_AMOUNT = 15,
        parameter OUTPUT_OFFSET = 0,
        parameter CELL_AMOUNT = 4
    ) (
        input wire clk,
        input wire [RESULT_WIDTH:0] input_result,
        output reg [INDEX_WIDTH-1:0] output_index,
        output reg [DATA_WIDTH-1:0] output_value,
        output reg output_enable
    );
    
reg [INDEX_WIDTH-1:0] index;
wire [RESULT_WIDTH*2-1:0] accumulator;
    
initial begin
    index = 0;
end
   
assign accumulator = input_result[RESULT_WIDTH-1:0] * SCALING_FACTOR;
    
always @ (posedge clk) begin #1
    if (input_result[RESULT_WIDTH]) begin

        output_value <= accumulator[RESULT_WIDTH*2-1:SHIFT_AMOUNT] + OUTPUT_OFFSET;
        //output_value <= input_result[RESULT_WIDTH-1:0] * SCALING_FACTOR >> SHIFT_AMOUNT;

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