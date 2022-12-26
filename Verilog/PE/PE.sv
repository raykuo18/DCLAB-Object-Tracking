
`define IA_C_LENGTH 1199
`define W_C_LENGTH 1199
`define W_R_LENGTH 1199

`define IA_CHANNEL 8
`define IA_ROW 16

module PE(
    //////////////// input ////////////////
    // IA bundle
    input [6:0]                     i_ia_h,
    input [6:0]                     i_ia_w,
    input signed [15:0]             i_ia_data[0:`IA_C_LENGTH],
    input [4:0]                     i_ia_c_idx[0:`IA_C_LENGTH],
    input [5:0]                     i_ia_iters,
    input [$clog2(IA_C_LENGTH)-1:0] i_ia_len,
    // W bundle
    input [1:0]                     i_w_s,
    input signed [15:0]             i_w_data[0:`W_C_LENGTH],
    input [4:0]                     i_w_c_idx[0:`W_C_LENGTH],
    input [10:0]                    i_pos_ptr[0:`W_R_LENGTH],
    input [1:0]                     i_r_idx[0:`W_R_LENGTH],
    input [4:0]                     i_k_idx[0:`W_R_LENGTH],
    input [5:0]                     i_w_iters,
    input [$clog2(W_C_LENGTH)-1:0]  i_w_len,

    //////////////// output ////////////////
    output                          o_finish,
    output signed [16:0]            o_feature_map[0:`IA_ROW-1][0:`IA_CHANNEL-1]
);

localparam S_IDLE = 2'd0;
localparam S_AIM_AND_ADDR_COMP = 2'd1;
localparam S_ENC_AND_MAC = 2'd2;

logic [1:0]     state_r, state_w;

assign i_encode_start = (state_r == S_ENCO);
assign o_finish = finish_r;
assign o_valid = valid_r;
assign o_pos = pos_r;

// ===== Combinational Blocks ===== 
always_comb begin //IA
    case(state_r)
        S_COMP: IA_w = i_IA[(ite_counter_r << 5) +: 32];
        default: IA_w = IA_r;
    endcase
end
// ===== Sequential Blocks =====
integer s;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r         <= S_IDLE;
        ite_counter_r   <= 3'd0;
        match_r         <= 32'd0;
        finish_r        <= 1'd0;

        for(s=0; s<32; s=s+1) begin
            IA_r[s] <= 6'd0;
            map_r[s] <= 32'd0;
            valid_r[s] <= 1'd0;
            pos_r[s] <= 9'd0;
        end
    end
    else begin
        state_r         <= state_w;
        ite_counter_r   <= ite_counter_w;
        match_r         <= match_w;
        finish_r        <= finish_w;
        map_r           <= map_w;
        valid_r         <= valid_w;
        pos_r           <= pos_w;
        IA_r            <= IA_w;
    end
end

endmodule
