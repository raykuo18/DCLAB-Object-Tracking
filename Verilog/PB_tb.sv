`timescale 1ns/1ns

module tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;

    logic [9:0] R, G, B;
    logic take;
    logic [9:0] buffer[0:2][0:15][0:15];

    initial begin
        take = 0;
        R = 10'd1;
        G = 10'd2;
        B = 10'd3;
    end
    always #CLK begin
        take = ~take;
        R = R+1;
        G = G+1;
        B = B+1;
    end



	Picture_Buffer pb(
		.i_clk(clk),
		.i_rst_n(rst),
        .i_R(R),
        .i_G(G),
        .i_B(B),
        .i_take(take),
        .o_buf(buffer)
	);


	initial begin 
		rst = 1'b1;
		#10 begin
			rst = 1'b0;
		end
        #10 begin
			rst = 1'b1;
		end

	end


	initial begin
		$fsdbDumpfile("pb.fsdb");
		$fsdbDumpvars;
        $fsdbDumpMDA();
		
		for (int i = 0; i < 1500; i++) begin
			@(posedge clk);
		end
		$finish;
	end

endmodule
