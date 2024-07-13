`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:29:50 04/10/2024 
// Design Name: 
// Module Name:    Buffer_T 
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
module Buffer_T(clk,reset,tWR,tRD,datain,dataout,FCR,IER,IIR,LSR);

input clk;
input reset;
input tWR;        
input tRD;               
input [7:0]datain;
input [7:0]FCR;
input [7:0]IER;
 
output reg [7:0]dataout;
output reg [7:0]IIR;
output reg [7:0]LSR;

initial LSR = 8'b00000000;
initial IIR = 8'b00000000;

reg [7:0] mem[31:0];

integer count=0;
integer i=0;

always @(posedge clk)
begin
    if (~reset)
    begin
        count <= 0;
        i = 0;
		  LSR <= 8'b00000000;
	     IIR <= 8'b00000000;
    end
	 
	 else if (FCR[2]==1 | FCR[0]==0) //To clear transmitter buffer
	 begin
	     count <= 0;
        i = 0;
	 end
	 
	 else if (FCR[0]==1)
    begin
	     if ( count == 0)
		  begin
		    LSR <= LSR | 8'b00100000; // Transmitter FIFO is empty
			 if(IER[1]==1)
			   begin
				IIR <= (IIR & 8'b11111110) | 8'b0001000;  // Transmitter FIFO is empty enable interrupt pending
				end
		  end
		  
		  if ( count != 0)
		  begin
		    LSR <= LSR & 8'b11011111; // Transmitter FIFO is not empty
			 if(IER[1]==1)
				IIR <= (IIR & 8'b11110111) | 8'b00000001; // interrupt is not pending
		  end
		  
        if (tWR) // tWR - PWRITE and tRD - tx_init_tick                     
        begin	
            if ( count <31)
            begin				
              mem[count] <= datain;
				  count <= count + 1;
            end
				else if ( count == 31)
            begin				
              mem[count] <= datain;
            end
        end
		  
        if (tRD && count > 0) 
		  begin
            dataout <= mem[0];
            for (i = 0; i < 31; i = i + 1) 
				begin
                mem[i] <= mem[i+1];
            end
				mem[count] <= 8'dx; // Clear the last element
            count <= count - 1;
        end 
		  
		  else
		  dataout <= 8'dX;
		  
    end
   	 
end
endmodule
