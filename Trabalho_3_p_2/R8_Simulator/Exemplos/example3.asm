;***************************************
;*
;* Variables (data segment);*
;***************************************

.org #0000h             ; Set code start address to 0
.code

    
    xor r0, r0, r0      ; r0 <- 0
    
    ; Loading variable value in register
    
    ; First load the register with the variable memory address (&)
    ldh r1, #a          ; 
    ldl r1, #a          ; r1 <- &a
    
    ; Next, use the variable memory address to load the variable value from memory
    ld r2, r1, r0       ; r2 <- a
    ld r3, r1, r0       ; r3 <- a
    
    ldh r4, #temp       ; 
    ldl r4, #temp       ; r4 <- &temp
    ld r4, r4, r0       ; r4 <- temp
    
    ; Variables handling on registers
    addi r2, #1         ; r2++ (a++)
    addi r4, #1         ; r4++ (temp++)
      
    ; Updating variables in memory
    st r2, r1, r0       ; a <- r2 (MEM[r1+r0] <- r2)
    
    ldh r5, #temp       ; 
    ldl r5, #temp       ; r5 <- &temp
    st r4, r5, r0       ; temp <- r4 (MEM[r5+r0] <- r4)
    

    halt                ; Suspend the execution 
             
.endcode


; 16 bits variables declaration
.data
    a:      db  #8
    temp:   db  #ABCDh
.enddata
