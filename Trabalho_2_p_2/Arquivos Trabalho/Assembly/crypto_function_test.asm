;----------------------------------------------------------------------------------------------------------------------------
;                           Projeto de Processadores
;   Descrição: Test of CryptoMessage Functions
;----------------------------------------------------------------------------------------------------------------------------

.CODE

main:

    ; Go to function crypto_init to configure PORT_A registers
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_init                   ; DEFAULT SETTINGS OF CRYPTOMESSAGE
                                        ; param  : R1    <- &PORT.EnableReg
                                        ; return : NONE

    ; Read data from cryptoMessage device
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_read_data              ; READS VALUE(8LSb) FROM DEVICE
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- PORT.DataReg 

    ; Write data in cryptoMessage device
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    LDH  R2, #00h 
    LDL  R2, #41h                       ; R2 <- "000000001001"
    JSRD #crypto_write_data             ; SET PORT.CONFIGREG(7 DOWNTO 0) = INPUT AND WRITE ON DEVICE
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; param  : R2    <- value
                                        ; return : NONE

    ; Send an ACK signal to cryptoMessage device
    JSRD #crypto_send_ack               ; SET ACK FOR SOME CYCLES
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; return : NONE

    ; Check if data_av flag is activated
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A                                        
    JSRD #crypto_get_data_av            ; CHECK DATA_AV FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- DATA_AV Status 

    ; Check if keyExchange flag is activated
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A 
    JSRD #crypto_get_key_exchange       ; CHECK KEYEXCHANG FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- keyExchange Status

    ; Check if eom flag is activated
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A 
    JSRD #crypto_get_eom                ; CHECK IF EOM FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- EOM Status

    JMPD #fim                
    


; ----------------------------------------------------------------------------------------------
; Simple functions
; ----------------------------------------------------------------------------------------------

increment_index:                        ; INCREMENT AND SAVE THE INDEX
                                        ; param  : R8   <- &INDEX
                                        ; return : NONE

    LD  R9, R0, R8                      ; R9 <- INDEX

    LDH R5, SIZE
    LDL R5, SIZE                        ; R5 <- array size

    ADD R6, R5, R0                      ; R6 <- array size
    SUBI R6, #01h                       ; R6 <- R6 - 1
    SUB R6, R6, R9                      ; R6 <- R6 - R8 = (79 - INDEX)
    JMPZD #index_reset                  ; if (79 - INDEX_A) = 0 then JUMP
    
    ADDI R5, #01h                       ; R5 <- R5 + 1
    JMPD #store_index
index_reset:
    ADD R5, R0, R0                      ; R5 <- 0
store_index:
    ST  R5, R8, R0                      ; SIZE  <- x0000h

    RTS                                 ; return

; ---------------------------------------------------------------------------------------------
; CryptoMessage functions
; This functions work with with both CryptoMessage Devices 
; You need to pass the ADDRESS of the PORT referent to the cryptoMessage device that you want
; ----------------------------------------------------------------------------------------------

crypto_init:                            ; DEFAULT SETTINGS OF CRYPTOMESSAGE
                                        ; param  : R1    <- &PORT.EnableReg
                                        ; return : NONE

    ADD  R2, R0, R1
    ADDI R2, #01h                       ; R2    <- &PORT.ConfigReg
    ADD  R3, R0, R1
    ADDI R3, #02h                       ; R3    <- &PORT.DataReg

    ST   R0, R1, R0                     ; PORT.EnableReg    <- "0000000000000000"

    LDH  R4, #16h
    LDL  R4, #FFh                       
    ST   R4, R2, R0                     ; PORT.ConfigReg    <- "0001011011111111"

    LDH  R4, #1Fh
    LDL  R4, #FFh                       
    ST   R4, R1, R0                     ; PORT.EnableReg    <- "0001111111111111"  (3 MORE SIGNIFICANT BITS ARE NEVER USED)

    LDH  R4, #01h
    LDL  R4, #00h                       
    ST   R4, R3, R0                     ; PORT.DataReg      <- "0000000100000000"  SET JUST THE TRISTATE_CTRL

    RTS                                 ; return


crypto_write_data:                      ; SET PORT.CONFIGREG(7 DOWNTO 0) = OUTPUT AND WRITE ON DEVICE
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; param  : R2    <- value
                                        ; return : NONE

    ADD  R8, R0, R1
    ADDI R8, #01h                       ; R8    <- &PORT.ConfigReg
    ADD  R7, R0, R1
    ADDI R7, #02h                       ; R7    <- &PORT.DataReg

    ST   R0, R1, R0                     ; PORT.EnableReg    <- "0000000000000000"

    LDH  R4, #16h
    LDL  R4, #00h  
    ST   R6, R8, R0                     ; PORT.ConfigReg    <- "0001011000000000"

    LDH  R4, #1Fh
    LDL  R4, #FFh                       
    ST   R4, R1, R0                     ; PORT.EnableReg    <- "0001111111111111"

    LDH  R6, #00h
    LDL  R6, #FFh                       ; R6 <- MASK "0000000011111111"

    AND  R2, R2, R6                     ; KEEPS THE 8 LEAST SIGNIFICANT BITS

    ST   R2, R7, R0                     ; PORT.DataReg      <- "R2"    

    RTS                                 ; return


