`include "placement_top.v"
module testbench#(
    parameter grid_size = 9,
    parameter rand_width = 4,

    parameter max_edges_width = 8,

    parameter mem_edges_depth = 8,
    parameter mem_edges_width = 8,

    parameter mem_offset_depth = 6,
    parameter mem_offset_width = 4,

    parameter mem_position_depth = 7,
    parameter mem_position_width = 5,

    parameter mem_grid_depth = 7,
    parameter mem_grid_width = 8

)();
  reg clk, rst, start, loadseed;
  reg [32-1:0] seed;
  reg [max_edges_width-1:0] n_edge;

  initial begin
    clk = 0;
    rst = 0;
    start = 0;
    loadseed = 0;
    seed = 60879648823995;
    n_edge = 85;
    #1
    rst = 1;
    #3
    rst = 0;
    #1
    loadseed = 1;
    #1
    loadseed = 0;
    #1
    start = 1;
  end

  always #1 clk = ~clk;

  placement_top #(
  .grid_size(grid_size),
  .rand_width(rand_width),
  .max_edges_width(max_edges_width),
  .mem_edges_depth(mem_edges_depth),
  .mem_edges_width(mem_edges_width),
  .mem_offset_depth(mem_offset_depth),
  .mem_offset_width(mem_offset_width),
  .mem_position_depth(mem_position_depth),
  .mem_position_width(mem_position_width),
  .mem_grid_depth(mem_grid_depth),
  .mem_grid_width(mem_grid_width)
  ) p1 (
  .clk(clk),
  .rst(rst),
  .start(start),
  .loadseed(loadseed),
  .seed(seed),
  .n_edge(n_edge)
  );
endmodule
