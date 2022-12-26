module Picture_Buffer(
    i_clk,
    i_rst_n,
    i_R,
    i_G,
    i_B,
    i_take,
	o_buf
    /*o_buf_R,
    o_buf_G,
    o_buf_B*/
);

input i_clk, i_rst_n, i_take;
input [9:0] i_R, i_G, i_B;
output [9:0] o_buf[0:2][0:15][0:15];

reg [9:0] buffer_r[0:2][0:15][0:15];
//[255:0][9:0] o_buf_R, o_buf_G, o_buf_B;
//reg o_bug_R[0:255], o_buf_G[0:255], o_buf_B[0:255];

reg [3:0] H_Cont, V_Cont;
assign o_buf = buffer_r;
//reg [7:0] Cont;


always@(posedge i_clk or negedge i_rst_n) // H_counter
begin
	if(!i_rst_n)
	begin
		H_Cont		<=	0;
	end
	else
	begin
		//	H_Sync Counter
		if( H_Cont <= 4'd15 && i_take == 1 )
		H_Cont	<=	H_Cont+1;

	end
end

always@(posedge i_clk or negedge i_rst_n) // V_counter
begin
	if(!i_rst_n)
	begin
		V_Cont		<=	0;
	end
	else
	begin
		//	When H_Sync Re-start
		if(H_Cont==15)
		begin
			//	V_Sync Counter
			if( V_Cont < 4'd15 && i_take == 1 )
			V_Cont	<=	V_Cont+1;
		end
	end
end

integer i, j;
always@(posedge i_clk or negedge i_rst_n) // o_buf
begin
	if(!i_rst_n) begin
        for(i=0; i<16; i=i+1) begin
            for(j=0; j<16; j=j+1) begin
				buffer_r[0][i][j] <=	0;
                buffer_r[1][i][j] <=	0;
                buffer_r[2][i][j] <=	0;
            end
        end
	end
    else begin
        if(i_take) begin
            buffer_r[0][V_Cont][H_Cont] <= i_R;
            buffer_r[1][V_Cont][H_Cont] <= i_G;
            buffer_r[2][V_Cont][H_Cont] <= i_B;
        end
        
    end
end

endmodule