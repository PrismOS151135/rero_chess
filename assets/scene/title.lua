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
    -- Animation curve test
    -- FONT.set(15,'number') GC.setColor(COLOR.dR) GC.setLineWidth(2)
    -- local y=100
    -- for k,v in next,Jump do if k~='setBPM' and type(v())=='number' then
    --     GC.print(k,5,y-20) GC.line(20,y,80,y)
    --     GC.circle('fill',50,y,3) GC.circle('line',50+30*v(),y,6)
    --     y=y+30
    -- end end

    -- Title texts
    GC.replaceTransform(SCR.xOy)
    GC.setColor(COLOR.D)
    FONT.set(90) GC.mStr(Texts.menu_title,500,100)
    FONT.set(30) GC.mStr(Texts.menu_info,500,210)
    GC.setColor(Jump.bool() and COLOR.D or COLOR.G)
    FONT.set(25) GC.mStr(Texts.menu_desc,500,260)

    -- Fumo
    GC.setColor(1,1,1)
    local q,rot,kx,ky
    if DATA.fumoDmg<20 then
        kx,ky=1+fumoAnimTimer*.8,1-fumoAnimTimer*.6
        q=QUAD.ui.title.fumo.normal
    elseif DATA.fumoDmg<40 then
        kx,ky=1+fumoAnimTimer*.1,1-fumoAnimTimer*.1
        q=QUAD.ui.title.fumo.squashed
    elseif DATA.fumoDmg<60 then
        kx,ky=1-fumoAnimTimer*.1,1-fumoAnimTimer*.1
        q=QUAD.ui.title.fumo.dead
    elseif DATA.fumoDmg<80 then
        rot=fumoAnimTimer*.1
        q=QUAD.ui.title.fumo.rip[1]
    elseif DATA.fumoDmg<110 then
        rot=fumoAnimTimer*.1
        q=QUAD.ui.title.fumo.rip[2]
    elseif DATA.fumoDmg<150 then
        rot=fumoAnimTimer*.1
        q=QUAD.ui.title.fumo.rip[3]
    elseif DATA.fumoDmg<200 then
        rot=fumoAnimTimer*.1
        q=QUAD.ui.title.fumo.rip[4]
    elseif DATA.fumoDmg<202 then
        GC.draw(TEX.ui,QUAD.ui.title.fumo.ghost,60,495+10*Jump.sin(.26))
        q=QUAD.ui.title.fumo.rip[5]
    else
        q=QUAD.ui.title.fumo.rip[6]
    end
    local _,_,w,h=q:getViewport()
    GC.draw(TEX.ui,q,80,600,rot,kx,ky,w/2,h)
end

scene.widgetList={
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*0,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.skin,      code=WIDGET.c_goScn'skin'},
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*1,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.doodle,    code=WIDGET.c_goScn'doodle'},
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*2,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.gacha,     code=WIDGET.c_goScn'gacha'},
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*3,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.settings,  code=WIDGET.c_goScn'settings'},
    WIDGET.new{type='button_simp', pos={1,0},x=-50,y=50+95*4,w=85,frameColor='X',fillColor='L',cornerR=30,image=TEX.ui,quad=QUAD.ui.title.subscribe, code=NULL},
    WIDGET.new{type='button_invis',x=80,y=530,w=100,h=130,
        name='fumo',
        onPress=function()
            if fumoAnimTimer<.626 then
                DATA.fumoDmg=DATA.fumoDmg+1
                fumoAnimTimer=1
                TWEEN.tag_kill('fumo_bounce')
                TWEEN.new(function(t) fumoAnimTimer=1-t end):setTag('fumo_bounce'):setEase('OutElastic'):setDuration(.62):run()
                if DATA.fumoDmg==200 then
                    DATA:getSkin('长相潦草的幽灵')
                elseif DATA.fumoDmg==202 then
                    scene.widgetList.fumo:reset()
                end
            end
        end,
        visibleFunc=function()
            return DATA.fumoDmg<202
        end,
    },
    WIDGET.new{type='button_simp',pos={.5,.5},x=-130,y=180,w=180,h=80,fillColor='dL',fontSize=35,fontType='norm',text=function() return Texts.menu_local  .." "..CHAR.icon.person end,code=WIDGET.c_pressKey'enter'},
    WIDGET.new{type='button_simp',pos={.5,.5},x= 130,y=180,w=180,h=80,fillColor='dL',fontSize=35,fontType='norm',text=function() return Texts.menu_network.." "..CHAR.icon.people end,code=WIDGET.c_goScn'mp_menu'},
    QuitButton,
}
return scene
