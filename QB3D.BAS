' 3D IN QBASIC
' by Matthew Lynch


' SETUP
' use pages to stop flickering
SCREEN 7, 0, 1, 0

' SETTINGS
Pi = 3.141593
Pi2 = 2 * Pi
GR = (1 + SQR(5)) / 2 ' golden ratio
Radius = SQR(1 + (GR * GR)) ' for sphere
ScaleX = 180
ScaleY = 180 * 0.83
Dist = 4
ShapeNum = 0
YAng = 0
XAng = 0

' CUBE CORNERS:
DIM CubX(7), CubY(7), CubZ(7)
CubX(0) = -1: CubY(0) = -1: CubZ(0) = -1
CubX(1) = 1: CubY(1) = -1: CubZ(1) = -1
CubX(2) = 1: CubY(2) = -1: CubZ(2) = 1
CubX(3) = -1: CubY(3) = -1: CubZ(3) = 1
CubX(4) = -1: CubY(4) = 1: CubZ(4) = -1
CubX(5) = 1: CubY(5) = 1: CubZ(5) = -1
CubX(6) = 1: CubY(6) = 1: CubZ(6) = 1
CubX(7) = -1: CubY(7) = 1: CubZ(7) = 1

' PYRAMID CORNERS:
DIM PyrX(4), PyrY(4), PyrZ(4)
PyrX(0) = -1: PyrY(0) = -.8: PyrZ(0) = -1
PyrX(1) = 1: PyrY(1) = -.8: PyrZ(1) = -1
PyrX(2) = 1: PyrY(2) = -.8: PyrZ(2) = 1
PyrX(3) = -1: PyrY(3) = -.8: PyrZ(3) = 1
PyrX(4) = 0: PyrY(4) = 1.2: PyrZ(4) = 0

' SPHERE POINTS:
' made of triangles connecting 12 evenly spaced points
DIM SphX(11), SphY(11), SphZ(11)
RESTORE SPHPOINTS
FOR I = 0 TO 11
    READ X, Y, Z
    
    ' if the data says 2 replace it with the golden ratio
    IF ABS(X) = 2 THEN X = SGN(X) * GR
    IF ABS(Y) = 2 THEN Y = SGN(Y) * GR
    IF ABS(Z) = 2 THEN Z = SGN(Z) * GR
    
    ' for scaling to work properly the radius of the sphere must be 1
    ' but we used golden ratio (1.618) in coordinates so it is bigger than 1
    ' need to divide by actual radius to shrink sphere down to radius of 1
    SphX(I) = X / Radius
    SphY(I) = Y / Radius
    SphZ(I) = Z / Radius
NEXT I

SPHPOINTS:
' simple three point curves repeated in every direction to make a sphere
' 2 is replaced with the golden ration to make it more round
DATA  0,  1,  2
DATA  0, -1,  2
DATA  0,  1, -2
DATA  0, -1, -2
DATA  1,  2,  0
DATA -1,  2,  0
DATA  1, -2,  0
DATA -1, -2,  0
DATA  2,  0,  1
DATA -2,  0,  1
DATA  2,  0, -1
DATA -2,  0, -1

' ROTATED COORDINATES:
' temporary store coordinates here after rotating the shape
DIM RX(11), RY(11)


GETINPUT:
' faster CLS
LINE (0,0)-(319,199), 0, BF

COLOR 15
LOCATE 2, 15
PRINT "3D IN QBASIC"

IF ShapeNum = 0 THEN
    COLOR 11
    LOCATE 3, 17: PRINT "[ CUBE ]"
    GOSUB DRAWCUBE
END IF
IF ShapeNum = 1 THEN
    COLOR 14
    LOCATE 3, 15: PRINT "[ PYRAMID ]"
    GOSUB DRAWPYRAMID
END IF
IF ShapeNum = 2 THEN
    COLOR 10
    LOCATE 3, 16: PRINT "[ SPHERE ]"
    GOSUB DRAWSPHERE
END IF

COLOR 8
LOCATE 23, 6
PRINT "LEFT/RIGHT: change   ESC: QUIT"

YAng = YAng + .04
XAng = XAng + .008
IF YAng > Pi2 THEN YAng = YAng - Pi2
IF XAng > Pi2 THEN XAng = XAng - Pi2

K$ = INKEY$
IF K$ = CHR$(27) THEN GOTO QUIT

