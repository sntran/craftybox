(function() {
  var b2AABB, b2Body, b2BodyDef, b2CircleShape, b2DebugDraw, b2Fixture, b2FixtureDef, b2MassData, b2PolygonShape, b2Vec2, b2World, _ref, _ref2, _ref3;

  b2Vec2 = Box2D.Common.Math.b2Vec2;

  _ref = Box2D.Dynamics, b2BodyDef = _ref.b2BodyDef, b2Body = _ref.b2Body, b2FixtureDef = _ref.b2FixtureDef, b2Fixture = _ref.b2Fixture, b2World = _ref.b2World, b2DebugDraw = _ref.b2DebugDraw;

  _ref2 = Box2D.Collision, b2AABB = _ref2.b2AABB, (_ref3 = _ref2.Shapes, b2MassData = _ref3.b2MassData, b2PolygonShape = _ref3.b2PolygonShape, b2CircleShape = _ref3.b2CircleShape);

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
      */
      world: null,
      debug: false,
      /*
          # #Crafty.Box2D.init
          # @comp Crafty.Box2D
          # @sign public void Crafty.Box2D.init(void)
          # Create a Box2D world. Must be called before any entities
          # with the Box2D component can be created
      */
      init: function(gravityX, gravityY, SCALE, doSleep) {
        var AABB, canvas, debugDraw,
          _this = this;
        if (gravityX == null) gravityX = 0;
        if (gravityY == null) gravityY = 10;
        this.SCALE = SCALE != null ? SCALE : 30;
        if (doSleep == null) doSleep = true;
        /*
              # The world AABB should always be bigger then the region 
              # where your bodies are located. It is better to make the
              # world AABB too big than too small. If a body reaches the
              # boundary of the world AABB it will be frozen and will stop simulating.
        */
        AABB = new b2AABB;
        AABB.lowerBound.Set(-100.0, -100.0);
        AABB.upperBound.Set(Crafty.viewport.width + 100.0, Crafty.viewport.height + 100.0);
        this.world = new b2World(AABB, new b2Vec2(gravityX, gravityY), doSleep);
        Crafty.bind("EnterFrame", function() {
          _this.world.Step(1 / 60, 10, 10);
          if (_this.debug) _this.world.DrawDebugData();
          return _this.world.ClearForces();
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
          this.world.SetDebugDraw(debugDraw);
          return this.debug = true;
        }
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
  */

  Crafty.c("Box2D", {
    body: null,
    init: function() {
      var bodyDef, fixDef;
      this.requires("2D");
      if (!(Crafty.Box2D.world != null)) Crafty.Box2D.init();
      bodyDef = new b2BodyDef;
      bodyDef.type = b2Body.b2_staticBody;
      bodyDef.position.Set(this._x / Crafty.Box2D.SCALE, this._y / Crafty.Box2D.SCALE);
      this.body = Crafty.Box2D.world.CreateBody(bodyDef);
      fixDef = new b2FixtureDef;
      fixDef.shape = new b2PolygonShape;
      fixDef.density = 1.0;
      fixDef.friction = 0.5;
      fixDef.restitution = 0.1;
      fixDef.shape.SetAsBox(10.0, 10.0);
      this.body.CreateFixture(fixDef);
      return this;
    }
  });

}).call(this);
