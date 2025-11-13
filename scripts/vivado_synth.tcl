# vivado_synth.tcl - Synthesize and implement for Basys3
# Usage: vivado -mode batch -source scripts/vivado_synth.tcl

puts "========================================="
puts "Vivado Synthesis for Basys3"
puts "========================================="
puts ""

# Set project paths
set project_dir "vivado_impl"
set project_name "mips_cpu_basys3"

# Create project directory
file mkdir $project_dir

# Create new project for Basys3
create_project -force $project_name $project_dir -part xc7a35tcpg236-1

puts "Adding RTL sources..."

# Add all RTL source files (not testbench)
add_files {
    fpga_top.v
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

# Add constraints file
add_files -fileset constrs_1 basys3_constraints.xdc

# Set top module
set_property top fpga_top [current_fileset]

puts "Running synthesis..."
synth_design -top fpga_top -part xc7a35tcpg236-1

# Write checkpoint
write_checkpoint -force $project_dir/post_synth.dcp

# Generate synthesis reports
report_timing_summary -file $project_dir/synth_timing.rpt
report_utilization -file $project_dir/synth_utilization.rpt
report_power -file $project_dir/synth_power.rpt

puts ""
puts "Running implementation..."

# Optimize design
opt_design

# Place design
place_design
write_checkpoint -force $project_dir/post_place.dcp
report_timing_summary -file $project_dir/place_timing.rpt

# Route design
route_design
write_checkpoint -force $project_dir/post_route.dcp

# Generate reports
report_timing_summary -file $project_dir/route_timing.rpt
report_utilization -file $project_dir/route_utilization.rpt
report_power -file $project_dir/route_power.rpt
report_drc -file $project_dir/route_drc.rpt

# Check timing
set timing_met [get_property SLACK [get_timing_paths]]
puts ""
puts "========================================="
if { $timing_met >= 0 } {
    puts "TIMING MET (Slack: $timing_met)"
} else {
    puts "TIMING VIOLATION (Slack: $timing_met)"
}
puts "========================================="

# Generate bitstream
puts ""
puts "Generating bitstream..."
write_bitstream -force $project_dir/${project_name}.bit

puts ""
puts "========================================="
puts "Build Complete!"
puts "Bitstream: $project_dir/${project_name}.bit"
puts "========================================="
puts ""
puts "To program the Basys3:"
puts "  1. Open Vivado Hardware Manager"
puts "  2. Connect to target"
puts "  3. Program device with generated .bit file"
puts ""
puts "Or use: vivado -mode batch -source scripts/vivado_program.tcl"

exit 0
