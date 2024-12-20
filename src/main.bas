REM Set VIC Bank 2
POKE 56578,PEEK(56578) OR 3 : REM Allow writing to PORT A
POKE 56576,(PEEK(56576) AND 252) or 1 : REM Set PORT A serial bus access to VIC Bank 2
POKE 53272,4 : REM Set pointer of character memory to $2000-$27FF / 8192-10239
POKE 648,128 : REM High byte of pointer to screen memory for screen input/output
REM 128 * 256 = 32768, which is the start of Bank 2
rem -----
REM Reduce Basic RAM Size
POKE 55,255 : POKE 56,127 : CLR : REM Set end to $7FFF


GOTO Title_Screen

Wait_Title:
    GET K$ : IF K$ <> "S" THEN Wait_Title
    GOTO Restart

Get_User_Instruction:
Check_String_Variable_Pointer:
    IF PEEK(52) <= 112 THEN POKE 52,120 : REM Limit Growth of string variable pointer

    POKE 649,1 : REM Set keyboard buffer size to 1
    GET K$ : REM Get Keyboard Key
    REM Next instruction based on key press
    IF K$ = "Q" THEN END
    IF CR > 0 AND (K$ = "-" OR K$ = "_") THEN Decrease_Bet : REM Decrease Bet
    IF CR > 0 AND (K$ = "+" OR K$ = "=") THEN Increase_Bet : REM Increase Bet
    IF CR > 0 AND K$ = "S" THEN Play_Next_Credit : REM Play Next Credit
    IF CR <= 0 AND K$ = "P" THEN Restart : REM Restart
    IF CR <= 0 AND GC < 150 THEN GC = GC + 1 : REM GC = Game over timer counter
    IF GC >= 150 THEN Title_Screen
    GOTO Get_User_Instruction : REM Get Keyboard Key

Set_Cursor_Position:
    REM Set Cursor Position to X=XP%, Y=YP% : Clear Flags : CALL PLOT kernal routine
    POKE 781,YP% : POKE 782,XP% : POKE 783,0 : SYS 65520
    RETURN
#---------------------

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
#---------------------

Centre_Text:
    REM Calculate padding spaces for centring
    REM LN% = Available Space Length

    REM Check string length and return if too long
    IF LEN(SS$) >= LN% THEN RETURN

    J = INT((LN% - LEN(SS$)) / 2)
    J = J - (J - INT(J/2) * 2) : REM Subtract 1 if J is odd - MOD Function

    FOR I = 1 TO J : REM 1 TO Number of Spaces Required
    SS$ = " " + SS$
    NEXT I

    REM Check string length and return if too long
    IF LEN(SS$) >= LN% THEN RETURN

    FOR I = LEN(SS$) TO LN% - 1
    SS$ = SS$ + " "
    NEXT I

    RETURN
#---------------------

Print_Instructions:
    REM Print Instructions with no credits
    IF CR > 0 THEN Print_Instructions__In_Credit
    PRINT "   [ P ] PLAY AGAIN   [ Q ] QUIT      ";
    RETURN
#---------------------

Print_Instructions__In_Credit:
    REM Print Instructions when in credit
    PRINT "   [ S ] Spin  [+/-] BET  [ Q ] QUIT  ";
    RETURN
#---------------------

Full_Win:
    REM Full Win (All 3 matching)
    WI = (VAL(FR$(R1%,1)) * BT%) : REM WI = Winning amount
    CR = CR + WI

    CV = WI : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits

    SS$ = FR$(R1%,0) + " WIN - YOU WIN: {92}" + CV$
    GOSUB Play_Full_Win_Sound : REM Play Full Win Sound
    RETURN
#---------------------

Half_Win:
    REM Half Win (Only first and second matching)
    WI = BT% * 2 : REM WI = Winning amount
    CR = CR + WI
    
    CV = WI : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits

    SS$ = "HALF WIN - YOU WIN: {92}" + CV$ : REM WV$ = Win string
    GOSUB Play_Half_Win_Sound : REM Play Half Win Sound
    RETURN
#---------------------

Print_Win_Strip_Text:
    REM Print Win Strip Text
    IF LEN(SS$) > 0 THEN Print_Win_Strip_Text__Centre_Text
    SS$ = "                              "
    GOTO Print_Win_Strip_Text__Continue

Print_Win_Strip_Text__Centre_Text:
    LN% = 30
    GOSUB Centre_Text

