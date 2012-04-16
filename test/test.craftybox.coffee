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

  describe "when entity is moving", ->
    it "should move 2D component as well", ->
      ###attrs = {x:1800, y: 250, w:1800, h:30, dynamic:true}
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
          done()###
      


