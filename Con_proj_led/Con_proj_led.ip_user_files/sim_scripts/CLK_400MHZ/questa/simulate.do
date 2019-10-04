onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib CLK_400MHZ_opt

do {wave.do}

view wave
view structure
view signals

do {CLK_400MHZ.udo}

run -all

quit -force
