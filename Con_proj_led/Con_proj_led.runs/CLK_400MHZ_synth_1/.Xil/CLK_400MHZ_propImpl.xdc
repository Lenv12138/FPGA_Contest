set_property SRC_FILE_INFO {cfile:f:/FPGA_Contest_Proj/Con_proj_led/Con_proj_led.srcs/sources_1/ip/CLK_400MHZ/CLK_400MHZ.xdc rfile:../../../Con_proj_led.srcs/sources_1/ip/CLK_400MHZ/CLK_400MHZ.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
