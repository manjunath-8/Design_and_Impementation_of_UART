`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:10:23 03/23/2024 
// Design Name: 
// Module Name:    Baud_rate_gen 
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
module Baud_rate_gen(clk,reset,bclk,DLR,LCR);

input clk,reset;
input [15:0]DLR;
input [7:0]LCR;

output reg bclk;

reg [15:0]dlr;

integer count=0;

always @(posedge clk)
begin
  if (~reset) 
	 begin
        count <= 0;
        bclk <= 0;
		  dlr<=0;
    end 
	 
  if(LCR[7]==1)
    begin
		dlr<=DLR;
		count <= 0;
	 end	
	 
  else 
    begin
        if (count == dlr) 
		     begin
            count <= 0;
            bclk <= 1'b1;
        end 
		   else 
			   begin
            count <= count + 1;
				bclk <= 1'b0;
        end
    end
end
endmodule

