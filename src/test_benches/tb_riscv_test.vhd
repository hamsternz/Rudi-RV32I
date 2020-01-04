----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.12.2019 23:11:15
-- Design Name: 
-- Module Name: tb_riscv - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

entity tb_riscv is
end tb_riscv;

architecture Behavioral of tb_riscv is
  
    component top_level is
          port ( clk        : in  STD_LOGIC;
                 debug_sel  : in  STD_LOGIC_VECTOR(4 downto 0);
                 debug_data : out STD_LOGIC_VECTOR(31 downto 0)); 
    end component;

    signal clk             : std_logic := '0';
    signal debug_sel       : STD_LOGIC_VECTOR( 4 downto 0) := "00001";
    signal debug_data      : STD_LOGIC_VECTOR(31 downto 0); 
    signal cache_last_addr : std_logic := '0';
begin

process
   begin
       wait for 5 ns;
       clk <= '0';
       wait for 5 ns;
       clk <= '1';
   end process;
   

i_top_level: top_level port map(
                 clk        => clk,

                 debug_sel  => debug_sel,
                 debug_data => debug_data); 
end Behavioral;

