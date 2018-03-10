*-----------------------------------------------------------
* Title      : First simple implementation of printing out NOP
* Written by : Thuan Tran
* Date       : Feb 25th,2018
* Description: Load the test program in prototype, testNop. Enter starting and ending address. Expected to print out NOP
*-----------------------------------------------------------

*** A2 will be used as the address in which it will iterate through all the way until ending adrress

STARTING_ADDRESS            EQU    $100 * User input starting address
ENDING_ADDRESS              EQU    $150 * User input ending address
TEMP_CURRENT_4_NIBBLES      EQU    $200 * Temporary variables to start decode
DESTINATION_VAR             EQU    $250 * Used to hold the Address number
DESTINATION_MODE            EQU    $300 * Used to hold the mode of destination
SOURCE_MODE                 EQU    $350 * used to hold the mode of the source
SOURCE_VAR                  EQU    $400 * Used to hold the address number of source
SIZE                        EQU    $450 * Used to hold the size: 00,01 or 10 stuff
SECOND_TEMP_VAR             EQU    $500 * Can either be used to hold source var or destination var for print out
THIRD_TEMP_VAR              EQU    $550
FOURTH_TEMP_VAR             EQU    $600
FIFTH_TEMP_VAR              EQU    $650
REGISTER_NUMBER_TO_PRINT    EQU    $700
TEMP_CURRENT_2_NIBBLES      EQU    $750

    ORG    $1000
START:                  ; first instruction of program


*************************
* Input and parsing op code section
*************************

GET_START_ADDRESS
    LEA INTRO_STARTING,A1  * Welcome the user
    MOVE.B  #13,D0         * Nice to have carry and line feed
    TRAP    #15

    MOVEA.L   #0,A1         * Clear what is in A1
    LEA FIFTH_TEMP_VAR,A1
    CLR     D0
    CLR     D1
    MOVE.B  #2,D0          * Get a string input that represent the user
    TRAP    #15

    BRA     CONVERT_ASCII_TO_HEX

CHECK_VALID_ADDRESS



GET_END_ADDRESS
    LEA INTRO_ENDING,A1         * Now time to get the ending address
    MOVE.B  #13,D0
    TRAP    #15

    LEA     FOURTH_TEMP_VAR,A1
    MOVE.B  #2,D0
    TRAP    #15

    BRA     CONVERT_ASCII_TO_HEX


PARSING_OP_CODE * Decode the first four byte. Will go throug each 2 bytes at a time
    JSR       PRINT_ADDRESS_LOCATION
    JSR       GET_NEXT_FOUR_NIBBLE
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR       GET_THE_FIRST_NIBBLE

    MULU      #6,D3
    JSR       0(A0,D3)          * Jump to the table depemding on first nibble
    SIMHALT


CONVERT_ASCII_TO_HEX            * ascii table http://www.asciitable.com/
    MOVE.B (A1)+,D0       * Go through each byte of the address
    CMP.B   #$30,D0       * Valid data are from $30 - $39 ( 0-9) and $41 - $46 (A-F)
    BLT    ERROR_INVALID_INPUT
    CMP.B   #$39,D0          * check if in the range number of hex character
    BGT    CONVERT_CHARACTER_ASCII_TO_HEX
    SUB.B   #$30,D0     * Get the hex range from '0-9'
    ADD.L   D0,D3
    SUBI    #1,D1          * Decrement the counter for length of address
    CMP.B   #0,D1
    BEQ     FINISH_CONVERT_STARTING_ADDRESS
    LSL.L   #4,D3
    BRA     CONVERT_ASCII_TO_HEX

CONVERT_CHARACTER_ASCII_TO_HEX
    CMP.B   #$41,D0                        * At this point, the data must be larger than number
    BLT     ERROR_INVALID_INPUT            * Only $41 - 46 are valid
    CMP.B   #$46,D0
    BGT     ERROR_INVALID_INPUT             * Greater than $46, nope
    SUB.B   #$37,D0                         * Get the A-F value
    ADD.L   D0,D3                           * Save the value
    SUBI    #1,D1                           * Decrement the counter
    CMP.B   #0,D1
    BEQ     FINISH_CONVERT_STARTING_ADDRESS
    LSL.L   #4,D3                           * Shift the value to the left 4 bits to save room for another byte
    BRA     CONVERT_ASCII_TO_HEX


CONVERT_HEX_TO_ASCII                       * Usually call when printing out address in memory to console
                                           * Convert 4 nibblees (2 bytes at a time). Each 1 nibble
                                           * Variables: TEMP_CURRENT_4_NIBBLES
               * Reset the index that is used to jump table
    LEA      HEX_CHARACTER_JUMP_TABLE,A4            * Load the table to print out ascii charracter
    MOVE.W   TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_FIRST_NIBBLE * Get the left most hex value and convert
    MULU    #6,D3
    JSR     0(A4,D3)
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_SECOND_NIBBLE
    MULU    #6,D3
    JSR     0(A4,D3)
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_THIRD_NIBBLE
    MULU    #6,D3
    JSR     0(A4,D3)
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_FOURTH_NIBBLE
    MULU    #6,D3
    JSR     0(A4,D3)
    CLR.W   D3
    RTS



PREPARE_START_AND_END_ADDRESS * When finish getting the ending adress, will load data into address regist
    LEA         FIRST_NIBBLE_JUMP_TABLE,A0
    MOVE.L      STARTING_ADDRESS,A2
    MOVE.L      ENDING_ADDRESS,A3
    BRA         PARSING_OP_CODE * Start parsing the opcode now

FINISH_CONVERT_STARTING_ADDRESS
    BTST    #0,D3 * The the last bit of the address to see if it is even or odd
    BNE     INVALID_STARTING_ADDRESS
    CMP     #1,D2                      * Check if we are doing starting or ending address
    BEQ     FINISH_CONVERT_ENDING_ADDRESS
    ADDI    #1,D2 * Counter to make sure that we are doing the ending address
    MOVE.L  D3,STARTING_ADDRESS
    BRA     GET_END_ADDRESS

FINISH_CONVERT_ENDING_ADDRESS
    BTST    #0,D3        * Check for odd address
    BNE     INVALID_ENDING_ADDRESS
    CMP     STARTING_ADDRESS, D3       * Check if the ending address is less than or equal starting address
    BGE     INVALID_ENDING_ADDRESS
    CLR.W   D2       * Clear the second data register for future use
    MOVE.L  D3,ENDING_ADDRESS
    CLR.W   D3
    LEA     SPACE,A1
    MOVE.B  #13,D0
    TRAP    #15
    BRA     PREPARE_START_AND_END_ADDRESS
    SIMHALT

INVALID_STARTING_ADDRESS
    MOVEA.L   #0,A1
    LEA INVALID_INPUT,A1
    MOVE.B #13,D0
    TRAP #15
    BRA GET_START_ADDRESS

INVALID_ENDING_ADDRESS
    MOVEA.L   #0,A1
    LEA INVALID_INPUT,A1
    MOVE.B #13,D0
    TRAP #15
    BRA GET_END_ADDRESS

USER_INPUT_ENTER  * Wait for the user to press enter to continue
    MOVE.B  #5,D0
    TRAP #15
    RTS


*************************************************
* Print to console section
*************************************************







* Could be used to detect non aligned starting address and ending address
ERROR_INVALID_INPUT
    CMP #1,D2
    BEQ INVALID_ENDING_ADDRESS
    BRA INVALID_STARTING_ADDRESS

