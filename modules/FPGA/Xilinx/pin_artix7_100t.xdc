# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 
## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Switches
#set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {slideSwitch[0]}]
#set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {slideSwitch[1]}]
#set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports {slideSwitch[2]}]
#set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports {slideSwitch[3]}]

## LEDs
#set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {data[4]}]
#set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {data[5]}]
#set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {data[6]}]
#set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {data[7]}]
## RGB LEDs
set_property -dict { PACKAGE_PIN E1    IOSTANDARD LVCMOS33 } [get_ports { rx_empty }]; #IO_L18N_T2_35 Sch=led0_b
set_property -dict { PACKAGE_PIN F6    IOSTANDARD LVCMOS33 } [get_ports { rx_full }]; #IO_L19N_T3_VREF_35 Sch=led0_g
#set_property -dict { PACKAGE_PIN J4    IOSTANDARD LVCMOS33 } [get_ports { slideSwitch[4] }]; #IO_L21P_T3_DQS_35 Sch=led1_g
#set_property -dict { PACKAGE_PIN G3    IOSTANDARD LVCMOS33 } [get_ports { slideSwitch[5] }]; #IO_L20N_T3_35 Sch=led1_r
#set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { slideSwitch[6] }]; #IO_L21N_T3_DQS_35 Sch=led2_b
#set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { slideSwitch[7] }]; #IO_L22N_T3_35 Sch=led2_g
## Buttons
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports btn0]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports btn1]
set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports { btn2 }]; #IO_L11N_T1_SRCC_16 Sch=btn[2]
## USB-UART Interface
# set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports o_uart_tx]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
# set_property -dict { PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]

## Pmod Header JA
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { data[0] }]; #IO_0_15 Sch=ja[1]
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { data[1] }]; #IO_L4P_T0_15 Sch=ja[2]
set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { data[2] }]; #IO_L4N_T0_15 Sch=ja[3]
set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports { data[3] }]; #IO_L6P_T0_15 Sch=ja[4]
set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS33 } [get_ports { data[4] }]; #IO_L6N_T0_VREF_15 Sch=ja[7]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { data[5] }]; #IO_L10P_T1_AD11P_15 Sch=ja[8]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { data[6] }]; #IO_L10N_T1_AD11N_15 Sch=ja[9]
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { data[7] }]; #IO_25_15 Sch=ja[10]


## ChipKit Outer Digital Header
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { o_uart_tx  }]; #IO_L16P_T2_CSI_B_14 Sch=ck_io[0]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { i_uart_rx  }]; #IO_L18P_T2_A12_D28_14 Sch=ck_io[1]
