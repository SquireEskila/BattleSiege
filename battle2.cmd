### BattleSiege! Version 1.2 Coded by Eskila and Cryle ###

# TO DO - make pieces an array and counter so it's easier for players to pick and choose which ones to play with

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
var MOONMAGE MM
var THIEF TT
var TRAP <>
var TRAP_SPENT ><
var PROTECTED ??

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
var M 3
var EM ?
var T 2
var ET ?
var GAME_SETUP 1
var PALADIN_SET 0
var WARMAGE_SET 0
var EMPATH_SET 0
var RANGER_SET 0
var MOONMAGE_SET 0
var THIEF_SET 0
var TRAP_SET 0
var TRAP2_SET 0
var ENEMY_SET 0
var PIECE PALADIN
var ECHO_2 0
var LOOP 1
gosub SETVARS_LINKS

REDRAW_DISPLAY:
gosub DISPLAY
if %GAME_SETUP = 1 then gosub PIECE_INFO
if ("%ECHO_2" != "0") then
    {
    put #echo >%WINDOW mono "%ECHO_2";#echo >%WINDOW
    var ECHO_2 0
    }

GAME_LOOP:
gosub clear
if %GAME_SETUP = 1 then goto GAME_SETUP_LOOP
if %GAG_WHISPERS = 1 then put #ungag %OUTPUT_GAG
if !matchre ("%STRIKE","^0$") then goto ENEMY_STRIKES
if !matchre ("%INFO","^0$") then goto INFO_ON_MY_STRIKE
if ("%P|%W|%E|%R|%M|%T" = "0|0|0|0|0|0") then gosub YOU_LOSE
if ("%EP|%EW|%EE|%ER|%EM|%ET" = "0|0|0|0|0|0") then gosub YOU_WIN
if %GAME_WON != 0 then
    {
    put #class BattleSiege false
    exit
    }
matchre REQUEST_EMPATH_SPECIAL ^EMPATH_SPECIAL
matchre REQUEST_MOONMAGE_LOCATE ^MOONMAGE_LOCATE
matchre REQUEST_MOONMAGE_BACKTRACE ^MOONMAGE_BACKTRACE
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

