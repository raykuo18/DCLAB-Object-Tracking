`timescale 1ns/1ns

module tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst, start_cal;
	initial clk = 0;
	always #HCLK clk = ~clk;

    logic [2:0] ite;
    logic [15:0] word[0:31];
    logic [5:0] IA[0:255];
    logic finish;
    logic valid[0:31];
    logic [8:0] pos[0:31]; 

    integer i;
    always_comb begin
        for(i=0; i<32; i=i+1) begin
            word[i] = 2*i;
            IA[i] = 3*i;
        end
    end
    assign ite = 3'd0;


	PE pe(
		.i_clk(clk),
		.i_rst_n(rst),
		.i_start(start_cal),
        .i_ia_h(),
        .i_ia_w(),
        .i_ia_data(),
        .i_ia_c_idx(),
        .i_ia_iters(),
        .i_ia_len(),
        .i_w_s(),
        .i_w_data(),
        .i_w_c_idx(),
        .i_pos_ptr(),
        .i_r_idx(),
        .i_k_idx(),
        .i_w_iters(),
        .i_w_len(),
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
        #50 begin
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