Print_Win_Strip_Text__Continue:
    XP% = 5 : YP% = 18 : GOSUB Set_Cursor_Position
    GOSUB Print_Strip_Text
    RETURN
#---------------------

Print_Bet_Strip_Text:
    REM Print Credit Strip Text
    CV = BT% : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits
    SS$ = "{92}" + CV$

    XP% = 10 : YP% = 1 : GOSUB Set_Cursor_Position
    GOSUB Print_Strip_Text
    RETURN
#---------------------

Print_Credit_Strip_Text:
    REM Print Credit Strip Text
    SS$ = ""
    CV = CR : REM Set credit value for internal processing
    GOSUB Format_Credit_String : REM Print Credits
    FOR I = LEN(CV$) TO 5 : REM Max length 6 - 1
    SS$ = " " + SS$
    NEXT I
    SS$ = SS$ + "{92}" + CV$

    XP% = 31 : YP% = 1 : GOSUB Set_Cursor_Position
    GOSUB Print_Strip_Text
    RETURN
#---------------------

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
#---------------------

Play_Sound:
    POKE SR + 4, 33 : REM GATE(1) + SAWTOOTH(32)
    FOR I = 1 TO DL : NEXT : REM KEEP THE GATE ON FOR SOUND
    POKE SR + 4, 32 : REM GATE(0) + SAWTOOTH(32) : TURN SOUND OFF
    RETURN
#---------------------

Play_Half_Win_Sound:
    DL = 125 : REM Note Delay

    POKE SR + 1, NS%(0,0) : POKE SR, NS%(0,1)
    GOSUB Play_Sound
    
    POKE SR + 1, NS%(1,0) : POKE SR, NS%(1,1)
    GOSUB Play_Sound
    
    RETURN
#---------------------

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
#---------------------

Initialise_Sprites:
    REM Initialise Sprites
    VL = 53248 : REM Base Vic Address and Sprite Screen Location (X) Y pos = + 1
    SL = 16 : REM Base Sprite Pointer Location
    VR = 32768
    SP = VR + 1016 : REM Base Sprite Pointer Address Location
    
    POKE VL+37,10 : POKE VL+38,2: rem multicolors 1 & 2
    POKE VL+21,0 : rem set all sprites invisible
    POKE VL+27,255 : REM Set sprites behind characters
    POKE VL+28, 255: rem multicolor
    POKE VL+29, 0 : POKE VL+23, 255: rem width & height    
    FOR X = 0 TO 5 : POKE VL+39+X,0 : NEXT : REM Sprite Colours (0)
    
    FOR X=0TO11 : FOR Y=0TO63 : READ Z : POKE VR + ((X+SL)*64) + Y,Z : NEXT : NEXT

    POKE VL+16,0 : REM Disable Sprites MSB (for x pos)
    POKE VL,40 : POKE VL+1,88: rem sprite 0 pos
    POKE VL+2,40 : POKE VL+3,130: rem sprite 0 pos
    POKE VL+4,88 : POKE VL+5,88: rem sprite 1 pos
    POKE VL+6,88 : POKE VL+7,130: rem sprite 1 pos
    POKE VL+8,136 : POKE VL+9,88: rem sprite 2 pos (4 + 255)
    POKE VL+10,136 : POKE VL+11,130: rem sprite 2 pos (4 + 255)
    RETURN
#---------------------

Initialise_Program:
    REM Initialise Program
    CLR
    POKE 198,0 : REM Clear keyboard Buffer
    POKE 649,1 : REM Set keyboard buffer size to 1
    POKE 650,PEEK(650) AND 63 : REM Disable Key repeat

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

Intialise_Reel_Order:
    RESTORE
    DIM RO%(15) : REM Reel Order
    FOR I = 0 TO 15 : READ Q : RO%(I) = Q : NEXT
    
    DIM SO%(16) : REM Sprite Order, last item repeated
    FOR I = 0 TO 16 : READ Q : SO%(I) = Q : NEXT

Initialise_Notes:
    REM Notes Array
    DIM NS%(1,1)
    NS%(0,0) = 35 : NS%(0,1) = 134 : REM C-Sharp (5)
    NS%(1,0) = 47 : NS%(1,1) = 107 : REM F-Sharp (5)

    GOSUB Initialise_Sprites : REM Initialise Sprites
    GOTO Wait_Title

