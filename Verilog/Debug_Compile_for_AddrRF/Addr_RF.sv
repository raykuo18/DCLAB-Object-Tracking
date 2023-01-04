`include "header.h"

module AddrToRF(
    input i_clk,
    input i_rst_n,
    input i_start,
    input [$clog2(`IA_ROW):0] i_h,
    input [$clog2(`IA_ROW):0] i_w,
    input [1:0] i_s,
    input [`W_R_BITWIDTH-1:0] i_r[0:`W_R_LENGTH-1],
    input [`W_K_BITWIDTH-1:0] i_k[0:`W_R_LENGTH-1],
    input [`W_POS_PTR_BITWIDTH-1:0] i_ptr[0:`W_R_LENGTH-1],
    input [$clog2(`W_C_LENGTH):0] i_length,
    output o_finish,
    output [2:0][6:0] o_RF[0:`W_C_LENGTH-1]
);
localparam S_IDLE = 1'd0;
localparam S_PROC = 1'd1;

logic                         state_r,                  state_w;
logic                         finish_r,                 finish_w;
logic [`W_POS_PTR_BITWIDTH:0] counter_r,                counter_w;
logic [2:0][6:0]              RF_r[0:`W_C_LENGTH-1],    RF_w[0:`W_C_LENGTH-1];

logic [`W_POS_PTR_BITWIDTH:0] ptr_value_r, ptr_value_w;
logic [`W_R_LENGTH-1:0] ptr_idx_r, ptr_idx_w;
logic [`W_K_BITWIDTH:0] r_r, r_w, k_r, k_w;

assign o_finish = finish_w;
assign o_RF = RF_w;

// ===== Combinational Blocks =====
always_comb begin // RF
    RF_w = RF_r;
    case(state_r)
        S_IDLE: begin
            RF_w = RF_r;
        end
        S_PROC: begin
            if(counter_r < i_length) begin
                RF_w[counter_r][0] = i_h - r_w;
                RF_w[counter_r][1] = i_w - i_s;
                RF_w[counter_r][2] = k_w;
            end
            // for(int j=0; j<250; j++) begin
            //     if(j == counter_r) begin
            //         RF_w[j][0] = i_h - r_w;
            //         RF_w[j][1] = i_w - i_s;
            //         RF_w[j][2] = k_w;
            //     end
            //     else RF_w[j] = RF_r[j];
            // end

            // for(int j=250; j < i_length; j++) begin
            //     if(j == counter_r) begin
            //         RF_w[j][0] = i_h - r_w;
            //         RF_w[j][1] = i_w - i_s;
            //         RF_w[j][2] = k_w;
            //     end
            //     else RF_w[j] = RF_r[j];
            // end
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
        S_IDLE: counter_w = 0;
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
            ptr_value_w = (ptr_idx_r < `W_R_LENGTH-1) ? i_ptr[ptr_idx_r+1]: ptr_value_r;
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
            r_w = 0;
            k_w = 0;
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
// integer t;
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r     <= S_IDLE;
        finish_r    <= 1'd0;
        counter_r   <= 0;
        r_r         <= 0;
        k_r         <= 0;
        ptr_value_r <= 0;
        ptr_idx_r   <= 0;
        RF_r        <= '{default:0};

        // for(int t=0; t<250; t++) begin
        //     RF_r[t] <= 0;
        // end
        //   for(int t=250; t<i_length; t++) begin
        //     RF_r[t] <= 0;
        // end
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
