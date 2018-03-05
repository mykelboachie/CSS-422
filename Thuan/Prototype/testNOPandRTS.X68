*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program

* Put program code here
    NOP
    RTS
    NEG.L         $00511234         
    JSR         $00123658
    LEA         $00001234, A5
    CMPI.L    #5, D0
    CMPI.L        #112345, $00001234
    CMPI.B          #3,D1
    CMPI.W          #5, $FFFF1234
    SUBQ        #1, D3
    SUBQ.B      #8, $11112345
     SUBQ.L      #1, $00001234
    DIVS.W         $00001234,D0
    DIVS.W          $1200, D5
    DIVS.W         $FFFF3658,D2 
        SUB.B     D5,D4
    SUB.W     D5,D4
   SUB.L     D5,D4
    SUB.L     D1,$00001234
    SUB.L     $00001234,D1
    SUB.L     D1, $FFFF1234
    SUB.L       $FFFF1234,D1
    CMP    $FFFF1234,D0
   CMP     D0,D1
   CMP     A1,D4
   CMP.B  $FFFF1234,D5
   CMP.B   $00001234,D6
   CMP.W     $1234,D7
   CMP.L      $1234,D1
    BSR       TEST
    BRA       NO_TEST
       MULU #3,D0
   MULU $00001234,D5
   MULU.W $FFFF1100, D6
    MULS #45,D1
    MULS $00001234,D7
    MULS $FFFF1000, D2
    SIMHALT             ; halt simulator

* Put variables and constants here
TEST
    MOVE.W      #0,D1
    RTS
    
    
    
    
NO_TEST
    MOVE.W     #4,D2
    RTS
    END    START        ; last line of source



























*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
