local gc=love.graphics
local gc_translate,gc_scale,gc_rotate,gc_shear=gc.translate,gc.scale,gc.rotate,gc.shear
local gc_setColor,gc_setLineWidth,gc_setLineJoin=gc.setColor,gc.setLineWidth,gc.setLineJoin
local gc_line,gc_rectangle,gc_circle,gc_polygon=gc.line,gc.rectangle,gc.circle,gc.polygon



local lib={}

lib.pointer={}
local norm_wid=.8
local norm_poly={
    0*math.cos(0),0*math.sin(0),
    30*math.cos(0),0*math.sin(0),
    20*math.cos(norm_wid*.48),20*math.sin(norm_wid*.48),
    30*math.cos(norm_wid),30*math.sin(norm_wid),
}
function lib.pointer.draw(x,y)
    gc_translate(x,y)

    gc_setColor(COLOR.L)
    gc_rotate(.6)
    gc_polygon('fill',norm_poly)

    gc_setColor(COLOR.D)
    gc_setLineWidth(2)
    gc_setLineJoin('bevel')
    gc_polygon('line',norm_poly)
end
function lib.pointer.clickFX(x,y)
    for i=1,3 do
        local a=-i-math.random()+.26
        local sr=MATH.rand(6,12)
        local er=MATH.rand(15,22)
        local sx,sy=x+sr*math.cos(a),y+sr*math.sin(a)
        local ex,ey=x+er*math.cos(a),y+er*math.sin(a)
        SYSFX.beam(0.16,sx,sy,ex,ey,4,0,0,0)
    end
end

lib.move={}
local move_poly={
    -3,-3,
    -3,-10,
    -7,-10,
    0,-17,
    7,-10,
    3,-10,
}
for i=12,36,12 do
    for j=0,11,2 do
        move_poly[i+j+1]=-move_poly[i-12+j+2]
        move_poly[i+j+2]=move_poly[i-12+j+1]
    end
end
function lib.move.draw(x,y)
    gc_translate(x,y)

    gc_setColor(COLOR.L)
    gc_rectangle('fill',-3,-10,6,20)
    gc_rectangle('fill',-10,-3,20,6)
    gc_polygon('fill',-7,-10,0,-17,7,-10)
    gc_polygon('fill',-7,10,0,17,7,10)
    gc_polygon('fill',-10,-7,-17,0,-10,7)
    gc_polygon('fill',10,-7,17,0,10,7)

    gc_setColor(COLOR.D)
    gc_setLineWidth(2)
    gc_polygon('line',move_poly)
end

lib.hand={}
local hand_poly={
    0,0,
    0,30,
    5,30,
    5,23,
    10,23,
    10,22,
    15,22,
    15,20,
    20,20,
    20,0
}
local lastClickTime=0
function lib.hand.draw(x,y)
    gc_translate(x,y)
    gc_rotate(0.2)
    local dt=love.timer.getTime()-lastClickTime
    dt=MATH.roundUnit(dt,0.05)
    gc_translate(0,-30+(1/(1+42*dt))*26)

    gc_setColor(COLOR.L)
    gc_polygon('fill',hand_poly)

    gc_setColor(COLOR.D)
    gc_setLineWidth(2)
    gc_polygon('line',hand_poly)
    gc_line( 5,23, 5,13)
    gc_line(10,22,10,13)
    gc_line(15,20,15,13)
end
function lib.hand.clickFX(s)
    lastClickTime=love.timer.getTime()
end



local cursor={}

local curMode=false
function cursor.set(m)
    if m==curMode then return end
    assert(lib[m],'Invalid cursor mode: '..m)
    curMode=m
    ZENITHA.globalEvent.drawCursor=lib[m].draw or lib.pointer.draw
    ZENITHA.globalEvent.clickFX=lib[m].clickFX or NULL
end

return cursor
