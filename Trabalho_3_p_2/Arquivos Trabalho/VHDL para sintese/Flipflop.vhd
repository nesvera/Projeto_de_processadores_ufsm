
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Flipflop is
    generic (													   
        INIT_VALUE  : std_logic := '0'      -- Reset value
    );
    port (  
        clk         : in std_logic;
        rst         : in std_logic; 
        ce          : in std_logic;
        d           : in std_logic;
        q           : out std_logic
    );
end Flipflop;


architecture behavioral of Flipflop is
begin

    process(clk, rst)
    begin
        if rst = '1' then
            q <= INIT_VALUE;     
        
        elsif rising_edge(clk) then
            if ce = '1' then  
				q	<= d;
            end if;
        end if;
    end process;
        
end behavioral;

