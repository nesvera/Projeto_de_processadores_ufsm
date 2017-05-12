;----------------------------------------------------------------------------------------------------------------------------
;            Projeto de Processadores
;   Descrição:  Communication between R8_uC and CryptoMessage Device using polling
;               C-code in the end of the file
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

;-------------
; First we will communicate with the cryptoMessage Device A
;-------------

wait_ke_A:                              ; Wait Crypto_A.keyExchange = PORT_A.dataReg(10) = 1
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_get_key_exchange       ; CHECK KEYEXCHANG FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- keyExchange Status

    JMPZD #wait_ke_A                    ; if PORT_A.dataReg(10) = 0 jump
                                        ; else there is a keyExchange signal
                                           
    ; Read data from cryptoMessage device
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_read_data              ; READS VALUE(8LSb) FROM DEVICE
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- PORT.DataReg 

    ; R15 = MAGICNUMBER OF CRYPTOMESSAGE_A

    ; Store cryptoMessage magicNumber
    LDH R1, #MAGICNUMBER_A              ; STORE THE MAGICNUMBER FROM CRYPTOMESSAGE_A
    LDL R1, #MAGICNUMBER_A              ; R1 <- &MAGICNUMBER_A
    ST  R15, R1, R0                     ; MAGICNUMBER_A <- R12                                               

    ; NOW R8_UC WILL CALCULATE R8_uC MAGICNUMBER                             
    LDH  R15, A
    LDL  R15, A                        ; R15(BASE) <- A (primitive root, constant)
    LDH  R14, RANDNUMBER
    LDL  R14, RANDNUMBER               ; R14(exponent) <- RANDNUMBER (variable, "random")
    LDH  R13, Q
    LDL  R13, Q                        ; R13 <- Q (prime number, constant)
    JSRD #calculate_key                 
                                        ; param  : R15 <- base  <- A
                                        ; param  : R14 <- exp   <- RANDNUMBER
                                        ; param  : R13 <- prime <- Q
                                        ; return : R12 contains the MAGICNUMBER FROM R8_UC                      

    ; R12 = MAGICNUMBER OF R8_uC

    ; Send r8_uC magicNumber to cryptoMessage device
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    ADD  R2, R12, R0
    JSRD #crypto_write_data             ; SET PORT.CONFIGREG(7 DOWNTO 0) = INPUT AND WRITE ON DEVICE
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; param  : R2    <- value
                                        ; return : NONE

    ; Send an ACK signal to cryptoMessage device
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_send_ack               ; SET ACK FOR SOME CYCLES
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; return : NONE

    ; R8_uC calculate cryptographic key based on cryptoMessage magicNumber
    LDH  R15, MAGICNUMBER_A              
    LDL  R15, MAGICNUMBER_A            ; R15 <- MAGICNUMBER_A FROM CRYPTOMESSAGE_A
    LDH  R14, RANDNUMBER
    LDL  R14, RANDNUMBER               ; R14(exponent) <- RANDNUMBER (variable, "random")
    LDH  R13, Q
    LDL  R13, Q                        ; R13 <- Q (prime number, constant)
    JSRD #calculate_key                 
                                        ; param  : R15 <- base  <- MAGICNUMBER
                                        ; param  : R14 <- exp   <- RANDNUMBER
                                        ; param  : R13 <- prime <- Q
                                        ; return : R12 CONTAINS THE CRYPTOGRAPHIC KEY

    ; R12 = cryptographic key 

    ; Store cryptographic key
    LDH R1, #CRYPTOKEY_A                 ; STORE THE CRYPTOKEY_A
    LDL R1, #CRYPTOKEY_A                 ; R1 <- &CRYPTOKEY_A
    ST  R12, R1, R0                     ; MAGICNUMBER_A <- R12


