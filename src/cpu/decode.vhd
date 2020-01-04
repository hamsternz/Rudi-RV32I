--###############################################################################
--# decoder.vhd - The RISC-V RV32I instruction decoder
--#
--# Part of the Rudi-RV32I project
--#
--# See https://github.com/hamsternz/Rudi-RV32I
--#
--# MIT License
--#
--###############################################################################
--#
--# Copyright (c) 2020 Mike Field
--#
--# Permission is hereby granted, free of charge, to any person obtaining a copy
--# of this software and associated documentation files (the "Software"), to deal
--# in the Software without restriction, including without limitation the rights
--# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--# copies of the Software, and to permit persons to whom the Software is
--# furnished to do so, subject to the following conditions:
--#
--# The above copyright notice and this permission notice shall be included in all
--# copies or substantial portions of the Software.
--#
--# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--# SOFTWARE.
--#
--###############################################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
  port ( reset                  : in  STD_LOGIC;
         minimize_size          : in  STD_LOGIC;
         instr                  : in  STD_LOGIC_VECTOR(31 downto 0);
         out_immed              : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');         

         out_reg_a              : out STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
         out_select_a           : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
         out_zero_a             : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');

         out_reg_b              : out STD_LOGIC_VECTOR(4 downto 0)  := (others => '0');
         out_select_b           : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');
         out_zero_b             : out STD_LOGIC_VECTOR(0 downto 0)  := (others => '0');

         out_pc_mode            : out STD_LOGIC_VECTOR(1 downto 0) := "00";
         out_pc_jump_offset     : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
         out_pc_branch_offset   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
         out_loadstore_offset   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

         out_bus_write          : out STD_LOGIC;
         out_bus_enable         : out STD_LOGIC;
         out_bus_width          : out STD_LOGIC_VECTOR(1 downto 0);

         out_alu_mode           : out STD_LOGIC_VECTOR(2 downto 0) := "000";
         out_branch_test_enable : out STD_LOGIC := '0';
         out_branch_test_mode   : out STD_LOGIC_VECTOR(2 downto 0) := "000";
         out_shift_mode         : out STD_LOGIC_VECTOR(1 downto 0) := "00";

         out_sign_ex_mode       : out STD_LOGIC_VECTOR(0 downto 0) := "0";
         out_sign_ex_width      : out STD_LOGIC_VECTOR(1 downto 0) := "00";

         out_result_src         : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');         
         out_rdest              : out STD_LOGIC_VECTOR(4 downto 0) := (others => '0'));
end entity;

