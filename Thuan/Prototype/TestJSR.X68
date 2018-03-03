*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
SAD         EQU          $00007324
    ORG    $7000
START:                  ; first instruction of program

* Put program code here

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
