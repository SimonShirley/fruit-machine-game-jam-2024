REM Set VIC Bank 2
POKE 56578,PEEK(56578) OR 3 : REM Allow writing to PORT A
REM Set PORT A serial bus access to VIC Bank 2
POKE 56576,(PEEK(56576) AND 252) or 1
POKE 53272,4:REM Set pointer of character memory to $2000-$27FF / 8192-10239
POKE 648,128
REM High byte of pointer to screen memory for screen input/output
REM 128 * 256 = 32768, which is the start of Bank 2
REM Reduce Basic RAM Size
POKE 55,255 : POKE 56,127 : CLR : REM Set end to $7FFF


GOTO Title_Screen

Wait_Title:
    GET K$ : IF K$ <> "S" THEN Wait_Title
    GOTO Restart

Get_User_Instruction:
Check_String_Variable_Pointer:
    REM Limit Growth of string variable pointer
    IF PEEK(52) <= 112 THEN POKE 52,120

    POKE 649,1 : REM Set keyboard buffer size to 1
    GET K$ : REM Get Keyboard Key
    REM Next instruction based on key press
    IF K$ = "Q" THEN END
    IF CR > 0 AND HA% AND K$ = "1" THEN HR%(0) = NOT HR%(0) : GOSUB Print_Hold_Strip_1
    IF CR > 0 AND HA% AND K$ = "2" THEN HR%(1) = NOT HR%(1) : GOSUB Print_Hold_Strip_2
    IF CR > 0 AND HA% AND K$ = "3" THEN HR%(2) = NOT HR%(2) : GOSUB Print_Hold_Strip_3
    IF CR > 0 AND (K$ = "-" OR K$ = "_") THEN Decrease_Bet : REM Decrease Bet
    IF CR > 0 AND (K$ = "+" OR K$ = "=") THEN Increase_Bet : REM Increase Bet
    IF CR > 0 AND K$ = "S" THEN Play_Next_Credit : REM Play Next Credit
    IF CR <= 0 AND K$ = "P" THEN Restart : REM Restart
    IF CR <= 0 AND GC < 150 THEN GC = GC + 1 : REM GC = Game over timer counter
    IF GC >= 150 THEN Title_Screen
    GOTO Get_User_Instruction : REM Get Keyboard Key

Set_Cursor_Position:
    REM Set Cursor Position to X=XP%, Y=YP%
    REM Clear Flags
    REM CALL PLOT kernal routine
    POKE 781,YP% : POKE 782,XP% : POKE 783,0 : SYS 65520
    RETURN
#---------------------

Reset_Holds:
    REM Reset Holds
    HA% = 0
    FOR I = 0 TO 2 : HR%(I) = 0 : NEXT : REM Reset Holds

    GOSUB Print_Hold_Strip_Blank
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
#---------------------

Print_Instructions:
    REM Print Instructions with no credits
    IF CR > 0 THEN Print_Instructions__In_Credit
    PRINT OS$(3,0);
    RETURN
#---------------------

Print_Instructions__In_Credit:
    REM Print Instructions when in credit
    PRINT OS$(2,0);
    RETURN
#---------------------

Full_Win:
    REM Full Win (All 3 matching)
    WI = (VAL(FR$(R1%,1)) * BT%) : REM WI = Winning amount
    CR = CR + WI

    REM Win amount string now handled in Print_Win_Stip_Text sub
    GOSUB Play_Full_Win_Sound : REM Play Full Win Sound
    RETURN
#---------------------

Half_Win:
    REM Half Win (Only first and second matching)
    WI = BT% * 2 : REM WI = Winning amount
    CR = CR + WI
    
    REM Win amount string now handled in Print_Win_Stip_Text sub
    GOSUB Play_Half_Win_Sound : REM Play Half Win Sound
    RETURN
#---------------------

