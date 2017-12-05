----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:18:07 12/05/2017 
-- Design Name: 
-- Module Name:    int - Behavioral 
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

entity int_ctrl is
    port(
        clk             : in std_logic;
        rst             : in std_logic;
        -- current instruction for software INT
        cur_instruc     : in std_logic_vector (15 downto 0);
        int_instruc     : out std_logic_vector (15 downto 0);
        int_flag        : out std_logic;
        led             : out std_logic_vector (2 downto 0)
    );
end int_ctrl;

architecture Behavioral of int_ctrl is

type INTStateMachine is (int_idle, int_busy, int_save1, int_save2,
    int_exe1, int_exe2, int_exe3, int_exe4, int_exe5, int_exe6,
    int_restore1);

signal int_state : INTStateMachine := int_idle;
begin

    process(clk, rst)
        variable imm : std_logic_vector (7 downto 0) := x"00";
    begin
        if rst = '0' then
            int_state <= int_idle;
            imm := x"00";
        elsif clk'event and clk = '1' then
            if int_state = int_idle and cur_instruc (15 downto 11) = INT_op then
                -- enter INT mode
                int_state <= int_busy;
            end if;

            case int_state is
                when int_idle =>
                    int_flag <= '0';
                    int_instruc <= (others => '0');
                when others => int_flag <= '1';
            end case;

            case int_state is
                when int_busy =>
                    --int_state <= int_save1;
                    int_state <= int_exe1;
                --when int_save1 => -- save R0 | R6 do not need to be restored
                --    -- SW_SP R0
                --    int_instruc <= "11010" & "000" & x"00";
                --    int_state <= int_save2;
                --when int_save2 =>
                --    -- ADDSP 0x01
                --    int_instruc <= "01100" & "011" & x"01";
                --    int_state <= int_exe1;
                when int_exe1 =>
                    -- LI R6 Imm
                    imm := x"0" & cur_instruc(3 downto 0);
                    int_instruc <= "01101" & "110" & imm;
                    int_state <= int_exe2;
                when int_exe2 =>
                    -- SW_SP R6 0x00
                    int_instruc <= "11010" & "110" & x"00";
                    int_state <= int_exe3;
                when int_exe3 =>
                    -- MFPC R6
                    int_instruc <= "11101" & "110" & "01000000";
                    int_state <= int_exe4;
                when int_exe4 =>
                    -- SW_SP R6 0x01
                    int_instruc <= "11010" & "110" & x"01";
                    int_state <= int_exe5;
                when int_exe5 =>
                    -- LI R6 monitor : Set R6 to be target address
                    int_instruc <= "01101" & "110" & monitor_delint_addr(7 downto 0);
                    int_state <= int_exe6;
                when int_exe6 =>
                    -- JR R6
                    int_instruc <= "11101" & "110" & x"00";
                    int_state <= int_idle;
                    led <= "111";
                --when int_restore1 =>
                --    -- LW_SP R0 0xFF
                --    int_instruc <= "10010" & "000" & x"FF";
                --    int_state <= int_idle;
                when others =>
                    int_instruc <= (others => '0');
                    int_state <= int_idle;
            end case;
        end if;
    end process;

end Behavioral;

