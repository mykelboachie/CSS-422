*-----------------------------------------------------------
* Title      : 68k Disassembler
* Written by : Thuan Tran
* Date       : March 11th, 2018
* Description: Load a test file, enter starting and ending address. Press enter to see it disassemble every line
*-----------------------------------------------------------

*** A2 will be used as the address in which it will iterate through all the way until ending adrress
*** A3 will be used to store the ending address

STARTING_ADDRESS            EQU    $100 * User input starting address
ENDING_ADDRESS              EQU    $150 * User input ending address
TEMP_CURRENT_4_NIBBLES      EQU    $200 * Temporary variable to hold 4 nibble at a time
DESTINATION_VAR             EQU    $250 * Used to hold the Address number     (11-9th bit)
DESTINATION_MODE            EQU    $300 * Used to hold the mode of destination (8-6 bit)
SOURCE_MODE                 EQU    $350 * used to hold the mode of the source (5-3)
SOURCE_VAR                  EQU    $400 * Used to hold the address number of source (2-0 bit)
THIRD_TEMP_VAR              EQU    $550 * Used as an arbitrary storage for data
FOURTH_TEMP_VAR             EQU    $600 * Used to prevent overwrite to (A1) when getting end address
FIFTH_TEMP_VAR              EQU    $650 * Used to prevent overwrite to (A1) when getting start address
TEMP_CURRENT_2_NIBBLES      EQU    $750 * Temporary variable to store 2 nibble at a time

***
* Beginning of the program
***

    ORG    $1000
START:                  ; first instruction of program

********************************************************************************
*****************************************
* Start of input and parsing op code section
*****************************************
********************************************************************************

***
* Display welcome prompt to user and ask for starting address
***
GET_START_ADDRESS
    LEA         INTRO_STARTING,A1                       * Welcome the user
    MOVE.B      #13,D0                                  * Nice to have carry and line feed
    TRAP        #15
    MOVEA.L     #0,A1                                   * Clear what is in A1
    LEA         FIFTH_TEMP_VAR,A1                       * This was made so that when we read a string, it won't overide (A1)
    CLR         D0
    CLR         D1
    MOVE.B      #2,D0                                   * Get a string input that represent the user
    TRAP        #15
    BRA         CONVERT_ASCII_TO_HEX

***
* Display prompt to user and ask for ending address
***
GET_END_ADDRESS
    LEA         INTRO_ENDING,A1                         * Now time to get the ending address
    MOVE.B      #13,D0
    TRAP        #15
    LEA         FOURTH_TEMP_VAR,A1                      *Same like get starting address
    MOVE.B      #2,D0
    TRAP        #15
    BRA         CONVERT_ASCII_TO_HEX

***
* Parsing 4 nibbles sequentially and decoding them based on the first nibble (left most)
***
PARSING_OP_CODE
    JSR         PRINT_ADDRESS_LOCATION
    JSR         GET_NEXT_FOUR_NIBBLE
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_FIRST_NIBBLE
    MULU        #6,D3                                   * Get the index
    JSR         0(A0,D3)                                * Jump to the table depemding on first nibble
    SIMHALT

***
*This is called during the first part of program, when trying to convert user starting and ending address
* Convert 0-9 and A-F in ASCII to Hex Value
*ascii table http://www.asciitable.com/
***
CONVERT_ASCII_TO_HEX
    MOVE.B      (A1)+,D0                                * Go through each byte of the address
    CMP.B       #$30,D0                                 * Valid data are from $30 - $39 ( 0-9) and $41 - $46 (A-F)
    BLT         ERROR_INVALID_INPUT
    CMP.B       #$39,D0                                 * check if in the range number of hex character
    BGT         CONVERT_CHARACTER_ASCII_TO_HEX
    SUB.B       #$30,D0                                 * Get the hex range from '0-9'
    ADD.L       D0,D3
    SUBI        #1,D1                                   * Decrement the counter for length of address
    CMP.B       #0,D1
    BEQ         FINISH_CONVERT_STARTING_ADDRESS
    LSL.L       #4,D3                                   * Get space for next nibble
    BRA         CONVERT_ASCII_TO_HEX

***
* Convert A-F in ASCII to hex value
***
CONVERT_CHARACTER_ASCII_TO_HEX
    CMP.B       #$41,D0                                 * At this point, the data must be larger than number
    BLT         ERROR_INVALID_INPUT                     * Only $41 - 46 are valid
    CMP.B       #$46,D0
    BGT         ERROR_INVALID_INPUT                     * Greater than $46, nope
    SUB.B       #$37,D0                                 * Get the A-F value
    ADD.L       D0,D3                                   * Save the value
    SUBI        #1,D1                                   * Decrement the counter
    CMP.B       #0,D1
    BEQ         FINISH_CONVERT_STARTING_ADDRESS
    LSL.L       #4,D3                                   * Shift the value to the left 4 bits to save room for another nibble
    BRA         CONVERT_ASCII_TO_HEX

***
*   Save the starting addres to an appropriate place and also test if it is valid
***
FINISH_CONVERT_STARTING_ADDRESS
    BTST        #0,D3                                   * Test last bit of the address to see if it is even or odd
    BNE         INVALID_STARTING_ADDRESS
    CMP         #1,D2                                   * Check if we are doing starting or ending address
    BEQ         FINISH_CONVERT_ENDING_ADDRESS
    ADDI        #1,D2                                   * Counter to make sure that we are doing the ending address
    MOVE.L      D3,STARTING_ADDRESS
    BRA         GET_END_ADDRESS

***
* Save the ending address to an appropriate place and also test if it is valid
***
FINISH_CONVERT_ENDING_ADDRESS
    BTST        #0,D3                                   * Check for odd address
    BNE         INVALID_ENDING_ADDRESS
    CMP.L       STARTING_ADDRESS, D3                    * Check if the ending address is less than or equal starting address
    BLE         INVALID_ENDING_ADDRESS
    CLR.W       D2                                      * Clear the second data register for future use
    MOVE.L      D3,ENDING_ADDRESS
    CLR.W       D3
    LEA         SPACE,A1
    MOVE.B      #13,D0
    TRAP        #15
    BRA         PREPARE_START_AND_END_ADDRESS
    SIMHALT

***
* Display the prompt invalid and ask user to enter again for invalid starting address
***
INVALID_STARTING_ADDRESS
    MOVEA.L     #0,A1
    LEA         INVALID_INPUT,A1
    MOVE.B      #13,D0
    TRAP        #15
    CLR         D3
    BRA         GET_START_ADDRESS

***
* Display the prompt invalid and ask user to enter again for ending address
***
INVALID_ENDING_ADDRESS
    MOVEA.L     #0,A1
    LEA         INVALID_INPUT,A1
    MOVE.B      #13,D0
    TRAP        #15
    CLR         D3
    BRA         GET_END_ADDRESS

***
* Used to direct invalid address entered either to invalid starting or ending address
***
ERROR_INVALID_INPUT
    CMP         #1,D2
    BEQ         INVALID_ENDING_ADDRESS
    BRA         INVALID_STARTING_ADDRESS

***
* This is usally called during the program's execution.
* Used for printing out address location, immediate data, absolute short and long ,..etc
* Print out each nibble at a time (4 nibbles total)
***
CONVERT_HEX_TO_ASCII
    LEA         HEX_CHARACTER_JUMP_TABLE,A4             * Load the table to print out ascii charracter
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_FIRST_NIBBLE                    * Get the left most hex value and convert
    MULU        #6,D3
    JSR         0(A4,D3)
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    MULU        #6,D3
    JSR         0(A4,D3)
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_THIRD_NIBBLE
    MULU        #6,D3
    JSR         0(A4,D3)
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_FOURTH_NIBBLE
    MULU        #6,D3
    JSR         0(A4,D3)
    CLR.W       D3
    RTS


