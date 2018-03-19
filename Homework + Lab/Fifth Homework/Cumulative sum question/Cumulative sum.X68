*-----------------------------------------------------------
* Title      : Cumulative sum program
* Written by : Thuan Tran
* Date       : Feb 19th, 2018
* Description: This program takes in a decimal by the user and add 512 multiple times in which the times equal the user input
* P.S: Assumes valid input 
*-----------------------------------------------------------
    ORG    $1000
   
START:                  ; first instruction of program

* Put program code here
    
        LEA     MESSAGE,A1        * Display the message for user
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  #4,D0              * Get the input from user
        TRAP    #15 
        MOVE.L  #512, D5
    
LOOP    
        CMP.L     D4,D1           * Check if we reach the limit of the counter
        BEQ       FINISH     
        MOVE.L      D2,D3           * Save the value in case the carry bit is set
        ADD.L    D5,D2         * Add 512 to the result we already have
        BCS.L       CARRY_SET          * Check if carry bit is set
        ADDQ      #1,D4           * Increment the number of time we have looped
      
              
        BRA       LOOP
        

CARRY_SET
        LEA     CARRY_MESSAGE,A1   * Display message letting user know that the carry bit was set
        MOVE.B  #14,D0       
        TRAP    #15
        MOVE.L  D3,D1              * Print out the value before the carry bit is set
        MOVEQ   #15,D0
        MOVEQ   #10,D2
        TRAP    #15
        SIMHALT
        


FINISH
        MOVE.L  D2,D1               * Load the data that make the carry bit is set 
        MOVEQ  #15,D0              * Specify that task that will be used to printout the data 
        MOVEQ  #10,D2               * We want to see the number in base 10
        TRAP    #15
                                    * If the carry flag is set, it will print out 0 instead 
        SIMHALT
            
    SIMHALT             ; halt simulator

* Put variables and constants here

MESSAGE         DC.B    'WELCOME TO THE PROGRAM. PLEASE INPUT A POSITIVE DECIMAL NUMBER',CR,LF,0
CARRY_MESSAGE   DC.B    'THE RESULT HAS A CARRY BIT.HERE IS THE VALUE BEFORE THE CARRY BIT WAS SET',CR,LF,0


CR              EQU     $0D
LF              EQU     $0A
    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
