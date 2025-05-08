`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 14:27:35
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



module ubtb(

    );

    reg clk,rst,temp,op_mode,serial_in;
    wire serial_out,baudrate_clk,m_i_faulty;
    top DUT(.clk(clk), .rst(rst), .temp(temp), .serial_in(serial_in), .baudrate_clk(baudrate_clk), .serial_out(serial_out), .op_mode(op_mode),  .m_i_faulty(m_i_faulty));
    parameter [50:0] weight=(66000000*15)/(16*9600);
    
    always #7.5 clk=~clk;
	 
	 initial begin
	 clk=1'b1;
	 serial_in=1'b0;temp=1;
	      rst=1;op_mode=0;
	      #(2*weight) rst=0;
	      #(2*weight) serial_in=1'b0;temp=0;
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