create_clock -name clock -period 10.000 [get_ports {clock}]
set_false_path -from [get_ports {n_rst}]