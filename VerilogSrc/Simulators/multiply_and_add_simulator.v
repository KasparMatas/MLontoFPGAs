`timescale 1ns / 1ps

`define DATA_WIDTH 32
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.01.2019 11:48:04
// Design Name: 
// Module Name: multiply_and_add_simulator
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


module multiply_and_add_simulator();

    event error;
    always @ (error) begin
        $display("ERROR at time %t", $time);
        #100 $stop;
    end

    task check_output(input [`DATA_WIDTH:0] result, input [`DATA_WIDTH:0] golden);
    begin
        if (result!==golden) begin
            $display("Output is %0d which should be %0d instead!", result[`DATA_WIDTH-1:0], golden[`DATA_WIDTH-1:0]);
            ->error;
        end
    end
    endtask
    
    reg [`DATA_WIDTH-1:0] add_value;
    reg [`DATA_WIDTH-1:0] input_value;
    reg [7:0] weight_value;
    wire [`DATA_WIDTH-1:0] output_value;
    
    multiply_and_add #(
        .DATA_WIDTH(`DATA_WIDTH)
    ) uut (
        .add_value(add_value),
        .input_value(input_value),
        .weight_value(weight_value),
        .output_value(output_value)
    );
    
    initial begin
        add_value = 0;
        input_value = 0;
        weight_value = 0;
    end
    
    initial begin
        #100; 
        check_output(output_value, 32'd0);
        #100; 
        add_value = 32'd1;
        #10;
        check_output(output_value, 32'd1);
        #100; 
        input_value = 32'd2;
        #10;
        check_output(output_value, 32'd1);
        #100; 
        weight_value = 32'd3;
        #10;
        check_output(output_value, 32'd7);
        #100;
        add_value = 32'd10;
        input_value = 32'd5;
        weight_value = 32'd2;
        #10;
        check_output(output_value, 32'd20);
        $display("SUCCESSFUL TEST!"); 
        $stop;
    end

endmodule
