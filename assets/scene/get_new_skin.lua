---@type Zenitha.Scene
local scene={}

local aboveScene

local skin

local alpha=0
local function setAlpha(t) alpha=(1-t)*.8 end

local animIn
local timer=1
local function animTimer() return timer^2 end

local titleText=GC.newText(FONT.get(50))
local skinNameText=GC.newText(FONT.get(30))

local function quit()
    if timer>0 then return end
    animIn=false
    TWEEN.tag_kill('quit_sure')
    TWEEN.new(setAlpha):setEase('OutQuad'):setDuration(.26):setTag('quit_sure'):run(animTimer)
end

function scene.load(prev)
    if SCN.stackChange>0 then
        aboveScene=SCN.scenes[prev] or NONE
    end

    animIn=true
    timer=1
    TWEEN.tag_kill('quit_sure')
    TWEEN.new(setAlpha):setEase('OutQuad'):setDuration(.26):setTag('quit_sure'):run(animTimer)

    titleText:set(Texts.new_skin)
    if ChessData[SCN.args[1]] then
        skin=SCN.args[1]
        skinNameText:set(skin)
    else
        skinNameText:set("?")
    end
end

function scene.unload()
    TWEEN.tag_kill('quit_sure')
end

function scene.mouseClick() scene.keyDown('space') end
function scene.touchClick() scene.keyDown('space') end

function scene.keyDown(_,isRep)
    if isRep then return true end
    quit()
    return true
end

function scene.update(dt)
    if aboveScene.update then
        aboveScene.update(dt)
    end

    if animIn then
        timer=math.max(0,timer-1.26*dt)
    elseif timer<1 then
        timer=math.min(1,timer+1.62*dt)
    else
        SCN.back('none')
    end
end

local function lightStencil()
    local n=7
    local r=MATH.tau/n
    for j=0,n-1 do
        GC.arc('fill','pie',0,0,256,j*r,(j+.5)*r)
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
    GC.setColor(0,0,0,alpha)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)

    -- Light
    GC.replaceTransform(SCR.xOy_m)
    GC.setColor(1,1,.626,.26)
    GC.rotate(love.timer.getTime()*1.26)
    GC.setStencilTest('greater',0)
    GC.stencil(lightStencil,'replace',1)
    GC.blurCircle(0,0,0,256*(1-math.min(2.6*timer,1))^.5)
    GC.setStencilTest()

    -- Texts
    GC.replaceTransform(SCR.xOy_m)
    GC.setColor(COLOR.D)
    GC.strokeDraw('full',4,titleText,0,-200-(animTimer() or 0)*300,0,2,2,titleText:getWidth()/2,titleText:getHeight()/2)
    GC.strokeDraw('full',4,skinNameText,0,200+(animTimer() or 0)*300,0,2,2,skinNameText:getWidth()/2,skinNameText:getHeight()/2)
    GC.setColor(COLOR.dL)
    GC.mDraw(titleText,0,-200-animTimer()*300,0,2)
    GC.mDraw(skinNameText,0,200+animTimer()*300,0,2)

    -- Skin
    GC.scale((1-(timer)^2)*.8)
    GC.setColor(1,1,1,math.min(1,3-3*timer))
    GC.mDraw(TEX.chess[skin].base)
    GC.mDraw(TEX.chess[skin].normal)
end

return scene
