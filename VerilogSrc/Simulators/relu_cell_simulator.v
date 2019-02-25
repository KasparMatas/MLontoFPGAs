`timescale 1ns / 1ps

`define DATA_WIDTH 32
`define CLOCK 20 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2018 17:51:34
// Design Name: 
// Module Name: relu_cell_simulator
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
module relu_cell_simulator();
    
    event error;
    always @ (error) begin
        $display("ERROR at time %t", $time);
        #`CLOCK $stop;
    end

    task check_output(input [`DATA_WIDTH*2-1:0] result, input [`DATA_WIDTH*2-1:0] golden);
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
    wire [`DATA_WIDTH-1:0] output_index;
    wire [`DATA_WIDTH-1:0] output_value;
    wire output_enable;  

    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
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
        input_result = 1;
        #`CLOCK; 
        check_output(output_value, 0);
        check_output(output_index, 0);
        check_enable(output_enable, 0); 
        input_result[`DATA_WIDTH*2-1:0] = 1;
        input_result[`DATA_WIDTH*2] = 1;
        #`CLOCK; 
        check_output(output_value, 1);
        check_output(output_index, 0);
        check_enable(output_enable, 1);
        input_result[`DATA_WIDTH*2-1:0] = -1;
        input_result[`DATA_WIDTH*2] = 1;
        #`CLOCK; 
        check_output(output_value, 0);
        check_output(output_index, 1);
        check_enable(output_enable, 1);
        input_result[`DATA_WIDTH*2-1:0] = -20;
        input_result[`DATA_WIDTH*2] = 1;
        #`CLOCK; 
        check_output(output_value, 0);
        check_output(output_index, 0);
        check_enable(output_enable, 1);
        input_result[`DATA_WIDTH*2-1:0] = 15;
        input_result[`DATA_WIDTH*2] = 1;
        #`CLOCK;
        check_output(output_value, 15);
        check_output(output_index, 1);
        check_enable(output_enable, 1);
        input_result[`DATA_WIDTH*2-1:0] = 15;
        input_result[`DATA_WIDTH*2] = 0;
        #`CLOCK;
        check_output(output_value, 0);
        check_output(output_index, 0);
        check_enable(output_enable, 0); 
        #(`CLOCK*2);
        $display("SUCCESSFUL TEST!"); 
        $stop;
    end

endmodule
