`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:57:00 04/14/2024
// Design Name:   UART
// Module Name:   M:/Minor II/UART/UART_tb.v
// Project Name:  UART
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UART
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module UART_tb;

	// Inputs
	reg PCLK;
	reg PRESETn;
	reg PENABLE;
	reg [1:0] PADDR;
	reg PWRITE;
	reg PSEL;
	reg [7:0] PWDATA;
	reg RX;
	reg CTS;
	reg DSR;
	reg DCD;
	reg RI;
	
	reg [15:0] DLR;
	reg [7:0] IER;
	reg [7:0] LCR;
	reg [7:0] FCR;
	reg [7:0] MCR;
	
	// Outputs
	wire [7:0] PRDATA;
	wire TX;
	
	wire RTS;
	wire DTR;
	wire [7:0] IIR;
	wire [7:0] LSR;
	wire [7:0] MSR;

	// Instantiate the Unit Under Test (UUT)
	UART uut (
		.PCLK(PCLK), 
		.PRESETn(PRESETn), 
		.PENABLE(PENABLE), 
		.PADDR(PADDR), 
		.PWRITE(PWRITE), 
		.PSEL(PSEL), 
		.PWDATA(PWDATA), 
		.PRDATA(PRDATA), 
		.TX(TX), 
		.RX(RX),
      .RTS(RTS),
      .CTS(CTS),
      .DTR(DTR),
      .DSR(DSR),
      .DCD(DCD),
      .RI(RI),		
		.DLR(DLR), 
		.IER(IER), 
		.LCR(LCR), 
		.FCR(FCR), 
		.IIR(IIR), 
		.LSR(LSR),
		.MCR(MCR),
		.MSR(MSR)
	);

   initial PCLK = 1'b1;
	always #1 PCLK = ~PCLK;
	
	initial begin
		// Initialize Inputs
		PRESETn = 0;#2
		PRESETn = 1;
		PADDR = 0;
		PSEL = 0;
		RX = 0;
		DLR = 12'd13;
		LCR = 8'b10000000;#10;
		LCR = 8'b01111011;
		FCR = 8'b00000001;
		IER = 8'b11111111;
		MCR = 8'b00010000;
		
		CTS = 1;
		DSR = 1;
		DCD = 0;
		RI = 0 ;
		
		PENABLE = 0;
		
		PWRITE = 1;
		
		PWDATA = 8'b10101111;
		#2;
		
		PWDATA = 8'b11110000;
		#2;
		
		PWDATA = 8'b11010010;
		#2;
		PWDATA = 8'b11111111;
		#2;
		
		PWRITE = 0;
		
		PENABLE = 1;
		
		CTS = 0;
		DSR = 0;
		DCD = 1;
		RI = 1 ;
		/*
		PENABLE = 0;
		DLR = 12'd13;
		LCR = 8'b10000000;#10;
		LCR = 8'b01111011;
		FCR = 8'b00000001;
		IER = 8'b11111111;
		MCR = 8'b00000000;
		
		CTS = 1;
		DSR = 1;
		DCD = 0;
		RI = 0 ;
		
		RX = 1; #38;
		RX = 0; #458;        //start bit
		
		RX = 1; #448;    //data bits
		RX = 0; #448;
		RX = 1; #438;
		RX = 0; #458;
		RX = 0; #458;
		RX = 0; #438;
		RX = 1; #448;
		RX = 0; #458;
		
		RX = 1; #448;   //parity bit
		
		RX = 1; #458;   //stop bit
		
		RX = 0; #458;        //start bit
		
		RX = 1; #448;    //data bits
		RX = 0; #448;
		RX = 0; #438;
		RX = 0; #458;
		RX = 0; #458;
		RX = 0; #438;
		RX = 0; #448;
		RX = 1; #458;
		
		RX = 0; #448;   //parity bit
		
		RX = 1; #458;   //stop bit
		RX = 0;   //stop bit
		
		PENABLE = 1;
				
		CTS = 0;
		DSR = 0;
		DCD = 1;
		RI = 1 ;
*/
		
		// Wait 100 ns for global reset to finis
     
		// Add stimulus here

	end
      
endmodule
