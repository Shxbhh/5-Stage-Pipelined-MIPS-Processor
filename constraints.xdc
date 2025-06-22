
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]   # 100 MHz ⇒ 10 ns period :contentReference[oaicite:1]{index=1}

set_property PACKAGE_PIN C13 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property PACKAGE_PIN U16 [get_ports {LED[0]}]
set_property PACKAGE_PIN E19 [get_ports {LED[1]}]
set_property PACKAGE_PIN U19 [get_ports {LED[2]}]
set_property PACKAGE_PIN V19 [get_ports {LED[3]}]
set_property PACKAGE_PIN W18 [get_ports {LED[4]}]
set_property PACKAGE_PIN W17 [get_ports {LED[5]}]
set_property PACKAGE_PIN V17 [get_ports {LED[6]}]
set_property PACKAGE_PIN U17 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[*]}]
set_property PACKAGE_PIN W3  [get_ports {sw[0]}]
set_property PACKAGE_PIN W4  [get_ports {sw[1]}]
set_property PACKAGE_PIN V4  [get_ports {sw[2]}]
set_property PACKAGE_PIN U4  [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

