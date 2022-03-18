/***********************************************************************************
 * File: Main
 * @brief This is the main file for the compiler of my basic pipeline processor
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

   
}
