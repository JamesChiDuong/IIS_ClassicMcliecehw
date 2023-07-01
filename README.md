# Project's Structure
The project is a GNU Makefile project.
The modules are written in Verilog and parameterized with built-in Verilog mechanisms, SageMath, and Python scripts.
The makefile at the top includes targets for the top modules:
    TranAndRecei Data_Transmitter Data Receiver.
The makefile project automates the source, simulation, the synthesis, implement, generate bitstream and program the FPGA(for Xilinx devices) 

The makefile structure enables the automated building process
for the various specified parameters sets,module configarations, and FPGA models. 

The purpose of the individual folders are as follow:

| Folder          | Description                                                                |
| --------------- | -------------------------------------------------------------------------- |
| `build/`        | Build folder including generated sources, results and simulation file.     |
| `host/`         | Python test code                                                           |
| `modules/`      | User HDL code.                                                             |
| `platform/`     | simulation CPP code and UART HDL code.                                     | 
| `Makefile`      | Top Makefile.                                                              |

### Target 'sim':

  ```bash
  make TARGET=sim
  ```
  
  Communication via serial (pts); generate the testbench file, .vcd file, and using to simulation


### Target 'ArtixA7':

  ```bash
  make TARGET=ArtixA7
  ```

  To synthesis, implement, generate a bitstream and program of the FPGA project.