INVALID                         * UNSUPPORTED OR INVALID INSTRUCTION. PRINT OUT LOCATIO AND DATA
    CMP #1,D7
    BEQ PARSING_OP_CODE              * Used this to not print out instructions but to proceed
    LEA DATA_VALUE,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_HEX_SYMBOL
    JSR CONVERT_HEX_TO_ASCII * Print out the op code that was not decoded
    LEA  SPACE,A1 * Go to new line
    MOVE.B #13,D0
    TRAP #15
    MOVE #1,D7 * 1 signify that we are currently in the process of processing invalid op code.
    BRA PARSING_OP_CODE



RESET_INVALID_COUNTER
    MOVE      #0, D7                   * Reset the counter, 0 means now the instruction is valid
    RTS

PRINT_OUT_NEG                     * Check the 8-6 bits of NEG and LEA. For NEG, the 8-6 bits are 0S where S is the size. For LEA, it is 111
    JSR     RESET_INVALID_COUNTER
    LEA      NEG_VALUE,A1            * Print NEG to screen
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    JSR     PRINT_NORMAL_SUFFIX
                                            * Now print the source mode and data mode
    JSR     CHECK_TYPE_DATA             * Extract the mode and register
    JSR     PRINT_DATA_MODE_SOURCE
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    RTS

PRINT_OUT_NOP
    JSR     RESET_INVALID_COUNTER
    LEA     NOP_VALUE,A1 * Display the NOP message
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    SIMHALT             ; halt simulator

PRINT_OUT_RTS
    JSR     RESET_INVALID_COUNTER
    LEA     RTS_VALUE,A1
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    SIMHALT

PRINT_OUT_ORI_TO_SR
    JSR     RESET_INVALID_COUNTER
    LEA     ORI_VALUE,A1
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    RTS

PRINT_OUT_JSR
    JSR     RESET_INVALID_COUNTER
    LEA      JSR_VALUE,A1
    JSR      PRINT_TO_SCREEN_ENTIRE_STRING * Now query what type of data to print out, source or destination
    JSR      PRINT_EMPTY_SPACE
    JSR     CHECK_TYPE_DATA
    JSR     PRINT_DATA_MODE_SOURCE          * Print the M and N of the last 6 bits
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE



PRINT_OUT_CMPI
    JSR     RESET_INVALID_COUNTER                       * Dtermine the size to print out CMPI
    LEA     CMPI_VALUE,A1                  * Print out the literal value
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    JSR     CHECK_TYPE_DATA
    JSR     PRINT_NORMAL_SUFFIX
    JSR     PRINT_EMPTY_SPACE
    JSR     PRINT_IMMEDIATE_DATA_SYMBOL
    JSR     GET_NORMAL_SIZE               * Get the size of the operation to know how much byte should we advance forward
    LSR     #1, D3                        * For cmpi.b and cmpi.w, they all map to absolute short in which print only 4
    MOVE.W  D3, THIRD_TEMP_VAR
    JSR     CHECK_TYPE_DATA              * Now byte and word will be printed 4 space where as long will be printed 5 space
    JSR     REGISTER_MODE_111            * Print out the immediate value
    JSR     PRINT_COMMA
    JSR     PRINT_EMPTY_SPACE
    JSR     PRINT_DATA_MODE_SOURCE
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    RTS



PRINT_NORMAL_SUFFIX                       * For normal size, the size is on the first 2 bit of the third nibble
                              * Get rid of the 2 right most bit of the third nibble
    JSR     GET_NORMAL_SIZE
    LEA     NORMAL_SIZE_PRINT_JUMP_TABLE,A4
    CMP     #%11,D3                      * For normal size, does not take 11
    BEQ     INVALID
    MULU    #6,D3
    JSR     0(A4,D3)                       * Print out appropriate suffix
    RTS


** STORE DATA INTO THIRD_TEMP_VAR FIRST.DEPENDING ON SOURCE OR DESTINATION REGISTER

PRINT_REGISTER_NUMBER           * This is used to print the register number Dn or An where it will print n
                                * Expected to store the data into D3 first
    LEA  HEX_CHARACTER_JUMP_TABLE,A4
    MOVE.W  THIRD_TEMP_VAR,D3
    MULU    #6,D3
    JSR     0(A4,D3)
    CLR.W THIRD_TEMP_VAR
    CLR.W D3
    RTS

PRINT_OUT_LEA
    JSR     RESET_INVALID_COUNTER
    LEA LEA_VALUE,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_EMPTY_SPACE
    JSR CHECK_TYPE_DATA
    JSR PRINT_DATA_MODE_SOURCE
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_ADDRESS_REGISTER
    MOVE.W DESTINATION_VAR,THIRD_TEMP_VAR * Store the register number to print
    JSR PRINT_REGISTER_NUMBER
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE
    RTS

PRINT_OUT_ADDQ             * ADDQ is the same as SUBQ
    JSR     RESET_INVALID_COUNTER
    LEA ADDQ_VALUE,A1
    BRA ADDQ_AND_SUBQ_HELPER

PRINT_OUT_SUBQ                              * SUBQ does not accept 0. working on a way to print out 8
    JSR     RESET_INVALID_COUNTER
    LEA SUBQ_VALUE,A1
    BRA ADDQ_AND_SUBQ_HELPER

ADDQ_AND_SUBQ_HELPER
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_NORMAL_SUFFIX
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_IMMEDIATE_DATA_SYMBOL
    JSR CHECK_TYPE_DATA
    CMP #0, DESTINATION_VAR                * In the case of 8, the destination var is 000. But we want to print out 8
    BEQ SUBQ_HELPER_FUNCTION
    MOVE.W DESTINATION_VAR,THIRD_TEMP_VAR     * Save the value to print out from print register number
    JSR PRINT_REGISTER_NUMBER              * Print out the data from 1-8
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_DATA_MODE_SOURCE
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE
    RTS

SUBQ_HELPER_FUNCTION                         * Single function that exist to help with printing oout the data in SUBQ
    MOVE.W #8, THIRD_TEMP_VAR
    JSR PRINT_REGISTER_NUMBER
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_DATA_MODE_SOURCE
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE
PRINT_OUT_DIVS
    JSR     RESET_INVALID_COUNTER
    LEA DIVS_VALUE,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_NORMAL_WORD_SUFFIX
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_DATA_MODE_SOURCE
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_DATA_REGISTER
    MOVE.W DESTINATION_VAR, THIRD_TEMP_VAR      * Store the register number Dn to print out
    JSR PRINT_REGISTER_NUMBER
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE
    RTS

PRINT_OUT_MULS                      * MULS also act like sub for <ea>,Dn * FIX
    JSR     RESET_INVALID_COUNTER
    LEA   MULS_VALUE,A1
    JSR   PRINT_TO_SCREEN_ENTIRE_STRING
    JSR   PRINT_NORMAL_WORD_SUFFIX
    JSR   PRINT_EMPTY_SPACE
    JSR     CHECK_TYPE_DATA
    MOVE.W  #%01, DESTINATION_MODE      * Change the size of the 2 size bit to print out
    JSR  PRINT_DATA_MODE_SOURCE
    JSR     PRINT_COMMA
    JSR     PRINT_EMPTY_SPACE

    JSR     PRINT_DATA_REGISTER
    MOVE.W DESTINATION_VAR,THIRD_TEMP_VAR
    JSR     PRINT_REGISTER_NUMBER
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    RTS


