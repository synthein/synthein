# Synthein [![CI Status](https://drone.webgears.k.vu/api/badges/synthein/synthein/status.svg?branch=master)](https://drone.webgears.k.vu/synthein/synthein) [![Chat Channel](https://img.shields.io/badge/telegram-chat-lightgrey.svg)](https://t.me/synthein)

Synthein (working title) is a game about blowing up space ships and using their
parts to make your space ship bigger and better.

## Features

*  Build your ship.
*  Destroy enemies that spawn at random.
*  Build AI allies can follow you and attack nearby enemies.

![screenshot](http://i.imgur.com/b2QnY5A.png)

### Planned Features

* AI allies that you can give orders to (follow, guard, patrol)
* a customizable automated base
* storable ship configurations
* an open world with randomly generated things to encounter and explore

Check out [our issues](https://github.com/synthein/synthein/issues) to see more of our plans.

## Installing

Download the latest release [here](https://github.com/synthein/synthein/releases/latest).

If you're brave, you can also try out the latest unstable build:

* [For Linux](https://s3-us-west-2.amazonaws.com/synthein-unstable-builds/synthein-unstable.AppImage)
* [For macOS](https://s3-us-west-2.amazonaws.com/synthein-unstable-builds/synthein-unstable-macos.zip)
* [For Windows](https://s3-us-west-2.amazonaws.com/synthein-unstable-builds/synthein-unstable-windows.zip)
* [For Everything else](https://s3-us-west-2.amazonaws.com/synthein-unstable-builds/synthein-unstable.love) (More information about .love files is available [here](https://love2d.org/wiki/L%C3%96VE_Game_File).)

## How to Play

### Controls

* Fly your ship around with W, A, S, and D.
* Strafe left and right with Q and E.
* Toggle fullscreen mode with F11.
* Toggle debug mode with F12.
* Press escape to save the game or quit.

### Building

To add a block to your ship or an AI ally's ship:

 1. Click on the block.
 2. Click on one of the direction indicators to choose the side to attach to your ship.
 3. Click on the block on your ship or an ally's ship that you want to attach this block to.
 4. Click on the indicator for the side that you want to attach the block to.

### Debug Mode

Press F12 to toggle debug mode.

During debug node, you can see more information about your ship and the game
world. You can also spawn in a few different kinds of ships and ship parts.
Press "I" to open a menu that lets you choose something to spawn.

## License

Copyright (c) 2014-2022 Jordan Christiansen and Drake Halver

The code and assets of Synthein are distributed under the terms of the GPL v3,
included in the LICENSE file.

Synthein uses several third-party modules. The copyright information for these
modules is included with the modules themselves, which can be found in the
`src/vendor` directory.
