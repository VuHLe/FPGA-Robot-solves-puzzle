library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity robot_tb is
--  Port ( );
end robot_tb;

architecture Behavioral of robot_tb is
    signal clk_tb : std_logic;
    signal reset_tb : std_logic;
    signal start_tb : std_logic;
    
    signal init_start_tb : std_logic;
    signal init_goal_tb : std_logic;
    
    signal din_tb : std_logic_vector(6 downto 0);
    
    signal rst_tb         : std_logic;
    signal oled_sdin_tb   : std_logic;
    signal oled_sclk_tb   : std_logic;
    signal oled_dc_tb     : std_logic;
    signal oled_res_tb    : std_logic;
    signal oled_vbat_tb   : std_logic;
    signal oled_vdd_tb    : std_logic;
    
    signal oled_sw_tb : std_logic;
    signal dout_tb : std_logic_vector(7 downto 0);
  
begin
    robot_test: entity work.robot(Behavioral)
        port map(
            clk => clk_tb,
            reset => reset_tb,
            start => start_tb,
            
            init_start => init_start_tb,
            init_goal => init_goal_tb,
            
            din => din_tb,
            
            rst => rst_tb,
            oled_sdin => oled_sdin_tb,
            oled_sclk => oled_sclk_tb,
            oled_dc => oled_dc_tb,
            oled_res => oled_res_tb,
            oled_vbat => oled_vbat_tb,
            oled_vdd => oled_vdd_tb,
            
            oled_sw => oled_sw_tb,
            dout => dout_tb
        );
    
--    process begin
--            clk_tb <= '0';
--            wait for 1 ns;
--            clk_tb <= '1';               
--            wait for 1 ns;
           
--        end process;
    
    
--    process begin
    
--            wait until rising_edge(clk_tb);
--            start_tb <= '1';
    
--    end process; 
      testbench: process
    begin
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        din_tb <= "000000";
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        init_start_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        init_start_tb <= '0';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
  
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';

        init_goal_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
    
        init_goal_tb <= '0';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
   
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
     
        start_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
     
        start_tb <= '0';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        wait for 10ns;
        
        clk_tb <= '0';
        wait for 10ns;

        clk_tb <= '1';
        wait for 10ns;
        
        
        
--        assert FALSE
--            report "Simulation Completed"
--        severity FAILURE;   
    end process;  
end Behavioral;
