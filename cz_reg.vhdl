library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;	 
--use ieee.std_logic_unsigned.all;

entity cz_reg is
    port(
        clk: in std_logic;
        rst: in std_logic;
        wr_en_c: in std_logic;
        wr_en_z: in std_logic;
        busyc1, busyc2, busyz1, busyz2: in std_logic;
        read_c1: in std_logic_vector(1 downto 0);
        read_c2: in std_logic_vector(1 downto 0);
        read_z1: in std_logic_vector(1 downto 0);
        read_z2: in std_logic_vector(1 downto 0);
        wr_c_addr: in std_logic_vector(1 downto 0);
        wr_z_addr: in std_logic_vector(1 downto 0);
        wr_c_data: in std_logic;
        wr_z_data: in std_logic;

        cout1: out std_logic;
        cout2: out std_logic;
        zout1: out std_logic;
        zout2: out std_logic
    );
end entity cz_reg;

architecture design of cz_reg is
    type registers is array(0 to 3) of std_logic;
    signal RF_c: registers:= (
    '0', '0', '0', '0'
    );

    signal RF_z: registers:= (
    '0', '0', '0', '0'
    );

    --type aliasing is array(0 to 7) of std_logic_vector(3 downto 0);
    signal arf_c: std_logic_vector(1 downto 0) := "00";
    signal arf_z: std_logic_vector(1 downto 0) := "00";
	 
begin
    process(busyc1, busyc2, busyz1, busyz2, read_c1, read_c2, read_z1, read_z2)
    begin
        if(busyc1 = '0') then
            cout1 <= RF_c(to_integer(unsigned(read_c1)));
        end if;

        if(busyc2 = '0') then
            cout2 <= RF_c(to_integer(unsigned(read_c2)));
        end if;

        if(busyz1 = '0') then
            zout1 <= RF_z(to_integer(unsigned(read_z1)));
        end if;

        if(busyz2 = '0') then
            zout2 <= RF_z(to_integer(unsigned(read_z2)));
        end if;
    end process;

    process(clk, rst, wr_en_c, wr_en_z, wr_c_addr, wr_z_addr, wr_c_data, wr_z_data)
    begin
        if(falling_edge(clk)) then
            if(rst = '1') then
                for i in 0 to 3 loop--look up syntax
                    RF_c(i) <= '0';
                end loop;
            end if;

            if(wr_en_c = '1') then
                arf_c <= wr_c_addr;
                RF_c(to_integer(unsigned(wr_c_addr))) <= wr_c_data;
            end if;

            if(wr_en_z = '1') then
                arf_z <= wr_z_addr;
                RF_z(to_integer(unsigned(wr_z_addr))) <= wr_z_data;
            end if;
        end if;
    end process;
end design;