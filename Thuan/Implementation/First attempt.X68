*-----------------------------------------------------------
* Title      : First simple implementation of printing out NOP
* Written by : Thuan Tran
* Date       : Feb 25th,2018
* Description: Load the test program in prototype, testNop. Enter starting and ending address. Expected to print out NOP
*-----------------------------------------------------------

*** A2 will be used as the address in which it will iterate through all the way until ending adrress

STARTING_ADDRESS   EQU    $100 * User input starting address
ENDING_ADDRESS     EQU    $150 * User input ending address
TEMP_VAR           EQU    $200 * Temporary variables to start decode

DESTINATION_VAR    EQU    $250
DESTINATION_MODE   EQU    $300
SOURCE_MODE        EQU    $350
SOURCE_VAR         EQU    $400

SIZE               EQU    $450




SECOND_TEMP_VAR    EQU    $500
THIRD_TEMP_VAR     EQU    $550
FOURTH_TEMP_VAR    EQU    $600
FIFTH_TEMP_VAR     EQU    $650

REGISTER_NUMBER_TO_PRINT EQU $700


    ORG    $1000
START:                  ; first instruction of program

GET_START_ADDRESS
    LEA INTRO_STARTING,A1  * Welcome the user
    MOVE.B  #13,D0         * Nice to have carry and line feed
    TRAP    #15
    MOVE.B  #2,D0          * Get a string input that represent the user
    TRAP    #15
    BRA     CONVERT_ASCII_TO_HEX

GET_END_ADDRESS
    LEA INTRO_ENDING,A1         * Now time to get the ending address
    MOVE.B  #13,D0
    TRAP    #15
    MOVE.B  #2,D0
    TRAP    #15
    BRA     CONVERT_ASCII_TO_HEX

PARSING_OP_CODE * Decode the first four byte. Will go throug each 2 bytes at a time
    MOVE.W      (A2),D3 * Get the first 4 bytes of op code
    MOVE.W      D3, TEMP_VAR
    LSR       #8,D3            * Get the left most byte. 0000XYBC now will get 0000000X
    LSR       #4,D3              * Now shift remaing 4 bit. LSR only allow 1-8 bit shift
    MULU      #6,D3
    JSR        0(A0,D3)

    SIMHALT


PREPARE_START_AND_END_ADDRESS * When finish getting the ending adress, will load data into address regist
    LEA         FIRST_BYTE_JUMP_TABLE,A0
    MOVE.L      STARTING_ADDRESS,A2
    MOVE.L      ENDING_ADDRESS,A3
    BRA         PARSING_OP_CODE * Start parsing the opcode now

FIRST_BYTE_JUMP_TABLE                  * Based on the first byte of the op code then jump on what is possible
    JMP  FIRST_BYTE_IS_0               * ORI, CMPI. BCLR
    JMP  FIRST_BYTE_IS_1               * MOVE.B, MOVEA.B
    JMP  FIRST_BYTE_IS_2               * MOVEA.L, MOVE.L
    JMP  FIRST_BYTE_IS_3               * MOVE.W    MOVEA.W
    JMP  FIRST_BYTE_IS_4               * NOP, LEA, NEG, JSR, RTS
    JMP  FIRST_BYTE_IS_5               * SUBQ
    JMP  FIRST_BYTE_IS_6               * BCS, BGE, BLT, BVC, BRA
    JMP  FIRST_BYTE_IS_7               * NOT SUPPORTED
    JMP  FIRST_BYTE_IS_8               * DIVS, OR
    JMP  FIRST_BYTE_IS_9               * SUB
    JMP  FIRST_BYTE_IS_A               * NOT SUPPORTED
    JMP  FIRST_BYTE_IS_B               * EOR, CMP
    JMP  FIRST_BYTE_IS_C               * MULS
    JMP  FIRST_BYTE_IS_D               * ADD, ADDA
    JMP  FIRST_BYTE_IS_E               * LSR, LSL, ASR, ASL, ROL, ROR
    JMP  FIRST_BYTE_IS_F               * NOT SUPPORTED

REGISTER_MODE_JUMP_TABLE
    JMP REGISTER_MODE_000             * Data register mode Dn
    JMP REGISTER_MODE_001             * ADdress register mode   An
    JMP REGISTER_MODE_010             * Indirect address register mode (An)
    JMP REGISTER_MODE_011             *  Address register with increment (An)+
    JMP REGISTER_MODE_100             * Address register with decrement -(An)
    JMP REGISTER_MODE_101             * Not supported
    JMP REGISTER_MODE_110             * Not supported
    JMP REGISTER_MODE_111             * This could be immediate, absolute short or absolute long



