/*
 Jeffrey Stewart
 ECE319
 Project 4
 12/04/2016
*/




module array_multiplier(product, in1, in2);
//takes 2 inputs of 16 bit length and returns product of 16 bit length
   input [15:0] in1, in2;
   output [15:0] product;
   wire [14:0] s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16;
   wire [14:0] c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, cout;
   csa #(15) csa1(s1, c1, {15{in1[0]}} & in2[15:1], {15{in1[1]}} & in2[14:0], 15'd0);
   csa #(15) csa2(s2, c2, {15{in1[2]}} & in2[14:0], {in1[1] & in2[15], s1[14:1]}, c1);
   csa #(15) csa3(s3, c3, {15{in1[3]}} & in2[14:0], {in1[2] & in2[15], s2[14:1]}, c2);
   csa #(15) csa4(s4, c4, {15{in1[4]}} & in2[14:0], {in1[3] & in2[15], s3[14:1]}, c3);
   csa #(15) csa5(s5, c5, {15{in1[5]}} & in2[14:0], {in1[4] & in2[15], s4[14:1]}, c4);
   csa #(15) csa6(s6, c6, {15{in1[6]}} & in2[14:0], {in1[5] & in2[15], s5[14:1]}, c5);
   csa #(15) csa7(s7, c7, {15{in1[7]}} & in2[14:0], {in1[6] & in2[15], s6[14:1]}, c6);
   csa #(15) csa8(s8, c8, {15{in1[8]}} & in2[14:0], {in1[7] & in2[15], s7[14:1]}, c7);
   csa #(15) csa9(s9, c9, {15{in1[9]}} & in2[14:0], {in1[8] & in2[15], s8[14:1]}, c8);
   csa #(15) csa10(s10, c10, {15{in1[10]}} & in2[14:0], {in1[9] & in2[15], s9[14:1]}, c9);
   csa #(15) csa11(s11, c11, {15{in1[11]}} & in2[14:0], {in1[10] & in2[15], s10[14:1]}, c10);
   csa #(15) csa12(s12, c12, {15{in1[12]}} & in2[14:0], {in1[11] & in2[15], s11[14:1]}, c11);
   csa #(15) csa13(s13, c13, {15{in1[13]}} & in2[14:0], {in1[12] & in2[15], s12[14:1]}, c12);
   csa #(15) csa14(s14, c14, {15{in1[14]}} & in2[14:0], {in1[13] & in2[15], s13[14:1]}, c13);
   csa #(15) csa15(s15, c15, {15{in1[15]}} & in2[14:0], {in1[14] & in2[15], s14[14:1]}, c14);
   cpa #(15) cpa16(s16, cout, {in1[15]&in2[15], s15[14:1]}, c15, 1'd0);
   assign product = {s15[0], s14[0], s13[0], s12[0], s11[0], s10[0], s9[0], s8[0], s7[0], s6[0], s5[0], s4[0], s3[0], s2[0], s1[0], in1[0] & in2[0]};
endmodule // array_multiplier




module sign_extend_4to16(out16, in4);
//takes 4 bit input and extends sign to 16 bit output
   input [3:0] in4;
   output [15:0] out16;
   assign out16 = {{12{in4[3]}}, in4};
endmodule // sign_extend_4to16




