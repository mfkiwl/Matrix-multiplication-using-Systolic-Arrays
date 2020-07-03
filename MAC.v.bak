module MAC(
input clk,
input start,
input [7:0] F1,
input [7:0] F2,
output [7:0] F,
output done,
output reg ovf,
output reg uvf,
output reg sumValid
);

wire [4:0] f1,f2;
wire [2:0] e1,e2;
wire [7:0] fout;
reg [7:0] fpn1;
initial begin 
fpn1 <=0;
end

always @(posedge clk) begin
if(sumValid)
fpn1 <= F;
end

assign f1 = {F1[7],F1[3:0]};
assign f2 = {F2[7],F2[3:0]};
assign e1 = F1[6:4];
assign e2 = F2[6:4];

Floating_Multiplier FM1 (clk, start, f1,  e1, f2, e2, fout, done);
EightBitFAdder FA1 (clk, fpn1, fout, start, ovf, uvf, sumValid, F);

endmodule 