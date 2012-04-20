(function() {
  var b2AABB, b2Body, b2BodyDef, b2CircleShape, b2ContactListener, b2DebugDraw, b2Fixture, b2FixtureDef, b2MassData, b2PolygonShape, b2Vec2, b2World, b2WorldManifold, _ref, _ref2, _ref3;

  b2Vec2 = Box2D.Common.Math.b2Vec2;

  _ref = Box2D.Dynamics, b2BodyDef = _ref.b2BodyDef, b2Body = _ref.b2Body, b2FixtureDef = _ref.b2FixtureDef, b2Fixture = _ref.b2Fixture, b2World = _ref.b2World, b2DebugDraw = _ref.b2DebugDraw, b2ContactListener = _ref.b2ContactListener;

  _ref2 = Box2D.Collision, b2AABB = _ref2.b2AABB, b2WorldManifold = _ref2.b2WorldManifold, (_ref3 = _ref2.Shapes, b2MassData = _ref3.b2MassData, b2PolygonShape = _ref3.b2PolygonShape, b2CircleShape = _ref3.b2CircleShape);

  /*
  # #Crafty.Box2D
  # @category Physics
  # Dealing with Box2D
  */

  Crafty.extend({
    Box2D: {
      /*
          # #Crafty.Box2D.world
          # @comp Crafty.Box2D
          # This will return the Box2D world object,
          # which is a container for bodies and joints.
          # It will have 0 gravity when initialized.
          # Gravity can be set through a setter:
          # Crafty.Box2D.gravity = {x: 0, y:10}
      */
      world: null,
      /*
          # #Crafty.Box2D.debug
          # @comp Crafty.Box2D
          # This will determine whether to use Box2D's own debug Draw
      */
      debug: false,
      /*
          # #Crafty.Box2D.init
          # @comp Crafty.Box2D
          # @sign public void Crafty.Box2D.init(params)
          # @param options: An object contain settings for the world
          # Create a Box2D world. Must be called before any entities
          # with the Box2D component can be created
      */
      init: function(options) {
        var canvas, contactListener, debugDraw, doSleep, gravityX, gravityY, _ref4, _ref5, _ref6, _ref7, _world,
          _this = this;
        gravityX = (_ref4 = options != null ? options.gravityX : void 0) != null ? _ref4 : 0;
        gravityY = (_ref5 = options != null ? options.gravityY : void 0) != null ? _ref5 : 0;
        this.SCALE = (_ref6 = options != null ? options.scale : void 0) != null ? _ref6 : 30;
        doSleep = (_ref7 = options != null ? options.doSleep : void 0) != null ? _ref7 : true;
        _world = new b2World(new b2Vec2(gravityX, gravityY), doSleep);
        this.__defineSetter__('gravity', function(v) {
          return _world.SetGravity(new b2Vec2(v.x, v.y));
        });
        contactListener = new b2ContactListener;
        contactListener.BeginContact = function(contact) {
          var bodyA, bodyB, contactPoints, fixtureA, fixtureB, manifold;
          fixtureA = contact.GetFixtureA();
          fixtureB = contact.GetFixtureB();
          bodyA = fixtureA.GetBody();
          bodyB = fixtureB.GetBody();
          manifold = new b2WorldManifold();
          contact.GetWorldManifold(manifold);
          contactPoints = manifold.m_points;
          Crafty(bodyA.GetUserData()).trigger("BeginContact", {
            points: contactPoints,
            targetId: bodyB.GetUserData()
          });
          return Crafty(bodyB.GetUserData()).trigger("BeginContact", {
            points: contactPoints,
            targetId: bodyA.GetUserData()
          });
        };
        contactListener.EndContact = function(contact) {
          var bodyA, bodyB, fixtureA, fixtureB;
          fixtureA = contact.GetFixtureA();
          fixtureB = contact.GetFixtureB();
          bodyA = fixtureA.GetBody();
          bodyB = fixtureB.GetBody();
          Crafty(bodyA.GetUserData()).trigger("EndContact");
          return Crafty(bodyB.GetUserData()).trigger("EndContact");
        };
        _world.SetContactListener(contactListener);
        Crafty.bind("EnterFrame", function() {
          _world.Step(1 / Crafty.timer.getFPS(), 10, 10);
          if (_this.debug) _world.DrawDebugData();
          return _world.ClearForces();
        });
        if (Crafty.support.canvas) {
          canvas = document.createElement("canvas");
          canvas.id = "Box2DCanvasDebug";
          canvas.width = Crafty.viewport.width;
          canvas.height = Crafty.viewport.height;
          canvas.style.position = 'absolute';
          canvas.style.left = "0px";
          canvas.style.top = "0px";
          Crafty.stage.elem.appendChild(canvas);
          debugDraw = new b2DebugDraw();
          debugDraw.SetSprite(canvas.getContext('2d'));
          debugDraw.SetDrawScale(this.SCALE);
          debugDraw.SetFillAlpha(0.7);
          debugDraw.SetLineThickness(1.0);
          debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_joinBit);
          _world.SetDebugDraw(debugDraw);
        }
        return this.world = _world;
      },
      /*
          # #Crafty.Box2D.destroy
          # @comp Crafty.Box2D
          # @sign public void Crafty.Box2D.destroy(void)
          # Destroy all the bodies in the world.
      */
      destroy: function() {
        var body, _results;
        _results = [];
        while ((body = this.world.GetBodyList()) != null) {
          this.world.DestroyBody(body);
          _results.push(body = body.GetNext());
        }
        return _results;
      }
    }
  });

  /*
  # #Box2D
  # @category Physics
  # Creates itself in a Box2D World. Crafty.Box2D.init() will be automatically called
  # if it is not called already (hence the world element doesn't exist).
  # In order to create a Box2D object, a body definition of position and dynamic is need.
  # The world will use this bodyDef to create a body. A fixture definition with geometry,
  # friction, density, etc is also required. Then create shapes on the body.
  # The body will be created during the .attr call instead of init.
  */

  Crafty.c("Box2D", {
    /*
      #.body
      @comp Box2D
      The `b2Body` from Box2D, created by `Crafty.Box2D.world` during `.attr({x, y})` call.
      Shape can be attached to it if more params added to `.attr` call, or through
      `.circle`, `.rectangle`, or `.polygon` method.
    */
    body: null,
    init: function() {
      var SCALE,
        _this = this;
      this.addComponent("2D");
      if (!(Crafty.Box2D.world != null)) Crafty.Box2D.init();
      SCALE = Crafty.Box2D.SCALE;
      /*
          Box2D entity is created by calling .attr({x, y, w, h}) or .attr({x, y, r}).
          That funnction triggers "Change" event for us to set box2d attributes.
      */
      this.bind("Change", function(attrs) {
        var bodyDef, h, newH, newW, w, _ref4, _ref5, _ref6, _ref7, _ref8;
        if (!(attrs != null)) return;
        if (_this.body != null) {
          if (attrs._x !== _this.x || attrs._y !== _this.y) {
            _this.body.SetPosition(new b2Vec2(_this.x / SCALE, _this.y / SCALE));
          }
          if ((newW = attrs._w !== _this.w) || (newH = attrs._h !== _this.h)) {
            if (!(_this.r != null)) {
              return _this.rectangle(_this.w / SCALE, _this.h / SCALE);
            } else if (newW) {
              _this.r += _this.w - attrs._w;
              return _this.circle(_this.r);
            } else {
              _this._w = attrs._w;
              return _this._h = attrs._h;
            }
          }
        } else if ((attrs.x != null) && (attrs.y != null)) {
          bodyDef = new b2BodyDef;
          bodyDef.type = (attrs.dynamic != null) && attrs.dynamic ? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
          bodyDef.position.Set(attrs.x / SCALE, attrs.y / SCALE);
          _this.body = Crafty.Box2D.world.CreateBody(bodyDef);
          _this.body.SetUserData(_this[0]);
          _this.fixDef = new b2FixtureDef;
          _this.fixDef.density = (_ref4 = attrs.density) != null ? _ref4 : 1.0;
          _this.fixDef.friction = (_ref5 = attrs.friction) != null ? _ref5 : 0.5;
          _this.fixDef.restitution = (_ref6 = attrs.restitution) != null ? _ref6 : 0.2;
          if (attrs.r != null) {
            return _this.circle(attrs.r);
          } else if ((attrs.w != null) || (attrs.h != null)) {
            w = (_this.w = (_ref7 = attrs.w) != null ? _ref7 : attrs.h) / SCALE;
            h = (_this.h = (_ref8 = attrs.h) != null ? _ref8 : attrs.w) / SCALE;
            return _this.rectangle(w, h);
          }
        }
      });
      /*
          Update the entity by using Box2D's attributes.
      */
      this.bind("EnterFrame", function() {
        var pos;
        if ((_this.body != null) && _this.body.IsAwake()) {
          pos = _this.body.GetPosition();
          _this._x = pos.x * SCALE;
          _this._y = pos.y * SCALE;
          return _this.rotation = Crafty.math.radToDeg(_this.body.GetAngle());
        }
      });
      /*
          Remove the body from world before destroying this entity
      */
      return this.bind("Remove", function() {
        if (_this.body != null) return Crafty.Box2D.world.DestroyBody(_this.body);
      });
    },
    /*
      #.circle
      @comp Box2D
      @sign public this .circle(Number radius)
      @param radius - The radius of the circle to create
      Attach a circle shape to entity's existing body.
      @example 
      ~~~
      this.attr({x: 10, y: 10, r:10}) // called internally
      this.attr({x: 10, y: 10}).circle(10) // called explicitly
      ~~~
    */
    circle: function(radius) {
      var SCALE;
      if (!(this.body != null)) return this;
      SCALE = Crafty.Box2D.SCALE;
      if (this.body.GetFixtureList() != null) {
        this.body.DestroyFixture(this.body.GetFixtureList());
      }
      this._w = this._h = radius * 2;
      this.fixDef.shape = new b2CircleShape(radius / SCALE);
      this.fixDef.shape.SetLocalPosition(new b2Vec2(this.w / SCALE / 2, this.h / SCALE / 2));
      this.body.CreateFixture(this.fixDef);
      return this;
    },
    /*
      #.rectangle
      @comp Box2D
      @sign public this .rectangle(Number w, Number h)
      @param w - The width of the rectangle to create
      @param h - The height of the rectangle to create
      Attach a rectangle or square shape to entity's existing body.
      @example 
      ~~~
      this.attr({x: 10, y: 10, w:10, h: 15}) // called internally
      this.attr({x: 10, y: 10}).rectangle(10, 15) // called explicitly
      this.attr({x: 10, y: 10}).rectangle(10, 10) // a square
      this.attr({x: 10, y: 10}).rectangle(10) // also square!!!
      ~~~
    */
    rectangle: function(w, h) {
      var SCALE;
      if (!(this.body != null)) return this;
      h = h != null ? h : w;
      SCALE = Crafty.Box2D.SCALE;
      if (this.body.GetFixtureList() != null) {
        this.body.DestroyFixture(this.body.GetFixtureList());
      }
      this.fixDef.shape = new b2PolygonShape;
      this.fixDef.shape.SetAsOrientedBox(w / 2, h / 2, new b2Vec2(w / 2, h / 2));
      this.body.CreateFixture(this.fixDef);
      return this;
    },
    /*
      #.onHit
      @comp Box2D
      @sign public this .onHit(String component, Function beginContact[, Function endContact])
      @param component - Component to check collisions for
      @param beginContact - Callback method to execute when collided with component, 
      @param endContact - Callback method executed once as soon as collision stops
      Invoke the callback(s) if collision detected through contact listener. We don't bind
      to EnterFrame, but let the contact listener in the Box2D world notify us.
    */
    onHit: function(component, beginContact, endContact) {
      var _this = this;
      if (component !== "Box2D") return this;
      this.bind("BeginContact", function(data) {
        var hitData;
        hitData = [
          {
            obj: Crafty(data.targetId),
            type: "Box2D",
            points: data.points
          }
        ];
        return beginContact.call(_this, hitData);
      });
      if (typeof endContact === "function") {
        return this.bind("EndContact", function() {
          return endContact.call(_this);
        });
      }
    }
  });

}).call(this);
