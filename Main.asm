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
    BUTTON_SELECTOR,
    RIGHT_OPERAND,
    LEFT_OPERAND,
    RESULT,
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
    MOVLW b'00011111'								; 1=input -> ici RA0 et RA1
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
    CALL CHECK_RA3	
    CALL CHECK_RA4
    RETURN
START_ACTIONS
    CALL INCR_LEFT_OPERAND
    CALL INCR_RIGHT_OPERAND
    CALL SUB_OPERATION
    CALL ADD_OPERATION
    CALL RESET_OPERATION
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
CHECK_RA3
    BTFSS PORTA, RA3
    RETURN
    BTFSC PORTA,RA3			
    GOTO $-1
    CALL ACTION_RA3
    GOTO MAIN  
CHECK_RA4
    BTFSS PORTA, RA4
    RETURN
    BTFSC PORTA,RA4			
    GOTO $-1
    CALL ACTION_RA4
    GOTO MAIN 
;************************************************************************ 
; BUTTONS: ACTIONS
;************************************************************************  
ACTION_RA0
    CALL SET_INCR_LEFT_OPERAND
    RETURN
ACTION_RA1
    CALL SET_INCR_RIGHT_OPERAND
    RETURN
ACTION_RA2
    CALL SET_SUB_OPERATION
    RETURN
ACTION_RA3
    CALL SET_ADD_OPERATION
    RETURN
ACTION_RA4
    CALL SET_RESET
    RETURN
;************************************************************************ 
; OPERATION SELECTION
;************************************************************************    
SET_INCR_LEFT_OPERAND
    MOVLW b'00000001'
    MOVWF BUTTON_SELECTOR   
    RETURN	
SET_INCR_RIGHT_OPERAND
    MOVLW b'00000010'
    MOVWF BUTTON_SELECTOR   
    RETURN  
SET_SUB_OPERATION
    MOVLW b'00000100'
    MOVWF BUTTON_SELECTOR   
    RETURN 
SET_ADD_OPERATION
    MOVLW b'00001000'
    MOVWF BUTTON_SELECTOR   
    RETURN 
SET_RESET
    MOVLW b'00010000'
    MOVWF BUTTON_SELECTOR   
    RETURN
;************************************************************************ 
; CLEARS
;************************************************************************
CLEAR_BUTTON_SELECTOR
    MOVLW b'00000000'		   
    MOVWF BUTTON_SELECTOR   
    RETURN
CLEAR_LEFT_OPERAND
    MOVLW b'00000000'		   
    MOVWF LEFT_OPERAND   
    RETURN
CLEAR_RIGHT_OPERAND
    MOVLW b'00000000'		   
    MOVWF RIGHT_OPERAND   
    RETURN
CLEAR_RESULT
    MOVLW b'00000000'		   
    MOVWF RESULT   
    RETURN
CLEAR_PORTB
    MOVLW b'00000000'		   
    MOVWF PORTB   
    RETURN
;************************************************************************ 
; ACTIONS TRIGGERS WITH OPERATION SELECTOR
;************************************************************************ 
INCR_LEFT_OPERAND
    BTFSC BUTTON_SELECTOR, 0						; ",1" veut dire qu'on check le bit en position 1 (ici X => 0000 00X0 ). BTFSC prend en compte ce bit, si c'est un 1 il skip, sinon il exécute l'instruction suivante.
    CALL INCR_LEFT_OPERAND_ROUTINE
    RETURN
INCR_RIGHT_OPERAND
    BTFSC BUTTON_SELECTOR, 1						; ",1" veut dire qu'on check le bit en position 1 (ici X => 0000 00X0 ). BTFSC prend en compte ce bit, si c'est un 1 il skip, sinon il exécute l'instruction suivante.
    CALL INCR_RIGHT_OPERAND_ROUTINE
    RETURN
SUB_OPERATION
    BTFSC BUTTON_SELECTOR, 2						; ",1" veut dire qu'on check le bit en position 1 (ici X => 0000 00X0 ). BTFSC prend en compte ce bit, si c'est un 1 il skip, sinon il exécute l'instruction suivante.
    CALL SUB_OPERATION_ROUTINE
    RETURN
ADD_OPERATION
    BTFSC BUTTON_SELECTOR, 3						; ",1" veut dire qu'on check le bit en position 1 (ici X => 0000 00X0 ). BTFSC prend en compte ce bit, si c'est un 1 il skip, sinon il exécute l'instruction suivante.
    CALL ADD_OPERATION_ROUTINE
    RETURN
RESET_OPERATION
    BTFSC BUTTON_SELECTOR, 4						; ",1" veut dire qu'on check le bit en position 1 (ici X => 0000 00X0 ). BTFSC prend en compte ce bit, si c'est un 1 il skip, sinon il exécute l'instruction suivante.
    CALL RESET_ROUTINE
    RETURN
;************************************************************************ 
; PORTB STATE REGISTER MODIFICATIONS AND OPERATIONS
;************************************************************************ 
INCR_LEFT_OPERAND_ROUTINE
    CALL CLEAR_BUTTON_SELECTOR
    INCF LEFT_OPERAND
    CALL SHOW_LEFT_OPERAND
    RETURN
INCR_RIGHT_OPERAND_ROUTINE
    CALL CLEAR_BUTTON_SELECTOR
    INCF RIGHT_OPERAND
    CALL SHOW_RIGHT_OPERAND
    RETURN
SUB_OPERATION_ROUTINE
    CALL CLEAR_BUTTON_SELECTOR
    MOVFW RIGHT_OPERAND
    SUBWF LEFT_OPERAND, W
    MOVWF RESULT
    CALL SHOW_RESULT
    RETURN
ADD_OPERATION_ROUTINE
    CALL CLEAR_BUTTON_SELECTOR
    MOVFW LEFT_OPERAND
    ADDWF RIGHT_OPERAND, W
    MOVWF RESULT
    CALL SHOW_RESULT
    RETURN
RESET_ROUTINE
    CALL CLEAR_BUTTON_SELECTOR
    CALL CLEAR_PORTB
    CALL CLEAR_LEFT_OPERAND
    CALL CLEAR_RIGHT_OPERAND
    CALL CLEAR_RESULT
    RETURN
;************************************************************************ 
; SHOW
;************************************************************************
SHOW_LEFT_OPERAND
    CALL CLEAR_PORTB
    MOVFW LEFT_OPERAND
    MOVWF PORTB
    RETURN
SHOW_RIGHT_OPERAND
    CALL CLEAR_PORTB
    MOVFW RIGHT_OPERAND
    MOVWF PORTB
    RETURN
SHOW_RESULT
    CALL CLEAR_PORTB
    MOVFW RESULT
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