`include "header.h"

module PE_TEMP(
    input        i_clk,
	input        i_rst_n,
	input        i_start,
    // IA bundle
    input        [$clog2(`IA_ROW):0]       i_ia_h,
    input        [$clog2(`IA_COL):0]       i_ia_w,
    input signed [`IA_DATA_BITWIDTH-1:0]     i_ia_data   [0:`IA_CHANNEL-1],
    input        [`IA_C_BITWIDTH-1:0]        i_ia_c_idx  [0:`IA_CHANNEL-1],
    input        [$clog2(`IA_CHANNEL):0]   i_ia_iters, // ---------------------- need discussion -> 0
    input        [$clog2(`IA_CHANNEL):0]   i_ia_len,
    // W bundle
    input        [1:0]                       i_w_s,
    input signed [`W_DATA_BITWIDTH-1:0]      i_w_data    [0:`W_C_LENGTH-1],
    input        [`W_C_BITWIDTH-1:0]         i_w_c_idx   [0:`W_C_LENGTH-1],
    input        [`W_POS_PTR_BITWIDTH-1:0]   i_pos_ptr   [0:`W_R_LENGTH-1],
    input        [`W_R_BITWIDTH-1:0]         i_r_idx     [0:`W_R_LENGTH-1],
    input        [`W_K_BITWIDTH-1:0]         i_k_idx     [0:`W_R_LENGTH-1],
    input        [$clog2(`W_C_LENGTH):0]   i_w_iters,  // ---------------------- need discussion -> ceil(w_len/32)
    input        [$clog2(`W_C_LENGTH):0]   i_w_len,
    // Output
    output logic                                   o_finish,
    output logic signed [`IA_DATA_BITWIDTH-1:0]    o_output_feature        [0:3*`IA_CHANNEL-1]
   
);

// ===== Parameters definition ===== 
localparam S_IDLE   = 0;
localparam S_PROC   = 1;
localparam S_FINISH = 2;
localparam S_END = 3;


// ===== Output logic ===== 
logic                                   o_finish_n;
logic signed [`IA_DATA_BITWIDTH-1:0]    o_output_feature_n         [0:3*`IA_CHANNEL-1];















// ===== logic ===== 
logic [2:0] state, state_n;

// ===== Combinational logic ===== 
always_comb begin 
    state_n    = state;
    o_finish_n = o_finish;

    for (int k=0; k < 3*`IA_CHANNEL; k++ ) o_output_feature_n[k] = o_output_feature[k];

   

    
    
    if (i_start) state_n = S_IDLE;
    else begin
        case(state)
            S_IDLE: begin
                o_finish_n = 0;
                state_n = S_PROC;

            end
            S_PROC: begin
                o_finish_n = 0;
                state_n = S_FINISH;
            end
            S_FINISH: begin
                o_finish_n = 1;
                state_n = S_IDLE;
                // if (!i_start) state_n = S_IDLE;
            end
            // S_END: begin
            //     o_finish_n = 0;
            //     state_n = S_END;
            //     // if (!i_start) state_n = S_IDLE;
            // end

        endcase
    end
end



// ===== Sequential logic ===== 
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
        state    <= S_IDLE;
        o_finish <= 0;
        for (int k=0; k < 3*`IA_CHANNEL; k++ ) o_output_feature[k] = 1;
        
	end
	else begin
		state    <= state_n;
        o_finish <= o_finish_n;
        for (int k=0; k < 3*`IA_CHANNEL; k++ ) o_output_feature[k] <= o_output_feature_n[k];
       
    end

end







endmodule