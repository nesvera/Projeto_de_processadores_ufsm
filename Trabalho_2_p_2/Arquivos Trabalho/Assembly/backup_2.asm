;----------------------------------------------------------------------------------------------------------------------------
;            Projeto de Processadores
;        Descrição: I/O ports
;----------------------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------------------------------
; Pseudocode
;----------------------------------------------------------------------------------------------------------------------------
;
;                                       // R8_uC and CryptoMessage device need to have the same "a" and "b"
;   a = 6;                              // "a" is a primitive square root of "q"
;   q = 251;                            // "q" is a prime number
;
;   randNumber = 0;                     // This is a fake randNumber, it will be just a incremental cont... randNumber < q
;
;   msg_c1[80];                         // Message arrays
;   msg_c2[80];
;   ind = 0;                            // Array index
;
;   main(){
;       set_port( address_port_A(R1) );                                 // Configure the input/output pins for CryptoMessage devices communication
;       set_port( address_port_B(R1) );
;
;       while(1){
;
;           // ----------------  CryptoMessage_A 
;           while(){                                                
;               if( portA_read_keyExchange() = 1 ) break;           // R8_uC waits for activation of CryptoMessage_A.keyExchange               
;           }
;
;           portA_read_data_IN();                                   // R8_uC reads magicNumber from CryptoMessage_A
;
;           magicNumber(R12) = calculate_key(R13, R14, R15);        // R8_uC calculates your magicNumber
;
;           portA_write_data_OUT();                                 // R8_uC sends your magicNumber to CryptoMessage_A  
;           portA_send_ack();                                       // R8_uC sends ack signal to CryptoMessage_A  
;
;           crypto_key(R12) = generate_crypto_key(R13,R14,R15);    // R8_uC and CryptoMessage device generate cryptographic key  
;
;           while(){                                                                                                                    <----------
;               while(){                                                                                                                                    
;                   if( portA_read_data_av() = 1 ) break;               // R8_uC waits for activation of CryptoMessage_A.data_av               
;               }
;
;               portA_read_data_IN();                                   // R8_uC reads caracter from CryptoMessage_A
;
;               portA_send_ack();                                       // R8_uC send ack signal to CryptoMessage_A
;
;               msg_c1[ind] = caracter_cript xor crypto_key;            // R8_uC decrypts the caracter received from CryptoMessage_A and saves in the array
;
;               if( ind < 79 ){                                         // Circular array
;                   ind++;
;               }else{
;                   ind = 0;            
;               }
;
;               if( portA_read_eom = 1 ){
;                   ind = 0;
;                   break;
;               }
;           }
;       }
;   }
;
;
;   inserir port_B aqui
;
;
;   set_port( int addr_port(REG1) ){                        // Default configuration of I/O ports
;       addr_enable_reg = addr_port;                        // Address of enable register
;       addr_config_reg = addr_port + 1;                    // Address of config register
;       addr_data_reg = addr_port + 2;                      // Address of data register
;
;       Enable_reg = "0000000000000000"
;       Config_reg = "0001011011111111"                     // Config_reg(7 downto 0) = data_in     (input)         crypto_data_out
;                                                           // Config_reg(8) = tristate_ctrl        (output)
;                                                           // Config_reg(9) = data_av              (input)
;                                                           // Config_reg(10) = keyExchange         (input)
;                                                           // Config_reg(11) = ack                 (output)
;                                                           // Config_reg(12) = eom                 (input)
;
;       Data_reg =   "0000000100000000"                     // Just enable trist_ctrl, then crypto will output data
;       Enable_reg = "0001111111111111"
;   }
;
;   int calculate_key( int base, int exponent, int prime  ){           // Function to calculate magicNumber and crypto key
;       int sum = 1;
;       int x = exponent;
;       while( x > 0 ){
;           sum = sum * base;
;           x--;
;       }
;
;       int reminder = sum % prime;     // Reminder
;
;       return reminder;
;   } 
;
;----------------------------------------------------------------------------------------------------------------------------

