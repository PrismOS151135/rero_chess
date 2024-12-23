---@type Zenitha.Scene
local scene={}

function scene.load()
end

function scene.mouseDown(x,y,k)
end
function scene.keyDown(key,isRep)
end

function scene.update(dt)
end

function scene.draw()
end

scene.widgetList={
    WIDGET.new{type='button_simp',pos={1,1},x=-120,y=-80,w=160,h=80,sound_press='back',fontSize=60,text=CHAR.icon.back,code=WIDGET.c_backScn()},
}
return scene