Print_Win_Strip_Text:
    REM Print Win Strip Text
    REM Requires Fruit offset, FR. -1 for not a fruit
    REM Requires WS index (to display WS$ value)
    XP% = 5 : YP% = 20 : GOSUB Set_Cursor_Position
    PRINT WS$(0,0); : REM Blank Line

    REM Line already blank, so no point printing another
    IF WS = 0 THEN RETURN

    XP% = 5 + VAL(WS$(WS,1)) : REM X Pos + Left Offset
    YP% = 20 : GOSUB Set_Cursor_Position

    IF WS = 1 THEN Print_Win_Strip_Text__WS1
    IF WS = 2 THEN Print_Win_Strip_Text__WS2
    GOTO Print_Win_Strip_Text__Print

Print_Win_Strip_Text__WS1:
    IF FR < 0 THEN Print_Win_Strip_Text__Print
    REM Print Win Strip Lookup Value
    CV = BT% * VAL(FR$(FR,1)) : GOSUB Format_Credit_String

    REM New X Pos + Fruit Text Offset
    XP% = XP% + VAL(FR$(FR,2))

    PRINT FR$(FR,0) + WS$(WS,0) + CV$; : RETURN 

Print_Win_Strip_Text__WS2:
    CV = BT% * 2 : GOSUB Format_Credit_String
    PRINT WS$(2,0) + CV$ : RETURN

Print_Win_Strip_Text__Print:
    PRINT WS$(WS,0) : RETURN
#---------------------

Print_Bet_Strip_Text:
    REM Print Credit Strip Text
    CV = BT% / 10 : REM Set credit value for internal processing
    XP% = 11 : YP% = 1 : GOSUB Set_Cursor_Position
    PRINT CA$(CV);
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

Print_Hold_Strip_Blank:
    XP% = 0 : YP% = 17 : GOSUB Set_Cursor_Position
    PRINT HT$(0);
    RETURN

Print_Hold_Strip_1:
    XP% = 2 : YP% = 17 : GOSUB Set_Cursor_Position
    IF HR%(0) THEN PRINT HT$(4) : RETURN
    PRINT HT$(1)
    RETURN

Print_Hold_Strip_2:
    XP% = 8 : YP% = 17 : GOSUB Set_Cursor_Position
    IF HR%(1) THEN PRINT HT$(5) : RETURN
    PRINT HT$(2)
    RETURN

Print_Hold_Strip_3:
    XP% = 14 : YP% = 17 : GOSUB Set_Cursor_Position
    IF HR%(2) THEN PRINT HT$(6) : RETURN
    PRINT HT$(3)
    RETURN

Print_Holds_Available:
    XP% = 22 : YP% = 17 : GOSUB Set_Cursor_Position
    PRINT HT$(7)
    RETURN

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


Initialise_Program:
    REM Initialise Program
    POKE 198,0 : REM Clear keyboard Buffer
    POKE 649,1 : REM Set keyboard buffer size to 1
    POKE 650,PEEK(650) AND 63 : REM Disable Key repeat

    LD = 0 : REM Loading flag, -1 = Loaded, 0 = Things to Load

    DIM HR%(2) : REM Hold Reels Array
    DIM SA%(2) : REM How far each reel needs to spin

#---------------------

Initialise_Fruits:
    DIM FR$(6,2) : REM Define Fruits array
    REM Fruit name, win multiplier
    FR$(0,0)="CHERRY":FR$(0,1)="3" : FR$(0,2) = "0"
    FR$(1,0)="PEAR"  :FR$(1,1)="5" : FR$(1,2) = "0"
    FR$(2,0)="LEMON" :FR$(2,1)="6" : FR$(2,2) = "0"
    FR$(3,0)="GRAPE" :FR$(3,1)="7" : FR$(3,2) = "0"
    FR$(4,0)="APPLE" :FR$(4,1)="8" : FR$(4,2) = "0"
    FR$(5,0)="SEVEN" :FR$(5,1)="9" : FR$(5,2) = "0"
    FR$(6,0)="BAR"   :FR$(6,1)="10": FR$(6,2) = "1"

