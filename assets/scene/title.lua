---@type Zenitha.Scene
local scene={}

local fumoAnimTimer=0

function scene.load()
    CURSOR.set('pointer')
    BG.set('title')
end
function scene.unload()
    CURSOR.set('pointer')
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

function scene.update()
    CURSOR.set(WIDGET.sel==scene.widgetList.fumo and 'hand' or 'pointer')
end

function scene.draw()
    GC.replaceTransform(SCR.xOy)
    GC.setColor(COLOR.D)
    FONT.set(90) GC.mStr(Texts.menu_title,500,100)
    FONT.set(30) GC.mStr(Texts.menu_info,500,210)
    GC.setColor(love.timer.getTime()%.6<.26 and COLOR.D or COLOR.G)
    FONT.set(25) GC.mStr(Texts.menu_desc,500,260)

    GC.setColor(1,1,1)
    local q=QUAD.ui.title.lue.fumo
    local _,_,w,h=q:getViewport()
    local fumo=scene.widgetList.fumo
    local droppedTimer=MATH.roundUnit(fumoAnimTimer,0.35)
    GC.draw(TEX.ui,q,fumo._x,fumo._y+fumo.h/2,nil,1+droppedTimer*.8,1-droppedTimer*.6,w/2,h)
end

scene.widgetList={
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*0,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.skin,      code=WIDGET.c_goScn'skin'},
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*1,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.doodle,    code=WIDGET.c_goScn'doodle'},
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*2,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.gacha,     code=WIDGET.c_goScn'gacha'},
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*3,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.settings,  code=WIDGET.c_goScn'settings'},
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*4,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.subscribe, code=NULL},
    WIDGET.new{type='button_invis',pos={0,1},x= 80,y=-90,w=100,h=130,
        name='fumo',
        code=function()
            if fumoAnimTimer<.626 then
                fumoAnimTimer=1
                TWEEN.tag_kill('fumo_bounce')
                TWEEN.new(function(t)
                    fumoAnimTimer=1-t
                end):setTag('fumo_bounce'):setEase('OutElastic'):setDuration(.62):run()
            end
        end,
    },
    WIDGET.new{type='button_simp',pos={.5,.5},x=-130,y=180,w=180,h=80,fillColor='dL',fontSize=35,fontType='norm',text=function() return Texts.menu_local  .." "..CHAR.icon.person end,code=WIDGET.c_pressKey'enter'},
    WIDGET.new{type='button_simp',pos={.5,.5},x= 130,y=180,w=180,h=80,fillColor='dL',fontSize=35,fontType='norm',text=function() return Texts.menu_network.." "..CHAR.icon.people end,code=WIDGET.c_goScn'mp_menu'},
    QuitButton,
}
return scene
