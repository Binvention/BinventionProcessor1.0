/***********************************************************************************
 * File: Main
 * @brief This is the main file for the golden code describing my verion of a basic
 *    pipelined processor
************************************************************************************/

#include <string>
#include <iostream>
#include <fstream>


/***********************************************************************************
 * Function: main
 * @brief Main driver function for the program
************************************************************************************/
int main(int argc , const char* argv[])
{
   std::cout << "Beginning simulation" << std::endl;
   std::string hexfile;
   if (argc <= 1)
   {
      std::cout << "Input hex file name: ";
      std::cin >> hexfile;
   }
   else
   {
      hexfile = argv[1];
   }
   std::fstream fin(hexfile);
   if (fin.fail())
   {
      std::cout << "Unable to read file " << hexfile << std::endl;
      return 0;
   }

   fin >> std::hex;
   uint32_t instruction;
   uint32_t instructionMem[256] = {0};
   uint32_t memory[256] = {0};
   uint8_t instructionAddress = 0;
   //load instructions into memory
   while (fin >> instruction)
   {
      instructionMem[instructionAddress] = instruction;
      instructionAddress++;
   }
   fin.close();
   //process instructions for a maximum of 200 cycles
   bool zero = false;
   bool negative = true;
   uint32_t registerFile [16] = {0};
   instructionAddress = 0;
   for (int i = 0; i < 200; i++)
   {
      instruction = instructionMem[instructionAddress];
      instructionAddress += 1;
      if ((instruction & 0xC0000000) == 0xC0000000) //ALU instruction
      {
         uint32_t output = 0;
         uint32_t regA = (instruction >> 8)&0xf;
         uint32_t regB = instruction&0xf;
         uint32_t a = registerFile[regA];
         uint32_t b = registerFile[regB];
         if ((instruction & 0x30000000) == 0x30000000) //add instruction
         {
            output = a + b;
         }
         else if (instruction & 0x20000000) //xor instruction
         {
            output = a ^ b;
         }
         else if (instruction & 0x10000000) //add instruction
         {
            output = a | b;
         }
         else  //and instruction
         {
            output = a & b;
         }
         //shift output
         int shiftValue = ((instruction >> 24) & 0xf);
         output = output << shiftValue;
      
         //write to destination register
         int dest = ((instruction >> 16) & 0xf);
         registerFile[dest] = output;
         //set flags
         if (output == 0)
         {
            zero = true;
         }
         else
         {
            zero = false;
         }
         int negativeCheck = output;
         if (negativeCheck < 1)
         {
            negative = true;
         }
         else
         {
            negative = false;
         }
      }
      else if (instruction & 0x80000000) //Jump instruction
      {
         uint32_t jumpAddr = 0;
         //get the jump address 
         if (instruction & 0x01000000) //immediate value
         {
            jumpAddr = (instruction & 0xffffff);
         }
         else //register value
         {
            jumpAddr = registerFile[(instruction >> 16) & 0xf];
         }
         //do the jump
         if ((instruction & 0x30000000) == 0x30000000) //jump if negative
         {
            if (negative)
            {
               instructionAddress = jumpAddr;
            }
         }
         else if (instruction & 0x20000000) //jump if not zero
         {
            if (!zero)
            {
               instructionAddress = jumpAddr;
            }
         }
         else if (instruction & 0x10000000) //jump if zero
         {
            if (zero)
            {
               instructionAddress = jumpAddr;
            }
         }
         else  //unconditional jump
         {
            instructionAddress = jumpAddr;
         }
      }
      else if (instruction & 0x40000000) //Load instruction
      {
         if ((instruction & 0x30000000) == 0x30000000) //move
         {
            uint32_t source = (instruction >> 16) & 0xf;
            uint32_t value = registerFile[source];
            uint32_t dest = (instruction >> 24) & 0xf;
            registerFile[dest] = registerFile[source];
         }
         else if (instruction & 0x20000000) //write
         {
            uint32_t destReg = (instruction >> 24) & 0xf;
            uint32_t destMem = registerFile[destReg];
            uint32_t source = (instruction >> 16) & 0xf;
            uint32_t value = registerFile[source];
            memory[destMem] = value;
         }
         else if (instruction & 0x10000000) //load immediate 
         {
            uint32_t immediate = instruction & 0xffffff;
            uint32_t dest = (instruction >> 24) & 0xf;
            registerFile[dest] = immediate;
         }
         else  //load memory
         {
            uint32_t srcReg = (instruction >> 16) & 0xf;
            uint32_t memAddr = registerFile[srcReg];
            uint32_t dest = (instruction >> 24) & 0xf;
            uint32_t value = memory[memAddr];
            registerFile[dest] = value;
         }
      }
      //otherwise no operation
   }
   //Print memory and register results
   std::cout << "Printing results to files" << std::endl;
   std::ofstream memoryOut("memory_out.hex");
   if (memoryOut.fail())
   {
      std::cout << "\nUnable to write output to file. Writing to console instead.\n";
      for (int i = 0; i < 32; i++)
      {
         std::cout << std::hex << memory[i] << '\n';
      }
   }
   else
   {
      for (int i = 0; i < 32; i++)
      {
         memoryOut << std::hex << memory[i] << '\n';
      }
      memoryOut.close();
   }
   std::ofstream regOut("register_out.hex");
   if (regOut.fail())
   {
      std::cout << "\nUnable to write output to file. Writing to console instead.\n";
      for (int i = 0; i < 16; i++)
      {
         std::cout << std::hex << registerFile[i] << '\n';
      }
   }
   else
   {
      for (int i = 0; i < 16; i++)
      {
         regOut << std::hex << registerFile[i] << '\n';
      }
      regOut.close();
   }
   return 0;
}
