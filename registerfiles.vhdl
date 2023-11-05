library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity registerfiles is
port(
rst: in std_logic;
wr1, wr2, wr3: in std_logic;
a1, a2, a31, a32, a33: in std_logic_vector(2 downto 0);
d31, d32, d33, pc: in std_logic_vector(15 downto 0); 
d1, d2: out std_logic_vector(15 downto 0);
regdataout: out std_logic_vector(15 downto 0)
);
end registerfiles;

architecture beh of registerfiles is 

type regarray is array(7 downto 0) of std_logic_vector(15 downto 0);   
signal RegisterF: regarray:= (
0 => "0000000000000000",
1 => "0000000000000000",
2 => "0000000000000000",
3 => "0000000000000000",
4 => "0000000000000000",
5 => "0000000000000000",
6 => "0000000000000000",
7 => "0000000000000000"
);
signal regd1: std_logic_vector(15 downto 0) := "0000000000000000";
signal regd2: std_logic_vector(15 downto 0) := "0000000000000000";
signal check: std_logic_vector(15 downto 0) := "0000000000000000";

	function inte(A: in std_logic_vector(2 downto 0))
	return integer is
	
	variable a1: integer := 0;
	
	begin
		
		L1: for i in 0 to 2 loop
			
			if(A(i) = '1') then
				a1 := a1 + (2**i);
			end if;
			
		end loop L1;
		
	return a1;
	
	end inte;

begin
	
	process (wr1, wr2, wr3, a1, a2, a31, a32, a33, d31, d32, d33, pc, rst) --8 register files
	
	begin
		
		if(rst = '1') then
			
			RegisterF <= (others => "0000000000000000");
			
		else
		
		RegisterF(0) <= pc;
		
		if(wr1 = '1' and not(a31 = "000")) then	
			RegisterF(inte(a31)) <= d31; --wb addr
		end if;
		
		if(wr3 = '1' and not(a33 = "000")) then
			RegisterF(inte(a33)) <= d33; --mem addr
		end if;
		
		if(wr2 = '1' and not(a32 = "000")) then
			RegisterF(inte(a32)) <= d32; --alu addr
		end if;
		
		end if;
		
	end process;
	
	d1 <= RegisterF(inte(a1));
	d2 <= RegisterF(inte(a2));
	regdataout <= RegisterF(1); --reads registerfile
	
end beh;