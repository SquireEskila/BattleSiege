### BattleSiege! Version 1.2 Coded by Eskila and Cryle ###

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

#Pieces: Paladin, Warmage, Empath, Ranger, Moon Mage, Thief, Traps
# Enemy must always be last
var PIECE_ORDER PALADIN|WARMAGE|EMPATH|RANGER|MOONMAGE|THIEF|TRAP1|TRAP2|ENEMY
var PIECE_SHAPES 4|0|0|2|6|2|0|0|0
var PIECE_INITIAL P|W|E|R|M|T|X|X|X
var PIECE_HEALTH 5|5|4|4|3|2|0|0|0
var PIECES 8

var GAME_PIECES %PALADIN|%WARMAGE|%EMPATH|%RANGER|%MOONMAGE|%THIEF

var DEBUG 0

##################

put #class BattleSiege true
var ALPHABET A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z
eval RIGHT_EDGE element ("0|%ALPHABET","%GRID_MAX")
eval BC element ("%ALPHABET","%GRID_MAX")
eval BC replacere ("%ALPHABET","(%BC.*)","")
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
gosub SETVARS LINKS
var PIECES_SET 0

REDRAW_DISPLAY:
var TILE 0
var INFO 0
var STRIKE 0
var SPECIAL_HIT 0
var ENEMY_ACTION 0
if %GAG_WHISPERS = 1 then put #ungag %OUTPUT_GAG
gosub DISPLAY
if %DEBUG = 1 then debug 10
if %GAME_SETUP = 1 then gosub PIECE_INFO
if ("%ECHO_2" != "0") then
    {
    put #echo >%WINDOW mono "%ECHO_2";#echo >%WINDOW
    var ECHO_2 0
    }

GAME_SETUP_LOOP:
if %GAME_SETUP = 0 then goto GAME_LOOP
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

GAME_LOOP:
gosub clear
gosub END_CONDITIONS
if ("%STRIKE|%INFO|%ENEMY_ACTION" = "%LAST_UPDATE") then
    {
    var LAST_UPDATE none
    var STRIKE 0
    var INFO 0
    var ENEMY_ACTION 0
    }
if !matchre ("%STRIKE","^0$") then goto ENEMY_STRIKES
if !matchre ("%INFO","^0$") then goto INFO_ON_MY_STRIKE
if !matchre ("%ENEMY_ACTION","^0$") then goto PERFORM_ENEMY_ACTION
matchre REQUEST_EMPATH_SENSE ^EMPATH_SPECIAL
matchre REQUEST_MOONMAGE_LOCATE ^MOONMAGE_LOCATE
matchre REQUEST_MOONMAGE_BACKTRACE ^MOONMAGE_BACKTRACE
matchre STRIKE_AT_ENEMY ^SELECT_
matchre REDRAW_DISPLAY ^REDRAW$
matchre SAVE_GAME_ENEMY ^SAVE_GAME_ENEMY
matchre SAVE_GAME_FORCED ^%ENEMY whispers\, \"BattleSiege\: Saving!\"
matchwait 2
goto GAME_LOOP