Restart:
    POKE VL+21,0 : rem set all sprites invisible
    PRINT "{clr}{white}"; : REM Clear screen and set the text to white
    POKE 53280,0 : POKE 53281,0 : REM Set border and background to black
    RD% = INT(RND(-TI)) : REM Re-randomise the random seed    
    GC = 0 : REM GC = Game over timer counter
Initialise_Credits:
    REM Initialise Credits
    BT% = 10 : REM Initial Bet : BT% stores bet count
    IC = 100 : REM IC = Initial Credits
    CR = IC : REM CR = Credits
Initialise_Sound:
    SR = 54272 : REM SID BASE ADDRESS
    FOR I = SR TO SR + 24 : POKE I,0 : NEXT : REM Reset SID
    POKE SR + 5,9 : POKE SR + 6,0 : REM SET ADSR ENVELOPE
    POKE SR + 24,15 : REM SET MAX VOLUME
Print_Bet_Credit_Strip_Border:
    REM Print Bet and Credit Strip Borders
    PRINT "{176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}  {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}";
    PRINT "    BET:               Credit:"
    PRINT "{173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}  {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}"
Print_Machine:
    REM Print Machine Graphics
    PRINT "{176}{99}{99}{99}{99}{99}{178}{99}{99}{99}{99}{99}{178}{99}{99}{99}{99}{99}{174}  {176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}";
    PRINT "{98}     {98}     {98}     {98}                     ";
    PRINT "{98}     {98}     {98}     {98}    WIN WIN - : 2X   ";
    PRINT "{98}     {98}     {98}     {98}    CHERRY    : 3X   ";
    PRINT "{98}     {98}     {98}     {98}    PEAR      : 5X   ";
    PRINT "{109}     {98}     {98}     {110}    LEMON     : 6X   ";
    PRINT "{110}     {98}     {98}     {109}    GRAPE     : 7X   ";
    PRINT "{98}     {98}     {98}     {98}    APPLE     : 8X   ";
    PRINT "{98}     {98}     {98}     {98}    SEVEN     : 9X   ";
    PRINT "{98}     {98}     {98}     {98}    BAR       : 10X  ";
    PRINT "{98}     {98}     {98}     {98}                     ";
    PRINT "{173}{99}{99}{99}{99}{99}{177}{99}{99}{99}{99}{99}{177}{99}{99}{99}{99}{99}{189}  {173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}";
    PRINT
Print_Status_Strip_Border:
    REM Print Status Strip Borders
    PRINT "{176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}";
    PRINT
    PRINT "{173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}";
    PRINT

    GOSUB Print_Instructions : REM Print Instructions

Start_With_Random_Reels:
    R1 = INT(RND(1)*16) AND 15:R1% = RO%(R1):POKE SP+0,SL+SO%(R1):POKE SP+1,SL+SO%(R1+1)
    R2 = INT(RND(1)*16) AND 15:R2% = RO%(R2):POKE SP+2,SL+SO%(R2):POKE SP+3,SL+SO%(R2+1)
    R3 = INT(RND(1)*16) AND 15:R3% = RO%(R3):POKE SP+4,SL+SO%(R3):POKE SP+5,SL+SO%(R3+1)
    POKE VL+21,63 : rem set sprites 0-5 visible

#---------------------
    GOSUB Print_Bet_Strip_Text : REM Print Bet Strip Text
    GOSUB Print_Credit_Strip_Text : REM Print Credit Strip Text
    GOTO Get_User_Instruction : REM Get User Input
#---------------------

Game_Loop:
    SS$ = "" : GOSUB Print_Win_Strip_Text : REM Print Win Strip Text
Get_Reels:
    REM Generate Reels

    REM Shake the random numbers a few times and set offsets for the reels
    FOR RI = 0 TO 4
    R1% = INT(RND(1) * 4) : R2% = INT(RND(1) * 4) : R3% = INT(RND(1) * 4)
    NEXT RI

    FOR RI=1 TO 24
    REM Reels will spin for at least 12 counts
    IF RI < (12 + R1%) THEN R1 = (R1 - 1) AND 15
    IF RI < (16 + R2%) THEN R2 = (R2 - 1) AND 15
    IF RI < (20 + R3%) THEN R3 = (R3 - 1) AND 15
    
    POKE SP + 0, SL + SO%(R1) : POKE SP + 1, SL + SO%(R1+1)
    POKE SP + 2, SL + SO%(R2) : POKE SP + 3, SL + SO%(R2+1)
    POKE SP + 4, SL + SO%(R3) : POKE SP + 5, SL + SO%(R3+1)

    REM only play click sound if reels are still spinning
    IF RI >= 20 + R3% THEN RI = 99 : GOTO Get_Reels__Next
    POKE SR + 1,10 : POKE SR,0 : REM Play Reel Sound Pitch
    POKE SR + 4, 129 : REM GATE(1) + NOISE(128)
    POKE SR + 4, 128 : REM GATE(0) + NOISE(128) : TURN SOUND OFF   

