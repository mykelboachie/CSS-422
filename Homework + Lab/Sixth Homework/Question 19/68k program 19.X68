*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    MOVE.W             #0,D3           * Counter
    MOVE.W             #1,D4           * Output
    BRA                 PRINT_OUT
    SIMHALT             ; halt simulator

* Put variables and constants here
PRINT_OUT
    CMP       #11,D3      * Check if we have looped 11 times 
    BEQ       FINISH
    MOVE.W    #15,D0      * Prepare trap task
    MOVE.W    D4,D1       * Prepare output
    MOVE.B    #10,D2      * Print in base 10
    TRAP      #15
    MULU      #2,D4       * Update the number
    ADDQ      #1,D3       * Increment counter
    LEA       EMPTY,A1
    MOVE.W    #13,D0
    TRAP      #15
    BRA       PRINT_OUT    
FINISH
    SIMHALT
         


EMPTY     DC.W       '',0  
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