architecture Behavioral of decoder is
   -- decoding the instruction
   signal opcode  : STD_LOGIC_VECTOR( 6 downto 0);
   signal rd      : STD_LOGIC_VECTOR( 4 downto 0);
   signal rs1     : STD_LOGIC_VECTOR( 4 downto 0);
   signal rs2     : STD_LOGIC_VECTOR( 4 downto 0);
   signal func3   : STD_LOGIC_VECTOR( 2 downto 0);
   signal func7   : STD_LOGIC_VECTOR( 6 downto 0);
   signal immed_I : STD_LOGIC_VECTOR(31 downto 0);
   signal immed_S : STD_LOGIC_VECTOR(31 downto 0);
   signal immed_B : STD_LOGIC_VECTOR(31 downto 0);
   signal immed_U : STD_LOGIC_VECTOR(31 downto 0);
   signal immed_J : STD_LOGIC_VECTOR(31 downto 0);
   signal instr31 : STD_LOGIC_VECTOR(31 downto 0);

   -- MUXing of the A and B data
   constant A_BUS_REGISTER              : STD_LOGIC_VECTOR(0 downto 0) := "0";
   constant A_BUS_PC                    : STD_LOGIC_VECTOR(0 downto 0) := "1";

   constant B_BUS_REGISTER              : STD_LOGIC_VECTOR(0 downto 0) := "0";
   constant B_BUS_IMMEDIATE             : STD_LOGIC_VECTOR(0 downto 0) := "1";
   
   -- Deciding how the Program counter updates
   constant PC_JMP_RELATIVE             : STD_LOGIC_VECTOR(1 downto 0) := "00";
   constant PC_JMP_REG_RELATIVE         : STD_LOGIC_VECTOR(1 downto 0) := "01";
   constant PC_JMP_RELATIVE_CONDITIONAL : STD_LOGIC_VECTOR(1 downto 0) := "10";
   constant PC_RESET_STATE              : STD_LOGIC_VECTOR(1 downto 0) := "11";
   
   -- Tests for conditional branching  
   constant BRANCH_TEST_EQ              : STD_LOGIC_VECTOR(2 downto 0) := "000";
   constant BRANCH_TEST_NE              : STD_LOGIC_VECTOR(2 downto 0) := "001";
   constant BRANCH_TEST_TRUE            : STD_LOGIC_VECTOR(2 downto 0) := "010";
   constant BRANCH_TEST_FALSE           : STD_LOGIC_VECTOR(2 downto 0) := "011";
   constant BRANCH_TEST_LT              : STD_LOGIC_VECTOR(2 downto 0) := "100";
   constant BRANCH_TEST_GE              : STD_LOGIC_VECTOR(2 downto 0) := "101";
   constant BRANCH_TEST_LTU             : STD_LOGIC_VECTOR(2 downto 0) := "110";
   constant BRANCH_TEST_GEU             : STD_LOGIC_VECTOR(2 downto 0) := "111";

   -- Logical and addition functions
   constant ALU_OR                      : STD_LOGIC_VECTOR(2 downto 0) := "000";
   constant ALU_AND                     : STD_LOGIC_VECTOR(2 downto 0) := "001";
   constant ALU_XOR                     : STD_LOGIC_VECTOR(2 downto 0) := "010";
   constant ALU_UNUSED                  : STD_LOGIC_VECTOR(2 downto 0) := "011";
   constant ALU_ADD                     : STD_LOGIC_VECTOR(2 downto 0) := "100";
   constant ALU_SUB                     : STD_LOGIC_VECTOR(2 downto 0) := "101";
   constant ALU_LESS_THAN_SIGNED        : STD_LOGIC_VECTOR(2 downto 0) := "110";
   constant ALU_LESS_THAN_UNSIGNED      : STD_LOGIC_VECTOR(2 downto 0) := "111";
   
   -- Barrel shifter options
   constant SHIFTER_LEFT_LOGICAL        : STD_LOGIC_VECTOR(1 downto 0) := "00";
   constant SHIFTER_LEFT_ARITH          : STD_LOGIC_VECTOR(1 downto 0) := "01";  -- not used
   constant SHIFTER_RIGHT_LOGICAL       : STD_LOGIC_VECTOR(1 downto 0) := "10";
   constant SHIFTER_RIGHT_ARITH         : STD_LOGIC_VECTOR(1 downto 0) := "11";
   
   -- Selction of what is going to the reginster file
   constant RESULT_ALU                  : STD_LOGIC_VECTOR(1 downto 0) := "00";
   constant RESULT_SHIFTER              : STD_LOGIC_VECTOR(1 downto 0) := "01";
   constant RESULT_MEMORY               : STD_LOGIC_VECTOR(1 downto 0) := "10";
   constant RESULT_PC_PLUS_4            : STD_LOGIC_VECTOR(1 downto 0) := "11";

   constant SIGN_EX_WIDTH_B             : STD_LOGIC_VECTOR(1 downto 0) := "00";
   constant SIGN_EX_WIDTH_H             : STD_LOGIC_VECTOR(1 downto 0) := "01";
   constant SIGN_EX_WIDTH_W             : STD_LOGIC_VECTOR(1 downto 0) := "10";
   constant SIGN_EX_WIDTH_X             : STD_LOGIC_VECTOR(1 downto 0) := "11";

   constant SIGN_EX_SIGNED              : STD_LOGIC_VECTOR(0 downto 0) := "0";
   constant SIGN_EX_UNSIGNED            : STD_LOGIC_VECTOR(0 downto 0) := "1";

