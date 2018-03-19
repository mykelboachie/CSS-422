*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    MOVE.W             #3,D3
    MOVE.W             #3,D4
    CMP                 D3,D4
    BEQ                PRINT_EQUAL    
    SIMHALT             ; halt simulator

* Put variables and constants here

PRINT_EQUAL
    LEA EQUAL,A1
    MOVE.B #14,D0
    TRAP #15 
    SIMHALT 


EQUAL   DC.W      'Equal',0


    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
