`define K 4
`define length 10

module AddrToRF(
    input i_clk,
    input i_rst_n,
    input i_start,
    input [6:0] i_h,
    input [6:0] i_w,
    input [2:0] i_s,
    input [2:0] i_r[0:`K-1],
    input [4:0] i_k[0:`K-1],
    input [10:0] i_ptr[0:`K-1],
    input [10:0] i_length,
    output o_finish,
    output [2:0][6:0] o_RF[0:`length-1]
);
localparam S_IDLE = 1'd0;
localparam S_PROC = 1'd1;

logic state_r, state_w;
logic finish_r, finish_w;
logic [10:0] counter_r, counter_w;
logic [2:0][6:0] RF_r[0:`length-1], RF_w[0:`length-1];

logic [10:0] ptr_value_r, ptr_value_w;
logic [`K-1:0] ptr_idx_r, ptr_idx_w;
logic [6:0] r_r, r_w, k_r, k_w;

assign o_finish = finish_w;
assign o_RF = RF_w;

// ===== Combinational Blocks =====
integer i, j;
always_comb begin // RF
    case(state_r)
        S_IDLE: begin
            for(i=0; i<i_length; i=i+1) begin
                RF_w[i] = 0;
            end
        end
        S_PROC: begin
            for(j=0; j<i_length; j=j+1) begin
                if(j == counter_r) begin
                    RF_w[j][0] = i_h - r_w;
                    RF_w[j][1] = i_w - i_s;
                    RF_w[j][2] = k_w;
                end
                else RF_w[j] = RF_r[j];
            end
        end
        default: RF_w = RF_r;
    endcase
end
always_comb begin // state
    case(state_r)
        S_IDLE: state_w = (i_start) ? S_PROC: state_r;
        S_PROC: state_w = (counter_r == i_length-1) ? S_IDLE: state_r;
        default: state_w = state_r;
    endcase
end
always_comb begin // finish
    case(state_r)
        S_IDLE: finish_w = 1'd0;
        S_PROC: finish_w = (counter_r == i_length-1) ? 1'd1: 1'd0;
        default: finish_w = finish_r;
    endcase
end
always_comb begin // counter
    case(state_r)
        S_IDLE: counter_w = 11'd0;
        S_PROC: counter_w = counter_r + 1;
        default: counter_w = counter_r;
    endcase
end
always_comb begin // ptr
    case(state_r)
        S_IDLE: begin
            ptr_value_w = i_ptr[1];
            ptr_idx_w = 0;
        end
        S_PROC: begin
            ptr_value_w = (ptr_idx_r < `K-1) ? i_ptr[ptr_idx_r+1]: ptr_value_r;
            ptr_idx_w = (counter_r == ptr_value_r-1) ? ptr_idx_r +1: ptr_idx_r;
        end
        default: begin
            ptr_value_w = ptr_value_r;
            ptr_idx_w = ptr_idx_r;
        end
    endcase
end

always_comb begin //r, k
    case(state_r)
        S_IDLE: begin
            r_w = 7'd0;
            k_w = 7'd0;
        end
        S_PROC: begin
            r_w = (counter_r <= ptr_value_r) ? i_r[ptr_idx_r]: r_r;
            k_w = (counter_r <= ptr_value_r) ? i_k[ptr_idx_r]: k_r;
        end
        default: begin
            r_w = r_r;
            k_w = k_r;
        end
    endcase
end
// ===== Sequential Blocks =====
integer t;
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        finish_r    <= 1'd0;
        counter_r   <= 11'd0;
        r_r         <= 7'd0;
        k_r         <= 7'd0;
        ptr_value_r <= 11'd0;
        ptr_idx_r   <= 0;
        for(t=0; t<i_length; t=t+1) begin
            RF_r[t] <= 0;
        end
    end
    else begin
        state_r     <= state_w;
        finish_r    <= finish_w;
        counter_r   <= counter_w;
        r_r         <= r_w;
        k_r         <= k_w;
        ptr_value_r <= ptr_value_w;
        ptr_idx_r   <= ptr_idx_w;
        RF_r        <= RF_w;
    end
end

endmodule