#---------------------

Intialise_Reel_Order:
    RESTORE
    DIM RO%(15) : REM Reel Order
    FOR I = 0 TO 15 : READ Q : RO%(I) = Q : NEXT
    
    DIM SO%(16) : REM Sprite Order, last item repeated
    FOR I = 0 TO 16 : READ Q : SO%(I) = Q : NEXT

#---------------------

Initialise_Strings:
    DIM WS$(3,1) : REM String, Left padding
    WS$(0,0) = "                              " : WS$(0,1) = "0"
    WS$(1,0) = " WIN - YOU WIN: {92}" : WS$(1,1) = "2"
    WS$(2,0) = "HALF WIN - YOU WIN: {92}" : WS$(2,1) = "2"
    WS$(3,0) = "GAME OVER" : WS$(3,1) = "11"

    DIM CA$(10) : REM Cash amount strings
    CA$(0) = "0.00" : CA$(1) = "0.10" : CA$(2) = "0.20"
    CA$(3) = "0.30" : CA$(4) = "0.40" : CA$(5) = "0.50"
    CA$(6) = "0.60" : CA$(7) = "0.70" : CA$(8) = "0.80"
    CA$(9) = "0.90" : CA$(10) = "1.00"

    DIM OS$(4,1) : REM Other Strings
    OS$(0,0) = "    " : OS$(0,1) = "0" : REM Bet 4 - X.XX
    OS$(1,0) = "      " : OS$(1,1) = "0" : REM Credit 6 = XXX.XX
    OS$(2,0) = "   [ S ] Spin  [+/-] BET  [ Q ] QUIT  " : OS$(2,1) = "0"
    OS$(3,0) = "   [ P ] PLAY AGAIN   [ Q ] QUIT      " : OS$(3,1) = "0"

    DIM HT$(7) : REM Hold Text
    HT$(0) = "{171}     {123}     {123}     {179}                    "
    HT$(1) = "{light-red}{rvs on} 1 {rvs off}{white}"
    HT$(2) = "{light-red}{rvs on} 2 {rvs off}{white}"
    HT$(3) = "{light-red}{rvs on} 3 {rvs off}{white}"
    HT$(4) = "{lightgreen}{rvs on} 1 {rvs off}{white}"
    HT$(5) = "{lightgreen}{rvs on} 2 {rvs off}{white}"
    HT$(6) = "{lightgreen}{rvs on} 3 {rvs off}{white}"
    HT$(7) = "< HOLDS AVAILABLE"

#---------------------

Initialise_Notes:
    REM Notes Array
    DIM NS%(1,1)
    NS%(0,0) = 35 : NS%(0,1) = 134 : REM C-Sharp (5)
    NS%(1,0) = 47 : NS%(1,1) = 107 : REM F-Sharp (5)

#---------------------

Initialise_Sprites:
    REM Initialise Sprites
    VL = 53248 :REM Base Vic Address and Sprite Screen Location (X) Y pos = +1
    SL = 16 : REM Base Sprite Pointer Location
    VR = 32768
    SP = VR + 1016 : REM Base Sprite Pointer Address Location
    
    POKE VL+37,10 : POKE VL+38,2: rem multicolors 1 & 2
    POKE VL+21,0 : rem set all sprites invisible
    POKE VL+27,255 : REM Set sprites behind characters
    POKE VL+28, 255: rem multicolor
    POKE VL+29, 0 : POKE VL+23, 255: rem width & height    
    FOR X = 0 TO 5 : POKE VL+39+X,0 : NEXT : REM Sprite Colours (0)
    
    FOR X = 0 TO 11
    FOR Y = 0 TO 63
    READ Z
    POKE VR + ((X+SL)*64) + Y,Z
    NEXT Y
    NEXT X

    POKE VL+16,0 : REM Disable Sprites MSB (for x pos)
    POKE VL,40 : POKE VL+1,88: rem sprite 0 pos
    POKE VL+2,40 : POKE VL+3,130: rem sprite 0 pos
    POKE VL+4,88 : POKE VL+5,88: rem sprite 1 pos
    POKE VL+6,88 : POKE VL+7,130: rem sprite 1 pos
    POKE VL+8,136 : POKE VL+9,88: rem sprite 2 pos (4 + 255)
    POKE VL+10,136 : POKE VL+11,130: rem sprite 2 pos (4 + 255)

