b2Vec2 = Box2D.Common.Math.b2Vec2
{b2BodyDef, b2Body, b2FixtureDef, b2Fixture, b2World, b2DebugDraw, b2ContactListener} = Box2D.Dynamics
{b2AABB, b2WorldManifold, Shapes: {b2MassData, b2PolygonShape, b2CircleShape}} = Box2D.Collision

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
  _body = null
  SCALE = null
  _bodyTypes = ["static", "kinematic", "dynamic"]

  _createBody = (x, y, ent) ->
    return if _body?

    bodyDef = new b2BodyDef
    bodyDef.position.Set x/SCALE, y/SCALE
    _body = Crafty.Box2D.world.CreateBody bodyDef 
    ent.x = x
    ent.y = y
    _body.SetUserData ent

  _configureFixtureDef = (attrs, shape) ->
    _fixDef = new b2FixtureDef if not _fixDef?

    if attrs?
      _fixDef.density = attrs.density if attrs.density?
      _fixDef.friction = attrs.friction if attrs.friction?
      _fixDef.isSensor = attrs.isSensor if attrs.isSensor?
      _fixDef.restitution = attrs.restitution if attrs.restitution?
      _fixDef.userData = attrs.userData if attrs.userData?
      _fixDef.filter.categoryBits = attrs.filter.categoryBits if attrs.filter?.categoryBits?
      _fixDef.filter.groupIndex = attrs.filter.groupIndex if attrs.filter?.groupIndex?
      _fixDef.filter.maskBits = attrs.filter.maskBits if attrs.filter?.maskBits?

    _fixDef.shape = shape
    _body.CreateFixture _fixDef

  _arrayToVector = (pointAsArray) ->
    new b2Vec2(pointAsArray[0]/SCALE, pointAsArray[1]/SCALE)

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

  init: ->
    _fixDef = null
    _body = null
    SCALE = null

    @addComponent "2D"
    Crafty.Box2D.init() if not Crafty.Box2D.world?
    SCALE = Crafty.Box2D.SCALE

    @__defineGetter__ 'body', () -> _body

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

  bodyType: (bodyType) ->
    return _bodyTypes[_body.GetType()] if not bodyType?
    _body.SetType(b2Body["b2_#{bodyType}Body"]) if bodyType in _bodyTypes
    @

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
  circle: (radius, x=@x, y=@y, attrs) ->
    if arguments.length is 2 and typeof(arguments[1]) is "object"
      attrs = x
      x = @x

    _createBody(x, y, @)
    @w = @h = radius*2

    shape = new b2CircleShape radius/SCALE
    shape.SetLocalPosition new b2Vec2 radius/SCALE, radius/SCALE
    _configureFixtureDef(attrs, shape)
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
  rectangle: (@w, @h, x=@x, y=@y, attrs) ->
    if arguments.length is 3 and typeof(arguments[2]) is "object"
      attrs = x
      x = @x

    _createBody(x, y, @)
    shape = new b2PolygonShape
    hW = w/2/SCALE
    hH = h/2/SCALE
    shape.SetAsOrientedBox hW, hH, new b2Vec2(hW, hH)

    _configureFixtureDef(attrs, shape)    
    @   


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
  polygon: (vertices, x=@x, y=@y, attrs) ->
    if arguments.length is 2 and typeof(arguments[1]) is "object"
      attrs = x
      x = @x

    polygon = new Crafty.math.Polygon(vertices)
    ### Calculate the convex hull to ensure a clock-wise convex ###
    vertices = polygon.convexHull()

    _createBody(x, y, @)
    shape = new b2PolygonShape
    shape.SetAsArray (_arrayToVector vertex for vertex in vertices), vertices.length
    
    _configureFixtureDef(attrs, shape)    
    @

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

    otherEntity = contactEdge.other.GetUserData()

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

    @bind "BeginContact", ({target, points}) =>
      hitData = [{obj: target, type: "Box2D", points: points}]
      beginContact.call @, hitData

    if typeof endContact is "function"
      # This is only triggered once per contact, so just execute endContact callback.
      @bind "EndContact", (obj) =>
        endContact.call @, obj

    @


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
    Setting up contact listener to notify the concerned entities based on
    the entify reference in their body's user data that we set during the
    construction of the body. We don't keep track of the contact but let 
    the entities handle the collision.
    ###
    _setContactListener = ->
      contactListener = new b2ContactListener
      contactListener.BeginContact = (contact) ->
        entityA = contact.GetFixtureA().GetBody().GetUserData()
        entityB = contact.GetFixtureB().GetBody().GetUserData()

        ## Getting the contact points through manifold
        manifold = new b2WorldManifold()
        contact.GetWorldManifold manifold
        contactPoints = manifold.m_points

        entityA.trigger "BeginContact",
              points: contactPoints
              target: entityB
        entityB.trigger "BeginContact", 
              points: contactPoints
              target: entityA

      contactListener.EndContact = (contact) ->
        entityA = contact.GetFixtureA().GetBody().GetUserData()
        entityB = contact.GetFixtureB().GetBody().GetUserData()
        entityA.trigger "EndContact", entityB
        entityB.trigger "EndContact", entityA

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
      gravityX ?= 0
      gravityY ?= 0
      _SCALE ?= 30
      doSleep ?= true

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

