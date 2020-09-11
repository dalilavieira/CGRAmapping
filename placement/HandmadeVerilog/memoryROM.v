module memoryROM #(
  parameter init_file = "mem_file.txt",
  parameter data_depth = 5,
  parameter data_width = 5
)(
  input clk,
  input read,
  input [data_depth-1:0] addr,
  output reg signed [data_width-1:0] data
);

  reg signed [data_width-1:0] memROM [(2**data_depth)-1:0];

  always @ (posedge clk) begin
    if(read) begin
      data <= memROM[addr];
    end
  end

  initial begin
    data = 0;
    $readmemb(init_file, memROM, 0, (2**data_depth)-1);
  end
endmodule
