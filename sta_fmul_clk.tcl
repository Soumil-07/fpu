# Read the liberty file
read_liberty sg13g2_stdcell_typ_1p20V_25C.lib

# Read synthesized netlist
read_verilog fmul_clk.out.v

# Link design
link_design fmul_clk

# Define clock (e.g., 100 MHz, 10ns period)
create_clock -name clk -period 5 [get_ports clk]

# Set input and output delays (example: simple ideal IOs)
set_input_delay 0 [all_inputs]
set_output_delay 0 [all_outputs]

# Report timing
report_checks
report_clock_skew
report_wns
report_tns

