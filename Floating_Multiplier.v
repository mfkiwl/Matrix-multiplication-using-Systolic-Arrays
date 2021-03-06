module Floating_Multiplier(
input clk,
input start,
input S1,
input S2,
input [3:0] F1, // 4-bit fraction1
input [2:0] E1, //4-bit exponent1
input [3:0] F2, //4-bit fraction2
input [2:0] E2, //4-bit exponent2
output [7:0] Fout, //output 8-bit
output done1 //multiplication done
);

reg [9:0] F;
reg done;
reg [4:0] B,C;
reg [3:0] X,Y; //reg to load exponent plus signbit
reg Load,Adx,RSF,LSF,Mdone; //control signals
reg [1:0] PS1,NS1; //present and next state for main controller
reg [3:0] X1;
wire [3:0] X11;

initial
begin

PS1 <=0;
NS1 <=0; 
B <=0;
C <=0;
X <=0;
Y <=0;
X1 <=0;
Mdone<=0;
Load <=0;
Adx <=0;
NS1 <=0;
RSF <=0;
LSF <=0;
done <=0;
F<=0;
end

always @(PS1 or start or Mdone or X  or B) //state machine for main controller
begin 

	case(PS1)
		0:
			begin 
			done <=0;
			
				if(start)
				begin
					Load <=1;
					NS1 <=1;
				end
			end
		1:
			begin
			Adx <=1;
			Load<=0;
			NS1 <=2;
			end
		2:
			begin
				if(Mdone)
				begin
					Adx<=0;
					 if(F[9] == 0 & F[8] == 0) //if overflow right shift 
					begin
						RSF <=1;
					end
					 if(F[9] ==1 & F[8]== 1 ) //if unnormalized left shift
					begin
						LSF <= 1;
					end
 					if(F[9] ==1 & F[8]== 0 ) //if unnormalized left shift
					begin
						LSF <= 1;
					end
				NS1 <=3;	
				end
				else 
				begin
				NS1 <=2;
				end
			end
		3: 
			begin
				
				done <=1;
				LSF<=0;
				RSF<=0;
				X1<=X + 3;
			
				if(!start)
				begin
					NS1 <=0;
					
				end
			end
	endcase
end 


always @(posedge clk) //update registers for exponent adder and multiplier according to control signals
begin 
	PS1 <= NS1;
	
	if(Load)
	begin
		X <= E1+3'b101; //E1 with sign bit
		Y <= E2+3'b101; //E2 with sign bit 
		C <={1'b1,F2}; 
		B <={1'b1,F1};
		Mdone<=0;
		
	end
	if(Adx)
	begin
		F <= B*C;
		X<=X+Y; //add exponents 
		Mdone <= 1;
		
	end
	
	if(RSF) //if overflow occurs
	begin 
		F<={F[8:0],1'b0};
 		X <= X-1;
	end
	if(LSF) //if unnormalized 
	begin 
		F<={1'b0,F[9:1]};
 		X <= X+1;
	end
	
			

end

assign X11 = X1;
assign Fout = {S1^S2,X11[2:0],F[7:4]};
assign done1 = done;

endmodule 