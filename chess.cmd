## Run with any argument to play as black! 
## .chess black, .chess 2, .chess secondplayer, .chess egg noodles, etc.

# Window to display game in (will clear window between moves!)
var WINDOW Chess
# gender of your characters, for the ACT
var PRONOUN her
if matchre ("$charactername","male1|male2|male3") then var PRONOUN his
if matchre ("$charactername","nb1|nb2|nb3") then var PRONOUN their

# to debug while playing
var DEBUG 0

# Tile White and Black
var TW ><
var TB ··
# Symbols for White and Black sides' identification of pieces
var WHITE w
var BLACK b

## COPY THESE TO HIGHLIGHTS.CFG! ##
#
# #highlight {regexp} {#000000} {\[(··)\]} {Chess}
# #highlight {regexp} {#888888} {\[(><)\]} {Chess}
# #highlight {regexp} {#DDDD88} {\[(w.)\]} {Chess}
# #highlight {regexp} {#0088FF} {\[(b.)\]} {Chess}
#

# Piece characters
var PAWN c
var ROOK P
var KNIGHT R
var BISHOP C
var QUEEN B
var KING E

# Names of each piece
var ECHO_%PAWN Commoner
var ECHO_%ROOK Paladin
var ECHO_%KNIGHT Ranger
var ECHO_%BISHOP Cleric
var ECHO_%QUEEN Barbarian
var ECHO_%KING Empath
var ECHO_2 0

###### END USER VARIABLES ######

var PLAYER %WHITE
var EN %BLACK
if_1 then
    {
    var PLAYER %BLACK
    var EN %WHITE
    }

var ENEMY 0
var ALPHABET 0|A|B|C|D|E|F|G|H|I|J|K|L
var ALLTILES 0|A8|B8|C8|D8|E8|F8|G8|H8|A7|B7|C7|D7|E7|F7|G7|H7|A6|B6|C6|D6|E6|F6|G6|H6|A5|B5|C5|D5|E5|F5|G5|H5|A4|B4|C4|D4|E4|F4|G4|H4|A3|B3|C3|D3|E3|F3|G3|H3|A2|B2|C2|D2|E2|F2|G2|H2|A1|B1|C1|D1|E1|F1|G1|H1
var TILE_SETUP 0|%BLACK%ROOK|%BLACK%KNIGHT|%BLACK%BISHOP|%BLACK%QUEEN|%BLACK%KING|%BLACK%BISHOP|%BLACK%KNIGHT|%BLACK%ROOK|%BLACK%PAWN|%BLACK%PAWN|%BLACK%PAWN|%BLACK%PAWN|%BLACK%PAWN|%BLACK%PAWN|%BLACK%PAWN|%BLACK%PAWN|%TW|%TB|%TW|%TB|%TW|%TB|%TW|%TB|%TB|%TW|%TB|%TW|%TB|%TW|%TB|%TW|%TW|%TB|%TW|%TB|%TW|%TB|%TW|%TB|%TB|%TW|%TB|%TW|%TB|%TW|%TB|%TW|%WHITE%PAWN|%WHITE%PAWN|%WHITE%PAWN|%WHITE%PAWN|%WHITE%PAWN|%WHITE%PAWN|%WHITE%PAWN|%WHITE%PAWN|%WHITE%ROOK|%WHITE%KNIGHT|%WHITE%BISHOP|%WHITE%QUEEN|%WHITE%KING|%WHITE%BISHOP|%WHITE%KNIGHT|%WHITE%ROOK

eval LOOP count ("%TILE_SETUP","|")
var ROW 1
var COL 8
SET_BOARD:
eval TILE element ("%TILE_SETUP","%LOOP")
eval LETTER element ("%ALPHABET","%COL")
var %LETTER%ROW %TILE
var E%LETTER%ROW %TILE
math COL subtract 1
math LOOP subtract 1
if %COL = 0 then
    {
    var COL 8
    math ROW add 1
    if %ROW = 9 then goto CHOOSE_ENEMY
    }
goto SET_BOARD

CHOOSE_ENEMY:
gosub DISPLAY
gosub LIST_PEOPLE
action var ENEMY $1 when ^ENEMY_SELECT_(\w+)

CHOOSE_ENEMY_WAIT:
matchre CHOOSE_ENEMY ^REDRAW
matchre RESET_ENEMY ^DO_NOT_WANT_ENEMY
matchre SETUP_COMPLETE ^START_THE_GAME
matchre SET_ENEMY ^ENEMY_SELECT_
matchwait

