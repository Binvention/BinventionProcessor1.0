`timescale 1ps/1ps
`include "registerFile.v"
`include "alu.v"

module Processor (
   input [31:0]memoryIn,
   output [31:0]memoryOut,
   output [31:0] memoryAddress,
   output memoryWE,
   input [31:0]instruction,
   output [31:0]instructionAddress,
   input reset,
   input clk
);
      //Control Items
   reg [31:0]pc;
   reg fZero, fNegative;

   initial begin
      pc = 0;
      fZero = 0;
      fNegative = 0;
   end

   //Fetch
   assign instructionAddress = pc;

   //Decode
   //separate into bytes for simplicity
   wire [7:0]byte1,byte2,byte3,byte4;
   assign byte1 = instruction[31:24];
   assign byte2 = instruction[23:16];
   assign byte3 = instruction[15:8];
   assign byte4 = instruction[7:0];
   //define wires for execute stage to attach to later
   wire [3:0] writeAddr;
   wire regWE;
   //extract operation data
   wire [1:0] op;
   wire [1:0] opArg;
   assign op = byte1[7:6];
   assign opArg = byte1[5:4];
   //Extract needed data from the registers
   wire [3:0] regAddrA, regAddrB, dest;
   wire [31:0] regA,regB,A,B,regDataIn;
   assign regAddrA = op[1]? (op[0] ? byte3[3:0] : byte2[3:0]) : byte1[3:0];
   assign regAddrB = op[1]? byte4[3:0]  : byte2[3:0];
   RegFile reg0 (.addrA(regAddrA),.addrB(regAddrB),.addrW(dest),.dataIn(regDataIn), .clk(clk), .WE(regWE), .A(regA), .B(regB));
   //Find what the A, B, and destination values passed on the execution should be 
   wire [31:0] loadA,jumpA,immediate;
   assign immediate = {8'h00,byte2,byte3,byte4};
   assign loadA = opArg[1]? regA:(opArg[0]? immediate :memoryIn);
   assign jumpA = byte1[0]? immediate : regA;
   assign A = op[1]? (op[0]? regA: jumpA):(loadA);
   assign B = regB;
   assign dest = op[1]? byte2[3:0] : byte1[3:0];
   //registers written in control block;


   //Execute
   //ALU processing
   wire [31:0] aluOut;
   wire [1:0] aluOp;
   wire [3:0] aluShift;
   wire isALU;
   assign aluOp = opArg;
   assign aluShift = byte1[3:0];
   assign isALU = (op[0] & op[1]);
   ALU alu (.a(A), .b(B), .op(aluOp), .shift(aluShift), .out(aluOut));
   //set flags
   wire nFZ, nFN;
   //If it is an alu operation set the flag otherwise flags stay the same
   assign nFZ = isALU? (aluOut == 0): fZero;
   assign nFN = isALU? aluOut[31]: fNegative;

   //Jump Processing
   wire [31:0]jumpPC;
   wire [1:0] jumpOp;
   wire taken;
   assign jumpOp = opArg;
   assign taken = jumpOp[1]?(jumpOp[0]? fNegative : ~fZero ):(jumpOp[0]? fZero : 1'b1);

   wire [31:0] nPC;
   wire isTakenBranch;
   assign isTakenBranch = (op[1] & ~op[0])& taken;
   assign nPC = (isTakenBranch)? A : (pc + 1);


   //Load/Write/Move processing
   wire [3:0] registerID;
   wire [1:0] loadOp;
   wire [31:0] loadOut;
   wire writeReg;
   assign loadOp = opArg;
   assign memoryAddress = A;
   assign memoryWE = (~op[1] & op[0]) & (loadOp[1] & ~loadOp[0]); //we are loading to memory
   assign regWE = ~memoryWE & op[0]; //we are loading to a register (load or alu)
   assign memoryOut = B;
   assign regDataIn = (op[1] & op[0])? aluOut: A ; 
   




   //main control block
   always @(posedge clk) begin
      if (reset) begin
         pc <= 0;
         fZero <= 0;
         fNegative <= 0;
      end
      else begin
         pc <= nPC;
         fZero <= nFZ;
         fNegative <= nFN;
      end
   end

endmodule