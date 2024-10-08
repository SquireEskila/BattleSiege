### BattleSiege! Version 1.0 Coded by Eskila and Cryle ###

# Window Title
var WINDOW BattleSiege!
# Compact Display = 0 or 1
var COMPACT 1
# If your character is mute you can use slates to play! Set to 1 to use a slate.
var USE_SLATE 0
# Gag whispering game info for more immersive playing = 0 or 1
var GAG_WHISPERS 0
# Some fun colors! Set COLOR to 0 to use only the default color.
var DEFAULT_COLOR WhiteSmoke
# Options: ORANGE, PINK, GREEN, BLUE--must be in caps!
var COLOR BLUE
# How do links look? Use two characters.
var TILE_BUTTON ##
# Maximum grid size is 26
var GRID_MAX 10
# Game border tile left edge
var BL [
# Game border tile right edge
var BR ]
# Game border tile across - must be 4 characters wide. Only seen with Compact display set to 0
var BT [--]
# Unmarked/Empty tile
var BE ~~
# Marked, empty tile
var BB vv
# Marked, occupied tile
var BH !!
# Tile fill for each game piece - do not use symbols like {}, @@, "", or ||
var PALADIN PP
var WARMAGE WW
var EMPATH EE
var RANGER RR
var THIEF TT
var TRAP <>
var TRAP_SPENT ><

##################