SETUP_COMPLETE:
put #class chess on
if %DEBUG = 1 then debug 10
var INPUT 0
var TURNS 0
var ROOK_L_MOVED 0
var ROOK_R_MOVED 0
var KING_MOVED 0
var EN_TURNS 0
var ECHO_2 0
var EN_LAST_TURN 0
var DANGER_MOVES 0
var KINGBYPASS 0
var IN_PASSING 0
var KING_IN_DANGER 0
var TURN %WHITE
action var INPUT $1 when ^SELECT_(.*)
action var INPUT UPDATE;var TILE $2;var OLD_TILE $1 when ^\(%ENEMY moves .* from ([A-H]\d) to ([A-H]\d)
action var INPUT UPDATE;var CASTLE 1;var OLD_TILE $1 when ^\(%ENEMY moves \w+ Paladin at (.*) into position to protect \w+ Empath
action var ENEMY_ACT $1 when ^\((%ENEMY moves.*)\)$
action var INPUT CASTLE;var CASTLE LEFT when ^CASTLE_LEFT
action var INPUT CASTLE;var CASTLE RIGHT when ^CASTLE_RIGHT
action var INPUT REDRAW when ^REDRAW
action var KING_IN_DANGER 1 when ^\(^%ENEMY moves.* Now your Empath is in danger\!\)$

GAME_LOOP:
gosub clear
var INPUT 0
var CASTLE 0
gosub SET_LINKS
waiteval (%INPUT)
if %INPUT = REDRAW then goto GAME_LOOP
if %INPUT = CASTLE then goto CASTLE_ME
if %INPUT = UPDATE then goto ENEMY_TURN
if matchre ("%%INPUT","%PLAYER") then
    {
    gosub EVALUATE_MOVES
    goto NEXT_CLICK
    }
pause 0.001
goto GAME_LOOP

ENEMY_TURN:
var ECHO_2 %ENEMY_ACT
if matchre ("%ECHO_2","joins the (\w+)'s guild") then
    {
    if $0 = Barbarian then var %OLD_TILE %EN%QUEEN
    if $0 = Cleric then var %OLD_TILE %EN%BISHOP
    if $0 = Ranger then var %OLD_TILE %EN%KNIGHT
    if $0 = Paladin then var %OLD_TILE %EN%ROOK
    }
if %CASTLE = 1 then
    {
    eval OLD_ROW replacere ("%OLD_TILE","[A-H]","")
    eval OLD_COL replacere ("%OLD_TILE","\d","")
    gosub SET_BG_TILE
    var OLD_COL E
    gosub SET_BG_TILE
    if %OLD_TILE = H1 then
        {
        var F1 %EN%ROOK
        var G1 %EN%KING
        }
    if %OLD_TILE = H8 then
        {
        var F8 %EN%ROOK
        var G8 %EN%KING
        }
    if %OLD_TILE = A1 then
        {
        var D1 %EN%ROOK
        var C1 %EN%KING
        }
    if %OLD_TILE = A8 then
        {
        var D8 %EN%ROOK
        var C8 %EN%KING
        }
    }
else
    {
    var %TILE %%OLD_TILE
    eval OLD_ROW replacere ("%OLD_TILE","[A-H]","")
    eval OLD_COL replacere ("%OLD_TILE","\d","")
    gosub SET_BG_TILE
    if matchre ("%ENEMY_ACT","in passing") then
        {
        if %PLAYER = %WHITE then math OLD_ROW 4
        if %PLAYER = %BLACK then math OLD_ROW 5
        gosub SET_BG_TILE
        }    
    }
var TURN %PLAYER
math EN_TURNS add 1
var EN_LAST_TURN %%TILE|%TILE|%OLD_TILE
goto GAME_LOOP

NEXT_CLICK:
if %MYPIECE = %KING then gosub CLEAN_VALID_MOVES
if matchre ("%VALID_MOVES","\|") then eval VALID_MOVES replacere ("%VALID_MOVES","none\|","")
if %VALID_MOVES = none then
    {
    var ECHO_2 Your %ECHO_%MYPIECE has nowhere to move!
    goto GAME_LOOP
    }
var INPUT 0
gosub SET_LINKS_MOVE
waiteval (%INPUT)
if %INPUT = REDRAW then goto GAME_LOOP
var BACKUP_TILE_1 %OLD_TILE
var BACKUP_TILE_1_FILL %%OLD_TILE
var BACKUP_TILE_2 %INPUT
var BACKUP_TILE_2_FILL %%INPUT
# flows...

DO_MOVE:
var ECHO_2 You move your %ECHO_%MYPIECE from %OLD_TILE to %INPUT
var ACT moves %PRONOUN %ECHO_%MYPIECE from %OLD_TILE to %INPUT
if matchre ("%%INPUT","^%EN") then
    {
    eval ENPIECE replacere ("%%INPUT","^%EN","")
    var ECHO_2 %ECHO_2, capturing %ENEMY's %ECHO_%ENPIECE
    var ACT %ACT, capturing \@' %ECHO_%ENPIECE
    }
if matchre ("%INPUT","%IN_PASSING") then 
    {
    var ECHO_2 %ECHO_2 capturing %ENEMY's %PAWN in passing
    var ACT %ACT capturing \@' %PAWN in passing
    }
var ECHO_2 %ECHO_2!
var ACT act :%ENEMY %ACT!
var %INPUT %%OLD_TILE
if ((matchre ("%MYPIECE","%PAWN")) && (matchre ("%INPUT","[A-H](1|8)"))) then gosub JOIN_GUILD
# flows...

MOVE_COMPLETED:
math TURNS add 1
var TURN %EN
if %MYPIECE = %KING then var KING_MOVED 1
if (("%MYPIECE" = "%ROOK") && (matchre ("%OLD_TILE","A1|A8"))) then var ROOK_L_MOVED 1
if (("%MYPIECE" = "%ROOK") && (matchre ("%OLD_TILE","H1|H8"))) then var ROOK_R_MOVED 1
if %IN_PASSING = 1 then var IN_PASSING %OLD_COL
gosub SET_BG_TILE
eval ROW replacere ("%INPUT","[A-H]","")
eval COL replacere ("%INPUT","\d","")
gosub EVALUATE_MOVES_AFTER
if matchre ("%VALID_MOVES","%ENEMY_KING_TILE") then
    {
    var ACT %ACT Now \@' Empath is in danger!
    var ECHO_2 %ECHO_2 %ENEMY's Empath is now in danger!
    }
if %IN_PASSING = %INPUT then
    {
    if %PLAYER = %WHITE then var OLD_ROW 5
    if %PLAYER = %BLACK then var OLD_ROW 4
    gosub SET_BG_TILE
    }
if %KING_IN_DANGER = 1 then
    {
    gosub CHECKMATE_CHECK
    if %KING_IN_DANGER = 1 then
        {
        var %BACKUP_TILE_1 %BACKUP_TILE_1_FILL
        var %BACKUP_TILE_2 %BACKUP_TILE_2_FILL
        var ECHO_2 That move won't get your Empath out of danger!
        goto GAME_LOOP
        }
    }
var IN_PASSING 0
gosub ACTION
goto GAME_LOOP

CLEAN_VALID_MOVES:
eval LOOP count ("%VALID_MOVES","|")
if %LOOP = 0 then return

CLEAN_VALID_MOVES_LOOP:
eval TILE element ("%VALID_MOVES","%LOOP")
if matchre ("%DANGER_MOVES","%TILE") then eval VALID_MOVES replacere ("%VALID_MOVES","%TILE\||\|%TILE|%TILE","")
math LOOP subtract 1
if %LOOP = 0 then return
goto CLEAN_VALID_MOVES_LOOP

EVALUATE_MOVES:
var OLD_TILE %INPUT
eval MYPIECE replacere ("%%INPUT","%PLAYER","")
var ECHO_2 You have chosen your %ECHO_%MYPIECE! {Select another:#parse REDRAW}?
put #echo >%WINDOW mono "%ECHO_2"
eval ROW replacere ("%OLD_TILE","[A-H]","")
eval COL replacere ("%OLD_TILE","\d","")
#flow...

EVALUATE_MOVES_AFTER:
var OLD_ROW %ROW
var OLD_COL %COL
var VALID_MOVES none
var TARGET %EN
var TARGET_2 %PLAYER
if %MYPIECE = %PAWN then goto PAWN_MOVES
if %MYPIECE = %ROOK then goto ROOK_MOVES
if %MYPIECE = %KNIGHT then goto KNIGHT_MOVES
if %MYPIECE = %BISHOP then goto BISHOP_MOVES
if %MYPIECE = %QUEEN then goto QUEEN_MOVES
if %MYPIECE = %KING then goto KING_MOVES
goto ERROR

ACTION:
if %GAG = 1 then put #gag ^$scriptname
put #subs {^\(You} {($charactername}
pause 0.02
put %ACT
matchre ACTION ^\.\.\.wait|^Sorry\,
matchre RETURN ^\((You|$charactername) moves
matchwait 2
goto ACTION

RETURN:
pause 0.5
if %GAG = 1 then put #ungag ^$scriptname
put #unsub {^\(You} {($charactername}
return

SET_BG_TILE:
var BG %TB
if %PLAYER = %WHITE then
    {
    if ((matchre ("%OLD_ROW","2|4|6|8")) && (matchre ("%OLD_COL","A|C|E|G"))) then var BG %TW
    if ((matchre ("%OLD_ROW","1|3|5|7")) && (matchre ("%OLD_COL","B|D|F|H"))) then var BG %TW
    }
if %PLAYER = %BLACK then
    {
    if ((matchre ("%OLD_ROW","2|4|6|8")) && (matchre ("%OLD_COL","A|C|E|G"))) then var BG %TW
    if ((matchre ("%OLD_ROW","1|3|5|7")) && (matchre ("%OLD_COL","B|D|F|H"))) then var BG %TW
    }
var %OLD_COL%OLD_ROW %BG
return

JOIN_GUILD:
var OLD_TILE %INPUT
put #echo >%WINDOW mono "Your Commoner seeks to join a guild! Pick one!"
put #echo >%WINDOW mono " {Barbarian:#parse JOIN_Barbarian} - {Cleric:#parse JOIN_Cleric} - {Ranger:#parse JOIN_Ranger} - {Paladin:#parse JOIN_Paladin}"
action var INPUT $1 when ^JOIN_(.*)
var INPUT 0
waiteval (%INPUT)
if %INPUT = Paladin then var %OLD_TILE %PLAYER%ROOK
if %INPUT = Ranger then var %OLD_TILE %PLAYER%KNIGHT
if %INPUT = Cleric then var %OLD_TILE %PLAYER%BISHOP
if %INPUT = Barbarian then var %OLD_TILE %PLAYER%QUEEN
var ECHO_2 %ECHO_2 Your %ECHO_%PAWN joins the %INPUT's guild!
var ACT %ACT $charactername's %ECHO_%PAWN joins the %INPUT's guild!
return

SET_LINKS:
if %DEBUG = 1 then debug 0
var HP 0
var EN_HP 0
eval LINKLOOP count ("%ALLTILES","|")
var DANGER_MOVES 00

SET_LINKS_LOOP:
eval TILE element ("%ALLTILES","%LINKLOOP")
if matchre ("%%TILE","^%PLAYER") then
    {
    if %TURN = %PLAYER then var E%TILE {%%TILE:#parse SELECT_%TILE}
    else var E%TILE %%TILE
    math HP add 1
    if %%TILE = %PLAYER%KING then var KING_TILE %TILE
    }
else var E%TILE %%TILE
if matchre ("%%TILE","^%EN") then
    {
    math EN_HP add 1
    if %%TILE = %EN%KING then var ENEMY_KING_TILE %TILE
    if %TURN = %PLAYER then
        {
        gosub DETECT_ENEMY_MOVES
        eval VALID_MOVES replacere ("%VALID_MOVES","^\|","")
        if ("%VALID_MOVES" != "") then var DANGER_MOVES %DANGER_MOVES|%VALID_MOVES
        var KINGBYPASS 0
        }
    }
math LINKLOOP subtract 1
if %LINKLOOP = 0 then goto DISPLAY
goto SET_LINKS_LOOP

SET_LINKS_MOVE:
if %DEBUG = 1 then debug 0
eval LOOP count ("%ALLTILES","|")

SET_LINKS_MOVE_LOOP:
eval TILE element ("%ALLTILES","%LOOP")
if matchre ("%TILE","%VALID_MOVES") then var E%TILE {%%TILE:#parse SELECT_%TILE}
else var E%TILE %%TILE
math LOOP subtract 1
if %LOOP = 0 then goto DISPLAY
goto SET_LINKS_MOVE_LOOP

DISPLAY:
if %DEBUG = 1 then debug 10
put #window show %WINDOW
put #clear %WINDOW
put #echo >%WINDOW mono "(Type {#parse REDRAW:#parse REDRAW} to refresh links!)"
put #echo >%WINDOW
if %ENEMY = 0 then
    {
    put #echo >%WINDOW mono " Pick your opponent to begin!"
    put #echo >%WINDOW
    return
    }
put #echo >%WINDOW mono " My Turns: %TURNS - %ENEMY's turns: %EN_TURNS"
put #echo >%WINDOW
put #echo >%WINDOW mono " * A   B   C   D   E   F   G   H  * "
if_1 then
    {
    put #echo >%WINDOW mono "1 [%EA1][%EB1][%EC1][%ED1][%EE1][%EF1][%EG1][%EH1] 1"
    put #echo >%WINDOW mono "2 [%EA2][%EB2][%EC2][%ED2][%EE2][%EF2][%EG2][%EH2] 2"
    put #echo >%WINDOW mono "3 [%EA3][%EB3][%EC3][%ED3][%EE3][%EF3][%EG3][%EH3] 3"
    put #echo >%WINDOW mono "4 [%EA4][%EB4][%EC4][%ED4][%EE4][%EF4][%EG4][%EH4] 4"
    put #echo >%WINDOW mono "5 [%EA5][%EB5][%EC5][%ED5][%EE5][%EF5][%EG5][%EH5] 5"
    put #echo >%WINDOW mono "6 [%EA6][%EB6][%EC6][%ED6][%EE6][%EF6][%EG6][%EH6] 6"
    put #echo >%WINDOW mono "7 [%EA7][%EB7][%EC7][%ED7][%EE7][%EF7][%EG7][%EH7] 7"
    put #echo >%WINDOW mono "8 [%EA8][%EB8][%EC8][%ED8][%EE8][%EF8][%EG8][%EH8] 8"
    }
else
    {
    put #echo >%WINDOW mono "8 [%EA8][%EB8][%EC8][%ED8][%EE8][%EF8][%EG8][%EH8] 8"
    put #echo >%WINDOW mono "7 [%EA7][%EB7][%EC7][%ED7][%EE7][%EF7][%EG7][%EH7] 7"
    put #echo >%WINDOW mono "6 [%EA6][%EB6][%EC6][%ED6][%EE6][%EF6][%EG6][%EH6] 6"
    put #echo >%WINDOW mono "5 [%EA5][%EB5][%EC5][%ED5][%EE5][%EF5][%EG5][%EH5] 5"
    put #echo >%WINDOW mono "4 [%EA4][%EB4][%EC4][%ED4][%EE4][%EF4][%EG4][%EH4] 4"
    put #echo >%WINDOW mono "3 [%EA3][%EB3][%EC3][%ED3][%EE3][%EF3][%EG3][%EH3] 3"
    put #echo >%WINDOW mono "2 [%EA2][%EB2][%EC2][%ED2][%EE2][%EF2][%EG2][%EH2] 2"
    put #echo >%WINDOW mono "1 [%EA1][%EB1][%EC1][%ED1][%EE1][%EF1][%EG1][%EH1] 1"
    }
put #echo >%WINDOW mono " * A   B   C   D   E   F   G   H  * "
put #echo >%WINDOW
if %TURN = %PLAYER then gosub CASTLE_CHECK
if ("%ECHO_2" != "0") then put #echo >%WINDOW mono "%ECHO_2"
var ECHO_2 0
return

#########

LIST_PEOPLE:
if !matchre ("$roomplayers","^Also here") then
    {
    put #echo >%WINDOW mono "No one in the area? {Refresh:#parse REDRAW} player list"
    return
    }
eval ROOM replacere ("$roomplayers","Also here\:\s|\s?(who (is|has)|whose).+?(!?(\,\s)|\sand\s|\.)|\,|\sand|\.","|")
eval ROOM replacere("%ROOM", "(^\||\|$|\s\(\w+\)|[\w'-]+\s|\s)", "")
var ROOM 0|%ROOM
eval LOOP count ("%ROOM","|")
var ECHO_2

LIST_PEOPLE_LOOP:
eval ENEMY element ("%ROOM","%LOOP")
var ECHO_2 %ECHO_2 {%ENEMY:#parse ENEMY_SELECT_%ENEMY},
math LOOP subtract 1
if %LOOP = 0 then
    {
    eval ECHO_2 replacere ("%ECHO_2","\,$","")
    put #echo >%WINDOW mono "%ECHO_2"
    return
    }
goto LIST_PEOPLE_LOOP

SET_ENEMY:
put #echo >%WINDOW
put #echo >%WINDOW mono "You have chosen %ENEMY to be your opponent.";#echo >%WINDOW mono "{Continue?:#parse START_THE_GAME}";#echo >%WINDOW mono "{Choose someone else...:#parse DO_NOT_WANT_ENEMY}"
goto CHOOSE_ENEMY_WAIT

RESET_ENEMY:
pause 0.1
var ENEMY 0
goto CHOOSE_ENEMY

######### PIECES MOVEMENT LOGIC ##########

CASTLE_ME:
if %PLAYER = %BLACK then
    {
    var OLD_ROW 8
    if %CASTLE = LEFT then
        {
        var OLD_COL E
        gosub SET_BG_TILE
        var C1 %PLAYER%KING
        var OLD_COL A
        gosub SET_BG_TILE
        var D8 %PLAYER%ROOK
        var OLD_TILE A8
        var TILE C8
        }
    if %CASTLE = RIGHT then
        {
        var OLD_COL E
        gosub SET_BG_TILE
        var G8 %PLAYER%KING
        var OLD_COL H
        gosub SET_BG_TILE
        var F8 %PLAYER%ROOK
        var OLD_TILE H8
        var TILE G8
        }
    }
if %PLAYER = %WHITE then
    {
    var OLD_ROW 1
    if %CASTLE = LEFT then
        {
        var OLD_COL E
        gosub SET_BG_TILE
        var C1 %PLAYER%KING
        var OLD_COL A
        gosub SET_BG_TILE
        var D1 %PLAYER%ROOK
        var OLD_TILE A1
        var TILE C1
        }
    if %CASTLE = RIGHT then
        {
        var OLD_COL E
        gosub SET_BG_TILE
        var G1 %PLAYER%KING
        var OLD_COL H
        gosub SET_BG_TILE
        var F1 %PLAYER%ROOK
        var OLD_TILE H1
        var TILE G1
        }
    }
var ACT act moves %PRONOUN Paladin at %OLD_TILE into position to protect %PRONOUN Empath, who is now at %TILE!
var ECHO_2 Your Paladin at %OLD_TILE moves into position to protect your Empath now at %TILE!
var MYPIECE %KING
goto MOVE_COMPLETED

CASTLE_CHECK:
if %PLAYER = %BLACK then
    {
    if ("%KING_MOVED" = "0") then
        {
        if (("%ROOK_L_MOVED" = "0") && (!matchre ("%B8|%C8|%D8","(%BLACK|%WHITE)(%KING|%QUEEN|%ROOK|%BISHOP|%KNIGHT)"))) then
            {
            if !matchre ("%DANGER_MOVES","B8|C8|D8") then put #echo >%WINDOW mono " {Castle Left:#parse CASTLE_LEFT}";#echo >%WINDOW
            }
        if (("%ROOK_R_MOVED" = "0") && (!matchre ("%F8|%G8","(%BLACK|%WHITE)(%KING|%QUEEN|%ROOK|%BISHOP|%KNIGHT)"))) then
            {
            if !matchre ("%DANGER_MOVES","F8|G8") then put #echo >%WINDOW mono " {Castle Right:#parse CASTLE_RIGHT}";#echo >%WINDOW
            }
        }
    }
if %PLAYER = %WHITE then
    {
    if ("%KING_MOVED" = "0") then
        {
        if (("%ROOK_L_MOVED" = "0") && (!matchre ("%B1|%C1|%D1","(%BLACK|%WHITE)(%KING|%QUEEN|%ROOK|%BISHOP|%KNIGHT)"))) then
            {
            if !matchre ("%DANGER_MOVES","B8|C8|D8") then put #echo >%WINDOW mono " {Castle Left:#parse CASTLE_LEFT}";#echo >%WINDOW
            }
        if (("%ROOK_R_MOVED" = "0") && (!matchre ("%F1|%G1","(%BLACK|%WHITE)(%KING|%QUEEN|%ROOK|%BISHOP|%KNIGHT)"))) then
            {
            if !matchre ("%DANGER_MOVES","F1|G1") then put #echo >%WINDOW mono " {Castle Right:#parse CASTLE_RIGHT}";#echo >%WINDOW
            }
        }
    }
return

CHECKMATE_CHECK:
eval LOOP count ("%ALLTILES","|")
var DANGER_MOVES 00

CHECKMATE_CHECK_LOOP:
eval TILE element ("%ALLTILES","%LOOP")
if %%TILE = %PLAYER%KING then var KING_TILE %TILE
if matchre ("%%TILE","^%EN") then
    {
    gosub DETECT_ENEMY_MOVES
    eval VALID_MOVES replacere ("%VALID_MOVES","^\|","")
    if ("%VALID_MOVES" != "") then var DANGER_MOVES %DANGER_MOVES|%VALID_MOVES
    var KINGBYPASS 0
    }
math LOOP subtract 1
if ("%LOOP" != "0") then goto CHECKMATE_CHECK_LOOP
if !matchre ("%DANGER_MOVES","%KING_TILE") then var KING_IN_DANGER 0
return

DETECT_ENEMY_MOVES:
var TARGET %PLAYER
var TARGET_2 %EN
eval ROW replacere ("%TILE","[A-H]","")
eval COL replacere ("%TILE","\d","")
var OLD_ROW %ROW
var OLD_COL %COL
eval TILE replacere ("%%TILE","^(%BLACK|%WHITE)","")
var KINGBYPASS 1
var VALID_MOVES
if %TILE = %QUEEN then goto QUEEN_MOVES
if %TILE = %KING then goto KING_MOVES
if %TILE = %BISHOP then goto BISHOP_MOVES
if %TILE = %KNIGHT then goto KNIGHT_MOVES
if %TILE = %ROOK then goto ROOK_MOVES
if %TILE = %PAWN then goto PAWN_MOVES
goto ERROR

QUEEN_MOVES:
var LOOP 7
gosub SCAN_NORTHEAST
gosub RESET_TILE
var LOOP 7
gosub SCAN_NORTHWEST
gosub RESET_TILE
var LOOP 7
gosub SCAN_SOUTHEAST
gosub RESET_TILE
var LOOP 7
gosub SCAN_SOUTHWEST
gosub RESET_TILE

ROOK_MOVES:
var LOOP 7
gosub SCAN_SOUTH
gosub RESET_TILE
var LOOP 7
gosub SCAN_NORTH
gosub RESET_TILE
var LOOP 7
gosub SCAN_EAST
gosub RESET_TILE
var LOOP 7
gosub SCAN_WEST
return

BISHOP_MOVES:
var LOOP 7
gosub SCAN_NORTHEAST
gosub RESET_TILE
var LOOP 7
gosub SCAN_NORTHWEST
gosub RESET_TILE
var LOOP 7
gosub SCAN_SOUTHEAST
gosub RESET_TILE
var LOOP 7
gosub SCAN_SOUTHWEST
return

KING_MOVES:
var LOOP 1
gosub SCAN_NORTHEAST
gosub RESET_TILE
var LOOP 1
gosub SCAN_NORTHWEST
gosub RESET_TILE
var LOOP 1
gosub SCAN_SOUTHEAST
gosub RESET_TILE
var LOOP 1
gosub SCAN_SOUTHWEST
gosub RESET_TILE
var LOOP 1
gosub SCAN_SOUTH
gosub RESET_TILE
var LOOP 1
gosub SCAN_NORTH
gosub RESET_TILE
var LOOP 1
gosub SCAN_EAST
gosub RESET_TILE
var LOOP 1
gosub SCAN_WEST
return

PAWN_MOVES:
if %TARGET_2 = %BLACK then
    {
    math ROW subtract 1
    if !matchre ("%%COL%ROW","^(%TARGET_2|%TARGET)") then
        {
        var VALID_MOVES %VALID_MOVES|%COL%ROW
        if %ROW = 6 then
            {
            math ROW subtract 1
            if !matchre ("%%COL%ROW","^(%TARGET_2|%TARGET)") then var VALID_MOVES %VALID_MOVES|%COL%ROW
            math ROW add 1
            }
        }
    }
if %TARGET_2 = %WHITE then
    {
    math ROW add 1
    if !matchre ("%%COL%ROW","^(%TARGET_2|%TARGET)") then
        {
        var VALID_MOVES %VALID_MOVES|%COL%ROW
        if %ROW = 3 then
            {
            math ROW add 1
            if !matchre ("%%COL%ROW","^(%TARGET_2|%TARGET)") then var VALID_MOVES %VALID_MOVES|%COL%ROW
            math ROW subtract 1
            }
        }
    }
if %EN_LAST_TURN != 0 then
    {
    eval PASSING_1 element ("%EN_LAST_TURN","0")
    eval PASSING_2 element ("%EN_LAST_TURN","1")
    eval PASSING_3 element ("%EN_LAST_TURN","2")
    if %PASSING_1 = %EN%PAWN then
        {
        if ((matchre ("%PASSING_3","2|7")) && (matchre ("%PASSING_2","4|5"))) then
            {
            if %TARGET_2 = %WHITE then math ROW subtract 1
            if %TARGET_2 = %BLACK then math ROW add 1
            gosub PREV_COL
            if ((matchre ("%%COL%ROW","%EN%PAWN")) && ("%COL%ROW" = "%PASSING_2")) then
                {
                if %TARGET_2 = %WHITE then math ROW add 1
                if %TARGET_2 = %BLACK then math ROW subtract 1
                var IN_PASSING %COL%ROW
                var VALID_MOVES %VALID_MOVES|%COL%ROW
                gosub NEXT_COL
                goto PAWN_PASSING_CHECK_DONE
                }
            gosub NEXT_COL_2
            if ((matchre ("%%COL%ROW","%EN%PAWN")) && ("%COL%ROW" = "%PASSING_2")) then
                {
                if %TARGET_2 = %WHITE then math ROW add 1
                if %TARGET_2 = %BLACK then math ROW subtract 1
                var IN_PASSING %COL%ROW
                var VALID_MOVES %VALID_MOVES|%COL%ROW
                gosub PREV_COL
                goto PAWN_PASSING_CHECK_DONE
                }
            gosub PREV_COL
            if %TARGET_2 = %WHITE then math ROW subtract 1
            if %TARGET_2 = %BLACK then math ROW add 1
            }
        }
    }
PAWN_PASSING_CHECK_DONE:
gosub PREV_COL
if matchre ("%%COL%ROW","^%TARGET") then var VALID_MOVES %VALID_MOVES|%COL%ROW
gosub NEXT_COL_2
if matchre ("%%COL%ROW","^%TARGET") then var VALID_MOVES %VALID_MOVES|%COL%ROW
return

KNIGHT_MOVES:
math ROW subtract 1
gosub PREV_COL_2_OB
gosub KNIGHT_CHECK
math ROW subtract 2
gosub PREV_COL_OB
gosub KNIGHT_CHECK
math ROW subtract 2
gosub NEXT_COL_OB
gosub KNIGHT_CHECK
math ROW subtract 1
gosub NEXT_COL_2_OB
gosub KNIGHT_CHECK
math ROW add 1
gosub NEXT_COL_2_OB
gosub KNIGHT_CHECK
math ROW add 2
gosub NEXT_COL_OB
gosub KNIGHT_CHECK
math ROW add 2
gosub PREV_COL_OB
gosub KNIGHT_CHECK
math ROW add 1
gosub PREV_COL_2_OB
gosub KNIGHT_CHECK
return

KNIGHT_CHECK:
if matchre ("%ROW","\-") then goto RESET_TILE
if ((matchre ("%ROW","\b(1|2|3|4|5|6|7|8)\b")) && (matchre ("%COL","A|B|C|D|E|F|G|H"))) then
    {
    if !matchre ("%%COL%ROW","^%TARGET_2") then var VALID_MOVES %VALID_MOVES|%COL%ROW
    }
goto RESET_TILE


SCAN_SOUTH:
math ROW add 1
if %ROW = 9 then return
gosub BYPASS_CHECK
if matchre ("%%COL%ROW","^%TARGET_2") then return
var VALID_MOVES %VALID_MOVES|%COL%ROW
if %ROW = 1 then return
math LOOP subtract 1
if %LOOP = 0 then return
goto SCAN_SOUTH

SCAN_NORTH:
math ROW subtract 1
if %ROW = 0 then return
gosub BYPASS_CHECK
if matchre ("%%COL%ROW","^%TARGET_2") then return
var VALID_MOVES %VALID_MOVES|%COL%ROW
if %ROW = 8 then return
math LOOP subtract 1
if %LOOP = 0 then return
goto SCAN_NORTH

SCAN_EAST:
gosub NEXT_COL
if %COL = I then return
gosub BYPASS_CHECK
if matchre ("%%COL%ROW","^%TARGET_2") then return
var VALID_MOVES %VALID_MOVES|%COL%ROW
if %COL = H then return
math LOOP subtract 1
if %LOOP = 0 then return
goto SCAN_EAST

SCAN_WEST:
gosub PREV_COL
if %COL = 0 then return
gosub BYPASS_CHECK
if matchre ("%%COL%ROW","^%TARGET_2") then return
var VALID_MOVES %VALID_MOVES|%COL%ROW
if %COL = A then return
math LOOP subtract 1
if %LOOP = 0 then return
goto SCAN_WEST

SCAN_NORTHEAST:
math ROW subtract 1
if %ROW = 0 then return
gosub NEXT_COL
if %COL = I then return
gosub BYPASS_CHECK
if matchre ("%%COL%ROW","^%TARGET_2") then return
var VALID_MOVES %VALID_MOVES|%COL%ROW
if %ROW = 1 then return
if %COL = H then return
math LOOP subtract 1
if %LOOP = 0 then return
goto SCAN_NORTHEAST

SCAN_NORTHWEST:
math ROW subtract 1
if %ROW = 0 then return
gosub PREV_COL
if %COL = 0 then return
gosub BYPASS_CHECK
if matchre ("%%COL%ROW","^%TARGET_2") then return
var VALID_MOVES %VALID_MOVES|%COL%ROW
if %ROW = 1 then return
if %COL = A then return
math LOOP subtract 1
if %LOOP = 0 then return
goto SCAN_NORTHWEST

SCAN_SOUTHWEST:
math ROW add 1
if %ROW = 9 then return
gosub PREV_COL
if %COL = 0 then return
gosub BYPASS_CHECK
if matchre ("%%COL%ROW","^%TARGET_2") then return
var VALID_MOVES %VALID_MOVES|%COL%ROW
if %ROW = 8 then return
if %COL = A then return
math LOOP subtract 1
if %LOOP = 0 then return
goto SCAN_SOUTHWEST

SCAN_SOUTHEAST:
math ROW add 1
if %ROW = 9 then return
gosub NEXT_COL
if %COL = I then return
gosub BYPASS_CHECK
if matchre ("%%COL%ROW","^%TARGET_2") then return
var VALID_MOVES %VALID_MOVES|%COL%ROW
if %ROW = 8 then return
if %COL = H then return
math LOOP subtract 1
if %LOOP = 0 then return
goto SCAN_SOUTHEAST

BYPASS_CHECK:
if matchre ("%%COL%ROW","^%TARGET") then
    {
    if %KINGBYPASS = 1 then
        {
        if %%COL%ROW != %EN%KING then var LOOP 1
        }
    else var LOOP 1
    }
return

RESET_TILE:
var ROW %OLD_ROW
var COL %OLD_COL
return

PREV_COL_2:
gosub PREV_COL

PREV_COL:
eval COL replacere ("0|%ALPHABET","\|%COL.*","")
eval COL replacere ("%COL",".*\|","")
return

NEXT_COL_2:
gosub NEXT_COL

NEXT_COL:
eval COL replacere ("%ALPHABET|0",".*%COL\|","")
eval COL replacere ("%COL","\|.*","")
return

PREV_COL_2_OB:
gosub PREV_COL_OB

PREV_COL_OB:
eval COL replacere ("0|%ALPHABET","\|%COL.*","")
eval COL replacere ("%COL",".*\|","")
return

NEXT_COL_2_OB:
gosub NEXT_COL_OB

NEXT_COL_OB:
eval COL replacere ("%ALPHABET|0",".*%COL\|","")
eval COL replacere ("%COL","\|.*","")
return

##########

ERROR:
put #echo >Log This wasn't supposed to happen!
