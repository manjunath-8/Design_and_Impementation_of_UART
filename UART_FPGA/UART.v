`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:34:11 04/13/2024 
// Design Name: 
// Module Name:    UART 
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
module UART(PCLK,PRESETn,PENABLE,PADDR,PWRITE,PSEL,PWDATA,PRDATA,TX,RX,RTS,CTS,DTR,DSR,DCD,RI,DLR,IER,LCR,FCR,IIR,LSR,MCR,MSR);

input PCLK;
input PRESETn;
input PENABLE;
input [1:0]PADDR;
input PWRITE;
input PSEL;
input [7:0]PWDATA;
input RX;
input CTS;
input DSR;
input DCD;
input RI;

output reg[7:0] PRDATA;
output TX;
output RTS;
output DTR;

input [15:0]DLR;
input [7:0]IER;
input [7:0]LCR;
input [7:0]FCR;
input [7:0]MCR; // register data fed by user

output reg [7:0]IIR;
output reg [7:0]LSR;
output reg [7:0]MSR; // status registers

reg [7:0]SPR;

//baud rate generator
wire baud_clk;

Baud_rate_gen i1 (.clk(PCLK),
                  .reset(PRESETn),
				      .bclk(baud_clk),
				      .DLR(DLR),
				      .LCR(LCR)
				      );
					
//Receiver shift register
wire [7:0]r_data;
wire rx_done;

wire [7:0] LSR_R;
wire [7:0] IIR_R;

reg RXL;

Receiver i2 (.bclk(baud_clk),
             .clk(PCLK),
				 .reset(PRESETn),
				 .rx(RXL),
				 .b(r_data),
				 .rx_done(rx_done),
				 .LCR(LCR),
				 .LSR(LSR_R),
				 .IER(IER),
				 .IIR(IIR_R)
				 );
				 
//Transmitter shift register
wire tx_init;
reg [7:0] T_data;
	
Transmitter i3 (.bclk(baud_clk),
                .clk(PCLK),
                .reset(PRESETn),
                .din(T_data),
                .tx_init(tx_init),
                .tx(TX),
                .LCR(LCR),
                .LSR(LSR)
                );					 
//Reveiver Buffer
wire [7:0] LSR_RB;
wire [7:0] IIR_RB;

wire [7:0] PRDATA_F;	

Buffer_R i4 (.clk(PCLK),
             .reset(PRESETn),
             .WR(rx_done),
             .RD(PENABLE),
             .dataIn(r_data),
             .dataOut(PRDATA_F),
             .FCR(FCR),
             .IER(IER),
             .IIR(IIR_RB),
             .LSR(LSR_RB)
            );

//Transmitter buffer
wire [7:0] LSR_TB;
wire [7:0] IIR_TB;

wire [7:0] tt_data;

Buffer_T i5 (.clk(PCLK),
             .reset(PRESETn),
				 .tWR(PWRITE),
				 .tRD(tx_init),
				 .datain(PWDATA),
				 .dataout(tt_data),
				 .FCR(FCR),
             .IER(IER),
             .IIR(IIR_TB),
             .LSR(LSR_TB)
            );

//Receiver register
wire [7:0] LSR_RR;
wire [7:0] IIR_RR;	

wire [7:0] PRDATA_NF;

Register_R i6 (.clk(PCLK),
               .reset(PRESETn),
               .WR(rx_done),
               .RD(PENABLE),
               .DataIn(r_data),
               .DataOut(PRDATA_NF),
					.FCR(FCR),
               .IER(IER),
               .IIR(IIR_RR),
               .LSR(LSR_RR)
               );

//Transmitter register
wire [7:0] LSR_TR;
wire [7:0] IIR_TR;
 
wire [7:0] t_data;

Register_T i7 (.clk(PCLK),
               .reset(PRESETn),
					.tWR(PWRITE),
					.tRD(tx_init),
					.Datain(PWDATA),
					.Dataout(t_data),
					.FCR(FCR),
               .IER(IER),
               .IIR(IIR_TR),
               .LSR(LSR_TR)
                );
					 
always @(negedge PCLK)
begin
//MCR[1:0] <= LSR[5];
 if(FCR[0]==1)
  begin
  LSR <= LSR_R | LSR_RB | LSR_TB;
  LSR[6] <= tx_init;
  //IIR <= IIR_R | IIR_RB | IIR_TB;
  PRDATA <= PRDATA_F;
  T_data <= tt_data;
  end
 else
  begin
  LSR <= LSR_R | LSR_RR | LSR_TR ;
  LSR[6] <= tx_init;
  //IIR <= IIR_R | IIR_RR | IIR_TR ;
  PRDATA <= PRDATA_NF;
  T_data <= t_data;
  end
end

always @(negedge PCLK)
begin
 if (MCR[4]==1)
 RXL <= TX;
 else
 RXL <= RX;
end

reg P_CTS;
reg P_DSR;
reg P_DCD;
reg P_RI;

initial P_CTS=0;
initial P_DSR=0;
initial P_DCD=0;
initial P_RI=0;

reg P_RTS;
initial P_RTS = 0;

always @(posedge PCLK)
begin
if (~PRESETn)
 begin
  MSR <= 8'b00000000;
 end
 
else
 begin
 if (FCR[0]==1)
 IIR <= IIR_R | IIR_RB | IIR_TB;
 
 else if (FCR[0]==1)
 IIR <= IIR_R | IIR_RR | IIR_TR ;
 
 else if (MCR[4]==1)
  begin
   if ( P_RTS != MCR[1])
	 begin
     MSR[4] <= MCR[1];
	  MSR[5] <= MCR[0];
	  MSR[6] <= MCR[2];
	  MSR[7] <= MCR[3];
	  MSR <= MSR | 8'b00001111;
	  P_RTS <= MCR[1];
	  if(IER[3]==1)
	   IIR <= (IIR & 8'b11111110) | 8'b00010000; // IIR[4]=1 Modem status interrupt
	 end
	else
	 MSR <= MSR & 8'b11110000;
	 if(IER[3]==1)
	   IIR <= (IIR & 8'b11101111) | 8'b00000001; // No interrupt pending
  end
 else
  begin
   if(CTS != P_CTS)
	 begin
	  MSR[0] <= 1'b1;
	  MSR[4] <= ~CTS;
	  P_CTS <= CTS;
	  if(IER[3]==1)
	   IIR <= (IIR & 8'b11111110) | 8'b00010000; // IIR[4]=1 Modem status interrupt
	 end
	else if(DSR != P_DSR)
	 begin
	  MSR[1] <= 1'b1;
	  MSR[5] <= ~DSR;
	  P_DSR <= DSR;
	  if(IER[3]==1)
	   IIR <= (IIR & 8'b11111110) | 8'b00010000; // IIR[4]=1 Modem status interrupt
	 end
	else if(RI != P_RI)
	 begin
	  MSR[2] <= 1'b1;
	  MSR[6] <= ~RI;
	  P_RI <= RI;
	  if(IER[3]==1)
	   IIR <= (IIR & 8'b11111110) | 8'b00010000; // IIR[4]=1 Modem status interrupt
	 end
	else if(DCD != P_DCD)
	 begin
	  MSR[3] <= 1'b1;
	  MSR[7] <= ~DCD;
	  P_DCD <= DCD;
	  if(IER[3]==1)
	   IIR <= (IIR & 8'b11111110) | 8'b00010000; // IIR[4]=1 Modem status interrupt
	 end
	else
	 MSR <= MSR & 8'b11110000;
	 if(IER[3]==1)
	   IIR <= (IIR & 8'b11101111) | 8'b00000001; // No interrupt pending
  end
end
end


assign DTR = ~MCR[0];
assign RTS = ~MCR[1];

endmodule
