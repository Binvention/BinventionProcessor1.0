/***********************************************************************************
 * File: Main
 * @brief This is the main file for the assembler of my basic processor
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
   std::string assemFile;
   if (argc < 1)
   {
      std::cout << "Input assembly file name: ";
      std::cin >> assemFile;
   }
   std::string bitFile = "program.hex";
   std::ifstream assem(assemFile);
   if (assem.fail())
   {
      std::cout << "Failed to open assembly file" << std::endl;
      return 0;
   }
   std::ofstream bits(bitFile, std::ios_base::binary | std::ios_base::out);
   if (bits.fail())
   {
      std::cout << "Failed to open bitfile" << std::endl;
      return 0;
   }
   bits.flags(std::ios_base::hex);
   std::string instruction;
   while (std::getline(assem,instruction))
   {
      uint32_t inst = 0;
      if (instruction.compare(0,2,"NP"))
      {
         bits << inst; 
      }
      else if (instruction.compare(0,2,"LD"))
      {
         if (instruction[6] == '#')
         {

         }
         else if (instruction [6] == 'X')
         {

         }
         else
         {
            
         }
      }
      else if (instruction.compare(0,2,"ST"))
      {

      }
      else if (instruction.compare(0,2,"MV"))
      {

      }
      else if (instruction.compare(0,2,"JP"))
      {

      }
      else if (instruction.compare(0,2,"JZ"))
      {

      }
      else if (instruction.compare(0,2,"JY"))
      {

      }
      else if (instruction.compare(0,2,"JN"))
      {

      }
      else if (instruction.compare(0,2,"AN"))
      {

      }
      else if (instruction.compare(0,2,"OR"))
      {

      }
      else if (instruction.compare(0,2,"XR"))
      {

      }
      else if (instruction.compare(0,2,"AD"))
      {

      }
   }
   return 0;
}