***
* Called when starting and ending address was entered and converted correctly
***
PREPARE_START_AND_END_ADDRESS
    LEA         FIRST_NIBBLE_JUMP_TABLE,A0              * Prepare the jump table for first nibble decoding
    MOVE.L      STARTING_ADDRESS,A2
    MOVE.L      ENDING_ADDRESS,A3
    BRA         PARSING_OP_CODE                         * Start parsing the opcode now

***
* Wait for the user to press enter to continue
***
USER_INPUT_ENTER
    ADD         #1,D6
    CMP         #30,D6 * Need to run this 30 times (3o statements before user need to enter)
    BEQ         PRESS_ENTER_TO_CONTINUE
    LEA         SPACE,A1
    MOVE        #13,D0
    TRAP        #15
    RTS

PRESS_ENTER_TO_CONTINUE
    MOVE        #0,D6
    MOVE.B      #5,D0
    TRAP        #15
    RTS

********************************************************************************
*********************************************
* Print the decoded opcode and data to console
* This section will also be the place where most of the logic is done
*********************************************
********************************************************************************


***
* Called when an invalid instructions or data accessing mode was encounterd
***
INVALID
    LEA         DATA_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_HEX_SYMBOL
    JSR         CONVERT_HEX_TO_ASCII                    * Print out the op code that was not decoded
    LEA         SPACE,A1 * Go to new line
    MOVE.B      #14,D0
    TRAP        #15
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE                         * Get the next four nibbles and parsing

***
* Print out the NEG Instruction with only 1 operands to follow
***
PRINT_OUT_NEG
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_NORMAL_SIZE
    CMP         #%11,D3
    BEQ         INVALID                                 * NEG can only have normal size ,01,00,10
    LEA         NEG_VALUE,A1                            * Print NEG to screen
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_NORMAL_SUFFIX
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA                         * Extract the mode and register
    JSR         PRINT_DATA_MODE_SOURCE
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the NOP instructions with no operands to follow
***
PRINT_OUT_NOP
    LEA         NOP_VALUE,A1 * Display the NOP message
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the RTS instruction with no operands to follow
***
PRINT_OUT_RTS
    LEA         RTS_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the ORI to SR instruction
* Unfinished implementation
***
PRINT_OUT_ORI_TO_SR
    LEA         ORI_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the JSR instructions with the address to jump to
* This will print out the actual address, not just the displacement
***
PRINT_OUT_JSR
    LEA         JSR_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING           * Now query what type of data to print out, source or destination
    JSR         PRINT_EMPTY_SPACE
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         PRINT_DATA_MODE_SOURCE                  * Print the M and N of the last 6 bits
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE

***
* Print out the CMPI instruction
***
PRINT_OUT_CMPI
    LEA         CMPI_VALUE,A1                           * Print out the literal value
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         PRINT_NORMAL_SUFFIX
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_IMMEDIATE_DATA_SYMBOL
    JSR         GET_NORMAL_SIZE                         * Get the size of the operation to know how much byte should we advance forward
    LSR         #1, D3                                  * For cmpi.b and cmpi.w, they all map to absolute short in which print only 4
    MOVE.W      D3, THIRD_TEMP_VAR
    JSR         CHECK_TYPE_DATA                         * Now byte and word will be printed 4 space where as long will be printed 5 space
    JSR         REGISTER_MODE_111                       * Print out the immediate value
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_MODE_SOURCE
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print the suffix that represent size within the opcode
* This is only used for MOVE and MOVEM instructions where the size for byte, word ,long are 01,11,10
***
PRINT_NOT_NORMAL_SUFFIX
    LEA         NORMAL_SIZE_PRINT_JUMP_TABLE,A4
    MULU        #6,D3
    JSR         0(A4,D3)
    CLR         D3
    RTS

***
* Print the suffix that represent the NORMAL size within the op code
* The normal size are usually found at the first 2 bit at the third nibble
* For byte, word, long, the size are : 00,01,10
***
PRINT_NORMAL_SUFFIX
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_NORMAL_SIZE
    LEA         NORMAL_SIZE_PRINT_JUMP_TABLE,A4
    CMP         #%11,D3                                 * For normal size, does not take 11
    BEQ         INVALID
    MULU        #6,D3
    JSR         0(A4,D3)                                * Print out appropriate suffix
    RTS

***
* Print out the register number (Xn)
* Need to put the register number into THIRD_TEMP_VAR first
* Could be the data source or data destination that call this method
***

PRINT_REGISTER_NUMBER
    LEA         HEX_CHARACTER_JUMP_TABLE,A4
    MOVE.W      THIRD_TEMP_VAR,D3
    MULU        #6,D3
    JSR         0(A4,D3)
    CLR.W       THIRD_TEMP_VAR
    CLR.W       D3
    RTS

***
* Print out the LEA instruction
***
PRINT_OUT_LEA
    LEA         LEA_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         PRINT_DATA_MODE_SOURCE
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_ADDRESS_REGISTER                  * Already know the LEA can only take use of Address register
    MOVE.W      DESTINATION_VAR,THIRD_TEMP_VAR          * Store the register number to print
    JSR         PRINT_REGISTER_NUMBER
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the ADDQ instruction
* Utilized a helper method because ADDQ and SUBQ are the same
***
PRINT_OUT_ADDQ
    LEA         ADDQ_VALUE,A1
    BRA         ADDQ_AND_SUBQ_HELPER

***
* Print out the SUBQ instruction
* Utilized a helper method because ADDQ and SUBQ are the same
***
PRINT_OUT_SUBQ
    LEA         SUBQ_VALUE,A1
    BRA         ADDQ_AND_SUBQ_HELPER

***
* Helper method for ADDQ and SUBQ
***
ADDQ_AND_SUBQ_HELPER
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_NORMAL_SUFFIX
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_IMMEDIATE_DATA_SYMBOL
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    CMP         #0, DESTINATION_VAR                     * In the case of 8, the destination var is 000. But we want to print out 8
    BEQ         SUBQ_HELPER_FUNCTION                    * If it is the case, then move to another helper to move 8 directly into it
    MOVE.W      DESTINATION_VAR,THIRD_TEMP_VAR          * Save the value to print out from print register number
    JSR         PRINT_REGISTER_NUMBER                   * Print out the data from 1-8
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_MODE_SOURCE
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Helper method to print out 8 for ADDQ and SUBQ
***
SUBQ_HELPER_FUNCTION                                    * Single function that exist to help with printing oout the data in SUBQ
    MOVE.W      #8, THIRD_TEMP_VAR
    JSR         PRINT_REGISTER_NUMBER
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_MODE_SOURCE
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the DIVS instruction
***
PRINT_OUT_DIVS
    LEA         DIVS_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_NORMAL_WORD_SUFFIX                * DIVS can only take word suffix
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_MODE_SOURCE
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_REGISTER                     * DIVS can only use Data register
    MOVE.W      DESTINATION_VAR, THIRD_TEMP_VAR         * Store the register number Dn to print out
    JSR         PRINT_REGISTER_NUMBER
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the MULS instruction
***
PRINT_OUT_MULS
    LEA         MULS_VALUE,A1
    BRA         MULS_AND_MULU_HELPER