PRINT_OUT_MULU
    JSR     RESET_INVALID_COUNTER
    LEA     MULU_VALUE,A1
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    JSR     PRINT_NORMAL_WORD_SUFFIX
    JSR     PRINT_EMPTY_SPACE
    JSR     CHECK_TYPE_DATA
    MOVE.W  #%01, DESTINATION_MODE
    JSR     PRINT_DATA_MODE_SOURCE
    JSR     PRINT_COMMA
    JSR     PRINT_EMPTY_SPACE

    JSR     PRINT_DATA_REGISTER
    MOVE.W DESTINATION_VAR,THIRD_TEMP_VAR
    JSR     PRINT_REGISTER_NUMBER
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    RTS

PRINT_OUT_CMP
    JSR     RESET_INVALID_COUNTER
    LEA CMP_VALUE,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_NORMAL_SUFFIX
    JSR PRINT_EMPTY_SPACE
    JSR CHECK_TYPE_DATA
    JSR PRINT_DATA_MODE_SOURCE
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_DATA_REGISTER
    MOVE.W DESTINATION_VAR,THIRD_TEMP_VAR
    JSR PRINT_REGISTER_NUMBER
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE

    RTS


PRINT_OUT_SUBA
    JSR     RESET_INVALID_COUNTER
    LEA     SUBA_VALUE,A1
    BRA     SUBA_AND_ADDA_HELPER

PRINT_OUT_ADDA
    JSR     RESET_INVALID_COUNTER
    LEA     ADDA_VALUE,A1
    BRA     SUBA_AND_ADDA_HELPER

SUBA_AND_ADDA_HELPER
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    JSR     CHECK_TYPE_DATA
    JSR     GET_THE_SECOND_NIBBLE
    LSL     #8,D3                      * Get the special one bit size of ADDA
    LSL     #7,D3
    LSR     #7,D3
    LSR     #8,D3
    ADD     #1,D3                      * 0 is word and 1 is long. Add 1 will be 01 and 10, word and long
    MOVE.W  D3,DESTINATION_MODE
    JSR     PRINT_NORMAL_SUFFIX        * Now print .W or .L only
    JSR     PRINT_DATA_MODE_SOURCE
    JSR     PRINT_COMMA
    JSR     PRINT_EMPTY_SPACE
    JSR     PRINT_ADDRESS_REGISTER
    MOVE.W  DESTINATION_VAR, THIRD_TEMP_VAR       * Save the variable to print out the number of address register
    JSR     PRINT_REGISTER_NUMBER
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    RTS

PRINT_OUT_OR
    JSR     RESET_INVALID_COUNTER
    LEA     OR_VALUE,A1
    BRA     ADD_AND_SUB_HELPER           * Take advantage of the similar structure like add and sub

PRINT_OUT_ADD
    JSR     RESET_INVALID_COUNTER              * Function similar like SUB
    LEA     ADD_VALUE,A1
    BRA     ADD_AND_SUB_HELPER

PRINT_OUT_SUB                      * The SUB function is odd is that the Dn is always in front
                                   * So to distinguish it, we need to check the source mode and compare with
                                   *000
    JSR     RESET_INVALID_COUNTER
    LEA SUB_VALUE,A1                       * Only time where the source and dstiantion are in correct position
    BRA     ADD_AND_SUB_HELPER


ADD_AND_SUB_HELPER
    JSR PRINT_TO_SCREEN_ENTIRE_STRING       * Is when both are data register
    JSR PRINT_NORMAL_SUFFIX
    JSR PRINT_EMPTY_SPACE
    JSR CHECK_TYPE_DATA
    CMP #0, SOURCE_MODE               *
    BNE SUB_HELPER_FUNCTION         * Utilize the not normal approach
    JSR PRINT_DATA_MODE_SOURCE
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_DATA_REGISTER
    MOVE.W DESTINATION_VAR, THIRD_TEMP_VAR
    JSR PRINT_REGISTER_NUMBER
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE
    RTS

SUB_HELPER_FUNCTION       * For whatever the data register is always the first 3 bit of the second nibble
                                           * Even though it can either be in the source or destination when write it
    JSR CHECK_TYPE_DATA


    MOVE.W DESTINATION_VAR,D3
    MOVE.W SOURCE_VAR,DESTINATION_VAR
    MOVE.W D3,SOURCE_VAR
    MOVE.W DESTINATION_MODE,D3
    MOVE.W SOURCE_MODE,DESTINATION_MODE
    MOVE.W D3,SOURCE_MODE
    MOVE.W SOURCE_MODE, D3
    MOVE.W SOURCE_VAR, THIRD_TEMP_VAR         * Save the variable to print out from register
    LSR #2,D3
    CMP #0,D3         * Check direction to know which order we should be printing
    BEQ SUB_HELPER_REGISTER_TO_MEM

    JSR REGISTER_MODE_000                  * Need to find a way to switch the places
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_DATA_MODE_DESTINATION
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE
    RTS

SUB_HELPER_REGISTER_TO_MEM            * Helper function to help with printing fro register to memory
    JSR PRINT_DATA_MODE_DESTINATION
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR REGISTER_MODE_000
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE
    RTS

PRINT_OUT_BRA                         * Current limitation: Only can print out branch to a word address (4bytes).No support for 8 bytes
    JSR     RESET_INVALID_COUNTER
    LEA     BRA_VALUE,A1
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    JSR     PRINT_EMPTY_SPACE
    JSR     PRINT_HEX_SYMBOL
    MOVE.W  A2,D4           * Save the current address we are at
    JSR     GET_NEXT_FOUR_NIBBLE       * GEt the displacement we are suppose to branch to
    ADD     D3,D4             * Current address + displacement => address we are suppose to jump to
    MOVE.W  D4, TEMP_CURRENT_4_NIBBLES     * Prepare the address to print out in hex
    JSR     CONVERT_HEX_TO_ASCII
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
PRINT_OUT_BSR
    JSR     RESET_INVALID_COUNTER
    LEA    BSR_VALUE,A1
    JSR    PRINT_TO_SCREEN_ENTIRE_STRING
    JSR    PRINT_EMPTY_SPACE
    JSR    PRINT_HEX_SYMBOL
    MOVE.W  A2,D4
    JSR    GET_NEXT_FOUR_NIBBLE
    ADD    D3,D4
    MOVE.W D4,TEMP_CURRENT_4_NIBBLES
    JSR    CONVERT_HEX_TO_ASCII
    BSR    USER_INPUT_ENTER
    BRA   PARSING_OP_CODE

PRINT_OUT_Bcc
    JSR     RESET_INVALID_COUNTER
    LEA    B,A1
    JSR    PRINT_TO_SCREEN_ENTIRE_STRING
    LEA    CONDITION_JUMP_TABLE,A6            * Load the jump table to know which condition code to print
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_SECOND_NIBBLE
    MULU    #6,D3
    JSR     0(A6,D3)            * Now print out the suffix of B
    JSR     PRINT_EMPTY_SPACE
    JSR     PRINT_HEX_SYMBOL
    MOVE.W  A2,D4
    JSR     GET_NEXT_FOUR_NIBBLE
    ADD     D3,D4
    MOVE.W  D4,TEMP_CURRENT_4_NIBBLES
    JSR     CONVERT_HEX_TO_ASCII
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE

PRINT_OUT_LOGICAL_SHIFT_MEM           * Lsd with <ea>
    JSR     RESET_INVALID_COUNTER
    LEA    LS_VALUE,A1
    JSR    ASD_LSD_ROD_SHIFT_HELPER
    RTS

