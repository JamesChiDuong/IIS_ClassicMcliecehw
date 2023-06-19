# 
# Copyright (C) 2022
#
# Authors: James <chiduong1312@gmail.com>
# 
# Read command parameters
set sources [lindex $argv 0]
set constraints_timing [lindex $argv 1]
set constraints_pin [lindex $argv 2]

set top_module [lindex $argv 3]
set partname [lindex $argv 4]
set file_utilization [lindex $argv 5]
set file_utilization_hierarchical [lindex $argv 6]
set file_timing [lindex $argv 7]
set file_timing_summary [lindex $argv 8]
set file_clocks [lindex $argv 9]
set parameters [lindex $argv 10]
set macros [lindex $argv 11]

#Read .v type file
puts $sources
set splitCont [split $sources " "] ;
puts $splitCont
foreach f $splitCont {
    puts $f
    set pat ".vhd"
    set patv ".v"
    if [string match *$pat $f] {
        read_vhdl $f
    } elseif [string match *$patv $f] {
        read_verilog $f
    } else {
        # do nothing
    }
}

puts $parameters
set splitPar [split $parameters " "] ;
puts $splitPar
foreach f $splitPar {
    puts $f
	set_property generic {$f} [current_fileset]
}

puts $macros
#We need to create the clock before synthesis by read xdc timing

#--STEP1: Synthesis design

read_xdc $constraints_timing

synth_design \
    -part $partname \
    -top $top_module \
    -mode default \
    -verilog_define $macros

#After synthesis and befor implement we will read xdc pin
#Reference: https://docs.xilinx.com/v/u/2013.2-English/ug903-vivado-using-constraints

#--STEP2: Implement design
read_xdc $constraints_pin

opt_design
set ACTIVE_STEP opt_design


place_design
set ACTIVE_STEP place_design

place_design

phys_opt_design
set ACTIVE_STEP phys_opt_design

route_design
set ACTIVE_STEP route_design


#Compute utilization of device and display report
report_utilization -file $file_utilization
report_utilization -hierarchical -hierarchical_depth 6 -file $file_utilization_hierarchical
#Report timing paths
report_timing -file $file_timing
#Report timing summary
report_timing_summary -file $file_timing_summary
#Report clocks
report_clocks -file $file_clocks

##--STEP3: Generated bitstream

write_bitstream -force $top_module.bit
set ACTIVE_STEP write_bitstream

open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target

current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE $top_module.bit [lindex [get_hw_devices] 0]

program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]