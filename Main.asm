;************************************************************************
;* Nom de fichier:  *
;* Date: XX-XX-XXXX *
;* *
;* Auteur:  *
;* Haute Ecole Louvain en Hainaut *
;************************************************************************
;* Fichiers n�cessaires: aucun *
;************************************************************************
;* Notes: *
;************************************************************************
    list p=16F84, f=INHX8M ; directive pour definir le processeur
    list c=90, n=60 ; directives pour le listing
    #include <p16F84a.inc> ; incorporation variables sp�cifiques
    errorlevel -302 ; pas d'avertissements de bank
    errorlevel -305 ; pas d'avertissements de fdest

    __config _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC

;************************************************************************
;* D�finitions et Variables *
    #DEFINE led1_ON b'11111111' ;Define c'est comme d�clarer des constantes
    #DEFINE led1_OFF b'00000000'
    #DEFINE Button_RB1_PRESSED  b'00000000'
    #DEFINE Button_RB1_RELEASED b'00000001'
    ; Quand y'a un # (devant include et define) c'est une directive de 
    ;pr�compilation c�d que c'est pas le programme qui fait la commande, c'est 
    ;une commande pour le compilateur
;************************************************************************
    cblock 0x020
; d�claration de variables
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
    BCF STATUS, RP0	    ;on clear le bit 5 de STATUS, ce qui permet de selectionner bank0
    CLRF PORTB		    ; initialise portB avec un clear des outputs
    CLRF PORTA
    BSF STATUS, RP0	    ; On set le bit 5 de STATUS � 1, donc bank1 est selectionn�e    
; Partie qui dit que RB7 � RB0 sont des outputs
    MOVLW 0x00		    ;0x00 = hexa / b'0' = binaire / 0 = decimal on doit pr�ciser le syst�me de num�ration
    MOVWF TRISB		    ; on met 0x00 dans TRISB, ce qui met PORTB en output
;Partie qui dit que RA4 � RA0 sont des inputs
    MOVLW b'00000111'	    ;0x01 = input
    MOVWF TRISA		    ;on met 1 dans trisA : input
    
    BCF STATUS, RP0	    ;On repasse dans la bank0 pour pouvoir utiliser PORTA et B sans utiliser les trucs � la ligne 40
;************************************************************************
;************************************************************************ 
MAIN
    CALL CHECK_RA0 
    GOTO MAIN
    
CHECK_RA0		;Subroutine qui permet d'allumer/�teindre la led
    BTFSS PORTA,RA0	;On teste les bits qu'on a dans f (donc PORTA), s'ils sont =1 on skip l'instruction suivante imm�diate et on va � celle d'apr�s
    RETURN		;Return execute l'instruction apr�s le call de la fonction CHECK_RA0
			;Donc l� si les bits PORTA = 0 on vient ici, si les bits PORTA = 1 on la saute
    ;CALL DELAY_100MS	;Delay de 100ms pour �viter les rebonds du bouton
    BTFSC PORTB,RB0	;si les bits de PORTB=0 on skip l'instruction suivante imm�diate (donc si la led n'est pas allum�e)
    GOTO LED_OFF	;D'apr�s l'instruction au dessus, si les bits de PORTB =0 on skip ici, sinon on skip pas et la led s'�teint
LED_ON
    BTFSC PORTA,RA0	;si les bits de PORTA=0 on skip l'instruction suivante imm�diate (le bouton n'est pas appuy� donc on allume pas les leds)
    GOTO LED_ON		;on va ici que si les bits de PORTA=1 (donc si le bouton est appuy�)
    BSF PORTB,RB0	;on set les bits de PORTB � 1 -> les leds s'allument
    RETURN
LED_OFF
    BTFSC PORTA,RA0	;si les bits de PORTA=0 on skip l'instruction suivante imm�diate (le bouton n'est pas appuy� donc on allume pas les leds)
    GOTO LED_OFF	;on va ici que si les bits de PORTA=1 (donc si le bouton est appuy�)
    BCF PORTB,RB0	;on clear les bits de PORTB  -> les leds s'�teignent
    RETURN
    
BLINK_ALL_LEDS
    movlw led1_ON	; move led1_ON dans le W
    movwf PORTB		; move W dans f (�a bouge led1_ON dans w dans portB)
    call DELAY_1S
    movlw led1_OFF	; move led1_OFF dans w
    movwf PORTB		; move W dans f (�a bouge led1_OFF dans w dans portB)
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