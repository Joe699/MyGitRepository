onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib syncprotect_lutrom_opt

do {wave.do}

view wave
view structure
view signals

do {syncprotect_lutrom.udo}

run -all

quit -force
