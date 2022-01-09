# Synthein

*  Build your ship.
*  Destroy enemies that spawn at random.
*  Build AI allies can follow you and attack nearby enemies.

![screenshot](https://user-images.githubusercontent.com/2390950/148664456-b180ff4e-5237-42ce-8397-deed5472ecbe.png)

## Planned Features

* AI allies that you can give orders to (follow, guard, patrol, custom programs)
* a customizable automated base
* storable ship configurations
* an open world with randomly generated things to encounter and explore

Check out [our issues](https://github.com/synthein/synthein/issues) to see more of our plans.

## Installing

Download the latest release [here](https://github.com/synthein/synthein/releases/latest).

If you're brave, you can also [download LÖVE](https://love2d.org/) and run the latest dev version:

```
git clone https://github.com/synthein/synthein.git
cd synthein
love src
```

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
