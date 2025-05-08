`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 10:04:56
// Design Name: 
// Module Name: top
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


module top( input clk,rst,Tx_en,sel,temp,/*serial_in,*/ input [7:0] parallel_in,  output serial_out,m_i_faulty, output [7:0] parallel_out, output baudrate_clk,Load);
   parameter [15:0] baudrate=9600;
   parameter [4:0] divisions=16;
    

	wire Busy,Busy1;
	wire match;
    wire [7:0] out,y,data;
    
   baud_rate_generator brg(clk,rst,baudrate,divisions,baudrate_clk);
   lfsr_excess4 le(baudrate_clk,temp,out);
   mux2to1 mm(baudrate_clk,sel,out,parallel_in,y);
   UART_tx  uarttx(baudrate_clk,rst,y,Tx_en,serial_out,Busy);
   UART_rx  uartrx(baudrate_clk,rst,serial_out,parallel_out,Load,Busy1);
   /*demux1to2 demux(baudrate_clk,sel,out,parallel_out);*/
   uart_golden_rom ugr(Load,temp,data);
   comparator comparator(clk, rst,parallel_out,data,match);
   response_analyzer ra(match,clk,sel, m_i_faulty);
endmodule



module mux2to1(input clk, sel, input [7:0] a,b, output reg [7:0] y);
   always @(posedge clk) begin
    y=sel?a:b; end
   endmodule

module demux1to2(input clk,sel, input [7:0] a, output reg [7:0] p,q);
     always @(posedge clk) begin
        p=sel?a:8'bxxxxxxxx;
        q=sel?8'bxxxxxxxx:a; end
endmodule


module response_analyzer(input match,clk,sel,output reg  m_i_faulty=0);
always @(posedge clk) begin
        if(~sel)
        m_i_faulty<=1'bX;
        else if(!match)
        m_i_faulty<=1'b1; 
        else
        m_i_faulty<=1'b0|m_i_faulty;
        /*else
        m_i_faulty<=1'bx;*/
        end
        endmodule

module uart_golden_rom (
    input wire clk,            
    input wire rst,            
    output reg [7:0] data    
);

    reg [3:0] addr=0;            
    reg [3:0] clk_count;      

    
    always @(posedge clk) begin
        if (rst) begin
            clk_count <= 0;
            addr <= 0;
            data <= 8'h00;
        end else begin
            
                addr <= addr + 1; end

                
                case (addr)
                    4'd0:  data <= 8'h00;
                    4'd1:  data <= 8'hfc;
                    4'd2:  data <= 8'h04;
                    4'd3:  data <= 8'h1c;
                    4'd4:  data <= 8'hdf;
                    4'd5:  data <= 8'h41;
                    4'd6:  data <= 8'h46;
                    4'd7:  data <= 8'hc2;
                    4'd8:  data <= 8'h80;
                    4'd9:  data <= 8'h97;
                    4'd10: data <= 8'h95;
                    4'd11: data <= 8'h5f;
                    4'd12: data <= 8'h89;
                    4'd13: data <= 8'h4E;
                    4'd14: data <= 8'h4F;
                    4'd15: data <= 8'h50;
                    default: data <= 8'h00;
                endcase

            end 
   

endmodule


module comparator (
    input clk,              
    input rst,              
    input [7:0] out1,       
    input [7:0] out2,       
    output reg fault_flag=1   
);

    reg [3:0] cycle_count;  

    always @(posedge clk) begin
        
                if (out1 != out2)
                    fault_flag <= 0;
                else
                    fault_flag <= 1;
            
          end

endmodule





module baud_rate_generator(
    input clk,
    input rst, 
    input [15:0] int,
    input [4:0] int2,
    output reg baudrate
);

    reg [17:0] count;
    
    wire [50:0] count_max = 66000000 / (int * int2); 
    
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            baudrate <= 0;
        end else if (count == count_max) begin
            count <= 0;  
            baudrate <= 1;  
        end else begin
            count <= count + 1;
            baudrate <= 0;
        end
    end

endmodule


module lfsr_excess4 (
    input clk,
    input rst,
    output reg [7:0] out
);
    reg [7:0] lfsrreg;
    reg [3:0] cycle_count;  

    
    always @(posedge clk ) begin
        if (rst) begin
            lfsrreg <= 8'b00110011;
            cycle_count <= 0;
            out <= 8'd0;
        end else begin
            
            lfsrreg <= {lfsrreg[6:0], lfsrreg[7] ^ lfsrreg[5]};
            
            
            if (cycle_count == 9) begin
                cycle_count <= 0;
                out <= lfsrreg + 8'd4;  
                lfsrreg<=out;
            end else begin
                cycle_count <= cycle_count + 1;
            end
        end
    end

endmodule




module UART_tx(
    input clk,
    input rst,
    input [7:0] Tx_Data,
    input Tx_en,
    output reg serial_out=1,
    output reg Busy=0
    );
    
    parameter IDLE = 2'b00, LOAD = 2'b01, SHIFT=2'b10, WAIT = 2'b11;
    reg [1:0] present_state;
    reg [9:0] shift_reg;
    reg [3:0] counter;
    
    always @(posedge clk)
    begin
    case(present_state)
    IDLE: begin
          if(rst) present_state<=IDLE;
          else if(Tx_en) begin present_state<=LOAD; end end
    LOAD: begin
          shift_reg[0]<=1'b0;
          shift_reg[8:1]<=Tx_Data;
          shift_reg[9]<=1'b1; Busy<=1'b1; present_state<=SHIFT; end
    SHIFT: begin
           /*serial_out<=1'b1;*/
           serial_out <= shift_reg[0];
           shift_reg <= shift_reg >> 1; Busy<=1'b1; counter<=counter+4'b0001; 
           if(counter==4'b1010) begin present_state=WAIT;  end else present_state<=SHIFT; end
    WAIT: begin
          shift_reg[8:0]=10'b0000000000; Busy=1'b1; counter=4'b0001; present_state<=IDLE;
          end 
    default: begin
                    counter=4'b0001; 
                   present_state<=IDLE; end 
          endcase
                    end
          endmodule 




 module UART_rx(
    input clk,
    input rst,
    input serial_in,
    output reg [7:0] parallel_out,
    output reg Load=0,Busy
    );
    wire ndet_output;
    wire q=1;
    assign ndet_output=q&~serial_in;
    parameter IDLE = 2'b00, LOAD = 2'b01, SHIFT=2'b10, WAIT = 2'b11;
    reg [1:0] present_state;
    reg [9:0] shift_reg;
    reg [3:0] counter;
    always @(posedge clk)
    begin
    case(present_state)
    IDLE: begin
          if(rst) begin present_state<=IDLE;Busy<=1'b0; end
          else if(ndet_output) begin present_state<=SHIFT; Busy<=1'b0; end else begin present_state<=IDLE;/*parallel_out=8'b11111111;*/ Busy<=1'b1;Load=1'b0; end end
    SHIFT: begin
          shift_reg = shift_reg>>1; shift_reg[9] = serial_in; counter<=counter+4'b0001; Busy<=1'b0;Load=1'b0;
          if(counter==4'b1001) present_state<=LOAD; end
    LOAD: begin
          /*parallel_out<=8'b11111111;*/
          parallel_out<=shift_reg[8:1];
          present_state<=WAIT; Busy<=1'b1;Load=1'b1; end
    WAIT: begin
          shift_reg[9:0]<=10'b0000000000; Busy<=1'b0; counter<=4'b0001;present_state<=IDLE;Load=1'b0;
          end 
    default: begin
                    present_state<=IDLE; counter<=4'b0001; Busy<=1'b0; end
          endcase
                    end
          endmodule      
          









































