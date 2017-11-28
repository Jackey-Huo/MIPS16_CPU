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

        -- feed in instruct
        instruct : in std_logic_vector (15 downto 0)
    );
end cpu;

architecture Behavioral of cpu is
    -- register
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := zero16;
    signal SP, IH, T : std_logic_vector(15 downto 0) := zero16;
    -- pc
    signal pc                              : std_logic_vector (15 downto 0) := zero16;
    signal pc_real                         : std_logic_vector (15 downto 0) := zero16;
    -- help signal
     
    -- IF/ID pipeline storage
    signal ifid_instruc                    : std_logic_vector (15 downto 0) := zero16;
    signal ifid_instruc_mem                : std_logic_vector (15 downto 0) := zero16;
    -- NOTICE: What's this?
    signal id_pc_branch                    : std_logic                      := '0';
    signal id_branch_value                 : std_logic_vector (15 downto 0) := zero16;
    
    -- Control Unit
    signal ctrl_mux_reg_a, ctrl_mux_reg_b  : std_logic_vector (2 downto 0)  := "000";
    signal ctrl_mux_bypass                 : std_logic_vector (2 downto 0)  := "000";
    signal ctrl_insert_bubble              : std_logic                      := '0';

    signal id_instruc                      : std_logic_vector (15 downto 0) := zero16;

    -- ID/EX
    signal idex_instruc                    : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_a_data                 : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_a_data_real            : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_b_data                 : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_b_data_real            : std_logic_vector (15 downto 0) := zero16;
    signal idex_bypass                     : std_logic_vector (15 downto 0) := zero16;
    signal idex_bypass_real                : std_logic_vector (15 downto 0) := zero16;
    signal idex_reg_wb                     : std_logic_vector (3 downto 0)  := "0000";
    
    -- EX layer variables
    signal ex_reg_a_data, ex_reg_b_data    : std_logic_vector (15 downto 0) := zero16;
    signal ex_alu_op                       : std_logic_vector (3 downto 0)  := "0000";
    signal ex_alu_output                   : std_logic_vector (15 downto 0) := zero16;
    
    -- EX/MEM pipeline storage
    signal exme_instruc                    : std_logic_vector (15 downto 0)  := zero16;
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

    signal seri_wrn_t, seri_rdn_t          : std_logic                      := '0';
    signal seri1_read_enable               : std_logic                      := '0';
    signal seri1_write_enable              : std_logic                      := '0';
    signal seri1_write_enable_real         : std_logic                      := '0';

    --MEM/WB pipeline storage
    signal mewb_instruc                    : std_logic_vector (15 downto 0) := zero16;
    signal mewb_result                     : std_logic_vector (15 downto 0) := zero16;
    signal mewb_readout                    : std_logic_vector (15 downto 0) := zero16;
    signal mewb_reg_wb                     : std_logic_vector (3 downto 0)  := "0000";
    signal mewb_bypass                     : std_logic_vector (15 downto 0) := zero16;

    signal wb_reg_data                     : std_logic_vector (15 downto 0) := zero16;

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

    component mux7to1 is
        port (
            output       : out std_logic_vector (15 downto 0) := zero16;
            ctrl_mux     : in std_logic_vector (2 downto 0);
            default_data : in std_logic_vector (15 downto 0);
            alu_result   : in std_logic_vector (15 downto 0);
            mewb_result  : in std_logic_vector (15 downto 0);
            mewb_readout : in std_logic_vector (15 downto 0);
            wb_reg_data  : in std_logic_vector (15 downto 0);
            exme_bypass  : in std_logic_vector (15 downto 0);
            mewb_bypass  : in std_logic_vector (15 downto 0)
        );
    end component mux7to1;