START_GAME:
action var STRIKE $2 when ^%ENEMY.*(says|asks|exclaims|yells|belts out).*\,\s\".*([A-Z]\d+|\d+[A-Z])
action var STRIKE SLATE when ^%ENEMY shows you (his|her) slate
action var SLATESTRIKE $1 when ^The slate reads\:.*([A-Z]\d+|\d+[A-Z])
action var ENEMY_ACTION $1 when ^%ENEMY whispers\, \"BattleSiege\: My Empath senses life around (.*)\!"
action var ENEMY_ACTION $1 when ^%ENEMY whispers\, \"BattleSiege\: My Moon Mage casts Locate at (.*)\!"
action var ENEMY_ACTION BACKTRACE when ^%ENEMY whispers\, \"BattleSiege\: My Moon Mage backtraces yours\!"
action var INFO $1 when ^%ENEMY whispers\, \"BattleSiege\: Your strike reveals (.*)\!\"
action var INFO $1;var SPECIAL_HIT TRAP when ^%ENEMY whispers\, \"BattleSiege\: The explosion of your mana trap reveals (.*)\!\"
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
var OUTPUT_GAG {^You whisper to %ENEMY\, \"BattleSiege\:|^$scriptname} {BattleSiege}
var INPUT_GAG {^%ENEMY whispers\, \"BattleSiege\:} {BattleSiege}
if %GAG_WHISPERS = 1 then
    {
    put #gag %OUTPUT_GAG
    put #gag %INPUT_GAG
    }
var STRIKE 0
var SLATESTRIKE 0
var INFO 0
var SPECIAL_HIT 0
var GAME_SETUP 0
var ENEMYTURN 0
var MYTURN 0
var MEFIRST
var ENFIRST
var LAST_UPDATE none
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


EXTRACT:
eval LETTER replacere ("$0","\d+","")
eval NUMBER replacere ("$0","[A-Z]","")
return

INFO_ON_MY_STRIKE:
var LAST_UPDATE 0|%INFO|0
math MYTURN add 1
if ("%ENFIRST" = "") then var MEFIRST First Strike!
if matchre ("%INFO","\|") then goto REVEAL_MULTI_TILES
eval TILE replacere ("%INFO","\:.*","")
eval FILL replacere ("%INFO","^.*\:","")
if %SPECIAL_HIT = Thief then
    {
    math MYTURN subtract 1
    var ECHO_2 Your Thief lashes out with their dying breath, striking tile %TILE!
    }
if %SPECIAL_HIT = Backtrace then
    {
    var ECHO_2 Your Moon Mage backtraces the locate...
    var E%TILE {%FILL:#parse SELECT_%TILE}
    goto REDRAW_DISPLAY
    }
if %SPECIAL_HIT = Empath then
    {
    var ECHO_2 Your Empath reaches out to sense nearby dangers!
    var EMPATH_SPECIAL 0
    var E%TILE {%FILL:#parse SELECT_%TILE}
    goto REDRAW_DISPLAY
    }    
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
var ECHO_2 Your mana trap explodes, revealing several of %ENEMY's tiles to you! Score!
var INFO 0|%INFO
eval LOOP count ("%INFO","|")
if %SPECIAL_HIT = MoonMage then
    {
    eval ECHO_1 element ("%INFO","1")
    eval ECHO_1 replacere ("%ECHO_1!","\:.*","")
    eval ECHO_2 element ("%INFO","2")
    eval ECHO_2 replacere ("%ECHO_2","\:.*","")
    var ECHO_2 Your Moon Mage casts locate on tiles %ECHO_1 and %ECHO_2!
    math MOONMAGE_CHARGES subtract 1
    }
if %SPECIAL_HIT = Backtrace then
    {
    var ECHO_2 Your Moon Mage backtraces the locate...
    }
if %SPECIAL_HIT = WarMage then
    {
    math MYTURN subtract 1
    var ECHO_2 Your Warrior Mage manages to conflagrate the area with their dying breath, striking out all around them!
    }
if %SPECIAL_HIT = Empath then
    {
    var ECHO_2 Your Empath reaches out to sense nearby dangers!
    var EMPATH_SPECIAL 0
    }
if %SPECIAL_HIT = TRAP then math MYTURN subtract 1    

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
if %FILL = TRAP then var E%TILE %TRAP_SPENT
if matchre ("%FILL","KILL T") then gosub THIEF_SPECIAL
if matchre ("%FILL","KILL W") then gosub WARMAGE_SPECIAL

REVEAL_MULTI_TILES_LOOP_NEXT:
math LOOP subtract 1
if %LOOP != 0 then goto REVEAL_MULTI_TILES_LOOP
goto REDRAW_DISPLAY

THIEF_SPECIAL:
var SPECIAL_HIT ThiefDeath
eval EN_THIEF_SPECIAL replacere ("%FILL","KILL T ","")
gosub EXTRACT %TILE
var TILE_1 %LETTER%NUMBER
if matchre ("%EN_THIEF_SPECIAL","\d+") then
    {
    var LOOP %NUMBER
    goto THIEF_SPECIAL_SCAN
    }
eval TILE replacere ("%ALPHABET","%EN_THIEF_SPECIAL\|.*","")
eval LOOP count ("%0|%TILE|%EN_THIEF_SPECIAL","|")

THIEF_SPECIAL_SCAN:
math LOOP add 1
if %LOOP > %GRID_MAX then var LOOP 1
if matchre ("%EN_THIEF_SPECIAL","\d+") then var NUMBER %LOOP
else eval LETTER element ("0|%ALPHABET","%LOOP")
var TILE %LETTER%NUMBER
if %TILE = %TILE_1 then return
if matchre ("%%TILE","%GAME_PIECES") then goto THIEF_HIT_WHO
goto THIEF_SPECIAL_SCAN

THIEF_HIT_WHO:
var VALIDSTRIKE %TILE
gosub TILE_HIT
gosub HIT_WHO %TILE
var ECHO_2 As %ENEMY's thief perishes, they let loose with a throwing knife and strike your %SPECIAL_HIT!
var WHISPER Your Thief's dying strike reveals %VALIDSTRIKE:%ECHO!
goto WHISPER_RETURN

HIT_WHO:
if ("$0" = "%PALADIN") then var SPECIAL_HIT Paladin
if ("$0" = "%WARMAGE") then var SPECIAL_HIT Warrior Mage
if ("$0" = "%EMPATH") then var SPECIAL_HIT Empath
if ("$0" = "%RANGER") then var SPECIAL_HIT Ranger
if ("$0" = "%MOONMAGE") then var SPECIAL_HIT Moon Mage
if ("$0" = "%THIEF") then var SPECIAL_HIT Thief
if ("$0" = "%TRAP") then var SPECIAL_HIT mana trap
return

RANGER_SPECIAL:
if %RANGER_CHARGES = 0 then return
if matchre ("%RANGER_SPECIAL","\d") then var NUMBER %RANGER_SPECIAL
if matchre ("%RANGER_SPECIAL","[A-Z]") then var LETTER %RANGER_SPECIAL
if matchre ("%%LETTER%NUMBER","%BE") then
    {
    var %LETTER%NUMBER %RANGER
    var %VALIDSTRIKE %BE
    var TILE %BE
    math RANGER_CHARGES subtract 1
    var ECHO_2 %ENEMY strikes at %VALIDSTRIKE but your Ranger dodges!
    }
return

REQUEST_MOONMAGE_LOCATE:
gosub COUNT_TILES_REMAINING
if %TILES < 2 then
    {
    var ECHO_2 Why bother...? Also, your Moon Mage runs out of mana now.
    var MOONMAGE_CHARGES 0
    goto REDRAW_DISPLAY
    }
var ECHO_TILES 0

PICK_LOCATE_TILES_LOOP:
random 1 %GRID_MAX
if matchre ("%r","-") then eval r replacere ("%r","-","")
var NUMBER %r
pause 0.001
random 1 %GRID_MAX
if matchre ("%r","-") then eval r replacere ("%r","-","")
eval LETTER element ("0|%ALPHABET","%r")
if matchre ("%ECHO_TILES","%LETTER%NUMBER") then goto PICK_LOCATE_TILES_LOOP
if matchre ("%E%LETTER%NUMBER","%TILE_BUTTON") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER
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

REQUEST_EMPATH_SENSE:
if ("%ENFIRST" = "") then var MEFIRST First Strike!
var WHISPER My Empath senses life around %EMPATH_SPECIAL!
gosub WHISPER_RETURN
goto GAME_LOOP

MOONMAGE_LOCATE:
var SPECIAL_HIT 0
eval TILE element ("%ENEMY_ACTION","0")
var ECHO_TILES %TILE:%%TILE
eval TILE element ("%ENEMY_ACTION","1")
var ECHO_TILES %ECHO_TILES|%TILE:%%TILE
var ENEMY_ACTION 0
var WHISPER Your Moon Mage's Locate spell reveals %ECHO_TILES!
goto WHISPER

MOONMAGE_BACKTRACE:
var ECHO_TILES 0
gosub SETVARS FIND
eval ECHO_TILES replacere ("%ECHO_TILES","^0\|","")
var WHISPER Your Moon Mage's backtrace reveals %ECHO_TILES!
var INFO 0
var SPECIAL_HIT 0
gosub WHISPER_RETURN
goto GAME_LOOP

PERFORM_ENEMY_ACTION:
var LAST_UPDATE 0|0|%ENEMY_ACTION
math ENEMYTURN add 1
if ("%MEFIRST" = "") then var ENFIRST First Strike!
if %ENEMY_ACTION = BACKTRACE then goto MOONMAGE_BACKTRACE
if !matchre ("%ENEMY_ACTION","\|") then goto EMPATH_SPECIAL
eval ECHO_1 element ("%ENEMY_ACTION","0")
eval ECHO_2 element ("%ENEMY_ACTION","1")
var ECHO_2 %ENEMY's Moon Mage casts Locate on tiles %ECHO_1 and %ECHO_2!
if %M != 0 then var ECHO_2 %ECHO_2 {Backtrace:#parse MOONMAGE_BACKTRACE} it?
goto MOONMAGE_LOCATE

EMPATH_SPECIAL:
var ECHO_TILES 0
#starting from bottom left tile, going clockwise from the left
gosub EXTRACT %ENEMY_ACTION
if matchre ("%E%LETTER%NUMBER","%TILE_BUTTON") then var E%LETTER%NUMBER {%EMPATH:#parse SELECT_%LETTER%NUMBER}
math NUMBER subtract 1
if matchre ("%E%LETTER%NUMBER","%TILE_BUTTON") then var E%LETTER%NUMBER {%EMPATH:#parse SELECT_%LETTER%NUMBER}
gosub NEXT_LETTER
if matchre ("%E%LETTER%NUMBER","%TILE_BUTTON") then var E%LETTER%NUMBER {%EMPATH:#parse SELECT_%LETTER%NUMBER}
math NUMBER add 1
if matchre ("%E%LETTER%NUMBER","%TILE_BUTTON") then var E%LETTER%NUMBER {%EMPATH:#parse SELECT_%LETTER%NUMBER}
gosub PREV_LETTER_2
if matchre ("%%LETTER%NUMBER","%GAME_PIECES") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%%LETTER%NUMBER
math NUMBER subtract 1
if matchre ("%%LETTER%NUMBER","%GAME_PIECES") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%%LETTER%NUMBER
gosub NEXT_LETTER
math NUMBER subtract 1
if matchre ("%%LETTER%NUMBER","%GAME_PIECES") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%%LETTER%NUMBER
gosub NEXT_LETTER
if matchre ("%%LETTER%NUMBER","%GAME_PIECES") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%%LETTER%NUMBER
gosub NEXT_LETTER
math NUMBER add 1
if matchre ("%%LETTER%NUMBER","%GAME_PIECES") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%%LETTER%NUMBER
math NUMBER add 1
if matchre ("%%LETTER%NUMBER","%GAME_PIECES") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%%LETTER%NUMBER
math NUMBER add 1
gosub PREV_LETTER
if matchre ("%%LETTER%NUMBER","%GAME_PIECES") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%%LETTER%NUMBER
gosub PREV_LETTER
if matchre ("%%LETTER%NUMBER","%GAME_PIECES") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%%LETTER%NUMBER
var ENEMY_ACTION 0
eval ECHO_TILES replacere ("%ECHO_TILES","^0\|","")
var WHISPER Your Empath's senses reveal %ECHO_TILES!
pause
goto WHISPER

WARMAGE_SPECIAL:
var SPECIAL_HIT WarMage
eval EN_WARMAGE_SPECIAL replacere ("%FILL","KILL W ","")
var TILES 0
var ECHO_TILES 0
gosub EXTRACT %EN_WARMAGE_SPECIAL
#var TILES %TILES|%LETTER%NUMBER
# 4 is enough tiles
gosub TILE_SW
gosub TILE_N2
gosub TILE_E2
gosub TILE_S2
goto REVEAL_MY_MULTI_TILES

MANA_TRAP_TRIGGERED:
var ECHO_2 %ENEMY's mana trap explodes, revealing several of your tiles to %ENEMY!
var TILES 0
var ECHO_TILES 0
gosub EXTRACT %TILE
gosub TILE_W
gosub TILE_NE
gosub TILE_SE
gosub TILE_SW
gosub TILE_N
goto REVEAL_MY_MULTI_TILES

REVEAL_MY_MULTI_TILES:
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
gosub EXTRACT %VALIDSTRIKE
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
    if (("%P" != "0") && ("%SPECIAL_HIT" != "ThiefDeath") then
        {
        if !matchre ("%TILE","%TRAP|%BE") then
            {
            gosub PALADIN_SPECIAL
            if matchre ("%PALADIN_SPECIAL","%PALADIN") then
                {
                var ECHO PROTECTED
                return
                }
            var NUMBER %BACKUP_NUMBER
            var LETTER %BACKUP_LETTER
            }
        }
    }
if matchre ("%TILE","%WARMAGE") then gosub HIT_SCORE W
if matchre ("%TILE","%EMPATH") then gosub HIT_SCORE E
if matchre ("%TILE","%RANGER") then
    {
    if ("%SPECIAL_HIT" != "ThiefDeath") then gosub RANGER_SPECIAL
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
var BACKUP_NUMBER %NUMBER
var BACKUP_LETTER %LETTER
var PALADIN_SPECIAL 0
math NUMBER subtract 1
var PALADIN_SPECIAL %PALADIN_SPECIAL|%%LETTER%NUMBER
math NUMBER add 2
var PALADIN_SPECIAL %PALADIN_SPECIAL|%%LETTER%NUMBER
math NUMBER subtract 1
gosub NEXT_LETTER
var PALADIN_SPECIAL %PALADIN_SPECIAL|%%LETTER%NUMBER
gosub PREV_LETTER_2
var PALADIN_SPECIAL %PALADIN_SPECIAL|%%LETTER%NUMBER
eval PALADIN_SPECIAL replacere ("%PALADIN_SPECIAL","^0\|","")
return

ENEMY_STRIKES:
var LAST_UPDATE %STRIKE|0|0
math ENEMYTURN add 1
if ("%MEFIRST" = "") then var ENFIRST First Strike!
var VALIDSTRIKE %STRIKE
var STRIKE 0
if ("%VALIDSTRIKE" = "SLATE") then
    {
    if matchre ("%SLATESTRIKE","^0$") then goto GAME_LOOP
    else var VALIDSTRIKE %SLATESTRIKE
    }
gosub EXTRACT %VALIDSTRIKE
var VALIDSTRIKE %LETTER%NUMBER
eval TILE replacere ("%ALPHABET","%LETTER\|.*","")
eval TILE count ("%TILE","|")
if %TILE > %GRID_MAX then goto GAME_LOOP
if %NUMBER > %GRID_MAX then goto GAME_LOOP
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
eval PIECE element ("%PIECE_INITIAL","%PIECES_SET")
eval %PIECE element ("%PIECE_HEALTH","%PIECES_SET")
eval PIECE element ("%PIECE_ORDER","%PIECES_SET")
eval ORIENT element ("%PIECE_SHAPES","%PIECES_SET")
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
    }
if %PIECE = TRAP1 then put #echo >%WINDOW mono "Select the tile to lay your first Mana Trap:
if %PIECE = TRAP2 then put #echo >%WINDOW mono "Select the tile to lay your second Mana Trap:"
if matchre ("%PIECE","TRAP") then
    {
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
if matchre ("%PIECE","PALADIN|WARMAGE") then
    {
    if matchre ("%TILE","^(A|%RIGHT_EDGE)|([A-Z]1|%GRID_MAX)$") then
        {
        put #echo >%WINDOW mono "Center tile cannot be on the edge of the board!"
        goto GAME_SETUP_LOOP
        }
    }
if matchre ("%PIECE","EMPATH") then
    {
    if matchre ("%TILE","^%RIGHT_EDGE|[A-Z]1$") then
        {
        put #echo >%WINDOW mono "Bottom-left tile cannot be on the upper or right edge of the board!"
        goto GAME_SETUP_LOOP
        }
    }
if matchre ("%PIECE","RANGER") then
    {
    evalmath NUMBER %GRID_MAX - 1
    eval LETTER element ("0|%ALPHABET","%NUMBER")
    evalmath NUMBER %GRID_MAX - 2
    eval TILES element ("0|%ALPHABET","%NUMBER")
    if matchre ("%TILE","(%LETTER|%TILES|%RIGHT_EDGE)(1|2|3)$") then
        {
        put #echo >%WINDOW mono "Bottom-left tile cannot be in this corner!"
        goto GAME_SETUP_LOOP
        }
    }
if matchre ("%PIECE","MOONMAGE") then
    {
    if matchre ("%TILE","A1|A%GRID_MAX|%RIGHT_EDGE1|%RIGHTE_EDGE%GRID_MAX") then
        {
        put #echo >%WINDOW mono "Middle tile cannot be in a corner!"
        goto GAME_SETUP_LOOP
        }
    }
if matchre ("%PIECE","THIEF") then
    {
    if matchre ("%TILE","^%RIGHT_EDGE1$") then
        {
        put #echo >%WINDOW mono "Bottom-left tile cannot be in this corner!"
        goto GAME_SETUP_LOOP
        }
    }
if matchre ("%PIECE","TRAP") then
    {
    if matchre ("%TILE","^(A|%RIGHT_EDGE)|([A-Z]1|%GRID_MAX)$") then
        {
        put #echo >%WINDOW mono "Mana trap tile cannot be on the edge of the board!"
        goto GAME_SETUP_LOOP
        }
    }
put #echo >%WINDOW mono "Selected tile %TILE!"
var TILES 0
eval LETTER replacere ("%TILE","\d+","")
eval NUMBER replacere ("%TILE","[A-Z]","")
if %PIECE = WARMAGE then goto PLACE_WARMAGE
if %PIECE = EMPATH then goto PLACE_EMPATH
if %PIECE = TRAP1 then goto PLACE_TRAP1
if %PIECE = TRAP2 then goto PLACE_TRAP2
if %ORIENT != 0 then goto GAME_SETUP_LOOP
goto LOGIC_ERROR

SET_PIECE_ORIENTATION:
var TILES 0
if %TILE = 0 then
    {
    put #echo >%WINDOW mono "Select a tile first!"
    goto GAME_SETUP_LOOP
    }
var PLACE_TILE %TILE
if %PIECE = THIEF then
    {
    if %SHAPE = 1 then goto PLACE_THIEF_SHAPE_1
    if %SHAPE = 2 then goto PLACE_THIEF_SHAPE_2
    }
if %PIECE = MOONMAGE then
    {
    if %SHAPE = 1 then goto PLACE_MOONMAGE_SHAPE_1
    if %SHAPE = 2 then goto PLACE_MOONMAGE_SHAPE_2
    if %SHAPE = 3 then goto PLACE_MOONMAGE_SHAPE_3
    if %SHAPE = 4 then goto PLACE_MOONMAGE_SHAPE_4
    if %SHAPE = 5 then goto PLACE_MOONMAGE_SHAPE_5
    if %SHAPE = 6 then goto PLACE_MOONMAGE_SHAPE_6
    }
if %PIECE = RANGER then
    {
    if %SHAPE = 1 then goto PLACE_RANGER_SHAPE_1
    if %SHAPE = 2 then goto PLACE_RANGER_SHAPE_2
    if %SHAPE = 3 then goto PLACE_RANGER_SHAPE_3
    if %SHAPE = 4 then goto PLACE_RANGER_SHAPE_4
    }
if %PIECE = PALADIN then
    {
    if %SHAPE = 1 then goto PLACE_PALADIN_SHAPE_1
    if %SHAPE = 2 then goto PLACE_PALADIN_SHAPE_2
    if %SHAPE = 3 then goto PLACE_PALADIN_SHAPE_3
    if %SHAPE = 3 then goto PLACE_PALADIN_SHAPE_4
    }


PLACE_PALADIN_SHAPE_4:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_NE
gosub TILE_S
gosub TILE_SW
gosub TILE_W
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_SHAPE_3:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_NW
gosub TILE_S
gosub TILE_SE
gosub TILE_E
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_SHAPE_2:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_NW
gosub TILE_E
gosub TILE_SE
gosub TILE_S
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_SHAPE_1:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_NE
gosub TILE_W
gosub TILE_SW
gosub TILE_S
goto PLACE_PALADIN_CONFIRM

PLACE_PALADIN_CONFIRM:
gosub CONFIRM_PLACEMENT Paladin
gosub PRINT_PIECE PALADIN
math PIECES_SET add 1
goto REDRAW_DISPLAY

PLACE_WARMAGE:
var WARMAGE_SPECIAL %LETTER%NUMBER
var TILES %TILES|%LETTER%NUMBER
gosub TILE_N
gosub TILE_SE
gosub TILE_SW
gosub TILE_NW
gosub CONFIRM_PLACEMENT Warrior Mage
gosub PRINT_PIECE WARMAGE
math PIECES_SET add 1
goto REDRAW_DISPLAY

PLACE_EMPATH:
var TILES %TILES|%LETTER%NUMBER
var EMPATH_SPECIAL %LETTER%NUMBER
gosub TILE_N
gosub TILE_E
gosub TILE_S
gosub CONFIRM_PLACEMENT Empath
gosub PRINT_PIECE EMPATH
math PIECES_SET add 1
goto REDRAW_DISPLAY

PLACE_RANGER_SHAPE_1:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_N
gosub TILE_N
gosub TILE_N
gosub NEXT_LETTER
var RANGER_SPECIAL %LETTER
goto PLACE_RANGER_CONFIRM

PLACE_RANGER_SHAPE_2:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_N
gosub TILE_N
gosub TILE_N
gosub PREV_LETTER
var RANGER_SPECIAL %LETTER
goto PLACE_RANGER_CONFIRM

PLACE_RANGER_SHAPE_3:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_E
gosub TILE_E
gosub TILE_E
math NUMBER subtract 1
var RANGER_SPECIAL %NUMBER
goto PLACE_RANGER_CONFIRM

PLACE_RANGER_SHAPE_4:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_E
gosub TILE_E
gosub TILE_E
math NUMBER add 1
var RANGER_SPECIAL %NUMBER
goto PLACE_RANGER_CONFIRM

PLACE_RANGER_CONFIRM:
gosub CONFIRM_PLACEMENT Ranger
gosub PRINT_PIECE RANGER
math PIECES_SET add 1
var RANGER_CHARGES 2
goto REDRAW_DISPLAY

PLACE_MOONMAGE_SHAPE_1:
gosub TILE_SW
gosub TILE_NE
gosub TILE_NE
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_2:
gosub TILE_SE
gosub TILE_NW
gosub TILE_NW
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_3:
gosub TILE_SW
gosub TILE_NE
gosub TILE_SE
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_4:
gosub TILE_NW
gosub TILE_SE
gosub TILE_NE
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_5:
gosub TILE_SW
gosub TILE_NE
gosub TILE_NW
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_SHAPE_6:
gosub TILE_SE
gosub TILE_NW
gosub TILE_NE
goto PLACE_MOONMAGE_CONFIRM

PLACE_MOONMAGE_CONFIRM:
gosub CONFIRM_PLACEMENT Moon Mage
gosub PRINT_PIECE MOONMAGE
math PIECES_SET add 1
var MOONMAGE_CHARGES 5
goto REDRAW_DISPLAY

PLACE_THIEF_SHAPE_1:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_N
var THIEF_SPECIAL %NUMBER
goto PLACE_THIEF_CONFIRM

PLACE_THIEF_SHAPE_2:
var TILES %TILES|%LETTER%NUMBER
gosub TILE_E
var THIEF_SPECIAL %LETTER
goto PLACE_THIEF_CONFIRM

PLACE_THIEF_CONFIRM:
gosub CONFIRM_PLACEMENT Thief
gosub PRINT_PIECE THIEF
math PIECES_SET add 1
goto REDRAW_DISPLAY

PLACE_TRAP1:
var %TILE %TRAP
math PIECES_SET add 1
goto REDRAW_DISPLAY

PLACE_TRAP2:
var %TILE %TRAP
math PIECES_SET add 1
gosub SETVARS CLEAR
goto REDRAW_DISPLAY

TILE_N2:
math NUMBER subtract 1

TILE_N:
math NUMBER subtract 1
var TILES %TILES|%LETTER%NUMBER
return

TILE_NE:
math NUMBER subtract 1
gosub NEXT_LETTER
var TILES %TILES|%LETTER%NUMBER
return

TILE_E2:
gosub NEXT_LETTER

TILE_E:
gosub NEXT_LETTER
var TILES %TILES|%LETTER%NUMBER
return

TILE_SE:
math NUMBER add 1
gosub NEXT_LETTER
var TILES %TILES|%LETTER%NUMBER
return

TILE_S2:
math NUMBER add 1

TILE_S:
math NUMBER add 1
var TILES %TILES|%LETTER%NUMBER
return

TILE_SW:
math NUMBER add 1
gosub PREV_LETTER
var TILES %TILES|%LETTER%NUMBER
return

TILE_W:
gosub PREV_LETTER
var TILES %TILES|%LETTER%NUMBER
return

TILE_NW:
math NUMBER subtract 1
gosub PREV_LETTER
var TILES %TILES|%LETTER%NUMBER
return

PREV_LETTER_2:
eval LETTER replacere ("0|%ALPHABET","\|%LETTER.*","")
eval LETTER replacere ("%LETTER","\|[A-Z]$","")
eval LETTER replacere ("%LETTER","^.*\|","")
return

PREV_LETTER:
eval LETTER replacere ("0|%ALPHABET","\|%LETTER.*","")
eval LETTER replacere ("%LETTER",".*\|","")
return

NEXT_LETTER:
eval LETTER replacere ("%ALPHABET|0",".*%LETTER\|","")
eval LETTER replacere ("%LETTER","\|.*","")
return

CONFIRM_PLACEMENT:
var ECHO_PIECE $0
eval LOOP count ("%TILES","|")

CONFIRM_PLACEMENT_LOOP:
eval TILE element ("%TILES","%LOOP")
var TYPE %%TILE
if !matchre ("%TYPE","%TILE_BUTTON") then
    {
    put #echo >%WINDOW mono "Cannot place your %ECHO_PIECE there!";#echo >%WINDOW mono "Try another spot or orientation."
    var TILES 0
    var TILE %PLACE_TILE
    eval LETTER replacere ("%TILE","\d+","")
    eval NUMBER replacere ("%TILE","[A-Z]","")
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
if %DEBUG = 1 then debug 0
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
eval COL element ("%ALPHABET","%COL_LOOP")
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
                if (("%M" != "0") && ("%MOONMAGE_CHARGES" != "0")) then put #echo >%WINDOW mono "   Empath: {Sense Life:#parse EMPATH_SPECIAL}  Moon Mage: {Locate:#parse MOONMAGE_LOCATE}"
                else put #echo >%WINDOW mono "   Empath: {Sense Life:#parse EMPATH_SPECIAL}"
                }
            else
                {
                if (("%M" != "0") && ("%MOONMAGE_CHARGES" != "0")) then put #echo >%WINDOW mono "   Moon Mage: {Cast Locate:#parse MOONMAGE_LOCATE}"
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
eval COL element ("%ALPHABET","%COL_LOOP")
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


SAVE_GAME_FORCED_BY_ENEMY:
if %LAST_UPDATE = Saving then goto GAME_LOOP

SAVE_GAME_ENEMY:
#eval SAVE replacere ("%PALADIN_SPECIAL","\|","-")
# Insert %SAVE before %WARMAGE_SPECIAL when using Paladin Special Version 1
var SAVE %RIGHT_EDGE|%GRID_MAX|%P|%W|%E|%R|%M|%T|%EP|%EW|%EE|%ER|%EM|%ET|%WARMAGE_SPECIAL|%EMPATH_SPECIAL|%RANGER_SPECIAL|%RANGER_CHARGES|%MOONMAGE_CHARGES|%THIEF_SPECIAL|%MYTURN|%ENEMYTURN|%MEFIRST|%ENFIRST
var ECHO_2 Game versus %ENEMY saved!
var FILL %ENEMY
var LAST_UPDATE Saving
var WHISPER Saving!
gosub WHISPER_RETURN
var LOOP 1
if %DEBUG = 1 then debug 0
goto SAVE_GAME_OUTER_LOOP

SAVE_GAME_PRESET:
#eval SAVE replacere ("%PALADIN_SPECIAL","\|","-")
var SAVE %RIGHT_EDGE|%GRID_MAX|%PIECES_SET|%WARMAGE_SPECIAL|%EMPATH_SPECIAL|%RANGER_SPECIAL|%RANGER_CHARGES|%MOONMAGE_CHARGES|%THIEF_SPECIAL
var ECHO_2 Preset game saved!
var FILL Preset
var LOOP 1

SAVE_GAME_OUTER_LOOP:
var COL_LOOP 0

SAVE_GAME_INNER_LOOP:
eval COL element ("%ALPHABET","%COL_LOOP")
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
gosub SETVARS LINKS
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
eval RANGER_CHARGES element ("%LOAD","17")
eval MOONMAGE_CHARGES element ("%LOAD","18")
eval THIEF_SPECIAL element ("%LOAD","19")
eval MYTURN element ("%LOAD","20")
eval ENEMYTURN element ("%LOAD","21")
eval MEFIRST element ("%LOAD","22")
eval ENFIRST element ("%LOAD","23")
eval COL_LOOP count ("%LOAD","|")
var LOOP 23
goto LOAD_GAME_LOOP

LOAD_GAME_PRESET:
gosub SETVARS LINKS
var LOAD $BattleSiege_Preset
var ECHO_2 Preset game loaded!
var ENEMY 0
eval RIGHT_EDGE element ("%LOAD","0")
eval GRID_MAX element ("%LOAD","1")
eval PIECES_SET element ("%LOAD","2")
eval WARMAGE_SPECIAL element ("%LOAD","3")
eval EMPATH_SPECIAL element ("%LOAD","4")
eval RANGER_SPECIAL element ("%LOAD","5")
eval RANGER_CHARGES element ("%LOAD","6")
eval MOONMAGE_CHARGES element ("%LOAD","7")
eval THIEF_SPECIAL element ("%LOAD","8")
eval COL_LOOP count ("%LOAD","|")
if %COL_LOOP = 8 then goto REDRAW_DISPLAY
var LOOP 8

LOAD_GAME_LOOP:
if %DEBUG = 1 then debug 0
eval TILE element ("%LOAD","%LOOP")
eval FILL replacere ("%TILE","^.*\:","")
eval TILE replacere ("%TILE","\:.*","")
var %TILE %FILL
math LOOP add 1
if %LOOP <= %COL_LOOP then goto LOAD_GAME_LOOP
gosub SETVARS CLEAR
if %ENEMY = 0 then goto REDRAW_DISPLAY
if %DEBUG = 1 then debug 10
goto START_GAME


######## SETVARS ##########


COUNT_TILES_REMAINING:
var TILES 0
var NUMBER 1
if %DEBUG = 1 then debug 0

SETVARS_COUNT:
var COLUMN 0
SETVARS_COUNT_LOOP:
eval LETTER element ("%ALPHABET","%COLUMN")
math COLUMN add 1
if %COLUMN > %GRID_MAX then
    {
    math NUMBER add 1
    if %NUMBER > %GRID_MAX then return
    goto SETVARS_COUNT
    }
if matchre ("%E%LETTER%NUMBER","%TILE_BUTTON") then math TILES add 1
goto SETVARS_COUNT_LOOP

SETVARS:
if %DEBUG = 1 then debug 0
var NUMBER 1
goto SETVARS_$0

SETVARS_FIND:
var COLUMN 0
SETVARS_FIND_LOOP:
eval LETTER element ("%ALPHABET","%COLUMN")
math COLUMN add 1
if %COLUMN > %GRID_MAX then
    {
    math NUMBER add 1
    if %NUMBER > %GRID_MAX then return
    goto SETVARS_FIND
    }
if matchre ("%%LETTER%NUMBER","%MOONMAGE") then var ECHO_TILES %ECHO_TILES|%LETTER%NUMBER:%MOONMAGE
goto SETVARS_FIND_LOOP

SETVARS_CLEAR:
var COLUMN 0
SETVARS_CLEAR_LOOP:
eval LETTER element ("%ALPHABET","%COLUMN")
math COLUMN add 1
if %COLUMN > %GRID_MAX then
    {
    math NUMBER add 1
    if %NUMBER > %GRID_MAX then return
    goto SETVARS_CLEAR
    }
if matchre ("%%LETTER%NUMBER","%TILE_BUTTON") then var %LETTER%NUMBER %BE
goto SETVARS_CLEAR_LOOP

SETVARS_LINKS:
var COLUMN 0
SETVARS_LINKS_LOOP:
eval LETTER element ("%ALPHABET","%COLUMN")
math COLUMN add 1
if %COLUMN > %GRID_MAX then
    {
    math NUMBER add 1
    if %NUMBER > %GRID_MAX then return
    goto SETVARS_LINKS
    }
var %LETTER%NUMBER {%TILE_BUTTON:#parse SELECT_%LETTER%NUMBER}
var E%LETTER%NUMBER {%TILE_BUTTON:#parse SELECT_%LETTER%NUMBER}
goto SETVARS_LINKS_LOOP


########################

END_CONDITIONS:
if ("%P|%W|%E|%R|%M|%T" = "0|0|0|0|0|0") then
    {
    var ECHO_2 You lost! But the real treasure is the mana traps we set off along the way!
    var GAME_WON 2
    }
if ("%EP|%EW|%EE|%ER|%EM|%ET" = "0|0|0|0|0|0") then
    {
    var ECHO_2 You won! You're a stategic mastermind!
    var GAME_WON 1
    }
if %GAME_WON != 0 then
    {
    gosub DISPLAY
    put #echo >%WINDOW mono "%ECHO_2"
    put #echo >%WINDOW lime mono "Total Turns: %MYTURN! - %ENEMY's Total Turns: %ENEMYTURN!"
    put #echo >%WINDOW
    random 1 6
    gosub QUOTES
    put #echo >%WINDOW '"%QUOTE_%r"'
    if %GAG_WHISPERS = 1 then
        {
        put #ungag %OUTPUT_GAG
        put #ungag %INPUT_GAG
        }
    put #class BattleSiege false
    exit
    }
return

QUOTES:
var QUOTE_1 Every day, once a day, give yourself a present. Don't plan it. Don't wait for it. Just let it happen. It could be a new shirt at the men's store, a catnap in your office chair, or two cups of good, hot black coffee.
var QUOTE_2 Everything will be okay in the end. If it's not okay, it's not the end.
var QUOTE_3 Now you listen to me. While I will admit to a certain cynicism, the fact is that I am a naysayer and hatchetman in the fight against violence. I pride myself in taking a punch and I'll gladly take another because I choose to live my life in the company of Gandhi and King. My concerns are global. I reject absolutely revenge, aggression, and retaliation. The foundation of such a method... is love. I love you, Sheriff Truman.
var QUOTE_4 If any god had anything to do with it, then that god shouldn't be a god. And if any god could have stopped it, then that god shouldn't be a god.
var QUOTE_5 Let's go fill Moominvalley with crime, c'mon!
var QUOTE_6 Hey, hey, hey, rainy face! Hey, proud warrior. Let the sun come out, you big bad G.I. Joe. You know, kitten, we all have permission to make mistakes. It's called learning.

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

LOGIC_ERROR:
put #echo >Log pink BattleSiege: This text should never display. The script is broken and will now close.
exit
