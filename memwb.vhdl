library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity memwb is 
port(
clock: in std_logic;
rst: in std_logic;
dmemdata: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(42 downto 0);
Reg_dataout: out std_logic_vector(19 downto 0)
);
end memwb;

architecture beh of memwb is 

signal reg: std_logic_vector(19 downto 0) := "10000000000000000000";

begin
	
	process (clock, rst) --register between memory read stage and write back stage
	
	begin
		
		if(rst = '1') then
			
			reg <= "10000000000000000000";
			
		else
		
		if(falling_edge(clock)) then
			
			reg(19) <= Reg_datain(41); --wrwb
			if(Reg_datain(38 downto 35) = "0100") then
				reg(18 downto 3) <= dmemdata;
			else
				reg(18 downto 3) <= Reg_datain(34 downto 19); --data
			end if;
			reg(2 downto 0) <= Reg_datain(18 downto 16); --addr
		
		else
			
			reg <= reg;
				
		end if;
		
		end if;
		
	end process;
	
	Reg_dataout <= reg;
	
end beh;