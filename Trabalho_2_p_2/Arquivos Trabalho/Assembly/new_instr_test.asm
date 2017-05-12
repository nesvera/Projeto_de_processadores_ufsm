;------------------------------------------------
;            Projeto de Processadores
;        Descrição: I/O ports
;------------------------------------------------

;------------------------------------------------
; Pseudocode
;
;   R1 = 2;
;   R2 = 10;
;   R3,R4 = R1 * R2
;   R5,R6 = R2 / R1
;
;   R1 = 100
;   R2 = 30;
;   R3,R4 = R1*R2
;   R5,R6 = R2/R1
;
;------------------------------------------------

.CODE
    LDH R1, #00h			
    LDL R1, #02h				        ; R1 <- x"0002" (2)

    LDH R2, #00h            
    LDL R2, #0Ah                        ; R2 <- x"000A" (10)


    MUL R1, R2
    MFH R3                              ; R3 <- HIGH(R1*R2)
    MFL R4                              ; R4 <- LOW(R1*R2)

    DIV R2, R1
    MFH R5                              ; R5 <- R2%R1
    MFL R6                              ; R6 <- R2/R1  

    LDH R1, #00h
    LDL R1, #64h                        ; R1 <- x"0064" (100)

    LDH R2, #00h
    LDL R2, #1Eh                        ; R2 <- x"001E" (30)  

    MUL R1, R2
    MFH R3                              ; R3 <- HIGH(R1*R2)
    MFL R4                              ; R4 <- LOW(R1*R2)

    DIV R1, R2
    MFH R5                              ; R5 <- R2%R1
    MFL R6                              ; R6 <- R2/R1                              

fim:
    HALT                 	; Termina a execução     

.ENDCODE

.DATA
	ENABLE_REG_ADDR:	db		#8000h
	CONFIG_REG_ADDR:  	db    	#8001h
	DATA_REG_ADDR:  	db    	#8002h
	LAST_DATA:			db		#0000h
    

.ENDDATA