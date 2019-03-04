`timescale 1ns / 1ps

`define DATA_WIDTH 8
`define CLOCK 20 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2019 10:41:17
// Design Name: 
// Module Name: scaler_integration_simulator
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
module scaler_integration_simulator();
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
    
    reg clk;
    reg [`DATA_WIDTH+1:0] input_index;
    reg [`DATA_WIDTH-1:0] input_value;
    reg input_enable;
    
    // One layer with 4 cells and a scaler
    
    wire [`DATA_WIDTH*2+4:0] input_result;
    
    wire [`DATA_WIDTH+1:0] index_1_2;
    wire [`DATA_WIDTH-1:0] value_1_2;
    wire [`DATA_WIDTH*2+4:0] result_1_2;
    wire enable_1_2;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2+4), 
        .WEIGHT_AMOUNT(4), 
        .WEIGHTS({8'd161, 8'd205, 8'd42, 8'd203})
    ) cell_1_1 (
        .clk(clk), 
        .input_index(input_index),
        .input_value(input_value),
        .input_result(input_result),
        .input_enable(input_enable),
        .output_index(index_1_2),
        .output_value(value_1_2),
        .output_result(result_1_2),
        .output_enable(enable_1_2)
    );  
    
    wire [`DATA_WIDTH+1:0] index_2_3;
    wire [`DATA_WIDTH-1:0] value_2_3;
    wire [`DATA_WIDTH*2+4:0] result_2_3;
    wire enable_2_3; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2+4), 
        .WEIGHT_AMOUNT(4), 
        .WEIGHTS({8'd225, 8'd235, 8'd142, 8'd104})
    ) cell_1_2 (
        .clk(clk), 
        .input_index(index_1_2),
        .input_value(value_1_2),
        .input_result(result_1_2),
        .input_enable(enable_1_2),
        .output_index(index_2_3),
        .output_value(value_2_3),
        .output_result(result_2_3),
        .output_enable(enable_2_3)
    );
    
    wire [`DATA_WIDTH+1:0] index_3_4;
    wire [`DATA_WIDTH-1:0] value_3_4;
    wire [`DATA_WIDTH*2+4:0] result_3_4;
    wire enable_3_4; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2+4), 
        .WEIGHT_AMOUNT(4), 
        .WEIGHTS({8'd84, 8'd179, 8'd103, 8'd92})
    ) cell_1_3 (
        .clk(clk), 
        .input_index(index_2_3),
        .input_value(value_2_3),
        .input_result(result_2_3),
        .input_enable(enable_2_3),
        .output_index(index_3_4),
        .output_value(value_3_4),
        .output_result(result_3_4),
        .output_enable(enable_3_4)
    );
    
    wire [`DATA_WIDTH+1:0] output_index_1;
    wire [`DATA_WIDTH-1:0] output_value_1;
    wire [`DATA_WIDTH*2+4:0] output_result_1;
    wire output_enable_1;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2+4), 
        .WEIGHT_AMOUNT(4), 
        .WEIGHTS({8'd11, 8'd255, 8'd19, 8'd134})
    ) cell_1_4 (
        .clk(clk), 
        .input_index(index_3_4),
        .input_value(value_3_4),
        .input_result(result_3_4),
        .input_enable(enable_3_4),
        .output_index(output_index_1),
        .output_value(output_value_1),
        .output_result(output_result_1),
        .output_enable(output_enable_1)
    );       
    
    wire [`DATA_WIDTH+1:0] input_index_2;
    wire [`DATA_WIDTH-1:0] input_value_2;
    wire input_enable_2;
    
    scaler #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2+4),
        .SCALING_FACTOR(16'd20837),
        .SHIFT_AMOUNT(8'd23),
        .CELL_AMOUNT(4)
    ) scaling_cell_1 (
        .clk(clk), 
        .input_result(output_result_1),
        .output_index(input_index_2),
        .output_value(input_value_2),
        .output_enable(input_enable_2)
    );
    
    assign input_result = {1'b0, 32'bx}; 
    
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
        input_enable = 1;
        input_value = 8'd255;
        #(`CLOCK); 
        input_index = 1;
        input_value = 8'd100;
        #(`CLOCK); 
        input_index = 2;  
        input_value = 8'd88;
        #(`CLOCK); 
        input_index = 3;   
        input_value = 8'd177;
        #(`CLOCK);
        input_enable = 0;
        #(`CLOCK); 
    end
    
    task check_output_according_to_index(input [`DATA_WIDTH-1:0] input_index, 
                                         input [`DATA_WIDTH-1:0] input_value, 
                                         input [`DATA_WIDTH*8-1:0] golden_values,
                                         input [3:0] value_amount,
                                         input [3:0] iteration_index);
    begin
    if (input_index >= value_amount) begin
        $display("Unknown index %0d on #%0d iteartion", input_index, iteration_index);
        ->error;
    end
    else check_output(input_value, golden_values[`DATA_WIDTH*(input_index) +: `DATA_WIDTH]);
    end
    endtask
    
    task check_output_values(input [3:0] check_count, 
                             input [`DATA_WIDTH-1:0] input_index, 
                             input [`DATA_WIDTH-1:0] input_value, 
                             input [`DATA_WIDTH*8-1:0] golden_values_1,
                             input [`DATA_WIDTH*8-1:0] golden_values_2,
                             input [3:0] value_amount,
                             input [3:0] layer_index);
    begin
    case (check_count)
        0: begin
            check_output_according_to_index(input_index, input_value, golden_values_1, 4, 0);
        end
        default: begin
            $display("Layer #%0d input enable is high when it shouldn't be", layer_index);
            ->error;
        end
    endcase
    end
    endtask    
    
    reg [3:0] output_1_values_checked;
    
    initial begin
        output_1_values_checked = 0;
    end    
    
    always @ (posedge clk) begin
        if (input_enable_2) begin
            check_output_values(output_1_values_checked, input_index_2, input_value_2, {8'd150, 8'd159, 8'd251, 8'd254}, 
                {8'dx, 8'dx, 8'dx, 8'dx}, 4, 0);
            if (input_index_2 == 3) begin 
                output_1_values_checked <= output_1_values_checked + 1; 
                #(`CLOCK*2);
                $display("SUCCESSFUL TEST!"); 
                $stop;  
            end
        end    
    end
    
endmodule
