*-----------------------------------------------------------
* Title      : Most significant bit
* Written by : Thuan Tran
* Date       : Feb 23rd, 2018
* Description: Given a hex number, print out its most significant bit 
*-----------------------------------------------------------
DATA     EQU        $FE631200  * An input to the program. Range from $00000000 to $FFFFFFFF

    ORG    $1000

START:                  ; first instruction of program

* Put program code here
    MOVE.L      #DATA, $00004232
    LEA         $0004232,A1
    
LOOP   
    CMPI        #4,D1   * Check to see if we have go through all the bytes (4 bytes - 32 bits)
    
    BEQ         NO_SIGNIFICANT
    BRA         LOOP2
  
LOOP2
    MOVE.B     (A1,D1.L),D2  * Go through each byte, starting from the left
   
     ADDI       #1,D1      * The increment counter 
    CMP         #0,D2            * Check to see the bytes on the left is 0
    BEQ         LOOP      * If it is the most significant bit will be more to the right
     
    MOVE.B      D2,D3      * Save the old data in D2, and let D3 do all te work
    LSR         #4,D3    * Shift 4 bits or a nibble to the right
    CMP.B       #0,D3     * Check if the new result is 0. because here, D3 can be 0E, which is 0000 0011. The most significant bit should be 3 in this case
    BEQ      FINISH      *
    MOVE.B       D3,D1     * Get the new data, the most significant bit 
    BRA       PRINT_OUT 
   
    
    
FINISH
    MOVE.B      D2,D1       * in this case ,we move the old data to print out
    BRA PRINT_OUT
  
NO_SIGNIFICANT
    MOVE.B      0,D1            * Print out 0 as there is no significant 
    BRA PRINT_OUT  
PRINT_OUT
    MOVEQ   #15,D0         * Print out in decimal form
    MOVEQ   #10,D2
    TRAP     #15
    SIMHALT
  

    SIMHALT             ; halt simulator

* Put variables and constants here
   
    
    
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