while_msg_a:                            ; LOOP UNTIL EOM = 1
while_data_av:                          ; Wait Crypto_A.data_av = PORT_A.dataReg(9) = 1
    ; Check if data_av flag is activated
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A                                        
    JSRD #crypto_get_data_av            ; CHECK DATA_AV FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- DATA_AV Status 

    JMPZD #while_data_av                ; if PORT_A.dataReg(9) = 0 jump
                                        ; ELSE THERE IS A MSG ON DATA_IN

    ; Read data from cryptoMessage device
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_read_data              ; READS VALUE(8LSb) FROM DEVICE
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- PORT.DataReg 

    ; R15 contains the encrypted character form cryptoMessage_A device
                                                                                                     ; precisa fazer a logica de eom
    ; Send an ACK signal to cryptoMessage device
    JSRD #crypto_send_ack               ; SET ACK FOR SOME CYCLES
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; return : NONE

    ; Load cryptographic key
    LDH  R3, #CRYPTOKEY_A
    LDL  R3, #CRYPTOKEY_A               ; R3 <- CRYPTOKEY_A
    LD   R3 , R3, R0

    ; DECRYPTION    
    XOR R10, R3, R15                    ; R10 <- character decrypted

    ; Store decrypted character in the array and increment the index
    LDH R4, #MSG_C1
    LDL R4, #MSG_C1                     ; R4 <- &MSG_C1
    LDH R8, #INDEX_A
    LDL R8, #INDEX_A                    ; R8 <- &INDEX_A
    LD  R6, R8, R0                      ; R6 <- INDEX_A
    ST  R10, R4, R6                     ; MSG_C1[ &MSG_C1 + INDEX_A ] <- R10
    JSRD #increment_index               ; INCREMENT AND SAVE THE INDEX
                                        ; param  : R8   <- &INDEX
                                        ; return : NONE

    ; Look if there was a EOM before
    LDH R2, #OEM_A
    LDL R2, #OEM_A                      ; R2 <- &EOM variable
    LD  R3, R2, R0                      ; R3 <- EOM variable
    ADD R3, R3, R0

    JMPZD #check_eom                    ; if zero, EOM flag didnt occur yet
                                        ; ELSE END OF MESSAGE Flag have occured
    
    ; When the code reaches this point, all characters of the message were read.
    ; Now we need to reset the INDEX_A value and change to cryptoMessage_B device
    LDH  R4, #INDEX_A
    LDL  R4, #INDEX_A
    ST   R0, R4, R0                     ; INDEX_A  <- 0

    HALT

    ;If the EOM didnt occur yet, check if this time it occured
check_eom:
    ; Check eom (end of message) flag
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_get_eom                ; CHECK IF EOM FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- EOM Status   

    JMPZD #while_msg_a                  ; if PORT_A.dataReg(9) = 0 JUMP             Get other character from cryptMessage
                                        ; ELSE END OF MESSAGE

    ; Look if there was a EOM before
    LDH R2, #OEM_A
    LDL R2, #OEM_A                      ; R2 <- &EOM variable
    LDH R3, #00h
    LDL R3, #01h                        ; R3 <- 1
    ST  R3, R2, R0                      ; OEM_A <- 1        This means that it is the last character to read

     JMPD #while_msg_a                   ; Return to wait new character
    
;-------------
; Now we will communicate with the cryptoMessage Device B
;-------------




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
    
    ADDI R9, #01h                       ; R5 <- R5 + 1
    JMPD #store_index
index_reset:
    ADD R9, R0, R0                      ; R5 <- 0
store_index:
    ST  R9, R8, R0                      ; SIZE  <- x0000h

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
    ST   R4, R8, R0                     ; PORT.ConfigReg    <- "0001011000000000"

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

    ; oem_var
    OEM_A:          db      #0000h
    OEM_B:          db      #0000h

    ; msg_c1 and msg_c2 has 80 values which
    MSG_C1: db  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0

    MSG_C2: db  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
    
    ; Array size
    SIZE: db #0050h

    Teste: db  #0, #0, #0, #0

.ENDDATA



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