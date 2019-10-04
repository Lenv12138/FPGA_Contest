onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.CLK_400MHZ xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {CLK_400MHZ.udo}

run -all

quit -force
