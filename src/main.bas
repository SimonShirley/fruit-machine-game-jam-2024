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

Set_Cursor_Position:
    POKE 211,0 : POKE 214, 0 : SYS 58732 : REM Set cursor to x=0, y=0
    RETURN

Get_Random:
    REM Get random number
    RD% = INT(RND(0) * 6) + 1 : REM 0 = seed based on clock, 6 = FR$ length
    RETURN    

Print_Machine:
    REM Print Machine Graphics
    PRINT "   {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{178}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{178}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {98} " FR$(R1%,0) " {98} " FR$(R2%,0) " {98} " FR$(R3%,0) " {98}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{177}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{177}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
    PRINT
    RETURN

Format_Credit_String:
    REM Print Credits
    REM CV is the passed in value for processing
    
    CF = CV / 100 : REM Convert to float and turn cents into dollars
    CV$ = MID$(STR$(CF),2)

    IF CF = INT(CF) THEN Format_Credit_String__Set_Pence_DoubleZero
    IF CF < 1 THEN Format_Credit_String__Set_Leading_Zero
    GOTO Format_Credit_String__Set_Trailing_Zero

Format_Credit_String__Set_Pence_DoubleZero:
    CV$ = CV$ + ".0"
    GOTO Format_Credit_String__Set_Trailing_Zero

Format_Credit_String__Set_Leading_Zero:
    CV$ = "0" + CV$

Format_Credit_String__Set_Trailing_Zero:
    CV$ = CV$ + "0"

Format_Credit_String__Continue:    
    RETURN

Print_Instructions:
    REM Print Instructions
    IF CR > 0 THEN Print_Instructions__In_Credit
    PRINT "[P] PLAY AGAIN"
    GOTO Print_Instructions__Continue
Print_Instructions__In_Credit:
    PRINT "[S] Spin Reels"

Print_Instructions__Continue:
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

    SS$ = "" : REM SS$ = Status Strip string
    REM Remove Spaces from Reel string
    FOR I = 1 TO 8
    SC$ = MID$(FR$(R1%,0), I, 1) : REM Test character
    IF SC$ = " " THEN Full_Win__Next
    SS$ = SS$ + SC$
Full_Win__Next:
    NEXT I

    CV = VAL(FR$(R1%,1)) : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits

    SS$ = SS$ + " WIN - YOU WIN: $" + CV$
    RETURN

Half_Win:
    REM Half Win (Only first and second matching)
    CR = CR + HW
    
    CV = HW : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits

    SS$ = "HALF WIN - YOU WIN: $" + CV$ : REM WV$ = Win string
    RETURN

Print_Status_Strip:
    PRINT "   {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}"
    PRINT SPC(4); SPC((32 - LEN(SS$)) / 2); SS$
    PRINT "   {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
    PRINT
    RETURN

Initialise_Program:
    REM Initialise Program
    GOSUB Initialise_Fruits
    HW = 20 : REM HW = Half Win Credits

Initialise_Credits:
    IC = 100 : REM Initial Credits
    CR = IC : REM CR = Credits    

Start:
    GOSUB Get_Reels : REM Get Reels

    SS$ = ""

    REM Check for Win
    IF R1% = R2% AND R2% = R3% THEN GOSUB Full_Win
    IF R1% = R2% AND R2% <> R3% THEN GOSUB Half_Win

    PRINT "{clr}"
    GOSUB Print_Machine : REM Print Machine Graphics
    GOSUB Print_Status_Strip

    CV = CR : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits
    SS$ = "Credits: $" + CV$
    GOSUB Print_Status_Strip

    GOSUB Print_Instructions : REM Print Instructions

Get_User_Instruction:
    GOSUB Wait_Key : REM Get Keyboard Key
    REM Next instruction based on key press
    IF K$ = "Q" THEN END
    IF CR > 0 AND K$ = "S" THEN Play_Next_Credit
    IF CR <= 0 AND K$ = "P" THEN Initialise_Credits
    GOTO Get_User_Instruction

Play_Next_Credit:
    REM Deduct credit and play again
    IF CR <= 0 THEN END
    CR = CR - 10
    GOTO Start
