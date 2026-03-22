' Amazing Mazes (AMAZE)
' by Matthew Lynch


' SETUP:
DEFINT A-Z

SCREEN 0
WIDTH 80, 25
COLOR 7, 0

RANDOMIZE TIMER

DIM LEVEL(39, 21) ' level grid
DIM MAP(39, 21) ' players map
DIM ROOMX(10), ROOMY(10) ' room positions

GOSUB TITLE

NEWLEVEL:
' reset player settings
Steps = 0
FoundStairs = 0
PowerUp = 0

CLS
COLOR 7, 0
LOCATE 12, 32
PRINT "BUILDING LEVEL...";
COLOR 6, 0
LOCATE 13, 32
PRINT "PLEASE WAIT...";

GOSUB BUILDLEVEL
GOSUB DRAWMAP

' start player in room 1
PX = ROOMX(1): PY = ROOMY(1)

' first reveal with increase range
PowerUp = 1
GOSUB REVEAL
PowerUp = 0


GETINPUT:
K$ = INKEY$
IF K$ = "" THEN GOTO GETINPUT
IF K$ = "q" OR K$ = "Q" THEN GOTO QUIT
IF K$ = "n" OR K$ = "N" THEN GOTO NEWLEVEL
IF K$ = "r" OR K$ = "R" THEN
    GOSUB SHOWMAP
    GOTO GETINPUT
END IF

NPX = PX
NPY = PY
MOVED = 0
' move up
IF K$ = CHR$(0) + CHR$(72) THEN
    NPY = PY - 1
    MOVED = 1
END IF
' move down
IF K$ = CHR$(0) + CHR$(80) THEN
    NPY = PY + 1
    MOVED = 1
END IF
' move left
IF K$ = CHR$(0) + CHR$(75) THEN
    NPX = PX - 1
    MOVED = 1
END IF
' move right
IF K$ = CHR$(0) + CHR$(77) THEN
    NPX = PX + 1
    MOVED = 1
END IF

IF MOVED = 0 THEN GOTO GETINPUT

' check if player hit wall
IF NPX < 1 OR NPX > 39 OR NPY < 1 OR NPY > 21 THEN GOTO GETINPUT
IF LEVEL(NPX, NPY) = 0 THEN GOTO GETINPUT

' erase old player
LOCATE PY, (PX - 1) * 2 + 1
' player was on floor
IF LEVEL(PX, PY) = 1 THEN
    COLOR 0, 0
    PRINT "  ";
END IF
' player was on stairs
IF LEVEL(PX, PY) = 2 THEN
    COLOR 6, 0
    PRINT CHR$(25); CHR$(25);
END IF

' update player
PX = NPX
PY = NPY
Steps = Steps + 1

' reveal new area
GOSUB REVEAL

' draw updated player
GOSUB DRAWPLAYER

' redraw info
GOSUB DRAWINFO

' player found the stairs
IF LEVEL(PX, PY) = 2 AND FoundStairs = 0 THEN
    FoundStairs = 1
    GOSUB SHOWMAP
    LOCATE 23, 1
    COLOR 6, 0
    PRINT "You found the stairs!  Press N to go deeper..."
END IF

GOTO GETINPUT


BUILDLEVEL:
' 1) clear level
' 2) place random rooms
' 3) connect rooms
' 4) scan for places to dig
' 5) dig until we find something
' 6) repeat 4 and 5 till we run out of places to dig
' 7) place stairs

CLEARLEVEL:
FOR Y = 1 TO 21
    FOR X = 1 TO 39
        LEVEL(X, Y) = 0
        MAP(X, Y) = 0
    NEXT X
NEXT Y


PLACEROOMS:
NumRooms = 3 + INT(RND * 3)
FOR R = 1 TO NumRooms
    ' odd sizes (3, 5, or 7)
    RW = (1 + INT(RND * 3)) * 2 + 1
    RH = (1 + INT(RND * 2)) * 2 + 1
    
    ' even positions
    MaxRX = (38 - RW) \ 2
    MaxRY = (20 - RH) \ 2
    RX = (1 + INT(RND * MaxRX)) * 2
    RY = (1 + INT(RND * MaxRY)) * 2

    ' odd widths + even positions = space between rooms

    ' safe position inside room for digger or player
    ROOMX(R) = RX + 1
    ROOMY(R) = RY + 1

    ' dig out the room
    FOR Y = RY TO RY + RH - 1
        FOR X = RX TO RX + RW - 1
            LEVEL(X, Y) = 1
        NEXT X
    NEXT Y
