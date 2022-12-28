`include "header.h"

module PEReducer(
    input               i_clk,
    input               i_rst_n,
    input               i_start,
    input [2:0][6:0]    i_addr[0:2],
    input signed [15:0] i_w[0:2],
    input signed [15:0] i_ia[0:2],
    output signed [`IA_DATA_BITWIDTH-1:0] o_buf[0:3*`IA_CHANNEL-1],
    output              o_finish
);

localparam S_IDLE = 2'd0;
localparam S_PROC = 2'd1;
localparam S_SLCT = 2'd2;

logic [1:0] state_r, state_w;
logic finish_r, finish_w;

logic signed [`IA_DATA_BITWIDTH-1:0] buf_r[0: 3*`IA_CHANNEL-1], buf_w[0: 3*`IA_CHANNEL-1];
logic [3*`IA_CHANNEL-1:0] ptr_r, ptr_w;

logic addr_start, comp_start;
logic [1:0] comp_code;
logic [1:0] out_num;
logic [33:0] ABC, C, BC, B, AB, A;
logic proc_finish, addr_finish, comp_finish;
logic signed [33:0] out_r[0:2], out_w[0:2];

logic [2:0][6:0] addr_last_r, addr_last_w;
logic addr_diff_r, addr_diff_w;

assign proc_finish = addr_finish & comp_finish;
assign o_buf = buf_w;
assign o_finish = finish_w;

// ===== Submodules =====
AddrProcess addr(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(addr_start),
    .i_A(i_addr[0]),
    .i_B(i_addr[1]),
    .i_C(i_addr[2]),
    .o_finish(addr_finish),
    .o_comp(comp_code),
    .o_num(out_num)
);
Computation comp(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(comp_start),
    .i_w(i_w),
    .i_ia(i_ia),
    .o_ABC(ABC),
    .o_C(C),
    .o_BC(BC),
    .o_B(B),
    .o_AB(AB),
    .o_A(A),
    .o_finish(comp_finish)
);
// ===== Combinational Blocks =====
always_comb begin // state
    case(state_r)
        S_IDLE: state_w = (i_start) ? S_PROC: state_r;
        S_PROC: state_w = S_SLCT;
        S_SLCT: state_w = S_IDLE;
        default: state_w = state_r;
    endcase
end
always_comb begin // addr & comp start
    case(state_r)
        S_IDLE: begin
            addr_start = (i_start) ? 1'd1: 1'd0;
            comp_start = (i_start) ? 1'd1: 1'd0;
        end

        default: begin
            addr_start = 1'd0;
            comp_start = 1'd0;
        end
    endcase
end
always_comb begin // finish
    case(state_r)
        S_IDLE: finish_w = 1'd0;
        S_SLCT: finish_w = 1'd1;
        default: finish_w = 1'd0;
    endcase
end
always_comb begin // out
    case(state_r)
        S_IDLE: begin
            out_w[0] = 34'd0;
            out_w[1] = 34'd0;
            out_w[2] = 34'd0;
        end
        S_PROC: begin
            case(comp_code)
                2'd0: begin
                    out_w[0] = ABC;
                    out_w[1] = 34'd0;
                    out_w[2] = 34'd0;
                end
                2'd1: begin
                    out_w[0] = AB;
                    out_w[1] = C;
                    out_w[2] = 34'd0;
                end
                2'd2: begin
                    out_w[0] = A;
                    out_w[1] = BC;
                    out_w[2] = 34'd0;
                end
                2'd3: begin
                    out_w[0] = A;
                    out_w[1] = B;
                    out_w[2] = C;
                end
                default: out_w = out_r;
            endcase
        end
        default: out_w = out_r;
    endcase
end
always_comb begin // buffer
    case(state_r)
        S_SLCT: begin
            buf_w[ptr_r] = buf_r[ptr_r] + out_r[0];
            buf_w[ptr_r+1] = buf_r[ptr_r+1] + out_r[1];
            buf_w[ptr_r+2] = buf_r[ptr_r+2] + out_r[2];
        end
        default: buf_w = buf_r;
    endcase
end
always_comb begin // addr_last
    case(state_r)
        S_PROC: begin
            addr_last_w = i_addr[0];
            addr_diff_w = (addr_last_w == addr_last_r)? 1'd1: 1'd0;
        end
        S_SLCT: begin
            addr_last_w = i_addr[2];
            addr_diff_w = addr_diff_r;
        end
        default: begin
            addr_last_w = addr_last_r;
            addr_diff_w = addr_diff_r;
        end
    endcase
end
always_comb begin // ptr
    case(state_r)
        S_PROC: ptr_w = (addr_diff_w) ? ptr_r: ptr_r +1;
        S_SLCT: ptr_w = ptr_r + out_num;
        default: ptr_w = ptr_r;
    endcase
end
// ===== Sequential Blocks =====
integer i;
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        finish_r    <= 1'd0;
        ptr_r       <= 0;
        out_r[0]    <= 34'd0;
        out_r[1]    <= 34'd0;
        out_r[2]    <= 34'd2;
        addr_last_r <= 0;
        addr_diff_r <= 1'b1;
        for(i=0; i<(3*`IA_CHANNEL); i=i+1) begin
            buf_r[i] <= 0;
        end
    end
    else begin
        state_r     <= state_w;
        finish_r    <= finish_w;
        ptr_r       <= ptr_w;
        out_r       <= out_w;
        addr_last_r <= addr_last_w;
        addr_diff_r <= addr_diff_w;
        buf_r       <= buf_w;
    end
