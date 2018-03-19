**********************************************************
*
* This program uses the example from the questions above and only make a minor modification
* Instead of providing user input of what patterns we want to find, I manually input the data instead and checked if the answer is correct or not
* For the previous problem, the pattern at $AA50 point to is FFFF, in which case, it will match the first starting address. Because from $00007000 to $00008000, all the data is F
* So for this problem, I manually inserted a pattern to look for. And also set the pattern to look for within the address range
*
************************************************************
* Equates section
 
            OPT         CRE
test_st     EQU         $00007000     * Start of block to fill
test_end    EQU         $00008000     * Last address to fill
pattern     EQU         $AA50         * Pattern to find
stack       EQU         $000A0000     * Locate the stack if necessary
start       EQU         $400          * Program begins here
exit        EQU         $2700         * Simulator stop code
byte        EQU         1             * Advance by one byte
 
* code section
        	ORG         start
START
            MOVE.B      #%1001, pattern     * Load the actual data pattern to the address. In this case, we want to look for any where that contains 09
            MOVE.B      #%1001, $00007080   * Let's say that at address 00007080 we have a 9. The actual data of the adress stored at (A2) at the end is expected to be 00007080
                                            
      	    LEA         test_st,A0    * Load starting address
           	LEA         test_end,A1   * Load ending address
           	LEA         addr_match,A2 * Address of match saved here
            MOVE.B      pattern,D0   * Store pattern in D0
              
loop        CMP.B       (A0),D0       * Test pattern
            BEQ         match         * They're the same, save it and exit
            ADDQ.L      #byte,A0      * Increment pointer
            CMPA.L      A1,A0         * Are we done yet?
            BGT         no_match      * Past range? Exit
            BRA          loop   * Go back and try again
match       MOVE.L        A0,(A2)         * Save contents of A0 and exit
            STOP        #exit              * Also added this line to exit because in the previous sample code, it will keep going
no_match    MOVE.L      $FFFFFFFF,(A2)    * Added this as requested from the question
            STOP          #exit           * Break out of the simulator
 
* data section
 
addr_match    DC.L         $00000000       * Initialize to no-match value
            END          START






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
