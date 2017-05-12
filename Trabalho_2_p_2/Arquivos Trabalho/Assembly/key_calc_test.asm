;------------------------------------------------
;            Projeto de Processadores
;        Descrição: Contador de 0 a 9999
;------------------------------------------------

;------------------------------------------------
; Código em C
;   int a = 6;
;   int q = 251;
;   int randNumber = 0;
;
;   int calculate_key( int base, int exponent, int prime  ){           // Function to calculate magicNumber and crypto key
;       int sum = 1;
;       int x = exponent;
;       while( x > 0 ){
;           sum = sum * base;
;           x--;
;       }
;
;       int resto = sum % prime;     // Reminder
;
;       return resto;
;   } 
;
;------------------------------------------------

.CODE
    LDH R15, A
    LDL R15, A

    LDH R14, RANDNUMBER
    LDl R14, RANDNUMBER

    LDH R13, Q
    LDL R13, Q

calculate_key:
                                        ; param  : R15 <- base  <- A
                                        ; param  : R14 <- exp   <- RANDNUMBER
                                        ; param  : R13 <- prime <- Q
                                        ; return : R12 contains the magicNumber or the crypto_key

begin:

    LDH R4, #00h
    LDL R4, #01h                        ; R4 = SUM <= 1

    ADD R5, R14, R0                     ; R5 <= X <= exponent
while:
    JMPZD #exit_while
    MUL R4, R15
    MFL R4                              ; R4 = SUM <= SUM * BASE
    SUBI R5, #01h
    JMPD #while

exit_while:
    DIV R4, R13                         
    MFH R12                             ; R12 = Remainder <= SUM % Q

    ADDI R14, #01h
    JMPD #begin

fim:
    HALT                 	; Termina a execução     

.ENDCODE

.DATA

    ; Prime number of key equation
    Q:  db      #00FBh                  ; Q = 251

    ; Primitive square root of "Q"
    A:  db      #0006h                  ; A = 6

    ; "Randon Number"
    RANDNUMBER:     db      #0000h

.ENDDATA