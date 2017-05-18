;*****************************************************************************************************
;*
;* Control 7 segments display of Nexys 3 via sotfware
;* Use interruption from buttons to change values
;*
;* Bit(15 downto 12) - input from buttons
;* Bit(11 downto 8)  - anode signal active low
;* Bit(7 downto 0)   - cathode signal active low
;*
;* There is 4 displays
;*      - Automatic counter of 1 second on display 3 and 2 (left-most)
;*      - Counter incremented and decremented by button interruption on display 1 and 0 (right-most)
;*
;* The refresh rate for the display will be set to 100Hz. Which 0.04s one display will be actived  ((1/0.04)*4) = 100Hz
;* To increment the automatic counter, we will use this 0.04s step and increment an variable until 25, this results in one second
;*
;******************************************************************************************************

.code

; ----------------------------------------------------------------------------------------------
; Initialization
; ---------------------------------------------------------------------------------------------- 
init:
    ; Set address of SP
    LDH  R1, #7Fh
    LDL  R1, #FFh
    LDSP R1                             

    ; Set address of ISR
    LDH  R1, #isr
    LDL  R1, #isr
    LDISRA R1                           ; ISRA <- &isr

    ; Configure the PORT I/O
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #port_init                     ; Go to function to configure PORT_A registers

    ; Initialize variables
    LDH  R1, #COUNTER_1
    LDL  R1, #COUNTER_1
    ST   R0, R1, R0                     ; COUNTER_1 <- 0

    LDH  R1, #COUNTER_2
    LDL  R1, #COUNTER_2
    ST   R0, R1, R0                     ; COUNTER_2 <- 0    

    LDH  R1, #IND_DISPLAYS
    LDL  R1, #IND_DISPLAYS
    ST   R0, R1, R0                     ; IND_DISPLAYS <- 0

    LDH  R1, #DISPLAY_VALUES
    LDL  R1, #DISPLAY_VALUES

    LDH  R2, #00h
    LDL  R2, #03h                       ; R2 <- 0 in 7segments

    ST   R2, R1, R0
    ADDI R1, #01h
    ST   R2, R1, R0
    ADDI R1, #01h
    ST   R2, R1, R0
    ADDI R1, #01h
    ST   R2, R1, R0

    JMPD  #main                         ; Go to main

 
; ----------------------------------------------------------------------------------------------
; ISR - interrupt service routine
; ----------------------------------------------------------------------------------------------
; Fixed address that R8 search when a interruption happen 
isr:
    ; Save context - register used on bubbleSort
    PUSH R1                             ; Save main context
    PUSH R15
    PUSHF                               ; Save the flags in stack

; Check if port A generated the interruption
check_port_a:
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A
    JSRD #check_interruption            ; CHECK IF PORT A GENERATE INTERRUPTION
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- 1 IF IS TRUE 

    ADD  R15, R15, R0
    JMPZD #exit_isr                     ; if R15 == 0, port_A didnt generate the interruption jump to

    ; else - cryptoMessage 1 generated the interruption
    JSRD #handler_port_A

exit_isr:
    ; Restore context
    POPF                                ; Restore main context
    POP R15
    POP R1

    RTI
 
; Increment or decrement value of display(3 downto 2)
handler_port_A:
    
    PUSH R1                             ; Save context
    PUSH R2
    PUSH R3
    PUSH R15
    ;PUSHF

    JSRD #delay2                         ; Delay to avoid bouncing

    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A

    JSRD #check_button_up               ; CHECK IF BUTTON UP FROM PORT_A IS PRESSED
                                        ; param  : R1       <- &PORT_A 
                                        ; return : R15      != 0 IF button UP is pressed

    ADD R15, R15, R0

    JMPZD #check_bd                     ; IF R15 == 0, button up isnt pressed

    ; increment counter_2 
    JSRD #incrementa_counter_2

    ; Update value of the display_values, where the displays sequence are
    LDH  R2, #COUNTER_2
    LDL  R2, #COUNTER_2 
    LD   R2, R2, R0                     ; R2 <- counter_2

    LDH  R3, #DISPLAY_VALUES
    LDL  R3, #DISPLAY_VALUES            ; R3 <- 2 Right-most displays

    JSRD #set_out_number                ; Update array of displays with the chatode sequence of the number (8888)           
                                        ; param  : R2       <- Value with 2 digits to display (0-99)
                                        ; param  : R3       <- Posision on display_values related with this timer 
                                        ; return : NONE

