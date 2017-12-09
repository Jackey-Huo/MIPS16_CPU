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

entity MEM is
    port (
        clk, rst                        : in std_logic;

        -- flash load
        flash_load_finish               : in std_logic;
        boot_ram2_read_enable           : in std_logic;
        boot_ram2_write_enable          : in std_logic;
        boot_ram2_write_addr            : in std_logic_vector (17 downto 0);
        boot_ram2_write_data            : in std_logic_vector (15 downto 0);

        -- vga
        vga_ram2_read_addr              : in std_logic_vector;
        vga_ram2_read_enable            : in std_logic;

        boot_finish                     : in std_logic;
        boot_write_addr                 : in std_logic_vector (17 downto 0);
        boot_write_data                 : in std_logic_vector (15 downto 0);
        boot_write_enable               : in std_logic;
        boot_read_enable                : in std_logic;

        -- EX/MEM pipeline storage
        exme_instruc                    : in std_logic_vector (15 downto 0);
        exme_result                     : in std_logic_vector (15 downto 0);
        exme_reg_wb                     : in std_logic_vector (3 downto 0) ;
        exme_bypass                     : in std_logic_vector (15 downto 0);

        -- MEM variables
        me_read_enable                  : out std_logic                      := '0';
        me_write_enable                 : out std_logic                      := '0';
        me_read_addr                    : out std_logic_vector (17 downto 0) := zero18;
        me_write_addr                   : out std_logic_vector (17 downto 0) := zero18;
        me_write_data                   : out std_logic_vector (15 downto 0) := zero16;

        ram2_read_enable                : out std_logic                      := '0';
        ram2_write_enable               : out std_logic                      := '0';
        ram2_read_addr, ram2_write_addr : out std_logic_vector (17 downto 0) := zero18;
        ram2_write_data                 : out std_logic_vector (15 downto 0) := zero16;

        seri_wrn_t, seri_rdn_t          : out std_logic                      := '0';
        seri1_read_enable               : out std_logic                      := '0';
        seri1_write_enable              : out std_logic                      := '0';
        seri1_write_enable_real         : out std_logic                      := '0';
        seri1_ctrl_read_en              : out std_logic                      := '0';

        -- hard int address
        hardint_keyboard_addr           : in std_logic_vector (15 downto 0);

        --MEM/WB pipeline storage
        mewb_instruc                    : out std_logic_vector (15 downto 0) := zero16;
        mewb_result                     : out std_logic_vector (15 downto 0) := zero16;
        mewb_reg_wb                     : out std_logic_vector (3 downto 0)  := "0000";
        mewb_bypass                     : out std_logic_vector (15 downto 0) := zero16

    );
end MEM;

architecture Behavioral of MEM is

begin

    ---------------- ME --------------------------
    ME_unit: process(clk, rst)
    begin
        if flash_load_finish = '0' then
            ram2_read_enable    <= boot_ram2_read_enable;
            ram2_write_enable   <= boot_ram2_write_enable;
            ram2_write_addr     <= boot_ram2_write_addr;
            ram2_write_data     <= boot_ram2_write_data;
        else
            ram2_read_addr      <= vga_ram2_read_addr;
            ram2_read_enable    <= vga_ram2_read_enable;
            ram2_write_enable   <= '0';
            ram2_write_addr     <= zero18;
            ram2_write_data     <= zero16;
        end if;

        if (rst = '0') then
            mewb_instruc <= NOP_instruc;
            me_read_enable <= '0';
            me_write_enable <= '0';
            seri1_read_enable <= '0';
            seri1_write_enable <= '0';
            seri1_ctrl_read_en <= '0';
        elsif boot_finish = '0' then
            me_read_enable <= boot_read_enable;
            me_write_enable <= boot_write_enable;
            me_write_addr <= boot_write_addr;
            me_write_data <= boot_write_data;
        elsif (clk'event and clk='1') then
            mewb_instruc <= exme_instruc;
            me_read_enable <= '0';
            me_write_enable <= '0';
            seri1_read_enable <= '0';
            seri1_write_enable <= '0';
            seri1_ctrl_read_en <= '0';
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
                        when seri1_data_addr =>    -- 0xBF00 serial 1 data
                            seri1_write_enable <= '0';
                            seri1_read_enable <= '1';
                            mewb_reg_wb <= exme_reg_wb;
                        when seri1_ctrl_addr =>    -- 0xBF01 serial 1 control signal
                            seri1_ctrl_read_en <= '1';
                            mewb_reg_wb <= exme_reg_wb;
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
                        when seri1_ctrl_addr =>            -- not allowed
                        when seri2_data_addr =>            -- not support yet
                        when seri2_ctrl_addr =>
                        when others => -- sw in SRAM
                            me_write_addr <= "00" & exme_result;
                            me_write_data <= exme_bypass;
                            me_read_enable <= '0';
                            me_write_enable <= '1';
                    end case;
                when INT_op =>
                    case exme_instruc(3 downto 0) is
                        when "1000" =>                 -- hard interrupt
                            me_write_addr <= "00" & hardint_keyboard_addr;
                            me_write_data <= exme_bypass;
                            me_read_enable <= '0';
                            me_write_enable <= '1';
                        when others =>
                                                      -- soft interrupt, do nothing
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
                        when EX_MFIH_sf_op | EX_MTIH_sf_op | EX_MFEPC_sf_op | EX_MFCAS_sf_op  =>
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


end Behavioral;

