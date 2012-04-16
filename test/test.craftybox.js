(function() {
  var b2AABB, b2Body, b2BodyDef, b2CircleShape, b2DebugDraw, b2Fixture, b2FixtureDef, b2MassData, b2PolygonShape, b2Vec2, b2World, should, _ref, _ref2, _ref3;

  should = chai.should();

  b2Vec2 = Box2D.Common.Math.b2Vec2;

  _ref = Box2D.Dynamics, b2BodyDef = _ref.b2BodyDef, b2Body = _ref.b2Body, b2FixtureDef = _ref.b2FixtureDef, b2Fixture = _ref.b2Fixture, b2World = _ref.b2World, b2DebugDraw = _ref.b2DebugDraw;

  _ref2 = Box2D.Collision, b2AABB = _ref2.b2AABB, (_ref3 = _ref2.Shapes, b2MassData = _ref3.b2MassData, b2PolygonShape = _ref3.b2PolygonShape, b2CircleShape = _ref3.b2CircleShape);

  describe("CraftyBox Component", function() {
    describe("when initialized", function() {
      it("should set up a world", function() {
        should.not.exist(Crafty.Box2D.world);
        Crafty.e("Box2D");
        return should.exist(Crafty.Box2D.world);
      });
      it("should have 2D component", function() {
        return Crafty.e("Box2D").has("2D").should.be["true"];
      });
      return it("should not have a body", function() {
        return should.not.exist(Crafty.e("Box2D").body);
      });
    });
    describe("when setting attributes", function() {
      var ent;
      ent = null;
      beforeEach(function() {
        return ent = Crafty.e("Box2D");
      });
      it("should not create a body when missing x or y", function() {
        ent.attr({
          x: 30
        });
        should.not.exist(ent.body);
        ent = Crafty.e("Box2D").attr({
          y: 30
        });
        return should.not.exist(ent.body);
      });
      it("should have a body when x and y provided", function() {
        ent.attr({
          x: 30,
          y: 30
        });
        return should.exist(ent.body);
      });
      it("should have the the body at position specified (with SCALE)", function() {
        var SCALE, attrs;
        attrs = {
          x: 30,
          y: 30
        };
        ent.attr(attrs);
        SCALE = Crafty.Box2D.SCALE;
        ent.body.GetPosition().x.should.equal(attrs.x / SCALE);
        return ent.body.GetPosition().y.should.equal(attrs.y / SCALE);
      });
      it("should have no fixture when only x and y provided", function() {
        var attrs;
        attrs = {
          x: 30,
          y: 30
        };
        ent.attr(attrs);
        return should.not.exist(ent.body.GetFixtureList());
      });
      it("should create a rectangle with w and h provided", function() {
        var SCALE, attrs, h, shape, vertices, w;
        attrs = {
          x: 1800,
          y: 250,
          w: 1800,
          h: 30
        };
        ent.attr(attrs);
        SCALE = Crafty.Box2D.SCALE;
        shape = ent.body.GetFixtureList().GetShape();
        shape.should.be.an["instanceof"](b2PolygonShape);
        shape.GetVertexCount().should.equal(4);
        vertices = shape.GetVertices();
        w = attrs.w / SCALE;
        h = attrs.h / SCALE;
        vertices[0].should.eql({
          x: 0,
          y: 0
        });
        vertices[1].should.eql({
          x: w,
          y: 0
        });
        vertices[2].should.eql({
          x: w,
          y: h
        });
        return vertices[3].should.eql({
          x: 0,
          y: h
        });
      });
      it("should create a square with only w provided", function() {
        var SCALE, attrs, shape, side, vertices;
        attrs = {
          x: 1800,
          y: 250,
          w: 1800
        };
        ent.attr(attrs);
        SCALE = Crafty.Box2D.SCALE;
        shape = ent.body.GetFixtureList().GetShape();
        shape.should.be.an["instanceof"](b2PolygonShape);
        shape.GetVertexCount().should.equal(4);
        vertices = shape.GetVertices();
        side = attrs.w / SCALE;
        vertices[0].should.eql({
          x: 0,
          y: 0
        });
        vertices[1].should.eql({
          x: side,
          y: 0
        });
        vertices[2].should.eql({
          x: side,
          y: side
        });
        return vertices[3].should.eql({
          x: 0,
          y: side
        });
      });
      it("should create a square with only h provided", function() {
        var SCALE, attrs, shape, side, vertices;
        attrs = {
          x: 1800,
          y: 250,
          h: 1800
        };
        ent.attr(attrs);
        SCALE = Crafty.Box2D.SCALE;
        shape = ent.body.GetFixtureList().GetShape();
        shape.should.be.an["instanceof"](b2PolygonShape);
        shape.GetVertexCount().should.equal(4);
        vertices = shape.GetVertices();
        side = attrs.h / SCALE;
        vertices[0].should.eql({
          x: 0,
          y: 0
        });
        vertices[1].should.eql({
          x: side,
          y: 0
        });
        vertices[2].should.eql({
          x: side,
          y: side
        });
        return vertices[3].should.eql({
          x: 0,
          y: side
        });
      });
      it("should create a circle with r provided", function() {
        var attrs, shape;
        attrs = {
          x: 1800,
          y: 250,
          r: 30
        };
        ent.attr(attrs);
        shape = ent.body.GetFixtureList().GetShape();
        return shape.should.be.an["instanceof"](b2CircleShape);
      });
      it("should have w and h when creating circle", function() {
        var attrs;
        attrs = {
          x: 1800,
          y: 250,
          r: 30
        };
        ent.attr(attrs);
        ent.w.should.equal(attrs.r * 2);
        return ent.h.should.equal(attrs.r * 2);
      });
      it("should set the local position of the circle to the center", function() {
        var SCALE, attrs, local, shape;
        attrs = {
          x: 1800,
          y: 250,
          r: 30
        };
        ent.attr(attrs);
        SCALE = Crafty.Box2D.SCALE;
        shape = ent.body.GetFixtureList().GetShape();
        local = shape.GetLocalPosition();
        local.x.should.equal(attrs.r / SCALE);
        return local.y.should.equal(attrs.r / SCALE);
      });
      it("should be static by default", function() {
        var attrs, type;
        attrs = {
          x: 1800,
          y: 250,
          r: 30
        };
        ent.attr(attrs);
        type = ent.body.GetDefinition().type;
        return type.should.equal(b2Body.b2_staticBody);
      });
      return it("should become dynamic if specified", function() {
        var attrs, type;
        attrs = {
          x: 1800,
          y: 250,
          r: 30,
          dynamic: true
        };
        ent.attr(attrs);
        type = ent.body.GetDefinition().type;
        return type.should.equal(b2Body.b2_dynamicBody);
      });
    });
    return describe("when entity is moving", function() {
      return it("should move 2D component as well", function() {
        /*attrs = {x:1800, y: 250, w:1800, h:30, dynamic:true}
        ent = Crafty.e("Box2D").attr(attrs)
        SCALE = Crafty.Box2D.SCALE
        ent.body.GetPosition().x.should.equal attrs.x/SCALE
        ent.body.GetPosition().y.should.equal attrs.y/SCALE
        #Crafty.Box2D.gravity = {x:0, y:10}
        count = 0
        ent.bind "EnterFrame", ->
          if count < 100
            pos = ent.body.GetPosition()
            ent.x.should.equal pos.x/SCALE
            ent.y.should.equal pos.y/SCALE
            count++
          else
            done()
        */
      });
    });
  });

}).call(this);