Get_Reels__Next:
    NEXT RI

    REM Get reel symbol value to calculate win
    R1% = RO%(R1 AND 15) : R2% = RO%(R2 AND 15) : R3% = RO%(R3 AND 15)

    POKE 53269,63 : REM Set sprites 0-5 visible
#---------------

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
    IF CR <= 0 THEN Game_Over

    GOTO Get_User_Instruction

Game_Over:
    SS$ = "GAME OVER"
    GOSUB Print_Win_Strip_Text : REM Print Win Strip Text

    XP% = 0 : YP% = 21 : GOSUB Set_Cursor_Position
    GOSUB Print_Instructions
    GOTO Get_User_Instruction

#---------------------

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
#---------------------

Play_Next_Credit:
    POKE 649,0 : REM Set keyboard buffer size to 0 (disable keyboard)
    POKE 198,0 : REM Clear keyboard Buffer

    REM Deduct credit and play again
    IF CR >= BT% THEN Play_Next_Credit__Deduct_Bet
    CR = 0

    GOTO Play_Next_Credit__Continue

Play_Next_Credit__Deduct_Bet:
    CR = CR - BT%

Play_Next_Credit__Continue:
    GOSUB Print_Credit_Strip_Text
    GOTO Game_Loop
#---------------------

Title_Screen:
    REM Title Screen
    POKE 53269,0 : rem set all sprites invisible
    POKE 53280,0 : POKE 53281,0 : REM Set border and background to black
    PRINT "{clr}{white}                                        ";
    PRINT "                                        ";
    PRINT "  {186}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{184}{108}  ";
    PRINT "  {180}     {102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}{102}     {182}  ";
    PRINT "  {180}                                  {182}  ";
    PRINT "  {180}      {lightgreen}Fruit Machine Game Jam{white}      {182}  ";
    PRINT "  {180}                                  {182}  ";
    PRINT "  {180}     {100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}{100}     {182}  ";
    PRINT "  {180}                                  {182}  ";
    PRINT "  {180}     {185}{185}{185}{185}{185} {182}  {light-red}{rvs on}{190}   {188}{rvs off}{white}  {180}   {yellow}{rvs on}{190} {188}{rvs off}{white}      {182}  ";
    PRINT "  {180}           {182}     {light-red}{rvs on}{190}{172}{rvs off}{white}  {180}  {yellow}{rvs on}{111}{188} {187}{112}{rvs off}{white}     {182}  ";
    PRINT "  {180}      BAR  {182}    {light-red}{rvs on}{190}{172}{rvs off}{white}   {180} {yellow}{rvs on}{161} {187}   {rvs off}{161}{white}    {182}  ";
    PRINT "  {180}           {182}   {light-red}{rvs on}{180}{167}{rvs off}{white}    {180}  {yellow}{rvs on}{108}  {190}{186}{rvs off}{white}     {182}  ";
    PRINT "  {180}     {184}{184}{184}{184}{184} {182}   {light-red}{rvs on}{175}{175}{rvs off}{white}    {180}   {yellow}{rvs on}{187}{190}{172}{rvs off}{white}      {182}  ";
    PRINT "  {180}                                  {182}  ";
    PRINT "  {180}                                  {182}  ";
    PRINT "  {180}  {yellow}ITCH.IO/JAM/{white}                    {182}  ";
    PRINT "  {180}  {yellow}THE-SLOT-MACHINE-SIMULATION-JAM{white} {182}  ";
    PRINT "  {180}                                  {182}  ";
    PRINT "  {180}        ALTOFLUFF - 2024{grey3}/{white}25       {182}  ";
    PRINT "  {180}                                  {182}  ";
    PRINT "  {180}        {grey3}- {light-red}PRESS {yellow}S{light-red} TO PLAY {grey3}-{white}       {182}  ";
    PRINT "  {112}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{111}  ";
    PRINT "                                        ";
    PRINT "                     {grey3}GAME JAM BY RPI{white}";
    GOTO Initialise_Program : REM Can be readying up the rest of the game while waiting
    
