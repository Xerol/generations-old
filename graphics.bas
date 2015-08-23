declare sub generateLists()
declare sub initTextures()


sub initTextures()
    cubetex = LoadGLTexture("textures/cube.bmp")
    'skybox = LoadGLTexture("textures/background.bmp")
end sub


sub generateLists()
    dim as integer x, y, z
    firstlist = glGenLists(1000)
    
    glNewList(firstlist, GL_COMPILE)
        'glEnable(GL_TEXTURE_2D)
        glBindTexture(GL_TEXTURE_2D, *cubetex)
        glBegin GL_QUADS
            'Bottom
            glNormal3f 0.0, -1.0, 0.0
            glTexCoord2f 0, 0
            glVertex3f -0.5, -0.5, -0.5
            glTexCoord2f 1, 0
            glVertex3f 0.5, -0.5, -0.5
            glTexCoord2f 1, 1
            glVertex3f 0.5, -0.5, 0.5
            glTexCoord2f 0, 1
            glVertex3f -0.5, -0.5, 0.5
            'Back
            glNormal3f 0.0, 0.0, 1.0
            glTexCoord2f 0, 0
            glVertex3f -0.5, -0.5, 0.5
            glTexCoord2f 1, 0
            glVertex3f 0.5, -0.5, 0.5
            glTexCoord2f 1, 1
            glVertex3f 0.5, 0.5, 0.5
            glTexCoord2f 0, 1
            glVertex3f -0.5, 0.5, 0.5
            'Right
            glNormal3f 1.0, 0.0, 0.0
            glTexCoord2f 0, 0
            glVertex3f 0.5, -0.5, -0.5
            glTexCoord2f 1, 0
            glVertex3f 0.5, -0.5, 0.5
            glTexCoord2f 1, 1
            glVertex3f 0.5, 0.5, 0.5
            glTexCoord2f 0, 1
            glVertex3f 0.5, 0.5, -0.5
            'Left
            glNormal3f -1.0, 0.0, 0.0
            glTexCoord2f 0, 0
            glVertex3f -0.5, -0.5, -0.5
            glTexCoord2f 1, 0
            glVertex3f -0.5, -0.5, 0.5
            glTexCoord2f 1, 1
            glVertex3f -0.5, 0.5, 0.5
            glTexCoord2f 0, 1
            glVertex3f -0.5, 0.5, -0.5
            'Front
            glNormal3f 0.0, 0.0, -1.0
            glTexCoord2f 0, 0
            glVertex3f -0.5, -0.5, -0.5
            glTexCoord2f 1, 0
            glVertex3f 0.5, -0.5, -0.5
            glTexCoord2f 1, 1
            glVertex3f 0.5, 0.5, -0.5
            glTexCoord2f 0, 1
            glVertex3f -0.5, 0.5, -0.5
            'Top
            glNormal3f 0.0, 1.0, 0.0
            glTexCoord2f 0, 0
            glVertex3f -0.5, 0.5, -0.5
            glTexCoord2f 1, 0
            glVertex3f 0.5, 0.5, -0.5
            glTexCoord2f 1, 1
            glVertex3f 0.5, 0.5, 0.5
            glTexCoord2f 0, 1
            glVertex3f -0.5, 0.5, 0.5
        glEnd
    glEndList()
    
'    glNewList(skyboxlist, GL_COMPILE)
'        glColor4f 1.0, 1.0, 1.0, 1.0
'        glBindTexture GL_TEXTURE_2D, *skybox
'        x = 3 'texture repeat
'        glBegin GL_QUADS
'            glTexCoord2f 0, 0
'            glVertex3f -100, -100, -100
'            glTexCoord2f 0, x
'            glVertex3f -100, 100, -100
'            glTexCoord2f x, x
'            glVertex3f -100, 100, 100
'            glTexCoord2f x, 0
'            glVertex3f -100, -100, 100
'            
'            glTexCoord2f 0, 0
'            glVertex3f 100, -100, -100
'            glTexCoord2f 0, x
'            glVertex3f 100, 100, -100
'            glTexCoord2f x, x
'            glVertex3f 100, 100, 100
'            glTexCoord2f x, 0
'            glVertex3f 100, -100, 100
'            
'            glTexCoord2f 0, 0
'            glVertex3f -100, -100, -100
'            glTexCoord2f 0, x
'            glVertex3f 100, -100, -100
'            glTexCoord2f x, x
'            glVertex3f 100, -100, 100
'            glTexCoord2f x, 0
'            glVertex3f -100, -100, 100
'            
'            glTexCoord2f 0, 0
'            glVertex3f -100, 100, -100
'            glTexCoord2f 0, x
'            glVertex3f 100, 100, -100
'            glTexCoord2f x, x
'            glVertex3f 100, 100, 100
'            glTexCoord2f x, 0
'            glVertex3f -100, 100, 100
'            
'            glTexCoord2f 0, 0
'            glVertex3f -100, -100, -100
'            glTexCoord2f 0, x
'            glVertex3f -100, 100, -100
'            glTexCoord2f x, x
'            glVertex3f 100, 100, -100
'            glTexCoord2f x, 0
'            glVertex3f 100, -100, -100
'            
'            glTexCoord2f 0, 0
'            glVertex3f -100, -100, 100
'            glTexCoord2f 0, x
'            glVertex3f -100, 100, 100
'            glTexCoord2f x, x
'            glVertex3f 100, 100, 100
'            glTexCoord2f x, 0
'            glVertex3f 100, -100, 100
'            
'            
'        glEnd
'    glEndList()
'
    glNewList(firstlist+1, GL_COMPILE)
        glDisable(GL_TEXTURE_2D)
        glLineWidth 2.0
        glBegin GL_LINE_LOOP
            glVertex3f -0.5, 0.0, -0.5
            glVertex3f 0.5, 0.0, -0.5
            glVertex3f 0.5, 0.0, 0.5
            glVertex3f -0.5, 0.0, 0.5
            glVertex3f -0.5, 0.0, -0.5
        glEnd
    glEndList
end sub
