`include "header.h"
module AIM(
    input i_clk,
    input i_rst_n,
    input i_start,
    input [$clog2(`IA_CHANNEL):0] i_ite, // DO SUBTRACT 1, ex, run 2 iteration -> i_ite = 1
    input [`W_C_BITWIDTH-1:0] i_word[0:31],
    input [`IA_C_BITWIDTH-1:0] i_IA[0:`IA_CHANNEL-1], // 8*32 = 256
    output o_finish,
    output o_valid[0:`W_C_LENGTH-1],
    output [8:0] o_pos[0:`W_C_LENGTH-1] 
);

localparam S_IDLE = 2'd0;
localparam S_COMP = 2'd1;
localparam S_ENCO = 2'd2;

logic [1:0]     state_r, state_w;
logic [$clog2(`IA_CHANNEL):0]     ite_counter_r, ite_counter_w;
logic [31:0]    map_r[0:31], map_w[0:31];
logic [31:0]    match_r, match_w;
logic [`W_C_LENGTH-1:0] ptr_r, ptr_w;

logic           finish_r, finish_w;
logic           valid_r[0:31], valid_w[0:31];
logic [8:0]     pos_r[0:31], pos_w[0:31];
logic           valid_all_r[0:`W_C_LENGTH-1], valid_all_w[0: `W_C_LENGTH-1];
logic [8:0]     pos_all_r[0:`W_C_LENGTH-1], pos_all_w[0:`W_C_LENGTH-1];

logic           i_encode_start;
logic           i_encode_finish[0:31];
logic [`IA_C_BITWIDTH-1:0]     IA_r[0:31], IA_w[0:31];

assign i_encode_start = (state_r == S_ENCO);
assign o_finish = finish_r;
assign o_valid = valid_all_w;
assign o_pos = pos_all_w;