check_bd:
    JSRD #check_button_down             ; CHECK IF BUTTON DOWN FROM PORT_A IS PRESSED
                                        ; param  : R1       <- &PORT_A
                                        ; return : R15      != 0 IF button DOWN is pressed 

    ADD R15, R15, R0

    JMPZD #end_handler                  ; IF R15 == 0, button down isnt pressed

    ; decrement counter_2
    JSRD #decrementa_counter_2

    ; implementar decrementadorao

    ; Update value of the display_values, where the displays sequence are
    LDH  R2, #COUNTER_2
    LDL  R2, #COUNTER_2 
    LD   R2, R2, R0                     ; R2 <- counter_2

    LDH  R3, #DISPLAY_VALUES
    LDL  R3, #DISPLAY_VALUES            ; R3 <- 2 Right-most displays

    JSRD #set_out_number                ; Update array of displays with the chatode sequence of the number (8888)           
                                        ; param  : R2       <- Value with 2 digits to display (0-99)
                                        ; param  : R3       <- Posision on display_values related with this timer 
                                        ; return : NONE

end_handler:
    
    ;POPF                                ; Restore context
    POP  R15
    POP  R3
    POP  R2
    POP  R1

    RTS


; ---------------------------------------------------------------------------------------------
; MAIN
; ----------------------------------------------------------------------------------------------

main:
while_main:
    
    LDH  R5, #IND_DISPLAYS 
    LDL  R5, #IND_DISPLAYS
    LD   R2, R5, R0                     ; R2 <- IND_DISPLAY             ind_display represent which display in ON (0-1-2-3)

    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A

    LDH  R2, #COUNTER_1
    LDL  R2, #COUNTER_1 
    LD   R2, R2, R0                     ; R2 <- counter_1

    LDH  R3, #DISPLAY_VALUES
    LDL  R3, #DISPLAY_VALUES
    ADDI R3, #02h                       ; R3 <- 2 Left-most displays

    JSRD #set_out_number                ; Update array of displays with the chatode sequence of the number (8888)                
                                        ; param  : R2       <- Value with 2 digits to display (0-99)
                                        ; param  : R3       <- Posision on display_values related with this timer 
                                        ; return : NONE

    LDH  R2, #IND_DISPLAYS
    LDL  R2, #IND_DISPLAYS 
    LD   R2, R2, R0                     ; R2 <- IND_DISPLAYS

    JSRD #refresh_display               ; Send to port io, a display(anode) and the specific digit to this display(cathodes)
                                        ; param  : R1       <- &PORT.EnableReg
                                        ; param  : R2       <- IND_DISPLAYS
                                        ; return : NONE

    ; Increment IND_DISPLAY

    LDH  R5, #IND_DISPLAYS 
    LDL  R5, #IND_DISPLAYS
    LD   R2, R5, R0

    LD   R4, R5, R0                     ; R4 <-IND_DISPLAY
    SUBI R2, #03h                       

    JMPZD #zera_ind_display             ; IF ind_display == 3 then ind_display <- 0
                                        ; ELSE ind_diplay += 1
    ADDI R4, #01h
    JMPD #store_ind_display

zera_ind_display:
    ADD  R4, R0, R0

store_ind_display:
    ST   R4, R5, R0 


    ; Increment ref_cont which counts 25 refresh of display to. 25 refresh = 1 second

    LDH R3, #REF_CONT
    LDL R3, #REF_CONT                   ; R3 <- &ref_cont

    LD  R4, R3, R0                      ; R4 <- ref_cont

    ADD R5, R4, R0                      ; R5 <- ref_cont
    SUBI R5, #FAh                       ; R5 <- ref_cont - 250

    JMPZD #zera_ref                     ; IF ref_cont == 250 then increment one second
                                        ; ELSE just increment ref_cont

    ADDI R4, #01h
    JMPD #store_ref

