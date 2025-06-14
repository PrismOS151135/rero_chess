---@type Zenitha.Scene
local scene = {}

local btn = WIDGET.new {
    type = 'button_simp', pos = { .5, .5 },
    x = 0, y = 100, w = 300, h = 100,
    frameColor = COLOR.S, fillColor = COLOR.LS,
    fontSize = 30, text = LANG 'leave_sure',
    onClick = WIDGET.c_pressKey 'escape',
}
local function freshWidget(timer)
    btn.y = 100 + timer * 300
    btn:resetPos()
end

local aboveScene

local alpha = 0
local function setAlpha(t) alpha = (1 - t) * .62 end
local function setPos(t) freshWidget(t) end

local animIn
local timer
local function animTimer() return timer ^ 2 end

local winnerText = GC.newText(FONT.get(60))

function scene.load(prev)
    if SCN.stackChange > 0 then
        aboveScene = SCN.scenes[prev] or NONE
    end

    animIn = true
    timer = 1
    TWEEN.tag_kill('leave_sure')
    TWEEN.new(setAlpha):setEase('OutQuad'):setDuration(.26):setTag('leave_sure'):run(animTimer)
    TWEEN.new(setPos):setEase('OutQuad'):setDuration(.42):setTag('leave_sure'):run(animTimer)

    winnerText:set(SCN.args[1].name .. "胜利！")
end

function scene.unload()
    TWEEN.tag_kill('leave_sure')
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' then
        SCN._pop()
        SCN.back()
    end
    return true
end

function scene.update(dt)
    if animIn then
        timer = math.max(0, timer - 4 * dt)
    elseif timer < 1 then
        timer = math.min(1, timer + 4 * dt)
    else
        SCN.back('none')
    end
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
    GC.setColor(0, 0, 0, alpha)
    GC.rectangle('fill', 0, 0, SCR.w, SCR.h)


    -- Texts
    GC.replaceTransform(SCR.xOy_m)
    GC.setColor(COLOR.L)
    local size = math.min(2, 800 / winnerText:getWidth())
    GC.strokeDraw('full', 6, winnerText, 0, -100 - animTimer() * 300, 0, size, size, winnerText:getWidth() / 2, winnerText:getHeight() / 2)
    GC.setColor(COLOR.D)
    GC.mDraw(winnerText, 0, -100 - animTimer() * 300, 0, size)
end

scene.widgetList = {
    btn,
}

return scene
