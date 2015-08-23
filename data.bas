dim shared as gluint ptr cubetex
dim shared as gluint ptr skybox

dim shared as gluint firstlist
dim shared as gluint skyboxlist

dim shared as gluint fontbase
dim shared as gluint ptr fonttex
dim shared as gluint ptr fontmasktex

type coord3
    x as glfloat
    y as glfloat
    z as glfloat
end type

type coord3s
    r as glfloat
    o as glfloat
    p as glfloat
end type

type rgba1
    r as glfloat
    g as glfloat
    b as glfloat
    a as glfloat
end type


type camera
    location as coord3
    lookat as coord3
    up as coord3
end type

type consolestring
    t as double
    text as string
end type

dim shared as consolestring console(10)

type pattern
    dat(10,10) as integer
    size as integer
    patternname as string
end type

dim shared as pattern patterns(10)

const PI = 3.141592