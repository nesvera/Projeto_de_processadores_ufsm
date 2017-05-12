;*********************************************************************
;*
;* Bubble sort and CryptoMessage Interface using interruption
;*
;* 
;*      Sort array in ascending order
;*      Used registers:
;*          r1: points the first element of array
;*          r2: temporary register
;*          r3: points the end of array (right after the last element)
;*          r4: indicates elements swaping (r4 = 1)
;*          r5: array index
;*          r6: array index
;*          r7: element array[r5]
;*          r8: element array[r8]
;*
;*
;*********************************************************************

.org #0000h                 ; Set code start address to 0
.code

; ----------------------------------------------------------------------------------------------
; Port I/O initialization
; ---------------------------------------------------------------------------------------------- 

    LDH  R1, #03h
    LDL  R1, #FEh
    LDSP R1                             ; SP <- 1022

init_crypto_port:
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_init                   ; Go to function crypto_init to configure PORT_A registers

    LDH  R1, PORT_B_ADDRESS             
    LDL  R1, PORT_B_ADDRESS             ; R1 <- &PORT_B
    JSRD #crypto_init                   ; Go to function crypto_init to configure PORT_B registers

    JMPD  #main                         ; Go to bubblesort
 
; ----------------------------------------------------------------------------------------------
; ISR - interrupt service routine
; ----------------------------------------------------------------------------------------------
isr:
    ; Save context - register used on bubbleSort
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSHF                               ; Save the flags in stack

; Check if was cryptoMessage 1 that generated the interruption
check_crypto_1:
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #crypto_get_key_exchange       ; CHECK KEYEXCHANG FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- keyExchange Status

    ADD  R15, R15, R0
    JMPZD #check_crypto_2               ; if cryptoMessage 1 didnt generate the interruption jump to

    ; else - cryptoMessage 1 generated the interruption
    JSRD #handler_crypto_message_1


; Check if was cryptoMessage 2 that generated the interruption
check_crypto_2:
    LDH  R1, PORT_B_ADDRESS             
    LDL  R1, PORT_B_ADDRESS             ; R1 <- &PORT_B
    JSRD #crypto_get_key_exchange       ; CHECK KEYEXCHANG FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- keyExchange Status

    ADD  R15, R15, R0
    JMPZD #exit_isr                     ; if cryptoMessage 2 didnt generate the interruption jump to

    ; else - cryptoMessage 2 generated the interruption
    JSRD #handler_crypto_message_2


exit_isr:
    ; Restore context
    POPF                                ; Restore the flags from stack
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1

    RTI

; Read messages from cryptoMessage_1 until EOM
handler_crypto_message_1:

    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    LDH  R2, #MSG_C1
    LDL  R2, #MSG_C1                    ; R2 <- &MSG_C1[0]

    ; Read messages
    JSRD #crypto_read_messages          ; READ ALL MESSAGES OF CRYPTOMESSAGE BETWEEN KEYEXCHANGE FLAG AND EOM FLAG
                                        ; param  : R1   <- &PORT.EnableReg 
                                        ; param  : R2   <- &MSG_C                   first address of array

    RTS

; Read messages from cryptoMessage_2 until EOM
handler_crypto_message_2:

    LDH  R1, PORT_B_ADDRESS             
    LDL  R1, PORT_B_ADDRESS             ; R1 <- &PORT_B        
    LDH  R2, #MSG_C2
    LDL  R2, #MSG_C2                    ; R2 <- &MSG_C1[0]

    ; Read messages
    JSRD #crypto_read_messages          ; READ ALL MESSAGES OF CRYPTOMESSAGE BETWEEN KEYEXCHANGE FLAG AND EOM FLAG
                                        ; param  : R1   <- &PORT.EnableReg 
                                        ; param  : R2   <- &MSG_C                   first address of array

    RTS


; ----------------------------------------------------------------------------------------------
; Codigo referente ao BubbleSort 
; ----------------------------------------------------------------------------------------------
main:

