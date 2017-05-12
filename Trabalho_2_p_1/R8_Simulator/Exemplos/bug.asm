;**********************************************
;*
;* Do not declare a variable called 'b' or 'B';*
;**********************************************

.org #0000h             ; Set code start address to 0
.code

    
    xor r0, r0, r0      ; r0 <- 0
    
    ; Loading variable value in register
    ldh r1, #b          ; 
    ldl r1, #b          ; r1 <- &b
    ld r2, r1, r0       ; r2 <- b    
     
    addi r2, #1         ; b++    
    
    ; Updating variables in memory
    st r2, r1, r0       ; b <- r2 (MEM[r1+r0] <- r2)
    
  
    halt                ; Suspend the execution 
             
.endcode


; 16 bits variables declaration
.data
    b:      db  #8
.enddata
