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

**ENCAPSULATION MODULE**

1. set_seed: This is a loading seed data from `host/kat/kat_generate/mem_512.kat` to memory in encap_sim module via UART protocol.

2. set_pk: This is a loading public key data from `host/kat/kat_generate/pubkey_32.kat` to memory in encap_sim module via UART protocol.

3. start_encap: This is a command for starting encapsulation.

4. check_data: After finish the encapsulation, the python scrpit will be created 3 file `build/result/cipher_0.out`,`build/result/cipher_1.out`, `build/result/K.out` by receiving these data from encap_sim module. The check_data command will be check the output data by running `host/kat/kat.sage.py`.

### The following step for testing could be:
- `Step 1`: set_seed or set_pk command.
- `Step 2`: set_seed or set_pk command.
- `Step 3`: start_encap command.
- `Step 4`: check_data command


### Target 'sim':

  ```bash
  make TARGET=sim
  ```
  When we run the command:

   The program will generate the kat file `host/kat/kat_generate`, and generate these folder `build/simulation/cpp`, `build/simulation/rtl`, `/build/simulation/verilog`.The result foler have a 3 output file `build/result/cipher_0.out`,`build/result/cipher_1.out`, `build/result/K.out`. Then, The program will run `.mk file` of each folder. After running, the terminal will compile and run the code. It will open the pseudo-terminal and wait for the test file from `host/` folder.
  

   `Example 1:`

  - `First` is a loading seed data from seed file to memory by `set_seed` command.

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     -------------------------------------------------------|
  |`./encap_sim`             | `python3 Test_encap_sim.py /dev/pts/4 3000000 set_seed`       |
  | Slave device: /dev/pts/4 |    Send Data:  0x240000........00001000000                 |
  |                          |-------------------Read Data-------------------             |
  | [mceliece348864] Send Seed data completed| Send Seed data completed.                  |

  - `Second` is a loading public data from public key file to memory by `set_pk` command.

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     -------------------------------------------------------|
  |`./encap_sim`             | `python3 Test_encap_sim.py /dev/pts/4 3000000 set_pk`         |
  | Slave device: /dev/pts/4 |  Send Data:  0x18303fc00a74c0bdf......29ce66c80ae3d69e25799|
  |                          |-------------------Read Data-------------------             |
  | [mceliece348864] Send Public key data completed.| Send Public key data completed.     |

  - `Third` is a starting to encapsulation by `start_encap` command.

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     -------------------------------------------------------|
  |`./encap_sim`             | `python3 Test_encap_sim.py /dev/pts/4 3000000 start_encap`         |
  | Slave device: /dev/pts/4 |  Send Data:  0x30101                                       |
  |                          |-------------------Read Data-------------------             |
  |[mceliece348864] Start Encapsulation. (5155211 cycles) |Start Encapsulation:  5155211 cycles  |
  |[mceliece348864] Start FixedWeight. (5155211 cycles)   |Stop Encapsulation:  17897  cycles    |
  |[mceliece348864] Start Encode. (5155752 cycles)        |Start FixedWeight:  5155211 cycles    |
  |[mceliece348864] FixedWeight finished. (541 cycles)    |Stop FixedWeight:  541 cycles         |
  |[mceliece348864] Encode finished. (16899 cycles)       |Start Encode:  5155752 cycles         |
  |[mceliece348864] Encapsulation finished. (17897 cycles)|Stop Encode:  16899 cycles            |
  |                          |-------------------Writting to file-------------------             |
  |                          | cipher_0.out:Done                                                 |
  |                          | cipher_1.out:Done                                                 |
  |                          | K.out:Done                                                        |

  - `Finally` is a checking data from 3 file which is created a python script at a `build/result/` folder by `check_data` command.

  |   TEST PYTHON FILE                                             |
  | ---------------                                                |
  | `python3 Test_encap_sim.py check_data`                         |
  |------------------Checking encapsulation data-------------------|
  |[mceliece348864-KAT] Checking encapsulation data.               |
  |[mceliece348864-32-encapsulation] Test Passed!                  |
### Target 'ArtixA7':

  ```bash
  make TARGET=ArtixA7
  ```
  When we run the command:
  
  - The program will generate the `build/Artycs324g/Top_moduleName/src` and `build/results`. The `build/Artycs324g/Top_moduleName/src` has all the Verilog files on your project. The `build/results` has the log file which stores the command line on the bash.
  - Changing the baud rate of UART or the FPGA clock at `target.mk`

  ## NOTE:
   - We need to use `make clean` before running the new target
   - To list the USB port of your device, open the terminal: `sudo ls /dev/ttyUSB*`


**DECAPSULATION MODULE**
1. set_s: This is a Delta data from `host/kat/kat_generate/s.kat` to memory in encap_sim module via UART protocol.

2. set_C1: This is a C1 data from `host/kat/kat_generate/cipher_1.kat` to memory in encap_sim module via UART protocol.

3. set_C0: This is a C0 data from `host/kat/kat_generate/cipher_0.kat` to memory in encap_sim module via UART protocol.

4. set_POLY: This is a POLY data from `host/kat/kat_generate/poly_g.kat` to memory in encap_sim module via UART protocol.

5. start_decap: This is a command for starting decapsulation.

6. check_data: After finish the encapsulation, the python scrpit will be created 1 file `build/result/K.out` by receiving these data from decap_sim module. The check_data command will be check the output data by running `host/kat/kat.sage.py`.