PRINT_OUT_ARITH_SHIFT_MEM
    JSR     RESET_INVALID_COUNTER
    LEA    AS_VALUE,A1
    JSR    ASD_LSD_ROD_SHIFT_HELPER
    RTS

ASD_LSD_ROD_SHIFT_HELPER
    JSR    PRINT_TO_SCREEN_ENTIRE_STRING
    LEA     RIGHT_OR_LEFT_JUMP_TABLE,A6     * Print the direction, left or right
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     CHECK_TYPE_DATA
    JSR     GET_THE_SECOND_NIBBLE
    LSL      #8,D3
    LSL      #7,D3
    LSR       #7,D3
    LSR      #8,D3
    MULU     #6,D3
    JSR      0(A6,D3)   * Print out left or right
    JSR     PRINT_NORMAL_WORD_SUFFIX
    MOVE.W   SOURCE_VAR, THIRD_TEMP_VAR      * Save the register number in case for print OUT
    JSR      PRINT_DATA_MODE_SOURCE
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    RTS

PRINT_OUT_ROTATE_MEM
    JSR     RESET_INVALID_COUNTER
    LEA    RO_VALUE,A1
    JSR    ASD_LSD_ROD_SHIFT_HELPER
    RTS



PRINT_OUT_ASD_OR_LSD                * For other ASd and LSd, the first  bit of the last nibble can differentiate them
    JSR     RESET_INVALID_COUNTER
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR    GET_THE_FOURTH_NIBBLE
    LSR    #3,D3
    CMP    #0,D3
    BEQ    PRINT_OUT_ASD * First bit is 0 for ASD
    BRA    PRINT_OUT_LSD * 1 for LSD
    RTS

PRINT_OUT_ASD
    JSR     RESET_INVALID_COUNTER
    LEA AS_VALUE,A1
    JSR ASD_LSD_ROD_HELPER_FUNCTION
    RTS

PRINT_OUT_LSD
    JSR     RESET_INVALID_COUNTER
    LEA LS_VALUE,A1
    JSR ASD_LSD_ROD_HELPER_FUNCTION
    RTS

PRINT_OUT_ROD           * Could be ROd or ROXd. If the latter case, then it is invalid

    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_FOURTH_NIBBLE
    LSR     #3,D3
    CMP     #1,D3
    BNE     INVALID         * ROD ibly accept 1 as the first bit in the fourth nibbles
    JSR     RESET_INVALID_COUNTER
    LEA     RO_VALUE,A1
    JSR     ASD_LSD_ROD_HELPER_FUNCTION
    RTS




ASD_LSD_ROD_HELPER_FUNCTION   * Used for printing out the cases where a source and destionaion are present
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    LEA     RIGHT_OR_LEFT_JUMP_TABLE,A6     * Print the direction, left or right
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3 * Now print out the Direction left or right
    JSR     CHECK_TYPE_DATA
    JSR     GET_THE_SECOND_NIBBLE
    LSL      #8,D3
    LSL      #7,D3
    LSR      #8,D3
    LSR      #7,D3
    MULU     #6,D3
    JSR      0(A6,D3)   * Print out left or right
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     PRINT_NORMAL_SUFFIX    * Print out .B, .W or .L
    MOVE.W   TEMP_CURRENT_4_NIBBLES,D3      * Now we need to determine if its is immediate or register rotation
    JSR      GET_THE_THIRD_NIBBLE
    LSL      #8,D3
    LSL      #6,D3
    LSR      #8,D3
    LSR      #7,D3 * Now the third bit will be at the last position
    LEA     IMMEDIATE_OR_REGISTER_JUMP_TABLE,A6
    MULU     #6,D3
    JSR     0(A6,D3)
    JSR     PRINT_DATA_REGISTER
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     CHECK_TYPE_DATA
    MOVE.W  SOURCE_VAR,THIRD_TEMP_VAR * Save the register number to print out
    JSR     PRINT_REGISTER_NUMBER
    BSR     USER_INPUT_ENTER
    BRA     PARSING_OP_CODE
    RTS


MOVE_OPCODE_HELPER
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR CHECK_TYPE_DATA
    CMP #%001, DESTINATION_MODE
    BEQ PRINT_OUT_MOVEA
    BRA PRINT_OUT_MOVE
    RTS


PRINT_OUT_MOVEA
    JSR     RESET_INVALID_COUNTER
    MOVE     #0,D7
    LEA MOVEA_VALUE,A1
    JSR MOVE_SECOND_OPCODE_HELPER

PRINT_OUT_MOVE

    JSR     RESET_INVALID_COUNTER
    LEA MOVE_VALUE,A1
    JSR MOVE_SECOND_OPCODE_HELPER



MOVE_SECOND_OPCODE_HELPER
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    LEA MOVE_SIZE_PRINT_JUMP_TABLE,A6
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR GET_THE_FIRST_NIBBLE
    MULU #6,D3
    JSR 0(A6,D3)
    JSR PRINT_DATA_MODE_SOURCE
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR PRINT_DATA_MODE_DESTINATION
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE
    RTS




PRINT_TO_SCREEN_ENTIRE_STRING         * Simple utility method that take whatever in A1 and print out
    MOVE.B  #14,D0      * This is used to print out the command as an entire string
    TRAP    #15
    RTS

PRINT_DATA_MODE_SOURCE         * Depnding on the mode, will print out appropriate data mode: Dn,An,(An),...
    LEA     REGISTER_MODE_JUMP_TABLE,A6
    MOVE.W   SOURCE_VAR, THIRD_TEMP_VAR
    MOVE    SOURCE_MODE,D3
    MULU    #6,D3
    JSR     0(A6,D3)       * Let's see what mode is this source mode
    RTS

PRINT_DATA_MODE_DESTINATION
    LEA     REGISTER_MODE_JUMP_TABLE,A6
    MOVE.W    DESTINATION_VAR, THIRD_TEMP_VAR      * Determine the Xn to print
    MOVE.W    DESTINATION_MODE,D3
    MULU    #6,D3
    JSR     0(A6,D3)
    RTS

PRINT_ADDRESS_LOCATION        * Print out the address in which we are executing the disassembling
                              * Should print out 00XX YYYY as the address location
                              * Find a way to load the address at A2 into some variables and call print hex to ascii
    MOVE.L  A2,D5
    LSR     #8,D5              * Shift 4 bytes left most to print out
    LSR     #8,D5
    MOVE.W  D5,TEMP_CURRENT_4_NIBBLES * Get the entire long address
    JSR     CONVERT_HEX_TO_ASCII
    MOVE.W  A2,D5
    MOVE.W  D5,TEMP_CURRENT_4_NIBBLES
    JSR     CONVERT_HEX_TO_ASCII
    JSR     PRINT_EMPTY_SPACE
    RTS


PRINT_COMMA *Print the comma to separate between source and destination
    LEA     COMMA,A1
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_ADDRESS_REGISTER
    LEA   ADDRESS_REGISTER,A1
    JSR   PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_DATA_REGISTER
    LEA    DATA_REGISTER,A1
    JSR    PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_OPEN_BRACKET
    LEA   OPENING_BRACKET,A1
    JSR   PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_CLOSE_BRACKET
    LEA  CLOSING_BRACKET,A1
    JSR  PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_PLUS_SIGN
    LEA  PLUS_SIGN,A1
    JSR  PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_MINUS_SIGN
    LEA  MINUS_SIGN,A1
    JSR  PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_SYMBOL
    LEA   HEX_SYMBOL,A1
    JSR   PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_BINARY_SYMBOL
    LEA   BINARY_SYMBOL,A1
    JSR   PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_EMPTY_SPACE
    LEA   SPACE,A1
    JSR   PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_IMMEDIATE_DATA_SYMBOL
    LEA    IMMEDIATE_DATA_SYMBOL,A1
    JSR     PRINT_TO_SCREEN_ENTIRE_STRING
    RTS



