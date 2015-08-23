#include "fbgfx.bi"
#include "GL/gl.bi"
#include "GL/glu.bi"

randomize timer

dim shared as integer x, y, z, x1, y1, x2, y2, cellcount, n, m, k, generation, totalcount, tempcell


dim shared as integer cameraangle = 0
dim shared as glfloat lookatx = 5, lookaty = 5, lookatz = 1
dim shared as glfloat camposx, camposy, camposz, camrot
dim shared as double countdown, sc, sc1, col
dim shared as double keydelay, elapsed, lasttimer, starttime, totaltime, exespeed
dim shared as integer mousex, mousey, mousew, mouseb
dim shared as integer oldmousex, oldmousey, oldmousew, oldmouseb
dim shared as integer moveh, movev
dim shared as integer maxspeed

const timestep = 50
const depth = 100

dim as integer displaydepth = 10

const boardsize = 100

type layer
    cells(boardsize, boardsize) as integer
end type


dim shared as layer layers(-1 to depth)
dim shared as layer templayer

dim menumode as integer
dim menusel as integer

'dim shared as integer cells(boardsize, boardsize, -1 to depth)
'dim shared as integer templayer(boardsize, boardsize)

#include "data.bas"
#include "functions.bas"
#include "graphics.bas"

dim as rgba1 cellcolor


LoadConfig()
LoadPatterns()
InitGL()
initTextures()
GenerateLists()

'Initialise cells
for x = 0 to boardsize-1
    for y = 0 to boardsize-1
        'if rnd < .4 then cells(x,y,-1) = 1
    next y
next x


dim cam as camera
cam.lookat.x = boardsize/2
cam.lookat.y = -1
cam.lookat.z = boardsize/2
camrot = 0
camposx = boardsize/2
camposy = boardsize/2
cam.location.x = cos(camrot)*80 + camposx
cam.location.y = boardsize/2
cam.location.z = sin(camrot)*80 + camposy
cam.up.z = 1

countdown = timestep

lasttimer = timer
starttime = timer

maxspeed = frameratecap * timestep

