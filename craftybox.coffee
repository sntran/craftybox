b2Vec2 = Box2D.Common.Math.b2Vec2
{b2BodyDef, b2Body, b2FixtureDef, b2Fixture, b2World, b2DebugDraw, b2ContactListener} = Box2D.Dynamics
{b2AABB, b2WorldManifold, Shapes: {b2MassData, b2PolygonShape, b2CircleShape}} = Box2D.Collision

###
# #Crafty.Box2D
# @category Physics
# Dealing with Box2D
###
Crafty.extend
  Box2D: do ->
    ###
    PRIVATE
    ###

    _SCALE = 30

    ###
    # #Crafty.Box2D.world
    # @comp Crafty.Box2D
    # This will return the Box2D world object through a getter,
    # which is a container for bodies and joints.
    # It will have 0 gravity when initialized.
    # Gravity can be set through a setter:
    # Crafty.Box2D.gravity = {x: 0, y:10}
    ###
    _world = null

    ###
    A list of bodies to be destroyed in the next step. Usually during
    collision step, it's bad to destroy bodies. 
    ###
    _toBeRemoved = []

    ### 
    Setting up contact listener to notify the concerned entities
    based on the ids in their body's user data that we set during
    the construction of the body. We don't keep track of the contact
    but let the entities handle the collision.
    ###
    _setContactListener = ->
      
      contactListener = new b2ContactListener
      contactListener.BeginContact = (contact) ->
        entityIdA = contact.GetFixtureA().GetBody().GetUserData()
        entityIdB = contact.GetFixtureB().GetBody().GetUserData()

        ## Getting the contact points through manifold
        manifold = new b2WorldManifold()
        contact.GetWorldManifold manifold
        contactPoints = manifold.m_points

        # Crafty(id) will return the entity with that id.
        Crafty(entityIdA).trigger "BeginContact",
              points: contactPoints
              targetId: entityIdB
        Crafty(entityIdB).trigger "BeginContact", 
              points: contactPoints
              targetId: entityIdA

      contactListener.EndContact = (contact) ->
        entityIdA = contact.GetFixtureA().GetBody().GetUserData()
        entityIdB = contact.GetFixtureB().GetBody().GetUserData()

        Crafty(entityIdA).trigger "EndContact"
        Crafty(entityIdB).trigger "EndContact"

      _world.SetContactListener contactListener

    # Setting up debug draw. Setting @debug outside will trigger drawing
    _setDebugDraw = -> 
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
        debugDraw.SetSprite canvas.getContext '2d'
        debugDraw.SetDrawScale _SCALE
        debugDraw.SetFillAlpha 0.7
        debugDraw.SetLineThickness 1.0
        debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_joinBit
        _world.SetDebugDraw debugDraw


    ###
    PUBLIC
    ###

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
    init: ({gravityX, gravityY, scale, doSleep} = {}) ->
      gravityX = gravityX ? 0
      gravityY = gravityY ? 0
      _SCALE = scale ? 30
      doSleep = doSleep ? true

      _world = new b2World(new b2Vec2(gravityX, gravityY), doSleep)

      @__defineGetter__ 'world', () -> _world
      @__defineSetter__ 'gravity', (v) -> 
        _world.SetGravity new b2Vec2(v.x, v.y)

        body = _world.GetBodyList()
        while body?
          body.SetAwake(true)
          body = body.GetNext()

      @__defineGetter__ 'gravity', () -> _world.GetGravity()
      @__defineGetter__ 'SCALE', () -> _SCALE

      _setContactListener()

      # Update loop
      Crafty.bind "EnterFrame", =>
        _world.Step 1/Crafty.timer.getFPS(), 10, 10
        _world.DestroyBody body for body in _toBeRemoved
        _toBeRemoved = []
        _world.DrawDebugData() if @debug
        _world.ClearForces()

      _setDebugDraw()

    ###
    #Crafty.Box2D.destroy
    @comp Crafty.Box2D
    @sign public void Crafty.Box2D.destroy([b2Body body])
    @param body - The body to be destroyed. Destroy all if none
    Destroy all the bodies in the world. Internally, add to a list to destroy
    on the next step to avoid collision step.
    ###
    destroy: (body)->
      if body?
        _toBeRemoved.push body
      else
        body = _world.GetBodyList()
        while body?
          _toBeRemoved.push body
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
Crafty.c "Box2D", do ->
  ###
  PRIVATE
  ###

  _fixDef = null

  _createBody = ({x, y, w, h, r, poly, type, density, friction, restitution}) ->
    SCALE = Crafty.Box2D.SCALE
    # Creating a new body requires both x and y, and  ( (w and h) or r)
    bodyDef = new b2BodyDef
    bodyDef.type = b2Body["b2_#{type}Body"] if type? and type in ["static", "dynamic", "kinematic"]
    bodyDef.position.Set x/SCALE, y/SCALE
    @body = Crafty.Box2D.world.CreateBody bodyDef

    ###
    Set entity's id to body's user data.
    Needed for collision detection
    ###
    @body.SetUserData @[0]

    _fixDef = _fixDef ? new b2FixtureDef          
    _fixDef.density = density ? 1.0 # how heavy it is in relation to its area
    _fixDef.friction = friction ? 0.5 # how slippery it is
    _fixDef.restitution = restitution ? 0.2 # how bouncy the fixture is

    if r?
      _circle.call @, r

    else if w? or h?    
      # Need to set same @w or same @h if only one param is provided
      w = w ? h
      h = h ? w
      _rectangle.call @, w, h      

    else if poly?
      _polygon.call @, poly

  _circle = (radius) ->
    return if not @x or not @y
    SCALE = Crafty.Box2D.SCALE

    if not @body
      bodyDef = new b2BodyDef
      bodyDef.position.Set x/SCALE, y/SCALE
      @body = Crafty.Box2D.world.CreateBody bodyDef 

    # Not use setters to avoid Change event
    @_w = @_h = radius*2
    _fixDef.shape = new b2CircleShape radius/SCALE
    _fixDef.shape.SetLocalPosition new b2Vec2 @w/SCALE/2, @h/SCALE/2
    @body.CreateFixture _fixDef
    @

  _rectangle = (@w, @h) ->
    return if not @x or not @y
    SCALE = Crafty.Box2D.SCALE

    if not @body
      bodyDef = new b2BodyDef
      bodyDef.position.Set x/SCALE, y/SCALE
      @body = Crafty.Box2D.world.CreateBody bodyDef    

    _fixDef.shape = new b2PolygonShape
    _fixDef.shape.SetAsOrientedBox w/2/SCALE, h/2/SCALE, new b2Vec2 w/2/SCALE, h/2/SCALE
    @body.CreateFixture _fixDef
    @

  ###
  polygon([[50,0],[100,100],[0,100]])
  polygon([50,0],[100,100],[0,100])
  ###
  _polygon = (vertices) ->
    return if not @x or not @y
    SCALE = Crafty.Box2D.SCALE

    if not @body
      bodyDef = new b2BodyDef
      bodyDef.position.Set x/SCALE, y/SCALE
      @body = Crafty.Box2D.world.CreateBody bodyDef

    vertices = Array::slice.call(arguments, 0) if arguments.length > 1
    SCALE = Crafty.Box2D.SCALE
    _fixDef.shape = new b2PolygonShape
    convert = (pointAsArray) -> vec = new b2Vec2(pointAsArray[0]/SCALE, pointAsArray[1]/SCALE)
    poly = (convert vertex for vertex in vertices)
    _fixDef.shape.SetAsArray (convert vertex for vertex in vertices), vertices.length
    @body.CreateFixture _fixDef
    @


  ###
  PUBLIC
  ###

  ###
  #.body
  @comp Box2D
  The `b2Body` from Box2D, created by `Crafty.Box2D.world` during `.attr({x, y})` call.
  Shape can be attached to it if more params added to `.attr` call, or through
  `.circle`, `.rectangle`, or `.polygon` method.
  Those helpers also create a body if @x and @y available and no body was created.
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
      if attrs.x? and attrs.y?
        _createBody.call @, attrs

    ###
    This event is triggered when x,y,w or h changes, when physics body moves, or when entity
    is moved manually. To avoid conflict, we only allow manual movement when body is sleeping.
    Other components dealing with manual movement through inputs such as keyboard and mouse
    need to make it sleep before handling, then awake it when done.
    ###
    @bind "Move", ({_x, _y, _w, _h}) =>
      return if not @body? or (@body.GetType() is b2Body.b2_dynamicBody and @body.IsAwake())
      if _x isnt @x or _y isnt @y
        @body.SetPosition(new b2Vec2(@x/SCALE, @y/SCALE))

      if _w isnt @w or _h isnt @h
        ###
        Reseting w and h is to resize, but Box2D does not scale.
        When resizing, need to destroy initial shape, then add a new one
        ###        
        @body.DestroyFixture @body.GetFixtureList() if @body.GetFixtureList()? 

        if not @r?          
          _rectangle.call @, @w, @h

        else
          ###
          As a collision body, I choose to make the circle fits inside the AABB.
          Thus it must accomodate for the smaller side.
          ###
          @r = if @w<@h then @w/2 else @h/2
          _circle.call @, @r


    ###
    Update the entity by using Box2D's attributes.
    ###
    @bind "EnterFrame", =>
      if @body? and @body.IsAwake()
        pos = @body.GetPosition()
        angle = Crafty.math.radToDeg @body.GetAngle()

        @x = pos.x*SCALE if pos.x*SCALE isnt @x
        @y = pos.y*SCALE if pos.y*SCALE isnt @y
        @rotation = angle if angle isnt @rotation

    ###
    Add this body to a list to be destroyed on the next step.
    This is to prevent destroying the bodies during collision.
    ###
    @bind "Remove", =>
      Crafty.Box2D.destroy @body if @body?

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
  circle: (radius) -> _circle.call @, radius

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
  rectangle: (w, h) -> _rectangle.call @, w, h

  ###
  #.polygon
  @comp Box2D
  @sign public this .polygon(Array vertices)
  @sign public this .polygon(Array point, Array point[, Array point...])
  @param vertices - vertices array as an argument where index 0 is the x position
  and index 1 is the y position. Can also simply put each point as an argument.
  Attach a polygon to entity's existing body. When creating a polygon for an entity,
  each point should be offset or relative from the entities `x` and `y`
  @example
  ~~~
  this.attr({x: 10, y: 10}).polygon([[50,0],[100,100],[0,100]])
  this.attr({x: 10, y: 10}).polygon([50,0],[100,100],[0,100])
  ###
  polygon: (vertices) -> _polygon.call @, vertices

  ###
  #.hit
  @comp Box2D
  @sign public Boolean/Array hit(String component)
  @param component - Component to check collisions for
  @return `false if no collision. If a collision is detected, return an Array of
  objects that are colliding, with the type of collision, and the contact points.
  The contact points has at most two points for polygon and one for circle.
  ~~~
  [{
    obj: [entity],
    type: "Box2D",
    points: [Vector[, Vector]]
  }] 
  ###
  hit: (component) ->
    contactEdge = @body.GetContactList()
    # Return false if no collision at this frame
    return false if not contactEdge?

    otherId = contactEdge.other.GetUserData()
    otherEntity = Crafty otherId
    return false if not otherEntity.has component
    # A contact edge happens as soon as the two AABBs are touching, not the fixtures.
    # We only care when the fixture are actually touching.
    return false if not contactEdge.contact.IsTouching()

    finalresult = []

    ## Getting the contact points through manifold
    manifold = new b2WorldManifold()
    contactEdge.contact.GetWorldManifold(manifold)
    contactPoints = manifold.m_points

    finalresult.push({obj: otherEntity, type: "Box2D", points: contactPoints})

    return finalresult;

  ###
  #.onHit
  @comp Box2D
  @sign public this .onHit(String component, Function beginContact[, Function endContact])
  @param component - Component to check collisions for
  @param beginContact - Callback method to execute when collided with component, 
  @param endContact - Callback method executed once as soon as collision stops
  Invoke the callback(s) if collision detected through contact listener. We don't bind
  to EnterFrame, but let the contact listener in the Box2D world notify us.
  ###
  onHit: (component, beginContact, endContact) ->
    return @ if component isnt "Box2D"

    @bind "BeginContact", (data) =>
      hitData = [{obj: Crafty(data.targetId), type: "Box2D", points: data.points}]
      beginContact.call @, hitData

    if typeof endContact is "function"
      # This is only triggered once per contact, so just execute endContact callback.
      @bind "EndContact", =>
        endContact.call @

    @