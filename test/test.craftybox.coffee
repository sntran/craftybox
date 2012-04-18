should = chai.should()
b2Vec2 = Box2D.Common.Math.b2Vec2
{b2BodyDef, b2Body, b2FixtureDef, b2Fixture, b2World, b2DebugDraw} = Box2D.Dynamics
{b2AABB, Shapes: {b2MassData, b2PolygonShape, b2CircleShape}} = Box2D.Collision

describe "CraftyBox Component", ->
  describe "when initialized", ->
    it "should set up a world", ->
      should.not.exist Crafty.Box2D.world
      Crafty.e "Box2D"
      should.exist Crafty.Box2D.world

    it "should have 2D component", ->
      Crafty.e("Box2D").has("2D").should.be.true

    it "should not have a body", ->
      should.not.exist Crafty.e("Box2D").body

  describe "when setting attributes", ->
    ent = null

    beforeEach ->
      ent = Crafty.e("Box2D")

    afterEach ->
      Crafty.Box2D.destroy()
      ent.destroy()

    it "should not create a body when missing x or y", ->
      ent.attr({x:30})
      should.not.exist ent.body
      ent = Crafty.e("Box2D").attr({y:30})
      should.not.exist ent.body

    it "should have a body when x and y provided", ->
      ent.attr({x:30, y: 30})
      should.exist ent.body

    it "should have the the body at position specified (with SCALE)", ->
      attrs = {x: 30, y: 30}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      ent.body.GetPosition().x.should.equal attrs.x/SCALE
      ent.body.GetPosition().y.should.equal attrs.y/SCALE

    it "should only set new position when body exists", ->
      attrs = {x: 30, y: 30}
      ent.attr attrs
      Crafty.Box2D.world.GetBodyCount().should.equal 1
      ent.attr {x: 50, y: 50}
      Crafty.Box2D.world.GetBodyCount().should.not.equal 2
      Crafty.Box2D.world.GetBodyCount().should.equal 1

    it "should have no fixture when only x and y provided", ->
      attrs = {x: 30, y: 30}
      ent.attr attrs
      should.not.exist ent.body.GetFixtureList()

    it "should create a rectangle with w and h provided", ->
      attrs = {x:1800, y: 250, w:1800, h:30}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      shape = ent.body.GetFixtureList().GetShape()
      shape.should.be.an.instanceof(b2PolygonShape)
      shape.GetVertexCount().should.equal 4
      vertices = shape.GetVertices()

      w = attrs.w/SCALE
      h = attrs.h/SCALE    
      # Note: vertices are in local cordinates
      vertices[0].should.eql {x: 0, y: 0}
      vertices[1].should.eql {x: w, y: 0}
      vertices[2].should.eql {x: w, y: h}
      vertices[3].should.eql {x: 0, y: h}

    it "should create a square with only w provided", ->
      attrs = {x:1800, y: 250, w:1800}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      shape = ent.body.GetFixtureList().GetShape()
      shape.should.be.an.instanceof(b2PolygonShape)
      shape.GetVertexCount().should.equal 4
      vertices = shape.GetVertices()

      side = attrs.w/SCALE
      # Note: vertices are in local cordinates
      vertices[0].should.eql {x: 0, y: 0}
      vertices[1].should.eql {x: side, y: 0}
      vertices[2].should.eql {x: side, y: side}
      vertices[3].should.eql {x: 0, y: side}

    it "should create a square with only h provided", ->
      attrs = {x:1800, y: 250, h:1800}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      shape = ent.body.GetFixtureList().GetShape()
      shape.should.be.an.instanceof(b2PolygonShape)
      shape.GetVertexCount().should.equal 4
      vertices = shape.GetVertices()

      side = attrs.h/SCALE
      # Note: vertices are in local cordinates
      vertices[0].should.eql {x: 0, y: 0}
      vertices[1].should.eql {x: side, y: 0}
      vertices[2].should.eql {x: side, y: side}
      vertices[3].should.eql {x: 0, y: side}

    it "should have same h with only w provided", ->
      attrs = {x:1800, y: 250, w:1800}
      ent.attr attrs
      ent.h.should.equal attrs.w

    it "should have same w with only h provided", ->
      attrs = {x:1800, y: 250, h:1800}
      ent.attr attrs
      ent.w.should.equal attrs.h

    it "should create a circle with r provided", ->
      attrs = {x:1800, y: 250, r:30}
      ent.attr attrs
      shape = ent.body.GetFixtureList().GetShape()
      shape.should.be.an.instanceof b2CircleShape

    it "should have w and h when creating circle", ->
      attrs = {x:1800, y: 250, r:30}
      ent.attr attrs
      ent.w.should.equal attrs.r*2
      ent.h.should.equal attrs.r*2

    it "should set the local position of the circle to the center", ->
      attrs = {x:1800, y: 250, r:30}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      shape = ent.body.GetFixtureList().GetShape()
      local = shape.GetLocalPosition()
      local.x.should.equal attrs.r/SCALE
      local.y.should.equal attrs.r/SCALE

    it "should be static by default", ->
      attrs = {x:1800, y: 250, r:30}
      ent.attr attrs
      type = ent.body.GetDefinition().type
      type.should.equal b2Body.b2_staticBody

    it "should become dynamic if specified", ->
      attrs = {x:1800, y: 250, r:30, dynamic: true}
      ent.attr attrs
      type = ent.body.GetDefinition().type
      type.should.equal b2Body.b2_dynamicBody      

  describe "2D Component", ->
    rectangle = null
    circle = null
    recAttrs = {x:100, y: 100, w:50, h: 50}
    cirAttrs = {x:100, y: 100, r:50}

    beforeEach ->
      rectangle = Crafty.e("Box2D").attr recAttrs
      circle = Crafty.e("Box2D").attr cirAttrs

    describe ".area()", ->
      it "should return w * h for rectangle", ->
        rectangle.area().should.equal recAttrs.w*recAttrs.h
      it "should return PI*r", ->
        circle.area().should.equal cirAttrs.r*Math.PI

    describe ".intersect(x, y, w, h)", ->
      it "should intesect with (100, 100, 50, 50) for rectangle", ->
        rectangle.intersect(100, 100, 50, 50).should.be.true
      it "should not intesect with (0, 0, 100, 100) for rectangle", ->
        rectangle.intersect(0, 0, 100, 100).should.be.false

    describe ".within(x, y, w, h)", ->
    describe ".contains(x, y, w, h)", ->
    describe ".pos()", ->
    describe ".mbr()", ->
    describe ".isAt(x, y)", ->
    describe ".move(dir, by)", ->
      it "should has x and y at the specified location", ->
        amount = 10
        rectangle.move("n", amount)
                  .isAt(recAttrs.x, recAttrs.y - amount)
                  .should.be.true
        rectangle.move("s", amount)
                  .isAt(recAttrs.x, recAttrs.y)
                  .should.be.true
        rectangle.move("e", amount)
                  .isAt(recAttrs.x+amount, recAttrs.y)
                  .should.be.true
        rectangle.move("w", amount)
                  .isAt(recAttrs.x, recAttrs.y)
                  .should.be.true

      it "should move Box2D position as well", ->
        amount = 30
        SCALE = Crafty.Box2D.SCALE
        rectangle.move("n", amount)
                  .body.GetPosition()
                  .should.eql
                    x:recAttrs.x/SCALE
                    y:(recAttrs.y - amount)/SCALE

    describe ".shift(x, y, w, h)", ->
    describe ".attach(Entity obj[, .., Entity objN])", ->
      it "should move the follower", ->
        attrs = {x:200, y: 200, w:50, h: 50}
        follower = Crafty.e("Box2D").attr(attrs)
        amount = 30
        rectangle.attach(follower).move("n", amount)
        follower.y.should.equal attrs.y - amount

    describe ".detach(obj)", ->
    describe ".origin(x, y)", ->
    describe ".flip(dir)", ->
    describe ".rotate(e)", ->
      


