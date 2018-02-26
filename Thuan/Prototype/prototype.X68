*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:           
    MOVE.W $7000,D1              * Move what ever in 7000 to D1
    CMP.W   #$4E71,D1            * Check to see if it is NOP or not
    BEQ     PRINT                
    
    
    
PRINT
    LEA   MESSAGE,A1              * It is NOP
    MOVE.W   #14,D0                 * PRINT
    TRAP #15
           

    SIMHALT             
MESSAGE    DC.W   'NOP',0


    END    START        


*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
