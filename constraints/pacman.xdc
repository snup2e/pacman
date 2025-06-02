set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports rst]



set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33} [get_ports btn_left]
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVCMOS33} [get_ports btn_right]
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports btn_up]
set_property -dict {PACKAGE_PIN N22 IOSTANDARD LVCMOS33} [get_ports btn_down]


set_property -dict {PACKAGE_PIN K22 IOSTANDARD LVCMOS33} [get_ports hsync]
set_property -dict {PACKAGE_PIN K21 IOSTANDARD LVCMOS33} [get_ports vsync]

set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {vga_r[3]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {vga_r[2]}]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports {vga_r[1]}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {vga_r[0]}]

set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports {vga_g[3]}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports {vga_g[2]}]
set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS33} [get_ports {vga_g[1]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports {vga_g[0]}]

set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports {vga_b[3]}]
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS33} [get_ports {vga_b[2]}]
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports {vga_b[1]}]
set_property -dict {PACKAGE_PIN J22 IOSTANDARD LVCMOS33} [get_ports {vga_b[0]}]

#set_property CONFIG_MODE SPIx4 [current_design]
#set_property BITSTREAM.CONFIG_SPI_BUSWIDTH 4 [current_design]

