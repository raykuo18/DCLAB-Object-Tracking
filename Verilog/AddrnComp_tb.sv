`timescale 1ns/1ns

module tb;
	localparam          CLK = 10;
	localparam          HCLK = CLK/2;

	logic clk, rst, start_cal;
	initial clk = 0;
	always #HCLK clk = ~clk;

    logic [99:0] A, B, C;
    logic [1:0] comp;
    logic finish_addr, finish_comp;
    logic [2:0] Ah, Aw, As, Ar, Ak, Bh, Bw, Bs, Br, Bk, Ch, Cw, Cs, Cr, Ck;
    logic [3:0] Ai, Bi, Ci;
    logic [12:0] ABC, C2, BC, B2, AB, A2;

    assign Ah = 3'd5;
    assign Aw = 3'd5;
    assign As = 3'd3;
    assign Ar = 3'd3;
    assign Ak = 3'd2;
    assign Bh = 3'd6;
    assign Bw = 3'd5;
    assign Bs = 3'd3;
    assign Br = 3'd4;
    assign Bk = 3'd2;
    assign Ch = 3'd7;
    assign Cw = 3'd5;
    assign Cs = 3'd3;
    assign Cr = 3'd3;
    assign Ck = 3'd4;

    assign Ai = 4'd8;
    assign Bi = 4'd10;
    assign Ci = 4'd12;

	AddrProcess addr(
		.i_clk(clk),
		.i_rst_n(rst),
		.i_start(start_cal),
        .i_Ah(Ah),
        .i_Aw(Aw),
        .i_Ar(Ar),
        .i_As(Ar),
        .i_Ak(Ak),
        .i_Bh(Bh),
        .i_Bw(Bw),
        .i_Br(Br),
        .i_Bs(Bs),
        .i_Bk(Bk),
        .i_Ch(Ch),
        .i_Cw(Cw),
        .i_Cr(Cr),
        .i_Cs(Cr),
        .i_Ck(Ck),
        .o_A(A),
        .o_B(B),
        .o_C(C),
        .o_finish(finish_addr),
        .o_comp(comp)
	);

    Computation compute(
        .i_clk(clk),
        .i_rst_n(rst),
        .i_start(start_cal),
        .i_Aw(Aw),
        .i_Ai(Ai),
        .i_Bw(Bw),
        .i_Bi(Bi),
        .i_Cw(Cw),
        .i_Ci(Ci),
        .o_ABC(ABC),
        .o_C(C2),
        .o_BC(BC),
        .o_B(B2),
        .o_AB(AB),
        .o_A(A2),
        .o_finish(finish_comp)
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
        #30 begin
            start_cal = 1'b1;
        end
        #10 begin
            start_cal = 1'b0;
        end     
	end


	initial begin
		$fsdbDumpfile("addr.fsdb");
		$fsdbDumpvars;
		
		for (int i = 0; i < 100; i++) begin
			@(posedge clk);
		end
		$finish;
	end

endmodule
