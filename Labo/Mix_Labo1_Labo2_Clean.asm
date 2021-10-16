;************************************************************************
;* Nom de fichier: LABO1-2_REFACTORING *
;* Date: 20211016 *
;* *
;* Auteur:  MCD
;* Haute Ecole Louvain en Hainaut *
;************************************************************************
;* Fichiers nécessaires: aucun *
;************************************************************************
;* Notes: *
;************************************************************************
    list p=16F84, f=INHX8M							; directive pour definir le processeur
    list c=90, n=60								; directives pour le listing
    #include <p16F84a.inc>							; incorporation variables spécifiques
    errorlevel -302								; pas d'avertissements de bank
    errorlevel -305								; pas d'avertissements de fdest

    __config _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC				; configuration du pic, cf. documentation

;************************************************************************
;* Définitions et Variables *
    #DEFINE EXAMPLE b'000000000'						; Define c'est comme déclarer des constantes
										; Quand y'a un # (devant include et define) c'est une directive de 
										; précompilation càd que c'est pas le programme qui fait la commande, c'est 
										; une commande pour le compilateur
;************************************************************************
    cblock 0x020
; déclaration de variables
    d1,
    d2,
    NB_BUTTON_CHECK,
    LEDS_PATTERN_SELECTOR
    endc   
;************************************************************************
;* Programme principal *
;************************************************************************
;    cpu equates (memory map)
    ;myPortB    equ    0x06							; Definit l'addresse du portB quelque soit la bank 
										; dans laquelle je me trouve j'ai le droit d'utiliser PORTB
    ;myPortA    equ    0x05							; Definit l'addresse du portA
    ORG 0x000 ; vecteur reset
START  
;************************************************************************ 
; START - PORTS INITIALISATION (p.15)
;************************************************************************
    BCF STATUS, RP0								; on clear le bit 5 de STATUS, ce qui permet de selectionner bank0
    CLRF PORTB									; initialise portB avec un clear des outputs
    CLRF PORTA
    BSF STATUS, RP0								; On set le bit 5 de STATUS à 1, donc bank1 est selectionnée    
;************************************************************************ 
; START - I/O SETUP
;************************************************************************
    MOVLW 0x00									; 0x00 = hexa / b'0' = binaire / 0 = decimal on doit préciser le système de numération
    MOVWF TRISB									; on met 0x00 dans TRISB, ce qui met PORTB en output
    MOVLW b'00000111'								; 1=input -> ici RA0 et RA1
    MOVWF TRISA									; on met 1 dans trisA : input
;************************************************************************ 
; START - BANK SELECTION TO USE PORTA / PORTB
;************************************************************************    
    BCF STATUS, RP0								; On repasse dans la bank0 pour pouvoir utiliser PORTA et B sans utiliser les trucs à la ligne 40
;************************************************************************ 
; MAIN AREA - MAIN LOOP OF THE PROGRAM
;************************************************************************ 
MAIN
    CALL CHECK_BUTTONS
    CALL START_ACTIONS
    GOTO MAIN			
;************************************************************************ 
; MAIN SUBROUTINES AGGREGATION
;************************************************************************ 
CHECK_BUTTONS
    CALL CHECK_RA0		
    CALL CHECK_RA1	
    CALL CHECK_RA2	
    RETURN
START_ACTIONS
    CALL SCANNER_EFFECT_START_ACTION
    CALL LEDS_BLINKING_START_ACTION
    RETURN
;************************************************************************ 
; BUTTONS: TRIGGERS
;************************************************************************   
CHECK_RA0			
    BTFSS PORTA,RA0		
    RETURN
    BTFSC PORTA,RA0			
    GOTO $-1
    CALL ACTION_RA0
    GOTO MAIN
CHECK_RA1
    BTFSS PORTA,RA1			
    RETURN	
    BTFSC PORTA,RA1			
    GOTO $-1
    CALL ACTION_RA1
    GOTO MAIN	
CHECK_RA2
    BTFSS PORTA, RA2
    RETURN
    BTFSC PORTA,RA2			
    GOTO $-1
    CALL ACTION_RA2
    GOTO MAIN  