begin

    ------------- Memory and Serial Control Unit, pure combinational logic
    me_write_enable_real <= '0' when (rst = '0') else (me_write_enable and clk);
    seri1_write_enable_real <= '0' when (rst = '0') else (seri1_read_enable and not(clk));

    -- TODO: serial read & write need further implementation, tbre tsre and data_ready not used now
    seri_rdn_t <= '1' when (rst = '0') else
                '0' when (seri1_read_enable = '1') else
                '1';
    seri_rdn <= seri_rdn_t;
    seri_wrn_t <= '1' when (rst = '0') else
                '0' when (seri1_write_enable_real = '1') else
                '1';
    seri_wrn <= seri_rdn_t;

    EN_ram1 <= '1' when ((rst = '0') or (seri1_read_enable = '1') or (seri1_write_enable = '1')) else '0';
    WE_ram1 <= '1' when (rst = '0') else
               '1' when ((seri1_read_enable = '1') or (seri1_write_enable = '1')) else
               '0' when (me_write_enable_real = '1') else
               '1' when (me_read_enable = '1') else '1';
    OE_ram1 <= '1' when (rst = '0') else
               '1' when ((seri1_read_enable = '1') or (seri1_write_enable = '1')) else
               '0' when (me_read_enable = '1') else
               '1' when (me_write_enable = '1') else '0';
    addr_ram1 <= zero18 when(rst = '0') else
                 me_read_addr when (me_read_enable = '1') else
                 me_write_addr when (me_write_enable = '1') else
                 "00" & pc_real;
    data_ram1 <= me_write_data when ((me_write_enable_real = '1') or (seri1_write_enable = '1'))else "ZZZZZZZZZZZZZZZZ";
    mewb_readout <= data_ram1 when ((me_read_enable = '1') or (seri1_write_enable = '1')) else "ZZZZZZZZZZZZZZZZ";
    -- if MEM is using SRAM, insert a NOP into pipeline
    --ifid_instruc_mem <= data_ram1 when ((me_read_enable = '0') and (me_write_enable = '0') and
                                        --(seri1_read_enable = '0') and (seri1_write_enable = '0')) else NOP_instruc;

    ifid_instruc_mem <= instruct when ((me_read_enable = '0') and (me_write_enable = '0') and
                                        (seri1_read_enable = '0') and (seri1_write_enable = '0')) else NOP_instruc;

    ---------------- IF --------------------------
    IF_unit: process(clk, rst)
    begin
        if (rst = '0') then
            pc <= zero16;
        elsif ( clk'event and clk='1' ) then
            -- TODO: the update of PC has 3 ways
            -- (1) pc <= pc + 1; (2) JR (3) BEQZ
            if (ctrl_insert_bubble = '1') then
                ifid_instruc <= ifid_instruc;
                pc <= pc_real;
            elsif ((me_read_enable = '1') or (me_write_enable = '1')) then
                ifid_instruc <= ifid_instruc_mem;     -- actually, it's a NOP
                pc <= pc_real;
            elsif ((seri1_read_enable = '1') or (seri1_write_enable = '1')) then
                ifid_instruc <= ifid_instruc_mem;     -- actually, it's a NOP
                pc <= pc_real;
            else
                ifid_instruc <= ifid_instruc_mem;
                pc <= pc_real + 1;
            end if;
        end if;
    end process IF_unit;
    -- mux for real pc, TODO: block pc increase with IF MEM conflict
    pc_real <= id_branch_value when (id_pc_branch = '1') else pc;

    ---------------- ID --------------------------
    ID_unit: process(clk, rst)
    begin
        if (rst = '0') then
            id_pc_branch <= '0';
        elsif (clk'event and clk='1') then
            if (ctrl_insert_bubble = '1') then
                idex_instruc <= idex_instruc;
            else
                idex_instruc <= ifid_instruc;
            end if;
            id_pc_branch <= '0';
            id_instruc <= ifid_instruc;
            case ifid_instruc(15 downto 11) is
                when EXTEND_ALU3_op => -- ADDU, SUBU
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
                when ADDIU3_op =>
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate value, put into reg_b
                    idex_reg_b_data <= sign_extend4(ifid_instruc(3 downto 0));
                    -- write back register index
                    idex_reg_wb <= "0" & ifid_instruc(7 downto 5);
                when EXTEND_TSP_op =>
                    case ifid_instruc(10 downto 8) is
                        when EX_ADDSP_pf_op =>  -- TODO: conflict detection
                            idex_reg_a_data <= SP;
                            idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                            idex_reg_wb <= SP_index;
                        when EX_BTEQZ_pf_op =>
                            id_pc_branch <= '1';
                            idex_reg_a_data <= T;
                            idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                        when EX_BTNEZ_pf_op =>
                            id_pc_branch <= '1';
                            idex_reg_a_data <= T;
                            idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                        when EX_MTSP_pf_op =>
                            reg_decode(idex_bypass, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            idex_reg_wb <= SP_index;
                        when others =>
                    end case;
                when EXTEND_ALUPCmix_op =>
                    case ifid_instruc(4 downto 0) is
                        when EX_AND_sf_op | EX_OR_sf_op =>         -- rx <- rx [] ry
                            reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            reg_decode(idex_reg_b_data, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                        when EX_NEG_sf_op =>               -- rx <- 0-ry
                            idex_reg_a_data <= zero16;
                            reg_decode(idex_reg_b_data, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                        when EX_NOT_sf_op =>                           -- rx <- ~ry
                            reg_decode(idex_reg_a_data, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                        when EX_SRLV_sf_op =>             -- ry <- ry >> rx
                            reg_decode(idex_reg_a_data, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            reg_decode(idex_reg_b_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            idex_reg_wb <= "0" & ifid_instruc(7 downto 5);
                        when EX_CMP_sf_op =>
                            reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            reg_decode(idex_reg_b_data, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            idex_reg_wb <= T_index;
                        when EX_PC_sf_op =>
                            case ifid_instruc(7 downto 5) is
                                when EX_MFPC_sf_diff_op =>
                                    idex_bypass <= pc_real;
                                    idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                                when EX_JR_sf_diff_op =>
                                    id_pc_branch <= '1';
                                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                                when others =>
                                    idex_reg_wb <= reg_none;
                            end case;
                        when others =>
                            idex_reg_wb <= reg_none;
                    end case;
                when EXTEND_RRI_op =>
                    case ifid_instruc(1 downto 0) is
                        when EX_SLL_sf_op | EX_SRA_sf_op | EX_SRL_sf_op =>
                            reg_decode(idex_reg_a_data, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            if (ifid_instruc(4 downto 2) = "000") then
                                idex_reg_b_data <= "0000000000001000";
                            else
                                idex_reg_b_data <= zero_extend3(ifid_instruc(4 downto 2));
                            end if;
                            idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                        when others =>
                            idex_reg_wb <= reg_none;
                    end case;
                when EXTEND_IH_op =>
                    case ifid_instruc(7 downto 0) is
                        when EX_MFIH_sf_op =>
                            idex_bypass <= IH;
                            idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                        when EX_MTIH_sf_op =>
                            reg_decode(idex_bypass, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                            idex_reg_wb <= IH_index;
                        when others =>
                            idex_reg_wb <= reg_none;
                    end case;
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
                when LW_SP_op =>
                    -- sp value
                    idex_reg_a_data <= SP;
                    -- immediate sign extend
                    idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                    -- write back rx register
                    idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                when SW_op =>
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate sign extend
                    idex_reg_b_data <= sign_extend5(ifid_instruc(4 downto 0));
                    -- ry value
                    reg_decode(idex_bypass, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                when SW_SP_op =>
                    -- sp value
                    idex_reg_a_data <= SP;
                    -- immediate sign extend
                    idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                    -- rx value  TODO: control unit for bypass value
                    reg_decode(idex_bypass, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                when BNEZ_op =>
                    id_pc_branch <= '1';
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate sign extend
                    idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                when BEQZ_op =>
                    id_pc_branch <= '1';
                    -- rx value
                    reg_decode(idex_reg_a_data, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate sign extend
                    idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                when B_op =>
                    id_pc_branch <= '1';
                    -- immediate sign extend
                    idex_reg_a_data <= sign_extend11(ifid_instruc(10 downto 0));
                when others =>
                    idex_reg_a_data <= zero16;
                    idex_reg_b_data <= zero16;
                    idex_reg_wb <= reg_none;
            end case;
        end if;
    end process ID_unit;

    -- combination logic multiplexer unit for branch TODO: maybe we need bubble handle, fix it later
    process(pc, id_instruc, idex_reg_b_data_real, idex_reg_a_data_real)
    begin
        if (id_pc_branch = '1') then
            case id_instruc(15 downto 11) is
                when BNEZ_op =>
                    if (idex_reg_a_data_real /= zero16) then
                        id_branch_value <= pc - 1 + idex_reg_b_data_real;
                    else
                        id_branch_value <= pc;
                    end if;
                when BEQZ_op =>
                    if (idex_reg_a_data_real = zero16) then
                        id_branch_value <= pc - 1 + idex_reg_b_data_real;
                    else
                        id_branch_value <= pc;
                    end if;
                when B_op =>
                    id_branch_value <= pc - 1 + idex_reg_a_data_real;
                when EXTEND_TSP_op =>
                    case id_instruc(10 downto 8) is
                        when EX_BTNEZ_pf_op =>
                            if (idex_reg_a_data_real /= zero16) then
                                id_branch_value <= pc - 1 + idex_reg_b_data_real;
                            else
                                id_branch_value <= pc;
                            end if;
                        when EX_BTEQZ_pf_op =>
                            if (idex_reg_a_data_real = zero16) then
                                id_branch_value <= pc -1 + idex_reg_b_data_real;
                            else
                                id_branch_value <= pc;
                            end if;
                        when others =>
                            id_branch_value <= zero16;
                    end case;
                when EXTEND_ALUPCmix_op =>
                    case id_instruc(4 downto 0) is
                        when EX_PC_sf_op =>
                            case id_instruc(7 downto 5) is
                                when EX_JR_sf_diff_op =>
                                    id_branch_value <= idex_reg_a_data_real;
                                when others =>
                                    id_branch_value <= zero16;
                            end case;
                        when others =>
                            id_branch_value <= zero16;
                    end case;
                when others =>
                    id_branch_value <= zero16;
            end case;
        end if;
    end process;

    -- TODO input will be change to 7, current is not good
    -- combination logic multiplexer unit for conflict solve
    -- multiplexer map
    Rg_A_mux: mux7to1 port map (idex_reg_a_data_real, ctrl_mux_reg_a, idex_reg_a_data, exme_result,
                        mewb_result, mewb_readout, wb_reg_data, exme_bypass, mewb_bypass);
    Rg_B_mux: mux7to1 port map (idex_reg_b_data_real, ctrl_mux_reg_b, idex_reg_b_data, exme_result,
                        mewb_result, mewb_readout, wb_reg_data, exme_bypass, mewb_bypass);
    Rg_bypass: mux7to1 port map (idex_bypass_real, ctrl_mux_bypass, idex_bypass, exme_result,
                        mewb_result, mewb_readout, wb_reg_data, exme_bypass, mewb_bypass);

--                 ---                                  ---                                  ---
--    idex_reg_a--|   |                    idex_reg_b--|   |     ^_^           idex_bypass--|   |
--    alu_result--| M |                    alu_result--| M |                    alu_result--| M |
--   mewb_result--|   |                   mewb_result--|   |                   mewb_result--|   |
--  mewb_readout--| U |--ex_alu_reg_a    mewb_readout--| U |--ex_alu_reg_b    mewb_readout--| U |--ex_bypass
--   wb_reg_data--|   |                   wb_reg_data--|   |                   wb_reg_data--|   |
--   exme_bypass--| X |                   exme_bypass--| X |                   exme_bypass--| X |
--   mewb_bypass--|   |                   mewb_bypass--|   |                   mewb_bypass--|   |
--                 ---                                  ---                                  ---                





    ---------------- EX --------------------------
    EX_unit: process(clk, rst)
        variable ex_instruc : std_logic_vector (15 downto 0) := NOP_instruc;
    begin
        if (rst = '0') then
            exme_instruc <= NOP_instruc;
            ex_instruc := NOP_instruc;
        elsif (clk'event and clk='1') then
            if (ctrl_insert_bubble = '1') then
                ex_instruc := NOP_instruc;
                exme_instruc <= NOP_instruc;
            else
                ex_instruc := idex_instruc;
                exme_instruc <= idex_instruc;
            end if;
            case ex_instruc(15 downto 11) is
                when ADDIU_op | ADDIU3_op | LW_op | LW_SP_op | SW_op | SW_SP_op =>
                    ex_reg_a_data <= idex_reg_a_data_real;
                    ex_reg_b_data <= idex_reg_b_data_real;
                    ex_alu_op <= alu_add;
                    exme_bypass <= idex_bypass_real;
                    exme_reg_wb <= idex_reg_wb;
                when EXTEND_ALU3_op =>
                    ex_reg_a_data <= idex_reg_a_data_real;
                    ex_reg_b_data <= idex_reg_b_data_real;
                    exme_bypass <= idex_bypass_real;
                    exme_reg_wb <= idex_reg_wb;
                    case ex_instruc(1 downto 0) is
                        when EX_ADDU_sf_op =>
                            ex_alu_op <= alu_add;
                        when EX_SUBU_sf_op =>
                            ex_alu_op <= alu_sub;
                        when others =>
                            ex_alu_op <= alu_nop;
                    end case;
                when LI_op =>
                    ex_alu_op <= alu_nop;
                    exme_reg_wb <= idex_reg_wb;
                    exme_bypass <= idex_reg_a_data_real;
                when EXTEND_TSP_op =>
                    case ex_instruc(10 downto 8) is
                        when EX_ADDSP_pf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_add;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_MTSP_pf_op =>
                            ex_alu_op <= alu_nop;
                            exme_bypass <= idex_bypass_real;
                            exme_reg_wb <= idex_reg_wb;
                        when others =>
                            ex_alu_op <= alu_nop;
                    end case;
                when EXTEND_ALUPCmix_op =>
                    case ex_instruc(4 downto 0) is
                        when EX_AND_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_and;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_OR_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_or;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_NEG_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_sub;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_NOT_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_alu_op <= alu_not;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_SRLV_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_srl;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_CMP_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_cmp;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_PC_sf_op =>
                            case ex_instruc(7 downto 5) is
                                when EX_MFPC_sf_diff_op =>
                                    ex_alu_op <= alu_nop;
                                    exme_bypass <= idex_bypass_real;
                                    exme_reg_wb <= idex_reg_wb;
                                when others =>
                                    ex_alu_op <= alu_nop;
                            end case;
                        when others =>
                            ex_alu_op <= alu_nop;
                    end case;
                when EXTEND_RRI_op =>
                    case ex_instruc(1 downto 0) is
                        when EX_SLL_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_sll;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_SRA_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_sra;
                            exme_reg_wb <= idex_reg_wb;
                        when EX_SRL_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_srl;
                            exme_reg_wb <= idex_reg_wb;
                        when others =>
                            ex_alu_op <= alu_nop;
                    end case;
                when EXTEND_IH_op =>
                    case ex_instruc(7 downto 0) is
                        when EX_MFIH_sf_op | EX_MTIH_sf_op  =>
                            exme_bypass <= idex_bypass_real;
                            exme_reg_wb <= idex_reg_wb;
                            ex_alu_op <= alu_nop;
                        when others =>
                            ex_alu_op <= alu_nop;
                    end case;
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
            mewb_instruc <= exme_instruc;
            me_read_enable <= '0';
            me_write_enable <= '0';
            seri1_read_enable <= '0';
            seri1_write_enable <= '0';
            case exme_instruc(15 downto 11) is
                when ADDIU_op | ADDIU3_op | EXTEND_RRI_op  =>
                    mewb_result <= exme_result;
                    mewb_reg_wb <= exme_reg_wb;
                when EXTEND_ALU3_op => -- ADDU, SUBU
                    mewb_result <= exme_result;
                    mewb_reg_wb <= exme_reg_wb;
                when LI_op =>
                    mewb_reg_wb <= exme_reg_wb;
                    mewb_bypass <= exme_bypass;
                when LW_op | LW_SP_op =>
                    case exme_result is
                        when seri1_data_addr =>
                            seri1_write_enable <= '0';
                            seri1_read_enable <= '1';
                            mewb_reg_wb <= exme_reg_wb;
                        when seri1_ctrl_addr =>    -- do nothing
                        when seri2_data_addr =>   -- not support yet
                        when seri2_ctrl_addr =>
                        when others => -- lw in SRAM
                            mewb_reg_wb <= exme_reg_wb;
                            me_read_addr <= "00" & exme_result;
                            me_read_enable <= '1';
                            me_write_enable <= '0';
                    end case;
                when SW_op | SW_SP_op =>
                    case exme_result is
                        when seri1_data_addr =>
                            seri1_write_enable <= '1';
                            seri1_read_enable <= '0';
                            me_write_data <= exme_bypass;  -- actually, only low 8 bit will write to serial
                        when seri1_ctrl_addr =>    -- do nothing
                        when seri2_data_addr =>   -- not support yet
                        when seri2_ctrl_addr =>
                        when others => -- sw in SRAM
                            me_write_addr <= "00" & exme_result;
                            me_write_data <= exme_bypass;
                            me_read_enable <= '0';
                            me_write_enable <= '1';
                    end case;
                when EXTEND_TSP_op =>
                    case exme_instruc(10 downto 8) is
                        when EX_ADDSP_pf_op =>
                            mewb_result <= exme_result;
                            mewb_reg_wb <= exme_reg_wb;
                        when EX_MTSP_pf_op =>
                            mewb_bypass <= exme_result;
                            mewb_reg_wb <= exme_reg_wb;
                        when others =>
                    end case;
                when EXTEND_ALUPCmix_op =>
                    case exme_instruc(4 downto 0) is
                        when EX_AND_sf_op | EX_OR_sf_op | EX_NEG_sf_op | EX_NOT_sf_op | EX_SRLV_sf_op | EX_CMP_sf_op =>
                            mewb_result <= exme_result;
                            mewb_reg_wb <= exme_reg_wb;
                        when EX_PC_sf_op =>
                            case exme_instruc(7 downto 5) is
                                when EX_MFPC_sf_diff_op =>
                                    mewb_reg_wb <= exme_reg_wb;
                                    mewb_bypass <= exme_bypass;
                                when others =>
                            end case;
                        when others =>
                    end case;
                when EXTEND_IH_op =>
                    case exme_instruc(7 downto 0) is
                        when EX_MFIH_sf_op | EX_MTIH_sf_op  =>
                            mewb_bypass <= exme_bypass;
                            mewb_reg_wb <= exme_reg_wb;
                        when others =>
                    end case;
                when NOP_op =>
                    mewb_instruc <= NOP_instruc;
                when others =>
                    mewb_instruc <= NOP_instruc;
            end case;
        end if;
    end process ME_unit;

    ---------------- WB --------------------------
    WB_unit: process(clk, rst)
        variable wb_data : std_logic_vector(15 downto 0);
        variable wb_enable : boolean := false;
    begin
        if (clk'event and clk='1') then
            case mewb_instruc(15 downto 11) is
                when ADDIU_op | ADDIU3_op | EXTEND_RRI_op =>
                    wb_data := mewb_result;
                    wb_enable := true;
                when EXTEND_ALU3_op => -- ADDU, SUBU
                    wb_data := mewb_result;
                    wb_enable := true;
                when LI_op =>
                    wb_data := mewb_bypass;
                    wb_enable := true;
                when LW_op | LW_SP_op =>
                    case exme_result is
                        when seri1_data_addr =>
                            wb_data := "00000000" & mewb_readout(7 downto 0);
                            wb_enable := true;
                        when seri1_ctrl_addr =>    -- do nothing
                        when seri2_data_addr =>   -- not support yet
                        when seri2_ctrl_addr =>
                        when others => -- lw in SRAM
                            wb_data := mewb_readout;
                            wb_enable := true;
                    end case;
                when EXTEND_TSP_op =>
                    case mewb_instruc(10 downto 8) is
                        when EX_ADDSP_pf_op =>
                            wb_data := mewb_result;
                            wb_enable := true;
                        when EX_MTSP_pf_op =>
                            wb_data := mewb_bypass;
                            wb_enable := true;
                        when others =>
                            wb_enable := false;
                    end case;
                when EXTEND_ALUPCmix_op =>
                    case mewb_instruc(4 downto 0) is
                        when EX_AND_sf_op | EX_OR_sf_op | EX_NEG_sf_op | EX_NOT_sf_op | EX_SRLV_sf_op | EX_CMP_sf_op =>
                            wb_data := mewb_result;
                            wb_enable := true;
                        when EX_PC_sf_op =>
                            case mewb_instruc(7 downto 5) is
                                when EX_MFPC_sf_diff_op =>
                                    wb_data := mewb_bypass;
                                    wb_enable := true;
                                when others =>
                            end case;
                        when others =>
                            wb_enable := false;
                    end case;
                when EXTEND_IH_op =>
                    case exme_instruc(7 downto 0) is
                        when EX_MFIH_sf_op | EX_MTIH_sf_op  =>
                            wb_data := mewb_bypass;
                            wb_enable := true;
                        when others =>
                    end case;
                when NOP_op =>
                    wb_enable := false;
                when others =>
                    wb_enable := false;
            end case;
            if (wb_enable = true) then
                wb_reg_data <= wb_data;
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
                    when "1010" =>
                        T <= wb_data;
                    when others =>
                end case;
            else
                wb_reg_data <= zero16;
            end if;

        end if;
    end process WB_unit;


    ------------ Control Unit --------------------
    Control_unit: process(clk, rst)
        variable ctrl_wb_reg_0      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_wb_reg_1      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_wb_reg_2      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_wb_reg_3      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_rd_reg_a      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_rd_reg_b      : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_rd_bypass     : std_logic_vector (3 downto 0)  := reg_none;
        variable ctrl_instruc_0     : std_logic_vector (15 downto 0) := NOP_instruc;
        variable ctrl_instruc_1     : std_logic_vector (15 downto 0) := NOP_instruc;
        variable ctrl_instruc_2     : std_logic_vector (15 downto 0) := NOP_instruc;
        variable ctrl_instruc_3     : std_logic_vector (15 downto 0) := NOP_instruc;
        variable ctrl_fake_nop      : boolean                        := false;
    begin
        if (rst = '0') then
            ctrl_wb_reg_0  := reg_none;
            ctrl_wb_reg_1  := reg_none;
            ctrl_wb_reg_2  := reg_none;
            ctrl_wb_reg_3  := reg_none;
            ctrl_rd_reg_a  := reg_none;
            ctrl_rd_reg_b  := reg_none;
            ctrl_rd_bypass := reg_none;
            ctrl_instruc_0 := NOP_instruc;
            ctrl_instruc_1 := NOP_instruc;
            ctrl_instruc_2 := NOP_instruc;
            ctrl_instruc_3 := NOP_instruc;
            ctrl_insert_bubble <= '0';
            ctrl_fake_nop  := false;
        elsif (clk'event and clk='1') then
            ctrl_fake_nop  := false;
            ctrl_wb_reg_3  := ctrl_wb_reg_2;
            ctrl_wb_reg_2  := ctrl_wb_reg_1;
            ctrl_wb_reg_1  := ctrl_wb_reg_0;
            ctrl_instruc_3 := ctrl_instruc_2;
            ctrl_instruc_2 := ctrl_instruc_1;
            ctrl_instruc_1 := ctrl_instruc_0;
            ctrl_instruc_0 := ifid_instruc;
            case ctrl_instruc_0(15 downto 11) is
                when EXTEND_ALU3_op => -- ADDU, SUBU
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(4 downto 2);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := "0" & ctrl_instruc_0(7 downto 5);
                    ctrl_rd_bypass := reg_none;
                when ADDIU_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when ADDIU3_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(7 downto 5);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when LI_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_a  := reg_none;
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when EXTEND_RRI_op =>  -- SLL, SRA, SRL
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(7 downto 5);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when EXTEND_TSP_op => -- ADDSP, BTEQZ, BTNEZ, MTSP
                    case ctrl_instruc_0(10 downto 8) is
                        when EX_BTEQZ_pf_op | EX_BTNEZ_pf_op =>
                            ctrl_wb_reg_0  := reg_none;
                            ctrl_rd_reg_a  := T_index;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                        when EX_ADDSP_pf_op =>
                            ctrl_wb_reg_0  := SP_index;
                            ctrl_rd_reg_a  := SP_index;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                        when EX_MTSP_pf_op =>
                            ctrl_wb_reg_0  := SP_index;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := "0" & ctrl_instruc_0(7 downto 5);
                        when others =>
                            ctrl_wb_reg_0  := reg_none;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                    end case;
                when EXTEND_ALUPCmix_op =>
                    case ctrl_instruc_0(4 downto 0) is
                        when EX_AND_sf_op | EX_OR_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_b  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_bypass := reg_none;
                        when EX_CMP_sf_op =>
                            ctrl_wb_reg_0  := T_index;
                            ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_b  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_bypass := reg_none;
                        when EX_NEG_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_bypass := reg_none;
                        when EX_NOT_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                        when EX_SRLV_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_reg_a  := "0" & ctrl_instruc_0(7 downto 5);
                            ctrl_rd_reg_b  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_bypass := reg_none;
                        when EX_PC_sf_op =>
                            case ctrl_instruc_0(7 downto 5) is
                                when EX_JR_sf_diff_op =>
                                    ctrl_wb_reg_0  := reg_none;
                                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                                    ctrl_rd_reg_b  := reg_none;
                                    ctrl_rd_bypass := reg_none;
                                when EX_MFPC_sf_diff_op =>
                                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                                    ctrl_rd_reg_a  := reg_none;
                                    ctrl_rd_reg_b  := reg_none;
                                    ctrl_rd_bypass := reg_none;
                                when others =>
                                    ctrl_wb_reg_0  := reg_none;
                                    ctrl_rd_reg_a  := reg_none;
                                    ctrl_rd_reg_b  := reg_none;
                                    ctrl_rd_bypass := reg_none;
                            end case;
                        when others =>
                            ctrl_wb_reg_0  := reg_none;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                    end case;
                when EXTEND_IH_op =>
                    case ctrl_instruc_0(7 downto 0) is
                        when EX_MFIH_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := IH_index;
                        when EX_MTIH_sf_op =>
                            ctrl_wb_reg_0  := IH_index;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := "0" & ctrl_instruc_0(10 downto 8);
                        when others =>
                            ctrl_wb_reg_0  := reg_none;
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := reg_none;
                    end case;
                when LW_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(7 downto 5);
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when LW_SP_op =>
                    ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_a  := SP_index;
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when SW_op =>
                    ctrl_wb_reg_0  := reg_none;
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := "0" & ctrl_instruc_0(7 downto 5);
                when SW_SP_op =>
                    ctrl_wb_reg_0  := reg_none;
                    ctrl_rd_reg_a  := SP_index;
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := "0" & ctrl_instruc_0(10 downto 8);
                when BNEZ_op | BEQZ_op =>
                    ctrl_wb_reg_0  := reg_none;
                    ctrl_rd_reg_a  := "0" & ctrl_instruc_0(10 downto 8);
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
                when others =>
                    ctrl_wb_reg_0  := reg_none;
                    ctrl_rd_reg_a  := reg_none;
                    ctrl_rd_reg_b  := reg_none;
                    ctrl_rd_bypass := reg_none;
            end case;
            conflict_detect(ctrl_fake_nop, ctrl_mux_reg_a, ctrl_mux_reg_b, ctrl_mux_bypass,
                            ctrl_rd_reg_a, ctrl_rd_reg_b, ctrl_rd_bypass, ctrl_wb_reg_1, ctrl_wb_reg_2, ctrl_wb_reg_3,
                            ctrl_instruc_0, ctrl_instruc_1, ctrl_instruc_2, ctrl_instruc_3);
            if (ctrl_fake_nop = true) then
                ctrl_insert_bubble <= '1';
                ctrl_wb_reg_0 := reg_none;
                ctrl_instruc_0 := NOP_instruc;
            else
                ctrl_insert_bubble <= '0';
            end if;
        end if;
    end process Control_unit;

    dyp0 <= "0000000";
    dyp1 <= "1111111";

    EN_ram2 <= '1';
    OE_ram2 <= '1';
    WE_ram2 <= '1';
    data_ram2 <= "ZZZZZZZZZZZZZZZZ";
    addr_ram2 <= zero18;

    led(15) <= seri_wrn_t;
    led(14) <= seri_rdn_t;
    led(13) <= seri_tbre;
    led(12) <= seri_tsre;
    led(11) <= seri_data_ready;
    led(10 downto 8) <= "000";
    led(7 downto 0) <= data_ram1(7 downto 0);

end Behavioral;

