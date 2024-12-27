library ieee;
use ieee.std_logic_1164.all;


entity rob is 
    generic(
        size : integer := 256 -- size of the ROB
    );
    port(
	 
	 -------------inputs--------------------------------------------------------------------------------------------
	
	clk: in std_logic; -- input clock
	 rst: in std_logic; -- reset
	 wr_inst1, wr_inst2: in std_logic; -- write bits for newly decoded instructions
	 wr_ALU1, wr_ALU2, wr_ALU3: in std_logic; -- write bits for newly executed instructions
	 output_en : in std_logic; -- read bit for finished instruction (bit that came at the top of ROB)
	 pc_decode1, pc_decode2: in std_logic_vector(15 downto 0); -- PC values associated with newly decoded instructions
    pc_exe1, pc_exe2 , pc_exe3: in std_logic_vector(15 downto 0); -- PC values associated with newly executed instructions
	 dest_reg1, dest_reg2: in std_logic_vector(2 downto 0); -- Destination registers for newly decoded instructions (ARF values)
	 rr_reg1, rr_reg2: in std_logic_vector(3 downto 0); -- Destination registers for newly decoded instructions (RRF values)
	 value_ALU1, value_ALU2,value_ALU3: in std_logic_vector(15 downto 0); --  final output values obtained from the execution pipelines
	 c_ALU1, z_ALU1, c_ALU2, z_ALU2 , c_ALU3, z_ALU3: in std_logic; -- c and z values obtained from the execution pipelines
	 c_instr1, c_instr2, c_instr3 : in std_logic_vetor(1 downto 0);
	 z_instr1, z_instr2, z_instr3 : in std_logic_vetor(1 downto 0);
	
	
	 --------------outputs---------------------------------------------------------------------------------------------------
	  pc_out : out std_logic_vector(15 downto 0);
	  value_out : out std_logic_vector(15 downto 0); -- output vaues that will be written to the registers
	  dest_out: out std_logic_vector(2 downto 0); -- destination register for final output (RRF value)
	  executed: out std_logic -- bit for when an instruction is completed
	  pc_branch: out std_logic_vector(15 downto 0); -- branch pc calculated value
	  c_instrp : out std_logic_vetor(1 downto 0);
	  z_instrp : out std_logic_vetor(1 downto 0);
	  
	  
);
end rob;

architecture behavioural of rob is

  -- defining the types required for different-sized columns
    type rob_type_16 is array(size-1 downto 0) of std_logic_vector(15 downto 0);
    type rob_type_3 is array(size-1 downto 0) of std_logic_vector(2 downto 0);
	 type rob_type_2 is array(size-1 downto 0) of std_logic_vector(1 downto 0);
    type rob_type_1 is array(size-1 downto 0) of std_logic;
	 
	  -- defining the required columns, each with (size) entries
    signal rob_pc: rob_type_16:= (others => (others => '0')); -- column for storing pc
    signal rob_value: rob_type_16:= (others => (others => '0')); -- column for storing the 16 bit values
	 signal rob_dest: rob_type_3:= (others => (others => '0'));  -- column for storing ARF values
	 signal rob_rr: rob_type_3:= (others => (others => '0'));  -- column for storing RRF values
	 --signal rob_rr2: rob_type_3:= (others => (others => '0'));
	 signal rob_c: rob_type_1:= (others => '0'); -- column for storing carry 
	 signal rob_z: rob_type_1:= (others => '0'); --  -- column for storing zero
	 signal rob_busy: rob_type_1:= (others => '0');  -- column for storing busy bit
    signal rob_issue: rob_type_1:= (others => '0');  -- column for storing issue bit
    signal rob_executed: rob_type_1:= (others => '0');  -- column for storing executed bit
	 signal rob_c_add: rob_type_2:= (others => '0');  -- column for carry address
	  signal rob_z_add: rob_type_2:= (others => '0');  -- column for zero address
	 
	  -- defining the indexes for read/write, count and the full/empty bits, pointers basically
    signal wr_index: integer range 0 to size-1 := 0;
    signal output_index: integer range 0 to size-1 := 0; 
   
