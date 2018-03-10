*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
SAD         EQU          $00007324





    ORG    $7000
START:                  ; first instruction of program

*Put program code here
    OR     D0,D1
    OR.B  $FFFF1234,D5
    OR.B   $00001234,D6
    RESET
    ADDI   #5,D5
    OR.W     $1234,D7
    OR.L      $1234,D1
    OR.W    (A1),D1
    OR.L    -(A2),D3
    OR.B    (A2)+,D5
    
    SIMHALT             ; halt simulator

TEST
    MOVE.W     #4,D0
* Put variables and constants here

    END    START        ; last line of source

















































*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
