onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ram_sum_opt

do {wave.do}

view wave
view structure
view signals

do {ram_sum.udo}

run -all

quit -force