***
* Helper method for MULS and MULU instruction
***
MULS_AND_MULU_HELPER
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_NORMAL_WORD_SUFFIX
    JSR         PRINT_EMPTY_SPACE
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    MOVE.W      #%01, DESTINATION_MODE                  * Change the size of to word to print out
    JSR         PRINT_DATA_MODE_SOURCE
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_REGISTER
    MOVE.W      DESTINATION_VAR,THIRD_TEMP_VAR          * Save the register number
    JSR         PRINT_REGISTER_NUMBER
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the MULU instruction
* Utilized a helper method
***
PRINT_OUT_MULU
    LEA         MULU_VALUE,A1
    BRA         MULS_AND_MULU_HELPER

***
* Print out the CMP instructions
***
PRINT_OUT_CMP
    LEA         CMP_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_NORMAL_SUFFIX
    JSR         PRINT_EMPTY_SPACE
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         PRINT_DATA_MODE_SOURCE
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_REGISTER                     * CMP can only use Data register
    MOVE.W      DESTINATION_VAR,THIRD_TEMP_VAR
    JSR         PRINT_REGISTER_NUMBER
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the MOVEQ instructions
***
PRINT_OUT_MOVEQ
    LEA         MOVEQ_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_NORMAL_LONG_SUFFIX                * Can only use long suffix
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D1               * Save the current opcode
    JSR         PRINT_IMMEDIATE_DATA_SYMBOL
    JSR         PRINT_HEX_SYMBOL
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    LSL         #8,D3
    LSR         #8,D3
    MOVE.W      D3, TEMP_CURRENT_4_NIBBLES              * Get the last 2 nibbles that represents that data to print out
    JSR         CONVERT_HEX_TO_ASCII                    * Print the 8 bit data field
    MOVE.W      D1, TEMP_CURRENT_4_NIBBLES
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3               * Restore the data
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         PRINT_DATA_REGISTER                     * Can only use Data Register
    MOVE.W      DESTINATION_VAR, THIRD_TEMP_VAR         * Store the register number to print out
    JSR         PRINT_REGISTER_NUMBER
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE

***
* Print out SUBA instruction
* Utilied a helper method
***
PRINT_OUT_SUBA
    LEA         SUBA_VALUE,A1
    BRA         SUBA_AND_ADDA_HELPER

***
* Print out ADDA instrucion
* Utilized a helper method
***
PRINT_OUT_ADDA
    LEA         ADDA_VALUE,A1
    BRA         SUBA_AND_ADDA_HELPER

***
* Helper method for ADDA ans SUBA
***
SUBA_AND_ADDA_HELPER
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_THE_SECOND_NIBBLE
    LSL         #8,D3                                   * Get the special one bit size of ADDA and SUBA
    LSL         #7,D3
    LSR         #7,D3
    LSR         #8,D3
    ADD         #1,D3                                   * 0 is word and 1 is long. Add 1 will be 01 and 10, word and long for normal size
    JSR         PRINT_NOT_NORMAL_SUFFIX                 * Now print .W or .L only
    JSR         PRINT_DATA_MODE_SOURCE
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_ADDRESS_REGISTER
    MOVE.W      DESTINATION_VAR, THIRD_TEMP_VAR         * Save the variable to print out the number of address register
    JSR         PRINT_REGISTER_NUMBER
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the OR instruction
* Utilized helper method of ADD and SUB
***
PRINT_OUT_OR
    LEA         OR_VALUE,A1
    BRA         ADD_AND_SUB_HELPER                      * Take advantage of the similar structure like add and sub

***
* Print out the ADD instruction
* Utilized a helper method
***
PRINT_OUT_ADD           * Function similar like SUB
    LEA         ADD_VALUE,A1
    BRA         ADD_AND_SUB_HELPER

***
* Print out the SUB instructions
* Utilized a helper method
***
PRINT_OUT_SUB
    LEA         SUB_VALUE,A1
    BRA         ADD_AND_SUB_HELPER


***
* Helper method for SUB and ADD
* The SUB function is odd is that the Dn is always in front
* So to distinguish it, we need to check the source mode and compare wit 000
* Only time where the source and dstiantion are in correct position
* This method is when both are data register
***
ADD_AND_SUB_HELPER
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_NORMAL_SUFFIX
    JSR         PRINT_EMPTY_SPACE
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    CMP         #0, SOURCE_MODE
    BNE         SUB_HELPER_FUNCTION                         * Utilize the not normal approach
    JSR         PRINT_DATA_MODE_SOURCE
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_REGISTER
    MOVE.W      DESTINATION_VAR, THIRD_TEMP_VAR
    JSR         PRINT_REGISTER_NUMBER
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Helper for the helper method of ADD and SUB
* Used to handle cases with data register
* For whatever the data register is always the first 3 bit of the second nibble
* Even though it can either be in the source or destination when write it
* This method is when they are not both data register
***
SUB_HELPER_FUNCTION
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3                   * Need to swap places to print out
    JSR         CHECK_TYPE_DATA
    MOVE.W      DESTINATION_VAR,D3
    MOVE.W      SOURCE_VAR,DESTINATION_VAR
    MOVE.W      D3,SOURCE_VAR
    MOVE.W      DESTINATION_MODE,D3
    MOVE.W      SOURCE_MODE,DESTINATION_MODE
    MOVE.W      D3,SOURCE_MODE
    MOVE.W      SOURCE_MODE, D3
    MOVE.W      SOURCE_VAR, THIRD_TEMP_VAR                  * Save the variable to print out from register
    LSR         #2,D3
    CMP         #0,D3                                       * Check direction to know which order we should be printing
    BEQ         SUB_HELPER_REGISTER_TO_MEM
    JSR         REGISTER_MODE_000                           * Need to find a way to switch the places
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_MODE_DESTINATION
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Helper method to help with printing from register to memory
***
SUB_HELPER_REGISTER_TO_MEM
    MOVE.W      DESTINATION_VAR, THIRD_TEMP_VAR
    JSR         PRINT_DATA_MODE_DESTINATION
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    MOVE.W      SOURCE_VAR, THIRD_TEMP_VAR
    JSR         REGISTER_MODE_000
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the BRA instruction
* Current limitation: Only can print out branch to a word address (4bytes).No support for 8 bytes
***
PRINT_OUT_BRA
    LEA         BRA_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_HEX_SYMBOL
    MOVE.W      A2,D4                                       * Save the current address we are at
    JSR         GET_NEXT_FOUR_NIBBLE                        * Get the displacement we are suppose to branch to
    ADD         D3,D4                                       * Current address + displacement => address we are suppose to jump to
    MOVE.W      D4, TEMP_CURRENT_4_NIBBLES                  * Prepare the address to print out in hex
    JSR         CONVERT_HEX_TO_ASCII
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE

***
* Print out the BSR instruction
* limitation: Same like BRA
***
PRINT_OUT_BSR
    LEA         BSR_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_HEX_SYMBOL
    MOVE.W      A2,D4
    JSR         GET_NEXT_FOUR_NIBBLE
    ADD         D3,D4
    MOVE.W      D4,TEMP_CURRENT_4_NIBBLES
    JSR         CONVERT_HEX_TO_ASCII
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE

***
* Print out the appropriate Bcc instruction using a jump table
***
PRINT_OUT_Bcc
    LEA         B,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    LEA         CONDITION_JUMP_TABLE,A6                     * Load the jump table to know which condition code to print
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    MULU        #6,D3
    JSR         0(A6,D3)                                    * Now print out the suffix of B
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_HEX_SYMBOL
    MOVE.W      A2,D4                                       * Print out the address
    JSR         GET_NEXT_FOUR_NIBBLE
    ADD         D3,D4
    MOVE.W      D4,TEMP_CURRENT_4_NIBBLES
    JSR         CONVERT_HEX_TO_ASCII
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE

