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
        led : out std_logic_vector(15 downto 0);

        -- ram1
        data_ram1 : inout std_logic_vector(15 downto 0);
        addr_ram1 : out std_logic_vector(17 downto 0);
        OE_ram1   : out std_logic;
        WE_ram1   : out std_logic;
        EN_ram1   : out std_logic;

        -- serial
        seri_rdn : out std_logic;
        seri_wrn : out std_logic;
        seri_data_ready : in std_logic;
        seri_tbre       : in std_logic;
        seri_tsre       : in std_logic;

        --digits
        digit1  :   out  STD_LOGIC_VECTOR (6 downto 0) := "1111111";
        digit2  :   out  STD_LOGIC_VECTOR (6 downto 0) := "1111111"
    );
end cpu;

architecture Behavioral of cpu is
    -- register
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(15 downto 0) := "0000000000000000";
    signal SP, IH : std_logic_vector(15 downto 0) := "000000000000000000";
    signal T : std_logic := '0';
    -- pc
    signal pc : std_logic_vector(15 downto 0) := "0000000000000000";
    signal pc_instruc : std_logic_vector(15 downto 0) := "000000000000000";
    -- help signal
    signal ifid_instruc : std_logic_vector(15 downto 0) := "0000000000000000";
    signal idex_ins_op  : std_logic_vector(4 downto 0) := "00000";
    signal idex_reg_a_data : std_logic_vector(15 downto 0) := "0000000000000000";
    signal idex_reg_b_data : std_logic_vector(15 downto 0) := "0000000000000000";
    signal idex_reg_wb : std_logic (2 downto 0) := "000";
    signal idex_alu_op : std_logic (3 downto 0) := "0000";
    signal ex_reg_a_data, ex_reg_b_data : std_logic_vector(15, downto 0) := "0000000000000000";
    signal exme_ins_op : std_logic_vector(4 downto 0) := "00000";
    signal exme_carry, exme_zero, exme_ovr : std_logic := '0';
    signal exme_reg_wb : std_logic_vector(2 downto 0) := "000"
    signal mewb_ins_op : std_logic_vector(4 downto 0) := "00000";


    -- component
    component alu is
        port (
            rst                             : in std_logic                      := '1';
            reg_a, reg_b                    : in std_logic_vector(15 downto 0)  := "000000000000000";
            alu_op                          : in std_logic_vector(3 downto 0)   := "0000";
            result                          : out std_logic_vector(15 downto 0) := "0000000000000000";
            carry_flag, zero_flag, ovr_flag : out std_logic                     := '0'
        );
    end component alu;
begin

    ---------------- IF --------------------------
    IF_unit: process(clk, rst)
    begin
        if (rst = '0') then

        elsif ( clk'event and clk='1' ) then
            pc_instruc <= data_ram1;
            id_op <= data_ram1(15 downto 11);
        end if;
    end process IF_unit;

    ---------------- ID --------------------------
    ID_unit: process(clk, rst)
    begin
        if (clk'event and clk='1') then
            idex_ins_op <= ifid_instruc(15 downto 11);
            case ifid_instruc(15 downto 11) is
                when ADDU_op =>
                    -- rx value
                    reg_decode(idex_reg_a, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- ry value
                    reg_decode(idex_reg_a, "0"&ifid_instruc(7 downto 5), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- write back register index
                    idex_reg_wb <= ifid_instruc(4 downto 2);
                    -- alu operat
                    idex_alu_op <= alu_add;
                when ADDIU_op =>
                    -- rx value
                    reg_decode(idex_reg_a, "0"&ifid_instruc(10 downto 8), r0, r1, r2, r3, r4, r5, r6, r7, SP, IH);
                    -- immediate value, put into reg_b
                    idex_reg_b_data <= sign_extend8(ifid_instruc(7 downto 0));
                    -- write back register index
                    idex_reg_wb <= ifid_instruc(10 downto 8);
                    -- alu operat
                    idex_alu_op <= alu_add;
                when others =>
                    idex_reg_a_data <= "0000000000000000";
                    idex_reg_b_data <= "0000000000000000";
                    idex_reg_wb <= "000";
                    idex_alu_op <= alu_nop;
            end case;
        end if;
    end process ID_unit;

    ---------------- EX --------------------------
    EX_unit: process(clk, rst)
    begin
        if (clk'event and clk='1') then
            case idex_ins_op is
                when ADDU_op =>
                    ex_reg_a_data <= idex_reg_a_data;
                    ex_reg_b_data <= idex_reg_b_data;
                    ex_alu_op <= idex_alu_op;
                when ADDU_op =>
                    ex_reg_a_data <= idex_reg_a_data;
                    ex_reg_b_data <= idex_reg_b_data;
                    ex_alu_op <= idex_alu_op;
                when others =>
                    ex_alu_op <= alu_nop;
            end case;
        end if;
    end process EX_unit;

    ALU_comp: alu port map (rst, ex_reg_a_data, ex_reg_b_data, ex_alu_op, exme_result,
                                exme_carry, exme_zero, exme_ovr);

    ---------------- ME --------------------------
    ME_unit: process(clk, rst)
    begin
    end process ME_unit;

    ---------------- WB --------------------------
    WB_unit: process(clk, rst)
    begin
    end process WB_unit;

    ------------ Control Unit --------------------
    Control_unit: process(clk, rst)
    begin
    end process Control_unit;




end Behavioral;

