----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:24:18 11/16/2017 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library basic;
use basic.helper.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    port (
        clk : in std_logic;
        rst : in std_logic;

        -- ram1, Instruction memory
        data_ram1 : inout std_logic_vector(15 downto 0);
        addr_ram1 : out std_logic_vector(17 downto 0);
        OE_ram1   : out std_logic;
        WE_ram1   : out std_logic;
        EN_ram1   : out std_logic;

        -- ram2, Data memory
        data_ram2 : inout std_logic_vector(15 downto 0);
        addr_ram2 : out std_logic_vector(17 downto 0);
        OE_ram2   : out std_logic := '1';
        WE_ram2   : out std_logic := '1';
        EN_ram2   : out std_logic := '1';

        -- serial
        seri_rdn        : out std_logic := '1';
        seri_wrn        : out std_logic := '1';
        seri_data_ready : in std_logic;
        seri_tbre       : in std_logic;
        seri_tsre       : in std_logic;

        --digits
        dyp0            : out  STD_LOGIC_VECTOR (6 downto 0) := "1111111";
        dyp1            : out  STD_LOGIC_VECTOR (6 downto 0) := "1111111";
        -- led
        led : out std_logic_vector(15 downto 0);

        -- DEBUG variables
		  -- feed in instruct
        instruct : in std_logic_vector (15 downto 0);
        --dbg_ex_reg_a, dbg_ex_reg_b	: out std_logic_vector(15 downto 0)
    );
end cpu;

architecture Behavioral of cpu is
    -- register
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := zero16;
    signal SP, IH : std_logic_vector(15 downto 0) := zero16;
    signal T : std_logic := '0';
    -- pc
    signal pc                              : std_logic_vector (15 downto 0) := zero16;
    signal pc_real                         : std_logic_vector (15 downto 0) := zero16;
    -- help signal
	 
    -- IF/ID pipeline storage
    signal ifid_instruc                    : std_logic_vector (15 downto 0) := zero16;
    -- NOTICE: What's this?
    signal id_pc_branch                    : std_logic                      := '0';
    signal id_branch_value                 : std_logic_vector (15 downto 0) := zero16;
	
    -- Control Unit
--    signal ctrl_id_write_reg            : std_logic_vector (1 downto 0)  := "00";
--    signal ctrl_ex_alu_reg_a            : std_logic_vector (2 downto 0)  := "000";
--    signal ctrl_ex_alu_reg_b            : std_logic_vector (2 downto 0)  := "000"; 
--    signal ctrl_ex_alu_op               : std_logic_vector (4 downto 0)  := "00000";
--    signal ctrl_me_branch               : std_logic                      := '0';
--    signal ctrl_me_wb                   : std_logic_vector (2 downto 0)  := "000";

    -- ID/EX
    signal idex_ins_op                     : std_logic_vector (4 downto 0)  := zero5;
    signal idex_reg_a_data                 : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_b_data                 : std_logic_vector (15 downto 0) := zero16;
    -- What's this?
    signal idex_bypass                     : std_logic_vector (15 downto 0)  := zero16;
    signal idex_reg_wb                     : std_logic_vector (3 downto 0)  := "0000";
    
    -- EX layer variables
    signal ex_reg_a_data, ex_reg_b_data    : std_logic_vector (15 downto 0) := zero16;
    signal ex_alu_op                       : std_logic_vector (3 downto 0)  := "0000";
    signal ex_alu_output                   : std_logic_vector (15 downto 0) := zero16;
    
    -- EX/MEM pipeline storage
    signal exme_ins_op                     : std_logic_vector (4 downto 0)  := zero5;
	 -- NOTICE: carry and overflow is not required
    signal exme_carry, exme_zero, exme_ovr : std_logic                      := '0';
    signal exme_result                     : std_logic_vector (15 downto 0) := zero16;
    signal exme_reg_wb                     : std_logic_vector (3 downto 0)  := "0000";
    signal exme_bypass                     : std_logic_vector (15 downto 0) := zero16;
    
    -- MEM variables
    signal me_read_enable, me_write_enable : std_logic                      := '0';
    signal me_write_enable_real            : std_logic                      := '0';
    signal me_read_addr, me_write_addr     : std_logic_vector (17 downto 0) := zero18;
    signal me_write_data                   : std_logic_vector (15 downto 0) := zero16;
    
    --MEM/WB pipeline storage
    signal mewb_ins_op                     : std_logic_vector (4 downto 0)  := zero5;
    signal mewb_result                     : std_logic_vector (15 downto 0) := zero16;
    signal mewb_readout                    : std_logic_vector (15 downto 0) := zero16;
    signal mewb_reg_wb                     : std_logic_vector (3 downto 0)  := "0000";
    signal mewb_bypass                     : std_logic_vector (15 downto 0) := zero16;

    -- component
    component alu is
        port (
            rst                             : in std_logic;
            reg_a, reg_b                    : in std_logic_vector(15 downto 0);
            alu_op                          : in std_logic_vector(3 downto 0);
            result                          : out std_logic_vector(15 downto 0);
            carry_flag, zero_flag, ovr_flag : out std_logic
        );
    end component alu;
