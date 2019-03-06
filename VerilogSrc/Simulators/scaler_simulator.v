`timescale 1ns / 1ps

`define DATA_WIDTH 16
`define CLOCK 20 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.02.2019 15:49:13
// Design Name: 
// Module Name: scaler_simulator
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
module scaler_simulator();
    
    event error;
    always @ (error) begin
        $display("ERROR at time %t", $time);
        #`CLOCK $stop;
    end

    task check_output(input [`DATA_WIDTH-1:0] result, input [`DATA_WIDTH-1:0] golden);
    begin
        if (result!=golden) begin
            $display("Output is %0d which should be %0d instead!", result, golden);
            ->error;
        end
    end
    endtask
    
    task check_enable(input enable, input golden);
    begin
        if (enable!=golden) begin
            $display("Enable is %0d which should be %0d instead!", enable, golden);
            ->error;
        end   
    end
    endtask
    
    reg clk;
    reg [`DATA_WIDTH*2:0] input_result;
    wire [`DATA_WIDTH+1:0] output_index;
    wire [`DATA_WIDTH-1:0] output_value;
    wire output_enable;  

    scaler #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .INDEX_WIDTH(`DATA_WIDTH+2),
        .SCALING_FACTOR(19311),
        .SHIFT_AMOUNT(27),
        .OUTPUT_OFFSET(121),
        .CELL_AMOUNT(2)
    ) uut (
        .clk(clk), 
        .input_result(input_result),
        .output_index(output_index),
        .output_value(output_value),
        .output_enable(output_enable)
    );  

    initial begin
        clk = 1;
        forever #(`CLOCK/2) clk = !clk;
    end

    initial begin
        input_result = 0;
    end

    initial begin
        #2;
        #(`CLOCK*2); 
        input_result = {1'b1, 32'd28841};
        #`CLOCK; 
        check_output(output_value, 0);
        check_output(output_index, 0);
        check_enable(output_enable, 0); 
        input_result = {1'b1, 16'hFFFF};
        #`CLOCK; 
        check_output(output_value, 5);
        check_output(output_index, 0);
        check_enable(output_enable, 1);
        input_result = {1'b1, 16'd5};
        #`CLOCK; 
        check_output(output_value, 35);
        check_output(output_index, 1);
        check_enable(output_enable, 1);
        input_result = {1'b1, 16'd0};
        #`CLOCK; 
        check_output(output_value, 10);
        check_output(output_index, 0);
        check_enable(output_enable, 1);
        input_result = {1'b1, 16'd3};
        #`CLOCK;
        check_output(output_value, 25);
        check_output(output_index, 1);
        check_enable(output_enable, 1);
        input_result = {1'b0, 16'd60};
        #`CLOCK;
        check_output(output_value, 0);
        check_output(output_index, 0);
        check_enable(output_enable, 0); 
        #(`CLOCK*2);
        $display("SUCCESSFUL TEST!"); 
        $stop;
    end

endmodule
