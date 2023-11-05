library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity adder1 is
port (
pc: in std_logic_vector(15 downto 0);
adder1out: out std_logic_vector(15 downto 0)
);
end adder1;

architecture beh of adder1 is

signal disp : std_logic_vector(15 downto 0) := "0000000000000001";
	
	function add(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0))
	return std_logic_vector is
	
	variable add1 : std_logic_vector(15 downto 0):= (others=>'0');
	variable carry1 : std_logic_vector(16 downto 0):= (others=>'0');
	
	begin
		
		carry1(0) := '0';
		
		L1: for i in 0 to 15 loop
		
		add1(i) := A(i) xor B(i) xor carry1(i);
		carry1(i+1) := (A(i) and B(i)) or (A(i) and carry1(i)) or (B(i) and carry1(i));
		
		end loop L1;
		
	return add1;
		
	end add;

begin
	
	process(pc) --upgrades pc
	
	begin
		
		adder1out <= add(pc, disp);
		
	end process;
	
end beh;