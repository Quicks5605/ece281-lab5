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
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(15 downto 0);
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; --adv
        btnL    :   in std_logic; --stability
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals

    component TDM4 is
            generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
            port ( i_clk        : in  STD_LOGIC;
                   i_reset        : in  STD_LOGIC; -- asynchronous
                   i_D3         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                   i_D2         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                   i_D1         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                   i_D0         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                   o_data        : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
                   o_sel        : out STD_LOGIC_VECTOR (3 downto 0)    -- selected data line (one-cold)
            );
        end component TDM4;
    
    component clock_divider is
            generic ( constant k_DIV : natural := 2    ); -- How many clk cycles until slow clock toggles
                                                       -- Effectively, you divide the clk double this 
                                                       -- number (e.g., k_DIV := 2 --> clock divider of 4)
            port (  i_clk    : in std_logic;
                    i_reset  : in std_logic;           -- asynchronous
                    o_clk    : out std_logic           -- divided (slow) clock
            );
        end component clock_divider;
  
  component ALU is
  
           port (  i_A    :   in std_logic_vector (7 downto 0);
                   i_B    :   in std_logic_vector (7 downto 0);       
                   i_op   :   in std_logic_vector (2 downto 0);
                   o_flag :   out std_logic_vector(2 downto 0);
                   o_res  :   out std_logic_vector(7 downto 0)                       
            );
                end component ALU;

  component Controller is
    Port (     i_adv : in STD_LOGIC;
               i_reset : in STD_LOGIC;
               i_stable : in std_logic;
               i_input : in STD_LOGIC_VECTOR (7 downto 0);
               o_S : out STD_LOGIC_VECTOR (3 downto 0);
               o_A : out STD_LOGIC_VECTOR (7 downto 0);
               o_B : out STD_LOGIC_VECTOR (7 downto 0)
               );
  end component Controller;
          
  component sevenSegDecoder is
      Port ( i_D : in STD_LOGIC_VECTOR (3 downto 0);
             o_S : out STD_LOGIC_VECTOR (6 downto 0)
             );
  end component sevenSegDecoder;
  
  component twoscomp_decimal is
      port (
          i_binary: in std_logic_vector(7 downto 0);
          o_negative: out std_logic;
          o_hundreds: out std_logic_vector(3 downto 0);
          o_tens: out std_logic_vector(3 downto 0);
          o_ones: out std_logic_vector(3 downto 0)
      );
  end component twoscomp_decimal;
  
signal w_clk, w_neg : std_logic;
signal w_A, w_B, w_res, w_mux : std_logic_vector(7 downto 0);
signal w_cyc, w_sign, w_hund, w_tens, w_ones, w_seg, w_sel : std_logic_vector(3 downto 0);


  
begin
	-- PORT MAPS ----------------------------------------
    TDM4_inst : TDM4
            generic map (k_WIDTH => 4) -- bits in input and output
            port map ( 
                   i_clk   => w_clk,
                   i_reset    => btnU,
                   i_D3         => w_sign,
                   i_D2         => w_hund,
                   i_D1         => w_tens,
                   i_D0         => w_ones,
                   o_data       => w_seg,
                   o_sel        => w_sel   -- selected data line (one-cold)
            );

    
     clock_divider_inst : clock_divider
            generic map (k_DIV => 50000) -- How many clk cycles until slow clock toggles

            port map (  i_clk => clk,
                        i_reset  => btnU,   
                        o_clk   => w_clk           -- divided (slow) clock
            );

  
  ALU_inst : ALU
  
           port map (  i_A    => w_A,
                       i_B    => w_B,          
                       i_op   => sw( 15 downto 13),
                       o_flag => led(15 downto 13),
                       o_res  => w_res                      
            );
            
  Controller_inst : Controller
    Port map ( i_adv => btnC,
               i_reset => btnU,
               i_stable => btnL,
               i_input => sw(7 downto 0),
               o_S => w_cyc,
               o_A => w_A,
               o_B => w_B
                );

          
  sevenSegDecoder_inst : sevenSegDecoder
      Port map ( i_D => w_seg,
                 o_S => seg
             );

 twoscomp_inst : twoscomp_decimal
    port map(
        i_binary => w_mux,
        o_negative => w_neg,
        o_hundreds => w_hund,
        o_tens => w_tens,
        o_ones => w_ones
    );

 
	
	
	-- CONCURRENT STATEMENTS ----------------------------
w_mux <= w_A when (w_cyc = "0001") else
         w_B when (w_cyc = "0010") else
         w_res when (w_cyc = "0100") else
         "00000000";
         
w_sign <= "1111" when (w_neg = '1') else "0000";

	
	
	
	--ground leds and set ans--
led(12) <= '0';
led(11) <= '0';
led(10) <= '0';
led(9) <= '0';
led(8) <= '0';
led(7) <= '0';
led(6) <= '0';
led(5) <= '0';
led(4) <= '0';

an(0) <= w_sel(0);
an(1) <= w_sel(1);
an(2) <= w_sel(2);
an(3) <= w_sel(3);

led(3) <= w_cyc(3);
led(2) <= w_cyc(2);
led(1) <= w_cyc(1);
led(0) <= w_cyc(0);
	
end top_basys3_arch;
