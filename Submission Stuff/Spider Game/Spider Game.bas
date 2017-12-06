 rem   SPIDER GAME
 rem
 rem   Authors:
 rem    Programmer --> Ethan Wilson
 rem    Designer ----> Evan Brook
 rem    Producer ----> DJ Baker
 rem
 rem In a future where everyone was forced to retreat underground
 rem after nuclear war ravaged the surface, a new dominant race emerged:
 rem giant, man-eating spiders. One player is the spider, and they are trying
 rem  to get their next meal. The other player is the human, who is trying to
 rem escape from the spider?s lair and keep from becoming its next meal.
 rem Unfortunately for the human, the spider?s home is confusing and they
 rem will have to find and hit the switch to open up an escape route to
 rem leave the maze. Unfortunately for the spider, it?s slow.
 rem
 rem The spider is Player0
 rem The human is Player1
 rem To start the game, press Player0's fire button
 rem
 rem The Human's objective is to find the button located in the middle of
 rem the maze, and escape through the pathway that opens up.
 rem
 rem The Spider's objective is to catch the human and eat them.
 rem
 rem There are five levels.  The game starts in the middle level.  One player
 rem must continuously win levels until GAME OVER is reached.  It's kind of
 rem like tug-of-war in the sense that you must be winning by a certain amount
 rem in order to win the entire game.

init

 rem MONSTER SPRITE
 player0:
 %10100101
 %10100101
 %01011010
 %00111100
 %00100100
 %01011010
 %11000011
end

 rem HUMAN SPRITE
 player1:
 %01100110
 %00100100
 %00011000
 %00011000
 %01111110
 %01001010
 %10011010
end

 rem POSITIONS
 rem x,y --> MONSTER COORDINATES
 rem v,z --> HUMAN  COORDINATES

 rem VARIABLES USED TO STORE DIRECTIONAL INPUTS FOR COLLISION PREVENTION
 rem a --> left
 rem d --> right
 rem s --> down
 rem w --> up
 a = 0 : d = 0 : s = 0 : w = 0

 rem GAME STATES (c)
 rem -1 -> title screen
 rem 0 --> game over
 rem 1 --> set up monster level 2
 rem 2 --> set up monster level 1
 rem 3 --> set up middle level
 rem 4 --> set up human level 1
 rem 5 --> set up human level 2
 rem 6 --> game over
 rem 101 --> level -2 ongoing
 rem 102 --> level -1 ongoing
 rem 103 --> level 0 ongoing
 rem 104 --> level 1 ongoing
 rem 105 --> level 2 ongoing
 rem ...
 c = -1

 rem STORES WHETHER BUTTON HAS BEEN PRESSED BY PLAYER (g)
 rem 0 --> not pressed yet
 rem 1 --> pressed, wall opens up
 g = 0

 rem THIS MANIPULATES BALL DIMENSIONS
 CTRLPF = $21
 ballheight = 4

mainloop
 rem SETS UP THE LEVEL
 if c = 1 then gosub monsterlevel2
 if c = 2 then gosub monsterlevel1
 if c = 3 then gosub middlelevel
 if c = 4 then gosub humanlevel1
 if c = 5 then gosub humanlevel2

 drawscreen
 rem THE CHARACTERS TURNED INVISIBLE WITHOUT THIS DUPLICATE
 COLUP0 = 1 : COLUP1 = 39
 drawscreen

 rem USING GOTO MAKES THESE SHOW A STATIC SCREEN (unable to move characters)
 if c = -1 then goto title
 if c = 0 then goto gameover

 rem POSITION UPDATE
 player0x = x : player0y = y : player1x = v : player1y = z

 rem COLORING CHARACTERS
 COLUP0 = 1 : COLUP1 = 39

 rem BUTTON PRESS, OPEN WALL
 if collision(player1, ball) then gosub buttonpress

 rem HUMAN DIES, GO BACK A LEVEL
 if collision(player0, player1) && c = 105 then c = 4
 if collision(player0, player1) && c = 104 then c = 3
 if collision(player0, player1) && c = 103 then c = 2
 if collision(player0, player1) && c = 102 then c = 1
 if collision(player0, player1) && c = 101 then c = 0



 rem PREVENTS PLAYERS FROM GOING THROUGH WALLS
 if collision(player0, playfield) then gosub collision0
 if collision(player1, playfield) && !collision(player0,playfield) then gosub collision1

 rem RESET DIRECTION INDICATORS FOR NEXTITERATION
 a = 0 : d = 0 : s = 0 : w = 0

 rem CHECK TO SEE IF PLAYER HAS BROKEN OUT OF THE MAZE
 rem playerx = 140 --> right bound
 rem playerx = ??? --> left bound
 rem playery = ??? --> upper bound
 rem playery = ??? --> lower bound

 rem PLAYER BREAKS OUT OF MAZE TO NEXT LEVEL
 if player1x > 140 && c = 101 then c = 2
 if player1x > 140 && c = 102 then c = 3
 if player1x > 140 && c = 103 then c = 4
 if player1x > 140 && c = 104 then c = 5
 if player1x > 140 && c = 105 then c = 0

 rem MOVE CHARACTERS AND LOG INPUTS
 rem MONSTER
 if joy0left  then a = 1 : x = x - 1
 if joy0right then d = 1 : x = x + 1
 if joy0up    then w = 1 : y = y - 1
 if joy0down  then s = 1 : y = y + 1
 rem HUMAN
 if joy1left  then a = a + 2 : v = v - 2
 if joy1right then d = d + 2 : v = v + 2
 if joy1up    then w = w + 2 : z = z - 2
 if joy1down  then s = s + 2 : z = z + 2
 rem POSITION UPDATE
 player0x = x : player0y = y : player1x = v : player1y = z

 goto mainloop


 rem COLLISION DETECTION
 rem OPTIONS for ADSW ARE:
  rem 0 --> no collision
  rem 1 --> just MONSTER collided
  rem 2 --> just human collided
  rem 3 --> both collided