put #class BattleSiege true
var BattleSiege NewGame
var COLUMNS A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z
eval RIGHT_EDGE element ("0|%COLUMNS","%GRID_MAX")
eval BC element ("%COLUMNS","%GRID_MAX")
eval BC replacere ("%COLUMNS","(%BC.*)","")
eval BC replacere ("%BC","\|","   "
eval BC replacere ("%BC","^A"," *  A"
eval BC replacere ("%BC","\s\s\s$","  *"
var LOOP 0
var BA
BORDER_ACROSS_LOOP:
var BA %BA%BT
math LOOP add 1
if %LOOP < %GRID_MAX then goto BORDER_ACROSS_LOOP
if_1 then
    {
    eval 1 toupper ("%1")
    if matchre ("%1","BLUE|GREEN|PINK|ORANGE") then var COLOR $0
    }
if %COLOR != 0 then gosub %COLOR_COLORS
else gosub NO_COLORS

action var TILE $1 when ^SELECT_(.*)$
action var SHAPE $1 when ^SHAPE_SET_(\d)
action var ENEMY $1 when ^ENEMY_SELECT_(\w+)

GAME_SETUP:
var GAME_WON 0
var P 5
var EP ?
var W 5
var EW ?
var E 4
var EE ?
var R 4
var ER ?
var T 2
var ET ?
var GAME_SETUP 1 
var PALADIN_SET 0
var WARMAGE_SET 0
var EMPATH_SET 0
var RANGER_SET 0
var THIEF_SET 0
var TRAP_SET 0
var TRAP2_SET 0
var ENEMY_SET 0
var PIECE PALADIN
var LOOP 1
gosub SETVARS_LINKS

REDRAW_DISPLAY:
gosub DISPLAY
if %GAME_SETUP = 1 then gosub PIECE_INFO
if %GAME_SAVED_LOADED = 1 then 
    {
    put #echo >%WINDOW mono "%ECHO_2";#echo >%WINDOW
    var GAME_SAVED_LOADED 0
    }

GAME_LOOP:
gosub clear
if %GAME_SETUP = 1 then goto GAME_SETUP_LOOP
if %GAG_WHISPERS = 1 then put #ungag %OUTPUT_GAG
if !matchre ("%STRIKE","^0$") then goto ENEMY_STRIKES
if !matchre ("%INFO","^0$") then goto INFO_ON_MY_STRIKE
if ("%P|%W|%E|%R|%T" = "0|0|0|0|0") then gosub YOU_LOSE
if ("%EP|%EW|%EE|%ER|%ET" = "0|0|0|0|0") then gosub YOU_WIN
if %GAME_WON != 0 then 
    {
    put #class BattleSiege false
    exit
    }
matchre STRIKE_AT_ENEMY ^SELECT_
matchre REDRAW_DISPLAY ^REDRAW$
matchre SAVE_GAME_ENEMY ^SAVE_GAME_ENEMY
matchwait 2
goto GAME_LOOP

GAME_SETUP_LOOP:
matchre SET_PIECE ^SELECT_
matchre SET_PIECE_ORIENTATION ^SHAPE_SET_
matchre SET_ENEMY ^ENEMY_SELECT_
matchre RESET_ENEMY ^DO_NOT_WANT_ENEMY
matchre START_GAME ^START_THE_GAME
matchre REDRAW_DISPLAY ^REDRAW$
matchre GAME_SETUP ^REMOVE_MY_BATTLE_PIECES$
matchre SAVE_GAME_PRESET ^SAVE_GAME_PRESET
matchre LOAD_GAME_PRESET ^LOAD_GAME_PRESET
matchre LOAD_GAME_ENEMY_LIST ^LOAD_GAME_ENEMY
matchwait

STRIKE_AT_ENEMY:
math MYTURN add 1
if %USE_SLATE = 1 then goto USE_SLATE
pause 0.1
put say }%ENEMY %TILE.
matchre STRIKE_AT_ENEMY ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre GAME_LOOP ^You.*say to %ENEMY
matchwait 2
goto GAME_LOOP

NO_SLATE:
var USE_SLATE 0
goto STRIKE_AT_ENEMY

USE_SLATE:
if matchre ("$righthandnoun|$lefthandnoun","slate") then goto CLEAN_SLATE
pause 0.2
put get my slate
matchre USE_SLATE ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre CLEAN_SLATE ^You get .* slate
matchre NO_SLATE ^What were you
matchwait 2
goto USE_SLATE

CLEAN_SLATE:
pause 0.2
put clean my slate
matchre CLEAN_SLATE ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre WRITE_SLATE ^You rub .* slate clean
matchwait 2
goto CLEAN_SLATE

WRITE_SLATE:
pause 0.2
put write %TILE
matchre WRITE_SLATE ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre SHOW_SLATE ^You have written
matchwait 2
goto WRITE_SLATE

SHOW_SLATE:
pause 0.2
put show my slate to %ENEMY
matchre SHOW_SLATE ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre GAME_LOOP ^You show your slate to
matchwait 2
goto SHOW_SLATE


INFO_ON_MY_STRIKE:
if matchre ("%INFO","\|") then goto REVEAL_ENEMY_MANA_TRAP_TILES
eval TILE replacere ("%INFO","\:.*","")
eval FILL replacere ("%INFO","^.*\:","")
var E%TILE %BH
if %FILL = MISS then var E%TILE %BB
if %FILL = TRAP then 
    {
    var E%TILE %TRAP
    gosub MANA_TRAP_TRIGGERED
    }
var INFO 0
goto REDRAW_DISPLAY

REVEAL_ENEMY_MANA_TRAP_TILES:
var INFO 0|%INFO
eval LOOP count ("%INFO","|")

REVEAL_ENEMY_MANA_TRAP_TILES_LOOP:
eval VALIDSTRIKE element ("%INFO","%LOOP")
eval TILE replacere ("%VALIDSTRIKE","\:.*","")
eval FILL replacere ("%VALIDSTRIKE","^.*\:","")
var E%TILE %BH
if %FILL = MISS then var E%TILE %BB
if %FILL = TRAP then var E%TILE %TRAP
math LOOP subtract 1
if %LOOP != 0 then goto REVEAL_ENEMY_MANA_TRAP_TILES_LOOP
var INFO 0
goto REDRAW_DISPLAY

MANA_TRAP_TRIGGERED:
var TILES 0
eval TILE_LETTER replacere ("%TILE","\d+","")
eval TILE_NUMBER replacere ("%TILE","[A-Z]","")
var ECHO_TILES 0
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREVIOUS_LETTER_2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
eval LOOP count ("%TILES","|")
gosub TILE_HIT_LOOP
eval LOOP count ("%ECHO_TILES","|")

# pause to let other player's script resume the game loop...

REVEAL_MY_MANA_TRAP_TILES_LOOP:
eval VALIDSTRIKE element ("%ECHO_TILES","%LOOP")
eval TILE replacere ("%VALIDSTRIKE","\:.*","")
eval FILL replacere ("%VALIDSTRIKE","^.*\:","")
var %TILE %BH
if %FILL = MISS then var %TILE %BB
math LOOP subtract 1
if %LOOP != 0 then goto REVEAL_MY_MANA_TRAP_TILES_LOOP
eval ECHO_TILES replacere ("%ECHO_TILES","^0\|","")
pause 
var INFO 0

WHISPER_ENEMY_TRAP:
pause 0.2
put whisper %ENEMY BattleSiege: The explosion of your mana trap reveals %ECHO_TILES!
matchre WHISPER_ENEMY_TRAP ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre WHISPER_ENEMY_TRAP_WAIT ^Who are you trying to whisper to
matchre REDRAW_DISPLAY ^You whisper to %ENEMY
matchwait 2
goto WHISPER_ENEMY_TRAP

WHISPER_ENEMY_TRAP_WAIT:
if matchre ("$roomplayers","%ENEMY") then goto WHISPER_ENEMY_TRAP
pause 1
goto WHISPER_ENEMY_TRAP_WAIT

TILE_HIT_LOOP:
eval VALIDSTRIKE element ("%TILES","%LOOP")
gosub TILE_HIT
var ECHO_TILES %ECHO_TILES|%VALIDSTRIKE:%ECHO
math LOOP subtract 1
if %LOOP = 0 then return
goto TILE_HIT_LOOP

TILE_HIT:
var TILE %%VALIDSTRIKE
var ECHO MISS
if matchre ("%TILE","%PALADIN") then gosub HIT_SCORE P
if matchre ("%TILE","%WARMAGE") then gosub HIT_SCORE W
if matchre ("%TILE","%EMPATH") then gosub HIT_SCORE E
if matchre ("%TILE","%RANGER") then gosub HIT_SCORE R
if matchre ("%TILE","%THIEF") then gosub HIT_SCORE T
if matchre ("%TILE","%BH") then var ECHO HIT
if matchre ("%TILE","%TRAP") then var ECHO TRAP
if matchre ("%ECHO","HIT|KILL") then var %VALIDSTRIKE %BH
if matchre ("%ECHO","TRAP") then var %VALIDSTRIKE %TRAP_SPENT
if matchre ("%ECHO","MISS") then var %VALIDSTRIKE %BB
return

HIT_SCORE:
var ECHO $0
math %ECHO subtract 1
if %%ECHO = 0 then var ECHO KILL %ECHO
else var ECHO HIT
return

ENEMY_STRIKES:
math ENEMYTURN add 1
var VALIDSTRIKE %STRIKE
var STRIKE 0
if ("%VALIDSTRIKE" = "SLATE") then
    {
    if matchre ("%SLATESTRIKE","^0$") then goto GAME_LOOP
    else var VALIDSTRIKE %SLATESTRIKE
    }
eval TILE_LETTER replacere ("%VALIDSTRIKE","\d+","")
eval TILE_NUMBER replacere ("%VALIDSTRIKE","[A-Z]","")
var VALIDSTRIKE %TILE_LETTER%TILE_NUMBER
if %TILE_NUMBER > %GRID_MAX then goto GAME_LOOP
eval TILE_LETTER replacere ("%COLUMNS","%TILE_LETTER\|.*","")
eval TILE_LETTER count ("%TILE_LETTER","|")
if %TILE_LETTER > %GRID_MAX then goto GAME_LOOP
gosub TILE_HIT
if %GAG_WHISPERS = 1 then put #gag %OUTPUT_GAG
var SLATESTRIKE 0

WHISPER_ENEMY_STRIKES:
pause 0.2
put whisper %ENEMY BattleSiege: Your strike reveals %VALIDSTRIKE:%ECHO!
matchre WHISPER_ENEMY_STRIKES ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre WHISPER_ENEMY_WAIT ^Who are you trying to whisper to
matchre REDRAW_DISPLAY ^You whisper to %ENEMY
matchwait 2
goto WHISPER_ENEMY_STRIKES

WHISPER_ENEMY_STRIKES_WAIT:
if matchre ("$roomplayers","%ENEMY") then goto WHISPER_ENEMY_STRIKES
pause 1
goto WHISPER_ENEMY_STRIKES_WAIT

START_GAME:
var GAME_SETUP 0
var ENEMYTURN 0
var MYTURN 0
action var STRIKE $2 when ^%ENEMY.*(says|asks|exclaims|yells|belts out).*\,\s\".*([A-Z]\d+|\d+[A-Z])
action var STRIKE SLATE when ^%ENEMY shows you (his|her) slate
action var SLATESTRIKE $1 when ^The slate reads\:.*([A-Z]\d+|\d+[A-Z])
action var INFO $1 when ^%ENEMY whispers\, \"BattleSiege\: Your strike reveals (.*)\!\"
action var INFO $1 when ^%ENEMY whispers\, \"BattleSiege\: The explosion of your mana trap reveals (.*)\!\"
action var EP 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL P
action var EW 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL W
action var EE 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL E
action var ER 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL R
action var ET 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL T
var OUTPUT_GAG {^You whisper to %ENEMY\, \"BattleSiege\:|^$scriptname}
var INPUT_GAG {^%ENEMY whispers\, \"BattleSiege\:}
var STRIKE 0
var SLATESTRIKE 0
var INFO 0
goto REDRAW_DISPLAY

LIST_PEOPLE:
if !matchre ("$roomplayers","^Also here") then
    {
    put #echo >%WINDOW mono "No one in the area? {Refresh player list:#parse REDRAW}"
    return
    }
eval ROOM replacere ("$roomplayers","Also here\:\s|\s?(who (is|has)|whose).+?(!?(\,\s)|\sand\s|\.)|\,|\sand|\.","|")
eval ROOM replacere("%ROOM", "(^\||\|$|\s\(\w+\)|[\w'-]+\s|\s)", "")
var ROOM 0|%ROOM
eval LOOP count ("%ROOM","|")
var ECHO

LIST_PEOPLE_LOOP:
eval ENEMY element ("%ROOM","%LOOP")
var ECHO %ECHO {%ENEMY:#parse ENEMY_SELECT_%ENEMY},
math LOOP subtract 1
if %LOOP = 0 then
    {
    eval ECHO replacere ("%ECHO","\,$","")    
    put #echo >%WINDOW mono "%ECHO"
    return
    }
goto LIST_PEOPLE_LOOP

SET_ENEMY:
pause 0.1
put #echo >%WINDOW mono "You have chosen %ENEMY to be your opponent.";#echo >%WINDOW mono "{Continue?:#parse START_THE_GAME}";#echo >%WINDOW mono "{Choose someone else...:#parse DO_NOT_WANT_ENEMY}"
goto GAME_SETUP_LOOP

RESET_ENEMY:
pause 0.1
var ENEMY_SET 0
goto REDRAW_DISPLAY


####### PIECE SETUP ########

PIECE_INFO:
if %ENEMY_SET = 0 then var PIECE ENEMY
if %TRAP2_SET = 0 then var PIECE TRAP2
if %TRAP_SET = 0 then var PIECE TRAP
if %THIEF_SET = 0 then var PIECE THIEF
if %RANGER_SET = 0 then var PIECE RANGER
if %EMPATH_SET = 0 then var PIECE EMPATH
if %WARMAGE_SET = 0 then var PIECE WARMAGE
if %PALADIN_SET = 0 then var PIECE PALADIN
var ORIENT 0
var TILE 0
if %PIECE = PALADIN then
    {
    put #echo >%WINDOW mono "Select the center tile for your Paladin."
    put #echo >%WINDOW mono "Then select an orientation:"
    put #echo >%WINDOW mono "   # # | # #   | #     |     # "
    put #echo >%WINDOW mono " # #   |   # # | # #   |   # # "
    put #echo >%WINDOW mono " #     |     # |   # # | # #   "
    put #echo >%WINDOW mono "{Shape 1:#parse SHAPE_SET_1}|{Shape 2:#parse SHAPE_SET_2}|{Shape 3:#parse SHAPE_SET_3}|{Shape 4:#parse SHAPE_SET_4}"
    var ORIENT 1
    }
if %PIECE = WARMAGE then
    {
    put #echo >%WINDOW mono "Select the center tile for your Warrior Mage:"
    put #echo >%WINDOW mono "   #   "
    put #echo >%WINDOW mono " # # # "
    put #echo >%WINDOW mono "   #   "
    }
if %PIECE = EMPATH then
    {
    put #echo >%WINDOW mono "Select the lower-left corner tile for your Empath:"
    put #echo >%WINDOW mono " # #"
    put #echo >%WINDOW mono " # #"
    }
if %PIECE = RANGER then
    {
    put #echo >%WINDOW mono "Select the bottom/left tile for your Ranger."
    put #echo >%WINDOW mono "Then select an orientation:"
    put #echo >%WINDOW mono " #     |  "
    put #echo >%WINDOW mono " #     |  "
    put #echo >%WINDOW mono " #     |  "
    put #echo >%WINDOW mono " #     | # # # # "
    put #echo >%WINDOW mono "{Shape 1:#parse SHAPE_SET_1}|{Shape 2:#parse SHAPE_SET_2}"
    var ORIENT 1
    }
if %PIECE = THIEF then
    {
    put #echo >%WINDOW mono "Select the bottom tile for your Thief."
    put #echo >%WINDOW mono "Then select an orientation:"
    put #echo >%WINDOW mono " #     |     "
    put #echo >%WINDOW mono " #     | # # "
    put #echo >%WINDOW mono "{Shape 1:#parse SHAPE_SET_1}|{Shape 2:#parse SHAPE_SET_2}"
    var ORIENT 1
    }
if %PIECE = TRAP then
    {
    put #echo >%WINDOW mono "Select the tile to lay your first Mana Trap:"
    put #echo >%WINDOW mono "   ^   "
    put #echo >%WINDOW mono " < # > "
    put #echo >%WINDOW mono "   v   "
    put #echo >%WINDOW mono "(The trap is a single-tile which reveals adjacent tiles when hit.)"
    }
if %PIECE = TRAP2 then
    {
    put #echo >%WINDOW mono "Select the tile to lay your second Mana Trap:"
    put #echo >%WINDOW mono "   ^   "
    put #echo >%WINDOW mono " < # > "
    put #echo >%WINDOW mono "   v   "
    put #echo >%WINDOW mono "(The trap is a single-tile which reveals adjacent tiles when hit.)"
    }
if %PIECE = ENEMY then
    {
    put #echo >%WINDOW mono "Select your opponent from the following:"
    gosub LIST_PEOPLE
    }
put #echo >%WINDOW
return

SET_PIECE:
pause 0.1
if matchre ("%PIECE","PALADIN|WARMAGE") then
    {
    if matchre ("%TILE","^(A|%RIGHT_EDGE)|([A-Z]1|%GRID_MAX)$") then
        {
        put #echo >%WINDOW mono "Center tile cannot be on the edge of the board!"
        var TILE 0
        goto GAME_SETUP_LOOP
        }
    }
if matchre ("%PIECE","EMPATH") then
    {
    if matchre ("%TILE","^%RIGHT_EDGE|[A-Z]1$") then
        {
        put #echo >%WINDOW mono "Bottom-left tile cannot be on the upper or right edge of the board!"
        var TILE 0
        goto GAME_SETUP_LOOP
        }
    }
if matchre ("%PIECE","RANGER") then
    {
    evalmath TILE_NUMBER %GRID_MAX - 1
    eval TILE_LETTER element ("0|%COLUMNS","%TILE_NUMBER")
    evalmath TILE_NUMBER %GRID_MAX - 2
    eval TILES element ("0|%COLUMNS","%TILE_NUMBER")
    if matchre ("%TILE","(%TILE_LETTER|%TILES|%RIGHT_EDGE)(1|2|3)$") then
        {
        put #echo >%WINDOW mono "Bottom-left tile cannot be in this corner!"
        var TILE 0
        goto GAME_SETUP_LOOP
        }
    }        
if matchre ("%PIECE","THIEF") then
    {
    if matchre ("%TILE","^%RIGHT_EDGE1$") then
        {
        put #echo >%WINDOW mono "Bottom-left tile cannot be in this corner!"
        var TILE 0
        goto GAME_SETUP_LOOP
        }
    }    
if matchre ("%PIECE","TRAP") then
    {
    if matchre ("%TILE","^(A|%RIGHT_EDGE)|([A-Z]1|%GRID_MAX)$") then
        {
        put #echo >%WINDOW mono "Mana trap tile cannot be on the edge of the board!"
        var TILE 0
        goto GAME_SETUP_LOOP
        }
    }    
put #echo >%WINDOW mono "Selected tile %TILE!"
var TILES 0
eval TILE_LETTER replacere ("%TILE","\d+","")
eval TILE_NUMBER replacere ("%TILE","[A-Z]","")
if %PIECE = WARMAGE then goto PLACE_WARMAGE
if %PIECE = EMPATH then goto PLACE_EMPATH
if %PIECE = TRAP then goto PLACE_TRAP
if %PIECE = TRAP2 then goto PLACE_TRAP2
if %ORIENT = 1 then goto GAME_SETUP_LOOP
put #echo >%WINDOW mono "This text should never display."
goto REDRAW_DISPLAY

SET_PIECE_ORIENTATION:
pause 0.1
var TILES 0
if %TILE = 0 then 
    {
    put #echo >%WINDOW mono "Select a tile first!"
    goto GAME_SETUP_LOOP
    }
var PLACE_TILE %TILE   
if %PIECE = THIEF then
    {
    if %SHAPE = 1 then goto PLACE_THIEF_TALL
    else goto PLACE_THIEF_WIDE
    }
if %PIECE = RANGER then
    {
    if %SHAPE = 1 then goto PLACE_RANGER_TALL
    else goto PLACE_RANGER_WIDE
    }
# must be Paladin...
if %SHAPE = 1 then goto PLACE_PALADIN_SHAPE_1    
if %SHAPE = 2 then goto PLACE_PALADIN_SHAPE_2
if %SHAPE = 3 then goto PLACE_PALADIN_SHAPE_3
#goto PLACE_PALADIN_SHAPE_4

PLACE_PALADIN_SHAPE_4:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREVIOUS_LETTER_2
math TILE_NUMBER add 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_SHAPE_3:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREVIOUS_LETTER_2
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_SHAPE_2:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREVIOUS_LETTER_2
math TILE_NUMBER subtract 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_SHAPE_1:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREVIOUS_LETTER_2
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER

PLACE_PALADIN_CONFIRM:
gosub CONFIRM_PLACEMENT Paladin
gosub PRINT_PIECE PALADIN
var PALADIN_SET 1
goto REDRAW_DISPLAY

PLACE_WARMAGE:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREVIOUS_LETTER_2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub CONFIRM_PLACEMENT Warrior Mage
gosub PRINT_PIECE WARMAGE
var WARMAGE_SET 1
goto REDRAW_DISPLAY

PLACE_EMPATH:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub CONFIRM_PLACEMENT Empath
gosub PRINT_PIECE EMPATH
var EMPATH_SET 1
goto REDRAW_DISPLAY

PLACE_RANGER_WIDE:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_RANGER_CONFIRM

PLACE_RANGER_TALL:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER

PLACE_RANGER_CONFIRM:
gosub CONFIRM_PLACEMENT Ranger
gosub PRINT_PIECE RANGER
var RANGER_SET 1
goto REDRAW_DISPLAY

PLACE_THIEF_WIDE:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_THIEF_CONFIRM

PLACE_THIEF_TALL:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER

PLACE_THIEF_CONFIRM:
gosub CONFIRM_PLACEMENT Thief
gosub PRINT_PIECE THIEF
var THIEF_SET 1
goto REDRAW_DISPLAY

PLACE_TRAP:
var %TILE %TRAP
var TRAP_SET 1
goto REDRAW_DISPLAY

PLACE_TRAP2:
var %TILE %TRAP
var TRAP2_SET 1
var LOOP 1
gosub SETVARS_CLEAR
goto REDRAW_DISPLAY

PREVIOUS_LETTER_2:
eval TILE_LETTER replacere ("%COLUMNS","\|%TILE_LETTER.*","")
eval TILE_LETTER replacere ("%TILE_LETTER","\|[A-Z]$","")
eval TILE_LETTER replacere ("%TILE_LETTER","^.*\|","")
return

PREVIOUS_LETTER:
eval TILE_LETTER replacere ("%COLUMNS","\|%TILE_LETTER.*","")
eval TILE_LETTER replacere ("%TILE_LETTER",".*\|","")
return

NEXT_LETTER:
eval TILE_LETTER replacere ("%COLUMNS",".*%TILE_LETTER\|","")
eval TILE_LETTER replacere ("%TILE_LETTER","\|.*","")
return

CONFIRM_PLACEMENT:
var ECHO_PIECE $0
eval LOOP count ("%TILES","|")

CONFIRM_PLACEMENT_LOOP:
eval TILE element ("%TILES","%LOOP")
if !matchre ("%%TILE","%TILE_BUTTON") then
    {
    put #echo >%WINDOW mono "Cannot place your %ECHO_PIECE there!";#echo >%WINDOW mono "Try another spot or orientation."
    var TILES 0
    var TILE %PLACE_TILE
    eval TILE_LETTER replacere ("%TILE","\d+","")
    eval TILE_NUMBER replacere ("%TILE","[A-Z]","")
    goto GAME_LOOP
    }
math LOOP subtract 1
if %LOOP = 0 then return
goto CONFIRM_PLACEMENT_LOOP

PRINT_PIECE:
eval LOOP count ("%TILES","|")

PRINT_PIECE_LOOP:
eval TILE element ("%TILES","%LOOP")
var %TILE %$0
math LOOP subtract 1
if %LOOP = 0 then return
goto PRINT_PIECE_LOOP

######## DISPLAY ##########

DISPLAY:
put #window show %WINDOW
put #clear %WINDOW
put #echo >%WINDOW
if %GAME_SETUP = 1 then 
    {
    if def(BattleSiege_Preset) then put #echo >%WINDOW mono " {Load Preset Game:#parse LOAD_GAME_PRESET} - {Load Vs Game:#parse LOAD_GAME_ENEMY}"
    else put #echo >%WINDOW mono " {Load Vs Game:#parse LOAD_GAME_ENEMY}"
    put #echo >%WINDOW;#echo >%WINDOW mono " {Save Preset Game:#parse SAVE_GAME_PRESET} - {Restart Setup:#parse REMOVE_MY_BATTLE_PIECES}";#echo >%WINDOW
    }
else put #echo >%WINDOW mono " Playing against %ENEMY! - {Save %ENEMY Game:#parse SAVE_GAME_ENEMY}"
put #echo >%WINDOW mono "(In case of link failure, type {#parse REDRAW:#parse REDRAW})"
put #echo >%WINDOW;#echo >%WINDOW %CL1 mono "%BC"
var LOOP 1

ECHO:
var COL_LOOP 0
var ECHO

ECHO_LOOP:
eval COL element ("%COLUMNS","%COL_LOOP")
math COL_LOOP add 1
if %COL_LOOP > %GRID_MAX then
    {
    if %LOOP < 10 then put #echo >%WINDOW %CL%LOOP mono "%LOOP  %ECHO %LOOP"
    else put #echo >%WINDOW %CL%LOOP mono "%LOOP %ECHO %LOOP"
    math LOOP add 1
    if %LOOP > %GRID_MAX then
        {
        put #echo >%WINDOW %CL%LOOP mono "%BC"
        put #echo >%WINDOW
        if %GAME_SETUP = 0 then 
            {
            put #echo >%WINDOW mono "   Health: P-%P   W-%W   E-%E   R-%R  T-%T"
            put #echo >%WINDOW mono "   Turns: %MYTURN"
            put #echo >%WINDOW
            goto DISPLAY_ENEMY
            }
        return
        }
    if %COMPACT = 0 then put #echo >%WINDOW %CL%LOOP mono "   %BA"
    goto ECHO
    }
var ECHO %ECHO%BL%%COL%LOOP%BR
goto ECHO_LOOP

DISPLAY_ENEMY:
put #echo >%WINDOW mono "   Field Operations in %ENEMY's territory:"
put #echo >%WINDOW %CL1 mono "%BC"
var LOOP 1

ECHO_ENEMY:
var COL_LOOP 0
var ECHO

ECHO_ENEMY_LOOP:
eval COL element ("%COLUMNS","%COL_LOOP")
math COL_LOOP add 1
if %COL_LOOP > %GRID_MAX then
    {
    if %LOOP < 10 then put #echo >%WINDOW %CL%LOOP mono "%LOOP  %ECHO %LOOP"
    else put #echo >%WINDOW %CL%LOOP mono "%LOOP %ECHO %LOOP"
    math LOOP add 1
    if %LOOP > %GRID_MAX then
        {
        put #echo >%WINDOW %CL%LOOP mono "%BC"
        put #echo >%WINDOW
        put #echo >%WINDOW mono "   Health: P-%EP   W-%EW   E-%EE   R-%ER   T-%ET"
        put #echo >%WINDOW mono "   Turns: %ENEMYTURN"
        put #echo >%WINDOW
        return
        }
    if %COMPACT = 0 then put #echo >%WINDOW %CL%LOOP mono "   %BA"
    goto ECHO_ENEMY
    }
var ECHO %ECHO%BL%E%COL%LOOP%BR
goto ECHO_ENEMY_LOOP

######## SAVE\LOAD #########


SAVE_GAME_ENEMY:
var SAVE %RIGHT_EDGE|%GRID_MAX|%P|%W|%E|%R|%T|%EP|%EW|%EE|%ER|%ET|%MYTURN|%ENEMYTURN
var ECHO_2 Game versus %ENEMY saved!
var FILL %ENEMY
var LOOP 1
goto SAVE_GAME_OUTER_LOOP

SAVE_GAME_PRESET:
var SAVE %RIGHT_EDGE|%GRID_MAX|%PALADIN_SET|%WARMAGE_SET|%EMPATH_SET|%RANGER_SET|%THIEF_SET|%TRAP_SET|%TRAP2_SET
var ECHO_2 Preset game saved!
var FILL Preset
var LOOP 1

SAVE_GAME_OUTER_LOOP:
var GAME_SAVED_LOADED 1
var COL_LOOP 0

SAVE_GAME_INNER_LOOP:
eval COL element ("%COLUMNS","%COL_LOOP")
math COL_LOOP add 1
if %COL_LOOP > %GRID_MAX then
    {
    math LOOP add 1
    if %LOOP > %GRID_MAX then
        {
        put #var BattleSiege_%FILL %SAVE
        goto REDRAW_DISPLAY
        }
    goto SAVE_GAME_OUTER_LOOP
    }
if !matchre ("%%COL%LOOP","parse|%BE") then var SAVE %SAVE|%COL%LOOP:%%COL%LOOP
if %FILL != Preset then 
    {
    if !matchre ("%E%COL%LOOP","parse|%BE") then var SAVE %SAVE|E%COL%LOOP:%E%COL%LOOP
    }
goto SAVE_GAME_INNER_LOOP

LOAD_GAME_ENEMY_LIST:
put #echo >%WINDOW
put #echo >%WINDOW mono "Load game against who? - ({cancel loading:#parse NO_LOAD_GAME})"
gosub LIST_PEOPLE
matchre LOAD_GAME_ENEMY ^ENEMY_SELECT_
matchre REDRAW_DISPLAY ^NO_LOAD_GAME
matchwait

LOAD_GAME_ENEMY:
var LOOP 1
gosub SETVARS_LINKS
var GAME_SAVED_LOADED 1
if !def(BattleSiege_%ENEMY) then
    {
    var ECHO_2 There is no saved game with %ENEMY!
    goto REDRAW_DISPLAY
    }
var LOAD $BattleSiege_%ENEMY
var ECHO_2 Game versus %ENEMY loaded!
eval RIGHT_EDGE element ("%LOAD","0")
eval GRID_MAX element ("%LOAD","1")
eval P element ("%LOAD","2")
eval W element ("%LOAD","3")
eval E element ("%LOAD","4")
eval R element ("%LOAD","5")
eval T element ("%LOAD","6")
eval EP element ("%LOAD","7")
eval EW element ("%LOAD","8")
eval EE element ("%LOAD","9")
eval ER element ("%LOAD","10")
eval ET element ("%LOAD","11")
eval MYTURN element ("%LOAD","12")
eval ENEMYTURN element ("%LOAD","13")
eval COL_LOOP count ("%LOAD","|")
var LOOP 13
goto LOAD_GAME_LOOP

LOAD_GAME_PRESET:
var LOOP 1
gosub SETVARS_LINKS
var GAME_SAVED_LOADED 1
var LOAD $BattleSiege_Preset
var ECHO_2 Preset game loaded!
var ENEMY 0
eval RIGHT_EDGE element ("%LOAD","0")
eval GRID_MAX element ("%LOAD","1")
eval PALADIN_SET element ("%LOAD","2")
eval WARMAGE_SET element ("%LOAD","3")
eval EMPATH_SET element ("%LOAD","4")
eval RANGER_SET element ("%LOAD","5")
eval THIEF_SET element ("%LOAD","6")
eval TRAP_SET element ("%LOAD","7")
eval TRAP2_SET element ("%LOAD","8")
eval COL_LOOP count ("%LOAD","|")
if %COL_LOOP = 8 then goto REDRAW_DISPLAY
var LOOP 8

LOAD_GAME_LOOP:
eval TILE element ("%LOAD","%LOOP")
eval FILL replacere ("%TILE","^.*\:","")
eval TILE replacere ("%TILE","\:.*","")
var %TILE %FILL
math LOOP add 1
if %LOOP <= %COL_LOOP then goto LOAD_GAME_LOOP
var LOOP 1
gosub SETVARS_CLEAR
if %ENEMY = 0 then goto REDRAW_DISPLAY
goto START_GAME

######## SETVARS ##########

SETVARS_INIT:
var COL_LOOP 0

SETVARS_INIT_LOOP:
eval COL element ("%COLUMNS","%COL_LOOP")
math COL_LOOP add 1
if %COL_LOOP > %GRID_MAX then
    {
    math LOOP add 1
    if %LOOP > %GRID_MAX then return
    goto SETVARS_INIT
    }
var %COL%LOOP 0
goto SETVARS_INIT_LOOP

SETVARS_CLEAR:
var COL_LOOP 0

SETVARS_CLEAR_LOOP:
eval COL element ("%COLUMNS","%COL_LOOP")
math COL_LOOP add 1
if %COL_LOOP > %GRID_MAX then
    {
    math LOOP add 1
    if %LOOP > %GRID_MAX then return
    goto SETVARS_CLEAR
    }
if matchre ("%%COL%LOOP","%TILE_BUTTON") then var %COL%LOOP %BE
goto SETVARS_CLEAR_LOOP

SETVARS_LINKS:
var COL_LOOP 0

SETVARS_LINKS_LOOP:
eval COL element ("%COLUMNS","%COL_LOOP")
math COL_LOOP add 1
if %COL_LOOP > %GRID_MAX then
    {
    math LOOP add 1
    if %LOOP > %GRID_MAX then return
    goto SETVARS_LINKS
    }
var %COL%LOOP {%TILE_BUTTON:#parse SELECT_%COL%LOOP}
var E%COL%LOOP {%TILE_BUTTON:#parse SELECT_%COL%LOOP}
goto SETVARS_LINKS_LOOP

########################

YOU_WIN:
put #echo >%WINDOW lime mono "You won! A strategic mastermind!"
put #echo >%WINDOW lime mono "Total Turns: %MYTURN! - %ENEMY's Total Turns: %ENEMYTURN!"
var GAME_WON 1
return

YOU_LOSE:
put #echo >%WINDOW pink mono "You lost! But the real treasure is..."
put #echo >%WINDOW pink mono "...the mana traps we set off along the way!"
put #echo >%WINDOW lime mono "Total Turns: %MYTURN! - %ENEMY's Total Turns: %ENEMYTURN!"
var GAME_WON 2
return


PINK_COLORS:
 var CL1 #ff8fbe
 var CL2 #fe89be
 var CL3 #fc83be
 var CL4 #fa7dbf
 var CL5 #f877c0
 var CL6 #f571c1
 var CL7 #f26bc2
 var CL8 #ef65c4
 var CL9 #ec5fc6
var CL10 #e859c8
var CL11 #e454ca
var CL12 #e04ecc
var CL13 #db49cf
var CL14 #d544d2
var CL15 #d03fd5
var CL16 #c93bd8
var CL17 #c337db
var CL18 #bc33de
var CL19 #b430e2
var CL20 #ab2ee5
var CL21 #a22ce9
var CL22 #982bed
var CL23 #8c2af0
var CL24 #802bf4
var CL25 #712bf8
var CL26 #602dfb
var CL27 #4a2eff
return

BLUE_COLORS:
 var CL1 #6edafc
 var CL2 #60d4fc
 var CL3 #52cffc
 var CL4 #42c9fc
 var CL5 #30c3fc
 var CL6 #14bdfc
 var CL7 #00b7fc
 var CL8 #00b1fc
 var CL9 #00abfc
var CL10 #00a4fb
var CL11 #009ef7
var CL12 #0098f3
var CL13 #0092ef
var CL14 #008ceb
var CL15 #0085e8
var CL16 #007fe5
var CL17 #0079e3
var CL18 #0072e1
var CL19 #006be1
var CL20 #0062e3
var CL21 #0058e8
var CL22 #004fe4
var CL23 #0847df
var CL24 #223dda
var CL25 #3133d4
var CL26 #3c27ce
var CL27 #4516c7
return

GREEN_COLORS:
 var CL1 #61ffbd
 var CL2 #61fbb7
 var CL3 #62f8b1
 var CL4 #63f4ab
 var CL5 #63f0a5
 var CL6 #64ed9f
 var CL7 #64e999
 var CL8 #65e594
 var CL9 #65e28e
var CL10 #66de88
var CL11 #67da82
var CL12 #67d67d
var CL13 #68d377
var CL14 #68cf72
var CL15 #69cb6c
var CL16 #69c867
var CL17 #6ac462
var CL18 #6ac05c
var CL19 #6abd57
var CL20 #6bb952
var CL21 #6bb54c
var CL22 #6bb147
var CL23 #6cae42
var CL24 #6caa3d
var CL25 #6ca638
var CL26 #6ca332
var CL27 #6c9f2d
return

ORANGE_COLORS:
 var CL1 #fcdd6e
 var CL2 #fcd968
 var CL3 #fcd462
 var CL4 #fcd05c
 var CL5 #fccb56
 var CL6 #fcc750
 var CL7 #fcc24b
 var CL8 #fcbe45
 var CL9 #fcb93f
var CL10 #fcb43a
var CL11 #fcaf35
var CL12 #fdaa2f
var CL13 #fda52a
var CL14 #fda025
var CL15 #fd9b20
var CL16 #fd961b
var CL17 #fe9016
var CL18 #fe8a11
var CL19 #fe850c
var CL20 #fe7f07
var CL21 #fe7903
var CL22 #ff7200
var CL23 #ff6c00
var CL24 #ff6500
var CL25 #ff5d00
var CL26 #ff5600
var CL27 #ff4d00
return

NO_COLORS:
 var CL1 %DEFAULT_COLOR 
 var CL2 %DEFAULT_COLOR
 var CL3 %DEFAULT_COLOR
 var CL4 %DEFAULT_COLOR
 var CL5 %DEFAULT_COLOR
 var CL6 %DEFAULT_COLOR
 var CL7 %DEFAULT_COLOR
 var CL8 %DEFAULT_COLOR
 var CL9 %DEFAULT_COLOR
var CL10 %DEFAULT_COLOR
var CL11 %DEFAULT_COLOR
var CL12 %DEFAULT_COLOR
var CL13 %DEFAULT_COLOR
var CL14 %DEFAULT_COLOR
var CL15 %DEFAULT_COLOR
var CL16 %DEFAULT_COLOR
var CL17 %DEFAULT_COLOR
var CL18 %DEFAULT_COLOR
var CL19 %DEFAULT_COLOR
var CL20 %DEFAULT_COLOR
var CL21 %DEFAULT_COLOR
var CL22 %DEFAULT_COLOR
var CL23 %DEFAULT_COLOR
var CL24 %DEFAULT_COLOR
var CL25 %DEFAULT_COLOR
var CL26 %DEFAULT_COLOR
var CL27 %DEFAULT_COLOR
return
