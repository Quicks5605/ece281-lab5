----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2024 07:03:03 PM
-- Design Name: 
-- Module Name: Controller - Behavioral
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
use IEEE.numeric_std.ALL;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Controller is
    Port ( i_adv : in STD_LOGIC;
           i_stable : in std_logic;
           i_reset : in STD_LOGIC;
           i_input : in STD_LOGIC_VECTOR (7 downto 0);
           o_S : out STD_LOGIC_VECTOR (3 downto 0);
           o_A : out STD_LOGIC_VECTOR (7 downto 0);
           o_B : out STD_LOGIC_VECTOR (7 downto 0));
end Controller;

architecture Behavioral of Controller is
type state is (state1, state2, state3, state4);
signal f_Q, f_Q_next: state;
signal w_A, w_B : STD_LOGIC_VECTOR(7 downto 0);
begin

    f_Q_next <= state1 when ((f_Q = state4) or (i_reset = '1'))else
                state2 when (f_Q = state1) else
                state3 when (f_Q = state2) else
                state4 when (f_Q = state3);


with f_Q select
    o_S <= "0001" when state1,
           "0010" when state2,
           "0100" when state3,
           "1000" when state4;

with f_Q select                
    w_B <= i_input when state1,
    "00000000" when state4,
    w_B  when others;  
with f_Q select           
    w_A <= i_input when state2,
    "00000000" when state4,
    w_A  when others; 
o_A <= w_A;
o_B <= w_B;    

           
advance : process (i_adv, i_reset)
    begin
    if (i_reset ='1') then 
        f_Q <= state4;
     elsif ((rising_edge(i_adv)) and (i_stable = '1')) then       
        f_Q <= f_Q_next;


     end if;
      
end process advance;

end Behavioral;