***
* Logical Shift instruction with single operand memory <ea>
***
PRINT_OUT_LOGICAL_SHIFT_MEM
    LEA         LS_VALUE,A1
    JSR         ASD_LSD_ROD_SHIFT_HELPER
    RTS

***
* Arithmeic shift instruction with single operand memory <ea>
***
PRINT_OUT_ARITH_SHIFT_MEM
    LEA         AS_VALUE,A1
    JSR         ASD_LSD_ROD_SHIFT_HELPER
    RTS

***
* Helper method for ASd, LSd, ROd
***
ASD_LSD_ROD_SHIFT_HELPER
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    LEA         RIGHT_OR_LEFT_JUMP_TABLE,A6                 * Print the direction, left or right
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_THE_SECOND_NIBBLE
    LSL         #8,D3
    LSL         #7,D3
    LSR         #7,D3
    LSR         #8,D3
    MULU        #6,D3
    JSR         0(A6,D3)                                    * Print out left or right
    JSR         PRINT_NORMAL_WORD_SUFFIX
    MOVE.W      SOURCE_VAR, THIRD_TEMP_VAR                  * Save the register number in case for print OUT
    JSR         PRINT_DATA_MODE_SOURCE
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print out the ROd instruction with operand memory <ea>
***
PRINT_OUT_ROTATE_MEM
    LEA         RO_VALUE,A1
    JSR         ASD_LSD_ROD_SHIFT_HELPER
    RTS

***
* print out the ASd and LSd with other cases
* ASL Dx, Dy for example
* ASL #<data>, Dy
***
PRINT_OUT_ASD_OR_LSD                                * For other ASd and LSd, the first  bit of the last nibble can be used to differentiate them
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_FOURTH_NIBBLE
    LSR         #3,D3
    CMP         #0,D3
    BEQ         PRINT_OUT_ASD                       * First bit is 0 for ASD
    BRA         PRINT_OUT_LSD                       * 1 for LSD
    RTS

***
* Print out the ASD instruction with other cases
* ASL Dx, Dy
* ASL #<data>, Dy
***
PRINT_OUT_ASD
    LEA         AS_VALUE,A1
    JSR         ASD_LSD_ROD_HELPER_FUNCTION
    RTS

***
* Print out the LSd instruction with other cases
* LSR Dx, Dy
* LSR #<data>, Dy
***
PRINT_OUT_LSD
    LEA         LS_VALUE,A1
    JSR         ASD_LSD_ROD_HELPER_FUNCTION
    RTS

***
* Print out the ROd instruction with other cases
* ROL Dx, Dy
* ROL #<data>, Dy
***
PRINT_OUT_ROD
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_FOURTH_NIBBLE
    LSR         #3,D3
    CMP         #1,D3
    BNE         INVALID                                     * ROD ibly accept 1 as the first bit in the fourth nibbles
    LEA         RO_VALUE,A1
    JSR         ASD_LSD_ROD_HELPER_FUNCTION
    RTS

***
* ASd, LSd, ROd instruction with other cases with 2 operands source and destionation
***
ASD_LSD_ROD_HELPER_FUNCTION   *
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    LEA         RIGHT_OR_LEFT_JUMP_TABLE,A6                 * Print the direction, left or right
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_THE_SECOND_NIBBLE
    LSL         #8,D3
    LSL         #7,D3
    LSR         #8,D3
    LSR         #7,D3
    MULU        #6,D3
    JSR         0(A6,D3)                                    * Print out left or right
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         PRINT_NORMAL_SUFFIX                         * Print out .B, .W or .L
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3                   * Now we need to determine if its is immediate or register rotation
    JSR         GET_THE_THIRD_NIBBLE
    LSL         #8,D3
    LSL         #6,D3
    LSR         #8,D3
    LSR         #7,D3                                       * Now the third bit will be at the last position
    LEA         IMMEDIATE_OR_REGISTER_JUMP_TABLE,A6
    MULU        #6,D3
    JSR         0(A6,D3)
    JSR         PRINT_DATA_REGISTER
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    MOVE.W      SOURCE_VAR,THIRD_TEMP_VAR                   * Save the register number to print out
    JSR         PRINT_REGISTER_NUMBER
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
*  Decide whether to print move or move a based the 3 bit at the destination mode
***
MOVE_OPCODE_HELPER
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    CMP         #%001, DESTINATION_MODE
    BEQ         PRINT_OUT_MOVEA
    BRA         PRINT_OUT_MOVE
    RTS

***
* Print out MOVEA
* UTilized a helper method
***
PRINT_OUT_MOVEA
    LEA         MOVEA_VALUE,A1
    JSR         MOVE_SECOND_OPCODE_HELPER

***
* Print out MOVE
* Utlized a helper method
***
PRINT_OUT_MOVE
    LEA         MOVE_VALUE,A1
    JSR         MOVE_SECOND_OPCODE_HELPER

***
* Helper method for MOVE and MOVEA
***
MOVE_SECOND_OPCODE_HELPER
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    LEA         MOVE_SIZE_PRINT_JUMP_TABLE,A6                   * Special size for move instruction
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_FIRST_NIBBLE
    MULU        #6,D3
    JSR         0(A6,D3)
    JSR         PRINT_DATA_MODE_SOURCE
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    JSR         PRINT_DATA_MODE_DESTINATION
    BSR         USER_INPUT_ENTER
    BRA         PARSING_OP_CODE
    RTS

***
* Print whatever is stored in A1
***
PRINT_TO_SCREEN_ENTIRE_STRING
    MOVE.B      #14,D0
    TRAP        #15
    RTS

***
* Print the data containeds at the last 6 bit of op code
* Destionation var - destionation mode- source mode - source var
***
PRINT_DATA_MODE_SOURCE         * Depnding on the mode, will print out appropriate data mode: Dn,An,(An),...
    LEA         REGISTER_MODE_JUMP_TABLE,A6
    MOVE.W      SOURCE_VAR, THIRD_TEMP_VAR
    MOVE        SOURCE_MODE,D3
    MULU        #6,D3
    JSR         0(A6,D3)       * Let's see what mode is this source mode
    RTS
***
* Print the data contains in the 12-7 bit of op code
* Destionation var - destionation mode - source mode - source var
***
PRINT_DATA_MODE_DESTINATION
    LEA         REGISTER_MODE_JUMP_TABLE,A6
    MOVE.W      DESTINATION_VAR, THIRD_TEMP_VAR             * Determine the Xn to print
    MOVE.W      DESTINATION_MODE,D3
    MULU        #6,D3
    JSR         0(A6,D3)
    RTS

***
* Print out the address in which we are executing the disassembli
* Should print out 00XX YYYY as the address location
***
PRINT_ADDRESS_LOCATION
    MOVE.L      A2,D5 * Save the address we are at
    LSR         #8,D5                                       * Shift 4 bytes left most to print out
    LSR         #8,D5
    MOVE.W      D5,TEMP_CURRENT_4_NIBBLES                   * Get the entire long address
    JSR         CONVERT_HEX_TO_ASCII
    MOVE.W      A2,D5
    MOVE.W      D5,TEMP_CURRENT_4_NIBBLES
    JSR         CONVERT_HEX_TO_ASCII
    JSR         PRINT_EMPTY_SPACE
    RTS

***
* Print ','
***
PRINT_COMMA
    LEA         COMMA,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* Print 'A'
