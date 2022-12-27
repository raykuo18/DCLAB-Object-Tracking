// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	VGA_Controller
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN Peli Li:| 22/07/2010:| Initial Revision
// --------------------------------------------------------------------

module	VGA_Controller(	//	Host Side
						iRed,
						iGreen,
						iBlue,
						oRequest,
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_H_SYNC,
						oVGA_V_SYNC,
						oVGA_SYNC,
						oVGA_BLANK,

						//	Control Signal
						iCLK,
						iRST_N,
						iZOOM_MODE_SW,
						i_itp_mode
						// for interpolation
						//o_take_data

							);
//`include "VGA_Param.h"

`ifdef VGA_640x480p60
//	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	96;
parameter	H_SYNC_BACK	=	48;
parameter	H_SYNC_ACT	=	640;	
parameter	H_SYNC_FRONT=	16;
parameter	H_SYNC_TOTAL=	800;

parameter   H_ITP_START =   128;
parameter   H_ITP_RANGE =   384;

//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	2;
parameter	V_SYNC_BACK	=	33;
parameter	V_SYNC_ACT	=	480;	
parameter	V_SYNC_FRONT=	10;
parameter	V_SYNC_TOTAL=	525;

parameter   V_ITP_START =   48;
parameter   V_ITP_RANGE =   384;

`else
    // SVGA_800x600p60
    ////	Horizontal Parameter	( Pixel )
    parameter	H_SYNC_CYC	=	128;         //Peli
    parameter	H_SYNC_BACK	=	88;
    parameter	H_SYNC_ACT	=	800;	
    parameter	H_SYNC_FRONT=	40;
    parameter	H_SYNC_TOTAL=	1056;

	parameter   H_ITP_START =   208;
	parameter   H_ITP_RANGE =   384;
    //	Virtical Parameter		( Line )
    parameter	V_SYNC_CYC	=	4;
    parameter	V_SYNC_BACK	=	23;
    parameter	V_SYNC_ACT	=	600;	
    parameter	V_SYNC_FRONT=	1;
    parameter	V_SYNC_TOTAL=	628;
	
	parameter   V_ITP_START =   108;
	parameter   V_ITP_RANGE =   384;	

