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
    return describe("when setting attributes", function() {
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
        var SCALE, attrs, halfHeight, halfWidth, shape, vertices;
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
        halfWidth = attrs.w / SCALE / 2;
        halfHeight = attrs.h / SCALE / 2;
        vertices[0].should.eql({
          x: -halfWidth,
          y: -halfHeight
        });
        vertices[1].should.eql({
          x: halfWidth,
          y: -halfHeight
        });
        vertices[2].should.eql({
          x: halfWidth,
          y: halfHeight
        });
        return vertices[3].should.eql({
          x: -halfWidth,
          y: halfHeight
        });
      });
      it("should create a square with only w provided", function() {
        var SCALE, attrs, halfSide, shape, vertices;
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
        halfSide = attrs.w / SCALE / 2;
        vertices[0].should.eql({
          x: -halfSide,
          y: -halfSide
        });
        vertices[1].should.eql({
          x: halfSide,
          y: -halfSide
        });
        vertices[2].should.eql({
          x: halfSide,
          y: halfSide
        });
        return vertices[3].should.eql({
          x: -halfSide,
          y: halfSide
        });
      });
      it("should create a square with only h provided", function() {
        var SCALE, attrs, halfSide, shape, vertices;
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
        halfSide = attrs.h / SCALE / 2;
        vertices[0].should.eql({
          x: -halfSide,
          y: -halfSide
        });
        vertices[1].should.eql({
          x: halfSide,
          y: -halfSide
        });
        vertices[2].should.eql({
          x: halfSide,
          y: halfSide
        });
        return vertices[3].should.eql({
          x: -halfSide,
          y: halfSide
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
  });

}).call(this);