***
PRINT_ADDRESS_REGISTER
    LEA         ADDRESS_REGISTER,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* Print 'D'
***
PRINT_DATA_REGISTER
    LEA         DATA_REGISTER,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* Print '('
***
PRINT_OPEN_BRACKET
    LEA         OPENING_BRACKET,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* Print ')'
***
PRINT_CLOSE_BRACKET
    LEA         CLOSING_BRACKET,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* Print '+'
***
PRINT_PLUS_SIGN
    LEA         PLUS_SIGN,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* Print '-'
***
PRINT_MINUS_SIGN
    LEA         MINUS_SIGN,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* print '$'
***
PRINT_HEX_SYMBOL
    LEA         HEX_SYMBOL,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* Print ' '
***
PRINT_EMPTY_SPACE
    LEA         SPACE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

***
* Print '#'
***
PRINT_IMMEDIATE_DATA_SYMBOL
    LEA         IMMEDIATE_DATA_SYMBOL,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

*******************************************************************************
***************************************
* Query data section
* Contains utility methods
***************************************
*******************************************************************************

***
* Get the left most byte. Assuming that the full word data is already store in D3
***
GET_THE_FIRST_NIBBLE
    LSR         #8,D3                               * Shift 2 bytes to the rights
    LSR         #4,D3                               * Shift 1 byte to the right. Now left most byte is now the right most byte
    RTS

***
* Get the second nibble from the left
***
GET_THE_SECOND_NIBBLE
    LSL         #4,D3                               * Shift the left most byte to go away
    LSR         #4,D3                               * Return the original place
    LSR         #8,D3                               * Push the 2 right most byte out of the way
    RTS

***
* Get the third nibble from the left
***
GET_THE_THIRD_NIBBLE
    LSL         #8,D3                               * Bye byte 2 left most nibble
    LSR         #8,D3                               * Get rid of the 3 bytes that are infront
    LSR         #4,D3                               * Shift back to original position
    RTS

***
* Get the fourth nibble from the left
***
GET_THE_FOURTH_NIBBLE
    LSL         #8,D3
    LSL         #4,D3
    LSR         #8,D3
    LSR         #4,D3
    RTS

***
* Advance 2 bytes for Word ( 4 nibbles)
***
GET_NEXT_FOUR_NIBBLE
    MOVE.W      (A2)+,D3
    MOVE.W      D3, TEMP_CURRENT_4_NIBBLES          * Copy the value into temp variable
    CMPA.L      A2,A3                               * Check the starting and ending address if we have surpass it
    BLE         FINISH_DISASSEMBLING
    RTS

***
* Advance 1 byte for word (2 nibbles)
***
GET_NEXT_TWO_NIBBLE
    MOVE.B      (A2)+,D3                            * Get the next byte ( 2 nibbles)
    MOVE.B      D3, TEMP_CURRENT_2_NIBBLES
    RTS

***
* Get the normal size in the opcode, usually the first 2 bit of the third nibble
***
GET_NORMAL_SIZE
    JSR         CHECK_TYPE_DATA
    MOVE.W      DESTINATION_MODE,D3
    LSL         #8,D3
    LSL         #6,D3
    LSR         #8,D3
    LSR         #6,D3
    RTS

***
* Display prompt saying that it has finished disassembling
***
FINISH_DISASSEMBLING
    LEA         SPACE,A1
    MOVE.B      #13,D0
    TRAP        #15
    LEA         FINISH,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    SIMHALT

*******************************************************************************
* logical reasoning section (determine what kind of opcode to print, what type of data to print)
*******************************************************************************


***
* getting the appropriate source and destination register  and mode
* Destionation var - destionation mode - source mode - soruce var
***
CHECK_TYPE_DATA
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    LSL         #4,D3                               * Get rid of left most byte
    LSR         #4,D3                               * Now focus on the following format      destination mode mode source. Start with destination first
    LSR         #8,D3                               * Now the D3 has the destination
    LSR         #1,D3
    MOVE.W      D3,DESTINATION_VAR
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3           * Now go with the destination mode
    LSL         #7,D3
    LSR         #7,D3
    LSR         #6,D3
    MOVE.W      D3,DESTINATION_MODE
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3           * Now extract the source mode
    LSL         #8,D3
    LSL         #2,D3
    LSR         #8,D3
    LSR         #2,D3
    LSR         #3,D3
    MOVE.W      D3,SOURCE_MODE                      * Now extract the source
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    LSL         #8,D3
    LSL         #5,D3
    LSR         #8,D3
    LSR         #5,D3
    MOVE.W      D3,SOURCE_VAR
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    RTS

***
* Reasoning section for NOP, JSR, RTS
***
FIRST_NIBBLE_4_SECOND_NIBBLE_E
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    LSL         #8,D3                               * Shift to the left to dissappear 2 left most byte
    LSR         #8,D3                               * Shift to the right to gain back original position. Only now the 2 left most byte are gone
    CMP.B       #$71,D3                             * NOP is 4E71
    BEQ         PRINT_OUT_NOP
    CMP.B       #$75,D3                             *RTS is 4E75
    BEQ         PRINT_OUT_RTS
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA                     *  Get the destination mode and desitnation register. Could be JSR
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_THIRD_NIBBLE                * For Jsr  the 2 bit of the 3rd nibble is 10
    LSR         #2, D3
    CMP         #%10, D3
    BEQ         PRINT_OUT_JSR                       * Print out the command JSR and the data
    BRA         INVALID
    RTS

********************************************************************************
* Specific branching of the jump table is stored here
*******************************************************************************
FIRST_NIBBLE_JUMP_TABLE                  * Based on the first byte of the op code then jump on what is possible
    JMP         FIRST_NIBBLE_IS_0               * ORI, CMPI. BCLR
    JMP         FIRST_NIBBLE_IS_1               * MOVE.B, MOVEA.B
    JMP         FIRST_NIBBLE_IS_2               * MOVEA.L, MOVE.L
    JMP         FIRST_NIBBLE_IS_3               * MOVE.W    MOVEA.W
    JMP         FIRST_NIBBLE_IS_4               * NOP, LEA, NEG, JSR, RTS
    JMP         FIRST_NIBBLE_IS_5               * SUBQ
    JMP         FIRST_NIBBLE_IS_6               * BCS, BGE, BLT, BVC, BRA
    JMP         FIRST_NIBBLE_IS_7               * NOT SUPPORTED
    JMP         FIRST_NIBBLE_IS_8               * DIVS, OR
    JMP         FIRST_NIBBLE_IS_9               * SUB
    JMP         FIRST_NIBBLE_IS_A               * NOT SUPPORTED
    JMP         FIRST_NIBBLE_IS_B               * EOR, CMP
    JMP         FIRST_NIBBLE_IS_C               * MULS
    JMP         FIRST_NIBBLE_IS_D               * ADD, ADDA
    JMP         FIRST_NIBBLE_IS_E               * LSR, LSL, ASR, ASL, ROL, ROR
    JMP         FIRST_NIBBLE_IS_F               * NOT SUPPORTED

FIRST_NIBBLE_IS_0
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    CMP         #$C, D3
    BEQ         PRINT_OUT_CMPI
    BRA         INVALID
    RTS


FIRST_NIBBLE_IS_1 *MOVE.B, MOVEA.B * Can only be MOVE for these nibble because of the size of MOVE
    JSR         MOVE_OPCODE_HELPER
    SIMHALT

FIRST_NIBBLE_IS_2 *MOVE.L, MOVEA.L
    JSR         MOVE_OPCODE_HELPER
    SIMHALT

