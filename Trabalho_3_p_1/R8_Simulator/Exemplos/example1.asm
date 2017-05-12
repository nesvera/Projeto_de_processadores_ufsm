;************************************************************
;*
;* Register loading, logic/arithmetic and shift instructions;*
;************************************************************

.org #0000h             ; Set code start address to 0
.code

    ; Register loading instructions
    ldh r0, #12         ; Load the higher half of register r0 with 12 (decimal)
    ldl r0, #12h        ; Load the lower half of register r0 with 12 (hexadecimal)

    ldh r1, #1          ; Load the higher half of register r0 with 1 (decimal)
    ldl r1, #ABh        ; Load the lower half of register r0 with ABh (hexadecimal)
    
    
    ; All the following instructions can modify the status flags (carry, negative, zero and overflow)

    
    ; Arithmetic instructions (3 registers)
    add r2, r1, r0      ; r2 <- r1 + r0
    sub r3, r1, r0      ; r3 <- r1 - r0
    
    ; Bit logic instructions
    and r4, r1, r0      ; r4 <- r1 and r0
    or  r5, r1, r0      ; r3 <- r1 or r0
    xor r1, r1, r1      ; r3 <- r1 xor r1
    not r6, r1          ; r6 <- not r1   
   
    
    ; Immediate arithmetic instructions (1 register and an 8-bits constant)
    addi r1, #FFh       ; r1 <- r1 + 0xFF
    subi r4, #1         ; r4 <- r4 - 1
    
    ; Shift instructions
    sl0 r6, r4          ; r6 <- r4 shifted left 1-bit (bit(0) <- 0)
    sr0 r6, r6          ; r6 <- r6 shifted rigth 1-bit (bit(15) <- 0)
    sl1 r6, r1          ; r6 <- r1 shifted left 1-bit (bit(0) <- 1)
    sr1 r6, r4          ; r6 <- r4 shifted rigth 1-bit (bit(15) <- 1)
    
    halt                ; Suspend the execution 
             
.endcode