START_GAME:
var GAME_SETUP 0
var ENEMYTURN 0
var MYTURN 0
var MEFIRST
var ENFIRST
action var STRIKE $2 when ^%ENEMY.*(says|asks|exclaims|yells|belts out).*\,\s\".*([A-Z]\d+|\d+[A-Z])
action var STRIKE SLATE when ^%ENEMY shows you (his|her) slate
action var SLATESTRIKE $1 when ^The slate reads\:.*([A-Z]\d+|\d+[A-Z])
action var INFO $1 when ^%ENEMY whispers\, \"BattleSiege\: Your strike reveals (.*)\!\"
action var INFO $1 when ^%ENEMY whispers\, \"BattleSiege\: The explosion of your mana trap reveals (.*)\!\"
action var INFO $1 when ^%ENEMY whispers\, \"BattleSiege\: My Empath senses life around (.*)\!"
action var INFO $1;var SPECIAL_HIT Locate when ^%ENEMY whispers\, \"BattleSiege\: My Moon Mage casts Locate at (.*)\!"
action var INFO MOONMAGE when ^%ENEMY whispers\, \"BattleSiege\: My Moon Mage backtraces yours\!"
action var INFO $1;var SPECIAL_HIT WarMage when ^%ENEMY whispers\, \"BattleSiege\: Your Warrior Mage's self-immolation reveals (.*)\!\"
action var INFO $1;var SPECIAL_HIT Empath when ^%ENEMY whispers\, \"BattleSiege\: Your Empath's senses reveal (.*)\!"
action var INFO $1;var SPECIAL_HIT MoonMage when ^%ENEMY whispers\, \"BattleSiege\: Your Moon Mage's Locate spell reveals (.*)\!"
action var INFO $1;var SPECIAL_HIT Backtrace when ^%ENEMY whispers\, \"BattleSiege\: Your Moon Mage's backtrace reveals (.*)\!"
action var INFO $1;var SPECIAL_HIT Thief when ^%ENEMY whispers\, \"BattleSiege\: Your Thief's dying strike reveals (.*)\!\"
action var EP 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL P
action var EW 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL W
action var EE 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL E
action var ER 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL R
action var EM 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL M
action var ET 0 when ^%ENEMY whispers\, \"BattleSiege\:.*\:KILL T
var OUTPUT_GAG {^You whisper to %ENEMY\, \"BattleSiege\:|^$scriptname}
var INPUT_GAG {^%ENEMY whispers\, \"BattleSiege\:}
var STRIKE 0
var SLATESTRIKE 0
var INFO 0
var SPECIAL_HIT 0
goto REDRAW_DISPLAY

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


####### STRIKES ############


INFO_ON_MY_STRIKE:
math MYTURN add 1
if ("%ENFIRST" = "") then var MEFIRST First Strike!
if %INFO = MOONMAGE then goto MOONMAGE_BACKTRACE
if matchre ("%INFO","\|") then goto REVEAL_MULTI_TILES
if !matchre ("%INFO","\:") then goto EMPATH_SPECIAL
eval TILE replacere ("%INFO","\:.*","")
eval FILL replacere ("%INFO","^.*\:","")
if %SPECIAL_HIT = Thief then
    {
    math MYTURN subtract 1
    var SPECIAL_HIT 0
    var ECHO_2 Your Thief manages to lash out with their dying breath, striking at tile %TILE!
    }
var INFO 0
var E%TILE %BH
if %FILL = PROTECTED then var E%TILE {%PROTECTED:#parse SELECT_%TILE}
if %FILL = MISS then var E%TILE %BB
if %FILL = TRAP then
    {
    var E%TILE %TRAP_SPENT
    gosub MANA_TRAP_TRIGGERED
    }
if matchre ("%FILL","KILL T") then gosub THIEF_SPECIAL
if matchre ("%FILL","KILL W") then gosub WARMAGE_SPECIAL
if matchre ("%FILL","KILL") then eval FILL replacere ("%FILL","\s.*","")
if %ECHO_2 = 0 then var ECHO_2 You strike at tile %TILE and it's a %FILL!
if %FILL = PROTECTED then var ECHO_2 %ENEMY's Paladin deflects the attack on %TILE!
goto REDRAW_DISPLAY

REVEAL_MULTI_TILES:
math MYTURN subtract 1
var ECHO_2 %ENEMY's mana trap explodes, revealing several of your tiles to %ENEMY!
var INFO 0|%INFO
eval LOOP count ("%INFO","|")
if %SPECIAL_HIT = Locate then
    {
    eval TILE element ("%INFO","1")
    eval FILL element ("%INFO","2")    
    var ECHO_2 %ENEMY's Moon Mage casts Locate on tiles %TILE and %FILL!
    if %M != 0 then var ECHO_2 %ECHO_2 {Backtrace:#parse MOONMAGE_BACKTRACE} it?
    goto MOONMAGE_LOCATE
    }
if %SPECIAL_HIT = MoonMage then
    {
    math MYTURN add 1
    eval TILE element ("%INFO","1")
    eval TILE replacere ("%TILE","\:.*","")
    eval FILL element ("%INFO","2")
    eval FILL replacere ("%FILL","\:.*","")
    var ECHO_2 Your Moon Mage casts locate on tiles %TILE and %FILL!
    math MOONMAGE_SPECIAL subtract 1
    }
if %SPECIAL_HIT = Backtrace then
    {
    math MYTURN add 1
    var ECHO_2 Your Moon Mage backtraces the locate...
    }
if %SPECIAL_HIT = WarMage then
    {
    var ECHO_2 Your Warrior Mage manages to conflagrate the area with their dying breath, striking out all around them!
    }
if %SPECIAL_HIT = Empath then
    {
    var ECHO_2 Your Empath reaches out to sense nearby dangers!
    var EMPATH_SPECIAL 0
    }

REVEAL_MULTI_TILES_LOOP:
eval VALIDSTRIKE element ("%INFO","%LOOP")
eval TILE replacere ("%VALIDSTRIKE","\:.*","")
eval FILL replacere ("%VALIDSTRIKE","^.*\:","")
if matchre ("%SPECIAL_HIT","Empath|Backtrace") then
    {
    var E%TILE {%FILL:#parse SELECT_%TILE}
    goto REVEAL_MULTI_TILES_LOOP_NEXT
    }
if matchre ("%SPECIAL_HIT","MoonMage") then
    {
    var E%TILE {%FILL:#parse SELECT_%TILE}
    if %FILL = %BE then var E%TILE %BE
    if %FILL = %TRAP then var E%TILE %TRAP
    goto REVEAL_MULTI_TILES_LOOP_NEXT
    }    
var E%TILE %BH
if %FILL = PROTECTED then var E%TILE {%PROTECTED:#parse SELECT_%TILE}
if %FILL = MISS then var E%TILE %BB
if %FILL = TRAP then var E%TILE %TRAP
if matchre ("%FILL","KILL T") then gosub THIEF_SPECIAL
if matchre ("%FILL","KILL W") then gosub WARMAGE_SPECIAL

REVEAL_MULTI_TILES_LOOP_NEXT:
math LOOP subtract 1
if %LOOP != 0 then goto REVEAL_MULTI_TILES_LOOP
var SPECIAL_HIT 0
var INFO 0
goto REDRAW_DISPLAY

HIT_WHO:
if $0 = %PALADIN then var SPECIAL_HIT Paladin
if $0 = %WARMAGE then var SPECIAL_HIT Warrior Mage
if $0 = %EMPATH then var SPECIAL_HIT Empath
if $0 = %RANGER then var SPECIAL_HIT Ranger
if $0 = %MOONMAGE then var SPECIAL_HIT Moon Mage
if $0 = %THIEF then var SPECIAL_HIT Thief
return

THIEF_SPECIAL:
eval EN_THIEF_SPECIAL replacere ("%FILL","KILL T ","")
eval TILE_LETTER replacere ("%TILE","\d+","")
eval TILE_NUMBER replacere ("%TILE","[A-Z]","")
var SPECIAL_TILE %TILE_LETTER%TILE_NUMBER
if matchre ("%%EN_THIEF_SPECIAL","\d+") then
    {
    var SPECIAL_LOOP %TILE_NUMBER
    goto THIEF_SPECIAL_SCAN
    }
var SPECIAL_LOOP 1

FIND_THIEF_SPECIAL_LETTER:
eval SPECIAL_LETTER element ("0|%COLUMNS","%SPECIAL_LOOP")
if %SPECIAL_LETTER = %TILE_LETTER then goto THIEF_SPECIAL_SCAN
math SPECIAL_LOOP add 1
goto FIND_THIEF_SPECIAL_LETTER

THIEF_SPECIAL_SCAN:
math SPECIAL_LOOP add 1
if %SPECIAL_LOOP > %GRID_MAX then var SPECIAL_LOOP 1
if matchre ("%%EN_THIEF_SPECIAL","\d+") then var TILE_NUMBER %SPECIAL_LOOP
else eval TILE_LETTER element ("0|%COLUMNS","%SPECIAL_LOOP")
var TILE %TILE_LETTER%TILE_NUMBER
if %TILE = %SPECIAL_TILE then
    {
    var SPECIAL_HIT 0
    return
    }
if matchre ("%%TILE","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then goto THIEF_HIT_WHO
goto THIEF_SPECIAL_SCAN

THIEF_HIT_WHO:
gosub HIT_WHO %%TILE
var ECHO_2 As %ENEMY's thief perishes, they let loose with a throwing knife and strike your %SPECIAL_HIT!
var SPECIAL_HIT 0
var VALIDSTRIKE %TILE
gosub TILE_HIT
var WHISPER Your Thief's dying strike reveals %VALIDSTRIKE:%ECHO!
goto WHISPER_RETURN

RANGER_SPECIAL:
if %RANGER_SPECIAL_CHARGES = 0 then return
if matchre ("%RANGER_SPECIAL","\d") then var TILE_NUMBER %RANGER_SPECIAL
if matchre ("%RANGER_SPECIAL","[A-Z]") then var TILE_LETTER %RANGER_SPECIAL
if matchre ("%%TILE_LETTER%TILE_NUMBER","%BE") then
    {
    var %TILE_LETTER%TILE_NUMBER %RANGER
    var %VALIDSTRIKE %BE
    var TILE %BE
    math RANGER_SPECIAL_CHARGES subtract 1
    var ECHO_2 %ENEMY strikes at %VALIDSTRIKE but your Ranger dodges!
    }
return

REQUEST_MOONMAGE_LOCATE:
var ECHO_TILES 0

PICK_LOCATE_TILES_LOOP:
random 1 %GRID_MAX
if matchre ("%r","-") then eval r replacere ("%r","-","")
var TILE_NUMBER %r
pause 0.001
random 1 %GRID_MAX
if matchre ("%r","-") then eval r replacere ("%r","-","")
eval TILE_LETTER element ("0|%COLUMNS","%r")
if matchre ("%ECHO_TILES","%TILE_LETTER%TILE_NUMBER") then goto PICK_LOCATE_TILES_LOOP
if matchre ("%E%TILE_LETTER%TILE_NUMBER","%TILE_BUTTON") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER
eval LOOP count ("%ECHO_TILES","|")
if %LOOP < 2 then goto PICK_LOCATE_TILES_LOOP
eval ECHO_TILES replacere ("%ECHO_TILES","^0\|","")
var WHISPER My Moon Mage casts Locate at %ECHO_TILES!
gosub WHISPER_RETURN
goto GAME_LOOP

REQUEST_MOONMAGE_BACKTRACE:
var WHISPER My Moon Mage backtraces yours!
gosub WHISPER_RETURN
goto GAME_LOOP

MOONMAGE_LOCATE:
#var BACKTRACE_ENABLED 1
var SPECIAL_HIT 0
var ECHO_TILES 0

var LOOP 1
gosub COUNT_TILES_REMAINING
if TILES < 2 then
    {
    var ECHO_2 Why bother...? Also, your Moon Mage runs out of mana now.
    var MOONMAGE_SPECIAL 0
    goto REDRAW_DISPLAY
    }

MOONMAGE_LOCATE_LOOP:
eval TILE element ("%INFO","%LOOP")
var ECHO_TILES %ECHO_TILES|%TILE:%%TILE
math LOOP subtract 1
if %LOOP != 0 then goto MOONMAGE_LOCATE_LOOP
eval ECHO_TILES replacere ("%ECHO_TILES","^0\|","")
var INFO 0
var WHISPER Your Moon Mage's Locate spell reveals %ECHO_TILES!
goto WHISPER

MOONMAGE_BACKTRACE:
var ECHO_TILES 0
var LOOP 1
gosub SETVARS_FIND
eval ECHO_TILES replacere ("%ECHO_TILES","^0\|","")
var WHISPER Your Moon Mage's backtrace reveals %ECHO_TILES!
var INFO 0
var SPECIAL_HIT 0
gosub WHISPER_RETURN
goto GAME_LOOP

REQUEST_EMPATH_SPECIAL:
math MYTURN add 1
if ("%ENFIRST" = "") then var MEFIRST First Strike!
var WHISPER My Empath senses life around %EMPATH_SPECIAL!
gosub WHISPER_RETURN
goto GAME_LOOP

EMPATH_SPECIAL:
var ECHO_TILES 0
#starting from bottom left tile, going clockwise from the left
eval TILE_LETTER replacere ("%INFO","\d+","")
eval TILE_NUMBER replacere ("%INFO","[A-Z]","")
if matchre ("%E%TILE_LETTER%TILE_NUMBER","%TILE_BUTTON") then var E%TILE_LETTER%TILE_NUMBER {%EMPATH:#parse SELECT_%TILE_LETTER%TILE_NUMBER}
math TILE_NUMBER subtract 1
if matchre ("%E%TILE_LETTER%TILE_NUMBER","%TILE_BUTTON") then var E%TILE_LETTER%TILE_NUMBER {%EMPATH:#parse SELECT_%TILE_LETTER%TILE_NUMBER}
gosub NEXT_LETTER
if matchre ("%E%TILE_LETTER%TILE_NUMBER","%TILE_BUTTON") then var E%TILE_LETTER%TILE_NUMBER {%EMPATH:#parse SELECT_%TILE_LETTER%TILE_NUMBER}
math TILE_NUMBER add 1
if matchre ("%E%TILE_LETTER%TILE_NUMBER","%TILE_BUTTON") then var E%TILE_LETTER%TILE_NUMBER {%EMPATH:#parse SELECT_%TILE_LETTER%TILE_NUMBER}
gosub PREV_LETTER_2
if matchre ("%%TILE_LETTER%TILE_NUMBER","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER:%%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
if matchre ("%%TILE_LETTER%TILE_NUMBER","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER:%%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
math TILE_NUMBER subtract 1
if matchre ("%%TILE_LETTER%TILE_NUMBER","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER:%%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
if matchre ("%%TILE_LETTER%TILE_NUMBER","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER:%%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
math TILE_NUMBER add 1
if matchre ("%%TILE_LETTER%TILE_NUMBER","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER:%%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
if matchre ("%%TILE_LETTER%TILE_NUMBER","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER:%%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
gosub PREV_LETTER
if matchre ("%%TILE_LETTER%TILE_NUMBER","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER:%%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER
if matchre ("%%TILE_LETTER%TILE_NUMBER","%PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF") then var ECHO_TILES %ECHO_TILES|%TILE_LETTER%TILE_NUMBER:%%TILE_LETTER%TILE_NUMBER
var INFO 0
eval ECHO_TILES replacere ("%ECHO_TILES","^0\|","")
var WHISPER Your Empath's senses reveal %ECHO_TILES!
pause
gosub WHISPER_RETURN
goto GAME_LOOP

WARMAGE_SPECIAL:
eval EN_WARMAGE_SPECIAL replacere ("%FILL","KILL W ","")
var TILES 0
var ECHO_TILES 0
eval TILE_LETTER replacere ("%EN_WARMAGE_SPECIAL","\d+","")
eval TILE_NUMBER replacere ("%EN_WARMAGE_SPECIAL","[A-Z]","")
#var TILES %TILES|%TILE_LETTER%TILE_NUMBER
# 4 is enough tiles
math TILE_NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
eval LOOP count ("%TILES","|")
gosub TILE_HIT_LOOP
var SPECIAL_HIT WarMage
eval LOOP count ("%ECHO_TILES","|")
goto REVEAL_MY_MULTI_TILES_LOOP

MANA_TRAP_TRIGGERED:
var TILES 0
var ECHO_TILES 0
eval TILE_LETTER replacere ("%TILE","\d+","")
eval TILE_NUMBER replacere ("%TILE","[A-Z]","")
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
eval LOOP count ("%TILES","|")
gosub TILE_HIT_LOOP
eval LOOP count ("%ECHO_TILES","|")

REVEAL_MY_MULTI_TILES_LOOP:
eval VALIDSTRIKE element ("%ECHO_TILES","%LOOP")
eval TILE replacere ("%VALIDSTRIKE","\:.*","")
eval FILL replacere ("%VALIDSTRIKE","^.*\:","")
if %FILL != PROTECTED then
    {
    var %TILE %BH
    if %FILL = MISS then var %TILE %BB
    }
math LOOP subtract 1
if %LOOP != 0 then goto REVEAL_MY_MULTI_TILES_LOOP
eval ECHO_TILES replacere ("%ECHO_TILES","^0\|","")
var WHISPER The explosion of your mana trap reveals %ECHO_TILES!
if %SPECIAL_HIT = WarMage then
    {
    var WHISPER Your Warrior Mage's self-immolation reveals %ECHO_TILES!
    }
var SPECIAL_HIT 0
var INFO 0
pause
goto WHISPER

TILE_HIT_LOOP:
eval VALIDSTRIKE element ("%TILES","%LOOP")
eval TILE_LETTER replacere ("%VALIDSTRIKE","\d+","")
eval TILE_NUMBER replacere ("%VALIDSTRIKE","[A-Z]","")
gosub TILE_HIT
var ECHO_TILES %ECHO_TILES|%VALIDSTRIKE:%ECHO
math LOOP subtract 1
if %LOOP = 0 then return
goto TILE_HIT_LOOP

TILE_HIT:
var TILE %%VALIDSTRIKE
var ECHO MISS
if matchre ("%TILE","%PALADIN") then gosub HIT_SCORE P
else
    {
    if %P != 0 then
        {
        gosub PALADIN_SPECIAL
        if matchre ("%PALADIN_SPECIAL","%PALADIN") then
            {
            var ECHO PROTECTED
            return
            }
        var %TILE_NUMBER %BACKUP_NUMBER
        var %TILE_LETTER %BACKUP_LETTER
        }
    }
if matchre ("%TILE","%WARMAGE") then gosub HIT_SCORE W
if matchre ("%TILE","%EMPATH") then gosub HIT_SCORE E
if matchre ("%TILE","%RANGER") then
    {
    gosub RANGER_SPECIAL
    if matchre ("%TILE","%RANGER") then gosub HIT_SCORE R
    }
if matchre ("%TILE","%MOONMAGE") then gosub HIT_SCORE M
if matchre ("%TILE","%THIEF") then gosub HIT_SCORE T
if matchre ("%TILE","%BH") then var ECHO HIT
if matchre ("%TILE","%TRAP") then var ECHO TRAP
if matchre ("%ECHO","HIT|KILL") then var %VALIDSTRIKE %BH
if matchre ("%ECHO","TRAP") then var %VALIDSTRIKE %TRAP_SPENT
if matchre ("%ECHO","MISS") then var %VALIDSTRIKE %BB
RETURN:
return

HIT_SCORE:
var ECHO $0
math %ECHO subtract 1
if %%ECHO = 0 then var ECHO KILL %ECHO
else var ECHO HIT
if %ECHO = KILL T then var ECHO KILL T %THIEF_SPECIAL
if %ECHO = KILL W then var ECHO KILL W %WARMAGE_SPECIAL
return

PALADIN_SPECIAL:
var BACKUP_NUMBER %TILE_NUMBER
var BACKUP_LETTER %TILE_LETTER
var PALADIN_SPECIAL
math TILE_NUMBER subtract 1
var PALADIN_SPECIAL %PALADIN_SPECIAL|%%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 2
var PALADIN_SPECIAL %PALADIN_SPECIAL|%%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
gosub NEXT_LETTER
var PALADIN_SPECIAL %PALADIN_SPECIAL|%%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
var PALADIN_SPECIAL %PALADIN_SPECIAL|%%TILE_LETTER%TILE_NUMBER
eval PALADIN_SPECIAL replacere ("%PALADIN_SPECIAL","^\|","")
return

ENEMY_STRIKES:
math ENEMYTURN add 1
if ("%MEFIRST" = "") then var ENFIRST First Strike!
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
eval TILE_LETTER replacere ("%VALIDSTRIKE","\d+","")
gosub TILE_HIT
var SLATESTRIKE 0
var WHISPER Your strike reveals %VALIDSTRIKE:%ECHO!
gosub HIT_WHO %TILE
if %ECHO_2 = 0 then
    {
    var ECHO_2 %ENEMY strikes at tile %VALIDSTRIKE and hits your %SPECIAL_HIT!
    if %ECHO = MISS then var ECHO_2 %ENEMY strikes at %VALIDSTRIKE, but it's a miss!
    }
if %ECHO = PROTECTED then var ECHO_2 Your Paladin protects your %SPECIAL_HIT on tile %VALIDSTRIKE!
var SPECIAL_HIT 0

WHISPER:
if %GAG_WHISPERS = 1 then put #gag %OUTPUT_GAG
pause 0.2
put whisper %ENEMY BattleSiege: %WHISPER
matchre WHISPER ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre WHISPER_WAIT ^Who are you trying to whisper to
matchre REDRAW_DISPLAY ^You whisper to %ENEMY
matchwait 2
goto WHISPER

WHISPER_WAIT:
if matchre ("$roomplayers","%ENEMY") then goto WHISPER
pause 1
goto WHISPER_WAIT

WHISPER_RETURN:
if %GAG_WHISPERS = 1 then put #gag %OUTPUT_GAG
pause 0.2
put whisper %ENEMY BattleSiege: %WHISPER
matchre WHISPER_RETURN ^\.\.\.wait|^Sorry\,|^You are still stunned
matchre WHISPER_RETURN_WAIT ^Who are you trying to whisper to
matchre RETURN ^You whisper to %ENEMY
matchwait 2
goto WHISPER

WHISPER_RETURN_WAIT:
if matchre ("$roomplayers","%ENEMY") then goto WHISPER_RETURN
pause 1
goto WHISPER_RETURN_WAIT

STRIKE_AT_ENEMY:
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


####### PIECE SETUP ########


PIECE_INFO:
if %ENEMY_SET = 0 then var PIECE ENEMY
if %TRAP2_SET = 0 then var PIECE TRAP2
if %TRAP_SET = 0 then var PIECE TRAP
if %THIEF_SET = 0 then var PIECE THIEF
if %MOONMAGE_SET = 0 then var PIECE MOONMAGE
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
    put #echo >%WINDOW mono "(Paladins will protect tiles touching them until defeated!)"
    var ORIENT 1
    }
if %PIECE = WARMAGE then
    {
    put #echo >%WINDOW mono "Select the center tile for your Warrior Mage:"
    put #echo >%WINDOW mono " ! # ! "
    put #echo >%WINDOW mono " # # # "
    put #echo >%WINDOW mono " ! # ! "
    put #echo >%WINDOW mono "(Warrior Mages will strike at the '!' tiles when they die!)
    }
if %PIECE = EMPATH then
    {
    put #echo >%WINDOW mono "Select the lower-left corner tile for your Empath."
    put #echo >%WINDOW mono "   ! !   "
    put #echo >%WINDOW mono " ! # # ! "
    put #echo >%WINDOW mono " ! # # ! "
    put #echo >%WINDOW mono "   ! !   "
    put #echo >%WINDOW mono "(Empaths can sense, but not injure, nearby enemy tiles, but this will inform the enemy of their position!)
    }
if %PIECE = RANGER then
    {
    put #echo >%WINDOW mono "Select the bottom/left tile for your Ranger."
    put #echo >%WINDOW mono "Then select an orientation:"
    put #echo >%WINDOW mono "  # >  |  < #  |         |          "
    put #echo >%WINDOW mono "  # >  |  < #  | ^ ^ ^ ^ | # # # #  "
    put #echo >%WINDOW mono "  # >  |  < #  | # # # # | v v v v  "
    put #echo >%WINDOW mono "  # >  |  < #  |         |          "
    put #echo >%WINDOW mono "{Shape 1:#parse SHAPE_SET_1}|{Shape 2:#parse SHAPE_SET_2}|{Shape 3:#parse SHAPE_SET_3}  |{Shape 4:#parse SHAPE_SET_4}"
    put #echo >%WINDOW mono "(Give your Ranger space - they can dodge twice!)
    var ORIENT 1
    }
if %PIECE = MOONMAGE then
    {
    put #echo >%WINDOW mono "Select the middle tile for your Moon Mage."
    put #echo >%WINDOW mono "Then select an orientation:"
    put #echo >%WINDOW mono "     # | #     |       | #   # |  #    |    # "
    put #echo >%WINDOW mono "   #   |   #   |   #   |   #   |    #  |  #   "
    put #echo >%WINDOW mono " #     |     # | #   # |       |  #    |    # "
    put #echo >%WINDOW mono "{Shape 1:#parse SHAPE_SET_1}|{Shape 2:#parse SHAPE_SET_2}|{Shape 3:#parse SHAPE_SET_3}|{Shape 4:#parse SHAPE_SET_4}|{Shape 5:#parse SHAPE_SET_5}|{Shape 6:#parse SHAPE_SET_6}"
    put #echo >%WINDOW mono "(Moon Mages can Locate, but not damage, 2 random squares, and Backtrace enemy Moon Mages!)
    var ORIENT 1
    }
if %PIECE = THIEF then
    {
    put #echo >%WINDOW mono "Select the bottom tile for your Thief."
    put #echo >%WINDOW mono "Then select an orientation:"
    put #echo >%WINDOW mono " #     |       "
    put #echo >%WINDOW mono " #     | # # > "
    put #echo >%WINDOW mono " v     |       "
    put #echo >%WINDOW mono "{Shape 1:#parse SHAPE_SET_1}|{Shape 2:#parse SHAPE_SET_2}"
    put #echo >%WINDOW mono "(Thieves will strike far in the pointed direction when killed!)
    var ORIENT 1
    }
if %PIECE = TRAP then
    {
    put #echo >%WINDOW mono "Select the tile to lay your first Mana Trap:"
    put #echo >%WINDOW mono "   !   "
    put #echo >%WINDOW mono " ! # ! "
    put #echo >%WINDOW mono "   !   "
    put #echo >%WINDOW mono "(The trap is a single-tile which reveals four adjacent tiles when hit.)"
    }
if %PIECE = TRAP2 then
    {
    put #echo >%WINDOW mono "Select the tile to lay your second Mana Trap:"
    put #echo >%WINDOW mono "   !   "
    put #echo >%WINDOW mono " ! # ! "
    put #echo >%WINDOW mono "   !   "
    put #echo >%WINDOW mono "(The trap is a single-tile which reveals four adjacent tiles when hit.)"
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
if matchre ("%PIECE","MOONMAGE") then
    {
    if matchre ("%TILE","A1|A%GRID_MAX|%RIGHT_EDGE1|%RIGHTE_EDGE%GRID_MAX") then
        {
        put #echo >%WINDOW mono "Middle tile cannot be in a corner!"
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
put #echo >Log BattleSiege: This text should never display.
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
if %PIECE = MOONMAGE then
    {
    if %SHAPE = 1 then goto PLACE_MOONMAGE_SHAPE_1
    if %SHAPE = 2 then goto PLACE_MOONMAGE_SHAPE_2
    if %SHAPE = 3 then goto PLACE_MOONMAGE_SHAPE_3
    if %SHAPE = 4 then goto PLACE_MOONMAGE_SHAPE_4
    if %SHAPE = 5 then goto PLACE_MOONMAGE_SHAPE_5
    else goto PLACE_MOONMAGE_SHAPE_6
    }
if %PIECE = RANGER then
    {
    if %SHAPE = 1 then goto PLACE_RANGER_SHAPE_1
    if %SHAPE = 2 then goto PLACE_RANGER_SHAPE_2
    if %SHAPE = 3 then goto PLACE_RANGER_SHAPE_3
    else goto PLACE_RANGER_SHAPE_4
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
gosub PREV_LETTER_2
math TILE_NUMBER add 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_SHAPE_3:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
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
gosub PREV_LETTER_2
math TILE_NUMBER subtract 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_SHAPE_1:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER

PLACE_PALADIN_CONFIRM:
gosub CONFIRM_PLACEMENT Paladin
gosub PRINT_PIECE PALADIN
eval PALADIN_SPECIAL replacere ("%TILES","^0\|","")
eval PALADIN_SPECIAL replacere ("%PALADIN_SPECIAL","\|.*","")
var PALADIN_SPECIAL %SHAPE %PALADIN_SPECIAL
var PALADIN_SET 1
goto REDRAW_DISPLAY

PLACE_WARMAGE:
var WARMAGE_SPECIAL %TILE_LETTER%TILE_NUMBER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub CONFIRM_PLACEMENT Warrior Mage
gosub PRINT_PIECE WARMAGE
var WARMAGE_SET 1
goto REDRAW_DISPLAY

PLACE_EMPATH:
var EMPATH_SPECIAL %TILE_LETTER%TILE_NUMBER
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

PLACE_RANGER_SHAPE_1:
gosub NEXT_LETTER
var RANGER_SPECIAL %TILE_LETTER
gosub PREV_LETTER
goto PLACE_RANGER_SHAPE_TALL

PLACE_RANGER_SHAPE_2:
gosub PREV_LETTER
var RANGER_SPECIAL %TILE_LETTER
gosub NEXT_LETTER

PLACE_RANGER_SHAPE_TALL:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_RANGER_CONFIRM

PLACE_RANGER_SHAPE_3:
math TILE_NUMBER subtract 1
var RANGER_SPECIAL %TILE_NUMBER
math TILE_NUMBER add 1
goto PLACE_RANGER_SHAPE_WIDE

PLACE_RANGER_SHAPE_4:
math TILE_NUMBER add 1
var RANGER_SPECIAL %TILE_NUMBER
math TILE_NUMBER subtract 1

PLACE_RANGER_SHAPE_WIDE:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER

PLACE_RANGER_CONFIRM:
gosub CONFIRM_PLACEMENT Ranger
gosub PRINT_PIECE RANGER
var RANGER_SET 1
var RANGER_SPECIAL_CHARGES 2
goto REDRAW_DISPLAY

PLACE_MOONMAGE_SHAPE_1:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
math TILE_NUMBER add 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_2:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 2
gosub PREV_LETTER_2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_3:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_4:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub PREV_LETTER_2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_5:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
gosub PREV_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_6:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER add 2
var TILES %TILES|%TILE_LETTER%TILE_NUMBER

PLACE_MOONMAGE_CONFIRM:
gosub CONFIRM_PLACEMENT Moon Mage
gosub PRINT_PIECE MOONMAGE
var MOONMAGE_SET 1
var MOONMAGE_SPECIAL 5
goto REDRAW_DISPLAY

PLACE_THIEF_WIDE:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
gosub NEXT_LETTER
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
var THIEF_SPECIAL %TILE_LETTER
goto PLACE_THIEF_CONFIRM

PLACE_THIEF_TALL:
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
math TILE_NUMBER subtract 1
var TILES %TILES|%TILE_LETTER%TILE_NUMBER
var THIEF_SPECIAL %TILE_NUMBER

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

PREV_LETTER_2:
eval TILE_LETTER replacere ("0|%COLUMNS","\|%TILE_LETTER.*","")
eval TILE_LETTER replacere ("%TILE_LETTER","\|[A-Z]$","")
eval TILE_LETTER replacere ("%TILE_LETTER","^.*\|","")
return

PREV_LETTER:
eval TILE_LETTER replacere ("0|%COLUMNS","\|%TILE_LETTER.*","")
eval TILE_LETTER replacere ("%TILE_LETTER",".*\|","")
return

NEXT_LETTER:
eval TILE_LETTER replacere ("%COLUMNS|0",".*%TILE_LETTER\|","")
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
            if (("%E" != "0") && ("%EMPATH_SPECIAL" != "0")) then
                {
                if (("%M" != "0") && ("%MOONMAGE_SPECIAL" != "0")) then put #echo >%WINDOW mono "   Empath: {Sense Life:#parse EMPATH_SPECIAL}  Moon Mage: {Locate:#parse MOONMAGE_LOCATE}"
                else put #echo >%WINDOW mono "   Empath: {Sense Life:#parse EMPATH_SPECIAL}"
                }
            else
                {
                if (("%M" != "0") && ("%MOONMAGE_SPECIAL" != "0")) then put #echo >%WINDOW mono "   Moon Mage: {Cast Locate:#parse MOONMAGE_LOCATE}"
                }                
            put #echo >%WINDOW mono "   HP: P-%P   W-%W   E-%E   R-%R   M-%M   T-%T"
            put #echo >%WINDOW mono "   Turns: %MYTURN               %MEFIRST"
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
        put #echo >%WINDOW mono "   HP: P-%EP   W-%EW   E-%EE   R-%ER   M-%EM   T-%ET"
        put #echo >%WINDOW mono "   Turns: %ENEMYTURN               %ENFIRST"
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
#eval SAVE replacere ("%PALADIN_SPECIAL","\|","-")
# Insert %SAVE before %WARMAGE_SPECIAL when using Paladin Special Version 1
var SAVE %RIGHT_EDGE|%GRID_MAX|%P|%W|%E|%R|%M|%T|%EP|%EW|%EE|%ER|%EM|%ET|%WARMAGE_SPECIAL|%EMPATH_SPECIAL|%RANGER_SPECIAL|%RANGER_SPECIAL_CHARGES|%MOONMAGE_SPECIAL|%THIEF_SPECIAL|%MYTURN|%ENEMYTURN|%MEFIRST|%ENFIRST
var ECHO_2 Game versus %ENEMY saved!
var FILL %ENEMY
var LOOP 1
goto SAVE_GAME_OUTER_LOOP

SAVE_GAME_PRESET:
#eval SAVE replacere ("%PALADIN_SPECIAL","\|","-")
var SAVE %RIGHT_EDGE|%GRID_MAX|%PALADIN_SET|%WARMAGE_SET|%EMPATH_SET|%RANGER_SET|%MOONMAGE_SET|%TRAP_SET|%THIEF_SET|%TRAP2_SET|%WARMAGE_SPECIAL|%EMPATH_SPECIAL|%RANGER_SPECIAL|%RANGER_SPECIAL_CHARGES|%MOONMAGE_SPECIAL|%THIEF_SPECIAL
var ECHO_2 Preset game saved!
var FILL Preset
var LOOP 1

SAVE_GAME_OUTER_LOOP:
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
eval M element ("%LOAD","6")
eval T element ("%LOAD","7")
eval EP element ("%LOAD","8")
eval EW element ("%LOAD","9")
eval EE element ("%LOAD","10")
eval ER element ("%LOAD","11")
eval EM element ("%LOAD","12")
eval ET element ("%LOAD","13")
eval WARMAGE_SPECIAL element ("%LOAD","14")
eval EMPATH_SPECIAL element ("%LOAD","15")
eval RANGER_SPECIAL element ("%LOAD","16")
eval RANGER_SPECIAL_CHARGES element ("%LOAD","17")
eval MOONMAGE_SPECIAL element ("%LOAD","18")
eval THIEF_SPECIAL element ("%LOAD","19")
eval MYTURN element ("%LOAD","20")
eval ENEMYTURN element ("%LOAD","21")
eval MEFIRST element ("%LOAD","22")
eval ENFIRST element ("%LOAD","23")
eval COL_LOOP count ("%LOAD","|")
var LOOP 23
goto LOAD_GAME_LOOP

LOAD_GAME_PRESET:
var LOOP 1
gosub SETVARS_LINKS
var LOAD $BattleSiege_Preset
var ECHO_2 Preset game loaded!
var ENEMY 0
eval RIGHT_EDGE element ("%LOAD","0")
eval GRID_MAX element ("%LOAD","1")
eval PALADIN_SET element ("%LOAD","2")
eval WARMAGE_SET element ("%LOAD","3")
eval EMPATH_SET element ("%LOAD","4")
eval RANGER_SET element ("%LOAD","5")
eval MOONMAGE_SET element ("%LOAD","6")
eval THIEF_SET element ("%LOAD","7")
eval TRAP_SET element ("%LOAD","8")
eval TRAP2_SET element ("%LOAD","9")
eval WARMAGE_SPECIAL element ("%LOAD","14")
eval EMPATH_SPECIAL element ("%LOAD","11")
eval RANGER_SPECIAL element ("%LOAD","12")
eval RANGER_SPECIAL_CHARGES element ("%LOAD","13")
eval MOONMAGE_SPECIAL element ("%LOAD","14")
eval THIEF_SPECIAL element ("%LOAD","15")
eval COL_LOOP count ("%LOAD","|")
if %COL_LOOP = 15 then goto REDRAW_DISPLAY
var LOOP 15

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

SETVARS_FIND:
var COL_LOOP 0

SETVARS_FIND_LOOP:
eval COL element ("%COLUMNS","%COL_LOOP")
math COL_LOOP add 1
if %COL_LOOP > %GRID_MAX then
    {
    math LOOP add 1
    if %LOOP > %GRID_MAX then return
    goto SETVARS_FIND
    }
if matchre ("%%COL%LOOP","%MOONMAGE") then var ECHO_TILES %ECHO_TILES|%COL%LOOP:%MOONMAGE
goto SETVARS_FIND_LOOP

COUNT_TILES_REMAINING:
var TILES 0

SETVARS_COUNT:
var COL_LOOP 0

SETVARS_COUNT_LOOP:
eval COL element ("%COLUMNS","%COL_LOOP")
math COL_LOOP add 1
if %COL_LOOP > %GRID_MAX then
    {
    math LOOP add 1
    if %LOOP > %GRID_MAX then return
    goto SETVARS_COUNT
    }
if matchre ("%%COL%LOOP","%TILE_BUTTON") then math TILES add 1
goto SETVARS_COUNT_LOOP

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
