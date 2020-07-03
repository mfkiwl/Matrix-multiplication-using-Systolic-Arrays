module EightBitFAdder(
	input [7:0] fpn1,
	input [7:0] fpn2,
	input start,
	output reg ovf = 0,
	output reg uvf = 0,
	output reg sumValid = 0,
	output reg [7:0] fpsum = 0);
	
	reg fpn1_sig = 0, fpn2_sig = 0;
	reg [4:0] fpn1_frac = 0, fpn2_frac = 0;
	reg [3:0] fpn1_exp = 0, fpn2_exp = 0;
	reg [5:0] fracSum = 0;
	reg [2:0] expSum = 0;
	reg [3:0] state = 4'b0001;
	reg [1:0] unorm = 0;
	reg zeroCheck = 0;
	
	always@(/*fpn1, fpn2, fracSum, fpn1_exp, fpn2_exp, fpn1_frac, fpn2_frac, fracSum, expSum, fpsum,*/start) begin	
		case(state)
			//load the numbers into a register where they can be altered
			4'b0001: begin
                sumValid = 1'b0;
                
				if(start==0) begin
                    if((fpn1[6:4] >= fpn2[6:4] + 5) || (fpn2[6:4] == 3'b000 && fpn1[6:4] >= 3'b110)|| (fpn2 == 8'h00)) begin
						fpsum <= fpn1;
						state <= 4'b1000;
					end else if((fpn2[6:4] >= fpn1[6:4] + 5) || (fpn1[6:4] == 3'b000 && fpn2[6:4] >= 3'b110) || (fpn1 == 8'h00)) begin
						fpsum <= fpn2;
						state <= 4'b1000;
					end else begin
						fpn1_sig <= fpn1[7];
						fpn1_frac <= fpn1[6:4] == 3'b000 ? {1'b0, fpn1[3:0]} : {1'b1, fpn1[3:0]};
						fpn1_exp <= fpn1[6:4] == 3'b000 ? fpn1[6:4]+1 : fpn1[6:4];
						fpn2_sig <= fpn2[7];
						fpn2_frac <= fpn2[6:4] == 3'b000 ? {1'b0, fpn2[3:0]} : {1'b1, fpn2[3:0]};
						fpn2_exp <= fpn2[6:4] == 3'b000 ? fpn2[6:4]+1 : fpn2[6:4];
						state <= 4'b0010;
					end
				end else
					state <= 4'b0001;
			end
			//start shifting the smaller number to match the larger one
			4'b0010: begin
				if(fpn1_exp < fpn2_exp) begin
					fpn1_frac <= fpn1_frac >> 1;
					fpn1_exp <= fpn1_exp + 1;
					unorm[0] <= 1'b1;
				end else if(fpn1_exp > fpn2_exp) begin
					fpn2_frac <= fpn2_frac >> 1;
					fpn2_exp <= fpn2_exp + 1;
					unorm[1] <= 1'b1;
				end else begin
					expSum <= fpn1_exp;
					
					case({fpn1_sig, fpn2_sig})
						2'b00: begin
							fracSum <= fpn1_frac + fpn2_frac;
							fpsum[7] <= 1'b0;
						end
						2'b01: begin
							if(fpn1_frac >= fpn2_frac) begin
								fracSum <= fpn1_frac - fpn2_frac;
								fpsum[7] <= 1'b0;
							end else begin
								fracSum <= ~(fpn1_frac - fpn2_frac) + 1;
								fpsum[7] <= 1'b1;
							end
						end
						2'b10: begin 
							if(fpn2_frac >= fpn1_frac) begin
								fracSum <= fpn2_frac - fpn1_frac;
								fpsum[7] <= 1'b0;
							end else begin
								fracSum <= ~(fpn2_frac - fpn1_frac) + 1;
								fpsum[7] <= 1'b1;
							end
						end
						2'b11: begin
							fracSum <= fpn1_frac + fpn2_frac;
							fpsum[7] <= 1'b1;
						end
					endcase
					
					state <= 4'b0100;
				end
			end
			
			4'b0100: begin
				//is the fraction 0?
				if(fracSum == 0 && zeroCheck == 0) begin
					fpsum <= 0;
					state <= 4'b1000;
				end
				//has the fraction overflowed?
				else if(fracSum[5] != 0) begin
					zeroCheck <= 1;
					
					fracSum <= fracSum >> 1;
					
					if(expSum == 3'b111) begin
						ovf <= 1;
						fpsum[6:0] <= 7'hFF;
						state <= 4'b1000;
					end
					
					expSum <= expSum + 1;
				end
				//is the fraction normalized?
				else if(fracSum[4] != 1) begin
					zeroCheck <= 1;
					
					if(expSum > 3'b001) begin
						fracSum <= fracSum << 1;
						expSum <= expSum - 1;
					end else begin
						//the sum is in the denormalized range or underflowed
						fpsum[6:4] <= 3'b000;
						fpsum[3:0] <= fracSum[3:0];
						state <= 4'b1000;
						//if the fraction is zero, then there is underflow
						if(fracSum[3:0] == 4'b0000)
							uvf <= 1;
					end
				end
				//the fraction has been normalized, and fraction overflow has been taken care of
				else begin
					fpsum[6:4] <= expSum;
					fpsum[3:0] <= fracSum[3:0];
					
					state <= 4'b1000;
				end
				
				
			end
			
			4'b1000: begin
                sumValid <= 1'b1;
                if(start)
                    state <= 4'b0001;
			end
			
			default: begin
				state <= 4'b0001;
			end
		endcase
	end

endmodule