-------------------------------------------------------------------------
-- Design unit: BidirectionalPort simutation test bench
-- Description:             
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;   

entity BidirectionalPort_tb is
end BidirectionalPort_tb;

architecture behavioral of BidirectionalPort_tb is
	signal clk 			: std_logic := '0';  	
	signal rst			: std_logic := '0';			 
	signal data_i 		: std_logic_vector(15 downto 0);
	signal data_o		: std_logic_vector(15 downto 0);
	signal address		: std_logic_vector(1 downto 0);
	signal rw			: std_logic := '0';
	signal ce			: std_logic := '0';
	signal pin			: std_logic_vector(15 downto 0);
	signal irq			: std_logic_vector(15 downto 0);
	
begin
	
	IOPERIPH: entity work.BidirectionalPort
		generic map(
	        DATA_WIDTH          => 16,
	        PORT_DATA_ADDR      => "10",
	        PORT_CONFIG_ADDR    => "01",
	        PORT_ENABLE_ADDR    => "00",
			PORT_IRQENABLE_ADDR => "11"
	    )
	    port map(  
	        clk         		=> clk,
	        rst         		=> rst,
	        data_i      		=> data_i,
	        data_o      		=> data_o,
	        address     		=> address,
	        rw          		=> rw,
	        ce          		=> ce,
	        port_io     		=> pin,	 
			irq 				=> irq
	    );
    
    -- Generates the clock signal            
    clk <= not clk after 5 ns;
	
    -- Generates the reset signal
    rst <= '1', '0' after 3 ns;        
    
	-- enable = x1111												   	00 ns
	-- config = 0101010101010101									   	10 ns
	-- data = data_i(1z1z1z1z1z1z1z1z1z) + pin(z1z1z1z1z1z1z1z1) 	   	20, 30 ns  
	-- data = data_i(1111111100000000) + pin(zzzzzzzzzzzzzzzz)		   	40, ns  
	-- enable = x0000													50 ns 
	-- enable = "010101010101010101"									60 ns
	-- enable = "101010101010101010"									70 ns
	
	
	-- 
	address	<=	"00", 
				"01" after 10 ns, 
				"10" after 20 ns, 
				"10" after 30 ns,
				"10" after 40 ns, 
				"00" after 50 ns, 
				"01" after 60 ns,
				"10" after 70 ns;
	
	--
	data_i	<=	x"FFFF",
				"1111111100000000" after 10 ns,
				"0000000010101010" after 20 ns,
				"0000000010101010" after 30 ns, 
				"1111111100000000" after 40 ns, 
				x"0000" after 50 ns, 
				"0000000000000000" after 60 ns,
				"1010101010101010" after 70 ns;
	
	-- 								  	
	pin		<= 	"ZZZZZZZZZZZZZZZZ",
				"1111111100000000" after 20 ns,
				"1111111100000000" after 30 ns,
				"1111111100000000" after 40 ns,
				"0000000000000000" after 50 ns,
				"1111111111111111" after 60 ns;
	
	--
	rw 	<= '0', '0' after 100 ns;
	
	--		   
	ce	<= '1';
	
end behavioral;