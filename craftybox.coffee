b2Vec2 = Box2D.Common.Math.b2Vec2
{b2BodyDef, b2Body, b2FixtureDef, b2Fixture, b2World, b2DebugDraw} = Box2D.Dynamics
{b2AABB, Shapes: {b2MassData, b2PolygonShape, b2CircleShape}} = Box2D.Collision

###
# #Crafty.Box2D
# @category Physics
# Dealing with Box2D
###
Crafty.extend
  Box2D:
    ###
    # #Crafty.Box2D.world
    # @comp Crafty.Box2D
    # This will return the Box2D world object,
    # which is a container for bodies and joints.
    ###
    world: null
    debug: false

    ###
    # #Crafty.Box2D.init
    # @comp Crafty.Box2D
    # @sign public void Crafty.Box2D.init(void)
    # Create a Box2D world. Must be called before any entities
    # with the Box2D component can be created
    ###
    init: (gravityX=0, gravityY=10, @SCALE=30, doSleep=true) ->
      ###
      # The world AABB should always be bigger then the region 
      # where your bodies are located. It is better to make the
      # world AABB too big than too small. If a body reaches the
      # boundary of the world AABB it will be frozen and will stop simulating.
      ###
      AABB = new b2AABB
      AABB.lowerBound.Set -100.0, -100.0
      AABB.upperBound.Set Crafty.viewport.width+100.0, Crafty.viewport.height+100.0
      @world = new b2World(AABB, new b2Vec2(gravityX, gravityY), doSleep)

      Crafty.bind "EnterFrame", =>
        # TODO: Integrate Step with Crafty rendering framerate
        @world.Step(1/60, 10, 10)
        @world.DrawDebugData() if @debug
        @world.ClearForces()

      if Crafty.support.canvas
        canvas = document.createElement "canvas"
        canvas.id = "Box2DCanvasDebug"
        canvas.width = Crafty.viewport.width
        canvas.height = Crafty.viewport.height
        canvas.style.position = 'absolute'
        canvas.style.left = "0px"
        canvas.style.top = "0px"

        Crafty.stage.elem.appendChild canvas

        debugDraw = new b2DebugDraw()
        debugDraw.SetSprite canvas.getContext('2d')
        debugDraw.SetDrawScale @SCALE
        debugDraw.SetFillAlpha 0.7
        debugDraw.SetLineThickness 1.0
        debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_joinBit)
        @world.SetDebugDraw debugDraw
        @debug = true


###
# #Box2D
# @category Physics
# Creates itself in a Box2D World. Crafty.Box2D.init() will be automatically called
# if it is not called already (hence the world element doesn't exist).
# In order to create a Box2D object, a body definition of position and dynamic is need.
# The world will use this bodyDef to create a body. A fixture definition with geometry,
# friction, density, etc is also required. Then create shapes on the body.
###
Crafty.c "Box2D",
  body: null

  init: ->
    @requires "2D"
    Crafty.Box2D.init() if not Crafty.Box2D.world?

    bodyDef = new b2BodyDef
    bodyDef.type = b2Body.b2_staticBody
    bodyDef.position.Set(@_x/Crafty.Box2D.SCALE, @_y/Crafty.Box2D.SCALE);

    @body = Crafty.Box2D.world.CreateBody(bodyDef)

    fixDef = new b2FixtureDef
    fixDef.shape = new b2PolygonShape
    fixDef.density = 1.0
    fixDef.friction = 0.5
    fixDef.restitution = 0.1
    fixDef.shape.SetAsBox(10.0, 10.0)
    @body.CreateFixture(fixDef)
    @