****************************************
* Query data section
****************************************

GET_THE_FIRST_NIBBLE            * Get the left most byte. Assuming that the full word data is already store in D3
    LSR     #8,D3               * Shift 2 bytes to the rights
    LSR     #4,D3               * Shift 1 byte to the right. Now left most byte is now the right most byte
    RTS


GET_THE_SECOND_NIBBLE
    LSL     #4,D3             * Shift the left most byte to go away
    LSR     #4,D3             * Return the original place
    LSR     #8,D3              * Push the 2 right most byte out of the way
    RTS

GET_THE_THIRD_NIBBLE
    LSL     #8,D3                * Bye byte 2 left most nibble
    LSR     #8,D3                * Get rid of the 3 bytes that are infront
    LSR     #4,D3                 * Shift back to original position
    RTS

GET_THE_FOURTH_NIBBLE
    LSL     #8,D3
    LSL     #4,D3
    LSR     #8,D3
    LSR     #4,D3
    RTS

GET_NEXT_FOUR_NIBBLE
    MOVE.W  (A2)+,D3
    MOVE.W  D3, TEMP_CURRENT_4_NIBBLES       * Copy the value into temp variable
    RTS


GET_NEXT_TWO_NIBBLE
    MOVE.B  (A2)+,D3            * Get the next byte ( 2 nibbles)
    MOVE.B  D3, TEMP_CURRENT_2_NIBBLES
    RTS

GET_NORMAL_SIZE                   * The normal size is on the first 2 bit of the third nibble of the op code
*    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    **JSR     GET_THE_THIRD_NIBBLE           * Get the index to know which value to print
    MOVE.W  DESTINATION_MODE,D3
    LSL     #8,D3
    LSL     #6,D3
    LSR     #8,D3
    LSR     #6,D3
    RTS
**********************************
* logical reasoning section (determine what kind of opcode to print, what type of data to print)
**********************************


********
* Check type data: Means getting the appropriate source and destination register  and mode
********
CHECK_TYPE_DATA
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    LSL     #4,D3      * Get rid of left most byte
    LSR     #4,D3      * Now focus on the following format      destination mode mode source. Start with destination first
    LSR     #8,D3      * Now the D3 has the destination
    LSR     #1,D3
    MOVE.W  D3,DESTINATION_VAR
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3 * Now go with the destination mode
    LSL     #7,D3
    LSR     #7,D3
    LSR     #6,D3
    MOVE.W  D3,DESTINATION_MODE
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3       * Now extract the source mode
    LSL     #8,D3
    LSL     #2,D3
    LSR     #8,D3
    LSR     #2,D3
    LSR     #3,D3
    MOVE.W  D3,SOURCE_MODE      * Now extract the source
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    LSL     #8,D3
    LSL     #5,D3
    LSR     #8,D3
    LSR     #5,D3
    MOVE.W  D3,SOURCE_VAR
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    RTS


* Now the byte of the opcode is in D3







FIRST_NIBBLE_4_SECOND_NIBBLE_E        * Possible answer are NOP,JSR and RTS
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3       * Get the op code
    LSL     #8,D3             * Shift to the left to dissappear 2 left most byte
    LSR     #8,D3             * Shift to the right to gain back original position. Only now the 2 left most byte are gone
    CMP.B   #$71,D3           * NOP is 4E71
    BEQ     PRINT_OUT_NOP
    CMP.B   #$75,D3           *RTS is 4E75
    BEQ     PRINT_OUT_RTS
    JSR     CHECK_TYPE_DATA       *  Get the destination mode and desitnation register. Could be JSR
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_THIRD_NIBBLE     * For Jsr  the 2 bit of the 3rd nibble is 10
    LSR     #2, D3
    CMP     #%10, D3              *
    BEQ     PRINT_OUT_JSR         * Print out the command JSR and the data
    BRA     INVALID               * Need to implement
    RTS

SECOND_NIBBLE_IS_0 * Possible to be ORI. In the case first byte is 0 as well
    JSR     GET_NEXT_TWO_NIBBLE
    CMP.B   #$7C, TEMP_CURRENT_2_NIBBLES            * Only ORI to SR have the last 2 bytes in op code as 7C
    BRA     PRINT_OUT_ORI_TO_SR


SECOND_NIBBLE_IS_E  * Possible to be NOP and RTS. In the case the first byte is 4
    JSR GET_NEXT_TWO_NIBBLE   * Get the remaning 2 bytes
    CMP     #$71, TEMP_CURRENT_2_NIBBLES
    BEQ     PRINT_OUT_NOP
    CMP     #$75,D3
    BEQ     PRINT_OUT_RTS




**************************************************
* Specific branching of the jump table is stored here
*************************************************
FIRST_NIBBLE_JUMP_TABLE                  * Based on the first byte of the op code then jump on what is possible
    JMP  FIRST_NIBBLE_IS_0               * ORI, CMPI. BCLR
    JMP  FIRST_NIBBLE_IS_1               * MOVE.B, MOVEA.B
    JMP  FIRST_NIBBLE_IS_2               * MOVEA.L, MOVE.L
    JMP  FIRST_NIBBLE_IS_3               * MOVE.W    MOVEA.W
    JMP  FIRST_NIBBLE_IS_4               * NOP, LEA, NEG, JSR, RTS
    JMP  FIRST_NIBBLE_IS_5               * SUBQ
    JMP  FIRST_NIBBLE_IS_6               * BCS, BGE, BLT, BVC, BRA
    JMP  FIRST_NIBBLE_IS_7               * NOT SUPPORTED
    JMP  FIRST_NIBBLE_IS_8               * DIVS, OR
    JMP  FIRST_NIBBLE_IS_9               * SUB
    JMP  FIRST_NIBBLE_IS_A               * NOT SUPPORTED
    JMP  FIRST_NIBBLE_IS_B               * EOR, CMP
    JMP  FIRST_NIBBLE_IS_C               * MULS
    JMP  FIRST_NIBBLE_IS_D               * ADD, ADDA
    JMP  FIRST_NIBBLE_IS_E               * LSR, LSL, ASR, ASL, ROL, ROR
    JMP  FIRST_NIBBLE_IS_F               * NOT SUPPORTED

FIRST_NIBBLE_IS_0             * UNFINISHED IMPLEMENTATION
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_SECOND_NIBBLE
    CMP.B   #$C, D3
    BEQ     PRINT_OUT_CMPI
    RTS


FIRST_NIBBLE_IS_1 *MOVE.B, MOVEA.B * Can only be MOVE for these nibble because of the size of MOVE
    JSR MOVE_OPCODE_HELPER
    SIMHALT

FIRST_NIBBLE_IS_2 *MOVE.L, MOVEA.L
    JSR MOVE_OPCODE_HELPER
    SIMHALT

FIRST_NIBBLE_IS_3 * MOVE.W, MOVEA.W
    JSR MOVE_OPCODE_HELPER
    SIMHALT


