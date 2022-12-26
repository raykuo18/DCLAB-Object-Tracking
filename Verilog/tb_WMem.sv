`timescale 1us/1us


`define W_DATA_BITWIDTH    16
`define W_C_BITWIDTH       5   // log2(# Channel)
`define W_R_BITWIDTH       2 
`define W_K_BITWIDTH       5 
`define W_POS_PTR_BITWIDTH 11 
// `define W_S_BITWIDTH       2  
// `define W_ITERS_BITWIDTH   6 


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



module tb_WMem;
	localparam CLK = 10;
	localparam HCLK = CLK/2;

	logic rst, clk;
	initial clk = 0;
	always #HCLK clk = ~clk;

    // w_data
        logic signed [`W_DATA_BITWIDTH-1 :0] o_w_data_l1_s0 [0:`W_C_LENGTH_L1_S0-1];
        logic signed [`W_DATA_BITWIDTH-1 :0] o_w_data_l1_s1 [0:`W_C_LENGTH_L1_S1-1];
        logic signed [`W_DATA_BITWIDTH-1 :0] o_w_data_l1_s2 [0:`W_C_LENGTH_L1_S2-1];
        logic signed [`W_DATA_BITWIDTH-1 :0] o_w_data_l2_s0 [0:`W_C_LENGTH_L2_S0-1];
        logic signed [`W_DATA_BITWIDTH-1 :0] o_w_data_l2_s1 [0:`W_C_LENGTH_L2_S1-1];
        logic signed [`W_DATA_BITWIDTH-1 :0] o_w_data_l2_s2 [0:`W_C_LENGTH_L2_S2-1];


    // w_c_idx
        logic [`W_C_BITWIDTH-1 :0] o_w_c_idx_l1_s0 [0:`W_C_LENGTH_L1_S0-1];
        logic [`W_C_BITWIDTH-1 :0] o_w_c_idx_l1_s1 [0:`W_C_LENGTH_L1_S1-1];
        logic [`W_C_BITWIDTH-1 :0] o_w_c_idx_l1_s2 [0:`W_C_LENGTH_L1_S2-1];
        logic [`W_C_BITWIDTH-1 :0] o_w_c_idx_l2_s0 [0:`W_C_LENGTH_L2_S0-1];
        logic [`W_C_BITWIDTH-1 :0] o_w_c_idx_l2_s1 [0:`W_C_LENGTH_L2_S1-1];
        logic [`W_C_BITWIDTH-1 :0] o_w_c_idx_l2_s2 [0:`W_C_LENGTH_L2_S2-1];


    // w_r_idx
        logic [`W_R_BITWIDTH-1 :0] o_w_r_idx_l1_s0 [0:`W_R_LENGTH_L1_S0-1];
        logic [`W_R_BITWIDTH-1 :0] o_w_r_idx_l1_s1 [0:`W_R_LENGTH_L1_S1-1];
        logic [`W_R_BITWIDTH-1 :0] o_w_r_idx_l1_s2 [0:`W_R_LENGTH_L1_S2-1];
        logic [`W_R_BITWIDTH-1 :0] o_w_r_idx_l2_s0 [0:`W_R_LENGTH_L2_S0-1];
        logic [`W_R_BITWIDTH-1 :0] o_w_r_idx_l2_s1 [0:`W_R_LENGTH_L2_S1-1];
        logic [`W_R_BITWIDTH-1 :0] o_w_r_idx_l2_s2 [0:`W_R_LENGTH_L2_S2-1];
        

    //  w_k-idx
        logic [`W_K_BITWIDTH-1 :0] o_w_k_idx_l1_s0 [0:`W_R_LENGTH_L1_S0-1];
        logic [`W_K_BITWIDTH-1 :0] o_w_k_idx_l1_s1 [0:`W_R_LENGTH_L1_S1-1];
        logic [`W_K_BITWIDTH-1 :0] o_w_k_idx_l1_s2 [0:`W_R_LENGTH_L1_S2-1];
        logic [`W_K_BITWIDTH-1 :0] o_w_k_idx_l2_s0 [0:`W_R_LENGTH_L2_S0-1];
        logic [`W_K_BITWIDTH-1 :0] o_w_k_idx_l2_s1 [0:`W_R_LENGTH_L2_S1-1];
        logic [`W_K_BITWIDTH-1 :0] o_w_k_idx_l2_s2 [0:`W_R_LENGTH_L2_S2-1];
        

    // w_pos_ptr
        logic [`W_POS_PTR_BITWIDTH-1 :0] o_w_pos_ptr_l1_s0 [0:`W_R_LENGTH_L1_S0-1];
        logic [`W_POS_PTR_BITWIDTH-1 :0] o_w_pos_ptr_l1_s1 [0:`W_R_LENGTH_L1_S1-1];
        logic [`W_POS_PTR_BITWIDTH-1 :0] o_w_pos_ptr_l1_s2 [0:`W_R_LENGTH_L1_S2-1];
        logic [`W_POS_PTR_BITWIDTH-1 :0] o_w_pos_ptr_l2_s0 [0:`W_R_LENGTH_L2_S0-1];
        logic [`W_POS_PTR_BITWIDTH-1 :0] o_w_pos_ptr_l2_s1 [0:`W_R_LENGTH_L2_S1-1];
        logic [`W_POS_PTR_BITWIDTH-1 :0] o_w_pos_ptr_l2_s2 [0:`W_R_LENGTH_L2_S2-1];
        




	WMEM wmem0(
        .i_rst_n(rst),
		.i_clk(clk),

        // w_data
        .o_w_data_l1_s0(o_w_data_l1_s0),
        .o_w_data_l1_s1(o_w_data_l1_s1),
        .o_w_data_l1_s2(o_w_data_l1_s2),
        .o_w_data_l2_s0(o_w_data_l2_s0),
        .o_w_data_l2_s1(o_w_data_l2_s1),
        .o_w_data_l2_s2(o_w_data_l2_s2),
        
        // w_c_idx
        .o_w_c_idx_l1_s0(o_w_c_idx_l1_s0),
        .o_w_c_idx_l1_s1(o_w_c_idx_l1_s1),
        .o_w_c_idx_l1_s2(o_w_c_idx_l1_s2),
        .o_w_c_idx_l2_s0(o_w_c_idx_l2_s0),
        .o_w_c_idx_l2_s1(o_w_c_idx_l2_s1),
        .o_w_c_idx_l2_s2(o_w_c_idx_l2_s2),
        

        // w_r_idx
        .o_w_r_idx_l1_s0(o_w_r_idx_l1_s0),
        .o_w_r_idx_l1_s1(o_w_r_idx_l1_s1),
        .o_w_r_idx_l1_s2(o_w_r_idx_l1_s2),
        .o_w_r_idx_l2_s0(o_w_r_idx_l2_s0),
        .o_w_r_idx_l2_s1(o_w_r_idx_l2_s1),
        .o_w_r_idx_l2_s2(o_w_r_idx_l2_s2),
        

        // w_k_idx
        .o_w_k_idx_l1_s0(o_w_k_idx_l1_s0),
        .o_w_k_idx_l1_s1(o_w_k_idx_l1_s1),
        .o_w_k_idx_l1_s2(o_w_k_idx_l1_s2),
        .o_w_k_idx_l2_s0(o_w_k_idx_l2_s0),
        .o_w_k_idx_l2_s1(o_w_k_idx_l2_s1),
        .o_w_k_idx_l2_s2(o_w_k_idx_l2_s2),
        

        // w_pos_ptr
        .o_w_pos_ptr_l1_s0(o_w_pos_ptr_l1_s0),
        .o_w_pos_ptr_l1_s1(o_w_pos_ptr_l1_s1),
        .o_w_pos_ptr_l1_s2(o_w_pos_ptr_l1_s2),
        .o_w_pos_ptr_l2_s0(o_w_pos_ptr_l2_s0),
        .o_w_pos_ptr_l2_s1(o_w_pos_ptr_l2_s1),
        .o_w_pos_ptr_l2_s2(o_w_pos_ptr_l2_s2)
	);

	initial begin
		$fsdbDumpfile("wmem.fsdb");
		$fsdbDumpvars;
		$fsdbDumpMDA();
        // reset & start_call
		rst = 1'b0;
		#(2*CLK)
		rst = 1'b1;

		// for (int i = 0; i < 5000; i++) begin
		// 		@(posedge clk);
		// 	end
        $finish;
    end
	initial begin
		#(50000*CLK)
		$display(".A.B.O.R.T.");
		$finish;
	end

endmodule
