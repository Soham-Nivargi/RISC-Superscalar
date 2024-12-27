library ieee;
use ieee.std_logic_1164.all;

entity Sign_Ext7 is 
port(
IR7: in std_logic_vector(63 downto 0);
SE7: out std_logic_vector(31 downto 0)
);
end Sign_Ext7;

architecture beh of Sign_Ext7 is
signal temp: std_logic_vector(31 downto 0) := (others => '0');
signal ones: std_logic_vector(6 downto 0) := (others => '1');
begin
	process(IR7) --sign extender for 9 bit immidiate
	begin		
		temp <= "00000000000000000000000000000000";
		temp(24 downto 16) <= IR7(40 downto 32);	
		temp(8 downto 0) <= IR7(8 downto 0);	
		if IR7(8) = '1' then			
			temp(15 downto 9) <= ones;			
		end if;		
		if IR7(41) = '1' then			
			temp(31 downto 25) <= ones;			
		end if;
	end process;	
	SE7 <= temp;	
end beh;






library ieee;
use ieee.std_logic_1164.all;

entity Sign_Ext10 is 
port(
IR10: in std_logic_vector(63 downto 0);
SE10: out std_logic_vector(31 downto 0)
);
end Sign_Ext10;

architecture beh of Sign_Ext10 is
signal temp: std_logic_vector(31 downto 0) := (others => '0');
signal ones: std_logic_vector(9 downto 0) := (others => '1');
begin
	process(IR10) --sign extender for 6 bit immidiate
	begin		
		temp <= "00000000000000000000000000000000";	
		temp(5 downto 0) <= IR10(5 downto 0);
		temp(21 downto 16) <= IR10(37 downto 32);		
		if IR10(5) = '1' then			
			temp(15 downto 6) <= ones;			
		end if;
		if IR10(37) = '1' then			
			temp(31 downto 22) <= ones;			
		end if;		
	end process;	
	SE10 <= temp;	
end beh;





library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity instr_decode is 
port(
clock: in std_logic;
rst: in std_logic;
Reg_datain: in std_logic_vector(63 downto 0);
Reg_dataout: out std_logic_vector(95 downto 0)
);
end instr_decode;

--input reg is |16-bit pc of first instr|16-bit first instr|16-bit pc of second instr|16-bit second instr|
--output reg is |16-bit pc of first instr|16-bit first instr|16-bit sign extended immediate of first instr
              --|16-bit pc of second instr|16-bit second instr|16-bit sign extended immediate of second instr|



architecture beh of instr_decode is 

component Sign_Ext10 is 
port(
IR10: in std_logic_vector(63 downto 0);
SE10: out std_logic_vector(31 downto 0)
);
end component;

component Sign_Ext7 is 
port(
IR7: in std_logic_vector(63 downto 0);
SE7: out std_logic_vector(31 downto 0)
);
end component;

signal reg: std_logic_vector(95 downto 0) := (others => '0');
signal regreset: std_logic_vector(95 downto 0) := (others => '0');
signal se70: std_logic_vector(31 downto 0) := (others => '0');
signal se100: std_logic_vector(31 downto 0) := (others => '0');
begin
se71: Sign_Ext7 port map (IR7 => Reg_datain, SE7 => se70);
se101: Sign_Ext10 port map (IR10 => Reg_datain, SE10 => se100);


	process (clock, rst) --register between instruction decode stage and register read stage	
		begin		
		if(rst = '1') then		
			reg <= regreset;	
		else
			if(falling_edge(clock)) then		
				reg(95 downto 80) <= Reg_datain(63 downto 48); --pc1
				reg(79 downto 64) <= Reg_datain(47 downto 32); --inst1
				reg(47 downto 32) <= Reg_datain(31 downto 16); --pc2
				reg(31 downto 16) <= Reg_datain(15 downto 0); --inst2	
				
				--decoding instr by looking for immediates and sign extending them
				
				if(Reg_datain(47 downto 44) = "0000" or Reg_datain(47 downto 44) = "0100" or Reg_datain(47 downto 44) = "0101" or Reg_datain(47 downto 44) = "1000" or Reg_datain(47 downto 44) = "1001" or Reg_datain(47 downto 44) = "1010" or Reg_datain(47 downto 44) = "1101") then
					reg(63 downto 48) <= se100(31 downto 16); --imm
				elsif(Reg_datain(47 downto 44) = "0011" or Reg_datain(47 downto 44) = "0110" or Reg_datain(47 downto 44) = "0111" or Reg_datain(47 downto 44) = "1100" or Reg_datain(47 downto 44) = "1111") then
					reg(63 downto 48) <= se70(31 downto 16); --imm
				end if;
				
				if(Reg_datain(15 downto 12) = "0000" or Reg_datain(15 downto 12) = "0100" or Reg_datain(15 downto 12) = "0101" or Reg_datain(15 downto 12) = "1000" or Reg_datain(15 downto 12) = "1001" or Reg_datain(15 downto 12) = "1010" or Reg_datain(15 downto 12) = "1101") then
					reg(15 downto 0) <= se100(15 downto 0); --imm
				elsif(Reg_datain(15 downto 12) = "0011" or Reg_datain(15 downto 12) = "0110" or Reg_datain(15 downto 12) = "0111" or Reg_datain(15 downto 12) = "1100" or Reg_datain(15 downto 12) = "1111") then
					reg(15 downto 0) <= se70(15 downto 0); --imm
				end if;
					
			else	
				reg <= reg;
			end if;
		end if;
	end process;
	Reg_dataout <= reg;
end beh;