FIRST_NIBBLE_IS_4                 * Possible for NOP,LEA,RTS,JSR,NEG. Now will check the second byte
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3         * Get the original op code back
    JSR     GET_THE_SECOND_NIBBLE
    CMP.B   #$E,D3
    BEQ     FIRST_NIBBLE_4_SECOND_NIBBLE_E             * NOP,RTS,JSR
    CMP.B   #4,D3              *  If the second nibble is 4, then it must be neg
    BEQ     PRINT_OUT_NEG
                                * For LEA, the aestination mode must be 111 (address register)
    JSR     CHECK_TYPE_DATA
    CMP     #%111,DESTINATION_MODE
    BEQ     PRINT_OUT_LEA           * Only LEA have the 3 bits of destination is 111
    BRA     INVALID
    RTS

FIRST_NIBBLE_IS_5                     * This is SUBQ and ADDQ
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR    CHECK_TYPE_DATA
    JSR    GET_NORMAL_SIZE           * SUBQ and ADDQ only accpet normal size. Meaning no 11
    CMP    #%11,D3
    BEQ    INVALID
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR    GET_THE_SECOND_NIBBLE
    LSL    #8,D3           * Get rid of the first 2 byets
    LSL    #7,D3           * Shift back to original position
    LSR    #8,D3
    LSR    #7,D3
    CMP    #0,D3           * SUBQ have 1 as the last bit in the second nibble
    BEQ    PRINT_OUT_ADDQ     * ADDQ has 0 as the last bit in the second nibble
    BRA    PRINT_OUT_SUBQ
    RTS
    SIMHALT

FIRST_NIBBLE_IS_6
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_SECOND_NIBBLE
    CMP     #%0000,D3      * Only the condition code of BRA is 0000
    BEQ     PRINT_OUT_BRA
    CMP     #%0001,D3
    BEQ     PRINT_OUT_BSR
    BRA     PRINT_OUT_Bcc

    RTS
    SIMHALT

FIRST_NIBBLE_IS_7 * This is MOVEQ
    LEA MOVEQ_VALUE,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_NORMAL_LONG_SUFFIX
    MOVE.W TEMP_CURRENT_4_NIBBLES,D1 * Save the current opcode
    JSR PRINT_IMMEDIATE_DATA_SYMBOL
    JSR PRINT_HEX_SYMBOL
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    LSL #8,D3
    LSR #8,D3
    MOVE.W D3, TEMP_CURRENT_4_NIBBLES
    JSR CONVERT_HEX_TO_ASCII                * Print the 8 bit data field
    MOVE.W D1, TEMP_CURRENT_4_NIBBLES
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    JSR CHECK_TYPE_DATA
    JSR PRINT_DATA_REGISTER
    MOVE.W DESTINATION_VAR, THIRD_TEMP_VAR
    JSR PRINT_REGISTER_NUMBER
    BSR USER_INPUT_ENTER
    BRA PARSING_OP_CODE

    SIMHALT

FIRST_NIBBLE_IS_8 * DIVS
    MOVE.W TEMP_CURRENT_4_NIBBLES, D3
    JSR CHECK_TYPE_DATA
    CMP #%111, DESTINATION_MODE
    BEQ  PRINT_OUT_DIVS
    CMP #%011, DESTINATION_MODE
    BEQ  INVALID * This is DIVU
    BRA PRINT_OUT_OR
    RTS
    SIMHALT

FIRST_NIBBLE_IS_9              * SUB and SUBA           * No way of knowing SUX
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR CHECK_TYPE_DATA
    JSR GET_NORMAL_SIZE
    CMP #%11,D3
    BEQ PRINT_OUT_SUBA      * SUB Does not accept the size of 11
    BRA PRINT_OUT_SUB
    SIMHALT

FIRST_NIBBLE_IS_A
    RTS
    SIMHALT

FIRST_NIBBLE_IS_B        * CMP
    MOVE.W   TEMP_CURRENT_4_NIBBLES,D3
    JSR      CHECK_TYPE_DATA
    JSR     GET_NORMAL_SIZE
    CMP      #%11, D3
    BEQ      INVALID * CMP does not accept size 11
    MOVE.W   TEMP_CURRENT_4_NIBBLES,D3
    JSR      GET_THE_SECOND_NIBBLE
    LSL     #8,D3      * Get the last bit of the second nibble
    LSL      #7,D3
    LSR      #7,D3
    LSR      #8,D3
    CMP      #0,D3        * CMP only accept 0 as the last bit in the second nibble
    BNE      INVALID
    BRA      PRINT_OUT_CMP
    SIMHALT

FIRST_NIBBLE_IS_C          * MULS
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     CHECK_TYPE_DATA
    JSR     GET_NORMAL_SIZE
    CMP     #%11,D3
    BNE     INVALID        * MULS only accept 11 as the size
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR     GET_THE_SECOND_NIBBLE
    LSL     #8,D3      * Get the last bit of the second
    LSL      #7,D3
    LSR      #7,D3
    LSR      #8,D3
    CMP     #1,D3     * If it is 1, then it is MULS. Otherwise MULU
    BEQ     PRINT_OUT_MULS
    BRA     PRINT_OUT_MULU
    RTS
    SIMHALT

FIRST_NIBBLE_IS_D *ADD, ADDA                        * Have no way of knowing ADDX
    MOVE.W  TEMP_CURRENT_4_NIBBLES,D3
    JSR CHECK_TYPE_DATA
    JSR GET_NORMAL_SIZE
    CMP #%11,D3
    BEQ PRINT_OUT_ADDA
    BRA PRINT_OUT_ADD
    RTS
    SIMHALT

FIRST_NIBBLE_IS_E              * There are 2 types for every LSL,LSR,ASL,ASR,ROR,ROL. They can be seperated as LSd <ea> and other. They can be differentiate by the size 11
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR CHECK_TYPE_DATA
    JSR GET_NORMAL_SIZE
    CMP #%11,D3
    BEQ SPECIAL_SHIFT_INSTRUCTION * Only the instructions with 11 in the size parts deal with <ea> (shift memory)
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR CHECK_TYPE_DATA
    JSR GET_THE_THIRD_NIBBLE         * For ASd and LSd, the lat bit is 0 of third nibble is 0
    LSL     #8,D3      * Get the last bit of the second
    LSL      #7,D3
    LSR      #7,D3
    LSR      #8,D3
    CMP     #0,D3
    BEQ    PRINT_OUT_ASD_OR_LSD
    BRA    PRINT_OUT_ROD           * Could also be ROXD. If it is then invalid
    RTS


FIRST_NIBBLE_IS_F * UNSUPPORTED
    RTS
    SIMHALT

SPECIAL_SHIFT_INSTRUCTION *Asd, LSd,ROd with <ea>. Shift instructions
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR     CHECK_TYPE_DATA
    JSR     GET_THE_SECOND_NIBBLE
    LSR     #1, D3
    CMP     #1,D3
    BEQ     PRINT_OUT_LOGICAL_SHIFT_MEM * 001
    CMP     #0,D3
    BEQ     PRINT_OUT_ARITH_SHIFT_MEM *000
    CMP     #%11,D3
    BEQ     PRINT_OUT_ROTATE_MEM * 011
    BRA     INVALID * Must be ROXd, UNSUPPORTED
    RTS





* Used to figure out what type of mode and address where used to print
REGISTER_MODE_JUMP_TABLE
    JMP REGISTER_MODE_000             * Data register mode Dn
    JMP REGISTER_MODE_001             * ADdress register mode   An
    JMP REGISTER_MODE_010             * Indirect address register mode (An)
    JMP REGISTER_MODE_011             *  Address register with increment (An)+
    JMP REGISTER_MODE_100             * Address register with decrement -(An)
    JMP REGISTER_MODE_101             * Not supported
    JMP REGISTER_MODE_110             * Not supported
    JMP REGISTER_MODE_111             * This could be immediate, absolute short or absolute long

