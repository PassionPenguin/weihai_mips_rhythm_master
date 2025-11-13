# vivado_sim.tcl - Automated Vivado simulation script
# Usage: vivado -mode batch -source scripts/vivado_sim.tcl -tclargs <test_name>

# Get test name from arguments (default: test_memory)
if { $argc > 0 } {
    set test_name [lindex $argv 0]
} else {
    set test_name "test_memory"
}

puts "========================================="
puts "Vivado Automated Simulation"
puts "Test: $test_name"
puts "========================================="
puts ""

# Set project paths
set project_dir "vivado_sim"
set project_name "mips_cpu_sim"

# Create project directory if it doesn't exist
file mkdir $project_dir

# Create new project
create_project -force $project_name $project_dir -part xc7a35tcpg236-1

# Add source files
puts "Adding source files..."
add_files {
    mips32.v
    controller.v
    datapath.v
    alucontrol.v
    exmemory.v
    cpu_modules/alu.v
    cpu_modules/flop.v
    cpu_modules/mux.v
    cpu_modules/regfile.v
    cpu_modules/zerodetect.v
}

# Add testbench
add_files -fileset sim_1 testbench.v

# Set testbench as top
set_property top testbench [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Running simulation..."
puts ""

# Launch simulation
launch_simulation

# Run simulation for specified time
run 50us

# Check for errors
set errors [get_msg_config -severity ERROR -count]
set warnings [get_msg_config -severity WARNING -count]

puts ""
puts "========================================="
puts "Simulation Results:"
puts "  Errors:   $errors"
puts "  Warnings: $warnings"
puts "========================================="

# Save waveform
if { [current_sim] != "" } {
    puts "Saving waveform..."
    set wcfg_file "$project_dir/${test_name}_waveform.wcfg"
    save_wave_config $wcfg_file
    puts "Waveform saved to: $wcfg_file"
}

# Close simulation
close_sim -quiet

# Generate report
set report_file "$project_dir/${test_name}_report.log"
set fp [open $report_file w]
puts $fp "Simulation Report for $test_name"
puts $fp "=================================="
puts $fp "Date: [clock format [clock seconds]]"
puts $fp ""
puts $fp "Errors: $errors"
puts $fp "Warnings: $warnings"
puts $fp ""
close $fp

puts ""
puts "Report saved to: $report_file"
puts ""

if { $errors > 0 } {
    puts "SIMULATION FAILED with $errors errors"
    exit 1
} else {
    puts "SIMULATION COMPLETED SUCCESSFULLY"
    exit 0
}
