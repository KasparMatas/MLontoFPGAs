`timescale 1ns / 1ps

`define DATA_WIDTH 16
`define CLOCK 20 
`define WEIGHT_AMOUNT_1 4
`define WEIGHT_AMOUNT_2 4
`define WEIGHT_AMOUNT_3 4
`define WEIGHT_AMOUNT_4 2
`define WEIGHT_AMOUNT_5 8
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2018 14:37:56
// Design Name: 
// Module Name: integration_simulator
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
module integration_simulator();
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
    
    reg clk;
    reg [`DATA_WIDTH-1:0] input_index;
    reg [`DATA_WIDTH-1:0] input_value;
    reg input_enable;
    wire [`DATA_WIDTH*2:0] output_result;
    
    // FIRST LAYER with 4 cells and a RELU
    
    wire [`DATA_WIDTH*2:0] input_result;
    
    wire [`DATA_WIDTH-1:0] index_1_2;
    wire [`DATA_WIDTH-1:0] value_1_2;
    wire [`DATA_WIDTH*2:0] result_1_2;
    wire enable_1_2;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_1), 
        .WEIGHTS({8'd1, 8'd2, 8'd3, 8'd4})
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
    
    wire [`DATA_WIDTH-1:0] index_2_3;
    wire [`DATA_WIDTH-1:0] value_2_3;
    wire [`DATA_WIDTH*2:0] result_2_3;
    wire enable_2_3; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_1), 
        .WEIGHTS({8'd5, 8'd3, 8'd2, 8'd1})
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
    
    wire [`DATA_WIDTH-1:0] index_3_4;
    wire [`DATA_WIDTH-1:0] value_3_4;
    wire [`DATA_WIDTH*2:0] result_3_4;
    wire enable_3_4; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_1), 
        .WEIGHTS({8'd1, 8'd1, 8'd1, 8'd1})
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
    
    wire [`DATA_WIDTH-1:0] output_index_1;
    wire [`DATA_WIDTH-1:0] output_value_1;
    wire [`DATA_WIDTH*2:0] output_result_1;
    wire output_enable_1;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_1), 
        .WEIGHTS({8'd4, 8'd4, 8'd4, 8'd4})
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
    
    wire [`DATA_WIDTH-1:0] input_index_2;
    wire [`DATA_WIDTH-1:0] input_value_2;
    wire input_enable_2;
    
    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(4)
    ) activation_cell_1 (
        .clk(clk), 
        .input_result(output_result_1),
        .output_index(input_index_2),
        .output_value(input_value_2),
        .output_enable(input_enable_2)
    );    
    
    // SECOND LAYER with 4 cells and a RELU

    wire [`DATA_WIDTH*2:0] input_result_2;

    wire [`DATA_WIDTH-1:0] index_5_6;
    wire [`DATA_WIDTH-1:0] value_5_6;
    wire [`DATA_WIDTH*2:0] result_5_6;
    wire enable_5_6;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_2), 
        .WEIGHTS({8'd1, 8'd2, 8'd3, 8'd4})
    ) cell_2_1 (
        .clk(clk), 
        .input_index(input_index_2),
        .input_value(input_value_2),
        .input_result(input_result_2),
        .input_enable(input_enable_2),
        .output_index(index_5_6),
        .output_value(value_5_6),
        .output_result(result_5_6),
        .output_enable(enable_5_6)
    );  
    
    wire [`DATA_WIDTH-1:0] index_6_7;
    wire [`DATA_WIDTH-1:0] value_6_7;
    wire [`DATA_WIDTH*2:0] result_6_7;
    wire enable_6_7; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_2), 
        .WEIGHTS({8'd5, 8'd3, 8'd2, 8'd1})
    ) cell_2_2 (
        .clk(clk), 
        .input_index(index_5_6),
        .input_value(value_5_6),
        .input_result(result_5_6),
        .input_enable(enable_5_6),
        .output_index(index_6_7),
        .output_value(value_6_7),
        .output_result(result_6_7),
        .output_enable(enable_6_7)
    );
    
    wire [`DATA_WIDTH-1:0] index_7_8;
    wire [`DATA_WIDTH-1:0] value_7_8;
    wire [`DATA_WIDTH*2:0] result_7_8;
    wire enable_7_8; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_2), 
        .WEIGHTS({8'd1, 8'd1, 8'd1, 8'd1})
    ) cell_2_3 (
        .clk(clk), 
        .input_index(index_6_7),
        .input_value(value_6_7),
        .input_result(result_6_7),
        .input_enable(enable_6_7),
        .output_index(index_7_8),
        .output_value(value_7_8),
        .output_result(result_7_8),
        .output_enable(enable_7_8)
    );
    
    wire [`DATA_WIDTH-1:0] output_index_2;
    wire [`DATA_WIDTH-1:0] output_value_2;
    wire [`DATA_WIDTH*2:0] output_result_2;
    wire output_enable_2;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_2), 
        .WEIGHTS({8'd4, 8'd4, 8'd4, 8'd4})
    ) cell_2_4 (
        .clk(clk), 
        .input_index(index_7_8),
        .input_value(value_7_8),
        .input_result(result_7_8),
        .input_enable(enable_7_8),
        .output_index(output_index_2),
        .output_value(output_value_2),
        .output_result(output_result_2),
        .output_enable(output_enable_2)
    );       
    
    wire [`DATA_WIDTH-1:0] input_index_3;
    wire [`DATA_WIDTH-1:0] input_value_3;
    wire input_enable_3;
    
    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(4)
    ) activation_cell_2 (
        .clk(clk), 
        .input_result(output_result_2),
        .output_index(input_index_3),
        .output_value(input_value_3),
        .output_enable(input_enable_3)
    );
    
    // THIRD LAYER with 2 cells and a RELU 
    
    wire [`DATA_WIDTH*2:0] input_result_3;
    
    wire [`DATA_WIDTH-1:0] index_8_9;
    wire [`DATA_WIDTH-1:0] value_8_9;
    wire [`DATA_WIDTH*2:0] result_8_9;
    wire enable_8_9;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_3), 
        .WEIGHTS({8'd1, 8'd2, 8'd3, 8'd4})
    ) cell_3_1 (
        .clk(clk), 
        .input_index(input_index_3),
        .input_value(input_value_3),
        .input_result(input_result_3),
        .input_enable(input_enable_3),
        .output_index(index_8_9),
        .output_value(value_8_9),
        .output_result(result_8_9),
        .output_enable(enable_8_9)
    );
    
    wire [`DATA_WIDTH-1:0] output_index_3;
    wire [`DATA_WIDTH-1:0] output_value_3;
    wire [`DATA_WIDTH*2:0] output_result_3;
    wire output_enable_3;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_3), 
        .WEIGHTS({8'd1, 8'd1, 8'd1, 8'd1})
    ) cell_3_2 (
        .clk(clk), 
        .input_index(index_8_9),
        .input_value(value_8_9),
        .input_result(result_8_9),
        .input_enable(enable_8_9),
        .output_index(output_index_3),
        .output_value(output_value_3),
        .output_result(output_result_3),
        .output_enable(output_enable_3)
    );

    wire [`DATA_WIDTH-1:0] input_index_4;
    wire [`DATA_WIDTH-1:0] input_value_4;
    wire input_enable_4;
    
    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(2)
    ) activation_cell_3 (
        .clk(clk), 
        .input_result(output_result_3),
        .output_index(input_index_4),
        .output_value(input_value_4),
        .output_enable(input_enable_4)
    );
    
    // FOURTH LAYER with 8 cells and 4 RELUs

    wire [`DATA_WIDTH*2:0] input_result_4;
    
    wire [`DATA_WIDTH-1:0] index_10_14;
    wire [`DATA_WIDTH-1:0] value_10_14;
    wire [`DATA_WIDTH*2:0] result_10_14;
    wire enable_10_14;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_4), 
        .WEIGHTS({8'd1, 8'd2})
    ) cell_4_1 (
        .clk(clk), 
        .input_index(input_index_4),
        .input_value(input_value_4),
        .input_result(input_result_4),
        .input_enable(input_enable_4),
        .output_index(index_10_14),
        .output_value(value_10_14),
        .output_result(result_10_14),
        .output_enable(enable_10_14)
    );

    wire [`DATA_WIDTH-1:0] index_11_15;
    wire [`DATA_WIDTH-1:0] value_11_15;
    wire [`DATA_WIDTH*2:0] result_11_15;
    wire enable_11_15;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_4), 
        .WEIGHTS({8'd1, 8'd1})
    ) cell_4_2 (
        .clk(clk), 
        .input_index(input_index_4),
        .input_value(input_value_4),
        .input_result(input_result_4),
        .input_enable(input_enable_4),
        .output_index(index_11_15),
        .output_value(value_11_15),
        .output_result(result_11_15),
        .output_enable(enable_11_15)
    );

    wire [`DATA_WIDTH-1:0] index_12_16;
    wire [`DATA_WIDTH-1:0] value_12_16;
    wire [`DATA_WIDTH*2:0] result_12_16;
    wire enable_12_16;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_4), 
        .WEIGHTS({8'd2, 8'd1})
    ) cell_4_3 (
        .clk(clk), 
        .input_index(input_index_4),
        .input_value(input_value_4),
        .input_result(input_result_4),
        .input_enable(input_enable_4),
        .output_index(index_12_16),
        .output_value(value_12_16),
        .output_result(result_12_16),
        .output_enable(enable_12_16)
    );

    wire [`DATA_WIDTH-1:0] index_13_17;
    wire [`DATA_WIDTH-1:0] value_13_17;
    wire [`DATA_WIDTH*2:0] result_13_17;
    wire enable_13_17;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_4), 
        .WEIGHTS({8'd0, 8'd1})
    ) cell_4_4 (
        .clk(clk), 
        .input_index(input_index_4),
        .input_value(input_value_4),
        .input_result(input_result_4),
        .input_enable(input_enable_4),
        .output_index(index_13_17),
        .output_value(value_13_17),
        .output_result(result_13_17),
        .output_enable(enable_13_17)
    );
    
    wire [`DATA_WIDTH-1:0] output_index_4_1;
    wire [`DATA_WIDTH-1:0] output_value_4_1;
    wire [`DATA_WIDTH*2:0] output_result_4_1;
    wire output_enable_4_1;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_4), 
        .WEIGHTS({8'd1, 8'd0})
    ) cell_4_5 (
        .clk(clk), 
        .input_index(index_10_14),
        .input_value(value_10_14),
        .input_result(result_10_14),
        .input_enable(enable_10_14),
        .output_index(output_index_4_1),
        .output_value(output_value_4_1),
        .output_result(output_result_4_1),
        .output_enable(output_enable_4_1)
    );
    
    wire [`DATA_WIDTH-1:0] input_index_5_1;
    wire [`DATA_WIDTH-1:0] input_value_5_1;
    wire input_enable_5_1;
    
    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(2)
    ) activation_cell_4_1 (
        .clk(clk), 
        .input_result(output_result_4_1),
        .output_index(input_index_5_1),
        .output_value(input_value_5_1),
        .output_enable(input_enable_5_1)
    );
    
    wire [`DATA_WIDTH-1:0] output_index_4_2;
    wire [`DATA_WIDTH-1:0] output_value_4_2;
    wire [`DATA_WIDTH*2:0] output_result_4_2;
    wire output_enable_4_2;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_4), 
        .WEIGHTS({8'd0, 8'd0})
    ) cell_4_6 (
        .clk(clk), 
        .input_index(index_11_15),
        .input_value(value_11_15),
        .input_result(result_11_15),
        .input_enable(enable_11_15),
        .output_index(output_index_4_2),
        .output_value(output_value_4_2),
        .output_result(output_result_4_2),
        .output_enable(output_enable_4_2)
    );
    
    wire [`DATA_WIDTH-1:0] input_index_5_2;
    wire [`DATA_WIDTH-1:0] input_value_5_2;
    wire input_enable_5_2;
    
    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(2)
    ) activation_cell_4_2 (
        .clk(clk), 
        .input_result(output_result_4_2),
        .output_index(input_index_5_2),
        .output_value(input_value_5_2),
        .output_enable(input_enable_5_2)
    );
    
    wire [`DATA_WIDTH-1:0] output_index_4_3;
    wire [`DATA_WIDTH-1:0] output_value_4_3;
    wire [`DATA_WIDTH*2:0] output_result_4_3;
    wire output_enable_4_3;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_4), 
        .WEIGHTS({8'd0, 8'd2})
    ) cell_4_7 (
        .clk(clk), 
        .input_index(index_12_16),
        .input_value(value_12_16),
        .input_result(result_12_16),
        .input_enable(enable_12_16),
        .output_index(output_index_4_3),
        .output_value(output_value_4_3),
        .output_result(output_result_4_3),
        .output_enable(output_enable_4_3)
    );
    
    wire [`DATA_WIDTH-1:0] input_index_5_3;
    wire [`DATA_WIDTH-1:0] input_value_5_3;
    wire input_enable_5_3;
    
    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(2)
    ) activation_cell_4_3 (
        .clk(clk), 
        .input_result(output_result_4_3),
        .output_index(input_index_5_3),
        .output_value(input_value_5_3),
        .output_enable(input_enable_5_3)
    );
    
    wire [`DATA_WIDTH-1:0] output_index_4_4;
    wire [`DATA_WIDTH-1:0] output_value_4_4;
    wire [`DATA_WIDTH*2:0] output_result_4_4;
    wire output_enable_4_4;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_4), 
        .WEIGHTS({8'd2, 8'd0})
    ) cell_4_8 (
        .clk(clk), 
        .input_index(index_13_17),
        .input_value(value_13_17),
        .input_result(result_13_17),
        .input_enable(enable_13_17),
        .output_index(output_index_4_4),
        .output_value(output_value_4_4),
        .output_result(output_result_4_4),
        .output_enable(output_enable_4_4)
    );
    
    wire [`DATA_WIDTH-1:0] input_index_5_4;
    wire [`DATA_WIDTH-1:0] input_value_5_4;
    wire input_enable_5_4;
    
    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(2)
    ) activation_cell_4_4 (
        .clk(clk), 
        .input_result(output_result_4_4),
        .output_index(input_index_5_4),
        .output_value(input_value_5_4),
        .output_enable(input_enable_5_4)
    );
    
    // FIFTH LAYER with 2 universal cells with 4 inputs and 1 RELU
    
    wire [`DATA_WIDTH*2:0] input_result_5;
    
    wire [`DATA_WIDTH-1:0] index_18_19;
    wire [`DATA_WIDTH*4-1:0] value_18_19;
    wire [`DATA_WIDTH*2:0] result_18_19;
    wire enable_18_19;  
    
    universal_weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH),
        .RESULT_WIDTH(`DATA_WIDTH*2),  
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_5), 
        .WEIGHTS({8'd2, 8'd2, 8'd2, 8'd2, 8'd2, 8'd2, 8'd2, 8'd2}),
        .INPUT_AMOUNT(4)
    ) cell_5_1 (
        .clk(clk), 
        .input_index(input_index_5_1),
        .input_value({input_value_5_4, input_value_5_3, input_value_5_2, input_value_5_1}),
        .input_result(input_result_5),
        .input_enable(input_enable_5_1),
        .output_index(index_18_19),
        .output_value(value_18_19),
        .output_result(result_18_19),
        .output_enable(enable_18_19)
    );

    wire [`DATA_WIDTH-1:0] output_index_5;
    wire [`DATA_WIDTH*4-1:0] output_value_5;
    wire [`DATA_WIDTH*2:0] output_result_5;
    wire output_enable_5;  
    
    universal_weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_5), 
        .WEIGHTS({8'd1, 8'd1, 8'd1, 8'd1, 8'd1, 8'd1, 8'd1, 8'd1}),
        .INPUT_AMOUNT(4)
    ) cell_5_2 (
        .clk(clk), 
        .input_index(index_18_19),
        .input_value(value_18_19),
        .input_result(result_18_19),
        .input_enable(enable_18_19),
        .output_index(output_index_5),
        .output_value(output_value_5),
        .output_result(output_result_5),
        .output_enable(output_enable_5)
    );
    
    wire [`DATA_WIDTH-1:0] input_index_6;
    wire [`DATA_WIDTH-1:0] input_value_6;
    wire input_enable_6;
    
    relu_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(2)
    ) activation_cell_5 (
        .clk(clk), 
        .input_result(output_result_5),
        .output_index(input_index_6),
        .output_value(input_value_6),
        .output_enable(input_enable_6)
    );
    
    // OUTPUT

    argmax_cell #(
        .DATA_WIDTH(`DATA_WIDTH),
        .RESULT_WIDTH(`DATA_WIDTH*2),
        .CELL_AMOUNT(2)
    ) result_cell (
        .clk(clk), 
        .input_index(input_index_6),
        .input_value(input_value_6),
        .input_enable(input_enable_6),
        .output_result(output_result)
    );  

    assign input_result = {1'b0, 32'bx}; 
    assign input_result_2 = {1'b0, 32'bx};
    assign input_result_3 = {1'b0, 32'bx};   
    assign input_result_4 = {1'b0, 32'bx};
    assign input_result_5 = {1'b0, 32'bx}; 
    
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
        input_value = 1;
        #(`CLOCK); 
        input_index = 1;
        #(`CLOCK); 
        input_index = 2;   
        #(`CLOCK); 
        input_index = 3;   
        #(`CLOCK);
        input_index = 0;
        input_value = 2;
        #(`CLOCK); 
        input_index = 1;
        #(`CLOCK); 
        input_index = 2;   
        #(`CLOCK); 
        input_index = 3;   
        #(`CLOCK);
        input_enable = 0;
        #(`CLOCK); 
    end
    
    reg [3:0] output_1_values_checked;
    reg [3:0] output_2_values_checked;
    reg [3:0] output_3_values_checked;
    reg [3:0] output_4_values_checked;
    reg [3:0] output_5_values_checked;
    
    initial begin
        output_1_values_checked = 0;
        output_2_values_checked = 0;
        output_3_values_checked = 0;
        output_4_values_checked = 0;
        output_5_values_checked = 0;
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
        1: begin
            check_output_according_to_index(input_index, input_value, golden_values_2, 4, 1);
        end
        default: begin
            $display("Layer #%0d input enable is high when it shouldn't be", layer_index);
            ->error;
        end
    endcase
    end
    endtask
    
    always @ (posedge clk) begin
        if (input_enable_2) begin
            check_output_values(output_1_values_checked, input_index_2, input_value_2, {16'd16, 16'd4, 16'd11, 16'd10}, 
                {16'd32, 16'd8, 16'd22, 16'd20}, 4, 0);
            if (input_index_2 == 3) output_1_values_checked <= output_1_values_checked + 1; 
        end    
        if (input_enable_3) begin
            check_output_values(output_2_values_checked, input_index_3, input_value_3, {16'd164, 16'd41, 16'd124, 16'd97}, 
                {16'd328, 16'd82, 16'd248, 16'd194}, 4, 1);
            if (input_index_3 == 3) output_2_values_checked <= output_2_values_checked + 1; 
        end
        if (input_enable_4) begin
            check_output_values(output_3_values_checked, input_index_4, input_value_4, {16'd426, 16'd1006}, 
                {16'd852, 16'd2012}, 2, 2);
            if (input_index_4 == 1) output_3_values_checked <= output_3_values_checked + 1; 
        end
        if (input_enable_5_1 || input_enable_5_2 || input_enable_5_3 || input_enable_5_4) begin
            if (!(input_enable_5_1 && input_enable_5_2 && input_enable_5_3 && input_enable_5_4)) begin
                $display("Parallel cells are out of sync with enable signals");
                ->error;
            end
            if (!(input_index_5_1 == input_index_5_2 && input_index_5_2 == input_index_5_3 && input_index_5_3 == input_index_5_4)) begin
                $display("Parallel cells are out of sync with index signals");
                ->error;
            end 
            check_output_values(output_4_values_checked, input_index_5_1, input_value_5_1, {16'd426, 16'd2438},
                {16'd852, 16'd4876}, 2, 3);
            check_output_values(output_4_values_checked, input_index_5_2, input_value_5_2, {16'd0, 16'd1432},
                {16'd0, 16'd2864}, 2, 3);
            check_output_values(output_4_values_checked, input_index_5_3, input_value_5_3, {16'd2012, 16'd1858},
                {16'd4024, 16'd3716}, 2, 3);
            check_output_values(output_4_values_checked, input_index_5_4, input_value_5_4, {16'd852, 16'd1006},
                {16'd1704, 16'd2012}, 2, 3);
            if (input_index_5_1 == 1) output_4_values_checked <= output_4_values_checked + 1; 
        end
        if (input_enable_6) begin
            check_output_values(output_5_values_checked, input_index_6, input_value_6, {16'd10024, 16'd20048}, 
                {16'd20048, 16'd40096}, 2, 4);
            if (input_index_6 == 1) output_5_values_checked <= output_5_values_checked + 1; 
        end   
    end
    
    reg [3:0] output_results_checked;
        
    initial begin
        output_results_checked = 0;
    end
    
    always @ (posedge clk) begin
        if (output_result[`DATA_WIDTH*2]) begin 
            check_output(output_result[`DATA_WIDTH*2-1:0], 0);
            output_results_checked <= output_results_checked+1;
            if (output_results_checked == 1) begin
                #(`CLOCK*2);
                $display("SUCCESSFUL TEST!"); 
                $stop;
            end
        end
    end
    
endmodule
