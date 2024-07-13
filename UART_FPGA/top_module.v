`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:49:29 05/22/2024 
// Design Name: 
// Module Name:    top_module 
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

module top_module(clk,TX,RX);
input clk;
wire[35:0]q;
wire [65:0]d;
wire [33:0]o;
output TX;
input RX;

//reg [3:0]clk_div;

//initial clk_div=0;

//always @(posedge clk)
//clk_div <= clk_div+1;

icon q1 (
    .CONTROL0(q) // INOUT BUS [35:0]
);

vio q2 (
    .CONTROL(q), // INOUT BUS [35:0]
    .CLK(clk), // IN
    .SYNC_OUT(d), // OUT BUS [66:0]
    .SYNC_IN(o) // IN BUS [34:0]
);

UART q3(
	.PCLK(clk),
	.PRESETn(d[65:65]),
	.PENABLE(d[64:64]),
	.PADDR(d[63:62]),
	.PWRITE(d[61:61]),
	.PSEL(d[60:60]),	
	.PWDATA(d[59:52]),
	.PRDATA(o[33:26]),
	.TX(TX),
	.RX(RX),
	.RTS(o[25:25]),
	.CTS(d[51:51]),
	.DTR(o[24:24]),	
	.DSR(d[50:50]),
	.DCD(d[49:49]),
	.RI(d[48:48]),
	.DLR(d[47:32]),
	.IER(d[31:24]),
	.LCR(d[23:16]),
	.FCR(d[15:8]),
	.IIR(o[23:16]),
	.LSR(o[15:8]),
	.MCR(d[7:0]),
	.MSR(o[7:0])
	);
	
endmodule

