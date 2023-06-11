create_clock -name clock -period 20.000 [get_ports {clock}]
derive_pll_clocks
set_false_path -from [get_ports {n_rst}]