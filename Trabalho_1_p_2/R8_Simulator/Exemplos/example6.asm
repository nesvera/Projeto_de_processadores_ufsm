;***************************************
;*
;* Flags (carry and overflow) and jumps;*
;***************************************

.org #0000h             ; Set code start address to 0
.code
    
    ldh r1, #FFh        ; 
    ldl r1, #FFh        ; r1 <- -1
    
    addi r1, #1         ; r1++
    jmpcd #label1       ; Jump if C = 1
    
    nop
    nop
    nop
    
label1:
    xor r0, r0, r0      ; r0 <- 0
    
    ldh r2, #num1
    ldl r2, #num1
    ld r2, r2, r0       ; r2 <- num1
    
    addi r2, #1         ; r2++
    jmpvd #end          ; Jump if V = 1
    
    nop
    nop
    nop
   
    
end:
    halt                ; Suspend the execution 
             
.endcode

; 16 bits variables declaration
.data
    num1:   db #32767       ; Greatest posivite number representable in 2's complement using 16 bits
.enddata
