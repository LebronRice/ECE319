/*  	Project 3
	ECE 319
	
	Jeffrey Stewart
	11/27/2016
*/

module proj3(port1, dready1, dack1, port2, dready2, dack2, port3, dready3, dreq3, clock4, reset);
   input[7:0] port1, port2;
   output [7:0] port3;
   input 	clock4, reset, dready1, dready2, dreq3;
   output 	dack1, dack2, dready3;
   reg [7:0] 	OUT;
   assign port3 = OUT;
   //FIFO Registers
   reg [7:0] 	R0, R1, R2, R3, R4, R5, R6, R7;
   wire [7:0] 	toReg;
   
   
   //Arbiter Variables
   wire 	treq1, treq2, tgrant1, tgrant2, tgrant;
   
   
   //WRITE variables
   //outputs
   wire 	wr1, wr2, wr, inc_WR1, inc_WR2, inc_WR, setFull1, setFull2, setFull, resetEmpty1, resetEmpty2, resetEmpty;
   assign wr = wr1 | wr2;
   assign inc_WR = inc_WR1 | inc_WR2;
   assign setFull = setFull1 | setFull2;
   assign resetEmpty = resetEmpty1 | resetEmpty2;
   assign tgrant = tgrant1 ^ tgrant2;
   
      
   //inputs
   wire 	full_empty; //full_empty tells whether the FIFO is full or empty but not which.
   reg 		full, empty;
   
//READ variables
   //outputs
