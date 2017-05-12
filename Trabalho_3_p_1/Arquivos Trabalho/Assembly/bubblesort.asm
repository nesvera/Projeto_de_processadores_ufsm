;*********************************************************************
;*
;* Bubble sort
;*      Sort array in ascending order
;*
;*      Used registers:
;*          r1: points the first element of array
;*          r2: temporary register
;*          r3: points the end of array (right after the last element)
;*          r4: indicates elements swaping (r4 = 1)
;*          r5: array index
;*          r6: array index
;*          r7: element array[r5]
;*          r8: element array[r8]
;*
;*********************************************************************

.org #0000h	                ; Set code start address to 0
.code
   
BubbleSort:
   
    ; Initialization code
    xor r0, r0, r0          ; r0 <- 0
    
    ldh r1, #array          ;
    ldl r1, #array          ; r1 <- &array
    
    ldh r2, #size           ;
    ldl r2, #size           ; r2 <- &size
    ld r2, r2, r0           ; r2 <- size
    
    add r3, r2, r1          ; r3 points the end of array (right after the last element)
    
    ldl r4, #0              ;
    ldh r4, #1              ; r4 <- 1
   
   
; Main code
scan:
    addi r4, #0             ; Verifies if there was element swaping
    jmpzd #end              ; If r4 = 0 then no element swaping
    
    xor r4, r4, r4          ; r4 <- 0 before each pass
    
    add r5, r1, r0          ; r5 points the first arrar element
    
    add r6, r1, r0          ;
    addi r6, #1             ; r6 points the second array element
    
; Read two consecutive elements and compares them    
loop:
    ld r7, r5, r0           ; r7 <- array[r5]
    ld r8, r6, r0           ; r8 <- array[r6]
    sub r2, r8, r7          ; If r8 > r7, negative flag is set
    jmpnd #swap             ; (if array[r5] > array[r6] jump)
    
; Increments the index registers and verifies is the pass is concluded
continue:
    addi r5, #1             ; r5++
    addi r6, #1             ; r6++
    
    sub r2, r6, r3          ; Verifies if the end of array was reached (r6 = r3)
    jmpzd #scan             ; If r6 = r3 jump
    jmpd #loop              ; else, the next two elements are compared


; Swaps two array elements (memory)
swap:
    st r7, r6, r0           ; array[r6] <- r7
    st r8, r5, r0           ; array[r5] <- r8
    ldl r4, #1              ; Set the element swaping (r4 <- 1)
    jmpd #continue
    
    
end:    
    halt                    ; Suspend the execution
             
.endcode


; Data area (variables)
.data
    array:    db #50h, #49h, #48h, #47h, #46h, #45h, #44h, #43h, #42h, #41h, #40h, #39h, #38h, #37h, #36h, #35h, #34h, #33h, #32h, #31h, #30h, #29h, #28h, #27h, #26h, #25h, #24h, #23h, #02h, #21h, #20h, #19h, #18h, #17h, #16h, #15h, #14h, #13h, #12h, #11h, #10h, #91h, #88h, #72h, #66h, #57h, #43h, #03h, #12h, #51h

    size:      db #50    ; 'array' size  

.enddata