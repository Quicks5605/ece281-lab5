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
signal w_sel_addsub,w_B, w_AND, w_OR, w_LS, w_RS, w_sel_shift, w_out, w_add, w_sub : std_logic_vector (7 downto 0);
signal w_Cout : std_logic;
signal w_Cin : std_logic_vector (0 downto 0);

  
begin
	-- PORT MAPS ----------------------------------------
w_B <= not i_B when i_op = "100" else i_B;
w_Cin <= i_op(2 downto 2);	
	
	-- CONCURRENT STATEMENTS ----------------------------
w_add <= std_logic_vector(unsigned(i_A) + unsigned(i_B));
w_sub <= std_logic_vector(unsigned(i_A) + unsigned(w_B)+ unsigned(w_Cin));
o_res <= w_add when (i_op =  "000") else
	     w_sub when (i_op =  "100");
end behavioral;