zera_ref:
    ADD  R4, R0, R0
    JSRD #incrementa_segundo

store_ref:
    ST   R4, R3, R0                     ; ref_cont += 1

    JSRD #delay                         ; delay 0.04s

    JMPD #while_main


;----------------------------------------------------------------------------------------------
; Main functions
;----------------------------------------------------------------------------------------------
    ; Increment Counter_1
incrementa_segundo:
    PUSH R3
    PUSH R4
    PUSH R5

    LDH R3, #COUNTER_1
    LDL R3, #COUNTER_1                  ; R3 <- &COUNTER_1

    LD  R4, R3, R0                      ; R4 <- counter_1

    ADD R5, R4, R0
    SUBI R5, #63h                       ; R5 <= counter_1 - 99

    JMPZD #zera_counter_1               ; IF CONTER_1 - 99 == 0, reset counter_1

    ADDI R4, #01h
    JMPD #store_counter_1

zera_counter_1:
    ADD R4, R0, R0

store_counter_1:
    ST  R4, R3, R0

    POP  R5
    POP  R4
    POP  R3

    RTS

incrementa_counter_2:
    PUSH R3
    PUSH R4
    PUSH R5

    LDH R3, #COUNTER_2
    LDL R3, #COUNTER_2                  ; R3 <- &COUNTER_2

    LD  R4, R3, R0                      ; R4 <- counter_2

    ADD R5, R4, R0
    SUBI R5, #63h                       ; R5 <= counter_1 - 99

    JMPZD #reset_counter_2              ; IF CONTER_2 - 99 == 0, reset counter_1

    ADDI R4, #01h
    JMPD #store_counter_2

reset_counter_2:
    ADD R4, R0, R0
    JMPD #store_counter_2

decrementa_counter_2:
    PUSH R3
    PUSH R4
    PUSH R5

    LDH R3, #COUNTER_2
    LDL R3, #COUNTER_2                  ; R3 <- &COUNTER_2

    LD  R4, R3, R0                      ; R4 <- counter_2

    ADD R5, R4, R0                      ; Actived the flag if zero

    JMPZD #set_counter_2                ; IF CONTER_2 == 0, reset counter_1

    SUBI R4, #01h
    JMPD #store_counter_2

set_counter_2: 
    LDH  R5, #00h
    LDL  R5, #63h

    ADD  R4, R5, R0                     ; R4 <- 99
    JMPD #store_counter_2

; End of increment and decrement counter_2 functions, both functions jump to here
store_counter_2:
    ST  R4, R3, R0

    POP  R5
    POP  R4
    POP  R3

    RTS

delay:
    PUSH R6
    PUSH R7
    PUSHF

    JSRD #rst_for_1             ;
    JSRD #rst_for_2

for_lento:                      ; for(i=x,i>0;i--)
    JSRD #for_rapido            ; Salta para loop rapid
    SUBI R6, #01h               ; R6 <- R6 - 1
    JMPZD #f_f_lento            ; Se R7 = 0, salta para a label fim_for_rapido
    JMPD #for_lento

for_rapido:                     ;for(j=x,j>0;j--)
    SUBI R7, #01h               ; R7 <- R7 - 1
    JMPZD #f_f_rapido           ; Se R7 = 0, reseta valor do for rapido e retorna ao lento
    JMPD #for_rapido            ; Se R3 > 0, volta para a label for_rapido

; #0004h
rst_for_1:                 
    LDH R6, #00h                ; Reseta valor para o loop lento        For lento tem o número de clocks do for rapido mais 12 clocks vezes n interacoes  
    LDL R6, #01h                                                        ;(249996 + 12) * 4 = 11999808 clocks * (1/frequencia(25Mhz)) =  delay de aproximadamente 0.04 segundos
    RTS                 