SHORT_OR_LONG_PRINT                     * Will jump to this when the register mode is 111 and not immediate data
    JMP ABSOLUTE_SHORT                  * Xn index for this is 000
    JMP ABSOLUTE_LONG                   * Xn index for this is 001


ABSOLUTE_SHORT     *We need to get the next 4 bytes as the address
    MOVE.W (A2)+,SECOND_TEMP_VAR
    LEA    SECOND_TEMP_VAR,A1 * Load the data for printing
    JSR     PRINT_TO_SCREEN
    CLR.W   SECOND_TEMP_VAR * Reset the variables after displaying
    RTS
    SIMHALT

ABSOLUTE_LONG       * Print the next 8 bytes as the address
    JSR ABSOLUTE_SHORT        * PRinted 4 bytes
    JSR ABSOLUTE_SHORT         * Printed 4 more
    RTS
    SIMHALT

IMMEDIATE_DATA        * No implementation yet. Need to figure how how much byte to get. Can be 4 or 8. Depending on data
    SIMHALT

CONVERT_ASCII_TO_HEX            * ascii table http://www.asciitable.com/
    MOVE.B (A1)+,D0       * Go through each byte of the address
    CMP.B   #$30,D0       * Valid data are from $30 - $39 ( 0-9) and $41 - $46 (A-F)
    BLT.B   ERROR_INVALID_INPUT
    CMP.B   #$39,D0          * check if in the range number of hex character
    BGT.B   CONVERT_CHARACTER_ASCII_TO_HEX
    SUB.B   #$30,D0     * Get the hex range from '0-9'
    ADD.L   D0,D3
    SUBI    #1,D1          * Decrement the counter for length of address
    CMP.B   #0,D1
    BEQ     FINISH_CONVERT_STARTING_ADDRESS
    LSL.L   #4,D3
    BRA     CONVERT_ASCII_TO_HEX

ERROR_INVALID_INPUT
    LEA INVALID_INPUT,A1   * Print out to the user invalid message and stop the program
    MOVE.B  #13,D0         * CAN PRINT THIS EITHER WITH NEW LINE OR NOT> TEMPORARY LEAVE IT THERE
    TRAP    #15
    SIMHALT

CONVERT_CHARACTER_ASCII_TO_HEX
    CMP.B   #$41,D0                        * At this point, the data must be larger than number
    BLT.B   ERROR_INVALID_INPUT            * Only $41 - 46 are valid
    CMP.B   #$46,D0
    BGT.B   ERROR_INVALID_INPUT             * Greater than $46, nope
    SUB.B   #$37,D0                         * Get the A-F value
    ADD.L   D0,D3                           * Save the value
    SUBI    #1,D1                           * Decrement the counter
    CMP.B   #0,D1
    BEQ     FINISH_CONVERT_STARTING_ADDRESS
    LSL.L   #4,D3                           * Shift the value to the left 4 bits to save room for another byte
    BRA     CONVERT_ASCII_TO_HEX

FINISH_CONVERT_STARTING_ADDRESS
    CMP     #1,D2                      * Check if we are doing starting or ending address
    BEQ     FINISH_CONVERT_ENDING_ADDRESS
    ADDI    #1,D2 * Counter to make sure that we are doing the ending address
    MOVE.L  D3,STARTING_ADDRESS
    CLR.L   D3
    BRA     GET_END_ADDRESS

FINISH_CONVERT_ENDING_ADDRESS
    CLR.W   D2       * Clear the second data register for future use
    MOVE.L  D3,ENDING_ADDRESS
    CLR.W   D3
    BRA     PREPARE_START_AND_END_ADDRESS
    SIMHALT

FIRST_BYTE_IS_0             * UNFINISHED IMPLEMENTATION
    MOVE.B  TEMP_VAR,D3
    CMP.B   #$00,D3
    BEQ     SECOND_BYTE_IS_0

FIRST_BYTE_IS_1
    RTS
    SIMHALT
FIRST_BYTE_IS_2
    RTS
    SIMHALT
FIRST_BYTE_IS_3
    RTS
    SIMHALT
FIRST_BYTE_IS_4                 * Possible for NOP,LEA,RTS,JSR,NEG. Now will check the second byte
    MOVE.W  TEMP_VAR,D3         * Get the original op code back
    LSL     #4,D3               * Go to the left 4 bits, make the second byte the left most byte    0000 1234 => 0000 2340
    LSR     #8,D3               * Go back 2 bytes, now on the third most byte 0000 2340 => 0000 0023
    LSR     #4,D3               * Go back 1 bytes, now on the fourth byte    0000 0023 => 0002
    CMP.B   #$E,D3
    BEQ     FIRST_BYTE_4_SECOND_BYTE_E
    CMP.B   #8,D3              * Could be NEG or LEA
    BLT     NEG_OR_LEA
                                * SHOULD ADD MORE CASES TO CHECK FOR INVALID

