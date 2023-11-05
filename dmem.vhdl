library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity dmem is
port(
clock: in std_logic;
rst: in std_logic;
memen: in std_logic;
addr: in std_logic_vector(15 downto 0);
Din: in std_logic_vector(15 downto 0);
Dout: out std_logic_vector(15 downto 0)
--dmemcheck: out std_logic_vector(15 downto 0)
);
end dmem;

architecture beh of dmem is

type mem is array(0 to 2**8 - 1) of std_logic_vector(15 downto 0);
signal data: mem;--:= (
--1 => "0000000000000000",
--2 => "0000000000000000",
--others=>"0000000000000000"
--);
signal addr1: std_logic_vector(15 downto 0) := (others => '0');
	
	function inte(A: in std_logic_vector(15 downto 0) )
	return integer is
	
	variable a1: integer := 0;
	
	begin
		
		L1: for i in 0 to 15 loop
			
			if(A(i) = '1') then
				a1 := a1 + (2**i);
			end if;
			
		end loop L1;
		
	return a1;
	
	end inte;

begin
	
	addr1(7 downto 0) <= addr(7 downto 0);
	
	process(clock, rst)
	
	begin
		
		if(rising_edge(clock)) then
			
			if(memen = '1') then
				
				data(inte(addr1)) <= Din; --takes data input
				
			end if;
			
			Dout <= data(inte(addr1)); --dataout
			--dmemcheck <= data(1); --reads dmem
			
		end if;
		
	end process;
	
end beh;