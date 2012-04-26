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
      ent.destroy()
      Crafty.Box2D.destroy()

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

    it "should not create a new body when .attr is called again with x and y", ->

    it "should change position when changing x or y", ->
      attrs = {x: 30, y: 30}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      ent.x = 60
      ent.body.GetPosition().x.should.equal 60/SCALE
      ent.body.GetPosition().y.should.equal attrs.y/SCALE
      ent.x = 80
      ent.y = 70
      ent.body.GetPosition().x.should.equal 80/SCALE
      ent.body.GetPosition().y.should.equal 70/SCALE

    it "should only set new position when body exists", ->
      attrs = {x: 30, y: 30}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      Crafty.Box2D.world.GetBodyCount().should.equal 1
      ent.attr {x: 50, y: 50}
      Crafty.Box2D.world.GetBodyCount().should.not.equal 2
      Crafty.Box2D.world.GetBodyCount().should.equal 1
      ent.body.GetPosition().x.should.equal 50/SCALE
      ent.body.GetPosition().y.should.equal 50/SCALE

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

    it "should have the correct radius", ->
      attrs = {x:1800, y: 250, r:30}
      ent.attr attrs
      ent.r.should.equal attrs.r

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
    SCALE = 0

    beforeEach ->
      rectangle = Crafty.e("Box2D").attr recAttrs
      circle = Crafty.e("Box2D").attr cirAttrs
      SCALE = Crafty.Box2D.SCALE

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
    describe ".isAt(x, y) #used for below tests", ->
      it "should check for both 2D and Box2D", ->
        # This test would ensure the usage of isAt will cover Box2D also
        # Any tests below using .isAt will not need to check for both.
        rectangle.isAt(recAttrs.x, recAttrs.y).should.be.true
        rectangle.body.GetPosition().x.should.equal (recAttrs.x)/SCALE
        rectangle.body.GetPosition().y.should.equal (recAttrs.y)/SCALE

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

    describe ".shift(x, y, w, h)", ->
      it "should move the entity by an amount in specified direction", ->
        rectangle.shift(10)
                  .isAt(recAttrs.x+10, recAttrs.y)
                  .should.be.true

        rectangle.shift(-10)
                  .isAt(recAttrs.x, recAttrs.y)
                  .should.be.true

        rectangle.shift(-10,10)
                  .isAt(recAttrs.x-10, recAttrs.y+10)
                  .should.be.true

      it "should change width and/or height for rectangle", ->
        rectangle.shift(0,0,10).w.should.equal recAttrs.w+10

        # There is no scaling with Box2D, so to scale, we have to
        # remove the initial shape, then add a new one.
        vertices = rectangle.body.GetFixtureList().GetShape().GetVertices()
        w = (recAttrs.w + 10) / SCALE
        h = recAttrs.h / SCALE
        # Note: vertices are in local cordinates
        vertices[0].should.eql {x: 0, y: 0}
        vertices[1].should.eql {x: w, y: 0}
        vertices[2].should.eql {x: w, y: h}
        vertices[3].should.eql {x: 0, y: h}

        rectangle.shift(0,0,-10).w.should.equal recAttrs.w
        vertices = rectangle.body.GetFixtureList().GetShape().GetVertices()
        w = (recAttrs.w) / SCALE
        h = recAttrs.h / SCALE
        # Note: vertices are in local cordinates
        vertices[0].should.eql {x: 0, y: 0}
        vertices[1].should.eql {x: w, y: 0}
        vertices[2].should.eql {x: w, y: h}
        vertices[3].should.eql {x: 0, y: h}

        rectangle.shift(0,0,-10, 10).w.should.equal recAttrs.w-10
        rectangle.h.should.equal recAttrs.h+10
        vertices = rectangle.body.GetFixtureList().GetShape().GetVertices()
        w = (recAttrs.w - 10) / SCALE
        h = (recAttrs.h + 10) / SCALE
        # Note: vertices are in local cordinates
        vertices[0].should.eql {x: 0, y: 0}
        vertices[1].should.eql {x: w, y: 0}
        vertices[2].should.eql {x: w, y: h}
        vertices[3].should.eql {x: 0, y: h}

      it "should change radius for circle", ->
        circle.shift(0,0,30).r.should.equal cirAttrs.r+30
        # @w will become 100+30, @h is still 100
        # Received attr = {_w: 100, _h: 100}
        circle.body.GetFixtureList().GetShape().GetRadius()
                    .should.equal (cirAttrs.r+30)/SCALE

      it "should only shift the third param for radius", ->
        circle.shift(0,0,30,60).r.should.equal cirAttrs.r+30
        # Both events for w and h will be fired.
        # First is  {_w: 100, _h: 100} (@w = 130, @h=100) 
        # Then {_w: 130, _h: 100} (@w = 130, @h=160)
        circle.body.GetFixtureList().GetShape().GetRadius()
                    .should.equal (cirAttrs.r+30)/SCALE

        # Never care about the third param
        circle.shift(0,0,0,60).r.should.equal cirAttrs.r+30
        circle.body.GetFixtureList().GetShape().GetRadius()
                    .should.equal (cirAttrs.r+30)/SCALE

      it "should set new width and height for circle", ->
        circle.shift(0,0,30).w.should.equal (cirAttrs.r+30)*2
        circle.h.should.equal (cirAttrs.r+30)*2

      it "should not set new width and height for circle when no third param", ->
        circle.shift(0,0,0,30).w.should.equal cirAttrs.r*2
        circle.h.should.equal cirAttrs.r*2

    describe ".attach(Entity obj[, .., Entity objN])", ->
      it "should move the follower", ->
        attrs = {x:200, y: 200, w:50, h: 50}
        follower = Crafty.e("Box2D").attr(attrs)
        amount = 30

        rectangle.attach(follower).move("n", amount)
        follower.isAt(attrs.x, attrs.y - amount).should.be.true

    describe ".detach(obj)", ->
      it "should stop following the rectangle", ->
        attrs = {x:200, y: 200, w:50, h: 50}
        follower = Crafty.e("Box2D").attr(attrs)
        amount = 30

        rectangle.attach(follower).move("n", amount)
        follower.isAt(attrs.x, attrs.y - amount).should.be.true

        rectangle.detach(follower).move("n", amount)
        follower.isAt(attrs.x, attrs.y - amount).should.be.true

    describe ".origin(x, y)", ->
    describe ".flip(dir)", ->
    describe ".rotate(e)", ->
      
  describe "creation helpers (.circle, .rectangle, ...)", ->
    it "should ignore when @body is not defined", ->
      ent = Crafty.e("Box2D").circle(10)
      should.not.exist ent.body
      ent.rectangle(10, 15)
      should.not.exist ent.body

  describe "Collision", ->
    it "should store entity's id to body's user data", ->
      ent = Crafty.e("Box2D").attr({x: 30, y: 30, r: 30})
      ent.body.GetUserData().should.equal ent[0]

    describe ".onHit(compopent, beginContact, endContact)", ->
      it "should only check with other Box2D entity", ->
        ent = Crafty.e("Box2D").attr({x: 30, y: 30, r: 30})


