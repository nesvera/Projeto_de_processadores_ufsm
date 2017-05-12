;------------------------------------------------
;            Projeto de Processadores
;        Descrição: I/O ports Test interuption
;------------------------------------------------

;------------------------------------------------
; Pseudocode

;------------------------------------------------

.CODE

    LDH  R1, #03h
    LDL  R1, #FFh
    LDSP R1                     ; SP <- 1023

    LDH  R2, #00h
    LDL  R2, #01h

    LDH  R3, #FFh
    LDL  R3, #FFh

    ADD  R4, R3, R2

    PUSHF
    PUSH R1
    PUSH R2
    PUSH R3

    ADD R1, R0, R0
    ADD R2, R0, R0
    ADD R3, R0, R0

    POP R3
    POP R2
    POP R1
    POPF

fim:
    HALT                        ; Termina a execução     

.ENDCODE

.DATA

.ENDDATA