should = chai.should()

describe "Rotating Calipers", ->
  describe "input", ->

    it "should have arguments", ->
      ( -> new RotatingCalipers() ).should.throw("Argument required")
      ( -> new RotatingCalipers ( "asdas" ) ).should.not.throw("Argument required")

    it "should take an array with at least three vertices", ->
      ( -> new RotatingCalipers ( "adasda" ) ).should.throw("Array of vertices required")
      ( -> new RotatingCalipers ( [] ) ).should.throw("Array of vertices required")
      ( -> new RotatingCalipers ( [ "abc" ] ) ).should.throw("Array of vertices required")
      ( -> new RotatingCalipers ( [ "abc", "abc" ] ) ).should.throw("Array of vertices required")
      ( -> new RotatingCalipers ( [ "abc", "abc", "abc" ] ) ).should.not.throw("Array of vertices required")

    it "should have each vertex as an array with x and y as integers", ->
      ( -> new RotatingCalipers ( [ "abc", "abc", "abc" ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [], "abc", "abc" ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [], [], "abc" ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [], [], [] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ ["two", "three"], [], [] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ ["two", "three"], ["four", "five"], [] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ ["two", "three"], ["four", "five"], ["six", "seven"] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [2, "three"], ["four", "five"], ["six", "seven"] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [2, 3], ["four", "five"], ["six", "seven"] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [2, 3], [4, "five"], ["six", "seven"] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [2, 3], [4, 5], ["six", "seven"] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [2, 3], [4, 5], [6, "seven"] ] ) ).should.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ [2, 3], [4, 5], [6, 7] ] ) ).should.not.throw("Invalid vertex")
      ( -> new RotatingCalipers ( [ ["2", "3"], ["4", "5"], ["6", "7"] ] ) ).should.not.throw("Invalid vertex")

    it "should be in clockwise order", ->

    it "should also accept counterclockwise, but convert it", ->

    it "should form a convex polygon", ->

  ###
  IMO, if we calculate the convex hull, the input can just be arbitrary array of points
  ###
  describe "calculating convex hull", ->    
    solver = null
    it "should return the aligned axis rectangle in clockwise order", ->
      solver = new RotatingCalipers [ [0,0], [1,0], [1,1], [0,1] ]
      hullPoints = solver.convexHull()
      hullPoints.should.have.length 4
      
      hullPoints[0][0].should.equal 0
      hullPoints[0][1].should.equal 1

      hullPoints[1][0].should.equal 1
      hullPoints[1][1].should.equal 1

      hullPoints[2][0].should.equal 1
      hullPoints[2][1].should.equal 0

      hullPoints[3][0].should.equal 0
      hullPoints[3][1].should.equal 0

