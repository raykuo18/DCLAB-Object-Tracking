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


	AIM aim(
		.i_clk(clk),
		.i_rst_n(rst),
		.i_start(start_cal),
        .i_ite(ite),
        .i_word(word),
        .i_IA(IA),
        .o_finish(finish),
        .o_valid(valid),
        .o_pos(pos)
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
		$fsdbDumpfile("aim.fsdb");
		$fsdbDumpvars;
        $fsdbDumpMDA();
		
		for (int i = 0; i < 150; i++) begin
			@(posedge clk);
		end
		$finish;
	end

endmodule
