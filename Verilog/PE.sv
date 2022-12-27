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
    output signed [`IA_DATA_BITWIDTH-1:0]    o_output_feature        [0:`IA_ROW*`IA_CHANNEL-1]
);

localparam S_IDLE = 0;
localparam S_PREPROCESS = 1;
localparam S_ENC_MAC = 2;

logic [1:0] state_r, state_w;

// output
logic finish_r, finish_w;
logic signed [`IA_DATA_BITWIDTH-1:0] output_feature_r[0:`IA_ROW*`IA_CHANNEL-1], output_feature_w[0:`IA_ROW*`IA_CHANNEL-1];

// Submodule



endmodule