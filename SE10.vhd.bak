library ieee;
use ieee.std_logic_1164.all;

entity SE10 is 
	port(
		state: in std_logic_vector(4 downto 0);
		IR: in std_logic_vector(5 downto 0);
		B: out std_logic_vector(15 downto 0)
	);
end SE10;

architecture se of SE10 is

constant s6  : std_logic_vector(4 downto 0):= "00110";
constant s15 : std_logic_vector(4 downto 0):= "01111";
constant s21 : std_logic_vector(4 downto 0):= "10101";

begin 
process(IR, state)
variable temp: std_logic_vector(15 downto 0):= (others => '0');
variable ones: std_logic_vector(9 downto 0):= (others => '1');
begin
	temp := "0000000000000000";
    case state is
		when s6|s15|s21 =>
	
		temp(5 downto 0) := IR;
		if IR(5) = '1' then
			temp(15 downto 6) := ones;
		end if;
		B <= temp;
		
	when others =>
		null;
	end case;
end process;
end architecture;
