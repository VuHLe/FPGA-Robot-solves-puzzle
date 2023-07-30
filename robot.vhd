library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package oled_pkg is
    type oled_mem is array (0 to 3, 0 to 15) of std_logic_vector (7 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.oled_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity robot is
    generic (DIM : in integer := 6);-- CHANGE DIM HERE----------
  Port ( 
    clk : in std_logic;
    reset : in std_logic;
    start : in std_logic;
    init_start : in std_logic;
    init_goal : in std_logic;
    din : in std_logic_vector(6 downto 0);

    -----------------------OLED part-------------------------
     rst         : in std_logic;
     oled_sdin   : out std_logic;
     oled_sclk   : out std_logic;
     oled_dc     : out std_logic;
     oled_res    : out std_logic;
     oled_vbat   : out std_logic;
     oled_vdd    : out std_logic;
    ---------------------------------------------------------
    oled_sw : in std_logic;
    dout : out std_logic_vector(7 downto 0)
  );
end robot;

architecture Behavioral of robot is
---------------------------------------------OLED control-------------------------------------------
    component oled_ctrl is
         port (  clk         : in std_logic;
                rst         : in std_logic;
                oled_sdin   : out std_logic;
                oled_sclk   : out std_logic;
                oled_dc     : out std_logic;
                oled_res    : out std_logic;
                oled_vbat   : out std_logic;
                oled_vdd    : out std_logic;
                input_oled_screen : in oled_mem
                );
    end component;
    signal temp_screen : oled_mem := ( (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                       (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                       (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                       (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));  
                                                                        
    signal temp_screen2 : oled_mem := ((x"4E", x"2F", x"41", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                       (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                       (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                       (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));                                                                                 
                                                                              
    signal input_screen : oled_mem := ( (x"46", x"69", x"6E", x"64", x"69", x"6E", x"67", x"2E", x"2E", x"2E", x"20", x"20", x"20", x"20", x"20", x"20"),
                                        (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                        (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                        (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));
                                        
    ----------------------------------------------------------------------------------------------------
    type square is array (0 to DIM, 0 to DIM) of std_logic;
    type path is array ((DIM + 1) * (DIM + 1) downto 0) of integer;
    type state_type is (S0A,S0A0,S0A1,S0A2,S0B,S0B0,S0B1,S0B2,S0,S1,S2,S3,S3A,S3B,S4,S4A,S4B,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,
                        S17,S17A,S18,S18A,S19,SErr);
-- Stage 1: --------------------- DIM = 6X6 no obstacles-------------    
--    signal maze : square := (('0','0','0','0','0','0'),
--                             ('0','0','0','0','0','0'),
--                             ('0','0','0','0','0','0'),
--                             ('0','0','0','0','0','0'),
--                             ('0','0','0','0','0','0'),
--                             ('0','0','0','0','0','0'));
-- Stage 2: --------------------- DIM = 7X7 1 obstacles--------------
    signal maze : square := (('0','0','0','0','0','0','0'),
                             ('0','0','0','0','0','0','0'),
                             ('0','0','0','0','0','0','1'),
                             ('0','0','0','0','0','0','0'),
                             ('0','0','0','0','0','0','0'),
                             ('0','0','0','0','0','0','0'),
                             ('0','0','0','0','0','0','0'));
-- Stage 3: --------------------- DIM = 4X4 2 obstacles--------------  
--    signal maze : square := (('0','0','1','0'),
--                             ('0','0','0','1'),
--                             ('0','0','0','0'),
--                             ('0','0','0','0'));
-- Stage 4: --------------------- DIM = 5x5 Multiple obstacles with back tracking-------------------------
--    signal maze : square := (('0','0','0','0','0'),
--                             ('0','1','0','1','1'),
--                             ('0','1','0','0','0'),
--                             ('0','0','0','1','0'),
--                             ('0','1','0','0','0'));
                  
    signal path_x : path := (others => 0);
    signal path_y : path := (others => 0);
    signal deadend_x : path := (others => 0);
    signal deadend_y : path := (others => 0); 
                          
    signal state: state_type := S0A;
begin
-------------------------------------------OLED control---------------------------------
    oled_control: oled_ctrl port map (
        clk,
        rst,
        oled_sdin,
        oled_sclk,
        oled_dc,
        oled_res,
        oled_vbat,
        oled_vdd,
        input_screen
    );
---------------------------------------------------------------------------------------------   
    process(clk)
        variable path_count : integer := 0;
        variable deadend_count : integer := 0;
     
        variable curpath_x : integer;
        variable curpath_y : integer;
        variable goal_x : integer;
        variable goal_y : integer;
        
        variable right : std_logic := '1';
        variable up : std_logic := '1';
        variable left : std_logic := '1';
        variable down : std_logic := '1';
        
        variable loop_count :  integer := 0;
        
        variable i : integer := 0;
        variable k : integer := 0;
        
        variable j : integer := 0;
        variable n : integer := 0;
        variable m : integer := 0;
        variable oled_count : integer := 0;
        
    begin
        if rising_edge(clk) then
            if reset = '1' then
                path_x <= (others => 0);
                path_y <= (others => 0);
                
                deadend_x <= (others => 0);
                deadend_y <= (others => 0);

                right := '1';
                up := '1';
                left := '1';
                down := '1';
                
                path_count := 0;
                deadend_count := 0;
                
                loop_count := 0;
                
                i := 0;
                k := 0;
                
                j := 0;
                n := 0;
                m := 0;
                oled_count := 0;
                
                dout <= "00000000";
                
                temp_screen <= ( (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                 (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                 (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                 (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));
                
                temp_screen2 <= ((x"4E", x"2F", x"41", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                 (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                 (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                 (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));
                
                input_screen <= ( (x"46", x"69", x"6E", x"64", x"69", x"6E", x"67", x"2E", x"2E", x"2E", x"20", x"20", x"20", x"20", x"20", x"20"),
                                  (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                  (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                  (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));
                
                state <= S0A;
            else
                case state is
                     -- assign start
                    when S0A =>
                        if init_start = '1' then
                            curpath_x := to_integer(unsigned(din));
                            path_x(path_count) <= to_integer(unsigned(din));
                            state <= S0A0;
                        else
                            state <= S0A;
                        end if;
                        
                    when S0A0 =>
                        if init_start = '1' then
                            state <= S0A0;
                        else
                            state <= S0A1;
                        end if;
                      
                    when S0A1 =>
                         if init_goal = '1' then
                            curpath_y := to_integer(unsigned(din));
                            path_y(path_count) <= to_integer(unsigned(din));
                            state <= S0A2;
                        else
                            state <= S0A1;
                        end if;
                        
                    when S0A2 =>
                        if init_goal = '1' then
                            state <= S0A2;
                        else
                            state <= S0B;
                        end if;
                    
                    -- assign goal    
                    when S0B =>
                        if init_start = '1' then
                            goal_x := to_integer(unsigned(din));
                            state <= S0B0;
                        else
                            state <= S0B;
                        end if;
                        
                    when S0B0 =>
                        if init_start = '1' then
                            state <= S0B0;
                        else
                            state <= S0B1;
                        end if;
                        
                    when S0B1 =>
                        if init_goal = '1' then
                            goal_y := to_integer(unsigned(din));
                            state <= S0B2;
                        else
                            state <= S0B1;
                        end if;
                    when S0B2 =>
                        if init_goal = '1' then
                            state <= S0B2;
                        else
                            state <= S0;
                        end if;
                        
                    -- START-------------------------------------
                    when S0 =>          
                        if start = '1' then
--                            path_x(0) <= curpath_x;
--                            path_y(0) <= curpath_y;
                            dout <= "00000000";
                            state <= S1;
                        else
                            state <= S0;
                        end if;
                    -- intitiallize the valid signal
                    when S1 =>
                        if loop_count >= (DIM + 1) * (DIM + 1) then -- If the loop go beyond or equal to the maximum path in the maze, then it cannot find the goal
                            state <= SErr;
                        else
                            right := '1';
                            up := '1';
                            left := '1';
                            down := '1';
                            loop_count := loop_count + 1;-- increament loop count
                            state <= S2;
                        end if;
                        
                    when S2 =>
                    -- if curpath = goal, which mean the robot reach the goal
                        if curpath_x = goal_x 
                        and curpath_y = goal_y then
                            state <= S16;
                        else
                            state <= S3;
                        end if;
                        -- check if the next path already go
                    when S3 =>
                        if i < path_count + 1 then
                            --right path existed
                            if path_x(i) = curpath_x + 1 and path_y(i) = curpath_y then
                                right := '0';
                            end if;
                            --up path existed
                            if path_x(i) = curpath_x and path_y(i) = curpath_y + 1 then
                                up := '0';
                            end if;
                            --left path existed
                            if path_x(i) = curpath_x - 1 and path_y(i) = curpath_y then
                                left := '0';
                            end if;
                            --down path existed
                            if path_x(i) = curpath_x and path_y(i) = curpath_y - 1 then
                                down := '0';
                            end if;
                            state <= S3A;
                        else
                            
                            state <= S3B;    
                        end if;
                    when S3A =>
                        i := i + 1;
                        state <= S3;
                        
                    when S3B =>
                        i := 0;
                        state <= S4;
                        -- check if the next path is in deadend list
                    when S4 =>
                        if k < deadend_count + 1 then
                            --right deadend
                            if deadend_x(k) = curpath_x + 1 and deadend_y(k) = curpath_y then
                                right := '0';
                            end if;
                            --up deadend
                            if deadend_x(k) = curpath_x and deadend_y(k) = curpath_y + 1 then
                                up := '0';
                            end if;
                            --left deadend
                            if deadend_x(k) = curpath_x - 1 and deadend_y(k) = curpath_y then
                                left := '0';
                            end if;
                            --down deadend
                            if deadend_x(k) = curpath_x and deadend_y(k) = curpath_y - 1 then
                                down := '0';
                            end if;
                            state <= S4A;
                        else
                            
                            state <= S4B;
                        end if;
                        
                    when S4A =>
                        k := k + 1;
                        state <= S4;
                        
                    when S4B =>
                        k := 0;  
                        state <= S5;  
                    -- move right
                    when S5 =>
                        if ((maze(curpath_y, curpath_x+1) = '0') AND (curpath_x < DIM) AND (right = '1')) then                      
                            curpath_x := curpath_x + 1;

                            state <= S14;
                        else
                            state <= S6;
                        end if;
                    -- move up
                    when S6 =>
                        if ((maze(curpath_y+1, curpath_x) = '0') AND (curpath_y < DIM) AND (up = '1')) then
                            curpath_y := curpath_y + 1;

                            state <= S14;
                        else
                            state <= S7;
                        end if;
                    -- move left
                    when S7 =>
                        if ((maze(curpath_y, curpath_x-1) = '0') AND (curpath_x > 0) AND (left = '1')) then
                            curpath_x := curpath_x - 1;
                            
                            state <= S14;
                        else
                            state <= S8;
                        end if;
                    -- move down    
                    when S8 =>
                        if ((maze(curpath_y-1, curpath_x) = '0') AND (curpath_y > 0) AND (down = '1')) then
                            curpath_y := curpath_y - 1;
                                                       
                            state <= S14;
                        else
                            state <= S9;
                        end if;
                        
                     -- if robot this not make any move, 
                     -- which mean this path is deadend
                     -- include curpath in dead end array
                     when S9 =>
                        deadend_x(deadend_count) <= curpath_x;
                        deadend_y(deadend_count) <= curpath_y;
                        state <= S10;
                     -- increasment deadend count   
                     when S10 =>
                        deadend_count := deadend_count + 1;
                        state <= S11;
                     -- make curpath back tracking
                     when S11 =>
                        curpath_x := path_x(path_count-1);
                        curpath_y := path_y(path_count-1);
                        state <= S12;
                     -- Remove the curpath out of path array
                     when S12 =>
                        path_x(path_count) <= 0;
                        path_y(path_count) <= 0;
                        state <= S13;
                     -- decrement path count then go back to S1   
                     when S13 =>
                        path_count := path_count - 1;
                        state <= S1;
                    -----------------------------------
                    -- include next path into path array
                    when S14 =>
                        path_x(path_count+1) <= curpath_x;
                        path_y(path_count+1) <= curpath_y;
                        state <= S15;
                    -- increament path_count then go back to S1
                    when S15 =>
                        path_count := path_count + 1;
                        state <= S1;
                        
                    when S16 =>
                    -- If finding goal successfully, signal that it is done
                         dout <= "11111111"; 
                         state <= S17;
                    -- Put path on oled-------------------------------------------
                    -- first oled screen
                    when S17 =>
                        if n < 4 then --run out of oled screen
                            if j < path_count + 1 then
                            -- put in x
                                if path_x(j) = 0 then
                                    temp_screen(n,m) <= x"30"; 
                                elsif path_x(j) = 1 then
                                    temp_screen(n,m) <= x"31";
                                elsif path_x(j) = 2 then
                                    temp_screen(n,m) <= x"32";
                                elsif path_x(j) = 3 then
                                    temp_screen(n,m) <= x"33";
                                elsif path_x(j) = 4 then
                                    temp_screen(n,m) <= x"34";
                                elsif path_x(j) = 5 then
                                    temp_screen(n,m) <= x"35";
                                elsif path_x(j) = 6 then
                                    temp_screen(n,m) <= x"36";
                                elsif path_x(j) = 7 then
                                    temp_screen(n,m) <= x"37";
                                end if;
                             -- put in y
                                if path_y(j) = 0 then
                                    temp_screen(n,m+1) <= x"30"; 
                                elsif path_y(j) = 1 then
                                    temp_screen(n,m+1) <= x"31";
                                elsif path_y(j) = 2 then
                                    temp_screen(n,m+1) <= x"32";
                                elsif path_y(j) = 3 then
                                    temp_screen(n,m+1) <= x"33";
                                elsif path_y(j) = 4 then
                                    temp_screen(n,m+1) <= x"34";
                                elsif path_y(j) = 5 then
                                    temp_screen(n,m+1) <= x"35";
                                elsif path_y(j) = 6 then
                                    temp_screen(n,m+1) <= x"36";
                                elsif path_y(j) = 7 then
                                    temp_screen(n,m+1) <= x"37";
                                end if;
                              -- put in space
                                temp_screen(n,m+2) <= x"20";
                              
                                oled_count := oled_count + 1;
                                state <= S18;
                            else
                                j := 0;
                                state <= S19;  
                            end if;
                        else -- reset variable
                            m := 0;
                            n := 0;
                            oled_count := 0;
                            state <= S17A;
                        end if;
                    when S18 =>
                        if oled_count = 5 then
                            m := 0;
                            n := n + 1;
                            oled_count := 0;
                        else
                            m := m + 3;
                        end if;
                        j := j + 1;
                        state <= S17;
                     -- second oled screen-----------
                    when S17A =>
                        if j < path_count + 1 then
                            -- put in x
                                if path_x(j) = 0 then
                                    temp_screen2(n,m) <= x"30"; 
                                elsif path_x(j) = 1 then
                                    temp_screen2(n,m) <= x"31";
                                elsif path_x(j) = 2 then
                                    temp_screen2(n,m) <= x"32";
                                elsif path_x(j) = 3 then
                                    temp_screen2(n,m) <= x"33";
                                elsif path_x(j) = 4 then
                                    temp_screen2(n,m) <= x"34";
                                elsif path_x(j) = 5 then
                                    temp_screen2(n,m) <= x"35";
                                elsif path_x(j) = 6 then
                                    temp_screen2(n,m) <= x"36";
                                elsif path_x(j) = 7 then
                                    temp_screen2(n,m) <= x"37";
                                end if;
                             -- put in y
                                if path_y(j) = 0 then
                                    temp_screen2(n,m+1) <= x"30"; 
                                elsif path_y(j) = 1 then
                                    temp_screen2(n,m+1) <= x"31";
                                elsif path_y(j) = 2 then
                                    temp_screen2(n,m+1) <= x"32";
                                elsif path_y(j) = 3 then
                                    temp_screen2(n,m+1) <= x"33";
                                elsif path_y(j) = 4 then
                                    temp_screen2(n,m+1) <= x"34";
                                elsif path_y(j) = 5 then
                                    temp_screen2(n,m+1) <= x"35";
                                elsif path_y(j) = 6 then
                                    temp_screen2(n,m+1) <= x"36";
                                elsif path_y(j) = 7 then
                                    temp_screen2(n,m+1) <= x"37";
                                end if;
                              -- put in space
                                temp_screen2(n,m+2) <= x"20";
                              
                                oled_count := oled_count + 1;
                                state <= S18A;
                            else
                                j := 0;
                                state <= S19;  
                            end if;
                    when S18A =>
                        if oled_count = 5 then
                            m := 0;
                            n := n + 1;
                            oled_count := 0;
                        else
                            m := m + 3;
                        end if;
                        j := j + 1;
                        state <= S17A;
                    ----------- switching oled creen-----------------------
                    when S19 =>
                        if oled_sw = '0' then
                            input_screen <= temp_screen;
                        elsif oled_sw = '1' then
                            input_screen <= temp_screen2;
                        end if;
                        state <= S19;
                        
                    -- If the robot cannot find the goal, signal that it is error
                    when SErr =>
                         dout <= "00000001"; 
                         input_screen <= ((x"45", x"52", x"52", x"4F", x"52", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                          (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                          (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
                                          (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"));
                end case;
            end if;
        end if; 
    end process;

end Behavioral;
