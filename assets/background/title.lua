local back={}

local gc=love.graphics
local floor=math.floor
local min=math.min
function back.draw()
    gc.clear(.89,.89,.89)
    gc.replaceTransform(SCR.origin)
    gc.translate(SCR.w/2,SCR.h/2)
    gc.setColor(1,1,1)
    local tex=TEX.menu[floor(love.timer.getTime()*12%6+1)]
    GC.mDraw(
        tex,0,0,0,
        min(SCR.w/tex:getWidth(),SCR.h/tex:getHeight())
    )
end

return back
