---@type Zenitha.Scene
local scene = {}

local btnN = WIDGET.new {
    type = 'button_simp', pos = { .5, .5 },
    x = -180, y = 100, w = 300, h = 100,
    frameColor = COLOR.LD, fillColor = COLOR.dL,
    fontSize = 30, text = function() return ("$2 $1 $2"):repD(Texts.quit_back, CHAR.icon.back) end,
    onClick = WIDGET.c_pressKey 'escape',
}
local btnY = WIDGET.new {
    type = 'button_simp', pos = { .5, .5 },
    x = 180, y = 100, w = 300, h = 100,
    frameColor = COLOR.R, fillColor = COLOR.LR,
    fontSize = 30, text = function() return ("$2 $1 $2"):repD(Texts.quit_sure, CHAR.icon.cross_big) end,
    onClick = WIDGET.c_pressKey 'return',
}
local function freshWidget(timer)
    btnN.y = 100 + timer * 300
    btnN:resetPos()
    btnY.y = 100 + timer * 300
    btnY:resetPos()
end

local aboveScene

local alpha = 0
local function setAlpha(t) alpha = (1 - t) * .62 end
local function setPos(t) freshWidget(t) end

local animIn
local timer
local function animTimer() return timer ^ 2 end

local quitText = GC.newText(FONT.get(60))

function scene.load(prev)
    if SCN.stackChange > 0 then
        aboveScene = SCN.scenes[prev] or NONE
    end

    animIn = true
    timer = 1
    TWEEN.tag_kill('quit_sure')
    TWEEN.new(setAlpha):setEase('OutQuad'):setDuration(.26):setTag('quit_sure'):run(animTimer)
    TWEEN.new(setPos):setEase('OutQuad'):setDuration(.42):setTag('quit_sure'):run(animTimer)

    quitText:set(
        SCN.args[1] == 'quit' and Texts.quit_title_quit or
        Texts.quit_title_back
    )
end

function scene.unload()
    TWEEN.tag_kill('quit_sure')
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' then
        animIn = false
        TWEEN.tag_kill('quit_sure')
        TWEEN.new(setAlpha):setEase('OutQuad'):setDuration(.26):setTag('quit_sure'):run(animTimer)
        TWEEN.new(setPos):setEase('OutQuad'):setDuration(.42):setTag('quit_sure'):run(animTimer)
    elseif key == 'return' then
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
    GC.strokeDraw('full', 6, quitText, 0, -100 - animTimer() * 300, 0, 2, 2, quitText:getWidth() / 2,
        quitText:getHeight() / 2)
    GC.setColor(COLOR.D)
    GC.mDraw(quitText, 0, -100 - animTimer() * 300, 0, 2)
end

scene.widgetList = {
    btnN, btnY,
}

return scene
