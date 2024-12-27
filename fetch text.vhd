library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PCC is 
    port(
        pc_in : in std_logic_vector(15 downto 0);
		  CLK,RST: in std_logic;
		  pc_enable: in std_logic;
        pc_out : out std_logic_vector(15 downto 0));
end entity;

architecture program of PCC is

	signal pc_data : std_logic_vector(15 downto 0);
	
begin

	 write_proc: process(pc_enable,pc_in)
	 begin 
	     if(pc_enable = '1') then 
	        pc_data <= pc_in;
	     end if;
	 end process write_proc;

    read_proc: process(CLK,RST,pc_data)
    begin
		  if(RST = '1') then pc_out <= "0000000000000000";
        elsif (CLK'event and CLK = '1') then  --writing at positive clock edge
            pc_out <= pc_data;
        end if;
    end process read_proc;

end program;


---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder1 is
port (
pcin: in std_logic_vector(15 downto 0);
adder1out: out std_logic_vector(15 downto 0)
);
end entity;

architecture beh2 of adder1 is
signal disp : std_logic_vector(15 downto 0) := "0000000000000100";
	
	function add(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0))
	return std_logic_vector is	
	variable add1 : std_logic_vector(15 downto 0):= (others=>'0');
	variable carry1 : std_logic_vector(16 downto 0):= (others=>'0');	
	begin	
		carry1(0) := '0';	
		L1: for i in 0 to 15 loop		
		add1(i) := A(i) xor B(i) xor carry1(i);
		carry1(i+1) := (A(i) and B(i)) or (A(i) and carry1(i)) or (B(i) and carry1(i));		
		end loop L1;	
	return add1;	
	end add;
	
begin
	process(pcin) --upgrades pc
	begin	
		adder1out <= add(pcin, disp);	
	end process;
end beh2;
--------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder2 is
port (
pcin: in std_logic_vector(15 downto 0);
adder2out: out std_logic_vector(15 downto 0)
);
end entity;

architecture beh22 of adder2 is
signal disp : std_logic_vector(15 downto 0) := "0000000000000010";
	
	function add(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0))
	return std_logic_vector is	
	variable add1 : std_logic_vector(15 downto 0):= (others=>'0');
	variable carry1 : std_logic_vector(16 downto 0):= (others=>'0');	
	begin	
		carry1(0) := '0';	
		L1: for i in 0 to 15 loop		
		add1(i) := A(i) xor B(i) xor carry1(i);
		carry1(i+1) := (A(i) and B(i)) or (A(i) and carry1(i)) or (B(i) and carry1(i));		
		end loop L1;	
	return add1;	
	end add;
	
begin
	process(pcin) --upgrades pc
	begin	
		adder2out <= add(pcin, disp);	
	end process;
end beh22;

---------------------------------------------------------------------------------------
--(ACTING AS A MUX HERE)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity ProgCount is
port(
clock: in std_logic;
rst: in std_logic;
check: in std_logic;
adder1out: in std_logic_vector(15 downto 0);
alu2out: in std_logic_vector(15 downto 0); ----- THIS WILL COME FROM EXECUTE STAGE
pcout: out std_logic_vector(15 downto 0)
);
end entity;
architecture beh1 of ProgCount is
signal pc1 : std_logic_vector(15 downto 0) := "0000000000000000";
begin
	process(clock, rst, check) --program counter register	
	begin	
		if(rst = '1') then		
			pc1 <= "0000000000000000";		
		else	
			if(falling_edge(clock)) then					
				if(check = '0') then
					pc1 <= adder1out; --pc update						
				elsif(check = '1') then
					pc1 <= alu2out; --pc update for beq, blt, ble, jal, jlr, jri					
				end if;								
			else				
				pc1 <= pc1;			
			end if;			
		end if;		
	end process;	
	pcout <= pc1;	
end beh1;


---------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity instr_fetch is
port(
clock: in std_logic;
rst: in std_logic;
pc_enable: in std_logic; --- for stall purposes
check: in std_logic; --- check bit which will come from execute stage
alu2out : in std_logic_vector(15 downto 0);  --- branch pc value again comes from execute stage
Reg_dataout: out std_logic_vector(63 downto 0)
);
end instr_fetch;

architecture beh of instr_fetch is

component ProgCount is
port(
clock: in std_logic;
rst: in std_logic;
check: in std_logic;
adder1out: in std_logic_vector(15 downto 0);
alu2out: in std_logic_vector(15 downto 0);
pcout: out std_logic_vector(15 downto 0)
);
end component;

component adder1 is   ----+4
port (
pcin: in std_logic_vector(15 downto 0);
adder1out: out std_logic_vector(15 downto 0)
);
end component;

component adder2 is ---+2
port (
pcin: in std_logic_vector(15 downto 0);
adder2out: out std_logic_vector(15 downto 0)
);
end component;

component PCC is 
    port(
        pc_in : in std_logic_vector(15 downto 0);
		  CLK,RST: in std_logic;
		  pc_enable: in std_logic;
        pc_out : out std_logic_vector(15 downto 0));
end component;


signal pc0: std_logic_vector(15 downto 0) := (others => '0');
signal pc1: std_logic_vector(15 downto 0) := (others => '0');
signal pc2: std_logic_vector(15 downto 0) := (others => '0');
signal inst0: std_logic_vector(15 downto 0) := (others => '0');
signal adder10: std_logic_vector(15 downto 0) := (others => '0');
signal dis0: std_logic := '0';
signal alu20: std_logic_vector(15 downto 0) := (others => '0');
signal rrex0: std_logic_vector(75 downto 0) := (others => '0');

type mem is array(0 to 2**8 - 1) of std_logic_vector(15 downto 0);
signal instr: mem := (
--add intructions
others => "0000000000000000");


signal Reg_datain: std_logic_vector(31 downto 0) := (others => '0');
signal reg: std_logic_vector(63 downto 0) := (others => '0');
signal regreset: std_logic_vector(63 downto 0) := (others => '0');

	function inte(A: in std_logic_vector(15 downto 0))
	return integer is	
	variable a1: integer := 0;	
	begin		
		L1: for i in 0 to 15 loop			
			if(A(i) = '1') then
				a1 := a1 + (2**i);
			end if;			
		end loop L1;		
	return a1;	
	end inte;

begin
program_counter: ProgCount port map (clock => clock, rst => rst, check => check, adder1out => adder10, alu2out => alu2out, pcout => pc0);
adder11: adder1 port map (pcin => pc1, adder1out => adder10);
pc6 : PCC port map ( pc_in => pc0 , CLK => clock,  RST => rst, pc_enable => pc_enable, pc_out => pc1);
adder22 : adder2 port map (pcin =>pc1 , adder2out => pc2 );
	
	Reg_datain(31 downto 16) <= instr(inte(pc1));
	Reg_datain(15 downto 0) <= instr(inte(pc2));
	
--input reg is |16-bit first instr|16-bit second instr|              Reg_datain
--output reg is |16-bit pc of first instr|16-bit first instr         Reg_dataout
--              |16-bit pc of second instr|16-bit second instr|	 


	process (clock, rst)	
	begin	
		if(rst = '1') then		
			reg <= regreset;	
		else	
			
			--pc allocation for both instructions
				reg(47 downto 32) <= Reg_datain(31 downto 16); --instr
				reg(63 downto 48) <= pc1;
				
				
				reg(15 downto 0) <= Reg_datain(15 downto 0); --instr
				reg(31 downto 16) <= pc2;
				end if;	
				
			
	end process;
	Reg_dataout <= reg;
end beh;