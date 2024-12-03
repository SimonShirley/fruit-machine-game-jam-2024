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
    REM Set Cursor Position to X=XP%, Y=YP%
    POKE 211,XP% : POKE 214,YP% : SYS 58732
    RETURN

Get_Random:
    REM Get random number
    IF RS% = 1 THEN GOSUB Randomise_Seed
    RD% = INT(RND(1) * 6) + 1 : REM 0 = seed based on clock, 6 = FR$ length
    RETURN

Randomise_Seed:
    REM Randomise Seed
    RD% = INT(RND(-TI)) + 1
    RS% = 0 : REM Set Flag so that the seed doesn't get re-generated this play
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
    REM Print Reel Line
    XP% = 5 : YP% = 7 : GOSUB Set_Cursor_Position
    PRINT "        ";SPC(3);"        ";SPC(3);"        ";
    GOSUB Set_Cursor_Position

    LN% = 8 : REM LN% = Reel Width in Characters
    TT$ = "" : REM Reel Line Text String for printing

    SS$ = FR$(R1%,0)
    GOSUB Centre_Text    
    TT$ = TT$ + SS$ + " {98} " : REM Add dividing character to text string

    SS$ = FR$(R2%,0)
    GOSUB Centre_Text
    TT$ = TT$ + SS$ + " {98} " : REM Add dividing character to text string

    SS$ = FR$(R3%,0)
    GOSUB Centre_Text
    TT$ = TT$ + SS$ + " {98}" : REM Add dividing character to text string
    
    PRINT TT$;
    RETURN

Format_Credit_String:
    REM Print Credits
    REM CV is the passed in value for processing
    
    CF = CV / 100 : REM Convert to float and turn pence into pounds
    CV$ = MID$(STR$(CF),2)

    IF CF = INT(CF) THEN Format_Credit_String__Set_Pence_DoubleZero
    IF CF < 1 THEN Format_Credit_String__Set_Leading_Zero
    GOTO Format_Credit_String__Set_Trailing_Zero

Format_Credit_String__Set_Pence_DoubleZero:
    REM Format Credit String - Set Pence Double Zero
    CV$ = CV$ + ".0"
    GOTO Format_Credit_String__Set_Trailing_Zero

Format_Credit_String__Set_Leading_Zero:
    REM Format Credit String - Set Pence Leading Zero
    CV$ = "0" + CV$

Format_Credit_String__Set_Trailing_Zero:
    REM Format Credit String - Set Pence Trailing Zero
    CV$ = CV$ + "0"

    RETURN

Centre_Text:
    REM Calculate padding spaces for centring
    REM LN% = Available Space Length

    REM Check string length and return if too long
    IF LEN(SS$) => LN% THEN RETURN

    J = INT((LN% - LEN(SS$)) / 2)
    J = J - (J - INT(J/2) * 2) : REM Subtract 1 if J is odd - MOD Function

    FOR I = 1 TO J : REM 1 TO Number of Spaces Required
    SS$ = " " + SS$
    NEXT I

    REM Check string length and return if too long
    IF LEN(SS$) => LN% THEN RETURN

    FOR I = LEN(SS$) TO LN% - 1
    SS$ = SS$ + " "
    NEXT I

    RETURN

Print_Instructions:
    REM Print Instructions with no credits
    IF CR > 0 THEN Print_Instructions__In_Credit
    PRINT "[ P ] PLAY AGAIN                       "
    PRINT "[ Q ] QUIT                             "
    PRINT "                                       "
    PRINT "                                       "
    RETURN

Print_Instructions__In_Credit:
    REM Print Instructions when in credit
    PRINT "[ S ] Spin Reels                       "
    PRINT "[+/-] INCREASE / DECREASE BET          "
    PRINT "[ Q ] Quit                             "
    PRINT "                                       "
    RETURN

