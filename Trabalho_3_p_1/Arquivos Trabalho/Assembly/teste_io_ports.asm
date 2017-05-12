;------------------------------------------------
;            Projeto de Processadores
;        Descrição: I/O ports Test interuption
;------------------------------------------------

;------------------------------------------------
; Pseudocode

;------------------------------------------------

.CODE

    LDH R1, ENABLE_REG_ADDR             
    LDL R1, ENABLE_REG_ADDR     ; R1 <- &PERIPHERAL(0).ENABLE_REG

    LDH R2, CONFIG_REG_ADDR             
    LDL R2, CONFIG_REG_ADDR     ; R2 <- &PERIPHERAL(0).CONFIG_REG

    LDH R3, DATA_REG_ADDR                
    LDL R3, DATA_REG_ADDR       ; R3 <- &PERIPHERAL(0).DATA_REG

    ST  R0, R0, R1              ; PERIPHERAL(0).ENABLE_REG  <- "0000000000000000" (ALL PINS OFF)
    LDH R4, #FFh
    LDL R4, #00h
    ST  R4, R0, R2              ; PERIPHERAL(0).CONFIG_REG  <- "1111111100000000" (ALL PINS OUTPUT)
    LDL R4, #FFh
    ST  R4, R0, R1              ; PERIPHERAL(0).ENABLE_REG  <- "1111111111111111" (ALL PINS ON)

    LDH R5, ENABLE_IRQ_ADDR     
    LDL R5, ENABLE_IRQ_ADDR     ; R5 <- &Port.EnableIrqAddr
    LDH R4, #04h
    LDL R4, #00h
    ST  R4, R0, R5              ; PERIPHERAL(0).ENABLE_IRQ_REG <- "0000010000000000"  (Bit 10 is an interrupt entry)


fim:
    HALT                        ; Termina a execução     

.ENDCODE

.DATA
    ENABLE_REG_ADDR:    db      #8000h
    CONFIG_REG_ADDR:    db      #8001h
    DATA_REG_ADDR:      db      #8002h
    ENABLE_IRQ_ADDR:    db      #8003h

.ENDDATA