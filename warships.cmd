#############
# USER VARS #
#############

# echo to Log window how the turn queue is looking.
var DEBUG 0
# echo Board to custom window; 0 to disable
var WINDOW Warships
# Color of text to echo when watching
var COLOR #60d4fc
# Set to 1 to hide whispering of cards to a player when you are also playing!
var FAIR_DEALER 1
# set how you want to describe yourself in ACTs if you're playing the game.
var DEALER herself
var DEALER_SHORT her
if $charactername = Banjo then
    {
    var DEALER himself
    var DEALER_SHORT his
    }
if $charactername = Kazooie then
    {
    var DEALER herself
    var DEALER_SHORT her
    }
if $charactername = Blue Jingo then
    {
    var DEALER themselves
    var DEALER_SHORT their
    }

#################
# GAME SETTINGS #
#################

# Debris chance. Chance that barricades or arbalests turn into debris upon destruction. This number out of 200.
var DEBRIS 100

# Amount of each card in the deck
var AMOUNT_1 10
var AMOUNT_2 10
var AMOUNT_3 5
var AMOUNT_4 15
var AMOUNT_5 8
var AMOUNT_6 4
var AMOUNT_7 6
var AMOUNT_8 4
var AMOUNT_9 0

# 1 = CONSTRUCT Arbalest <1 base tile>
# 2 = BUILD Fortification <1 tile>
# 3 = BUILD Heavy Fortification <2 tiles> (End Turn)
# 4 = FIRE Arbalest <1 tile>
# 5 = FIRE ALL Arbalests (End Turn)
# 6 = SWAB the Decks! (Discard Hand)
# 7 = CLEAN debris <1 tile> (Remove Xx)
# 8 = REPAIR Ship <10%>
# 9 = REPAIR Ship <30%> (End Turn)

#############

if_2 then
    {
    var N1 %1
    var N2 %2
    if matchre ("%N1","$charactername") then
        {
        if !matchre ("$roomplayers","%N2") then goto START_ERROR
        }
    if matchre ("%N2","$charactername") then
        {
        if !matchre ("$roomplayers","%N1") then goto START_ERROR
        }
    if !matchre ("%N1|%N2","$charactername") then
        {
        var FAIR_DEALER 0
        if !matchre ("$roomplayers","%N1") then goto START_ERROR
        if !matchre ("$roomplayers","%N2") then goto START_ERROR
        }
    goto START
    }
START_ERROR:
eval 1 toupper ("%1")
if matchre ("%1","SUPPORT|WATCH|HOST|PLAY") then goto SUPPORT
if matchre ("%1","RULES") then
    {
    var N1 Player One
    var N2 Player Two
    gosub RULES
    exit
    }
put #echo
put #echo pink Game requires two players to start! Make sure they're here and spelled correctly! (That includes you!)
put #echo yellow Alternatively, start with the arguements "watch/play <Hostname>" to enable monofont windowed support!
put #echo
exit

SUPPORT:
var HOST %2
if !matchre ("$roomplayers","%HOST") then
    {
    put #echo
    put #echo pink Host [%HOST] not found in the area! Try again!
    put #echo
    exit
    }
