---@type Zenitha.Scene
local scene={}

function scene.load()
    CURSOR.set('pointer')
    BG.set('title')
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='enter' then
        SCN.go('play',nil,'newGame')
    elseif key=='escape' then
        SCN.go('quit_sure','none')
    end
    return true
end

function scene.draw()
    GC.replaceTransform(SCR.xOy)
    GC.setColor(COLOR.D)
    FONT.set(90)
    GC.mStr(Texts.menu_title,500,100)
    FONT.set(30)
    GC.mStr(Texts.menu_info,500,210)
end

scene.widgetList={
    WIDGET.new{type='button_simp',pos={.5,.5},y=160,w=160,h=80,fontSize=40,text=LANG'menu_play',code=WIDGET.c_pressKey'enter'},
    QuitButton,
}
return scene
