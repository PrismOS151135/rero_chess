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
    GC.setColor(COLOR.D)
    FONT.set(80)
    GC.print("涂鸦设置菜单\n别急 也还没做",100,100,0.1,1.6)
end

scene.widgetList={
    QuitButton,
}
return scene
