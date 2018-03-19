*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
CR      EQU     $0D
LF      EQU     $0A


    ORG    $1000
START:                  ; first instruction of program

* Put program code here
LOOP    LEA     ASKUSER,A1  ; print out the question for user 
        MOVE.B  #14,D0
        TRAP    #15
  
        MOVE.B  #4,D0    ; read input from user
        TRAP    #15
        
        CMP.L   #-1,D1  ;check if user enter -1 or not
        BEQ     DONE
        
        CMP.B   #25,D1   ; check if user entered a number greater than 25
        BGT     INVALID
        
        CMP.B   #20,D1
        BLT     INVALID
        
        BRA     LOOP
  
INVALID 
        LEA     INVALIDMESSAGE,A1
        MOVE.B  #14,D0
        TRAP    #15  
        BRA     LOOP


DONE    
        LEA     LYRIC,A1
        MOVE.B  #14,D0
        TRAP    #15
        SIMHALT             ; halt simulator
* Put variables and constants here


ASKUSER DC.B    'Enter a number between 20 and 25 inclusive, -1 to exit',CR,LF,0

MESSAGE DC.B    'FALL OUT BOY',CR,LF
        DC.B    'CRACKING OPEN A COLD ONE WITH THE BOIS',CR,LF,CR,LF
        DC.B    'THIS IS A FAKE LYRIC FOR A FAKE SONG',CR,LF,CR,LF
        DC.B    'THANK YOU FOR LISTENING',CR,LF,0

INVALIDMESSAGE   DC.B    'YOU HAVE ENTERED AN INVALID NUMBER. NEED TO BE WITHIN [20,25]',CR,LF,0

LYRIC   DC.B     'CRACKING OPEN A COLD ONE WITH THE BOIS',CR,LF,0

QUESTION    DC.B    'DO YOU LIKE THIS SONG ?',CR,LF,0
        
    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