.CODE

main:
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_init                   ; Go to function crypto_init to configure PORT_A registers

    LDH  R1, PORT_B_ADDRESS             
    LDL  R1, PORT_B_ADDRESS             ; R1 <- &PORT_B
    JSRD #crypto_init                   ; Go to function crypto_init to configure PORT_B registers
 
while:                                  ; main loop
    
wait_ke_A:                              ; Wait Crypto_A.keyExchange = PORT_A.dataReg(10) = 1
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    ADDI R1, #02h                       ; R1 <- &PORT_A.dataReg
    LD   R2, R0, R1                     ; R2 <- PORT_A.dataReg

    LDH  R3, #04h
    LDL  R3, #00h                       ; R3 <- "0000010000000000"          MASK bit(10) = 1

    AND  R4, R2, R3                     ; R4 <- R2 & R3

    JMPZD #wait_ke_A                    ; if PORT_A.dataReg(10) = 0 jump
                                        ; else there is a keyExchange signal
                                                                                            
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A

    JSRD #crypto_read_data              ; SET PORT_IO(7 DOWNTO 0) AS INPUT AND READS FROM DEVICE
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- PORT.DataReg

                                        ; R15 = MAGICNUMBER FROM CRYPTOMESSAGE_A

    LDH R1, #MAGICNUMBER_A              ; STORE THE MAGICNUMBER FROM CRYPTOMESSAGE_A
    LDL R1, #MAGICNUMBER_A              ; R1 <- &MAGICNUMBER_A
    ST  R15, R1, R0                     ; MAGICNUMBER_A <- R12
                                                                        

                                        ; NOW R8_UC WILL CALCULATE R8_uC MAGICNUMBER                             
    LDH  R15, #A
    LDL  R15, #A                        ; R15(BASE) <- A (primitive root, constant)

    LDH  R14, RANDNUMBER
    LDL  R14, RANDNUMBER                ; R14(exponent) <- RANDNUMBER (variable, "random")

    LDH  R13, #Q
    LDL  R13, #Q                        ; R13 <- Q (prime number, constant)

    JSRD #calculate_key                 
                                        ; param  : R15 <- base  <- A
                                        ; param  : R14 <- exp   <- RANDNUMBER
                                        ; param  : R13 <- prime <- Q
                                        ; return : R12 contains the MAGICNUMBER FROM R8_UC                      

    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A

    JSRD #crypto_write_data:            ; SET PORT.CONFIGREG(7 DOWNTO 0) = INPUT AND WRITE ON DEVICE
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; param  : R12   <- crypto_key
                                        ; return : NONE


    JSRD #crypto_write_ack:             ; SET ACK FOR SOME CYCLES
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; return : NONE


                                        ; NOW R8_UC WILL CALCULATE R8_uC CRIPTO_KEY                             

    LDH R1, #MAGICNUMBER_A              ; STORE THE MAGICNUMBER FROM CRYPTOMESSAGE_A
    LDL R1, #MAGICNUMBER_A              ; R1 <- &MAGICNUMBER_A
    LD  R15, R1, R0                     ; R15 <- MAGICNUMBER_A FROM CRYPTOMESSAGE_A

    LDH  R14, RANDNUMBER
    LDL  R14, RANDNUMBER                ; R14(exponent) <- RANDNUMBER (variable, "random")

    LDH  R13, #Q
    LDL  R13, #Q                        ; R13 <- Q (prime number, constant)

    JSRD #calculate_key                 
                                        ; param  : R15 <- base  <- MAGICNUMBER
                                        ; param  : R14 <- exp   <- RANDNUMBER
                                        ; param  : R13 <- prime <- Q
                                        ; return : R12 CONTAINS THE CRYPTOGRAPHIC KEY FROM THE R8_UC

