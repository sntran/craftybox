# CraftyBox 

Here are some components I am working on to help using Box2D in Crafty.js engine.

It uses [Box2DWeb](http://code.google.com/p/box2dweb/), which is a JavaScript port from [Box2DFlash](http://www.box2dflash.org), which is a port from the original [Box2D](http://www.gphysics.com/) physic engine written in C++.

The components are written in [CoffeeScript](http://jashkenas.github.com/coffee-script/), which speeds up the developing process really quick.

Please note that I have just learned JavaScript/CoffeeScript for a few weeks, thus my codes are definitely full of bugs. Please help me improve them.

## Components:

### Component "Box2D"
- Public attributes
 - b2Body body
 - b2Fixture fixture
 - b2PolygonShape shape
 - Number x
 - Number y
 - Boolean dynamic - indicates whether body type is dynamic or not
 - Number density
 - Number friction
 - Number restitution
- Public methods
 - rectangle (Number halfWidth, Number halfLength)
 - polygon (Object vertex1, Object vertex2, ...)
 - polygon (Object vertices)

All public methods return the component for chaining.

Usage:
    box = Crafty.e("Box2D")
          .attr({x:1, y:1})
          .rectangle(0.5, 0.5)