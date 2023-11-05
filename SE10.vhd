library ieee;
use ieee.std_logic_1164.all;

entity SE10 is 
port(
IR10: in std_logic_vector(5 downto 0);
SE10: out std_logic_vector(15 downto 0)
);
end SE10;

architecture beh of SE10 is

signal temp: std_logic_vector(15 downto 0) := (others => '0');
signal ones: std_logic_vector(9 downto 0) := (others => '1');

begin

	process(IR10) --sign extender for 6 bit immidiate

	begin
		
		temp <= "0000000000000000";	
		temp(5 downto 0) <= IR10;
		
		if IR10(5) = '1' then
			
			temp(15 downto 6) <= ones;
			
		end if;
		
	end process;
	
	SE10 <= temp;
	
end beh;