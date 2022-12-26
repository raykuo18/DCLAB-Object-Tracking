`timescale 1ns/1ns



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



module Encoder_tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;

    

    // input signal
    logic                               i_start;
    logic [2:0][6:0]                    i_addr_buf[0:`W_C_LENGTH-1]; //
    logic                               i_valid_buf[0:`W_C_LENGTH-1]; //
    logic [8:0]                         i_pos_buf[0:`W_C_LENGTH-1]; //
    logic signed [15:0]                 i_ia_data[0:`IA_CHANNEL]; //
    logic signed [15:0]                 i_w_data[0:`W_C_LENGTH]; //
    logic [$clog2(`W_C_LENGTH)-1:0]     i_w_len; //
    
    always_comb begin
        i_w_len = 10;
        i_valid_buf[0:9] = {0,0,0,0,1,1,1,1,1,1};
        i_pos_buf[0:9] = '{
            9'd1,
            9'd1,
            9'd7,
            9'd1,
            9'd6,
            9'd5,
            9'd4,
            9'd1,
            9'd1,
            9'd3
        };
        for (int i=0; i<474; i=i+1) begin
            i_addr_buf[i][0] = i;
            i_addr_buf[i][1] = i;
            i_addr_buf[i][2] = i;
        end
        for (int i=0; i<474; i=i+1) begin
            i_w_data[i] = i;
        end
        for (int i=0; i<8; i=i+1) begin
            i_ia_data[i] = i;
        end

        $display("valid, pos, addr, w_data, ia_data");
        for (int i=0; i<20; i=i+1) begin
            $display("%d, %d, (%d, %d, %d), %d, %d", i_valid_buf[i], i_pos_buf[i], i_addr_buf[i][0], i_addr_buf[i][1], i_addr_buf[i][2], i_w_data[i], i_ia_data[i]);
        end
    end
    // output signal 
    logic                  o_left_ready;
    logic                  o_right_ready;
    logic [2:0][6:0]       o_addr_right_buffer[0:2];
    logic signed [15:0]    o_w_data_right_buffer[0:2];
    logic signed [15:0]    o_ia_data_right_buffer[0:2];
    logic [2:0][6:0]       o_addr_left_buffer[0:2];
    logic signed [15:0]    o_w_data_left_buffer[0:2];
    logic signed [15:0]    o_ia_data_left_buffer[0:2];

    

	VPEncoder vpEncoder(
		.i_clk(clk),
		.i_rst_n(rst),
        .i_start(i_start),
        // input
        .i_w_len(i_w_len),
        .i_addr_buf(i_addr_buf),
        .i_valid_buf(i_valid_buf),
        .i_pos_buf(i_pos_buf),
        .i_ia_data(i_ia_data),
        .i_w_data(i_w_data),
        // output
        .o_left_ready(o_left_ready),
        .o_right_ready(o_right_ready),
        .o_addr_right_buffer(o_addr_right_buffer),
        .o_w_data_right_buffer(o_w_data_right_buffer),
        .o_ia_data_right_buffer(o_ia_data_right_buffer),
        .o_addr_left_buffer(o_addr_left_buffer),
        .o_w_data_left_buffer(o_w_data_left_buffer),
        .o_ia_data_left_buffer(o_ia_data_left_buffer)
	);


	initial begin 
		rst = 1'b0;
        i_start = 0;
		#(2*CLK)
		rst = 1'b1;

        for (int i = 0; i < 10; i++) @(posedge clk);

        $display("-----------------------");
        @(negedge clk);
        i_start = 1;
        @(negedge clk);
        i_start = 0;
        $display("addr, w, ia");
        for (int i = 0; i < 20; i++) begin
            @(posedge clk);
            $display("-----------------------");
            i_start = 0;
            $display("left: %d", o_left_ready);
            for (int j=0; j<3; j=j+1) begin
                $display("(%d, %d, %d), %d, %d", o_addr_left_buffer[j][0], o_addr_left_buffer[j][1], o_addr_left_buffer[j][2], o_w_data_left_buffer[j], o_ia_data_left_buffer[j]);
            end
            $display("right: %d", o_right_ready);
            for (int j=0; j<3; j=j+1) begin
                $display("(%d, %d, %d), %d, %d", o_addr_right_buffer[j][0], o_addr_right_buffer[j][1], o_addr_right_buffer[j][2], o_w_data_right_buffer[j], o_ia_data_right_buffer[j]);
            end
        end
	end


	initial begin
		$fsdbDumpfile("encoder.fsdb");
		$fsdbDumpvars;
        $fsdbDumpMDA();
		
		for (int i = 0; i < 150; i++) begin
			@(posedge clk);
		end
		$finish;
	end

endmodule
