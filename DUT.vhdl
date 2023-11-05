-- A DUT entity is used to wrap your design so that we can combine it with testbench.
-- This example shows how you can do this for the OR Gate

library ieee;
use ieee.std_logic_1164.all;

entity DUT is
port(
input_vector: in std_logic_vector(1 downto 0);
output_vector: out std_logic_vector(48 downto 0)
);
end entity;

architecture DutWrap of DUT is

component datapath is
port(
clock: in std_logic;
rst: in std_logic;
dummy0: out std_logic_vector(15 downto 0);
dummy1: out std_logic_vector(15 downto 0);
dummy2: out std_logic_vector(16 downto 0)
);
end component;

begin

   -- input/output vector element ordering is critical,
   -- and must match the ordering in the trace file!
   add_instance: datapath 
			port map (
					-- order of inputs B A
					clock => input_vector(1),
					rst => input_vector(0),
               -- order of output OUTPUT
					dummy2 => output_vector(48 downto 32),
					dummy1 => output_vector(31 downto 16),
					dummy0 => output_vector(15 downto 0));
					
end DutWrap;