# vivado_program.tcl - Program Basys3 board
# Usage: vivado -mode batch -source scripts/vivado_program.tcl

puts "========================================="
puts "Programming Basys3 Board"
puts "========================================="
puts ""

set bitstream "vivado_impl/mips_cpu_basys3.bit"

# Check if bitstream exists
if { ![file exists $bitstream] } {
    puts "ERROR: Bitstream not found: $bitstream"
    puts "Run synthesis first: vivado -mode batch -source scripts/vivado_synth.tcl"
    exit 1
}

# Open hardware manager
open_hw_manager

# Connect to local server
connect_hw_server -url localhost:3121

# Get hardware targets
set targets [get_hw_targets]
if { [llength $targets] == 0 } {
    puts "ERROR: No hardware targets found"
    puts "Make sure:"
    puts "  1. Basys3 board is connected via USB"
    puts "  2. Board is powered on"
    puts "  3. Digilent drivers are installed"
    close_hw_manager
    exit 1
}

# Open first target
set target [lindex $targets 0]
puts "Opening target: $target"
open_hw_target $target

# Get devices
set devices [get_hw_devices]
if { [llength $devices] == 0 } {
    puts "ERROR: No devices found on target"
    close_hw_target
    close_hw_manager
    exit 1
}

# Program first device
set device [lindex $devices 0]
puts "Programming device: $device"
puts "Bitstream: $bitstream"
puts ""

current_hw_device $device
set_property PROGRAM.FILE $bitstream $device

# Program the device
program_hw_devices $device

# Verify
if { [get_property PROGRAM.DONE $device] == 1 } {
    puts ""
    puts "========================================="
    puts "SUCCESS: Device programmed successfully!"
    puts "========================================="
    set result 0
} else {
    puts ""
    puts "========================================="
    puts "ERROR: Programming failed"
    puts "========================================="
    set result 1
}

# Cleanup
close_hw_target
close_hw_manager

exit $result
