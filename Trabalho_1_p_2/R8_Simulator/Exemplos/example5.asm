;***************************************
;*
;* Flags (zero and negative) and jumps;*
;***************************************

.org #0000h             ; Set code start address to 0
.code

    
    xor r0, r0, r0      ; r0 <- 0
    
    ; Read variables 'num1' and 'num2'
    ldh r1, #num1       ; 
    ldl r1, #num1       ; r1 <- &num1
    ld r1, r1, r0       ; r1 <- num1
    
    ldh r2, #num2       ; 
    ldl r2, #num2       ; r2 <- &num2
    ld r2, r2, r0       ; r2 <- num2
    
    
    ; Verifies if r2 > r1
    sub r3, r1, r2      ; r3 <- r1 - r2
    jmpnd #end          ; Jump if r2 > r1 (N = 1)
    
    
    ; Verifies if r1 > r2
    sub r3, r2, r1      ; r3 <- r2 - r1
    jmpnd #label1       ; Jump if r1 > r2 (N = 1)
    
    nop
    nop
    nop
    
    
label1:
    ; Verifies if r3 = 0
    addi r3, #0         ; r3 <- r3 + 0           
    jmpzd #end          ; Jump if r3 = 0 (Z = 1)
    
    nop
    nop
    nop
    
    ; Verifies if r0 = 0
    addi r0, #0         ; r0 <- r0 + 0
    jmpzd #label2       ; Jump if r0 = 0 (Z = 1)
    
    nop
    nop
    nop
    
label2:
    ; Verifies if r3 < 0
    addi r3, #0         ; r3 <- r3 + 0
    jmpnd #label3       ; Jump if r3 < 0 (N = 1)
    
    nop
    nop
    nop
    
label3:
    
end:
    halt                ; Suspend the execution 
             
.endcode

; 16 bits variables declaration
.data
    num1:   db #7
    num2:   db #3
    zero:   db #0
.enddata
