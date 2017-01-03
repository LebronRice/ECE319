/*

 *Jeffrey Stewart
 *jls317@lehigh.edu
 *ECE319
 *Proj2
 
*/

module cpu(reset, clk, address, data, rd, wr);
 //declare input/output
 input reset, clk;
 inout [7:0] data;
 output rd, wr;
 output [15:0] address;

 wire[7:0] bus;
 assign bus = data;

 //Control Declarations
 //clock of registers to AND with system clk
 reg clkA, clkB, clkC, clkD, clkE, clkH, clkL, clkIR, clkPC, clkT1, clkT2;
 wire wclkA, wclkB, wclkC, wclkD, wclkE, wclkH, wclkL, wclkIR, wclkPC, wclkT1, wclkT2;
 //control of registers after AND
 wire Actrl, Bctrl, Cctrl, Dctrl, Ectrl, Hctrl, Lctrl, IRctrl, PCctrl, T1ctrl, T2ctrl;
 //controls of other structures
 wire muxCPActrl,  muxTempctrl, muxMemctrl;
 wire wTA, wTB, wTC, wTD, wTE, wTH, wTL, wmuxCPActrl, wmuxAddrctrl, wmuxTempctrl, wmuxMemctrl;
 wire muxAddrctrl;
 //RD and WR
 wire rd, wr;
 wire wrd, wwr;
 //Adder
 //reg [7:0] Addrctrl;
 wire [7:0] wAddrctrl;

 //Instruction Wires
 wire MOV_r_r, MOV_r_m, MOV_m_r, HLT, ADD_r, ADD_m, SUB_r, SUB_m, JMP, JNZ;
 wire JZ, STA, LDA, LXI, MVI, NOP, ORG;

//Architecture
 wire [15:0] address;
  
 //main registers (bus -> bus)
 //A
 //takes inA on Actrl
 reg [7:0] A;
 wire [7:0] inA, outCPA;
 mux2 #(8) M1(inA, {bus, outCPA}, muxCPActrl);
 always @(posedge Actrl or posedge reset)
	begin
		if(reset)
			A <= 8'd0;
		else
			A <= inA;
	end
 tristate #(8) triA(bus, A, wTA);
 
 //B
 //takes bus on Bctrl
 reg [7:0] B;
 always @(posedge Bctrl or posedge reset)
 	begin
		if(reset)
			B <= 8'd0;
		else
			B <= bus;
	end
 tristate #(8) triB(bus, B, wTB); 
 
 //C
 //takes bus on Cctrl
 reg [7:0] C;
 always @(posedge Cctrl or posedge reset)
	begin
		if(reset)
			C <= 8'd0;
		else
			C <= bus;
	end
 tristate #(8) triC(bus, C, wTC);
 
 //D
 //takes bus on Dctrl
 reg [7:0] D;
 always @(posedge Dctrl or posedge reset)
	begin
		if(reset)
			D <= 8'd0;
		else
			D <= bus;
	end
 tristate #(8) triD(bus, D, wTD);

 //E
 //takes bus on Ectrl
 reg [7:0] E;
 always @(posedge Ectrl or posedge reset)
	begin
		if(reset)
			E <= 8'd0;
		 else
			E <= bus;
	end
 tristate #(8) triE(bus, E, wTE);

 //H
 //takes bus on Hctrl
 reg [7:0] H;
 always @(posedge Hctrl or posedge reset)
	begin
		if(reset)
			H <= 8'd0;
		else
			H <= bus;
	end
 tristate #(8) triH(bus, H, wTH);
  
 //L
 //takes bus on Lctrl
 reg [7:0] L;
 always @(posedge Lctrl or posedge reset)
	begin
		if(reset)
			L <= 8'd0;
		else
			L <= bus;
	end
 tristate #(8) triL(bus, L, wTL);
 
 //CPA
 reg ZeroFlag;
 wire toZeroFlag;
 cpa #(8) cpaA(outCPA, out_c, A, bus^wAddrctrl, wAddrctrl);
 assign toZeroFlag = ~(outCPA[0] | outCPA[1] | outCPA[2] | outCPA[3] | outCPA[4] | outCPA[5] | outCPA[6] | outCPA[7]);
 always @(posedge muxCPActrl or posedge reset)
	begin
		if(reset)
			ZeroFlag <= 1'd0;
		else
			ZeroFlag <= toZeroFlag;
	end
 
 //IR
 reg [7:0] IR;
 wire [3:0] OP;
 wire [7:0] Dest, Src;
 always @(posedge IRctrl or posedge reset)
	begin
		if(reset)
			IR <= 8'b01000001;
		else
			IR <= bus;
	end



 //Temp Registers
 reg [7:0] T1, T2;
 always @(posedge T1ctrl or posedge reset)
	begin
		if(reset)
			T1 <= 8'd0;
 else
			T1 <= bus;
	end
 always @(posedge T2ctrl or posedge reset)
	begin
		if(reset)
			T2 <= 8'd0;
		else
			T2 <= bus;
	end

 //PC
 reg [15:0] PC;
 wire [15:0] outMuxTemp, address1, PCplus1;

 always @(posedge PCctrl or posedge reset)
	begin
		if(reset)
			PC <= 16'd0;
		else
			PC <= outMuxTemp;
	end
 assign PCplus1 = PC + 16'd1; 
 mux2 #(16) muxTemp(outMuxTemp, {PCplus1, {T1, T2}}, muxTempctrl);
 mux2 #(16) muxAddr(address1, {PC, {H,L}}, muxAddrctrl); 
 mux2 #(16) muxMem(address, {address1,{T1, T2}}, muxMemctrl);
 


