// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vdecap_with_support_tb.h"

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

int main(int argc, char** argv, char** env) {
    vluint64_t clk_cnt = 0;

    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(0);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v".
    // Using unique_ptr is similar to "Vtop* top = new Vtop" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vdecap_with_support_tb> top{new Vdecap_with_support_tb{contextp.get(), "TOP"}};

    // Set Vtop's input signals
    top->clk = 0;
    top->rst = 0;

    // Simulate until $finish
    while (!contextp->gotFinish() && !top->done_decap) {
	    // 1 timeprecision period passes...
        contextp->timeInc(1);
		// Toggle a fast (time/2 period) clock.
		// One clockperiod requires 2 timeprecision periods.
		// Determine the clock count by a division of 2.
		// if(contextp->time() % 10){
		top->clk = !top->clk;
		//if(top->clk) clk_cnt++;
		//}
        // Toggle control signals on an edge that doesn't correspond
        // to where the controls are sampled; in this example we do
        // this only on a negedge of clk, because we know
        // reset is not sampled there.
        if (!top->clk) {
            if (contextp->time() > 0 && contextp->time() <= 10) {
                top->rst = 1;  // Assert reset
            } else {
                top->rst = 0;  // Deassert reset
            }
        }

		// if (top->clk){
		//   clk_cnt++;
		// }

        // Evaluate model
        top->eval();
	}
		// Wait another 100 cycles
		for (int i = 0; i < 100;) {
		  contextp->timeInc(1);
		  top->clk = !top->clk;

		  if (top->clk) {
			// clk_cnt++;
			i++;
		  }
		  top->eval();
		}

		VL_PRINTF("Total cycle count (Verilator): %" VL_PRI64 "d\n", contextp->time());

		// Final model cleanup
		top->final();

    // Coverage analysis (calling write only after the test is known to pass)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}
