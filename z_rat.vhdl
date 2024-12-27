library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;	 
--use ieee.std_logic_unsigned.all;

entity z_rat is
    port(
        clk: in std_logic;
        rst: in std_logic;
		wr_en: in std_logic;
		wr_rob: in std_logic_vector(1 downto 0);
        en1: in std_logic;
        en2: in std_logic;
		read1, read2:in std_logic_vector(1 downto 0);

        cin1: out std_logic_vector(1 downto 0);
        busy1: out std_logic;
        cin2: out std_logic_vector(1 downto 0);
        busy2: out std_logic;
        cout1: out std_logic_vector(1 downto 0);
        cout2: out std_logic_vector(1 downto 0);
        stall1: out std_logic;
        stall2: out std_logic;
		b1,b2: out std_logic
    );
end entity z_rat;

architecture design of z_rat is
    type registers is array(0 to 3) of std_logic;
    signal busy: registers:= (
    '0', '0', '0', '0'
    );
    signal arf: integer := 0;

    type aliasing is array(0 to 3) of std_logic_vector(1 downto 0);
    signal rat: aliasing:= (
    "00",
    "01", 
    "10",
    "11"
    );  
begin
	
    process(clk, rst, wr_en, wr_rob, en1, en2)
    variable set1: integer := 0;
	 variable set2: integer := 0;
	 variable set3: integer := 0;
    begin
        if(rising_edge(clk)) then
			  if(wr_en = '1') then
					busy(to_integer(unsigned(wr_rob))) <= '0';
			  end if;
			  
			  if (en1 = '1') then
					cin1 <= rat(arf);
					busy1 <= busy(arf);
					if(busy(arf) = '1') then
						 for i in 0 to 3 loop
							  if(i /= arf and busy(i) = '0') then
									arf <= i;
									cout1 <= rat(i);
									busy(i) <= '1';
									set1 := 1;
									exit;
							  end if;
						 end loop;
						 if(set1 = 0)then
							  stall1 <= '1';
						 else 
							  stall1 <= '0';
						 end if;
					else
						 busy(arf) <= '1';
						 cout1 <= rat(arf);
						 set1 := 1;
					end if;
					if(en2 = '1') then
						 cin2 <= rat(arf);
						 busy2 <= '1';
						 for i in 0 to 3 loop
							  if(i /= arf and busy(i) = '0')then
									arf <= i;
									cout1 <= rat(i);
									busy(i) <= '1';
									set2 := 1;
									exit;
							  end if;
						 end loop;
						 if(set2 = 0)then
							  stall2 <= '1';
						 else 
							  stall2 <= '0';
						 end if;
					end if;
			  else
					cin2 <= rat(arf);
					busy2 <= busy(arf);
					if(busy(arf) = '1') then
						 for i in 0 to 3 loop
							  if(i /= arf and busy(i) = '0')then
									arf <= i;
									cout2 <= rat(i);
									busy(i) <= '1';
									set3 := 1;
									exit;
							  end if;
						 end loop;
						 if(set3 = 0)then
							  stall2 <= '1';
						 else 
							  stall2 <= '0';
						 end if;
					else
						 busy(arf) <= '1';
						 cout2 <= rat(arf);
						 set3 := 1;
					end if;
			  end if;
		  end if;
    end process;
	 
	 process(read1, read2)
	 begin
		b1 <= busy(to_integer(unsigned(read1)));
		b2 <= busy(to_integer(unsigned(read2)));
	 end process;
	

end design;