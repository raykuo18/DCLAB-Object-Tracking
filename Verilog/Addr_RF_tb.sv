`timescale 1ns/1ns

module tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst, start_cal;
	initial clk = 0;
	always #HCLK clk = ~clk;

    logic [6:0] i_h, i_w;
    logic [2:0] i_r[0:3], i_s;
    logic [4:0] i_k[0:3];
    logic [10:0] i_ptr[0:3];
    logic finish;
    logic [2:0][6:0] RF[0:9];

    initial begin
        i_h = 7'd10;
        i_w = 7'd11;
        #55 begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
        #(CLK) begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
        #(CLK) begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
        #(CLK) begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
        #(CLK) begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
        #(CLK) begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
        #(CLK) begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
        #(CLK) begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
        #(CLK) begin
            i_h = i_h+1;
            i_w = i_w-1;
        end
    end


    assign i_r[0] = 3'd0;
    assign i_r[1] = 3'd1;
    assign i_r[2] = 3'd2;
    assign i_r[3] = 3'd3;
    assign i_k[0] = 5'd0;
    assign i_k[1] = 5'd0;
    assign i_k[2] = 5'd0;
    assign i_k[3] = 5'd1;
    assign i_ptr[0] = 11'd0;
    assign i_ptr[1] = 11'd3;
    assign i_ptr[2] = 11'd5;
    assign i_ptr[3] = 11'd8;
    assign i_s = 3'd1;

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
        .i_length(4'd10),
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
