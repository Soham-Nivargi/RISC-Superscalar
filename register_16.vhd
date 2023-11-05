library std;

use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;



entity Register16 is 
	port (	Reg_datain: in std_logic_vector(15 downto 0); 
			clk, Reg_wrbar: in std_logic;
			Reg_dataout: out std_logic_vector(15 downto 0));
end entity;

architecture Form of Register16 is 

signal reg: std_logic_vector(15 downto 0) := (others => '0');

begin
Reg_dataout <= reg;
Reg_write:
process (Reg_wrbar,Reg_datain,clk)
	begin
	if(Reg_wrbar = '0') then
		if(falling_edge(clk)) then
			reg <= Reg_datain;
		end if;
	end if;
	end process;

end Form;