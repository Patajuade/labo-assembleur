# Documentation
## Description d'une routine pour un bouton (avec gestion du rebond)

```asm
CHECK_RA0		
    BTFSS PORTA,RA0	
    RETURN		
    BTFSC PORTB,RB0
    GOTO LED_OFF
LED_ON
    BTFSC PORTA,RA0	
    GOTO LED_ON
    BSF PORTB,RB0
    RETURN
LED_OFF
    BTFSC PORTA,RA0
    GOTO LED_OFF
    BCF PORTB,RB0
    RETURN
```

### LED allumée

0. Le but est de check si le bouton est appuyé. Si il ne l'est pas on sort de la subroutine. Sinon si il est appuyé on saute la ligne `RETURN`. 
1. Pour savoir si on allume ou si on éteint la led, il faut connaître son état. Si elle est allumée, alors son état est 1. On skip donc la première instruction qui suit `BTFSC PORTB,RB0`. On entre dans la zone `LED_OFF`.
2. Nouveau check de `RA0`. Ce check a pour but de piéger l'exécution du code dans une boucle tant que le bouton est appuyé. Lorsqu'il ne l'est plus, on skip alors `GOTO LED_OFF`
3. `BCF PORTB,RB0`, on éteint la led.
4. On continue d'exécuter le code qui a `CALL CHECK_RA0` 