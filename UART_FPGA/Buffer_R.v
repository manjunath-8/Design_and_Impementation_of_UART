`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:02:17 04/09/2024 
// Design Name: 
// Module Name:    Buffer_R 
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
module Buffer_R(clk,reset,WR,RD,dataIn,dataOut,FCR,IER,IIR,LSR);

input clk;
input reset;
input WR,RD;        
input [7:0]dataIn;
input [7:0]FCR;
input [7:0]IER;

output reg [7:0]dataOut;
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
	 
	 else if (FCR[1]==1 | FCR[0]==0) //To clear receiver buffer
	 begin
	     count <= 0;
        i = 0;
	 end
	 
    else if (FCR[0]==1)
    begin
	     if ( count != 0)
		  begin
		    LSR <= LSR | 8'b00000001; // Data ready
			 if(IER[0]==1)
			   begin
				IIR <= (IIR | 8'b00000100) & 8'b11111110; // Data is available in receiver FIFO enable interrupt pending
				end
		  end
		  
		  if ( count == 0)
		  begin
		    LSR <= LSR & 8'b11111110; // Data is not ready
			 if(IER[0]==1)
			 begin
				IIR <= (IIR | 8'b00000001) & 8'b11111011; // Data is not available in receiver FIFO
				end
		  end
		  
        if (WR)  // WR - RX_done_tick and RD - PENABLE                    
        begin	
            if ( count < 31)
            begin				
              mem[count] <= dataIn;
				  count <= count + 1;
            end
				else if (count == 31)
				begin				
              mem[count] <= dataIn;
            end
            else
            begin
              LSR <= LSR | 8'b00000010; // Overrun error
				  if (IER[2]==1)                 // Receiver line status interrupt
						  begin
						  IIR <= (IIR & 8'b11111110) | 8'b00000010;        // IIR[1]=1  Overun error pending
						  end
            end				  
        end
		  
		  if (RD && count > 0) 
		  begin
		      LSR <= LSR & 8'b11111101; // Overrun error is cleared once processor starts reading
				if (IER[2]==1)                 // Receiver line status interrupt
						  begin
						  IIR <= (IIR & 8'b11111101) | 8'b00000001;  // IIR[1]=1     Overun error resolved
						  end
            dataOut <= mem[0];
            for (i = 0; i < 31; i = i + 1) 
				begin
                mem[i] <= mem[i+1];
            end
				mem[count] <= 8'dx;
            count <= count - 1;
        end
		   
        else  
          dataOut <= 8'dX;
    end
end
endmodule
