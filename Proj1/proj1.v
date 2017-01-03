/*
Jeffrey Stewart
jls317@lehigh.edu
ECE319
proj1
data_manipulator
see ECE319 Proj1 assignment
*/
module proj1(port2, port1, clock, reset);
	input clock, reset;
	input [7:0] port1;
	reg [7:0] indata;
	output [7:0] port2;
	reg [7:0] port2;
	reg [7:0] R1, R2, R3, R4, R_out, answer;
	reg [3:0] neg_clk_controls, pos_clk_controls;
	wire R1_clk_controls, R2_clk_controls, R3_clk_controls, R4_clk_controls, M1_clk, M2_clk, M3_clk, Adder_clk, out_c;
	wire R1_clk, R2_clk, R3_clk, R4_clk;
	wire [7:0] R1_out, R2_out, R3_out, R4_out;
	wire [7:0] M1_out, M2_out, M3_out, add_out;

	//REG & MUX LOGIC
	reg [1:0] poscount, negcount;
	//mod4negedge
	always @(posedge clock or posedge reset)
		if(reset)
			negcount <= 2'd1;
		else
			begin
				if(negcount == 2'd3)
					negcount <= 2'd0;
				else
					negcount <= negcount + 2'd1;
			end
	//logic
	always @(negedge clock)	//these are anded with clock, so they must
				//be changed on negative edge to avoid
				//glitches
		begin
			//register clocks
			if(negcount == 2'd0)
				neg_clk_controls <= {1'd0,1'd1,1'd0,1'd0};
			else if(negcount == 2'd1)
				neg_clk_controls <= {1'd0,1'd1,1'd1,1'd0};
			else if(negcount == 2'd2)
				neg_clk_controls <= {1'd0,1'd0,1'd0,1'd1};
			else
				neg_clk_controls <= {1'd1,1'd0,1'd0,1'd0};
			
		end
	always @(posedge clock)
		begin	//register clock reset
			if(negcount == 2'd0)
				neg_clk_controls <= {1'd0,1'd0,1'd0,1'd0};
			else if(negcount == 2'd1)
				neg_clk_controls <= {1'd0,1'd0,1'd0,1'd0};
			else if(negcount == 2'd2)
				neg_clk_controls <= {1'd0,1'd0,1'd0,1'd0};
			else
				neg_clk_controls <= {1'd0,1'd0,1'd0,1'd0}; 

			//mux and adder controls			
			if(negcount == 2'd0)
				pos_clk_controls <= {1'd1,1'd1,1'd0,1'd1};
			else if(negcount == 2'd1)
				pos_clk_controls <= {1'd1,1'd1,1'd1,1'd0};
			else if(negcount == 2'd2)
				pos_clk_controls <= {1'd0,1'd1,1'd0,1'd1};
			else
				pos_clk_controls <= {1'd0,1'd0,1'd0,1'd1};	
		end	
	//assignments
	//        Y   =   X    & clock
	//potential for glitches in Y
	assign R1_clk = neg_clk_controls[0] & clock;
	assign R2_clk = neg_clk_controls[1] & clock;
	assign R3_clk = neg_clk_controls[2] & clock;
	assign R4_clk = neg_clk_controls[3] & clock;
	
	//not anded with clock, therefore were taken on posedge
	assign M1_clk = pos_clk_controls[0];
	assign M2_clk = pos_clk_controls[1];
	assign M3_clk = pos_clk_controls[2];
	assign Adder_clk = pos_clk_controls[3];

	//Register Data Movement
	//indata port 1 buffer register
	always @(negedge clock or posedge reset)
		begin
			if(reset)
				indata <= 8'd0;
			else
				indata <= port1;
		end
	//R1 takes indata on its clock
	always @(posedge R1_clk or posedge reset)
		begin					
			if(reset)
				R1 <= 8'd0;
			else
				R1 <= indata;
		end
	//R2 takes R1 on its clock
	always @(posedge R2_clk or posedge reset)
		begin
			if(reset)
				R2 <= 8'd0;
			else
				R2 <= R1;
		end
	//R3 takes indata on its clock
	always @(posedge R3_clk or posedge reset)
		begin
			if(reset)
				R3 <= 8'd0;
			else
				R3 <= indata;
		end
	//R4 takes indata on its clock
	always @(posedge R4_clk or posedge reset)
		begin
			if(reset)
				R4 <= 8'd0;
			else
				R4 <= indata;
		end
	//output register data into wires to go to MUX
	assign R1_out = R1;
	assign R2_out = R2;
	assign R3_out = R3;
	assign R4_out = R4;

	//MUX controls
	//mux(out, zero_option, one_option, control)
	mux2 mymux1(M1_out, {R4_out, R1_out}, M1_clk);
	mux2 mymux2(M2_out, {R4_out, R3_out}, M2_clk);
	
	
	//Adder Call
	//adder(answer, op1, op2, control)
	//cpa cpa1(add_out, out_c, M2_out, M1_out, Adder_clk);
	always @(negedge clock)
		begin
			if(Adder_clk)
				answer <= M2_out - M1_out;
			else
				answer <= M2_out + M1_out;
		end
	assign add_out = answer;	

	mux2 mymux3(M3_out, {add_out, R2_out}, M3_clk);	
	
	//R_out
	//from output of mymux3
	always @(posedge clock or posedge reset)
		begin		
			if(reset)
				R_out <= 8'd0;
			else
				R_out <= M3_out;
		end
	//R_out is buffer register, gives data to output port2
	always @(posedge clock)
		port2 <= R_out;
endmodule

module proj1_tb;
	reg [7:0] in;
	wire [7:0] out;
	wire clk, reset;
	reg eof;
	integer data_file;
	init i(reset, clk);
	initial
		begin
			data_file = $fopen("/home/jls317/ECE319/project1/proj1.dat","rb");
		end
	always @(posedge clk)
		begin
			eof = $feof(data_file);
			if (eof == 0)
				$fscanf(data_file, "%d", in);
			else 
				begin
					$fclose(data_file);
					$finish;
				end
		end
	proj1 p1(out, in, clk, reset);
endmodule

