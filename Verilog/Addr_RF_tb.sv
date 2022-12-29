`timescale 1ns/1ns
`include "header.h"
module tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst, start_cal;
	initial clk = 1;
	always #HCLK clk = ~clk;

    logic [$clog2(`IA_ROW):0] i_h, i_w;
    logic [`W_R_BITWIDTH-1:0] i_r[0:`W_R_LENGTH-1]; 
    logic [1:0] i_s;
    logic [`W_K_BITWIDTH-1:0] i_k[0:`W_R_LENGTH-1];
    logic [`W_POS_PTR_BITWIDTH-1:0] i_ptr[0:`W_R_LENGTH-1];
    logic [$clog2(`W_C_LENGTH):0] length;

    logic finish;
    logic [2:0][6:0] RF[0:`W_C_LENGTH-1];

    initial begin
        i_h = 7'd10;
        i_w = 7'd11;
        $display("\n\033[1;31m=============================================");
	    $display("           Start the assignment of h & w!      ");
	    $display("=============================================\033[0m");
    end
    integer i;
    always_comb begin
        for(i=0; i<`W_R_LENGTH; i=i+1) begin
            i_r[i] = i[0];
            i_k[i] = i[2:0];
            i_ptr[i] = 3*i;
        end
        $display("\n\033[1;31m=============================================");
	    $display("           End the assignment of r & k!      ");
	    $display("=============================================\033[0m");
    end

    assign i_s = 2'd1;
    assign length = 10;

	AddrToRF addr_rf(
		.i_clk(clk),
		.i_rst_n(rst),
		.i_start(start_cal),
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
        #200 begin
            start_cal = 1'b1;
        end
        #10 begin
            start_cal = 1'b0;
        end     
	end


	initial begin
		$fsdbDumpfile("addr_rf.fsdb");
		$fsdbDumpvars;
        $fsdbDumpMDA();
		
		for (int i = 0; i < 300; i++) begin
			@(posedge clk);
		end
		$finish;
	end

endmodule