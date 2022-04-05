`timescale 1ps/1ps
`include "registerFile.v"
`include "alu.v"

module Processor (
   input [31:0]memoryIn,
   output reg [31:0]memoryOut, memoryAddress,
   output reg memoryWE,
   input memoryReady,
   input [31:0]instructionBus,
   output reg [31:0]instructionAddress,
   input instructionReady,
   input reset,
   input clk
);
   //Pipeline Registers
   reg [31:0]fetchReg;
   reg [1:0]decodeOp, execOp;
   reg [5:0]decodeArg;
   reg [3:0]decodeDest, execDest;
   reg [31:0] decodeA, decodeB, execResult;
   reg fZero, fNegative;
   reg [31:0]regDataIn;
   reg regWE;
   reg [3:0] regWA;

   //Control Items
   reg [31:0]pc;
   wire decodeOut;
   wire bubble;

   initial begin
      pc = 0;
      fetchReg = 0;
      decodeOp = 0;
      execOp = 0;
      decodeArg = 0;
      decodeDest = 0;
      execDest = 0;
      decodeA = 0;
      decodeB = 0;
      execResult = 0;
      fZero = 0;
      fNegative = 0;
   end

   always @(reset) begin
      pc = 0;
      fetchReg = 0;
      decodeOp = 0;
      execOp = 0;
      decodeArg = 0;
      decodeDest = 0;
      execDest = 0;
      decodeA = 0;
      decodeB = 0;
      execResult = 0;
      fZero = 0;
      fNegative = 0;
   end

   //Fetch
   

   //Decode
   //separate into bytes for simplicity
   wire [7:0]byte1,byte2,byte3,byte4;
   assign byte1 = fetchReg[31:24];
   assign byte2 = fetchReg[23:16];
   assign byte3 = fetchReg[15:8];
   assign byte4 = fetchReg[7:0];
   //define wires for execute stage to attach to later
   wire [3:0] writeAddr;
   wire WE;
   //extract operation data
   wire [1:0] op;
   wire [1:0] opArg;
   assign op = byte1[7:6];
   assign opArg = byte1[5:4];
   //Extract needed data from the registers
   wire [3:0] regAddrA, regAddrB, regDest;
   wire [31:0] regA,regB,A,B;
   assign regAddrA = op[1]? (op[0] ? byte3[3:0] : byte2[3:0]) : byte2[3:0];
   assign regAddrB = op[1]? byte4[3:0]  : byte1[3:0];
   RegFile reg0 (.addrA(regAddrA),.addrB(regAddrB),.addrW(regWA),.dataIn(regDataIn), .clk(clk), .WE(regWE), .A(regA), .B(regB));
   //Find what the A, B, and destination values passed on the execution should be 
   wire [31:0] loadA,jumpA,immediate;
   assign immediate = {8'h00,byte2,byte3,byte4};
   assign loadA = opArg[1]? regA:(opArg[0]? immediate :regA);
   assign jumpA = byte1[0]? regA: immediate;
   assign A = op[1]? (op[0]? regA: jumpA):(loadA);
   assign B = regB;
   assign dest = byte1[3:0];
   //registers written in control block;


   //Execute
   //ALU processing
   wire [31:0] aluOut;
   wire [1:0] aluOp;
   wire [3:0] aluShift;
   assign aluOp = decodeArg[5:4];
   assign aluShift = decodeArg[3:0];
   ALU alu (.a(decodeA), .b(decodeB), .op(aluOp), .shift(decodeArg), .out(aluOut));
   //set flags
   wire nFZ, nFN;
   //If it is an alu operation set the flag otherwise flags stay the same
   assign nFZ = (decodeOp[0] & decodeOp[1])? (aluOut == 0): fZero;
   assign nfN = (decodeOp[0] & decodeOp[1])? aluOut[31] : fNegative;

   //Jump Processing
   wire [31:0]jumpPC;
   wire [1:0] jumpOp;
   wire isMissedJump, conditional, taken;
   assign jumpOp = decodeArg[5:4];
   assign conditional = jumpOp[1] | jumpOp[0];
   assign taken = jumpOp[1]?(jumpOp[0]? fNegative : ~fZero ):(jumpOp[0]? fZero : 1'b0);
   assign isMissedJump = (decodeOp[1] & ~decodeOp[0]) & (conditional & taken);
   //address to be jumped to is in decodeA


   //Load/Write/Move processing
   wire [3:0] registerID;
   wire [1:0] loadOp;
   wire [31:0] memAddr, loadOut;
   wire writeMem, writeReg;

   assign memAddr = loadOp[1]? decodeB : decodeA;
   assign writeMem = (~decodeOp[1] & decodeOp[0]) & (loadOp[1] & ~loadOp[0]); //we are loading to memory
   assign writeReg = ~writeMem & decodeOp[0]; //we are loading to a register (load or alu)
   //value to be written is in decodeA
   
   wire [31:0]execOut;
   assign execOut = (decodeOp[1] & decodeOp[0])? aluOut: decodeA; 
   




   //main control block
   always @(posedge clk) begin
      if (bubble)begin

      end
      else begin
         // fetch

         //decode
         decodeOp <= op;
         decodeArg <= byte1[5:0];
         decodeDest <= dest;
         decodeA <= A;
         decodeB <= B;
         //execute
         //set flags
         fZero <= nFZ;
         fNegative <= nfN;
         execOp <= decodeOp;
         execResult <= execOut;
         execDest <= decodeDest;
         memoryAddress <= memAddr;
         memoryWE <= writeMem;
         regWE <= writeReg;
         
         //write
         
      end
   end

endmodule