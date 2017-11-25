--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package helper is

    constant LI_op       : std_logic_vector (4 downto 0) := "01101";
    constant LW_op       : std_logic_vector (4 downto 0) := "10011";
    constant LW_SP_op    : std_logic_vector (4 downto 0) := "10010";
    constant SW_op       : std_logic_vector (4 downto 0) := "11011";
    constant SW_SP_op    : std_logic_vector (4 downto 0) := "11010";
    constant ADDIU_op    : std_logic_vector (4 downto 0) := "01001";
    constant ADDIU3_op   : std_logic_vector (4 downto 0) := "01000";
    constant BNEZ_op     : std_logic_vector (4 downto 0) := "00101";
    constant BEQZ_op     : std_logic_vector (4 downto 0) := "00100";
    constant B_op        : std_logic_vector (4 downto 0) := "00010";
    constant NOP_op      : std_logic_vector (4 downto 0) := "00001";

    constant EXTEND_ALU3_op : std_logic_vector (4 downto 0) := "11100";
    constant EX_ADDU_sf_op  : std_logic_vector (1 downto 0) := "01";
    constant EX_SUBU_sf_op  : std_logic_vector (1 downto 0) := "11";

    constant EXTEND_TSP_op  : std_logic_vector (4 downto 0) := "01100";
    constant EX_ADDSP_pf_op : std_logic_vector (2 downto 0) := "011";
    constant EX_BTEQZ_pf_op : std_logic_vector (2 downto 0) := "000";
    constant EX_BTNEZ_pf_op : std_logic_vector (2 downto 0) := "001";
    constant EX_MTSP_pf_op  : std_logic_vector (2 downto 0) := "100";

    constant EXTEND_ALUPCmix_op : std_logic_vector (4 downto 0) := "11101";
    constant EX_AND_sf_op       : std_logic_vector (4 downto 0) := "01100";
    constant EX_CMP_sf_op       : std_logic_vector (4 downto 0) := "01010";
    constant EX_PC_sf_op        : std_logic_vector (4 downto 0) := "00000";
    constant EX_JR_sf_diff_op   : std_logic_vector (2 downto 0) := "000";
    constant EX_JALR_sf_diff_op : std_logic_vector (2 downto 0) := "110"; -- NOTE: not implement
    constant EX_MFPC_sf_diff_op : std_logic_vector (2 downto 0) := "010";
    constant EX_NEG_sf_op       : std_logic_vector (4 downto 0) := "01011";
    constant EX_NOT_sf_op       : std_logic_vector (4 downto 0) := "01111";
    constant EX_OR_sf_op        : std_logic_vector (4 downto 0) := "01101";
    constant EX_SRLV_sf_op      : std_logic_vector (4 downto 0) := "00110";

    constant EXTEND_RRI_op      : std_logic_vector (4 downto 0) := "00110";
    constant EX_SLL_sf_op       : std_logic_vector (1 downto 0) := "00";
    constant EX_SRA_sf_op       : std_logic_vector (1 downto 0) := "11";
    constant EX_SRL_sf_op       : std_logic_vector (1 downto 0) := "10";


    constant EXTEND_IH_op         : std_logic_vector (4 downto 0) := "11110";
    constant EX_MFIH_sf_op      : std_logic_vector (7 downto 0) := "00000000";
    constant EX_MTIH_sf_op      : std_logic_vector (7 downto 0) := "00000001";


    constant NOP_instruc : std_logic_vector (15 downto 0) := "0000100000000000";

    constant alu_add  : std_logic_vector (3 downto 0) := "0000";
    constant alu_sub  : std_logic_vector (3 downto 0) := "0001";
    constant alu_and  : std_logic_vector (3 downto 0) := "0010";
    constant alu_or   : std_logic_vector (3 downto 0) := "0011";
    constant alu_xor  : std_logic_vector (3 downto 0) := "0100";
    constant alu_not  : std_logic_vector (3 downto 0) := "0101";
    constant alu_sll  : std_logic_vector (3 downto 0) := "0110";
    constant alu_srl  : std_logic_vector (3 downto 0) := "0111";
    constant alu_sra  : std_logic_vector (3 downto 0) := "1000";
    constant alu_rol  : std_logic_vector (3 downto 0) := "1001";
    constant alu_cmp  : std_logic_vector (3 downto 0) := "1010";
    constant alu_nop  : std_logic_vector (3 downto 0) := "1111";

    -- for serial
    constant seri1_data_addr  : std_logic_vector (15 downto 0) := "1011111100000000"; -- 0xBF00
    constant seri1_ctrl_addr  : std_logic_vector (15 downto 0) := "1011111100000001"; -- 0xBF01
    constant seri2_data_addr  : std_logic_vector (15 downto 0) := "1011111100000010"; -- 0xBF02
    constant seri2_ctrl_addr  : std_logic_vector (15 downto 0) := "1011111100000011"; -- 0xBF03


    constant zero16   : std_logic_vector (15 downto 0) := "0000000000000000";
    constant zero17   : std_logic_vector (16 downto 0) := "00000000000000000";
    constant zero18   : std_logic_vector (17 downto 0) := "000000000000000000";
    constant zero5    : std_logic_vector (4 downto 0)  := "00000";

    constant chs_idex_reg     : std_logic_vector (2 downto 0) := "000";
    constant chs_idex_bypass  : std_logic_vector (2 downto 0) := "000";  -- YES, chs_idex_reg has same value with chs_idex_bypass
    constant chs_alu_result   : std_logic_vector (2 downto 0) := "001";  -- cause they will map to different mux with different signal input
    constant chs_mewb_result  : std_logic_vector (2 downto 0) := "010";
    constant chs_mewb_readout : std_logic_vector (2 downto 0) := "011";
    constant chs_wb_reg_data  : std_logic_vector (2 downto 0) := "100";
    constant chs_exme_bypass  : std_logic_vector (2 downto 0) := "101";
    constant chs_mewb_bypass  : std_logic_vector (2 downto 0) := "110";


    constant r0_index : std_logic_vector (3 downto 0) := "0000";
    constant r1_index : std_logic_vector (3 downto 0) := "0001";
    constant r2_index : std_logic_vector (3 downto 0) := "0010";
    constant r3_index : std_logic_vector (3 downto 0) := "0011";
    constant r4_index : std_logic_vector (3 downto 0) := "0100";
    constant r5_index : std_logic_vector (3 downto 0) := "0101";
    constant r6_index : std_logic_vector (3 downto 0) := "0110";
    constant r7_index : std_logic_vector (3 downto 0) := "0111";
    constant SP_index : std_logic_vector (3 downto 0) := "1000";
    constant IH_index : std_logic_vector (3 downto 0) := "1001";
    constant T_index  : std_logic_vector (3 downto 0) := "1010";
    constant reg_none : std_logic_vector (3 downto 0) := "1111";




    ------ VGA Section ------
    -------------------------
    constant vga_disp_480       : std_logic_vector (2 downto 0) := "000";
    constant vga_disp_768       : std_logic_vector (2 downto 0) := "001";

    constant vga480_full_w : integer := 799;
    constant vga480_full_h : integer := 524;
    constant vga480_w : integer := 640;
    constant vga480_h : integer := 480;
    constant vga480_hs_start : integer := 656;
    constant vga480_hs_end : integer := 752;
    constant vga480_vs_start : integer := 490;
    constant vga480_vs_end : integer := 492;

    constant vga768_full_w : integer := 1263; -- 1024 + 8 + 176 + 56
    constant vga768_full_h : integer := 816; -- 768 + 0	8	41
    constant vga768_w : integer := 1024;
    constant vga768_h : integer := 768;
    constant vga768_hs_start : integer := 1032; -- 1024 + 8 - 1
    constant vga768_hs_end : integer := 1208;
    constant vga768_vs_start : integer := 816;
    constant vga768_vs_end : integer := 824;


    procedure reg_decode(signal reg_data: out std_logic_vector(15 downto 0);
                        addr: in std_logic_vector(3 downto 0);
                        signal r0, r1, r2, r3, r4, r5, r6, r7, SP, IH: in std_logic_vector(15 downto 0));

    procedure conflict_detect( variable ctrl_fake_nop                 : out boolean;
                             signal ctrl_mux_reg_a, ctrl_mux_reg_b    : out std_logic_vector (2 downto 0);
                             signal ctrl_mux_bypass                   : out std_logic_vector (2 downto 0);
                             ctrl_rd_reg_a, ctrl_rd_reg_b             : in std_logic_vector (3 downto 0);
                             ctrl_rd_bypass                           : in std_logic_vector (3 downto 0);
                             ctrl_wb_reg1, ctrl_wb_reg2, ctrl_wb_reg3 : in std_logic_vector (3 downto 0);
                             ctrl_instruc_0, ctrl_instruc_1           : in std_logic_vector (15 downto 0);
                             ctrl_instruc_2, ctrl_instruc_3           : in std_logic_vector (15 downto 0));

    function sign_extend11(imm : std_logic_vector(10 downto 0))
                            return std_logic_vector;

    function sign_extend8(imm : std_logic_vector(7 downto 0))
                            return std_logic_vector;

    function sign_extend5(imm : std_logic_vector(4 downto 0))
                            return std_logic_vector;

    function sign_extend4(imm : std_logic_vector(3 downto 0))
                            return std_logic_vector;

    function zero_extend8(imm : std_logic_vector(7 downto 0))
                            return std_logic_vector;

    function zero_extend3(imm : std_logic_vector(2 downto 0))
                            return std_logic_vector;