while_msg_a:                            ; LOOP UNTIL EOM = 1
while_dav_A:                            ; Wait Crypto_A.data_av = PORT_A.dataReg(9) = 1

    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    ADDI R1, #02H
    LD   R2, R0, R1                     ; R2 <- PORT_A.dataReg

    LDH  R3, #02h
    LDL  R3, #00h                       ; R3 <- "0000001000000000"          MASK bit(9) = 1

    AND  R4, R2, R3                     ; R4 <- R2 & R3

    JMPZD #while_dav_A                  ; if PORT_A.dataReg(9) = 0 jump
                                        ; ELSE THERE IS A MSG ON DATA_IN

    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_read_data:             ; SET PORT_IO(7 DOWNTO 0) AS INPUT AND READS FROM DEVICE
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- PORT.DataReg(7 DOWNTO 0)

                                        ; R15 CONTAINS THE ENCRYPTED CARACTER FROM CRYPTOMESSAGE_A
    
    crypto_write_ack:                   ; SET ACK FOR SOME CYCLES
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; return : NONE

                                        ; DECRYPTION    
    XOR R10, R3, R12                    ; R10 <- character decrypted

                                        ; STORE DECRYPTED CHARACTER IN THE ARRAY
    LDH R4, #MSG_C1
    LDL R4, #MSG_C1                     ; R4 <- &MSG_C1
    LDH R8, #INDEX_A
    LDL R8, #INDEX_A                    ; R8 <- &INDEX_A
    LD  R6, R8, R0                      ; R6 <- INDEX_A
    ADD R4, R4, R6                      ; R4 <- &MSG_C1+INDEX_A
    ST  R10, R4, R0                     ; MSG_C1[index] <- R10
    JSRD #increment_index

                                        ; CHECK CRYPTO.EOM_A SIGNAL
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    ADDI R1, #02h
    LD   R2, R0, R1                     ; R2 <- PORT_A.dataReg

    LDH  R3, #10h
    LDL  R3, #00h                       ; R3 <- "000001000000000000"          MASK bit(12) = 1

    AND  R4, R2, R3                     ; R4 <- R2 & R3

    JMPZD #oem_cripto_a                 ; SE BIT(12) = 1 = OEM  END OF MESSAGE
                                        ; RESET INDEX_A AND GO TO CRIPTOMESSAGE_B

    JMPD #while_msg_a                   ; Return to wait new data

oem_cripto_a:                           ; RESET INDEX_A
    LDH  R4, #INDEX_A
    LDL  R4, #INDEX_A
    ST   R0, R4, R0                     ; INDEX_A  <- 0

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
    LDL  R4, #FFh                       ; R4    <- "0001011011111111"
    ST   R4, R2, R0                     ; PORT.ConfigReg    <- "0001011011111111"

    LDH  R4, #01h
    LDL  R4, #00h                       ; R4    <- "0000000100000000"
    ST   R4, R3, R0                     ; PORT.DataReg      <- "0000000100000000"  SET JUST THE TRISTATE_CTRL

    LDH  R4, #1Fh
    LDL  R4, #FFh                       ; R4    <- "0001111111111111"
    ST   R4, R1, R0                     ; PORT.EnableReg    <- "0001111111111111"

    RTS                                 ; return