begin
	-- DEBUG
--	dbg_ex_reg_a <= ex_reg_a;
--	dbg_ex_reg_b <= ex_reg_b;


    ------------- Memory Control Unit, pure combinational logic
    me_write_enable_real <= '0' when (rst = '0') else (me_write_enable and clk);

    EN_ram1 <= '1' when (rst = '0') else '0';
    WE_ram1 <= '1' when (rst = '0') else
               '0' when (me_write_enable_real = '1') else
               '1' when (me_read_enable = '1') else '1';
    OE_ram1 <= '1' when (rst = '0') else
               '0' when (me_read_enable = '1') else
               '1' when (me_write_enable = '1') else '0';
    addr_ram1 <= zero18 when(rst = '0') else
                 me_read_addr when (me_read_enable = '1') else
                 me_write_addr when (me_write_enable = '1') else
                 "00" & pc_real;
    data_ram1 <= me_write_data when (me_write_enable_real = '1') else "ZZZZZZZZZZZZZZZZ";
    mewb_readout <= data_ram1 when (me_read_enable = '1') else "ZZZZZZZZZZZZZZZZ";
    -- if MEM is using SRAM, insert a NOP into pipeline
    --ifid_instruc <= data_ram1 when ((me_read_enable = '0') and (me_write_enable = '0')) else "000010000000000000";

    ifid_instruc <= instruct;

    ---------------- IF --------------------------
    IF_unit: process(clk, rst)
    begin
        if (rst = '0') then
            pc <= zero16;
        elsif ( clk'event and clk='1' ) then
            -- TODO: the update of PC has 3 ways
            -- (1) pc <= pc + 1; (2) JR (3) BEQZ
            pc <= pc_real + 1;
        end if;
    end process IF_unit;
    
    -- mux for real pc
    pc_real <= id_branch_value when (id_pc_branch = '1') else pc;


    ---------------- ID --------------------------
    ID_unit: process(clk, rst)
    begin
        if (clk'event and clk='1') then
            idex_ins_op <= ifid_instruc(15 downto 11);
            id_pc_branch <= '0';
            case ifid_instruc(15 downto 11) is
                when ADDU_op =>
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- ry value
                    reg_decode(idex_reg_b_data, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- write back register index
                    idex_reg_wb <= "0" & ifid_instruc(4 downto 2);
                when ADDIU_op =>
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate value, put into reg_b
                    idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                    -- write back register index
                    idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                when SLL_op =>
                    -- ry value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate zero extend
                    if (ifid_instruc(4 downto 2) = "000") then
                        idex_reg_b_data <= "0000000000001000";
                    else
                        idex_reg_b_data <= zero_extend3(ifid_instruc(4 downto 2));
                          end if;
                    -- write back rx register
                    idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                when LI_op =>
                    -- immediate value, zero extend, put into register A
                    idex_reg_a_data <= zero_extend8(ifid_instruc(7 downto 0));
                    idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                when LW_op =>
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate sign extend
                    idex_reg_b_data <= sign_extend5(ifid_instruc(4 downto 0));
                    -- write back ry register
                    idex_reg_wb <= "0" & ifid_instruc(7 downto 5);
                when SW_op =>
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate sign extend
                    idex_reg_b_data <= sign_extend5(ifid_instruc(4 downto 0));
                    -- ry value
                    reg_decode(idex_bypass, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                when BNEZ_op =>
                    id_pc_branch <= '1';
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate sign extend
                    idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                when others =>
                    idex_reg_a_data <= zero16;
                    idex_reg_b_data <= zero16;
                    idex_reg_wb <= "0000";
            end case;
        end if;
    end process ID_unit;

    -- combination logic multiplexer unit for branch
    process(pc, idex_reg_b_data, idex_reg_a_data)
    begin
        case ifid_instruc(15 downto 11) is
            when BNEZ_op =>
                if (idex_reg_a_data /= zero16) then
                    id_branch_value <= pc - 1 + idex_reg_b_data;
                else
                    id_branch_value <= pc;
                end if;
            when others =>
                id_branch_value <= zero16;
        end case;
    end process;



    ---------------- EX --------------------------
    EX_unit: process(clk, rst)
    begin
        if (rst = '0') then
            exme_ins_op <= zero5;
        elsif (clk'event and clk='1') then
            exme_ins_op <= idex_ins_op;
            case idex_ins_op is
                when ADDU_op | ADDIU_op | LW_op | SW_op =>
                    ex_reg_a_data <= idex_reg_a_data;
                    ex_reg_b_data <= idex_reg_b_data;
                    ex_alu_op <= alu_add;
                    exme_bypass <= idex_bypass;
                    exme_reg_wb <= idex_reg_wb;
                when SLL_op =>
                    ex_reg_a_data <= idex_reg_a_data;
                    ex_reg_b_data <= idex_reg_b_data;
                    ex_alu_op <= alu_sll;
                    exme_reg_wb <= idex_reg_wb;
                when LI_op =>
                    ex_alu_op <= alu_nop;
                    exme_reg_wb <= idex_reg_wb;
                    exme_bypass <= idex_reg_a_data;
                when others =>
                    ex_alu_op <= alu_nop;
            end case;
        end if;
    end process EX_unit;
	 
    -- alu map
    ALU_comp: alu port map (rst, ex_reg_a_data, ex_reg_b_data, ex_alu_op, exme_result,
                                exme_carry, exme_zero, exme_ovr);

    ---------------- ME --------------------------
    ME_unit: process(clk, rst)
    begin
        if (clk'event and clk='1') then
            mewb_ins_op <= exme_ins_op;
            me_read_enable <= '0';
            me_write_enable <= '0';
            case exme_ins_op is
                when ADDU_op | ADDIU_op | SLL_op =>
                    mewb_result <= exme_result;
                    mewb_reg_wb <= exme_reg_wb;
                when LI_op =>
                    mewb_reg_wb <= exme_reg_wb;
                    mewb_bypass <= exme_bypass;
                when LW_op =>
                    mewb_reg_wb <= exme_reg_wb;
                    me_read_addr <= "00" & exme_result;
                    me_read_enable <= '1';
                    me_write_enable <= '0';
                when SW_op =>
                    me_write_addr <= "00" & exme_result;
                    me_write_data <= exme_bypass;
                    me_read_enable <= '0';
                    me_write_enable <= '1';
                when NOP_op =>
                    mewb_ins_op <= NOP_op;
                when others =>
                    mewb_ins_op <= NOP_op;
            end case;
        end if;
    end process ME_unit;

    ---------------- WB --------------------------
    WB_unit: process(clk, rst)
        variable wb_data : std_logic_vector(15 downto 0);
        variable wb_enable : boolean := false;
    begin
        if (clk'event and clk='1') then
            case mewb_ins_op is
                when ADDU_op | ADDIU_op | SLL_op =>
                    wb_data := mewb_result;
                    wb_enable := true;
                when LI_op =>
                    wb_data := mewb_bypass;
                    wb_enable := true;
                when LW_op =>
                    wb_data := mewb_readout;
                    wb_enable := true;
                when NOP_op =>
                    wb_enable := false;
                when others =>
                    wb_enable := false;
            end case;
            if (wb_enable = true) then
                case mewb_reg_wb is
                    when "0000" =>
                        r0 <= wb_data;
                    when "0001" =>
                        r1 <= wb_data;
                    when "0010" =>
                        r2 <= wb_data;
                    when "0011" =>
                        r3 <= wb_data;
                    when "0100" =>
                        r4 <= wb_data;
                    when "0101" =>
                        r5 <= wb_data;
                    when "0110" =>
                        r6 <= wb_data;
                    when "0111" =>
                        r7 <= wb_data;
                    when "1000" =>
                        SP <= wb_data;
                    when "1001" =>
                        IH <= wb_data;
                    when others =>
                end case;
            end if;
        end if;
    end process WB_unit;

    ------------ Control Unit --------------------
    Control_unit: process(clk, rst)
    begin
    end process Control_unit;

    dyp0 <= "0000000";
    dyp1 <= "1111111";
    seri_rdn <= '1';
    seri_wrn <= '1';

    EN_ram2 <= '1';
    OE_ram2 <= '1';
    WE_ram2 <= '1';
    data_ram2 <= "ZZZZZZZZZZZZZZZZ";
    addr_ram2 <= zero18;

    led <= instruct;

end Behavioral;