crypto_read_data:                       ; SET PORT_IO(7 DOWNTO 0) AS INPUT AND READS DATA(8LSb) FROM DEVICE
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- PORT.DataReg


    ADD  R2, R0, R1
    ADDI R2, #01h                       ; R2    <- &PORT.ConfigReg

    ADD  R3, R0, R1
    ADDI R3, #02h                       ; R3    <- &PORT.DataReg

    ST   R0, R3, R0                     ; Clear PORT.DataReg

    ST   R0, R1, R0                     ; PORT.EnableReg    <- "0000000000000000"

    LDH  R4, #16h
    LDL  R4, #FFh                       
    ST   R4, R2, R0                     ; PORT.ConfigReg    <- "0001011011111111"

    LDH  R4, #1Fh
    LDL  R4, #FFh                       
    ST   R4, R1, R0                     ; PORT.EnableReg    <- "0001111111111111"  (3 MORE SIGNIFICANT BITS ARE NEVER USED)

    LDH  R4, #01h
    LDL  R4, #00h                       
    ST   R4, R3, R0                     ; PORT.DataReg      <- "0000000100000000"  SET JUST THE TRISTATE_CTRL

    LD   R15, R3, R0                    ; R15 <- DataReg

    LDH  R5, #00h
    LDL  R5, #FFh                       ; R5 <- MASK "0000000011111111"

    AND  R15, R15, R5                   ; R15 <- Data(8LSb) = just the data message

    RTS                                 ; return


crypto_get_data_av:                     ; CHECK DATA_AV FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- DATA_AV Status       

    ADD  R2, R0, R1
    ADDI R2, #02h                       ; R2    <- &PORT.DataReg

    LD   R3, R2, R0                     ; R3    <- PORT.DataReg

    LDH  R4, #02h
    LDL  R4, #00h                       ; DATA_AV MASK

    AND  R15, R3, R4                    ; R15 > 0 if DATA_AV is active, else R15 = 0
    
    RTS


crypto_get_key_exchange:                ; CHECK KEYEXCHANG FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- keyExchange Status       

    ADD  R2, R0, R1
    ADDI R2, #02h                       ; R2    <- &PORT.DataReg

    LD   R3, R2, R0                     ; R3    <- PORT.DataReg

    LDH  R4, #04h
    LDL  R4, #00h                       ; keyExchange MASK

    AND  R15, R3, R4                    ; R15 > 0 if keyExchange is active, else R15 = 0
    
    RTS


crypto_get_eom:                         ; CHECK IF EOM FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- EOM Status       

    ADD  R2, R0, R1
    ADDI R2, #02h                       ; R2    <- &PORT.DataReg

    LD   R3, R2, R0                     ; R3    <- PORT.DataReg

    LDH  R4, #10h
    LDL  R4, #00h                       ; EOM MASK

    AND  R15, R3, R4                    ; R15 > 0 if EOM is active, else R15 = 0
    
    RTS


crypto_send_ack:                        ; SET ACK FOR SOME CYCLES
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; return : NONE

    ADD  R2, R0, R1
    ADDI R2, #02h                       ; R2    <- &PORT.DataReg

    LD   R3, R0, R2                     ; R3    <- PORT_A.DataReg

    LDH  R4, #08h
    LDL  R4, #00h                       ; R6 <- MASK "0000100000000000"

    OR   R3, R3, R4                     ; Set ack

    ST   R3, R2, R0                     ; PORT.DataReg      <- "R3"

    nop                                 ; delay

    LDH  R4, #F7h 
    LDL  R4, #FFh                       ; R4 <- MASK "1111011111111111" 

    AND  R3, R3, R4                     ; Clear ack

    ST   R3, R2, R0                     ; PORT.DataReg      <- "R3"

    RTS                                 ; return    


; -----------------------------------------------------------------------------------------------
; Function calculate_key is used to find magicalNumer and crypto_key
; -----------------------------------------------------------------------------------------------
calculate_key:
                                        ; param  : R15 <- base  <- A
                                        ; param  : R14 <- exp   <- RANDNUMBER
                                        ; param  : R13 <- prime <- Q
                                        ; return : R12 contains the magicNumber or the crypto_key

    LDH R4, #00h
    LDL R4, #01h                        ; R4 = SUM <= 1

    ADD R5, R14, R0                     ; R5 <= X <= exponent
while_mul:
    JMPZD #exit_while
    MUL R4, R15
    MFL R4                              ; R4 = SUM <= SUM * BASE
    SUBI R5, #01h
    JMPD #while_mul

exit_while:
    DIV R4, R13                         
    MFH R12                             ; R12 = Remainder <= SUM % Q                               

    RTS                                 ; Return


; ------------------------------------------------------------------------------------------------
;
; ------------------------------------------------------------------------------------------------

fim:
    HALT                                ; End of code     

.ENDCODE

.DATA
    ; Address of register from PORT_A
    PORT_A_ADDRESS:            db       #8000h
    
    ; Address of register from PORT_B
    PORT_B_ADDRESS:            db       #9000h

    ; Prime number of key equation
    Q:  db      #00FBh                  ; Q = 251

    ; Primitive square root of "Q"
    A:  db      #0006h                  ; A = 6

    ; "Randon Number"
    RANDNUMBER:     db      #0000h

    ; Index of the array
    INDEX_A:          db      #0000h
    INDEX_B:          db      #0000h

    ; magicNumbers
    MAGICNUMBER_A:  db      #0000h
    MAGICNUMBER_B:  db      #0000h

    ; cryptoKey
    CRYPTOKEY_A:    db      #0000h
    CRYPTOKEY_B:    db      #0000h

    ; msg_c1 and msg_c2 has 80 values which
    MSG_C1: db  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0

    MSG_C2: db  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
    
    ; Array size
    SIZE: db #0050h

    Teste: db  #0, #0, #0, #0

.ENDDATA