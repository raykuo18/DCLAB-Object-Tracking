`include "header.h"

module PE(
    input        i_clk,
	input        i_rst_n,
	input        i_start,
    // IA bundle
    input        [$clog2(`IA_ROW):0]       i_ia_h,
    input        [$clog2(`IA_COL):0]       i_ia_w,
    input signed [`IA_DATA_BITWIDTH-1:0]   i_ia_data   [0:`IA_CHANNEL-1],
    input        [`IA_C_BITWIDTH-1:0]      i_ia_c_idx  [0:`IA_CHANNEL-1],
    input        [$clog2(`IA_CHANNEL):0]   i_ia_iters, // ---------------------- need discussion -> 0
    input        [$clog2(`IA_CHANNEL):0]   i_ia_len,
    // W bundle
    input        [1:0]                     i_w_s,
    input signed [`W_DATA_BITWIDTH-1:0]    i_w_data    [0:`W_C_LENGTH-1],
    input        [`W_C_BITWIDTH-1:0]       i_w_c_idx   [0:`W_C_LENGTH-1],
    input        [`W_POS_PTR_BITWIDTH-1:0] i_pos_ptr   [0:`W_R_LENGTH-1],
    input        [`W_R_BITWIDTH-1:0]       i_r_idx     [0:`W_R_LENGTH-1],
    input        [`W_K_BITWIDTH-1:0]       i_k_idx     [0:`W_R_LENGTH-1],
    input        [$clog2(`W_C_LENGTH):0]   i_w_iters,  // ---------------------- need discussion -> ceil(w_len/32)
    input        [$clog2(`W_C_LENGTH):0]   i_w_len,

    // Output
    output                                   o_finish,
    output signed [`IA_DATA_BITWIDTH-1:0]    o_output_feature        [0:3*`IA_CHANNEL-1]
);

localparam S_IDLE = 0;
localparam S_PREPROCESS = 1;
localparam S_ENC_MAC = 2;

logic [1:0] state_r, state_w;

// output
logic finish_r, finish_w;
logic signed [`IA_DATA_BITWIDTH-1:0] output_feature_r[0:3*`IA_CHANNEL-1], output_feature_w[0:3*`IA_CHANNEL-1];

//////////////////// Submodule ////////////////////
// Addr RF
logic addr_to_rf_finish, addr_to_rf_finish_w;
logic [2:0][6:0] addr_buf[0:`W_C_LENGTH-1];

AddrToRF addr_to_rf(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(i_start),
    .i_h(i_ia_h),
    .i_w(i_ia_w),
    .i_s(i_w_s),
    .i_r(i_r_idx),
    .i_k(i_k_idx),
    .i_ptr(i_pos_ptr),
    .i_length(i_w_len),
    .o_finish(addr_to_rf_finish_r),
    .o_RF(addr_buf)
);

// AIM
logic aim_start_r, aim_start_w;
// logic signed [15:0] aim_w_c_input_r[0:31], aim_w_c_input_w[0:31]
logic aim_finish;
logic aim_valids[0:31];
logic [8:0] aim_poses[0:31];
logic aim_w_c_input;

AIM aim(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(aim_start_r),
    .i_ite(i_ia_iters), // DO SUBTRACT 1, ex, run 2 iteration -> i_ite = 1
    .i_word(aim_w_c_input), // weight channel idx // dynamic assignment
    .i_IA(i_ia_c_idx), // 8*32 = 256
    .o_finish(aim_finish),
    .o_valid(aim_valids), ///////////// need to be stored or modified
    .o_pos(aim_poses)    ///////////// need to be stored or modified
);

// VPEncoder
logic vp_enc_start_r, vp_enc_start_r_w;
logic left_ready, right_ready;
logic [2:0][6:0] addr_right_buffer[0:2], addr_left_buffer[0:2];
logic signed [15:0] w_data_right_buffer[0:2], w_data_left_buffer[0:2];
logic signed [15:0] ia_data_right_buffer[0:2], ia_data_left_buffer[0:2];
logic vp_encoder_finish;

VPEncoder vp_encoder(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(vp_enc_start_r),
    .i_addr_buf(addr_buf),
    .i_valid_buf(),////////////////
    .i_pos_buf(),////////////////
    .i_ia_data(i_ia_data),
    .i_w_data(i_w_data),
    .i_w_len(i_w_len),
    .o_left_ready(left_ready),
    .o_right_ready(right_ready),
    .o_addr_right_buffer(addr_right_buffer),
    .o_w_data_right_buffer(w_data_right_buffer),
    .o_ia_data_right_buffer(ia_data_right_buffer),
    .o_addr_left_buffer(addr_left_buffer),
    .o_w_data_left_buffer(w_data_left_buffer),
    .o_ia_data_left_buffer(ia_data_left_buffer),
    .o_finish(vp_encoder_finish)     
);

// PE Reducer
logic pe_reducer_start_r, pe_reducer_start_w;
logic [2:0][6:0] pe_reducer_addr_input[0:2];
logic [15:0] w_data_input[0:2], ia_data_input[0:2];
logic [35:0] output_feature[0:`IA_ROW*`IA_CHANNEL-1];
logic pe_reducer_finish;

PEReducer pe_reducer(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(pe_reducer_start_r),
    .i_addr(pe_reducer_addr_input),
    .i_w(w_data_input),
    .i_ia(ia_data_input),
    .o_buf(output_feature),
    .o_finish(pe_reducer_finish)
);
assign o_output_feature = output_feature;

always_comb begin
    
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        finish_r        <= 0;
    end
    else begin
    end
end

endmodule