-------------------------------------------------------------------------
-- Design unit: R8 microcontroller
-- Description: R8 processor connected to a RAM memory and peripherals            
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use ieee.std_logic_unsigned.all; 	-- CONV_INTEGER function	
USE ieee.numeric_std.ALL;	   
use ieee.std_logic_misc.ALL;

entity R8_uC is	
	generic(																
		MEMORY_SIZE			: integer := 256;		-- Memory depth (number of words)
		DATA_WIDTH  		: integer := 16;        -- Data bus width 
		ADDR_WIDTH  		: integer := 16;        -- Address bus width	
		IMAGE       		: string := "UNUSED";   -- Memory content to be loaded    (text file) 
		ISR_ADDRESS			: integer := 256 		-- Fixed address to the ISR function
	);
    port( 
        clk     			: in std_logic;
        rst     			: in std_logic;
        portA_io			: inout std_logic_vector(DATA_WIDTH-1 downto 0);	-- External interface
		portB_io			: inout std_logic_vector(DATA_WIDTH-1 downto 0)		-- External interface
    );
end R8_uC;    

architecture arch1 of R8_uC is
    
    signal rw, wr_n 		: std_logic;
	signal ce				: std_logic;
	signal ce_memory		: std_logic;
	signal ce_peripheral	: std_logic_vector(7 downto 0);	  
	
	signal ce_n				: std_logic;
	signal we_n				: std_logic;
	signal oe_n				: std_logic; 	  
	
	 
	signal addressR8 		: std_logic_vector(15 downto 0); 
	signal dataR8_out		: std_logic_vector(15 downto 0);
	signal dataR8_in		: std_logic_vector(15 downto 0);
	
	signal dataBus_Mem		: std_logic_vector(15 downto 0);
	signal dataMem_out		: std_logic_vector(15 downto 0);
	
	signal dataP1_out		: std_logic_vector(15 downto 0);
	signal dataP2_out		: std_logic_vector(15 downto 0);	
	
	signal intr  			: std_logic;  
	signal intr_A			: std_logic;
	signal intr_B			: std_logic;
	signal irq_A			: std_logic_vector(15 downto 0);
	signal irq_B			: std_logic_vector(15 downto 0);
	   
begin			 	
	-- Memory & Peripheral read/write    																						 
    wr_n <= not rw; 											-- R8 			( write->rw=0 read->rw=1 )		
																-- Memory 		( write->wr=1 read->wr=0 )
															   	-- Peripheral	( write->wr=1 read->wr=0 )
		
	--========================================================================================================
	-- CPU R8
	--========================================================================================================
    PROCESSOR: entity work.R8 
		generic map(
			DATA_WIDTH  => DATA_WIDTH,         					-- Data bus width
        	ADDR_WIDTH  => ADDR_WIDTH,         					-- Address bus width	
			ISR_ADDRESS => ISR_ADDRESS 
		)
        port map (
            clk         	=> clk, 
            rst         	=> rst, 
            data_in     	=> dataR8_in, 
            data_out    	=> dataR8_out, 
            address     	=> addressR8, 
            ce          	=> ce, 
            rw          	=> rw,	   
			intr			=> intr
        );
		
	dataR8_in	<= 	dataP1_out when addressR8(15 downto 12) = "1000" else 		-- MUX data_in
					dataP2_out when addressR8(15 downto 12) = "1001" else
					dataBus_Mem;		
					
	-- DataBus normaly is dataR8_in, but when want to write on memory DataBus receives dataR8_out
   	dataBus_Mem 	<= 	dataR8_out when ce_memory = '1' and rw='0' else     		-- Writing access
	   				(others => 'Z');   
					   
	-- Which interrupt from which port will become one single signal that enter on processor
	intr			<= 	intr_A or intr_B;
		
	--========================================================================================================
	-- CE Decoder
	--========================================================================================================
	CEDEC: entity work.AddressDecoder 
		generic map(
			DATA_WIDTH  		=> DATA_WIDTH          				-- Data bus width	  
		)
		port map(
			address 			=> addressR8,
			ce					=> ce,								-- CE from CPU
			ce_memory			=> ce_memory,					 	-- CE to memory
			ce_peripheral		=> ce_peripheral				  	-- CE to peripherals, which bit is one peripheral
		);
		
	--========================================================================================================
	-- Memory
	--========================================================================================================
    RAM: entity work.Memory   
        generic map (			
			SIZE				=> MEMORY_SIZE,						-- Memory depth (number of words) -- x words (xKB)
			START_ADDRESS		=> x"00000000",						-- Lowest address
			imageFileName		=> IMAGE						  	-- Memory content to be loaded
		)
        port map (
			clk     			=> clk,		  						-- This memory is 
			ce_n				=> ce_n,							-- Enable (low active)
			we_n				=> we_n,   							-- we_n = 0 -> write on memory
			oe_n				=> oe_n,					  		-- oe_n = 0 -> memory output data , oe_n = 1 -> memory receves data
			address 			=> addressR8,
			data			 	=> dataBus_Mem
        );	  			      										
		
    -- Memory access control signals       
    ce_n <= '0' when (ce_memory='1') else '1';
    oe_n <= '0' when (ce_memory='1' and rw='1') else '1';       
    we_n <= '0' when (ce_memory='1' and rw='0') else '1';    		
		
	--========================================================================================================
	-- I/O Port
	--========================================================================================================
	PORTA: entity work.BidirectionalPort
		generic map(
	        DATA_WIDTH          => DATA_WIDTH,    					-- Port width in bits
	        PORT_DATA_ADDR      => "10",     						-- Address of data register? 	= 2 
	        PORT_CONFIG_ADDR    => "01",							-- Address of config register  	= 1
	        PORT_ENABLE_ADDR    => "00",							-- Address of enable register  	= 0	 
			PORT_IRQENABLE_ADDR => "11"
	    )
	    port map(  
	        clk         		=> clk,
	        rst         		=> rst,
	        data_i      		=> dataR8_out,						-- Data from CPU
	        data_o      		=> dataP1_out,					 	-- Data to CPU
	        address    			=> addressR8(1 downto 0),
	        rw          		=> wr_n,							-- 0: read; 1: write   			
	        ce          		=> ce_peripheral(0),			   	-- Peripheral "ID" = 0 			CE_PA
	        port_io     		=> portA_io,						-- Data to external interface	 
			irq	 				=> irq_A
	    ); 																			  
		
	intr_A	<= or_reduce(irq_A);	 								-- AND between which bit of the net
		
	PORTB: entity work.BidirectionalPort
		generic map(
	        DATA_WIDTH          => DATA_WIDTH,    					-- Port width in bits
	        PORT_DATA_ADDR      => "10",     						-- Address of data register? 	= 2 
	        PORT_CONFIG_ADDR    => "01",							-- Address of config register  	= 1
	        PORT_ENABLE_ADDR    => "00",							-- Address of enable register  	= 0
			PORT_IRQENABLE_ADDR => "11"
	    )
	    port map(  
	        clk         		=> clk,
	        rst         		=> rst,
	        data_i      		=> dataR8_out,						-- Data from CPU
	        data_o      		=> dataP2_out,					 	-- Data to CPU
	        address    			=> addressR8(1 downto 0),
	        rw          		=> wr_n,							-- 0: read; 1: write
	        ce          		=> ce_peripheral(1),			   	-- Peripheral "ID" = 1 			CE_PB
	        port_io     		=> portB_io,						-- Data to external interface
	    	irq					=> irq_B
		);
		
		
	intr_B <= or_reduce(irq_B);										-- AND between which bit of the net
		
end arch1;