NEXT R


CONNECTROOMS:
FOR R = 1 TO NumRooms - 1
    ' current pos
    CX = ROOMX(R)
    CY = ROOMY(R)
    ' target pos
    TX = ROOMX(R + 1)
    TY = ROOMY(R + 1)
    ' dig left or right toward target
    WHILE CX <> TX
        IF CX < TX THEN NX = CX + 2 ELSE NX = CX - 2
        LEVEL(CX + (NX - CX) \ 2, CY) = 1
        LEVEL(NX, CY) = 1
        CX = NX
    WEND
    ' dig up or down toward target
    WHILE CY <> TY
        IF CY < TY THEN NY = CY + 2 ELSE NY = CY - 2
        LEVEL(CX, CY + (NY - CY) \ 2) = 1
        LEVEL(CX, NY) = 1
        CY = NY
    WEND
NEXT R


SCAN:
' look for wall with floor two spaces away
' break walls until we reach floor then start digging
HY = 2

SCANY:
IF HY > 20 THEN GOTO PLACESTAIRS
HX = 2

SCANX:
IF HX > 38 THEN GOTO NEXTY

IF LEVEL(HX, HY) = 0 THEN
    ' look up
    IF HY > 2 THEN
        IF LEVEL(HX, HY - 2) = 1 THEN
            ' clear path from floor to here
            LEVEL(HX, HY - 1) = 1
            LEVEL(HX, HY) = 1
            CX = HX
            CY = HY
            GOTO DIG
        END IF
    END IF
    ' look down
    IF HY < 20 THEN
        IF LEVEL(HX, HY + 2) = 1 THEN
            LEVEL(HX, HY + 1) = 1
            LEVEL(HX, HY) = 1
            CX = HX
            CY = HY
            GOTO DIG
        END IF
    END IF
    ' look left
    IF HX > 2 THEN
        IF LEVEL(HX - 2, HY) = 1 THEN
            LEVEL(HX - 1, HY) = 1
            LEVEL(HX, HY) = 1
            CX = HX
            CY = HY
            GOTO DIG
        END IF
    END IF
    ' look right
    IF HX < 38 THEN
        IF LEVEL(HX + 2, HY) = 1 THEN
            LEVEL(HX + 1, HY) = 1
            LEVEL(HX, HY) = 1
            CX = HX
            CY = HY
            GOTO DIG
        END IF
    END IF
END IF

NEXTX:
HX = HX + 2
GOTO SCANX

NEXTY:
HY = HY + 2
GOTO SCANY

DIG:
' make sure we won't hit outer walls
' make sure there is still a floor two spaces away
DigMore = 0
IF CY > 3 THEN IF LEVEL(CX, CY - 2) = 0 THEN DigMore = 1
IF CY < 19 THEN IF LEVEL(CX, CY + 2) = 0 THEN DigMore = 1
IF CX > 3 THEN IF LEVEL(CX - 2, CY) = 0 THEN DigMore = 1
IF CX < 37 THEN IF LEVEL(CX + 2, CY) = 0 THEN DigMore = 1

' dead end... scan for a new plac to dig
IF DigMore = 0 THEN GOTO SCAN

TRYDIR:
Dir = INT(RND * 4)
' try dig up
IF Dir = 0 AND CY > 3 THEN
    IF LEVEL(CX, CY - 2) = 0 THEN
        LEVEL(CX, CY - 1) = 1
        LEVEL(CX, CY - 2) = 1
        CY = CY - 2
        GOTO DIG
    END IF
END IF
' try dig down
IF Dir = 1 AND CY < 19 THEN
    IF LEVEL(CX, CY + 2) = 0 THEN
        LEVEL(CX, CY + 1) = 1
        LEVEL(CX, CY + 2) = 1
        CY = CY + 2
        GOTO DIG
    END IF
