GOTO Initialise_Program

Set_Cursor_Position:
    REM Set Cursor Position to X=XP%, Y=YP%
    POKE 211,XP% : POKE 214,YP% : SYS 58732
    RETURN

Get_Random:
    REM Get random number
    RD% = INT(RND(1) * 7) : REM 0 = seed based on clock, 7 = FR$ length
    REM RandomNumber = INT(RND(1) * (Upper - Lower) + Lower)
    RETURN

Print_Machine:
    REM Print Machine Graphics
    PRINT "   {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{178}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{178}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {98}          {98}          {98}          {98}"
    PRINT "   {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{177}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{177}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
    PRINT
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
    PRINT "   [ P ] PLAY AGAIN                    "
    PRINT "   [ R ] RESET SPRITES                 "
    PRINT "   [ Q ] QUIT                          "    
    PRINT "                                       "
    RETURN

Print_Instructions__In_Credit:
    REM Print Instructions when in credit
    PRINT "   [ S ] Spin Reels                    "
    PRINT "   [+/-] INCREASE / DECREASE BET       "
    PRINT "   [ R ] RESET SPRITES                 "
    PRINT "   [ Q ] Quit                          "
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
    FOR I=1 TO 16
    GOSUB Get_Random : R1% = RD% : POKE SP + 0, SL + R1%
    GOSUB Get_Random : R2% = RD% : POKE SP + 1, SL + R2%
    GOSUB Get_Random : R3% = RD% : POKE SP + 2, SL + R3%

    POKE 53269,7 : REM Set sprites 0, 1, and 2 visible
    NEXT I
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

    XP% = 10 : YP% = 1 : GOSUB Set_Cursor_Position
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

    XP% = 28 : YP% = 1 : GOSUB Set_Cursor_Position
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

Initialise_Sprites:
    REM Initialise Sprites
    VL = 53248 : REM Base Vic Address and Sprite Screen Location (X) Y pos = + 1
    SL = 248 : REM Base Sprite Pointer Location
    SP = 2040 : REM Base Sprite Pointer Address Location
    SL = 248 : REM Base Sprite Pointer Location

    POKE VL+37,10 : POKE VL+38,2: rem multicolors 1 & 2
    POKE VL+21,0 : rem set all sprites invisible
    POKE VL+28, 127: rem multicolor
    POKE VL+29, 0 : POKE VL+23, 7: rem width & height
    POKE VL+39,0 : REM Sprite 0 Colour
    POKE VL+40,0 : REM Sprite 1 Colour
    POKE VL+41,0 : REM Sprite 2 Colour
    
    RESTORE
    FOR X=SL*64 TO (SL+7)*64-1: READ Y: POKE X,Y: NEXT

    POKE VL+16,4 : REM Enable Sprite 3 MSB (for x pos)
    POKE VL,84 : POKE VL+1,84: rem sprite 0 pos
    POKE VL+2,172 : POKE VL+3,84: rem sprite 1 pos
    POKE VL+4,4 : POKE VL+5,84: rem sprite 2 pos (4 + 255)
    RETURN


Initialise_Program:
    REM Initialise Program

Initialise_Fruits:
    DIM FR$(6,1):REM Define Fruits array
    REM Fruit name, win multiplier
    FR$(0,0)="CHERRY":FR$(0,1)="3"
    FR$(1,0)="PEAR"  :FR$(1,1)="5"
    FR$(2,0)="LEMON" :FR$(2,1)="6"
    FR$(3,0)="GRAPE" :FR$(3,1)="7"
    FR$(4,0)="APPLE" :FR$(4,1)="8"
    FR$(5,0)="SEVEN" :FR$(5,1)="9"
    FR$(6,0)="BAR"   :FR$(6,1)="10"

    GOSUB Initialise_Notes: REM Initialise Notes
    GOSUB Initialise_Sprites : REM Initialise Sprites

Initialise_Credits:
    REM Initialise Credits
    BT% = 10 : REM Initial Bet : BT% stores bet count
    IC = 100 : REM IC = Initial Credits
    CR = IC : REM CR = Credits

