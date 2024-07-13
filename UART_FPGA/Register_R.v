`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:31:20 04/11/2024 
// Design Name: 
// Module Name:    Register_R 
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
module Register_R(clk,reset,WR,RD,DataIn,DataOut,FCR,IER,IIR,LSR);

input clk;
input reset;
input WR;
input RD;
input [7:0] DataIn;
input [7:0] IER;
input [7:0] FCR;

output reg [7:0] DataOut;
output reg [7:0] IIR;
output reg [7:0] LSR;

reg [7:0] RDR;

initial LSR = 8'b00000000;
initial IIR = 8'b00000000;

always @(posedge clk) 
begin
    if (~reset) 
	 begin
        RDR <= 8'b0;
        LSR <= 8'b0;
        IIR <= 8'b0;
    end 
	 
	 else if(FCR[0]==0)
	 begin
        if (WR && RDR == 8'd0)
		  begin
            RDR <= DataIn;
        end

        if (WR && RDR != 8'd0) 
		  begin
           LSR <= LSR | 8'b00000010; // overrun error
			  if (IER[2]==1)                 // Receiver line status interrupt
					begin
					 IIR <= (IIR & 8'b11111110) | 8'b00000010;        // IIR[1]=1  Overun error pending
					end
        end
		  
        if (RD) 
		  begin
		      LSR <= LSR & 8'b11111101; // Overrun error is cleared once processor starts reading
				if (IER[2]==1)                 // Receiver line status interrupt
						  begin
						  IIR <= (IIR & 8'b11111101) | 8'b00000001;  // IIR[1]=1     Overun error resolved
						  end
            DataOut <= RDR;
				RDR <=0;
        end

        // Check if data is ready
        if (RDR != 8'b0) 
		  begin
		    LSR <= LSR | 8'b00000001; // Data ready
			 if(IER[0]==1)
			   begin
				IIR <= (IIR | 8'b00000100) & 8'b11111110; // Data is available in receiver FIFO enable interrupt pending
				end
		  end
		  else 
		  begin
		    LSR <= LSR & 8'b11111110; // Data is not ready
			 if(IER[0]==1)
				begin
				IIR <= (IIR | 8'b00000001) & 8'b11111011; // Data is not available in receiver FIFO
				end
		  end
    end
end

endmodule

