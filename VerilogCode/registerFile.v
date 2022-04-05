module RegFile (
   input [3:0] addrA, addrB, addrW,
   input [31:0] dataIn,
   input WE,
   input clk,
   output [31:0] A,B
);
   
   //32 x 16 register file 
   reg [31:0] regfile [15:0];

   assign A = regfile[addrA];
   assign B = regfile[addrB];

   always @(posedge clk) begin
      if(WE) begin
         regfile[addrW] <= dataIn;
      end
   end

endmodule