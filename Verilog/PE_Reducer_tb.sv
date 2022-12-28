`timescale 1ns/1ns
`include "header.h"
module tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst, start_cal;
	initial clk = 0;
	always #HCLK clk = ~clk;

    logic [2:0][6:0] addr[0:2];
    logic signed [15:0] w[0:2], ia[0:2];
    logic signed [`IA_DATA_BITWIDTH-1:0] buffer[0:3*`IA_CHANNEL-1];
    logic finish;
    initial begin
        #35 begin
            addr[0] = {7'd0, 7'd0, 7'd0};
            addr[1] = {7'd1, 7'd1, 7'd1};
            addr[2] = {7'd2, 7'd2, 7'd2};
            w[0] = 16'd15;
            w[1] = 16'd16;
            w[2] = 16'd17;
            ia[0] = 16'd3;
            ia[1] = 16'd2;
            ia[2] = 16'd1;
        end
        #40 begin
            addr[0] = {7'd2, 7'd2, 7'd2};
            addr[1] = {7'd2, 7'd2, 7'd2};
            addr[2] = {7'd3, 7'd3, 7'd3};
            w[0] = 16'd4;
            w[1] = 16'd5;
            w[2] = 16'd6;
            ia[0] = 16'd3;
            ia[1] = 16'd2;
            ia[2] = 16'd1;
        end
    end

	PEReducer pe_r(
        .i_clk(clk),
        .i_rst_n(rst),
        .i_start(start_cal),
        .i_addr(addr),
        .i_w(w),
        .i_ia(ia),
        .o_buf(buffer),
        .o_finish(finish)
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
        #50 begin
            start_cal = 1'b1;
        end
        #10 begin
            start_cal = 1'b0;
        end     
	end


	initial begin
		$fsdbDumpfile("pe_r.fsdb");
		$fsdbDumpvars;
        $fsdbDumpMDA();
		
		for (int i = 0; i < 100; i++) begin
			@(posedge clk);
		end
		$finish;
	end

endmodule
