;***************************************
;*
;* Arrays (data segment);*
;***************************************

.org #0000h                 ; Set code start address to 0
.code

    
    xor r0, r0, r0          ; r0 <- 0
    
    ; r1 used as a pointer to the array elements
    ; The 'array' address corresponds to the address of the first array element 
    ldh r1, #array          ; 
    ldl r1, #array          ; r1 <- &array
    
    ; Reading array elements
    ld r10, r1, r0          ; r10 <- array[0]
    addi r1, #1             ; r1++ (points the next element)
    ld r11, r1, r0          ; r11 <- array[1]
    addi r1, #1             ; r1++ (points the next element)
    ld r12, r1, r0          ; r12 <- array[2]
    addi r1, #1             ; r1++ (points the next element)
    ld r13, r1, r0          ; r13 <- array[3]
    addi r1, #1             ; r1++ (points the next element)
    ld r14, r1, r0          ; r14 <- array[4]
    
    
    ; Storing array elements
    st r10, r1, r0          ; array[4] <- r10
    subi r1, #1             ; r1-- (points the preceding element)
    st r11, r1, r0          ; array[3] <- r11
    subi r1, #1             ; r1-- (points the preceding element)
    st r12, r1, r0          ; array[2] <- r12
    subi r1, #1             ; r1-- (points the preceding element)
    st r13, r1, r0          ; array[1] <- r13
    subi r1, #1             ; r1-- (points the preceding element)
    st r14, r1, r0          ; array[0] <- r14  
    

    halt                    ; Suspend the execution 
             
.endcode


.org #20h
.data
    ; Array declaration
    array:  db  #1, #2, #3, #4, #5
.enddata