END IF
' try dig left
IF Dir = 2 AND CX > 3 THEN
    IF LEVEL(CX - 2, CY) = 0 THEN
        LEVEL(CX - 1, CY) = 1
        LEVEL(CX - 2, CY) = 1
        CX = CX - 2
        GOTO DIG
    END IF
END IF
' try dig right
IF Dir = 3 AND CX < 37 THEN
    IF LEVEL(CX + 2, CY) = 0 THEN
        LEVEL(CX + 1, CY) = 1
        LEVEL(CX + 2, CY) = 1
        CX = CX + 2
        GOTO DIG
    END IF
END IF
' hit wall... try again
GOTO TRYDIR


PLACESTAIRS:
' put stiars in last room
LEVEL(ROOMX(NumRooms), ROOMY(NumRooms)) = 2

DONEMAP:
RETURN


DRAWMAP:
CLS
FOR Y = 1 TO 21
    FOR X = 1 TO 39
        IF MAP(X, Y) = 1 THEN
            LOCATE Y, (X - 1) * 2 + 1
            ' wall
            IF LEVEL(X, Y) = 0 THEN
                COLOR 8, 0
                PRINT CHR$(219); CHR$(219);
            END IF
            ' floor
            IF LEVEL(X, Y) = 1 THEN
                COLOR 0, 0
                PRINT "  ";
            END IF
            ' stairs
            IF LEVEL(X, Y) = 2 THEN
                COLOR 6, 0
                PRINT CHR$(25); CHR$(25);
            END IF
        END IF
    NEXT X
NEXT Y
GOSUB DRAWINFO
RETURN


REVEAL:
RANGE = 1 + PowerUp
FOR DY = -RANGE TO RANGE
    FOR DX = -RANGE TO RANGE
        TX = PX + DX
        TY = PY + DY
        IF TX >= 1 AND TX <= 39 AND TY >= 1 AND TY <= 21 THEN
            IF MAP(TX, TY) = 0 THEN
                MAP(TX, TY) = 1
                LOCATE TY, (TX - 1) * 2 + 1
                ' wall
                IF LEVEL(TX, TY) = 0 THEN
                    COLOR 8, 0
                    PRINT CHR$(219); CHR$(219);
                END IF
                ' floor
                IF LEVEL(TX, TY) = 1 THEN
                    COLOR 0, 0
                    PRINT "  ";
                END IF
                ' stairs
                IF LEVEL(TX, TY) = 2 THEN
                    COLOR 6, 0
                    PRINT CHR$(25); CHR$(25);
                END IF
            END IF
        END IF
    NEXT DX
NEXT DY
GOSUB DRAWPLAYER
RETURN


SHOWMAP:
FOR Y = 1 TO 21
    FOR X = 1 TO 39
        MAP(X, Y) = 1
    NEXT X
NEXT Y
GOSUB DRAWMAP
GOSUB DRAWPLAYER
RETURN


DRAWPLAYER:
LOCATE PY, (PX - 1) * 2 + 1
COLOR 9, 0
PRINT CHR$(2); " ";
RETURN


DRAWINFO:
LOCATE 24, 1
COLOR 9, 0
PRINT "Steps:"; Steps;
LOCATE 25, 1
COLOR 7, 0
PRINT "Move = Arrows";
LOCATE 25, 57
COLOR 7, 0
PRINT "(N)ew  (R)eveal  (Q)uit";
RETURN


TITLE:
CLS
COLOR 9, 0
LOCATE 9, 34
PRINT "AMAZING MAZES";
COLOR 8, 0
LOCATE 11, 25
PRINT CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219)
COLOR 7, 0
LOCATE 13, 28
PRINT "Find the stairs "; CHR$(25); CHR$(25); " to win";
COLOR 6, 0
LOCATE 13, 44
PRINT CHR$(25); CHR$(25);
COLOR 8, 0
LOCATE 15, 25
PRINT CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219); "  "; CHR$(219); CHR$(219)
COLOR 6, 0
LOCATE 17, 29
PRINT "PRESS ANY KEY TO START";

WAITKEY:
K$ = INKEY$
IF K$ = "" THEN GOTO WAITKEY
CLS
RETURN


QUIT:
CLS
COLOR 13, 0
LOCATE 12, 36
PRINT "GOODBYE!";
COLOR 7, 0
END

