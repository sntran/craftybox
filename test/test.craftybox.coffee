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

  describe "creating shape", ->
    SCALE = null
    ent = null

    before ->
      Crafty.Box2D.init()
      SCALE = Crafty.Box2D.SCALE

    beforeEach ->
      ent = Crafty.e("Box2D")

    describe "rectangle", ->
      it "should create the body", ->
        should.exist ent.rectangle(10, 10).body

      it "should use entity's position if any to create body", ->
        ent.attr({x: 10, y: 10})
        ent.rectangle(15, 15)
        should.exist ent.body
        pos = ent.body.GetPosition()
        pos.x.should.equal ent.x/SCALE
        pos.y.should.equal ent.y/SCALE

      it "should set to 0,0 if no entity's position", ->
        ent.rectangle(15, 15)
        should.exist ent.body
        pos = ent.body.GetPosition()
        pos.x.should.equal 0
        pos.y.should.equal 0

      it "should set entity's x and y if no body", ->
        ent.rectangle(15, 15, 10, 10)
        ent.x.should.equal 10
        ent.y.should.equal 10

      it "should take a width and height and make the rectangle fixture", ->
        w = 30
        h = 15
        ent.rectangle(w, h)
        shape = ent.body.GetFixtureList().GetShape()
        shape.should.be.an.instanceof(b2PolygonShape)
        shape.GetVertexCount().should.equal 4
        vertices = shape.GetVertices()

        w = w/SCALE
        h = h/SCALE    
        # Note: vertices are in local cordinates
        # Origin is at the top left
        #  0,0 --- 0 --- v1
        #  |             |
        #  |             |
        #  |             |
        #  v3 --- 0 --- v4
        vertices[0].should.eql {x: 0, y: 0}
        vertices[1].should.eql {x: w, y: 0}
        vertices[2].should.eql {x: w, y: h}
        vertices[3].should.eql {x: 0, y: h}

      it "should set the width and height of entity", ->
        w = 30
        h = 15
        ent.rectangle w, h
        ent.w.should.equal w
        ent.h.should.equal h

      it "should allow setting density property", ->
        density = 1.0
        ent.rectangle(30, 15, 10, 10, {density: density})
        fixture = ent.body.GetFixtureList()
        fixture.GetDensity().should.equal(density)

      it "should allow setting any other properties", ->
        attrs = 
          friction: 0.5
          restitution: 0.2
          isSensor: true
          userData: ent
          filter:
            categoryBits: 0x0001
            maskBits: 0x0001
            groupIndex: 0

        ent.rectangle(30, 15, 10, 10, attrs)
        fixture = ent.body.GetFixtureList()
        fixture.GetFriction().should.equal(attrs.friction)
        fixture.GetRestitution().should.equal(attrs.restitution)
        fixture.IsSensor().should.equal(attrs.isSensor)
        fixture.GetUserData().should.eql(attrs.userData)
        fixture.GetFilterData().should.eql(attrs.filter)


      it "should also allow setting properties without x and y", ->
        attrs = 
          friction: 0.5
          restitution: 0.2
          isSensor: true
          userData: ent
          filter:
            categoryBits: 0x0001
            maskBits: 0x0001
            groupIndex: 0

        ent.rectangle(30, 15, attrs)
        fixture = ent.body.GetFixtureList()
        fixture.GetFriction().should.equal(attrs.friction)
        fixture.GetRestitution().should.equal(attrs.restitution)
        fixture.IsSensor().should.equal(attrs.isSensor)
        fixture.GetUserData().should.eql(attrs.userData)
        fixture.GetFilterData().should.eql(attrs.filter)

    describe "circle", ->
      it "should create the body", ->
        should.exist ent.circle(10).body

      it "should use entity's position if any to create body", ->
        ent.attr {x: 10, y: 10}
        ent.circle 15
        should.exist ent.body
        pos = ent.body.GetPosition()
        pos.x.should.equal ent.x/SCALE
        pos.y.should.equal ent.y/SCALE

      it "should set to 0,0 if no entity's position", ->
        ent.circle(15)
        should.exist ent.body
        pos = ent.body.GetPosition()
        pos.x.should.equal 0
        pos.y.should.equal 0

      it "should set entity's x and y if no body", ->
        ent.circle(15, 10, 10)
        ent.x.should.equal 10
        ent.y.should.equal 10

      it "should take a radius and make a circle shape", ->
        r = 30
        ent.circle r
        shape = ent.body.GetFixtureList().GetShape()
        shape.should.be.an.instanceof(b2CircleShape)
        shape.GetRadius().should.equal(r/SCALE)

      it "should set width and height of entity", ->
        r = 30
        ent.circle r
        ent.w.should.equal r*2
        ent.h.should.equal r*2

      it "should have its local position at its center", ->
        r = 30
        ent.circle r
        localPosition = ent.body.GetFixtureList().GetShape().GetLocalPosition()
        localPosition.x.should.equal (ent.x + r)/SCALE
        localPosition.y.should.equal (ent.y + r)/SCALE

      it "should allow setting density property", ->
        density = 1.0
        ent.circle(30, 10, 10, {density: density})
        fixture = ent.body.GetFixtureList()
        fixture.GetDensity().should.equal(density)

      it "should allow setting any other properties", ->
        attrs = 
          friction: 0.5
          restitution: 0.2
          isSensor: true
          userData: ent
          filter:
            categoryBits: 0x0001
            maskBits: 0x0001
            groupIndex: 0

        ent.circle(30, 10, 10, attrs)
        fixture = ent.body.GetFixtureList()
        fixture.GetFriction().should.equal(attrs.friction)
        fixture.GetRestitution().should.equal(attrs.restitution)
        fixture.IsSensor().should.equal(attrs.isSensor)
        fixture.GetUserData().should.eql(attrs.userData)
        fixture.GetFilterData().should.eql(attrs.filter)


      it "should also allow setting properties without x and y", ->
        attrs = 
          friction: 0.5
          restitution: 0.2
          isSensor: true
          userData: ent
          filter:
            categoryBits: 0x0001
            maskBits: 0x0001
            groupIndex: 0

        ent.circle(30, attrs)
        fixture = ent.body.GetFixtureList()
        fixture.GetFriction().should.equal(attrs.friction)
        fixture.GetRestitution().should.equal(attrs.restitution)
        fixture.IsSensor().should.equal(attrs.isSensor)
        fixture.GetUserData().should.eql(attrs.userData)
        fixture.GetFilterData().should.eql(attrs.filter)
   
    describe "polygon", ->
      it "should create the body", ->
        should.exist ent.polygon([[30,30], [60,60], [0,0]]).body

      it "should take an array of points in clockwise order by default", ->
        ###
           --->
            __
          x/  |
          |___|
        ###
        points = [[0,30], [30, 0], [60,0], [60,60], [0, 60]]
        ent.polygon points
        shape = ent.body.GetFixtureList().GetShape()
        shape.should.be.an.instanceof(b2PolygonShape)
        shape.GetVertexCount().should.equal points.length
        vertices = shape.GetVertices()
        for v, i in vertices
          v.x.should.equal(points[i][0]/SCALE)
          v.y.should.equal(points[i][1]/SCALE)

      it "should also take an array of points in anti-clockwise order", ->
        ###
             __
        |  x/  |
        V  |___|

        By default, Box2D will draw, but it won't collide.
        As long as the points forming a convex polygon,
        reorder to be clock-wise.
        ###
        points = [[0,30], [0,60], [60,60], [60, 0], [30, 0]]
        ent.polygon points
        shape = ent.body.GetFixtureList().GetShape()
        shape.should.be.an.instanceof(b2PolygonShape)
        shape.GetVertexCount().should.equal points.length
        vertices = shape.GetVertices()

        points = [[0,30], [30, 0], [60,0], [60,60], [0, 60]]
        for v, i in vertices
          v.x.should.equal(points[i][0]/SCALE)
          v.y.should.equal(points[i][1]/SCALE)

      it "should also take arbitrary order of points", ->
        ###
              /|
           __/ |
          | /\ | 
          |/  \|

        By default, Box2D will draw, but it won't collide correctly.
        The middle point will be ignored. It will become like this:

             / | 
           /   |
          |    | 
          |____|
        ###
        points = [[0,30], [0,60], [30,0], [30, 60], [15,30]]
        ent.polygon points
        shape = ent.body.GetFixtureList().GetShape()
        shape.should.be.an.instanceof(b2PolygonShape)

        points = [[0,30], [30,0], [30,60], [0,60]]
        shape.GetVertexCount().should.equal points.length
        vertices = shape.GetVertices()
        for v, i in vertices
          v.x.should.equal(points[i][0]/SCALE)
          v.y.should.equal(points[i][1]/SCALE)

      describe "with minimal area enclosing rectangle", ->
        rotate = (point, rad, origin) ->
          result = []
          offX = point[0] - origin[0]
          offY = point[1] - origin[1]
          result[0] = Math.cos(rad) * offX - Math.sin(rad) * offY + origin[0]
          result[1] = Math.sin(rad) * offX + Math.cos(rad) * offY + origin[1]
          return result

        getMiddlePoint = (i, a) ->
          [ 
            (a[ (i+1)%a.length ][0] - a[i][0]) / 2 + a[i][0]
            (a[ (i+1)%a.length ][1] - a[i][1]) / 2 + a[i][1] 
          ]

        getSide = (i, a) ->
          d = Crafty.math.distance
          Math.round(d(a[i][0], a[i][1], a[(i+1)%a.length][0], a[(i+1)%a.length][1]))

        maer = {}

        beforeEach ->
          x = 60
          y = 60
          w = 60
          h = 30
          rotation = -Math.PI/4
          aabb = [[x,y], [x+w,y], [x+w,y+h], [x,y+h]]
          origin = [x+(w/2), y+(h/2)]
          ### Rotate the AABB around its origin ###
          maer.vertices = (rotate point, rotation, origin for point in aabb)
          maer.w = w
          maer.h = h
          sides = (getSide i, maer for point, i in maer)
          
        it "should set width and height of entity for polygon same as MAER", ->
          ###          
          The simplest polygon enclosed by the MAER is the MAER itself
          ###
          ent.w.should.equal 0
          ent.h.should.equal 0
          points = maer.vertices
          ent.polygon points
          ent.w.should.equal maer.w
          ent.h.should.equal maer.h                                                  

        it "should set entity's x and y after calculating the polygon"

        it "should also reset entity's x and y when MAER is not MBR", ->
          ###
             --->
               ___
              /   \
            x/     \
              \    /
                \ /
          
          Since Crafty's entity uses x, y as top-left corner, need to
          reset it based on the MAER. In this case, the MAER is not 
          the same as MBR, and thus the x, y are different.
          ###
          ent.x.should.equal 0
          ent.y.should.equal 0
          points = [[0,30], [30,0], [60,0], [90,30], [60,60]]
          ent.polygon points
          ent.x.should.not.equal 0
          ent.y.should.not.equal 0

      it "should have the x and y as the least rotating point from AABB"

      it "should break concave-forming points into convex fixtures"


    describe "mix and match", ->
      ###
      The order of fixtures in body is LIFO
      ###
      it "should have many shapes of same fixture", ->
        ent.rectangle(10, 10)
        fixture = ent.body.GetFixtureList()
        should.exist fixture
        fixture.GetShape().should.be.an.instanceof(b2PolygonShape)
        should.not.exist fixture.GetNext()

        ent.rectangle(15, 15)
        fixture = ent.body.GetFixtureList()
        should.exist fixture
        fixture.GetShape().should.be.an.instanceof(b2PolygonShape)
        fixture = fixture.GetNext()
        should.exist fixture
        fixture.GetShape().should.be.an.instanceof(b2PolygonShape)

      it "should have many shapes of different fixture", ->
        ent.rectangle(10, 10)
        fixture = ent.body.GetFixtureList()
        should.exist fixture
        fixture.GetShape().should.be.an.instanceof(b2PolygonShape)
        should.not.exist fixture.GetNext()

        ent.circle(15)
        fixture = ent.body.GetFixtureList()
        should.exist fixture
        fixture.GetShape().should.be.an.instanceof(b2CircleShape)
        fixture = fixture.GetNext()
        should.exist fixture
        fixture.GetShape().should.be.an.instanceof(b2PolygonShape)

      it "should not reset entity's x and y when body exist", ->
        ent.rectangle(10, 10, 15, 15)
        ent.rectangle(10, 10, 30, 30)
        ent.x.should.equal 15
        ent.y.should.equal 15

      it "should have different shapes with different properties", ->
        friction = 0.5
        density = 0.2
        isSensor = true

        ent.rectangle(10, 10, {friction: friction, density: density})
        fixture = ent.body.GetFixtureList()
        fixture.GetFriction().should.equal friction
        fixture.GetDensity().should.equal density
        fixture.IsSensor().should.not.be.ok

        newDensity = 0.7
        ent.circle(10, {density: newDensity, isSensor: isSensor})
        fixture = ent.body.GetFixtureList()
        fixture.GetFriction().should.equal friction
        fixture.GetDensity().should.equal newDensity
        fixture.IsSensor().should.be.ok

  describe "setting body attributes", ->
    SCALE = null
    ent = null

    before ->
      Crafty.Box2D.init()
      SCALE = Crafty.Box2D.SCALE

    beforeEach ->
      ent = Crafty.e("Box2D").rectangle(10, 10)

    it "could check the body type", ->
      ent.bodyType().should.equal "static"
      ent.body.GetType().should.equal b2Body.b2_staticBody

    it "could change type", ->      
      ent.bodyType "dynamic"
      ent.body.GetType().should.equal b2Body.b2_dynamicBody
      ent.bodyType().should.equal "dynamic"

    it "should not change to invalid type", ->
      type = ent.bodyType()
      ent.bodyType("something_weird").bodyType().should.equal type

  describe "apply setting to all fixtures", ->

  ###describe "2D Component", ->
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
    describe ".rotate(e)", ->###


