`define W_Length 3
`define I_Length 4

module Computation(
    input i_clk,
    input i_rst_n,
    input i_start,
    input [`W_Length-1:0] i_Aw,
    input [`I_Length-1:0] i_Ai,
    input [`W_Length-1:0] i_Bw,
    input [`I_Length-1:0] i_Bi,
    input [`W_Length-1:0] i_Cw,
    input [`I_Length-1:0] i_Ci,
    output [99:0] o_ABC,
    output [99:0] o_C,
    output [99:0] o_BC,
    output [99:0] o_B,
    output [99:0] o_AB,
    output [99:0] o_A,
    output o_finish
);
//localparam length = `W_Length*`I_Length;
localparam S_IDLE = 1'd0;
localparam S_PROC = 1'd1;

logic state_r, state_w;
logic finish_r, finish_w;
logic [99:0] ABC_r, ABC_w, C_r, C_w, BC_r, BC_w, B_r, B_w, AB_r, AB_w, A_r, A_w;
logic [99:0] A, B, C;

assign A = i_Aw * i_Ai;
assign B = i_Bw * i_Bi;
assign C = i_Cw * i_Ci;

assign o_ABC = ABC_w;
assign o_C = C_w;
assign o_BC = BC_w;
assign o_B = B_w;
assign o_AB = AB_w;
assign o_A = A_w;
assign o_finish = finish_w;

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
always_comb begin // output
    case(state_r)
        S_IDLE: begin
            ABC_w = 100'd0;
            C_w = 100'd0;
            BC_w = 100'd0;
            B_w = 100'd0;
            AB_w = 100'd0;
            A_w = 100'd0;
        end
        S_PROC: begin
            ABC_w = A+B+C;
            C_w = C;
            BC_w = B+C;
            B_w = B;
            AB_w = A+B;
            A_w = A;
        end
        default: begin
            ABC_w = ABC_r;
            C_w = C_r;
            BC_w = BC_r;
            B_w = B_r;
            AB_w = AB_r;
            A_w = A_r;
        end
    endcase
end
// ===== Sequential Blocks =====
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        finish_r    <= 1'b0;
        ABC_r       <= 100'd0;
        C_r         <= 100'd0;
        BC_r        <= 100'd0;
        B_r         <= 100'd0;
        AB_r        <= 100'd0;
        A_r         <= 100'd0;
    end
    else begin
        state_r     <= state_w;
        finish_r    <= finish_w;
        ABC_r       <= ABC_w;
        C_r         <= C_w;
        BC_r        <= BC_w;
        B_r         <= B_w;
        AB_r        <= AB_w;
        A_r         <= A_w;
    end
end

endmodule