bubble_sort:   
    ; Initialization bubblesort code
    xor r0, r0, r0          ; r0 <- 0
    
    ldh r1, #array          ;
    ldl r1, #array          ; r1 <- &array
    
    ldh r2, #size           ;
    ldl r2, #size           ; r2 <- &size
    ld r2, r2, r0           ; r2 <- size
    
    add r3, r2, r1          ; r3 points the end of array (right after the last element)
    
    ldl r4, #0              ;
    ldh r4, #1              ; r4 <- 1
   
   
; Main code
scan:
    addi r4, #0             ; Verifies if there was element swaping
    jmpzd #end              ; If r4 = 0 then no element swaping
    
    xor r4, r4, r4          ; r4 <- 0 before each pass
    
    add r5, r1, r0          ; r5 points the first arrar element
    
    add r6, r1, r0          ;
    addi r6, #1             ; r6 points the second array element
    
; Read two consecutive elements and compares them    
loop:
    ld r7, r5, r0           ; r7 <- array[r5]
    ld r8, r6, r0           ; r8 <- array[r6]
    sub r2, r8, r7          ; If r8 > r7, negative flag is set
    jmpnd #swap             ; (if array[r5] > array[r6] jump)
    
; Increments the index registers and verifies is the pass is concluded
continue:
    addi r5, #1             ; r5++
    addi r6, #1             ; r6++
    
    sub r2, r6, r3          ; Verifies if the end of array was reached (r6 = r3)
    jmpzd #scan             ; If r6 = r3 jump
    jmpd #loop              ; else, the next two elements are compared


; Swaps two array elements (memory)
swap:
    st r7, r6, r0           ; array[r6] <- r7
    st r8, r5, r0           ; array[r5] <- r8
    ldl r4, #1              ; Set the element swaping (r4 <- 1)
    jmpd #continue

; ----------------------------------------------------------------------------------------------
; End of BubbleSort
; ---------------------------------------------------------------------------------------------- 

; ---------------------------------------------------------------------------------------------
; CryptoMessage functions
; This functions work with with both CryptoMessage Devices 
; You need to pass the ADDRESS of the PORT referent to the cryptoMessage device that you want
; ----------------------------------------------------------------------------------------------

crypto_init:                            ; DEFAULT SETTINGS OF CRYPTOMESSAGE
                                        ; param  : R1    <- &PORT.EnableReg
                                        ; return : NONE

    ADD  R4, R0, R1
    ADDI R4, #01h                       ; R4    <- &PORT.ConfigReg
    ADD  R5, R0, R1
    ADDI R5, #02h                       ; R5    <- &PORT.DataReg 
    ADD  R6, R0, R1
    ADDI R6, #03h                       ; R6    <- &PORT.IrqEnableReg

    ST   R0, R1, R0                     ; PORT.EnableReg    <- "0000000000000000"

    LDH  R7, #16h
    LDL  R7, #FFh                       
    ST   R7, R4, R0                     ; PORT.ConfigReg    <- "0001011011111111"

    ; Habilita o bit 10 da porta como interrupao = keyExchange
    LDH  R7, #04h
    LDL  R7, #00h                        
    ST   R7, R6, R0                     ; PORT.IRQ_ENABLE    <- "0000010000000000"

    LDH  R7, #1Fh
    LDL  R7, #FFh                       
    ST   R7, R1, R0                     ; PORT.EnableReg    <- "0001111111111111"  (3 MORE SIGNIFICANT BITS ARE NEVER USED)

    LDH  R7, #01h
    LDL  R7, #00h                       
    ST   R7, R5, R0                     ; PORT.DataReg      <- "0000000100000000"  SET THE TRISTATE_CTRL TO ALLOW DATA FLOW FROM CRYPTOMESSAGE TO R8_UC

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



