.org #0000h                 ; Set code start address to 0
.code

; ----------------------------------------------------------------------------------------------
; Test LDISRA instruction
; ---------------------------------------------------------------------------------------------- 

    LDH  R1, #01h
    LDL  R1, #FEh
    LDSP R1                             ; SP <- 511

init:
    LDH  R1, PORT_A_ADDRESS             
    LDL  R1, PORT_A_ADDRESS             ; R1 <- &PORT_A

    LDH  R1, PORT_B_ADDRESS             
    LDL  R1, PORT_B_ADDRESS             ; R1 <- &PORT_B

    LDH  R1, #isr
    LDL  R1, #isr
    LDISRA R1                           ; ISRRA <- &isr

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

    JMPD #exit_isr


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

main:
    JMPD #main                          ; while(1)

end:    
    halt                    ; Suspend the execution
             
.endcode

; Data area (variables)
.data

    ; Address of register from PORT_A
    PORT_A_ADDRESS:            db       #8000h
    
    ; Address of register from PORT_B
    PORT_B_ADDRESS:            db       #9000h

.enddata


