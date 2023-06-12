# Read command parameters
set sources [lindex $argv 0]
set constraints [lindex $argv 1]
set includes [lindex $argv 3]
set top_module [lindex $argv 2]
set partname [lindex $argv 3]
set file_utilization [lindex $argv 4]
set file_utilization_hierarchical [lindex $argv 5]
set file_timing [lindex $argv 6]
set file_timing_summary [lindex $argv 7]
set file_clocks [lindex $argv 8]
set parameters [lindex $argv 9]
set macros [lindex $argv 10]

set_property top TranAndRecei [current_fileset]
# catch {set fptr [open $sources_file r]} ;
# set contents [read -nonewline $fptr] ;
# close $fptr ;
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
# set_property file_type "Verilog Header" [get_files $includes]
# set_property is_global_include true [get_files $includes]
puts $macros

synth_design \
    -part $partname \
    -top $top_module \
    -mode out_of_context \
    -verilog_define $macros
#read physical and timing constraints from one of more files.
read_xdc $constraints

#Optimize the current netlist. This will perform the retarget, propconst, sweep and bram_power_opt optimizations by default.
opt_design

#Automatically place ports and leaf-level instances
place_design

#Route the current design
route_design
#Compute utilization of device and display report
report_utilization -file $file_utilization
report_utilization -hierarchical -hierarchical_depth 6 -file $file_utilization_hierarchical
#Report timing paths
report_timing -file $file_timing
#Report timing summary
report_timing_summary -file $file_timing_summary
#Report clocks
report_clocks -file $file_clocks


