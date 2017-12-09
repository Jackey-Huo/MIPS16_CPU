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

entity WB is
    port (
        clk, rst                        : in std_logic;

        boot_finish                     : in std_logic;

        --MEM/WB pipeline storage
        mewb_instruc                    : in std_logic_vector (15 downto 0);
        mewb_result                     : in std_logic_vector (15 downto 0);
        mewb_readout                    : in std_logic_vector (15 downto 0);
        mewb_reg_wb                     : in std_logic_vector (3 downto 0);
        mewb_bypass                     : in std_logic_vector (15 downto 0);

        wb_reg_data                     : out std_logic_vector (15 downto 0) := zero16;

        -- register
        r0, r1, r2, r3, r4, r5, r6, r7  : out std_logic_vector (15 downto 0) := zero16;
        SP, IH, T                       : out std_logic_vector (15 downto 0) := zero16
    );
end WB;

architecture Behavioral of WB is

begin

    ---------------- WB --------------------------
    WB_unit: process(clk, rst)
        variable wb_data : std_logic_vector(15 downto 0);
        variable wb_enable : boolean := false;
    begin
          if rst = '0' or boot_finish = '0' then
                r0 <= zero16;
                r1 <= zero16;
                r2 <= zero16;
                r3 <= zero16;
                r4 <= zero16;
                r5 <= zero16;
                r6 <= zero16;
                r7 <= zero16;
                SP <= zero16;
                IH <= zero16;
                T <= zero16;
                wb_enable := false;
        elsif (clk'event and clk='1') then
            case mewb_instruc(15 downto 11) is
                when ADDIU_op | ADDIU3_op | EXTEND_RRI_op | MOVE_op | CMPI_op | ADDSP3_op =>
                    wb_data := mewb_result;
                    wb_enable := true;
                when EXTEND_ALU3_op => -- ADDU, SUBU
                    wb_data := mewb_result;
                    wb_enable := true;
                when LI_op =>
                    wb_data := mewb_bypass;
                    wb_enable := true;
                when LW_op | LW_SP_op =>
                    wb_data := mewb_readout;
                    wb_enable := true;
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
                        when EX_AND_sf_op | EX_OR_sf_op | EX_NEG_sf_op | EX_NOT_sf_op | EX_SRLV_sf_op | EX_CMP_sf_op | EX_SLTU_sf_op =>
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
                    case mewb_instruc(7 downto 0) is
                        when EX_MFIH_sf_op | EX_MTIH_sf_op | EX_MFEPC_sf_op | EX_MFCAS_sf_op =>
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
                        -- for INT register EPC and Cause, they will be assigned 
                        -- at INT module, that is, no instruction can write them
                end case;
            else
                wb_reg_data <= zero16;
            end if;

        end if;
    end process WB_unit;

end Behavioral;

