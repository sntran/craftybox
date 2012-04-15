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

      halfWidth = attrs.w/SCALE/2
      halfHeight = attrs.h/SCALE/2     
      # Note: vertices are in local cordinates
      vertices[0].should.eql {x: -halfWidth, y: -halfHeight}
      vertices[1].should.eql {x: halfWidth, y: -halfHeight}
      vertices[2].should.eql {x: halfWidth, y: halfHeight}
      vertices[3].should.eql {x: -halfWidth, y: halfHeight}

    it "should create a square with only w provided", ->
      attrs = {x:1800, y: 250, w:1800}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      shape = ent.body.GetFixtureList().GetShape()
      shape.should.be.an.instanceof(b2PolygonShape)
      shape.GetVertexCount().should.equal 4
      vertices = shape.GetVertices()

      halfSide = attrs.w/SCALE/2
      vertices[0].should.eql {x: -halfSide, y: -halfSide}
      vertices[1].should.eql {x: halfSide, y: -halfSide}
      vertices[2].should.eql {x: halfSide, y: halfSide}
      vertices[3].should.eql {x: -halfSide, y: halfSide}

    it "should create a square with only h provided", ->
      attrs = {x:1800, y: 250, h:1800}
      ent.attr attrs
      SCALE = Crafty.Box2D.SCALE
      shape = ent.body.GetFixtureList().GetShape()
      shape.should.be.an.instanceof(b2PolygonShape)
      shape.GetVertexCount().should.equal 4
      vertices = shape.GetVertices()

      halfSide = attrs.h/SCALE/2
      vertices[0].should.eql {x: -halfSide, y: -halfSide}
      vertices[1].should.eql {x: halfSide, y: -halfSide}
      vertices[2].should.eql {x: halfSide, y: halfSide}
      vertices[3].should.eql {x: -halfSide, y: halfSide}

    it "should create a circle with r provided", ->
      attrs = {x:1800, y: 250, r:30}
      ent.attr attrs
      shape = ent.body.GetFixtureList().GetShape()
      shape.should.be.an.instanceof b2CircleShape

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

