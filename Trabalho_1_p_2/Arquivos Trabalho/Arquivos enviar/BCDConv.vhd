library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BCDConv is
    port (  						
        d_in           : in  std_logic_vector (3 downto 0);
        d_out          : out std_logic_vector (7 downto 0)
    );
end BCDConv;


architecture behavioral of BCDConv is
begin
	with d_in select		   
	d_out		<= 		"00000011" when "0000",				-- (0 == ligado		1 == desligado) os display tem anodo(positivo) comum
						"10011111" when "0001",
						"00100101" when "0010",
						"00001101" when "0011",
						"10011001" when "0100",
						"01001001" when "0101",
						"01000001" when "0110",
						"00011111" when "0111",
						"00000001" when "1000",
						"00001001" when "1001",
						"00010001" when "1010",
						"11000001" when "1011",
						"01100011" when "1100",
						"10000101" when "1101",
						"01100001" when "1110",
						"01110001" when others;
        
end behavioral;