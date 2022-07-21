# Unnamed raycast fps

## Goal

Making a playable raycasted game using HTML/JavaScript api only.

## Dev blog

### Start

I decided to continue on my raycasted game from the @js1024fun jam.

First steps:
 * Support wide ratio
 * Keyboard controls
 * Cleaner code (original was aimed to be minimal)

![start](https://github.com/gogoprog/raycastfps/raw/master/res/rfps-start.png)

### Floor

First acceptable floor rendering : I could not figure it out by myself so I read stuff about `mode7` and `rotozoomer` to achieve this.

![floor](https://github.com/gogoprog/raycastfps/raw/master/res/rfps-floor.gif)

### First sprite

First step on sprite rendering :
  * (almost) correctly positionned in "3D"
  * Correct size depending on the distance

![sprite](https://github.com/gogoprog/raycastfps/raw/master/res/rfps-sprite.gif)

### Sprite again

Continuing on sprite rendering :
  * Snapped to the ground
  * Support depth (hidden by walls)
  * Support transparency (just skipping transparent pixels)

![sprite](https://github.com/gogoprog/raycastfps/raw/master/res/rfps-sprite2.gif)