; #5161h
rst_for_2:                      ; Reseta valor para o loop rapido       For rápido tem 12 clocks por interacao, 12 * 20833 = 249996 clocks
    LDH R7, #20h                ; Variavel loop interno       #5161h = 20833
    LDL R7, #00h
    RTS

f_f_rapido:                     ; FIM FOR RAPIDO
    JSRD #rst_for_2             ; Reseta valor para o loop rapido
    RTS                         ; Retorna ao for_lento depois do JSRD #for_rapido

f_f_lento:

    POPF
    POP R7
    POP R6

    RTS                         ; RETORNA DO DELAY


delay2:
    PUSH R6
    PUSH R7
    PUSHF

    JSRD #rst_for_12             ;
    JSRD #rst_for_22

for_lento2:                      ; for(i=x,i>0;i--)
    JSRD #for_rapido2            ; Salta para loop rapid
    SUBI R6, #01h               ; R6 <- R6 - 1
    JMPZD #f_f_lento2            ; Se R7 = 0, salta para a label fim_for_rapido
    JMPD #for_lento2

for_rapido2:                     ;for(j=x,j>0;j--)
    SUBI R7, #01h               ; R7 <- R7 - 1
    JMPZD #f_f_rapido2           ; Se R7 = 0, reseta valor do for rapido e retorna ao lento
    JMPD #for_rapido2            ; Se R3 > 0, volta para a label for_rapido

; #0004h
rst_for_12:                 
    LDH R6, #00h                ; Reseta valor para o loop lento        For lento tem o número de clocks do for rapido mais 12 clocks vezes n interacoes  
    LDL R6, #0Fh                                                        ;(249996 + 12) * 4 = 11999808 clocks * (1/frequencia(25Mhz)) =  delay de aproximadamente 0.04 segundos
    RTS                 

; #5161h
rst_for_22:                      ; Reseta valor para o loop rapido       For rápido tem 12 clocks por interacao, 12 * 20833 = 249996 clocks
    LDH R7, #FFh                ; Variavel loop interno       #5161h = 20833
    LDL R7, #FFh
    RTS

f_f_rapido2:                     ; FIM FOR RAPIDO
    JSRD #rst_for_2             ; Reseta valor para o loop rapido
    RTS                         ; Retorna ao for_lento depois do JSRD #for_rapido

f_f_lento2:

    POPF
    POP R7
    POP R6

    RTS                         ; RETORNA DO DELAY

; ---------------------------------------------------------------------------------------------
; Display and buttons functions
; ----------------------------------------------------------------------------------------------

port_init:                              ; Default settings of display and buttons interface
                                        ; param  : R1    <- &PORT.EnableReg
                                        ; return : NONE

    ADD  R4, R0, R1
    ADDI R4, #01h                       ; R4    <- &PORT.ConfigReg
    ADD  R5, R0, R1
    ADDI R5, #02h                       ; R5    <- &PORT.DataReg 
    ADD  R6, R0, R1
    ADDI R6, #03h                       ; R6    <- &PORT.IrqEnableReg

    ST   R0, R1, R0                     ; PORT.EnableReg    <- "0000000000000000"

    LDH  R7, #F0h
    LDL  R7, #00h                       
    ST   R7, R4, R0                     ; PORT.ConfigReg    <- "1111000000000000"

    LDH  R7, #FFh
    LDL  R7, #FFh                       
    ST   R7, R1, R0                     ; PORT.EnableReg    <- "1111111111111111"

    LDH  R7, #0Fh
    LDL  R7, #FFh                       
    ST   R7, R5, R0                     ; PORT.DataReg      <- "0000111111111111"           ; Disable all leds (low-active led)  

    ; Enable interruption on bit(15 downto 12) [LEFT, RIGHT, UP, DOWN]
    LDH  R7, #F0h
    LDL  R7, #00h                        
    ST   R7, R6, R0                     ; PORT.IRQ_ENABLE    <- "1111000000000000"

    RTS                                 ; return

