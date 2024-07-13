`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:18:35 03/27/2024 
// Design Name: 
// Module Name:    Receiver 
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
module Receiver(bclk,clk,reset,rx,b,rx_done,LCR,LSR,IER,IIR);

input bclk;
input clk;
input reset; 
input [7:0]LCR;
input rx;
input [7:0]IER;

output reg [7:0]IIR;
output reg [7:0]b;
output reg [7:0]LSR;
output reg rx_done;

initial LSR = 8'b00000000;
initial IIR = 8'b00000000;

reg par;
reg p_par;
reg [2:0]state;
reg [3:0]DBIT;
reg [1:0]SB;

integer n=0;
integer b_count=0;
parameter idle=0, start=1, data=2, parity=3,stop=4;

always @(posedge clk )
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

always @(posedge clk)
begin
  if (~reset)
  begin
    b_count <= 0;
    n = 0;
    par <= 0;
	 p_par <= 0;
    b <= 0;
    LSR <= 8'b00000000;
	 IIR <= 8'b00000000;
    rx_done <= 0;
    state <= idle;
  end
else
  begin
  case( state)
  idle: begin
           b_count<=0;
			  n = 0;
           par <= 0;
			  p_par <= 0;
           b <= 0;
           rx_done <= 0;

         if(rx==0)
		     begin
       	  state<= start;
			  end
			 else
			  state<= idle;
	       end
  start: begin
          if( bclk==1)
			   begin
			    if(b_count == 7)
			     begin
				   b_count <= 0;
			      n = 0;
				   if (LCR[4]==0)
					 begin
				     par <=1;
				     state<= data;
					 end
			      else
					 begin
				    par <=0;
				    state<= data;
				   end
			     end
				  
				 else
				  begin
				  b_count <= b_count+1;
				  state <= start;
				 end
			 end
			else
			state <= start;
		  end
				
	data: begin	 
			 if (bclk==1)
			  begin
				 if (b_count==15)
				   begin
					 b_count <= 0;
					   case(DBIT)
					    5: b <= {rx, b[4:1]};
						 6: b <= {rx, b[5:1]};
						 7: b <= {rx, b[6:1]};
						 8: b <= {rx, b[7:1]};
					   endcase
					 if (LCR[3]==1)
					  begin
						par <= par ^ rx;
						 if (n==DBIT-1)
                    state <= parity;										  
						 else
							begin
							 n = n+1;
							 state <= data;
							end
						 end
					 else
					  begin
						if (n==DBIT-1)
                    state <= stop;										  
						else
						 begin
							n = n+1;
							state <= data;
						 end
						end
					  end
					 else
					  begin
						b_count <= b_count+1;
						state <= data;
                 end							 
				  end
			else
			 state <= data;
	      end
			
	parity: begin
	         if ( bclk==1)
				  begin
					 if ( b_count == 15)
					  begin
						 b_count <= 0;
						 if ( rx == par)                     //checking parity
						  begin
						  p_par <= 0;
						  LSR <= LSR & 8'b11111011;
						  if (IER[2]==1)                 // Receiver line status interrupt
						  begin
						  IIR <= (IIR | 8'b00000001) & 8'b11111101;        // IIR[1]=1
						  end
						  state <= stop;
						  end
						 else
						  begin
						  p_par <= 1;
						  LSR <= LSR | 8'b00000100;      // Parity error 
						  if (IER[2]==1)                 // Receiver line status interrupt
						  begin
						  IIR <= (IIR | 8'b00000010) & 8'b11111110;        // IIR[1]=1
						  end
						  state <= stop;
						  end
						end
					  else 
						begin
						 b_count <= b_count+1;
						 state <= parity;
						end
					 end
				 else 
				  state <=  parity;
	         end
	stop: begin
		     if ( bclk == 1)
				begin
				 if ( b_count == SB*15)
				  begin
				  b_count <= 0;
					if (rx==1)                     //checking framing error
					 begin
					 LSR <= LSR & 8'b11110111;
					 if (IER[2]==1)                 // Receiver line status interrupt
						  begin
						  IIR <= (IIR | 8'b00000001) & 8'b11111101;       // IIR[1]=1
						  end
					 if (p_par)
	             rx_done <= 0;
					 else
					 rx_done <= 1;
					 state <= idle;
					 end
					else
					 begin
					 LSR <= LSR | 8'b00001000;      //Framing error
				  if (IER[2]==1)                 // Receiver line status interrupt
						  begin
						  IIR <= (IIR | 8'b00000010) & 8'b11111110;        // IIR[1]=1
						  end
					 state <= idle;
					 end
				  end
				 else 
				  begin
				  b_count <= b_count+1;
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
