library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity rrex is 
port(
clock: in std_logic;
rst: in std_logic;
Bubble: in std_logic;
dis: in std_logic;
dis1: in std_logic;
regd1: in std_logic_vector(15 downto 0);
regd2: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(48 downto 0);
regaddr1: in std_logic_vector(2 downto 0);
regaddr2: in std_logic_vector(2 downto 0);
Reg_dataout: out std_logic_vector(75 downto 0)
);
end rrex;

architecture beh of rrex is 

signal reg: std_logic_vector(75 downto 0) := "1000000000000000000000000000000000000000000000000000000000000000000000000000";

begin

	process (clock, rst) --register between register read stage and execution stage
		
	begin
		
		if(rst = '1') then
			
			reg <= "1000000000000000000000000000000000000000000000000000000000000000000000000000";
			
		else
		
		if(falling_edge(clock)) then
			
			if(bubble = '0') then
				
				reg(73 downto 58) <= Reg_datain(47 downto 32); --pc
				reg(57 downto 54) <= Reg_datain(31 downto 28); --opcode
				reg(53 downto 51) <= Reg_datain(18 downto 16); --kcz
				reg(50 downto 35) <= regd1; --regd1
				reg(34 downto 19) <= regd2; --regd2
				reg(15 downto 0) <= Reg_datain(15 downto 0); --imm
				
				if(Reg_datain(31 downto 28) = "0001" or Reg_datain(31 downto 28) = "0010") then
					
					reg(18 downto 16) <= Reg_datain(21 downto 19); --regaddr
					reg(74) <= (not(regaddr1(2) xor Reg_datain(21)) and not(regaddr1(1) xor Reg_datain(20)) and not(regaddr1(0) xor Reg_datain(19))) or (not(regaddr2(2) xor Reg_datain(21)) and not(regaddr2(1) xor Reg_datain(20)) and not(regaddr2(0) xor Reg_datain(19))); --datadep
					
				elsif(Reg_datain(31 downto 28) = "0000") then
					
					reg(18 downto 16) <= Reg_datain(24 downto 22); --regaddr
					reg(74) <= (not(regaddr1(2) xor Reg_datain(24)) and not(regaddr1(1) xor Reg_datain(23)) and not(regaddr1(0) xor Reg_datain(22))) or (not(regaddr2(2) xor Reg_datain(24)) and not(regaddr2(1) xor Reg_datain(23)) and not(regaddr2(0) xor Reg_datain(22)));
					
				elsif(Reg_datain(31 downto 28) = "0011" or Reg_datain(31 downto 28) = "0100" or Reg_datain(31 downto 28) = "1101") then
					
					reg(18 downto 16) <= Reg_datain(27 downto 25); --regaddr
					reg(74) <= (not(regaddr1(2) xor Reg_datain(27)) and not(regaddr1(1) xor Reg_datain(26)) and not(regaddr1(0) xor Reg_datain(25))) or (not(regaddr2(2) xor Reg_datain(27)) and not(regaddr2(1) xor Reg_datain(26)) and not(regaddr2(0) xor Reg_datain(25)));
					
				end if;
				
			end if;
			
			reg(75) <= Reg_datain(48) or dis or dis1; --disable
			
		else
			
			reg <= reg;
			
		end if;
		
		end if;
	
	end process;
	
	Reg_dataout <= reg;

end beh;