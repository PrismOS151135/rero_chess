---@type Zenitha.Scene
local scene = {}

local mode, data

function scene.load()
    mode, data = SCN.args[1], SCN.args[2] or ""
end

function scene.mouseDown(x, y, k)
end

function scene.keyDown(key, isRep)
end

function scene.update(dt)
end

function scene.draw()
    GC.setColor(COLOR.D)
    FONT.set(50)
    GC.print(mode, 100, 60)
    GC.print(data, 100, 120)
end

scene.widgetList = {
    QuitButton,
}
return scene
