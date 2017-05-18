-----------------------------------------------------------------------------------------
-- Design unit: I/O Peripheral
-- Description: 
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity BidirectionalPort  is
    generic (
        DATA_WIDTH          : integer;    							-- Port width in bits
        PORT_DATA_ADDR      : std_logic_vector(1 downto 0);     	-- Address of data register? 	= 0 
        PORT_CONFIG_ADDR    : std_logic_vector(1 downto 0);     	-- Address of config register  	= 1
        PORT_ENABLE_ADDR    : std_logic_vector(1 downto 0);      	-- Address of enable register  	= 2
		PORT_IRQENABLE_ADDR : std_logic_vector(1 downto 0) 			-- Address of irEnable register = 3
		
    );
    port (  
        clk         		: in std_logic;
        rst         		: in std_logic; 
        
        -- Processor interface
        data_i      		: in std_logic_vector (DATA_WIDTH-1 downto 0);
        data_o      		: out std_logic_vector (DATA_WIDTH-1 downto 0);
        address    			: in std_logic_vector (1 downto 0);     		
        rw          		: in std_logic; 								-- 0: read; 1: write
        ce          		: in std_logic;
        
        -- External interface
        port_io     		: inout std_logic_vector (DATA_WIDTH-1 downto 0);  
		
		-- Interrupt signal
		irq					: out std_logic_vector (DATA_WIDTH-1 downto 0)
    );
end BidirectionalPort ;

architecture Behavioral of BidirectionalPort  is   

	signal ce_regData		: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal ce_regConfig		: std_logic;
	signal ce_regEnable		: std_logic;
	signal ce_regIrqEnable  : std_logic;
	
	signal regData_in		: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal regData_out		: std_logic_vector( DATA_WIDTH-1 downto 0 ); 
	signal regSynch_out		: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal regConfig_out	: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal regEnable_out	: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal regIrqEnable_out : std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal triState_in		: std_logic_vector( DATA_WIDTH-1 downto 0 );
	signal triState_out 	: std_logic_vector( DATA_WIDTH-1 downto 0 );

begin	
	
	-- PortData register - Stores the value (from INPUT) or (to OUTPUT)
	REG_DATA: for I in 0 to (DATA_WIDTH-1)	generate 
		REG: entity work.Flipflop
		generic map(		  
			INIT_VALUE	=> '0'		
		)
		port map(
			clk			=> clk,
			rst			=> rst,
		  	ce			=> ce_regData(I),
			d			=> regData_in(I),
			q			=> regData_out(I)						  
    	);
	end generate REG_DATA;
		
	-- PortConfig register - Select the peripheral fuction (0 = output) and (1 = input)
	REG_CONFIG: entity work.RegisterNbits
		generic map(
			WIDTH		=> DATA_WIDTH,
			INIT_VALUE	=> 0		
		)
		port map(
			clk			=> clk,
			rst			=> rst,
		  	ce			=> ce_regConfig,
			d			=> data_i,
			q			=> regConfig_out						  
    	);	  
	
	-- irqEnable register - Select which signal generate interruption
	REG_IRQENABLE: entity work.RegisterNbits
		generic map(
			WIDTH		=> DATA_WIDTH,
			INIT_VALUE	=> 0		
		)
		port map(
			clk			=> clk,
			rst			=> rst,
		  	ce			=> ce_regIrqEnable,
			d			=> data_i,
			q			=> regIrqEnable_out						  
    	);	
		
	-- PortEnable register - Enable to read input or to write output if "1"
	REG_ENABLE: entity work.RegisterNbits
		generic map(
			WIDTH		=> DATA_WIDTH,
			INIT_VALUE	=> 0		
		)
		port map(
			clk			=> clk,
			rst			=> rst,
		  	ce			=> ce_regEnable,
			d			=> data_i,
			q			=> regEnable_out			  
    	);
		
	-- SYNC Register - This register synchronizes the exterior signal with the internal CPU.	
	-- This prevents the value to change when the CPU wants to read the value.
	SYNCH: entity work.RegisterNbits
		generic map(
			WIDTH		=> DATA_WIDTH,
			INIT_VALUE	=> 0		
		)
		port map(
			clk			=> clk,
			rst			=> rst,
		  	ce			=> '1',
			d			=> triState_in,
			q			=> regSynch_out						  
    	);	
	
	-- CE logic - Signal that enables to write in the register selected  												
	ce_regConfig   	<= '1' when (address = PORT_CONFIG_ADDR and ce = '1' and rw = '1') else '0';
	ce_regEnable   	<= '1' when (address = PORT_ENABLE_ADDR and ce = '1' and rw = '1') else '0';  
	ce_regIrqEnable <= '1' when (address = PORT_IRQENABLE_ADDR and ce = '1' and rw = '1') else '0';  

	-- MUX OUTPUT - Output from the I/O peripheral unit	 (data to CPU)
	data_o	<=	regEnable_out when (address = PORT_ENABLE_ADDR 	and ce = '1') else
				regConfig_out when (address = PORT_CONFIG_ADDR 	and ce = '1') else
				regData_out   when (address = PORT_DATA_ADDR 	and ce = '1')   else
				(others=>'Z');	   
				
	-- BITWISE LOGIC to input and output
	FORBB: for I in 0 to (DATA_WIDTH-1)	generate 
		regData_in(I)	<= 	regSynch_out(I) when (((not regConfig_out(I)) and regEnable_out(I)) = '0') else			-- Data register input logic
							data_i(I);
	
		ce_regData(I)	<=	'1' when regConfig_out(I) = '1' else																-- If Nth-bit is INPUT ways write on Reg Data
							'1' when (regConfig_out(I) = '0' and address = PORT_DATA_ADDR and ce = '1' and rw = '1') else		-- If Nth-bit is OUTPUT, enable look for address, ce and wr to write
							'0';
							
		triState_in(I)	<=	port_io(I) when ((regConfig_out(I) and regEnable_out(I)) = '1') else	  				-- Input TRISTATE
							'Z';
						
		triState_out(I)	<=	regData_out(I) when (((not regConfig_out(I)) and regEnable_out(I)) = '1') else		   	-- Output TRISTATE
							'Z';					  
							
		irq(I)	<= regData_out(I) and regConfig_out(I) and regEnable_out(I) and regIrqEnable_out(I);
							
	end generate FORBB;
	
	-- External world interface
	port_io			<=	triState_out;
	
end Behavioral;