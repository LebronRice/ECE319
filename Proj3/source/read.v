module read (addr, data);
  input  [6:0] addr;
  output [7:0] data;

  reg [7:0] read_memory[0:127];

  initial
     $readmemh("/home/jls317/ECE319/project3/proj3/read.dat",read_memory);

  assign data = read_memory[addr];
endmodule

  // The rom data (in hex) is in file read.dat
  // Make sure addr_reg is initialized to 7'd4
  // output z1 = bit 4 of rom data output
  // output z2 = bit 3 of rom data output
  // output z3 = bit 2 of rom data output
  // output z4 = bit 1 of rom data output
  // output z5 = bit 0 of rom data output
  // Modify addr_reg to {data[7:5], x1, x2, x3, x4}
