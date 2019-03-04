`timescale 1ns / 1ps

`define DATA_WIDTH 16
`define CLOCK 20 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2018 14:41:26
// Design Name: 
// Module Name: weight_comp_cell_simulator
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
module weight_comp_cell_simulator();

    event error;
    always @ (error) begin
        $display("ERROR at time %t", $time);
        #`CLOCK $stop;
    end

    task check_output(input [`DATA_WIDTH*2:0] result, input [`DATA_WIDTH*2:0] golden);
    begin
        if (result!==golden) begin
            $display("Output is %0d which should be %0d instead!", result[`DATA_WIDTH*2-1:0], golden[`DATA_WIDTH*2-1:0]);
            ->error;
        end
    end
    endtask

    reg clk;
    reg [`DATA_WIDTH+1:0] input_index;
    reg [`DATA_WIDTH-1:0] input_value;
    reg [`DATA_WIDTH*2:0] input_result;
    reg input_enable;
    wire [`DATA_WIDTH+1:0] output_index;
    wire [`DATA_WIDTH-1:0] output_value;
    wire [`DATA_WIDTH*2:0] output_result;
    wire output_enable;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .INDEX_WIDTH(`DATA_WIDTH+2),
        .WEIGHT_AMOUNT(2), 
        .WEIGHT_OFFSET(1),
        .INPUT_OFFSET(2),
        .WEIGHTS({8'd4, 8'd1})
    ) uut (
        .clk(clk), 
        .input_index(input_index),
        .input_value(input_value),
        .input_result(input_result),
        .input_enable(input_enable),
        .output_index(output_index),
        .output_value(output_value),
        .output_result(output_result),
        .output_enable(output_enable)
    );  

initial begin
    clk = 1;
    forever #(`CLOCK/2) clk = !clk;
end

initial begin
    input_index = 0;
    input_value = 0;
    input_result = 0;
    input_enable = 0;
end

initial begin
    #2;
    #(`CLOCK*2); 
    input_enable = 1;
    #(`CLOCK); 
    check_output(output_result, {1'b0, 32'd0});
    input_index = 1;
    input_value = 3'd4;
    #(`CLOCK); 
    check_output(output_result, {1'b1, 32'd6});
    input_index = 0;   
    input_value = 3'd5;
    input_result = {1'b1, 32'd6};
    #(`CLOCK); 
    check_output(output_result, {1'b1, 32'd6});
    input_index = 1;   
    input_value = 3'd6;
    input_result = {1'b1, 32'd55};
    #(`CLOCK); 
    check_output(output_result, {1'b1, 32'd55});
    input_enable = 0;
    input_result = {1'b1, 32'd45};
    #(`CLOCK); 
    input_result = {1'b0, 32'd100};
    check_output(output_result, {1'b1, 32'd45});
    #(`CLOCK); 
    check_output(output_result, {1'b1, 32'd12});
    #(`CLOCK*2);
    $display("SUCCESSFUL TEST!"); 
    $stop;
end
 
endmodule
