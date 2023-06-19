# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 
set top_module [lindex $argv 1]

open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target

current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE $top_module.bit [lindex [get_hw_devices] 0] [current_hw_device] 

program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]