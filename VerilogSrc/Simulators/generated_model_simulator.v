`timescale 1ns / 1ps

`define CLOCK 20 
`define DATA_WIDTH 8
//////////////////////////////////////////////////////////////////////////////////
// Module for testing the generated model. It inputs data for all of the digits 
// and checks that they are classified correctly.
//////////////////////////////////////////////////////////////////////////////////
module generated_model_simulator();

event error;
always @ (error) begin
    $display("ERROR at time %t", $time);
    #`CLOCK $stop;
end

task check_output(input [`DATA_WIDTH*4+2-1:0] result, input [`DATA_WIDTH*4+2-1:0] golden);
begin
    if (result!=golden) begin
        $display("Output is %0d which should be %0d instead!", result, golden);
        ->error;
    end
end
endtask

reg[31:0] file_lines_read;
integer data_file;
reg[31:0] captured_data;
reg[7:0] pixel_data [0:1023];
reg[9:0] pixels_fed;
reg[7:0] numbers_streamed;

task open_data_file(input [1023:0] file_name);
begin
  data_file = $fopen(file_name, "r");
  if (data_file == 0) begin
    $display("File %s handle was NULL", file_name);
    $stop;
  end
  else begin 
    file_lines_read = 0;
    while (!$feof(data_file)) begin
      $fscanf(data_file, "%d\n", captured_data); 
      pixel_data[file_lines_read] = captured_data;
      file_lines_read = file_lines_read + 1;
    end
  end
end
endtask

reg clk;
reg [10-1:0] input_index;
reg [`DATA_WIDTH-1:0] input_value;
reg input_enable;
wire [`DATA_WIDTH*4+2:0] output_result;

generated_model #(
        .DATA_WIDTH(`DATA_WIDTH)
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
    input_value = 0;
    input_index = 0;
    input_enable = 0;
    pixels_fed = 0;
    numbers_streamed = 0;
    open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/zero.txt");
end

reg [3:0] output_results_checked;
        
initial begin
    output_results_checked = 0;
end
    
always @ (posedge clk) begin #2
    if (pixels_fed!=file_lines_read) begin
        input_value <= pixel_data[pixels_fed];
        input_index <= pixels_fed;
        input_enable <= 1;
        if (pixels_fed + 1 == file_lines_read && numbers_streamed != 9) begin
            pixels_fed <= 0;
            if (numbers_streamed == 0) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/one.txt");
            end
            if (numbers_streamed == 1) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/two.txt");
            end
            if (numbers_streamed == 2) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/three.txt");
            end
            if (numbers_streamed == 3) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/four.txt");
            end
            if (numbers_streamed == 4) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/five.txt");
            end
            if (numbers_streamed == 5) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/six.txt");
            end                                                
            if (numbers_streamed == 6) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/seven.txt");
            end
            if (numbers_streamed == 7) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/eight.txt");
            end
            if (numbers_streamed == 8) begin
                open_data_file("/home/mbax4km4/FinalProject/MLontoFPGAs/VerilogSrc/Simulators/test_data/nine.txt");
            end                                         
            numbers_streamed <= numbers_streamed + 1;
        end
        else begin
            pixels_fed <= pixels_fed + 1;
        end
    end
    else begin
        input_enable <= 0;
    end
    if (output_result[`DATA_WIDTH*4+2]) begin
        output_results_checked <= output_results_checked+1;
        if (output_results_checked == 0) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 0);
        end
        if (output_results_checked == 1) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 1);
        end
        if (output_results_checked == 2) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 2);
        end
        if (output_results_checked == 3) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 3);
        end
        if (output_results_checked == 4) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 4);
        end
        if (output_results_checked == 5) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 5);
        end
        if (output_results_checked == 6) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 6);
        end
        if (output_results_checked == 7) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 7);
        end
        if (output_results_checked == 8) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 8);
        end                                                                
        if (output_results_checked == 9) begin
            check_output(output_result[`DATA_WIDTH*4+2-1:0], 9);
            #(`CLOCK*2);
            $display("SUCCESSFUL TEST!"); 
            $stop;
        end
    end
end

endmodule