#---------------------

    LD = -1 : REM Game Defined and loaded

    XP% = 0 : YP% = 21 : GOSUB Set_Cursor_Position
    PRINT "  {180}        {grey3}- {light-red}PRESS {yellow}S{light-red} TO PLAY {grey3}-{white}       {182}  ";

    GOTO Wait_Title

Restart:
    POKE VL+21,0 : rem set all sprites invisible
    XP% = 0 : YP% = 0 : GOSUB Set_Cursor_Position
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
    PRINT "    BET:  {92}            Credit:"
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
    PRINT "{171}     {123}     {123}     {179}"
    PRINT
Print_Status_Strip_Border:
    REM Print Status Strip Borders
    PRINT "{176}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{174}";
    PRINT
    PRINT "{173}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{189}";
    PRINT

    GOSUB Print_Instructions : REM Print Instructions

Start_With_Random_Reels:
    R1 = INT(RND(1)*16) AND 15
    R1% = RO%(R1)
    POKE SP+0,SL+SO%(R1) : POKE SP+1,SL+SO%(R1+1)

    R2 = INT(RND(1)*16) AND 15
    R2% = RO%(R2)
    POKE SP+2,SL+SO%(R2) : POKE SP+3,SL+SO%(R2+1)

    R3 = INT(RND(1)*16) AND 15
    R3% = RO%(R3)
    POKE SP+4,SL+SO%(R3) : POKE SP+5,SL+SO%(R3+1)

    POKE VL+21,63 : rem set sprites 0-5 visible

#---------------------
    GOSUB Print_Bet_Strip_Text : REM Print Bet Strip Text
    GOSUB Print_Credit_Strip_Text : REM Print Credit Strip Text
    GOSUB Reset_Holds : REM Reset Holds
    GOTO Get_User_Instruction : REM Get User Input
#---------------------

Game_Loop:
Get_Reels:
    WS = 0 : FR = -1 : GOSUB Print_Win_Strip_Text : REM Print Win Strip Text

    REM Generate Reels

    REM Set the amount of times to spin the reel
    FOR RI = 0 TO 2 : SA%(RI) = 12 + (RI * 4) + INT(RND(1) * 4) : NEXT

    REM If a reel is held, set the spin distance to 0
    FOR RI = 0 TO 2
    IF HA% AND HR%(RI) THEN SA%(RI) = 0
    NEXT

    RA% = 0 : REM Max Reel Spin Amount Counter
    IF SA%(0) > RA% THEN RA% = SA%(0)
    IF SA%(1) > RA% THEN RA% = SA%(1)
    IF SA%(2) > RA% THEN RA% = SA%(2)

    IF RA% <= 0 THEN Get_Reels__Set_Win_Values

    REM Spin Reels - Reels will spin for at least 12 counts
    FOR RI=1 TO RA%

Get_Reels__Try_Reel_1:
    IF SA%(0) <= 0 THEN Get_Reels__Try_Reel_2
    R1 = (R1 - 1) AND 15 : REM Move Reel
    POKE SP + 0, SL + SO%(R1) : POKE SP + 1, SL + SO%(R1+1):REM Update Sprites
    SA%(0) = SA%(0) - 1

