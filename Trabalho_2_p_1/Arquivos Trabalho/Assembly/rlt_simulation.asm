;------------------------------------------------
;            Projeto de Processadores
;        Descrição: I/O ports
;------------------------------------------------

;------------------------------------------------
; Pseudocode
;
;   set( all_enable_OFF )
;	set( all_pins_OUTPUT )                      // all pins as output
;   set( all_enable_ON )
;   read( enable_reg )
;   read( config_reg )
;   read( data_reg )
;   set( data_reg ) 
;   read( data_reg )
;	store( data_reg )							// store in memory
;
;   set( all_enable_off )               
;   set( all_pins_input )                       // all pins as input
;   set( all_enable_on )
;   read( config_reg )
;   read( data_reg )
;
;	store( data_reg )      						// store in memory	
;
;   set( all_enable_OFF )
;   set( half_pins_INPUT/half_pins_OUTPUT )     // "0000000011111111"
;   set( all_enable_ON )
;   set( data_reg )                             // "10101010zzzzzzzz"
;   read( data_reg )
;   set( data_reg )                             // "11111111zzzzzzzz"
;   read( data_reg )
;
;	store( data_reg )							// store in memory
;
;------------------------------------------------

.CODE
    LDH R1, ENABLE_REG_ADDR				
    LDL R1, ENABLE_REG_ADDR				; R1 <- &PERIPHERAL(0).ENABLE_REG

    LDH R2, CONFIG_REG_ADDR				
    LDL R2, CONFIG_REG_ADDR				; R2 <- &PERIPHERAL(0).CONFIG_REG

    LDH R3, DATA_REG_ADDR				 
    LDL R3, DATA_REG_ADDR				; R3 <- &PERIPHERAL(0).DATA_REG

    LDH R9, #LAST_DATA
    LDL R9, #LAST_DATA					; R9 <- &LAST_DATA

    ST R0, R0, R1						; PERIPHERAL(0).ENABLE_REG 	<- "0000000000000000" (ALL PINS OFF)
    ST R0, R0, R2						; PERIPHERAL(0).CONFIG_REG 	<- "0000000000000000" (ALL PINS OUTPUT)
    LDH R4, #FFh
    LDL R4, #FFh
    ST R4, R0, R1						; PERIPHERAL(0).ENABLE_REG 	<- "1111111111111111" (ALL PINS ON)
    LD R5, R0, R1						; R5 <- PERIPHERAL(0).ENABLE_REG
    LD R6, R0, R2						; R6 <- PERIPHERAL(0).CONFIG_REG
    LD R7, R0, R3						; R7 <- PERIPHERAL(0).DATA_REG
    LDH R4, #0Fh
    LDL R4, #0Fh
    ST R4, R0, R3						; PERIPHERAL(0).DATA_REG 	<- "0000111100001111"
    LD R8, R0, R3						; R8 <- PERIPHERAL(0).DATA_REG
    
    ST R8, R0, R9						; PMEM( &LAST_DATA ) <- R8

    ST R0, R0, R1						; PERIPHERAL(0).ENABLE_REG 	<- "0000000000000000" (ALL PINS OFF)
    LDH R4, #FFh
    LDL R4, #FFh
    ST R4, R0, R2						; PERIPHERAL(0).CONFIG_REG 	<- "1111111111111111" (ALL PINS OUTPUT)
    ST R4, R0, R1						; PERIPHERAL(0).ENABLE_REG 	<- "1111111111111111" (ALL PINS ON)
    LD R6, R0, R2						; R6 <- PERIPHERAL(0).CONFIG_REG
    LD R7, R0, R3						; R7 <- PERIPHERAL(0).DATA_REG

    ST R7, R0, R9						; PMEM( &LAST_DATA ) <- R9

    ST R0, R0, R1						; PMEM( PERIPHERAL(0).ENABLE_REG ) 	<- "0000000000000000" (ALL PINS OFF)
    LDH R4, #FFh
    LDL R4, #00h
    ST R4, R0, R2						; PMEM( PERIPHERAL(0).CONFIG_REG ) 	<- "1111111100000000" (ALL PINS OUTPUT)
    LDL R4, #FFh
    ST R4, R0, R1						; PMEM( PERIPHERAL(0).ENABLE_REG ) 	<- "1111111111111111" (ALL PINS ON)
    LDH R4, #AAh
    ST R4, R0, R3						; PMEM( PERIPHERAL(0).DATA_REG ) 	<- "1010101011111111"
    LD R7, R0, R3						; R7 <- PMEM( PERIPHERAL(0).DATA_REG )
    LDH R4, #FFh
    LDL R4, #00h
    ST R4, R0, R3						; PERIPHERAL(0).DATA_REG 	<- "1111111100000000"
    LD R8, R0, R3						; R8 <- PERIPHERAL(0).DATA_REG

    ST R8, R0, R9						; PMEM( &LAST_DATA ) <- R8

fim:
    HALT                 	; Termina a execução     

.ENDCODE

.DATA
	ENABLE_REG_ADDR:	db		#8000h
	CONFIG_REG_ADDR:  	db    	#8001h
	DATA_REG_ADDR:  	db    	#8002h
	LAST_DATA:			db		#0000h
    

.ENDDATA