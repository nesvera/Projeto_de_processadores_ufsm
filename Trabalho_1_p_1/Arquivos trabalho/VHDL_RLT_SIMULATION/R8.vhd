-------------------------------------------------------------------------
-- Design unit: R8
-- Description: Comportamental description of R8
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use ieee.std_logic_unsigned.all; 	-- CONV_INTEGER function	
USE ieee.numeric_std.ALL;

entity R8 is
	generic(
		DATA_WIDTH  	: integer := 16;         	-- Data bus width
        ADDR_WIDTH  	: integer := 16         	-- Address bus width
	);
    port( 
        clk     		: in std_logic;
        rst     		: in std_logic;
        
        -- Memory interface
        data_in 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
        address 		: out std_logic_vector(ADDR_WIDTH-1 downto 0);
        ce      		: out std_logic;
        rw      		: out std_logic 
    );
end R8;

architecture behavioral of R8 is   

	-- The 'instruction' enumeration indicates the decoded one by the control path  -- 28 instructions
    -- The 15 conditional jumps are grouped in just 3 instruction classes: 
    --      JUMP_R: JMPR, JMPNR, JMPZR, JMPCR, JMPVR        - Register relative jump
    --      JUMP_A: JMP, JMPN, JMPZ, JMPC, JMPV             - Absolute jump
    --      JUMP_D: JMPD, JMPND, JMPZD, JMPCD, JMPVD        - Displacement jump
    type Instruction is ( 
        ADD, SUB, AAND, OOR, XXOR, ADDI, SUBI, NOT_A, 
        SL0, SL1, SR0, SR1,
        LDL, LDH, LD, ST, LDSP, POP, PUSH,
        JUMP_R, JUMP_A, JUMP_D, JSRR, JSR, JSRD,
        NOP, HALT,  RTS
    );				  
	signal decodedInstruction: Instruction;

	-- Control path
	-- 13 states
    type State  is (Sidle, Sfetch, Sreg, Shalt, Salu, Srts, Spop, Sldsp, Sld, Sst, Swbk, Sjmp, Ssbrt, Spush);
    signal currentState: State;	   -- talvez tirar next
	
	-- Data path
	-- Data register
	signal pc, sp, ir, rA, rB, rALU : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal carryFlag, negativeFlag, zeroFlag, overflowFlag: std_logic;
	
	-- Register bank
	type RegisterArray is array (0 to 15) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal registerFile: RegisterArray;		 
	
	-- ALU inputs
	signal opA:	std_logic_vector(DATA_WIDTH-1 downto 0);
	signal opB: std_logic_vector(DATA_WIDTH-1 downto 0); 
	
	-- Clock counter
	signal clkCount: std_logic_vector(16 downto 0);
											   