INVALID                         * UNSUPPORTED OR INVALID INSTRUCTION. PRINT OUT LOCATIO AND DATA
    RTS

NEG_OR_LEA                     * Check the 8-6 bits of NEG and LEA. For NEG, the 8-6 bits are 0S where S is the size. For LEA, it is 111
    MOVE.W  TEMP_VAR,D3
    LSL     #7,D3              * Get rid of 7 left most bit
    LSR     #7,D3              * Return back to the original position
    LSR     #6,D3              * Push them back all the way to the right
    CMP.B   #$07,D3             * INCORRECT IMPLEMENTATION.NEED TO FIX NOW. LEA's second byte depends on data size. Need to check data size
    BEQ     PRINT_LEA          * This is LEA
    BRA     INVALID            * Unrecognized instructions
    RTS



********
* Check type data: Means getting the appropriate source and destination register  and mode
********
CHECK_TYPE_DATA
    MOVE.W TEMP_VAR,D3
    LSL     #4,D3      * Get rid of left most byte
    LSR     #4,D3      * Now focus on the following format      destination mode mode source. Start with destination first
    LSR     #8,D3      * Now the D3 has the destination
    LSR     #1,D3
    MOVE.W  D3,DESTINATION_VAR
    MOVE.W  TEMP_VAR,D3 * Now go with the destination mode
    LSL     #7,D3
    LSR     #7,D3
    LSR     #6,D3
    MOVE.W  D3,DESTINATION_MODE
    MOVE.W  TEMP_VAR,D3       * Now extract the source mode
    LSL     #8,D3
    LSL     #2,D3
    LSR     #8,D3
    LSR     #2,D3
    LSR     #3,D3
    MOVE.W  D3,SOURCE_MODE      * Now extract the source
    MOVE.W  TEMP_VAR,D3
    LSL     #8,D3
    LSL     #5,D3
    LSR     #8,D3
    LSR     #5,D3
    MOVE.W  D3,SOURCE_VAR
    RTS

PRINT_LEA
    JSR CHECK_TYPE_DATA * Check what type of data we are dealing with and whether we need to out more to fetch data

    CMP #$0,SOURCE_MODE
    JSR PRINT_DATA_MODE
    JSR PRINT_COMMA


PRINT_TO_SCREEN         * Simple utility method that take whatever in A1 and print out
    MOVE.B  #14,D0
    TRAP    #15
    RTS

PRINT_DATA_MODE         * Depnding on the mode, will print out appropriate data mode: Dn,An,(An),... 
    LEA     REGISTER_MODE_JUMP_TABLE,A3
    MOVE    SOURCE_MODE,D3
    MULU    #6,D3
    JSR     0(A3,D3)       * Let's see what mode is this source mode
    RTS


PRINT_COMMA *Print the comma to separate between source and destination
    LEA     COMMA,A1
    JSR     PRINT_TO_SCREEN
    RTS

PRINT_A
    LEA   ADDRESS_REGISTER,A1
    JSR   PRINT_TO_SCREEN
    RTS

PRINT_D
    LEA    DATA_REGISTER,A1
    JSR    PRINT_TO_SCREEN
    RTS

PRINT_OPEN_BRACKET
    LEA   OPENING_BRACKET,A1
    JSR   PRINT_TO_SCREEN
    RTS

PRINT_CLOSE_BRACKET
    LEA  CLOSING_BRACKET,A1
    JSR  PRINT_TO_SCREEN
    RTS

PRINT_PLUS_SIGN
    LEA  PLUS_SIGN,A1
    JSR  PRINT_TO_SCREEN
    RTS

PRINT_MINUS_SIGN
    LEA  MINUS_SIGN,A1
    JSR  PRINT_TO_SCREEN
    RTS

















FIRST_BYTE_IS_5
    RTS
    SIMHALT
FIRST_BYTE_IS_6
    RTS
    SIMHALT
FIRST_BYTE_IS_7
    RTS
    SIMHALT
FIRST_BYTE_IS_8
    RTS
    SIMHALT
FIRST_BYTE_IS_9
    RTS
    SIMHALT
FIRST_BYTE_IS_A
    RTS
    SIMHALT
FIRST_BYTE_IS_B
    RTS
    SIMHALT
FIRST_BYTE_IS_C
    RTS
    SIMHALT
FIRST_BYTE_IS_D
    RTS
    SIMHALT
FIRST_BYTE_IS_E
    RTS
    SIMHALT
FIRST_BYTE_IS_F
    RTS
    SIMHALT


