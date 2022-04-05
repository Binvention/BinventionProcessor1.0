`timescale 1ns/10ps
`include "basicProcessor.v"

module basicProcessor_tb();
   reg [31:0] memory [31:0];
   reg [31:0] instruction [31:0];
   reg clk;
   reg reset;
   wire [31:0] memOut, memAddress, instructionAddress;
   wire WE;
   reg [31:0]cycleCount;
   localparam [31:0] noOp = 32'h00000000;
   localparam [1:0] Load = 2'b01;
   localparam [1:0] mem = 2'b00;
   localparam [1:0] immediate = 2'b01;
   localparam [1:0] write = 2'b10;
   localparam [1:0] move = 2'b11;
   localparam [1:0] jump = 2'b10;
   localparam [1:0] unconditional = 2'b00;
   localparam [1:0] equal = 2'b01;
   localparam [1:0] notEqual = 2'b10;
   localparam [1:0] negative = 2'b11;
   localparam [1:0] alu = 2'b11;

   always @(posedge clk) begin
      if(WE) begin
         memory[memAddress] <= memOut;
         $display("Memory Written address = %h, value = %d",memAddress,memOut);
      end
   end

   initial
   begin 
      $readmemh("program.hex",instruction);
      $monitor("Time %t, instruction address = %h", $time, instructionAddress);
      //set instruction memory
      // instruction[0] = noOp; //NO op
      // instruction[1] = {Load,immediate,4'h0,24'd13}; //Load 13 to reg 0
      // instruction[2] = {Load,immediate,4'h1,24'd17}; //load 17 to reg 1
      // instruction[3] = {Load,immediate,4'h2,24'h0};  //load 0 to reg 2
      // instruction[4] = {Load,immediate,4'h3,24'h1};  //load 1 to reg 3
      // instruction[5] = {Load,immediate,4'h4,24'h0};  //load 0 to reg 4
      // instruction[6] = {Load,immediate,4'h5,24'hffffff};  //load ffffff to reg 5 (for subtracting)
      // instruction[7] = {Load,immediate,4'h6,24'hff};  //load ff to reg 6 (for subtracting)
      // instruction[8] = {alu,2'b00,4'h8,8'h5,8'h5,8'h5}; //Shift reg 5 8 bits
      // instruction[9] = {alu,2'b01,4'b0,8'h5,8'h5,8'h6}; //or ff to ffffff00 to get our negative 1
      // instruction[10] = {alu,2'b11,4'h0,8'h1,8'h1,8'h0}; //add reg 1 to reg 0 store in reg 1
      // instruction[11] = {Load,write,4'h4,8'h1,16'h0000}; //store created value in memory at address in reg 4
      // instruction[12] = {alu,2'b11,4'h0,8'h4,8'h4,8'h3}; //add 1 to reg 4
      // instruction[13] = {alu,2'b10,4'h0,8'h7,8'h0,8'h5}; //xor reg 0 to reg 5 (for subtraction)
      // instruction[14] = {alu,2'b11,4'h0,8'h7,8'h7,8'h3}; //add 1 to get negative reg 0
      // instruction[15] = {alu,2'b11,4'h0,8'h7,8'h7,8'h4}; //add to reg 4 to see if result is negative
      // instruction[16] = {jump,negative,4'h1,24'ha}; //loop back to instruction 10 13 times
      // instruction[17] = noOp; //NO op
      // instruction[18] = noOp; //NO op
      // instruction[19] = noOp; //NO op
      // instruction[20] = noOp; //NO op
      // instruction[21] = {jump,unconditional,4'h0,8'h4,16'h0000}; //jump to instruction 0
      // $writememb("instructions_binary.txt",instruction);
      // $writememh("instructions_hex.txt",instruction);
      reset = 1'b1;
      #20;
      reset = 1'b0;
      #20;
      cycleCount = 0;
      clk = 0;
      #8000;
      $writememh("memory_out.hex", memory);
      $writememh("register_out.hex", p.reg0.regfile);
      $finish;
   end
   
   always
   begin
      $display("Cycle %d", cycleCount);
      clk = 0;
      #20;
      $display("A = %h, B = %h, nPC = %h, op = %b, isTakenBranch = %b, fZero = %b, fNegative = %b", p.A, p.B, p.nPC, p.op, p.isTakenBranch, p.fZero, p.fNegative);
      $display("isALU = %b, aluOut = %h, nFN = %b", p.isALU, p.aluOut, p.nFN);
      clk = 1;
      #20;
      cycleCount = cycleCount + 1;
   end

   Processor p (.memoryIn(memory[memAddress]), .memoryOut(memOut), .memoryAddress(memAddress), .memoryWE(WE), .instruction(instruction[instructionAddress]), .instructionAddress(instructionAddress), .reset(reset), .clk(clk));


endmodule