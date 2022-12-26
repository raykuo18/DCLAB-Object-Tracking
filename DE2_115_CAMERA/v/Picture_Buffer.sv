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
output reg o_bug[0:2][0:15][0:15];
//[255:0][9:0] o_buf_R, o_buf_G, o_buf_B;
//reg o_bug_R[0:255], o_buf_G[0:255], o_buf_B[0:255];

reg [3:0] H_Cont, V_Cont;
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
		else
		H_Cont	<=	0;
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
		if(H_Cont==0)
		begin
			//	V_Sync Counter
			if( V_Cont <= 4'd15 && i_take == 1 )
			V_Cont	<=	V_Cont+1;
			else
			V_Cont	<=	0;
		end
	end
end
/*
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
	begin
		Cont		<=	0;
	end
    else
	begin
		if( Cont <= 8'd255 && i_take == 1 )
		Cont	<=	Cont+1;
	end
end
integer i;
always@(posedge i_clk or negedge i_rst_n) // o_buf
begin
	if(!i_rst_n) begin
        for(i=0; i<256; i=i+1) begin
            o_buf_R[i] <=	0;
            o_buf_G[i] <=	0;
            o_buf_B[i] <=	0;
        end
	end
    else begin
        if(i_take) begin
            o_buf_R[Cont] <= i_R;
            o_buf_G[Cont] <= i_G;
            o_buf_B[Cont] <= i_B;
        end
        //else o_buf <= o_buf;
    end
end
*/
integer i, j;
always@(posedge i_clk or negedge i_rst_n) // o_buf
begin
	if(!i_rst_n) begin
        for(i=0; i<16; i=i+1) begin
            for(j=0; j<16; j=j+1) begin
				o_buf[0][i][j] <=	0;
                o_buf[1][i][j] <=	0;
                o_buf[2][i][j] <=	0;
            end
        end
	end
    else begin
        if(i_take) begin
            o_buf[0][V_Cont][H_Cont] <= i_R;
            o_buf[1][V_Cont][H_Cont] <= i_G;
            o_buf[2][V_Cont][H_Cont] <= i_B;
        end
        //else o_buf <= o_buf;
    end
end*/

endmodule