begin   
  	-- Machine state
	process(rst, clk)
		variable result 		: std_logic_vector(16 downto 0); 	 
		variable zeroVar		: std_logic;
		variable negativeVar	: std_logic;
		variable carryVar		: std_logic;
		variable overflowVar	: std_logic;
		
	begin
		if rst = '1' then	
			-- Reset all registers
			currentState 	<= Sidle;  
			
			pc				<= (others => '0');
			sp				<= x"7FFF";
			ir				<= (others => '0');
			rA				<= (others => '0');
			rB				<= (others => '0');
			rALU			<= (others => '0');
			carryFlag		<= '0';
			negativeFlag	<= '0';
			zeroFlag		<= '0';
			overflowFlag	<= '0';	   
			
			clkCount		<= (others => '0');
			
			--registerFile	<= (others=>(others => '0'));
			
			for i in 0 to 15 loop
				registerFile(i)	<= (others => '0');	
				
			end loop;  			   							 
			
		elsif rising_edge(clk) then
			clkCount	<= clkCount + x"1";
			
			case currentState is  
				
				-- Sidle is the state the machine stays while processor is being reset
				when Sidle =>  
                	currentState <= Sfetch;
       			
				--=============================================================================================
            	-- First clock cycle after reset and after each instruction ends execution
				--=============================================================================================
            	when Sfetch =>     																 
					ir		<=	data_in;		-- IR receives Memory value addressed by PC value
					pc		<=	pc + x"1";		-- PC is incremented 
					
					currentState <= Sreg;
					
				--=============================================================================================
	            -- Second clock cycle of every instruction 
				-- Decode instructions
				-- rA and rB receveis values from source1 and source2
	           	--=============================================================================================
				when Sreg =>   			 		
					-- ADD, SUB, AAND, OOR, XXOR, LD, ST, SHIFTS, NOT, LDSP		RA <- Rs1	RB <- Rs2				(they have the same target and sources)
					if (decodedInstruction = ADD or decodedInstruction = SUB or decodedInstruction = AAND or decodedInstruction = OOR or 
						decodedInstruction = XXOR or decodedInstruction = SL0 or decodedInstruction = SL1 or decodedInstruction = SR0 or 
						decodedInstruction = SR1 or decodedInstruction = NOT_A or decodedInstruction = LDSP or decodedInstruction = LD or
						decodedInstruction = ST ) then
						
						rA	<= registerFile(to_integer(unsigned(ir(7 downto 4))));
						rB	<= registerFile(to_integer(unsigned(ir(3 downto 0))));	  
						
						currentState	<= Salu;
						
					-- ADDI, SUBI, LDL, LDH, PUSH  									RA <- Rt	RB <- constant			(they have the same target and constant format)
					elsif decodedInstruction = ADDI or decodedInstruction = SUBI or decodedInstruction = LDL or decodedInstruction = LDH or
						  decodedInstruction = PUSH then
						
						rA	<= registerFile(to_integer(unsigned(ir(7 downto 4))));
						rB	<= registerFile(to_integer(unsigned(ir(11 downto 8))));
						
						currentState	<= Salu;	
						
					-- NOP, RTS, POP, JSRD
					elsif decodedInstruction = NOP or decodedInstruction = RTS or decodedInstruction = POP or decodedInstruction = JSRD then
						currentState	<= Salu;			
						
					-- JSR, JSRR, JUMP_A, JUMP_R
					elsif decodedInstruction = JSR or decodedInstruction = JSRR or decodedInstruction = JUMP_A or decodedInstruction = JUMP_R then
						rA	<= registerFile(to_integer(unsigned(ir(7 downto 4))));
						rB	<= registerFile(to_integer(unsigned(ir(3 downto 0))));
						
						currentState	<= Salu;		 
						
					-- JUMP_D
					elsif decodedInstruction = JUMP_D then
						currentState 	<= Salu;
					
					-- HALT (do nothing and go to Shalt)
					elsif decodedInstruction = HALT then
						currentState	<= Shalt;
					end if;
				
				--=============================================================================================
	            -- Third clock cycle of every instruction - there are 9 distinct destination states from here
				--=============================================================================================
	            when Salu =>				
					-- ADD 					
					if	decodedInstruction = ADD then		   
						result			:= ('0'&opA) + ('0'&opB);
						rALU			<= result(15 downto 0);	   							-- Rt <- Rs1 + Rs2
						
						negativeVar			:= '0';
						zeroVar				:= '0';
						carryVar			:= '0';
						overflowVar			:= '0';
						
						if result(15) = '1' then											-- negative
							negativeVar		:= '1';		 
																							-- (+) + (-) = (-) ok
																							-- (-) + (-) = (-) ok
																							-- (-) + (+) = (-) ok
							if (opA(15) = '0' and opB(15) = '0') then 						-- (+) + (+) = (-) overflow	   
								overflowVar		:= '1';	
							end if;	   
							
						else					
																							-- (+) + (-) = (+) ok
																							-- (-) + (+) = (+) ok
																							-- (+) + (+) = (+) ok
							if (opA(15) = '1' and opB(15) = '1') then	   					-- (-) + (-) = (+) overflow
								overflowVar		:= '1';
							end if;
						end if;	   
						
						if result(15 downto 0) = x"0" then 									-- zero
							zeroVar			:= '1';
						end if;
						
						if result(16) = '1' then											-- carry
							carryVar		:= '1';			
						end if;		 
												
						negativeFlag		<= negativeVar;
						zeroFlag			<= zeroVar;
						carryFlag			<= carryVar;
						overflowFlag		<= overflowVar;
						
						currentState	<= Swbk;
						
					-- ADDI	 
					elsif decodedInstruction = ADDI then	  	 						
						result			:= ("000000000" & opA(7 downto 0)) + ('0'&opB);
						rALU			<= result(15 downto 0);	   							-- Rt <- Rt + "00000000"&constante
						
						negativeVar			:= '0';
						zeroVar				:= '0';
						carryVar			:= '0';
						overflowVar			:= '0';
						
						if result(15) = '1' then											-- negative
							negativeVar		:= '1';			  
																							-- (+) + (-) = (-) ok
							if opB(15) = '0' then											-- (+) + (+) = (-) overflow
								overflowVar		:= '1';
							end if;
						end if;
																							-- positive
																							-- (+) + (-) = (+) ok
																							-- (+) + (+) = (+) ok
						
						if result(15 downto 0) = x"0" then									-- zero
							zeroVar			:= '1';
						end if;	
						
						if result(16) = '1' then											-- carry
							carryVar		:= '1';	 
						end if;
						
						negativeFlag		<= negativeVar;
						zeroFlag			<= zeroVar;
						carryFlag			<= carryVar;
						overflowFlag		<= overflowVar;
						
						currentState	<= Swbk;
						
					-- SUB
					elsif decodedInstruction = SUB then	      
						result	:= '0'&opA + ('0'&(not opB)) + x"1";						-- Rt <- Rs1 - Rs2		 (complemento de 2 é usado para o carry aparecer)  
						rALU	<= result(15 downto 0);	  
						
						negativeVar			:= '0';
						zeroVar				:= '0';
						carryVar			:= '0';
						overflowVar			:= '0';
						
						if result(15) = '1' then											-- negative
							negativeVar		:= '1';
																							-- (+) - (+) = (-) ok
																							-- (-) - (+) = (-) ok
																							-- (-) - (-) = (-) ok
							if (opA(15) = '0' and opB(15) = '1') then						-- (+) - (-) = (-) overflow
								overflowVar		:= '1';
							end if;	
							
						else	  															-- positive
																							-- (+) - (+) = (+) ok
																							-- (-) - (-) = (+) ok
																							-- (+) - (-) = (+) ok
							if (opA(15) = '1' and opB(15) = '0') then						-- (-) - (+) = (+) overflow
								overflowVar		:= '1';
							end if;		
							
						end if;
						
						if result(15 downto 0) = x"0" then 									-- zero
							zeroVar			:= '1';
						end if;							  
						
						if result(16) = '1' then								 			-- carry
							carryVar		:= '1';	 
						end if;							
						
						negativeFlag		<= negativeVar;
						zeroFlag			<= zeroVar;
						carryFlag			<= carryVar;
						overflowFlag		<= overflowVar;
						
						currentState	<= Swbk;
						
					-- SUBI
					elsif decodedInstruction = SUBI then  
						result	:= '0'&opB + ('0'&(not("00000000"&opA(7 downto 0)))) + x"1"; 	   							-- Rt <- Rt - constant 
						rALU	<= result(15 downto 0);	  
						
						negativeVar			:= '0';
						zeroVar				:= '0';
						carryVar			:= '0';
						overflowVar			:= '0';
						
						if result(15) = '1' then											-- negative
							negativeVar		:= '1';		
																							-- (-) = (+) - (+) ok
																							-- (-) = (-) - (-) ok
																							
						else																-- positive	   
							
							if opB(15) = '1' then											-- (-) - (+) = (-) overflow		
								overflowVar		:= '1';			  
							end if;		  
																							-- (+) = (+) - (+) ok
						end if;
						
						if result(15 downto 0) = x"0" then 									-- zero
							zeroVar			:= '1';
						end if;
						
						if result(16) = '1' then											-- carry
							carryVar		:= '1';
						end if;
						
						negativeFlag		<= negativeVar;
						zeroFlag			<= zeroVar;
						carryFlag			<= carryVar;
						overflowFlag		<= overflowVar;
						
						currentState	<= Swbk;
						
					-- AND
					elsif decodedInstruction = AAND then
						result	:= '0'&opA and '0'&opB;
						rALU	<= result(15 downto 0);  
						
						negativeFlag		<= '0';
						zeroFlag			<= '0';
						
						if result(15) = '1' then																	-- negative
							negativeFlag	<= '1';
						
						elsif result(15 downto 0) = x"0" then 														-- zero
							zeroFlag		<= '1';
						end if;
						
						currentState	<= Swbk;
						
					-- OR
					elsif decodedInstruction = OOR then
						result	:= '0'&opA or '0'&opB;
						rALU	<= result(15 downto 0); 	
						
						negativeFlag		<= '0';
						zeroFlag			<= '0';	 
						
						if result(15) = '1' then																	-- negative
							negativeFlag	<= '1';
						
						elsif result(15 downto 0) = x"0" then 														-- zero
							zeroFlag		<= '1';
						end if;
						
						currentState	<= Swbk;
						
					-- XOR
					elsif decodedInstruction = XXOR then
						result	:= '0'&opA xor '0'&opB;
						rALU	<= result(15 downto 0); 	
						
						negativeFlag		<= '0';
						zeroFlag			<= '0';
						
						if result(15) = '1' then																	-- negative
							negativeFlag	<= '1';
						
						elsif result(15 downto 0) = x"0" then 														-- zero
							zeroFlag		<= '1';
						end if;
						
						currentState	<= Swbk;
						
					-- LDL
					elsif decodedInstruction = LDL then
						rALU	<= opB(15 downto 8) & opA(7 downto 0);
						
						currentState	<= Swbk;
						
					-- LDH
					elsif decodedInstruction = LDH then
						rALU	<= opA(7 downto 0) & opB(7 downto 0);
						
						currentState 	<= Swbk;
					
					-- LD
					elsif decodedInstruction = LD then
						rALU			<= opA + opB;	   
					   
						currentState	<= Sld;
						
					-- ST
					elsif decodedInstruction = ST then
						rALU			<= opA + opB;	   
					
						currentState	<= Sst;		
						
					-- SL0
					elsif decodedInstruction = SL0 then
						result	:= opA(15 downto 0) & '0';
						rALU	<= result(15 downto 0); 	
						
						negativeFlag		<= '0';
						zeroFlag			<= '0';
						
						if result(15) = '1' then																	-- negative
							negativeFlag	<= '1';
						
						elsif result(15 downto 0) = x"0" then 														-- zero
							zeroFlag		<= '1';
						end if;
						
						currentState 	<= Swbk;
						
					-- SL1
					elsif decodedInstruction = SL1 then
						result	:= opA(15 downto 0) & '1';
						rALU	<= result(15 downto 0); 	
						
						negativeFlag		<= '0';
						zeroFlag			<= '0';
						
						if result(15) = '1' then																	-- negative
							negativeFlag	<= '1';
						
						elsif result(15 downto 0) = x"0" then 														-- zero
							zeroFlag		<= '1';
						end if;
						
						currentState 	<= Swbk;
					
					-- SR0
					elsif decodedInstruction = SR0 then
						result	:= "00" & opA(15 downto 1);
						rALU	<= result(15 downto 0); 	
						
						negativeFlag		<= '0';
						zeroFlag			<= '0';
						
						if result(15) = '1' then																	-- negative
							negativeFlag	<= '1';
						
						elsif result(15 downto 0) = x"0" then 														-- zero
							zeroFlag		<= '1';
						end if;
						
						currentState 	<= Swbk;
					
					-- SR1
					elsif decodedInstruction = SR1 then
						result	:= "01" & opA(15 downto 1);
						rALU	<= result(15 downto 0); 	
						
						negativeFlag		<= '0';
						zeroFlag			<= '0';
						
						if result(15) = '1' then																	-- negative
							negativeFlag	<= '1';
						
						elsif result(15 downto 0) = x"0" then 														-- zero
							zeroFlag		<= '1';
						end if;
						
						currentState 	<= Swbk;
						
					-- NOT
					elsif decodedInstruction = NOT_A then
						result	:= not('0'&opA);
						rALU	<= result(15 downto 0); 	
						
						negativeFlag		<= '0';
						zeroFlag			<= '0';
						
						if result(15) = '1' then																	-- negative
							negativeFlag	<= '1';
						
						elsif result(15 downto 0) = x"0" then 														-- zero
							zeroFlag		<= '1';
						end if;
						
						currentState 	<= Swbk;
						
					-- LDSP
					elsif decodedInstruction = LDSP then
						rALU			<= opA;									-- ALU pass rA
						
						currentState 	<= Sldsp;
						
					-- RTS
					elsif decodedInstruction = RTS then
						rALU			<= sp + x"1";
						
						currentState	<= Srts;
						
					-- POP
					elsif decodedInstruction = POP then
						rALU			<= sp + x"1";
						
						currentState	<= Spop;
						
					-- PUSH
					elsif decodedInstruction = PUSH then
						rALU			<= opB;
						
						currentState	<= Spush;
					
					-- JSR
					elsif decodedInstruction = JSR then
						rALU			<= opA;
						
						currentState 	<= Ssbrt;
					   
					-- JSRR
					elsif decodedInstruction = JSRR	then
						rALU			<= opA + opB;
						
						currentState	<= Ssbrt;
						
					-- JSRD
					elsif decodedInstruction = JSRD then   
						if opA(11) = '0' then
							rALU			<= ("0000"&opA(11 downto 0)) + opB;
						else
							rALU			<= ("1111"&opA(11 downto 0)) + opB;	
						end if;
						
						currentState	<= Ssbrt;		
						
					-- JMP_R
					elsif decodedInstruction = JUMP_R then					
						rALU			<= opA + opB;
						
						currentState <= Sjmp;
						
					-- JUMP_D
	                elsif decodedInstruction = JUMP_D then   
						if opA(9) = '0' then
							rALU			<= ("000000"&opA(9 downto 0)) + opB;  
						else
							rALU			<= ("111111"&opA(9 downto 0)) + opB;
						end if;
							
	                    currentState <= Sjmp;
	                
					-- JUMP_A
	                elsif decodedInstruction = JUMP_A then 
						rALU			<= opA;
						
	                    currentState <= Sjmp;
						
	               -- NOP
	                else    -- ** ATTENTION ** NOP and jumps with corresponding flag=0 execute in just 3 clock cycles 
	                    currentState <= Sfetch;   
	                end if;
				
				--=============================================================================================
	            -- Fourth clock cycle of several instructions 
				--=============================================================================================
				when Swbk =>  
					registerFile(to_integer(unsigned(ir(11 downto 8))))	<=	rALU;			-- Rt <- rALU
				
					currentState	<= Sfetch;
					
				when Sld =>
					registerFile(to_integer(unsigned(ir(11 downto 8))))	<=	data_in;		-- Rt <- PMEM(Rs1+Rs2)
					
					currentState	<= Sfetch;
					
				when Sst =>  
	                currentState 	<= Sfetch; 
					
				when Sldsp =>
					sp				<= rALU;   
					
					currentState	<= Sfetch;
					
				when Srts =>
					pc				<= data_in;					-- PC <- PMEM(SP+1)
					sp				<= sp + x"1";			  	-- SP <- SP + 1
					
					currentState 	<= Sfetch;
					
				when Spop =>
					sp				<= sp + x"1";										-- SP <- SP + 1
				 	registerFile(to_integer(unsigned(ir(11 downto 8))))	<= data_in;		-- Rt <- PMEM(SP+1)
					 
					currentState	<= Sfetch;
					
				when Spush =>
					sp				<= sp - x"1";		-- SP <- SP-1
														-- PMEM(SP) <- data_out		data_out = Rt  
					currentState	<= Sfetch;
				
				when Ssbrt =>
					sp 				<= sp - x"1";		-- SP <- SP-1
					pc				<= rALU;			-- PC <- Rs1  or	PC <- PC+displace
														-- PMEM(SP) <- data_out		data_out = PC
					currentState	<= Sfetch;
				
				when Sjmp =>  	  
					-- JMPR, JMP
					if ((decodedInstruction = JUMP_R or decodedInstruction = JUMP_A) and (ir(3 downto 0) = x"0" or ir(3 downto 0) = x"5" ))then		-- unconditional jump
						pc			<= rALU;
						
					-- JMPD	 
					elsif decodedInstruction = JUMP_D and ir(15 downto 12) = x"D" then																-- unconditional jump
						pc			<= rALU;
					
					-- JMPNR, JMPN
					elsif ((decodedInstruction = JUMP_R or decodedInstruction = JUMP_A) and (ir(3 downto 0) = x"1" or ir(3 downto 0) = x"6" )) then	-- conditional jump (negative)
						if negativeFlag = '1' then
							pc		<= rALU;
						end if;
						
					-- JMPND
					elsif (decodedInstruction = JUMP_D and ir(11 downto 10) = x"0") then
						if negativeFlag = '1' then
							pc		<= rALU;
						end if;
						
					-- JMPZR, JMPZ
					elsif ((decodedInstruction = JUMP_R or decodedInstruction = JUMP_A) and (ir(3 downto 0) = x"2" or ir(3 downto 0) = x"7" )) then	-- conditional jump (zero)
						if zeroFlag = '1' then
							pc		<= rALU;
						end if;
						
					-- JMPZD														   
					elsif (decodedInstruction = JUMP_D and ir(11 downto 10) = x"1") then
						if zeroFlag = '1' then
							pc		<= rALU;
						end if;
						
					-- JMPCR, JMPC
					elsif ((decodedInstruction = JUMP_R or decodedInstruction = JUMP_A) and (ir(3 downto 0) = x"3" or ir(3 downto 0) = x"8" )) then	-- conditional jump (carry)
						if carryFlag = '1' then
							pc		<= rALU;
						end if;
						
					-- JMPCD														   
					elsif (decodedInstruction = JUMP_D and ir(11 downto 10) = x"2") then
						if carryFlag = '1' then
							pc		<= rALU;
						end if;
						
					-- JMPVR, JMPV
					elsif ((decodedInstruction = JUMP_R or decodedInstruction = JUMP_A) and (ir(3 downto 0) = x"4" or ir(3 downto 0) = x"9" )) then	-- conditional jump (overflow)
						if overflowFlag = '1' then
							pc		<= rALU;
						end if;
						
					-- JMPVD														   
					elsif (decodedInstruction = JUMP_D and ir(11 downto 10) = x"3") then
						if overflowFlag = '1' then
							pc		<= rALU;
						end if;	
					end if;
						
	                currentState 	<= Sfetch;           	            
	            
	            -- The HALT instruction locks the processor until external reset occurs
	            when Shalt  =>  
	                currentState <= Shalt;
			
			end case;
		end if;	
	end process;	
	
	----------------------------------------------------------------------------------------
    -- Instruction decoding --
    ----------------------------------------------------------------------------------------
    decodedInstruction <=   ADD     when ir(15 downto 12) = x"0" else
                            SUB     when ir(15 downto 12) = x"1" else
                            AAND    when ir(15 downto 12) = x"2" else
                            OOR     when ir(15 downto 12) = x"3" else
                            XXOR    when ir(15 downto 12) = x"4" else
                            ADDI    when ir(15 downto 12) = x"5" else
                            SUBI    when ir(15 downto 12) = x"6" else
                            LDL     when ir(15 downto 12) = x"7" else
                            LDH     when ir(15 downto 12) = x"8" else
                            LD      when ir(15 downto 12) = x"9" else
                            ST      when ir(15 downto 12) = x"A" else
                            SL0     when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"0" else
                            SL1     when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"1" else
                            SR0     when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"2" else
                            SR1     when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"3" else
                            NOT_A   when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"4" else
                            NOP     when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"5" else
                            HALT    when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"6" else
                            LDSP    when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"7" else
                            RTS     when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"8" else
                            POP     when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"9" else
                            PUSH    when ir(15 downto 12) = x"B" and ir(3 downto 0) = x"A" else 
               
                            -- Jump instructions (18). 
                            -- Here the status flags are tested to jump or not
                            JUMP_R  when 	ir(15 downto 12) = x"C" and (
	                                     		ir(3 downto 0) = x"0" or                           		-- JMPR
	                                    		ir(3 downto 0) = x"1" or   								-- JMPNR
	                                    		ir(3 downto 0) = x"2" or       							-- JMPZR
	                                    		ir(3 downto 0) = x"3" or      							-- JMPCR
	                                    		ir(3 downto 0) = x"4")       							-- JMPVR
							else 

                            JUMP_A  when 	ir(15 downto 12) = x"C" and (
                                     			ir(3 downto 0) = x"5" or                           		-- JMP
                                    			ir(3 downto 0) = x"6" or   								-- JMPN
                                    			ir(3 downto 0) = x"7" or       							-- JMPZ
												ir(3 downto 0) = x"8" or      							-- JMPC
                                    			ir(3 downto 0) = x"9")      							-- JMPV
							else 

                            JUMP_D  when 	ir(15 downto 12) = x"D" or (                           		-- JMPD
	                                        	ir(15 downto 12) = x"E" and ( 
		                                            ir(11 downto 10) = "00" or 							-- JMPND
		                                            ir(11 downto 10) = "01" or    						-- JMPZD
		                                            ir(11 downto 10) = "10" or    						-- JMPCD
		                                            ir(11 downto 10) = "11")   							-- JMPVD
                            				)  
							else 

                            JSRR  when ir(15 downto 12) = x"C" and ir(3 downto 0) = x"A" else
                            JSR   when ir(15 downto 12) = x"C" and ir(3 downto 0) = x"B" else
                            JSRD  when ir(15 downto 12) = x"F" else

                            NOP ;   -- IMPORTANT: default condition in case of conditional jumps with corresponding flag = '0';
	
	----------------------------------------------------------------------------------------
    -- ALU inputs --
    ----------------------------------------------------------------------------------------
	-- Selects the A operand for the ALU    
   	-- MUX connected to the ALU 'A' input
	opA <= 	"0000" & ir(11 downto 0) 	when 	decodedInstruction = ADDI or decodedInstruction = SUBI or decodedInstruction = LDL  or decodedInstruction = LDH or decodedInstruction = LDL or
												decodedInstruction = JUMP_D or decodedInstruction = JSRD else 			
			rA;   
			
    -- Selects the B operand for the ALU, or memory
	-- MUX connected to the ALU 'B' input  
    opB <=	rB 	when 	decodedInstruction = ADD or decodedInstruction = SUB or decodedInstruction = AAND or decodedInstruction = OOR or
						decodedInstruction = XXOR or decodedInstruction = LD or decodedInstruction = ST or decodedInstruction = SL0 or
	 					decodedInstruction = SL1 or decodedInstruction = SR0 or decodedInstruction = SR1  or decodedInstruction = NOT_A or
						decodedInstruction = LDSP or decodedInstruction = ADDI or decodedInstruction = SUBI or decodedInstruction = LDL or
						decodedInstruction = LDH else
		 	sp 	when	decodedInstruction = RTS or decodedInstruction = POP else
			pc;
			
	----------------------------------------------------------------------------------------
    -- Memory interface --
    ----------------------------------------------------------------------------------------
	-- Selection of who addresses the external memory   
    address <=	sp when currentState = Spush or  currentState = Ssbrt else  -- In subroutine call memory is addressed by SP to store PC
				pc when currentState = Sfetch else    						-- In instruction fetch memory is addressed by PC
				rALU;								   						-- RALU register. Used for LD/ST instructions.
					
	--address <= pc;	
				
   -- Data selection to memory storing											   
   -- MUX connected to memory data bus 
   data_out <=  registerFile(to_integer(unsigned(ir(11 downto 8)))) when decodedInstruction = ST or decodedInstruction = PUSH else    	-- ST
	   			opB;
	   
	-- Controls the memory access
    --      rw = 0: write
    --      rw = 1: read
    ce <= '1' when rst = '0' and (currentState = Sfetch or currentState = Srts or currentState = Spop or currentState = Sld or currentState = Ssbrt or currentState = Spush or currentState = Sst) else '0';
    rw <= '1' when currentState = Sfetch or currentState = Srts or currentState = Spop or currentState = Sld else '0';
	
end behavioral;