REGISTER_MODE_000   * Print out data register Dn
    JSR     PRINT_DATA_REGISTER
    JSR     PRINT_REGISTER_NUMBER
    RTS

REGISTER_MODE_001       * An
    JSR     PRINT_ADDRESS_REGISTER
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
    LEA REGISTER_111_JUMP_TABLE,A4    * Print out the appropriate value
    MOVE.W  THIRD_TEMP_VAR,D3
    MULU #6,D3
    JSR 0(A4,D3)

    LEA SHORT_OR_LONG_PRINT,A4 * Prepare the table to print out the data
**    CMP #4, THIRD_TEMP_VAR      * Check if it is immediate data or Not
*    BEQ     IMMEDIATE_DATA        * This is immediate data, need to have specific check
    MOVE.W  THIRD_TEMP_VAR,D3
    MULU #6,D3        * Use THIRD_TEMP_VAR as a place holder for the data we want to print out for register mode 111.
                          * In the code before this, we need to move the appropriate data into this address. Either the destination or the source
                          *   REMEMBER TO IMPLEMENT This

    JSR  0(A4,D3)     * Print out the appropriate long or short value
    RTS

            * Third table that deal with printing out short .W or .L value
SHORT_OR_LONG_PRINT                     * Will jump to this when the register mode is 111 and not immediate data
    JMP ABSOLUTE_SHORT                  * Xn index for this is 000
    JMP ABSOLUTE_LONG                   * Xn index for this is 001
    JMP COUNTER_DISPLACEMENT
    JMP COUNTER_INDEX
    JMP IMMEDIATE_DATA



ABSOLUTE_SHORT     *We need to get the next 4 bytes as the address to print out
    JSR     GET_NEXT_FOUR_NIBBLE * Got next 4 nibbles to print out as address
    JSR     CONVERT_HEX_TO_ASCII
    CLR.W   SECOND_TEMP_VAR * Reset the variables after displaying
    RTS
    SIMHALT

ABSOLUTE_LONG       * Print the next 8 bytes as the address
    JSR ABSOLUTE_SHORT        * PRinted 4 bytes
    JSR ABSOLUTE_SHORT         * Printed 4 more
    RTS
    SIMHALT

COUNTER_DISPLACEMENT           * Not SUPPORTED
    SIMHALT

COUNTER_INDEX                  * Not SUPPORTED
    SIMHALT

    * Immediate data is also like absolute short and long. Will take advantage of that
IMMEDIATE_DATA
    JSR     GET_NORMAL_SIZE  * Now the first 2 bit of third nibble is on the right most
    LSR     #1, D3           * Byte aand word are mapped to absolute short => 00 and 01 after shift will go to 00
                                * If the size is long, the it will go to absolute long 10 => 01
    LEA SHORT_OR_LONG_PRINT,A4 * Prepare the table to print out the data
    MULU #6,D3        * Use THIRD_TEMP_VAR as a place holder for the data we want to print out for register mode 111.
                              * In the code before this, we need to move the appropriate data into this address. Either the destination or the source
                              *   REMEMBER TO IMPLEMENT This
    JSR  0(A4,D3)     * Print out the appropriate long or short value
    RTS

REGISTER_111_JUMP_TABLE
    JMP PRINT_SHORT_SYMBOL
    JMP PRINT_LONG_SYMBOL
    JMP PLACE_HOLDER_3
    JMP PLACE_HOLDER_4
    JMP PRINT_IMMEDIATE_DATA_AND_HEX

PRINT_SHORT_SYMBOL
    JSR PRINT_HEX_SYMBOL
    RTS

PRINT_LONG_SYMBOL
    JSR PRINT_HEX_SYMBOL
    RTS

PLACE_HOLDER_3
    SIMHALT

PLACE_HOLDER_4
    SIMHALT

PRINT_IMMEDIATE_DATA_AND_HEX
    JSR PRINT_IMMEDIATE_DATA_SYMBOL
    JSR PRINT_HEX_SYMBOL
    RTS

HEX_CHARACTER_JUMP_TABLE
    JMP     PRINT_HEX_0
    JMP     PRINT_HEX_1
    JMP     PRINT_HEX_2
    JMP     PRINT_HEX_3
    JMP     PRINT_HEX_4
    JMP     PRINT_HEX_5
    JMP     PRINT_HEX_6
    JMP     PRINT_HEX_7
    JMP     PRINT_HEX_8
    JMP     PRINT_HEX_9
    JMP     PRINT_HEX_A
    JMP     PRINT_HEX_B
    JMP     PRINT_HEX_C
    JMP     PRINT_HEX_D
    JMP     PRINT_HEX_E
    JMP     PRINT_HEX_F

PRINT_HEX_0
        LEA ZERO,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS
PRINT_HEX_1
        LEA ONE,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_2
        LEA TWO,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_3
        LEA THREE,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_4
        LEA FOUR,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_5
        LEA FIVE,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_6
        LEA SIX,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_7
        LEA SEVEN,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_8
        LEA EIGHT,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_9
        LEA NINE,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_A
        LEA A,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_B
        LEA B,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_C
        LEA C,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_D
        LEA D,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_E
        LEA E,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

PRINT_HEX_F
        LEA F,A1
        JSR PRINT_TO_SCREEN_ENTIRE_STRING
        RTS

MOVE_SIZE_PRINT_JUMP_TABLE
    JMP UNSUPPORTED_MOVE_SIZE
    JMP MOVE_BYTE_SUFFIX
    JMP MOVE_LONG_SUFFIX
    JMP MOVE_WORD_SUFFIX

UNSUPPORTED_MOVE_SIZE
    BRA INVALID
    RTS

MOVE_BYTE_SUFFIX
    LEA BYTE_SUFFIX,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_EMPTY_SPACE
    RTS

MOVE_LONG_SUFFIX
    LEA LONG_SUFFIX,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_EMPTY_SPACE
    RTS

MOVE_WORD_SUFFIX
    LEA WORD_SUFFIX,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_EMPTY_SPACE
    RTS


NORMAL_SIZE_PRINT_JUMP_TABLE
    JMP PRINT_NORMAL_BYTE_SUFFIX
    JMP PRINT_NORMAL_WORD_SUFFIX
    JMP PRINT_NORMAL_LONG_SUFFIX
    JMP UNSUPPORTED_NORMAL_SUFFIX         * Could be move

PRINT_NORMAL_BYTE_SUFFIX
    LEA BYTE_SUFFIX,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_EMPTY_SPACE
    RTS

PRINT_NORMAL_WORD_SUFFIX
    LEA WORD_SUFFIX,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_EMPTY_SPACE
    RTS

PRINT_NORMAL_LONG_SUFFIX
    LEA LONG_SUFFIX,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    JSR PRINT_EMPTY_SPACE
    RTS

UNSUPPORTED_NORMAL_SUFFIX * Could be Move to CCR 11
    BRA INVALID
    RTS


