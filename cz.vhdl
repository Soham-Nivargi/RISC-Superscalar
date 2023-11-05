library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity cz is
port(
clock: in std_logic;
c: in std_logic;
z: in std_logic;
rst: in std_logic;
carry: out std_logic;
zero: out std_logic
);
end cz;

architecture beh of cz is

signal carry1: std_logic := '0';
signal zero1: std_logic := '0';

begin
	
	process(clock) --carry and zero flag registers
		
	begin
		
		if(rst = '1') then
			
			carry1 <= '0';
			zero1 <= '0';
			
		else
			
			if(falling_edge(clock)) then
				
				carry1 <= c;
				zero1 <= z;
				
			else
				
				carry1 <= carry1;
				zero1 <= zero1;
				
			end if;
			
		end if;
		
	end process;
	
	carry <= carry1;
	zero <= zero1;
	
end beh;