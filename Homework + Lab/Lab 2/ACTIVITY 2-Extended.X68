*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    LEA MESSAGE,A1  ; print out the artist and song info
    MOVE.B #14,D0
    TRAP #15
    
    LEA QUESTION,A1 ; ask user if user like this song or not
    TRAP #15
    
    MOVE.B #2,D0    ; read input from user
    TRAP #15
    
    MOVE.B #14,D0  ; print out the input from the user
    TRAP #15
    
    SIMHALT             ; halt simulator

* Put variables and constants here
CR      EQU     $0D
LF      EQU     $0A
MESSAGE DC.B    'FALL OUT BOY',CR,LF
        DC.B    'CRACKING OPEN A COLD ONE WITH THE BOIS',CR,LF,CR,LF
        DC.B    'THIS IS A FAKE LYRIC FOR A FAKE SONG',CR,LF,CR,LF
        DC.B    'THANK YOU FOR LISTENING',CR,LF,0
QUESTION    DC.B    'DO YOU LIKE THIS SONG ?',CR,LF,0
        
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
