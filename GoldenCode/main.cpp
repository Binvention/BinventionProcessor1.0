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
   std::string bitfile;
   char memory [64];
   if (argc < 1)
   {
      std::cout << "Input executable file name: ";
      std::cin >> bitfile;
   }

   std::fstream fin(bitfile);
   if (fin.fail())
   {
      throw "Unable to open file";
   }

   fin >> std::hex;
   int
}