do
    elapsed = timer - lasttimer
    lasttimer = timer
    keydelay -= elapsed
    totaltime = timer - starttime
    
    if multikey(FB.SC_TILDE) then 
        exespeed += elapsed*25
    else
        'exespeed = 1
    end if
    
    'if exespeed > frameratecap*timestep then exespeed = frameratecap*timestep
    if exespeed > maxspeed then exespeed = maxspeed
    
    countdown -= elapsed*exespeed
    
    glClear GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
    
    while countdown < 0
        generation += 1
        countdown += timestep
        for z = depth to 1 step -1
            layers(z) = layers(z-1)
        next z
        
        totalcount = 0
        for x = 0 to boardsize-1
            for y = 0 to boardsize-1
                cellcount = 0
                for x1 = -1 to 1
                    for y1 = -1 to 1
                        if layers(1).cells((x+x1+boardsize) mod boardsize, (y+y1+boardsize) mod boardsize) > 0 and not (x1 = 0 and y1 = 0) then cellcount += 1
                    next y1
                next x1
                'if (cellcount = 4 and cells(x,y,1) = 1) or cellcount >= 5 then 
                if (layers(1).cells(x, y) > 0 and ((2^cellcount and surviverule) > 0)) or (layers(1).cells(x, y) = 0 and ((2^cellcount and bornrule) > 0)) then
                    layers(0).cells(x, y) = layers(1).cells(x,y) + 1
                    totalcount += 1
                else
                    layers(0).cells(x, y) = 0
                end if
            next y
        next x
        
        for x = 0 to boardsize-1
            for y = 0 to boardsize-1
                if layers(-1).cells(x,y) > 0 then layers(0).cells(x,y) = layers(-1).cells(x,y)
                layers(-1).cells(x,y) = 0
            next y
        next x
        
        if generation mod int(2/timestep + 1) = 0 then
            consoleWrite("Generation " & generation & ": " & totalcount & " cells.")
        end if
        
    wend
    
    
    'Check controls
    moveh = 0
    movev = 0
    oldmousex = mousex
    oldmousey = mousey
    oldmousew = mousew
    oldmouseb = mouseb
    getmouse mousex, mousey, mousew, mouseb
    
    'moveh = mousex - screenwidth/2
    'movev = mousey - screenheight/2
    
    'setmouse screenwidth/2, screenheight/2, 0
    

    
    'Controls - Ignore if in menu
    if menumode = 0 then
        if multikey(26) and keydelay < 0 then
            keydelay = .1
            displaydepth -= 1
            if displaydepth < 1 then displaydepth = 1
            consolewrite("Displaying " & displaydepth & " layers.")
        end if
        if multikey(27) and keydelay < 0 then
            keydelay = .1
            displaydepth += 1
            if displaydepth > depth then displaydepth = depth
            consolewrite("Displaying " & displaydepth & " layers.")
        end if
        
        if multikey(FB.SC_LEFT) and moveh = 0 then
            moveh -= sensitivity
        end if
        
        if multikey(FB.SC_RIGHT) and moveh = 0 then
            moveh += sensitivity
        end if
        
        
        if multikey(FB.SC_DOWN) then
            movev += sensitivity
        end if
        
        if multikey(FB.SC_UP) then
            movev -= sensitivity
        end if
        
        if multikey(FB.SC_W) then
            camposx -= cos(camrot)*elapsed*15
            camposy -= sin(camrot)*elapsed*15
            cam.lookat.x -= cos(camrot)*elapsed*15
            cam.lookat.z -= sin(camrot)*elapsed*15
        end if
        
        if multikey(FB.SC_S) then
            camposx += cos(camrot)*elapsed*15
            camposy += sin(camrot)*elapsed*15
            cam.lookat.x += cos(camrot)*elapsed*15
            cam.lookat.z += sin(camrot)*elapsed*15
        end if
        
        if multikey(FB.SC_A) then
            camposx -= cos(camrot-PI/2)*elapsed*15
            camposy -= sin(camrot-PI/2)*elapsed*15
            cam.lookat.x -= cos(camrot-PI/2)*elapsed*15
            cam.lookat.z -= sin(camrot-PI/2)*elapsed*15
        end if
        
        if multikey(FB.SC_D) then
            camposx -= cos(camrot+PI/2)*elapsed*15
            camposy -= sin(camrot+PI/2)*elapsed*15
            cam.lookat.x -= cos(camrot+PI/2)*elapsed*15
            cam.lookat.z -= sin(camrot+PI/2)*elapsed*15
        end if
        
        if (mouseb AND 1) then 'lmb down
            if NOT (oldmouseb AND 1) then 'it's a click
            end if
            
            'not a click, but mouse is down anyway.
            if mousex > screenwidth*.01 and mousex < screenwidth*.06 then
                if (screenheight-mousey) > screenheight * .5 and (screenheight-mousey) < screenheight * .9 then 'mouse in speed slider
                    exespeed = ((screenheight-mousey)/screenheight - .5) / .4 * maxspeed
                elseif (screenheight-mousey) > screenheight * .5 - 48 and (screenheight-mousey) < screenheight*.5 then 'mouse on "stop" button
                    exespeed = 0
                elseif (screenheight-mousey) > screenheight * .9 and (screenheight-mousey) < screenheight*.9 + 48 then 'mouse on "max" button
                    exespeed = maxspeed
                end if
                
            end if
        end if
        
        if multikey(FB.SC_F5) then
            for z = -1 to depth
                for x = 0 to boardsize-1
                    for y = 0 to boardsize-1
                        layers(z).cells(x,y) = 0
                    next y
                next x
            next z
            exespeed = 0
            consolewrite("Cleared map.")
        end if
        
        
    end if
    
    
    if abs(moveh) > sensitivity then moveh = sensitivity * sgn(moveh)
    camrot += elapsed * moveh/sensitivity
    while camrot < -PI/4
        camrot += 2*PI
    wend
    
    while camrot >= 7*PI/4
        camrot -= 2*PI
    wend

    
    if abs(movev) > sensitivity then movev = sensitivity * sgn(movev)
    cam.location.y += elapsed*(abs(cam.location.y)+4) * movev/sensitivity

    
    
    cam.location.x = cos(camrot)*(cam.location.y+10) + camposx
    cam.location.z = sin(camrot)*(cam.location.y+10) + camposy
    
    cam.lookat.y = cam.location.y - 1
    if cam.lookat.y > -1 then cam.lookat.y = -1
    
    for n = 0 to 9
        if n = 0 then z = 11 else z = n+1
        if multikey(z) and multikey(FB.SC_ENTER) and keydelay < 0 then
            keydelay = .5
            x = int(cam.lookat.x)
            while x < 0
                x += boardsize
            wend
            y = int(cam.lookat.z)
            while y < 0
                y += boardsize
            wend
            
            for x1 = 0 to patterns(n).size-1
                for y1 = 0 to patterns(n).size-1
                    layers(-1).cells((x+x1) mod boardsize, (y+y1) mod boardsize) = patterns(n).dat(x1, y1)
                next y1
            next x1
        end if
    next n
    
    
    
    'Draw Scene
    'glDisable GL_TEXTURE_2D
    glEnable GL_BLEND
    glBlendFunc GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
    
    glLoadIdentity
    gluLookAt cam.location.x, cam.location.y, cam.location.z, cam.lookat.x, cam.lookat.y, cam.lookat.z, 0, 1, 0
    
    n = displaydepth-1
    'if n > 10 then n = 10
    
    for x1 = 0 to boardsize-1
        for y1 = 0 to boardsize-1
            templayer.cells(x1,y1) = layers(-1).cells(x1,y1)
        next y1
    next x1
    
    for z = n to -1 step -1
        sc = (1 - ((z-countdown/timestep)/depth)) / ((z+generation) mod 2 + 1)
        'glLoadIdentity
        'gluLookAt cam.location.x, cam.location.y, cam.location.z, cam.lookat.x, cam.lookat.y, cam.lookat.z, 0, 1, 0
            if z = 0 then
                for x = 0 to boardsize-1
                    for y = 0 to boardsize-1
                        if x = int(cam.lookat.x) and y = int(cam.lookat.z) then
                            glColor4f sin(totaltime*10)/4 + .75, 0.6, 0.6, 0.7
                        else
                            glColor4f 1.0, 1.0, 1.0, 0.1
                        end if
                        
                        glPushMatrix
                            glTranslatef x, -0.49, y
                            glCallList(firstlist+1)
                        glPopMatrix
                    next y
                next x
            end if
            
            if z = -1 then
            glDisable GL_TEXTURE_2D
            glPolygonMode GL_FRONT_AND_BACK, GL_LINE
        else
            glEnable GL_TEXTURE_2D
            glPolygonMode GL_FRONT_AND_BACK, GL_FILL
        end if
        
        for x = 0 to boardsize-1
            for y = 0 to boardsize-1
                
                if z = -1 then
                    for m = 0 to 9
                        if m = 0 then k = 11 else k = m+1
                        if multikey(k) then
                            x2 = int(cam.lookat.x)
                            while x2 < 0
                                x2 += boardsize
                            wend
                            y2 = int(cam.lookat.z)
                            while y2 < 0
                                y2 += boardsize
                            wend
                            
                            for x1 = 0 to patterns(m).size-1
                                for y1 = 0 to patterns(m).size-1
                                    if patterns(m).dat(x1,y1) = 1 then templayer.cells((x1+x2) mod boardsize, (y1+y2) mod boardsize) = 1
                                    'if (x2+x1) mod boardsize = x and (y2+y1) mod boardsize = y and patterns(m).dat(x1, y1) = 1 then
                                    '    tempcell = 1
                                    'else
                                    '    tempcell = 0
                                    'end if
                                next y1
                            next x1
                        end if
                    next m
                end if
                
                if (z = -1 and templayer.cells(x,y) > 0) or layers(z).cells(x,y) > 0 then
                        if layers(z).cells(x,y) < 10 then
                            cellcolor.r = 0
                            cellcolor.g = 1
                            cellcolor.b = (10 - layers(z).cells(x,y)) / 10
                        elseif layers(z).cells(x,y) < 50 then
                            cellcolor.r = (layers(z).cells(x,y) - 10) / 40
                            cellcolor.g = 1 - cellcolor.r
                            cellcolor.b = 0
                        elseif layers(z).cells(x,y) < 100 then
                            cellcolor.r = 1
                            cellcolor.g = 0
                            cellcolor.b = (layers(z).cells(x,y) - 50) / 50
                        elseif layers(z).cells(x,y) < 150 then
                            cellcolor.r = 1
                            cellcolor.g = (layers(z).cells(x,y) - 100) / 50
                            cellcolor.b = 1
                        else
                            cellcolor.r = 1
                            cellcolor.g = 1
                            cellcolor.b = 1
                        end if
                    
                    if z = -1 then
                        glColor4f cellcolor.r*countdown/timestep, cellcolor.g*countdown/timestep, cellcolor.b*countdown/timestep, (1-countdown/timestep)
                    elseif z = 0 then
                        glColor4f cellcolor.r, cellcolor.g, cellcolor.b, (1-countdown/timestep)*.9 + .1
                    elseif z = 1 then
                        glColor4f cellcolor.r*((countdown/2)/timestep + .5), cellcolor.g*((countdown/2)/timestep + .5), cellcolor.b*((countdown/2)/timestep + .5), 1.0
                        'glColor4f x/(boardsize*1.5 - countdown*(boardsize/2)/timestep), sc/(1.5 - countdown*.5/timestep), y/(boardsize*1.5 - countdown*(boardsize/2)/timestep), 1.0
                    elseif z = n then
                        'glColor4f x/boardsize*1.5 * (countdown/timestep), 0, y/boardsize*1.5 * (countdown/timestep), 1.0
                        glColor4f cellcolor.r/2, cellcolor.g/2, cellcolor.b/2, 1.0
                    else
                        'glColor4f x/boardsize*1.5, sc/1.5, y/boardsize*1.5, 1.0
                        glColor4f cellcolor.r/2, cellcolor.g/2, cellcolor.b/2, 1.0
                    end if
                    glPushMatrix
                        'if z = 0 then
                        '    if countdown/timestep > .5 then
                        '        glTranslatef x, countdown/timestep - .499, y
                        '        glScalef 2*(1-(countdown/timestep)), 0, 2*(1-(countdown/timestep))
                        '    else
                        '        'glTranslatef x, (countdown/timestep - .5)*2, y
                        '        glTranslatef x, 0, y
                        '        glScalef 1, 2*(1-countdown/timestep)-1, 1
                        '    end if
                        'else
                            'glScalef sc, 1, sc
                            'glScalef 1, sc, 1
                            'glScalef 1,1,1
                            
                            glTranslatef x, -z + countdown/timestep, y
                            if (camrot+PI/4) < PI/2 then
                                glRotatef 0, 0.0, 1.0, 0.0
                            elseif (camrot+PI/4) < PI then
                                glRotatef 90, 0.0, 1.0, 0.0
                            elseif (camrot+PI/4) < 3*PI/2 then
                                glRotatef 180, 0.0, 1.0, 0.0
                            elseif (camrot+PI/4) < 2*PI then
                                glRotatef 270, 0.0, 1.0, 0.0
                            end if
                        'end if
                        
                        glCallList(firstlist)
                    glPopMatrix
                end if
                
                
            next y
        next x
    next z
    
    
    
    glDisable GL_BLEND
    
    glEnable GL_TEXTURE_2D
    glPolygonMode GL_FRONT_AND_BACK, GL_FILL

    
    'Draw text
    
    glEnable GL_TEXTURE_2D
    glDisable GL_DEPTH_TEST                                         '' Disables Depth Testing
    glEnable GL_BLEND
	glMatrixMode GL_PROJECTION                                      '' Select The Projection Matrix
	glPushMatrix                                                    '' Store The Projection Matrix
		glLoadIdentity                                              '' Reset The Projection Matrix
		glOrtho 0, screenwidth, 0, screenheight, -1, 1                                '' Set Up An Ortho Screen
		glMatrixMode GL_MODELVIEW                                   '' Select The Modelview Matrix
		glPushMatrix                                                '' Store The Modelview Matrix
            'Print text
            glLoadIdentity
            
            for n = 0 to 9
                if (timer - console(n).t) < 10 then
                    col = 1-((timer - console(n).t)/10)
                    glColor4f col, col, (col/2)+.5, 1
                    glPrint 0, n*16, console(n).text, 1
                else
                    
                end if
            next n
            
            
            
            
            if multikey(FB.SC_F1) then
                for n = 0 to 9
                    glColor4f 1.0, 1.0, 1.0, 0.8
                    glPrint int(screenwidth * 0.07), screenheight - (n+3)*16, n & " " & patterns(n).patternname, 1
                next n
                glColor4f 0.5, 0.5, 0.5, 0.8
            else
                glColor4f 1.0, 1.0, 1.0, 0.8
            end if
            glPrint int(screenwidth * 0.07), screenheight - 16, "F1: Display stored patterns", 1
            glColor4f 1.0, 1.0, 1.0, 0.8
            glPrint int(screenwidth * 0.07) + 336, screenheight - 16, "F5: Clear Map", 1
            
            'Draw other controls
            
            'Draw speed meter
            glLoadIdentity
            glColor4f 1.0, 1.0, 0.5, 0.8
            glPrint screenwidth*.035 - 24, screenheight*.5 - 32, "Stop", 1
            glPrint screenwidth*.035 - 16, screenheight*.9 + 16, "Max", 1
            glPrint screenwidth*.01, screenheight*.9 + 48, "Speed", 1
            
            glLoadIdentity
            glDisable GL_TEXTURE_2D
            glColor4f 0.0, 1.0, 1.0, 0.2
            glBegin GL_QUADS
                glVertex2f screenwidth*.01 - 3, screenheight*.5 - 48
                glVertex2f screenwidth*.01 - 3, screenheight*.9 + 48
                glVertex2f screenwidth*.06 + 3, screenheight*.9 + 48
                glVertex2f screenwidth*.06 + 3, screenheight*.5 - 48
            glEnd
            glColor4f 0.0, 0.0, 0.5, 0.8
            glBegin GL_LINE_LOOP
                glVertex2f screenwidth*.01 - 3, screenheight*.5 - 48
                glVertex2f screenwidth*.01 - 3, screenheight*.9 + 48
                glVertex2f screenwidth*.06 + 3, screenheight*.9 + 48
                glVertex2f screenwidth*.06 + 3, screenheight*.5 - 48
            glEnd
            
            glBegin GL_QUADS
                glColor4f 1.0, 0.0, 0.5, 0.6
                glVertex2f screenwidth*.02, screenheight*.5
                glColor4f 0.0, 1.0, 0.5, 0.6
                glVertex2f screenwidth*.02, screenheight*.9
                glVertex2f screenwidth*.05, screenheight*.9
                glColor4f 1.0, 0.0, 0.5, 0.6
                glVertex2f screenwidth*.05, screenheight*.5
            glEnd
            glColor4f 0.0, 0.0, 0.5, 0.6
            glBegin GL_LINE_LOOP
                glVertex2f screenwidth*.02, screenheight*.5
                glVertex2f screenwidth*.02, screenheight*.9
                glVertex2f screenwidth*.05, screenheight*.9
                glVertex2f screenwidth*.05, screenheight*.5
            glEnd
            
            glColor4f 1 - exespeed/(frameratecap*timestep), exespeed/(frameratecap*timestep), 0.0, 0.8
            glBegin GL_QUADS
                glVertex2f screenwidth*.01, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight*.49
                glVertex2f screenwidth*.01, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight*.51
                glVertex2f screenwidth*.06, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight*.51
                glVertex2f screenwidth*.06, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight*.49
            glEnd
            glColor4f 0.0, 0.0, 0.5, 0.6
            glBegin GL_LINE_LOOP
                glVertex2f screenwidth*.01, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight*.49
                glVertex2f screenwidth*.01, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight*.51
                glVertex2f screenwidth*.06, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight*.51
                glVertex2f screenwidth*.06, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight*.49
            glEnd
            
            glEnable GL_TEXTURE_2D
            glColor4f 1.0, 1.0, 1.0, 1.0
            glPrint screenwidth*.06 - len(str(int(exespeed)))*12, (exespeed/(frameratecap*timestep) * screenheight*.4) + screenheight * .5 - 8, str(int(exespeed)), 1
            
            
            'Draw mouse
            glLoadIdentity
            glDisable GL_TEXTURE_2D
            glColor4f 1.0, 1.0, 1.0, 0.5
            mousey = screenheight - mousey
            glBegin GL_POLYGON
                glVertex2f mousex, mousey
                glVertex2f mousex + 12, mousey - 12
                glVertex2f mousex + 5, mousey - 10
                glVertex2f mousex, mousey - 18
            glEnd
            glColor4f 0.0, 0.0, 0.0, 1.0
            glBegin GL_LINE_LOOP
                glVertex2f mousex, mousey
                glVertex2f mousex + 12, mousey - 12
                glVertex2f mousex + 5, mousey - 10
                glVertex2f mousex, mousey - 18
            glEnd
            
			glMatrixMode GL_PROJECTION                              '' Select The Projection Matrix
		glPopMatrix                                                 '' Restore The Old Projection Matrix
		glMatrixMode GL_MODELVIEW                                   '' Select The Modelview Matrix
	glPopMatrix                                                     '' Restore The Old Projection Matrix
    glDisable GL_BLEND
	glEnable GL_DEPTH_TEST                                          '' Enables Depth Testing
    
    
   
    DrawScreen()
    
    if Inkey = Chr( 255 ) + "k" then exit do
    if multikey(FB.SC_ESCAPE) then exit do
loop

CleanupGL()