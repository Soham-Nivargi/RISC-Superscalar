library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity complimentor is
port(
opcode: in std_logic_vector(3 downto 0);
k: in std_logic;
Din: in std_logic_vector(15 downto 0);
Dout: out std_logic_vector
);
end complimentor;


architecture beh of complimentor is

signal k1: std_logic := '0';

begin

k1 <= (k and not opcode(3) and not opcode(2) and (opcode(1) xor opcode(0))); --compliments bit according to operation

Dout(0) <= k1 xor Din(0);
Dout(1) <= k1 xor Din(1);
Dout(2) <= k1 xor Din(2);
Dout(3) <= k1 xor Din(3);
Dout(4) <= k1 xor Din(4);
Dout(5) <= k1 xor Din(5);
Dout(6) <= k1 xor Din(6);
Dout(7) <= k1 xor Din(7);
Dout(8) <= k1 xor Din(8);
Dout(9) <= k1 xor Din(9);
Dout(10) <= k1 xor Din(10);
Dout(11) <= k1 xor Din(11);
Dout(12) <= k1 xor Din(12);
Dout(13) <= k1 xor Din(13);
Dout(14) <= k1 xor Din(14);
Dout(15) <= k1 xor Din(15);

end beh;