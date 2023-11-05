library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity pc is
port(
clock: in std_logic;
rst: in std_logic;
bubble: in std_logic;
check: in std_logic;
check1: in std_logic;
adder1out: in std_logic_vector(15 downto 0);
alu2out: in std_logic_vector(15 downto 0);
pcout: out std_logic_vector(15 downto 0)
);
end pc;

architecture beh of pc is

signal pc1 : std_logic_vector(15 downto 0) := "0000000000000000";

begin
	
	process(clock, rst, check) --program counter register
		
	begin
		
		if(rst = '1') then
			
			pc1 <= "0000000000000000";
			
		else
		
			if(falling_edge(clock)) then
				
				if(bubble = '0' and check1 = '0') then
					
					if(check = '0') then
						pc1 <= adder1out; --pc update
						
					elsif(check = '1') then
						pc1 <= alu2out; --pc update for beq, blt, ble, jal, jlr, jri
						
					end if;
					
				end if;
			
			else
				
				pc1 <= pc1;
				
			end if;
			
		end if;
		
	end process;
	
	pcout <= pc1;
	
end beh;