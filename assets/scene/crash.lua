---@type Zenitha.Scene
local scene={}

local aboveScene

function scene.load(prev)
    aboveScene=SCN.scenes[prev] or NONE
end

function scene.draw()
    if aboveScene.draw then
        aboveScene.draw()
    end
    if aboveScene.widgetList then
        GC.replaceTransform(SCR.xOy)
        WIDGET.draw(aboveScene.widgetList)
    end

    -- Back
    GC.origin()
    GC.setColor(.2,.5,1,.8)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)

    GC.replaceTransform(SCR.xOy_m)
    GC.setColor(1,1,1)
    GC.mDraw(TEX.crash,nil,nil,nil,2)
end

scene.widgetList={
    WIDGET.new{type='button_invis',x=705,y=100,w=75,h=60,code=WIDGET.c_backScn'none'},
    WIDGET.new{type='button_invis',x=635,y=100,w=65,h=55,code=WIDGET.c_backScn'none'},
    WIDGET.new{type='button_invis',x=385,y=420,w=160,h=90,code=function() love.system.openURL(ChessData['一只略'].link) end},
}
return scene
