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
    # It will have 0 gravity when initialized.
    # Gravity can be set through a setter:
    # Crafty.Box2D.gravity = {x: 0, y:10}
    ###
    world: null

    ###
    # #Crafty.Box2D.debug
    # @comp Crafty.Box2D
    # This will determine whether to use Box2D's own debug Draw
    ###
    debug: false

    ###
    # #Crafty.Box2D.init
    # @comp Crafty.Box2D
    # @sign public void Crafty.Box2D.init(params)
    # @param options: An object contain settings for the world
    # Create a Box2D world. Must be called before any entities
    # with the Box2D component can be created
    ###
    init: (options) ->
      gravityX = options?.gravityX ? 0
      gravityY = options?.gravityY ? 0
      @SCALE = options?.scale ? 30
      doSleep = options?.doSleep ? true

      _world = new b2World(new b2Vec2(gravityX, gravityY), doSleep)

      @__defineSetter__('gravity', (v) -> _world.SetGravity(new b2Vec2(v.x, v.y)))

      Crafty.bind "EnterFrame", =>
        _world.Step(1/Crafty.timer.getFPS(), 10, 10)
        _world.DrawDebugData() if @debug
        _world.ClearForces()

      # Setting up debug draw. Setting @debug outside will trigger drawing
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
        _world.SetDebugDraw debugDraw

      @world = _world

    ###
    # #Crafty.Box2D.destroy
    # @comp Crafty.Box2D
    # @sign public void Crafty.Box2D.destroy(void)
    # Destroy all the bodies in the world.
    ###
    destroy: ->
      while (body = @world.GetBodyList())?
        @world.DestroyBody(body)
        body = body.GetNext()

###
# #Box2D
# @category Physics
# Creates itself in a Box2D World. Crafty.Box2D.init() will be automatically called
# if it is not called already (hence the world element doesn't exist).
# In order to create a Box2D object, a body definition of position and dynamic is need.
# The world will use this bodyDef to create a body. A fixture definition with geometry,
# friction, density, etc is also required. Then create shapes on the body.
# The body will be created during the .attr call instead of init.
###
Crafty.c "Box2D",
  ###
  #.body
  @comp Box2D
  The `b2Body` from Box2D, created by `Crafty.Box2D.world` during `.attr({x, y})` call.
  Shape can be attached to it if more params added to `.attr` call, or through
  `.circle`, `.rectangle`, or `.polygon` method.
  ###
  body: null

  init: ->
    @addComponent "2D"
    Crafty.Box2D.init() if not Crafty.Box2D.world?
    SCALE = Crafty.Box2D.SCALE

    ###
    Box2D entity is created by calling .attr({x, y, w, h}) or .attr({x, y, r}).
    That funnction triggers "Change" event for us to set box2d attributes.
    ###
    @bind "Change", (attrs) =>
      return if not attrs?
      if @body?
        # When individual attributes are set through 2d._attr(), which always
        # send {_x, _y, _w, _h}, the attributes before change.
        if attrs._x isnt @x or attrs._y isnt @y
          # When changing position
          @body.SetPosition(new b2Vec2(@x/SCALE, @y/SCALE))
        
        if (newW = attrs._w isnt @w) or (newH = attrs._h isnt @h)
          # Reseting w and h is to resize, but Box2D does not scale.
          # When resizing, need to destroy initial shape, then add a new one

          if not @r?
            @rectangle @w / SCALE, @h / SCALE

          else if newW
            # Shifting circle radius will only take the third param, which is the _w
            # or the _h if _w is not change. The other param is ignored.
            # See test cases for examples.
            @r += @w-attrs._w
            @circle(@r)

          else
            ## When being a circle but a new height is being set
            ## Set test cases for more detail
            @_w = attrs._w
            @_h = attrs._h

      else if attrs.x? and attrs.y?
        # Creating a new body requires both x and y, and  ( (w and h) or r)
        bodyDef = new b2BodyDef
        bodyDef.type = if attrs.dynamic? and attrs.dynamic then b2Body.b2_dynamicBody else b2Body.b2_staticBody
        bodyDef.position.Set attrs.x/SCALE, attrs.y/SCALE
        @body = Crafty.Box2D.world.CreateBody bodyDef

        @fixDef = new b2FixtureDef          
        @fixDef.density = attrs.density ? 1.0
        @fixDef.friction = attrs.friction ? 0.5
        @fixDef.restitution = attrs.restitution ? 0.2

        if attrs.r?
          @circle(attrs.r)

        else if attrs.w? or attrs.h?
          # Need to set same @w or same @h if only one param is provided
          w = (@w = attrs.w ? attrs.h) / SCALE
          h = (@h = attrs.h ? attrs.w) / SCALE
          @rectangle w, h

    ###
    Update the entity by using Box2D's attributes.
    ###
    @bind "EnterFrame", =>
      if @body? and @body.IsAwake()
        pos = @body.GetPosition()
        # Not use setters to avoid Change event
        @_x = pos.x*SCALE
        @_y = pos.y*SCALE
        @rotation = Crafty.math.radToDeg @body.GetAngle()

    ###
    Remove the body from world before destroying this entity
    ###
    @bind "Remove", =>
      Crafty.Box2D.world.DestroyBody(@body) if @body?

  ###
  #.circle
  @comp Box2D
  @sign public this .circle(Number radius)
  @param radius - The radius of the circle to create
  Attach a circle shape to entity's existing body.
  @example 
  ~~~
  this.attr({x: 10, y: 10, r:10}) // called internally
  this.attr({x: 10, y: 10}).circle(10) // called explicitly
  ~~~
  ###
  circle: (radius) ->
    return @ if not @body?
    SCALE = Crafty.Box2D.SCALE
    # Remove any old fixture
    if @body.GetFixtureList()?
      @body.DestroyFixture @body.GetFixtureList()

    # Not use setters to avoid Change event
    @_w = @_h = radius*2
    @fixDef.shape = new b2CircleShape radius/SCALE
    @fixDef.shape.SetLocalPosition new b2Vec2 @w/SCALE/2, @h/SCALE/2
    @body.CreateFixture @fixDef
    @

  ###
  #.rectangle
  @comp Box2D
  @sign public this .rectangle(Number w, Number h)
  @param w - The width of the rectangle to create
  @param h - The height of the rectangle to create
  Attach a rectangle or square shape to entity's existing body.
  @example 
  ~~~
  this.attr({x: 10, y: 10, w:10, h: 15}) // called internally
  this.attr({x: 10, y: 10}).rectangle(10, 15) // called explicitly
  this.attr({x: 10, y: 10}).rectangle(10, 10) // a square
  this.attr({x: 10, y: 10}).rectangle(10) // also square!!!
  ~~~
  ###
  rectangle: (w, h) ->
    return @ if not @body?
    h = h ? w
    SCALE = Crafty.Box2D.SCALE
    # Remove any old fixture
    if @body.GetFixtureList()?
      @body.DestroyFixture @body.GetFixtureList()

    @fixDef.shape = new b2PolygonShape
    @fixDef.shape.SetAsOrientedBox w/2, h/2, new b2Vec2 w/2, h/2
    @body.CreateFixture @fixDef
    @

