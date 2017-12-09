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
library IEEE, BASIC;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use BASIC.HELPER.ALL;
use BASIC.INTERFACE.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Control is
    port (

        clk, rst                   : in std_logic;

        id_instruc                 : in std_logic_vector (15 downto 0);
        ifid_instruc               : in std_logic_vector (15 downto 0);

        boot_finish                : in std_logic;

        -- hard int signal
        hard_int_flag              : in std_logic;
        hard_int_insert_bubble     : out std_logic := '0';

        -- Control Unit output
        ctrl_mux_reg_a             : out std_logic_vector (2 downto 0) := "000";
        ctrl_mux_reg_b             : out std_logic_vector (2 downto 0) := "000";
        ctrl_mux_bypass            : out std_logic_vector (2 downto 0) := "000";
        ctrl_insert_bubble         : out std_logic                     := '0'

    );
end Control;

architecture Behavioral of Control is
    signal ctrl_insert_bubble_t : std_logic := '0';
begin

    ctrl_insert_bubble <= ctrl_insert_bubble_t;

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
        if ((rst = '0') or (boot_finish = '0')) then
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
            ctrl_insert_bubble_t <= '0';
            ctrl_fake_nop  := false;
        elsif (clk'event and clk='1') then
            ctrl_fake_nop  := false;
            ctrl_wb_reg_3  := ctrl_wb_reg_2;
            ctrl_wb_reg_2  := ctrl_wb_reg_1;
            ctrl_wb_reg_1  := ctrl_wb_reg_0;
            ctrl_instruc_3 := ctrl_instruc_2;
            ctrl_instruc_2 := ctrl_instruc_1;
            ctrl_instruc_1 := ctrl_instruc_0;
            if (ctrl_insert_bubble_t = '1') then        -- if the last instruction need insert bubble
                ctrl_instruc_0 := id_instruc;         -- grab id_instruc, for ifid_instruc currently contain
            else                                      -- next instruction
                ctrl_instruc_0 := ifid_instruc;
            end if;
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
                        when EX_MFEPC_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := EPC_index;
                        when EX_MFCAS_sf_op =>
                            ctrl_wb_reg_0  := "0" & ctrl_instruc_0(10 downto 8);
                            ctrl_rd_reg_a  := reg_none;
                            ctrl_rd_reg_b  := reg_none;
                            ctrl_rd_bypass := Case_index;
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
                --when INT_op =>                 -- TODO, add INT hard int control
                    --case 
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
            if (hard_int_flag = '1') then
                hard_int_insert_bubble <= '1';
                ctrl_wb_reg_0 := reg_none;
                ctrl_instruc_0 := NOP_instruc;
            else
                hard_int_insert_bubble <= '0';
            end if;
            if (ctrl_fake_nop = true) then
                ctrl_insert_bubble_t <= '1';
                ctrl_wb_reg_0 := reg_none;
                ctrl_instruc_0 := NOP_instruc;
            else
                ctrl_insert_bubble_t <= '0';
            end if;

        end if;
    end process Control_unit;

end Behavioral;

