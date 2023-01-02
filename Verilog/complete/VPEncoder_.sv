/*// --------------------- `define for WMem ------------------------
    `define W_DATA_BITWIDTH    16
    `define W_C_BITWIDTH       5   // log2(# Channel)
    `define W_R_BITWIDTH       2 
    `define W_K_BITWIDTH       5 
    `define W_POS_PTR_BITWIDTH 11 

    `define W_C_LENGTH        474 // max of C_LENGTH
    `define W_R_LENGTH        48  // max of R_LENGTH


// --------------------- `define for IA ------------------------
    `define IA_DATA_BITWIDTH    16
    `define IA_C_BITWIDTH       5   // log2(# Channel)
    `define IA_CHANNEL 8
    `define IA_ROW 16
    `define IA_COL 16*/

`include "header.h"


module VPEncoder(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_start,
    //////////////// input (7) ////////////////
    input [2:0][6:0]        i_addr_buf[0:`W_C_LENGTH-1],
    input                   i_valid_buf[0:`W_C_LENGTH-1],
    input [8:0]             i_pos_buf[0:`W_C_LENGTH-1],
    input signed [15:0]     i_ia_data[0:`IA_CHANNEL-1],
    input signed [15:0]     i_w_data[0:`W_C_LENGTH-1],
    input [$clog2(`W_C_LENGTH):0]  i_w_len,

    //////////////// output (8) ////////////////
    // o_ready
    output                  o_left_ready,
    output                  o_right_ready,
    // right o_buffer
    output [2:0][6:0]       o_addr_right_buffer[0:2],
    output signed [15:0]    o_w_data_right_buffer[0:2],
    output signed [15:0]    o_ia_data_right_buffer[0:2],
    // left o_buffer
    output [2:0][6:0]       o_addr_left_buffer[0:2],
    output signed [15:0]    o_w_data_left_buffer[0:2],
    output signed [15:0]    o_ia_data_left_buffer[0:2],

    //////////////// Finish ////////////////
    output                  o_finish      
);

/////////////////// State ///////////////////
localparam          S_IDLE = 0;
localparam          S_WRITE_RIGHT = 1;
localparam          S_WRITE_LEFT = 2;

logic               finish_r, finish_w;
logic [1:0]         state_r, state_w;
logic [1:0]         write_pos_r, write_pos_w;
logic [4:0]         current_idx_r, current_idx_w;

/////////////////// output var ///////////////////
logic [2:0][6:0]        addr_right_buffer_r[0:2], addr_right_buffer_w[0:2];
logic signed [15:0]     w_data_right_buffer_r[0:2], w_data_right_buffer_w[0:2];
logic signed [15:0]     ia_data_right_buffer_r[0:2], ia_data_right_buffer_w[0:2];
logic [2:0][6:0]        addr_left_buffer_r[0:2], addr_left_buffer_w[0:2];
logic signed [15:0]     w_data_left_buffer_r[0:2], w_data_left_buffer_w[0:2];
logic signed [15:0]     ia_data_left_buffer_r[0:2], ia_data_left_buffer_w[0:2];

/*integer i;
always_comb begin
    for (i = 0; i < 3; i=i+1) begin 
        o_addr_right_buffer[i]       = addr_right_buffer_r[i];
        o_w_data_right_buffer[i]     = w_data_right_buffer_r[i];
        o_ia_data_right_buffer[i]    = ia_data_right_buffer_r[i];
        o_addr_left_buffer[i]        = addr_left_buffer_r[i];
        o_w_data_left_buffer[i]      = w_data_left_buffer_r[i];
        o_ia_data_left_buffer[i]     = ia_data_left_buffer_r[i];
    end
end*/
assign o_addr_right_buffer       = addr_right_buffer_r;
assign o_w_data_right_buffer     = w_data_right_buffer_r;
assign o_ia_data_right_buffer    = ia_data_right_buffer_r;
assign o_addr_left_buffer        = addr_left_buffer_r;
assign o_w_data_left_buffer      = w_data_left_buffer_r;
assign o_ia_data_left_buffer     = ia_data_left_buffer_r;
assign o_finish                  = finish_r;

logic left_ready_r, left_ready_w;
logic right_ready_r, right_ready_w;

assign o_left_ready = left_ready_r;
assign o_right_ready = right_ready_r;
//////////////////////////////////////////////////
integer j;
// ===== Combinational Blocks ===== 
always_comb begin
    /*finish_w        = finish_r;
    state_w         = state_r;
    write_pos_w     = write_pos_r;
    current_idx_w   = current_idx_r;
    left_ready_w    = left_ready_r;
    right_ready_w   = right_ready_r;
    for (j = 0; j < 3; j=j+1) begin
        addr_right_buffer_w[j]      = addr_right_buffer_r[j];
        w_data_right_buffer_w[j]    = w_data_right_buffer_r[j];
        ia_data_right_buffer_w[j]   = ia_data_right_buffer_r[j];
        addr_left_buffer_w[j]       = addr_left_buffer_r[j];
        w_data_left_buffer_w[j]     = w_data_left_buffer_r[j];
        ia_data_left_buffer_w[j]    = ia_data_left_buffer_r[j];
    end*/

    case(state_r)
        S_IDLE: begin
            if (i_start) begin
                state_w = S_WRITE_RIGHT;
                if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[(current_idx_r+1)] == 0 && i_valid_buf[(current_idx_r+2)] == 0) begin
                    current_idx_w = current_idx_r + 3;
                end
                else begin
                    // Three cases
                    if (i_valid_buf[current_idx_r] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_w[write_pos_r] = i_w_data[current_idx_r]; // w_data
                        ia_data_right_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r]; // address
                        // step
                        current_idx_w = current_idx_r + 1;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_w[write_pos_r] = i_w_data[current_idx_r+1]; // w_data
                        ia_data_right_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+1]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+1]; // address
                        // step
                        current_idx_w = current_idx_r + 2;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_w[write_pos_r] = i_w_data[current_idx_r+2]; // w_data
                        ia_data_right_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+2]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+2]; // address
                        // step
                        current_idx_w = current_idx_r + 3;
                    end
                    write_pos_w = write_pos_r + 1;
                end
            end else begin
                right_ready_w = 0;
                left_ready_w = 0;
                finish_w = 0;
            end
        end

        S_WRITE_RIGHT: begin
            if (current_idx_r >= i_w_len) begin
                // reset
                if (write_pos_r == 0) begin
                    right_ready_w = 0;
                end else if (write_pos_r == 1) begin
                    ia_data_right_buffer_w[1] = 0;
                    w_data_right_buffer_w[1] = 0;
                    ia_data_right_buffer_w[2] = 0;
                    w_data_right_buffer_w[2] = 0;
                    right_ready_w = 1;
                end else if (write_pos_r == 2) begin
                    ia_data_right_buffer_w[2] = 0;
                    w_data_right_buffer_w[2] = 0;
                    right_ready_w = 1;
                end
                write_pos_w = 0;
                current_idx_w = 0;
                left_ready_w = 0; // change in different state
                // right_ready_w = 1; // change in different state
                finish_w = 1;
                state_w = S_IDLE;
            end else begin
                if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[(current_idx_r+1)] == 0 && i_valid_buf[(current_idx_r+2)] == 0) begin
                    current_idx_w = current_idx_r + 3;
                end
                else begin
                    // Three cases
                    if (i_valid_buf[current_idx_r] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_w[write_pos_r] = i_w_data[current_idx_r]; // w_data
                        ia_data_right_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r]; // address
                        // step
                        current_idx_w = current_idx_r + 1;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_w[write_pos_r] = i_w_data[current_idx_r+1]; // w_data
                        ia_data_right_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+1]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+1]; // address
                        // step
                        current_idx_w = current_idx_r + 2;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_w[write_pos_r] = i_w_data[current_idx_r+2]; // w_data
                        ia_data_right_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+2]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+2]; // address
                        // step
                        current_idx_w = current_idx_r + 3;
                    end

                    // Check ouptut state;
                    if (write_pos_r == 2) begin // finish a buffer
                        state_w = S_WRITE_LEFT;
                        left_ready_w = 0;
                        right_ready_w = 1;
                        write_pos_w = 0;
                    end else begin
                        left_ready_w = 0;
                        right_ready_w = 0;
                        write_pos_w = write_pos_r + 1;
                    end

                    
                end
            end        
        end

        S_WRITE_LEFT: begin
            if (current_idx_r >= i_w_len) begin
                // reset
                if (write_pos_r == 0) begin
                    left_ready_w = 0;
                end else if (write_pos_r == 1) begin
                    ia_data_left_buffer_w[1] = 0;
                    w_data_left_buffer_w[1] = 0;
                    ia_data_left_buffer_w[2] = 0;
                    w_data_left_buffer_w[2] = 0;
                    left_ready_w = 1;
                end else if (write_pos_r == 2) begin
                    ia_data_left_buffer_w[2] = 0;
                    w_data_left_buffer_w[2] = 0;
                    left_ready_w = 1;
                end
                write_pos_w = 0;
                current_idx_w = 0;
                // left_ready_w = 0; // change in different state
                right_ready_w = 0; // change in different state
                finish_w = 1;
                state_w = S_IDLE;
            end else begin
                if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 0) begin
                    current_idx_w = current_idx_r + 3;
                end
                else begin
                    // Three cases
                    if (i_valid_buf[current_idx_r] == 1) begin
                        // write left buffer at write_pos_r
                        w_data_left_buffer_w[write_pos_r] = i_w_data[current_idx_r]; // w_data
                        ia_data_left_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r]]; // ia data
                        addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r]; // address
                        // step
                        current_idx_w = current_idx_r + 1;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 1) begin
                        // write left buffer at write_pos_r
                        w_data_left_buffer_w[write_pos_r] = i_w_data[current_idx_r+1]; // w_data
                        ia_data_left_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+1]]; // ia data
                        addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+1]; // address
                        // step
                        current_idx_w = current_idx_r + 2;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 1) begin
                        // write left buffer at write_pos_r
                        w_data_left_buffer_w[write_pos_r] = i_w_data[current_idx_r+2]; // w_data
                        ia_data_left_buffer_w[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+2]]; // ia data
                        addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+2]; // address
                        // step
                        current_idx_w = current_idx_r + 3;
                    end

                    // Check ouptut state
                    if (write_pos_r == 2) begin // finish a buffer
                        state_w = S_WRITE_RIGHT;
                        left_ready_w = 1;
                        right_ready_w = 0;
                        write_pos_w = 0;
                    end else begin
                        left_ready_w = 0;
                        right_ready_w = 0;
                        write_pos_w = write_pos_r + 1;
                    end

                end
            end   
        end

        default: begin
            finish_w                    = finish_r;
            state_w                     = state_r;
            write_pos_w                 = write_pos_r;
            current_idx_w               = current_idx_r;
            left_ready_w                = left_ready_r;
            right_ready_w               = right_ready_r;
            addr_right_buffer_w         = addr_right_buffer_r;
            w_data_right_buffer_w       = w_data_right_buffer_r;
            ia_data_right_buffer_w      = ia_data_right_buffer_r;
            addr_left_buffer_w          = addr_left_buffer_r;
            w_data_left_buffer_w        = w_data_left_buffer_r;
            ia_data_left_buffer_w       = ia_data_left_buffer_r;

        end
    endcase
end

// ===== Sequential Blocks =====
integer p, q;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        finish_r        <= 0;
        state_r         <= S_IDLE;
        //$display("State_r in reset: %d", state_r);
        write_pos_r     <= 0;
        current_idx_r   <= 0;
        left_ready_r    <= 0;
        right_ready_r   <= 0;

        for (p = 0; p < 3; p=p+1) begin
            addr_right_buffer_r[p]      <= 0;
            w_data_right_buffer_r[p]    <= 0;
            ia_data_right_buffer_r[p]   <= 0;
            addr_left_buffer_r[p]       <= 0;
            w_data_left_buffer_r[p]     <= 0;
            ia_data_left_buffer_r[p]    <= 0;
        end
    end
    else begin
        finish_r        <= finish_w;
        state_r         <= state_w;
        //$display("State_r in ff: %d", state_r);
        //$display("State_w in ff: %d", state_w);

        write_pos_r     <= write_pos_w;
        current_idx_r   <= current_idx_w;
        left_ready_r    <= left_ready_w;
        right_ready_r   <= right_ready_w;

        addr_right_buffer_r      <= addr_right_buffer_w;
        w_data_right_buffer_r    <= w_data_right_buffer_w;
        ia_data_right_buffer_r   <= ia_data_right_buffer_w;
        addr_left_buffer_r       <= addr_left_buffer_w;
        w_data_left_buffer_r     <= w_data_left_buffer_w;
        ia_data_left_buffer_r    <= ia_data_left_buffer_w;
        /*
        for (q = 0; q < 3; q=q+1) begin
            addr_right_buffer_r[q]      <= addr_right_buffer_w[q];
            w_data_right_buffer_r[q]    <= w_data_right_buffer_w[q];
            ia_data_right_buffer_r[q]   <= ia_data_right_buffer_w[q];
            addr_left_buffer_r[q]       <= addr_left_buffer_w[q];
            w_data_left_buffer_r[q]     <= w_data_left_buffer_w[q];
            ia_data_left_buffer_r[q]    <= ia_data_left_buffer_w[q];
        end*/
    end
end

endmodule
