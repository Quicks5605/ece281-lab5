--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|     SUB     100
--|     Left    011
--|     Right   111
--|     AND     X01
--|     OR      X10
--+----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port ( i_A    :   in std_logic_vector (7 downto 0);
           i_B    :   in std_logic_vector (7 downto 0);       
           i_op   :   in std_logic_vector (2 downto 0);
           o_flag :   out std_logic_vector(2 downto 0);
           o_res  :   out std_logic_vector(7 downto 0)               
     );
end ALU;


architecture behavioral of ALU is 
  
	-- declare components and signals
signal w_sel_shift, w_out, w_addsub, w_A, w_B, w_LS, w_RS, w_res: std_logic_vector (7 downto 0) := "00000000";
signal w_CoutFLG, w_overflow, w_CPUzero : std_logic;
signal w_Cin : std_logic_vector (0 downto 0) := "0";
  
begin
	-- PORT MAPS ----------------------------------------
w_B <= not i_B when (i_op = "100")else
       i_B;
w_addsub <= std_logic_vector(unsigned(i_A) + unsigned(w_B) + unsigned(w_Cin));
--w_A <= 
w_Cin <= i_op(2 downto 2);	
w_LS <= std_logic_vector(shift_left(unsigned(i_A), 2));
w_RS <= std_logic_vector(shift_right(unsigned(i_A), 2));
-- CONCURRENT STATEMENTS ----------------------------
w_res <= w_addsub when (i_op(1 downto 0)= "00") else
      i_A or i_B when i_op(1 downto 0) = "10" else
      i_A and i_B when i_op(1 downto 0) = "01" else
       w_LS when i_op = "011" else
       w_RS when i_op = "111" else
       "00000000";
      
--w_CoutFLG <= (( (i_A(7) or i_B(7)) and not w_addsub(7)) or (i_A(7) and i_B(7))) when i_op(1 downto 0) = "00";
--w_overflow <= w_CoutFLG when i_op = "000";
--w_CPUzero <= not (w_res or "00000000");
--o_flag(0) <= w_CoutFLG;
--o_flag(1) <= w_overflow;
--o_flag(2) <= w_CPUzero;
o_res <= w_res;

end behavioral;

