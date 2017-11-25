----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:28:13 11/18/2017 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

entity alu is
    port (
        rst                             : in std_logic                      := '1';
        reg_a, reg_b                    : in std_logic_vector(15 downto 0)  := zero16;
        alu_op                          : in std_logic_vector(3 downto 0)   := "0000";
        result                          : out std_logic_vector(15 downto 0) := zero16;
        carry_flag, zero_flag, ovr_flag : out std_logic                     := '0'
    );
end alu;


architecture Behavioral of alu is
    signal a1, b1, result1        : std_logic_vector(16 downto 0) := zero17;
    signal ovr_add_en, ovr_sub_en : std_logic;
    signal sim_sign, diff_high2   : std_logic;
begin

    a1 <= zero17 when (rst = '0') else "0" & reg_a;
    b1 <= zero17 when (rst = '0') else"0" & reg_b;

    alu : process(a1, b1, alu_op, rst)
    begin
        if (rst = '0') then
            result1 <= zero17;
        else
            case alu_op is
              when alu_add =>
                result1 <= a1 + b1;
              when alu_sub =>
                result1 <= a1 + (not(b1(15 downto 0))+1);
              when alu_and =>
                result1 <= a1 and b1;
              when alu_or =>
                result1 <= a1 or b1;
              when alu_xor =>
                result1 <= a1 xor b1;
              when alu_not =>         
                result1 <= not(a1);
              when alu_sll =>
                result1 <= std_logic_vector( shift_left(unsigned(a1),
                          to_integer(unsigned(b1(4 downto 0)))) );
              when alu_srl =>     
                result1(15 downto 0) <= std_logic_vector( shift_right(unsigned(a1(15 downto 0)),
                          to_integer(unsigned(b1(4 downto 0)))) );
              when alu_sra =>                             
                result1(15 downto 0) <= std_logic_vector( shift_right(signed(a1(15 downto 0)),
                          to_integer(unsigned(b1(4 downto 0)))) );
              when alu_rol =>
                result1(15 downto 0) <= std_logic_vector( rotate_left(unsigned(a1(15 downto 0)),
                          to_integer(unsigned(b1(4 downto 0)))) );
              when alu_cmp =>
                  if (a1 = b1) then
                      result1 <= zero17;
                  else
                      result1 <= "00000000000000001";
                  end if;
              when others =>
                result1 <= "ZZZZZZZZZZZZZZZZZ";
            end case;
        end if;
    end process alu;

    result <= "0000000000000000" when (rst = '0') else result1(15 downto 0);

    carry_flag <= '0' when (rst = '0') else result1(16);

    zero_flag <= '0' when (rst = '0') else
                 '1' when (result1 = "00000000000000000") else '0';

    ovr_add_en <= '1' when (alu_op = alu_add) else '0';
    ovr_sub_en <= '1' when (alu_op = alu_sub) else '0';
    sim_sign <= '1' when (a1(15) = b1(15)) else '0';
    diff_high2 <= '1' when (result1(16) /= result1(15)) else '0';
    ovr_flag  <= '0' when (rst = '0') else ( (ovr_add_en and sim_sign and diff_high2) or (ovr_sub_en and not(sim_sign) and diff_high2) );

end Behavioral;

