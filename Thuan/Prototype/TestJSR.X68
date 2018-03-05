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

    MULU #3,D0
   MULU $00001234,D5
   MULU.W $FFFF1100, D6
    MULS #45,D1
    MULS $00001234,D7
    MULS $FFFF1000, D2
    
    SIMHALT             ; halt simulator

TEST
    MOVE.W     #4,D0
* Put variables and constants here

    END    START        ; last line of source



































*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
