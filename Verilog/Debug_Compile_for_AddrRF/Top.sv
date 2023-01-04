`include "header.h"


module Top(
	input              i_clk,
	input              i_rst_n,
	input              i_start,
    input              i_start_2,
	output logic [3:0] o_random_out,
    output logic [3:0] o_random_out_2
);

	// ========================== Output Logic ============================================
        logic  [3:0] o_random_out_n;
        logic  [3:0] o_random_out_2_n;

    // ========================== Logic (Wire) =============================================

		logic [$clog2(`IA_ROW):0] 		i_h, 						i_w;
		logic [`W_R_BITWIDTH-1:0] 		i_r		[0:`W_R_LENGTH-1]; 
		logic [1:0] 					i_s;
		logic [`W_K_BITWIDTH-1:0] 		i_k		[0:`W_R_LENGTH-1];
		logic [`W_POS_PTR_BITWIDTH-1:0] i_ptr	[0:`W_R_LENGTH-1];
		logic [$clog2(`W_C_LENGTH):0] 	length;
		logic 							finish;
		logic [2:0][6:0] 				RF		[0:`W_C_LENGTH-1];

		AddrToRF addr_rf(
			.i_clk(i_clk),
			.i_rst_n(i_rst_n),
			.i_start(i_start),
			.i_h(i_h),
			.i_w(i_w),
			.i_r(i_r),
			.i_k(i_k),
			.i_s(i_s),
			.i_ptr(i_ptr),
			.i_length(length),
			.o_finish(finish),
			.o_RF(RF)
		);

		always_comb begin 
			i_h 	= 10;
			i_w 	= 11;
			i_s 	= 1;
			length 	= 474;

			for(int i=0; i<`W_R_LENGTH; i++) begin
				i_r[i] = i[0];
				i_k[i] = i[2:0];
				i_ptr[i] = 3*i;
			end


		end
    // ========================== Sequential Circuit ========================================
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n) begin
				o_random_out   <= 0;
				o_random_out_2 <= 0;
			end

			else begin
				o_random_out   <= o_random_out_n;
				o_random_out_2 <= o_random_out_2_n;
			end
		end









endmodule
