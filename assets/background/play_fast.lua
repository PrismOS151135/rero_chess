local back={}

local w,h

function back.init()
    back.resize()
end

function back.resize()
    w,h=SCR.w,SCR.h
end

local min=math.min
local gc=love.graphics
local gc_clear,gc_origin,gc_translate=gc.clear,gc.origin,gc.translate
local gc_setColor,gc_draw=gc.setColor,gc.draw

function back.draw()
    gc_clear(.89,.89,.89)
    gc_origin()
    gc_translate(w/2,h/2)
    gc_setColor(1,1,1,.26)
    gc_draw(TEX.bg_anim[Jump.bgFrame()],nil,nil,nil,min(w/798,h/532),nil,798*.5,532*.5)
end

return back
