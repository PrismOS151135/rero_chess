---@type Zenitha.Scene
local scene = {}

local subButtonClick
local fumoAnimTimer = 0

local subMenu = false
local function selectSubMenu(m)
    subMenu = m
    local L = scene.widgetList
    L.offline:setVisible(not m)
    L.lan:setVisible(not m)
    L.wan:setVisible(not m)
    L.create:setVisible(m)
    L.join:setVisible(m)
    L.back:setVisible(m)
end

function scene.load()
    selectSubMenu(subMenu)
    subButtonClick = 0
    CURSOR.set('pointer')
    BG.set('title')
    SetBgmMode('menu')
end

function scene.unload()
    CURSOR.set('pointer')
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' then
        SCN.go('quit_sure', 'none', 'quit')
    end
    return true
end

function scene.update()
    CURSOR.set(WIDGET.sel == scene.widgetList.fumo and 'hand' or 'pointer')
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
    GC.setColor(COLOR.D)
    FONT.set(90)
    GC.mStr(Texts.menu_title, 500, 100)
    FONT.set(30)
    GC.mStr(Texts.menu_info, 500, 210)

    -- Submenu
    if subMenu then
        FONT.set(50)
        GC.setColor(COLOR.D)
        GC.mStr(Texts.menu_subTitle[subMenu], 500, 335)
    end

    -- Fumo
    GC.replaceTransform(SCR.xOy_dl)
    GC.setColor(1, 1, 1)
    local q, rot, kx, ky
    if DATA.fumoDmg < 20 then
        kx, ky = 1 + fumoAnimTimer * .8, 1 - fumoAnimTimer * .6
        q = QUAD.ui.title.fumo.normal
    elseif DATA.fumoDmg < 40 then
        kx, ky = 1 + fumoAnimTimer * .1, 1 - fumoAnimTimer * .1
        q = QUAD.ui.title.fumo.squashed
    elseif DATA.fumoDmg < 60 then
        kx, ky = 1 - fumoAnimTimer * .1, 1 - fumoAnimTimer * .1
        q = QUAD.ui.title.fumo.dead
    elseif DATA.fumoDmg < 80 then
        rot = fumoAnimTimer * .1
        q = QUAD.ui.title.fumo.rip[1]
    elseif DATA.fumoDmg < 110 then
        rot = fumoAnimTimer * .1
        q = QUAD.ui.title.fumo.rip[2]
    elseif DATA.fumoDmg < 150 then
        rot = fumoAnimTimer * .1
        q = QUAD.ui.title.fumo.rip[3]
    elseif DATA.fumoDmg < 200 then
        rot = fumoAnimTimer * .1
        q = QUAD.ui.title.fumo.rip[4]
    elseif DATA.fumoDmg < 202 then
        GC.draw(TEX.ui, QUAD.ui.title.fumo.ghost, 60, 495 + 10 * Jump.sin(.26))
        q = QUAD.ui.title.fumo.rip[5]
    else
        q = QUAD.ui.title.fumo.rip[6]
    end
    local _, _, w, h = q:getViewport()
    GC.draw(TEX.ui, q, scene.widgetList.fumo.x, scene.widgetList.fumo.y + 65, rot, kx, ky, w / 2, h)
end

function scene.overDraw()
    GC.origin()
    GC.setColor(0, 0, 0, TASK.getLock('title_subscribePress') or 0)
    GC.rectangle('fill', 0, 0, SCR.w, SCR.h)
end

