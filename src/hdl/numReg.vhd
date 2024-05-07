----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2024 08:09:28 AM
-- Design Name: 
-- Module Name: numReg - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity numReg is
    Port ( i_num : in STD_LOGIC_VECTOR (7 downto 0);
           o_num : out STD_LOGIC_VECTOR (7 downto 0);
           i_clk : in STD_LOGIC);
end numReg;

architecture Behavioral of numReg is
signal f_Q : STD_LOGIC := '0';
signal f_Q_next : STD_LOGIC := '0';


begin

f_Q_next <= '1' when (i_clk = '1' and f_Q = '0') else
            '0';
            

    reg_proc : process
        begin
            

end Behavioral;