module PolyPipe(clock, reset, const0, const1, const2, const3, in, out);
   input clock, reset;
   input [3:0] const0, const1, const2, const3, in;
   output [15:0] out;
   reg [15:0] 	 a0, a1, a2, a3;
   wire [15:0] 	 a0extend, a1extend, a2extend, a3extend, x;
   
   sign_extend_4to16 SE0(a0extend, const0);
   sign_extend_4to16 SE1(a1extend, const1);
   sign_extend_4to16 SE2(a2extend, const2);
   sign_extend_4to16 SE3(a3extend, const3);
   sign_extend_4to16 SEx(x, in);
   
   always @(posedge reset)
     begin
	a0 <= a0extend;
	a1 <= a1extend;
	a2 <= a2extend;
	a3 <= a3extend;
     end
   
   
   //architecture initialization
   reg [15:0] x1, x2, x3, x4, H1, H2, R1, T1, T2, out;
   wire [15:0] mult1_xmux_out, mult2_xmux_out,  mult1_mux_out, mult2_mux_out, R1_mux_out, adder_mux_out, adder_mux_out2;
   wire [15:0] mult1_out, mult2_out, adder_out, cout;
   //control initialization
   reg [3:0]   mod12counter;
   reg	       x1_clk, x2_clk, x3_clk, x4_clk, R1_clk, out_clk;
   wire        x1_ctrl, x2_ctrl, x3_ctrl, x4_ctrl, H1_ctrl, H2_ctrl, T1clk, T1_ctrl, T2clk, T2_ctrl, out_ctrl;
   reg 	       mult1_mux_ctrl, mult2_mux_ctrl, mult1_xmux_ctrl, mult2_xmux_ctrl, R1_mux_ctrl, adder_mux_ctrl, adder_mux_ctrl2;
   
   //architecture------------------------------------------------------------------------------------------------------
   //multipliers-------------------------------------------------------------------------------------------------------
   //mult1
   always @(posedge x1_ctrl or posedge reset)
     begin
	if(reset)
	  x1 <= 16'd0;
	else
	  x1 <= x;
     end
   always @(posedge x2_ctrl or posedge reset)
     begin
	if(reset)
	  x2 <= 16'd0;
	else
	  x2 <= x;
     end
   mux2 #(16) mult1_xmux(mult1_xmux_out, {x1, x2}, mult1_xmux_ctrl);
   mux2 #(16) mult1_mux(mult1_mux_out, {a3, T2}, mult1_mux_ctrl);
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  H1 <= 16'd0;
	else
	  H1 <= mult1_mux_out;
     end
   array_multiplier mult1(mult1_out, mult1_xmux_out, H1);
   //mult2
   //X3 and X4
   always @(posedge x3_ctrl or posedge reset)
     begin
	if(reset)
	  x3 <= 16'd0;
	else
	  x3 <= x;
     end
   always @(posedge x4_ctrl or posedge reset)
     begin
	if(reset)
	  x4 <= 16'd0;
	else
	  x4 <= x;
     end
   mux2 #(16) mult2_xmux(mult2_xmux_out, {x3, x4}, mult2_xmux_ctrl);
   mux2 #(16) mult2_mux(mult2_mux_out, {a3, T2}, mult2_mux_ctrl);
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  H2 <= 16'd0;
	else
	  H2 <= mult2_mux_out;
     end
   array_multiplier mult2(mult2_out, mult2_xmux_out, H2);
   //adder----------------------------------------------------------------------------------------------------------
   mux2 #(16) R1_mux(R1_mux_out, {mult1_out, mult2_out}, R1_mux_ctrl);
   
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  R1 <= 16'd0;
	else
	  R1 <= R1_mux_out;
     end
   mux2 #(16) adder_mux2(adder_mux_out2, {a1, a2}, adder_mux_ctrl2);
   mux2 #(16) adder_mux1(adder_mux_out, {a0, adder_mux_out2}, adder_mux_ctrl);
   cpa #(16) adder(adder_out, cout, R1, adder_mux_out, 1'd0); //adder_out = R1 + adder_mux_out
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  T1 <= 16'd0;
	else
	  T1 <= adder_out;
     end
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  T2 <= 16'd0;
	else
	  T2 <= T1;
     end
   always @(posedge out_ctrl or posedge reset)
     begin
	if(reset)
	  out <= 16'd0;
	else if(out_ctrl)
	  out <= adder_out;
     end
   //controls------------------------------------------------------------------------------------------------------
   //counters-----------------------------------
   always @(negedge clock or posedge reset)
     begin
	if(reset)
	  mod12counter <= 4'd11;
	else if(mod12counter == 4'd11)
	  mod12counter <= 4'd0;
	else
	  mod12counter <= mod12counter + 4'd1;
     end
   //input X registers-------------------------
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  x1_clk <= 1'd0;
	else if(mod12counter == 4'd0)
	  x1_clk <= 1'd1;
	else
	  x1_clk <= 1'd0;
     end
   assign x1_ctrl = x1_clk & clock;
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  x2_clk <= 1'd0;
	else if(mod12counter == 4'd6)
	  x2_clk <= 1'd1;
	else
	  x2_clk <= 1'd0;
     end
   assign x2_ctrl = x2_clk & clock;
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  x3_clk <= 1'd0;
	else if(mod12counter == 4'd3)
	  x3_clk <= 1'd1;
	else
	  x3_clk <= 1'd0;
     end
   assign x3_ctrl = x3_clk & clock;
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  x4_clk <= 1'd0;
	else if(mod12counter == 4'd9)
	  x4_clk <= 1'd1;
	else
	  x4_clk <= 1'd0;
     end
   assign x4_ctrl = x4_clk & clock;
   
   //mult1 muxes----------------------------------
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  mult1_xmux_ctrl <= 1'd1;
	else if(mod12counter == 4'd0 |
		mod12counter == 4'd1 |
		mod12counter == 4'd4 |
		mod12counter == 4'd5 |
		mod12counter == 4'd8 |
		mod12counter == 4'd9)
	  mult1_xmux_ctrl <= 1'd1;
	else
	  mult1_xmux_ctrl <= 1'd0;
     end // always @ (posedge clock or posedge reset)
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  mult1_mux_ctrl <= 1'd1;
	else if(mod12counter == 4'd0 |
		mod12counter == 4'd1 |
		mod12counter == 4'd6 |
		mod12counter == 4'd7)
	  mult1_mux_ctrl <= 1'd1;
	else
	  mult1_mux_ctrl <= 1'd0;
     end // always @ (posedge clock or posedge reset)
   //mult2 muxes----------------------------------
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  mult2_xmux_ctrl <= 1'd0;
	else if(mod12counter == 4'd0 |
		mod12counter == 4'd3 |
		mod12counter == 4'd4 |
		mod12counter == 4'd7 |
		mod12counter == 4'd8 |
		mod12counter == 4'd11)
	  mult2_xmux_ctrl <= 1'd1;
	else
	  mult2_xmux_ctrl <= 1'd0;
     end // always @ (posedge clock or posedge reset)
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  mult2_mux_ctrl <= 1'd0;
	else if(mod12counter == 4'd3 |
		mod12counter == 4'd4 |
		mod12counter == 4'd9 |
		mod12counter == 4'd10)
	  mult2_mux_ctrl <= 1'd1;
	else
	  mult2_mux_ctrl <= 1'd0;
     end // always @ (posedge clock or posedge reset)
   //R1 mux--------------------------------------
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  R1_mux_ctrl <= 1'd0;
	else if(mod12counter == 4'd1 |
		mod12counter == 4'd3 |
		mod12counter == 4'd5 |
		mod12counter == 4'd7 |
		mod12counter == 4'd9 |
		mod12counter == 4'd11)
	  R1_mux_ctrl <= 1'd1;
	else
	  R1_mux_ctrl <= 1'd0;
     end // always @ (posedge clock or posedge reset)
   
   //adder muxes---------------------------------
   //adder_mux_ctrl
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  adder_mux_ctrl <= 1'd0;
	else if(mod12counter == 4'd1 |
		mod12counter == 4'd4 |
		mod12counter == 4'd7 |
		mod12counter == 4'd10)
	  adder_mux_ctrl <= 1'd1;
	else
	  adder_mux_ctrl <= 1'd0;
     end // always @ (posedge clock or posedge reset)
   //adder_mux_ctrl2
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  adder_mux_ctrl2 <= 1'd0;
	else if(mod12counter == 4'd2 |
		mod12counter == 4'd5 |
		mod12counter == 4'd8 |
		mod12counter == 4'd11)
	  adder_mux_ctrl2 <= 1'd0;
	else
	  adder_mux_ctrl2 <= 1'd1;
     end // always @ (posedge clock or posedge reset)
   //out register control------------------------
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  out_clk <= 1'd0;
	else if(mod12counter == 4'd2 |
		mod12counter == 4'd5 |
		mod12counter == 4'd8 |
		mod12counter == 4'd11)
	  out_clk <= 1'd1;
	else
	  out_clk <= 1'd0;
     end // always @ (posedge clock or posedge reset)
   assign out_ctrl = out_clk & clock & ((mod12counter == 4'd2) |
					(mod12counter == 4'd5) |
					(mod12counter == 4'd8) |
					(mod12counter == 4'd11));
   
   
endmodule // PolyPipe


module test_PolyPipe;
   wire clock, reset;
   wire [15:0] out;
   reg [3:0]  x;
   wire [3:0]  a0, a1, a2, a3;
   reg 	       eof;
   integer     data_file;
   reg [1:0]   counter;
   
   init i(reset, clock);
   
   assign a0 = 4'd5;
   assign a1 = 4'd1;
   assign a2 = 4'd2;
   assign a3 = 4'd3;

   initial
     begin
	data_file = $fopen("/home/jls317/ECE319/project4/proj4.dat","rb");
     end
   always @(posedge clock or posedge reset)
     begin
	if(reset)
	  counter <= 2'd0;
	else if(counter == 2'd2)
	  counter <= 2'd0;
	else
	  counter <= counter + 2'd1;
     end
   
   always @(posedge clock)
     begin
	if(counter ==  2'd0)
	  begin
	     eof = $feof(data_file);
	     if(eof == 0)
	       $fscanf(data_file, "%d", x);
	     else
	       begin
		  $fclose(data_file);
		  $finish;
	       end
	  end
     end // always @ (posedge clock)
   
   PolyPipe myPolyPipe(clock, reset, a0, a1, a2, a3, x, out);
endmodule // test_PolyPipe