end


endmodule

module AddrProcess(
    input i_clk,
    input i_rst_n,
    input i_start,
    input [2:0][6:0] i_A,
    input [2:0][6:0] i_B,
    input [2:0][6:0] i_C,
    output o_finish,
    output [1:0] o_comp,
    output [1:0] o_num
);

    localparam S_IDLE = 1'd0;
    localparam S_PROC = 1'd1;

    logic state_r, state_w;
    logic finish_r, finish_w;
    logic [1:0] comp_r, comp_w, num_r, num_w;

    logic [2:0] compareAB, compareBC;

    assign compareAB[0] = (i_A[0] == i_B[0]);
    assign compareAB[1] = (i_A[1] == i_B[1]);
    assign compareAB[2] = (i_A[2] == i_B[2]);
    assign compareBC[0] = (i_C[0] == i_B[0]);
    assign compareBC[1] = (i_C[1] == i_B[1]);
    assign compareBC[2] = (i_C[2] == i_B[2]);

    assign o_finish = finish_w;
    assign o_comp = comp_w;
    assign o_num = num_w;

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

    always_comb begin // compare result
        case(state_r)
            S_IDLE: begin
                num_w = 2'd2;
                comp_w = 2'd3;
            end
            S_PROC: begin
                if (compareAB == 3'b111 && compareBC == 3'b111) begin
                    comp_w = 2'd0;
                    num_w = 2'd0;
                end
                else if (compareAB == 3'b111 && compareBC != 3'b111) begin
                    comp_w = 2'd1;
                    num_w = 2'd1;
                end
                else if (compareAB != 3'b111 && compareBC == 3'b111) begin
                    comp_w = 2'd2;
                    num_w = 2'd1;
                end
                else begin
                    comp_w = 2'd3;
                    num_w = 2'd2;
                end
            end
            default: begin
                comp_w = comp_r;
                num_w = num_r;
            end
        endcase
    end


    // ===== Sequential Blocks =====
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            finish_r    <= 1'd0;
            comp_r      <= 2'd0;
            num_r       <= 2'd0;
            state_r     <= 1'b0;
        end
        else begin        
            finish_r    <= finish_w;
            comp_r      <= comp_w;
            num_r       <= num_w;
            state_r     <= state_w;
        end
    end
endmodule


module Computation(
    input i_clk,
    input i_rst_n,
    input i_start,
    input signed [15:0] i_w[0:2],
    input signed [15:0] i_ia[0:2],
    output [33:0] o_ABC,
    output [33:0] o_C,
    output [33:0] o_BC,
    output [33:0] o_B,
    output [33:0] o_AB,
    output [33:0] o_A,
    output o_finish
);
    localparam S_IDLE = 1'd0;
    localparam S_PROC = 1'd1;

    logic state_r, state_w;
    logic finish_r, finish_w;
    logic [33:0] ABC_r, ABC_w, C_r, C_w, BC_r, BC_w, B_r, B_w, AB_r, AB_w, A_r, A_w;
    logic [15:0] Aw, Aia, Bw, Bia, Cw, Cia;
    logic [31:0] A, B, C;

    assign Aw = i_w[0];
    assign Aia = i_ia[0];
    assign Bw = i_w[1];
    assign Bia = i_ia[1];
    assign Cw = i_w[2];
    assign Cia = i_ia[2];

    assign A = Aw * Aia;
    assign B = Bw * Bia;
    assign C = Cw * Cia;

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
                ABC_w = 34'd0;
                C_w = 34'd0;
                BC_w = 34'd0;
                B_w = 34'd0;
                AB_w = 34'd0;
                A_w = 34'd0;
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
            ABC_r       <= 34'd0;
            C_r         <= 34'd0;
            BC_r        <= 34'd0;
            B_r         <= 34'd0;
            AB_r        <= 34'd0;
            A_r         <= 34'd0;
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