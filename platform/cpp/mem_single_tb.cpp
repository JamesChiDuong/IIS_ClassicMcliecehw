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
#include "Vmem_single_tb.h"
#define	SIMCLASS	Vmem_single_tblite
#else
#include "Vmem_single_tb.h"
#define	SIMCLASS	Vmem_single_tb
#endif
#include "verilated_vcd_c.h"
#include "uartsim.h"
#define WAVENAME "mem_single_tb.vcd"

int	main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    UARTSIM		*uart;									// Init Uart Simulate
    uart_PseudoTerminal *Pseudo;						// Init the Pseudo Terminal pointer
    bool		run_interactively = false;
    int		port = 0;
    unsigned	setup = 868;							// Init the baudrate
    int fd;
    
    // Argument processing
    // {{{
    for(int argn=1; argn<argc; argn++)
    {
        if (argv[argn][0] == '-') for(int j=1; (j<1000)&&(argv[argn][j]); j++)
        switch(argv[argn][j])
        {
            case 'i':
                run_interactively = true;
                break;
            case 'p':
                port = atoi(argv[argn++]); j+= 4000;
                run_interactively = true;
                break;
            case 's':
                setup= strtoul(argv[++argn], NULL, 0); j+= 4000;
                break;
            default:
                printf("Undefined option, -%c\n", argv[argn][j]);
                break;
        }
    }
    // }}}

    if (run_interactively) 								// if using the option -i or -p
    {
        // Setup the model and baud rate
        // {{{
        SIMCLASS tb;									// declerate the tb variable
        tb.i_uart_rx = 1;
        unsigned	clocks = 0;
        // }}}


        // {{{
        uart = new UARTSIM(port);						// Init the UART sim ith the port is the standard input
        uart->setup(setup);								// Set up the parameter
        int baudclocks = setup & 0x0ffffff;

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

        while(1)
        {

            tb.clk = 1;
            tb.eval();
            TRACE_POSEDGE;
            tb.clk = 0;
            tb.eval();
            TRACE_NEGEDGE;
            tb.i_uart_rx = (*uart)(tb.o_uart_tx);		// transfer and receiver via tx and rx
            clocks++;
        }
        // }}}
    }
}