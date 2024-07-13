`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:56:20 04/01/2024 
// Design Name: 
// Module Name:    Transmitter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Transmitter(bclk,clk,reset,din,tx_init,tx,LCR,LSR);

input clk,reset,bclk;
input [7:0]din;
input [7:0]LCR;
input [7:0]LSR;

output reg tx_init;
output tx;

parameter idle=0, start=1, data=2, parity=3, stop=4 , idle2=5 ;

reg [2:0]state;
reg [4:0]b_count; //tracks stick counter
reg [3:0]DBIT;    //tracks no of bits
reg [7:0]b;       //shifts tansmitted bit
reg [1:0]SB;
reg tx;
reg par;
integer n;

always@(posedge clk)
case(LCR[1:0])
2'b00: DBIT<=5;
2'b01: DBIT<=6;
2'b10: DBIT<=7;
2'b11: DBIT<=8;
endcase

always @(posedge clk )
case(LCR[2])
 1'b0: SB<=1;
 1'b1: SB<=2;
endcase

always @(negedge clk)
begin
 case (state)
 idle : tx_init <= 1;
 idle2 : tx_init <= 0;
 endcase
end

always @(posedge clk)
begin
 if(~reset)
  begin
  state<=idle;
  b_count<=0;
  n<=0;
  b<=0;
  tx<=1'b1;
  end
else
begin
case(state)

  idle: begin
        tx<=1;
         if(LSR[5]==0)
          begin
          b_count <= 0;
          state <= idle2;
          end
         else 
			 state<=idle;
        end
		  
  idle2: begin
         b <= din;
         state <= start;
			end
			
  start: begin
          if(bclk==1)
           begin
           tx<=0;
            if(b_count==15)
             begin
				  b_count<=0;
              n<=0;
              if(LCR[4]==0)
               begin
               par <= 1;
               b_count<=0;
               n<=0;
               state<=data;
               end
              else
               begin
               par <= 0;
               state<=data;
               end
             end
            else
             begin
             b_count <= b_count + 1;
             state <= start;
             end
           end
          else
          state<=start;
         end
			
  data: begin
         if(bclk==1)
          begin
          tx <= b[0];
           if(b_count==15)
            begin
				b_count <=0;
	         par <= par ^ b[0];
            b <= b>>1; //right shift
             if(n == DBIT-1)
              begin
               if (LCR[3]==1)
                state <= parity;
               else
                state <= stop;
              end
             else
              begin
              n <= n + 1;
              state <= data;
              end
            end
           else
            begin
            b_count <= b_count + 1;
            state <= data;
            end
          end
         else
         state <= data;
        end
		  
  parity: begin
           if(bclk==1)
            begin
            tx <= par;
             if(b_count == 15)
              begin
              b_count <= 0;
              state <= stop;
              end
             else
              begin
              b_count <= b_count + 1;
              state <= parity;
              end
            end
           else
            state <= parity;
          end

  stop: begin
         if(bclk==1)
          begin
          tx <= 1;
           if(b_count == SB*15)
            begin
            state <= idle;
            end
           else
			   begin
            b_count <= b_count + 1;
				state <= stop;
				end
          end
         else
          state <= stop;
        end
  
  default: state <= idle;
endcase
end
end
endmodule
