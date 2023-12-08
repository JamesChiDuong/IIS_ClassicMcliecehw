#include <stdlib.h>
#include "Vdecryption_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <iostream>
using namespace std;

vluint64_t main_time = 0;   // Current simulation time

double sc_time_stamp ()     // Called by $time in Verilog
{       
  return main_time;
}

int main(int argc, char **argv) {
  // Initialize Verilators variables
  Verilated::commandArgs(argc, argv);

  // Create an instance of our module under test
  Vdecryption_tb *tb = new Vdecryption_tb;

  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  tb->trace(tfp, 99);  // Trace 99 levels of hierarchy
  tfp->open("obj_dir/decryption_tb.vcd");

  
  for (int rounds = 0; rounds < 1; rounds++)
  {

    // wait for 10 cycles
    for (int i = 0; i < 10; i++)
    {
      tb->clk = 1;
      tb->eval();
      tb->clk = 0;
      tb->eval();

      main_time += 1;
    }

    // set start high for one cycle
    tb->start = 1;
  
    tb->clk = 1;
    tb->eval();
    tb->clk = 0;
    tb->eval();
    main_time += 1;
  
    tb->start = 0;
  
    // perform clock ticks until done
    while(!tb->done)
    {
      tb->clk = 1;
      tb->eval();
      tb->clk = 0;
      tb->eval();

      main_time += 1;

      tfp->dump(main_time);
  
      if ((main_time & 0xffff) == 0)
        cout << "time: " << main_time << "\n";
    }

    tfp->close();
  
  //   // test printing memory contents
  //   for (int i = 0; i < 128; i++)
  //     cout << tb->decryption_tb__DOT__DUT__DOT__doubled_syndrome_inst__DOT__mem_synd_A__DOT__mem[i] << "\n";
   }

  exit(EXIT_SUCCESS);
}

