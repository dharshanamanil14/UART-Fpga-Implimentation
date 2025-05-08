`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 10:05:28
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
    reg clk,rst,Tx_en,temp,sel;
    reg [7:0] parallel_in;
   /*wire [7:0] parallel_out;*/
   wire serial_out/*,Tx_en*/,baudrate_clk,Load,m_i_faulty;
    wire [7:0] parallel_out;
   top DUT(.clk(clk), .rst(rst),.temp(temp),.m_i_faulty(m_i_faulty), .sel(sel),.Load(Load), .parallel_in(parallel_in), .parallel_out(parallel_out), .serial_out(serial_out),.Tx_en(Tx_en),.baudrate_clk(baudrate_clk));
   parameter [50:0] weight=(66000000*15)/(16*9600);
    
   always #7.5 clk=~clk;
	 
	 initial begin
	 clk=1'b1;sel=1;
	     Tx_en=1'b1;
	      rst=1;temp=1;
	      #weight rst=0;
	      #(2*weight) temp=0;
	      parallel_in=8'b01110101;
	      #(16*weight) parallel_in=8'b00110011;
	      #(16*weight)  parallel_in=8'b01111001;
	      
          #900000 $finish;
           end
endmodule