;************************************************************************ 
; BUTTONS: ACTIONS
;************************************************************************  
ACTION_RA0
    CALL SHUT_THE_LEDS_OFF
    CALL SET_IS_LED_BLINKING
    RETURN
ACTION_RA1
    CALL SHUT_THE_LEDS_OFF
    RETURN
ACTION_RA2
    CALL SHUT_THE_LEDS_OFF
    CALL SET_IS_SCANNER_EFFECT_ON
    RETURN
;************************************************************************ 
; ACTIONS TRIGGERS WITH PATTERN SELECTOR
;************************************************************************ 
SCANNER_EFFECT_START_ACTION
    BTFSC LEDS_PATTERN_SELECTOR, 1						; ",1" veut dire qu'on check le bit en position 1 (ici X => 0000 00X0 ). BTFSC prend en compte ce bit, si c'est un 1 il skip, sinon il exécute l'instruction suivante.
    CALL SCANNER_EFFECT
    RETURN
LEDS_BLINKING_START_ACTION
    BTFSC LEDS_PATTERN_SELECTOR, 0 
    CALL BLINK_ALL_LEDS_ONCE
    RETURN
;************************************************************************ 
; PATTERN SELECTION
;************************************************************************    
SET_IS_LED_BLINKING
    MOVLW b'00000001'
    MOVWF LEDS_PATTERN_SELECTOR   
    RETURN	
SET_IS_SCANNER_EFFECT_ON
    MOVLW b'00000010'
    MOVWF LEDS_PATTERN_SELECTOR   
    RETURN  
CLEAR_LEDS_PATTERN_SELECTOR
    MOVLW b'00000000'		   
    MOVWF LEDS_PATTERN_SELECTOR   
    RETURN	
;************************************************************************ 
; LED PATTERNS
;************************************************************************ 
SHUT_THE_LEDS_OFF
    CALL CLEAR_LEDS_PATTERN_SELECTOR
    CALL LIGHT_OFF_PORTB
    RETURN
BLINK_ALL_LEDS_ONCE
    CALL LIGHT_ON_PORTB		    
    CALL DELAY_WITH_CHECK_BUTTON    
    CALL LIGHT_OFF_PORTB	    
    CALL DELAY_WITH_CHECK_BUTTON    
    RETURN
SCANNER_EFFECT ; une autre façon de faire mais pas forcément mieux <3 
    MOVLW b'00000000'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    MOVLW b'10000001'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    MOVLW b'01000010'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    MOVLW b'00100100'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    MOVLW b'00011000'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    MOVLW b'00100100'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    MOVLW b'01000010'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    MOVLW b'10000001'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    MOVLW b'00000000'
    CALL SCANNER_EFFECT_MOVE_AND_WAIT
    RETURN
;************************************************************************ 
; PORTB STATE REGISTER MODIFICATIONS
;************************************************************************  
SCANNER_EFFECT_MOVE_AND_WAIT
    MOVWF PORTB
    CALL DELAY_WITH_CHECK_BUTTON
    RETURN
LIGHT_ON_PORTB
    MOVLW b'11111111'	
    MOVWF PORTB		
    RETURN		
LIGHT_OFF_PORTB
    MOVLW b'00000000'	
    MOVWF PORTB		
    RETURN			  
;************************************************************************ 
; DELAYS
;************************************************************************ 
DELAY_WITH_CHECK_BUTTON
    MOVLW 0x20
    MOVWF NB_BUTTON_CHECK
DELAY_WITH_CHECK_BUTTON_0		    
    DECFSZ NB_BUTTON_CHECK,f
    GOTO DELAY_WITH_CHECK_BUTTON_CHECK
    RETURN
DELAY_WITH_CHECK_BUTTON_CHECK
    CALL DELAY
    CALL CHECK_BUTTONS
    GOTO DELAY_WITH_CHECK_BUTTON_0
DELAY
    MOVLW	0xE7
    MOVWF	d1
    MOVLW	0x04
    MOVWF	d2
DELAY_0
    DECFSZ	d1, f
    GOTO	$+2
    DECFSZ	d2, f
    GOTO	DELAY_0
    GOTO	$+1
    RETURN
END