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

    constant LI_op    : std_logic_vector(4 downto 0) := "01101";
    constant SLL_op   : std_logic_vector(4 downto 0) := "00110";
    constant LW_op    : std_logic_vector(4 downto 0) := "10011";
    constant SW_op    : std_logic_vector(4 downto 0) := "11011";
    constant ADDU_op  : std_logic_vector(4 downto 0) := "11100";
    constant ADDIU_op : std_logic_vector(4 downto 0) := "01001";
    constant BNEZ_op  : std_logic_vector(4 downto 0) := "00101";
    constant NOP_op   : std_logic_vector(4 downto 0) := "00001";


    constant alu_add  : std_logic_vector(3 downto 0) := "0000";
    constant alu_sub  : std_logic_vector(3 downto 0) := "0001";
    constant alu_and  : std_logic_vector(3 downto 0) := "0010";
    constant alu_or   : std_logic_vector(3 downto 0) := "0011";
    constant alu_xor  : std_logic_vector(3 downto 0) := "0100";
    constant alu_not  : std_logic_vector(3 downto 0) := "0101";
    constant alu_sll  : std_logic_vector(3 downto 0) := "0110";
    constant alu_srl  : std_logic_vector(3 downto 0) := "0111";
    constant alu_sra  : std_logic_vector(3 downto 0) := "1000";
    constant alu_rol  : std_logic_vector(3 downto 0) := "1001";
    constant alu_nop  : std_logic_vector(3 downto 0) := "1111";

    constant zero16   : std_logic_vector(15 downto 0) := "0000000000000000";
    constant zero17   : std_logic_vector(16 downto 0) := "00000000000000000";
    constant zero5    : std_logic_vector(4 downto 0)  := "00000";


    procedure reg_decode(signal reg_data: out std_logic_vector(15 downto 0);
                        addr: in std_logic_vector(3 downto 0);
                        signal r0, r1, r2, r3, r4, r5, r6, r7, SP, IH: in std_logic_vector(15 downto 0));

    function sign_extend11(imm : std_logic_vector(10 downto 0))
                            return std_logic_vector;

    function sign_extend8(imm : std_logic_vector(7 downto 0))
                            return std_logic_vector;

    function zero_extend8(imm : std_logic_vector(7 downto 0))
                            return std_logic_vector;

    function zero_extend3(imm : std_logic_vector(2 downto 0))
                            return std_logic_vector;

end helper;

package body helper is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

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

 
end helper;
