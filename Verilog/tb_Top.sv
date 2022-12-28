`timescale 1us/1us


`include "header.h"


module tb_top;
	localparam CLK = 10;
	localparam HCLK = CLK/2;

	logic rst, clk;
	initial clk = 0;
	always #HCLK clk = ~clk;


    logic       i_start;
    logic       i_start_2;
    logic [3:0] o_random_out;
    logic [3:0] o_random_out_2;


    Top top0(
        .i_clk          (clk),
        .i_rst_n        (rst),
        .i_start        (i_start),
        .i_start_2      (i_start_2),
        .o_random_out   (o_random_out),
        .o_random_out_2 (o_random_out_2)
    );

    initial begin
		$fsdbDumpfile("top.fsdb");
		$fsdbDumpvars;
		$fsdbDumpMDA();

        i_start = 0;

        // reset 
		rst = 1'b0;
		#(2*CLK)
		rst = 1'b1;

        for (int i = 0; i < 10; i++) @(posedge clk);


        i_start = 1;
    end



    initial begin
		#(2000*CLK)
		$display(".A.B.O.R.T.");
		$finish;
	end


endmodule