FIRST_BYTE_4_SECOND_BYTE_E        * Possible answer are NOP,JSR and RTS
    MOVE.W  TEMP_VAR,D3       * Get the op code
    LSL     #8,D3             * Shift to the left to dissappear 2 left most byte
    LSR     #8,D3             * Shift to the right to gain back original position. Only now the 2 left most byte are gone
    CMP.B   #$71,D3           * NOP is 4E71
    BEQ     PRINT_OUT_NOP
    CMP.B   #$75,D3           *RTS is 4E75
    BEQ     PRINT_OUT_RTS






SECOND_BYTE_IS_0 * Possible to be ORI. In the case first byte is 0 as well
    MOVE.B  (A2)+,D3
    CMP.B   #$7C,D3            * Only ORI to SR have the last 2 bytes in op code as 7C
    BRA     PRINT_OUT_ORI_TO_SR

FINISH_ONE_INSTRUCTION
    ADD #2,A2 *Move to the next instruction
    BRA PARSING_OP_CODE

SECOND_BYTE_IS_E  * Possible to be NOP and RTS. In the case the first byte is 4
    MOVE.B  (A2)+,D3   * Get the remaning 2 bytes
    CMP     #$71,D3
    BEQ     PRINT_OUT_NOP
    CMP     #$75,D3
    BEQ     PRINT_OUT_RTS

PRINT_OUT_NOP
    LEA     NOP_VALUE,A1 * Display the NOP message
    MOVE.B  #13,D0
    TRAP    #15
    BSR     USER_INPUT_ENTER
    BRA     FINISH_ONE_INSTRUCTION
    SIMHALT             ; halt simulator

PRINT_OUT_RTS
    LEA     RTS_VALUE,A1
    MOVE.B  #13,D0
    TRAP    #15
    BSR USER_INPUT_ENTER
    BRA FINISH_ONE_INSTRUCTION
    SIMHALT

PRINT_OUT_ORI_TO_SR
    LEA     ORI_VALUE,A1
    JSR     PRINT_TO_SCREEN
    RTS



USER_INPUT_ENTER  * Wait for the user to press enter to continue
    MOVE.B  #4,D0
    TRAP #15
    RTS


PRINT_REGISTER_NUMBER           * This is used to print the register number Dn or An where it will print n
    LEA  SECOND_TEMP_VAR,A1
    JSR  PRINT_TO_SCREEN
    RTS


REGISTER_MODE_000   * Print out data register Dn
    JSR     PRINT_D
    JSR     PRINT_REGISTER_NUMBER
    RTS






REGISTER_MODE_001       * An
    JSR     PRINT_A
    JSR     PRINT_REGISTER_NUMBER
    RTS
REGISTER_MODE_010         * (An)
    JSR     PRINT_OPEN_BRACKET
    JSR     REGISTER_MODE_001
    JSR     PRINT_CLOSE_BRACKET
    RTS
REGISTER_MODE_011        *(An)+
    JSR REGISTER_MODE_010
    JSR PRINT_PLUS_SIGN
    RTS


REGISTER_MODE_100    * -(An)
    JSR PRINT_MINUS_SIGN
    JSR REGISTER_MODE_010
    RTS
REGISTER_MODE_101 * Not supported yet. Will deal later
    RTS
REGISTER_MODE_110 * Not supported. Will deal later
    RTS
REGISTER_MODE_111  * Immediate data, absolute long or absolute short
    LEA SHORT_OR_LONG_PRINT,A4 * Prepare the table to print out the data
    CMP #4, THIRD_TEMP_VAR      * Check if it is immediate data or Not
    BEQ     IMMEDIATE_DATA        * This is immediate data, need to have specific check
    MULU #6,THIRD_TEMP_VAR        * Use THIRD_TEMP_VAR as a place holder for the data we want to print out for register mode 111.
                                  * In the code before this, we need to move the appropriate data into this address. Either the destination or the source
                                *   REMEMBER TO IMPLEMENT This

    JSR  0(A4,THIRD_TEMP_VAR)     * Print out the appropriate long or short value
    RTS











* Put variables and constants here

INTRO_STARTING   DC.W   'Welcome to the Disassembler. Please enter starting address',0
INTRO_ENDING     DC.W   'Please enter ending address',0
INVALID_INPUT    DC.W   'INVALID ADDRESS ENTERED. PLEASE ONLY ENTER 0 - 9 AND A-F',0
NOP_VALUE        DC.W   'NOP',0
RTS_VALUE        DC.W   'RTS',0
ORI_VALUE        DC.W   'ORI',0
SR_VALUE         DC.W   'SR',0
CCR_VALUE        DC.W   'CCR',0
OPENING_BRACKET  DC.W   '(',0
CLOSING_BRACKET  DC.W   ')',0
PLUS_SIGN        DC.W   '+',0
MINUS_SIGN       DC.W   '-',0
DATA_REGISTER    DC.W   'D',0
COMMA            DC.W   ',',0
NOP             EQU      $4E71










    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