### The following step for testing could be:
- `Step 1`: set_s command.
- `Step 2`: set_C1 command.
- `Step 3`: set_C0 command.
- `Step 4`: set_POLY command.
- `Step 5`: start_decap command.
- `Step 6`: check_data command.

### Target 'sim':

- `First` is a loading Delta data from Delta file to memory by `set_s` command.

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     -------------------------------------------------------|
  |`./decap_sim`             | `python3 Test_decap_sim.py /dev/pts/4 3000000 set_s`       |
  | Slave device: /dev/pts/4 |    Send Data:  0x12073........748167                       |
  |                          |-------------------Read Data-------------------             |
  | [mceliece348864] Send Delta data completed| Send Delta data completed.                |

  - `Second` is a loading C1 data from C1 file to memory by `set_C1` command.

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     -------------------------------------------------------|
  |`./decap_sim`             | `python3 Test_decap_sim.py /dev/pts/4 3000000 set_C1`      |
  | Slave device: /dev/pts/4 |  Send Data:  0x220bff7......df4f3111b7723f71502a           |
  |                          |-------------------Read Data-------------------             |
  | [mceliece348864] Send C1 data completed.| Send C1 data completed.                     |

  - `Third` is a loading C0 data from C0 file to memory by `set_C0` command.

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     -------------------------------------------------------|
  |`./decap_sim`             | `python3 Test_decap_sim.py /dev/pts/4 3000000 set_C0`      |
  | Slave device: /dev/pts/4 |  Send Data:  0x3604f306de1ef2b7b39......6ad84c877          |
  |                          |-------------------Read Data-------------------             |
  | [mceliece348864] Send C0 data completed.| Send C0 data completed.                     |

  - `Fouth` is a loading POLY data from C0 file to memory by `set_POLY` command.

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     -------------------------------------------------------|
  |`./decap_sim`             | `python3 Test_decap_sim.py /dev/pts/4 3000000 set_POLY`    |
  | Slave device: /dev/pts/4 |  Send Data:  0x46400106afd78d9d0......b3500000             |
  |                          |-------------------Read Data-------------------             |
  | [mceliece348864] Send POLY data completed.| Send POLY data completed.                 |
  
  - `Fifth` is a a starting to decapsulation by `start_decap` command.

  | TOP MODULE FILE          |      TEST PYTHON FILE                                      |
  | ---------------          |     -------------------------------------------------------|
  |`./decap_sim`             | `python3 Test_decap_sim.py /dev/pts/4 3000000 start_decap` |
  | Slave device: /dev/pts/4 |  Send Data: 0x50101                                        |
  |                          |-------------------Read Data-------------------             |
  | [mceliece348864] FieldOrdering module started | FieldOrdering module started          |
  | [mceliece348864] FieldOrdering finished. (32790 cycles) | FieldOrdering finished. 32790  cycles             |
  | [mceliece348864] Decapsulation module started | Decapsulation module started          |
  | [mceliece348864] Decapsulation module finished. (6940 cycles) [re-encrypt succeeded] | Decapsulation module finished. 6940 cycles [re-encrypt succeeded]         |
  | [mceliece348864] FieldOrdering and Decapsulation require 39730 cycles | FieldOrdering and Decapsulation require 39730 cycles          |
  |  | -------------------Writting to file-------------------          |
  |  | K.out:Done          |

  - `Finally` is a checking data from 1 file which is created a python script at a `build/result/` folder by `check_data` command.

  |   TEST PYTHON FILE                                             |
  | ---------------                                                |
  | `python3 Test_decap_sim.py check_data`                         |
  |------------------Checking decapsulation data-------------------|
  |[mceliece348864-32-decapsulation] Test Passed!                  |

### Target 'clean':
To delete all of the generated file and folder during building the code processing.

### Target 'clean_withou_kat':
To also delete all of the generated file and folder during building the code processing expect the kat generate folder.

# SECTION 2: What needs to be changed to adapt the code for another design

  
  ## With TARGET=sim

   - The `modules/` folder to change the top modules' Verilog files

   - The `platform/cpp` to change the simulation top modules file
   
   - The `target.mk`to change the name of the modules at the TOPMODULES and TOPMODULES_SIMU variables in this file. With TOPMODULES variable is a module we want to test such as: encap, decap... And the TOPMODULES_SIMU variable is a module at the testbench folder of each module such as: In the testbench folder in the encap folder we has the encap_sim.v that is a testbench file for encap module. In the project, the TOPMODULES_SIMU is a top-module.

  ## With TARGET=ArtixA7

   - Make sure you have already installed follow `modules/FPGA/tools.mk`

   - Plug your FPGA board

   - The `FPGA.mk` to change the top modules at TOPMODULES variable

   - The `modules/FPGA/parameter.mk` to change the package following your FPGA. 
   Example: my FPGA board is Artix-7 with package csg324
   
   - The `modules/FPGA/Xilinx/models` to change the Xilinx model. 
   Example: my FPGA board is xc7a100tcsg324-1 model

   - The `modules/FPGA/Xilinx/pin_artix7_100t.xdc` to configure the pin planner for your FPGA

   - Another file in `modules/FPGA/Xilinx/timing__` to create the clock for FPGA, we don't need to change.

   - The `target.mk`to change the name of the modules at the TOPMODULES and TOPMODULES_SIMU variables in this file. With TOPMODULES variable is a module we want to test such as: encap, decap... And the TOPMODULES_SIMU variable is a module at the testbench folder of each module such as: In the testbench folder in the encap folder we has the encap_sim.v that is a testbench file for encap module. In the project, the TOPMODULES_SIMU is a top-module.
