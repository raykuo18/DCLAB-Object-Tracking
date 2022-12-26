`timescale 1ns/1ns

`define W_C_LEN 16
`define ADDR_LEN 200
`define IA_C_LEN 1199
`define W_C_LEN 1199


module Encoder_tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;

    // input signal
    logic                               i_start;
    logic [$clog2(`W_C_LEN)-1:0]        i_w_len;
    logic [2:0][6:0]                    i_addr_buf[0:`W_C_LEN-1] = 
    `{
        `{1, 2, 3},
        `{},
        `{},
        `{},

    };
    logic                               i_valid_buf[0:ADDR_LEN];
    logic [8:0]                         i_pos_buf[0:`ADDR_LEN];
    logic signed [15:0]                 i_ia_data[0:`IA_C_LEN];
    logic signed [15:0]                 i_w_data[0:`W_C_LEN];
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
        // input
        .i_start(i_start),
        .i_w_len(i_w_len),
        .i_addr_buf(i_addr_buf),
        .i_valid_buf(i_valid_buf),
        .i_pos_buf(i_pos_buf),
        .i_ia_data[0:`IA_C_LEN](i_ia_data),
        .i_w_data[0:`W_C_LEN](i_w_data),
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
		#10 begin
			rst = 1'b1;
		end
        #10 begin
			rst = 0'b1;
		end
        
        #15 begin
            
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
