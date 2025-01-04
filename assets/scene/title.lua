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
        SCN.go('quit_sure','none','quit')
    end
    return true
end

function scene.draw()
    GC.replaceTransform(SCR.xOy)
    GC.setColor(COLOR.D)
    FONT.set(90) GC.mStr(Texts.menu_title,500,100)
    FONT.set(30) GC.mStr(Texts.menu_info,500,210)

    GC.setColor(COLOR.L)
    for i=1,5 do
        GC.mRect('fill',scene.widgetList[i]._x,scene.widgetList[i]._y,75,75,25)
    end
end

scene.widgetList={
    WIDGET.new{type='button_invis',pos={1,0},x=-50,y=50+85*0,w=60,image=TEX.ui,quad=QUAD.ui.title.skin,      code=WIDGET.c_goScn'skin'},
    WIDGET.new{type='button_invis',pos={1,0},x=-50,y=50+85*1,w=60,image=TEX.ui,quad=QUAD.ui.title.doodle,    code=WIDGET.c_goScn'skin'},
    WIDGET.new{type='button_invis',pos={1,0},x=-50,y=50+85*2,w=60,image=TEX.ui,quad=QUAD.ui.title.gacha,     code=WIDGET.c_goScn'skin'},
    WIDGET.new{type='button_invis',pos={1,0},x=-50,y=50+85*3,w=60,image=TEX.ui,quad=QUAD.ui.title.settings,  code=WIDGET.c_goScn'skin'},
    WIDGET.new{type='button_invis',pos={1,0},x=-50,y=50+85*4,w=60,image=TEX.ui,quad=QUAD.ui.title.subscribe, code=NULL},
    WIDGET.new{type='button_simp',pos={.5,.5},x=-130,y=180,w=180,h=80,fillColor='dL',fontSize=35,fontType='norm',text=function() return Texts.menu_local  .." "..CHAR.icon.person end,code=WIDGET.c_pressKey'enter'},
    WIDGET.new{type='button_simp',pos={.5,.5},x= 130,y=180,w=180,h=80,fillColor='dL',fontSize=35,fontType='norm',text=function() return Texts.menu_network.." "..CHAR.icon.people end,code=WIDGET.c_goScn'mp_menu'},
    QuitButton,
}
return scene
