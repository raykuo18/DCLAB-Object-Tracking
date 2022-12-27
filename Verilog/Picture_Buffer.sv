module Picture_Buffer(
    input i_clk,
    input i_rst_n,
    input [9:0] i_R,
    input [9:0] i_G,
    input [9:0] i_B,
    input i_take,
	input i_fetch,
	output o_oktofetch,
	output [9:0] o_buf[0:2][0:15][0:15]
);

localparam S_IDLE = 2'd0;
localparam S_BUF1 = 2'd1;
localparam S_BUF2 = 2'd2;

logic [1:0] state_w, state_r;
logic [9:0] buf1_r[0:2][0:15][0:15], buf1_w[0:2][0:15][0:15], buf2_r[0:2][0:15][0:15], buf2_w[0:2][0:15][0:15];
logic [3:0] H_counter_r, H_counter_w, V_counter_r, V_counter_w;
logic buf_select;
logic buf1_full_w, buf1_full_r, buf2_full_w, buf2_full_r;

assign buf_select = (buf1_full_r==0 && buf2_full_r==1) ? 1'b1: 1'b0;
assign o_oktofetch = (buf1_full_r | buf2_full_r);
assign o_buf = (buf_select) ? buf2_r: buf1_r;

// ===== Combinational Blocks =====
always_comb begin // state
	case(state_r)
		S_IDLE: state_w = S_BUF1;
		S_BUF1: state_w = (buf1_full_w) ? S_BUF2: state_r;
		S_BUF2: state_w = (!buf1_full_r && buf2_full_w) ? S_BUF1: state_r;
		default: state_w = state_r;
	endcase
end
always_comb begin // H counter
	case(state_r)
		S_BUF1: begin
			if(!buf1_full_r) H_counter_w = (H_counter_r <= 15 && i_take == 1)? H_counter_r +1: H_counter_r;
			else H_counter_w = 4'd0;
		end
		S_BUF2: begin
			if(!buf2_full_r) H_counter_w = (H_counter_r <= 15 && i_take == 1)? H_counter_r +1: H_counter_r;
			else H_counter_w = 4'd0;
		end
		default: H_counter_w = H_counter_r;
	endcase
end
always_comb begin // V counter
	case(state_r)
		S_BUF1: begin
			if(!buf1_full_r)  V_counter_w = (V_counter_r < 15 && i_take == 1 && H_counter_r == 15)? V_counter_r +1: V_counter_r;
			else V_counter_w = 4'd0;
		end
		S_BUF2: begin
			if(!buf1_full_r)  V_counter_w = (V_counter_r < 15 && i_take == 1 && H_counter_r == 15)? V_counter_r +1: V_counter_r;
			else V_counter_w = 4'd0;
		end
		default: V_counter_w = V_counter_r;
	endcase
end
always_comb begin // buf1_full
	case(state_r)
		S_IDLE: buf1_full_w = 1'd0;
		S_BUF1: buf1_full_w = (H_counter_r==4'd15 && V_counter_r==4'd15)? 1'b1: 1'b0;
		S_BUF2: buf1_full_w = (i_fetch ==1 && buf_select == 0)? 1'd0: buf1_full_r;
		default: buf1_full_w = buf1_full_r;
	endcase
end
always_comb begin // buf2_full
	case(state_r)
		S_IDLE: buf2_full_w = 1'd0;
		S_BUF2: buf2_full_w = (H_counter_r==4'd15 && V_counter_r==4'd15)? 1'b1: 1'b0;
		S_BUF1: buf2_full_w = (i_fetch ==1 && buf_select == 1)? 1'd0: buf2_full_r;
		default: buf2_full_w = buf2_full_r;
	endcase
end
always_comb begin // buf1
	case(state_r)
		S_BUF1: begin
			buf1_w[0][V_counter_r][H_counter_r] = i_R;
            buf1_w[1][V_counter_r][H_counter_r] = i_G;
            buf1_w[2][V_counter_r][H_counter_r] = i_B;
		end
		default: buf1_w = buf1_r;
	endcase
end
always_comb begin // buf2
	case(state_r)
		S_BUF2: begin
			buf2_w[0][V_counter_r][H_counter_r] = i_R;
            buf2_w[1][V_counter_r][H_counter_r] = i_G;
            buf2_w[2][V_counter_r][H_counter_r] = i_B;
		end
		default: buf2_w = buf2_r;
	endcase
end

// ===== Sequential Block =====
integer i,j;
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		state_r 	<= S_IDLE;
		H_counter_r <= 4'd0;
		V_counter_r <= 4'd0;
		buf1_full_r <= 1'd0;
		buf2_full_r <= 1'd0;
		for(i=0; i<16; i=i+1) begin
			for(j=0; j<16; j=j+1) begin
				buf1_r[0][i][j] <= 10'd0;
				buf1_r[1][i][j] <= 10'd0;
				buf1_r[2][i][j] <= 10'd0;
				buf2_r[0][i][j] <= 10'd0;
				buf2_r[1][i][j] <= 10'd0;
				buf2_r[2][i][j] <= 10'd0;
			end
		end
	end
	else begin
		state_r 	<= state_w;
		H_counter_r <= H_counter_w;
		V_counter_r <= V_counter_w;
		buf1_full_r <= buf1_full_w;
		buf2_full_r <= buf2_full_w;
		buf1_r 		<= buf1_w;
		buf2_r 		<= buf2_w;
	end
end

endmodule