// // For std::unique_ptr
// #include <memory>

// // Include common routines
// #include <verilated.h>

// // Include model header, generated from Verilating "top.v"
// #include "Vencap_sim.h"

// #include "uartsim.h"
// // Legacy function required only so linking works on Cygwin and MSVC++
// double sc_time_stamp() { return 0; }

// int main(int argc, char **argv, char **env) {
//   Verilated::commandArgs(argc, argv);
//   UARTSIM		*uart;										              // init uart pointer
//                                                    //uart_PseudoTerminal Pseudo;
//   unsigned	setup = 868;								          // init baudrate

//   vluint64_t clk_cnt = 0;
//     // Setup the model and baud rate
//   SIMCLASS tb;
//   int baudclocks = setup & 0x0ffffff;
//   tb.i_uart_rx = 1;

//   uart = new UARTSIM();
//   uart->setup(setup);

  
//   for(int argn=1; argn<argc; argn++)
//   {
//     if (argv[argn][0] == '-') for(int j=1; (j<1000)&&(argv[argn][j]); j++)
//         switch(argv[argn][j])
//         {
//           case 's':
//               setup= strtoul(argv[++argn], NULL, 0); j+= 4000;
//               break;
//           default:
//               printf("Undefined option, -%c\n", argv[argn][j]);
//               break;
//         }
//   }

//   // Prevent unused variable warnings
//   if (false && argc && argv && env) {
//   }

//   // Using unique_ptr is similar to
//   // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
//   const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

//   // Set debug level, 0 is off, 9 is highest presently used
//   // May be overridden by commandArgs argument parsing
//   contextp->debug(0);

//   // Randomization reset policy
//   // May be overridden by commandArgs argument parsing
//   contextp->randReset(0);

//   // Verilator must compute traced signals
//   contextp->traceEverOn(true);

//   // Pass arguments so Verilated code can see them, e.g. $value$plusargs
//   // This needs to be called before you create any model
//   contextp->commandArgs(argc, argv);

//   // Construct the Verilated model, from Vtop.h generated from Verilating
//   // "top.v". Using unique_ptr is similar to "Vtop* top = new Vtop" then
//   // deleting at end. "TOP" will be the hierarchical name of the module.
//   const std::unique_ptr<Vencap_sim> top{new Vencap_sim{contextp.get(), "TOP"}};

//   // Set Vtop's input signals
//   top->clk = 0;
//   top->rst = 0;

//   // Simulate until $finish
//   while (!contextp->gotFinish() && !top->done) {
//     // 1 timeprecision period passes...
//     contextp->timeInc(1);
//     // Toggle a fast (time/2 period) clock.
//     // One clockperiod requires 2 timeprecision periods.
//     // Determine the clock count by a division of 2.
//     // if(contextp->time() % 10){
//     top->clk = !top->clk;
//     // if(top->clk) clk_cnt++;
//     //}
//     // Toggle control signals on an edge that doesn't correspond
//     // to where the controls are sampled; in this example we do
//     // this only on a negedge of clk, because we know
//     // reset is not sampled there.
//     if (!top->clk) {
//       if (contextp->time() > 0 && contextp->time() <= 10) {
//         top->rst = 1; // Assert reset
//       } else {
//         top->rst = 0; // Deassert reset
//       }
//     }
//     // if (top->clk){
//     //   clk_cnt++;
//     // }

//     // Evaluate model
//     top->eval();
//   }
//   // Wait another 100 cycles
//   for (int i = 0; i < 100;) {
//     contextp->timeInc(1);
//     top->clk = !top->clk;

//     if (top->clk) {
//       // clk_cnt++;
//       i++;
//     }
//     top->eval();
//   }

//   VL_PRINTF("Total cycle count (Verilator): %" VL_PRI64 "d\n",
//             contextp->time());

//   // Final model cleanup
//   top->final();

//   // Coverage analysis (calling write only after the test is known to pass)
// #if VM_COVERAGE
//   Verilated::mkdir("logs");
//   contextp->coveragep()->write("logs/coverage.dat");
// #endif

//   // Return good completion status
//   // Don't use exit() or destructor won't get called
//   return 0;
// }


#include <verilatedos.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include "verilated.h"
// #ifdef	USE_UART_LITE
// #include "VTranAndReceilite.h"
// #define	SIMCLASS	VTranAndReceilite
// #else
#include "Vencap_sim.h"
#define	SIMCLASS	Vencap_sim
// #endif
#include "verilated_vcd_c.h"
#include "uartsim.h"

#define WAVENAME "encap_sim.vcd"
int	main(int argc, char **argv) 
{
   Verilated::commandArgs(argc, argv);
   UARTSIM		*uart;										// init uart pointer
                                                   //uart_PseudoTerminal Pseudo;							// Init Pseudo terminal
   unsigned	setup = 868;								// init baudrate

   for(int argn=1; argn<argc; argn++)
   {
      if (argv[argn][0] == '-') for(int j=1; (j<1000)&&(argv[argn][j]); j++)
         switch(argv[argn][j])
         {
            case 's':
               setup= strtoul(argv[++argn], NULL, 0); j+= 4000;
               break;
            default:
               printf("Undefined option, -%c\n", argv[argn][j]);
               break;
         }
   }

   // Setup the model and baud rate
   SIMCLASS tb;
   int baudclocks = setup & 0x0ffffff;
   tb.i_uart_rx = 1;

   uart = new UARTSIM();
   uart->setup(setup);

   // Make sure we don't run longer than 4 seconds ...
   unsigned	clocks = 0;  
   // VCD trace setup
#define	VCDTRACE
#ifdef	VCDTRACE
   Verilated::traceEverOn(true);
   VerilatedVcdC* tfp = new VerilatedVcdC;
   tb.trace(tfp, 99);
   tfp->open(WAVENAME);
#define	TRACE_POSEDGE	tfp->dump(10*clocks)
#define	TRACE_NEGEDGE	tfp->dump(10*clocks+5)
#define	TRACE_CLOSE	tfp->close()
#else
#define	TRACE_POSEDGE	while(0)
#define	TRACE_NEGEDGE	while(0)
#define	TRACE_CLOSE	while(0)
#endif

   // Clear any initial break condition
   for(int i=0; i<(baudclocks*24); i++) {
      tb.clk = 1;
      tb.eval();
      tb.clk = 0;
      tb.eval();

      tb.i_uart_rx = 1;
   }

   // Simulation loop: process the hello world string
   while(1)
   {
      tb.clk = 1;
      tb.eval();
      TRACE_POSEDGE;
      tb.clk = 0;
      tb.eval();
      TRACE_NEGEDGE;
      clocks++;
      tb.i_uart_rx = (*uart)(tb.o_uart_tx);
   }
   TRACE_CLOSE;

   exit(EXIT_SUCCESS);
}

