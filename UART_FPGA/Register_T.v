`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:15:08 04/11/2024 
// Design Name: 
// Module Name:    Register_T 
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
module Register_T(clk,reset,tWR,tRD,Datain,Dataout,FCR,IER,IIR,LSR);

input clk;
input reset;
input tWR;
input tRD;
input [7:0] Datain;
input [7:0] IER;
input [7:0] FCR;

output reg [7:0] Dataout;
output reg [7:0] IIR;
output reg [7:0] LSR;

initial LSR = 8'b00000000;
initial IIR = 8'b00000000; 

reg [7:0] TDR;

always @(posedge clk) 
begin
    if (~reset) 
	 begin
        TDR <= 8'b0;
        LSR <= 8'b0;
        IIR <= 8'b0;
    end 
	 else if(FCR[0]==0)
	 begin 
        if (tWR && TDR == 8'd0) 
		  begin
            TDR <= Datain;
        end

        if (tRD && TDR != 0) 
		  begin
            Dataout <= TDR;
				TDR <= 0;
        end

        if (TDR == 8'b0) 
		  begin
		    LSR <= LSR | 8'b00100000; // TDR is empty
			 if(IER[1]==1)
			   begin
				IIR <= (IIR & 8'b11111110) | 8'b00001000; // TDR is empty enable interrupt pending
				end
		  end 
		  
		  else 
		  begin
		    LSR <= LSR & 8'b11011111; // TDR is not empty
			 if(IER[1]==1)
				IIR <= (IIR & 8'b11110111) | 8'b00000001; // interrupt is not pending
		  end
    end
end

endmodule

