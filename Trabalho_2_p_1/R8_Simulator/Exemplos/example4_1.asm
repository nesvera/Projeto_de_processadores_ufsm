;********************************************************
;*
;* Fills all array positions with FFFFh;*      Array indexed as: (base register + index register)
;*
;*          r0: base register
;*          r1: index register
;*      
;********************************************************

.org #0000h                 ; Set code start address to 0
.code

    ; r0 used as array base address
    ; The 'array' address corresponds to the address of the first array element 
    ldh r0, #array          ; 
    ldl r0, #array          ; r0 <- &array
    
    ; r1 used as array index
    xor r1, r1, r1          ; r1 <- 0
    
    ldh r2, #FFh            ; 
    ldl r2, #FFh            ; r2 <- FFFFh
    
    ldh r3, #size           ; 
    ldl r3, #size           ;
    ld r3, r3, r1           ; r3 <- size
    
    ; Loop to travel all the array 
loop:    
    addi r3, #0             ; Verifies if all positions were filled
    jmpzd #end              ; Jump if (r3 - 0) = 0
    
    st r2, r1, r0           ; array[r1] <- r2
    addi r1, #1             ; r1++
    
    subi r3, #1             ; r3--
    jmpd #loop
    
end:
    halt                    ; Suspend the execution 
             
.endcode


.data
    array:  db  #1, #2, #3, #4, #5
    size:   db #5
.enddata
