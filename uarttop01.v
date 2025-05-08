`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 11:38:48
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


module top( input clk,rst,serial_in, output [7:0] parallel_out, output serial_out,Tx_en,baudrate_clk);
    parameter [15:0] baudrate=9600;
    parameter [4:0] divisions=16;
    

	wire Busy;
    /*wire [7:0] parallel_out;*/
    baud_rate_generator brg(clk,rst,baudrate,divisions,baudrate_clk);
    UART_rx  uartrx(baudrate_clk,rst,serial_in,parallel_out,Tx_en,Busy);
    UART_tx  uarttx(baudrate_clk,rst,parallel_out,Tx_en,serial_out,Busy);
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
          if(rst) present_state<=IDLE;
          else if(ndet_output) begin present_state<=SHIFT; Busy<=1'b0; end else begin present_state<=IDLE; Busy<=1'b0; end end
    SHIFT: begin
          shift_reg = shift_reg>>1; shift_reg[9] = serial_in; counter<=counter+4'b0001; Busy<=1'b1;
          if(counter==4'b1001) present_state<=LOAD; end
    LOAD: begin
          parallel_out<=shift_reg[8:1];
          present_state<=WAIT; Busy<=1'b1;Load=1'b1; end
    WAIT: begin
          shift_reg[9:0]<=10'b0000000000; Busy<=1'b1; counter<=4'b0001;present_state<=IDLE;
          end 
    default: begin
                    present_state<=IDLE; counter<=4'b0001; Busy<=1'b0; end
          endcase
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

