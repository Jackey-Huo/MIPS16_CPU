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

entity ID is
    port (
        clk, rst                        : in std_logic;

        -- boot finish flag
        boot_finish                     : in std_logic;

        -- Control Unit
        ctrl_insert_bubble              : in std_logic;

        -- hard keyboard interrupt
        ps2_hold_key_value              : in std_logic_vector (15 downto 0);

        -- IF/ID pipeline storage
        ifid_instruc                    : in std_logic_vector (15 downto 0);

        -- branch signal
        id_pc_branch                    : out std_logic                      := '0';

        id_instruc                      : out std_logic_vector (15 downto 0) := zero16;

        -- ID/EX
        idex_instruc                    : out std_logic_vector (15 downto 0) := zero16;
        idex_reg_a_data                 : out std_logic_vector (15 downto 0) := zero16;
        idex_reg_b_data                 : out std_logic_vector (15 downto 0) := zero16;
        idex_bypass                     : out std_logic_vector (15 downto 0) := zero16;
        idex_reg_wb                     : out std_logic_vector (3 downto 0)  := "0000";
        idex_reg_a_data_real            : in  std_logic_vector (15 downto 0);
        idex_reg_b_data_real            : in  std_logic_vector (15 downto 0);
        idex_bypass_real                : in  std_logic_vector (15 downto 0);

        -- Register
        r0, r1, r2, r3, r4, r5, r6, r7  : in  std_logic_vector (15 downto 0);
        SP, IH, T                       : in  std_logic_vector (15 downto 0);
        EPC, Cause                      : in  std_logic_vector (15 downto 0);
        pc_real                         : in  std_logic_vector (15 downto 0)
    );
end ID;

architecture Behavioral of ID is

begin


    ---------------- ID --------------------------
    ID_unit: process(clk, rst)
    begin
        if (rst = '0' or boot_finish = '0') then
            id_pc_branch <= '0';
            idex_instruc <= NOP_instruc;
        elsif (clk'event and clk='1') then
            if (ctrl_insert_bubble = '1') then  -- all other register don't change
                                                -- idex_instruc, idex_reg_a_data, idex_reg_b_data, idex_bypass, idex_reg_wb, id_pc_branch, id_instruc
            else
                idex_instruc <= ifid_instruc;

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
                    when INT_op =>
                        if (ifid_instruc(3 downto 0) = "1000") then   -- if it's keyboard hardware interrupt
                            id_pc_branch <= '1';
                            idex_bypass <= ps2_hold_key_value;
                            idex_reg_wb <= reg_none;
                        else                                          -- else, it's soft interrupt
                            id_pc_branch <= '1';
                            idex_reg_wb <= reg_none;
                        end if;
                    when EXTEND_TSP_op =>
                        case ifid_instruc(10 downto 8) is
                            when EX_ADDSP_pf_op =>
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
                            when EX_MFEPC_sf_op =>
                                idex_bypass <= EPC;
                                idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
                            when EX_MFCAS_sf_op =>
                                idex_bypass <= Cause;
                                idex_reg_wb <= "0" & ifid_instruc(10 downto 8);
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
                        -- rx value
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
        end if;
    end process ID_unit;

end Behavioral;

