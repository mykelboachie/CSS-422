*-----------------------------------------------------------
* Title      : First simple implementation of printing out NOP
* Written by : Thuan Tran
* Date       : Feb 25th,2018
* Description: Load the test program in prototype, testNop. Enter starting and ending address. Expected to print out NOP
*-----------------------------------------------------------

*** A2 will be used as the address in which it will iterate through all the way until ending adrress

STARTING_ADDRESS   EQU    $100 * User input starting address
ENDING_ADDRESS     EQU    $200 * User input ending address
TEMP_VAR           EQU    $300 * Temporary variables to start decode

DESTINATION_VAR    EQU    $400
DESTINATION_MODE   EQU    $500
SOURCE_MODE        EQU    $600
SOURCE_VAR         EQU    $700

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

FIRST_BYTE_JUMP_TABLE
    JMP  FIRST_BYTE_IS_0
    JMP  FIRST_BYTE_IS_1
    JMP  FIRST_BYTE_IS_2
    JMP  FIRST_BYTE_IS_3
    JMP  FIRST_BYTE_IS_4
    JMP  FIRST_BYTE_IS_5
    JMP  FIRST_BYTE_IS_6
    JMP  FIRST_BYTE_IS_7
    JMP  FIRST_BYTE_IS_8
    JMP  FIRST_BYTE_IS_9
    JMP  FIRST_BYTE_IS_A
    JMP  FIRST_BYTE_IS_B
    JMP  FIRST_BYTE_IS_C
    JMP  FIRST_BYTE_IS_D
    JMP  FIRST_BYTE_IS_E
    JMP  FIRST_BYTE_IS_F

REGISTER_MODE_JUMP_TABLE
    JMP REGISTER_MODE_000             * Data register mode
    JMP REGISTER_MODE_001             * ADdress register mode
    JMP REGISTER_MODE_010
    JMP REGISTER_MODE_011
    JMP REGISTER_MODE_100
    JMP REGISTER_MODE_101
    JMP REGISTER_MODE_110
    JMP REGISTER_MODE_111









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
    MOVE.B  #13,D0
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

FIRST_BYTE_IS_0
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

INVALID

NEG_OR_LEA                     * Check the 8-6 bits of NEG and LEA. For NEG, the 8-6 bits are 0S where S is the size. For LEA, it is 111
    MOVE.W  TEMP_VAR,D3
    LSL     #7,D3              * Get rid of 7 left most bit
    LSR     #7,D3              * Return back to the original position
    LSR     #6,D3              * Push them back all the way to the right
    CMP.B   #$07,D3
    BEQ     PRINT_LEA          * This is LEA

    BRA     INVALID            * Unrecognized instructions





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



PRINT_DATA_MODE
    LEA     REGISTER_MODE_JUMP_TABLE,A3
    MOVE    SOURCE_MODE,D3
    MULU    #6,D3
    JSR     0(A3,D3)       * Let's see what mode is this source mode


PRINT_COMMA *Print the comma to separate between source and destination
    LEA     COMMA,A1
    MOVE.B  #14,D0
    TRAP #15
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
    MOVE.B  #14,D0
    TRAP    #15



USER_INPUT_ENTER  * Wait for the user to press enter to continue
    MOVE.B  #4,D0
    TRAP #15
    RTS





REGISTER_MODE_000
    LEA





REGISTER_MODE_001
REGISTER_MODE_010
REGISTER_MODE_011
REGISTER_MODE_100
REGISTER_MODE_101
REGISTER_MODE_110
REGISTER_MODE_111











* Put variables and constants here

INTRO_STARTING   DC.W   'Welcome to the Disassembler. Please enter starting address',0
INTRO_ENDING     DC.W   'Please enter ending address',0
INVALID_INPUT    DC.W   'INVALID ADDRESS ENTERED. PLEASE ONLY ENTER 0 - 9 AND A-F',0
NOP_VALUE        DC.W   'NOP',0
RTS_VALUE        DC.W   'RTS',0
ORI_VALUE        DC.W   'ORI',0
SR_VALUE         DC.W   'SR',0
CCR_VALUE        DC.W   'CCR',0
DATA_REGISTER    DC.W   'D',0
COMMA            DC.W   ',',0
NOP             EQU      $4E71










    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
