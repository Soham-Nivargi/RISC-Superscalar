onerror {resume}
quietly virtual signal -install /testbench { /testbench/output_vector(15 downto 0)} output1
quietly virtual signal -install /testbench { /testbench/output_vector(31 downto 16)} output2
quietly virtual signal -install /testbench { /testbench/output_vector(47 downto 32)} output3
quietly virtual signal -install /testbench {/testbench/output_vector(48)  } bitoutput
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/input_vector
add wave -noupdate /testbench/output1
add wave -noupdate /testbench/output2
add wave -noupdate /testbench/output3
add wave -noupdate /testbench/bitoutput
add wave -noupdate /testbench/output_vector
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {160352 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits sec
update
WaveRestoreZoom {0 ps} {240216 ps}