// ===== Combinational Blocks ===== 
always_comb begin //IA
    case(state_r)
        //S_COMP: IA_w = i_IA[(ite_counter_r << 5) +: 32];
        S_COMP: begin
            IA_w[0:`IA_CHANNEL-1] = i_IA;
            IA_w[`IA_CHANNEL:31] = IA_r[`IA_CHANNEL:31];
        end
        default: IA_w = IA_r;
    endcase
end
always_comb begin // state
    case(state_r)
        S_IDLE: state_w = (i_start) ? S_COMP : state_r;
        S_COMP: state_w = S_ENCO;
        S_ENCO: state_w = (ite_counter_r == i_ite)? S_IDLE: S_COMP;
        default: state_w = state_r;
    endcase
end
always_comb begin // ite_counter
    case(state_r)
        S_IDLE: ite_counter_w = 3'd0;
        S_ENCO: ite_counter_w = (ite_counter_r < i_ite)? ite_counter_r +1 : ite_counter_r;
        default: ite_counter_w = ite_counter_r;
    endcase
end
always_comb begin // finish
    case(state_r)
        S_IDLE: finish_w = 1'd0;
        S_ENCO: finish_w = (ite_counter_r == i_ite) ? 1'd1: finish_r;
        default: finish_w = 1'd0;
    endcase
end
always_comb begin //ptr
    case(state_r) 
        S_ENCO: ptr_w = ptr_r + 1;
        default: ptr_w = ptr_r;
    endcase
end

integer j, k;
always_comb begin
    case(state_r)
        S_IDLE: begin
            map_w = map_r;
            match_w = 32'd0;
        end
        S_COMP: begin
            for(j=0; j<32; j=j+1) begin
                for(k=0; k<`IA_CHANNEL; k=k+1) begin
                    map_w[j][k] = (IA_w[k] == i_word[j]);
                end
                match_w[j] = (map_w[j] != 32'd0) ? 1'd1: match_r[j];
            end
        end
        default: begin
            match_w = match_r;
            map_w = map_r;
        end
    endcase
end

genvar i;
generate
    for(i=0; i<32; i=i+1) begin
        encoder enco(.i_clk(i_clk), .i_rst_n(i_rst_n), .i_start(i_encode_start), .i_match(match_r[i]), .i_word(map_r[i]),
         .i_ite(ite_counter_r), .o_valid(valid_w[i]), .o_pos(pos_w[i]));
    end
endgenerate

integer b;
always_comb begin
    case(state_r)
    S_IDLE: begin
        valid_all_w = valid_all_r;
        pos_all_w = pos_all_r;
    end
    ENCO: begin
        for(b=0; b<`W_C_LENGTH; b=b+1) begin
            if(b>= ((ptr_r-1)<<5)&& b < (ptr_r<<5)) begin
                valid_all_w[b] = valid_w[(b-((ptr_r-1)<<5))];
                pos_all_w[b] = pos_w[(b-((ptr_r-1)<<5))];
            end
            else begin
                valid_all_w[b] = valid_all_r[b];
                pos_all_w[b] = pos_all_r[b];
            end
        end
    end
    default: begin
        valid_all_w = valid_all_r;
        pos_all_w = pos_all_r;
    end
    endcase
end

// ===== Sequential Blocks =====
integer s, t;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r         <= S_IDLE;
        ite_counter_r   <= 3'd0;
        match_r         <= 32'd0;
        finish_r        <= 1'd0;
        ptr_r           <= 0;

        for(s=0; s<32; s=s+1) begin
            IA_r[s] <= 5'dz;
            map_r[s] <= 32'd0;
            valid_r[s] <= 1'd0;
            pos_r[s] <= 9'd0;
        end
        for(t=0; t<`W_C_LENGTH; t=t+1) begin
            valid_all_r[t] <= 1'd0;
            pos_all_r[t] <= 9'd0;
        end
    end
    else begin
        state_r         <= state_w;
        ite_counter_r   <= ite_counter_w;
        match_r         <= match_w;
        finish_r        <= finish_w;
        map_r           <= map_w;
        valid_r         <= valid_w;
        pos_r           <= pos_w;
        IA_r            <= IA_w;
        valid_all_r     <= valid_all_w;
        pos_all_r       <= pos_all_w;
        ptr_r           <= ptr_w;
    end
end

endmodule

module encoder(
    input i_clk,
    input i_rst_n,
    input i_start,
    input i_match,
    input [31:0] i_word,
    input [$clog2(`IA_CHANNEL):0] i_ite,
    output o_valid,
    output [8:0] o_pos
);
localparam S_IDLE = 1'd0;
localparam S_ENCO = 1'd1;

logic           state_r, state_w;
logic           valid_r, valid_w;
logic [8:0]     pos_r, pos_w;
logic [4:0]     match_pos;

assign o_valid = valid_w;
assign o_pos = pos_w;

// ===== Combinational Blocks =====
always_comb begin
    case(i_word)
        32'h00000001: match_pos = 5'd0;
        32'h00000002: match_pos = 5'd1;
        32'h00000004: match_pos = 5'd2;
        32'h00000008: match_pos = 5'd3;
        32'h00000010: match_pos = 5'd4;
        32'h00000020: match_pos = 5'd5;
        32'h00000040: match_pos = 5'd6;
        32'h00000080: match_pos = 5'd7;
        32'h00000100: match_pos = 5'd8;
        32'h00000200: match_pos = 5'd9;
        32'h00000400: match_pos = 5'd10;
        32'h00000800: match_pos = 5'd11;
        32'h00001000: match_pos = 5'd12;
        32'h00002000: match_pos = 5'd13;
        32'h00004000: match_pos = 5'd14;
        32'h00008000: match_pos = 5'd15;
        32'h00010000: match_pos = 5'd16;
        32'h00020000: match_pos = 5'd17;
        32'h00040000: match_pos = 5'd18;
        32'h00080000: match_pos = 5'd19;
        32'h00100000: match_pos = 5'd20;
        32'h00200000: match_pos = 5'd21;
        32'h00400000: match_pos = 5'd22;
        32'h00800000: match_pos = 5'd23;
        32'h01000000: match_pos = 5'd24;
        32'h02000000: match_pos = 5'd25;
        32'h04000000: match_pos = 5'd26;
        32'h08000000: match_pos = 5'd27;
        32'h10000000: match_pos = 5'd28;
        32'h20000000: match_pos = 5'd29;
        32'h40000000: match_pos = 5'd30;
        32'h80000000: match_pos = 5'd31;
        default: match_pos = 5'dz;
    endcase
end

always_comb begin // state
    case(state_r)
        S_IDLE: state_w = (i_start) ? S_ENCO : state_r;
        S_ENCO: state_w = S_IDLE;
        default: state_w = state_r;
    endcase
end
always_comb begin // valid & pos
    case(state_r)
        S_IDLE: begin
            valid_w = 1'dz;
            pos_w = 9'dz;
        end
        S_ENCO: begin
            if(i_match == 1'b1) begin
                valid_w = 1'd1;
                pos_w =  match_pos + (i_ite << 5);
            end
            else begin
                valid_w = 1'd0;
                pos_w = 9'd0;
            end
        end
        default: begin
            valid_w = valid_r;
            pos_w = pos_r;
        end
    endcase
end
// ===== Sequential Block =====
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        valid_r     <= 1'd0;
        pos_r       <= 9'dz;
    end
    else begin
        state_r     <= state_w;
        valid_r     <= valid_w;
        pos_r       <= pos_w;
    end
end
endmodule