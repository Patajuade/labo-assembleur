;************************************************************************
;* Nom de fichier: LABO1-2_REFACTORING *
;* Date: 20211016 *
;* *
;* Auteur:  MCD
;* Haute Ecole Louvain en Hainaut *
;************************************************************************
;* Fichiers n�cessaires: aucun *
;************************************************************************
;* Notes: *
;************************************************************************
    list p=16F84, f=INHX8M		; directive pour definir le processeur
    list c=90, n=60			; directives pour le listing
    #include <p16F84a.inc>		; incorporation variables sp�cifiques
    errorlevel -302			; pas d'avertissements de bank
    errorlevel -305			; pas d'avertissements de fdest

    __config _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC	    ; configuration du pic, cf. documentation

;************************************************************************
;* D�finitions et Variables *
    #DEFINE EXAMPLE b'000000000'	; Define c'est comme d�clarer des constantes
					; Quand y'a un # (devant include et define) c'est une directive de 
					; pr�compilation c�d que c'est pas le programme qui fait la commande, c'est 
					; une commande pour le compilateur
;************************************************************************
    cblock 0x020	    ; Debut de l'endroit o� on d�clare les variables
    d1,d2,NB_BUTTON_CHECK,LEDS_PATTERN_SELECTOR,K2000_COUNTDOWN
    endc		    ; Fin de l'endroit o� on d�clare les variables
    
;************************************************************************
;* Programme principal *
;************************************************************************
;    cpu equates (memory map)
    ;myPortB    equ    0x06	    ; Definit l'addresse du portB quelque soit la bank 
				    ; dans laquelle je me trouve j'ai le droit d'utiliser PORTB
    ;myPortA    equ    0x05	    ; Definit l'addresse du portA
    ORG 0x000 ; vecteur reset
START  
;************************************************************************ 
; START - PORTS INITIALISATION (p.15)
;************************************************************************
    BCF STATUS, RP0		; on clear le bit 5 de STATUS, ce qui permet de selectionner bank0 (p.7)
    CLRF PORTB			; initialise portB avec un clear des outputs
    CLRF PORTA			; idem
    BSF STATUS, RP0		; On set le bit 5 de STATUS � 1, donc bank1 est selectionn�e    
;************************************************************************ 
; START - I/O SETUP
;************************************************************************
    MOVLW 0x00			; 0x00 = hexa / b'0' = binaire / 0 = decimal on doit pr�ciser le syst�me de num�ration
    MOVWF TRISB			; on met 0x00 dans TRISB, ce qui met PORTB en output
    MOVLW b'00000111'		; 1=input -> ici RA0 et RA1
    MOVWF TRISA			; on met 1 dans trisA : input
;************************************************************************ 
; START - BANK SELECTION TO USE PORTA / PORTB
;************************************************************************    
    BCF STATUS, RP0		; On repasse dans la bank0 pour pouvoir utiliser PORTA et B sans utiliser les trucs � la ligne 40
;************************************************************************ 
; MAIN AREA - MAIN LOOP OF THE PROGRAM
;************************************************************************ 
MAIN
    CALL CHECK_BUTTONS		; On appelle la subroutine CHECK_BUTTONS
    CALL START_ACTIONS		; On appelle la subroutine START_ACTIONS
    GOTO MAIN			; On retourne au label MAIN
;************************************************************************ 
; MAIN SUBROUTINES AGGREGATION
;************************************************************************ 
CHECK_BUTTONS
    CALL CHECK_RA0		; On appelle la subroutine CHECK_RA0
    CALL CHECK_RA1		; On appelle la subroutine CHECK_RA1
    CALL CHECK_RA2		; On appelle la subroutine CHECK_RA2
    RETURN			; On retourne l� o� la subroutine a �t� call
    
START_ACTIONS
    CALL SCANNER_EFFECT_START_ACTION	    ; On appelle la subroutine SCANNER_EFFECT_START_ACTION
    CALL K2000_START_ACTION		    ; On appelle la subroutine K2000_START_ACTION
    CALL PARROT_EFFECT_START_ACTION	    ; On appelle la subroutine PARROT_EFFECT_START_ACTION
    RETURN				    ; On retourne l� o� la subroutine a �t� call