var PLAYBACK 0
action if %PLAYBACK = 1 then math LOOP add 1;if %PLAYBACK = 1 then var R%LOOP $2 when ^\s\s\s\s(\s|\")(.*)\"?$
action var PLAYBACK 1 when ^%HOST recites

SUPPORT_LOOP:
var PLAYBACK 0
var LOOP 0
waiteval ("%PLAYBACK")
pause 1.5
put #window show %WINDOW
put #clear %WINDOW
if ("%R1" != "0") then put #echo >%WINDOW %COLOR mono "%R1"
if ("%R2" != "0") then put #echo >%WINDOW %COLOR mono "%R2"
if ("%R3" != "0") then put #echo >%WINDOW %COLOR mono "%R3"
if ("%R4" != "0") then put #echo >%WINDOW %COLOR mono "%R4"
if ("%R5" != "0") then put #echo >%WINDOW %COLOR mono "%R5"
if ("%R6" != "0") then put #echo >%WINDOW %COLOR mono "%R6"
if ("%R7" != "0") then put #echo >%WINDOW %COLOR mono "%R7"
if ("%R8" != "0") then put #echo >%WINDOW %COLOR mono "%R8"
if ("%R9" != "0") then put #echo >%WINDOW %COLOR mono "%R9"
var R1 0
var R2 0
var R3 0
var R4 0
var R5 0
var R6 0
var R7 0
var R8 0
var R9 0
goto SUPPORT_LOOP

#############

START:
var P1_ARB_1 ]=
var P1_ARB_2 =D
var P2_ARB_1 =[
var P2_ARB_2 C=
var P1_BAR ]]
var P2_BAR [[

var 1_HEALTH 100
var 1_CARDS 0
var 1_ARBALESTS_FRONT 0
var 1_ARBALESTS_BACK 0
var 1_BARRICADES 0
var 1_WEAKNESS 0
var 2_HEALTH 100
var 2_CARDS 0
var 2_ARBALESTS_FRONT 0
var 2_ARBALESTS_BACK 0
var 2_BARRICADES 0
var 2_WEAKNESS 0

var C1 CONSTRUCT Arbalest <1 base tile>
var C2 BUILD Fortification <1 tile>
var C3 BUILD Heavy Fortification <2 tiles> (End Turn)
var C4 FIRE Arbalest <1 tile>
var C5 FIRE ALL Arbalests (End Turn)
var C6 SWAB the Decks! (Discard Hand)
var C7 CLEAN Debris <1 tile> (Remove Xx)
var C8 REPAIR Ship <10%>
var C9 REPAIR Ship <30%> (End Turn)

var LINE_1 GAMESTART
var LINE_2 * 1: 2: 3: 4: 5: 6: * (%1_HEALTH %) --- (%2_HEALTH %) * 6: 5: 4: 3: 2: 1: *
#                           6...        7....          8  9  10 11 12 13
var LINE_A A|::|::|::|::|::|::|) ~ ~~~ ~ ~ ~ ~ ~~~ ~ (|::|::|::|::|::|::|A
var LINE_B B|::|::|::|::|::|::|) ~ ~ ~~~ ~ ~~~ ~ ~ ~ (|::|::|::|::|::|::|B
var LINE_C C|::|::|::|::|::|::|) ~ ~ ~ ~~~ ~ ~ ~ ~~~ (|::|::|::|::|::|::|C
var LINE_D D|::|::|::|::|::|::|) ~ ~~~ ~ ~ ~ ~~~ ~ ~ (|::|::|::|::|::|::|D
var LINE_E E|::|::|::|::|::|::|) ~ ~ ~ ~ ~~~ ~ ~~~ ~ (|::|::|::|::|::|::|E
var LINE_F F|::|::|::|::|::|::|) ~ ~ ~~~ ~ ~ ~~~ ~ ~ (|::|::|::|::|::|::|F
var LINE_G G|::|::|::|::|::|::|) ~~~ ~ ~ ~ ~~~ ~ ~ ~ (|::|::|::|::|::|::|G
var ROW_FIX 0|1|2|A|B|C|D|E|F|G
var COL_FIX 0|13|12|11|10|9|8
var COL_REVERSE 0|1|2|3|4|5|6|7|6|5|4|3|2|1
var COL_REVERSE_SHORT 0|6|5|4|3|2|1
var RETRY ^\.\.\.wait|^Sorry\,|^You are still stunned
var COL_2 1
var ROW_2 A
var EMPTY
var LOOP 0
var DECK 0
evalmath MAX (%AMOUNT_1 + %AMOUNT_2 + %AMOUNT_3 + %AMOUNT_4 + %AMOUNT_5 + %AMOUNT_6 + %AMOUNT_7 + %AMOUNT_8 + %AMOUNT_9)
var EXTRA_SWAB 0

CREATE_DECK:
if %LOOP = %MAX then goto GAME_START
random 1 9
if ("%AMOUNT_%r" = "0") then goto CREATE_DECK
math AMOUNT_%r subtract 1
var DECK %DECK|%r
math LOOP add 1
goto CREATE_DECK

SHUFFLE_DECK:
if (("%EXTRA_SWAB" = "1") && (matchre ("%DECK","6"))) then
    {
    eval CARD replacere ("%DECK","6.*","")
    eval CARD count ("%CARD","|")
    gosub REPLACE DECK %CARD X
    eval DECK replacere ("%DECK","\|X","")
    var EXTRA_SWAB 0
    }
eval MAX count ("%DECK","|")
eval DECK replacere ("%DECK","0\|","")
var NEW_DECK 0

SHUFFLE:
random 1 %MAX
eval CARD element ("%DECK","%r")
var NEW_DECK %NEW_DECK|%CARD
gosub REPLACE DECK %r X
eval DECK replacere ("%DECK","\|X","")
math MAX subtract 1
if %MAX != 0 then goto SHUFFLE
var DECK %NEW_DECK|0
eval DECK replacere ("%DECK","0\|","")
return

#####################

GAME_START:
gosub SHUFFLE_DECK
put #echo
put #echo lime Starting with %N1 as Player 1 and %N2 as Player 2!
put #echo
var TURN 0
action (P1) off
action (P2) off
if ("%N1" = "$charactername") then
    {
    action (P1) var TURN %TURN|$2 when ^You.*(say|accent)\, \"(.*)\"$
    }
if ("%N2" = "$charactername") then
    {
    action (P2) var TURN %TURN|$2 when ^You.*(say|accent)\, \"(.*)\"$
    }
action (P1) var TURN %TURN|$2 when ^%N1.*(says|accent|to you)\, \"(.*)\"$
action (P2) var TURN %TURN|$2 when ^%N2.*(says|accent|to you)\, \"(.*)\"$
action (P1) var TURN %TURN|$1 when ^\(%N1\'?s?\,? (.*)
action (P2) var TURN %TURN|$1 when ^\(%N2\'?s?\,? (.*)
action var TURN %TURN|BOARD when (asks you|asks you in an? ([\w-']+\s)?[\w-']+ accent)\, \"(.*)?\b(BOARD|Board|board)\b(.*)?\?\"
action var TURN %TURN|RULES when (asks you|asks you in an? ([\w-']+\s)?[\w-']+ accent)\, \"(.*)?\b(RULES?|Rule|rule)s?\b(.*)?\?\"
action var TURN %TURN|TYPES when (asks you|asks you in an? ([\w-']+\s)?[\w-']+ accent)\, \"(.*)?\b(TYPES?|Type|type)s?\b(.*)?\?\"
action var TURN %TURN|RULES when ^\w+ asks you a question.*(RULES?|Rule|rule)s?
action var TURN %TURN|BOARD when ^\w+ asks you a question.*(BOARD?|Board|board)
action var TURN %TURN|TYPES when ^\w+ asks you a question.*(TYPES?|Type|type)s?
action var TURN %TURN|REMIND $1 when ^(%N1|%N2) asks you a question.*(REMIND|Remind|remind)
action var TURN %TURN|REMIND $1 when ^(%N1|%N2).*(asks you|asks you in an? ([\w-']+\s)?[\w-']+ accent)\, \"(.*)?\b(REMIND|Remind|remind)\b(.*)?\?\"
action var TURN %TURN|REMIND $1 when ^(%N1|%N2) (taps you lightly on the shoulder)
action var TURN %TURN|REMIND $charactername when ^You tap yourself
action var TURN %TURN|REMIND $1 when ^REMIND (.*)
action var TURN %TURN|BOARD when ^BOARD
action var TURN %TURN|RULES when ^RULES
action var TURN %TURN|TYPES when ^TYPES
action var TURN %TURN|PASS when ^PASS

var LOOP 0
gosub WEAK_BOARDS_P1
var LOOP 0
gosub WEAK_BOARDS_P2
var LINE_1 Starting with %N1 on the left and %N2 on the right! %N1 goes first.
var LAST FirstTurn
var PLAYER P1
var GAMESTART 1
goto PLAYER_1

PASS_TURN:
var NEXTLINE %N%K has passed their turn.

NEXT_TURN:
if %PLAYER = P1 then var PLAYER P2
else var PLAYER P1
var LINE_1 %NEXTLINE %ENEMY goes next.
if %PLAYER = P1 then goto PLAYER_1
goto PLAYER_2

PLAYER_1:
var ENEMY %N2
action (P2) off
gosub RECITE
var K 1
var E 2
if %GAMESTART = 0 then
    {
    var ACT :%N1 draws a card and deals it out to \@.
    if ("%N1" = "$charactername") then var ACT draws a card for %DEALER.
    gosub GIVE_CARDS %N%K %K 1
    }
if %GAMESTART = 1 then
    {
    var ACT :%N1 draws six cards and deals them out to \@.
    if ("%N1" = "$charactername") then var ACT draws six card for %DEALER.
    gosub GIVE_CARDS %N%K %K 6
    }
action (P1) on
var CARDS_PLAYED 0
goto GAME_LOOP

PLAYER_2:
var ENEMY %N1
action (P1) off
gosub RECITE
var K 2
var E 1
if %GAMESTART = 0 then
    {
    var ACT :%N2 draws a card and deals it out to \@.
    if ("%N2" = "$charactername") then var ACT draws a card for %DEALER.
    gosub GIVE_CARDS %N%K %K 1
    }
if %GAMESTART = 1 then
    {
    var ACT :%N2 draws six cards and deals them out to \@.
    if ("%N2" = "$charactername") then var ACT draws six card for %DEALER.
    gosub GIVE_CARDS %N%K %K 6
    var GAMESTART 0
    }
action (P2) on
var CARDS_PLAYED 0
goto GAME_LOOP

GAME_LOOP_UPDATE:
if %CARDS_PLAYED = 3 then goto NEXT_TURN
if %CARDS_PLAYED = 2 then var LINE_1 %NEXTLINE %N%K has 1 play left this turn.
if %CARDS_PLAYED = 1 then var LINE_1 %NEXTLINE %N%K has 2 plays left this turn.
gosub RECITE
var ACT :%N%K draws a card and deals it out to \@.
if ("%N%K" = "$charactername") then var ACT draws a card for %DEALER.
gosub GIVE_CARDS %N%K %K 1

GAME_LOOP:
gosub clear
eval TURN replacere ("%TURN","\|+","|")
eval TURN replacere ("%TURN","\|$","")
if matchre ("%TURN","^0$") then waiteval ("%TURN")
pause 0.5
eval GO element ("%TURN","1")
gosub REPLACE "TURN" 1 %EMPTY
eval TURN replacere ("%TURN","\|+","|")
eval TURN replacere ("%TURN","\|$","")
if ("%LAST" = "%GO") then
    {
    var LAST LastIsNowFixed
    goto GAME_LOOP
    }
if %DEBUG = 1 then put #echo >Log Warships Debug, %N%K's turn: %TURN
var LAST %GO
eval GO toupper ("%GO")
if matchre ("%GO","^RULES") then goto RULES_GOTO
if matchre ("%GO","^TYPES") then goto CARD_RULES_GOTO
if matchre ("%GO","^BOARD") then goto RECITE_GOTO
if matchre ("%GO","^REMIND") then goto REMIND
if matchre ("%GO","\b(CLEAN)\b") then goto FIX
if matchre ("%GO","\b(FIRE)S?\b") then goto FIRE
if matchre ("%GO","\b(BUILD)S?\b") then goto BUILD
if matchre ("%GO","\b(REPAIR)S?\b") then goto REPAIR
if matchre ("%GO","\b(CONSTRUCT)S?\b") then goto CONSTRUCT
if matchre ("%GO","\b(SWAB)S?\b") then goto DISCARD
if matchre ("%GO","\b(PASS)\b") then goto PASS_TURN
goto GAME_LOOP

COL_OFFSET:
# Player 2 doesn't use 1-6, but 8-13... and in reverse order sometimes! (which is then just adding 7)
if $0 = 2 then eval COL_2 element ("%COL_FIX","%COL_2")
else eval COL element ("%COL_FIX","%COL")
return

ECHO_TILES:
var ECHO_TILE_1 %ROW%COL
var ECHO_TILE_2 %ROW_2%COL_2
if %PLAYER = P2 then
    {
    eval ECHO_COL element ("%COL_REVERSE","%COL")
    eval ECHO_TILE_1 replacere ("%ECHO_TILE_1","(\d+)","%ECHO_COL")
    eval ECHO_COL element ("%COL_REVERSE","%COL_2")
    eval ECHO_TILE_2 replacere ("%ECHO_TILE_2","(\d+)","%ECHO_COL")
    }
return

#####################

REPAIR:
if !matchre ("%%K_CARDS","\b(C8|C9)\b") then goto ERROR_INVALID_CARD
if ("%%K_HEALTH" = "100") then goto ERROR_HEALTH_FULL
gosub FIND_REPAIR
if ("%TILE" = "0") then
    {
    if matchre ("%%K_CARDS","\bC9\b") then var TILE 30
    if matchre ("%%K_CARDS","\bC8\b") then var TILE 10
    if ((matchre ("%%K_CARDS","\bC9\b")) && (%%K_HEALTH < 80)) then var TILE 30
    }
math %K_HEALTH add %TILE
if %%K_HEALTH > 100 then var %K_HEALTH 100
if ("%TILE" = "30") then
    {
    gosub DISCARD_ONE C9
    var NEXTLINE %N%K has repaired their ship by 30%!
    goto NEXT_TURN
    }
gosub DISCARD_ONE C8
var NEXTLINE %N%K has repaired their ship by 10%!
goto GAME_LOOP_UPDATE

FIND_REPAIR:
eval PARSE_LIST replacere ("%GO","\s+","|")
eval PARSE_LIST replacere ("%PARSE_LIST","[\-\'\,\.\?\!\#\^\&\*\$\%\@\=\+]+","")
eval MAX count ("%PARSE_LIST","|")
var LOOP 0
var TILE 0

FIND_REPAIR_LOOP:
eval TILE element ("%PARSE_LIST","%LOOP")
if matchre ("%TILE","\b10\b") then return
if matchre ("%TILE","\b30\b") then return
if matchre ("%TILE","\b(1|TEN|Ten|ten)\b") then
    {
    var TILE 10
    return
    }
if matchre ("%TILE","\b(3|THIRTY|Thirty|thirty)\b") then
    {
    var TILE 30
    return
    }
if %LOOP > %MAX then
    {
    # no repair amount specified...
    var TILE 0
    return
    }
math LOOP add 1
goto FIND_REPAIR_LOOP

###################

FIRE:
var FIRING_ALL 0
if !matchre ("%%K_CARDS","\b(C4|C5)\b") then goto ERROR_INVALID_CARD
if ("%%K_ARBALESTS_BACK" = "0") then goto ERROR_NO_ARBALESTS
gosub FIND_TILE 2
if ("%TILE_2" = "INVALID") then
    {
    # No tile mentioned, so it's either "Fire all" or "fire the only one I've got"
    if ((matchre ("%%K_CARDS","\bC4\b")) && (!matchre ("%%K_CARDS","\bC5\b"))) then
        {
        # they have no fire all cards so see how many arbalests they got
        eval MAX count ("%%K_ARBALESTS_BACK","|")
        # they have more than one, so make them pick one!
        if %MAX > 1 then goto ERROR_NO_ARBALEST_TILE_CHOSEN
        eval TILE_2 element ("%%K_ARBALESTS_BACK","1")
        goto FIRE_SINGLE_ARBALEST
        }
    if ((matchre ("%%K_CARDS","\bC4\b")) && (matchre ("%%K_CARDS","\bC5\b"))) then
        {
        #they have both kinds of cards, so see if they specified "all"
        if matchre ("%GO","\bALL\b") then goto FIRE_ALL
        eval MAX count ("%%K_ARBALESTS_BACK","|")
        # but again, force them to confirm if they have more than one, or use a single-fire card for them
        if %MAX > 1 then goto ERROR_NO_ARBALEST_TILE_CHOSEN
        eval TILE_2 element ("%%K_ARBALESTS_BACK","1")
        goto FIRE_SINGLE_ARBALEST
        }
    if matchre ("%%K_CARDS","\bC5\b") then goto FIRE_ALL
    put #echo >Log pink Warships: This text should never display, if it does, tell Eskila what the player just asked for!
    goto ERROR_INVALID_CARD
    }

FIRE_SINGLE_ARBALEST:
var TILE_1 %TILE_2
eval ROW replacere ("%TILE_1","\d+","")
eval COL replacere ("%TILE_1","[A-G]","")
if %K = 2 then
    {
    gosub COL_OFFSET 1
    var TILE_1 %ROW%COL
    }
if ((!matchre ("%%K_ARBALESTS_BACK","%TILE_1")) && (!matchre ("%%K_ARBALESTS_FRONT","%TILE_1"))) then goto ERROR_NO_ARBALEST_ON_TILE
var R1 %N%K fires an arbalest at %ENEMY's ship!
var CHECK %COL
var FIRE_LOOP 2
if %K = 1 then
    {
    if %CHECK = 6 then goto FIRE_ONE
    if %CHECK = 5 then goto FIRE_ONE
    if %CHECK = 4 then
        {
        if matchre ("%1_ARBALESTS_BACK","%ROW5") then goto ERROR_DO_NOT_FIRE
        }
    if %CHECK = 3 then
        {
        if matchre ("%1_ARBALESTS_BACK","%ROW4|%ROW5") then goto ERROR_DO_NOT_FIRE
        }
    if %CHECK = 2 then
        {
        if matchre ("%1_ARBALESTS_BACK","%ROW3|%ROW4|%ROW5") then goto ERROR_DO_NOT_FIRE
        }
    if %CHECK = 1 then
        {
        if matchre ("%1_ARBALESTS_BACK","%ROW2|%ROW3|%ROW4|%ROW5") then goto ERROR_DO_NOT_FIRE
        }
    }
if %K = 2 then
    {
    eval CHECK element ("%COL_FIX","%COL")
    if %CHECK = 8 then goto FIRE_ONE
    if %CHECK = 9 then goto FIRE_ONE
    if ("%CHECK" = "10") then
        {
        if matchre ("%2_ARBALESTS_BACK","%ROW9") then goto ERROR_DO_NOT_FIRE
        }
    if ("%CHECK" = "11") then
        {
        if matchre ("%2_ARBALESTS_BACK","%ROW4|%ROW9") then goto ERROR_DO_NOT_FIRE
        }
    if ("%CHECK" = "12") then
        {
        if matchre ("%2_ARBALESTS_BACK","%ROW11|%ROW10|%ROW9") then goto ERROR_DO_NOT_FIRE
        }
    if ("%CHECK" = "13") then
        {
        if matchre ("%2_ARBALESTS_BACK","%ROW12|%ROW11|%ROW10|%ROW9") then goto ERROR_DO_NOT_FIRE
        }
    }
goto FIRE_ONE

FIRE_ONE:
var LOOP 6
var REAL_LOOP 6
if %K = 1 then var REAL_LOOP 8

FIRE_ONE_LOOP:
var ECHO_TILE_1 %ROW%LOOP
var TILE %ROW%REAL_LOOP
eval CHECK element ("%LINE_%ROW","%REAL_LOOP")
if matchre ("%CHECK","::|Xx") then
    {
    math LOOP subtract 1
    if %K = 1 then math REAL_LOOP add 1
    if %K = 2 then math REAL_LOOP subtract 1
    if %LOOP = 0 then goto DAMAGE_HEALTH
    goto FIRE_ONE_LOOP
    }
if matchre ("%TILE","\b(%%E_ARBALESTS_FRONT)\b") then goto DAMAGE_ARBALEST
if matchre ("%TILE","\b(%%E_BARRICADES)\b") then goto DAMAGE_FORTIFICATION
# should never reach here, but...
if %DEBUG = 1 then put #echo >Log pink Warship Debug: Damage out of bounds on loop %LOOP!
math LOOP subtract 1
if %LOOP <= 0 then
    {
    if %FIRING_ALL = 1 then return
    goto GAME_LOOP
    }
goto FIRE_ONE_LOOP

DAMAGE_ARBALEST:
var DESTROYED 0
var DEBRIS_LEFT 0
var COL %REAL_LOOP
math %E_%TILE_HEALTH subtract 10
if ("%%E_%TILE_HEALTH" = "0") then
    {
    random 1 200
    if %r > %DEBRIS then gosub REPLACE "LINE_%ROW" %COL ::
    else
        {
        var DEBRIS_LEFT 1
        gosub REPLACE "LINE_%ROW" %COL Xx
        }
    eval %E_ARBALESTS_FRONT replacere ("%%E_ARBALESTS_FRONT","\|%TILE","")
    }
if %K = 1 then evalmath COL (%COL + 1)
else evalmath COL (%COL - 1)
var TILE %ROW%COL
math %E_%TILE_HEALTH subtract 10
if ("%%E_%TILE_HEALTH" = "0") then
    {
    var DESTROYED 1
    random 1 200
    if %r > %DEBRIS then gosub REPLACE "LINE_%ROW" %COL ::
    else
        {
        var DEBRIS_LEFT 1
        gosub REPLACE "LINE_%ROW" %COL Xx
        }
    eval %E_ARBALESTS_BACK replacere ("%%E_ARBALESTS_BACK","\|%TILE","")
    }
evalmath COL (%LOOP - 1)
var ECHO_TILE_2 %ROW%COL
var R%FIRE_LOOP %ENEMY's arbalest at %ECHO_TILE_1 and %ECHO_TILE_2 is badly damaged!
if %DESTROYED = 1 then var R%FIRE_LOOP %ENEMY's arbalest at %ECHO_TILE_1 and %ECHO_TILE_2 is destroyed!
if %DEBRIS_LEFT = 1 then var R%FIRE_LOOP %ENEMY's arbalest at %ECHO_TILE_1 and %ECHO_TILE_2 is destroyed, leaving some scrap behind!
if %FIRING_ALL = 1 then return
gosub RECITE_HITS
gosub DISCARD_ONE C4
if %DESTROYED = 0 then var NEXTLINE %N%K has struck a blow to the arbalest at %ECHO_TILE_1 and %ECHO_TILE_2 on %ENEMY's ship!
if %DESTROYED = 1 then var NEXTLINE %N%K has demolished the arbalest at %ECHO_TILE_1 and %ECHO_TILE_2 on %ENEMY's ship!
if %DEBRIS_LEFT = 1 then eval var NEXTLINE %N%K has demolished the arbalest at %ECHO_TILE_1 and %ECHO_TILE_2 on %ENEMY's ship, leaving some scrap behind!
goto GAME_LOOP_UPDATE

DAMAGE_FORTIFICATION:
var DEBRIS_LEFT 0
random 1 200
if %r > %DEBRIS then gosub REPLACE "LINE_%ROW" %REAL_LOOP ::
else
    {
    var DEBRIS_LEFT 1
    gosub REPLACE "LINE_%ROW" %REAL_LOOP Xx
    }
eval %E_BARRICADES replacere ("%%E_BARRICADES","\|%TILE","")
var R%FIRE_LOOP %ENEMY's fortifications at %ECHO_TILE_1 are destroyed!
if %DEBRIS_LEFT = 1 then var R%FIRE_LOOP %ENEMY's fortifications at %ECHO_TILE_1 are destroyed, leaving some scrap behind!
if %FIRING_ALL = 1 then return
gosub RECITE_HITS
gosub DISCARD_ONE C4
var NEXTLINE %N%K has struck down the fortifications at %ECHO_TILE_1 on %ENEMY's ship!
if %DEBRIS_LEFT = 1 then var NEXTLINE %N%K has struck down the fortifications at %ECHO_TILE_1 on %ENEMY's ship, leaving some scrap behind!
goto GAME_LOOP_UPDATE

DAMAGE_HEALTH:
if ("%%E_HEALTH" != "0") then math %E_HEALTH subtract 10
if ("%%E_HEALTH" = "0") then
    {
    var NEXTLINE %N%K has struck the sinking blow to %ENEMY's ship!
    if %FIRING_ALL = 1 then var PLAYER_WON 1
    else
        {
        var R%FIRE_LOOP %ENEMY's ship takes 10 damage and begins to sink!
        goto PLAYER_WON
        gosub RECITE_HITS
        }
    }
if ("%%E_HEALTH" = "0") then var R%FIRE_LOOP The battered husk of %ENEMY's ship is ripped to splinters! Have mercy!
if ("%%E_HEALTH" != "0") then var R%FIRE_LOOP %ENEMY's ship takes 10 damage!
if %FIRING_ALL = 1 then return
gosub RECITE_HITS
gosub DISCARD_ONE C4
var NEXTLINE %N%K has struck a blow to %ENEMY's ship!
goto GAME_LOOP_UPDATE

FIRE_ALL:
var FIRE_LIST 0
var PLAYER_WON 0
var LOOP 2

FIRE_ALL_FIND_LOOP_ROW:
math LOOP add 1
if %LOOP = 10 then goto FIRE_ALL_ARBALESTS_FOUND
eval ROW element ("%ROW_FIX","%LOOP")
var COL 7

FIRE_ALL_FIND_LOOP_COL:
if %K = 1 then
    {
    math COL subtract 1
    if %COL = 0 then goto FIRE_ALL_FIND_LOOP_ROW
    }
if %K = 2 then
    {
    math COL add 1
    if %COL = 14 then goto FIRE_ALL_FIND_LOOP_ROW
    }
var TILE %ROW%COL
if matchre ("%%K_ARBALESTS_BACK","%TILE") then
    {
    var FIRE_LIST %FIRE_LIST|%TILE
    goto FIRE_ALL_FIND_LOOP_ROW
    }
goto FIRE_ALL_FIND_LOOP_COL

FIRE_ALL_ARBALESTS_FOUND:
var FIRE_LOOP 1
eval FIRE_MAX count ("%FIRE_LIST","|")
if %FIRE_MAX = 0 then goto ERROR_NO_ARBALESTS
var FIRING_ALL 1
var NEXTLINE %N%K fires a furious volley from %FIRE_MAX arbalests upon %ENEMY's ship!
if %FIRE_MAX = 1 then var NEXTLINE %N%K desperately fires their only arbalest at %ENEMY's ship!

FIRE_ALL_ARBALESTS_LOOP:
eval FIRE_TILE element ("%FIRE_LIST","%FIRE_LOOP")
eval ROW replacere ("%FIRE_TILE","\d+","")
eval COL replacere ("%FIRE_TILE","[A-G]","")
gosub FIRE_ONE
math FIRE_LOOP add 1
if %FIRE_LOOP > %FIRE_MAX then
    {
    gosub DISCARD_ONE C5
    gosub RECITE_HITS
    if %PLAYER_WON = 1 then goto PLAYER_WON
    goto NEXT_TURN
    }
goto FIRE_ALL_ARBALESTS_LOOP

######################

CONSTRUCT:
if !matchre ("%%K_CARDS","\b(C1)\b") then goto ERROR_INVALID_CARD
gosub FIND_TILE
eval ROW replacere ("%TILE_1","\d+","")
eval COL replacere ("%TILE_1","[A-G]","")
if %K = 2 then gosub COL_OFFSET 1
if (("%K" = "1") && ("%COL" = "6") then goto ERROR_CONSTRUCT_NO_ROOM
if (("%K" = "2") && ("%COL" = "8") then goto ERROR_CONSTRUCT_NO_ROOM
eval CHECK element ("%LINE_%ROW","%COL")
if ("%CHECK" != "::") then goto ERROR_NO_CONSTRUCT_1
if %K = 1 then evalmath COL_2 (%COL + 1)
if %K = 2 then evalmath COL_2 (%COL - 1)
var FRONT %ROW%COL_2
var BACK %ROW%COL
eval CHECK element ("%LINE_%ROW","%COL_2")
if ("%CHECK" != "::") then
    {
    if %K = 1 then evalmath COL_2 (%COL - 1)
    if %K = 2 then evalmath COL_2 (%COL + 1)
    eval CHECK element ("%LINE_%ROW","%COL_2")
    if ("%CHECK" != "::") then goto ERROR_NO_CONSTRUCT_2
    var FRONT %ROW%COL
    var BACK %ROW%COL_2
    eval COL replacere ("%BACK","[A-G]","")
    eval COL_2 replacere ("%FRONT","[A-G]","")
    }
if %PLAYER = P1 then
    {
    gosub REPLACE "LINE_%ROW" %COL "%P1_ARB_1"
    gosub REPLACE "LINE_%ROW" %COL_2 "%P1_ARB_2"
    }
if %PLAYER = P2 then
    {
    gosub REPLACE "LINE_%ROW" %COL "%P2_ARB_1"
    gosub REPLACE "LINE_%ROW" %COL_2 "%P2_ARB_2"
    }
var ROW_2 %ROW
gosub ECHO_TILES
var NEXTLINE %N%K has constructed an arbalest on tiles %ECHO_TILE_1 and %ECHO_TILE_2!
var %K_%FRONT_HEALTH 20
var %K_%BACK_HEALTH 20
var %K_ARBALESTS_FRONT %%K_ARBALESTS_FRONT|%FRONT
var %K_ARBALESTS_BACK %%K_ARBALESTS_BACK|%BACK
gosub DISCARD_ONE C1
goto GAME_LOOP_UPDATE

BUILD:
if !matchre ("%%K_CARDS","\b(C2|C3)\b") then goto ERROR_INVALID_CARD
gosub FIND_TILE
eval ROW replacere ("%TILE_1","\d+","")
eval COL replacere ("%TILE_1","[A-G]","")
eval GO replacere ("%GO","\b%COL\b|\b%ROW\b|\b%ROW%COL\b|\b%COL%ROW\b","XX")
gosub FIND_TILE 2
if %K = 2 then gosub COL_OFFSET 1
eval CHECK element ("%LINE_%ROW","%COL")
if ("%CHECK" != "::") then goto ERROR_NO_BUILD
if !matchre ("%%K_CARDS","\b(C2)\b") then goto BUILD_HEAVY_CHECK
if matchre ("%GO","\bHEAVY\b") then goto BUILD_HEAVY_CHECK
if ("%TILE_2" != "INVALID") then goto BUILD_HEAVY_CHECK
# here if: they have C2 cards, haven't said "Heavy", and Tile_2 *is* INVALID

var TILE_1 %ROW%COL
gosub REPLACE "LINE_%ROW" %COL "%P%K_BAR"
gosub ECHO_TILES
var NEXTLINE %N%K has built fortifications at %ECHO_TILE_1!
var %K_BARRICADES %%K_BARRICADES|%TILE_1
gosub DISCARD_ONE C2
goto GAME_LOOP_UPDATE

BUILD_HEAVY_CHECK:
if ("%TILE_2" = "INVALID") then goto ERROR_BUILD_NEEDS_TWO
if !matchre ("%%K_CARDS","\b(C3)\b") then goto ERROR_NO_HEAVY_CARD

BUILD_TWO:
eval ROW_2 replacere ("%TILE_2","\d+","")
eval COL_2 replacere ("%TILE_2","[A-G]","")
if %K = 2 then gosub COL_OFFSET 2
if ("%ROW_2" = "%ROW") then
    {
    var TMP %COL
    math TMP subtract 1
    if %TMP = %COL_2 then goto BUILD_TWO_TOGETHER
    math TMP add 2
    if %TMP = %COL_2 then goto BUILD_TWO_TOGETHER
    }
if %COL = %COL_2 then
    {
    if ("%ROW" = "A") then var TMP 1
    if ("%ROW" = "B") then var TMP 2
    if ("%ROW" = "C") then var TMP 3
    if ("%ROW" = "D") then var TMP 4
    if ("%ROW" = "E") then var TMP 5
    if ("%ROW" = "F") then var TMP 6
    if ("%ROW" = "G") then var TMP 7
    if ("%ROW_2" = "A") then var TMP_2 1
    if ("%ROW_2" = "B") then var TMP_2 2
    if ("%ROW_2" = "C") then var TMP_2 3
    if ("%ROW_2" = "D") then var TMP_2 4
    if ("%ROW_2" = "E") then var TMP_2 5
    if ("%ROW_2" = "F") then var TMP_2 6
    if ("%ROW_2" = "G") then var TMP_2 7
    math TMP subtract 1
    if %TMP = %TMP_2 then goto BUILD_TWO_TOGETHER
    math TMP add 2
    if %TMP = %TMP_2 then goto BUILD_TWO_TOGETHER
    }
goto ERROR_BUILD_SPACING

BUILD_TWO_TOGETHER:
eval CHECK element ("%LINE_%ROW_2","%COL_2")
if ("%CHECK" != "::") then goto ERROR_NO_BUILD_2
var TILE_1 %ROW%COL
var TILE_2 %ROW_2%COL_2
gosub REPLACE "LINE_%ROW" %COL "%P%K_BAR"
gosub REPLACE "LINE_%ROW_2" %COL_2 "%P%K_BAR"
gosub DISCARD_ONE C3
gosub ECHO_TILES
var NEXTLINE %N%K has built fortifications at %ECHO_TILE_1 and %ECHO_TILE_2!
var %K_BARRICADES %%K_BARRICADES|%TILE_1|%TILE_2
goto NEXT_TURN

FIX:
if !matchre ("%%K_CARDS","\bC7\b") then goto ERROR_INVALID_CARD
# What if the possible tiles to look for are referenced from the weakness list first...?
gosub FIND_TILE
eval ROW replacere ("%TILE_1","\d+","")
eval COL replacere ("%TILE_1","[A-G]","")
if %K = 2 then gosub COL_OFFSET 1
#if ("%PLAYER_WEAKNESS" = "0") then goto ERROR_NO_FIX
#if !matchre ("%PLAYER_WEAKNESS","%TILE_1") then goto ERROR_NO_FIX
# Little bit redundant there...?
eval CHECK element ("%LINE_%ROW","%COL")
if ("%CHECK" != "Xx") then goto ERROR_NO_FIX
eval %K_WEAKNESS replacere ("%%K_WEAKNESS","%TILE_1\||\|%TILE_1","")
gosub REPLACE "LINE_%ROW" %COL "::"
gosub DISCARD_ONE C7
gosub ECHO_TILES
var NEXTLINE %N%K has cleared the scrap off their deck at %TILE_1!
goto GAME_LOOP_UPDATE

FIND_TILE:
var SECOND_TILE 0
if matchre ("$0","2") then var SECOND_TILE 1
eval PARSE_LIST replacere ("%GO","\s+","|")
eval PARSE_LIST replacere ("%PARSE_LIST","[\-\'\,\.\?\!\#\^\&\*\$\%\@\=\+]+","")
eval MAX count ("%PARSE_LIST","|")
var LOOP 0

FIND_TILE_LOOP:
eval TILE element ("%PARSE_LIST","%LOOP")
eval TILE toupper ("%TILE")
if matchre ("%TILE","\b[A-G]-?[1-6]\b") then goto TILE_FOUND
if matchre ("%TILE","\b[1-6]-?[A-G]\b") then goto TILE_FOUND
if matchre ("%TILE","\b[A-G]\b") then
    {
    evalmath TMP_LOOP (%LOOP + 1)
    eval TMP element ("%PARSE_LIST","%TMP_LOOP")
    if matchre ("%TMP","\b[1-6]\b") then
        {
        if %SECOND_TILE = 0 then var TILE_1 %TILE%TMP
        if %SECOND_TILE = 1 then var TILE_2 %TILE%TMP
        return
        }
    }
if matchre ("%TILE","\b[1-6]\b") then
    {
    evalmath TMP_LOOP (%LOOP + 1)
    eval TMP element ("%TILE_LIST","%TMP_LOOP")
    if matchre ("%TMP","\b[A-G]\b") then
        {
        if %SECOND_TILE = 0 then var TILE_1 %TMP%TILE
        if %SECOND_TILE = 1 then var TILE_2 %TMP%TILE
        return
        }
    }
math LOOP add 1
if %LOOP > %MAX then
    {
    if %SECOND_TILE = 1 then
        {
        var TILE_2 INVALID
        return
        }
    goto ERROR_INVALID_TILE
    }
goto FIND_TILE_LOOP

TILE_FOUND:
if %SECOND_TILE = 0 then var TILE_1 %TILE
if %SECOND_TILE = 1 then var TILE_2 %TILE
return

DISCARD:
if !matchre ("%%K_CARDS","\b(C6)\b") then goto ERROR_INVALID_CARD
var ACT :%N%K takes \@' cards and shuffles them back into the deck, then deals out six new ones for %.
if ("%N%K" = "$charactername") then var ACT shuffles %DEALER_SHORT cards back into the deck, then draws out six new ones for %DEALER.
eval %K_CARDS replacere ("%%K_CARDS","C","")
var DECK %DECK|%%K_CARDS
var %K_CARDS 0
gosub SHUFFLE_DECK
gosub GIVE_CARDS %N%K %K 6
math CARDS_PLAYED add 1
var NEXTLINE %N%K has used their last play to draw a new hand.
if %CARDS_PLAYED = 3 then goto NEXT_TURN
goto GAME_LOOP

DISCARD_ONE:
var REMOVE $0
var LOOP 1
eval MAX count ("%%K_CARDS","|")
gosub DISCARD_LOOP
if ("%%K_CARDS" = "0") then
    {
    var ACT :%N%K shuffles all the used cards back into the deck and deals out six new ones for \@.
    if ("%N%K" = "$charactername") then var , having used the last of %DEALER_SHORT cards, shuffles all the used cards back into the deck and draws out six new ones.
    gosub GIVE_CARDS %N%K %K 6
    }
math CARDS_PLAYED add 1
return

DISCARD_LOOP:
eval CARD element ("%%K_CARDS","%LOOP")
if matchre ("\b(%REMOVE)\b","\b%CARD\b") then
    {
    eval CARD replacere ("%CARD","C","")
    var DECK %DECK|%CARD
    gosub REPLACE "%K_CARDS" %LOOP XX
    eval %K_CARDS replacere ("%%K_CARDS","\|XX","")
    return
    }
math LOOP add 1
if %LOOP > %MAX then
    {
    put #echo >Log pink Weird, %N%K didn't have any %REMOVE cards!
    return
    }
goto DISCARD_LOOP

###################

WEAK_BOARDS_P1:
gosub GET_WEAK_BOARDS_VALUES_P1
# make sure that 4 different rows have damaged deck tiles
if matchre ("%LOOP","1|2|3") then
    {
    eval CHECK replacere ("%LINE_%ROW","\).*","")
    if matchre ("%CHECK","x") then goto WEAK_BOARDS_P1
    }
# after that, the last two damaged deck tiles can be on any row. Chaos!
if matchre ("%LOOP","4|5") then
    {
    eval CHECK element ("%LINE_%ROW","%COL")
    if matchre ("%CHECK","x") then goto WEAK_BOARDS_P1
    }
gosub REPLACE "LINE_%ROW" %COL Xx
var 1_WEAKNESS %1_WEAKNESS|%ROW%COL
math LOOP add 1
if %LOOP = 6 then return
goto WEAK_BOARDS_P1

GET_WEAK_BOARDS_VALUES_P1:
random 1 6
var COL %r
random 3 9
eval ROW element ("%ROW_FIX","%r")
return

WEAK_BOARDS_P2:
gosub GET_WEAK_BOARDS_VALUES_P2
if matchre ("%LOOP","1|2|3") then
    {
    eval CHECK replacere ("%LINE_%ROW",".*\(","")
    if matchre ("%CHECK","x") then goto WEAK_BOARDS_P2
    }
if matchre ("%LOOP","4|5") then
    {
    eval CHECK element ("%LINE_%ROW","%COL")
    if matchre ("%CHECK","x") then goto WEAK_BOARDS_P2
    }
gosub REPLACE "LINE_%ROW" %COL Xx
var 2_WEAKNESS %2_WEAKNESS|%ROW%COL
math LOOP add 1
if %LOOP = 6 then return
goto WEAK_BOARDS_P2

GET_WEAK_BOARDS_VALUES_P2:
random 8 13
var COL %r
random 3 9
eval ROW element ("%ROW_FIX","%r")
return

GIVE_CARDS:
var TELL $1
var GIVE $2
var LOOP $3
var CARDS %%GIVE_CARDS
var CARD_OVERDRAW 0
eval MAX count ("%%GIVE_CARDS","|")
if %MAX = 11 then
    {
    # see if they have a "Swab" in their hand already...
    if matchre ("%CARDS","C6") then goto GIVE_CARDS_LOOP
    # if not... give them one.
    var CARDS %CARDS|C6
    var %GIVE_CARDS %C1
    var EXTRA_SWAB 1
    gosub ACT
    goto SORT_CARDS
    }
if %MAX = 12 then
    {
    var CARD_OVERDRAW 1
    goto SORT_CARDS
    }

GIVE_CARDS_LOOP:
eval CARD element ("%DECK","0")
eval DECK replacere ("%DECK","^\d+\|","")
if %CARD = 0 then
    {
    # What will this break?
    gosub SHUFFLE_DECK
    goto GIVE_CARDS_LOOP
    }
var CARDS %CARDS|C%CARD
math LOOP subtract 1
if %LOOP = 0 then
    {
    var %GIVE_CARDS %CARDS
    gosub ACT
    goto SORT_CARDS
    }
goto GIVE_CARDS_LOOP

REMIND:
eval PARSE_LIST replacere ("%GO","\s+","|")
eval TELL element ("%PARSE_LIST","1")
eval TELL tolower (%TELL)
eval CAPITAL replacere ("%TELL","(?!^[a-z])(.*)","")
eval TELL replacere ("%TELL","(^[a-z])","")
eval CAPITAL toupper (%CAPITAL)
var TELL %CAPITAL%TELL
if %TELL = %N1 then gosub TELL_CARDS 1
else gosub TELL_CARDS 2
goto GAME_LOOP

TELL_CARDS:
if $1 = 1 then var CARDS %1_CARDS
else var CARDS %2_CARDS

SORT_CARDS:
eval MAX count ("%CARDS","|")
var WHISPER_CARDS 0
var LOOP 1

SORT_CARDS_LOOP:
eval CARD element ("%CARDS","%LOOP")
var WHISPER_CARDS %WHISPER_CARDS -- [%%CARD]
math LOOP add 1
if %LOOP > %MAX then goto WHISPER_CARDS
goto SORT_CARDS_LOOP

WHISPER_CARDS:
eval WHISPER_CARDS replacere ("%WHISPER_CARDS","^0\s\-\-\s","")
if matchre ("%TELL","$charactername") then
    {
    put #echo
    put #echo aqua Your cards are... %WHISPER_CARDS
    put #echo aqua mono " * {PASS TURN:#parse PASS} * {RULES:#parse RULES} * {CARD TYPES:#parse TYPES} * {RECITE BOARD:#parse BOARD} * "
    if %CARD_OVERDRAW = 1 then put #echo yellow mono You have the maximum amoutn of cards for now.
    put #echo
    return
    }
var WHISPER %TELL Your cards are... %WHISPER_CARDS -- You can also PASS your turn, or ask me about the RULES, BOARD, or card TYPES.
if %CARD_OVERDRAW = 1 then var WHISPER %WHISPER You have the maximum amount of cards for now.
if %FAIR_DEALER = 1 then
    {
    put #gag {^%scriptname.*}
	put #gag {^You whisper to %TELL}
	gosub WHISPER
    put #ungag {^%scriptname.*}
	put #ungag {^You whisper to %TELL}
    return
    }

WHISPER:
pause 0.2
put whisper %WHISPER
matchre WHISPER %RETRY
matchre RETURN ^You whisper
matchre WHISPER_WAIT ^Whisper what to who
matchwait

WHISPER_WAIT:
pause 0.1
waiteval ("$roomplayers")
goto WHISPER

ACT:
pause
put act %ACT
matchre ACT %RETRY
matchre RETURN ^\($charactername|^\(You
matchre ACT_WAIT ^But there isn't a
matchwait

ACT_WAIT:
pause 0.1
waiteval ("$roomplayers")
goto ACT

RECITE_GOTO:
gosub RECITE
goto GAME_LOOP

RULES_GOTO:
gosub RULES
goto GAME_LOOP

CARD_RULES_GOTO:
gosub CARD_RULES
goto GAME_LOOP

RULES:
var R1 The game is called Warships! But We Can't Board The Enemy And All We Have Are Siege Arbalests, A Game of Chance and Strategy
var R2 How to Play! (1/3)
var R3
var R4 %N1 has control of the left side of the board, while %N2 has control of the right. Each ship is 6x7 tiles.
var R5 On their first turn, each player draws 6 cards. For every turn or card played, 1 more card is drawn.
var R6 Turns end after 3 cards are played or when cards marked (End Turn) are played.
var RECITE %R1\;   \;%R3\;%R4\;%R5\;%R6
gosub DO_RECITE
pause 10
var R1 How to Play! (2/3)
var R2
var R3 Each ship is randomly given 6 debris piles (Xx), blocking where you can build. Plan around them, or clean them away!
var R4 Health: Fortifications are destroyed in 1 hit. Arbalests will are destroyed in 2 hits. Each ship can take 10 hits.
var R5 Attacking: Each arbalest does 10 damage to whatever is in its path, but will not fire through multiple objects.
var R6 Arbalests can fire over their own fortifications, but will not fire from behind their fellow arbalests.
var RECITE %R1\;  \;%R3\;%R4\;%R5\;%R6
gosub DO_RECITE
pause 10
var R1 How to Play! (3/3)
var R2
var R3 Players take actions by speaking or ACTing certain keywords. To learn the keywords, ask me about card TYPES.
var R4 You can also ask me about the RULES to hear this again, or about the BOARD to see the game again.
var R5 Lastly, you can just TAP me or ask me to REMIND you of your cards, or say "PASS" to skip your turn.
var RECITE %R1\;   \;%R3\;%R4\;%R5
goto DO_RECITE

CARD_RULES:
var R1 The card types! (1/2) - Building, Construction, and Debris
var R2
var R3 * Build Fortification - Build fortifications on a single tile - Keywords: "Build C5"!
var R4 * Build Heavy Fortification - Build fortifications on two adjacent tiles, in a row or column - Keywords: "Build C5 C6" or "Build C5 D5"!
var R5 * Construct Arbalest - Put an arbalest on two tiles in a row - Keywords: "Construct C5"!
var R6 * Clean Debris - Clear some of the scrap off your ship's deck - Keywords: "Clean C5"!
var RECITE %R1\;  \;%R3\;%R4\;%R5\;%R6
gosub DO_RECITE
pause 10
var R1 The card types! (2/2) - Repairing, Firing, and Discarding Cards
var R2
var R3 * Repair Ship - Restore your ship's health by the card's set amount - Keywords: "Repair 10" or "Repair 30"!
var R4 * Fire Arbalest - Choose a single arbalest to fire - Keyword: "Fire C5"!
var R5 * Fire All Arbalests - Fire all your arbalests in play - Keyword: "Fire" or "Fire all"!
var R6 * Swab the Deck - Discard all cards and draw a new hand - Keywords: "Swab"!
var RECITE %R1\;  \;%R3\;%R4\;%R5\;%R6
goto DO_RECITE

RECITE_HITS:
var RECITE %NEXTLINE\;%R1
if %FIRE_MAX = 2 then var RECITE %NEXTLINE\;\;%R1\;%R2
if %FIRE_MAX = 3 then var RECITE %NEXTLINE\;\;%R1\;%R2\;%R3
if %FIRE_MAX = 4 then var RECITE %NEXTLINE\;\;%R1\;%R2\;%R3\;%R4
if %FIRE_MAX = 5 then var RECITE %NEXTLINE\;\;%R1\;%R2\;%R3\;%R4\;%R5
if %FIRE_MAX = 6 then var RECITE %NEXTLINE\;\;%R1\;%R2\;%R3\;%R4\;%R5\;%R6
if %FIRE_MAX = 7 then var RECITE %NEXTLINE\;\;%R1\;%R2\;%R3\;%R4\;%R5\;%R6\;%R7
if %FIRING_ALL = 0 then var RECITE %R1\;\;%R2
goto DO_RECITE

RECITE:
eval R1 replacere ("%LINE_1","\|","")
eval MAX length ("%1_HEALTH")
if %MAX = 2 then var 1_HEALTH Z%1_HEALTH
eval MAX length ("%2_HEALTH")
if %MAX = 2 then var 2_HEALTH Z%2_HEALTH
var R2 * 1: 2: 3: 4: 5: 6: * (%1_HEALTH %) --- (%2_HEALTH %) * 6: 5: 4: 3: 2: 1: *
eval R2 replacere ("%R2","Z"," ")
eval 1_HEALTH replacere ("%1_HEALTH","^Z","")
eval 2_HEALTH replacere ("%2_HEALTH","^Z","")
gosub SILLY_THING A 3
gosub SILLY_THING B 4
gosub SILLY_THING C 5
gosub SILLY_THING D 6
gosub SILLY_THING E 7
gosub SILLY_THING F 8
gosub SILLY_THING G 9
eval R3 replacere ("%R3","\|"," ")
eval R4 replacere ("%R4","\|"," ")
eval R5 replacere ("%R5","\|"," ")
eval R6 replacere ("%R6","\|"," ")
eval R7 replacere ("%R7","\|"," ")
eval R8 replacere ("%R8","\|"," ")
eval R9 replacere ("%R9","\|"," ")
var RECITE %R1\;%R2\;%R3\;%R4\;%R5\;%R6\;%R7\;%R8\;%R9
if ("%WINDOW" != "0") then
    {
    put #window show %WINDOW
    put #clear %WINDOW
    put #echo >%WINDOW #6edafc mono "%R1"
    put #echo >%WINDOW #60d4fc mono "%R2"
    put #echo >%WINDOW #52cffc mono "%R3"
    put #echo >%WINDOW #42c9fc mono "%R4"
    put #echo >%WINDOW #30c3fc mono "%R5"
    put #echo >%WINDOW #14bdfc mono "%R6"
    put #echo >%WINDOW #00b7fc mono "%R7"
    put #echo >%WINDOW #00b1fc mono "%R8"
    put #echo >%WINDOW #00abfc mono "%R9"
    put #echo >%WINDOW #00a4fb mono " * * * * {PASS TURN:#parse PASS} * {RULES:#parse RULES} * {CARD TYPES:#parse TYPES} * {RECITE BOARD:#parse BOARD} * * * * "
    gosub STUPID_THING
    }

DO_RECITE:
pause 0.5
put recite %RECITE
matchre DO_RECITE %RETRY
matchre RETURN ^You recite
matchwait

SILLY_THING:
var ROW $1
var MAX $2
var TMP_LINE %LINE_%ROW
var LOOP 1
var DRAW 0

SILLY_THING_LOOP:
if %LOOP > 13 then
    {
    var R%MAX %TMP_LINE
    return
    }
var TILE %ROW%LOOP
if ((matchre ("%1_ARBALESTS_BACK","\b%TILE\b")) && (%LOOP < 7)) then
    {
    evalmath TMP_LOOP (%LOOP - %DRAW)
    if %1_%TILE_HEALTH = 10 then gosub REPLACE TMP_LINE %TMP_LOOP %P1_ARB_1+%P1_ARB_2
    if %1_%TILE_HEALTH = 20 then gosub REPLACE TMP_LINE %TMP_LOOP %P1_ARB_1#%P1_ARB_2
    evalmath TMP_LOOP (%LOOP + 1 - %DRAW)
    gosub REPLACE TMP_LINE %TMP_LOOP delete
    eval TMP_LINE replacere ("%TMP_LINE","\|delete","")
    math DRAW add 1
    math LOOP add 1
    }
if ((matchre ("%2_ARBALESTS_FRONT","\b%TILE\b")) && (%LOOP > 7)) then
    {
    evalmath TMP_LOOP (%LOOP - %DRAW)
    if %2_%TILE_HEALTH = 10 then gosub REPLACE TMP_LINE %TMP_LOOP %P2_ARB_2+%P2_ARB_1
    if %2_%TILE_HEALTH = 20 then gosub REPLACE TMP_LINE %TMP_LOOP %P2_ARB_2#%P2_ARB_1
    evalmath TMP_LOOP (%LOOP + 1 - %DRAW)
    gosub REPLACE TMP_LINE %TMP_LOOP delete
    eval TMP_LINE replacere ("%TMP_LINE","\|delete","")
    math DRAW add 1
    math LOOP add 1
    }
math LOOP add 1
goto SILLY_THING_LOOP    

STUPID_THING:
var PIPS * * * * * * *
var PIPS_DIV ----------
var REMIND_LINKS Remind %N1 Cards * Remind %N2 Cards
eval MAX length ("%REMIND_LINKS")
evalmath SIZE (63 - %MAX)
if matchre ("%SIZE","-") then var SIZE 0
evalmath SIZE floor (%SIZE / 2)
if matchre ("%SIZE","(2|4|6|8|10)$") then
    {
    math SIZE subtract 1
    }
eval ECHO_PIPS substring ("%PIPS",0,%SIZE)
eval MAX length ("%ECHO_PIPS %REMIND_LINKS %ECHO_PIPS")
evalmath MAX (64 - %MAX)
if matchre ("%MAX","\b0\b|\-") then
    {
    math SIZE subtract 2
    eval ECHO_PIPS substring ("%PIPS",0,%SIZE)
    if %MAX = 0 then var MAX 4
    else var MAX 3
    }
eval DIV substring ("%PIPS_DIV",0,%MAX)
put #echo >%WINDOW #009ef7 mono "%ECHO_PIPS {Remind %N1 Cards:#parse REMIND %N1} %DIV {Remind %N2 Cards:#parse REMIND %N2} %ECHO_PIPS"
return

PLAYER_WON:
gosub RECITE
pause 2
put say Woohoo, %N%K sank %ENEMY's ship. Time to nap."
put #echo
exit

ERROR_NO_CONSTRUCT_1:
gosub ECHO_TILES
var DEALER_ERROR Silly, tile %ECHO_TILE_1 can't be constructed upon!
var PLAYER_ERROR An arbalest can't be placed on tile %ECHO_TILE_1 as it's already occupied! Would you like to choose another?
goto DISPLAY_ERROR

ERROR_NO_CONSTRUCT_2:
gosub ECHO_TILES
var DEALER_ERROR Silly, an arbalest needs more than one tile to be constructed on!
var PLAYER_ERROR An arbalest can't be placed on tile %ECHO_TILE_1 as the tiles near it are already occupied! Would you like to choose another?
goto DISPLAY_ERROR

ERROR_CONSTRUCT_NO_ROOM:
gosub ECHO_TILES
var DEALER_ERROR Silly, an arbalest needs more room past tile %ECHO_TILE_1!
var PLAYER_ERROR An arbalest can't be placed on tile %ECHO_TILE_1 as there's not enough space in front! It needs start in column 5 or less. Would you like to choose another?
goto DISPLAY_ERROR

ERROR_HEALTH_FULL:
gosub ECHO_TILES
var DEALER_ERROR Silly, there's no need to repair your ship yet.
var PLAYER_ERROR Your ship is as healthy as can be! There's no need to repair it right now.
goto DISPLAY_ERROR

ERROR_NO_ARBALESTS:
gosub ECHO_TILES
var DEALER_ERROR Silly, you have no arbalests to fire!
var PLAYER_ERROR Sorry, you don't have any arbalests to fire! Would you like to play a different card, or PASS?
goto DISPLAY_ERROR

ERROR_NO_ARBALEST_TILE_CHOSEN:
gosub ECHO_TILES
var DEALER_ERROR Silly, specify which arbalest to fire!
var PLAYER_ERROR Oops! You didn't specify which arbalest to fire, please choose which one, or play another card.
goto DISPLAY_ERROR

ERROR_NO_ARBALEST_ON_TILE:
gosub ECHO_TILES
var DEALER_ERROR Silly, there's no arbalest to fire on tile %ECHO_TILE_1!
var PLAYER_ERROR Tile %ECHO_TILE_1 doesn't have an arbalest on it to fire. Would you like to choose another?
goto DISPLAY_ERROR

ERROR_DO_NOT_FIRE:
gosub ECHO_TILES
var DEALER_ERROR Silly, you would be shooting your own crew with the arbalest on tile %ECHO_TILE_1!
var PLAYER_ERROR Tile %ECHO_TILE_1 has another arbalest in front of it! Your crew would mutiny if you shot them in back... Would you like to choose another?
goto DISPLAY_ERROR

ERROR_NO_BUILD:
gosub ECHO_TILES
var DEALER_ERROR Silly, tile %ECHO_TILE_1 can't be build upon!
var PLAYER_ERROR Fortifications can't be placed on tile %ECHO_TILE_1 as it's already occupied! Would you like to choose another?
goto DISPLAY_ERROR

ERROR_NO_BUILD_2:
gosub ECHO_TILES
var DEALER_ERROR Silly, while %ECHO_TILE_1 is okay, %ECHO_TILE_2 can't be build upon!
var PLAYER_ERROR Oops! %ECHO_TILE_1 is okay, but fortifications can't be placed on tile %ECHO_TILE_2 as it's already occupied! Would you like to choose another?
goto DISPLAY_ERROR

ERROR_NO_HEAVY_CARD:
gosub ECHO_TILES
var DEALER_ERROR Silly, you said build on two tiles, but have no heavy fortification cards!
var PLAYER_ERROR Oops! You mentioned two tiles, but you have no heavy fortification cards. Please choose just one of the tiles if you wish to build, for now.
goto DISPLAY_ERROR

ERROR_BUILD_NEEDS_TWO:
gosub ECHO_TILES
var DEALER_ERROR Silly, for a heavy fortification you need to specify both tiles!
var PLAYER_ERROR Oops! You need to specify both tiles to build a heavy fortification on. Remember, they must be adjacent tiles.
goto DISPLAY_ERROR

ERROR_BUILD_SPACING:
gosub ECHO_TILES
var DEALER_ERROR Silly, while %ECHO_TILE_1 and %ECHO_TILE_2 need to be beside each other!
var PLAYER_ERROR Oops! The tiles of a heavy fortification need to be beside each other. %ECHO_TILE_1 and %ECHO_TILE_2 are not beside each other. Would you like to choose another?
goto DISPLAY_ERROR

ERROR_NO_FIX:
gosub ECHO_TILES
var DEALER_ERROR Silly, tile %ECHO_TILE_1 doesn't need fixing!
var PLAYER_ERROR Oops! Tile %ECHO_TILE_1 doesn't need fixing! Would you like to choose another?
goto DISPLAY_ERROR

ERROR_INVALID_CARD:
if ("%N%K" = "$charactername") then
    {
    gosub TELL_CARDS %K
    goto GAME_LOOP
    }
var PLAYER_ERROR Sorry, you can't do that, you don't have a valid card. TAP me or ask me to REMIND you of your cards if you need.
goto DISPLAY_ERROR

ERROR_INVALID_TILE:
var DEALER_ERROR Silly, that's not a valid tile!
var PLAYER_ERROR Sorry, I could not find the tile coordinates. Tiles range from row A to G, and column 1 through 6. Please try again!

DISPLAY_ERROR:
if ("%N%K" = "$charactername") then
    {
    put #echo
    put #echo pink %DEALER_ERROR
    put #echo
    goto GAME_LOOP
    }
var WHISPER %N%K %PLAYER_ERROR
gosub WHISPER
goto GAME_LOOP

RETURN:
return

REPLACE:
var REPLACE_ARRAY $1
var REPLACE_INDEX $2
var REPLACE_VALUE $3
eval %REPLACE_ARRAY replacere("%%REPLACE_ARRAY","^(?<First>(?:[^|]*\|){%REPLACE_INDEX})[^|]*(?<Last>\|.*)?","${First}%REPLACE_VALUE${Last}")
return