*This jump table depends on the condition of Bcc
CONDITION_JUMP_TABLE
    JMP    CONDITION_TRUE
    JMP    CONDITION_FALSE
    JMP    CONDITION_HIGHER
    JMP    CONDITION_LOWER_OR_SAME
    JMP    CONDITION_CARRY_CLEAR
    JMP    CONDITION_CARRY_SET                * Supported
    JMP    CONDITION_NOT_EQUAL
    JMP    CONDITION_EQUAL
    JMP    CONDITION_OVERFLOW_CLEAR            * Supported
    JMP    CONDITION_OVERFLOW_SET
    JMP    CONDITION_PLUS
    JMP    CONDITION_MINUS
    JMP    CONDITION_GREATER_OR_EQUAL         * Supported
    JMP    CONDITION_LESS_THAN                * SUPPORTED
    JMP    CONDITION_GREATER_THAN
    JMP    CONDITION_LESS_OR_EQUAL


CONDITION_TRUE
    BRA     INVALID
CONDITION_FALSE
    BRA     INVALID
CONDITION_HIGHER
    BRA     INVALID
CONDITION_LOWER_OR_SAME
    BRA     INVALID
CONDITION_CARRY_CLEAR
    BRA     INVALID



CONDITION_CARRY_SET
    LEA     CARRY_SET_VALUE,A1
    JSR    PRINT_TO_SCREEN_ENTIRE_STRING
    JSR    PRINT_EMPTY_SPACE
    RTS







CONDITION_NOT_EQUAL
    BRA     INVALID
CONDITION_EQUAL
    BRA     INVALID

CONDITION_OVERFLOW_CLEAR
    LEA    OVERFLOW_CLEAR_VALUE,A1
    JSR    PRINT_TO_SCREEN_ENTIRE_STRING
    JSR    PRINT_EMPTY_SPACE
    RTS



CONDITION_OVERFLOW_SET
    BRA     INVALID
CONDITION_PLUS
    BRA     INVALID
CONDITION_MINUS
    BRA     INVALID


CONDITION_GREATER_OR_EQUAL
    LEA    GREATER_OR_EQUAL_VALUE,A1
    JSR    PRINT_TO_SCREEN_ENTIRE_STRING
    JSR    PRINT_EMPTY_SPACE
    RTS




CONDITION_LESS_THAN
    LEA   LESS_THAN_VALUE,A1
    JSR   PRINT_TO_SCREEN_ENTIRE_STRING
    JSR   PRINT_EMPTY_SPACE
    RTS




CONDITION_GREATER_THAN
    BRA     INVALID
CONDITION_LESS_OR_EQUAL
    BRA     INVALID

RIGHT_OR_LEFT_JUMP_TABLE
    JMP   RIGHT_DIRECTION_PRINT
    JMP   LEFT_DIRECTION_PRINT


RIGHT_DIRECTION_PRINT
    LEA RIGHT_DIRECTION,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

LEFT_DIRECTION_PRINT
    LEA LEFT_DIRECTION,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    RTS


IMMEDIATE_OR_REGISTER_JUMP_TABLE       * Use for ASd, LSd, ROd operations
    JMP   IMMEDIATE_ROTATION
    JMP   REGISTER_ROTATION

IMMEDIATE_ROTATION
    LEA IMMEDIATE_DATA_SYMBOL,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR  GET_THE_SECOND_NIBBLE
    LSR #1,D3
    CMP #0,D3
    BEQ IMMEDIATE_ROTATION_HELPER  * For cases where the immediate is 0, make it 8
    MOVE.W D3, THIRD_TEMP_VAR * Save the immediate data 1-8 we want to print
    JSR PRINT_REGISTER_NUMBER
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    RTS

REGISTER_ROTATION
    LEA DATA_REGISTER,A1
    JSR PRINT_TO_SCREEN_ENTIRE_STRING
    MOVE.W TEMP_CURRENT_4_NIBBLES,D3
    JSR GET_THE_SECOND_NIBBLE
    LSR #1,D3
    MOVE.W D3,THIRD_TEMP_VAR
    JSR PRINT_REGISTER_NUMBER
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    RTS

IMMEDIATE_ROTATION_HELPER
    MOVE.W #8,THIRD_TEMP_VAR
    JSR PRINT_REGISTER_NUMBER
    JSR PRINT_COMMA
    JSR PRINT_EMPTY_SPACE
    RTS



******************************************************************
* Constant String that is used to print out the data is stored here
******************************************************************
INTRO_STARTING   DC.W   'Please enter starting address',0
INTRO_ENDING     DC.W   'Please enter ending address',0
INVALID_INPUT    DC.W   'INVALID ADDRESS ENTERED',0
NOP_VALUE        DC.W   'NOP',0
RTS_VALUE        DC.W   'RTS',0
ORI_VALUE        DC.W   'ORI',0
JSR_VALUE        DC.W   'JSR',0
LEA_VALUE        DC.W    'LEA',0
NEG_VALUE        DC.W    'NEG',0
CMPI_VALUE      DC.W     'CMPI',0
CMP_VALUE        DC.W     'CMP',0
SUB_VALUE        DC.W     'SUB',0
SUBA_VALUE       DC.W     'SUBA',0
SUBQ_VALUE       DC.W    'SUBQ',0
DIVS_VALUE       DC.W     'DIVS',0
BRA_VALUE        DC.W      'BRA',0
BSR_VALUE        DC.W     'BSR',0
MULS_VALUE       DC.W       'MULS',0
MULU_VALUE       DC.W       'MULU',0
ADD_VALUE        DC.W     'ADD',0
ADDA_VALUE        DC.W      'ADDA',0
ADDQ_VALUE       DC.W     'ADDQ',0
AS_VALUE         DC.W     'AS',0
LS_VALUE         DC.W     'LS',0
RO_VALUE         DC.W     'RO',0
LEFT_DIRECTION   DC.W     'L',0
RIGHT_DIRECTION  DC.W     'R',0
OR_VALUE         DC.W     'OR',0
MOVEA_VALUE      DC.W    'MOVEA',0
MOVE_VALUE       DC.W    'MOVE',0
MOVEQ_VALUE      DC.W    'MOVEQ',0
DATA_VALUE       DC.W    'DATA',0
OVERFLOW_CLEAR_VALUE     DC.W    'VC',0
GREATER_OR_EQUAL_VALUE   DC.W    'GE',0
LESS_THAN_VALUE          DC.W     'LT',0
CARRY_SET_VALUE          DC.W     'CS',0
SR_VALUE         DC.W   'SR',0
CCR_VALUE        DC.W   'CCR',0
OPENING_BRACKET  DC.W   '(',0
CLOSING_BRACKET  DC.W   ')',0
PLUS_SIGN        DC.W   '+',0
MINUS_SIGN       DC.W   '-',0
DATA_REGISTER    DC.W   'D',0
ADDRESS_REGISTER DC.W   'A',0
COMMA            DC.W   ',',0
SPACE            DC.W    ' ',0
BINARY_SYMBOL    DC.W   '%',0
HEX_SYMBOL      DC.W    '$',0
IMMEDIATE_DATA_SYMBOL   DC.W    '#',0
BYTE_SUFFIX      DC.W   '.B',0
WORD_SUFFIX      DC.W    '.W',0
LONG_SUFFIX      DC.W    '.L',0

ZERO            DC.W    '0',0
ONE            DC.W     '1',0
TWO            DC.W     '2',0
THREE            DC.W   '3',0
FOUR            DC.W    '4',0
FIVE            DC.W     '5',0
SIX             DC.W    '6',0
SEVEN           DC.W    '7',0
EIGHT          DC.W     '8',0
NINE           DC.W     '9',0
A             DC.W      'A',0
B             DC.W      'B',0
C             DC.W      'C',0
D            DC.W       'D',0
E            DC.W       'E',0
F            DC.W       'F',0














    END    START        ; last line of source








*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
