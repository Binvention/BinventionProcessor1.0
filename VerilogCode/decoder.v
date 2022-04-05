
module decoder (
   input [31:0] instruction,
   output [1:0] aluOp,
   output [3:0] shiftBits,
   output [1:0] operation,
   output [3:0] addrA, addrB, dest,
   output [2:0] jumpOffset,
   output [2:0] jumpInstruction
);
   operation = instruction[15:14];
   always @(operation)
   {
      case (operation)
         2'b00: begin
            srcA <=0;
            srcB <=0;
            aluOp <=0;
            jumpOffset <= 0;
            jumpInstruction <= 0;
         end
         2'b01: begin
         end
         2'b10:begin
         end
         2'b11:begin
         end
      endcase
   }

endmodule