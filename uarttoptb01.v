`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 11:39:21
// Design Name: 
// Module Name: toptb
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


module top_tb(

    );
    reg clk,rst,serial_in;
    wire [7:0] parallel_out;
    wire serial_out,baudrate_clk,Tx_en;
    top DUT(.clk(clk), .rst(rst), .serial_in(serial_in), .parallel_out(parallel_out), .serial_out(serial_out),.Tx_en(Tx_en),.baudrate_clk(baudrate_clk));
    parameter [50:0] weight=(66000000*15)/(16*9600);
    
    always #7.5 clk=~clk;
	 
	 initial begin
	 clk=1'b1;
	      serial_in=1'b0;
	      rst=1;
	      #(2*weight) rst=0;
	      #(2*weight) serial_in=1'b0;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b1;
	      
	      
	      #(2*weight) serial_in=1'b0;
	      #(2*weight) serial_in=1'b1;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b1;
	      
	      #(2*weight) serial_in=1'b0;
	      #(2*weight) serial_in=1'b1;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b1;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b0;
	      #weight serial_in=1'b1;
	      
          #190000 $finish;
           end
endmodule
