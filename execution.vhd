library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity complimentor is
port(
opcode: in std_logic_vector(3 downto 0);
k: in std_logic;
Din: in std_logic_vector(15 downto 0);
Dout: out std_logic_vector
);
end complimentor;


architecture beh of complimentor is
signal k1: std_logic := '0';
begin
k1 <= (k and not opcode(3) and not opcode(2) and (opcode(1) xor opcode(0))); --compliments bit according to operation
Dout(0) <= k1 xor Din(0);
Dout(1) <= k1 xor Din(1);
Dout(2) <= k1 xor Din(2);
Dout(3) <= k1 xor Din(3);
Dout(4) <= k1 xor Din(4);
Dout(5) <= k1 xor Din(5);
Dout(6) <= k1 xor Din(6);
Dout(7) <= k1 xor Din(7);
Dout(8) <= k1 xor Din(8);
Dout(9) <= k1 xor Din(9);
Dout(10) <= k1 xor Din(10);
Dout(11) <= k1 xor Din(11);
Dout(12) <= k1 xor Din(12);
Dout(13) <= k1 xor Din(13);
Dout(14) <= k1 xor Din(14);
Dout(15) <= k1 xor Din(15);
end beh;



library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity cz is
port(
clock: in std_logic;
c: in std_logic;
z: in std_logic;
rst: in std_logic;
carry: out std_logic;
zero: out std_logic
);
end cz;

architecture beh of cz is
signal carry1: std_logic := '0';
signal zero1: std_logic := '0';
begin	
	process(clock) --carry and zero flag registers		
	begin		
		if(rst = '1') then			
			carry1 <= '0';
			zero1 <= '0';			
		else			
			if(falling_edge(clock)) then				
				carry1 <= c;
				zero1 <= z;				
			else				
				carry1 <= carry1;
				zero1 <= zero1;			
			end if;			
		end if;		
	end process;	
	carry <= carry1;
	zero <= zero1;	
end beh;