;************************************************************************ 
; BUTTONS: TRIGGERS
;************************************************************************   
CHECK_RA0			
    BTFSS PORTA,RA0		; On teste RA0 de PORTA, s'il est =1 (donc si le bouton est appuy�), on skip l'instruction suivante
    RETURN			; Si RA0=0 (donc si le bouton n'est pas appuy�) on retourne l� o� la sub est call
    BTFSC PORTA,RA0		; ANTI-REBOND -> On teste RA0 de PORTA, s'il est =0 (donc si le bouton n'est pas appuy�), on skip l'instruction suivante
    GOTO $-1			; Si RA0=1 on revient une ligne avant (donc tant qu'on reste appuy� sur le bouton)
    CALL ACTION_RA0		; Sinon il appelle ACTION_RA0
    GOTO MAIN			; On retourne au MAIN
    
CHECK_RA1
    BTFSS PORTA,RA1		; Si RA1 = 1, on skip	
    RETURN			; On retourne l� o� la sub est call
    BTFSC PORTA,RA1		; Sinon si RA1 = 0, on skip
    GOTO $-1			; Si RA1 = 1, on retourne � la ligne du dessus pour recheck la condition 
    CALL ACTION_RA1		; Si RA1 = 0, donc une fois le bouton rel�ch�, on appelle la subroutine ACTION_RA1
    GOTO MAIN			; On retourne au MAIN
    
CHECK_RA2
    BTFSS PORTA, RA2		; Si le bouton est appuy�, on skip l'instruction d'apr�s
    RETURN			; Si le bouton n'est pas appuy�, on retourne l� o� la sub est call
    BTFSC PORTA,RA2		; Si le bouton n'est pas appuy�, on skip l'instruction d'apr�s
    GOTO $-1			; On retourne � la ligne d'avant et on boucle dessus tant que le bouton est appuy�
    CALL ACTION_RA2		; Quand le bouton est rel�ch�, on appelle ACTION_RA2
    GOTO MAIN			; On retourne au MAIN
;************************************************************************ 
; BUTTONS: ACTIONS
;************************************************************************  
ACTION_RA0				; L'action li�e au bouton RA0
    CALL SHUT_THE_LEDS_OFF		; On appelle la sub SHUT_THE_LEDS_OFF
    CALL SET_IS_SCANNER_EFFECT_ON	; On appelle la sub SET_IS_SCANNER_EFFECT_ON
    RETURN				; On retourne l� o� la sub est call
    
ACTION_RA1				; L'action li�e au bouton RA1
    CALL SHUT_THE_LEDS_OFF		; On appelle la sub SHUT_THE_LEDS_OFF
    CALL SET_IS_K2000_EFFECT_ON		; On appelle la sub SET_IS_K2000_EFFECT_ON
    RETURN				; On retourne l� o� la sub est call
    
ACTION_RA2				; L'action li�e au bouton RA2
    CALL SHUT_THE_LEDS_OFF		; On appelle la sub SHUT_THE_LEDS_OFF
    CALL SET_IS_PARROT_EFFECT_ON	; On appelle la sub SET_IS_PARROT_EFFECT_ON
    RETURN				; On retourne l� o� la sub est call
;************************************************************************ 
; ACTIONS TRIGGERS WITH PATTERN SELECTOR
;************************************************************************ 
SCANNER_EFFECT_START_ACTION		; Sub qui permet de d�marrer une action en fonction du bouton appuy�
    BTFSC LEDS_PATTERN_SELECTOR, 0	; ",0" veut dire qu'on check le bit en position 0 (ici X => 0000 000X ). BTFSC prend en compte ce bit, si c'est un 0 il skip, sinon il ex�cute l'instruction suivante.
    CALL SCANNER_EFFECT			; Si le bouton en position 0 a son bit � 1 (donc si il est appuy�) on call la sub
    RETURN				; On retourne l� o� la sub est call
    
K2000_START_ACTION
    BTFSC LEDS_PATTERN_SELECTOR, 1	; On check le bit en position 1 (0000 00X0), BTFSC le lit, si c'est 0 il skip, si c'est 1 il ex�cute
    CALL K2000_EFFECT			; Si le bouton en position 1 a son bit � 1 (donc si il est appuy�) on call la sub
    RETURN				; On retourne l� o� la sub est call
    
PARROT_EFFECT_START_ACTION		; On check le bit en position 2 (0000 0X00), BTFSC le lit, si c'est 0 il skip, si c'est 1 il ex�cute
    BTFSC LEDS_PATTERN_SELECTOR, 2	; Si le bouton en position 2 a son bit � 1 (donc si il est appuy�) on call la sub
    RETURN				; On retourne l� o� la sub est call
;************************************************************************ 
; PATTERN SELECTION
;************************************************************************    
SET_IS_SCANNER_EFFECT_ON	    ; Sub qui permet de selectionner un pattern et de set les bits en fonction du bouton qui va �tre appuy�
    MOVLW b'00000001'		    ; On move le Litteral b'00000001' dans le W
    MOVWF LEDS_PATTERN_SELECTOR	    ; On met ce qu'il y a dans le W (donc b'00000001') dans le F LEDS_PATTERN_SELECTOR
    RETURN			    ; On retourne l� o� la sub est call
    
SET_IS_K2000_EFFECT_ON
    MOVLW b'00000010'		    ; On move le Litteral b'00000010' dans le W
    MOVWF LEDS_PATTERN_SELECTOR	    ; On met ce qu'il y a dans le W (donc b'00000010') dans le F LEDS_PATTERN_SELECTOR
    RETURN			    ; On retourne l� o� la sub est call
    
SET_IS_PARROT_EFFECT_ON
    MOVLW b'00000100'		    ; On move le Litteral b'00000100' dans le W
    MOVWF LEDS_PATTERN_SELECTOR	    ; On met ce qu'il y a dans le W (donc b'00000100') dans le F LEDS_PATTERN_SELECTOR
    RETURN			    ; On retourne l� o� la sub est call
    
CLEAR_LEDS_PATTERN_SELECTOR
    MOVLW b'00000000'		   ; On move le Litteral b'00000000' dans le W
    MOVWF LEDS_PATTERN_SELECTOR	   ; On met ce qu'il y a dans le W (donc b'00000000') dans le F LEDS_PATTERN_SELECTOR
    RETURN			   ; On retourne l� o� la sub est call
;************************************************************************ 
; LED PATTERNS
;************************************************************************ 
SHUT_THE_LEDS_OFF
    CALL CLEAR_LEDS_PATTERN_SELECTOR	    ; On clear tous les bits de LEDS_PATTERN_SELECTOR
    CALL LIGHT_OFF_PORTB		    ; On eteint les leds
    RETURN				    ; On retourne l� o� la sub est call
    
BLINK_ALL_LEDS_ONCE
    CALL LIGHT_ON_PORTB			    ; On allume la led
    CALL DELAY_WITH_CHECK_BUTTON	    ; On attend
    CALL LIGHT_OFF_PORTB		    ; On �teint la led
    CALL DELAY_WITH_CHECK_BUTTON	    ; On attend
    RETURN				    ; On retourne l� o� la sub est call
    
SCANNER_EFFECT 
    MOVLW b'10000001'			    ; On move le Litt�ral b'10000001' dans le W
    CALL SCANNER_EFFECT_MOVE_AND_WAIT	    ; On appelle la sub qui move le W dans portb (donc allume les leds correspondantes) et fait un delay
    MOVLW b'01000010'			    ; idem
    CALL SCANNER_EFFECT_MOVE_AND_WAIT	    ; idem
    MOVLW b'00100100'			    ; idem
    CALL SCANNER_EFFECT_MOVE_AND_WAIT	    ; idem
    MOVLW b'00011000'			    ; idem
    CALL SCANNER_EFFECT_MOVE_AND_WAIT	    ; idem
    MOVLW b'00100100'			    ; idem
    CALL SCANNER_EFFECT_MOVE_AND_WAIT	    ; idem
    MOVLW b'01000010'			    ; idem
    CALL SCANNER_EFFECT_MOVE_AND_WAIT	    ; idem
    MOVLW b'10000001'			    ; idem
    CALL SCANNER_EFFECT_MOVE_AND_WAIT	    ; idem
    RETURN				    ; On retourne l� o� la sub est call
    
K2000_EFFECT
    MOVLW b'00000001'			    ; On move le Litt�ral b'00000001' dans le W
    MOVWF PORTB				    ; On met le contenu de W dans F donc dans PORTB
    MOVLW 8				    ; On met le Litteral 8 dans le W
    MOVWF K2000_COUNTDOWN		    ; On met 8 dans la variable countdown
K2000_EFFECT_LOOP_TO_RIGHT		    
    DECFSZ K2000_COUNTDOWN,f		    ; Decr�mente K2000_COUNTDOWN, fait l'instruction suivante tant qu'il n'arrive pas � 0
    CALL K2000_EFFECT_LED_SHIFT_TO_RIGHT    ; fait bouger les leds vers la droite
    MOVLW 8				    ; Met 8 dans W
    MOVWF K2000_COUNTDOWN		    ; met 8 dans K2000_COUNTDOWN
K2000_EFFECT_LOOP_TO_LEFT		    
    DECFSZ K2000_COUNTDOWN,f		    ; Decr�mente K2000_COUNTDOWN, fait l'instruction suivante tant qu'il n'arrive pas � 0
    CALL K2000_EFFECT_LED_SHIFT_TO_LEFT	    ; fait bouger les leds vers la gauche
    RETURN				    ; On retourne l� o� la sub est call
    
K2000_EFFECT_LED_SHIFT_TO_RIGHT		    ;
    CALL DELAY_WITH_CHECK_BUTTON	    ; sub de temporisation avec check du bouton
    RLF PORTB,1				    ; 0001 devient 0010 : op�ration de shift
    GOTO K2000_EFFECT_LOOP_TO_RIGHT	    ; va � la sub qui d�cr�mente, et boucle
K2000_EFFECT_LED_SHIFT_TO_LEFT		    ;
    CALL DELAY_WITH_CHECK_BUTTON	    ; sub de temporisation avec check du bouton
    RRF PORTB,1				    ; 0010 devient 0001
    GOTO K2000_EFFECT_LOOP_TO_LEFT	    ; va � la sub qui d�cr�mente, et boucle
    
PARROT_EFFECT	;A faire!
    RETURN
    
;************************************************************************ 
; PORTB STATE REGISTER MODIFICATIONS
;************************************************************************  
SCANNER_EFFECT_MOVE_AND_WAIT
    MOVWF PORTB				 ; On move ce qu'il y a dans le W dans F donc PORTB
    CALL DELAY_WITH_CHECK_BUTTON	 ; On appelle la sub qui???
    RETURN				 ; On retourne l� o� la sub est call
    
LIGHT_ON_PORTB
    MOVLW b'11111111'			 ; On move le Litt�ral b'11111111' dans W
    MOVWF PORTB				 ; On move ce qu'il y a dans le W dans F donc PORTB
    RETURN				 ; On retourne l� o� la sub est call
    
LIGHT_OFF_PORTB
    MOVLW b'00000000'			 ; On move le Litt�ral b'00000000' dans W
    MOVWF PORTB				 ; On move ce qu'il y a dans le W dans F donc PORTB
    RETURN				 ; On retourne l� o� la sub est call	  
;************************************************************************ 
; DELAYS
;************************************************************************ 
DELAY_WITH_CHECK_BUTTON			    ; Sub qui �coute les boutons quand les leds sont entrain de bouger (multithread simple)
    MOVLW 0x20				    ; On met l'hexa 0x20 dans le W 
    MOVWF NB_BUTTON_CHECK		    ; On met le 0x20 dans la variable NB_BUTTON_CHECK,qui sert comme le i de la boucle for -> 
					    ; for(int NB_BUTTON_CHECK = 0x020 ; NB_BUTTON_CHECK>0 ;NB_BUTTON_CHECK-- )
DELAY_WITH_CHECK_BUTTON_0		    ; loop
    DECFSZ NB_BUTTON_CHECK,f		    ; tant que decfsz arrive � d�cr�menter NB_BUTTON_CHECK, il fait le GOTO, et il fait le return quand il arrive � 0
    GOTO DELAY_WITH_CHECK_BUTTON_CHECK	    ; va � la subroutine
    RETURN				    ; On retourne l� o� la sub est call
DELAY_WITH_CHECK_BUTTON_CHECK
    CALL DELAY				    ; attend
    CALL CHECK_BUTTONS			    ; Ecoute le bouton
    GOTO DELAY_WITH_CHECK_BUTTON_0	    ; retourne au label
    
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