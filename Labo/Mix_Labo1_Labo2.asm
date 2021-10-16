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
IS_LED_BLINKING,d1,d2,NB_BUTTON_CHECK,IS_SCANNER_EFFECT_ON
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
 
START
    
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
    MOVLW b'00000111'	    ;1=input -> ici RA0 et RA1
    MOVWF TRISA		    ;on met 1 dans trisA : input
    
    BCF STATUS, RP0	    ;On repasse dans la bank0 pour pouvoir utiliser PORTA et B sans utiliser les trucs � la ligne 40
;************************************************************************
;************************************************************************ 

;Boucle principale du projet
MAIN
    CALL CHECK_RA0		;On appelle le check du bouton RA0
    CALL CHECK_RA1	;On appelle le check du bouton RA1
    CALL CHECK_RA2		;Check RA2
    BTFSC IS_SCANNER_EFFECT_ON,0
    CALL SCANNER_EFFECT
    BTFSC IS_LED_BLINKING, 0	;Skip l'instruction suivante si Is_Led_Blinking = 0 (donc si la led ne clignote pas) le programme fait juste boucler, attendant qu'on appuie sur un bouton
				;Si is_led_blinking est � 1, on fait l'instruction du dessous
    CALL BLINK_ALL_LEDS_ONCE	;On fait clignoter les leds 1 fois
    GOTO MAIN			;On boucle sur le main
    
;Toutes les op�rations servant � utiliser le bouton RA0
;En gros tout ce bloc est un toggle sur is_led_blinking -> Si les leds sont �teintes et qu'on appuie, �a les fait clignoter, 
;et si elles clignotent et qu'on appuie �a les fixe, et si elles sont fixes, �a les refait clignoter
;Le bloc g�re aussi le rebond du bouton
CHECK_RA0			;Subroutine qui permet d'allumer/�teindre la led
    BTFSS PORTA,RA0		;On teste les bits qu'on a dans f (donc PORTA), s'ils sont =1 on skip l'instruction suivante imm�diate et on va � celle d'apr�s
    RETURN			;Return execute l'instruction apr�s le call de la fonction CHECK_RA0
				;Donc l� si les bits PORTA = 0 on vient ici, si les bits PORTA = 1 on la saute
    BTFSC IS_LED_BLINKING,0	;Skip l'instruction suivante si Is_Led_Blinking = 0 (donc si la led ne clignote pas)
    GOTO STOP_LED_BLINKING	;Si is_led_blinking = 1, on att�rit sur cette instruction, donc on va � la subroutine stop_led_blinking
START_LED_BLINKING		
    CALL BOUNCING_BUTTON_SECURITY_RA0   ;Pour faire clignoter la led, on appelle la sub qui g�re le rebond du bouton
    CALL SHUT_THE_LEDS_OFF
    CALL SET_IS_LED_BLINKING		;Puis on appelle la sub qui met l'�tat de is_led_blinking � 1
    GOTO MAIN				;On va au Main
STOP_LED_BLINKING
    CALL BOUNCING_BUTTON_SECURITY_RA0   ;Pour stopper le clignotement, on appelle la sub qui g�re le rebond du bouton
    CALL SHUT_THE_LEDS_OFF		
    CALL LIGHT_ON_PORTB			;Puis on appelle la sub qui allume toutes les leds
    GOTO MAIN				;On va au Main

;Comme CHECK_RA0 mais avec RA1 (mais pour �teindre les leds)
CHECK_RA1
    BTFSS PORTA,RA1			;On teste les bits qu'on a dans f (donc PORTA), s'ils sont =1 on skip l'instruction suivante imm�diate et on va � celle d'apr�s
    RETURN				;Return execute l'instruction apr�s le call de la fonction CHECK_RA1
    CALL BOUNCING_BUTTON_SECURITY_RA1   ;Pour stopper le clignotement, on appelle la sub qui g�re le rebond du bouton
    CALL SHUT_THE_LEDS_OFF
    GOTO MAIN				;On va au Main

;Allume puis �teint les leds, pendant le d�lais d'attente check le bouton
BLINK_ALL_LEDS_ONCE
    CALL LIGHT_ON_PORTB		    ;On appelle la sub qui allume toutes les leds
    CALL DELAY_WITH_CHECK_BUTTON    ;On appelle la sub qui temporise en �coutant le bouton
    CALL LIGHT_OFF_PORTB	    ;On appelle la sub qui �teint toutes les leds
    CALL DELAY_WITH_CHECK_BUTTON    ;On appelle la sub qui temporise en �coutant le bouton
    RETURN			    ;On retourne apr�s le call de la subroutine 

CHECK_RA2
    BTFSS PORTA, RA2
    RETURN
    CALL BOUNCING_BUTTON_SECURITY_RA2
    CALL SHUT_THE_LEDS_OFF
    CALL SET_IS_SCANNER_EFFECT_ON
    GOTO MAIN
    
SCANNER_EFFECT
    CALL TRY_SCANNER_EFFECT_STATE1
    CALL DELAY_WITH_CHECK_BUTTON
    CALL TRY_SCANNER_EFFECT_STATE2
    CALL DELAY_WITH_CHECK_BUTTON
    CALL TRY_SCANNER_EFFECT_STATE3
    CALL DELAY_WITH_CHECK_BUTTON
    CALL TRY_SCANNER_EFFECT_STATE4
    CALL DELAY_WITH_CHECK_BUTTON
    CALL TRY_SCANNER_EFFECT_STATE3
    CALL DELAY_WITH_CHECK_BUTTON
    CALL TRY_SCANNER_EFFECT_STATE2
    CALL DELAY_WITH_CHECK_BUTTON
    CALL TRY_SCANNER_EFFECT_STATE1
    CALL DELAY_WITH_CHECK_BUTTON
    GOTO MAIN
    