set_out_number:                         ; Update array of displays with the chatode sequence of the number (8888)   
                                        ; param  : R2       <- Value with 2 digits to display (0-99)
                                        ; param  : R3       <- Posision on display_values related with this timer 
                                        ; return : NONE

    PUSH R4                             ; Savre context
    PUSH R5 
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9

    LDH  R4, #00h
    LDL  R4, #0Ah                       ; R4 <- 10

    DIV  R2, R4                                                                                            ; <<<<<--- conferir

    MFH  R5                             ; R5 <- value%10
    MFL  R6                             ; R6 <- value/10

    LDH  R7, #NUMBERS
    LDL  R7, #NUMBERS                   ; R7 points to the array with the 7segments representation of the real numbers

    ADD  R8, R7, R6                     
    LD   R8, R8, R0                     ; R8 <- 7segment_representation(R6)          R8 receives the number representation of the second digit (x_) of the counter
    
    ADD  R9, R7, R5                     
    LD   R9, R9, R0                     ; R9 <- 7segment_representation(R5)          R9 receives the number representation of the first digit (_x) of the counter

    ST   R9, R3, R0                     ; display_values(n+0) = 7segment_representatio( value/10 )

    ADDI R3, #01h
    ST   R8, R3, R0                     ; display_values(n+1) = value%10

    POP  R9
    POP  R8
    POP  R7
    POP  R6                             ; Restore context
    POP  R5
    POP  R4

    RTS

refresh_display:                        ; Send to port io, a display(anode) and the specific digit to this display(cathodes)
                                        ; param  : R1       <- &PORT.EnableReg
                                        ; param  : R2       <- IND_DISPLAYS
                                        ; return : NONE

    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R7
    PUSHF 

    ADD R7, R0, R0                      ; R7 will receive the data configuration to send to display (anode)+(cathodes)

    ; Find which anode to active
    LDH  R3, #DISPLAYS
    LDL  R3, #DISPLAYS                  ; R3 <- array with the sequence of displays with the specific anodes to which

    ADD  R3, R3, R2
    LD   R3, R3, R0                     ; R3 <- anode configuration to display

    OR   R7, R7, R3

    LDH  R4, #DISPLAY_VALUES
    LDL  R4, #DISPLAY_VALUES            ; R4 <- &DISPLAY_VALUES

    ADD  R4, R4, R2
    LD   R4, R4, R0                     ; R4 <- receives the 7segment converted value of display

    OR   R7, R7, R4

                                        ; R7 <- the correct sequence with anodes and cathodes

    ADD  R5, R0, R1
    ADDI R5, #02h                       ; R5    <- &PORT.DataReg 

    ST   R7, R5, R0                     ; PORT.DataReg <- the correct sequence with anodes and cathodes

    POPF
    POP  R7
    POP  R5
    POP  R4
    POP  R3

    RTS

check_interruption:                     ; CHECK IF PORT A GENERATE INTERRUPTION
                                        ; param  : R1       <- &PORT.EnableReg 
                                        ; return : R15      <- 1 IF IS TRUE 

    PUSH R2                             ; Save context
    PUSH R3
    PUSH R4
    ;PUSHF

    ADD  R2, R1, R0
    ADDI R2, #02h                       ; R2 <- &PORT.DataReg

    LD   R3, R2, R0                     ; R3 <- PORT.DataReg

    LDH  R4, #F0h
    LDL  R4, #00h                       ; R4 <- "1111000000000000" mask ALL BUTTONS

    AND  R15, R3, R4                    ; R15 <- Port.DataReg and MASK          R15 != 0 if any button is pressed

    ;POPF                                ; Restore context
    POP R4
    POP R3
    POP R2

    RTS

