library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity idrr is 
port(
clock: in std_logic;
rst: in std_logic;
Bubble: in std_logic;
dis: in std_logic;
Reg_datain: in std_logic_vector(32 downto 0);
se7: in std_logic_vector(15 downto 0);
se10: in std_logic_vector(15 downto 0);
Reg_dataout: out std_logic_vector(48 downto 0)
);
end idrr;

architecture beh of idrr is 

signal reg: std_logic_vector(48 downto 0) := "1000000000000000000000000000000000000000000000000";

begin
	
	process (clock, rst) --register between instruntion decode stage and register read stage
		
	begin
		
		if(rst = '1') then
			
			reg <= "1000000000000000000000000000000000000000000000000";
			
		else
		
		if(falling_edge(clock)) then
			
			if(bubble = '0') then
				
				reg(48) <= Reg_datain(16) or dis; --disable
				reg(47 downto 32) <= Reg_datain(32 downto 17); --pc
				reg(31 downto 16) <= Reg_datain(15 downto 0); --inst
					
				if(Reg_datain(15 downto 12) = "0000" or Reg_datain(15 downto 12) = "0100" or Reg_datain(15 downto 12) = "0101" or Reg_datain(15 downto 12) = "1000" or Reg_datain(15 downto 12) = "1001" or Reg_datain(15 downto 12) = "1010" or Reg_datain(15 downto 12) = "1101") then
					reg(15 downto 0) <= se10; --imm
				elsif(Reg_datain(15 downto 12) = "0011" or Reg_datain(15 downto 12) = "0110" or Reg_datain(15 downto 12) = "0111" or Reg_datain(15 downto 12) = "1100" or Reg_datain(15 downto 12) = "1111") then
					reg(15 downto 0) <= se7; --imm
				end if;
				
			end if;
			
		else
			
			reg <= reg;
			
		end if;
		
		end if;
	
	end process;
	
	Reg_dataout <= reg;
	
end beh;