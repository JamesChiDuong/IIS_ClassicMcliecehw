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
#ifdef	USE_UART_LITE
#include "VData_Transmitterlite.h"
#define	SIMCLASS	VData_Transmitterlite
#else
#include "VData_Transmitter.h"
#define	SIMCLASS	VData_Transmitter
#endif
#include "verilated_vcd_c.h"
#include "uartsim.h"

int	main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	SIMCLASS	tb;											// decleare the ib variable
	UARTSIM		*uart;										// Initial pointer
	int		port = 0;
	unsigned	setup = 868, clocks = 0, baudclocks;		// setup baudrate

	// Set our baud rate
	// {{{
	uart = new UARTSIM(port);								// Initial the port
	uart->setup(setup);
	baudclocks = setup & 0xfffffff;							// baudclock is the same the setup
	// }}}

	// Setup a VCD trace
	// {{{
#define	VCDTRACE
#ifdef	VCDTRACE
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	tb.trace(tfp, 99);
	tfp->open("Data_Transmitter.vcd");
#define	TRACE_POSEDGE	tfp->dump(10*clocks)
#define	TRACE_NEGEDGE	tfp->dump(10*clocks+5)
#define	TRACE_CLOSE	tfp->close()
#else
#define	TRACE_POSEDGE
#define	TRACE_NEGEDGE
#define	TRACE_CLOSE
#endif
	// }}}

	// Main simulation loop
	// {{{
	clocks = 0;
	while(clocks < 16*32*baudclocks) {
		tb.clk = 1;
		//char buf[1];
		tb.eval();
		TRACE_POSEDGE;
		tb.clk = 0;
		tb.eval();
		TRACE_NEGEDGE;

	//	(*uart)(tb.o_uart_tx);
		uart->operator()(tb.o_uart_tx);							// the verilog file will transfer data to the cpp file
		// writeData((tb.o_uart_tx));
		clocks++;
	}
	// }}}

	TRACE_CLOSE;
	printf("\n\nSimulation complete\n");
}



