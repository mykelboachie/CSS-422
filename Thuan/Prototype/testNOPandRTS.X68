*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program

* Put program code here
    NOP
    RTS
    NEG.L         $00511234         
    JSR         $00123658
    LEA         $00001234, A5
    CMPI.L    #5, D0
    CMPI.L        #112345, $00001234
    CMPI.B          #3,D1
    CMPI.W          #5, $FFFF1234
    SUBQ        #1, D3
    SUBQ.B      #8, $11112345
     SUBQ.L      #1, $00001234
    DIVS.W         $00001234,D0
    DIVS.W          $1200, D5
    DIVS.W         $FFFF3658,D2 
        SUB.B     D5,D4
    SUB.W     D5,D4
   SUB.L     D5,D4
    SUB.L     D1,$00001234
    SUB.L     $00001234,D1
    SUB.L     D1, $FFFF1234
    SUB.L       $FFFF1234,D1
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source























*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