`endif
//	Start Offset
parameter	X_START		=	H_SYNC_CYC+H_SYNC_BACK;
parameter	X_START2 	= 	H_SYNC_CYC+H_SYNC_BACK+H_ITP_START;
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK;
parameter	Y_START2	= 	V_SYNC_CYC+V_SYNC_BACK+V_ITP_START;
//	Host Side
input		[9:0]	iRed;
input		[9:0]	iGreen;
input		[9:0]	iBlue;
output	reg			oRequest;
//	VGA Side
output	reg	[9:0]	oVGA_R;
output	reg	[9:0]	oVGA_G;
output	reg	[9:0]	oVGA_B;
output	reg			oVGA_H_SYNC;
output	reg			oVGA_V_SYNC;
output	reg			oVGA_SYNC;
output	reg			oVGA_BLANK;

//output  reg 		o_take_data;

wire		[9:0]	mVGA_R;
wire		[9:0]	mVGA_G;
wire		[9:0]	mVGA_B;
reg					mVGA_H_SYNC;
reg					mVGA_V_SYNC;
wire				mVGA_SYNC;
wire				mVGA_BLANK;

//	Control Signal
input				iCLK;
input				iRST_N;
input 				iZOOM_MODE_SW;
input				i_itp_mode;

//	Internal Registers and Wires
reg		[12:0]		H_Cont;
reg		[12:0]		V_Cont;
reg 	[1:0] 		C_Cont;

wire	[12:0]		v_mask;

assign v_mask = 13'd0 ;//iZOOM_MODE_SW ? 13'd0 : 13'd26;

////////////////////////////////////////////////////////

assign	mVGA_BLANK	=	mVGA_H_SYNC & mVGA_V_SYNC;
assign	mVGA_SYNC	=	1'b0;


assign	mVGA_R	=	(	H_Cont>=X_START2 	&& H_Cont<X_START2+H_ITP_RANGE &&
						V_Cont>=Y_START2+v_mask 	&& V_Cont<Y_START2+V_ITP_RANGE)
						?	iRed	:	iRed>>2;
assign	mVGA_G	=	(	H_Cont>=X_START2 	&& H_Cont<X_START2+H_ITP_RANGE &&
						V_Cont>=Y_START2+v_mask 	&& V_Cont<Y_START2+V_ITP_RANGE)
						?	iGreen	:	iGreen>>2;
assign	mVGA_B	=	(	H_Cont>=X_START2 	&& H_Cont<X_START2+H_ITP_RANGE &&
						V_Cont>=Y_START2+v_mask 	&& V_Cont<Y_START2+V_ITP_RANGE)
						?	iBlue	:	iBlue>>2;
assign	mVGA_R2	=	(	H_Cont>=X_START2 	&& H_Cont<X_START2+H_ITP_RANGE &&
						V_Cont>=Y_START2+v_mask 	&& V_Cont<Y_START2+V_ITP_RANGE && C_Cont == 2'd2)
						?	iRed	:	iRed>>2;
assign	mVGA_G2	=	(	H_Cont>=X_START2 	&& H_Cont<X_START2+H_ITP_RANGE &&
						V_Cont>=Y_START2+v_mask 	&& V_Cont<Y_START2+V_ITP_RANGE && C_Cont == 2'd2)
						?	iGreen	:	iGreen>>2;
assign	mVGA_B2	=	(	H_Cont>=X_START2 	&& H_Cont<X_START2+H_ITP_RANGE &&
						V_Cont>=Y_START2+v_mask 	&& V_Cont<Y_START2+V_ITP_RANGE && C_Cont == 2'd2)
						?	iBlue	:	iBlue>>2;

always@(posedge iCLK or negedge iRST_N)
	begin
		if (!iRST_N)
			begin
				oVGA_R <= 0;
				oVGA_G <= 0;
                oVGA_B <= 0;
				oVGA_BLANK <= 0;
				oVGA_SYNC <= 0;
				oVGA_H_SYNC <= 0;
				oVGA_V_SYNC <= 0; 
			end
		else
			begin
				oVGA_R <= (i_itp_mode)? mVGA_R2: mVGA_R;
				oVGA_G <= (i_itp_mode)? mVGA_G2: mVGA_G;
                oVGA_B <= (i_itp_mode)? mVGA_B2: mVGA_B;
				oVGA_BLANK <= mVGA_BLANK;
				oVGA_SYNC <= mVGA_SYNC;
				oVGA_H_SYNC <= mVGA_H_SYNC;
				oVGA_V_SYNC <= mVGA_V_SYNC;				
			end               
	end



//	Pixel LUT Address Generator
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	oRequest	<=	0;
	else
	begin
		if(	H_Cont>=X_START-2 && H_Cont<X_START+H_SYNC_ACT-2 &&
			V_Cont>=Y_START && V_Cont<Y_START+V_SYNC_ACT )
		oRequest	<=	1;
		else
		oRequest	<=	0;
	end
end

//	H_Sync Generator, Ref. 40 MHz Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		mVGA_H_SYNC	<=	0;
	end
	else
	begin
		//	H_Sync Counter
		if( H_Cont < H_SYNC_TOTAL )
		H_Cont	<=	H_Cont+1;
		else
		H_Cont	<=	0;
		//	H_Sync Generator
		if( H_Cont < H_SYNC_CYC )
		mVGA_H_SYNC	<=	0;
		else
		mVGA_H_SYNC	<=	1;
	end
end
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N) begin
		C_Cont 		<= 0;
		o_take_data <= 0;
	end
	else begin
		if (C_Cont == 2'd2) begin
			C_Cont <= 0;
			o_take_data <= 1;
		end
		else begin
			C_Cont <= C_Cont +1;
			o_take_data <= 0;
		end
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		mVGA_V_SYNC	<=	0;
	end
	else
	begin
		//	When H_Sync Re-start
		if(H_Cont==0)
		begin
			//	V_Sync Counter
			if( V_Cont < V_SYNC_TOTAL )
			V_Cont	<=	V_Cont+1;
			else
			V_Cont	<=	0;
			//	V_Sync Generator
			if(	V_Cont < V_SYNC_CYC )
			mVGA_V_SYNC	<=	0;
			else
			mVGA_V_SYNC	<=	1;
		end
	end
end

endmodule