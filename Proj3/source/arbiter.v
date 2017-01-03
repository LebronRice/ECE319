module arbiter (addr, data);
  input  [4:0] addr;
  output [4:0] data;

  reg [4:0] arbiter_memory[0:31];

  initial
     $readmemh("/home/jls317/ECE319/project3/proj3/arbiter.dat",arbiter_memory);

  assign data = arbiter_memory[addr];
endmodule

  // The rom data (in hex) is in file arbiter.dat
  // Make sure addr_reg is initialized to 5'd3
  // output z1 = bit 1 of rom data output
  // output z2 = bit 0 of rom data output
  // Modify addr_reg to {data[4:2], x1, x2}