Restart:
    PRINT "{clr}{white}"; : REM Clear screen and set the text to white
    POKE 53280,0 : POKE 53281,0 : REM Set border and background to black
    RD% = INT(RND(-TI)) : REM Re-randomise the random seed
    POKE VL+21,0 : rem set all sprites invisible
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
    SS$ = "" : GOSUB Print_Win_Strip_Text : REM Print Win Strip Text
    GOSUB Get_Reels : REM Get Reels

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
    GET K$ : REM Get Keyboard Key
    REM Next instruction based on key press
    IF K$ = "Q" THEN END
    IF K$ = "R" THEN GOSUB Initialise_Sprites : POKE 53269,7
    IF CR > 0 AND (K$ = "-" OR K$ = "_") THEN Decrease_Bet : REM Decrease Bet
    IF CR > 0 AND (K$ = "+" OR K$ = "=") THEN Increase_Bet : REM Increase Bet
    IF CR > 0 AND K$ = "S" THEN Play_Next_Credit : REM Play Next Credit
    IF CR <= 0 AND K$ = "P" THEN Initialise_Credits : REM Initialise Credits
    GOTO Get_User_Instruction : REM Get Keyboard Key

Decrease_Bet:
    REM Decrease Bet
    IF BT% = 10 THEN Increase_Decrease_Bet__Continue
    BT% = BT% - 10
    DL = 125 : REM Note Delay
    POKE SR + 1, NS%(0,0) : POKE SR, NS%(0,1) : REM Play Low Note
    GOSUB Play_Sound : REM Play Sound
    GOTO Increase_Decrease_Bet__Continue

Increase_Bet:
    REM Increase Bet
    IF BT% = CR OR BT% = 100 THEN Increase_Decrease_Bet__Continue
    BT% = BT% + 10
    DL = 125 : REM Note Delay
    POKE SR + 1, NS%(1,0) : POKE SR, NS%(1,1) : REM Play High Note
    GOSUB Play_Sound : REM Play Sound

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
    GOSUB Print_Credit_Strip_Text
    GOTO Game_Loop

Sprite_Data:
    REM Generated with spritemate
    rem cherry / multicolor / color 1
    DATA 0,0,0,0,0,0,0,0,0,0,0,64,0,3,240,0
    DATA 3,16,0,13,0,0,12,0,0,31,0,0,255,192,0,192
    DATA 192,1,64,80,7,113,220,5,113,92,5,113,92,1,192,112
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,129
    rem pear / multicolor / color 0
    DATA 0,0,0,0,0,0,0,12,0,0,15,0,0,12,0,0
    DATA 12,0,0,20,0,0,215,0,0,85,192,0,93,64,3,85
    DATA 112,13,85,80,13,215,92,13,85,92,13,93,92,3,85,112
    DATA 0,213,192,0,63,0,0,0,0,0,0,0,0,0,0,128
    rem lemon / multicolor / color 0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 20,0,0,117,0,1,85,64,5,215,80,21,85,116,23,119
    DATA 84,53,85,92,13,221,112,3,85,192,0,215,0,0,60,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128
    rem grape / multicolor / color 1
    DATA 0,0,0,0,0,0,0,0,12,0,0,60,0,0,240,0
    DATA 15,192,0,48,64,0,17,80,0,87,112,3,220,192,1,49
    DATA 0,5,69,64,13,205,192,3,19,0,4,84,0,21,220,0
    DATA 55,48,0,12,0,0,0,0,0,0,0,0,0,0,0,129
    rem apple / multicolor / color 0
    DATA 0,0,0,0,0,0,0,12,0,0,15,0,0,12,0,0
    DATA 20,0,0,85,0,1,85,64,1,85,192,5,87,0,5,92
    DATA 0,5,92,0,5,87,0,13,85,192,1,85,64,3,85,192
    DATA 0,215,0,0,60,0,0,0,0,0,0,0,0,0,0,128
    rem seven / multicolor / color 1
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,1,85,64,1
    DATA 85,64,3,253,64,0,1,64,0,5,64,0,5,192,0,21
    DATA 0,0,23,0,0,84,0,0,92,0,0,80,0,0,80,0
    DATA 0,240,0,0,0,0,0,0,0,0,0,0,0,0,0,129
    rem bar / multicolor / color 0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,85,85,85,255
    DATA 255,255,0,0,0,20,4,20,29,29,29,17,17,17,23,21
    DATA 23,29,29,29,17,17,17,23,17,17,60,51,51,0,0,0
    DATA 85,85,85,255,255,255,0,0,0,0,0,0,0,0,0,128
