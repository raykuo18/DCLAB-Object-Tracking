

module	IAInterpolation(
						i_clk,
						i_rst_n,
						i_start,
						i_Red,
						i_Green,
						i_Blue,
                        o_read_request,
						o_finish,
						o_Red,
						o_Green,
						o_Blue
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
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK;
parameter	X_START2	=	H_SYNC_CYC+H_SYNC_BACK+H_ITP_START;
parameter	Y_START2	=	V_SYNC_CYC+V_SYNC_BACK+V_ITP_START;

input		[9:0]	i_Red;
input		[9:0]	i_Green;
input		[9:0]	i_Blue;
input				i_clk;
input				i_rst_n;
input				i_start;
output				o_read_request;
output 		[9:0]	o_Red, o_Green, o_Blue;
output 				o_finish;

parameter S_IDLE = 1'b0;
parameter S_CONT = 1'b1;
reg state_r, state_w;
reg [9:0] R_r, R_w, G_r, G_w, B_r, B_w;
reg read_request_r, read_request_w, finish_r, finish_w;
reg [12:0] H_counter_r, H_counter_w, V_counter_r, V_counter_w;
reg [1:0] C_counter_r, C_counter_w;

integer i;
// ===== Output Buffers =====
assign o_finish = finish_r;
assign o_read_request = read_request_r;
assign o_Red = R_r;
assign o_Green = G_r;
assign o_Blue = B_r;

// ===== Combinational Blocks =====
always@(*) begin // state
	case(state_r)
		S_IDLE: state_w = (i_start) ? S_CONT: state_r;
		S_CONT: state_w = (finish_r) ? S_IDLE: state_r; //***
		default: state_w = state_r;
	endcase
end
always@(*) begin // H_counter
	case(state_r)
		S_IDLE: H_counter_w = 13'd0;
		S_CONT: H_counter_w = (H_counter_r < H_SYNC_TOTAL) ? H_counter_r + 1: 13'd0;
		default: H_counter_w = H_counter_r;
	endcase
end
always@(*) begin // V_counter
	case(state_r)
		S_IDLE: V_counter_w = 13'd0;
		S_CONT: begin
			if(H_counter_r == 13'd0) V_counter_w = (V_counter_r < V_SYNC_TOTAL) ? V_counter_r +1: V_counter_r;
			else V_counter_w = V_counter_r;
		end
		default: V_counter_w = V_counter_r;
	endcase
end
always@(*) begin //finish
	case(state_r)
		S_IDLE: finish_w = 1'd0;
		S_CONT: finish_w = (V_counter_r == V_SYNC_TOTAL && H_counter_r == H_SYNC_TOTAL) ? 1'd1: 1'd0;
		default: finish_w = finish_r;
	endcase
end
always@(*) begin // C_counter
	case(state_r)
		S_IDLE: C_counter_w = 2'd0;
		S_CONT: begin
			if(H_counter_r>=X_START2 && H_counter_r<X_START2+H_ITP_RANGE &&
			V_counter_r>=Y_START2 	&& V_counter_r<Y_START2+V_ITP_RANGE) begin
				C_counter_w = (C_counter_r == 2'd2) ? 2'd0: C_counter_r +1;
			end
			else C_counter_w = C_counter_r;
		end
		default: C_counter_w = C_counter_r;
	endcase
end
always@(*) begin // read_request
	case(state_r)
		S_IDLE: read_request_w = 1'd0;
		S_CONT: begin
			if(H_counter_r>=X_START-2 && H_counter_r<X_START+H_SYNC_ACT-2 &&
			V_counter_r>=Y_START && V_counter_r<Y_START+V_SYNC_ACT ) read_request_w = 1'd1;
			else read_request_w = 1'd0;
		end
		default: read_request_w = read_request_r;
	endcase
end
always@(*) begin // R, G, B
	case(state_r)
		S_IDLE: begin
			R_w = 10'd0;
			G_w = 10'd0;
			B_w = 10'd0;
		end
		S_CONT: begin
			if(H_counter_r>=X_START2 && H_counter_r<X_START2+H_ITP_RANGE &&
			V_counter_r>=Y_START2 	&& V_counter_r<Y_START2+V_ITP_RANGE && C_counter_r == 2'd2) begin
				R_w = i_Red;
				G_w = i_Green;
				B_w = i_Blue;
			end
			else begin
				R_w = 10'd0;
				G_w = 10'd0;
				B_w = 10'd0;
			end
		end
		default: begin
			R_w = R_r;
			G_w = G_r;
			B_w = B_r;
		end
	endcase
end

// ===== Sequential Blocks =====
always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		state_r 		<= S_IDLE;
		R_r 			<= 10'd0;
		G_r 			<= 10'd0;
		B_r 			<= 10'd0;
		read_request_r 	<= 1'd0;
		finish_r 		<= 1'd0;
		H_counter_r 	<= 13'd0;
		V_counter_r 	<= 13'd0;
		C_counter_r 	<= 2'd0;
	end
	else begin
		state_r 		<= state_w;
		R_r 			<= R_w;
		G_r 			<= G_w;
		B_r 			<= B_w;
		read_request_r 	<= read_request_w;
		finish_r 		<= finish_w;
		H_counter_r 	<= H_counter_w;
		V_counter_r 	<= V_counter_w;
		C_counter_r 	<= C_counter_w;
	end
end

endmodule