end helper;

package body helper is

    function sign_extend11(imm : std_logic_vector(10 downto 0))
                                return std_logic_vector is
    begin
        if (imm(10) = '1') then
            return "11111" & imm;
        else
            return "00000" & imm;
        end if;
    end sign_extend11;

    function sign_extend8(imm : std_logic_vector(7 downto 0))
                                return std_logic_vector is
    begin 
        if imm(7) = '1' then
            return "11111111" & imm;
        else
            return "00000000" & imm;
        end if;
    end sign_extend8;

    function sign_extend5(imm : std_logic_vector(4 downto 0))
                                return std_logic_vector is
    begin 
        if imm(4) = '1' then
            return "11111111111" & imm;
        else
            return "00000000000" & imm;
        end if;
    end sign_extend5;

    function sign_extend4(imm : std_logic_vector(3 downto 0))
                                return std_logic_vector is
    begin 
        if imm(3) = '1' then
            return "111111111111" & imm;
        else
            return "000000000000" & imm;
        end if;
    end sign_extend4;

    function zero_extend8(imm : std_logic_vector(7 downto 0))
                                return std_logic_vector is
    begin 
        return "00000000" & imm;
    end zero_extend8;

    function zero_extend3(imm : std_logic_vector(2 downto 0))
                                return std_logic_vector is
    begin 
        return "0000000000000" & imm;
    end zero_extend3;



    -- TODO: decode register with register index constant
    procedure reg_decode(signal reg_data: out std_logic_vector(15 downto 0);
                        addr: in std_logic_vector(3 downto 0);
                        signal r0, r1, r2, r3, r4, r5, r6, r7, SP, IH: in std_logic_vector(15 downto 0)) is
    begin
        case addr is
            when "0000" =>
                reg_data <= r0;
            when "0001" =>
                reg_data <= r1;
            when "0010" =>
                reg_data <= r2;
            when "0011" =>
                reg_data <= r3;
            when "0100" =>
                reg_data <= r4;
            when "0101" =>
                reg_data <= r5;
            when "0110" =>
                reg_data <= r6;
            when "0111" =>
                reg_data <= r7;
            when "1000" =>
                reg_data <= SP;
            when "1001" =>
                reg_data <= IH;
            when others =>
                reg_data <= "0000000000000000";
        end case;
    end reg_decode;

    procedure conflict_detect( variable ctrl_fake_nop                 : out boolean;
                             signal ctrl_mux_reg_a, ctrl_mux_reg_b    : out std_logic_vector (2 downto 0);
                             signal ctrl_mux_bypass                   : out std_logic_vector (2 downto 0);
                             ctrl_rd_reg_a, ctrl_rd_reg_b             : in std_logic_vector (3 downto 0);
                             ctrl_rd_bypass                           : in std_logic_vector (3 downto 0);
                             ctrl_wb_reg1, ctrl_wb_reg2, ctrl_wb_reg3 : in std_logic_vector (3 downto 0);
                             ctrl_instruc_0, ctrl_instruc_1           : in std_logic_vector (15 downto 0);
                             ctrl_instruc_2, ctrl_instruc_3           : in std_logic_vector (15 downto 0)) is
        variable conflict_instruc_a               : std_logic_vector (15 downto 0) := NOP_instruc;
        variable conflict_instruc_number_a        : integer                        := 0;
        variable conflict_instruc_b               : std_logic_vector (15 downto 0) := NOP_instruc;
        variable conflict_instruc_number_b        : integer                        := 0;
        variable conflict_instruc_bypass          : std_logic_vector (15 downto 0) := NOP_instruc;
        variable conflict_instruc_number_bypass   : integer                        := 0;
        variable insert_bubble                    : std_logic                      := '0';
    begin

        if (ctrl_rd_reg_a /= reg_none) then
            if (ctrl_rd_reg_a = ctrl_wb_reg1) then
                conflict_instruc_a := ctrl_instruc_1;
                conflict_instruc_number_a := 1;
            elsif (ctrl_rd_reg_a = ctrl_wb_reg2) then
                conflict_instruc_a := ctrl_instruc_2;
                conflict_instruc_number_a := 2;
            elsif (ctrl_rd_reg_a = ctrl_wb_reg3) then
                conflict_instruc_a := ctrl_instruc_3;
                conflict_instruc_number_a := 3;
            else
                conflict_instruc_a := NOP_instruc;
                conflict_instruc_number_a := 0;
            end if;
        else
            conflict_instruc_a := NOP_instruc;
            conflict_instruc_number_a := 0;
        end if;

        if (ctrl_rd_reg_b /= reg_none) then
            if (ctrl_rd_reg_b = ctrl_wb_reg1) then
                conflict_instruc_b := ctrl_instruc_1;
                conflict_instruc_number_b := 1;
            elsif (ctrl_rd_reg_b = ctrl_wb_reg2) then
                conflict_instruc_b := ctrl_instruc_2;
                conflict_instruc_number_b := 2;
            elsif (ctrl_rd_reg_b = ctrl_wb_reg3) then
                conflict_instruc_b := ctrl_instruc_3;
                conflict_instruc_number_b := 3;
            else
                conflict_instruc_b := NOP_instruc;
                conflict_instruc_number_b := 0;
            end if;
        else
            conflict_instruc_b := NOP_instruc;
            conflict_instruc_number_b := 0;
        end if;

        if (ctrl_rd_bypass /= reg_none) then
            if (ctrl_rd_bypass = ctrl_wb_reg1) then
                conflict_instruc_bypass := ctrl_instruc_1;
                conflict_instruc_number_bypass := 1;
            elsif (ctrl_rd_bypass = ctrl_wb_reg2) then
                conflict_instruc_bypass := ctrl_instruc_2;
                conflict_instruc_number_bypass := 2;
            elsif (ctrl_rd_bypass = ctrl_wb_reg3) then
                conflict_instruc_bypass := ctrl_instruc_3;
                conflict_instruc_number_bypass := 3;
            else
                conflict_instruc_bypass := NOP_instruc;
                conflict_instruc_number_bypass := 0;
            end if;
        else
            conflict_instruc_bypass := NOP_instruc;
            conflict_instruc_number_bypass := 0;
        end if;