check_button_up:                        ; CHECK IF BUTTON UP FROM PORT_A IS PRESSED
                                        ; param  : R1       <- &PORT_A 
                                        ; return : R15      != 0 IF button UP is pressed

    PUSH R2                             ; Save context
    PUSH R3
    PUSH R4
    PUSHF

    ADD  R2, R1, R0
    ADDI R2, #02h                       ; R2 <- &PORT.DataReg

    LD   R3, R2, R0                     ; R3 <- PORT.DataReg

    LDH  R4, #20h
    LDL  R4, #00h                       ; R4 <- "0010000000000000" mask UP BUTTON

    AND  R15, R3, R4                    ; R15 <- Port.DataReg and MASK          R15 != 0 if any button is pressed

    POPF                                ; Restore context
    POP R4
    POP R3
    POP R2

    RTS

check_button_down:                       ; CHECK IF BUTTON DOWN FROM PORT_A IS PRESSED
                                        ; param  : R1       <- &PORT_A
                                        ; return : R15      != 0 IF button DOWN is pressed 

    PUSH R2                             ; Save context
    PUSH R3
    PUSH R4
    PUSHF

    ADD  R2, R1, R0
    ADDI R2, #02h                       ; R2 <- &PORT.DataReg

    LD   R3, R2, R0                     ; R3 <- PORT.DataReg

    LDH  R4, #10h
    LDL  R4, #00h                       ; R4 <- "0001000000000000" mask DOWN BUTTON

    AND  R15, R3, R4                    ; R15 <- Port.DataReg and MASK          R15 != 0 if any button is pressed

    POPF                                ; Restore context
    POP R4
    POP R3
    POP R2

    RTS

    
end:    
    halt                    ; Suspend the execution
             
.endcode

; Data area (variables)
.data

    ; Address of register from PORT_A
    PORT_A_ADDRESS:     db      #8000h
    
    COUNTER_1:          db      #0000h                          ; Counter 1 (left digit) store values from the timer incremented which second 
    COUNTER_2:          db      #0000h                          ; Counter 2 store values from the timer incremendted by interruption  

    ; Counter_2 has 4 states... (0) all display off 
    ;                           (1) display 

    ; Bit(15 downto 12) - input from buttons
    ; Bit(11 downto 8)  - anode signal active low
    ; Bit(7 downto 0)   - cathode signal active low
    
    ; Bits of individual cathodes that form a specific number - leds low actived(0 : led is on, 1: led is off)
    ; Active specific cathodes and disable all anodes
    N_0:                db      #0000000000000011b          
    N_1:                db      #0000000010011111b   
    N_2:                db      #0000000000100101b
    N_3:                db      #0000000000001101b
    N_4:                db      #0000000010011001b
    N_5:                db      #0000000001001001b
    N_6:                db      #0000000001000001b
    N_7:                db      #0000000000011111b    
    N_8:                db      #0000000000000001b
    N_9:                db      #0000000000001001b

    ; Numbers is an array with the values of N_0, N_1, N_2, N_3, N_4, N_5, N_6, N_7, N_8, N_9
    NUMBERS:            db      #0000000000000011b, #0000000010011111b, #0000000000100101b, #0000000000001101b, #0000000010011001b, #0000000001001001b, #0000000001000001b, #0000000000011111b, #0000000000000001b, #0000000000001001b

    ; Bits of individual anodes that actived which display
    DISP_NONE:          db      #0000111100000000b              ; Left-most Display
    DISP_3:             db      #0000011100000000b
    DISP_2:             db      #0000101100000000b
    DISP_1:             db      #0000110100000000b
    DISP_0:             db      #0000111000000000b              ; Right-most Display

    ; Displays is an array with the values of DISP_3, DISP_2, DISP_1, DISP_0
    DISPLAYS:           db      #0000011100000000b, #0000101100000000b, #0000110100000000b, #0000111000000000b

    ; Store the values (N_1, N_2 ...) from which display display_value(0-1) = left_counter  display_value(2-3) = right_counter
    DISPLAY_VALUES:     db      #0000h, #0000h, #0000h, #0000h

    ; Index of array displays and display_values
    IND_DISPLAYS:       db      #0000h

    ; Refresh counter
    REF_CONT:           db      #0000h

.enddata



