---@type Zenitha.Scene
local scene={}

local aboveScene

local textProgress
local finished

function scene.load(prev)
    aboveScene=SCN.scenes[prev] or NONE
    textProgress=1
    finished=TABLE.find(DATA.skin,'关注娘')
    scene.widgetList.sub:setVisible(not finished)
end

local function subscribe()
    if not finished and TASK.lock('sub',2.6) then
        love.system.openURL(ChessData['一只略'].link)
        TASK.new(function()
            TASK.yieldT(1.26)
            finished=true
            scene.widgetList.sub:setVisible(false)
        end)
    end
end
local function leave()
    if finished then
        SCN.back('none')
    elseif TASK.lock('subscribe_lock',2.6) then
        MSG('info',Texts.crash_texts[textProgress],6.2)
        textProgress=textProgress+1
        if not Texts.crash_texts[textProgress] then
            DATA.getSkin('关注娘')
            finished=true
            scene.widgetList.sub:setVisible(false)
        end
    end
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='escape' then
        leave()
    elseif key=='space' or key=='return' then
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
    GC.setColor(.2,.5,1,.8)
    GC.rectangle('fill',0,0,SCR.w,SCR.h)

    GC.replaceTransform(SCR.xOy)
    GC.setColor(1,1,1)
    GC.mDraw(TEX.crash,500,300,nil,2)

    if finished then
        GC.polygon('fill',
            263,306,
            533,299,
            453,521,
            262,513
        )
        GC.setColor(COLOR.D)
        FONT.set(60)
        GC.print("感谢！",300,384-Jump.smooth()*20)
    end
end

scene.widgetList={
    WIDGET.new{type='button_invis',x=705,y=100,w=75,h=60,code=leave},
    WIDGET.new{type='button_invis',x=635,y=100,w=65,h=55,code=leave},
    WIDGET.new{name='sub',type='button_invis',x=385,y=420,w=160,h=90,code=subscribe},
}
return scene
