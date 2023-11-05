transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/converter.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/adder1.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/DUT.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/SE10.vhd}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/SE7.vhd}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/imem.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/dmem.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/registerfiles.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/pc.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/ifid.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/idrr.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/rrex.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/exmem.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/memwb.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/datapath.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/alu2.vhd}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/contorller.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/cz.vhdl}
vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/complimentor.vhdl}

vcom -93 -work work {D:/study/4th_sem/ee_309/EE309_project/Quartus_code_and_simulation/Project/Testbench.vhdl}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  Testbench

add wave *
view structure
view signals
run 500 ns
