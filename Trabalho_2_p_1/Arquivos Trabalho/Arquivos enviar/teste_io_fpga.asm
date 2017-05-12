;------------------------------------------------
;            Projeto de Processadores
;        Descrição: I/O ports - FPGA 
;------------------------------------------------

;------------------------------------------------
; Pseudocode
;
;   set( all_enable_OFF )
;   set( half_pins_INPUT/half_pins_OUTPUT )     // "1111111100000000"
;   set( all_enable_ON )
;
;   write_OUTPUT( "0000000011111111" )
;   write_OUTPUT( "0000000000000000" )
;   write_OUTPUT( "0000000010000000" )
;   write_OUTPUT( "0000000001000000" )
;   write_OUTPUT( "0000000000100000" )
;   write_OUTPUT( "0000000000010000" )
;   write_OUTPUT( "0000000000001000" )
;   write_OUTPUT( "0000000000000100" )
;   write_OUTPUT( "0000000000000010" )
;   write_OUTPUT( "0000000000000001" )
;   write_OUTPUT( "0000000000000000" )
;   write_OUTPUT( "0000000011111111" )
;   write_OUTPUT( "0000000000000000" )

;   while(1)
;       a = read_INPUT()                        // data_reg(15 downto 8)
;       write_OUTPUT( a )                       // data_reg(7 downto 0) 
;
;       delay( 0.2s )
;
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

    LDH R4, #00h
    LDL R4, #FFh
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "11111111"
    JSRD #delay
    ST  R0, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00000000"
    JSRD #delay
    LDL R4, #80h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "10000000"
    JSRD #delay
    LDL R4, #40h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "01000000"
    JSRD #delay
    LDL R4, #20h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00100000"
    JSRD #delay
    LDL R4, #10h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00010000"
    JSRD #delay
    LDL R4, #08h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00001000"
    JSRD #delay
    LDL R4, #04h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00000100"
    JSRD #delay
    LDL R4, #02h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00000010"
    JSRD #delay
    LDL R4, #01h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00000001"
    JSRD #delay
    LDL R4, #00h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00000000"
    JSRD #delay
    LDL R4, #FFh
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "11111111"
    JSRD #delay
    LDL R4, #00h
    ST  R4, R0, R3              ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- "00000000"
    JSRD #delay

while:
    LD  R5, R0, R3               ; R5 <- PERIPHERAL(0).DATA_REG(15 downto 8)
    SR0 R5, R5
    SR0 R5, R5
    SR0 R5, R5
    SR0 R5, R5
    SR0 R5, R5
    SR0 R5, R5
    SR0 R5, R5
    SR0 R5, R5
    ST  R5, R0, R3               ; PERIPHERAL(0).DATA_REG(7 downto 0)    <- R5

    JMPD #while

delay:
    JSRD #rst_for_1             ;
    JSRD #rst_for_2

for_lento:                      ; for(i=x,i>0;i--)
    JSRD #for_rapido            ; Salta para loop rapid
    SUBI R6, #01h               ; R6 <- R6 - 1
    JMPZD #f_f_lento            ; Se R7 = 0, salta para a label fim_for_rapido
    JMPD #for_lento

for_rapido:                     ;for(j=x,j>0;j--)
    SUBI R7, #01h               ; R7 <- R7 - 1
    JMPZD #f_f_rapido           ; Se R7 = 0, reseta valor do for rapido e retorna ao lento
    JMPD #for_rapido            ; Se R3 > 0, volta para a label for_rapido

rst_for_1:                 
    LDH R6, #00h                ; Reseta valor para o loop lento        For lento tem o número de clocks do for rapido mais 12 clocks vezes n interacoes  
    LDL R6, #19h                                                        ;(393204 + 12) * 25 = 10223616 clocks        frequencia = 50Mhz      delay de aproximadamente 0.2 segundos
    RTS
    
rst_for_2:                      ; Reseta valor para o loop rapido       For rápido tem 12 clocks por interacao, 12 * 32767 = 393204 clocks
    LDH R7, #7Fh                ; Variavel loop interno
    LDL R7, #FFh
    RTS

f_f_rapido:                     ; FIM FOR RAPIDO
    JSRD #rst_for_2             ; Reseta valor para o loop rapido
    RTS                         ; Retorna ao for_lento depois do JSRD #for_rapido

f_f_lento:
    RTS                         ; RETORNA DO DELAY

fim:
    HALT                        ; Termina a execução     

.ENDCODE

.DATA
    ENABLE_REG_ADDR:    db      #8000h
    CONFIG_REG_ADDR:    db      #8001h
    DATA_REG_ADDR:      db      #8002h

.ENDDATA