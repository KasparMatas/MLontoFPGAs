`timescale 1ns / 1ps

`define DATA_WIDTH 8
`define CLOCK 20 
//////////////////////////////////////////////////////////////////////////////////
// Unit test for the argmax_cell module.
//////////////////////////////////////////////////////////////////////////////////
module argmax_simulator();

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
    reg input_enable;
    wire [`DATA_WIDTH*2:0] output_result;

    argmax_cell #(
        .DATA_WIDTH(`DATA_WIDTH),
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .INDEX_WIDTH(`DATA_WIDTH+2),
        .CELL_AMOUNT(2)
    ) uut (
        .clk(clk), 
        .input_index(input_index),
        .input_value(input_value),
        .input_enable(input_enable),
        .output_result(output_result)
    );  

    initial begin
        clk = 1;
        forever #(`CLOCK/2) clk = !clk;
    end

    initial begin
        input_index = 0;
        input_value = 0;
        input_enable = 0;
    end

    initial begin
        #2;
        #(`CLOCK*2); 
        input_value = 1;
        #`CLOCK;
        input_value = 0;
        input_index = 1;
        #`CLOCK;
        check_output(output_result, 0);
        input_index = 0;
        input_value = 2;
        input_enable = 1;
        #`CLOCK;
        check_output(output_result, 0);
        input_index = 1;
        input_value = 1;
        input_enable = 1;
        #`CLOCK;
        check_output(output_result, {1'b1, 16'd0});
        input_index = 0;
        input_value = 3;
        input_enable = 1;
        #`CLOCK;
        check_output(output_result, 0);
        input_index = 1;
        input_value = 6;
        input_enable = 0;
        #`CLOCK;
        check_output(output_result, 0);
        #`CLOCK;
        $display("SUCCESSFUL TEST!"); 
        $stop;
    end

endmodule
