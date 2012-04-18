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
      afterEach(function() {
        Crafty.Box2D.destroy();
        return ent.destroy();
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
      it("should only set new position when body exists", function() {
        var SCALE, attrs;
        attrs = {
          x: 30,
          y: 30
        };
        ent.attr(attrs);
        SCALE = Crafty.Box2D.SCALE;
        Crafty.Box2D.world.GetBodyCount().should.equal(1);
        ent.attr({
          x: 50,
          y: 50
        });
        Crafty.Box2D.world.GetBodyCount().should.not.equal(2);
        Crafty.Box2D.world.GetBodyCount().should.equal(1);
        ent.body.GetPosition().x.should.equal(50 / SCALE);
        return ent.body.GetPosition().y.should.equal(50 / SCALE);
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
      it("should have same h with only w provided", function() {
        var attrs;
        attrs = {
          x: 1800,
          y: 250,
          w: 1800
        };
        ent.attr(attrs);
        return ent.h.should.equal(attrs.w);
      });
      it("should have same w with only h provided", function() {
        var attrs;
        attrs = {
          x: 1800,
          y: 250,
          h: 1800
        };
        ent.attr(attrs);
        return ent.w.should.equal(attrs.h);
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
    return describe("2D Component", function() {
      var cirAttrs, circle, recAttrs, rectangle;
      rectangle = null;
      circle = null;
      recAttrs = {
        x: 100,
        y: 100,
        w: 50,
        h: 50
      };
      cirAttrs = {
        x: 100,
        y: 100,
        r: 50
      };
      beforeEach(function() {
        rectangle = Crafty.e("Box2D").attr(recAttrs);
        return circle = Crafty.e("Box2D").attr(cirAttrs);
      });
      describe(".area()", function() {
        it("should return w * h for rectangle", function() {
          return rectangle.area().should.equal(recAttrs.w * recAttrs.h);
        });
        return it("should return PI*r", function() {
          return circle.area().should.equal(cirAttrs.r * Math.PI);
        });
      });
      describe(".intersect(x, y, w, h)", function() {
        it("should intesect with (100, 100, 50, 50) for rectangle", function() {
          return rectangle.intersect(100, 100, 50, 50).should.be["true"];
        });
        return it("should not intesect with (0, 0, 100, 100) for rectangle", function() {
          return rectangle.intersect(0, 0, 100, 100).should.be["false"];
        });
      });
      describe(".within(x, y, w, h)", function() {});
      describe(".contains(x, y, w, h)", function() {});
      describe(".pos()", function() {});
      describe(".mbr()", function() {});
      describe(".isAt(x, y)", function() {});
      describe(".move(dir, by)", function() {
        it("should has x and y at the specified location", function() {
          var amount;
          amount = 10;
          rectangle.move("n", amount).isAt(recAttrs.x, recAttrs.y - amount).should.be["true"];
          rectangle.move("s", amount).isAt(recAttrs.x, recAttrs.y).should.be["true"];
          rectangle.move("e", amount).isAt(recAttrs.x + amount, recAttrs.y).should.be["true"];
          return rectangle.move("w", amount).isAt(recAttrs.x, recAttrs.y).should.be["true"];
        });
        return it("should move Box2D position as well", function() {
          var SCALE, amount;
          amount = 30;
          SCALE = Crafty.Box2D.SCALE;
          return rectangle.move("n", amount).body.GetPosition().should.eql({
            x: recAttrs.x / SCALE,
            y: (recAttrs.y - amount) / SCALE
          });
        });
      });
      describe(".shift(x, y, w, h)", function() {});
      describe(".attach(Entity obj[, .., Entity objN])", function() {
        return it("should move the follower", function() {
          var amount, attrs, follower;
          attrs = {
            x: 200,
            y: 200,
            w: 50,
            h: 50
          };
          follower = Crafty.e("Box2D").attr(attrs);
          amount = 30;
          rectangle.attach(follower).move("n", amount);
          return follower.y.should.equal(attrs.y - amount);
        });
      });
      describe(".detach(obj)", function() {});
      describe(".origin(x, y)", function() {});
      describe(".flip(dir)", function() {});
      return describe(".rotate(e)", function() {});
    });
  });

}).call(this);