scene.widgetList = {
    WIDGET.new { type = 'button_simp', pos = { 1, 0 }, x = -50, y = 50 + 95 * 0, w = 85, frameColor = 'X', fillColor = 'L', cornerR = 30, image = TEX.ui, quad = QUAD.ui.title.skin, onClick = WIDGET.c_goScn 'skin' },
    WIDGET.new { type = 'button_simp', pos = { 1, 0 }, x = -50, y = 50 + 95 * 1, w = 85, frameColor = 'X', fillColor = 'L', cornerR = 30, image = TEX.ui, quad = QUAD.ui.title.doodle, onClick = WIDGET.c_goScn 'doodle' },
    WIDGET.new { type = 'button_simp', pos = { 1, 0 }, x = -50, y = 50 + 95 * 2, w = 85, frameColor = 'X', fillColor = 'L', cornerR = 30, image = TEX.ui, quad = QUAD.ui.title.gacha, onClick = WIDGET.c_goScn 'gacha' },
    WIDGET.new { type = 'button_simp', pos = { 1, 0 }, x = -50, y = 50 + 95 * 3, w = 85, frameColor = 'X', fillColor = 'L', cornerR = 30, image = TEX.ui, quad = QUAD.ui.title.settings, onClick = WIDGET.c_goScn 'settings' },
    WIDGET.new { type = 'button_simp', pos = { 1, 0 }, x = -50, y = 50 + 95 * 4, w = 85, frameColor = 'X', fillColor = 'L', cornerR = 30, image = TEX.ui, quad = QUAD.ui.title.subscribe,
        onPress = function()
            if TASK.lock('title_subscribePress', .42) then
                love.timer.sleep(0.26)
                subButtonClick = subButtonClick + 1
                if subButtonClick == 3 then
                    SCN.go('crash', 'none')
                end
            end
        end,
    },
    WIDGET.new { type = 'button_invis', pos = { 0, 1 }, x = 60, y = -70, w = 120, h = 130,
        name = 'fumo',
        onPress = function()
            if fumoAnimTimer < .626 then
                DATA.fumoDmg = DATA.fumoDmg + 1
                fumoAnimTimer = 1
                TWEEN.tag_kill('fumo_bounce')
                TWEEN.new(function(t) fumoAnimTimer = 1 - t end):setTag('fumo_bounce'):setEase('OutElastic'):setDuration(.62)
                    :run()
                if DATA.fumoDmg >= 40 then
                    if not DATA.fumoDieTime then
                        DATA.fumoDieTime = os.time()
                    else
                        DATA.fumoDieTime = math.max(DATA.fumoDieTime, os.time() + 60 - 86400)
                    end
                end
                if DATA.fumoDmg == 200 then
                    DATA.getSkin('长相潦草的幽灵')
                elseif DATA.fumoDmg == 202 then
                    scene.widgetList.fumo:reset()
                end
                TASK.lock('data_save', 5)
                DATA.save()
            end
        end,
        visibleFunc = function()
            return DATA.fumoDmg < 202
        end,
    },
    WIDGET.new {
        name = 'offline',
        type = 'button_simp', pos = { .5, .5 },
        x = -260, y = 120, w = 180, h = 80, fillColor = 'dL',
        fontSize = 40, fontType = 'norm', text = LANG 'menu_offline',
        onClick = function() SCN.go('play', nil, 'demo') end,
    },
    WIDGET.new {
        name = 'lan',
        type = 'button_simp', pos = { .5, .5 },
        x = 0, y = 120, w = 180, h = 80, fillColor = 'dL',
        fontSize = 40, fontType = 'norm', text = LANG 'menu_lan',
        onClick = function() selectSubMenu('lan') end,
    },
    WIDGET.new {
        name = 'wan',
        type = 'button_simp', pos = { .5, .5 },
        x = 260, y = 120, w = 180, h = 80, fillColor = 'dL',
        fontSize = 40, fontType = 'norm', text = LANG 'menu_wan',
        onClick = function() selectSubMenu('wan') end,
    },
    WIDGET.new {
        name = 'create',
        type = 'button_simp', pos = { .5, .5 },
        x = -260, y = 160, w = 180, h = 80, fillColor = 'lG',
        fontSize = 40, fontType = 'norm', text = LANG 'menu_create',
        onClick = function()
            if subMenu == 'lan' then
                TCP.S_start(62626)
                TCP.S_setPermission({ broadcast = false })
                TCP.C_connect('localhost', 62626)
                SCN.go('room', nil, 'host')
            elseif subMenu == 'wan' then
                MSG('info', "暂不可用")
                -- SCN.go('numpad', nil, 'wan_join')
            end
        end,
    },
    WIDGET.new {
        name = 'join',
        type = 'button_simp', pos = { .5, .5 },
        x = 0, y = 160, w = 180, h = 80, fillColor = 'lS',
        fontSize = 40, fontType = 'norm', text = LANG 'menu_join',
        onClick = function()
            if subMenu == 'lan' then
                SCN.go('numpad', nil, 'lan_join')
            elseif subMenu == 'wan' then
                MSG('info', "暂不可用")
                -- SCN.go('numpad',nil,'wan_join')
            end
        end,
    },
    WIDGET.new {
        name = 'back',
        type = 'button_simp', pos = { .5, .5 },
        x = 260, y = 160, w = 180, h = 80, fillColor = 'DL',
        fontSize = 40, fontType = 'norm', text = LANG 'menu_back',
        onClick = function() selectSubMenu(false) end,
    },
    QuitButton,
}

return scene
