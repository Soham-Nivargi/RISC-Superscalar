library ieee;
use ieee.std_logic_1164.all;

entity SE7 is 
port(
IR7: in std_logic_vector(8 downto 0);
SE7: out std_logic_vector(15 downto 0)
);
end SE7;

architecture beh of SE7 is

signal temp: std_logic_vector(15 downto 0) := (others => '0');
signal ones: std_logic_vector(6 downto 0) := (others => '1');

begin

	process(IR7) --sign extender for 9 bit immidiate

	begin
		
		temp <= "0000000000000000";
		temp(8 downto 0) <= IR7;
		
		if IR7(8) = '1' then
			
			temp(15 downto 9) <= ones;
			
		end if;
		
	end process;
	
	SE7 <= temp;
	
end beh;