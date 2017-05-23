# Synthein

Synthein (working title) is a game about blowing up space ships and using their parts to make your space ship bigger and better.

## Features

*  You can build onto your ship.
*  Enemies spawn at random.
*  AI allies can follow you and attack nearby enemies.

### Planned Features [![Stories in Ready](https://badge.waffle.io/synthein/synthein.png?label=ready&title=Ready)](http://waffle.io/synthein/synthein)

*  AI allies that you can give orders to (follow, guard, patrol)
*  a customizable automated base
*  storable ship configurations
*  an open world with randomly generated things to encounter and explore

![screenshot](http://i.imgur.com/b2QnY5A.png)

## Running

Synthein is developed using the LÖVE framework. To run the game:

First, download and install LÖVE from [love2d.org](love2d.org).

Next, on **UNIX-like** systems, run love from the command line with the directory of this game as an argument, e.g. ```love synthein-master```.

On **Windows**, drag the game directory onto ```love.exe```.

For more information, see the [LÖVE wiki guide](https://www.love2d.org/wiki/Getting_Started#Running_Games) on running LÖVE games.

## How to Play

### Controls

Fly your ship around with W, A, S, and D.
Strafe left and right with Q and E.
Toggle fullscreen mode with F11.
Toggle debug mode with F12.
Press escape to save the game or quit.

### Building

To add a block to your ship or an AI ally's ship:

 1. Click on the block.
 2. Click on one of the direction indicators to choose the side to attach to your ship.
 3. Click on the block on your ship or an ally's ship that you want to attach this block to.
 4. Click on the indicator for the side that you want to attach the block to.
 
### Debug Mode

Press F12 to enter or leave debug mode. You can tell if you are in debug mode by looking at the top left corner of the screen. In debug mode, the screen shows some information in the top left corner.

* The first row of debug information is the x and y coordinates of your ship.
* Row 2 is the x and y coordinates of the mouse cursor.
* Row 3 tells you how many structures (ships, blocks, etc.) there are in the world.
* Row 4 tells you how many parts are in your ship.
* Row 5 says whether or not you are in the middle of putting a block onto a ship.

During debug node, you can also spawn in a few different kinds of ship parts.

* U: Spawn a block.
* I: Spawn an engine.
* O: Spawn a gun.
* 1: Spawn an allied AI.
* 2: Spawn an enemy AI.

## License

The code and assets of Synthein are distributed under the terms of the GPL v3, included in the LICENSE file.
