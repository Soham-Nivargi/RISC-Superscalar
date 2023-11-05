transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vcom -93 -work work {EE309_Pipeline.vho}

vcom -93 -work work {D:/study/4th_sem/ee_309/Project_testing/Testbench.vhdl}

vsim -t 1ps -L altera -L altera_lnsim -L fiftyfivenm -L gate_work -L work -voptargs="+acc"  Testbench

add wave *
view structure
view signals
run 1500 ns