begin
   with instr(31) select instr31 <= x"FFFFFFFF" when '1', x"00000000" when others;

   -- Break down the R, I, S, B, U. J-type instructions, as per ISA
   opcode  <= instr( 6 downto 0);
   rd      <= instr(11 downto 7);
   func3   <= instr(14 downto 12);
   func7   <= instr(31 downto 25);
   rs1     <= instr(19 downto 15);
   rs2     <= instr(24 downto 20);
   immed_I <= instr31(31 downto 12) & instr(31 downto 20);
   immed_S <= instr31(31 downto 12) & instr(31 downto 25) & instr(11 downto 7);
   immed_B <= instr31(31 downto 12) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & "0";
   immed_U <= instr(31 downto 12) & x"000";
   immed_J <= instr31(31 downto 20) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & "0" ;

instr_decode: process(opcode, rd, func3, func7, immed_I, immed_S, immed_B, immed_U, immed_J, rs1, rs2, reset)
   begin

      if 1 = 1 then   -- reserve structure for resets or interrupt requiests
         -- Set defaults for invalid instructions
         out_immed            <= immed_I;

         out_reg_a            <= rs1; 
         out_select_a         <= A_BUS_REGISTER;
         out_zero_a           <= "0";

         out_reg_b            <= rs2;
         out_select_b         <= B_BUS_REGISTER;
         out_zero_b           <= "0";

         out_pc_mode          <= PC_JMP_RELATIVE_CONDITIONAL;
         out_branch_test_mode <= func3;
         out_branch_test_enable <= '0';

         out_pc_jump_offset   <= immed_J;
         out_pc_branch_offset <= immed_B;
         if opcode(5) = '1' then
            out_loadstore_offset <= immed_S;
         else
            out_loadstore_offset <= immed_I;
         end if;      

         out_alu_mode         <= ALU_ADD;  -- Adds are used for memory addressing when minimal size is built
         out_shift_mode       <= SHIFTER_LEFT_LOGICAL;
         out_result_src       <= RESULT_ALU;         
         out_rdest            <= "00000";  -- By default write to register zero (which stays zero)
         out_bus_width        <= func3(1 downto 0);
         out_bus_write        <= '0';
         out_bus_enable       <= '0';
         out_sign_ex_width    <= SIGN_EX_WIDTH_W;
         out_sign_ex_mode     <= SIGN_EX_UNSIGNED;

         case opcode is 
            ----------------- LUI --------------------
            when "0110111" =>    
                out_immed            <= immed_U;
                out_zero_a           <= "1";
                out_select_b         <= B_BUS_IMMEDIATE;
                out_alu_mode         <= ALU_OR; 
                out_rdest            <= rd;
            ----------------- AUIPC-------------------
            when "0010111" =>
                out_immed            <= immed_U;
                out_select_a         <= A_BUS_PC;                
                out_select_b         <= B_BUS_IMMEDIATE;
                out_alu_mode         <= ALU_ADD;
                out_rdest            <= rd;
            ----------------- JAL  -------------------
            when "1101111" =>
                -- offsets already set as defaults
                out_result_src       <= RESULT_PC_PLUS_4;
                out_rdest            <= rd;
                out_pc_mode          <= PC_JMP_RELATIVE;

            ----------------- JALR -------------------
            when "1100111" =>
                if func3 = "000" then
                   -- offsets already set as defaults
                   out_select_b      <= B_BUS_IMMEDIATE;
                   out_result_src    <= RESULT_PC_PLUS_4;
                   out_rdest         <= rd;
                   out_pc_mode       <= PC_JMP_REG_RELATIVE;
                end if;

            ----------------- BEQ, BNE, BLT, BGE, BLTU, BGEU  -------------------
            when "1100011" =>
                case func3 is
                   when "000"  =>
                      ----------------- BEQ  -------------------
                      -- offset and branch condition already set as defaults
                      out_branch_test_enable  <= '1';
                      out_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                   when "001"  =>
                      ----------------- BNE  ------------------
                      -- offsets already set as defaults
                      out_branch_test_enable  <= '1';
                      out_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                   when "100"  =>
                      ----------------- BLT -------------------
                      -- offsets already set as defaults
                      out_branch_test_enable  <= '1';
                      out_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                   when "101"  =>
                      ----------------- BGE  -------------------
                      -- offsets already set as defaults
                      out_branch_test_enable  <= '1';
                      out_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                   when "110"  =>
                      ----------------- BLTU  -------------------
                      -- offsets already set as defaults
                      out_branch_test_enable  <= '1';
                      out_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                   when "111"  =>
                      ----------------- BGEU  -------------------
                      -- offsets already set as defaults
                      out_branch_test_enable  <= '1';
                      out_pc_mode             <= PC_JMP_RELATIVE_CONDITIONAL;
                   when others  =>  NULL;
                      -- Undecoded for opcode 1100011                      
                end case;
            when "0000011" =>
                case func3 is 
                   when "000"  =>
                      ------------ LB ------------------
                      out_immed               <= immed_I;
                      out_bus_width           <= "00";
                      out_bus_enable          <= '1';
                      out_sign_ex_width       <= SIGN_EX_WIDTH_B;
                      out_sign_ex_mode        <= SIGN_EX_SIGNED;

                      if minimize_size = '1' then
                          out_select_b            <= B_BUS_IMMEDIATE;
                          out_alu_mode            <= ALU_ADD;
                      end if;

                      out_rdest               <= rd;
                      out_result_src          <= RESULT_MEMORY;
                   when "001"  =>
                      ------------ LH ------------------
                      out_immed               <= immed_I;
                      out_bus_width           <= "01";
                      out_bus_enable          <= '1';
                      out_sign_ex_width       <= SIGN_EX_WIDTH_H;
                      out_sign_ex_mode        <= SIGN_EX_SIGNED;

                      if minimize_size = '1' then
                          out_select_b            <= B_BUS_IMMEDIATE;
                          out_alu_mode            <= ALU_ADD;
                      end if;

                      out_rdest               <= rd;
                      out_result_src          <= RESULT_MEMORY;
                   when "010"  =>
                      ------------ LW ------------------
                      out_immed               <= immed_I;
                      out_bus_width           <= "10";
                      out_bus_enable          <= '1';
                      out_sign_ex_width       <= SIGN_EX_WIDTH_W;
                      out_sign_ex_mode        <= SIGN_EX_SIGNED;

                      if minimize_size = '1' then
                          out_select_b            <= B_BUS_IMMEDIATE;
                          out_alu_mode            <= ALU_ADD;
                      end if;

                      out_rdest               <= rd;
                      out_result_src          <= RESULT_MEMORY;
                   when "100"  =>
                      ------------ LBU ------------------
                      out_immed               <= immed_I;
                      out_bus_width           <= "00";
                      out_bus_enable          <= '1';
                      out_sign_ex_width       <= SIGN_EX_WIDTH_B;
                      out_sign_ex_mode        <= SIGN_EX_UNSIGNED;

                      if minimize_size = '1' then
                          out_select_b            <= B_BUS_IMMEDIATE;
                          out_alu_mode            <= ALU_ADD;
                      end if;

                      out_rdest               <= rd;
                      out_result_src          <= RESULT_MEMORY;
                   when "101"  =>
                      ------------ LHU ------------------
                      out_immed               <= immed_I;
                      out_bus_width           <= "01";
                      out_bus_enable          <= '1';
                      out_sign_ex_width       <= SIGN_EX_WIDTH_H;
                      out_sign_ex_mode        <= SIGN_EX_UNSIGNED;

                      if minimize_size = '1' then
                          out_select_b            <= B_BUS_IMMEDIATE;
                          out_alu_mode            <= ALU_ADD;
                      end if;

                      out_rdest               <= rd;
                      out_result_src          <= RESULT_MEMORY;
                   when others  =>  NULL;
                      -- Undecoded for opcode 0000011                      
                end case;
            when "0100011" =>
                case func3 is 
                   when "000"  =>
                      ------------ SB ------------------
                      out_bus_width           <= "00";
                      out_bus_write           <= '1';
                      out_bus_enable          <= '1';

                      if minimize_size = '1' then
                         -- Immedidate needs to be the store address
                         out_select_b            <= B_BUS_IMMEDIATE;
                         out_immed               <= immed_S;
                      end if;

                      out_rdest               <= (others => '0');
                   when "001"  =>
                      ------------ SH ------------------
                      out_bus_width           <= "01";
                      out_bus_write           <= '1';
                      out_bus_enable          <= '1';

                      if minimize_size = '1' then
                         -- Immedidate needs to be the store address
                         out_select_b            <= B_BUS_IMMEDIATE;
                         out_immed               <= immed_S;
                      end if;

                      out_rdest               <= (others => '0');
                   when "010"  =>
                      ------------ SW ------------------
                      out_bus_width           <= "10";
                      out_bus_write           <= '1';
                      out_bus_enable          <= '1';

                      if minimize_size = '1' then
                         -- Immedidate needs to be the store address
                         out_select_b            <= B_BUS_IMMEDIATE;
                         out_immed               <= immed_S;
                      end if;

                      out_rdest               <= (others => '0');
                   when others  =>  NULL;
                      -- Undecoded for opcode 0100011                      
                end case;
            when "0010011" =>
                out_immed       <= immed_I;
                case func3 is                 
                   when "000"  =>
                      ------------ ADDI ------------------
                      out_select_b           <= B_BUS_IMMEDIATE;
                      out_alu_mode            <= ALU_ADD;
                      out_rdest               <= rd;
                   when "001"  =>
                      case func7 is                 
                         when "0000000"  =>
                            ------------ SLLI ------------------
                            out_select_b     <= B_BUS_IMMEDIATE;
                            out_result_src    <= RESULT_SHIFTER;
                            out_shift_mode    <= SHIFTER_LEFT_LOGICAL; 
                            out_rdest         <= rd;
                         when others =>
                      end case; 
                   when "010"  =>
                      ------------ SLTI ------------------
                      out_select_b           <= B_BUS_IMMEDIATE;
                      out_alu_mode            <= ALU_LESS_THAN_SIGNED;
                      out_rdest               <= rd;
                   when "011"  =>
                      ------------ SLTIU ------------------
                      out_select_b           <= B_BUS_IMMEDIATE;
                      out_alu_mode            <= ALU_LESS_THAN_UNSIGNED;
                      out_rdest               <= rd;
                   when "100"  =>
                      ------------ XORI ------------------
                      out_select_b           <= B_BUS_IMMEDIATE;
                      out_alu_mode            <= ALU_XOR; 
                      out_rdest               <= rd;
                   when "101"  =>
                      case func7 is                 
                         when "0000000"  =>
                            ------------ SRLI ------------------
                            out_select_b     <= B_BUS_IMMEDIATE;
                            out_result_src    <= RESULT_SHIFTER;
                            out_shift_mode    <= SHIFTER_RIGHT_LOGICAL; 
                            out_rdest         <= rd;
                         when "0100000"  =>
                            ------------ SRAI ------------------
                            out_select_b     <= B_BUS_IMMEDIATE;
                            out_result_src    <= RESULT_SHIFTER;
                            out_shift_mode    <= SHIFTER_RIGHT_ARITH; 
                            out_rdest         <= rd;
                         when others =>
                      end case; 
                   when "110"  =>
                      ------------ ORI ------------------
                      out_select_b           <= B_BUS_IMMEDIATE;
                      out_alu_mode            <= ALU_OR; 
                      out_rdest               <= rd;
                   when "111"  =>
                      ------------ ANDI ------------------
                      out_select_b           <= B_BUS_IMMEDIATE;
                      out_alu_mode            <= ALU_AND; 
                      out_rdest               <= rd;
                   when others  =>  NULL;
                      -- Undecoded for opcode 0100011                      
                end case;

            when "0110011" =>
               case func7 is                 
                  when "0000000"  =>
                     case func3 is 
                           when "000"  =>
                              ------------ ADD ------------------
                              out_alu_mode    <= ALU_ADD; 
                              out_rdest       <= rd;
                           when "001"  =>
                              ------------ SLL ------------------
                              out_result_src  <= RESULT_SHIFTER;
                              out_shift_mode  <= SHIFTER_LEFT_LOGICAL; 
                              out_rdest       <= rd;
                           when "010"  =>
                              ------------ SLT ------------------
                              out_alu_mode    <= ALU_LESS_THAN_SIGNED;
                              out_rdest       <= rd;
                           when "011"  =>
                              ------------ SLTU ------------------
                              out_alu_mode    <= ALU_LESS_THAN_UNSIGNED;
                              out_rdest       <= rd;
                           when "100"  =>
                              ------------ XOR ------------------
                              out_alu_mode    <= ALU_XOR; 
                              out_rdest       <= rd;
                           when "101"  =>
                              ------------ SRL ------------------
                              out_result_src  <= RESULT_SHIFTER;
                              out_shift_mode  <= SHIFTER_RIGHT_LOGICAL; 
                              out_rdest       <= rd;
                           when "110"  =>
                              ------------ OR ------------------
                              out_alu_mode    <= ALU_OR; 
                              out_rdest       <= rd;
                           when "111"  =>
                              ------------ AND ------------------
                              out_alu_mode    <= ALU_AND; 
                              out_rdest       <= rd;
                       when others  =>  NULL;
                     end case;
                  when "0100000"  =>
                     case func3 is 
                        when "000"  =>
                           ------------ SUB ------------------
                           out_alu_mode       <= ALU_SUB; 
                           out_rdest          <= rd;
                        when "101"  =>
                           ------------ SRA ------------------
                           out_result_src     <= RESULT_SHIFTER;
                           out_shift_mode     <= SHIFTER_RIGHT_ARITH; 
                           out_rdest          <= rd;
                        when others  =>  NULL;
                     end case;
                  when "0001111"  =>
                     case func3 is 
                        when "000"  =>
                           ------------ FENCE ------------------
                           -- TODO
                        when others  =>  NULL;
                          -- Undecoded for opcode 0001111                      
                     end case;
                  when "1110011"  =>
                     case instr(31 downto 20) is
                        when "000000000000" =>
                            if rs1 = "00000" and func3 = "000" and rd = "00000" then
                              ------------ ECALL ------------------
                              -- TODO
                            end if; 
                        when "000000000001" =>
                            if rs1 = "00000" and func3 = "000" and rd = "00000" then
                              ------------ EBREAK ------------------
                              -- TODO
                            end if; 
                        when others  =>  NULL;
                     end case;
                  when others  =>  NULL;
                     -- Undecoded for opcode 1110011                      
               end case;
            when others =>
              -- Undecoded for opcodes                      
         end case;
         if reset = '1' then
            out_pc_mode             <= PC_RESET_STATE;
            out_branch_test_mode    <= BRANCH_TEST_TRUE;
         end if;
      end if;
   end process;
end Behavioral;
