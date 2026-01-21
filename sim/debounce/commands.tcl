# ============================================================================ #
# Specify waves to be saved during the simulation
# ============================================================================ #
# Save top instance signals
log_wave *

# Save DUT instance signals
log_wave /debounce_test/dut/*

# Save all design signals (avoid using this in large designs - performance penalty!)
# log_wave -r *

# ============================================================================ #
# Run the simulation until $finish
# ============================================================================ #
run all

# ============================================================================ #
# Visualize the results
# Note: you can add waves after simulation has completed if they are logged
# ============================================================================ #

# ---------------------------------------------------------------------------- #
# Show all top instance signals (including local parameters)
# ---------------------------------------------------------------------------- #
# add_wave /

# ---------------------------------------------------------------------------- #
# Show all the design signals, recursive  
# Not very useful once your design grows!
# ---------------------------------------------------------------------------- #
# add_wave -r /

# ---------------------------------------------------------------------------- #
# Show selected top instance signals
# ---------------------------------------------------------------------------- #
add_wave_divider "TOP signals (debounce_test)"
add_wave /debounce_test/clk
add_wave /debounce_test/rst_n
add_wave /debounce_test/sw -color orange
add_wave /debounce_test/db_level -color aqua
add_wave /debounce_test/db_tick -color aqua

# ---------------------------------------------------------------------------- #
# Show selected DUT instance signals
# ---------------------------------------------------------------------------- #
add_wave_divider "DUT signals (debounce dut instance)"
add_wave /debounce_test/dut/state_nxt -color gray
add_wave /debounce_test/dut/state
add_wave /debounce_test/dut/q_nxt -color gray
add_wave /debounce_test/dut/q
