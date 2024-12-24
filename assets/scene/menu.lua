---@type Zenitha.Scene
local scene={}

function scene.load()
    CURSOR.set('pointer')
    BG.set('title')
end

function scene.draw()
    GC.setColor(COLOR.D)
    FONT.set(90)
    GC.mStr(Texts.menu_title,500,100)
    FONT.set(30)
    GC.mStr(Texts.menu_info,500,210)
end

scene.widgetList={
    WIDGET.new{type='button_simp',pos={.5,.6},w=260,h=120,fontSize=60,text=LANG'menu_play',code=WIDGET.c_goScn'play'},
    WIDGET.new{type='button_simp',pos={1,1},x=-80,y=-50,w=120,h=60,text=LANG'menu_quit',code=WIDGET.c_backScn()},
}
return scene