FIRST_NIBBLE_IS_3 * MOVE.W, MOVEA.W
    JSR         MOVE_OPCODE_HELPER
    SIMHALT

FIRST_NIBBLE_IS_4                                       * Possible for NOP,LEA,RTS,JSR,NEG. Now will check the second byte
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3               * Get the original op code back
    JSR         GET_THE_SECOND_NIBBLE
    CMP.B       #$E,D3
    BEQ         FIRST_NIBBLE_4_SECOND_NIBBLE_E          * NOP,RTS,JSR
    CMP.B       #4,D3                                   *If the second nibble is 4, then it must be neg
    BEQ         PRINT_OUT_NEG
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    CMP         #%111,DESTINATION_MODE
    BEQ         PRINT_OUT_LEA                           * Only LEA have the 3 bits of destination is 111
    BRA         INVALID
    RTS

FIRST_NIBBLE_IS_5                                       * This is SUBQ and ADDQ
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORMAL_SIZE                         * SUBQ and ADDQ only accpet normal size. Meaning no 11
    CMP         #%11,D3
    BEQ         INVALID
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    LSL         #8,D3                                   * Get rid of the first 2 byets
    LSL         #7,D3                                   * Shift back to original position
    LSR         #8,D3
    LSR         #7,D3
    CMP         #0,D3                                   * SUBQ have 1 as the last bit in the second nibble
    BEQ         PRINT_OUT_ADDQ                          * ADDQ has 0 as the last bit in the second nibble
    BRA         PRINT_OUT_SUBQ
    RTS
    SIMHALT

FIRST_NIBBLE_IS_6                                       * Bcc and BRA , BSR
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    CMP         #%0000,D3                               * Only the condition code of BRA is 0000
    BEQ         PRINT_OUT_BRA
    CMP         #%0001,D3
    BEQ         PRINT_OUT_BSR
    BRA         PRINT_OUT_Bcc
    RTS
    SIMHALT

FIRST_NIBBLE_IS_7                                       * This is MOVEQ
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    LSL         #8,D3
    LSL         #7,D3
    LSR         #8,D3
    LSR         #7,D3
    CMP         #0,D3
    BEQ         PRINT_OUT_MOVEQ
    BRA         INVALID
    SIMHALT

FIRST_NIBBLE_IS_8                                       * DIVS, Can't recognize SBCD
    MOVE.W      TEMP_CURRENT_4_NIBBLES, D3
    JSR         CHECK_TYPE_DATA
    CMP         #%111, DESTINATION_MODE
    BEQ         PRINT_OUT_DIVS
    CMP         #%011, DESTINATION_MODE
    BEQ         INVALID                                 * This is DIVU
    BRA         PRINT_OUT_OR
    RTS
    SIMHALT

FIRST_NIBBLE_IS_9                                       * SUB and SUBA           * No way of knowing SUX
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORMAL_SIZE
    CMP         #%11,D3
    BEQ         PRINT_OUT_SUBA                          * SUB Does not accept the size of 11
    BRA         PRINT_OUT_SUB
    SIMHALT

FIRST_NIBBLE_IS_A                                       * There are not any opcode with 1010
    BRA         INVALID
    SIMHALT

FIRST_NIBBLE_IS_B                                       * CMP
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORMAL_SIZE
    CMP         #%11, D3
    BEQ         INVALID                                 * CMP does not accept size 11
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    LSL         #8,D3                                   * Get the last bit of the second nibble
    LSL         #7,D3
    LSR         #7,D3
    LSR         #8,D3
    CMP         #0,D3                                   * CMP only accept 0 as the last bit in the second nibble
    BNE         INVALID
    BRA         PRINT_OUT_CMP
    SIMHALT

FIRST_NIBBLE_IS_C                                       * MULS and MULU
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORMAL_SIZE
    CMP         #%11,D3
    BNE         INVALID                                 * MULS only accept 11 as the size
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    LSL         #8,D3                                   * Get the last bit of the second
    LSL         #7,D3
    LSR         #7,D3
    LSR         #8,D3
    CMP         #1,D3                                   * If it is 1, then it is MULS. Otherwise MULU
    BEQ         PRINT_OUT_MULS
    BRA         PRINT_OUT_MULU
    RTS
    SIMHALT

FIRST_NIBBLE_IS_D *ADD, ADDA                            * Have no way of knowing ADDX
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORMAL_SIZE
    CMP         #%11,D3
    BEQ         PRINT_OUT_ADDA
    BRA         PRINT_OUT_ADD
    RTS
    SIMHALT

FIRST_NIBBLE_IS_E                                       * There are 2 types for every LSL,LSR,ASL,ASR,ROR,ROL. They can be seperated as LSd <ea> and other. They can be differentiate by the size 11
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_NORMAL_SIZE
    CMP         #%11,D3
    BEQ         SPECIAL_SHIFT_INSTRUCTION               * Only the instructions with 11 in the size parts deal with <ea> (shift memory)
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_THE_THIRD_NIBBLE                    * For ASd and LSd, the lat bit is 0 of third nibble is 0
    LSL         #8,D3                                   * Get the last bit of the second
    LSL         #7,D3
    LSR         #7,D3
    LSR         #8,D3
    CMP         #0,D3
    BEQ         PRINT_OUT_ASD_OR_LSD
    BRA         PRINT_OUT_ROD                           * Could also be ROXD. If it is then invalid
    RTS


FIRST_NIBBLE_IS_F * UNSUPPORTED
    RTS
    SIMHALT

SPECIAL_SHIFT_INSTRUCTION                               *Asd, LSd,ROd with <ea>. Shift instructions
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         CHECK_TYPE_DATA
    JSR         GET_THE_SECOND_NIBBLE
    LSR         #1, D3
    CMP         #1,D3
    BEQ         PRINT_OUT_LOGICAL_SHIFT_MEM             * 001
    CMP         #0,D3
    BEQ         PRINT_OUT_ARITH_SHIFT_MEM               *000
    CMP         #%11,D3
    BEQ         PRINT_OUT_ROTATE_MEM                    * 011
    BRA         INVALID                                 * Must be ROXd, UNSUPPORTED
    RTS

*******************************************************************************
* Jump table section
*******************************************************************************
* Used to figure out what type of mode and address where used to print
REGISTER_MODE_JUMP_TABLE
    JMP         REGISTER_MODE_000                       * Data register mode Dn
    JMP         REGISTER_MODE_001                       * ADdress register mode   An
    JMP         REGISTER_MODE_010                       * Indirect address register mode (An)
    JMP         REGISTER_MODE_011                       *  Address register with increment (An)+
    JMP         REGISTER_MODE_100                       * Address register with decrement -(An)
    JMP         REGISTER_MODE_101                       * Not supported
    JMP         REGISTER_MODE_110                       * Not supported
    JMP         REGISTER_MODE_111                       * This could be immediate, absolute short or absolute long

REGISTER_MODE_000                                       * Print out data register Dn
    JSR         PRINT_DATA_REGISTER
    JSR         PRINT_REGISTER_NUMBER
    RTS

REGISTER_MODE_001           * An
    JSR         PRINT_ADDRESS_REGISTER
    JSR         PRINT_REGISTER_NUMBER
    RTS

REGISTER_MODE_010           * (An)
    JSR         PRINT_OPEN_BRACKET
    JSR         REGISTER_MODE_001
    JSR         PRINT_CLOSE_BRACKET
    RTS

REGISTER_MODE_011           *(An)+
    JSR         REGISTER_MODE_010
    JSR         PRINT_PLUS_SIGN
    RTS

