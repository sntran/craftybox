# CraftyBox 

Here are some components I am working on to help using Box2D in Crafty.js ([web](http://craftyjs.com/) | [github](https://github.com/craftyjs/Crafty)) engine.

It uses [Box2DWeb](http://code.google.com/p/box2dweb/), which is a JavaScript port from [Box2DFlash](http://www.box2dflash.org), which is a port from the original [Box2D](http://www.gphysics.com/) physic engine written in C++.

The components are written in [CoffeeScript](http://jashkenas.github.com/coffee-script/), which speeds up the developing process really quick.

A compiled JS file is available.

## Components

* `Box2D`: intended to replace `2D, Physics, Gravity, Collision`.
* `Throwable`: intended to replace `Draggable`. Of course it uses `Mouse`.

## Usuage

### Initialization

You can initialize after Crafty with a set of optional options:

````javascript
Crafty.init()
Crafty.Box2D.init({gravityX:0, gravityY:0, scale:30, doSleep:true})
````

The default world has no gravity, allows sleeping, and has a SCALE of 30.

Or it will be initialized when you create a Box2D entity. You cannot set the world's properties at this point, and it will use the default values.

However you can change them through setters anytime after the world is created

````javascript
Crafty.Box2D.gravity = {x: 0, y: 10}
Crafty.Box2D.SCALE = 1
````

* `Crafty.e("Box2D").attr({x:x, y:y, w:w, h:h});`: A static rectangle
* `Crafty.e("Box2D").attr({x:x, y:y, w:w, dynamic: true});`: A dynamic square
* `Crafty.e("Box2D").attr({x:x, y:y, h:h, dynamic: true});`: also a dynamic square
* `Crafty.e("Box2D").attr({x:x, y:y, r:r, dynamic: true});`: dynamic circle

You can also indicate `density`, `friction`, and `restitution` if you don't want the default values (1.0, 0.5, 0.2 accordingly).

`Crafty.e("Box2D").attr({x:x, y:y, w:w, h:h, density: 1.0, friction: 0.5, restitution: 0.2});`

Some shortcuts:

* `Crafty.e("Box2D").attr({x:x, y:y}).rectangle(w, h);`: static rectangle
* `Crafty.e("Box2D").attr({x:x, y:y, dynamic: true}).rectangle(w, w);`: A dynamic square
* `Crafty.e("Box2D").attr({x:x, y:y, dynamic: true}).rectangle(w);`: also a dynamic square
* `Crafty.e("Box2D").attr({x:x, y:y, dynamic: true}).circle(r);`: dynamic circle

The Box2D world is accessible with `Crafty.Box2D.world`

See `examples` folder for more usuages.

## Changelogs:

### v0.0.3

* Added usuage
* Same attributes as of Crafty's 2D component
* Entities can move and rotate
* Finished Box2D example.
* Don't recreate body when .attr({x, y}) is called again.
* Made `.isAt`, `.move`, `.shift`, `.attach`, `.detach` work.
* More examples.
* Refactored to allow more usuages.
* Use Crafty's FPS for Box2D World step.
* Remove body from Box2D world before destroying entity.

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

* <del>Link between Crafty's 2D attributes and Box2D attributes</del>
* <del>Make objects move and rotate</del>
* Collision
* <del>`.move`, `.attach`, `.shift`, etc...</del>
* <del>`"Mouse"`, `"Draggable"`, `"Four-way"`, etc...</del>
* Throwable