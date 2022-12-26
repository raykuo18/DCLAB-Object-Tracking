`define ADDR_LEN 200
`define IA_C_LEN 1199
`define W_C_LEN 1199


module VPEncoder(
    input                   i_clk,
    input                   i_rst_n,
    //////////////// input (7) ////////////////
    input                   i_start,
    // W channel index length
    input [$clog2(`W_C_LEN)-1:0]  i_w_len,
    // Address buffer
    input [2:0][6:0]        i_addr_buf[0:`W_C_LEN-1], // N * (x, y, k)
    // V-P buffer
    input                   i_valid_buf[0:`ADDR_LEN],
    input [8:0]             i_pos_buf[0:`ADDR_LEN],
    // data
    input signed [15:0]     i_ia_data[0:`IA_C_LEN],
    input signed [15:0]     i_w_data[0:`W_C_LEN],

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
    output                  o_finish;         
);

/////////////////// State ///////////////////
localparam          S_IDLE = 2'd0;
localparam          S_WRITE_RIGHT = 2'd1;
localparam          S_WRITE_LEFT = 2'd2;

logic               finish_r, finish_w;
logic [1:0]         state_r, state_w;
logic [1:0]         write_pos_r, write_pos_w;
logic [4:0]         current_idx_r, current_idx_w;

/////////////////// output var ///////////////////
logic [6:0]         addr_right_buffer_r[0:2]    , addr_right_buffer_w[0:2];
logic signed [15:0] w_data_right_buffer_r[0:2]  , w_data_right_buffer_w[0:2];
logic signed [15:0] ia_data_right_buffer_r[0:2] , ia_data_right_buffer_w[0:2];
logic [6:0]         addr_left_buffer_r[0:2]     , addr_left_buffer_w[0:2];
logic signed [15:0] w_data_left_buffer_r[0:2]   , w_data_left_buffer_w[0:2];
logic signed [15:0] ia_data_left_buffer_r[0:2]  , ia_data_left_buffer_w[0:2];

always_comb begin
    for (int i = 0; i < 3; i++) begin 
        o_addr_right_buffer[i]       = addr_right_buffer_r[i];
        o_w_data_right_buffer[i]     = w_data_right_buffer_r[i];
        o_ia_data_right_buffer[i]    = ia_data_right_buffer_r[i];
        o_addr_left_buffer[i]        = addr_left_buffer_r[i];
        o_w_data_left_buffer[i]      = w_data_left_buffer_r[i];
        o_ia_data_left_buffer[i]     = ia_data_left_buffer_r[i];
    end
end

logic left_ready_r, left_ready_w;
logic right_ready_r, right_ready_w;

assign o_left_ready = left_ready_r;
assign o_right_ready = right_ready_r;
//////////////////////////////////////////////////

// ===== Combinational Blocks ===== 
always_comb begin
    finish_w        = finish_r;
    state_w         = state_r;
    write_pos_w     = write_pos_r;
    current_idx_w   = current_idx_r;
    left_ready_w    = left_ready_r;
    right_ready_w   = right_ready_r;
    for (int i = 0; i < 3; i++) begin
        addr_right_buffer_w[i]      = addr_right_buffer_r[i];
        w_data_right_buffer_w[i]    = w_data_right_buffer_r[i];
        ia_data_right_buffer_w[i]   = ia_data_right_buffer_r[i];
        addr_left_buffer_w[i]       = addr_left_buffer_r[i];
        w_data_left_buffer_w[i]     = w_data_left_buffer_r[i];
        ia_data_left_buffer_w[i]    = ia_data_left_buffer_r[i];
    end

    case(state_r)
        S_IDLE: begin
            if (i_start) begin
                state_w = S_WRITE_RIGHT;

                if (current_idx_r >= i_w_len) begin
                    // reset
                    write_pos_w = 0;
                    current_idx_w = 0;
                    left_ready_w = 0; // change in different state
                    right_ready_w = 0; // change in different state
                    state_w = S_IDLE;
                end else begin
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 0) begin
                        current_idx_w = current_idx_r + 3;
                    end
                    else begin
                        // Three cases
                        if (i_valid_buf[current_idx_r] == 1) begin
                            // write left buffer at write_pos_r
                            w_data_left_buffer_r[write_pos_r] = i_w_data[current_idx_r]; // w_data
                            ia_data_left_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r]]; // ia data
                            addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r]; // address
                            // step
                            current_idx_w = current_idx_r + 1;
                        end
                        if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 1) begin
                            // write left buffer at write_pos_r
                            w_data_left_buffer_r[write_pos_r] = i_w_data[current_idx_r+1]; // w_data
                            ia_data_left_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+1]]; // ia data
                            addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+1]; // address
                            // step
                            current_idx_w = current_idx_r + 2;
                        end
                        if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 1) begin
                            // write left buffer at write_pos_r
                            w_data_left_buffer_r[write_pos_r] = i_w_data[current_idx_r+2]; // w_data
                            ia_data_left_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+2]]; // ia data
                            addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+2]; // address
                            // step
                            current_idx_w = current_idx_r + 3;
                        end

                        // Check ouptut state
                        if (write_pos_r == 2) begin // finish a buffer
                            left_ready_w = 1;
                            right_ready_w = 0;
                        end else begin
                            // Vary in different state
                        end
                    end
                end
            end else begin
                // reset
                write_pos_w = 0;
                current_idx_w = 0;
                left_ready_w = 0; // change in different state
                right_ready_w = 0;
            end
        end

        S_WRITE_RIGHT: begin
            if (current_idx_r >= i_w_len) begin
                // reset
                if (write_pos_r == 0) begin
                    right_ready_w = 0;
                end else if (write_pos_r == 1) begin
                    ia_data_right_buffer_r[1] = 0;
                    ia_data_right_buffer_r[2] = 0;
                    right_ready_w = 1;
                end else if (write_pos_r == 2) begin
                    ia_data_right_buffer_r[2] = 0;
                    right_ready_w = 1;
                end
                write_pos_w = 0;
                current_idx_w = 0;
                left_ready_w = 0; // change in different state
                // right_ready_w = 1; // change in different state
                state_w = S_IDLE;
            end else begin
                if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 0) begin
                    current_idx_w = current_idx_r + 3;
                end
                else begin
                    // Three cases
                    if (i_valid_buf[current_idx_r] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_r[write_pos_r] = i_w_data[current_idx_r]; // w_data
                        ia_data_right_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r]; // address
                        // step
                        current_idx_w = current_idx_r + 1;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_r[write_pos_r] = i_w_data[current_idx_r+1]; // w_data
                        ia_data_right_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+1]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+1]; // address
                        // step
                        current_idx_w = current_idx_r + 2;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 1) begin
                        // write right buffer at write_pos_r
                        w_data_right_buffer_r[write_pos_r] = i_w_data[current_idx_r+2]; // w_data
                        ia_data_right_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+2]]; // ia data
                        addr_right_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+2]; // address
                        // step
                        current_idx_w = current_idx_r + 3;
                    end

                    // Check ouptut state;
                    if (write_pos_r == 2) begin // finish a buffer
                        left_ready_w = 0;
                        right_ready_w = 1;
                    end else begin
                        left_ready_w = 0;
                        right_ready_w = 0;
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
                    ia_data_left_buffer_r[1] = 0;
                    ia_data_left_buffer_r[2] = 0;
                    left_ready_w = 1;
                end else if (write_pos_r == 2) begin
                    ia_data_left_buffer_r[2] = 0;
                    left_ready_w = 1;
                end
                write_pos_w = 0;
                current_idx_w = 0;
                // left_ready_w = 0; // change in different state
                right_ready_w = 0; // change in different state
                state_w = S_IDLE;
            end else begin
                if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 0) begin
                    current_idx_w = current_idx_r + 3;
                end
                else begin
                    // Three cases
                    if (i_valid_buf[current_idx_r] == 1) begin
                        // write left buffer at write_pos_r
                        w_data_left_buffer_r[write_pos_r] = i_w_data[current_idx_r]; // w_data
                        ia_data_left_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r]]; // ia data
                        addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r]; // address
                        // step
                        current_idx_w = current_idx_r + 1;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 1) begin
                        // write left buffer at write_pos_r
                        w_data_left_buffer_r[write_pos_r] = i_w_data[current_idx_r+1]; // w_data
                        ia_data_left_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+1]]; // ia data
                        addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+1]; // address
                        // step
                        current_idx_w = current_idx_r + 2;
                    end
                    if (i_valid_buf[current_idx_r] == 0 && i_valid_buf[current_idx_r+1] == 0 && i_valid_buf[current_idx_r+2] == 1) begin
                        // write left buffer at write_pos_r
                        w_data_left_buffer_r[write_pos_r] = i_w_data[current_idx_r+2]; // w_data
                        ia_data_left_buffer_r[write_pos_r] = i_ia_data[i_pos_buf[current_idx_r+2]]; // ia data
                        addr_left_buffer_w[write_pos_r] = i_addr_buf[current_idx_r+2]; // address
                        // step
                        current_idx_w = current_idx_r + 3;
                    end

                    // Check ouptut state
                    if (write_pos_r == 2) begin // finish a buffer
                        left_ready_w = 1;
                        right_ready_w = 0;
                    end else begin
                        left_ready_w = 0;
                        right_ready_w = 0;
                    end
                end
            end   
        end

        default: begin
            
        end
    endcase
end

// ===== Sequential Blocks =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        finish_r        = 0;
        state_r         = S_IDLE;
        write_pos_r     = 0;
        current_idx_r   = 0;
        left_ready_r    = 0;
        right_ready_r   = 0;

        for (int i = 0; i < 3; i++) begin
            addr_right_buffer_r[i]      = 0;
            w_data_right_buffer_r[i]    = 0;
            ia_data_right_buffer_r[i]   = 0;
            addr_left_buffer_r[i]       = 0;
            w_data_left_buffer_r[i]     = 0;
            ia_data_left_buffer_r[i]    = 0;
        end
    end
    else begin
        finish_r        = finish_w;
        state_r         = state_w;
        write_pos_r     = write_pos_w;
        current_idx_r   = current_idx_w;
        left_ready_r    = left_ready_w;
        right_ready_r   = right_ready_w;

        for (int i = 0; i < 3; i++) begin
            addr_right_buffer_r[i]      = addr_right_buffer_w[i];
            w_data_right_buffer_r[i]    = w_data_right_buffer_w[i];
            ia_data_right_buffer_r[i]   = ia_data_right_buffer_w[i];
            addr_left_buffer_r[i]       = addr_left_buffer_w[i];
            w_data_left_buffer_r[i]     = w_data_left_buffer_w[i];
            ia_data_left_buffer_r[i]    = ia_data_left_buffer_w[i];
        end
    end
end

endmodule
