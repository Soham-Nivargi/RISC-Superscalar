library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;



entity ifid is 
port(
clock: in std_logic;
rst: in std_logic;
Bubble: in std_logic;
dis: in std_logic;
pc: in std_logic_vector(15 downto 0);
adder1out: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(15 downto 0);
Reg_dataout: out std_logic_vector(32 downto 0)
);
end ifid;

architecture beh of ifid is 

signal reg: std_logic_vector(32 downto 0) := "000000000000000010000000000000000";
signal reg1: std_logic_vector(32 downto 0) := "000000000000000010000000000000000";

begin
	
	process (clock, rst) --register between instruction fetch stage and instruntion decode stage
		
	begin
		
		if(rst = '1') then
			
			reg <= "000000000000000010000000000000000";
			
		else
			
		if(falling_edge(clock)) then
				
			if(bubble = '0') then
			
				reg(15 downto 0) <= Reg_datain; --inst
				if(Reg_datain = "0000000000000000") then
					reg(16) <= '1';
				else
					reg(16) <= dis; --disable
				end if;
				if(Reg_datain(15 downto 0) = "1100" or Reg_datain(15 downto 0) = "1101") then
					reg(32 downto 17) <= adder1out; --upgraded pc for jlr
				else
					reg(32 downto 17) <= pc; --pc
				end if;
				
			end if;	
			
		else
			
			reg <= reg;
			
		end if;
		
		end if;
	
	end process;
	
	Reg_dataout <= reg;
	
end beh;