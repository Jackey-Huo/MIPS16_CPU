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

    constant LI_op    : std_logic_vector (4 downto 0) := "01101";
    constant SLL_op   : std_logic_vector (4 downto 0) := "00110";
    constant LW_op    : std_logic_vector (4 downto 0) := "10011";
    constant SW_op    : std_logic_vector (4 downto 0) := "11011";
    constant ADDU_op  : std_logic_vector (4 downto 0) := "11100";
    constant ADDIU_op : std_logic_vector (4 downto 0) := "01001";
    constant BNEZ_op  : std_logic_vector (4 downto 0) := "00101";
    constant NOP_op   : std_logic_vector (4 downto 0) := "00001";

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
    constant alu_nop  : std_logic_vector (3 downto 0) := "1111";

    constant zero16   : std_logic_vector (15 downto 0) := "0000000000000000";
    constant zero17   : std_logic_vector (16 downto 0) := "00000000000000000";
    constant zero18   : std_logic_vector (17 downto 0) := "000000000000000000";
    constant zero5    : std_logic_vector (4 downto 0)  := "00000";

    constant reg_none : std_logic_vector (3 downto 0)  := "1111";

    constant chs_idex_reg     : std_logic_vector (2 downto 0) := "000";
    constant chs_alu_result   : std_logic_vector (2 downto 0) := "001";
    constant chs_mewb_result  : std_logic_vector (2 downto 0) := "010";
    constant chs_mewb_readout : std_logic_vector (2 downto 0) := "011";
    constant chs_wb_reg_data  : std_logic_vector (2 downto 0) := "100";


    ------ VGA Section ------
    -------------------------
    constant vga480_full_w : integer := 799;
    constant vga480_full_h : integer := 524;
    constant vga480_w : integer := 640;
    constant vga480_h : integer := 480;
    constant vga480_hs_start : integer := 656;
    constant vga480_hs_end : integer := 752;
    constant vga480_vs_start : integer := 490;
    constant vga480_vs_end : integer := 492;

    procedure reg_decode(signal reg_data: out std_logic_vector(15 downto 0);
                        addr: in std_logic_vector(3 downto 0);
                        signal r0, r1, r2, r3, r4, r5, r6, r7, SP, IH: in std_logic_vector(15 downto 0));

    procedure conflict_detect(signal ctrl_insert_bubble               : out std_logic;
                             signal ctrl_mux_reg_a, ctrl_mux_reg_b    : out std_logic_vector (2 downto 0);
                             ctrl_rd_reg_a, ctrl_rd_reg_b             : in std_logic_vector (3 downto 0);
                             ctrl_wb_reg1, ctrl_wb_reg2, ctrl_wb_reg3 : in std_logic_vector (3 downto 0);
                             ctrl_instruc_0, ctrl_instruc_1           : in std_logic_vector (15 downto 0);
                             ctrl_instruc_2, ctrl_instruc_3           : in std_logic_vector (15 downto 0));

    function sign_extend11(imm : std_logic_vector(10 downto 0))
                            return std_logic_vector;

    function sign_extend8(imm : std_logic_vector(7 downto 0))
                            return std_logic_vector;

    function sign_extend5(imm : std_logic_vector(4 downto 0))
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

    function sign_extend5(imm : std_logic_vector(4 downto 0))
                                return std_logic_vector is
    begin 
        if imm(4) = '1' then
            return "11111111111" & imm;
        else
            return "00000000000" & imm;
        end if;
    end sign_extend5;


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

    procedure conflict_detect(signal ctrl_insert_bubble               : out std_logic;
                             signal ctrl_mux_reg_a, ctrl_mux_reg_b    : out std_logic_vector (2 downto 0);
                             ctrl_rd_reg_a, ctrl_rd_reg_b             : in std_logic_vector (3 downto 0);
                             ctrl_wb_reg1, ctrl_wb_reg2, ctrl_wb_reg3 : in std_logic_vector (3 downto 0);
                             ctrl_instruc_0, ctrl_instruc_1           : in std_logic_vector (15 downto 0);
                             ctrl_instruc_2, ctrl_instruc_3           : in std_logic_vector (15 downto 0)) is
        variable conflict_instruc_a         : std_logic_vector (15 downto 0)  := NOP_instruc;
        variable conflict_instruc_number_a  : integer                         := 0;
        variable conflict_instruc_b         : std_logic_vector (15 downto 0)  := NOP_instruc;
        variable conflict_instruc_number_b  : integer                         := 0;
        variable insert_bubble              : std_logic                       := '0';
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


        case conflict_instruc_a(15 downto 11) is
            when ADDU_op | ADDIU_op =>
                insert_bubble := '0';
                case conflict_instruc_number_a is
                    when 1 =>
                        ctrl_mux_reg_a <= chs_alu_result;     --
                    when 2 =>                                 --                 ---
                        ctrl_mux_reg_a <= chs_mewb_result;    --    idex_reg_a--| M |
                    when 3 =>                                 --    alu_result--|   |
                        ctrl_mux_reg_a <= chs_wb_reg_data;    --   mewb_result--| U |--ex_alu_reg_a
                    when others =>                            --  mewb_readout--|   |
                        ctrl_mux_reg_a <= chs_idex_reg;       --   wb_reg_data--| X |
                end case;                                     --                 ---
            when LW_op =>
                if (conflict_instruc_number_a = 0) then
                    insert_bubble := '1';
                else
                    insert_bubble := '0';
                end if;
            when others =>
                ctrl_mux_reg_a <= chs_idex_reg;
                insert_bubble := '0';
        end case;

        case conflict_instruc_b(15 downto 11) is
            when ADDU_op | ADDIU_op =>
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
            when LW_op =>
                if (conflict_instruc_number_b = 0) then
                    insert_bubble := '1';
                else
                    insert_bubble := '0';
                end if;
            when others =>
                insert_bubble := '0';
                ctrl_mux_reg_b <= chs_idex_reg;
        end case;

    end procedure conflict_detect;





 
end helper;
