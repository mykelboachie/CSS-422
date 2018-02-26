*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program

* Put program code here
    NOP                 * At address 7000, run NOP. Expected to load the data into the other program and print out NOP
    RTS
    ORI #3,D0
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
