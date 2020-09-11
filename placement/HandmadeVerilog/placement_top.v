`include "memoryROM.v"
`include "memoryRAM.v"
`include "random.v"
`include "placement_core.v"

module placement_top #(
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
    input rst,
    input start,
    input loadseed,
    input [32-1:0] seed,
    input [max_edges_width-1:0] n_edge
);
    //Inputs and outputs of placement!
    // wire clk;
    // wire rst;
    // wire start;
    wire result, done;
    //wire [max_edges_width-1:0] n_edge;
    //Inputs and outputs of memories!
    wire rd_en_edges, rd_en_offset, rd_en_mem_position, rd_en_mem_grid;
    wire wr_en_mem_position, wr_en_mem_grid;
    wire [mem_edges_depth-1:0] addr_edges;
    wire [mem_offset_depth-1:0] addr_offset;
    wire [mem_position_depth-1:0] addr_mem_position;
    wire [mem_grid_depth-1:0] addr_mem_grid;
    wire [mem_edges_width*2 -1:0] rd_edges_data;
    wire [mem_offset_width*8 -1:0] rd_offset_data;
    wire [mem_position_width*2 -1:0] wr_mem_position_data;
    wire [mem_position_width*2 -1:0] rd_mem_position_data;
    wire [mem_grid_width-1:0] wr_mem_grid_data;
    wire [mem_grid_width-1:0] rd_mem_grid_data;
    //Inputs and outputs of random number generator!
    wire next_rand;
    wire [32-1:0] rnd_num;/*seed;*/
    //wire loadseed;

    placement_core#(
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
    ) place_inst (
    .clk(clk),
    .reset(rst),
    .start(start),
    .n_edge(n_edge),
    .rd_en_edges(rd_en_edges),
    .addr_edges(addr_edges),
    .rd_edges_data(rd_edges_data),
    .rd_en_offset(rd_en_offset),
    .addr_offset(addr_offset),
    .rd_offset_data(rd_offset_data),
    .rd_en_mem_position(rd_en_mem_position),
    .wr_en_mem_position(wr_en_mem_position),
    .addr_mem_position(addr_mem_position),
    .wr_mem_position_data(wr_mem_position_data),
    .rd_mem_position_data(rd_mem_position_data),
    .rd_en_mem_grid(rd_en_mem_grid),
    .wr_en_mem_grid(wr_en_mem_grid),
    .addr_mem_grid(addr_mem_grid),
    .wr_mem_grid_data(wr_mem_grid_data),
    .rd_mem_grid_data(rd_mem_grid_data),
    .next_rand(next_rand),
    .rnd_num(rnd_num),
    .result(result),
    .done(done)
    );

    random rand_gen (
    .clk(clk),
    .reset(rst),
    .loadseed_i(loadseed),
    .seed_i(seed),
    .next_rand(next_rand),
    .number_o(rnd_num)
    );

    memoryROM #(
    .init_file("edgeData.txt"),
    .data_depth(mem_edges_depth),
    .data_width(mem_edges_width*2)
    ) edges (
    .clk(clk),
    .read(rd_en_edges),
    .addr(addr_edges),
    .data(rd_edges_data)
    );

    memoryROM #(
    .init_file("offsetData.txt"),
    .data_depth(mem_offset_depth),
    .data_width(mem_offset_width*8)
    ) offsets (
    .clk(clk),
    .read(rd_en_offset),
    .addr(addr_offset),
    .data(rd_offset_data)
    );

    memoryRAM #(
    .init_file("positionData.txt"),
    .data_depth(mem_position_depth),
    .data_width(mem_position_width*2)
    ) pos (
    .clk(clk),
    .read(rd_en_mem_position),
    .write(wr_en_mem_position),
    .addr(addr_mem_position),
    .dataRead(rd_mem_position_data),
    .dataWrite(wr_mem_position_data)
    );

    memoryRAM #(
    .init_file("gridData.txt"),
    .data_depth(mem_grid_depth),
    .data_width(mem_grid_width)
    ) grid (
    .clk(clk),
    .read(rd_en_mem_grid),
    .write(wr_en_mem_grid),
    .addr(addr_mem_grid),
    .dataRead(rd_mem_grid_data),
    .dataWrite(wr_mem_grid_data)
    );
endmodule
