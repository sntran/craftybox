b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB
{b2BodyDef, b2Body, b2FixtureDef, b2Fixture, b2World, b2DebugDraw} = Box2D.Dynamics
{b2MassData, b2PolygonShape, b2CircleShape} = Box2D.Collision.Shapes

SCALE = 30

exports.init = ->
	Crafty.c "Box2DWorld",
		_gravity: new b2Vec2(0, 10)
		_sleeping: true
		_world: null
		init: ->
			@requires "Canvas"

			if Crafty.support.setter
				@__defineSetter__('gravity', (v)->@_gravity = v)
				@__defineSetter__('sleeping', (v)->@_sleeping = v)

				@__defineGetter__('gravity', ()->@_gravity)
				@__defineGetter__('sleeping', ()->@_sleeping)
				@__defineGetter__('world', ()->@_world)

			@_world = new b2World(@gravity, @sleeping)
			@_setDebugDraw()

			@bind "EnterFrame", (e) ->
				@world.Step(1/60, 10, 10)
				@world.DrawDebugData()
				@world.ClearForces()

		create: (box2DEntity) ->
			@world.CreateBody(box2DEntity.body)
				.CreateFixture(box2DEntity.fixture)

		_setDebugDraw: ->
			debugDraw = new b2DebugDraw()
			debugDraw.SetSprite(Crafty.canvas.context)
			debugDraw.SetDrawScale(SCALE)
			debugDraw.SetFillAlpha(0.3)
			debugDraw.SetLineThickness(1.0)
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_joinBit)
			@world.SetDebugDraw(debugDraw)

	Crafty.c "Box2D",
		### 
		Fixture Definition defines the attributes of the object,
		such as density, friction, and the restitution (bounciness)
		###
		_fixDef: null
		###
		Body Definition defines where in the world the object is,
		and if it is dynamic (reacts to things) or static.
		A Body Definition's position is set to the middle center
		point of the object, not upper left.
		###
		_bodyDef: null

		init: ->
			@_fixDef = new b2FixtureDef
			@_bodyDef = new b2BodyDef

			if Crafty.support.setter
				@__defineSetter__('x', (v)->@_bodyDef.position.x = v)
				@__defineSetter__('y', (v)->@_bodyDef.position.y = v)
				@__defineSetter__('dynamic', (v)->
						@_bodyDef.type = b2Body[(if v then "b2_dynamicBody" else "b2_staticBody")]
					)
				@__defineSetter__('density', (v)->@_fixDef.density = v)
				@__defineSetter__('friction', (v)->@_fixDef.friction = v)
				@__defineSetter__('restitution', (v)->@_fixDef.restitution = v)
				@__defineSetter__('shape', (v)->@_fixDef.shape = v)
				
				@__defineGetter__('body', () -> @_bodyDef)
				@__defineGetter__('fixture', () -> @_fixDef)
				@__defineGetter__('x', ()-> @_bodyDef.position.x)
				@__defineGetter__('y', ()-> @_bodyDef.position.y)
				@__defineGetter__('dynamic', ()-> @_bodyDef.type is b2Body.b2_dynamicBody)
				@__defineGetter__('density', ()-> @_fixDef.density)
				@__defineGetter__('friction', ()-> @_fixDef.friction)
				@__defineGetter__('restitution', ()-> @_fixDef.restitution)
				@__defineGetter__('shape', ()-> @_fixDef.shape)
			
			@density = 1.0
			@friction = 0.5
			@restitution = 0.1

		rectangle: (halfWidth, halfLength) ->
			@shape = new b2PolygonShape
			@shape.SetAsBox(halfWidth, halfLength)
			@

		polygon: (poly) ->
			if (arguments.length > 1)
				poly = Array.prototype.slice.call(arguments, 0)

			@points = @_toBox2DPoly(poly)

			@shape = new b2PolygonShape
			@shape.SetAsArray(@points, @points.length)
			@

		###
		# @sign private Object ._toBox2DPoly(list)
		# @param list - the list of vertices, in form [[x1,y1],[x2,y2]]
		# Convert crafty-format poly into box2D-format b2Vec2
		# [{x: x1, y: y1}, {x: x2, y: y2}]
		###
		_toBox2DPoly: (list) ->
			convert = (point) -> vec = new b2Vec2(point[0], point[1])
			(convert item for item in list)
			#TO-DO: Convert from Box2D unit to pixel