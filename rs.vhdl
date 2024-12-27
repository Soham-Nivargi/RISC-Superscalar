library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity rs is 
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
        c_instr1_out, c_instr2_out, c_instr3_out,z_instr1_out, z_instr2_out, z_instr3_out: out std_logic_vector(1 downto 0)
    );
    

end entity rs;

architecture design of rs is

    type type_4 is array(15 downto 0) of std_logic_vector(3 downto 0);
    type type_16 is array(15 downto 0) of std_logic_vector(15 downto 0);
    type type_1 is array(15 downto 0) of std_logic;
    type type_3 is array(15 downto 0) of std_logic_vector(5 downto 0);
    type type_8 is array(15 downto 0) of std_logic_vector(7 downto 0);
	 type type_2 is array(15 downto 0) of std_logic_vector(7 downto 0);

    signal instr, comp: type_1:=('0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
    signal opcode: type_4:=("0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000");
    signal imm16, pc: type_16:=("0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", 
                            "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", 
                            "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000", 
                            "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000");
    signal opr1, opr2, opr3: type_3:=("000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000", "000");
    signal opr1_prf, opr2_prf, opr3_prf: type_4:=("0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000");
    signal c1, c2, z1, z2, cond : type_2:= ("00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00");
    signal valid_opr1, valid_opr2, valid_c, valid_z: type_1:= ('0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

    component rat is
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
    end component rat;

    component c_rat is
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
	end component c_rat;

    component z_rat is
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
	 end component z_rat;

    signal i1: integer:= 0;
	 signal i2: integer:= 0;
	 
	 type intarray is array(1 downto 0) of integer;

    signal stall_rat1, stall_rat2, stall_full1, stall_full2, stall_crat1, stall_crat2, stall_zrat1, stall_zrat2: std_logic;
    signal x: intarray := (0,0);
    signal en_1, en_2, en_c1, en_c2: std_logic;
	 signal x1,x2: integer := 0;

    begin

        rat1: rat port map(clk => clk, rst => rst, wr_en => wr_en, wr_rob_addr => wr_rob_reg, read_addr1 => opr1(i1), read_addr2 => opr2(i1), read_addr3 => opr1(i2), read_addr4 =>opr2(i2),
                            wr_addr1 => wr_opr_inst1, wr_addr2 => wr_opr_inst2, read1 => opr1_prf(x1), read2 => opr2_prf(x1), read3 => opr1_prf(x2), read4 => opr2_prf(x2), 
                            rout1 => opr1_prf(i1), rout2 => opr2_prf(i1), rout3 => opr1_prf(i2), rout4 => opr2_prf(i2), wout1 => opr3_prf(i1), wout2 => opr3_prf(i2),
                            busy1 => valid_opr1(i1), busy2 => valid_opr2(i1), busy3 => valid_opr1(i2), busy4 => valid_opr2(i2), 
                            b1 => valid_opr1(x1), b2 => valid_opr2(x1), b3 => valid_opr1(x2), b4 => valid_opr2(x2),
                            stall1 => stall_rat1, stall2 => stall_rat2);
        
        carry_rat: c_rat port map(clk => clk, rst => rst, wr_en => wr_c, wr_rob => wr_rob_c, en1 => en_c1, en2 => en_c2, cout1 => c2(i1), cout2 => c2(i2), cin1 => c1(i1), cin2 => c1(i2), busy1 => valid_c(i1), busy2 => valid_c(i2), stall1 => stall_crat1, stall2 => stall_crat2, read1 => c1(x1), read2 => c1(x2), b1 => valid_c(x1), b2 => valid_c(x2));
        zero_rat: c_rat port map(clk => clk, rst => rst, wr_en => wr_z, wr_rob => wr_rob_z, en1 => en_c1, en2 => en_c2, cout1 => z2(i1), cout2 => z2(i2), cin1 => z1(i1), cin2 => z1(i2), busy1 => valid_z(i1), busy2 => valid_z(i2), stall1 => stall_zrat1, stall2 => stall_zrat2, read1 => z1(x1), read2 => z1(x2), b1 => valid_z(x1), b2 => valid_z(x2));
    
		  x1 <= x(0);
		  x2 <= x(1);
			
        process(clk,rst,op_instr1,opr1_inst1,opr2_inst1,wr_opr_inst1,imm16_inst1,op_instr2,opr1_inst2,opr2_inst2,wr_opr_inst2,imm16_inst2)
        variable set1 : integer := 0;
        variable set2 : integer := 0;
        begin
            if(rising_edge(clk)) then
                for i in 0 to 15 loop
                    if(instr(i) = '0') then
                        instr(i) <= '1';
                        i1 <= i;
                        opcode(i) <= op_instr1;
                        opr1(i) <= opr1_inst1;
                        opr2(i) <= opr2_inst1;
                        opr3(i) <= wr_opr_inst1;
                        imm16(i) <= imm16_inst1;
                        cond(i) <= cond_instr1;
                        comp(i) <= comp_instr1;
                        pc(i) <= pc_instr1;
                        set1 := 1;
                        exit;
                    end if;
                end loop;

                for i in 0 to 15 loop
                    if(instr(i) = '0') then
                        instr(i) <= '1';
                        i2 <= i;
                        opcode(i) <= op_instr2;
                        opr1(i) <= opr1_inst2;
                        opr2(i) <= opr2_inst2;
                        opr3(i) <= wr_opr_inst2;
                        imm16(i) <= imm16_inst2;
                        cond(i) <= cond_instr2;
                        comp(i) <= comp_instr2;
                        pc(i) <= pc_instr2;
                        set2 := 1;
                        exit;
                    end if;
                end loop;

                if(set1 = 0) then
                    stall_full1 <= '1';
                    stall_full2 <= '1';
                elsif(set2 = 0) then
                    stall_full2 <= '1';
                    stall_full1 <= '0';
                else 
                    stall_full1 <= '0';
                    stall_full2 <= '0';
                end if;
				end if;
                    
		end process;

            process(clk, rst)
            variable count : integer := 0;
            begin
                for i in 0 to 15 loop
                    if(instr(i) = '1' and i /= i1 and i /= i2) then
                        x(count) <= i;
                        count := count +1;
                        if(count = 2) then
                            exit;
                        end if;
                    end if;
                end loop;
                if(count = 2) then
                    en_1 <= '1';
                    en_2 <= '1';
                elsif(count = 1) then
                    if(instr(x(0)) = '1') then
                    en_1 <= '1';
                    en_2 <= '0';
                    elsif(instr(x(1)) = '1') then
                    en_1 <= '0';
                    en_2 <= '1';
                    end if;
                else
                    en_1 <= '0';
                    en_2 <= '0';
                end if;
            end process;

            process(clk)
            begin
                if(opcode(i1) = "0000" or opcode(i1) = "0001" or opcode(i1) = "0010") then
                    en_c1 <= '1';
                else
                    en_c1 <= '0';
                end if;

                if(opcode(i2) = "0000" or opcode(i2) = "0001" or opcode(i2) = "0010") then
                    en_c2 <= '1';
                else
                    en_c2 <= '0';
                end if;

            end process;
                 

            process(clk, rst)
            variable p1 : std_logic:= '0';
				variable p2 : std_logic:= '0';
				variable p3 : std_logic:= '0';
            begin
                if(falling_edge(clk)) then
                    if(instr(i1) = '1') then
                        if((opcode(i1) = "0001" or opcode(i1) = "0010")) then
                            if(valid_opr1(i1) = '1' and valid_opr2(i2) = '1' and valid_c(i1) = '1' and valid_z(i1) = '1') then
                                p1 := '1';
                                op_instr1_out <= opcode(i1);
                                wr_opr_instr1_out <= opr3(i1);
                                wr_opr1_instr1 <= opr3_prf(i1);
                                imm16_instr1_out <= imm16(i1);
                                rr1_instr1 <= opr1_prf(i1);
                                rr2_instr1 <= opr2_prf(i1);
                                c_instr1_in <= c1(i1);
                                c_instr1_out <= c2(i1);
                                z_instr1_in <= z1(i1);
                                z_instr1_out <= z2(i1);
                            else
                                p1 := '0';
                            end if;
                            
                        elsif((opcode(i1) = "0000")) then
                            if(valid_opr1(i1) = '1') then
                                p1 := '1';
										  op_instr1_out <= opcode(i1);
                                op_instr1_out <= opcode(i1);
                                wr_opr_instr1_out <= opr3(i1);
                                wr_opr1_instr1 <= opr3_prf(i1);
                                imm16_instr1_out <= imm16(i1);
                                rr1_instr1 <= opr1_prf(i1);
                                --rr2_instr1 <= opr2_prf(i1);
                                --c_instr_in <= c1(i1);
                                c_instr1_out <= c2(i1);
                                --z_instr_in <= z1(i1);
                                z_instr1_out <= z2(i1);
                            else 
                                p1 := '0';
                            end if;
                        elsif(opcode(i1) = "0011") then
                            p1 := '1';
									 op_instr1_out <= opcode(i1);
                            imm16_instr1_out <= imm16(i1);
                            wr_opr_instr1_out <= opr3(i1);
                            wr_opr1_instr1 <= opr3_prf(i1);
                        elsif(opcode(i1) = "0100") then
                            if(valid_opr1(i1) = '1') then
                                p1 := '1';
										  op_instr1_out <= opcode(i1);
                                imm16_instr1_out <= imm16(i1);
                                wr_opr_instr1_out <= opr3(i1);
                                wr_opr1_instr1 <= opr3_prf(i1);
                                rr1_instr1 <= opr1_prf(i1);
                            else 
                                p1 := '0';
                            end if;
                        elsif(opcode(i1) = "0101") then
                            if(valid_opr1(i1) = '1' and valid_opr2(i1) = '1') then
                                p1 := '1';
										  op_instr1_out <= opcode(i1);
                                imm16_instr1_out <= imm16(i1);
                                rr1_instr1 <= opr1_prf(i1);
                                rr2_instr1 <= opr2_prf(i1);
                            else 
                                p1 := '0';
                            end if;
                        elsif(opcode(i1) = "1000" or opcode(i1) = "1001" or opcode(i1) = "1010") then
                            if(valid_opr1(i1) = '1' and valid_opr2(i1) = '1') then
                                p1 := '1';
										  op_instr1_out <= opcode(i1);
                                rr1_instr1 <= opr1_prf(i1);
                                rr2_instr1 <= opr2_prf(i1);
                                pc_instr1_out <= pc(i1);
                                imm16_instr1_out <= imm16(i1);
                            else 
                                p1 := '0';
                            end if;
                        elsif(opcode(i1) = "1100") then
                            p1 := '1';
									 op_instr1_out <= opcode(i1);
                            wr_opr_instr1_out <= opr3(i1);
                            wr_opr1_instr1 <= opr3_prf(i1);
                            pc_instr1_out <= pc(i1);
                            imm16_instr1_out <= imm16(i1);
                        elsif(opcode(i1) = "1101") then
                            if(valid_opr1(i1) = '1') then
                                p1 := '1';
										  op_instr1_out <= opcode(i1);
                                wr_opr_instr1_out <= opr3(i1);
                                wr_opr1_instr1 <= opr3_prf(i1);
                                rr1_instr1 <= opr1_prf(i1);
                                pc_instr1_out <= pc(i1);
                            else 
                                p1 := '0';
                            end if;
                        elsif(opcode(i1) = "1111") then
                            if(valid_opr1(i1) = '1') then
                                p1 := '1';
										  op_instr1_out <= opcode(i1);
                                rr1_instr1 <= opr1_prf(i1);
                                imm16_instr1_out <= imm16(i1);
                            else 
                                p1 := '0';
                            end if;
                        else
                            p1 := '0';
                        end if;
                    end if;
                    if(instr(i2) = '1') then
                        if(p1 = '0') then
                            if((opcode(i2) = "0001" or opcode(i2) = "0010")) then
                                if(valid_opr1(i2) = '1' and valid_opr2(i2) = '1' and valid_c(i2) = '1' and valid_z(i2) = '1') then
                                    p1 := '1';
                                    op_instr1_out <= opcode(i2);
                                    wr_opr_instr1_out <= opr3(i2);
                                    wr_opr1_instr1 <= opr3_prf(i2);
                                    imm16_instr1_out <= imm16(i2);
                                    rr1_instr1 <= opr1_prf(i2);
                                    rr2_instr1 <= opr2_prf(i2);
                                    c_instr1_in <= c1(i2);
                                    c_instr1_out <= c2(i2);
                                    z_instr1_in <= z1(i2);
                                    z_instr1_out <= z2(i2);
                                else
                                    p1 := '0';
                                end if;
                                
                            elsif((opcode(i2) = "0000")) then
                                if(valid_opr1(i2) = '1') then
                                    p1 := '1';
                                    op_instr1_out <= opcode(i2);
                                    wr_opr_instr1_out <= opr3(i2);
                                    wr_opr1_instr1 <= opr3_prf(i2);
                                    imm16_instr1_out <= imm16(i2);
                                    rr1_instr1 <= opr1_prf(i2);
                                    --rr2_instr1 <= opr2_prf(i2);
                                    --c_instr_in <= c1(i2);
                                    c_instr1_out <= c2(i2);
                                    --z_instr_in <= z1(i2);
                                    z_instr1_out <= z2(i2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(i2) = "0011") then
                                p1 := '1';
										  op_instr1_out <= opcode(i2);
                                imm16_instr1_out <= imm16(i2);
                                wr_opr_instr1_out <= opr3(i2);
                                wr_opr1_instr1 <= opr3_prf(i2);
                            elsif(opcode(i2) = "0100") then
                                if(valid_opr1(i2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(i2);
                                    imm16_instr1_out <= imm16(i2);
                                    wr_opr_instr1_out <= opr3(i2);
                                    wr_opr1_instr1 <= opr3_prf(i2);
                                    rr1_instr1 <= opr1_prf(i2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(i2) = "0101") then
                                if(valid_opr1(i2) = '1' and valid_opr2(i2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(i2);
                                    imm16_instr1_out <= imm16(i2);
                                    rr1_instr1 <= opr1_prf(i2);
                                    rr2_instr1 <= opr2_prf(i2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(i2) = "1000" or opcode(i2) = "1001" or opcode(i2) = "1010") then
                                if(valid_opr1(i2) = '1' and valid_opr2(i2) = '1') then
                                    p1 := '1';
                                    rr1_instr1 <= opr1_prf(i2);
                                    rr2_instr1 <= opr2_prf(i2);
                                    pc_instr1_out <= pc(i2);
                                    imm16_instr1_out <= imm16(i2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(i2) = "1100") then
                                p1 := '1';
                                wr_opr_instr1_out <= opr3(i2);
                                wr_opr1_instr1 <= opr3_prf(i2);
                                pc_instr1_out <= pc(i2);
                                imm16_instr1_out <= imm16(i2);
                            elsif(opcode(i2) = "1101") then
                                if(valid_opr1(i2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(i2);
                                    wr_opr_instr1_out <= opr3(i2);
                                    wr_opr1_instr1 <= opr3_prf(i2);
                                    rr1_instr1 <= opr1_prf(i2);
                                    pc_instr1_out <= pc(i2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(i2) = "1111") then
                                if(valid_opr1(i2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(i2);
                                    rr1_instr1 <= opr1_prf(i2);
                                    imm16_instr1_out <= imm16(i2);
                                else 
                                    p1 := '0';
                                end if;
                            else
                                p1 := '0';
                            end if;
                        else
                            if((opcode(i2) = "0001" or opcode(i2) = "0010")) then
                                if(valid_opr1(i2) = '1' and valid_opr2(i2) = '1' and valid_c(i2) = '1' and valid_z(i2) = '1') then
                                    p2 := '1';
                                    op_instr2_out <= opcode(i2);
                                    wr_opr_instr2_out <= opr3(i2);
                                    wr_opr1_instr2 <= opr3_prf(i2);
                                    imm16_instr2_out <= imm16(i2);
                                    rr1_instr2 <= opr1_prf(i2);
                                    rr2_instr2 <= opr2_prf(i2);
                                    c_instr2_in <= c1(i2);
                                    c_instr2_out <= c2(i2);
                                    z_instr2_in <= z1(i2);
                                    z_instr2_out <= z2(i2);
                                else
                                    p2 := '0';
                                end if;
                                
                            elsif((opcode(i2) = "0000")) then
                                if(valid_opr1(i2) = '1') then
                                    p2 := '1';
                                    op_instr2_out <= opcode(i2);
                                    wr_opr_instr2_out <= opr3(i2);
                                    wr_opr1_instr2 <= opr3_prf(i2);
                                    imm16_instr2_out <= imm16(i2);
                                    rr1_instr2 <= opr1_prf(i2);
                                    --rr2_instr1 <= opr2_prf(i2);
                                    --c_instr_in <= c1(i2);
                                    c_instr2_out <= c2(i2);
                                    --z_instr_in <= z1(i2);
                                    z_instr2_out <= z2(i2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(i2) = "0011") then
                                p2 := '1';
										  op_instr2_out <= opcode(i2);
                                imm16_instr2_out <= imm16(i2);
                                wr_opr_instr2_out <= opr3(i2);
                                wr_opr1_instr2 <= opr3_prf(i2);
                            elsif(opcode(i2) = "0100") then
                                if(valid_opr1(i2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(i2);
                                    imm16_instr2_out <= imm16(i2);
                                    wr_opr_instr2_out <= opr3(i2);
                                    wr_opr1_instr2 <= opr3_prf(i2);
                                    rr1_instr2 <= opr1_prf(i2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(i2) = "0101") then
                                if(valid_opr1(i2) = '1' and valid_opr2(i2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(i2);
                                    imm16_instr2_out <= imm16(i2);
                                    rr1_instr2 <= opr1_prf(i2);
                                    rr2_instr2 <= opr2_prf(i2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(i2) = "1000" or opcode(i2) = "1001" or opcode(i2) = "1010") then
                                if(valid_opr1(i2) = '1' and valid_opr2(i2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(i2);
                                    rr1_instr2 <= opr1_prf(i2);
                                    rr2_instr2 <= opr2_prf(i2);
                                    pc_instr2_out <= pc(i2);
                                    imm16_instr2_out <= imm16(i2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(i2) = "1100") then
                                p2 := '1';
										  op_instr2_out <= opcode(i2);
                                wr_opr_instr2_out <= opr3(i2);
                                wr_opr1_instr2 <= opr3_prf(i2);
                                pc_instr2_out <= pc(i2);
                                imm16_instr2_out <= imm16(i2);
                            elsif(opcode(i2) = "1101") then
                                if(valid_opr1(i2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(i2);
                                    wr_opr_instr2_out <= opr3(i2);
                                    wr_opr1_instr2 <= opr3_prf(i2);
                                    rr1_instr2 <= opr1_prf(i2);
                                    pc_instr2_out <= pc(i2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(i2) = "1111") then
                                if(valid_opr1(i2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(i2);
                                    rr1_instr1 <= opr1_prf(i2);
                                    imm16_instr1_out <= imm16(i2);
                                else 
                                    p2 := '0';
                                end if;
                            else
                                p2 := '0';
                            end if;
                        end if;
                    end if;

                    if(instr(x1) = '1') then
                        if(p1 = '0' and p2 = '0') then
                            if((opcode(x1) = "0001" or opcode(x1) = "0010")) then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1' and valid_c(x1) = '1' and valid_z(x1) = '1') then
                                    p1 := '1';
                                    op_instr1_out <= opcode(x1);
                                    wr_opr_instr1_out <= opr3(x1);
                                    wr_opr1_instr1 <= opr3_prf(x1);
                                    imm16_instr1_out <= imm16(x1);
                                    rr1_instr1 <= opr1_prf(x1);
                                    rr2_instr1 <= opr2_prf(x1);
                                    c_instr1_in <= c1(x1);
                                    c_instr1_out <= c2(x1);
                                    z_instr1_in <= z1(x1);
                                    z_instr1_out <= z2(x1);
                                else
                                    p1 := '0';
                                end if;
                                
                            elsif((opcode(x1) = "0000")) then
                                if(valid_opr1(x1) = '1') then
                                    p1 := '1';
                                    op_instr1_out <= opcode(x1);
                                    wr_opr_instr1_out <= opr3(x1);
                                    wr_opr1_instr1 <= opr3_prf(x1);
                                    imm16_instr1_out <= imm16(x1);
                                    rr1_instr1 <= opr1_prf(x1);
                                    --rr2_instr1 <= opr2_prf(x1);
                                    --c_instr_in <= c1(x1);
                                    c_instr1_out <= c2(x1);
                                    --z_instr_in <= z1(x1);
                                    z_instr1_out <= z2(x1);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x1) = "0011") then
                                p1 := '1';
										  op_instr1_out <= opcode(x1);
                                imm16_instr1_out <= imm16(x1);
                                wr_opr_instr1_out <= opr3(x1);
                                wr_opr1_instr1 <= opr3_prf(x1);
                            elsif(opcode(x1) = "0100") then
                                if(valid_opr1(x1) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x1);
                                    imm16_instr1_out <= imm16(x1);
                                    wr_opr_instr1_out <= opr3(x1);
                                    wr_opr1_instr1 <= opr3_prf(x1);
                                    rr1_instr1 <= opr1_prf(x1);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x1) = "0101") then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x1);
                                    imm16_instr1_out <= imm16(x1);
                                    rr1_instr1 <= opr1_prf(x1);
                                    rr2_instr1 <= opr2_prf(x1);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x1) = "1000" or opcode(x1) = "1001" or opcode(x1) = "1010") then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x1);
                                    rr1_instr1 <= opr1_prf(x1);
                                    rr2_instr1 <= opr2_prf(x1);
                                    pc_instr1_out <= pc(x1);
                                    imm16_instr1_out <= imm16(x1);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x1) = "1100") then
                                p1 := '1';
										  op_instr1_out <= opcode(x1);
                                wr_opr_instr1_out <= opr3(x1);
                                wr_opr1_instr1 <= opr3_prf(x1);
                                pc_instr1_out <= pc(x1);
                                imm16_instr1_out <= imm16(x1);
                            elsif(opcode(x1) = "1101") then
                                if(valid_opr1(x1) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x1);
                                    wr_opr_instr1_out <= opr3(x1);
                                    wr_opr1_instr1 <= opr3_prf(x1);
                                    rr1_instr1 <= opr1_prf(x1);
                                    pc_instr1_out <= pc(x1);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x1) = "1111") then
                                if(valid_opr1(x1) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x1);
                                    rr1_instr1 <= opr1_prf(x1);
                                    imm16_instr1_out <= imm16(x1);
                                else 
                                    p1 := '0';
                                end if;
                            else
                                p1 := '0';
                            end if;
                        elsif(p1 = '1' and p2 = '0') then
                            if((opcode(x1) = "0001" or opcode(x1) = "0010")) then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1' and valid_c(x1) = '1' and valid_z(x1) = '1') then
                                    p2 := '1';
                                    op_instr2_out <= opcode(x1);
                                    wr_opr_instr2_out <= opr3(x1);
                                    wr_opr1_instr2 <= opr3_prf(x1);
                                    imm16_instr2_out <= imm16(x1);
                                    rr1_instr2 <= opr1_prf(x1);
                                    rr2_instr2 <= opr2_prf(x1);
                                    c_instr2_in <= c1(x1);
                                    c_instr2_out <= c2(x1);
                                    z_instr2_in <= z1(x1);
                                    z_instr2_out <= z2(x1);
                                else
                                    p2 := '0';
                                end if;
                                
                            elsif((opcode(x1) = "0000")) then
                                if(valid_opr1(x1) = '1') then
                                    p2 := '1';
                                    op_instr2_out <= opcode(x1);
                                    wr_opr_instr2_out <= opr3(x1);
                                    wr_opr1_instr2 <= opr3_prf(x1);
                                    imm16_instr2_out <= imm16(x1);
                                    rr1_instr2 <= opr1_prf(x1);
                                    --rr2_instr1 <= opr2_prf(x1);
                                    --c_instr_in <= c1(x1);
                                    c_instr2_out <= c2(x1);
                                    --z_instr_in <= z1(x1);
                                    z_instr2_out <= z2(x1);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x1) = "0011") then
                                p2 := '1';
										  op_instr2_out <= opcode(x1);
                                imm16_instr2_out <= imm16(x1);
                                wr_opr_instr2_out <= opr3(x1);
                                wr_opr1_instr2 <= opr3_prf(x1);
                            elsif(opcode(x1) = "0100") then
                                if(valid_opr1(x1) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x1);
                                    imm16_instr2_out <= imm16(x1);
                                    wr_opr_instr2_out <= opr3(x1);
                                    wr_opr1_instr2 <= opr3_prf(x1);
                                    rr1_instr2 <= opr1_prf(x1);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x1) = "0101") then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x1);
                                    imm16_instr2_out <= imm16(x1);
                                    rr1_instr2 <= opr1_prf(x1);
                                    rr2_instr2 <= opr2_prf(x1);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x1) = "1000" or opcode(x1) = "1001" or opcode(x1) = "1010") then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x1);
                                    rr1_instr2 <= opr1_prf(x1);
                                    rr2_instr2 <= opr2_prf(x1);
                                    pc_instr2_out <= pc(x1);
                                    imm16_instr2_out <= imm16(x1);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x1) = "1100") then
                                p2 := '1';
										  op_instr2_out <= opcode(x1);
                                wr_opr_instr2_out <= opr3(x1);
                                wr_opr1_instr2 <= opr3_prf(x1);
                                pc_instr2_out <= pc(x1);
                                imm16_instr2_out <= imm16(x1);
                            elsif(opcode(x1) = "1101") then
                                if(valid_opr1(x1) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x1);
                                    wr_opr_instr2_out <= opr3(x1);
                                    wr_opr1_instr2 <= opr3_prf(x1);
                                    rr1_instr2 <= opr1_prf(x1);
                                    pc_instr2_out <= pc(x1);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x1) = "1111") then
                                if(valid_opr1(x1) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x1);
                                    rr1_instr1 <= opr1_prf(x1);
                                    imm16_instr1_out <= imm16(x1);
                                else 
                                    p2 := '0';
                                end if;
                            else
                                p2 := '0';
                            end if;
                        else
                            if((opcode(x1) = "0001" or opcode(x1) = "0010")) then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1' and valid_c(x1) = '1' and valid_z(x1) = '1') then
                                    p3 := '1';
                                    op_instr3_out <= opcode(x1);
                                    wr_opr_instr3_out <= opr3(x1);
                                    wr_opr1_instr3 <= opr3_prf(x1);
                                    imm16_instr3_out <= imm16(x1);
                                    rr1_instr3 <= opr1_prf(x1);
                                    rr2_instr3 <= opr2_prf(x1);
                                    c_instr3_in <= c1(x1);
                                    c_instr3_out <= c2(x1);
                                    z_instr3_in <= z1(x1);
                                    z_instr3_out <= z2(x1);
                                else
                                    p3 := '0';
                                end if;
                                
                            elsif((opcode(x1) = "0000")) then
                                if(valid_opr1(x1) = '1') then
                                    p3 := '1';
                                    op_instr3_out <= opcode(x1);
                                    wr_opr_instr3_out <= opr3(x1);
                                    wr_opr1_instr3 <= opr3_prf(x1);
                                    imm16_instr3_out <= imm16(x1);
                                    rr1_instr3 <= opr1_prf(x1);
                                    --rr2_instr1 <= opr2_prf(x1);
                                    --c_instr_in <= c1(x1);
                                    c_instr3_out <= c2(x1);
                                    --z_instr_in <= z1(x1);
                                    z_instr3_out <= z2(x1);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x1) = "0011") then
                                p3 := '1';
										  op_instr3_out <= opcode(x1);
                                imm16_instr3_out <= imm16(x1);
                                wr_opr_instr3_out <= opr3(x1);
                                wr_opr1_instr3 <= opr3_prf(x1);
                            elsif(opcode(x1) = "0100") then
                                if(valid_opr1(x1) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x1);
                                    imm16_instr3_out <= imm16(x1);
                                    wr_opr_instr3_out <= opr3(x1);
                                    wr_opr1_instr3 <= opr3_prf(x1);
                                    rr1_instr3 <= opr1_prf(x1);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x1) = "0101") then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x1);
                                    imm16_instr3_out <= imm16(x1);
                                    rr1_instr3 <= opr1_prf(x1);
                                    rr2_instr3 <= opr2_prf(x1);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x1) = "1000" or opcode(x1) = "1001" or opcode(x1) = "1010") then
                                if(valid_opr1(x1) = '1' and valid_opr2(x1) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x1);
                                    rr1_instr3 <= opr1_prf(x1);
                                    rr2_instr3 <= opr2_prf(x1);
                                    pc_instr3_out <= pc(x1);
                                    imm16_instr3_out <= imm16(x1);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x1) = "1100") then
                                p3 := '1';
										  op_instr3_out <= opcode(x1);
                                wr_opr_instr3_out <= opr3(x1);
                                wr_opr1_instr3 <= opr3_prf(x1);
                                pc_instr3_out <= pc(x1);
                                imm16_instr3_out <= imm16(x1);
                            elsif(opcode(x1) = "1101") then
                                if(valid_opr1(x1) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x1);
                                    wr_opr_instr3_out <= opr3(x1);
                                    wr_opr1_instr3 <= opr3_prf(x1);
                                    rr1_instr3 <= opr1_prf(x1);
                                    pc_instr3_out <= pc(x1);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x1) = "1111") then
                                if(valid_opr1(x1) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x1);
                                    rr1_instr3 <= opr1_prf(x1);
                                    imm16_instr3_out <= imm16(x1);
                                else 
                                    p3 := '0';
                                end if;
                            else
                                p3 := '0';
                            end if;
                        end if;
                    end if;

                    if(instr(x2) = '1') then
                        if(p1 = '0' and p2 = '0' and p3 = '0') then
                            if((opcode(x1) = "0001" or opcode(x2) = "0010")) then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1' and valid_c(x2) = '1' and valid_z(x2) = '1') then
                                    p1 := '1';
                                    op_instr1_out <= opcode(x2);
                                    wr_opr_instr1_out <= opr3(x2);
                                    wr_opr1_instr1 <= opr3_prf(x2);
                                    imm16_instr1_out <= imm16(x2);
                                    rr1_instr1 <= opr1_prf(x2);
                                    rr2_instr1 <= opr2_prf(x2);
                                    c_instr1_in <= c1(x2);
                                    c_instr1_out <= c2(x2);
                                    z_instr1_in <= z1(x2);
                                    z_instr1_out <= z2(x2);
                                else
                                    p1 := '0';
                                end if;
                                
                            elsif((opcode(x2) = "0000")) then
                                if(valid_opr1(x2) = '1') then
                                    p1 := '1';
                                    op_instr1_out <= opcode(x2);
                                    wr_opr_instr1_out <= opr3(x2);
                                    wr_opr1_instr1 <= opr3_prf(x2);
                                    imm16_instr1_out <= imm16(x2);
                                    rr1_instr1 <= opr1_prf(x2);
                                    --rr2_instr1 <= opr2_prf(x2);
                                    --c_instr_in <= c1(x2);
                                    c_instr1_out <= c2(x2);
                                    --z_instr_in <= z1(x2);
                                    z_instr1_out <= z2(x2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x2) = "0011") then
                                p1 := '1';
										  op_instr1_out <= opcode(x2);
                                imm16_instr1_out <= imm16(x2);
                                wr_opr_instr1_out <= opr3(x2);
                                wr_opr1_instr1 <= opr3_prf(x2);
                            elsif(opcode(x2) = "0100") then
                                if(valid_opr1(x2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x2);
                                    imm16_instr1_out <= imm16(x2);
                                    wr_opr_instr1_out <= opr3(x2);
                                    wr_opr1_instr1 <= opr3_prf(x2);
                                    rr1_instr1 <= opr1_prf(x2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x2) = "0101") then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x2);
                                    imm16_instr1_out <= imm16(x2);
                                    rr1_instr1 <= opr1_prf(x2);
                                    rr2_instr1 <= opr2_prf(x2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x2) = "1000" or opcode(x2) = "1001" or opcode(x2) = "1010") then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x2);
                                    rr1_instr1 <= opr1_prf(x2);
                                    rr2_instr1 <= opr2_prf(x2);
                                    pc_instr1_out <= pc(x2);
                                    imm16_instr1_out <= imm16(x2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x2) = "1100") then
                                p1 := '1';
										  op_instr1_out <= opcode(x2);
                                wr_opr_instr1_out <= opr3(x2);
                                wr_opr1_instr1 <= opr3_prf(x2);
                                pc_instr1_out <= pc(x2);
                                imm16_instr1_out <= imm16(x2);
                            elsif(opcode(x2) = "1101") then
                                if(valid_opr1(x2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x2);
                                    wr_opr_instr1_out <= opr3(x2);
                                    wr_opr1_instr1 <= opr3_prf(x2);
                                    rr1_instr1 <= opr1_prf(x2);
                                    pc_instr1_out <= pc(x2);
                                else 
                                    p1 := '0';
                                end if;
                            elsif(opcode(x2) = "1111") then
                                if(valid_opr1(x2) = '1') then
                                    p1 := '1';
												op_instr1_out <= opcode(x2);
                                    rr1_instr1 <= opr1_prf(x2);
                                    imm16_instr1_out <= imm16(x2);
                                else 
                                    p1 := '0';
                                end if;
                            else
                                p1 := '0';
                            end if;
                        elsif(p1 = '1' and p2 = '0') then
                            if((opcode(x2) = "0001" or opcode(x2) = "0010")) then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1' and valid_c(x2) = '1' and valid_z(x2) = '1') then
                                    p2 := '1';
                                    op_instr2_out <= opcode(x2);
                                    wr_opr_instr2_out <= opr3(x2);
                                    wr_opr1_instr2 <= opr3_prf(x2);
                                    imm16_instr2_out <= imm16(x2);
                                    rr1_instr2 <= opr1_prf(x2);
                                    rr2_instr2 <= opr2_prf(x2);
                                    c_instr2_in <= c1(x2);
                                    c_instr2_out <= c2(x2);
                                    z_instr2_in <= z1(x2);
                                    z_instr2_out <= z2(x2);
                                else
                                    p2 := '0';
                                end if;
                                
                            elsif((opcode(x2) = "0000")) then
                                if(valid_opr1(x2) = '1') then
                                    p2 := '1';
                                    op_instr2_out <= opcode(x2);
                                    wr_opr_instr2_out <= opr3(x2);
                                    wr_opr1_instr2 <= opr3_prf(x2);
                                    imm16_instr2_out <= imm16(x2);
                                    rr1_instr2 <= opr1_prf(x2);
                                    --rr2_instr1 <= opr2_prf(x2);
                                    --c_instr_in <= c1(x2);
                                    c_instr2_out <= c2(x2);
                                    --z_instr_in <= z1(x2);
                                    z_instr2_out <= z2(x2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x2) = "0011") then
                                p2 := '1';
										  op_instr2_out <= opcode(x2);
                                imm16_instr2_out <= imm16(x2);
                                wr_opr_instr2_out <= opr3(x2);
                                wr_opr1_instr2 <= opr3_prf(x2);
                            elsif(opcode(x2) = "0100") then
                                if(valid_opr1(x2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x2);
                                    imm16_instr2_out <= imm16(x2);
                                    wr_opr_instr2_out <= opr3(x2);
                                    wr_opr1_instr2 <= opr3_prf(x2);
                                    rr1_instr2 <= opr1_prf(x2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x2) = "0101") then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x2);
                                    imm16_instr2_out <= imm16(x2);
                                    rr1_instr2 <= opr1_prf(x2);
                                    rr2_instr2 <= opr2_prf(x2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x2) = "1000" or opcode(x2) = "1001" or opcode(x2) = "1010") then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x2);
                                    rr1_instr2 <= opr1_prf(x2);
                                    rr2_instr2 <= opr2_prf(x2);
                                    pc_instr2_out <= pc(x2);
                                    imm16_instr2_out <= imm16(x2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x2) = "1100") then
                                p2 := '1';
										  op_instr2_out <= opcode(x2);
                                wr_opr_instr2_out <= opr3(x2);
                                wr_opr1_instr2 <= opr3_prf(x2);
                                pc_instr2_out <= pc(x2);
                                imm16_instr2_out <= imm16(x2);
                            elsif(opcode(x2) = "1101") then
                                if(valid_opr1(x2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x2);
                                    wr_opr_instr2_out <= opr3(x2);
                                    wr_opr1_instr2 <= opr3_prf(x2);
                                    rr1_instr2 <= opr1_prf(x2);
                                    pc_instr2_out <= pc(x2);
                                else 
                                    p2 := '0';
                                end if;
                            elsif(opcode(x2) = "1111") then
                                if(valid_opr1(x2) = '1') then
                                    p2 := '1';
												op_instr2_out <= opcode(x2);
                                    rr1_instr1 <= opr1_prf(x2);
                                    imm16_instr1_out <= imm16(x2);
                                else 
                                    p2 := '0';
                                end if;
                            else
                                p2 := '0';
                            end if;
                        else
                            if((opcode(x2) = "0001" or opcode(x2) = "0010")) then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1' and valid_c(x2) = '1' and valid_z(x2) = '1') then
                                    p3 := '1';
                                    op_instr3_out <= opcode(x2);
                                    wr_opr_instr3_out <= opr3(x2);
                                    wr_opr1_instr3 <= opr3_prf(x2);
                                    imm16_instr3_out <= imm16(x2);
                                    rr1_instr3 <= opr1_prf(x2);
                                    rr2_instr3 <= opr2_prf(x2);
                                    c_instr3_in <= c1(x2);
                                    c_instr3_out <= c2(x2);
                                    z_instr3_in <= z1(x2);
                                    z_instr3_out <= z2(x2);
                                else
                                    p3 := '0';
                                end if;
                                
                            elsif((opcode(x2) = "0000")) then
                                if(valid_opr1(x2) = '1') then
                                    p3 := '1';
                                    op_instr3_out <= opcode(x2);
                                    wr_opr_instr3_out <= opr3(x2);
                                    wr_opr1_instr3 <= opr3_prf(x2);
                                    imm16_instr3_out <= imm16(x2);
                                    rr1_instr3 <= opr1_prf(x2);
                                    --rr2_instr1 <= opr2_prf(x2);
                                    --c_instr_in <= c1(x2);
                                    c_instr3_out <= c2(x2);
                                    --z_instr_in <= z1(x2);
                                    z_instr3_out <= z2(x2);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x2) = "0011") then
                                p3 := '1';
										  op_instr3_out <= opcode(x2);
                                imm16_instr3_out <= imm16(x2);
                                wr_opr_instr3_out <= opr3(x2);
                                wr_opr1_instr3 <= opr3_prf(x2);
                            elsif(opcode(x2) = "0100") then
                                if(valid_opr1(x2) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x2);
                                    imm16_instr3_out <= imm16(x2);
                                    wr_opr_instr3_out <= opr3(x2);
                                    wr_opr1_instr3 <= opr3_prf(x2);
                                    rr1_instr3 <= opr1_prf(x2);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x2) = "0101") then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x2);
                                    imm16_instr3_out <= imm16(x2);
                                    rr1_instr3 <= opr1_prf(x2);
                                    rr2_instr3 <= opr2_prf(x2);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x2) = "1000" or opcode(x2) = "1001" or opcode(x2) = "1010") then
                                if(valid_opr1(x2) = '1' and valid_opr2(x2) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x2);
                                    rr1_instr3 <= opr1_prf(x2);
                                    rr2_instr3 <= opr2_prf(x2);
                                    pc_instr3_out <= pc(x2);
                                    imm16_instr3_out <= imm16(x2);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x2) = "1100") then
                                p3 := '1';
										  op_instr3_out <= opcode(x2);
                                wr_opr_instr3_out <= opr3(x2);
                                wr_opr1_instr3 <= opr3_prf(x2);
                                pc_instr3_out <= pc(x2);
                                imm16_instr3_out <= imm16(x2);
                            elsif(opcode(x2) = "1101") then
                                if(valid_opr1(x2) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x2);
                                    wr_opr_instr3_out <= opr3(x2);
                                    wr_opr1_instr3 <= opr3_prf(x2);
                                    rr1_instr3 <= opr1_prf(x2);
                                    pc_instr3_out <= pc(x2);
                                else 
                                    p3 := '0';
                                end if;
                            elsif(opcode(x2) = "1111") then
                                if(valid_opr1(x2) = '1') then
                                    p3 := '1';
												op_instr3_out <= opcode(x2);
                                    rr1_instr3 <= opr1_prf(x2);
                                    imm16_instr3_out <= imm16(x2);
                                else 
                                    p3 := '0';
                                end if;
                            else
                                p3 := '0';
                            end if;
                        end if;
                    end if;
						  en1 <= p1;
						  en2 <= p2;
						  en3 <= p3;
					 end if;
				 end process;
					 
					 
            stall1 <= stall_full1 or stall_rat1 or stall_crat1 or stall_zrat1;
            stall2 <= stall_full2 or stall_rat2 or stall_crat2 or stall_zrat2;

end design;