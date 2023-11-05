library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity controller is
port(
dis: in std_logic;
regd1: in std_logic_vector(15 downto 0);
regd2: in std_logic_vector(15 downto 0);
regaddr1: in std_logic_vector(2 downto 0);
regaddr2: in std_logic_vector(2 downto 0);
regaddr: in std_logic_vector(2 downto 0);
carry: in std_logic;
zero: in std_logic;
opcode: in std_logic_vector(3 downto 0);
kcz: in std_logic_vector(2 downto 0);
datadep: in std_logic;
check: out std_logic;
dis1: out std_logic;
wr1: out std_logic;
wr2: out std_logic;
wr3: out std_logic;
memen: out std_logic;
bubble: out std_logic;
dis2: out std_logic;
select0: out std_logic_vector(3 downto 0)
);
end controller;

architecture beh of controller is

signal check1: std_logic := '0';
signal dis11: std_logic := '0';
signal wr11: std_logic := '0';
signal wr21: std_logic := '0';
signal wr31: std_logic := '0';
signal memen1: std_logic := '0';
signal bubble1: std_logic := '0';
signal select01: std_logic_vector(3 downto 0) := "0000";
signal datadep1: std_logic := '0';
signal dis21: std_logic := '0';

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
	
	function comp(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0))
	return std_logic_vector is
	
	variable check : std_logic := '0';
	variable com : std_logic_vector(1 downto 0) := "00";
	variable a1: integer := 0;
	variable b1: integer := 0;
	
	begin
		
		a1 := inte(A);
		b1 := inte(B);
		
		if(a1 > b1) then
			com := "10";
		elsif(a1 = b1) then
			com := "00";
		else
			com := "01";
		end if;
		
	return com;
	
	end comp;

begin
	
	process(dis, regd1, regd2, carry, zero, opcode, kcz, datadep, regaddr1, regaddr2, regaddr)
	
	begin
		
		check1 <= '0'; --update pc
		dis11 <= '0'; --disable privious 3 instrnction
		wr11 <= '0'; --write back in write back stage
		wr21 <= '0'; --write back in execution stage
		wr31 <= '0'; --write back in memory stage
		memen1 <= '0'; --enable write for data memory
		bubble1 <= '0'; --not update previous instruction
		select01 <= "0000"; --alu select lines
		datadep1 <= '0'; --data dependency bit
		dis21 <= '0'; --disable just privious instruntion
		
		if(dis = '0') then
			
			datadep1 <= datadep or (not(regaddr1(2) xor regaddr(2)) and not(regaddr1(1) xor regaddr(1)) and not(regaddr1(0) xor regaddr(0))) or (not(regaddr2(2) xor regaddr(2)) and not(regaddr2(1) xor regaddr(1)) and not(regaddr2(0) xor regaddr(0)));
			
			if(opcode = "0000") then --adi
				
				select01 <= "1011";
				wr11 <= not datadep1;
				wr21 <= datadep1;
				
			elsif(opcode = "0001") then --ada, adc, adz, awc, aca, acc, acz, acw
				
				wr11 <= not datadep;
				wr21 <= datadep;
				
				if(kcz = "000" or kcz = "100") then
					select01 <= "0000";
					
				elsif(kcz = "001" or kcz = "101") then
					select01 <= "0000";
					wr11 <= wr11 and zero;
					wr21 <= wr21 and zero;
					dis21 <= not zero;
					
				elsif(kcz = "010" or kcz = "110") then
					select01 <= "0000";
					wr11 <= wr11 and carry;
					wr21 <= wr21 and carry;
					dis21 <= not carry;
					
				elsif(kcz = "011" or kcz = "111") then
					select01 <= "0001";
					
				end if;
				
			elsif(opcode = "0010") then --ndu, ndc, ndz, ncu, ncc, ncz
				
				wr11 <= not datadep;
				wr21 <= datadep;
				
				if(kcz = "000" or kcz = "100") then
					select01 <= "0100";
					
				elsif(kcz = "001" or kcz = "101") then
					select01 <= "0100";
					wr11 <= wr11 and zero;
					wr21 <= wr21 and zero;
					dis21 <= not zero;
					
				elsif(kcz = "010" or kcz = "110") then
					select01 <= "0100";
					wr11 <= wr11 and carry;
					wr21 <= wr21 and carry;
					dis21 <= not carry;
					
				end if;
				
			elsif(opcode = "0011") then --lli
				
				select01 <= "1001";
				bubble1 <= datadep1;
				dis11 <= datadep1;
				wr11 <= not datadep1;
				wr21 <= datadep1;
				
			elsif(opcode = "0100") then --lw
				
				select01 <= "1000";
				bubble1 <= datadep1;
				dis11 <= datadep1;
				wr11 <= not datadep1;
				wr31 <= datadep1;
				
			elsif(opcode = "0101") then --sw
				
				select01 <= "1000";
				memen1 <= '1';
				
			elsif(opcode = "1000") then --beq
				
				select01 <= "0110";
				check1 <= not(comp(regd1, regd2)(1) or comp(regd1, regd2)(0));
				
			elsif(opcode = "1001") then --blt
				
				select01 <= "0110";
				check1 <= not comp(regd1, regd2)(1) and comp(regd1, regd2)(0);
				
			elsif(opcode = "1010") then --ble
				
				select01 <= "0110";
				check1 <= (not(comp(regd1, regd2)(1) or comp(regd1, regd2)(0))) or (not comp(regd1, regd2)(1) and comp(regd1, regd2)(0));
				
			elsif(opcode = "1100") then --jal
				
				select01 <= "0110";
				check1 <= '1';
				wr11 <= not datadep1;
				wr21 <= datadep1;
				
			elsif(opcode = "1101") then --jlr
				
				select01 <= "1000";
				check1 <= '1';
				wr11 <= not datadep1;
				wr21 <= datadep1;
				
			elsif(opcode = "1111") then --jri
				
				select01 <= "0111";
				check1 <= '1';
				
			end if;
			
		end if;
		
	end process;
	
	check <= check1;
	dis1 <= dis11;
	wr1 <= wr11;
	wr2 <= wr21;
	wr3 <= wr31;
	memen <= memen1;
	bubble <= bubble1;
	select0 <= select01;
	dis2 <= dis21;
	
end beh;