---@type Zenitha.Scene
local scene = {}

local aboveScene

local subscribed

local alpha
local showWindow

function scene.load(prev)
    if SCN.stackChange > 0 then
        aboveScene = SCN.scenes[prev] or NONE
        alpha = 0
        showWindow = false
        TASK.new(function()
            repeat alpha = alpha + coroutine.yield() until alpha >= .8
            alpha = .8
            TASK.yieldT(1.2)
            showWindow = true
        end)
        subscribed = TABLE.find(DATA.skin, '关注娘')
        scene.widgetList.sub:setVisible(not subscribed)
    end
end

local function subscribe()
    if not subscribed and TASK.lock('subscribe_go', 2.6) then
        love.system.openURL(ChessData['一只略'].link)
        TASK.new(function()
            TASK.yieldT(1.26)
            subscribed = true
            scene.widgetList.sub:setVisible(false)
            DATA.getSkin('关注娘')
        end)
    end
end
local function leave()
    if subscribed then
        SCN.back('none')
    elseif TASK.lock('subscribe_lock', 6.2) then
        MSG('info', Texts.crash_sure, 6.2)
    else
        SCN.back('none')
    end
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' then
        leave()
    elseif key == 'space' or key == 'return' then
        subscribe()
    end
    return true
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
    GC.setColor(.95, .95, .95, alpha)
    GC.rectangle('fill', 0, 0, SCR.w, SCR.h)

    -- Window
    if showWindow then
        GC.replaceTransform(SCR.xOy)
        GC.setColor(1, 1, 1)
        GC.mDraw(TEX.crash, 500, 300, nil, 2)
        if subscribed then
            GC.polygon('fill',
                263, 306,
                533, 299,
                453, 521,
                262, 513
            )
            GC.setColor(COLOR.D)
            FONT.set(60)
            GC.print(Texts.crash_thanks, 300, 384 - Jump.smooth() * 20)
        end
    end
end

scene.widgetList = {
    WIDGET.new { type = 'button_invis', x = 705, y = 100, w = 75, h = 60, onClick = leave },
    WIDGET.new { type = 'button_invis', x = 635, y = 100, w = 65, h = 55, onClick = leave },
    WIDGET.new { name = 'sub', type = 'button_invis', x = 385, y = 420, w = 160, h = 90, onClick = subscribe },
}
return scene
