`define H_Length 3
`define W_Length 3
`define R_Length 3
`define S_Length 3
`define K_Length 3

module AddrProcess(
    input i_clk,
    input i_rst_n,
    input i_start,
    input [`H_Length-1:0] i_Ah,
    input [`W_Length-1:0] i_Aw,
    input [`R_Length-1:0] i_Ar,
    input [`S_Length-1:0] i_As,
    input [`K_Length-1:0] i_Ak,
    input [`H_Length-1:0] i_Bh,
    input [`W_Length-1:0] i_Bw,
    input [`R_Length-1:0] i_Br,
    input [`S_Length-1:0] i_Bs,
    input [`K_Length-1:0] i_Bk,
    input [`H_Length-1:0] i_Ch,
    input [`W_Length-1:0] i_Cw,
    input [`R_Length-1:0] i_Cr,
    input [`S_Length-1:0] i_Cs,
    input [`K_Length-1:0] i_Ck,
    output [99:0] o_A,
    output [99:0] o_B,
    output [99:0] o_C,
    output o_finish,
    output [1:0] o_comp
);

localparam S_IDLE = 1'd0;
localparam S_PROC = 1'd1;

logic state_r, state_w;
logic [99:0] A_r, A_w, B_r, B_w, C_r, C_w;
logic finish_r, finish_w;
logic [1:0] comp_r, comp_w;
logic [`H_Length-1:0] tempxA, tempxB, tempxC;
logic [`K_Length-1:0] tempyA, tempyB, tempyC;
logic [2:0] compareAB, compareBC;

assign compareAB[0] = (tempxA == tempxB);
assign compareAB[1] = (tempyA == tempyB);
assign compareAB[2] = (i_Ak == i_Bk);
assign compareBC[0] = (tempxB == tempxC);
assign compareBC[1] = (tempyB == tempyC);
assign compareBC[2] = (i_Bk == i_Ck);

assign o_A = A_w;
assign o_B = B_w;
assign o_C = C_w;
assign o_finish = finish_w;
assign o_comp = comp_w;

assign tempxA = i_Ah - i_Ar;
assign tempxB = i_Bh - i_Br;
assign tempxC = i_Ch - i_Cr;

assign tempyA = i_Aw - i_As;
assign tempyB = i_Bw - i_Bs;
assign tempyC = i_Cw - i_Cs;



// ===== Combinational Blocks =====
always_comb begin // state
    case(state_r)
        S_IDLE: state_w = (i_start) ? S_PROC : state_r;
        S_PROC: state_w = S_IDLE;
        default: state_w = state_r;
    endcase
end

always_comb begin // finish
    case(state_r)
        S_IDLE: finish_w = 1'b0;
        S_PROC: finish_w = 1'b1;
        default: finish_w = finish_r;
    endcase
end

always_comb begin // o_A, o_B, o_C
    case(state_r)
        S_IDLE: begin
            A_w = 100'd0;
            B_w = 100'd0;
            C_w = 100'd0;
        end
        S_PROC: begin
            A_w = tempxA * tempyA * i_Ak;
            B_w = tempxB * tempyB * i_Bk;
            C_w = tempxC * tempyC * i_Ck;
        end
        default: begin
            A_w = A_r;
            B_w = B_r;
            C_w = C_r;
        end
    endcase
end

always_comb begin // compare result
    case(state_r)
        S_IDLE: comp_w = 2'd3;
        S_PROC: begin
            if (compareAB == 3'b111 && compareBC == 3'b111) comp_w = 2'd0;
            else if (compareAB == 3'b111 && compareBC != 3'b111) comp_w = 2'd1;
            else if (compareAB != 3'b111 && compareBC == 3'b111) comp_w = 2'd2;
            else comp_w = 2'd3;
        end
        default: comp_w = comp_r;
    endcase
end

// ===== Sequential Blocks =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        A_r         <= 100'd0;
        B_r         <= 100'd0;
        C_r         <= 100'd0;
        finish_r    <= 1'd0;
        comp_r      <= 2'd0;
        state_r     <= 1'b0;
    end
    else begin        
        A_r         <= A_w;
        B_r         <= B_w;
        C_r         <= C_w;
        finish_r    <= finish_w;
        comp_r      <= comp_w;
        state_r     <= state_w;
    end
end


endmodule