//Controls
 //Step Counter and Decoder
 reg[2:0] stepCtr;
 wire [7:0] step;
 decode #(3) StepDecode(step, stepCtr);
 decode #(2) IRDecodeOP(OP, IR[7:6]);
 decode #(3) IRDecodeDest(Dest, IR[5:3]);
 decode #(3) IRDecodeSource(Src, IR[2:0]);
 always @(posedge clk or posedge reset)
	begin
	if(reset |NOP | (JZ & ~ZeroFlag) | (JNZ & ZeroFlag))
		stepCtr <= 3'd0;
else if((step[1] & (MOV_r_r | MOV_r_m | MOV_m_r | ADD_r | ADD_m | SUB_r | SUB_m | MVI)) | (step[3] & (JMP | JNZ | JZ | STA | LDA)) | (step[2] & (LXI))) 
		stepCtr <= 3'd0;
	else if(step[0] | (step[1] & HLT))
		stepCtr <= 3'd1;
	else if(step[5])
		stepCtr <= 3'd0;
	else
		stepCtr <= stepCtr + 3'd1;	
	end

 //Assign Instructions by OP, Dest, Src
 assign MOV_r_r = OP[1] & ~Dest[6] & ~Src[6];
 assign MOV_r_m = OP[1] & ~Dest[6] & Src[6];
 assign MOV_m_r = OP[1] & Dest[6] & ~Src[6];
 assign HLT = OP[1] & Dest[6] & Src[6];
 assign ADD_r = OP[2] & Dest[0] & ~Src[6];
 assign ADD_m = OP[2] & Dest[0] & Src[6];
 assign SUB_r = OP[2] & Dest[2] & ~Src[6];
 assign SUB_m = OP[2] & Dest[2] & Src[6];
 assign JMP = OP[3] & Dest[0] & Src[3];
 assign JNZ = OP[3] & Dest[0] & Src[2];
 assign JZ = OP[3] & Dest[1] & Src[2];
 assign STA = OP[0] & Dest[6] & Src[2];
 assign LDA = OP[0] & Dest[7] & Src[2];
 assign LXI = OP[0] & ~Dest[6] & Src[1];
 assign MVI = OP[0] & ~Dest[6] & Src[6];
 assign NOP = OP[0] & Dest[0] & Src[0];
 assign ORG = OP[1] & Dest[0] & Src[1];

 //Assign Register Clocks
 assign wclkA = (Dest[7] & (step[1] & (MOV_r_r | MOV_r_m | MVI))) | (step[1] & (ADD_r | ADD_m | SUB_r | SUB_m)) | (step[3] & LDA);
 assign wclkB = ((Dest[0]) & (((step[1] & (MOV_r_r | MOV_r_m | MVI)) | (step[1] & LXI))));
 assign wclkC = (Dest[1]) & ((step[1] & (MOV_r_r | MOV_r_m | MVI)) | (Dest[0] & step[2] & LXI));
 assign wclkD = (Dest[2]) & ((step[1] & (MOV_r_r | MOV_r_m | MVI)) | (step[1] & LXI));
 assign wclkE = (Dest[3]) & ((step[1] & (MOV_r_r | MOV_r_m | MVI)) | (Dest[2] & step[2] & LXI));
 assign wclkH = (Dest[4]) & ((step[1] & (MOV_r_r | MOV_r_m | MVI)) | (step[2] & LXI));
 assign wclkL = (Dest[5]) & ((step[1] & (MOV_r_r | MOV_r_m | MVI)) | (Dest[4] & step[1] & LXI));	
 assign wclkT1 = step[2] & (JMP | (JNZ & ~ZeroFlag) | (JZ & ZeroFlag) | LDA | STA);
 assign wclkT2 = step[1] & (JMP | (JNZ & ~ZeroFlag) | (JZ & ZeroFlag) | LDA | STA);
 assign wclkIR = step[0];
 assign wclkPC = step[0] | (step[1] & MVI) | ((step[1] | step[2]) & (STA | LDA | LXI)) | JMP | (JNZ & ~ZeroFlag) | (JZ & ZeroFlag);
 
 //Assign TriStates and Other Controls
 assign wTA = (Src[7]) & ((step[1] & (MOV_r_r | MOV_m_r | ADD_r | SUB_r)) | (step[3] & STA));
 assign wTB = (Src[0]) & ((step[1] & (MOV_r_r | MOV_r_m | ADD_r | SUB_r)));
 assign wTC = (Src[1]) & ((step[1] & (MOV_r_r | MOV_r_m | ADD_r | SUB_r)));
 assign wTD = (Src[2]) & ((step[1] & (MOV_r_r | MOV_r_m | ADD_r | SUB_r)));
 assign wTE = (Src[3]) & ((step[1] & (MOV_r_r | MOV_r_m | ADD_r | SUB_r)));
 assign wTH = (Src[4]) & ((step[1] & (MOV_r_r | MOV_r_m | ADD_r | SUB_r)));
 assign wTL = (Src[5]) & ((step[1] & (MOV_r_r | MOV_r_m | ADD_r | SUB_r)));
 assign wrd = step[0] | (step[1] & (MVI | MOV_r_m | ADD_m | SUB_m | LDA | LXI)) | ((step[1] | step[2]) & (STA | JMP | (JNZ & ~ZeroFlag) | LXI) | (JZ &
 ZeroFlag));
 assign wAddrctrl= {8{(step[1] & (SUB_r | SUB_m))}};
 assign wwr= ((step[3] & STA) | (step[1] & MOV_m_r));

 //MUX Logic
 assign wmuxCPActrl  = ~(step[1] & (ADD_r | ADD_m | SUB_r | SUB_m));
 assign muxAddrctrl = ~(
(step[0] &~clk & (MOV_r_m | MOV_m_r))|
(step[1] & MOV_m_r & clk)| 
(step[1] & MOV_r_m | ADD_m | SUB_m)
);
 assign wmuxTempctrl = ((step[3] & (JMP | (JNZ & ~ZeroFlag) | (JZ & ZeroFlag) | STA | LDA)));
 assign wmuxMemctrl  = ((step[3] & (STA | LDA | LXI)));

 //Mux and Rd/Wr controls
	assign muxCPActrl = wmuxCPActrl;
	assign muxTempctrl = ~(wmuxTempctrl);
	assign muxMemctrl = ~(wmuxMemctrl);
	assign rd = ~(wrd & clk);
 	assign wr = ~(wwr & clk);
 //Register Controls
	assign Actrl = wclkA & ~clk;
	assign Bctrl = wclkB & ~clk;
        assign Cctrl = wclkC & ~clk;
	assign Dctrl = wclkD & ~clk;
	assign Ectrl = wclkE & ~clk;
	assign Hctrl = wclkH & ~clk;
	assign Lctrl = wclkL & ~clk;
	assign IRctrl = wclkIR & ~clk;
	assign PCctrl = wclkPC & ~clk;
	assign T1ctrl = wclkT1 & ~clk;
	assign T2ctrl = wclkT2 & ~clk;
