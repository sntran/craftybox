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
        var AABB, canvas, debugDraw, doSleep, gravityX, gravityY, _ref4, _ref5, _ref6, _ref7, _world;
        gravityX = (_ref4 = options != null ? options.gravityX : void 0) != null ? _ref4 : 0;
        gravityY = (_ref5 = options != null ? options.gravityY : void 0) != null ? _ref5 : 0;
        this.SCALE = (_ref6 = options != null ? options.scale : void 0) != null ? _ref6 : 30;
        doSleep = (_ref7 = options != null ? options.doSleep : void 0) != null ? _ref7 : true;
        /*
              # The world AABB should always be bigger then the region 
              # where your bodies are located. It is better to make the
              # world AABB too big than too small. If a body reaches the
              # boundary of the world AABB it will be frozen and will stop simulating.
        */
        AABB = new b2AABB;
        AABB.lowerBound.Set(-100.0, -100.0);
        AABB.upperBound.Set(Crafty.viewport.width + 100.0, Crafty.viewport.height + 100.0);
        _world = new b2World(new b2Vec2(gravityX, gravityY), doSleep);
        this.__defineSetter__('gravity', function(v) {
          return _world.SetGravity(new b2Vec2(v.x, v.y));
        });
        Crafty.bind("EnterFrame", function() {
          _world.Step(1 / 60, 10, 10);
          if (this.debug) _world.DrawDebugData();
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
        var bodyDef, fixDef, h, w, _ref4, _ref5, _ref6, _ref7, _ref8;
        if (((attrs != null ? attrs.x : void 0) != null) && ((attrs != null ? attrs.y : void 0) != null)) {
          bodyDef = new b2BodyDef;
          bodyDef.type = (attrs.dynamic != null) && attrs.dynamic ? b2Body.b2_dynamicBody : b2Body.b2_staticBody;
          bodyDef.position.Set(attrs.x / SCALE, attrs.y / SCALE);
          _this.body = Crafty.Box2D.world.CreateBody(bodyDef);
          fixDef = new b2FixtureDef;
          fixDef.density = (_ref4 = attrs.density) != null ? _ref4 : 1.0;
          fixDef.friction = (_ref5 = attrs.friction) != null ? _ref5 : 0.5;
          fixDef.restitution = (_ref6 = attrs.restitution) != null ? _ref6 : 0.2;
          if ((attrs.w != null) || (attrs.h != null)) {
            w = ((_ref7 = attrs.w) != null ? _ref7 : attrs.h) / SCALE;
            h = ((_ref8 = attrs.h) != null ? _ref8 : attrs.w) / SCALE;
            fixDef.shape = new b2PolygonShape;
            fixDef.shape.SetAsOrientedBox(w / 2, h / 2, new b2Vec2(w / 2, h / 2));
            _this.body.CreateFixture(fixDef);
          }
          if (attrs.r != null) {
            _this.w = _this.h = attrs.r * 2;
            fixDef.shape = new b2CircleShape(attrs.r / SCALE);
            fixDef.shape.SetLocalPosition(new b2Vec2(_this.w / SCALE / 2, _this.h / SCALE / 2));
            return _this.body.CreateFixture(fixDef);
          }
        }
      });
      this.bind("EnterFrame", function() {
        var pos;
        if (_this.body && _this.body.IsAwake()) {
          pos = _this.body.GetPosition();
          _this.x = pos.x * SCALE;
          _this.y = pos.y * SCALE;
          return _this.rotation = Crafty.math.radToDeg(_this.body.GetAngle());
        }
      });
      return this;
    }
  });

}).call(this);
