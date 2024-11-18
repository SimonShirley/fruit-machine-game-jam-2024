GOTO Initialise_Program

Initialise_Fruits:
    REM Define Fruits array
    DIM FR$(6,1)

    FR$(0,0) = "CHERRY"
    FR$(0,1) = "3" : REM CHERRY WIN

    FR$(1,0) = "PEAR"
    FR$(1,1) = "5" : REM PEAR WIN

    FR$(2,0) = "LEMON"
    FR$(2,1) = "6" : REM LEMON WIN

    FR$(3,0) = "GRAPE"
    FR$(3,1) = "7" : REM GRAPE WIN

    FR$(4,0) = "APPLE"
    FR$(4,1) = "8" : REM SEVEN WIN

    FR$(5,0) = "SEVEN"
    FR$(5,1) = "9" : REM APPLE WIN

    FR$(6,0) = "BAR"
    FR$(6,1) = "10" : REM BAR WIN

    RETURN

Set_Cursor_Position:
    POKE 211,XP% : POKE 214,YP% : SYS 58732 : REM Set cursor to x=XP%, y=YP%
    RETURN

Get_Random:
    REM Get random number
    RD% = INT(RND(0) * 6) + 1 : REM 0 = seed based on clock, 6 = FR$ length
    RETURN    

Print_Machine:
    REM Print Machine Graphics
    PRINT "   {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{178}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{178}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{177}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{177}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
    PRINT
    RETURN

Print_Reel_Line:
    XP% = 5 : YP% = 7 : GOSUB Set_Cursor_Position
    PRINT "        ";SPC(3);"        ";SPC(3);"        ";
    GOSUB Set_Cursor_Position

    LN% = 8
    TT$ = ""

    SS$ = FR$(R1%,0)
    GOSUB Centre_Text    
    TT$ = TT$ + SS$ + " {98} "

    SS$ = FR$(R2%,0)
    GOSUB Centre_Text
    TT$ = TT$ + SS$ + " {98} "

    SS$ = FR$(R3%,0)
    GOSUB Centre_Text
    TT$ = TT$ + SS$ + " {98}"
    
    PRINT TT$;
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

Centre_Text:
    REM Calculate padding spaces for centring
    REM LN% = Available Space Length

    IF LEN(SS$) => LN% THEN Centre_Text__Return

    J = INT((LN% - LEN(SS$)) / 2)
    J = J - (J - INT(J/2) * 2) : REM Subtract 1 if J is odd

    FOR I = 1 TO J : REM 1 TO Number of Spaces Required
    SS$ = " " + SS$
    NEXT I

    IF LEN(SS$) => LN% THEN Centre_Text__Return

    FOR I = LEN(SS$) TO LN% - 1
    SS$ = SS$ + " "
    NEXT I

Centre_Text__Return:
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

Print_Prizes_Text:
    PRINT "WIN WIN -",": 2X",
    PRINT FR$(0,0),": " + FR$(0,1) + "X"

    FOR I = 1 TO 6 : REM FRUIT SIZE
    PRINT FR$(I,0),": " + FR$(I,1) + "X",
    I = I + 1
    IF I > 6 THEN Print_Prizes_Text__Next : REM Jump out if array size is odd
    PRINT FR$(I,0),": " + FR$(I,1) + "X"

Print_Prizes_Text__Next:
    NEXT I

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
    WI = (VAL(FR$(R1%,1)) * BT%) : REM WI = Winning amount
    CR = CR + WI

    CV = WI : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits

    SS$ = FR$(R1%,0) + " WIN - YOU WIN: {92}" + CV$
    RETURN

Half_Win:
    REM Half Win (Only first and second matching)
    WI = BT% * 2 : REM WI = Winning amount
    CR = CR + WI
    
    CV = WI : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits

    SS$ = "HALF WIN - YOU WIN: {92}" + CV$ : REM WV$ = Win string
    RETURN