Print_Prizes_Text:
    REM Print Prizes Text - Tab not available because of column width
    SS$ = "    WIN WIN - : 2X  " + FR$(0,0)
    
    FOR J = LEN(FR$(0,0)) TO 9
    SS$ = SS$ + " "
    NEXT J

    PRINT SS$ + ": " + FR$(0,1) + "X"

    FOR I = 1 TO 6 : REM FRUIT SIZE
    SS$ = "    " + FR$(I,0)

    FOR J = LEN(FR$(I,0)) TO 9
    SS$ = SS$ + " "
    NEXT J
    
    SS$ = SS$ + ": " + FR$(I,1) + "X  "

    I = I + 1
    IF I > 6 THEN Print_Prizes_Text__Next : REM Jump out if array size is odd

    SS$ = SS$ + FR$(I,0)
    
    FOR J = LEN(FR$(I,0)) TO 9
    SS$ = SS$ + " "
    NEXT J

    PRINT SS$ + ": " + FR$(I,1) + "X"

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
    GOSUB Play_Full_Win_Sound : REM Play Full Win Sound
    RETURN

Half_Win:
    REM Half Win (Only first and second matching)
    WI = BT% * 2 : REM WI = Winning amount
    CR = CR + WI
    
    CV = WI : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits

    SS$ = "HALF WIN - YOU WIN: {92}" + CV$ : REM WV$ = Win string
    GOSUB Play_Half_Win_Sound : REM Play Half Win Sound
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

Print_Bet_Strip_Text:
    REM Print Credit Strip Text
    CV = BT% : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits
    SS$ = "{92}" + CV$

    XP% = 10 : YP% = 2 : GOSUB Set_Cursor_Position
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
    REM Print Bet and Credit Strip Borders
    PRINT "   {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174} {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}"
    PRINT "     BET:           Credit:"
    PRINT "   {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189} {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
    PRINT
    RETURN

Print_Status_Strip_Border:
    REM Print Status Strip Borders
    PRINT "   {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}"
    PRINT
    PRINT "   {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
    PRINT
    RETURN

Initialise_Sound:
    SR = 54272 : REM SID BASE ADDRESS
    FOR I = SR TO SR + 24 : POKE I,0 : NEXT : REM Reset SID
    POKE SR + 5,9 : POKE SR + 6,0 : REM SET ADSR ENVELOPE
    POKE SR + 24,15 : REM SET MAX VOLUME
    RETURN

Initialise_Notes:
    REM Notes Array
    DIM NS%(1,1)
    REM C-Sharp (5)
    NS%(0,0) = 35
    NS%(0,1) = 134

    REM F-Sharp (5)
    NS%(1,0) = 47
    NS%(1,1) = 107
    RETURN

Play_Sound:
    POKE SR + 4, 33 : REM GATE(1) + SAWTOOTH(32)
    FOR I = 1 TO DL : NEXT : REM KEEP THE GATE ON FOR SOUND
    POKE SR + 4, 32 : REM GATE(0) + SAWTOOTH(32) : TURN SOUND OFF
    RETURN

Play_Half_Win_Sound:
    DL = 125 : REM Note Delay

    POKE SR + 1, NS%(0,0) : POKE SR, NS%(0,1)
    GOSUB Play_Sound
    
    POKE SR + 1, NS%(1,0) : POKE SR, NS%(1,1)
    GOSUB Play_Sound
    
    RETURN

Play_Full_Win_Sound:
    DL = 125 : REM Note Delay

    POKE SR + 1, NS%(1,0) : POKE SR, NS%(1,1)
    GOSUB Play_Sound

    POKE SR + 1, NS%(0,0) : POKE SR, NS%(0,1)
    GOSUB Play_Sound

    POKE SR + 1, NS%(0,0) : POKE SR, NS%(0,1)
    GOSUB Play_Sound
    
    POKE SR + 1, NS%(1,0) : POKE SR, NS%(1,1)
    GOSUB Play_Sound
    
    RETURN


