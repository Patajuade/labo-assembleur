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
unevariable,uneautre,temp_1,temp_2,temp_3
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
    BCF STATUS, RP0 ;on clear le bit 5 de STATUS, ce qui permet de selectionner bank0
    CLRF PORTB ; initialise portB avec un clear des outputs
    CLRF PORTA
    BSF STATUS, RP0 ; On set le bit 5 de STATUS à 1, donc bank1 est selectionnée    
; Partie qui dit que RB7 à RB0 sont des outputs
    MOVLW 0x00 ;0x00 = hexa / b'0' = binaire / 0 = decimal on doit préciser le système de numération
    MOVWF TRISB ; on met 0x00 dans TRISB, ce qui met PORTB en output
;Partie qui dit que RA4 à RA0 sont des inputs
    MOVLW b'00000111' ;0x01 = input
    MOVWF TRISA ;on met 1 dans trisA : input
    
    BCF STATUS, RP0 ;On repasse dans la bank0 pour pouvoir utiliser PORTA et B sans utiliser les trucs à la ligne 40
;************************************************************************
;************************************************************************ 
MAIN
    CALL CHECK_RA0
    GOTO MAIN
    
CHECK_RA0 ;Subroutine qui permet d'allumer/éteindre la led
    BTFSS PORTA,RA0
    RETURN
    CALL DELAY_100MS
    BTFSC PORTB,RB0
    GOTO LED_OFF
LED_ON
    BTFSC PORTA,RA0
    GOTO LED_ON
    BSF PORTB,RB0
    GOTO MAIN
LED_OFF
    BTFSC PORTA,RA0
    GOTO LED_OFF
    BCF PORTB,RB0
    GOTO MAIN
    
BLINK_ALL_LEDS
    movlw led1_ON    ; move led1_ON dans W
    movwf PORTB        ; move W dans f (ça bouge ce qu'y a dans w dans portB)
    call DELAY_1S
    movlw led1_OFF ; move led1_OFF dans w
    movwf PORTB        ; move W dans f (ça bouge ce qu'y a dans w dans portB)
    call DELAY_1S
    return
    
;------------------------------- Delay -----------------------------------
	cblock
	d1
	d2
	d3
	endc

DELAY_1S
			;499994 cycles
	movlw	0x03
	movwf	d1
	movlw	0x18
	movwf	d2
	movlw	0x02
	movwf	d3
__DELAY_1S
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	$+2
	decfsz	d3, f
	goto	__DELAY_1S

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return
    
DELAY_100MS
			;49998 cycles
	movlw	0x0F
	movwf	d1
	movlw	0x28
	movwf	d2
__DELAY_100MS
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	__DELAY_100MS

			;2 cycles
	goto	$+1
	RETURN
end