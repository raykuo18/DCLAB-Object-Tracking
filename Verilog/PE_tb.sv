`timescale 1ns/1ns
`include "header.h"
module tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst, start_cal;
	initial clk = 0;
	always #HCLK clk = ~clk;

    logic           [$clog2(`IA_ROW):0]        ia_h;
    logic           [$clog2(`IA_COL):0]        ia_w;
    logic signed    [`IA_DATA_BITWIDTH-1:0]    ia_data     [0:`IA_CHANNEL-1];
    logic           [`IA_C_BITWIDTH-1:0]       ia_c        [0:`IA_CHANNEL-1];
    logic           [$clog2(`IA_CHANNEL):0]    ia_ite;
    logic           [$clog2(`IA_CHANNEL):0]    ia_len;
    // W bundle
    logic           [1:0]                      s;
    logic signed    [`W_DATA_BITWIDTH-1:0]     w_data      [0:`W_C_LENGTH-1];
    logic           [`W_C_BITWIDTH-1:0]        w_c         [0:`W_C_LENGTH-1];
    logic           [`W_POS_PTR_BITWIDTH-1:0]  ptr         [0:`W_R_LENGTH-1];
    logic           [`W_R_BITWIDTH-1:0]        r           [0:`W_R_LENGTH-1];
    logic           [`W_K_BITWIDTH-1:0]        k           [0:`W_R_LENGTH-1];
    logic           [$clog2(`W_C_LENGTH):0]    w_ite;
    logic           [$clog2(`W_C_LENGTH):0]    w_len;

    // Output
    logic                                      finish;
    logic signed    [`IA_DATA_BITWIDTH-1:0]    out        [0:3*`IA_CHANNEL-1];

    // ===== assign value =====
    assign ia_h = 4;
    assign ia_w = 4;
    assign ia_ite = 2;
    assign ia_len = 2;
    assign w_ite = 2;
    assign w_len = 4;
    assign s = 1;

    integer i, j, p;
    always_comb begin
    for(i=0; i<`IA_CHANNEL; i=i+1) begin
         ia_data[i] = i+1;
         ia_c[i] = i+2;
    end
    for(j=0; j<`W_C_LENGTH; j=j+1) begin
         w_data[j] = j+4;
         w_c[j] = j+5;
    end
    for(p=0; p<`W_R_LENGTH; p=p+1) begin
         r[p] = p[1:0];
         k[p] = p>>2;
         ptr[p] = p+3;
    end
    end


	PE pe_tb(
		.i_clk(clk),
		.i_rst_n(rst),
		.i_start(start_cal),
        .i_ia_h(ia_h),
        .i_ia_w(ia_w),
        .i_ia_data(ia_data),
        .i_ia_c_idx(ia_c),
        .i_ia_iters(ia_ite),
        .i_ia_len(ia_len),
        .i_w_s(s),
        .i_w_data(w_data),
        .i_w_c_idx(w_c),
        .i_pos_ptr(ptr),
        .i_r_idx(r),
        .i_k_idx(k),
        .i_w_iters(w_ite),
        .i_w_len(w_len),
        .o_finish(finish),
        .o_output_feature(out)
	);


	initial begin 
		rst = 1'b1;
		start_cal = 1'b0;
		#10 begin
			rst = 1'b0;
		end
        #10 begin
			rst = 1'b1;
		end
        #15 begin
            start_cal = 1'b1;
        end
        #10 begin
            start_cal = 1'b0;
        end

	end


	initial begin
		$fsdbDumpfile("pe.fsdb");
		$fsdbDumpvars;
        $fsdbDumpMDA();
		
		for (int i = 0; i < 150; i++) begin
			@(posedge clk);
		end
		$finish;
	end

endmodule