IF K$ = CHR$(0) + "K" THEN ShapeNum = ShapeNum - 1
IF K$ = CHR$(0) + "M" THEN ShapeNum = ShapeNum + 1
    
IF ShapeNum > 2 THEN ShapeNum = 0
IF ShapeNum < 0 THEN ShapeNum = 2

' switch screen page
PCOPY 1, 0

GOTO GETINPUT

QUIT:
END


ROTATE:
' spin around y-axis
X1 = VX * COS(YAng) - VZ * SIN(YAng)
Z1 = VX * SIN(YAng) + VZ * COS(YAng)
' spin around x-axis
Y2 = VY * COS(XAng) - Z1 * SIN(XAng)
Z2 = VY * SIN(XAng) + Z1 * COS(XAng)
' fix perspective and scale to fit on screen
DZ = Z2 + Dist
IF DZ < .1 THEN DZ = .1
SX = (X1 / DZ) * ScaleX + 160
SY = (Y2 / DZ) * ScaleY + 100
RETURN


DRAWCUBE:
CubeCol = 11
FOR I = 0 TO 7
    VX = CubX(I): VY = CubY(I): VZ = CubZ(I)
    GOSUB ROTATE
    RX(I) = SX
    RY(I) = SY
NEXT I
LINE (RX(0), RY(0))-(RX(1), RY(1)), CubeCol
LINE (RX(1), RY(1))-(RX(2), RY(2)), CubeCol
LINE (RX(2), RY(2))-(RX(3), RY(3)), CubeCol
LINE (RX(3), RY(3))-(RX(0), RY(0)), CubeCol
LINE (RX(4), RY(4))-(RX(5), RY(5)), CubeCol
LINE (RX(5), RY(5))-(RX(6), RY(6)), CubeCol
LINE (RX(6), RY(6))-(RX(7), RY(7)), CubeCol
LINE (RX(7), RY(7))-(RX(4), RY(4)), CubeCol
LINE (RX(0), RY(0))-(RX(4), RY(4)), CubeCol
LINE (RX(1), RY(1))-(RX(5), RY(5)), CubeCol
LINE (RX(2), RY(2))-(RX(6), RY(6)), CubeCol
LINE (RX(3), RY(3))-(RX(7), RY(7)), CubeCol
RETURN


DRAWPYRAMID:
PyrCol = 14
FOR I = 0 TO 4
    VX = PyrX(I): VY = PyrY(I): VZ = PyrZ(I)
    GOSUB ROTATE
    RX(I) = SX
    RY(I) = SY
NEXT I
LINE (RX(0), RY(0))-(RX(1), RY(1)), PyrCol
LINE (RX(1), RY(1))-(RX(2), RY(2)), PyrCol
LINE (RX(2), RY(2))-(RX(3), RY(3)), PyrCol
LINE (RX(3), RY(3))-(RX(0), RY(0)), PyrCol
LINE (RX(0), RY(0))-(RX(4), RY(4)), PyrCol
LINE (RX(1), RY(1))-(RX(4), RY(4)), PyrCol
LINE (RX(2), RY(2))-(RX(4), RY(4)), PyrCol
LINE (RX(3), RY(3))-(RX(4), RY(4)), PyrCol
RETURN


DRAWSPHERE:
SphCol = 10
FOR I = 0 TO 11
    VX = SphX(I): VY = SphY(I): VZ = SphZ(I)
    GOSUB ROTATE
    RX(I) = SX
    RY(I) = SY
NEXT I
RESTORE SPHLINES
FOR E = 1 TO 30
    READ EA, EB
    LINE (RX(EA), RY(EA))-(RX(EB), RY(EB)), SphCol
NEXT E
RETURN

SPHLINES:
' each pair of numbers is one line connecting two corners
' drawn as triangles so not every corner is connected to every other corner
DATA  0, 1,  0, 4,  0, 5,  0, 8,  0, 9
DATA  1, 6,  1, 7,  1, 8,  1, 9
DATA  2, 3,  2, 4,  2, 5,  2,10,  2,11
DATA  3, 6,  3, 7,  3,10,  3,11
DATA  4, 5,  4, 8,  4,10
DATA  5, 9,  5,11
DATA  6, 7,  6, 8,  6,10
DATA  7, 9,  7,11
DATA  8,10,  9,11

