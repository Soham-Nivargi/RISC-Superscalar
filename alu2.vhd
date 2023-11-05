library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity alu2 is
port(
dis0: in std_logic;
dis: in std_logic;
select0: in std_logic_vector(3 downto 0);
alu2a: in std_logic_vector(15 downto 0);
alu2b: in std_logic_vector(15 downto 0);
pc: in std_logic_vector(15 downto 0);
imm: in std_logic_vector(15 downto 0);
alu2c: out std_logic_vector(15 downto 0);
carry: out std_logic;
zero: out std_logic
);
end alu2;

architecture beh of alu2 is

signal alu2c1: std_logic_vector(15 downto 0) := (others => '0');
signal carry1: std_logic := '0';
signal zero1: std_logic := '0';
signal temp: std_logic_vector(15 downto 0) := (others => '0');
signal temp1: std_logic_vector(17 downto 0) := (others => '0');

	function add(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0); C: in std_logic)
	return std_logic_vector is
	
	variable add1 : std_logic_vector(17 downto 0):= (others=>'0');
	variable carry11 : std_logic_vector(16 downto 0):= (others=>'0');
	
	begin
		
		carry11(0) := C;
		
		L1: for i in 0 to 15 loop
		
		add1(i) := A(i) xor B(i) xor carry11(i);
		carry11(i+1) := (A(i) and B(i)) or (A(i) and carry11(i)) or (B(i) and carry11(i));
		
		end loop L1;
		
		add1(16) := carry11(16);
		
		if(add1(15 downto 0) = "0000000000000000") then
			add1(17) := '1';
		else
			add1(17) := '0';
		end if;
		
	return add1;
	
	end add;
	
	function nand1(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0))
	return std_logic_vector is
	
	variable nand11 : std_logic_vector(16 downto 0):= (others=>'0');
	
	begin
		
		L2: for i in 0 to 15 loop
		
		nand11(i) := A(i) nand B(i);
		
		end loop L2;
		
		if(nand11(15 downto 0) = "0000000000000000") then
			nand11(16) := '1';
		else
			nand11(16) := '0';
		end if;
		
	return nand11;
	
	end nand1;
	
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
	
	process(alu2a, alu2b, pc, imm, select0)
	
	begin
		
		if(dis = '0' and dis0 = '0') then
		
		if(select0 = "0000") then --ada, adc, adz, aca, acc, acz
			
			alu2c1 <= add(alu2a, alu2b, '0')(15 downto 0);
			carry1 <= add(alu2a, alu2b, '0')(16);
			zero1 <= add(alu2a, alu2b, '0')(17);
			
		elsif(select0 = "0001") then --awc, acw
			
			alu2c1 <= add(alu2a, alu2b, carry1)(15 downto 0);
			carry1 <= add(alu2a, alu2b, carry1)(16);
			zero1 <= add(alu2a, alu2b, carry1)(17);
			
		elsif(select0 = "0100") then --ndu, ndc, ndz, ncu, ncc, ncz
			
			alu2c1 <= nand1(alu2a, alu2b)(15 downto 0);
			zero1 <= nand1(alu2a, alu2b)(16);
			
		elsif(select0 = "0110") then --beq, blt, ble, jal
			
			alu2c1 <= add(pc, imm, '0')(15 downto 0);
			
		elsif(select0 = "0111") then --jri
			
			alu2c1 <= add(alu2a, imm, '0')(15 downto 0);
			
		elsif(select0 = "1000") then --lw, sw, jlr
			
			alu2c1 <= add(alu2b, imm, '0')(15 downto 0);
			
		elsif(select0 = "1001") then --lli
			
			alu2c1 <= imm;
			
		elsif(select0 = "1011") then --adi
			
			alu2c1 <= add(alu2a, imm, '0')(15 downto 0);
			carry1 <= add(alu2a, imm, '0')(16);
			zero1 <= add(alu2a, imm, '0')(17);
		
		end if;
		
		end if;
		
	end process;
	
	alu2c <= alu2c1;
	carry <= carry1;
	zero <= zero1;
	
end beh;