crypto_write_data:                      ; SET PORT.CONFIGREG(7 DOWNTO 0) = INPUT AND WRITE ON DEVICE
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; param  : R12   <- value
                                        ; return : NONE

    ADD  R2, R0, R1
    ADDI R2, #01h                       ; R2    <- &PORT.ConfigReg
    ADD  R7, R0, R1
    ADDI R7, #02h                       ; R7    <- &PORT.DataReg

    LD   R3, R0, R2                     ; R3 <- PORT_A.ConfigReg

    LDH  R4, #FFh 
    LDL  R4, #00h                       ; R4 <- MASK "1111111100000000"

    AND  R6, R3, R4                     ; Keep the 8 more significant bits from PORT_A.ConfigReg
                                        ; PORT_A.ConfigReg(7 downto 0) = OUTPUT
                                        ; R6 = New value to PORT_A.ConfigReg

    ST   R0, R1, R0                     ; PORT.EnableReg    <- "0000000000000000"

    ST   R6, R2, R0                     ; PORT.ConfigReg    <- R6

    LDH  R4, #1Fh
    LDL  R4, #FFh                       ; R4    <- "0001111111111111"
    ST   R4, R1, R0                     ; PORT.EnableReg    <- "0001111111111111"

    LD   R3, R0, R7                     ; R3 <- PORT_A.DataReg

    LDH  R4, #FFh 
    LDL  R4, #00h                       ; R4 <- MASK "1111111100000000"

    LDH  R6, #00h
    LDL  R6, #FFh                       ; R6 <- MASK "0000000011111111"

    AND  R12, R12, R6                   ; KEEPS THE 8 LEAST SIGNIFICANT BITS

    AND  R5, R3, R4                     ; Keep the 8 more significant bits from PORT_A.DataReg
    OR   R5, R5, R12                    ; PORT_A.DataReg(7 downto 0) = magicNumber
                                        ; R5 = New value to PORT_A.DataReg

    ST   R5, R7, R0                     ; PORT.DataReg      <- "R5"    

    RTS                                 ; return


crypto_read_data:                       ; SET PORT_IO(7 DOWNTO 0) AS INPUT AND READS FROM DEVICE
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- PORT.DataReg

    ADD  R2, R0, R1
    ADDI R2, #01h                       ; R2    <- &PORT.ConfigReg

    LD   R3, R0, R2                     ; R3 <- PORT.ConfigReg

    LDH  R4, #FFh 
    LDL  R4, #00h                       ; R4 <- MASK "1111111100000000"

    LDH  R5, #00h
    LDL  R5, #FFh                       ; R5 <- MASK "0000000011111111"

    AND  R6, R3, R4                     ; KEEP THE 8 MORE SIGNIFICANT BITS FROM PORT_A.CONFIGREG
    OR   R6, R6, R5                     ; PORT_A.ConfigReg(7 downto 0) = INPUT
                                        ; R6 = New value to PORT_A.ConfigReg

    ST   R0, R1, R0                     ; PORT.EnableReg    <- "0000000000000000"

    ST   R6, R2, R0                     ; PORT.ConfigReg    <- R6

    LDH  R4, #1Fh
    LDL  R4, #FFh                       ; R4    <- "0001111111111111"
    ST   R4, R1, R0                     ; PORT.EnableReg    <- "0001111111111111"

    ADD  R4, R0, R1
    ADDI R4, #02h                       ; R4 <- &PORT.DataReg

    LD   R15, R4, R0

    RTS                                 ; return


crypto_write_ack:                       ; SET ACK FOR SOME CYCLES
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; return : NONE

    ADD  R2, R0, R1
    ADDI R2, #02h                       ; R2    <- &PORT.DataReg

    LD   R3, R0, R2                     ; R3    <- PORT_A.DataReg

    LDH  R4, #F7h 
    LDL  R4, #FFh                       ; R4 <- MASK "1111011111111111" 

    AND  R5, R3, R4                     ; Clear ack

    LDH  R6, #08h
    LDL  R6, #00h                       ; R6 <- MASK "0000100000000000"

    OR   R5, R5, R6                     ; Set ack
    ST   R5, R2, R0                     ; PORT.DataReg      <- "R5"

    nop                                 ; delay

    AND  R5, R5, R4                     ; Clear ack
    ST   R5, R2, R0                     ; PORT.DataReg      <- "R5"

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
    HALT                 	            ; End of code     

.ENDCODE

.DATA
	; Address of register from PORT_A
    PORT_A_ADDRESS:	           db		#8000h
    
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

.ENDDATA