;***************************************
;*
;* Subrotine;*      (stack overflow)
;*
;*;*      /*** Recursive sum ***/
;*      int Sum(int n){
;*          if (n == 1) 
;*              return 1;
;*    
;*          return  n + Sum(n-1);
;*      }
;*
;****************************************



.org #0000h         ; Set code start address to 0
.code
    
    ; Stack pointer (SP) inicialization
    ldh r1, #0              ; 
    ldl r1, #30h            ; r1 <- 0030h
    ldsp r1                 ; SP <- r1
    
    xor r0, r0, r0          ; r0 <- 0
    
    ldh r1, #n              ;  
    ldl r1, #n              ; r1 <- &n
    ld r1, r1, r0           ; r1 <- n
    
    ; Subroutine call
    jsrd #Sum               ; Call the Sum subroutine (MEM[SP] <- PC++)
    
end:
    halt                    ; Suspend the execution 
           
   
           
; Recursive sum           
;   Argument r1
;   return r2
Sum:
    ; Context saving
    push r0
    push r3                 ; Save the resgister
    push r4                 ; used by the subroutine
    push r5
    
    xor r0, r0, r0          ;
    add r5, r1, r0          ; Saves the original argument value
    
    ldh r3, #0              ;
    ldl r3, #1              ; r3 <- 1
    
    ; Verifies if r1 = 1
    sub r4, r1, r3          ;
    jmpzd #return_1         ; If r1 = 1 jump
    
    
    subi r1, #1             ; r1--
    jsrd #Sum               ; Call the Sum subroutine (MEM[SP] <- PC++)
    
    add r2, r5, r2          ; r2 <- n + Sum(n-1)
    jmpd #return
    
    
return_1:
    ldh r2, #0              ;
    ldl r2, #1              ; r2 <- 1
    
    
return:
    ; Restore context
    pop r5
    pop r4                  ; Restore the original
    pop r3                  ; value of the modified 
    pop r0                  ; registers
    
    rts                     ; Return (SP--; PC <- MEM[SP])

.endcode

.data
    n:   db #9
.enddata

