-makelib ies_lib/xil_defaultlib -sv \
  "E:/vivado.2017/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "E:/vivado.2017/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../Con_proj_led.srcs/sources_1/ip/CLK_400MHZ/CLK_400MHZ_clk_wiz.v" \
  "../../../../Con_proj_led.srcs/sources_1/ip/CLK_400MHZ/CLK_400MHZ.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

