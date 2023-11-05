library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity converter is
port(
clock: in std_logic;
inst0: in std_logic_vector(15 downto 0);
check1: out std_logic;
inst1: out std_logic_vector(15 downto 0);
converterout: out std_logic_vector(15 downto 0)
);
end converter;

architecture beh of converter is

signal inst11: std_logic_vector(15 downto 0) := (others => '0');
signal counter: std_logic_vector(15 downto 0) := "0000000000000001";
signal check11: std_logic := '0';
signal imm: std_logic_vector(15 downto 0) := (others => '0');
signal addr: std_logic_vector(15 downto 0) := (others => '0');
signal temp: std_logic_vector(15 downto 0) := (others => '0');
signal delay: std_logic := '0';
signal instdelay: std_logic_vector(15 downto 0) := (others => '0');
	
	function add(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0))
	return std_logic_vector is
	
	variable add1 : std_logic_vector(15 downto 0):= (others=>'0');
	variable carry11 : std_logic_vector(16 downto 0):= (others=>'0');
	
	begin
		
		carry11(0) := '0';
		
		L1: for i in 0 to 15 loop
		
		add1(i) := A(i) xor B(i) xor carry11(i);
		carry11(i+1) := (A(i) and B(i)) or (A(i) and carry11(i)) or (B(i) and carry11(i));
		
		end loop L1;
		
	return add1;
	
	end add;
	
	function inte(A: in std_logic_vector(15 downto 0))
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
	
	function xor1(A: in std_logic_vector(15 downto 0))
	return std_logic_vector is
	
	variable compl : std_logic_vector(15 downto 0):= (others=>'0');
	
	begin
		
		L4: for i in 0 to 15 loop
			
			compl(i) := not A(i);
			
		end loop L4;
		
	return compl;
	
	end xor1;
	
begin
	
	process(clock) --converts lm and sm into suitable lw and sw
	
	begin
		
		if(rising_edge(clock)) then
		
			if((inst0(15 downto 12) = "0110" or inst0(15 downto 12) = "0111") and not (counter(3) = '1' and counter(2) = '0' and counter(1) = '0' and counter(0) = '1')) then
				
				check11 <= not(counter(3) and not counter(2) and not counter(1) and not counter(0)) or delay;
				imm(2 downto 0) <= xor1(counter)(2 downto 0);
				
				if(inst0(inte(imm)) = '1') then
					
					if((xor1(add(xor1(counter), "0000000000000001"))(2 downto 0) = inst0(11 downto 9)) and check11 = '1' and inst0(12) = '0') then --if my load instruction address is same as of lm instruction
						
						delay <= '1';
						instdelay(15 downto 13) <= "010";
						instdelay(12) <= inst0(12);
						instdelay(11 downto 9) <= inst0(11 downto 9);
						instdelay(8 downto 6) <= inst0(11 downto 9);
						instdelay(5 downto 0) <= addr(5 downto 0);
						addr <= add(addr, "0000000000000001");
						inst11 <= "0000000000000000";
						
					else
						
						inst11(15 downto 13) <= "010";
						inst11(12) <= inst0(12);
						inst11(11 downto 9) <= xor1(add(xor1(counter), "0000000000000001"))(2 downto 0);
						inst11(8 downto 6) <= inst0(11 downto 9);
						inst11(5 downto 0) <= addr(5 downto 0);
						addr <= add(addr, "0000000000000001");
						
					end if;
					
				else
					
					inst11 <= "0000000000000000";
					
				end if;
				
				counter <= add(counter, "0000000000000001");
				
			elsif(delay = '1') then --at the end loading data in register form which we were reading the address;
				
				inst11 <= instdelay;
				instdelay <= "0000000000000000";
				delay <= '0';
				check11 <= '0';
				
			else
				
				counter <= "0000000000000001";
				addr <= "0000000000000000";
				inst11 <= inst0;
				check11 <= '0';
				
			end if;
			
		else
			
			inst11 <= inst11;
			check11 <= check11;
			counter <= counter;
			imm <= imm;
			addr <= addr;
			
		end if;
		
	end process;
	
	inst1 <= inst11;
	check1 <= check11;
	converterout(15 downto 0) <= (others => '0');
	
end beh;