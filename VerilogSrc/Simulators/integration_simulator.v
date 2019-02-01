`timescale 1ns / 1ps

`define DATA_WIDTH 32
`define CLOCK 20 
`define WEIGHT_AMOUNT_1 4
`define WEIGHT_AMOUNT_2 4
`define WEIGHT_AMOUNT_3 4
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

    task check_output(input [`DATA_WIDTH-1:0] result, input [`DATA_WIDTH-1:0] golden);
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
    wire [`DATA_WIDTH:0] output_result;
    
    // FIRST LAYER with 4 cells and a RELU
    
    wire [`DATA_WIDTH:0] input_result;
    
    wire [`DATA_WIDTH-1:0] index_1_2;
    wire [`DATA_WIDTH-1:0] value_1_2;
    wire [`DATA_WIDTH:0] result_1_2;
    wire enable_1_2;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_1), 
        .WEIGHTS({32'd1, 32'd2, 32'd3, 32'd4})
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
    wire [`DATA_WIDTH:0] result_2_3;
    wire enable_2_3; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_1), 
        .WEIGHTS({32'd5, 32'd3, 32'd2, 32'd1})
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
    wire [`DATA_WIDTH:0] result_3_4;
    wire enable_3_4; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_1), 
        .WEIGHTS({32'd1, 32'd1, 32'd1, 32'd1})
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
    wire [`DATA_WIDTH:0] output_result_1;
    wire output_enable_1;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_1), 
        .WEIGHTS({32'd4, 32'd4, 32'd4, 32'd4})
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
        .CELL_AMOUNT(4)
    ) activation_cell_1 (
        .clk(clk), 
        .input_result(output_result_1),
        .output_index(input_index_2),
        .output_value(input_value_2),
        .output_enable(input_enable_2)
    );    
    
    // SECOND LAYER with 4 cells and a RELU

    wire [`DATA_WIDTH:0] input_result_2;

    wire [`DATA_WIDTH-1:0] index_5_6;
    wire [`DATA_WIDTH-1:0] value_5_6;
    wire [`DATA_WIDTH:0] result_5_6;
    wire enable_5_6;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_2), 
        .WEIGHTS({32'd1, 32'd2, 32'd3, 32'd4})
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
    wire [`DATA_WIDTH:0] result_6_7;
    wire enable_6_7; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_2), 
        .WEIGHTS({32'd5, 32'd3, 32'd2, 32'd1})
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
    wire [`DATA_WIDTH:0] result_7_8;
    wire enable_7_8; 
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_2), 
        .WEIGHTS({32'd1, 32'd1, 32'd1, 32'd1})
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
    wire [`DATA_WIDTH:0] output_result_2;
    wire output_enable_2;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_2), 
        .WEIGHTS({32'd4, 32'd4, 32'd4, 32'd4})
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
        .CELL_AMOUNT(4)
    ) activation_cell_2 (
        .clk(clk), 
        .input_result(output_result_2),
        .output_index(input_index_3),
        .output_value(input_value_3),
        .output_enable(input_enable_3)
    );
    
    // THIRD LAYER with 2 cells and a RELU 
    
    wire [`DATA_WIDTH-1:0] index_8_9;
    wire [`DATA_WIDTH-1:0] value_8_9;
    wire [`DATA_WIDTH:0] result_8_9;
    wire enable_8_9;  

    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_3), 
        .WEIGHTS({32'd1, 32'd2, 32'd3, 32'd4})
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
    wire [`DATA_WIDTH:0] output_result_3;
    wire output_enable_3;
    
    weight_comp_cell #(
        .DATA_WIDTH(`DATA_WIDTH), 
        .WEIGHT_AMOUNT(`WEIGHT_AMOUNT_3), 
        .WEIGHTS({32'd1, 32'd1, 32'd1, 32'd1})
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
        .CELL_AMOUNT(2)
    ) activation_cell_3 (
        .clk(clk), 
        .input_result(output_result_3),
        .output_index(input_index_4),
        .output_value(input_value_4),
        .output_enable(input_enable_4)
    );

    argmax_cell #(
        .DATA_WIDTH(`DATA_WIDTH),
        .CELL_AMOUNT(2)
    ) result_cell (
        .clk(clk), 
        .input_index(input_index_4),
        .input_value(input_value_4),
        .input_enable(input_enable_4),
        .output_result(output_result)
    );  

    assign input_result = {1'b0, 32'bx}; 
    assign input_result_2 = {1'b0, 32'bx};
    assign input_result_3 = {1'b0, 32'bx};   
    
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
    
    reg [3:0] output_values_checked;
    
    initial begin
        output_values_checked = 0;
    end
    
    always @ (posedge clk) begin
        if (input_enable_3) begin
            case (output_values_checked)
                0: begin
                    case (input_index_3)
                        0: check_output(input_value_3, 97);
                        1: check_output(input_value_3, 124);
                        2: check_output(input_value_3, 41);
                        3: begin
                            output_values_checked <= output_values_checked+1;
                            check_output(input_value_3, 164);
                        end
                        default: begin
                            $display("Unknown index %0d on first iteartion", input_index_3);
                            ->error;
                        end
                    endcase 
                end
                1: begin
                    case (input_index_3)
                        0: check_output(input_value_3, 194);
                        1: check_output(input_value_3, 248);
                        2: check_output(input_value_3, 82);
                        3: begin 
                            output_values_checked <= output_values_checked+1;
                            check_output(input_value_3, 328);
                        end
                        default: begin
                            $display("Unknown index %0d on second iteartion", input_index_3);
                            ->error;
                        end
                    endcase
                end
                default: begin
                    $display("Second layer input enable is high when it shouldn't be");
                    ->error;
                end
            endcase
        end    
    end
    
    reg [3:0] output_results_checked;
        
    initial begin
        output_results_checked = 0;
    end
    
    always @ (posedge clk) begin
        if (output_result[`DATA_WIDTH]) begin 
            check_output(output_result[`DATA_WIDTH-1:0], 0);
            output_results_checked <= output_results_checked+1;
            if (output_results_checked == 1) begin
                #(`CLOCK*2);
                $display("SUCCESSFUL TEST!"); 
                $stop;
            end
        end
    end
    
endmodule