class Crafty.math.Polygon
  ### PRIVATE ###
  _inputVertices = null
  _hull = null
  _maer = null

  ###
  #._distance
  @sign Number _distance(Array start, Array end, Array point)
  @param start - the start point forming the dividing line.
  @param end - the end point forming the dividing line.
  @param point - the point from which the distance to the line is calculated.
  Find the distance between a point and a line formed by a start and end points.
  All params have first index as the x and second index as y coordinate.

  The real distance value could be calculated as follows:

  Calculate the 2D Pseudo crossproduct of the line vector (start 
  to end) and the start to point vector. 
  ((y2*x1) - (x2*y1))
  The result of this is the area of the parallelogram created by the 
  two given vectors. The Area formula can be written as follows:
  A = |start->end| h
  Therefore the distance or height is the Area divided by the length 
  of the first vector. This division is not done here for performance 
  reasons. The length of the line does not change for each of the 
  comparison cycles, therefore the resulting value can be used to 
  finde the point with the maximal distance without performing the 
  division.

  Because the result is not returned as an absolute value its 
  algebraic sign indicates of the point is right or left of the given 
  line
  ###
  _distance = (start, end, point) ->
    (point[1]-start[1])*(end[0]-start[0])-(point[0]-start[0])*(end[1]-start[1])

  ###
  #._quickHull
  @sign Array _quickHull(Array vertices, Array start, Array end)
  @param vertices - Contains the set of points to calculate the hull for.
                    Each point is an array with the form [x, y].
  @param start - The start point of the line, in the form [x, y].
  @param end - The end point of the line, in the form [x, y].
  @return set of points forming the convex hull, in clockwise order.
  Execute a QuickHull run on the given set of points, using the provided 
  line as delimiter of the search space.
  ###
  _quickHull = (vertices, start, end) ->
    maxPoint = null
    maxDistance = 0

    newPoints = []
    for vertex in vertices when (d = _distance(start, end, vertex)) > 0
      newPoints.push vertex
      continue if d < maxDistance
      maxDistance = d
      maxPoint = vertex

    ###
    The current delimiter line is the only one left and therefore a 
    segment of the convex hull. Only the end of the line is returned 
    to not have points multiple times in the result set.
    ###
    return [end] if not maxPoint?

    ###
    The new maximal point creates a triangle together with start and 
    end, Everything inside this trianlge can be ignored. Everything 
    else needs to handled recursively. Because the quickHull invocation 
    only handles points left of the line we can simply call it for the 
    different line segements to process the right kind of points.
    ###
    _quickHull(newPoints, start, maxPoint)
      .concat _quickHull(newPoints, maxPoint, end)


  ### PUBLIC ###

  ###
  #RotatingCalipers.constructor
  @sign void constructor(Array vertices)
  @sign void RotatingCalipers(Array vertex, Array vertex, Array vertex[, Array vertex...])
  @param vertices - An array contains vertices in form of an array. Can also take 
                    each vertex as arguments
  ###
  constructor: (verticesOrFirst) ->
    throw new Error("Argument required") if not verticesOrFirst?
    throw new Error("Array of vertices required") if not (verticesOrFirst instanceof Array) or verticesOrFirst.length < 3
    [vertex1, vertex2, vertex3, rest...] = verticesOrFirst
    for vertex in verticesOrFirst
      throw new Error("Invalid vertex") if not (vertex instanceof Array) or vertex.length < 2
      throw new Error("Invalid vertex") if isNaN(vertex[0]) or isNaN(vertex[1])

    _inputVertices = verticesOrFirst
    _hull = null
    _maer = null

  ###
  RotatingCalipers.convexHull
  @sign Array convexHull(void)
  @return an Array of the points forming the minimal convex set containing all
          input vertices.
  Calculates the convex hull of the arbitrary vertices defined in constructor.
  ###
  convexHull: ->
    return _hull if _hull?

    finder = (arr) ->
      ret = {}
      ret.min = ret.max = arr[0]
      for el in arr
        ret.min = el if el[0] < ret.min[0]
        ret.max = el if el[0] > ret.max[0]
      ret

    extremeX = finder(_inputVertices)
    _hull = _quickHull(_inputVertices, extremeX.min, extremeX.max)
      .concat(_quickHull(_inputVertices, extremeX.max, extremeX.min))
      .reverse()

  ###
  RotatingCalipers.angleBetweenVectors
  @sign Number angleBetweenVectors(Array vector1, Array vector2)
  @param vector1 - the first vector
  @param vector2 - the second vector
  @return the angle between them, in radian
  Calculate the angle between two vectors.
  ###
  angleBetweenVectors: (vector1, vector2) ->
    dotProduct = vector1[0]*vector2[0] + vector1[1]*vector2[1]
    magnitude1 = Math.sqrt(vector1[0]*vector1[0] + vector1[1]*vector1[1])
    magnitude2 = Math.sqrt(vector2[0]*vector2[0] + vector2[1]*vector2[1])
    return Math.acos(dotProduct/(magnitude1*magnitude2))

  ###
  RotatingCalipers.rotateVector
  @sign Array rotateVector(Array vector, Number angle)
  @param vector - the vector to rotate
  @param angle - the angle to rotate to, in radian
  @return the rotated vector as an array
  Rotate a vector to an angle and return the rotated vector.
  ###
  rotateVector: (vector, angle) ->
    rotated = [];
    rotated[0] = vector[0]*Math.cos(angle) - vector[1]*Math.sin(angle);
    rotated[1] = vector[0]*Math.sin(angle) + vector[1]*Math.cos(angle);
    return rotated

  ###
  RotatingCalipers.shortestDistance
  @sign Number shortestDistance(Array p, Array t, Array v)
  @param p - the point to which the shortest distance is calculated
  @param t - the point through which the vector extends
  @param v - the vector extended to t to form a line
  Calculate the shortest distance from point p to the line formed by extending
  the vector v through point t
  ###
  shortestDistance: (p, t, v) ->
    return Math.abs(p[0] - t[0]) if v[0] is 0

    a = v[1] / v[0]
    c = t[1] - a*t[0]
    return Math.abs(p[1] - c - a*p[0]) / Math.sqrt(a*a + 1)

  ###
  RotatingCalipers.intersection
  @sign Array intersection(Array point1, Array vector1, Array point2, Array vector2)
  @param point1 - the point through which the first vector passing
  @param vector1 - the vector passing through point1
  @param point2 - the point through which the second vector passing
  @param vector2 - the vector passing through point2
  @return the intersecting point between two vectors
  Finds the intersection of the lines formed by vector1 passing through
  point1 and vector2 passing through point2
  ###
  intersection: (point1, vector1, point2, vector2) ->
    return false if vector1[0] is 0 and vector2[0] is 0

    if vector1[0] isnt 0
      m1 = vector1[1]/vector1[0];
      b1 = point1[1] - m1*point1[0];

    if vector2[0] isnt 0
      m2 = vector2[1]/vector2[0];
      b2 = point2[1] - m2*point2[0];

    return [point1[0], m2*point1[0] + b2] if vector1[0] is 0
    return [point2[0], m1*point2[0] + b1] if vector2[0] is 0
    return false if m1 is m2

    point = [];
    point[0] = (b2 - b1)/(m1 - m2)
    point[1] = m1*point[0] + b1
    return point

  ###
  RotatingCalipers.minAreaEnclosingRectangle
  @sign Object minAreaEnclosingRectangle(void)
  @return an object containing the vertices, width, height and area of the
  enclosing rectangle that has the minimum area.
  Calculate the mimimum area enclosing retangle for a convex polygon with n
  vertices given in clockwise order.
  The algorithm is based on Godfried Toussaint's 1983 whitepaper on "Solving
  geometric problems with the rotating calipers" and the Wikipedia page for 
  "Rotating Calipers". More info at http://cgm.cs.mcgill.ca/~orm/maer.html.
  Ported from Geoffrey Cox's PHP port (github.com/brainbook/BbsRotatingCalipers).
  Adapted for CoffeeScript by Son Tran.
  The general guidelines for the algorithm is as followed:
  1. Compute all four extreme points, and call them xminP, xmaxP, yminP ymaxP.
  2. Construct four lines of support for P through all four points. 
    These determine two sets of "calipers".
  3. If one (or more) lines coincide with an edge, then compute the area of the
    rectangle determined by the four lines, and keep as minimum. Otherwise, 
    consider the current minimum area to be infinite.
  4. Rotate the lines clockwise until one of them coincides with an edge.
  5. Compute area of new rectangle, and compare it to the current minimum area. 
    Update the minimum if necessary, keeping track of the rectangle determining the minimum. 
  6. Repeat steps 4 and 5, until the lines have been rotated an angle greater than 90 degrees.
  7. Output the minimum area enclosing rectangle.
  ###
  minAreaEnclosingRectangle: ->
    return _maer if _maer?

    hull = @convexHull()

    # index of vertex with minY, maxY, minX, maxX
    xIndices = [0, 0, 0 ,0]

    getItem = (idxOfExtremePointInHull) -> 
      hull[idxOfExtremePointInHull % hull.length]

    # Helper to return the next adjacent edge from an extreme point
    getEdge = (idxOfExtremePointInHull) ->
      pointA = getItem(idxOfExtremePointInHull+1)
      pointB = getItem(idxOfExtremePointInHull)
      [pointA[0]-pointB[0], pointA[1]-pointB[1]]    

    ###
    Compute all four extreme points for the polygon, store their indices.
    ###
    for point, idx in hull
      xIndices[0] = idx if point[1] < hull[xIndices[0]][1]
      xIndices[1] = idx if point[1] > hull[xIndices[1]][1]
      xIndices[2] = idx if point[0] < hull[xIndices[2]][0]
      xIndices[3] = idx if point[0] > hull[xIndices[3]][0]

    rotatedAngle = 0
    minArea = minWidth = minHeight = null

    # Calipers pointing along +x, -x, -y, +y
    calipers = [ 
      [1, 0], [-1, 0], [0, -1], [0, 1]
    ]

    ###
    Repeat computing, until the lines have been rotated an angle greater than 90 degrees.
    ###
    while rotatedAngle < Math.PI
      ###
      Calculate the angle between the edge next adjacent to each extreme point
      and its caliper. The minimum of those angles indicates the angle needed
      to rotate all calipers to coincide with the nearest edge.
      ###
      angles = (@angleBetweenVectors(getEdge(idx), calipers[i]) for idx, i in xIndices)
      minAngle = Math.min angles...
      ###
      Then rotate all calipers to that minimum angle.
      ###
      calipers = (@rotateVector caliper, minAngle for caliper in calipers)

      idx = angles.indexOf minAngle

      ### 
      Compute the area of the new rectangle
      ###
      switch idx
        when 0, 2
          width = @shortestDistance(getItem(xIndices[1]), getItem(xIndices[0]), calipers[0])
          height = @shortestDistance(getItem(xIndices[3]), getItem(xIndices[2]), calipers[2])
        when 1
          width = @shortestDistance(getItem(xIndices[0]), getItem(xIndices[1]), calipers[1])
          height = @shortestDistance(getItem(xIndices[3]), getItem(xIndices[2]), calipers[2])
        when 3
          width = @shortestDistance(getItem(xIndices[1]), getItem(xIndices[0]), calipers[0])
          height = @shortestDistance(getItem(xIndices[2]), getItem(xIndices[3]), calipers[3])

      rotatedAngle += minAngle
      area = width * height

      ###
      Compare the new area to the current minArea.
      ###
      if not minArea? or area < minArea
        ###
        Update the minArea, keeping track of the rectangle determining the minimum.
        ###
        minArea = area
        minPairs = ([getItem(xIndices[i]), calipers[i]] for i in [0...4])
        minWidth = width
        minHeight = height

      ###
      Update the index of the extreme point with the minimum angle to the next point
      of the polygon.
      ###
      xIndices[idx]++

      #break if isNaN(rotatedAngle)

    vertices = [
      @intersection(minPairs[0][0], minPairs[0][1], minPairs[3][0], minPairs[3][1])
      @intersection(minPairs[3][0], minPairs[3][1], minPairs[1][0], minPairs[1][1])
      @intersection(minPairs[1][0], minPairs[1][1], minPairs[2][0], minPairs[2][1])
      @intersection(minPairs[2][0], minPairs[2][1], minPairs[0][0], minPairs[0][1])
    ]

    ### Round up the values to 3 decimal ###
    Math.round(point*1000)/1000 for point in vertices
    minWidth = Math.round(minWidth*1000)/1000
    minHeight = Math.round(minHeight*1000)/1000
    minArea = Math.round(minArea*1000)/1000

    {vertices: vertices, width: minWidth, height: minHeight, area: minArea}

