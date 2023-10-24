# SECTION 1: Project's Structure and How to Use the Makefile

## Project's Structure
The project is a GNU Makefile project.
The modules are written in Verilog and parameterized with built-in Verilog mechanisms, SageMath, and Python scripts.

The purpose of projects is testing the ClassicMelieHW via UART protocol. We can generate the data from SageMath and send these data from Python scripts to the ClassicMelieHW module via UART protocol. And We also can check the data and finished time via Python terminal.

The makefile project automates the source, simulation, synthesis, implementation, generate the bitstream, and program the FPGA(for Xilinx devices) 

The makefile structure enables the automated building process
for the various specified parameter sets, module configurations, and FPGA models. 

The purpose of the individual folders is as follows:

| Folder          | Description                                                                |
| --------------- | -------------------------------------------------------------------------- |
| `build/`        | Build folder including generated sources, results, and simulation file.                                                                                          |
| `host/`         | Python test code. It include the scripts to test the encapsulation module in the ClassicMcelieHW project.                                                                       |
| `host/kat`      | Know answer test generation anf verification scripts.                      |
| `modules/`      | User HDL code. This includes these top modules Verilog file and modules/FPGA folder.                                                                                        |
| `platform/`     | simulation CPP code is used to simulate these top modules, including `platform/cpp` and `platform/rtl`. The folder cpp has a cpp file to simulate via Verilator. The folder rtl has these modules for UART communication                     | 
| `Makefile`      | Top Makefile.                                          |
| `config.mk`     | To make sure we need to move the previous target when running the new target|
| `FPGA.mk`       | To run for TARGET = ArtixA7 for synthesis, implement, generate bit-stream, and program for FPGA                                            |
| `simulation.mk` | To run for the TARGET = sim for simulation             |
| `target.mk`     | To set the target for the top make file                    |

## How to use the Makefile

The top Makefile includes the cumulated targets for the sub-targets defined in the sub-Makefiles in the individual sub-folders. 
All targtes have their dependencies so that you can build arbitrary targets and all dependencies are build recursively. 
This enables a parallel build process as well. 

To generate targets for all parameter sets, the Makefiles use the second expansion feature of make, c.f., [3].
Therewith, we are able to generate targets for all combinations, e.g., over all Classic McEliece parameter sets, design simulators, or supported FPGA models,for design source generation, simulation execution, or synthesis runs.

**Before we run the code, make sure you have installed: sage --pip install uttlv sage --pip install pySerial**

The purpose test is interfaces between serial IO and the encaps top module to receive commands and to receive and send data as requested. A sequence of commands sends from the host to the FPGA could be:

1. set public key

2. set seed

### Target 'sim':

  ```bash
  make TARGET=sim
  ```
  When we run the command:

   The program will generate the kat file `host/kat/kat_generate`, and generate these folder `build/simulation/cpp`, `build/simulation/rtl`, `/build/simulation/verilog`. Then, The program will run `.mk file` of each folder. After running, the terminal will compile and run the code. It will open the pseudo-terminal and wait for the test file from `host/` folder.
  
   `Example 1:`
  
  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     --------------------------------------------------------------------------              |
  |`./encap_sim`             | `python3 Test_encap_sim.py /dev/pts/4 set_seed`            |
  | Slave device: /dev/pts/4 |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20400000000                               |
  |                          |    Send Data:  0x20401000000                               |
  |[mceliece348864] Start Encapsulation. (5155211 cycles) |                               |

  `Example 2:`

#### NOTE:
If you want to run the simulation of Data_Receiver modules. Go into the folder `platform/cpp/cpp` and remove the `#` character at test target.
### Target 'ArtixA7':

  ```bash
  make TARGET=ArtixA7
  ```
  When we run the command:
  
  The program will generate the `build/Artycs324g/Top_moduleName/src` and `build/results`. The `build/Artycs324g/Top_moduleName/src` has all the Verilog files on your project. The `build/results` has the log file which stores the command line on the bash.

   `Example 1:`
  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     --------------------------------------------------------------------------              |
  |`./Data_Receiver`         | `python3 Test_Data_Receiver.py /dev/ttyUSB1`               |
  |                          | Send Data:  Hello from Python file                         |
  |                          | Received Data:  Hello from Python file                     |

   `Example 2:`
  * The syntax additional: python3 Test_TranAndRecei.py /dev/ttyUSB1 110 101 add
  * The syntax subtraction: python3 Test_TranAndRecei.py /dev/ttyUSB1 110 101 sub
  * The syntax multiplicaton: python3 Test_TranAndRecei.py /dev/ttyUSB1 110 101 mul
  * The syntax division: python3 Test_TranAndRecei.py /dev/ttyUSB1 110 101 div

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     --------------------------------------------------------------------------              |
  |`./TranAndRecei`          | `python3 Test_TranAndRecei.py /dev/ttyUSB1 110 100 add`        |
  |                          | Send Data:  0x6e64010c0a                                        |
  |                          |  Number of Bytes: 7.0                                       |
  |                          |  Received Data:  0x20206e640100d20a                           |
  |                          |  Number1:  0x6e 110                                         |
  |                          |  Number2:  0x64 100                                         |
  |                          |  Operand:  0x1 add                                          |
  |                          |  Result:  0xd2 210                                          |           
  
  ## NOTE:
   - We need to use `make clean` before running the new target
   - To list the USB port of your device, open the terminal: `sudo ls /dev/ttyUSB*`


# SECTION 2: What needs to be changed to adapt the code for another design

  
  ## With TARGET=sim

   - The `modules/` folder to change the top modules' Verilog files

   - The `platform/cpp` to change the simulation top modules file
   
   - The `simulation.mk`to change the name of the modules at the TOPMODULES and TOPMODULES_SIMU variables in this file.

  ## With TARGET=ArtixA7

   - Make sure you have already installed follow `modules/FPGA/tools.mk`

   - Plug your FPGA board

   - The `FPGA.mk` to change the top modules at TOPMODULES variable

   - The `modules/FPGA/parameter.mk` to change the package following your FPGA. 
   Example: my FPGA board is Artix-7 with package csg324
   
   - The `modules/FPGA/Xilinx/models` to change the Xilinx model. 
   Example: my FPGA board is xc7a100tcsg324-1 model

   - The `modules/FPGA/Xilinx/pin_artix7_100t.xdc` to configure the pin planner for your FPGA

   - Another file in `modules/FPGA/Xilinx/timing__` to create the clock for FPGA, we don't need to change

   - The `modules/modules.mk/` to change the top modules. 
   Example: If I want to program FPGA with Data_Receiver is a top module. I only change the name of the top module at TOPMODULE and TOPMODULE_CHECK variable and also delete the fullAdder.v at MODULESTOP_SRC variable because, in the Data_Receiver, I don't use the alu module.



  