;Allume toutes les leds
LIGHT_ON_PORTB
    MOVLW b'11111111'	;On move le litteral (ici L = b'11111111') dans le W
    MOVWF PORTB		;On met ce qu'il y a dans le W (donc b'11111111') dans PORTB
    RETURN		;On retourne apr�s le call de la subroutine

;Eteint toutes les leds
LIGHT_OFF_PORTB
    MOVLW b'00000000'	;On move le litteral (ici L = b'00000000') dans le W
    MOVWF PORTB		;On met ce qu'il y a dans le W (donc b'00000000') dans PORTB
    RETURN		;On retourne apr�s le call de la subroutine
    
;Set � 1 le 1er bit de la variable qui sert � savoir si les leds doivent blink ou pas    
SET_IS_LED_BLINKING
    MOVLW 0x01		    ;On move le Litt�ral 0x01 dans le W
    MOVWF IS_LED_BLINKING   ;On met ce qu'il y a dans le W (0x01) dans Is_Led_Blinking
    RETURN		    ;On retourne apr�s le call de la subroutine
    
;Clear le 1er bit de la variable qui sert � savoir si les leds doivent blink ou pas
CLEAR_IS_LED_BLINKING
    MOVLW 0x00		    ;On move le Litt�ral 0x00 dans le W
    MOVWF IS_LED_BLINKING   ;On met ce qu'il y a dans le W (0x00) dans Is_Led_Blinking
    RETURN		    ;On retourne apr�s le call de la subroutine

SET_IS_SCANNER_EFFECT_ON
    MOVLW 0x01		    ;On move le Litt�ral 0x01 dans le W
    MOVWF IS_SCANNER_EFFECT_ON   ;On met ce qu'il y a dans le W (0x01) dans Is_Led_Blinking
    RETURN		    ;On retourne apr�s le call de la subroutine
    
CLEAR_IS_SCANNER_EFFECT_ON
    MOVLW 0x00		    ;On move le Litt�ral 0x01 dans le W
    MOVWF IS_SCANNER_EFFECT_ON   ;On met ce qu'il y a dans le W (0x01) dans Is_Led_Blinking
    RETURN		    ;On retourne apr�s le call de la subroutine

SHUT_THE_LEDS_OFF
    CALL CLEAR_IS_LED_BLINKING
    CALL CLEAR_IS_SCANNER_EFFECT_ON
    CALL LIGHT_OFF_PORTB
    RETURN
    
;Essai effet Scanner
TRY_SCANNER_EFFECT_STATE1
    MOVLW b'10000001'
    MOVWF PORTB
    RETURN
TRY_SCANNER_EFFECT_STATE2
    MOVLW b'01000010'
    MOVWF PORTB
    RETURN
TRY_SCANNER_EFFECT_STATE3
    MOVLW b'00100100'
    MOVWF PORTB
    RETURN
TRY_SCANNER_EFFECT_STATE4
    MOVLW b'00011000'
    MOVWF PORTB
    RETURN
    
;Pi�ge l'execution dans une boucle afin d'attendre que le bouton RA0 soit relach�
BOUNCING_BUTTON_SECURITY_RA0
    BTFSC PORTA,RA0			;si les bits de PORTA=0 on skip l'instruction suivante imm�diate 
    GOTO BOUNCING_BUTTON_SECURITY_RA0   ;On revient au d�but de la subroutine si PORTA=1
    RETURN				;On retourne apr�s le call de la subroutine
    
;Pi�ge l'execution dans une boucle afin d'attendre que le bouton RA1 soit relach�    
BOUNCING_BUTTON_SECURITY_RA1
    BTFSC PORTA,RA1			;si les bits de PORTA=0 on skip l'instruction suivante imm�diate 
    GOTO BOUNCING_BUTTON_SECURITY_RA1   ;On revient au d�but de la subroutine si PORTA=1
    RETURN				;On retourne apr�s le call de la subroutine
 
BOUNCING_BUTTON_SECURITY_RA2
    BTFSC PORTA,RA2			;si les bits de PORTA=0 on skip l'instruction suivante imm�diate 
    GOTO BOUNCING_BUTTON_SECURITY_RA2   ;On revient au d�but de la subroutine si PORTA=1
    RETURN				;On retourne apr�s le call de la subroutine
    
;Boucle de check du bouton entrecoup�e de d�lais r�p�t�e 0x20 fois
;La vraie utilit� de cette sub est de check le bouton pendant qu'on attend l'ex�cution du delay
;On appelle plein de fois le petit delay(et on check le bouton entre chaque), ce qui en fait un gros delay
DELAY_WITH_CHECK_BUTTON
    MOVLW 0x20				    ;On met le Litteral 0x20 dans W
    MOVWF NB_BUTTON_CHECK		    ;On met ce qu'il y a dans le W dans nb_button_check
DELAY_WITH_CHECK_BUTTON_0		    
    DECFSZ NB_BUTTON_CHECK,f		    ;On d�cr�mente f et on skip l'instruction suivante quand f=0
    GOTO DELAY_WITH_CHECK_BUTTON_CHECK	    ;On va ici si f !=0
    RETURN				    ;Return l� o� on call la subroutine
DELAY_WITH_CHECK_BUTTON_CHECK
    CALL DELAY				    ;On appelle l'autre delay, en gros on a un d�compte dans le d�compte
    CALL CHECK_RA0			    ;On �coute le bouton RA0
    CALL CHECK_RA1		    ;On �coute le bouton RA1
    CALL CHECK_RA2
    GOTO DELAY_WITH_CHECK_BUTTON_0	    ;boucle sur la ligne correspondante
    
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