Get_Reels__Try_Reel_2:
    IF SA%(1) <= 0 THEN Get_Reels__Try_Reel_3
    R2 = (R2 - 1) AND 15 : REM Move Reel
    POKE SP + 2, SL + SO%(R2) : POKE SP + 3, SL + SO%(R2+1):REM Update Sprites
    SA%(1) = SA%(1) - 1

Get_Reels__Try_Reel_3:
    IF SA%(2) <= 0 THEN Get_Reels__Continue
    R3 = (R3 - 1) AND 15 : REM Move Reel
    POKE SP + 4, SL + SO%(R3) : POKE SP + 5, SL + SO%(R3+1):REM Update Sprites
    SA%(2) = SA%(2) - 1

Get_Reels__Continue:
    REM only play click sound if reels are still spinning    
    POKE SR + 1,10 : POKE SR,0 : REM Play Reel Sound Pitch
    POKE SR + 4, 129 : REM GATE(1) + NOISE(128)
    POKE SR + 4, 128 : REM GATE(0) + NOISE(128) : TURN SOUND OFF   

    NEXT RI

Get_Reels__Set_Win_Values:
    REM Get reel symbol value to calculate win
    R1% = RO%(R1 AND 15) : R2% = RO%(R2 AND 15) : R3% = RO%(R3 AND 15)

    POKE 53269,63 : REM Set sprites 0-5 visible
#---------------

    REM Check for Win
    IF R1% = R2% AND R2% = R3% THEN GOSUB Full_Win : FR = R1% : WS = 1
    IF R1% = R2% AND R2% <> R3% THEN GOSUB Half_Win : FR = R1% : WS = 2
    
    GOSUB Print_Win_Strip_Text : REM Print Win Strip Text
    GOSUB Print_Credit_Strip_Text : REM Print Credit Strip Text

    REM Check if there is enough credit to bet
    IF BT% <= CR THEN Game_Loop__Continue
    BT% = INT(CR) : REM Reduce bet to remaining credit
    GOSUB Print_Bet_Strip_Text

Game_Loop__Continue:
    IF CR <= 0 THEN Game_Over

    GOSUB Reset_Holds
    RD% = INT(RND(1) * 5) : REM Get Hold Chance 40%
    
    IF WS <> 1 AND RD% >= 3 THEN HA% = -1 : REM Enable Holds
    IF NOT HA% THEN GOSUB Reset_Holds : GOTO Get_User_Instruction

    GOSUB Print_Holds_Available
    GOSUB Print_Hold_Strip_1
    GOSUB Print_Hold_Strip_2
    GOSUB Print_Hold_Strip_3
    GOTO Get_User_Instruction

Game_Over:
    GOSUB Reset_Holds : REM Reset Holds

    WS = 3 : FR = -1 : GOSUB Print_Win_Strip_Text : REM Print Win Strip Text

    XP% = 0 : YP% = 23 : GOSUB Set_Cursor_Position
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
    IF LD THEN Title_Screen__Show_Loaded
Title_Screen__Show_Loading:
    PRINT "  {180}     {grey3}- LOADING - PLEASE WAIT {grey3}-{white}    {182}  ";
    GOTO Title_Screen__Continue
Title_Screen__Show_Loaded:
    PRINT "  {180}        {grey3}- {light-red}PRESS {yellow}S{light-red} TO PLAY {grey3}-{white}       {182}  ";
Title_Screen__Continue:
    PRINT "  {112}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{185}{111}  ";
    PRINT "                                        ";
    PRINT "                     {grey3}GAME JAM BY RPI{white}";

    REM If the game has loaded then wait for user on the title screen
    IF LD THEN Wait_Title

    REM Ready up the rest of the game while displaying screen to user
    GOTO Initialise_Program

    
Define_Reel_Order:
    REM Reel Order
    DATA 6,0,3,2,1,0,2,4,5,1,3,2,1,0,3,4
Define_Reel_Sprite_Order:
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
