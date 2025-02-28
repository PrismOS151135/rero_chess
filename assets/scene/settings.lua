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
    FONT.set(70)
    GC.print("其实我没懂有什么好设置的", 50, 130)
    FONT.set(40)
    GC.print("但既然略把设置按钮画好了就先放一个在这里", 120, 520 - 40 * Jump.smooth())
end

scene.widgetList = {
    QuitButton,
}
return scene
