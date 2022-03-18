`timescale 1ps/1ps
`include "registerFile.v"
`include "alu.v"

module Processor (
   inout memoryBus,
   output memoryAddress,
   output memoryWE,
   input instructionBus,
   output instructionAddress,
   input reset,
   input clk
);
   //Pipeline Registers
   reg [31:0]fetchReg;
   reg [1:0]decodeOp, execOp;
   reg [5:0]decodeArg;
   reg [3:0]decodeDest, execDest;
   reg [31:0] decodeA, decodeB, execResult;

   //Control Items
   reg [31:0]pc;
   wire decodeOut;
   wire bubble;

   initial begin
      pc = 0;
   end
   //main register control
   always @(posedge clk) begin
      pc <= 0;
      fetchReg <= 0;
      decodeReg <= 0;
      execReg <= 0;
      memReg <= 0;
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
   RegFile reg0 (.addrA(regAddrA),.addrB(regAddrB),.addrW(writeAddr),.dataIn(dataIn), .clk(clk), .WE(WE), .A(regA), .B(regB));
   //Find what the A, B, and destination values passed on the execution should be 
   wire [31:0] loadA,jumpA,immediate;
   assign immediate = {8'h00,byte2,byte3,byte4};
   assign loadA = opArg[1]? regA:(opArg[0]? immediate :regA);
   assign jumpA = byte1[0]? regA: immediate;
   assign A = op[1]? (op[0]? regA: jumpA):(loadA);
   assign B = regB;
   assign dest = byte1[3:0];
   //Write results to decode register
   always @(posedge clk) begin
      decodeOp <= op;
      decodeArg <= byte1[5:0];
      decodeDest <= dest;
      decodeA <= A;
      decodeB <= B;
   end


   //Execute
   wire [31:0] aluOut;
   wire [1:0] aluOp;
   wire [3:0] aluShift;
   assign aluOp = decodeArg[5:4];
   assign aluShift = decodeArg[3:0];
   ALU alu (.a(decodeA), .b(decodeB), .op(decodeOp), .shift(decodeArg), .out(aluOut));
   

   

endmodule