library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;	 
--use ieee.std_logic_unsigned.all;

entity reg_file is
    port(
        clk: in std_logic;
        rst: in std_logic;
        rd_en: in std_logic;
        wr_en: in std_logic;
        busy1, busy2, busy3, busy4: in std_logic;
        read_addr1: in std_logic_vector(3 downto 0);
        read_addr2: in std_logic_vector(3 downto 0);
        read_addr3: in std_logic_vector(3 downto 0);
        read_addr4: in std_logic_vector(3 downto 0);
        wr_addr: in std_logic_vector(3 downto 0);
        wr_rat: in std_logic_vector(2 downto 0);
        wr_data: in std_logic_vector(15 downto 0);

        rout1: out std_logic_vector(15 downto 0);
        rout2: out std_logic_vector(15 downto 0);
        rout3: out std_logic_vector(15 downto 0);
        rout4: out std_logic_vector(15 downto 0)
    );
end entity reg_file;

architecture design of reg_file is
    type registers is array(0 to 15) of std_logic_vector(15 downto 0);
    signal RF: registers:= (
    "0000000000000000", 
    "0000000000000000",
    "0000000000000000", 
    "0000000000000000",
    "0000000000000000", 
    "0000000000000000", 
    "0000000000000000", 
    "0000000000000000", 
    "0000000000000000",
    "0000000000000000", 
    "0000000000000000",
    "0000000000000000", 
    "0000000000000000", 
    "0000000000000000", 
    "0000000000000000", 
    "0000000000000000"
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
    process(rd_en, busy1, busy2, busy3, busy4, read_addr1, read_addr2, read_addr3, read_addr4)
    begin
        if(rd_en = '1') then
            if(busy1 = '0') then
                rout1 <= RF(to_integer(unsigned(read_addr1)));
            end if;

            if(busy2 = '0') then
                rout2 <= RF(to_integer(unsigned(read_addr2)));
            end if;

            if(busy3 = '0') then
                rout3 <= RF(to_integer(unsigned(read_addr3)));
            end if;

            if(busy4 = '0') then
                rout4 <= RF(to_integer(unsigned(read_addr4)));
            end if;
        end if;
    end process;

    process(clk, rst, wr_en, wr_addr, wr_rat, wr_data)
    begin
        if(falling_edge(clk)) then
            if(rst = '1') then
                for i in 0 to 15 loop--look up syntax
                    RF(i) <= "0000000000000000";
                end loop;
            end if;

            if(wr_en = '1') then
                rat(to_integer(unsigned(wr_rat))) <= wr_addr;
                RF(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
        end if;
    end process;
end design;