collision0
 rem MONSTER COLLISION
 if a = 1 || a = 3 then x = x + 1
 if d = 1 || d = 3 then x = x - 1
 if w = 1 || w = 3 then y = y + 1
 if s = 1 || s = 3 then y = y - 1
 player0x = x : player0y = y
 rem CHECK IF HUMAN COLLIDED TOO
 if collision(player1, playfield) then goto collision1
 return

collision1
 rem FIX HUMAN (MONSTER is already fixed)
 if a = 2 || a = 3 then v = v + 2
 if d = 2 || d = 3 then v = v - 2
 if w = 2 || w = 3 then z = z + 2
 if s = 2 || s = 3 then z = z - 2
 player1x = v : player1y = z
 return
 rem END OF COLLISION DETECTION

buttonpress
 g = 1
 rem WALL to REMOVE WILL CORRESPOND to THE LEVEL WE ARE IN
 if c = 101 then pfpixel 31 8 off : pfpixel 31 7 off
 if c = 102 then pfpixel 31 5 off : pfpixel 31 6 off : pfpixel 31 7 off
 if c = 103 then pfpixel 31 8 off : pfpixel 31 7 off : pfpixel 31 6 off
 if c = 104 then pfpixel 31 7 off : pfpixel 31 8 off
 if c = 105 then pfpixel 31 9 off : pfpixel 31 8 off
 rem REMOVE BUTTON
 ballx = 0 : bally = 0
 return


 rem GAME STATES AND THEIR UPDATES to CONSTANTS/VARIABLES
 rem PLAYFIELD dimensions (32 x 11)
 rem PLAYERS take up ~1 unit of the playfield
title
 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  X..............................X
  X..XXX..XXX..XXX.XX...XXX.XX...X
  X.X...X.X..X..X..X.X..X...X.X..X
  X.X.....X..X..X..X..X.X...X..X.X
  X..XXX..X..X..X..X..X.XX..X.X..X
  X.....X.XXX...X..X..X.X...XX...X
  X.X...X.X.....X..X.X..X...X.X..X
  X..XXX..X....XXX.XX...XXX.X..X.X
  X..............................X
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 rem RESET EVERYTHING
 x = 0 : y = 0 : v = 0 : z = 254
 ballx = 0 : bally = 0
 g = 0
 COLUPF = 15 : COLUBK = 0 : scorecolor = 0
 rem PRESSING SPACEBAR GOES to LEVEL 1
 if joy0fire then c = 3
 goto mainloop

monsterlevel2
 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  X.....................X.....X..X
  X..XXX...X..XXXX......X..X..X..X
  X.....X...........XX.....X..X..X
  X..X..XXX..X..........X..X.....X
  X..X.......X..........X.....XXXX
  X..X..XXX..X......XX.....X..X..X
  X.....X.......X.......X..X.....X
  X..XXX...X.......XXX..X..X..X..X
  X...........XXX................X
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 rem UPDATE C TO IN-LEVEL STATE
 c = 101
 rem PLACE THE BUTTON
 ballx = 76 : bally = 45
 rem PLACE THE CHARACTERS
 v = 21 : z = 15
 player1x = v : player1y = z
 x = 133 : y = 15
 player0x = x : player0y = y
 rem BUTTON NOT PRESSED
 g = 0
 rem COLORS
 COLUPF = 64 : COLUBK = 68 : scorecolor = 68
 return

