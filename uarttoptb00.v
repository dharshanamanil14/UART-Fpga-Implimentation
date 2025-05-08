`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2025 10:43:55
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


module top_tb( );
    reg clk,rst,Tx_en;
    reg [7:0] parallel_in;
    wire serial_out,baudrate_clk;
    wire [7:0] parallel_out;
    
   top DUT(.clk(clk), .rst(rst),.parallel_in(parallel_in), .baudrate_clk(baudrate_clk), .serial_out(serial_out), .parallel_out(parallel_out), .Tx_en(Tx_en));
   parameter [50:0] weight=(100000000*10)/(16*9600);
    
   always #5 clk=~clk;
	 
	 initial begin
	 clk=1'b1;
	     Tx_en=1'b1;
	      rst=1;
	      #(2*weight)rst=0;
	      parallel_in=8'b01110101;
	      #(47*weight) parallel_in=8'b00110011;
	      #(33*weight)  parallel_in=8'b01111001;
	      
          #900000 $finish;
           end
endmodule
