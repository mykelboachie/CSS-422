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
   
    MOVE    $0F3(A3),D3
    TRAPV
    ADDI   #5,D5
    OR.W     $1234,D0
    RTR    
    OR.L      $1234,D1
    MOVE    $0F3(A3),D3
    MOVE    $0F3(A3),D3
    OR.W    (A1),D1
    OR.L    -(A2),D3
    MOVE    D3,$0F3(A3)
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
