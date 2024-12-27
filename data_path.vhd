library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    PORT (
        reset, clk : in std_logic
    );
end entity;

architecture dp of datapath is 

---------- IF STAGE

component instr_fetch is
    port(
        clock: in std_logic;
        rst: in std_logic;
        pc_enable: in std_logic; 
        check: in std_logic;
        alu2out : in std_logic_vector(15 downto 0);  
        Reg_dataout: out std_logic_vector(63 downto 0)
    );
end component instr_fetch;

component dmem is
    port(
        clock: in std_logic;
        rst: in std_logic;
        memen: in std_logic;
        addr: in std_logic_vector(15 downto 0);
        Din: in std_logic_vector(15 downto 0);
        Dout: out std_logic_vector(15 downto 0)
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

------------------ IF-ID pipeline register

component pipe_reg1 is 
    port(
        Reg_dataout1: in std_logic_vector(63 downto 0);
        CLK,RST: in std_logic;
        pipe_reg1_enable: in std_logic;
        Reg_dataout2: out std_logic_vector(63 downto 0));     -- Reg_dataout2 passed on to the second stage
end component pipe_reg1;

--------------------------------ID stage

component instr_decode is 
    port(
        clock: in std_logic;
        rst: in std_logic;
        Reg_datain: in std_logic_vector(63 downto 0);
        Reg_dataout: out std_logic_vector(95 downto 0)
    );
end instr_decode;

component rs is 
    port(
        clk: in std_logic;
        rst: in std_logic; 
        op_instr1, op_instr2: in std_logic_vector(3 downto 0); 
        opr1_inst1, opr2_inst1, wr_opr_inst1, opr1_inst2, opr2_inst2, wr_opr_inst2: in std_logic_vector(2 downto 0); 
        imm16_inst1, imm16_inst2, pc_instr1, pc_instr2: in std_logic_vector(15 downto 0); 
        wr_rob_reg: in std_logic_vector(3 downto 0);
        wr_en: in std_logic;
        wr_rob_c: in std_logic_vector(1 downto 0);
        wr_c: in std_logic;
        cond_instr1, cond_instr2: in std_logic_vector(1 downto 0);
        comp_instr1, comp_instr2: in std_logic;
        wr_rob_z: in std_logic_vector(1 downto 0);
        wr_z: in std_logic;

        stall1, stall2: out std_logic; 
        en1, en2, en3: out std_logic;
        op_instr1_out, op_instr2_out, op_instr3_out: out std_logic_vector(3 downto 0);
        wr_opr_instr1_out,wr_opr_instr2_out,wr_opr_instr3_out: out std_logic_vector(2 downto 0);
        wr_opr1_instr1,wr_opr1_instr2,wr_opr1_instr3: out std_logic_vector(3 downto 0);
        imm16_instr1_out, imm16_instr2_out, imm16_instr3_out, pc_instr1_out, pc_instr2_out, pc_instr3_out: out std_logic_vector(15 downto 0); 
        cond_instr1_out, cond_instr2_out: out std_logic_vector(1 downto 0);
        comp_instr1_out, comp_instr2_out: out std_logic;
        rr1_instr1, rr2_instr1, rr1_instr2, rr2_instr2, rr1_instr3, rr2_instr3: out std_logic_vector(3 downto 0); 
        c_instr1_in, c_instr2_in, c_instr3_in, z_instr1_in, z_instr2_in,z_instr3_in: out std_logic_vector(1 downto 0); 
        c_instr1_out, c_instr2_out, c_instr3_out, z_instr1_out, z_instr2_out, z_instr3_out: out std_logic_vector(1 downto 0)
    );
end component rs;

component reg_file is
    port(
        clk => clk;
        rst => rst;
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
end component reg_file;

component cz_reg is
    port(
        clk: in std_logic;
        rst: in std_logic;
        wr_en_c: in std_logic;
        wr_en_z: in std_logic;
        busyc1, busyc2, busyc3, busyz1, busyz2, busyz3: in std_logic;  -- not enable from rs
        read_c1: in std_logic_vector(1 downto 0);  -- from rs
        read_c2: in std_logic_vector(1 downto 0);
        read_c3: in std_logic_vector(1 downto 0);
        read_z1: in std_logic_vector(1 downto 0); --same 
        read_z2: in std_logic_vector(1 downto 0);
        read_z3: in std_logic_vector(1 downto 0);
        wr_c_addr: in std_logic_vector(1 downto 0);  -- from rob which shud be added
        wr_z_addr: in std_logic_vector(1 downto 0);  -- 
        wr_c_data: in std_logic; -- from rob
        wr_z_data: in std_logic; -- from rob

        cout1: out std_logic;  -- to execute
        cout2: out std_logic;
        cout3: out std_logic;
        zout1: out std_logic;
        zout2: out std_logic;
        zout3: out std_logic
    );
end component cz_reg;


--------------------------------------------------------------------------------------------------------------------EXECUTION

component execution is 
    port(
        clock: in std_logic;
        rst: in std_logic;
        regd1: in std_logic_vector(15 downto 0);
        regd2: in std_logic_vector(15 downto 0);
        regd3: in std_logic_vector(15 downto 0);
        regd4: in std_logic_vector(15 downto 0);
        regd5: in std_logic_vector(15 downto 0);
        regd6: in std_logic_vector(15 downto 0);
        Reg_datain: in std_logic_vector(95 downto 0);
        Reg_dataout: out std_logic_vector(147 downto 0);
        alu2c1: out std_logic_vector(15 downto 0);
        alu2c2: out std_logic_vector(15 downto 0);
        wr11: out std_logic;
        wr21: out std_logic;
        wr31: out std_logic;
        wr12: out std_logic;
        wr22: out std_logic;
        wr32: out std_logic
    );
end execution;

component rob is 
    generic(
        size : integer := 256 -- size of the ROB
    );
    port(
        clk: in std_logic; -- input clock
        wr_inst1, wr_inst2: in std_logic; -- write bits for newly decoded instructions
        wr_ALU1, wr_ALU2: in std_logic; -- write bits for newly executed instructions
        --rd: in std_logic; -- read bit for finished instructions 
        pc_decode1, pc_decode2: in std_logic_vector(15 downto 0); -- PC values associated with newly decoded instructions
        pc_exe1, pc_exe2: in std_logic_vector(15 downto 0); -- PC values associated with newly executed instructions
        dest_reg1, dest_reg2: in std_logic_vector(2 downto 0); -- Destination registers for newly decoded instructions (ARF values)
        rr_reg1, rr_reg2: in std_logic_vector(2 downto 0); -- Destination registers for newly decoded instructions (PRF values)
        value_ALU1, value_ALU2: in std_logic_vector(15 downto 0); -- final output values obtained from the execution pipelines
        c_ALU1, z_ALU1, c_ALU2, z_ALU2: in std_logic; -- c and z values obtained from the execution pipelines

        --------------outputs---------------------------------------------------------------------------------------------------
        value_out1, value_out2 : out std_logic_vector(15 downto 0); -- output vaues that will be written to the registers
        dest_out1, dest_out2: out std_logic_vector(2 downto 0); -- destination register for final output
        executed: out std_logic -- bit for when an instruction is completed
        -- value of z1 and c1,2
        -- rr out1,2 3 downto 0


);
end rob;

-----------------------------------------------------------------------------------------------------------

----------- SIGNALS FOR IF AND IF-ID PIPELINE REGISTER

signal Reg_dataoutp: std_logic_vector(63 downto 0);

------------ SIGNALS FOR IF-ID PIPELINE REGISTER AND ID STAGE
signal Reg_dataout2p: std_logic_vector(63 downto 0);

--------------------------------- SIGNALS FOR ID AND RS
 
signal Reg_dataoutop: std_logic_vector(95 downto 0);

------------------------------------------- SIGNALS FOR RS AND EXECUTION

signal en1_busy, en2_busy, en3_busy: std_logic;
signal rr1_instr1_read_addr1, rr2_instr1_read_addr2, rr1_instr2_read_addr3, rr2_instr2_read_addr4, rr1_instr3_read_addr5, rr2_instr3_read_addr6: std_logic_vector(3 downto 0)
signal data_to_ex1, data_to_ex2, data_to_ex3, data_to_ex4, data_to_ex5, data_to_ex6: std_logic_vector(15 downto 0);
signal c_instr1_in_read_c1, c_instr2_in_read_c2, c_instr3_in_read_c3: std_logic_vector(1 downto 0);
signal z_instr1_in_read_z1, z_instr2_in_read_z2, z_instr3_in_read_z3: std_logic_vector(1 downto 0);
signal alu_data_out1, alu_data_out2: std_logic_vector(15 downto 0); 
signal wr_cz1, wr_cz2, wr_cz3, wr_cz4: std_logic;
signal address_1_arf, address_2_arf: std_logic_vector(2 downto 0);
signal wrb_data1, wb_data2: std_logic_vector(15 downto 0);
signal decode_to_rs: std_logic_vector(95 downto 0);
signal rs_to_execute_reg_data: std_logic_vector(95 downto 0);
signal idrr0: std_logic_vector(48 downto 0) := (others => '0');
signal regd1: std_logic_vector(15 downto 0) := (others => '0');
signal alu20: std_logic_vector(15 downto 0) := (others => '0');
signal wr1: std_logic := '0';
signal wr2: std_logic := '0';
signal wr3: std_logic := '0';
signal memen1: std_logic := '0';
signal registercheck: std_logic_vector(15 downto 0) := (others => '0');
signal dmem0: std_logic_vector(15 downto 0) := (others => '0');
signal exmem0: std_logic_vector(42 downto 0) := (others => '0');
signal memwb0: std_logic_vector(19 downto 0) := (others => '0');
signal dmemcheck: std_logic_vector(15 downto 0) := (others => '0');
signal dis2: std_logic := '0';
--------------------------------------------------------------------

begin 

registerfiles1: registerfiles port map (rst => rst, wr1 => memwb0(19), wr2 => wr2, wr3 => exmem0(40), a1 => idrr0(27 downto 25), a2 => idrr0(24 downto 22), a31 => memwb0(2 downto 0), a32 => rrex0(18 downto 16), a33 => exmem0(18 downto 16), d31 => memwb0(18 downto 3), d32 => alu20, d33 => dmem0, pc => pc0, d1 => regd1, d2 => regd2, regdataout => registercheck);
exmem1: exmem port map (clock => clock, rst => rst, dis => dis2, memen => memen1, wrwb => wr1, wrmem => wr3, alu2out => alu20, Reg_datain => INPUT FROM ROB, Reg_dataout => exmem0);
dmem1: dmem port map (clock => clock, rst => rst, memen => exmem0(39), addr => exmem0(34 downto 19), Din => exmem0(15 downto 0), Dout => dmem0);--, dmemcheck => dmemcheck);
memwb1: memwb port map (clock => clock, rst => rst, dmemdata => dmem0, Reg_datain => exmem0, Reg_dataout => memwb0);

instfetch: instr_fetch port map(
    pc => output(63 downto 48),
    clock => clk,
    rst=> reset ,
    pc_enable => ,--- for stall purposes
    check => , --- check bit which will come from execute stage
    alu2out => ,  --- branch pc value again comes from execute stage
    Reg_dataout => Reg_dataoutp
);


pipe1 :  pipe_reg1 port map(
    Reg_dataout => Reg_dataoutp,
    CLK => clk, RST => rst,
    pipe_reg1_enable =>  ,
    Reg_dataout2 => Reg_dataout2p
);      -- Reg_dataout2 passed on to the second stage
		  
decode : instr_decode port map(
    clock => clk;
    rst => rst;
    Reg_datain => Reg_dataout2p; 
    Reg_dataout  => decode_to_rs
);

port_map3 : rs is 
    port map(
        clk => clk;
        rst => rst; 
        op_instr1 => decode_to_rs(15 downto 12);
        op_instr2 => decode_to_rs(47 downto 44);
        opr1_inst1  => decode_to_rs(11 downto 9);
        opr2_inst1 => decode_to_rs(8 downto 6);
        wr_opr_inst1  => decode_to_rs(6 downto 4);
        opr1_inst2  => decode_to_rs(38 downto 36);
        opr2_inst2  => decode_to_rs(41 downto 39);
        wr_opr_inst2 => decode_to_rs(44 downto 42);
        imm16_inst1 => decode_to_rs(11 downto 0);
        imm16_inst2 => decode_to_rs(43 downto 32);
        pc_instr1 => decode_to_rs(95 downto 80);
        pc_instr2 => decode_to_rs(47 downto 32);

        en1 => en1_busy;
        en2 => en2_busy;
        en3 => en3_busy;
        op_instr1_out => rs_to_execute_reg_data(15 downto 12);
        op_instr2_out => rs_to_execute_reg_data(47 downto 44);
        op_instr3_out => rs_to_execute_reg_data(11 downto 9);   
        
        wr_opr_instr1_out => rs_to_execute_reg_data(44 downto 42);
        wr_opr_instr2_out => rs_to_execute_reg_data(11 downto 0);
        wr_opr_instr3_out => rs_to_execute_reg_data(41 downto 39);  
        wr_opr1_instr1 => rs_to_execute_reg_data(43 downto 32);
        wr_opr1_instr2 => rs_to_execute_reg_data(95 downto 80);
        wr_opr1_instr3 => rs_to_execute_reg_data(47 downto 32);      
        
        rr1_instr1 => rr1_instr1_read_addr1;
        rr2_instr1 => rr2_instr1_read_addr2;
        rr1_instr2 => rr1_instr2_read_addr3;
        rr2_instr2 => rr2_instr2_read_addr4;
        rr1_instr3 => rr1_instr3_read_addr5;
        rr2_instr3 => rr2_instr3_read_addr6;
        c_instr1_in => c_instr1_in_read_c1;
        c_instr2_in => c_instr2_in_read_c2;
        c_instr3_in => c_instr3_in_read_c3;
        z_instr1_in => z_instr1_in_read_z1; 
        z_instr2_in => z_instr2_in_read_z2;
        z_instr3_in => z_instr3_in_read_z3;
    );

    port_map4: reg_file port map(
        clk => clk;
        rst => rst;

        busy1 => not(en1_busy);
        busy2 => not(en1_busy);
        busy3 => not(en2_busy);
        busy4 => not(en2_busy);
        busy5 => not(en3_busy);
        busy6 => not(en3_busy);

        read_addr1 => rr1_instr1_read_addr1;
        read_addr2 => rr2_instr1_read_addr2;
        read_addr3 => rr1_instr2_read_addr3;
        read_addr4 => rr2_instr2_read_addr4;
        read_addr5 => rr1_instr3_read_addr5;
        read_addr6 => rr2_instr3_read_addr6;

        rout1 => data_to_ex1;
        rout2 => data_to_ex2;
        rout3 => data_to_ex3;
        rout4 => data_to_ex4;
        rout5 => data_to_ex5;
        rout6 => data_to_ex6
    );

    port_map5: execution port map(
        clock => clk;
        rst => rst;
        regd1 => data_to_ex1;
        regd2 => data_to_ex2;
        regd3 => data_to_ex3;
        regd4 => data_to_ex4;
        regd5 => data_to_ex5;
        regd6 => data_to_ex6;
        Reg_datain => rs_to_execute_reg_data;
        alu2c1 => alu_data_out1;
        alu2c2 => alu_data_out2;
        wr11 => wr_cz1;
        wr21 => wr_cz2;
        wr12 => wr_cz3;
        wr22 => wr_cz4;
    );

    port_map2: rob is port map(
    clk => clk;
    rst => rst;
    wr_inst1 => wr_cz1;
    rr_reg1 => rr1_instr1_read_addr1;
    rr_reg2 => rr2_instr2_read_addr2;
    value_ALU1 => alu_data_out1;
    value_ALU2 => alu_data_out2;
    c_ALU1 => wr_cz1;
    z_ALU1 => wr_cz2;
    c_ALU2 => wr_cz3;
    z_ALU2 => wr_cz4;
    value_out1 => wrb_data1;
    value_out2 => wrb_data2;
    dest_out1 => address_1_arf;
    dest_out2 => address_2_arf;
    executed => executed;
    )

    port_map6: cz_reg port map(
        clk => clk;
        rst => rst;

        busyc1 => not(en1_busy);
        busyc2 => not(en2_busy);
        busyc3 => not(en3_busy);
        busyz1 => not(en1_busy);
        busyz2 => not(en2_busy);
        busyz3 => not(en3_busy);

        read_c1 => c_instr1_in_read_c1;
        read_c2 => c_instr2_in_read_c2;
        read_c3 => c_instr3_in_read_c3;
        read_z1 => z_instr1_in_read_z1;
        read_z2 => z_instr2_in_read_z2;
        read_z3 => z_instr3_in_read_z3;
    )

end dp;
        

    