begin
    -- responsible for clearing entries when clr is set
    proc_rst : process(rst)
        begin
        -- clear data and indices when reset is set
        if (rst = '1') then
            rob_pc <= (others => (others => '0'));
            rob_value <= (others => (others => '0'));
            rob_dest <= (others => (others => '0'));
            rob_rr <= (others => (others => '0'));
            --rob_rr2 <= (others => (others => '0'));
				rob_c <= (others => '0');
            rob_z <= (others => '0');
            rob_busy <= (others => '0');
            rob_issue <= (others => '0');
            wr_index <= 0;
            output_index <= 0;
            count <= 0;
        end if;
    end process proc_rst;
	 
	 
	 -- process for output 
 output_proc : process(clk, output_en , output_index)
        begin
        if rising_edge(clk) then
				
				  
            if (rob_executed(output_index) = '1') then
                pc_out <= rob_pc(output_index);
                dest_out <= rob_dest(output_index);
                value_out <= rob_value(output_index);
					 c_instrp <= rob_c_add(output_index);
					 z_instrp <= rob_z_add(output_index);
                rob_busy(output_index) <= '0';
					 rob_executed(output_index) <= '1';
					 rob_issue <= '1';
					 
            end if;
				
				-- incrementing output_index if the previous instruction is completed
            if (rob_executed(output_index) ='1') then
					output_index <= output_index + 1;
            end if;
				end if;
	
		 end process output_proc;
	 
				
		 -- responsible for filling entries in ROB with the newly decoded instructions
    dispatch_rob : process(clk, wr_ALU1, wr_ALU2, pc_decode1 , pc_decode2)
        begin
        if rising_edge(clk) then
				
				  -- writes 1st instruction to the empty entry pointed to by wr_index
            if (wr_inst1 = '1') then
                rob_pc(wr_index) <= pc_decode1;
                rob_dest(wr_index) <= dest_reg1;
                rob_rr(wr_index) <= rr_reg1;
                rob_issue(wr_index) <= '0';
                rob_busy(wr_index) <= '1';
					 rob_executed(wr_index) <= '0';
            end if;
				
				-- keeps tracks of the wr_index for the 2nd instruction
            if (wr_inst2 = '1') then
					wr_index <= wr_index + 1;
            end if;
           
				
				-- writes 2nd instruction to the empty entry pointed to by wr_index
            if (wr_inst2 = '1') then
                rob_pc(wr_index) <= pc_decode2;
                rob_dest(wr_index) <= dest_reg2;
                rob_rr(wr_index) <= rr_reg2;
                rob_issue(wr_index) <= '0';
                rob_busy(wr_index) <= '1';
					 rob_executed(wr_index) <= '0';
            end if;
				end if;
		 end process dispatch_rob;
		 
		  
	    -- responsible for writing output values from the execution pipelines, into the corresponding entry in ROB
    exe_rob : process(clk, wr_ALU1, wr_ALU2, pc_exe1, pc_exe2, pc_exe3, value_ALU1, value_ALU2, value_ALU3, c_ALU1, c_ALU2, c_ALU3,  z_ALU1, z_ALU2, z_ALU3)
        begin
        if rising_edge(clk) then
            -- write executed data from ALU1 into corresponding ROB entry
            if (wr_ALU1 = '1') then
                for i in 0 to size-1 loop
                    if (rob_pc(i) = pc_exe1) then
                        rob_value(i) <= value_ALU1;
                        rob_c(i) <= c_ALU1;
                        rob_z(i) <= z_ALU1;
								rob_c_add(i) <= c_instr1;
								rob_z_add(i) <= z_instr1;
                        rob_executed(i) <= '1';
                        exit;
                    end if;
                end loop;
            end if;
            -- write executed data from ALU2 into corresponding ROB entry
            if (wr_ALU2 = '1') then
                for i in 0 to size-1 loop
                    if (rob_pc(i) = pc_exe2) then
                        rob_value(i) <= value_ALU2;
                        rob_c(i) <= c_ALU2;
                        rob_z(i) <= z_ALU2;
								rob_c_add(i) <= c_instr2;
								rob_z_add(i) <= z_instr2;
                        rob_executed(i) <= '1';
                        exit;
                    end if;
                end loop;
            end if;
				
				 -- write executed data from ALU3 into corresponding ROB entry
            if (wr_ALU3 = '1') then
                for i in 0 to size-1 loop
                    if (rob_pc(i) = pc_exe3) then
                        rob_value(i) <= value_ALU3;
                        rob_c(i) <= c_ALU3;
                        rob_z(i) <= z_ALU3;
								rob_c_add(i) <= c_instr3;
								rob_z_add(i) <= z_instr3;
                        rob_executed(i) <= '1';
                        exit;
                    end if;
                end loop;
            end if;
        end if;
    end process exe_rob;
	 
					
end behavioural;
	 
	 
	 

	  