---@type Zenitha.Scene
local scene = {}

function scene.load()
end

function scene.mouseDown(x, y, k)
end

function scene.keyDown(key, isRep)
end

function scene.update(dt)
end

function scene.draw()
    GC.setColor(COLOR.D)
    FONT.set(80)
    GC.print("棋子皮肤设置菜单\n      还没做", 500, 260, .1 * Jump.dodge(), 1.2, nil, 300, 50)
end

scene.widgetList = {
    QuitButton,
}
return scene
