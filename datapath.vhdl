library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity datapath is
port(
clock: in std_logic;
rst: in std_logic;
dummy0: out std_logic_vector(15 downto 0);
dummy1: out std_logic_vector(15 downto 0);
dummy2: out std_logic_vector(16 downto 0)
);
end datapath;

architecture beh of datapath is

component SE10 is 
port(
IR10: in std_logic_vector(5 downto 0);
SE10: out std_logic_vector(15 downto 0)
);
end component;

component SE7 is 
port(
IR7: in std_logic_vector(8 downto 0);
SE7: out std_logic_vector(15 downto 0)
);
end component;

component adder1 is
port (
pc: in std_logic_vector(15 downto 0);
adder1out: out std_logic_vector(15 downto 0)
);
end component;

component alu2 is
port(
dis0: in std_logic;
dis: in std_logic;
select0: in std_logic_vector(3 downto 0);
alu2a: in std_logic_vector(15 downto 0);
alu2b: in std_logic_vector(15 downto 0);
pc: in std_logic_vector(15 downto 0);
imm: in std_logic_vector(15 downto 0);
alu2c: out std_logic_vector(15 downto 0);
carry: out std_logic;
zero: out std_logic
);
end component;

component imem is
port(
pc: in std_logic_vector(15 downto 0);
inst: out std_logic_vector(15 downto 0)
);
end component;

component dmem is
port(
clock: in std_logic;
rst: in std_logic;
memen: in std_logic;
addr: in std_logic_vector(15 downto 0);
Din: in std_logic_vector(15 downto 0);
Dout: out std_logic_vector(15 downto 0)
--dmemcheck: out std_logic_vector(15 downto 0)
);
end component;

component registerfiles is 
port(
rst: in std_logic;
wr1, wr2, wr3: in std_logic;
a1, a2, a31, a32, a33: in std_logic_vector(2 downto 0);
d31, d32, d33, pc: in std_logic_vector(15 downto 0); 
d1, d2: out std_logic_vector(15 downto 0);
regdataout: out std_logic_vector(15 downto 0)
);
end component;

component pc is
port(
clock: in std_logic;
rst: in std_logic;
bubble: in std_logic;
check: in std_logic;
check1: in std_logic;
adder1out: in std_logic_vector(15 downto 0);
alu2out: in std_logic_vector(15 downto 0);
pcout: out std_logic_vector(15 downto 0)
);
end component;

component ifid is 
port(
clock: in std_logic;
rst: in std_logic;
Bubble: in std_logic;
dis: in std_logic;
pc: in std_logic_vector(15 downto 0);
adder1out: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(15 downto 0);
Reg_dataout: out std_logic_vector(32 downto 0)
);
end component;

component idrr is 
port(
clock: in std_logic;
rst: in std_logic;
Bubble: in std_logic;
dis: in std_logic;
Reg_datain: in std_logic_vector(32 downto 0);
se7: in std_logic_vector(15 downto 0);
se10: in std_logic_vector(15 downto 0);
Reg_dataout: out std_logic_vector(48 downto 0)
);
end component;

component rrex is 
port(
clock: in std_logic;
rst: in std_logic;
Bubble: in std_logic;
dis: in std_logic;
dis1: in std_logic;
regd1: in std_logic_vector(15 downto 0);
regd2: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(48 downto 0);
regaddr1: in std_logic_vector(2 downto 0);
regaddr2: in std_logic_vector(2 downto 0);
Reg_dataout: out std_logic_vector(75 downto 0)
);
end component;

component exmem is 
port(
clock: in std_logic;
rst: in std_logic;
dis: in std_logic;
memen: in std_logic;
wrwb, wrmem: in std_logic;
alu2out: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(75 downto 0);
Reg_dataout: out std_logic_vector(42 downto 0)
);
end component;

component memwb is 
port(
clock: in std_logic;
rst: in std_logic;
dmemdata: in std_logic_vector(15 downto 0);
Reg_datain: in std_logic_vector(42 downto 0);
Reg_dataout: out std_logic_vector(19 downto 0)
);
end component;

component controller is
port(
dis: in std_logic;
regd1: in std_logic_vector(15 downto 0);
regd2: in std_logic_vector(15 downto 0);
regaddr1: in std_logic_vector(2 downto 0);
regaddr2: in std_logic_vector(2 downto 0);
regaddr: in std_logic_vector(2 downto 0);
carry: in std_logic;
zero: in std_logic;
opcode: in std_logic_vector(3 downto 0);
kcz: in std_logic_vector(2 downto 0);
datadep: in std_logic;
check: out std_logic;
dis1: out std_logic;
wr1: out std_logic;
wr2: out std_logic;
wr3: out std_logic;
memen: out std_logic;
bubble: out std_logic;
select0: out std_logic_vector(3 downto 0);
dis2: out std_logic
);
end component;

component converter is
port(
clock: in std_logic;
inst0: in std_logic_vector(15 downto 0);
check1: out std_logic;
inst1: out std_logic_vector(15 downto 0);
converterout: out std_logic_vector(15 downto 0)
);
end component;

component cz is
port(
clock: in std_logic;
c: in std_logic;
z: in std_logic;
rst: in std_logic;
carry: out std_logic;
zero: out std_logic
);
end component;

component complimentor is
port(
opcode: in std_logic_vector(3 downto 0);
k: in std_logic;
Din: in std_logic_vector(15 downto 0);
Dout: out std_logic_vector
);
end component;

