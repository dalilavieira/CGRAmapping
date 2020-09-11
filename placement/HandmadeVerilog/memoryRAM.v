module memoryRAM #(
  parameter init_file = "mem_file.txt",
  parameter data_depth = 5,
  parameter data_width = 5
)(
  input clk,
  input read,
  input write,
  input [data_depth-1:0] addr,
  input signed [data_width-1:0] dataWrite,
  output reg signed [data_width-1:0] dataRead
);

  reg signed [data_width-1:0] memRAM [(2**data_depth)-1:0];
  reg [32-1:0] i, j;
  always @ (posedge clk) begin
  	if(read) begin
  	  dataRead <= memRAM[addr];
  	end
    if(write) begin
  	  memRAM[addr] <= dataWrite;
  	end
	  // $display();
    // for(i=0; i<data_depth; i++) begin
    //   for(j=0; j<data_depth; j++) begin
    //       $write("%4d", memRAM[i*data_depth+j]);
    //   end
    //   $display();
    // end
  end
  
  initial begin
    dataRead = 0;
    $readmemb(init_file, memRAM, 0, (2**data_depth)-1);
  end
endmodule