crypto_read_messages:                   ; READ ALL MESSAGES OF CRYPTOMESSAGE BETWEEN KEYEXCHANGE FLAG AND EOM FLAG
                                        ; param  : R1   <- &PORT.EnableReg 
                                        ; param  : R2   <- &MSG_C                   first address of array
                                           
    ; Read data from cryptoMessage device
    JSRD #crypto_read_data              ; READS VALUE(8LSb) FROM DEVICE
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- PORT.DataReg 

    ; R15 = MAGICNUMBER OF CRYPTOMESSAGE

    ; Store cryptoMessage magicNumber
    LDH R3, #MAGICNUMBER                
    LDL R3, #MAGICNUMBER                ; R3 <- &MAGICNUMBER
    ST  R15, R3, R0                     ; MAGICNUMBER <- R15                                               

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

    ADD  R4, R2, R0                     ; R4 <- &MSG_C

    ; Send r8_uC magicNumber to cryptoMessage device
    ADD  R2, R12, R0
    JSRD #crypto_write_data             ; SET PORT.CONFIGREG(7 DOWNTO 0) = INPUT AND WRITE ON DEVICE
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; param  : R2    <- value
                                        ; return : NONE

    ADD R2, R4, R0                      ; R2 <- &MSG_C

    ; Send an ACK signal to cryptoMessage device
    JSRD #crypto_send_ack               ; SET ACK FOR SOME CYCLES
                                        ; param  : R1    <- &PORT.EnableReg 
                                        ; return : NONE

    ; R8_uC calculate cryptographic key based on cryptoMessage magicNumber
    LDH  R15, MAGICNUMBER              
    LDL  R15, MAGICNUMBER               ; R15 <- MAGICNUMBER FROM CRYPTOMESSAGE
    LDH  R14, RANDNUMBER
    LDL  R14, RANDNUMBER                ; R14(exponent) <- RANDNUMBER (variable, "random")
    LDH  R13, Q
    LDL  R13, Q                         ; R13 <- Q (prime number, constant)
    JSRD #calculate_key                 
                                        ; param  : R15 <- base  <- MAGICNUMBER
                                        ; param  : R14 <- exp   <- RANDNUMBER
                                        ; param  : R13 <- prime <- Q
                                        ; return : R12 CONTAINS THE CRYPTOGRAPHIC KEY

    ; R12 = cryptographic key 

    ; Store cryptographic key
    LDH R3, #CRYPTOKEY                  
    LDL R3, #CRYPTOKEY                  ; R3 <- &CRYPTOKEY_A
    ST  R12, R3, R0                     ; MAGICNUMBER <- R12


while_msg:                              ; LOOP UNTIL EOM = 1
while_data_av:                          ; Wait Crypto.data_av flag             PORT.dataReg(9) = 1
    ; Check if data_av flag is activated                             
    JSRD #crypto_get_data_av            ; CHECK DATA_AV FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- DATA_AV Status 

    JMPZD #while_data_av                ; if PORT.dataReg(9) = 0 jump
                                        ; ELSE THERE IS A MSG ON DATA_IN

    ; Read data from cryptoMessage device
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
    LDH  R3, #CRYPTOKEY
    LDL  R3, #CRYPTOKEY                 ; R3 <- CRYPTOKEY
    LD   R3, R3, R0

    ; DECRYPTION    
    XOR R10, R3, R15                    ; R10 <- character decrypted

    ; Store decrypted character in the array and increment the index

                                        ; R2 <- &MSG_C

    LDH R8, #INDEX
    LDL R8, #INDEX                      ; R8 <- &INDEX
    LD  R6, R8, R0                      ; R6 <- INDEX
    
    ; Look if INDEX is even or odd
    ; INDEX = EVEN      Save character in the MS part (15 downto 8)
    ; INDEX = ODD       Save character in the LS part (7 downto 0)
    LDH R5, #00h
    LDL R5, #01h
    AND R7, R6, R5                      ; R7 <- R6 and 1
    JMPZD #index_even                   ; IF R7 == 0, index is an even number
                                        ; else index is an odd number

    ;Already there is data on MS part of memory, then we need to load this
    SR0 R9, R6                          ; We need (index/2) to address memory
    LD  R11, R2, R9                     ; R11 <- MSG_C[ INDEX ]
    
    OR  R10, R11, R10                   ; MS & LS 
    JMPD #store_char 

index_even:
    SL0 R10, R10
    SL0 R10, R10
    SL0 R10, R10
    SL0 R10, R10
    SL0 R10, R10
    SL0 R10, R10
    SL0 R10, R10
    SL0 R10, R10                        ; Shift data to MS part

