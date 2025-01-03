---@type Zenitha.Scene
local scene={}

local btnN=WIDGET.new{type='button_simp',pos={.5,.5},x=-160,y=100,w=260,h=100,frameColor=COLOR.LD,fillColor=COLOR.dL,text=LANG'quit_back',code=WIDGET.c_pressKey'escape'}
local btnY=WIDGET.new{type='button_simp',pos={.5,.5},x= 160,y=100,w=260,h=100,frameColor=COLOR.R, fillColor=COLOR.LR,text=LANG'quit_back',code=WIDGET.c_pressKey'escape'}
local function freshWidget(timer)
    btnN.y=100+timer*300
    btnN:resetPos()
    btnY.y=100+timer*300
    btnY:resetPos()
end

local aboveScene

local alpha=0
local function setAlpha(t) alpha=(1-t)*.62 end
local function setPos(t) freshWidget(t) end

local enterMode
local timer=1
local function animTimer() return timer and timer^2 end

local quitText=GC.newText(FONT.get(60))

function scene.load(prev)
    aboveScene=SCN.scenes[prev] or NONE
    enterMode=true
    timer=1
    TWEEN.tag_kill('quit_sure')
    TWEEN.new(setAlpha):setEase('OutQuad'):setDuration(.26):setTag('quit_sure'):run(animTimer)
    TWEEN.new(setPos):setEase('OutQuad'):setDuration(.42):setTag('quit_sure'):run(animTimer)
    quitText:set(Texts.quit_title)
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='escape' then
        enterMode=false
        timer=timer or 0
        TWEEN.tag_kill('quit_sure')
        TWEEN.new(setAlpha):setEase('OutQuad'):setDuration(.26):setTag('quit_sure'):run(animTimer)
        TWEEN.new(setPos):setEase('OutQuad'):setDuration(.42):setTag('quit_sure'):run(animTimer)
    end
    return true
end

function scene.update(dt)
    if timer then
        if enterMode then
            if timer>0 then
                timer=math.max(0,timer-4*dt)
            else
                timer=nil
            end
        else
            if timer<1 then
                timer=math.min(1,timer+4*dt)
            else
                SCN.back('none')
            end
        end
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

    GC.replaceTransform(SCR.origin)
    GC.setColor(0,0,0,alpha)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)

    GC.replaceTransform(SCR.xOy_m)
    GC.setColor(COLOR.L)
    GC.strokeDraw('corner',6,quitText,0,-100-(animTimer() or 0)*300,0,2,2,quitText:getWidth()/2,quitText:getHeight()/2)
    GC.setColor(COLOR.D)
    GC.mDraw(quitText,0,-100-(animTimer() or 0)*300,0,2)
end

scene.widgetList={
    btnN,btnY,
}
return scene
