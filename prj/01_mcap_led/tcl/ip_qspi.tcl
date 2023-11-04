create_ip -name axi_quad_spi -vendor xilinx.com -library ip -module_name axi_quad_spi_0    

set_property -dict [list         \
    CONFIG.C_SPI_MODE        {2} \
	CONFIG.C_USE_STARTUP     {1} \
	CONFIG.C_USE_STARTUP_INT {1} \
] [get_ips axi_quad_spi_0]
