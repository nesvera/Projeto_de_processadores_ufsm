-----------------------------------------------------------------------------------------
-- Design unit: Address Decoder
-- Description: This circuit chooses wich ce to enable, between memory and 8 different
-- peripherals based on the address from the CPU
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity AddressDecoder is	
	generic(
		DATA_WIDTH  	: integer := 16         -- Data bus width	  
	);
	port(
		address 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		ce				: in std_logic;
		ce_memory		: out std_logic;
		ce_peripheral	: out std_logic_vector(7 downto 0)
	);
end AddressDecoder;

architecture arch1 of AddressDecoder is	  

	signal peripheral	: std_logic_vector(7 downto 0);

begin
	-- Memory enable						(0xxxxxxxxxxxxxxx) = Enable		(1xxxxxxxxxxxxxxx) = Disable 
	ce_memory		<= not address(15) and ce;	   
	
	-- Peripheral enable   					(1000xxxxxxxxxxxx) = peripheral 0
	with address(15 downto 12) select		   
	peripheral	<= 	"00000001" when "1000",
					"00000010" when "1001",
					"00000100" when "1010",
					"00001000" when "1011",
					"00010000" when "1100",
					"00100000" when "1101",
					"01000000" when "1110",
					"10000000" when "1111",
					"00000000" when others;
					
	-- BITWISE LOGIC
	CE_P: for I in 0 to (7)	generate 
		ce_peripheral(I)	<= peripheral(I) and ce; 
	end generate CE_P;

end arch1;
