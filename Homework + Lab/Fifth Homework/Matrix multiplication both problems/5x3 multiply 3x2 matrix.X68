*-----------------------------------------------------------
* Title      :       Matrix multiplication
* Written by :       Thuan Tran
* Date       :       Feb 21st,18
* Description:          
*-----------------------------------------------------------
MATRIX_A                 EQU     $4100  * m x n
MATRIX_B                 EQU     $4200  * n x p
MATRIX_C                 EQU     $4300    * m x p
NUMBER_OF_ROWS           EQU     5   * For the above A matrix, which is m
NUMBER_OF_COLUMNS_ROWS   EQU     3   * For the above A and B matrix, which is n
NUMBER_OF_COLUMNS        EQU     2   * For the above B matrix, which is p

FIRST_VAR               EQU      $4400            *Defined these variables because address register is such a pain to use
SECOND_VAR              EQU      $4500
THIRD_VAR               EQU      $4600



                ORG    $1000
START:                  ; first instruction of program

* Put program code here
                LEA     MATRIX_A,A0     * Starting address of matrix A
                LEA     MATRIX_B,A1     * Starting address of matrix B
                LEA     MATRIX_C,A2     * Starting address of matrix C, which is the result
        
                MOVE.W  #NUMBER_OF_ROWS,FIRST_VAR * Stored the rows of first matrix 
                MOVE.W  #NUMBER_OF_COLUMNS_ROWS,SECOND_VAR * Stored the column of first matrix and row of second matrix
                MOVE.W  #NUMBER_OF_COLUMNS,THIRD_VAR * Store the column of second matrix 
                CLR.W   D2 * Used to store the sum of the matrix multiplication
                MOVEQ   #-1,D5 * counter for outer loop
                
                
THIRD_OUTER_LOOP      * i=0 to m 
                MOVEQ   #-1,D6  * Reset the second inner loop
                ADDI    #1,D5   * Increment the counter
                CMP     FIRST_VAR,D5  * Check if we have looped through the row of first matrix or not
                BEQ     FINISH   * When we reach this stage, means the outer loop is done looping
                BRA     SECOND_INNER_LOOP * Continue to second inner loop 
                                                     
SECOND_INNER_LOOP     *j = 0 to p
                MOVEQ   #-1,D7  *Reset the first inner loop
                ADDI    #1,D6   * Counter for second inner loop
                CMP     THIRD_VAR,D6    * Check if we have looped through the column of the second matrix
                BEQ     THIRD_OUTER_LOOP    * When we have exceeded the limit, return to outer loop
                MOVE    #0,D0               * Prepare the sum for value A[i][j] starting at 0
                BRA     FIRST_INNER_LOOP    * Go the inner loop of column of second matrix
              

                    * Sum += A[i][k] * B[k][j]   (m x n  n x p)
FIRST_INNER_LOOP      *k = 0 to n 
                ADDI    #1,D7  * Increment the counter 
                CMP     SECOND_VAR,D7  * Check if we have loop through the column of first matrix (row of second matrix)
                BEQ     MOVE_DATA_TO_RESULT_MATRIX
                MOVE    D5,D2                   * Move i to D2
                MULU    SECOND_VAR,D2           * Perform the following calculation (k + (i * n)) * K. This is i*n where n is the column
                ADD     D7,D2               * This is k + above 
                MULU    #2,D2                  * Since we are handling with word, so need to multiply by 2
                MOVE.W  (A0,D2.W),D3            * The location of A[i][k] and we move it to D3
                MOVE    D7,D1                           * Move k to D1
                                                          * Perform the following calculation (j + (k*n))*K                                           
                MULU    THIRD_VAR,D1                       * This is k*n
                ADD     D6,D1                            * j + above 
                MULU    #2,D1
                MOVE.W  (A1,D1.W),D4                  * Move B[k][j] to D4
                MULU    D3,D4   * Calculate the product between A[i][k] and B[k][j]
                ADD     D4,D0    * Add sum to the product above
                CLR.W   D1           * Clear all data register we used before for next calculation
                CLR.W   D2
                CLR.W   D3
                CLR.W   D4
                BRA     FIRST_INNER_LOOP
                                               
MOVE_DATA_TO_RESULT_MATRIX
                MOVE    THIRD_VAR,D1      * Move j to D1
                MULU    D5,D1             * Calculate displacement of C[i][j]. Which is equal (j+(i*n) )* K where n is the column second matrix
                ADD     D6,D1                       
                MULU    #2,D1               * This is the location C[i][j] where we will put the data
                MOVE.W    D0,(A2,D1.W)        * Move the result sum into C[i][j]
                CLR.W   D1    * Reset the variable A3
                CLR.W   D0     * Reset the sum
                BRA SECOND_INNER_LOOP        
                
                
                
FINISH
                SIMHALT

* Put variables and constants here
    ORG     MATRIX_A
    DC.W    1,2,3
    DC.W    1,2,3         * Matrix A with 5x3
    DC.W    1,2,3
    DC.W    1,2,3
    DC.W    1,2,3
    
    ORG     MATRIX_B
    DC.W    2,3            * Matrix B with 3x2
    DC.W    2,3
    DC.W    2,3
   
      
    ORG     MATRIX_C         * Result matrix. Expected 5x2
    DS.W    1    
        
    END    START        ; last line of source











*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
