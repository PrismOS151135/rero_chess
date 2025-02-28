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
    GC.print("联机准备菜单\n\n还没做", 50, 130)
    FONT.set(20)
    GC.print("(理直气壮)", 300, 380)
end

scene.widgetList = {
    QuitButton,
}
return scene
