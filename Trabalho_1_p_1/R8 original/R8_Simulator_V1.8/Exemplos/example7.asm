;***************************************
;*
;* Stack;*
;***************************************

.org #0000h             ; Set code start address to 0
.code
    
    ; Stack pointer (SP) inicialization
    ldh r1, #0          ; 
    ldl r1, #15h        ; r1 <- 15h
    ldsp r1             ; SP <- r1
    
    ldh r1, #0          ;
    ldl r1, #5          ; r1 <- 5
    
    ldh r2, #0          ;
    ldl r2, #6          ; r2 <- 6
    
    ldh r3, #0          ;
    ldl r3, #7          ; r3 <- 7
    
    ; Stack data storing
    push r1             ; MEM[SP] <- r1; SP++
    push r2             ; MEM[SP] <- r2; SP++
    push r3             ; MEM[SP] <- r3; SP++
    
    ; Stack data restoring
    pop r1              ; r1 <- MEM[SP+1]; SP--
    pop r2              ; r2 <- MEM[SP+1]; SP--
    pop r3              ; r3 <- MEM[SP+1]; SP--
  
    
end:
    halt                ; Suspend the execution 
             
.endcode

