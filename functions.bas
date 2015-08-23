declare sub LoadConfig()
declare sub LoadPatterns()
declare sub InitGL()
declare sub DrawScreen()
declare sub CleanupGL()
declare sub BuildFont()

declare function LoadGLTexture(texfile as string) as gluint ptr

declare sub consoleWrite(text as string)

'--------------------------------------------------------
'| Global variables                                     |
'--------------------------------------------------------

dim shared as integer screenwidth, screenheight, frameratecap, fullscreen, flags, bornrule, surviverule
dim shared as string rulestring
dim shared as integer sensitivity

'--------------------------------------------------------
'| Initialisation functions                             |
'--------------------------------------------------------

sub LoadConfig()
    
    open "data/config.txt" for input as #1
    input #1, rulestring
    input #1, screenwidth
    input #1, screenheight
    input #1, fullscreen
    input #1, frameratecap
    input #1, sensitivity
    close #1
    
    dim as integer n, k, flag = 0
    dim as string ch
    for n = 1 to len(rulestring)
        ch = mid(rulestring, n, 1)
        if ch = "/" then
            flag = 1
        else
            k = val(ch)
            if flag = 0 then
                surviverule += 2^k
            else
                bornrule += 2^k
            end if
        end if
    next n
    
end sub

sub LoadPatterns()
    open "data/patterns.txt" for input as #1
    dim n as integer
    dim x as integer
    dim y as integer
    for n = 0 to 9
        input #1, patterns(n).patternname
        input #1, patterns(n).size
        for y = 0 to patterns(n).size-1
            for x = 0 to patterns(n).size-1
                input #1, patterns(n).dat(x,y)
            next x
        next y
    next n
    close #1
end sub


sub InitGL()
    screenres screenwidth, screenheight, 32, , FB.GFX_OPENGL or FB.GFX_MULTISAMPLE or fullscreen
    windowtitle "Generations 0.15 by Xerol"
    glViewport 0, 0, screenwidth, screenheight
    glMatrixMode GL_PROJECTION
    glLoadIdentity
    gluPerspective 45.0, screenwidth/screenheight, 0.1, 500.0
    glMatrixMode GL_MODELVIEW
    glLoadIdentity
    
    glShadeModel GL_SMOOTH
    glClearColor 0.0, 0.4, 0.4, 1.0
    glClearDepth 1.0
    glEnable GL_DEPTH_TEST
    glDepthFunc GL_LEQUAL
    glHint GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST
    
    'glCullFace GL_BACK
    
    BuildFont()
    
    setmouse ,,0
end sub

sub CleanupGL()
    glDeleteLists(firstlist, 1000)
end sub



'--------------------------------------------------------
'| Runtime functions                                    |
'--------------------------------------------------------


sub DrawScreen()
    static lasttime as double
    if lasttime = 0 then lasttime = timer
    while (timer-lasttime < 1/frameratecap)
        sleep 1
    wend
    elapsed = timer - lasttime
    lasttime = timer
    flip
end sub



#include once "bmpload.bi"


