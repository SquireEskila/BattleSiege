HOW TO PLAY:
* Run battle.cmd in Genie (if you already have a script named battle.cmd you can rename it to battlesiege.cmd or whatever you like)
* Resize the window that pops up so that its height is double what you see of the blank playing board.
* For first time setup, right click the BattleSiege! window and close it, then save your layout. This should keep the window in the same position next time the script opens it.
* Resizing the window will cause links to break, so run the script again to refresh it type #parse REDRAW

* Begin placing your pieces by first selecting the tile, and if the piece can be rotated, an orientation!
* Once all five pieces are set, you place the MANA TRAP piece. This is a special piece that, when your opponent hits it, will reveal 5 tiles of THEIR board to you.
* When the trap is set, you can now select an opponent from the players in the same room. If the person you want to play with is not there, refresh the list.
* If you're playing in a home and they do not show up, leave and re-enter the home.

* Any time before selecting an opponent, you can save your playing field to a global variable $BattleSiege_Preset
* Any time after selecting an opponent, you can save your game against them to resume later.
* Clicking Load Vs Game will attempt to load an in-progress game, giving you an option to load a game against any other player in the room.
  (Saving and loading a game only saves and loads YOUR version of events! It will not load game data for your opponent, they will need to save/load to sync with you.)

* With an opponent now selected, you can begin playing! The script is set to recognize most forms of speech.
* It does not currently register whispers, gweths, reciting, singing, chanting, etc. Only say, ask, exlaim, yell, belt out... and companion slates (not fancy ones)!
* If a valid move is detected when your opponent talks the game will auto-whisper the result of their strike and update both playing fields for both players.
* A valid move is a number and a letter within the playing field's boundaries, in either order: E4 or 4E will both trigger.
  
RULES OF THE GAME:
It's pretty much just like Battleship!
Each player takes a turn calling out their moves. The script is not set up to enforce a turn order.
When a player's five main pieces are taken out, the game is over! The mana trap tile is not needed to be found to finish a game.