signal pc0: std_logic_vector(15 downto 0) := (others => '0');
signal inst0: std_logic_vector(15 downto 0) := (others => '0');
signal adder10: std_logic_vector(15 downto 0) := (others => '0');
signal ifid0: std_logic_vector(32 downto 0) := (others => '0');
signal se70: std_logic_vector(15 downto 0) := (others => '0');
signal se100: std_logic_vector(15 downto 0) := (others => '0');
signal idrr0: std_logic_vector(48 downto 0) := (others => '0');
signal regd1: std_logic_vector(15 downto 0) := (others => '0');
signal regd2: std_logic_vector(15 downto 0) := (others => '0');
signal rrex0: std_logic_vector(75 downto 0) := (others => '0');
signal alu20: std_logic_vector(15 downto 0) := (others => '0');
signal bubble0: std_logic := '0';
signal dis0: std_logic := '0';
signal dis1: std_logic := '0';
signal wr1: std_logic := '0';
signal wr2: std_logic := '0';
signal wr3: std_logic := '0';
signal memen1: std_logic := '0';
signal registercheck: std_logic_vector(15 downto 0) := (others => '0');
signal dmem0: std_logic_vector(15 downto 0) := (others => '0');
signal carry: std_logic := '0';
signal zero: std_logic := '0';
signal select0: std_logic_vector(3 downto 0) := (others => '0');
signal exmem0: std_logic_vector(42 downto 0) := (others => '0');
signal memwb0: std_logic_vector(19 downto 0) := (others => '0');
signal inst: std_logic_vector(15 downto 0) := (others => '0');
signal check1: std_logic := '0';
signal converterout: std_logic_vector(15 downto 0) := (others => '0');
signal dmemcheck: std_logic_vector(15 downto 0) := (others => '0');
signal dis2: std_logic := '0';
signal carry11: std_logic := '0';
signal zero11: std_logic := '0';
signal alu2b0: std_logic_vector(15 downto 0) := (others => '0');

begin

pc1: pc port map (clock => clock, rst => rst, bubble  => bubble0, check => dis0, check1 => check1, adder1out => adder10, alu2out => alu20, pcout => pc0);
imem1: imem port map (pc => pc0, inst => inst);
adder11: adder1 port map (pc => pc0, adder1out => adder10);
converter1: converter port map (clock => clock, inst0 => inst, check1 => check1, inst1 => inst0, converterout => converterout);
ifid1: ifid port map (clock => clock, rst => rst, Bubble => bubble0, dis => dis0, pc => pc0, adder1out => adder10, Reg_datain => inst0, Reg_dataout => ifid0);
se71: SE7 port map (IR7 => ifid0(8 downto 0), SE7 => se70);
se101: SE10 port map (IR10 => ifid0(5 downto 0), SE10 => se100);
idrr1: idrr port map (clock => clock, rst => rst, Bubble => bubble0, dis => dis0, Reg_datain => ifid0, se7 => se70, se10 => se100, Reg_dataout => idrr0);
registerfiles1: registerfiles port map (rst => rst, wr1 => memwb0(19), wr2 => wr2, wr3 => exmem0(40), a1 => idrr0(27 downto 25), a2 => idrr0(24 downto 22), a31 => memwb0(2 downto 0), a32 => rrex0(18 downto 16), a33 => exmem0(18 downto 16), d31 => memwb0(18 downto 3), d32 => alu20, d33 => dmem0, pc => pc0, d1 => regd1, d2 => regd2, regdataout => registercheck);
rrex1: rrex port map (clock => clock, rst => rst, Bubble => bubble0, dis => dis0, dis1 => dis1, regd1 => regd1, regd2 => regd2, Reg_datain => idrr0, regaddr1 => ifid0(11 downto 9), regaddr2 => ifid0(8 downto 6), Reg_dataout => rrex0);
alu21: alu2 port map (dis => dis2, dis0 => rrex0(75), select0 => select0, alu2a => rrex0(50 downto 35), alu2b => alu2b0, pc => rrex0(73 downto 58), imm => rrex0(15 downto 0), alu2c => alu20, carry => carry11, zero => zero11);
controller1: controller port map (dis => rrex0(75), regd1 => rrex0(50 downto 35), regd2 => rrex0(34 downto 19), regaddr1 => ifid0(11 downto 9), regaddr2 => ifid0(8 downto 6), regaddr => rrex0(18 downto 16), carry => carry, zero => zero, opcode => rrex0(57 downto 54), kcz => rrex0(53 downto 51), datadep => rrex0(74), check => dis0, dis1 => dis1, wr1 => wr1, wr2 => wr2, wr3 => wr3, memen => memen1, bubble => bubble0, select0 => select0, dis2 => dis2);
exmem1: exmem port map (clock => clock, rst => rst, dis => dis2, memen => memen1, wrwb => wr1, wrmem => wr3, alu2out => alu20, Reg_datain => rrex0, Reg_dataout => exmem0);
dmem1: dmem port map (clock => clock, rst => rst, memen => exmem0(39), addr => exmem0(34 downto 19), Din => exmem0(15 downto 0), Dout => dmem0);--, dmemcheck => dmemcheck);
memwb1: memwb port map (clock => clock, rst => rst, dmemdata => dmem0, Reg_datain => exmem0, Reg_dataout => memwb0);
cz1: cz port map (clock => clock, c => carry11, z => zero11, rst => rst, carry => carry, zero => zero);
complimentor1: complimentor port map (opcode => rrex0(57 downto 54), k => rrex0(53), Din => rrex0(34 downto 19), Dout => alu2b0);

dummy0 <= registercheck; --dummy outputs
dummy1 <= (others => '0');
dummy2(15 downto 0) <= (others => '0');
dummy2(16) <= '0';

end beh;