REM Reel Order
    DATA 6,0,3,2,1,0,2,4,5,1,3,2,1,0,3,4
    DATA 0,1,2,3,4,5,6,7,8,9,10,3,4,5,2,11,0
Sprite_Data:
    REM Generated with spritemate
    :: rem 0 apple-bar / multicolor / color: 0
    data 5,92,0,5,87,0,13,85,192,1,85,64,3,85,192,0
    data 215,0,0,60,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,0,0,0,0,0,85,85,85,255,255,255
    data 0,0,0,20,4,20,29,29,29,17,17,17,23,21,23,128
    :: rem 1 bar-cherry / multicolor / color: 0
    data 29,29,29,17,17,17,23,17,17,60,51,51,0,0,0,85
    data 85,85,255,255,255,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,0,0,0,0,64,0,3,240,0,3,16
    data 0,13,0,0,12,0,0,31,0,0,255,192,0,192,192,128
    :: rem 2 cherry-grape / multicolor / color: 0
    data 1,64,80,7,113,220,5,113,92,5,113,92,1,192,112,0
    data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,0,12,0,0,60,0,0,240,0,15,192
    data 0,48,64,0,17,80,0,87,112,3,220,192,1,49,0,129
    :: rem 3 grape-lemon / multicolor / color: 0
    data 5,69,64,13,205,192,3,19,0,4,84,0,21,220,0,55
    data 48,0,12,0,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0
    data 0,117,0,1,85,64,5,215,80,21,85,116,23,119,84,129
    :: rem 4 lemon-pear / multicolor / color: 0
    data 53,85,92,13,221,112,3,85,192,0,215,0,0,60,0,0
    data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,12,0,0,15,0,0,12,0,0,12,0
    data 0,20,0,0,215,0,0,85,192,0,93,64,3,85,112,128
    :: rem 5 pear-cherry / multicolor / color: 0
    data 13,85,80,13,215,92,13,85,92,13,93,92,3,85,112,0
    data 213,192,0,63,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,0,0,0,0,64,0,3,240,0,3,16
    data 0,13,0,0,12,0,0,31,0,0,255,192,0,192,192,128
    :: rem 6 cherry-lemon / multicolor / color: 0
    data 1,64,80,7,113,220,5,113,92,5,113,92,1,192,112,0
    data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0
    data 0,117,0,1,85,64,5,215,80,21,85,116,23,119,84,129
    :: rem 7 lemon-apple / multicolor / color: 0
    data 53,85,92,13,221,112,3,85,192,0,215,0,0,60,0,0
    data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,12,0,0,15,0,0,12,0,0,20,0
    data 0,85,0,1,85,64,1,85,192,5,87,0,5,92,0,128
    :: rem 8 apple-seven / multicolor / color: 0
    data 5,92,0,5,87,0,13,85,192,1,85,64,3,85,192,0
    data 215,0,0,60,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,0,0,0,0,0,0,0,0,1,85,64
    data 1,85,64,3,253,64,0,1,64,0,5,64,0,5,192,128
    :: rem 9 seven-pear / multicolor / color: 0
    data 0,21,0,0,23,0,0,84,0,0,92,0,0,80,0,0
    data 80,0,0,240,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,12,0,0,15,0,0,12,0,0,12,0
    data 0,20,0,0,215,0,0,85,192,0,93,64,3,85,112,129
    :: rem 10 pear-grape / multicolor / color: 0
    data 13,85,80,13,215,92,13,85,92,13,93,92,3,85,112,0
    data 213,192,0,63,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,0,12,0,0,60,0,0,240,0,15,192
    data 0,48,64,0,17,80,0,87,112,3,220,192,1,49,0,128
    :: rem 11 grape-apple / multicolor / color: 0
    data 5,69,64,13,205,192,3,19,0,4,84,0,21,220,0,55
    data 48,0,12,0,0,0,0,0,0,0,0,0,0,0,0,0
    data 0,0,0,0,0,12,0,0,15,0,0,12,0,0,20,0
    data 0,85,0,1,85,64,1,85,192,5,87,0,5,92,0,128
