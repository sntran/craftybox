# CraftyBox 

Here are some components I am working on to help using Box2D in Crafty.js engine.

It uses [Box2DWeb](http://code.google.com/p/box2dweb/), which is a JavaScript port from [Box2DFlash](http://www.box2dflash.org), which is a port from the original [Box2D](http://www.gphysics.com/) physic engine written in C++.

The components are written in [CoffeeScript](http://jashkenas.github.com/coffee-script/), which speeds up the developing process really quick.

Please note that I have just learned JavaScript/CoffeeScript for a few weeks, thus my codes are definitely full of bugs. Please help me improve them.

## Changelogs:

### v0.0.2

* Changed the changelog version format :)
* Started writing tests
* Parameters for SetAsBox should be half width, half height
* Can create circle by `.attr({x, y, r})`
* Can specify dynamic body by `.attr({x, y, r, dynamic:true})`
* Added the standard example from Box2D

### v0.0.1

* Rewrote from scratch.
* Updated Crafty to v0.4.7.
* Updated Coffee-Script compiler to v1.3.1.
* Removed Box2DWorld component.
* Extended Crafty with a Box2D property to act as the world.

## To Do:

* Link between Crafty's 2D attributes and Box2D attributes
* Make objects move and rotate
* Collision