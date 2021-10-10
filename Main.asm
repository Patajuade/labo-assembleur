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
    #DEFINE led1_ON b'00000010'
    #DEFINE led1_OFF b'00000000'
    #DEFINE Button_RB1_PRESSED  b'00000000'
    #DEFINE Button_RB1_RELEASED b'00000001'
    
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
    myPortB    equ    0x06 ;Definit l'addresse du portB
    myPortA    equ    0x05 ;Definit l'addresse du portA
    ORG 0x000 ; vecteur reset
;************************************************************************
 
start
    
;************************************************************************   
;Initialisation PortB  
    BCF STATUS, RP0 ;on clear le bit b dans f
    CLRF PORTB ; initialise portB avec un clear des outputs
    BSF STATUS, RP0 ; Select Bank 1    
; Partie qui dit que RB7 à RB0 sont des outputs
    MOVLW 0x00 ;0x00 = output
    MOVWF TRISB

;Initalisation PortA	p15 et/ou 39
    BCF STATUS, RP0 ;
    CLRF PORTA ; initialise portB avec un clear des outputs
    BSF STATUS, RP0 ; Select Bank 1 
;Partie qui dit que RA1 est un input
    MOVLW 0x01 ;0x01 = input
    MOVWF TRISA ;on met 1 dans trisA : input
    
;************************************************************************
;************************************************************************ 
MAIN
    call sub_led1_on
    call sub_led1_off
    goto MAIN
    
sub_led1_on
    movlw led1_ON    ; move led1_ON dans W
    movwf myPortB        ; move W dans f (ça bouge ce qu'y a dans w dans portB)
    call Delay
    return
    
sub_led1_off
    movlw led1_OFF ; move led1_OFF dans w
    movwf myPortB        ; move W dans f (ça bouge ce qu'y a dans w dans portB)
    call Delay
    return
    
;---------------- 1s Delay -----------------------------------
	cblock
	d1
	d2
	d3
	endc

Delay
			;499994 cycles
	movlw	0x03
	movwf	d1
	movlw	0x18
	movwf	d2
	movlw	0x02
	movwf	d3
Delay_0
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	$+2
	decfsz	d3, f
	goto	Delay_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return
    
end