monsterlevel1
 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  X....X......................X..X
  XXX.....XXXX..XX..XX..XXXX..X..X
  X....X..X.............X........X
  X..XXX..X..XX.....XX..X..XXXXXXX
  X..X........X.....X............X
  X..X..XXXX..X.....X..XX..XXXX..X
  X........X........X...X.....X..X
  X..XXXX..X..XXX..XXX..X..X..X..X
  X..............................X
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 rem UPDATE C TO IN-LEVEL STATE
 c = 102
 rem PLACE THE BUTTON
 ballx = 76 : bally = 45
 rem PLACE THE CHARACTERS
 v = 21 : z = 15
 player1x = v : player1y = z
 x = 133 : y = 15
 player0x = x : player0y = y
 rem BUTTON NOT PRESSED
 g = 0
 rem COLORS
 COLUPF = 154 : COLUBK = 158 : scorecolor = 158
 return

middlelevel
 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  X..X......X....................X
  X.....XX......XXX....XXXXXXX...X
  X.....XX.......X......X........X
  X..XXX.....X.......X..X..X...XXX
  X....X.....X.......X.....X.....X
  XXX..X..X..X.......X.....XXX...X
  X.......X.....XXX.....X..X.....X
  X..XXXXXXXX....X......X..X.....X
  X..................X........X..X
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 rem UPDATE C TO IN-LEVEL STATE
 c = 103
 rem PLACE THE BUTTON
 ballx = 76 : bally = 45
 rem PLACE THE CHARACTERS
 v = 21 : z = 15
 player1x = v : player1y = z
 x = 133 : y = 15
 player0x = x : player0y = y
 rem BUTTON NOT PRESSED
 g = 0
 rem COLORS
 COLUPF = 4 : COLUBK = 8 : scorecolor = 8
 return

humanlevel1
 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  X..X....X.............X........X
  X..X....X..XXX...XXX..X........X
  X..X....X.............X.....X..X
  X.....X....XXX...XXX.....X.....X
  X.....X....X.............X.....X
  X.....X....XXX...XXX.....X.....X
  X..X....X.............X.....X..X
  X..........XXX...XXX........X..X
  X..............................X
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 rem UPDATE C TO IN-LEVEL STATE
 c = 104
 rem PLACE THE BUTTON
 ballx = 78: bally = 45
 rem PLACE THE CHARACTERS
 v = 21 : z = 15
 player1x = v : player1y = z
 x = 133 : y = 15
 player0x = x : player0y = y
 rem BUTTON NOT PRESSED
 g = 0
 rem COLORS
 COLUPF = 24 : COLUBK = 28 : scorecolor = 28
 return

humanlevel2
 playfield:
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  X..............................X
  X..XXXXXX..XXXXXX..XXXXX..XXX..X
  X..X.......X................X..X
  X..X.......X...........X....X..X
  X..X.......X...........X.......X
  X..X.......X...........X....X..X
  X......................X....X..X
  X..XXXXXX..XXXXXX..XXXXX...XX..X
  X..............................X
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 rem UPDATE C TO IN-LEVEL STATE
 c = 105
 rem PLACE THE BUTTON
 ballx = 86: bally = 45
 rem PLACE THE CHARACTERS
 v = 21 : z = 15
 player1x = v : player1y = z
 x = 133 : y = 15
 player0x = x : player0y = y
 rem BUTTON NOT PRESSED
 g = 0
 rem COLORS
 COLUPF = 104 : COLUBK = 108 : scorecolor = 108
 return

gameover
 playfield:
  ..XXXX.....X....XX....XX..XXXX..
  .X....X...X.X...X.X..X.X..X.....
  .X.......X...X..X.X..X.X..XXX...
  .XX..XX..XXXXX..X..XX..X..X.....
  ..XXX.X..X...X..X..XX..X..XXXX..
  ................................
  ..XXXX...X.....X..XXXXX..XXXX...
  .X....X..X.....X..X......X...X..
  .X....X...X...X...XXXX...XXXX..
  .X....X...X...X...X......X..XX..
  ..XXXX.....XXX....XXXXX..X...X..
end
 rem MOVE PLAYERS off SCREEN
 player0x = 0 : player0y = 0 : player1x = 0 : player1y = 100
 rem REMOVE THE BALL
 ballx = 0 : bally = 200
 rem PRESSING SPACEBAR PUTS US BACK AT THE START
 if !joy0fire && g = 99 then c = -1
 if joy0fire then g = 99
 goto mainloop