Print_Win_Strip_Text:
    REM Print Win Strip Text
    IF LEN(SS$) > 0 THEN Print_Win_Strip_Text__Centre_Text
    SS$ = "                              "
    GOTO Print_Win_Strip_Text__Continue

Print_Win_Strip_Text__Centre_Text:
    LN% = 30
    GOSUB Centre_Text

Print_Win_Strip_Text__Continue:
    XP% = 5 : YP% = 12 : GOSUB Set_Cursor_Position
    GOSUB Print_Strip_Text
    RETURN

Print_Credit_Strip_Text:
    REM Print Credit Strip Text
    SS$ = ""
    CV = CR : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits
    FOR I = LEN(CV$) TO 5 : REM Max length 6 - 1
    SS$ = " " + SS$
    NEXT I
    SS$ = SS$ + "{92}" + CV$

    XP% = 28 : YP% = 2 : GOSUB Set_Cursor_Position
    GOSUB Print_Strip_Text
    RETURN

Print_Strip_Text:
    REM Print_Strip_Text
    TT$ = "" : REM String to blank previous screen characters
    FOR I = 1 TO LEN(SS$)
        TT$ = TT$ + " "
    NEXT I

    PRINT TT$;

    GOSUB Set_Cursor_Position : REM Reset cursor position
    PRINT SS$;
    RETURN

Print_Bet_Credit_Strip_Border:
    PRINT "   {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174} {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}"
    PRINT "     BET: {92}0.10     Credit:"
    PRINT "   {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189} {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
    PRINT
    RETURN

Print_Status_Strip_Border:
    PRINT "   {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}"
    PRINT
    PRINT "   {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
    PRINT
    RETURN

Initialise_Program:
    REM Initialise Program
    GOSUB Initialise_Fruits

Initialise_Credits:
    BT% = 10 : REM Initial Bet : BT% stores bet count
    IC = 100 : REM IC = Initial Credits
    CR = IC : REM CR = Credits

Restart:
    PRINT "{clr}{white}" : REM Clear screen and set the text to white
    POKE 53280,0 : POKE 53281,0 : REM Set border and background to black
    GOSUB Print_Bet_Credit_Strip_Border
    GOSUB Print_Machine
    GOSUB Print_Status_Strip_Border
    GOSUB Print_Prizes_Text
    GOSUB Print_Instructions : REM Print Instructions
    GOSUB Print_Credit_Strip_Text
    GOTO Get_User_Instruction

Game_Loop:
    GOSUB Get_Reels : REM Get Reels
    GOSUB Print_Credit_Strip_Text
    GOSUB Print_Reel_Line

    SS$ = ""

    REM Check for Win
    IF R1% = R2% AND R2% = R3% THEN GOSUB Full_Win
    IF R1% = R2% AND R2% <> R3% THEN GOSUB Half_Win
    
    GOSUB Print_Win_Strip_Text    
    GOSUB Print_Credit_Strip_Text

    IF CR > 0 THEN Get_User_Instruction

    SS$ = "GAME OVER"
    GOSUB Print_Win_Strip_Text

    XP% = 0 : YP% = 20 : GOSUB Set_Cursor_Position
    GOSUB Print_Instructions

Get_User_Instruction:
    GOSUB Wait_Key : REM Get Keyboard Key
    REM Next instruction based on key press
    IF K$ = "Q" THEN END
    # TODO: Need to include a way to increase / decrease bet
    IF CR > 0 AND K$ = "S" THEN Play_Next_Credit
    IF CR <= 0 AND K$ = "P" THEN Initialise_Credits
    GOTO Get_User_Instruction

Play_Next_Credit:
    REM Deduct credit and play again
    IF CR >= BT% THEN Play_Next_Credit__Deduct_Bet
    CR = 0
    # TODO: Need to update displayed bet information
    GOTO Game_Loop

Play_Next_Credit__Deduct_Bet:
    CR = CR - BT%
    # TODO: Need to update displayed bet information
    GOTO Game_Loop
