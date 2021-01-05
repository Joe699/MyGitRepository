onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib walshtable_opt

do {wave.do}

view wave
view structure
view signals

do {walshtable.udo}

run -all

quit -force
