;===============================================================================
;
; TODO Step #2 - Configuration Word Setup
;
; The 'CONFIG' directive is used to embed the configuration word within the
; .asm file. MPLAB X requires users to embed their configuration words
; into source code.  See the device datasheet for additional information
; on configuration word settings.  Device configuration bits descriptions
; are in C:\Program Files\Microchip\MPLABX\mpasmx\P<device_name>.inc
; (may change depending on your MPLAB X installation directory).
;
; MPLAB X has a feature which generates configuration bits source code.  Go to
; Window > PIC Memory Views > Configuration Bits.  Configure each field as
; needed and select 'Generate Source Code to Output'.  The resulting code which
; appears in the 'Output Window' > 'Config Bits Source' tab may be copied
; below.
;
;===============================================================================

LIST P=16F887  
; CONFIG1
  CONFIG  FOSC = XT           ; Oscillator Selection bits (HS oscillator: High-speed crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF      
  
; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection

  #include <xc.inc>
  
;===============================================================================
;Definicion de varialbes
;===============================================================================

    PSECT udata_shr 
    SUMA: DS 1
		   
;===============================================================================
; Reset Vector
;===============================================================================

   PSECT VectorReset, class = CODE, abs, delta = 2
   ORG 0x0000
   
   VectorReset:
    PAGESEL SETUP
    GOTO SETUP
                      ; go to beginning of program

;===============================================================================
; MAIN PROGRAM
;===============================================================================

;======================
    TMR_0:
	LOOP_TIMER1:
	    BTFSS INTCON, 0002   ; VERIFICA SI LA BANDERA T0IF ESTA ENCENDIDA
	    GOTO LOOP_TIMER1	    ; INICIA EL CICLO NUEVAMENTE

	    BCF INTCON, 0002	    ; APAGA LA BANDERA DE INTERRUPCION
	    MOVLW 200		    ; TIEMPO DE INTERRUPCION 
	    MOVWF TMR0		    ; CARGA DE VALOR AL TMR0

	return
;===================
 TMR_1:
    LOOP_TIMER2:
	BTFSS INTCON, 0002	    ; VERIFICA SI LA BANDERA T0IF ESTA ENCENDIDA
	GOTO LOOP_TIMER2	    ; INICIA EL CICLO NUEVAMENTE
    
	BCF INTCON, 0002	    ; APAGA LA BANDERA DE INTERRUPCION
	MOVLW 200		    ; TIEMPO DE INTERRUPCION
	MOVWF TMR0		    ; CARGA DE VALOR AL TMR0
	
    return
 
;===============================================================================
; INICIALIZACION
;===============================================================================
 
SETUP:
    BSF STATUS, 0
    BCF STATUS, 1	; ESTABLEZCO BANCO 1
    
    MOVLW	    00000000B	
    MOVWF TRISB		; SALIDA PARA CONTADOR DE BTNA
    
    MOVLW 00000000B
    MOVWF TRISC		; SALIDA PARA CONTADOR DE BTNB
    
    MOVLW 111100B
    MOVWF TRISA		; ENTRADA DE BOTONES Y SALIDAS DE DISPLAYS 
    
    MOVLW 00000000B
    MOVWF TRISD		; SALIDA PARA LA SUMA DE LOS 2 CONTADORES
    
    BSF STATUS, 0
    BSF STATUS, 1	; BANCO 3
    
    CLRF ANSEL
    CLRF ANSELH		; ESTABLEZCO QUE TODAS LAS ENTRADAS SON DIGITALES


   
;===============================================================================
; TMR0    
;===============================================================================
    BSF STATUS, 0
    BCF STATUS, 1	    ; ESTABLEZCO BANCO 1
    
    banksel OPTION_REG
    BCF T0CS    ; RELOJ INTERNO PARA TIMER
    BCF PSA	    ; ASIGNA PRESCALER AL TMR0
    
    BSF  PS0
    BSF  PS1
    BSF  PS2	    ;SELECCIONA 1:256 PRESCALER
    
    BCF STATUS, 0
    BCF STATUS, 1	    ; BANCO 0
    
    
      BANKSEL TMR0
    BCF  INTCON, 0x02	    ; LIMPIA BANDERA DE INTERRUPCION 
    MOVLW 200		    ; TIEMPO PARA REALIZAR UNA INTERRUPCION 
    MOVWF TMR0		    ; CARGA DE TIMEMPO A TMR0
    
;===============================================================================    
    
    MOVLW 00000001B
    MOVWF PORTB		    ; INICIO CONTADOR DE TIMER EN 1
    
    MOVLW 00000001B	    ; INICIO CONTADOR DE TIMER EN 1
    MOVWF PORTC
    
;===============================================================================
; CICLO PRINCIPAL    
;===============================================================================
LOOP:
    ;===========================================================================
    ;PARTE 1:
    ;	SI UN BOTON ES PRECIONADO; SE EJECUTA LA SUBRUTINA DE ANTIREBOTE 
    ;	RESPECTIVA (LO MISMO PARA TODOS, POR ESO SOLO COMENTO EN GENERAL)
    ;===========================================================================
    
    BTFSC PORTA, 2
    GOTO AR_BTN1A
    
    BTFSC PORTA, 3
    GOTO AR_BTN2A
    
    BTFSC PORTA, 4
    GOTO AR_BTN1B
    
    BTFSC PORTA, 5
    GOTO AR_BTN2B 
    
	;=======================================================================
	;PARTE 2
	;=======================================================================
	
	MOVF PORTB, W	    ; VALOR DE PORTB --> W
	ADDWF PORTC, W	    ; VALOR DE SUMA ENTRE PORTB Y PORTC --> W
	MOVWF SUMA	    ; GUARDO VALOR EN UN NUEVO REGISTRO
	
	MOVLW 1111B
	ANDWF SUMA, W	    ; OBTENGO PRIMER NIBBLE
	CALL TABLA	    ; BUSCO SU REPRECENTACION EN EL DISPLAY
	MOVWF PORTD	    ; LO MUESTRO
	
	BSF PORTA, 0	    ; PRENDO PRIMER SALIDA PARA DISPLAY
	BCF PORTA, 1	    ; APAGO SEGUNDA SALIDA PARA DISPLAY
	
	CALL TMR_0		    ; PAUSA PARA HACER EL CAMBIO
	
	SWAPF SUMA, F	    ; CAMBIO LOS NIBBLES 
	MOVLW 1111B	    
	ANDWF SUMA, W	    ; OBTENGO EL SEGUNDO NIBBLE
	CALL TABLA	    ; BUSCO SU REPRESENTACION EN EL DISPLAY
	MOVWF PORTD	    ; LO MUESTRO
	
	BCF PORTA, 0	    ; APAGO PRIMER SALIDA PARA DISPLAY
	BSF PORTA, 1	    ; PRENDO SEGUNDA SALIDA PARA DISPLAY
	
	SWAPF SUMA, F	    ; REACOMODO LOS NIBBLES 
	
	CALL TMR_1		    ; PAUSA PARA HACER EL CAMBIO
	
    GOTO LOOP
    
;===============================================================================
;ANTIREBOTE PARA LOS BOTNONES 
;   MIENTRAS EL BOTON SIGA PRECIONADO, SE ESTARA EJECUTANDO EL CICLO DE
;   ANTIRREBOTE, CUENDO SE DEJA DE PRESIONAR SE HACE EL INCREMENTO O DECREMENTO
;   DEL PUERTO RESPECTIVO. (LO MISMO PARA TODOS)
;===============================================================================
AR_BTN1A:
    BTFSC PORTA, 2
    GOTO AR_BTN1A
    
    INCF PORTB
    GOTO LOOP
    
 AR_BTN2A:
    BTFSC PORTA, 3
    GOTO AR_BTN2A
    
    DECF PORTB
    GOTO LOOP
    
AR_BTN1B:
    BTFSC PORTA, 4
    GOTO AR_BTN1B
    
    INCF PORTC
    GOTO LOOP
    
AR_BTN2B:
    BTFSC PORTA, 5
    GOTO AR_BTN2B
    
    DECF PORTC
    GOTO LOOP
    
;===============================================================================
; TABLA CON LA REPRESENTACION DE CADA NUMERO EN EL DISPLAY
;   SE ELIGE LA CORRECTA POR MEDIO DE DIRECCIONAMIENTO INDIRECTO
;===============================================================================
 TABLA:
    CLRF PCLATH
    BSF PCLATH, 0 
    ADDWF PCL, F
	retlw 00111111B		    ;0
	retlw 00000110B		    ;1
	retlw 01011011B		    ;2
	retlw 01001111B		    ;3
	retlw 01100110B		    ;4
	retlw 01101101B		    ;5
	retlw 01111101B		    ;6
	retlw 00000111B		    ;7
	retlw 01111111B		    ;8
	retlw 01101111B		    ;9
	retlw 01110111B		    ;A
	retlw 01111100B		    ;B
	retlw 00111001B		    ;C
	retlw 01011110B		    ;D
	retlw 01111001B		    ;E
	retlw 01110001B		    ;F
    
    END