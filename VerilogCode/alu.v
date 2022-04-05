
module ALU (
   input [31:0]a,b,
   input [1:0] op,
   input [3:0] shift,
   output [31:0] out
);
   //wires
   wire [31:0] andout, orout, xorout, addout, opout, shift1, shift2, shift4;

   //Logical operation
   assign andout = a & b;
   assign orout = a | b;
   assign xorout = a ^ b;
   assign addout = a + b;
   assign opout = op[1] ? (op[0] ? addout : xorout ):(op[0] ? orout : andout );

   //shift operation
   assign shift1 = shift[0] ? {opout[30:0],1'b0} : opout;
   assign shift2 = shift[1] ? {shift1[29:0],2'b00}: shift1;
   assign shift4 = shift[2] ? {shift2[27:0],4'b0000}: shift2;
   assign out = shift[3] ? {shift4[23:0],8'b00000000}: shift4;

endmodule