Initialise_Program:
    REM Initialise Program
    GOSUB Initialise_Fruits
    GOSUB Initialise_Notes: REM Initialise Notes

Initialise_Credits:
    REM Initialise Credits
    BT% = 10 : REM Initial Bet : BT% stores bet count
    IC = 100 : REM IC = Initial Credits
    CR = IC : REM CR = Credits

Restart:
    PRINT "{clr}{white}" : REM Clear screen and set the text to white
    POKE 53280,0 : POKE 53281,0 : REM Set border and background to black
    RS% = 1 : REM RS = Flag needed to randomise the seed
    GOSUB Initialise_Sound: REM Initialise Sound
    GOSUB Print_Bet_Credit_Strip_Border : REM Print Bet Credit Strip Border
    GOSUB Print_Machine : REM Print Machine
    GOSUB Print_Status_Strip_Border : REM Print Status Strip Border
    GOSUB Print_Prizes_Text : REM Print Prize Information
    GOSUB Print_Instructions : REM Print Instructions
    GOSUB Print_Bet_Strip_Text : REM Print Bet Strip Text
    GOSUB Print_Credit_Strip_Text : REM Print Credit Strip Text
    GOTO Get_User_Instruction : REM Get User Input

Game_Loop:
    GOSUB Get_Reels : REM Get Reels
    GOSUB Print_Credit_Strip_Text : REM Print Credit Strip Text
    GOSUB Print_Reel_Line : REM Print Reel Line Text

    SS$ = ""

    REM Check for Win
    IF R1% = R2% AND R2% = R3% THEN GOSUB Full_Win
    IF R1% = R2% AND R2% <> R3% THEN GOSUB Half_Win
    
    GOSUB Print_Win_Strip_Text : REM Print Win Strip Text
    GOSUB Print_Credit_Strip_Text : REM Print Credit Strip Text

    REM Check if there is enough credit to bet
    IF BT% <= CR THEN Game_Loop__Continue
    BT% = INT(CR) : REM Reduce bet to remaining credit
    GOSUB Print_Bet_Strip_Text

Game_Loop__Continue:
    IF CR > 0 THEN Get_User_Instruction

    SS$ = "GAME OVER"
    GOSUB Print_Win_Strip_Text : REM Print Win Strip Text

    XP% = 0 : YP% = 20 : GOSUB Set_Cursor_Position
    GOSUB Print_Instructions

Get_User_Instruction:
    GOSUB Wait_Key : REM Get Keyboard Key
    REM Next instruction based on key press
    IF K$ = "Q" THEN END
    IF CR > 0 AND (K$ = "-" OR K$ = "_") THEN Decrease_Bet : REM Decrease Bet
    IF CR > 0 AND (K$ = "+" OR K$ = "=") THEN Increase_Bet : REM Increase Bet
    IF CR > 0 AND K$ = "S" THEN Play_Next_Credit : REM Play Next Credit
    IF CR <= 0 AND K$ = "P" THEN Initialise_Credits : REM Initialise Credits
    GOTO Get_User_Instruction : REM Get Keyboard Key

Decrease_Bet:
    REM Decrease Bet
    IF BT% = 10 THEN Increase_Decrease_Bet__Continue
    BT% = BT% - 10
    GOTO Increase_Decrease_Bet__Continue

Increase_Bet:
    REM Increase Bet
    IF BT% = CR OR BT% = 100 THEN Increase_Decrease_Bet__Continue
    BT% = BT% + 10

Increase_Decrease_Bet__Continue:
    GOSUB Print_Bet_Strip_Text
    GOTO Get_User_Instruction

Play_Next_Credit:
    REM Deduct credit and play again
    IF CR >= BT% THEN Play_Next_Credit__Deduct_Bet
    CR = 0

    GOTO Play_Next_Credit__Continue

Play_Next_Credit__Deduct_Bet:
    CR = CR - BT%

Play_Next_Credit__Continue:
    GOSUB Print_Bet_Strip_Text
    GOTO Game_Loop
