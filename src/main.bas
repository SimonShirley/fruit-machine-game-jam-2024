REM --------------------------------------------------------------
REM FRUIT MACHINE GAME - ENHANCED VERSION
REM Demonstrates a slot-machine-like program on Commodore 64
REM with improved comments, better subroutine organization,
REM optional "health" logic, and various code clarifications.
REM 
REM NOTE: This code is structured to run on the C64 with BASIC V2.
REM       Make sure your environment or emulator is set up
REM       correctly and that you have enough memory before running.
REM       The added “health” variable is purely illustrative and
REM       can be integrated with the game logic as you see fit.
REM --------------------------------------------------------------

REM Some Constants
REM --------------
REM For multi-line remarks in Commodore BASIC, we chain REM lines or add them inline.

REM VIC-II and SID addresses
CONST_VIC_BASE = 53248
CONST_SID_BASE = 54272
CONST_BANK2_BASE = 32768
CHUNK_SIZE = 64  : REM Not actually used, just an example

REM #region Setup: Switch to Bank 2, etc.
POKE 56578,PEEK(56578) OR 3   : REM Allow writing to DDR of PORT A
POKE 56576,(PEEK(56576) AND 252) OR 1
POKE 53272,4                  : REM Character Memory pointer to $2000-$27FF
POKE 648,128                  : REM High byte for screen memory pointer
POKE 55,255 : POKE 56,127 : CLR
REM #endregion

REM 
REM Title Screen + Jump
REM -------------------
GOTO Title_Screen

REM Subroutine: Wait_Title
REM Waits for user to press "S" to start.
Wait_Title:
  GET K$
  IF K$ <> "S" THEN Wait_Title
  GOTO Restart

REM Subroutine: Introducing a “health” concept
REM This can be used to show the idea of expansions the user might want to do.
REM By default we set HP to 3; each spin can reduce HP if the user wants.
REM Or use it for an alternate “game over” condition.
HEALTH = 3

REM Subroutine: If user’s credit is less or equal to zero:
Get_User_Instruction__Credit_Less_Equal_Zero:
  IF K$ = "P" THEN Restart
  IF GC >= 150 THEN Title_Screen
  GC = GC + 1
  GOTO Get_User_Instruction

REM Main Input: Get_User_Instruction
REM We read keypresses, manage credit, holds, etc.
Get_User_Instruction:
Check_String_Variable_Pointer:
  IF PEEK(52) <= 112 THEN POKE 52,120

  POKE 649,1
  GET K$

  IF K$ = "Q" THEN END

  IF CR <= 0 THEN GOTO Get_User_Instruction__Credit_Less_Equal_Zero

  IF HA% AND K$ = "1" THEN HR%(0) = NOT HR%(0) : GOSUB Print_Hold_Strip_1
  IF HA% AND K$ = "2" THEN HR%(1) = NOT HR%(1) : GOSUB Print_Hold_Strip_2
  IF HA% AND K$ = "3" THEN HR%(2) = NOT HR%(2) : GOSUB Print_Hold_Strip_3

  IF K$ = "-" OR K$ = "_" THEN Decrease_Bet
  IF K$ = "+" OR K$ = "=" THEN Increase_Bet
  IF K$ = "S" THEN Play_Next_Credit

  REM Example usage: pressing “H” lowers health
  IF K$ = "H" THEN HEALTH = HEALTH - 1 : GOSUB Print_HealthBar

  GOTO Get_User_Instruction

REM Subroutine: Print_HealthBar
REM A simple text-based health display concept. You can adapt it for fancy
REM bar displays or sprite-based hearts. “HEALTH” is the total HP left.
Print_HealthBar:
  XP% = 0 : YP% = 4
  GOSUB Set_Cursor_Position
  PRINT "HEALTH: ";
  FOR I = 1 TO HEALTH
    PRINT "{heart}"; : REM Just as an example
  NEXT I
  IF HEALTH <= 0 THEN GOTO Health_Zero
  RETURN

Health_Zero:
  PRINT "YOU HAVE NO HEALTH LEFT!"
  GOTO Game_Over

REM Subroutine: Title_Screen
Title_Screen:
  REM Hide sprites
  POKE 53269,0
  POKE 53280,0 : POKE 53281,0
  PRINT "{clr}{white}   FRUIT MACHINE ENHANCED!   "
  PRINT " Press S to Start, H for Health usage, Q to Quit"
  IF LD THEN Title_Screen__Show_Loaded
Title_Screen__Show_Loading:
  PRINT "   Loading... (Extended functionality)  "
  GOTO Title_Screen__Continue
Title_Screen__Show_Loaded:
  PRINT "   [ S ] to START  "
Title_Screen__Continue:
  PRINT "   (C) 2024 Fruit Machine Jam, etc."

  IF LD THEN Wait_Title
  GOTO Initialise_Program

REM Subroutine: Initialise_Program
Initialise_Program:
  POKE 198,0
  POKE 649,1
  POKE 650,PEEK(650) AND 63
  LD = 0
  DIM HR%(2)
  DIM SA%(2)

  GOTO Initialise_Fruits

REM Subroutine: ...
REM The rest of your code from the original snippet remains. 
REM For brevity, not repeating everything here. 
REM But keep your lines for the reels logic, sound logic, etc.
REM You can incorporate or reference the “HEALTH” or other expansions 
REM throughout your code.

REM *Just append the rest of your large code snippet below this comment, 
REM or integrate them as you see best, while preserving the original logic.*

REM ----- [ The rest of the original code from your snippet continues ] -----