wire rd, inc_RD, setEmpty, resetFull;
   //inputs
   //instantiated in write
   //wire full, empty, full_empty
   
   always @(posedge setFull or posedge reset)
     begin
	if(reset)
	  full <= 1'd0;
	else
	  full <= 1'd1;
     end
   always @(posedge resetFull or posedge reset)
     begin
	if(reset)
	  full <= 1'd0;
	else
	  full <= 1'd0;
     end
   
   always @(posedge setEmpty or posedge resetEmpty or posedge reset)
     begin
	if(reset)
	  empty <= 1'd1;
	else
	  empty <= 1'd1;
     end
   always @(posedge resetEmpty or posedge reset)
     begin
	if(reset)
	  empty <= 1'd1;	
	else
	  empty <= 1'd0;
     end
   
   
   //Architecture
   //clock controls for registers
   wire R0clk, R1clk, R2clk, R3clk, R4clk, R5clk, R6clk, R7clk;
   wire OUTclk;
   assign OUTclk = rd;
   //AND clk with clock4 to be ready for use
   wire R0ctrl, R1ctrl, R2ctrl, R3ctrl, R4ctrl, R5ctrl, R6ctrl, R7ctrl;
   
   wire OUTctrl;
   assign R0ctrl = R0clk & clock4;
   assign R1ctrl = R1clk & clock4;
   assign R2ctrl = R2clk & clock4;
   assign R3ctrl = R3clk & clock4;
   assign R4ctrl = R4clk & clock4;
   assign R5ctrl = R5clk & clock4;
   assign R6ctrl = R6clk & clock4;
   assign R7ctrl = R7clk & clock4;
   assign OUTctrl = OUTclk & clock4;
   
   //tristates
   //uses decoder output of the read block
   wire [7:0] toOut;
   wire [7:0] T;
   tristate T0(toOut, R0, T[0]);
   tristate T1(toOut, R1, T[1]);
   tristate T2(toOut, R2, T[2]);
   tristate T3(toOut, R3, T[3]);
   tristate T4(toOut, R4, T[4]);
   tristate T5(toOut, R5, T[5]);
   tristate T6(toOut, R6, T[6]);
   tristate T7(toOut, R7, T[7]);
   
   //registers
   always @(posedge R0ctrl or posedge reset)
     begin
	if(reset)
	  R0 <= 8'd0;
	else
	  R0 <= toReg;
     end
   
   always @(posedge R1ctrl or posedge reset)
     begin	
	if(reset)
	  R1 <= 8'd0;
	else
	  R1 <= toReg;
     end
   
   always @(posedge R2ctrl or posedge reset)
     begin
	if(reset)
	  R2 <= 8'd0;
	else
	  R2 <= toReg;
     end
   
   always @(posedge R3ctrl or posedge reset)
     begin	
	if(reset)
	  R3 <= 8'd0;
	else
	  R3 <= toReg;
     end
   
   always @(posedge R4ctrl or posedge reset)
     begin
	if(reset)
	  R4 <= 8'd0;
	else
	  R4 <= toReg;
     end
   
   always @(posedge R5ctrl or posedge reset)
     begin
	if(reset)
	  R5 <= 8'd0;
	else
	  R5 <= toReg;
     end
   
   always @(posedge R6ctrl or posedge reset)
     begin
	if(reset)
	  R6 <= 8'd0;
	else
	  R6 <= toReg;
     end
   
   always @(posedge R7ctrl or posedge reset)
     begin	
	if(reset)
	  R7 <= 8'd0;
	else
	  R7 <= toReg;
     end
   
   always @(posedge OUTctrl or posedge reset)
     begin
	if(reset)
	  OUT <= 8'd0;
	else
	  OUT <= toOut;
     end
   
   //mux1 for retrieving correct input
   mux2 inMux(toReg, {port1,port2}, tgrant1);
   
   
   
   //wr_ptr counter and decoder
   wire wr_ptrctrl;
   assign wr_ptrctrl = inc_WR;
   reg [2:0] wr_ptr;
   wire [7:0] r;
   always @(posedge wr_ptrctrl or posedge reset)
     begin
	if(reset)
	  wr_ptr <= 3'd7;
	else if(wr_ptr == 3'd7)
	  wr_ptr <= 3'd0;
	else
	  wr_ptr <= wr_ptr + 3'd1;
     end
   decode wr_decoder(r, wr_ptr); //decodes 3 bit binary (wr_ptr) to 8 bit dec
   //generate clk controls for registers
   assign R7clk = inc_WR & r[7];
   assign R6clk = inc_WR & r[6];
   assign R5clk = inc_WR & r[5];
   assign R4clk = inc_WR & r[4];
   assign R3clk = inc_WR & r[3];
   assign R2clk = inc_WR & r[2];
   assign R1clk = inc_WR & r[1];
   assign R0clk = inc_WR & r[0];
   
   //rd_ptr counter and decoder
   wire rd_ptrctrl;
   assign rd_ptrctrl = inc_RD;
   reg [2:0] rd_ptr;
   
   always @(posedge rd_ptrctrl or posedge reset)
     begin
	if(reset)
	  rd_ptr <= 3'd0;
	else if(rd_ptr == 3'd7)
	  rd_ptr <= 3'd0;
	else
	  rd_ptr <= rd_ptr + 3'd1;
     end
   //decodes 3bit binary (rd_ptr) to 8 bit decimal (T)
   //T controls activation of tristates
   decode rd_decoder(T, rd_ptr); 
   
   //comparator to determine full_empty
   assign full_empty = (wr_ptr[2] == rd_ptr[0]&
			wr_ptr[0] == rd_ptr[1]&
			wr_ptr[1] == rd_ptr[2]);

   
   //WRITE LOGIC BLOCK
   //includes: Arbiter, System A Write Logic, System B Write Logic
   
   //Arbiter:
   //input(~treq1, ~treq2)
   //output(tgrant1, tgrant2)
   reg [4:0] arbiter_addr;
   wire [4:0] arbiter_data;
   arbiter myArbiter(arbiter_addr, arbiter_data);
   always @(posedge reset or negedge clock4)
     begin
	if(reset)
	  arbiter_addr <= 5'd3;
	else
	  arbiter_addr <= {arbiter_data[4:2], treq1, treq2};
     end
   
   assign tgrant1 = arbiter_data[1];
   assign tgrant2 = arbiter_data[0];
   
   
   
   //System A Write Logic
   //input(~dready1, full, empty, tgrant1, full_empty)
   //output(~dack1, wr, inc_WR, setFull, resetEmpty, treq1)
   reg [7:0] writeA_addr;
   wire [8:0] writeA_data;
    write writeA(writeA_addr, writeA_data);
   always @(posedge reset or negedge clock4)
     begin
	if(reset)
	  writeA_addr <= 8'd8;
	else
	  writeA_addr <= {writeA_data[8:6], dready1, full, empty, tgrant1, full_empty};
     end
  
   assign dack1 	= writeA_data[5];
   assign wr1 	= writeA_data[4];
   assign inc_WR1 	= writeA_data[3];
   assign setFull1 	= writeA_data[2];
   assign resetEmpty1 = writeA_data[1];
   assign treq1 	=~writeA_data[0];
   
   
   //System B Write Logic
   //input(~dready2, full, empty, tgrant2, full_empty)
   //output(~dack2, wr, inc_WR, setFull, resetEmpty, treq2)
   reg [7:0] writeB_addr;
   wire [8:0] writeB_data;
   write writeB(writeB_addr, writeB_data);
   always @(posedge reset or negedge clock4)
     begin
	if(reset)
	  writeB_addr <= 8'd8;
	else
	  writeB_addr <= {writeB_data[8:6], dready2, full, empty, tgrant2, full_empty};
     end
   
   assign dack2 	= writeB_data[5];
   assign wr2 	        = writeB_data[4];
   assign inc_WR2 	= writeB_data[3];
   assign setFull2 	= writeB_data[2];
   assign resetEmpty2    = writeB_data[1];
   assign treq2 	= ~writeB_data[0];
   
   
   
   //READ LOGIC BLOCK
   //includes: System C Logic
   //input(dreq, empty, full, full_empty)
   //output(dready3, rd, inc_RD, setEmpty, resetFull)
   reg [6:0] readC_addr;
   wire [7:0] readC_data;
   read readC(readC_addr, readC_data);
   always @(posedge reset or negedge clock4)
     begin
	if(reset)
	  readC_addr <= 7'd4;
	else
	  readC_addr <= {readC_data[7:5], dreq3, empty, full, full_empty};
     end
   
   assign dready3 	= readC_data[4];
   assign rd	= readC_data[3];
   assign inc_RD	= readC_data[2];
   assign setEmpty	= readC_data[1];
   assign resetFull= readC_data[0];
   
endmodule

module proj3_test;
   wire [7:0] port1, port2, port3, Rfinal;
   wire   dready1, dack1, dready2, dack2, dreq3, dready3;
   wire reset, clk1, clk2, clk3, clk4;
   clocks myclocks(reset, clk1, clk2, clk3, clk4);
   writeSystem1 sys_A(reset, clk1, dack1, dready1, port1);
   writeSystem2 sys_B(reset, clk2, dack2, dready2, port2);
   readSystem3 sys_C(reset, clk3, dreq3, dready3, port3, Rfinal);

   proj3 myProj3(port1, dready1, dack1, port2, dready2, dack2, port3, dready3, dreq3, clk4, reset);
   

endmodule


module writeSystem1(reset, clock1, dack1, dready1, port1);
   output dready1, port1;
   input  reset, clock1, dack1;
   reg [1:0] state;
   wire      write_data;
   reg [7:0] port1;
   reg eof;
   integer data_file;

   //read data file
   initial
     begin
	data_file = $fopen("/home/jls317/ECE319/project3/proj3/systemA.dat","rb");
     end
 
   always @(posedge clock1 or posedge reset)
     begin
	if(reset)
	  state <= 2'b10;
	else if(dack1 & (state == 2'b10))
	  state <= 2'b11;
	else if(state == 2'b11)
	  state <= 2'b00;
	else if(~dack1 & (state == 2'b00))
	  state <= 2'b10;
	else
	  state <= state;	
     end // always @ (posedge clock or posedge reset)
     
   assign dready1 = state[1];
   assign write_data = state[0];
   always @(posedge write_data)
     begin
	eof = $feof(data_file);
	if (eof == 0)
	  $fscanf(data_file, "%d", port1);
	else 
	  begin
	     $fclose(data_file);
	     $finish;
	  end
     end
endmodule

   
module writeSystem2(reset, clock2, dack2, dready2, port2);
   output dready2, port2;
   input  reset, clock2, dack2;
   reg [1:0] state;
   wire      write_data;
   reg [7:0] port2;
   reg eof;
   integer data_file;
   //read data file
   initial
     begin
	data_file = $fopen("/home/jls317/ECE319/project3/proj3/systemB.dat","rb");
     end
   
   always @(posedge clock2 or posedge reset)
     begin
	if(reset)
	  state <= 2'b10;
	else if(dack2 & (state == 2'b10))
	  state <= 2'b11;
	else if(state == 2'b11)
	  state <= 2'b00;
	else if(~dack2 & (state == 2'b00))
	  state <= 2'b10;
	else
	  state <= state;	
     end 
   assign dready2 = state[1];
   assign write_data = state[0];
   always @(posedge write_data)
     begin
	eof = $feof(data_file);
	if (eof == 0)
	  $fscanf(data_file, "%d", port2);
	else 
	  begin
	     $fclose(data_file);
	     $finish;
	  end
     end
endmodule // writeSystem2

module readSystem3(reset, clock3, dreq3, dready3, port3, Rfinal);
   output dreq3, Rfinal;
   input  reset, clock3, dready3;
   input [7:0] port3;
   reg [1:0] state;
   wire     read_data;
   reg [7:0] Rfinal;
   always @(posedge clock3 or posedge reset)
     begin
	if(reset)
	  state <= 2'b10;
	else if(dready3 & (state == 2'b10))
	  state <= 2'b00;
	else if(~dready3 & (state ==2'b00))
	  state <= 2'b01;
	else if(state == 2'b01)
	  state <= 2'b10;
	else
	  state <= state;
     end

   
   always @(posedge read_data or posedge reset)
     begin
	if(reset)
	  Rfinal <= 8'd0;
	else
	  Rfinal <= port3;
     end
   
  
	   
   assign dreq3 = state[1];
   assign read_data = state[0];
endmodule


module clocks(reset, clk1, clk2, clk3, clk4);
   // provides a reset signal and four independent clocks
   output reset, clk1, clk2, clk3, clk4;
   reg 	  clk1, clk2, clk3, clk4;
   reg [8:0] X;
   wire      clk;
   
   init clocks_init(reset, clk);
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  X <= 9'd1;
	  clk1 <= 1'd0;
	  clk4 <= 1'd0;
       end
     else
       begin
	  clk1 <= X[1] & X[3];
	  clk4 <= X[4] & X[6] & ~X[7];
	  X <= {X[7:0], 1'b0}^{4'b0000, X[8], 3'b000, X[8]};
	  // corresponds to primitive polynomial
	  // x^9 + x^4 + 1
       end
   always @(posedge ~clk or posedge reset)
     if (reset)
       begin
	  clk2 <= 1'd0;
	  clk3 <= 1'd0;
       end
     else
       begin
	  clk2 <= X[1] & ~X[2] & ~X[4];
	  clk3 <= X[0] & ~X[5];
       end
   
endmodule // clocks