module write (addr, data);
  input  [7:0] addr;
  output [8:0] data;

  reg [8:0] write_memory[0:255];

  initial
     $readmemh("/home/jls317/ECE319/project3/proj3/write.dat",write_memory);

  assign data = write_memory[addr];
endmodule

  // The rom data (in hex) is in file write.dat
  // Make sure addr_reg is initialized to 8'd8
  // output z1 = bit 5 of rom data output
  // output z2 = bit 4 of rom data output
  // output z3 = bit 3 of rom data output
  // output z4 = bit 2 of rom data output
  // output z5 = bit 1 of rom data output
  // output z6 = bit 0 of rom data output
  // Modify addr_reg to {data[8:6], x1, x2, x3, x4, x5}
