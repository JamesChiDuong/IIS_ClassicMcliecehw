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
#include "VData_Receiverlite.h"
#define	SIMCLASS	VData_Receiverlite
#else
#include "VData_Receiver.h"
#define	SIMCLASS	VData_Receiver
#endif
#include "verilated_vcd_c.h"
#include "uartsim.h"

int	main(int argc, char **argv) 
{
	Verilated::commandArgs(argc, argv);
	UARTSIM		*uart;
	bool		run_interactively = false;
	int		port = 0;
	unsigned	setup = 868;
	char string[] = "12\r\n";

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

	if (run_interactively) 
    {
		// Setup the model and baud rate
		// {{{
		SIMCLASS tb;
		tb.i_uart_rx = 1;
		// }}}


		// {{{
		uart = new UARTSIM(port);
		uart->setup(setup);

		while(1) 
        {

			tb.clk = 1;
			tb.eval();
			tb.clk = 0;
			tb.eval();

			tb.i_uart_rx = (*uart)(tb.o_uart_tx);
		}
		// }}}
	} else 
    {
		// Set up a child process
		// {{{
		int	childs_stdin[2], childs_stdout[2];

		if ((pipe(childs_stdin)!=0)||(pipe(childs_stdout) != 0)) 
        {
			fprintf(stderr, "ERR setting up child pipes\n");
			perror("O/S ERR");
			printf("TEST FAILURE\n");
			exit(EXIT_FAILURE);
		}

		pid_t childs_pid = fork();

		if (childs_pid < 0) 
        {
			fprintf(stderr, "ERR setting up child process\n");
			perror("O/S ERR");
			printf("TEST FAILURE\n");
			exit(EXIT_FAILURE);
		}
		// }}}

		if (childs_pid) 
        { // The parent, feeding the simulation
			// {{{
			int	nr=-2, nw;

			// We are the parent
			close(childs_stdin[ 0]); // Close the read end
			close(childs_stdout[1]); // Close the write end

			char test[256];

			nw = write(childs_stdin[1], string, strlen(string));
			if (nw == (int)strlen(string)) 
            {
				int	rpos = 0;
				test[0] = '\0';
				while((rpos<nw)
					&&(0<(nr=read(childs_stdout[0],
						&test[rpos], strlen(string)-rpos))))
					rpos += nr;
				
				nr = rpos;
				if (rpos > 0)
					test[rpos] = '\0';
				printf("Successfully read %d characters: %s\n", nr, test);
			}

			int	status = 0, rv = -1;

			// Give the child the oppoortunity to take another
			// 60 seconds to finish closing itself
			for(int waitcount=0; waitcount < 60; waitcount++) 
            {
				rv = waitpid(-1, &status, WNOHANG);
				if (rv == childs_pid)
					break;
				else if (rv < 0)
					break;
				else // rv == 0
					sleep(1);
			}

			if (rv != childs_pid) 
            {
				kill(childs_pid, SIGTERM);
				printf("WARNING: Child/simulator did not terminate normally\n");
			}

			if (WEXITSTATUS(status) != EXIT_SUCCESS) 
            {
				printf("WARNING: Child/simulator exit status does not indicate success\n");
			}

			if ((nr == nw)&&(nw == (int)strlen(string))
					&&(strcmp(test, string) == 0)) 
            {
				printf("PASS!\n");
				exit(EXIT_SUCCESS);
			} else 
            {
				printf("TEST FAILED\n");
				exit(EXIT_FAILURE);
			}
			// }}}
		} else 
        { // The child (Verilator simulation)
			// {{{

			// Fix up the FILE I/O
			// {{{
			close(childs_stdin[ 1]);
			close(childs_stdout[0]);
			close(STDIN_FILENO);
			if (dup(childs_stdin[0]) < 0) 
            {
				fprintf(stderr, "ERR setting up child FD\n");
				perror("O/S ERR");
				exit(EXIT_FAILURE);
			}
			close(STDOUT_FILENO); 
			if (dup(childs_stdout[1]) < 0) 
            {
				fprintf(stderr, "ERR setting up child FD\n");
				perror("O/S ERR");
				exit(EXIT_FAILURE);
			}

			// Setup the model and baud rate
			// {{{
			SIMCLASS tb;
			int baudclocks = setup & 0x0ffffff;
			tb.i_uart_rx = 1;
			// }}}

			// UARTSIM(0) uses stdin and stdout for its FD's
			uart = new UARTSIM(0);
			uart->setup(setup);
			// }}}

			// Make sure we don't run longer than 4 seconds ...
			time_t	start = time(NULL);
			int	iterations_before_check = 2048;
			unsigned	clocks = 0;
			bool	done = false;

			// VCD trace setup
			// {{{
#define	VCDTRACE
#ifdef	VCDTRACE
			Verilated::traceEverOn(true);
			VerilatedVcdC* tfp = new VerilatedVcdC;
			tb.trace(tfp, 99);
			tfp->open("Data_Receiver.vcd");
#define	TRACE_POSEDGE	tfp->dump(10*clocks)
#define	TRACE_NEGEDGE	tfp->dump(10*clocks+5)
#define	TRACE_CLOSE	tfp->close()
#else
#define	TRACE_POSEDGE	while(0)
#define	TRACE_NEGEDGE	while(0)
#define	TRACE_CLOSE	while(0)
#endif
			// }}}

			// Clear any initial break condition
			// {{{
			for(int i=0; i<(baudclocks*24); i++) {
				tb.clk = 1;
				tb.eval();
				tb.clk = 0;
				tb.eval();

				tb.i_uart_rx = 1;
			}
			// }}}

			// Simulation loop: process the hello world string
			// {{{
			while(clocks < 2*(baudclocks*16)*strlen(string)) {
				tb.clk = 1;
				tb.eval();
				TRACE_POSEDGE;
				tb.clk = 0;
				tb.eval();
				TRACE_NEGEDGE;
				clocks++;

				tb.i_uart_rx = (*uart)(tb.o_uart_tx);

				if (false) { // Used only for debugging
					// {{{
					/*
					static long counts = 0;
					static int lasti = 1, lasto = 1;
					bool	writeout = false;

					counts++;
					if (lasti != tb.i_uart) {
						writeout = true;
						lasti = tb.i_uart;
					} if (lasto != tb.o_uart) {
						writeout = true;
						lasto = tb.o_uart;
					}

					if (writeout) {
					fprintf(stderr, "%08lx : [%d -> %d] %02x:%02x (%02x/%d) %d,%d->%02x [%2d/%d/%08x]\n",
						counts, tb.i_uart, tb.o_uart,
						tb.v__DOT__head,
						tb.v__DOT__tail,
						tb.v__DOT__lineend,
						tb.v__DOT__run_tx,
						tb.v__DOT__tx_stb,
						tb.v__DOT__transmitter__DOT__r_busy,
						tb.v__DOT__tx_data & 0x0ff,
						tb.v__DOT__transmitter__DOT__state,
						tb.v__DOT__transmitter__DOT__zero_baud_counter,
						tb.v__DOT__transmitter__DOT__baud_counter);
					} */
					// }}}
				}

				if (iterations_before_check-- <= 0) {
					iterations_before_check = 2048;
					done = ((time(NULL)-start)>60);
					if (done)
					fprintf(stderr, "CHILD-TIMEOUT\n");
				}
			}
			// }}}

			TRACE_CLOSE;

			exit(EXIT_SUCCESS);
			// }}}
		}
	}
}
