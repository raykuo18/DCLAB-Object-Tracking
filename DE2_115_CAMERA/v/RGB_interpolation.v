// Interpolation: size = 640*480
// Step1: take the middle 384*384
// Step2: take one point in every 3 points

module	VGA_Controller(
						i_Red,
						i_Green,
						i_Blue,
                        o_read_request,
						o_finish,
						o_itp_R,
						o_itp_G,
						o_itp_B,
						oVGA_H_SYNC,
						oVGA_V_SYNC,
						oVGA_SYNC,
						oVGA_BLANK,

						//	Control Signal
						i_clk,
						i_rst_n
							);
`include "VGA_Param.h"

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
    //	Virtical Parameter		( Line )
    parameter	V_SYNC_CYC	=	4;
    parameter	V_SYNC_BACK	=	23;
    parameter	V_SYNC_ACT	=	600;	
    parameter	V_SYNC_FRONT=	1;
    parameter	V_SYNC_TOTAL=	628;

`endif
//	Start Offset
parameter	X_START		=	H_SYNC_CYC+H_SYNC_BACK+H_ITP_START;
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK+V_ITP_START;
//	Host Side
input		[9:0]	i_Red;
input		[9:0]	i_Green;
input		[9:0]	i_Blue;
output	reg			o_read_request;
//	VGA Side
output	reg	[9:0]	o_itp_R;
output	reg	[9:0]	o_itp_G;
output	reg	[9:0]	o_itp_B;
output	reg			oVGA_H_SYNC;
output	reg			oVGA_V_SYNC;
output	reg			oVGA_SYNC;
output	reg			oVGA_BLANK;

wire		[9:0]	mVGA_R;
wire		[9:0]	mVGA_G;
wire		[9:0]	mVGA_B;
reg					mVGA_H_SYNC;
reg					mVGA_V_SYNC;
wire				mVGA_SYNC;
wire				mVGA_BLANK;

reg         [9:0]   tendor_out[0:49151]; //49151 = 128*128*3-1

//	Control Signal
input				i_clk;
input				i_rst_n;

//	Internal Registers and Wires
reg		[12:0]		H_Cont;
reg		[12:0]		V_Cont;

////////////////////////////////////////////////////////

assign	mVGA_BLANK	=	mVGA_H_SYNC & mVGA_V_SYNC;
assign	mVGA_SYNC	=	1'b0;

assign	mVGA_R	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_ITP_RANGE &&
						V_Cont>=Y_START 	&& V_Cont<Y_START+V_ITP_RANGE )
						?	i_Red	:	0;
assign	mVGA_G	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_ITP_RANGE &&
						V_Cont>=Y_START 	&& V_Cont<Y_START+V_ITP_RANGE )
						?	i_Green	:	0;
assign	mVGA_B	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_ITP_RANGE &&
						V_Cont>=Y_START 	&& V_Cont<Y_START+V_ITP_RANGE )
						?	i_Blue	:	0;

always@(posedge i_clk or negedge i_rst_n)
	begin
		if (!i_rst_n)
			begin
				o_itp_R <= 0;
				o_itp_G <= 0;
                o_itp_B <= 0;
				oVGA_BLANK <= 0;
				oVGA_SYNC <= 0;
				oVGA_H_SYNC <= 0;
				oVGA_V_SYNC <= 0; 
			end
		else
			begin
				o_itp_R <= mVGA_R;
				o_itp_G <= mVGA_G;
                o_itp_B <= mVGA_B;
				oVGA_BLANK <= mVGA_BLANK;
				oVGA_SYNC <= mVGA_SYNC;
				oVGA_H_SYNC <= mVGA_H_SYNC;
				oVGA_V_SYNC <= mVGA_V_SYNC;				
			end               
	end
//	Pixel LUT Address Generator
always@(posedge i_clk or negedge i_rst_n)
begin
	if(!i_rst_n)
	o_read_request	<=	0;
	else
	begin
		if(	H_Cont>=X_START-2 && H_Cont<X_START+H_ITP_RANGE-2 &&
			V_Cont>=Y_START && V_Cont<Y_START+V_ITP_RANGE )
		o_read_request	<=	1;
		else
		o_read_request	<=	0;
	end
end

//	H_Sync Generator, Ref. 40 MHz Clock
always@(posedge i_clk or negedge i_rst_n)
begin
	if(!i_rst_n)
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

//	V_Sync Generator, Ref. H_Sync
always@(posedge i_clk or negedge i_rst_n)
begin
	if(!i_rst_n)
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