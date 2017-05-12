;***************************************
;*
;* Memory load/store instructions;*
;***************************************

.org #0000h             ; Set code start address to 0
.code

    ; Register loading instructions
    xor r0, r0, r0      ; r0 <- 0 

    ldh r1, #0          ; 
    ldl r1, #2          ; r1 <- 2
    
    ldh r2, #0          ; 
    ldl r2, #8          ; r2 <- 8
    
    ; Memory load
    ld r3, r1, r0       ; r3 <- MEM[r1 + r0]
    
    ; Memory store
    st r3, r1, r2       ; MEM[r1 + r2] <- r3

    halt                ; Suspend the execution 
             
.endcode