library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity alu2 is
port(
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
	end process;
	alu2c <= alu2c1;
	carry <= carry1;
	zero <= zero1;
end beh;






library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;





entity controller is
port(
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
wr1: out std_logic;
wr2: out std_logic;
wr3: out std_logic;
memen: out std_logic;
select0: out std_logic_vector(3 downto 0)
);
end controller;

architecture beh of controller is

signal wr11: std_logic := '0';
signal wr21: std_logic := '0';
signal wr31: std_logic := '0';
signal memen1: std_logic := '0';
signal bubble1: std_logic := '0';
signal select01: std_logic_vector(3 downto 0) := "0000";
signal datadep1: std_logic := '0';

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
	process(regd1, regd2, carry, zero, opcode, kcz, datadep, regaddr1, regaddr2, regaddr)
	begin
		wr11 <= '0'; --write back in write back stage
		wr21 <= '0'; --write back in execution stage
		wr31 <= '0'; --write back in memory stage
		memen1 <= '0'; --enable write for data memory
		select01 <= "0000"; --alu select lines
		datadep1 <= '0'; --data dependency bit
			
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
				elsif(kcz = "010" or kcz = "110") then
					select01 <= "0000";
					wr11 <= wr11 and carry;
					wr21 <= wr21 and carry;		
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
				elsif(kcz = "010" or kcz = "110") then
					select01 <= "0100";
					wr11 <= wr11 and carry;
					wr21 <= wr21 and carry;				
				end if;	
			elsif(opcode = "0011") then --lli		
				select01 <= "1001";
				wr11 <= not datadep1;
				wr21 <= datadep1;		
			elsif(opcode = "0100") then --lw			
				select01 <= "1000";
				wr11 <= not datadep1;
				wr31 <= datadep1;		
			elsif(opcode = "0101") then --sw		
				select01 <= "1000";
				memen1 <= '1';		
			elsif(opcode = "1000") then --beq		
				select01 <= "0110";
			elsif(opcode = "1001") then --blt			
				select01 <= "0110";
			elsif(opcode = "1010") then --ble			
				select01 <= "0110";
			elsif(opcode = "1100") then --jal			
				select01 <= "0110";
				wr11 <= not datadep1;
				wr21 <= datadep1;		
			elsif(opcode = "1101") then --jlr		
				select01 <= "1000";
				wr11 <= not datadep1;
				wr21 <= datadep1;			
			elsif(opcode = "1111") then --jri			
				select01 <= "0111";				
			end if;
	end process;
	wr1 <= wr11;
	wr2 <= wr21;
	wr3 <= wr31;
	memen <= memen1;
	select0 <= select01;
end beh;




library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity execution is 
port(
clock: in std_logic;
rst: in std_logic;
regd1: in std_logic_vector(15 downto 0);
regd2: in std_logic_vector(15 downto 0);
regd3: in std_logic_vector(15 downto 0);
regd4: in std_logic_vector(15 downto 0);
regd5: in std_logic_vector(15 downto 0);
regd6: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(143 downto 0);
Reg_dataout: out std_logic_vector(221 downto 0);
alu2c: out std_logic_vector(15 downto 0);
c: out std_logic;
z: out std_logic;
write1: out std_logic;
write2: out std_logic;
write3: out std_logic
);
end execution;



--input reg is |16-bit pc of first instr|16-bit first instr|16-bit sign extended immediate of first instr
             --|16-bit pc of second instr|16-bit second instr|16-bit sign extended immediate of second instr|
--output reg is |16-bit pc1|4-bit opcode1|3-bit kcz 1|16-bit regd1|16-bit regd2|3-bit output regaddr1
              --|16-bit pc2|4-bit opcode2|3-bit kcz 2|16-bit regd3|16-bit regd4|3-bit output regaddr2|

				  
				  
architecture beh of execution is 

component alu2 is
port(
select0: in std_logic_vector(3 downto 0);
alu2a: in std_logic_vector(15 downto 0);
alu2b: in std_logic_vector(15 downto 0);
pc: in std_logic_vector(15 downto 0);
imm: in std_logic_vector(15 downto 0);
alu2c: out std_logic_vector(15 downto 0);
carry: out std_logic;
zero: out std_logic
);
end component;

component controller is
port(
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
wr1: out std_logic;
wr2: out std_logic;
wr3: out std_logic;
memen: out std_logic;
select0: out std_logic_vector(3 downto 0)
);
end component;

component cz is
port(
clock: in std_logic;
c: in std_logic;
z: in std_logic;
rst: in std_logic;
carry: out std_logic;
zero: out std_logic
);
end component;

component complimentor is
port(
opcode: in std_logic_vector(3 downto 0);
k: in std_logic;
Din: in std_logic_vector(15 downto 0);
Dout: out std_logic_vector
);
end component;


signal reg: std_logic_vector(221 downto 0) := (others=>'0');
signal regreset: std_logic_vector(221 downto 0) := (others=>'0');
signal select01: std_logic_vector(3 downto 0) := (others => '0');
signal select02: std_logic_vector(3 downto 0) := (others => '0');
signal select03: std_logic_vector(3 downto 0) := (others => '0');
signal alu2b0: std_logic_vector(15 downto 0) := (others => '0');
signal alu2b1: std_logic_vector(15 downto 0) := (others => '0');
signal alu2b2: std_logic_vector(15 downto 0) := (others => '0');
signal alu2c2: std_logic_vector(15 downto 0) := (others => '0');
signal alu2c3: std_logic_vector(15 downto 0) := (others => '0');
signal carry110: std_logic := '0';
signal carry111: std_logic := '0';
signal carry112: std_logic := '0';
signal zero110: std_logic := '0';
signal zero111: std_logic := '0';
signal zero112: std_logic := '0';
signal carry0: std_logic := '0';
signal carry1: std_logic := '0';
signal carry2: std_logic := '0';
signal zero0: std_logic := '0';
signal zero1: std_logic := '0';
signal zero2: std_logic := '0';
signal datadep0: std_logic := '0';
signal memen1: std_logic := '0';
signal memen2: std_logic := '0';
signal memen3: std_logic := '0';
signal wr11: std_logic := '0';
signal wr21: std_logic := '0';
signal wr31: std_logic := '0';
signal wr12: std_logic := '0';
signal wr22: std_logic := '0';
signal wr32: std_logic := '0';
signal wr13: std_logic := '0';
signal wr23: std_logic := '0';
signal wr33: std_logic := '0';

begin
	alu2p: alu2 port map (select0 => select01, alu2a => reg(50 downto 35), alu2b => alu2b0, pc => reg(73 downto 58), imm => reg(15 downto 0), alu2c => alu2c, carry => carry110, zero => zero110);
	alu2q: alu2 port map (select0 => select02, alu2a => reg(124 downto 109), alu2b => alu2b1, pc => reg(147 downto 132), imm => reg(89 downto 74), alu2c => alu2c2, carry => carry111, zero => zero111);
	alu2r: alu2 port map (select0 => select03, alu2a => reg(198 downto 183), alu2b => alu2b1, pc => reg(221 downto 206), imm => reg(163 downto 148), alu2c => alu2c3, carry => carry112, zero => zero112);
	controller1: controller port map (regd1 => reg(50 downto 35), regd2 => reg(34 downto 19), regaddr1 => Reg_datain(27 downto 25), regaddr2 => Reg_datain(24 downto 22), regaddr => reg(18 downto 16), carry => carry0, zero => zero0, opcode => reg(57 downto 54), kcz => reg(53 downto 51), datadep => datadep0, wr1 => wr11, wr2 => wr21, wr3 => wr31, memen => memen1, select0 => select01);
	controller2: controller port map (regd1 => reg(124 downto 109), regd2 => reg(108 downto 93), regaddr1 => Reg_datain(75 downto 73), regaddr2 => Reg_datain(72 downto 70), regaddr => reg(92 downto 90), carry => carry1, zero => zero1, opcode => reg(131 downto 128), kcz => reg(127 downto 125), datadep => datadep0, wr1 => wr12, wr2 => wr22, wr3 => wr32, memen => memen2, select0 => select02);
	controller3: controller port map (regd1 => reg(198 downto 183), regd2 => reg(182 downto 167), regaddr1 => Reg_datain(123 downto 121), regaddr2 => Reg_datain(120 downto 118), regaddr => reg(166 downto 164), carry => carry2, zero => zero2, opcode => reg(205 downto 202), kcz => reg(201 downto 199), datadep => datadep0, wr1 => wr13, wr2 => wr23, wr3 => wr33, memen => memen3, select0 => select03);	
	cz1: cz port map (clock => clock, c => carry110, z => zero110, rst => rst, carry => carry0, zero => zero0);
	cz2: cz port map (clock => clock, c => carry111, z => zero111, rst => rst, carry => carry1, zero => zero1);
	cz3: cz port map (clock => clock, c => carry112, z => zero112, rst => rst, carry => carry2, zero => zero2);
	complimentor1: complimentor port map (opcode => reg(57 downto 54), k => reg(53), Din => reg(34 downto 19), Dout => alu2b0);
	complimentor2: complimentor port map (opcode => reg(131 downto 128), k => reg(127), Din => reg(108 downto 93), Dout => alu2b1);
	complimentor3: complimentor port map (opcode => reg(205 downto 202), k => reg(201), Din => reg(182 downto 167), Dout => alu2b2);
	process (clock, rst) --register between register read stage and execution stage
	
	--input registers have been read and data has been included (reg d1 and regd2), output reg address is being
	--determined using opcode and included in this stage for execution, along with kcz values and immediates
	begin	
		if(rst = '1') then		
			reg <= regreset;	
		else	
			if(falling_edge(clock)) then	
				reg(221 downto 206) <= Reg_datain(143 downto 128); --pc1
				reg(205 downto 202) <= Reg_datain(127 downto 124); --opcode1
				reg(201 downto 199) <= Reg_datain(114 downto 112); --kcz1
				reg(198 downto 183) <= regd1; --regd1
				reg(182 downto 167) <= regd2; --regd2
				reg(163 downto 148) <= Reg_datain(111 downto 96); --imm1
				
				reg(147 downto 132) <= Reg_datain(95 downto 80); --pc2
				reg(131 downto 128) <= Reg_datain(79 downto 76); --opcode2
				reg(127 downto 125) <= Reg_datain(66 downto 64); --kcz2
				reg(124 downto 109) <= regd3; --regd3
				reg(108 downto 93) <= regd4; --regd4
				reg(89 downto 74) <= Reg_datain(63 downto 48); --imm3
				
				reg(73 downto 58) <= Reg_datain(47 downto 32); --pc3
				reg(57 downto 54) <= Reg_datain(31 downto 28); --opcode3
				reg(53 downto 51) <= Reg_datain(18 downto 16); --kcz3
				reg(50 downto 35) <= regd5; --regd5
				reg(34 downto 19) <= regd6; --regd6
				reg(15 downto 0) <= Reg_datain(15 downto 0); --imm3
				
				if(Reg_datain(127 downto 124) = "0001" or Reg_datain(127 downto 124) = "0010") then
					reg(166 downto 164) <= Reg_datain(117 downto 115); --regaddr2	regC address
				elsif(Reg_datain(127 downto 124) = "0000") then
					reg(166 downto 164) <= Reg_datain(120 downto 118); --regaddr2	regB address			
				elsif(Reg_datain(127 downto 124) = "0011" or Reg_datain(127 downto 124) = "0100" or Reg_datain(127 downto 124) = "1101") then
					reg(166 downto 164) <= Reg_datain(123 downto 121); --regaddr2	regA address
				end if;
				
				if(Reg_datain(79 downto 76) = "0001" or Reg_datain(79 downto 76) = "0010") then
					reg(92 downto 90) <= Reg_datain(69 downto 67); --regaddr2	regC address
				elsif(Reg_datain(79 downto 76) = "0000") then
					reg(92 downto 90) <= Reg_datain(72 downto 70); --regaddr2	regB address			
				elsif(Reg_datain(79 downto 76) = "0011" or Reg_datain(79 downto 76) = "0100" or Reg_datain(79 downto 76) = "1101") then
					reg(92 downto 90) <= Reg_datain(75 downto 73); --regaddr2	regA address
				end if;
				
				if(Reg_datain(31 downto 28) = "0001" or Reg_datain(31 downto 28) = "0010") then					
					reg(18 downto 16) <= Reg_datain(21 downto 19); --regaddr3	regC address	
				elsif(Reg_datain(31 downto 28) = "0000") then					
					reg(18 downto 16) <= Reg_datain(24 downto 22); --regaddr3	regB address				
				elsif(Reg_datain(31 downto 28) = "0011" or Reg_datain(31 downto 28) = "0100" or Reg_datain(31 downto 28) = "1101") then		
					reg(18 downto 16) <= Reg_datain(27 downto 25); --regaddr3	regA address
				end if;				
			else	
				reg <= reg;
			end if;
		end if;
	end process;
	Reg_dataout <= reg;
	c <= carry0 or carry1 or carry2;
	z <= zero0 or zero1 or zero2;
	write1 <= wr11 or wr12 or wr13;
	write2 <= wr21 or wr22 or wr23;
	write3 <= wr31 or wr32 or wr33;
end beh;