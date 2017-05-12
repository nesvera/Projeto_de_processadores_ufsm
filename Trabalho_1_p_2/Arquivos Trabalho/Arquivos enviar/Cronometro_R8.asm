;------------------------------------------------
;            Projeto de Processadores
;        Descrição: Contador de 0 a 9999
;------------------------------------------------

;------------------------------------------------
; Código em C
;
;   int timer = 0;
;   while(1){
;       for( i=127; i>0 ; i-- ){
;           for( j=32767; j>0 ; j-- ){
;               // do nothing
;           }
;       }
;
;       if(timer < 65535){
;           timer++;
;       }else{
;           timer = 0;
;       }
;
;       printf("%d",timer);
;   }
;
;------------------------------------------------

.CODE
    LDH R1, #FFh            ; Tempo máximo decimal do display       R1 <- 0xFFFF
    LDL R1, #FFh 

    LDH R2, #80h            ; Endereço para escrita no display      R2 <- 0x8000
    LDL R2, #00h

rst_time:                 
    LDH R3, #00h            ; Zera o valor do cronometro(timer)     R2 <- 0
    LDL R3, #00h     
    ST R3, R2, R0           ; Escreve no display

; Loop de delay de 1 segundo... É necessário loop de 2 registradores devido ao valor 50MHz
loop_delay:
    JSRD #rst_for_1         ;
    JSRD #rst_for_2

for_lento:                  ; for(i=x,i>0;i--)
    JSRD #for_rapido        ; Salta para loop rapid
    SUBI R4, #01h           ; R4 <- R4 - 1
    JMPZD #inc_timer        ; Se R5 = 0, salta para a label fim_for_rapido
    JMPD #for_lento

for_rapido:                 ;for(j=x,j>0;j--)
    SUBI R5, #01h     	    ; R5 <- R5 - 1
    JMPZD #f_f_rapido       ; Se R5 = 0, reseta valor do for rapido e retorna ao lento
    JMPD #for_rapido        ; Se R3 > 0, volta para a label for_rapido

rst_for_1:                 
    LDH R4, #00h            ; Reseta valor para o loop lento         
    LDL R4, #7Fh        
    RTS
    
rst_for_2:                  ; Reseta valor para o loop rapido
    LDH R5, #7Fh            ; Variavel loop interno
    LDL R5, #FFh
    RTS

f_f_rapido:                 ; FIM FOR RAPIDO
    JSRD #rst_for_2         ; Reseta valor para o loop rapido
    RTS                     ; Retorna ao for_lento depois do JSRD #for_rapido


inc_timer:
	SUB R6, R1, R2			; Compara valor atual ao valor máximo (R4 <- 9999 - R2)
	JMPZD #rst_time	        ; Se R4 = 0, faz salto para resetar o cronômetro

    ADDI R3, #01h        	; Incrementa valor do cronômetro
    ST R3, R2, R0           ; Escreve no display
    JMPD #loop_delay        ; Salta para a label loop_delay             

fim:
    HALT                 	; Termina a execução     

.ENDCODE

.DATA

.ENDDATA