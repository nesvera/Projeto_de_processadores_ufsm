;***************************************
;*
;* Subrotine;*
;***************************************

.org #0000h             ; Set code start address to 0
.code
    
    ; Stack pointer (SP) inicialization
    ldh r1, #0          ; 
    ldl r1, #20h        ; r1 <- 0020h
    ldsp r1             ; SP <- r1
    
    ldh r10, #num1      ;  
    ldl r10, #num1      ; r10 <- &num1
    
    ldh r11, #num2      ;
    ldl r11, #num2      ; r11 <- &num2
    
    ; Subroutine call
    jsrd #Swap          ; Call the Swap subroutine (MEM[SP] <- PC++)
    
    ; Subroutine call
    jsrd #Swap          ; Call the Swap subroutine (MEM[SP] <- PC++)
    
end:
    halt                ; Suspend the execution 
             

Swap:
    ; Context saving
    push r0             ; Save the resgister
    push r1             ; used by the subroutine
    push r2             ;
    
    xor r0, r0, r0
    
    ld r1, r10, r0      ; r1 <- num1
    ld r2, r11, r0      ; r2 <- num2
    
    st r1, r11, r0      ; num2 <- r1
    st r2, r10, r0      ; num1 <- r2
    
    ; Restore context
    pop r2              ; Restore the original
    pop r1              ; value of the modified 
    pop r0              ; registers
    
    rts                 ; Return (SP--; PC <- MEM[SP])

.endcode

.data
    num1:   db #1111h
    num2:   db #2222h
.enddata

