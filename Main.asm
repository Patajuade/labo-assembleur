;************************************************************************
;* Nom de fichier:  *
;* Date: XX-XX-XXXX *
;* *
;* Auteur:  *
;* Haute Ecole Louvain en Hainaut *
;************************************************************************
;* Fichiers nécessaires: aucun *
;************************************************************************
;* Notes: *
;************************************************************************
    list p=16F84, f=INHX8M ; directive pour definir le processeur
    list c=90, n=60 ; directives pour le listing
    #include <p16F84a.inc> ; incorporation variables spécifiques
    errorlevel -302 ; pas d'avertissements de bank
    errorlevel -305 ; pas d'avertissements de fdest

    __config _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC

;************************************************************************
;* Définitions et Variables *
    #DEFINE led1_ON b'11111111' ;Define c'est comme déclarer des constantes
    #DEFINE led1_OFF b'00000000'
    #DEFINE Button_RB1_PRESSED  b'00000000'
    #DEFINE Button_RB1_RELEASED b'00000001'
    ; Quand y'a un # (devant include et define) c'est une directive de 
    ;précompilation càd que c'est pas le programme qui fait la commande, c'est 
    ;une commande pour le compilateur
;************************************************************************
    cblock 0x020
; déclaration de variables
IS_LED_BLINKING,d1,d2,NB_BUTTON_CHECK
    endc   
 ;equ
;************************************************************************
;* Programme principal *
;************************************************************************

;    cpu equates (memory map)
    ;myPortB    equ    0x06 ;Definit l'addresse du portB quelque soit la bank 
			    ;dans laquelle je me trouve j'ai le droit d'utiliser PORTB
    ;myPortA    equ    0x05 ;Definit l'addresse du portA
    ORG 0x000 ; vecteur reset
;************************************************************************
 
start
    
;************************************************************************   
;Initialisation PortB et PortA p15
    BCF STATUS, RP0	    ;on clear le bit 5 de STATUS, ce qui permet de selectionner bank0
    CLRF PORTB		    ; initialise portB avec un clear des outputs
    CLRF PORTA
    BSF STATUS, RP0	    ; On set le bit 5 de STATUS à 1, donc bank1 est selectionnée    
; Partie qui dit que RB7 à RB0 sont des outputs
    MOVLW 0x00		    ;0x00 = hexa / b'0' = binaire / 0 = decimal on doit préciser le système de numération
    MOVWF TRISB		    ; on met 0x00 dans TRISB, ce qui met PORTB en output
;Partie qui dit que RA4 à RA0 sont des inputs
    MOVLW b'00000111'	    ;0x01 = input
    MOVWF TRISA		    ;on met 1 dans trisA : input
    
    BCF STATUS, RP0	    ;On repasse dans la bank0 pour pouvoir utiliser PORTA et B sans utiliser les trucs à la ligne 40
;************************************************************************
;************************************************************************ 

;Boucle principale du projet
MAIN
    CALL CHECK_RA0
    BTFSC IS_LED_BLINKING, 0
    CALL BLINK_ALL_LEDS_ONCE
    GOTO MAIN
    
;Toutes les opérations servant à utiliser le bouton RA0    
CHECK_RA0		;Subroutine qui permet d'allumer/éteindre la led
    BTFSS PORTA,RA0	;On teste les bits qu'on a dans f (donc PORTA), s'ils sont =1 on skip l'instruction suivante immédiate et on va à celle d'après
    RETURN		;Return execute l'instruction après le call de la fonction CHECK_RA0
			;Donc là si les bits PORTA = 0 on vient ici, si les bits PORTA = 1 on la saute
    BTFSC IS_LED_BLINKING,0	;
    GOTO STOP_LED_BLINKING	;
START_LED_BLINKING
    CALL BOUNCING_BUTTON_SECURITY
    CALL SET_IS_LED_BLINKING
    GOTO MAIN
STOP_LED_BLINKING
    CALL BOUNCING_BUTTON_SECURITY
    CALL CLEAR_IS_LED_BLINKING
    CALL LIGHT_ON_PORTB
    GOTO MAIN

;Allume puis éteint les leds, pendant le délais d'attente check le bouton
BLINK_ALL_LEDS_ONCE
    CALL LIGHT_ON_PORTB
    CALL DELAY_WITH_CHECK_BUTTON
    CALL LIGHT_OFF_PORTB
    CALL DELAY_WITH_CHECK_BUTTON
    RETURN
    
;Allume toutes les leds
LIGHT_ON_PORTB
    MOVLW b'11111111'	; 
    MOVWF PORTB		; 
    RETURN

;Eteint toutes les leds
LIGHT_OFF_PORTB
    MOVLW b'00000000'	; 
    MOVWF PORTB		; 
    RETURN 
    
;Set à 1 le 1er bit de la variable qui sert à savoir si les leds doivent blink ou pas    
SET_IS_LED_BLINKING
    MOVLW 0x01
    MOVWF IS_LED_BLINKING
    RETURN
    
;Clear le 1er bit de la variable qui sert à savoir si les leds doivent blink ou pas
CLEAR_IS_LED_BLINKING
    MOVLW 0x00
    MOVWF IS_LED_BLINKING
    RETURN
    
;Piège l'execution dans une boucle afin d'attendre que le bouton soit relaché
BOUNCING_BUTTON_SECURITY
    BTFSC PORTA,RA0	;si les bits de PORTA=0 on skip l'instruction suivante immédiate (le bouton n'est pas appuyé donc on allume pas les leds)
    GOTO BOUNCING_BUTTON_SECURITY
    RETURN
    
;Boucle de check du bouton entrecoupée de délais répétée 0x20 fois
DELAY_WITH_CHECK_BUTTON
    MOVLW 0x20
    MOVWF NB_BUTTON_CHECK
DELAY_WITH_CHECK_BUTTON_0
    DECFSZ NB_BUTTON_CHECK,f
    GOTO DELAY_WITH_CHECK_BUTTON_CHECK
    RETURN
DELAY_WITH_CHECK_BUTTON_CHECK
    CALL DELAY
    CALL CHECK_RA0
    GOTO DELAY_WITH_CHECK_BUTTON_0
    
;Delay subroutine
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