store_char:
    SR0 R6, R6                          ; We need (index/2) to address memory
    ST  R10, R2, R6                     ; MSG_C[ INDEX ] <- R10
    

    JSRD #increment_index               ; INCREMENT AND SAVE THE INDEX
                                        ; param  : R8   <- &INDEX
                                        ; return : NONE

    ; Look if there was a EOM before
    LDH R4, #OEM
    LDL R4, #OEM                        ; R4 <- &EOM variable
    LD  R3, R4, R0                      ; R3 <- EOM variable
    ADD R3, R3, R0

    JMPZD #check_eom                    ; if zero, EOM flag didnt occur yet
                                        ; ELSE END OF MESSAGE Flag have occured
    
    ; When the code reaches this point, all characters of the message were read.
    ; Now we need to reset the INDEX value
    LDH  R4, #INDEX
    LDL  R4, #INDEX
    ST   R0, R4, R0                     ; INDEX  <- 0

    ; Reset EOM variable
    LDH R4, #OEM
    LDL R4, #OEM                        ; R2 <- &EOM variable
    LDH R3, #00h
    LDL R3, #00h                        ; R3 <- 0
    ST  R3, R4, R0                      ; OEM <- 0

    ;JMPD #while_B                     ; JUMP to part that communicate with cryptomessage B
    ; aqui escrever o retorno da interrupccao
    ; rti
    halt

    ;If the EOM didnt occur yet, check if this time it occured
check_eom:
    ; Check eom (end of message) flag
    JSRD #crypto_get_eom                ; CHECK IF EOM FLAG
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- EOM Status   

    JMPZD #while_msg                    ; if PORT.dataReg(9) = 0 JUMP             Get other character from cryptMessage
                                        ; ELSE END OF MESSAGE

    ; Look if there was a EOM before
    LDH R4, #OEM
    LDL R4, #OEM                        ; R4 <- &EOM variable
    
    LDH R3, #00h
    LDL R3, #01h                        ; R3 <- 1
    ST  R3, R4, R0                      ; OEM <- 1        This means that it is the last character to read

    JMPD #while_msg                     ; Return to wait new character


increment_index:                        ; INCREMENT AND SAVE THE INDEX
                                        ; param  : R8   <- &INDEX
                                        ; return : NONE

    LD  R9, R0, R8                      ; R9 <- INDEX

    LDH R5, SIZE_A
    LDL R5, SIZE_A                      ; R5 <- array size

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

; ----------------------------------------------------------------------------------------------
; End of CryptoMessage
; ----------------------------------------------------------------------------------------------  
    
end:    
    halt                    ; Suspend the execution
             
.endcode

; Data area (variables)
.data

; Variables of BubbleSort
    array:    db #50h, #49h, #48h, #47h, #46h, #45h, #44h, #43h, #42h, #41h, #40h, #39h, #38h, #37h, #36h, #35h, #34h, #33h, #32h, #31h, #30h, #29h, #28h, #27h, #26h, #25h, #24h, #23h, #02h, #21h, #20h, #19h, #18h, #17h, #16h, #15h, #14h, #13h, #12h, #11h, #10h, #91h, #88h, #72h, #66h, #57h, #43h, #03h, #12h, #51h

    size:      db #50    ; 'array' size  

; Varibles of CrytoMessage
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

    ; magicNumbers
    MAGICNUMBER:    db      #0000h

    ; cryptoKey
    CRYPTOKEY:      db      #0000h

    ; oem_var
    OEM:            db      #0000h

    ; Index of the array
    INDEX:          db      #0000h

    ; msg_c1 and msg_c2 has 80 values which
    MSG_C1: db  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0

    MSG_C2: db  #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
    
    ; Array size
    SIZE_A: db #0050h

.enddata

.org #03FFh                             ; Last position of a 1024 slots memory  
    LDH R1, #isr
    LDL R1, #isr                  
    JMP R1                              ; Fixed address that R8 search when a interruption happen (Hard-wired) 


