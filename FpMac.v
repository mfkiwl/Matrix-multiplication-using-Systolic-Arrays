module FpMac(
	input clk,
	input [7:0] fpnum1,
	input [7:0] fpnum2,
    	input start,
	input reset,
    	output [7:0] fpmacsum);
    
    wire [7:0] product, sum;
    reg [7:0] accumulator = 0;
    wire add_start;
    
    assign fpmacsum = accumulator;
    assign add_start = ~clk;

    Multiplier M1(start, fpnum1[7], fpnum2[7], fpnum1[3:0], fpnum2[3:0], fpnum1[6:4], fpnum2[6:4], product);
    EightBitFAdder FA1 (accumulator,((start==0) ? product : 8'h00),start, ovf, uvf, sumValid, sum);
    
    always@(posedge clk) begin
        if(reset) begin
            accumulator <= 0;
        end else begin
            if(fpnum1 != 8'h00 || fpnum2 != 8'h00)
                accumulator <= sum;
        end
    end

endmodule