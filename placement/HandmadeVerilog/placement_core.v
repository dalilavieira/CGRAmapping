module placement_core#(
    parameter grid_size = 4,
    parameter rand_width = 3,

    parameter max_edges_width = 8,

    parameter mem_edges_depth = 8,
    parameter mem_edges_width = 8,

    parameter mem_offset_depth = 6,
    parameter mem_offset_width = 4,

    parameter mem_position_depth = 7,
    parameter mem_position_width = 5,

    parameter mem_grid_depth = 7,
    parameter mem_grid_width = 8

)(
    input clk,
    input reset,
    input start,
    input [max_edges_width-1:0]n_edge,

    //Interface with edge memory!
    output reg rd_en_edges,
    output reg [mem_edges_depth-1:0]addr_edges,
    input signed [mem_edges_width*2 -1:0]rd_edges_data,

    //Interface with offset memory!
    output reg rd_en_offset,
    output reg [mem_offset_depth-1:0] addr_offset,
    input signed [mem_offset_width*8 -1:0]rd_offset_data,

    //Interface with position memory!
    output reg rd_en_mem_position,
    output reg wr_en_mem_position,
    output reg [mem_position_depth-1:0] addr_mem_position,
    output signed [mem_position_width*2 -1:0]wr_mem_position_data,
    input signed [mem_position_width*2 -1:0]rd_mem_position_data,

    //Interface with grid memory!
    output reg rd_en_mem_grid,
    output reg wr_en_mem_grid,
    output reg [mem_grid_depth-1:0] addr_mem_grid,
    output signed [mem_grid_width-1:0]wr_mem_grid_data,
    input signed [mem_grid_width-1:0]rd_mem_grid_data,

    //Interface with random number generator!
    //output reg loadseed,
    output reg next_rand,
    input [32-1:0] rnd_num,

    output reg result,
    output reg done
);
	//Local parameters of states:
	localparam FSM_init0 = 0, FSM_init1 = 1, FSM_init2 = 2, FSM_init3 = 3, FSM_init4 = 4;
	localparam FSM_reMem0 = 5, FSM_reMem1 = 6, FSM_reMem2 = 7, FSM_reMem3 = 8, FSM_reMem4 = 9;
	localparam FSM_posA0 = 10, FSM_posA1 = 11, FSM_posA2 = 12, FSM_posA3 = 13, FSM_posA4 = 14, FSM_posA5 = 15, FSM_posA6 = 16, FSM_posA7 = 17;
	localparam FSM_posB0 = 18, FSM_posB1 = 19, FSM_posB2 = 20, FSM_posB3 = 21, FSM_posB4 = 22, FSM_posB5 = 23;
	localparam FSM_eval0 = 24, FSM_eval1 = 25;
	localparam FSM_exit = 26, FSM_waitState = 27;
	//Local parameters of algorithm:
	localparam size_offset = 62, WALK = 4;
	//Inputs and outputs of memories:
  	wire signed [mem_offset_width-1:0] outOX1, outOX2, outOX3, outOX4, outOY1, outOY2, outOY3, outOY4;
	wire signed [mem_position_width-1:0] outPX, outPY;
	reg signed [mem_position_width-1:0] dinPX, dinPY;
	wire signed [mem_grid_width-1:0] outGrid;
	reg signed [mem_grid_width-1:0] dinGrid;
	wire signed [mem_edges_width-1:0] a, b;
	//Registers and wires:
	reg [6-1:0] state, next_state;
	reg [mem_edges_depth-1:0] i;
	reg [mem_offset_depth-1:0] j;
	reg signed [7-1:0] pos_a_X, pos_a_Y, pos_b_X, pos_b_Y;
	reg signed [32-1:0] diff_pos_x, diff_pos_y;
	reg signed [7-1:0] aux1, aux2;
	reg signed [7-1:0] xi, xj;
	reg signed [32-1:0] sum, sum_1hop;
	reg [3-1:0] k;
	wire [32-1:0] rnd_number;
	reg [32-1:0] cont, cic_aresta;

	always @(posedge clk) begin
		if(reset) begin
			state <= FSM_init0; next_state <= FSM_init0;
			sum <= 0; sum_1hop <= 0; next_rand <= 0;
			rd_en_edges <= 0; rd_en_offset <= 0;
			rd_en_mem_grid <= 0; rd_en_mem_position <= 0;
			wr_en_mem_grid <= 0; wr_en_mem_position <= 0;
			addr_edges <= 0; addr_offset <= 0;
			addr_mem_grid <= 0; addr_mem_position <= 0;
			result <= 1'b1; cont <= 0; cic_aresta <= 0;
			done <= 1'b0;
		end
		else if(start) begin
			rd_en_edges <= 0; rd_en_offset <= 0;
			rd_en_mem_grid <= 0; rd_en_mem_position <= 0;
			wr_en_mem_grid <= 0; wr_en_mem_position <= 0;
			cont <= cont + 1;
			//State machine:
			case (state)
				FSM_init0: begin
					rd_en_edges <= 1; addr_edges <= 0;
					next_rand <= 1;
					state <= FSM_waitState;
					next_state <= FSM_init1;
				end
				FSM_init1: begin
					wr_en_mem_position <= 1; addr_mem_position <= a;
          			dinPX <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number);
					state <= FSM_init2;
				end
				FSM_init2: begin
          			next_rand <= 0;
					wr_en_mem_position <= 1; addr_mem_position <= a;
          			dinPY <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number);
					state <= FSM_init3;
				end
				FSM_init3: begin
          			next_rand <= 1;
					rd_en_mem_position <= 1; addr_mem_position <= a;
					i <= 0;
					j <= 0;
					state <= FSM_waitState;
					next_state <= FSM_init4;
				end
				FSM_init4: begin
          			next_rand <= 0;
					wr_en_mem_grid <= 1; addr_mem_grid <= outPX*grid_size+outPY;
					$write("%1d:%1d,%1d\n", a, outPX, outPY);
					dinGrid <= a;
					diff_pos_x <= outPX; diff_pos_y <= outPY;
					state <= FSM_reMem0;
				end
				FSM_reMem0: begin
					cic_aresta <= 1;
					if(i == n_edge) begin
						i <= 0;
						state <= FSM_exit;
					end
					else begin
						rd_en_edges <= 1; addr_edges <= i;
						state <= FSM_waitState;
						next_state <= FSM_reMem1;
					end
				end
				FSM_reMem1: begin
					cic_aresta <= cic_aresta + 1;
					//$display("A = %d / B = %d", a, b);
					rd_en_mem_position <= 1; addr_mem_position <= a;
					state <= FSM_waitState;
					next_state <= FSM_reMem2;
				end
				FSM_reMem2: begin
					cic_aresta <= cic_aresta + 1;
					pos_a_X <= outPX;
					pos_a_Y <= outPY;
					state <= FSM_reMem3;
					next_state <= FSM_reMem4;
				end
				FSM_reMem3: begin
					cic_aresta <= cic_aresta + 1;
					rd_en_mem_position <= 1; addr_mem_position <= b;
					state <= FSM_waitState;
				end
				FSM_reMem4: begin
					cic_aresta <= cic_aresta + 1;
					pos_b_X <= outPX;
					pos_b_Y <= outPY;
					if(i==0) begin
						state <= FSM_posB0;
					end
					else begin
						state <= FSM_posA0;
					end
				end
				FSM_posA0: begin
					cic_aresta <= cic_aresta + 1;
					if(pos_a_X != -1) begin
						state <= FSM_posB0;
            			diff_pos_x <= pos_a_X; diff_pos_y <= pos_a_Y;
				 		j <= 0;
			  		end
					else begin
            			next_rand <= 1;
						k <= rnd_number % WALK;
            			rd_en_offset <= 1; addr_offset <= j;
						state <= FSM_waitState;
						next_state <= FSM_posA1;
					end
				end
				FSM_posA1: begin
					cic_aresta <= cic_aresta + 1;
         	 		next_rand <= 0;
					if(pos_b_X != -1) begin
						if(k == 0) begin
							xi <= pos_b_X + outOX1;
							xj <= pos_b_Y + outOY1;
						end
						else if(k == 1) begin
							xi <= pos_b_X + outOX2;
							xj <= pos_b_Y + outOY2;
						end
						else if(k == 2) begin
							xi <= pos_b_X + outOX3;
							xj <= pos_b_Y + outOY3;
						end
						else if(k == 3) begin
							xi <= pos_b_X + outOX4;
							xj <= pos_b_Y + outOY4;
						end
						state <= FSM_posA4;
					end
					else begin
						state <= FSM_posA2;
					end
				end
				FSM_posA2: begin
					cic_aresta <= cic_aresta + 1;
          			next_rand <= 1;
					if(k == 0) begin
						xi <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number) + outOX1;
					end
					else if(k == 1) begin
						xi <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number) + outOX2;
					end
					else if(k == 2) begin
						xi <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number) + outOX3;
					end
					else if(k == 3) begin
						xi <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number) + outOX4;
					end
					state <= FSM_waitState;
					next_state <= FSM_posA3;
				end
				FSM_posA3: begin
					cic_aresta <= cic_aresta + 1;
					if(k == 0) begin
						xj <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number) + outOY1;
					end
					else if(k == 1) begin
						xj <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number) + outOY2;
					end
					else if(k == 2) begin
						xj <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number) + outOY3;
					end
					else if(k == 3) begin
						xj <= ((rnd_number > grid_size) ? rnd_number-grid_size : rnd_number) + outOY4;
					end
					state <= FSM_posA4;
				end
				FSM_posA4: begin
					cic_aresta <= cic_aresta + 1;
          			next_rand <= 0;
					j <= j + 1;
					aux1 <= xi*grid_size+xj;
					state <= FSM_posA5;
				end
				FSM_posA5: begin
					cic_aresta <= cic_aresta + 1;
					rd_en_mem_grid <= 1; addr_mem_grid <= aux1;
					state <= FSM_waitState;
					next_state <= FSM_posA6;
				end
				FSM_posA6: begin
					cic_aresta <= cic_aresta + 1;
					aux2 <= outGrid;
					state <= FSM_posA7;
				end
				FSM_posA7: begin
					cic_aresta <= cic_aresta + 1;
					if(aux2 == -1 && xi < grid_size && xi >= 0 && xj < grid_size && xj >= 0) begin
						wr_en_mem_grid <= 1; addr_mem_grid <= aux1; dinGrid <= a;
						$write("%1d:%1d,%1d\n", a, xi, xj);
						pos_a_X <= xi;
						pos_a_Y <= xj;
						wr_en_mem_position <= 1; addr_mem_position <= a;
						dinPX <= xi; dinPY <= xj;
						diff_pos_x <= xi; diff_pos_y <= xj;
						state <= FSM_posB0;
						j <= 0;
					end
					else if(pos_a_X == -1) begin
						state <= FSM_posA0;
					end
					if(j > size_offset) begin
						$display("No solution\n");
						result <= 1'b0;
						state <= FSM_exit;
					end
				end
				FSM_posB0: begin
					if(pos_b_X != -1) begin
						$write("(%1d,%1d): %1d\n", a, b, cic_aresta+1);
            			diff_pos_x <= diff_pos_x - pos_b_X; diff_pos_y <= diff_pos_y - pos_b_Y;
						state <= FSM_eval0;
            			next_state <= FSM_reMem0;
						j <= 0;
						i <= i + 1;
					end
					else begin
						cic_aresta <= cic_aresta + 1;
            			next_rand <= 1;
						k <= rnd_number % WALK;
            			rd_en_offset <= 1; addr_offset <= j;
						state <= FSM_waitState;
						next_state <= FSM_posB1;
					end
				end
				FSM_posB1: begin
					cic_aresta <= cic_aresta + 1;
          			next_rand <= 0;
					if(k == 0) begin
						xi <= pos_a_X + outOX1;
						xj <= pos_a_Y + outOY1;
					end
					else if(k == 1) begin
						xi <= pos_a_X + outOX2;
						xj <= pos_a_Y + outOY2;
					end
					else if(k == 2) begin
						xi <= pos_a_X + outOX3;
						xj <= pos_a_Y + outOY3;
					end
					else if(k == 3) begin
						xi <= pos_a_X + outOX4;
						xj <= pos_a_Y + outOY4;
					end
					state <= FSM_posB2;
				end
				FSM_posB2: begin
					cic_aresta <= cic_aresta + 1;
					aux1 <= xi*grid_size+xj;
					state <= FSM_posB3;
				end
				FSM_posB3: begin
					cic_aresta <= cic_aresta + 1;
					j <= j + 1;
					rd_en_mem_grid <= 1; addr_mem_grid <= aux1;
					state <= FSM_waitState;
					next_state <= FSM_posB4;
				end
				FSM_posB4: begin
					cic_aresta <= cic_aresta + 1;
					aux2 <= outGrid;
					state <= FSM_posB5;
				end
				FSM_posB5: begin
					cic_aresta <= cic_aresta + 1;
					if(aux2 == -1 && xi < grid_size && xi >= 0 && xj < grid_size && xj >= 0) begin
						wr_en_mem_grid <= 1; addr_mem_grid <= aux1; dinGrid <= b;
						$write("%1d:%1d,%1d\n", b, xi, xj);
						$write("(%1d,%1d): %1d\n", a, b, cic_aresta+1);
						pos_b_X <= xi;
						pos_b_Y <= xj;
						wr_en_mem_position <= 1; addr_mem_position <= b;
            			dinPX <= xi;
						dinPY <= xj;
            			diff_pos_x <= diff_pos_x - xi; diff_pos_y <= diff_pos_y - xj;
						j <= 0;
						i <= i + 1;
            			state <= FSM_eval0;
            			next_state <= FSM_reMem0;
					end
					else if(pos_b_X == -1) begin
						state <= FSM_posB0;
					end
					if(j > size_offset) begin
						$display("No solution\n");
						result <= 1'b0;
						state <= FSM_exit;
					end
				end
				FSM_eval0: begin
					if(diff_pos_x < 0) begin
						diff_pos_x <= (diff_pos_x ^ (32'b11111111111111111111111111111111)) + 1;
					end
          			if(diff_pos_y < 0) begin
						diff_pos_y <= (diff_pos_y ^ (32'b11111111111111111111111111111111)) + 1;
					end
					state <= FSM_eval1;
				end
				FSM_eval1: begin
					sum <= sum + diff_pos_x + diff_pos_y - 1;
					sum_1hop <= sum_1hop + ((diff_pos_x >> 1) + diff_pos_x[0]) + ((diff_pos_y >> 1) + diff_pos_y[0]) - 1;
					state <= next_state;
				end
				FSM_exit: begin
					done <= 1'b1;
					$write("\nEvaluation:%1d\nEvaluation 1-hop:%1d\n", sum, sum_1hop);
          			$write("Cycles:%1d\n", cont);
					$finish;
				end
				FSM_waitState: begin
					cic_aresta <= cic_aresta + 1;
					state <= next_state;
				end
			endcase
		end
	end

  	assign rnd_number = rnd_num[rand_width-1:0];
  	assign outOX1 = rd_offset_data[mem_offset_width-1:0];
	assign outOX2 = rd_offset_data[(mem_offset_width*2)-1:mem_offset_width];
  	assign outOX3 = rd_offset_data[(mem_offset_width*3)-1:mem_offset_width*2];
  	assign outOX4 = rd_offset_data[(mem_offset_width*4)-1:mem_offset_width*3];
  	assign outOY1 = rd_offset_data[(mem_offset_width*5)-1:mem_offset_width*4];
	assign outOY2 = rd_offset_data[(mem_offset_width*6)-1:mem_offset_width*5];
  	assign outOY3 = rd_offset_data[(mem_offset_width*7)-1:mem_offset_width*6];
  	assign outOY4 = rd_offset_data[(mem_offset_width*8)-1:mem_offset_width*7];
	assign a = rd_edges_data[mem_edges_width-1:0];
	assign b = rd_edges_data[mem_edges_width*2-1:mem_edges_width];
	assign outPX = rd_mem_position_data[mem_position_width-1:0];
	assign outPY = rd_mem_position_data[mem_position_width*2 -1:mem_position_width];
	assign wr_mem_position_data[mem_position_width-1:0] = dinPX;
	assign wr_mem_position_data[mem_position_width*2 -1:mem_position_width] = dinPY;
	assign outGrid = rd_mem_grid_data;
	assign wr_mem_grid_data = dinGrid;
endmodule
