---@type Zenitha.Scene
local scene={}

function scene.load()
    CURSOR.set('pointer')
    BG.set('title')
end

function scene.draw()
    FONT.set(90)
    GC.setColor(COLOR.D)
    GC.mStr(Texts.menu_title,500,100)
end

scene.widgetList={
    WIDGET.new{type='button_simp',pos={.5,.6},w=260,h=120,fontSize=70,text=LANG'menu_play',code=WIDGET.c_goScn'play'},
    WIDGET.new{type='button_simp',pos={1,1},x=-80,y=-50,w=120,h=60,text=LANG'menu_quit',code=WIDGET.c_backScn()},
}
return scene