sub BuildFont()
    fonttex = LoadGLTexture("data/Font.bmp")
    fontmasktex = LoadGLTexture("data/font_mask.bmp")
    
	dim cx as single                             '' Holds Our X Character Coord
	dim cy as single                             '' Holds Our Y Character Coord
    dim as integer gloop
	fontbase = glGenLists(256)                   '' Creating 256 Display Lists
	glBindTexture GL_TEXTURE_2D, *fonttex         '' Select Our Font Texture
	for gloop = 0 to 127                         '' Loop Through All 256 Lists
        
		cx = (gloop mod 16)/16.0                 '' X Position Of Current Character
		cy = (gloop\16)/16.0                     '' Y Position Of Current Character
        
		glNewList fontbase+gloop, GL_COMPILE     '' Start Building A List
		glBegin GL_QUADS                         '' Use A Quad For Each Character
			glTexCoord2f cx, 1-cy-0.0625         '' Texture Coord (Bottom Left)
			glVertex2i 0, 0                      '' Vertex Coord (Bottom Left)
			glTexCoord2f cx+0.0625, 1-cy-0.0625  '' Texture Coord (Bottom Right)
			glVertex2i 24,0                      '' Vertex Coord (Bottom Right)
			glTexCoord2f cx+0.0625, 1-cy         '' Texture Coord (Top Right)
			glVertex2i 24, 32                    '' Vertex Coord (Top Right)
			glTexCoord2f cx,1-cy                 '' Texture Coord (Top Left)
			glVertex2i 0, 32                     '' Vertex Coord (Top Left)
		glEnd                                    '' Done Building Our Quad (Character)
		glTranslated 24, 0, 0                    '' Move To The Right Of The Character
		glEndList                                '' Done Building The Display List
	next gloop                                   '' Loop Until All 256 Are Built
    for gloop = 128 to 255                       '' Loop Through All 256 Lists
        
		cx = (gloop mod 16)/16.0                 '' X Position Of Current Character
		cy = (gloop\16)/16.0                     '' Y Position Of Current Character
        
		glNewList fontbase+gloop, GL_COMPILE        '' Start Building A List
		glBegin GL_QUADS                         '' Use A Quad For Each Character
			glTexCoord2f cx, 1-cy-0.0625         '' Texture Coord (Bottom Left)
			glVertex2i 0, 0                      '' Vertex Coord (Bottom Left)
			glTexCoord2f cx+0.0625, 1-cy-0.0625  '' Texture Coord (Bottom Right)
			glVertex2i 12,0                      '' Vertex Coord (Bottom Right)
			glTexCoord2f cx+0.0625, 1-cy         '' Texture Coord (Top Right)
			glVertex2i 12,16                     '' Vertex Coord (Top Right)
			glTexCoord2f cx,1-cy                 '' Texture Coord (Top Left)
			glVertex2i 0,16                     '' Vertex Coord (Top Left)
		glEnd                                    '' Done Building Our Quad (Character)
		glTranslated 12, 0, 0                    '' Move To The Right Of The Character
		glEndList                                '' Done Building The Display List
	next gloop                                   '' Loop Until All 256 Are Builtend sub
    
end sub


sub glPrint(byval x as integer, byval y as integer, glstring as string, byval gset as integer)
	
    dim as glFloat tempcolor(0 to 3)
    glGetFloatv GL_CURRENT_COLOR, @tempcolor(0)
    
    if gset>1 then gset=1
    
    glColor4f 1.0, 1.0, 1.0, 1.0
    
    glBlendFunc(GL_DST_COLOR,GL_ZERO)
    glBindTexture GL_TEXTURE_2D, *fontmasktex                         '' Select Our Font Texture
    glLoadIdentity                                          '' Reset The Modelview Matrix
    glTranslated x, y, 0                                    '' Position The Text (0,0 - Bottom Left)
    glListBase fontbase-32+(128*gset)                          '' Choose The Font Set (0 or 1)
    glCallLists len(glstring),GL_BYTE, strptr(glstring)     '' Write The Text To The Screen
    
    glColor4f tempcolor(0), tempcolor(1), tempcolor(2), tempcolor(3)
    glBlendFunc(GL_ONE, GL_ONE)
    glBindTexture GL_TEXTURE_2D, *fonttex                         '' Select Our Font Texture
    glLoadIdentity                                          '' Reset The Modelview Matrix
    glTranslated x, y, 0                                    '' Position The Text (0,0 - Bottom Left)
    glListBase fontbase-32+(128*gset)                          '' Choose The Font Set (0 or 1)
    glCallLists len(glstring),GL_BYTE, strptr(glstring)     '' Write The Text To The Screen
    glBlendFunc GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA

end sub


'--------------------------------------------------------
'| Texture functions                                    |
'--------------------------------------------------------


function LoadGLTexture(texfile as string) as gluint ptr
    dim TextureImage(0) as BITMAP_RGBImageRec ptr     '' Create Storage Space For The Texture
    dim texture as gluint ptr
    
    ' Load The Bitmap, Check For Errors, If Bitmap's Not Found Quit
    TextureImage(0) = LoadBMP(texfile)
    if TextureImage(0) then
        texture = new gluint
        glGenTextures 1, texture
        glBindTexture GL_TEXTURE_2D, *texture
        gluBuild2DMipmaps GL_TEXTURE_2D, 3, TextureImage(0)->sizeX, TextureImage(0)->sizeY, GL_RGB, GL_UNSIGNED_BYTE, TextureImage(0)->buffer
        glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
        glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
    end if

    if TextureImage(0) then                           '' If Texture Exists
        if TextureImage(0)->buffer then                 '' If Texture Image Exist
            deallocate(TextureImage(0)->buffer)           '' Free The Texture Image Memory
        end if
        deallocate(TextureImage(0))                     '' Free The Image Structure
    end if
    
    return texture
end function


'--------------------------------------------------------
'| Console functions                                    |
'--------------------------------------------------------

sub consoleWrite(text as string)
    dim as integer n
    for n = 9 to 1 step -1
        console(n) = console(n-1)
    next n
    console(0).text = text
    console(0).t = timer
end sub