--
--                 ---
--    idex_reg_a--|   |
--    alu_result--| M |
--   mewb_result--|   |
--  mewb_readout--| U |--ex_alu_reg_a
--   wb_reg_data--|   |
--   exme_bypass--| X |
--   mewb_bypass--|   |
--                 ---                 

        ctrl_fake_nop := false;

        case conflict_instruc_a(15 downto 11) is
            when EXTEND_ALU3_op | ADDIU_op | EXTEND_RRI_op =>
                insert_bubble := '0';
                case conflict_instruc_number_a is
                    when 1 =>
                        ctrl_mux_reg_a <= chs_alu_result;     --                 ---
                    when 2 =>                                 --    idex_reg_a--|   |
                        ctrl_mux_reg_a <= chs_mewb_result;    --    alu_result--| M |
                    when 3 =>                                 --   mewb_result--|   |
                        ctrl_mux_reg_a <= chs_wb_reg_data;    --  mewb_readout--| U |--ex_alu_reg_a
                    when others =>                            --   wb_reg_data--|   |
                        ctrl_mux_reg_a <= chs_idex_reg;       --   exme_bypass--| X |
                end case;                                     --   mewb_bypass--|   |
            when LI_op =>                                     --                 ---                
                case conflict_instruc_number_a is
                    when 1 =>
                        ctrl_mux_reg_a <= chs_exme_bypass;
                    when 2 =>
                        ctrl_mux_reg_a <= chs_mewb_bypass;
                    when 3 =>
                        ctrl_mux_reg_a <= chs_wb_reg_data;
                    when others =>
                        ctrl_mux_reg_a <= chs_idex_bypass;
                end case;
            when LW_op =>
                if (conflict_instruc_number_a = 1) then
                    ctrl_fake_nop := true;
                end if;
                case conflict_instruc_number_a is
                    when 2 =>
                        ctrl_mux_reg_a <= chs_mewb_readout;
                    when 3 =>
                        ctrl_mux_reg_a <= chs_wb_reg_data;
                    when others =>
                        ctrl_mux_reg_a <= chs_idex_reg;
                end case;
            when others =>
                ctrl_mux_reg_a <= chs_idex_reg;
                insert_bubble := '0';
        end case;

        case conflict_instruc_b(15 downto 11) is
            when EXTEND_ALU3_op | ADDIU_op | EXTEND_RRI_op =>
                insert_bubble := '0';
                case conflict_instruc_number_b is
                    when 1 =>
                        ctrl_mux_reg_b <= chs_alu_result;     --
                    when 2 =>                                 --                 ---
                        ctrl_mux_reg_b <= chs_mewb_result;    --    idex_reg_b--| M |
                    when 3 =>                                 --    alu_result--|   |
                        ctrl_mux_reg_b <= chs_wb_reg_data;    --   mewb_result--| U |--ex_alu_reg_b
                    when others =>                            --  mewb_readout--|   |
                        ctrl_mux_reg_b <= chs_idex_reg;       --   wb_reg_data--| X |
                end case;                                     --                 ---
            when LI_op =>
                case conflict_instruc_number_b is
                    when 1 =>
                        ctrl_mux_reg_b <= chs_exme_bypass;
                    when 2 =>
                        ctrl_mux_reg_b <= chs_mewb_bypass;
                    when 3 =>
                        ctrl_mux_reg_b <= chs_wb_reg_data;
                    when others =>
                        ctrl_mux_reg_b <= chs_idex_bypass;
                end case;
            when LW_op =>
                if (conflict_instruc_number_b = 1) then
                    ctrl_fake_nop := true;
                end if;
                case conflict_instruc_number_b is
                    when 2 =>
                        ctrl_mux_reg_b <= chs_mewb_readout;
                    when 3 =>
                        ctrl_mux_reg_b <= chs_wb_reg_data;
                    when others =>
                        ctrl_mux_reg_b <= chs_idex_reg;
                end case;
            when others =>
                insert_bubble := '0';
                ctrl_mux_reg_b <= chs_idex_reg;
        end case;

        case conflict_instruc_bypass(15 downto 11) is
            when EXTEND_ALU3_op | ADDIU_op | EXTEND_RRI_op =>
                insert_bubble := '0';
                case conflict_instruc_number_bypass is
                    when 1 =>
                        ctrl_mux_bypass <= chs_alu_result;     --
                    when 2 =>                                      --                 ---
                        ctrl_mux_bypass <= chs_mewb_result;    --   idex_bypass--| M |
                    when 3 =>                                      --    alu_result--|   |
                        ctrl_mux_bypass <= chs_wb_reg_data;    --   mewb_result--| U |--exme_bypass
                    when others =>                                 --  mewb_readout--|   |
                        ctrl_mux_bypass <= chs_idex_reg;       --   wb_reg_data--| X |
                end case;                                          --                 ---
            when LI_op =>
                case conflict_instruc_number_bypass is
                    when 1 =>
                        ctrl_mux_bypass <= chs_exme_bypass;
                    when 2 =>
                        ctrl_mux_bypass <= chs_mewb_bypass;
                    when 3 =>
                        ctrl_mux_bypass <= chs_wb_reg_data;
                    when others =>
                        ctrl_mux_bypass <= chs_idex_bypass;
                end case;
            when LW_op =>
                if (conflict_instruc_number_bypass = 1) then
                    ctrl_fake_nop := true;
                end if;
                case conflict_instruc_number_bypass is
                    when 2 =>
                        ctrl_mux_bypass <= chs_mewb_readout;
                    when 3 =>
                        ctrl_mux_bypass <= chs_wb_reg_data;
                    when others =>
                        ctrl_mux_bypass <= chs_idex_reg;
                end case;
            when others =>
                insert_bubble := '0';
                ctrl_mux_bypass <= chs_idex_bypass;
        end case;

    end procedure conflict_detect;






end helper;
