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

entity EXE is
    port (
        clk, rst                : in std_logic;

        -- Control unit signal
        ctrl_insert_bubble              : in  std_logic;
        -- boot loader
        boot_finish                     : in  std_logic;

        -- ID/EX
        idex_instruc                    : in  std_logic_vector (15 downto 0);
        idex_reg_a_data_real            : in  std_logic_vector (15 downto 0);
        idex_reg_b_data_real            : in  std_logic_vector (15 downto 0);
        idex_bypass_real                : in  std_logic_vector (15 downto 0);
        idex_reg_wb                     : in  std_logic_vector (3 downto 0) ;

        -- EX layer variables
        ex_reg_a_data, ex_reg_b_data    : out std_logic_vector (15 downto 0) := zero16;
        ex_alu_op                       : out std_logic_vector (3 downto 0)  := "0000";

        -- EX/MEM pipeline storage
        exme_instruc                    : out std_logic_vector (15 downto 0)  := zero16;
        -- NOTICE: carry and overflow is not required
        exme_reg_wb                     : out std_logic_vector (3 downto 0)  := "0000";
        exme_bypass                     : out std_logic_vector (15 downto 0) := zero16
    );
end EXE;

architecture Behavioral of EXE is

begin
    ---------------- EX --------------------------
    EX_unit: process(clk, rst)
        variable ex_instruc : std_logic_vector (15 downto 0) := NOP_instruc;
    begin
        if (rst = '0' or boot_finish = '0') then
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
                when ADDIU_op | ADDIU3_op | LW_op | LW_SP_op | SW_op | SW_SP_op | MOVE_op |ADDSP3_op =>
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
                when CMPI_op =>
                    ex_reg_a_data <= idex_reg_a_data_real;
                    ex_reg_b_data <= idex_reg_b_data_real;
                    ex_alu_op <= alu_cmp;
                    exme_reg_wb <= idex_reg_wb;
                when LI_op =>
                    ex_alu_op <= alu_nop;
                    exme_reg_wb <= idex_reg_wb;
                    exme_bypass <= idex_reg_a_data_real;
                when INT_op =>
                    ex_alu_op <= alu_nop;
                    if (ex_instruc(4 downto 0) = "1000") then
                        exme_bypass <= idex_reg_a_data_real;    -- TODO
                        exme_reg_wb <= reg_none;
                    else
                        exme_reg_wb <= reg_none;
                    end if;
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
                        when EX_SLTU_sf_op =>
                            ex_reg_a_data <= idex_reg_a_data_real;
                            ex_reg_b_data <= idex_reg_b_data_real;
                            ex_alu_op <= alu_less;
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
                        when EX_MFIH_sf_op | EX_MTIH_sf_op | EX_MFEPC_sf_op | EX_MFCAS_sf_op =>
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

end Behavioral;

