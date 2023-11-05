library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity exmem is 
port(
clock: in std_logic;
rst: in std_logic;
dis: in std_logic;
memen: in std_logic;
wrwb, wrmem: in std_logic;
alu2out: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(75 downto 0);
Reg_dataout: out std_logic_vector(42 downto 0)
);
end exmem;

architecture beh of exmem is 

signal reg: std_logic_vector(42 downto 0) := "1000000000000000000000000000000000000000000";

begin
	
	process (clock, rst) --register between execution stage and memory read stage
		
	begin
			
		if(rst = '1') then
			
			reg <= "1000000000000000000000000000000000000000000";
			
		else
		
		if(falling_edge(clock)) then
			
			reg(41) <= wrwb; --wrwb
			reg(40) <= wrmem; --wrmem
			reg(39) <= memen; --memen
			reg(38 downto 35) <= Reg_datain(57 downto 54); --opcode
			
			if(Reg_datain(57 downto 54) = "1101") then
				reg(34 downto 19) <= Reg_datain(73 downto 58);
			else
				reg(34 downto 19) <= alu2out; --data
			end if;
			
			reg(18 downto 16) <= Reg_datain(18 downto 16); --regaddr
			reg(15 downto 0) <= Reg_datain(50 downto 35); --regdata
			
		else
			
			reg <= reg;
			
		end if;
		
		end if;
	
	end process;
	
	Reg_dataout <= reg;

end beh;