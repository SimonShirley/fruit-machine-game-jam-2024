GOTO Initialise_Program

Initialise_Fruits:
    REM Define Fruits array
    DIM FR$(6,1)

    FR$(0,0) = " APPLE  "
    FR$(0,1) = "90" : REM APPLE WIN

    FR$(1,0) = "  BAR   "
    FR$(1,1) = "100" : REM BAR WIN

    FR$(2,0) = " CHERRY "
    FR$(2,1) = "30" : REM CHERRY WIN

    FR$(3,0) = " SEVEN  "
    FR$(3,1) = "80" : REM SEVEN WIN

    FR$(4,0) = " LEMON  "
    FR$(4,1) = "60" : REM LEMON WIN

    FR$(5,0) = " GRAPE  "
    FR$(5,1) = "70" : REM GRAPE WIN

    FR$(6,0) = "  PEAR  "
    FR$(6,1) = "50" : REM PEAR WIN

    RETURN

Get_Random:
    REM Get random number
    RD% = INT(RND(0) * 6) + 1 : REM 0 = seed based on clock, 6 = FR$ length
    RETURN

Print_Machine:
    REM Print Machine Graphics
    PRINT "{clr}"
    PRINT "=================================="
    PRINT "|          |          |          |"
    PRINT "| " FR$(R1%,0) " | " FR$(R2%,0) " | " FR$(R3%,0) " |"
    PRINT "|          |          |          |"
    PRINT "=================================="
    PRINT
    RETURN

Print_Credits:
    REM Print Credits
    C1 = CR / 100
    CR$ = STR$(C1)

    IF C1 = INT(C1) THEN Print_Credits__Set_Pence_DoubleZero
    IF C1 < 1 THEN Print_Credits__Set_Leading_Zero
    GOTO Print_Credits__Set_Trailing_Zero

Print_Credits__Set_Pence_DoubleZero:
    CR$ = CR$ + ".0"
    GOTO Print_Credits__Set_Trailing_Zero

Print_Credits__Set_Leading_Zero:
    CR$ = "0" + CR$

Print_Credits__Set_Trailing_Zero:
    CR$ = CR$ + "0"

Print_Credits__Continue:
    PRINT "Credits: $" + CR$
    PRINT
    RETURN

Print_Instructions:
    REM Print Instructions
    PRINT "[SPACEBAR] Spin Reels"
    PRINT "[Q] Quit"
    PRINT
    RETURN

Get_Reels:
    REM Generate Reels
    GOSUB Get_Random : R1% = RD%
    GOSUB Get_Random : R2% = RD%
    GOSUB Get_Random : R3% = RD%
    RETURN

Wait_Key:
    REM Wait Key
    GET K$ : IF K$ = "" THEN Wait_Key
    RETURN

Full_Win:
    REM Full Win (All 3 matching)
    CR = CR + VAL(FR$(R1%,1))
    PRINT FR$(R1%,0) + " WIN!!"
    RETURN

Half_Win:
    REM Half Win (Only first and second matching)
    CR = CR + HW
    PRINT "HALF WIN!!"
    RETURN

Initialise_Program:
    REM Initialise Program
    GOSUB Initialise_Fruits
    CR = 100 : REM CR = Credits
    HW = 20 : REM HW = Half Win Credits

Start:    
    GOSUB Get_Reels : REM Get Reels
    GOSUB Print_Machine : REM Print Machine Graphics

    REM Check for Win
    IF R1% = R2% AND R2% = R3% THEN GOSUB Full_Win
    IF R1% = R2% AND R2% <> R3% THEN GOSUB Half_Win

    GOSUB Print_Credits : REM Print Credits
    GOSUB Print_Instructions : REM Print Instructions

    GOSUB Wait_Key : REM Get Keyboard Key
    REM Next instruction based on key press
    IF K$ = "Q" THEN END
    IF K$ <> " " THEN GOSUB Wait_Key

    REM Deduct credit and play again
    IF CR <= 0 THEN END
    CR = CR - 10
    GOTO Start
