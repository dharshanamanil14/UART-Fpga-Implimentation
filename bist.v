`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 14:27:07
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


module top( input clk,rst,serial_in,op_mode,temp,output serial_out, baudrate_clk, m_i_faulty
);
    wire [7:0]   rx_data, misr_data;
    
   
    parameter [15:0] baudrate=9600;
    parameter [4:0] divisions=16;
    
    wire match,ereg;
	wire Busy, serial_out1,comparator_in;
    wire [7:0] parallel_out;
    wire Tx_en;
    wire lfsr_out,mux_out;
    // Instantiate Modules
    baud_rate_generator brg(clk,rst,baudrate,divisions,baudrate_clk);
    lfsr lfsr_inst (.clk(baudrate_clk), .rst(rst), .temp(temp), .lfsr_out(lfsr_out), .lfsro(lfsro));
    mux_2to1 mux_inst (.sel(op_mode), .data_in(serial_in), .lfsr_out(lfsr_out), .mux_out(mux_out));
   
    
    UART_rx  uartrx(baudrate_clk,rst,mux_out,parallel_out,Tx_en,Busy);
    UART_tx  uarttx(baudrate_clk,rst,parallel_out,Tx_en,op_mode,serial_out1,Busy);
    
    demux_1to2 demux_1to2(op_mode,serial_out1,serial_out,comparator_in);
    
    comparator comparator(.baudrate_clk(baudrate_clk), .op_mode(op_mode), .serial_out(comparator_in),.temp(temp), .rst(rst), .ereg(ereg), .match(match)); // Example expected signature
    response_analyzer  response_analyzer(match,clk, m_i_faulty);
   

endmodule


module mux_2to1 (
    input wire sel,          
    input wire data_in, 
    input wire lfsr_out, 
    output wire mux_out  
);
    assign mux_out = sel ? lfsr_out : data_in;
endmodule



module lfsr (
    input clk,      
    input rst,      
    input temp,    
    output reg lfsr_out=1,  
    output reg [3:0] lfsro 
);

    always @(posedge clk) begin
        if (temp) 
            lfsro <= 4'b1011;  
        else  
            lfsro <= {lfsro[2:0], lfsro[3] ^ lfsro[2]}; 
    end

    always @(posedge clk) begin
        lfsr_out <= lfsro[0]; 
    end

endmodule




module demux_1to2 (
    input wire sel,             
    input wire [7:0] serial_out1,  
    output wire [7:0] serial_out, 
    output wire [7:0] misr_in   
);
    assign serial_out = sel ? 1'bX : serial_out1;
    assign misr_in = sel ? serial_out1 : 1'bz;
endmodule



module comparator(               
    input  baudrate_clk,       
    input  serial_out,         
    input  temp,rst,op_mode,               
    output reg  ereg=1,
    output reg match=1          
);

    reg [66:0] expected_reg = {49'b1001000111101100100011110110010001111011001000, 18'b111111111111111111}; 
    integer i = 0;

    always @(posedge baudrate_clk) begin
        if(op_mode==1'b0) begin 
            match<=1'bX;ereg=1'bX; end
        else if (temp|rst) begin
            i <= 0;
            match <= 1'b1;  
        end else begin
            if (i < 67) begin
                if (serial_out !== expected_reg[i]) begin   
                    match <= 1'b0; i <= i + 1; ereg<=serial_out; end 
                else begin
                i <= i + 1; match<=1'b1; ereg<=serial_out; end
            end
        end
    end

endmodule


module response_analyzer(input match,clk,output reg  m_i_faulty=0);
always @(posedge clk) begin
        if(!match)
        m_i_faulty<=1'b1; 
        else
        m_i_faulty<=1'b0|m_i_faulty;
        /*else
        m_i_faulty<=1'bx;*/
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
          /*parallel_out<=8'b1;*/
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
    input Tx_en,op_mode,
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
           /*serial_out <= 1'b0;*/
           serial_out <= shift_reg[0];
           shift_reg <= shift_reg >> 1; Busy<=1'b1; counter<=counter+4'b0001; 
           if(counter==4'b1010) begin present_state=WAIT;  end else present_state<=SHIFT; end
    WAIT: begin
          shift_reg[8:0]=10'b0000000000; Busy=1'b1; counter=4'b0001; present_state<=IDLE;
          end 
    default: begin   /*if(op_mode) serial_out=1'bX; else */  begin
                    counter=4'b0001; 
                   present_state<=IDLE; end end 
          endcase
                    end
          endmodule 