REGISTER_MODE_100       * -(An)
    JSR         PRINT_MINUS_SIGN
    JSR         REGISTER_MODE_010
    RTS

REGISTER_MODE_101                   * Not supported yet. Will deal later
    BRA         INVALID
    RTS

REGISTER_MODE_110                   * Not supported. Will deal later
    BRA         INVALID
    RTS

REGISTER_MODE_111                               * Immediate data, absolute long or absolute short
    LEA         REGISTER_111_JUMP_TABLE,A4      * Print out the appropriate value
    MOVE.W      THIRD_TEMP_VAR,D3
    MULU        #6,D3
    JSR         0(A4,D3)
    LEA         SHORT_OR_LONG_PRINT,A4          * Prepare the table to print out the data
    MOVE.W      THIRD_TEMP_VAR,D3
    MULU        #6,D3                           * Use THIRD_TEMP_VAR as a place holder for the data we want to print out for register mode 111.
                                                * In the code before this, we need to move the appropriate data into this address. Either the destination or the source
    JSR         0(A4,D3)                        * Print out the appropriate long or short value
    RTS

* Third table that deal with printing out short .W or .L value
SHORT_OR_LONG_PRINT                             * Will jump to this when the register mode is 111 and not immediate data
    JMP         ABSOLUTE_SHORT                  * Xn index for this is 000
    JMP         ABSOLUTE_LONG                   * Xn index for this is 001
    JMP         COUNTER_DISPLACEMENT
    JMP         COUNTER_INDEX
    JMP         IMMEDIATE_DATA

ABSOLUTE_SHORT                                  *We need to get the next 4 bytes as the address to print out
    JSR         GET_NEXT_FOUR_NIBBLE            * Got next 4 nibbles to print out as address
    JSR         CONVERT_HEX_TO_ASCII
    RTS
    SIMHALT

ABSOLUTE_LONG                                   * Print the next 8 bytes as the address
    JSR         ABSOLUTE_SHORT                  * PRinted 4 bytes
    JSR         ABSOLUTE_SHORT                  * Printed 4 more
    RTS
    SIMHALT

COUNTER_DISPLACEMENT                            * Not SUPPORTED
    BRA         INVALID
    SIMHALT

COUNTER_INDEX                                   * Not SUPPORTED
    BRA         INVALID
    SIMHALT

    * Immediate data is also like absolute short and long. Will take advantage of that
IMMEDIATE_DATA
    JSR         GET_NORMAL_SIZE                 * Now the first 2 bit of third nibble is on the right most
    LSR         #1, D3                          * Byte aand word are mapped to absolute short => 00 and 01 after shift will go to 00
                                                * If the size is long, the it will go to absolute long 10 => 01
    LEA         SHORT_OR_LONG_PRINT,A4          * Prepare the table to print out the data
    MULU        #6,D3                           * Use THIRD_TEMP_VAR as a place holder for the data we want to print out for register mode 111.
                                                * In the code before this, we need to move the appropriate data into this address. Either the destination or the source

    JSR         0(A4,D3)                        * Print out the appropriate long or short value
    RTS

REGISTER_111_JUMP_TABLE
    JMP         PRINT_SHORT_SYMBOL
    JMP         PRINT_LONG_SYMBOL
    JMP         PLACE_HOLDER_3 * Won't be reached
    JMP         PLACE_HOLDER_4
    JMP         PRINT_IMMEDIATE_DATA_AND_HEX

PRINT_SHORT_SYMBOL
    JSR         PRINT_HEX_SYMBOL
    RTS

PRINT_LONG_SYMBOL
    JSR         PRINT_HEX_SYMBOL
    RTS

PLACE_HOLDER_3
    BRA         INVALID
    SIMHALT

PLACE_HOLDER_4
    BRA        INVALID
    SIMHALT

PRINT_IMMEDIATE_DATA_AND_HEX
    JSR         PRINT_IMMEDIATE_DATA_SYMBOL
    JSR         PRINT_HEX_SYMBOL
    RTS

HEX_CHARACTER_JUMP_TABLE
    JMP         PRINT_HEX_0
    JMP         PRINT_HEX_1
    JMP         PRINT_HEX_2
    JMP         PRINT_HEX_3
    JMP         PRINT_HEX_4
    JMP         PRINT_HEX_5
    JMP         PRINT_HEX_6
    JMP         PRINT_HEX_7
    JMP         PRINT_HEX_8
    JMP         PRINT_HEX_9
    JMP         PRINT_HEX_A
    JMP         PRINT_HEX_B
    JMP         PRINT_HEX_C
    JMP         PRINT_HEX_D
    JMP         PRINT_HEX_E
    JMP         PRINT_HEX_F

PRINT_HEX_0
    LEA         ZERO,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_1
    LEA         ONE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_2
    LEA         TWO,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_3
    LEA         THREE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_4
    LEA         FOUR,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_5
    LEA         FIVE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_6
    LEA         SIX,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_7
    LEA         SEVEN,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_8
    LEA         EIGHT,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_9
    LEA         NINE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_A
    LEA         A,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_B
    LEA         B,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_C
    LEA         C,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_D
    LEA         D,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_E
    LEA         E,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

PRINT_HEX_F
    LEA         F,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

MOVE_SIZE_PRINT_JUMP_TABLE
    JMP         UNSUPPORTED_MOVE_SIZE
    JMP         MOVE_BYTE_SUFFIX
    JMP         MOVE_LONG_SUFFIX
    JMP         MOVE_WORD_SUFFIX

UNSUPPORTED_MOVE_SIZE
    BRA         INVALID
    RTS

MOVE_BYTE_SUFFIX
    LEA         BYTE_SUFFIX,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

MOVE_LONG_SUFFIX
    LEA         LONG_SUFFIX,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

MOVE_WORD_SUFFIX
    LEA         WORD_SUFFIX,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS


NORMAL_SIZE_PRINT_JUMP_TABLE
    JMP         PRINT_NORMAL_BYTE_SUFFIX
    JMP         PRINT_NORMAL_WORD_SUFFIX
    JMP         PRINT_NORMAL_LONG_SUFFIX
    JMP         UNSUPPORTED_NORMAL_SUFFIX         * Could be move

PRINT_NORMAL_BYTE_SUFFIX
    LEA         BYTE_SUFFIX,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

PRINT_NORMAL_WORD_SUFFIX
    LEA         WORD_SUFFIX,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

PRINT_NORMAL_LONG_SUFFIX
    LEA         LONG_SUFFIX,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

UNSUPPORTED_NORMAL_SUFFIX
    BRA         INVALID
    RTS

*This jump table depends on the condition of Bcc
CONDITION_JUMP_TABLE
    JMP         CONDITION_TRUE
    JMP         CONDITION_FALSE
    JMP         CONDITION_HIGHER
    JMP         CONDITION_LOWER_OR_SAME
    JMP         CONDITION_CARRY_CLEAR
    JMP         CONDITION_CARRY_SET                * Supported
    JMP         CONDITION_NOT_EQUAL
    JMP         CONDITION_EQUAL
    JMP         CONDITION_OVERFLOW_CLEAR            * Supported
    JMP         CONDITION_OVERFLOW_SET
    JMP         CONDITION_PLUS
    JMP         CONDITION_MINUS
    JMP         CONDITION_GREATER_OR_EQUAL         * Supported
    JMP         CONDITION_LESS_THAN                * SUPPORTED
    JMP         CONDITION_GREATER_THAN
    JMP         CONDITION_LESS_OR_EQUAL

CONDITION_TRUE
    BRA         INVALID