endmodule

module test_proj2;         // test bench for the module cpu
  wire reset, clock;       // reset and clock inputs to cpu
  wire [15:0] address;     // 16 address lines from cpu
  tri [7:0] data;          // 8 bidirectional data lines from cpu
  wire rd, wr;             // rd and wr signals from cpu for memory
  wire [9:0] ram_address;
   
  reg [7:0] ram_mem[0:1023]; // we only implement 1 KByte memory in the
                           // test bench, even if CPU can address 64 KBytes

  /* MEMORY */
   assign   ram_address = address[9:0];  // use only 10 bit address for ram
   
  // output data when rd is low (logic 0)
  // (rd is active low: normal state = logic 1)
  tristate #(8) ram_tristate(data, ram_mem[ram_address], ~rd);

  // write data to memory at the end of low pulse on wr 
  // (wr is active low: normal state = logic 1)
  always @(posedge wr)
     ram_mem[ram_address] <= data;

  initial
    $readmemh("/home/jls317/ECE319/project2/Prog2.dat", ram_mem);
   
  /* GENERATE CLOCK AN RESET FOR THE CPU */
  init test_init(reset, clock);

  /* INSTANTIATE cpu */ 
  cpu my_cpu(reset, clock, address, data, rd, wr);
   
endmodule
