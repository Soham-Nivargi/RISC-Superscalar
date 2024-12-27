library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;	 
--use ieee.std_logic_unsigned.all;

entity rat is
    port(
        clk: in std_logic;
        rst: in std_logic;
        read_addr1: in std_logic_vector(2 downto 0);
        read_addr2: in std_logic_vector(2 downto 0);
        read_addr3: in std_logic_vector(2 downto 0);
        read_addr4: in std_logic_vector(2 downto 0);
        wr_addr1: in std_logic_vector(2 downto 0);
        wr_addr2: in std_logic_vector(2 downto 0);
        wr_rob_addr: in std_logic_vector(3 downto 0);
        wr_en: in std_logic;
        read1, read2, read3, read4: in std_logic_vector(3 downto 0);

        rout1: out std_logic_vector(3 downto 0);
        busy1: out std_logic;
        busy2: out std_logic;
        busy3: out std_logic;
        busy4: out std_logic;
        rout2: out std_logic_vector(3 downto 0);
        rout3: out std_logic_vector(3 downto 0);
        rout4: out std_logic_vector(3 downto 0);
        wout1: out std_logic_vector(3 downto 0);
        wout2: out std_logic_vector(3 downto 0);
        stall1: out std_logic;
        stall2: out std_logic;
        b1,b2,b3,b4: out std_logic
    );
end entity rat;

architecture design of rat is
    type registers is array(0 to 15) of std_logic;
    signal busy: registers:= (
    '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
    );
    signal arf: registers:= (
    '1','1', '1', '1', '1', '1', '1', '1', '0', '0', '0', '0', '0', '0', '0', '0'
    );

    type aliasing is array(0 to 7) of std_logic_vector(3 downto 0);
    signal rat: aliasing:= (
    "0000",
    "0001", 
    "0010",
    "0011", 
    "0100",
    "0101", 
    "0110",
    "0111"  
    );
	 
begin
    process(read_addr1, read_addr2, read_addr3, read_addr4)
    --variable w1, w2, w3, w4: std_logic_vector(3 downto 0);
    begin
        rout1 <= rat(to_integer(unsigned(read_addr1)));
        busy1 <= busy(to_integer(unsigned(read_addr1)));

        rout2 <= rat(to_integer(unsigned(read_addr2)));
        busy2 <= busy(to_integer(unsigned(read_addr2)));

        rout3 <= rat(to_integer(unsigned(read_addr3)));
        busy3 <= busy(to_integer(unsigned(read_addr3)));

        rout4 <= rat(to_integer(unsigned(read_addr4)));
        busy4 <= busy(to_integer(unsigned(read_addr4)));

        b1 <= busy(to_integer(unsigned(read1)));
        b2 <= busy(to_integer(unsigned(read2)));
        b3 <= busy(to_integer(unsigned(read3)));
        b4 <= busy(to_integer(unsigned(read4)));

    end process;

    process(clk, wr_addr1, wr_addr2, wr_rob_addr, wr_en)
	 variable set1: integer:= 0;
	 variable set2: integer:= 0;
	 variable i_vector : std_logic_vector(3 downto 0);
    begin
        if(rising_edge(clk)) then
            if(wr_en = '1') then
                busy(to_integer(unsigned(wr_rob_addr))) <= '0';
            end if;

            if(busy(to_integer(unsigned(rat(to_integer(unsigned(wr_addr1)))))) = '1') then
                for i in 0 to 15 loop--look up syntax
						  --i_vector := std_logic_vector(i);
                    if(arf(i) = '0' and busy(i) = '0') then
                        arf(to_integer(unsigned(rat(to_integer(unsigned(wr_addr1)))))) <= '0';
                        wout1 <= std_logic_vector(to_unsigned(i, wout1'length));
                        rat(to_integer(unsigned(wr_addr1))) <= std_logic_vector(to_unsigned(i, wout1'length));
                        arf(i) <= '1';
                        busy(i) <= '1';
                        set1 := 1;
                        exit;
                    end if;
                end loop;
                if(set1 = 0) then
                    stall1 <= '1';
                else
                    stall1 <= '0';
                end if;
            else
                wout1 <= rat(to_integer(unsigned(wr_addr1)));
                busy(to_integer(unsigned(rat(to_integer(unsigned(wr_addr1)))))) <= '1';
            end if;

            if(busy(to_integer(unsigned(rat(to_integer(unsigned(wr_addr2)))))) = '1') then
                for i in 0 to 15 loop--look up syntax
                    if(arf(i) = '0' and busy(i) = '0') then
                        arf(to_integer(unsigned(rat(to_integer(unsigned(wr_addr2)))))) <= '0';
                        wout2 <= std_logic_vector(to_unsigned(i, wout2'length));
                        rat(to_integer(unsigned(wr_addr2))) <= std_logic_vector(to_unsigned(i, wout2'length));
                        arf(i) <= '1';
                        busy(i) <= '1';
                        set2 := 1;
                        exit;
                    end if;
					 end loop;
					 
                if(set2 = 0) then
                    stall2 <= '1';
                else
                    stall2 <= '0';
                end if;
            else
                wout2 <= rat(to_integer(unsigned(wr_addr1)));
                busy(to_integer(unsigned(rat(to_integer(unsigned(wr_addr2)))))) <= '1';
            end if;

        end if;
                
    end process;


end design;