CONDITION_FALSE
    BRA         INVALID

CONDITION_HIGHER
    LEA         HIGHER_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_LOWER_OR_SAME
    LEA         LOWER_OR_SAME_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_CARRY_CLEAR
    LEA         CARRY_CLEAR_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS



CONDITION_CARRY_SET
    LEA         CARRY_SET_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_NOT_EQUAL
    LEA         NOT_EQUAL_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_EQUAL
    LEA         EQUAL_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_OVERFLOW_CLEAR
    LEA         OVERFLOW_CLEAR_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_OVERFLOW_SET
    LEA         OVERFLOW_SET_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_PLUS
    LEA         PLUS_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_MINUS
    LEA         MINUS_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_GREATER_OR_EQUAL
    LEA         GREATER_OR_EQUAL_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_LESS_THAN
    LEA         LESS_THAN_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_GREATER_THAN
    LEA         GREATER_THAN_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

CONDITION_LESS_OR_EQUAL
    LEA         LESS_OR_EQUAL_VALUE,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    JSR         PRINT_EMPTY_SPACE
    RTS

RIGHT_OR_LEFT_JUMP_TABLE
    JMP         RIGHT_DIRECTION_PRINT
    JMP         LEFT_DIRECTION_PRINT

RIGHT_DIRECTION_PRINT
    LEA         RIGHT_DIRECTION,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

LEFT_DIRECTION_PRINT
    LEA         LEFT_DIRECTION,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    RTS

IMMEDIATE_OR_REGISTER_JUMP_TABLE                * Use for ASd, LSd, ROd operations
    JMP         IMMEDIATE_ROTATION
    JMP         REGISTER_ROTATION

IMMEDIATE_ROTATION
    LEA         IMMEDIATE_DATA_SYMBOL,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    LSR         #1,D3
    CMP         #0,D3
    BEQ         IMMEDIATE_ROTATION_HELPER       * For cases where the immediate is 0, make it 8
    MOVE.W      D3, THIRD_TEMP_VAR              * Save the immediate data 1-8 we want to print
    JSR         PRINT_REGISTER_NUMBER
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    RTS

REGISTER_ROTATION
    LEA         DATA_REGISTER,A1
    JSR         PRINT_TO_SCREEN_ENTIRE_STRING
    MOVE.W      TEMP_CURRENT_4_NIBBLES,D3
    JSR         GET_THE_SECOND_NIBBLE
    LSR         #1,D3
    MOVE.W      D3,THIRD_TEMP_VAR
    JSR         PRINT_REGISTER_NUMBER
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    RTS

IMMEDIATE_ROTATION_HELPER
    MOVE.W      #8,THIRD_TEMP_VAR
    JSR         PRINT_REGISTER_NUMBER
    JSR         PRINT_COMMA
    JSR         PRINT_EMPTY_SPACE
    RTS



******************************************************************
* Constant String that is used to print out the data is stored here
******************************************************************
INTRO_STARTING          DC.W        'Please enter starting address',0
INTRO_ENDING            DC.W        'Please enter ending address',0
INVALID_INPUT           DC.W        'INVALID ADDRESS ENTERED',0
FINISH                  DC.W        'Finish Dissassembling. Starting address has reached or passed ending address',0
NOP_VALUE               DC.W        'NOP',0     * Requested
RTS_VALUE               DC.W        'RTS',0     * Requested
ORI_VALUE               DC.W        'ORI',0     * Unfinished
JSR_VALUE               DC.W        'JSR',0     * Requested
LEA_VALUE               DC.W        'LEA',0     * Requested
NEG_VALUE               DC.W        'NEG',0     * Requested
CMPI_VALUE              DC.W        'CMPI',0    * Requested
CMP_VALUE               DC.W        'CMP',0     * Requested
SUB_VALUE               DC.W        'SUB',0     * Requested
SUBA_VALUE              DC.W        'SUBA',0    * Extra
SUBQ_VALUE              DC.W        'SUBQ',0    * Requested
DIVS_VALUE              DC.W        'DIVS',0    * Requested
BRA_VALUE               DC.W        'BRA',0     * Requested
BSR_VALUE               DC.W        'BSR',0     * Extra
MULS_VALUE              DC.W        'MULS',0    * Requested
MULU_VALUE              DC.W        'MULU',0    * Extra
ADD_VALUE               DC.W        'ADD',0     * Requested
ADDA_VALUE              DC.W        'ADDA',0    * Requested
ADDQ_VALUE              DC.W        'ADDQ',0    * Extra
AS_VALUE                DC.W        'AS',0      * Requested ASR, ASL
LS_VALUE                DC.W        'LS',0      * Requested LSR, LSL
RO_VALUE                DC.W        'RO',0      * Requested ROR, ROL
BCLR_VALUE              DC.W        'BCLR',0    * Unfinished
LEFT_DIRECTION          DC.W        'L',0
RIGHT_DIRECTION         DC.W        'R',0
OR_VALUE                DC.W        'OR',0      * Extra
MOVEA_VALUE             DC.W        'MOVEA',0   * Requested
MOVE_VALUE              DC.W        'MOVE',0    * Requested
MOVEQ_VALUE             DC.W        'MOVEQ',0   * Extra
DATA_VALUE              DC.W        'DATA',0
HIGHER_VALUE            DC.W        'HI',0
LOWER_OR_SAME_VALUE     DC.W        'LS',0
CARRY_CLEAR_VALUE       DC.W        'CC',0
NOT_EQUAL_VALUE         DC.W        'NE',0
EQUAL_VALUE             DC.W        'EQ',0
OVERFLOW_CLEAR_VALUE    DC.W        'VC',0 *
OVERFLOW_SET_VALUE      DC.W        'VS',0
PLUS_VALUE              DC.W        'PL',0
MINUS_VALUE             DC.W        'MI',0
GREATER_OR_EQUAL_VALUE  DC.W        'GE',0 *
LESS_THAN_VALUE         DC.W        'LT',0 *
GREATER_THAN_VALUE      DC.W        'GT',0
LESS_OR_EQUAL_VALUE     DC.W        'LE',0
CARRY_SET_VALUE         DC.W        'CS',0 *
SR_VALUE                DC.W        'SR',0
CCR_VALUE               DC.W        'CCR',0
OPENING_BRACKET         DC.W        '(',0
CLOSING_BRACKET         DC.W        ')',0
PLUS_SIGN               DC.W        '+',0
MINUS_SIGN              DC.W        '-',0
DATA_REGISTER           DC.W        'D',0
ADDRESS_REGISTER        DC.W        'A',0
COMMA                   DC.W        ',',0
SPACE                   DC.W        ' ',0
BINARY_SYMBOL           DC.W        '%',0
HEX_SYMBOL              DC.W        '$',0
IMMEDIATE_DATA_SYMBOL   DC.W        '#',0
BYTE_SUFFIX             DC.W        '.B',0
WORD_SUFFIX             DC.W        '.W',0
LONG_SUFFIX             DC.W        '.L',0
ZERO                    DC.W        '0',0
ONE                     DC.W        '1',0
TWO                     DC.W        '2',0
THREE                   DC.W        '3',0
FOUR                    DC.W        '4',0
FIVE                    DC.W        '5',0
SIX                     DC.W        '6',0
SEVEN                   DC.W        '7',0
EIGHT                   DC.W        '8',0
NINE                    DC.W        '9',0
A                       DC.W        'A',0
B                       DC.W        'B',0
C                       DC.W        'C',0
D                       DC.W        'D',0
E                       DC.W        'E',0
F                       DC.W        'F',0


    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
