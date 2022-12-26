// --------------------- `define for WMem ------------------------
    `define W_DATA_BITWIDTH    16
    `define W_C_BITWIDTH       5   // log2(# Channel)
    `define W_R_BITWIDTH       2 
    `define W_K_BITWIDTH       5 
    `define W_POS_PTR_BITWIDTH 11 

    `define W_C_LENGTH_L1_S0  123
    `define W_R_LENGTH_L1_S0  48
    `define W_C_LENGTH_L1_S1  130
    `define W_R_LENGTH_L1_S1  48
    `define W_C_LENGTH_L1_S2  124
    `define W_R_LENGTH_L1_S2  48

    `define W_C_LENGTH_L2_S0  474
    `define W_R_LENGTH_L2_S0  48
    `define W_C_LENGTH_L2_S1  460
    `define W_R_LENGTH_L2_S1  48
    `define W_C_LENGTH_L2_S2  446
    `define W_R_LENGTH_L2_S2  48

    `define W_C_LENGTH        474 // max of C_LENGTH
    `define W_R_LENGTH        48  // max of R_LENGTH


// --------------------- `define for IA ------------------------
    `define IA_DATA_BITWIDTH    16
    `define IA_C_BITWIDTH       5   // log2(# Channel)
    `define IA_CHANNEL 8
    `define IA_ROW 16
    `define IA_COL 16

module PE_TEMP(
    input        i_clk,
	input        i_rst_n,
	input        i_start,
    // IA bundle
    input        [$clog2(`IA_ROW)-1:0]       i_ia_h,
    input        [$clog2(`IA_COL)-1:0]       i_ia_w,
    input signed [`IA_DATA_BITWIDTH-1:0]     i_ia_data   [0:`IA_CHANNEL-1],
    input        [`IA_C_BITWIDTH-1:0]        i_ia_c_idx  [0:`IA_CHANNEL-1],
    input        [$clog2(`IA_CHANNEL)-1:0]   i_ia_iters, // ---------------------- need discussion
    // W bundle
    input        [1:0]                       i_w_s,
    input signed [`W_DATA_BITWIDTH-1:0]      i_w_data    [0:`W_C_LENGTH-1],
    input        [`W_C_BITWIDTH-1:0]         i_w_c_idx   [0:`W_C_LENGTH-1],
    input        [`W_POS_PTR_BITWIDTH-1:0]   i_pos_ptr   [0:`W_R_LENGTH-1],
    input        [`W_R_BITWIDTH-1:0]         i_r_idx     [0:`W_R_LENGTH-1],
    input        [`W_K_BITWIDTH-1:0]         i_k_idx     [0:`W_R_LENGTH-1],
    input        [$clog2(`W_C_LENGTH)-1:0]   i_w_iters,  // ---------------------- need discussion

    // Output
    output logic                                   o_finish,
    output logic signed [`IA_DATA_BITWIDTH-1:0]    o_OA        [0:`IA_ROW-1][0:`IA_CHANNEL-1]
);

// ===== Parameters definition ===== 
localparam S_IDLE   = 0;
localparam S_PROC   = 1;
localparam S_FINISH = 2;


// ===== Output logic ===== 
logic                                   o_finish_n;
logic signed [`IA_DATA_BITWIDTH-1:0]    o_OA_n        [0:`IA_ROW-1][0:`IA_CHANNEL-1];


// ===== logic ===== 
logic [2:0] state, state_n;

// ===== Combinational logic ===== 
always_comb begin 
    state_n    = state;
    o_finish_n = o_finish;

    for (int r=0; r < `IA_ROW; r++ ) begin
        for (int ch=0; ch < `IA_CHANNEL; ch++ ) begin
            o_OA_n[r][ch] = o_OA[r][ch];
        end
    end

    case(state)
        S_IDLE: begin
            if (i_start) state_n = S_PROC;
        end
        S_PROC: begin
            state_n = S_FINISH;
        end
        S_FINISH: begin
            o_finish_n = 1;
            if (!i_start) state_n = S_IDLE;
        end
    endcase
end



// ===== Sequential logic ===== 
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
        state    <= S_IDLE;
        o_finish <= 0;
        for (int r=0; r < `IA_ROW; r++ ) begin
            for (int ch=0; ch < `IA_CHANNEL; ch++ ) begin
                o_OA[r][ch] = 0;
            end
        end	
	end
	else begin
		state    <= state_n;
        o_finish <= o_finish_n;
        for (int r=0; r < `IA_ROW; r++ ) begin
            for (int ch=0; ch < `IA_CHANNEL; ch++ ) begin
                o_OA[r][ch] = o_OA_n[r][ch];
            end
        end
    end

end







endmodule