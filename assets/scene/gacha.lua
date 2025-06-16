---@type Zenitha.Scene
local scene = {}

local tileTextureID = {}
for i = 1, 8 do tileTextureID[i] = math.random(0, 4) end
---@type love.Mesh[]
local tileMesh = {}
for i = 1, 8 do
    tileMesh[i] = GC.newMesh(4, 'fan', 'dynamic')
end

local bias = 0
local function refreshTileMesh()
    local W, H = TEX.world.default:getDimensions()
    for i = 1, 8 do
        local x = i - 5 + bias
        tileMesh[i]:setVertices {
            { (-1 + x * 2) / 1.6, -1, 0 / W,   (256 * tileTextureID[i]) / H },
            { (1 + x * 2) / 1.6,  -1, 256 / W, (256 * tileTextureID[i]) / H },
            { (1 + x * 2),        1,  256 / W, 256 * (tileTextureID[i] + 1) / H },
            { (-1 + x * 2),       1,  0 / W,   256 * (tileTextureID[i] + 1) / H },
        }
    end
end

local function walk(n)
    table.remove(tileTextureID, 1)
    table.insert(tileTextureID, math.random(0, 4))
    TWEEN.new(function(t)
        bias = 1 - t
        refreshTileMesh()
    end):setLoop('repeat', n):setEase('Linear'):setDuration(60 / 129):setOnRepeat(function()
        table.remove(tileTextureID, 1)
        table.insert(tileTextureID, math.random(0, 4))
    end):setOnFinish(function()
        MSG('info', "恭喜抽到了…空气！")
        TASK.unlock('gacha_dice')
    end):run()
end

function scene.load()
    for _, m in next, tileMesh do
        m:setTexture(TEX.world.default)
    end
    refreshTileMesh()
end

function scene.keyDown(key, isRep)
    if key == 'space' then
        if TASK.lock('gacha_dice', 2.6) then
            if DATA.dust < 10 then
                MSG('info', Texts.gacha_notEnoughDust, 1)
                return
            end
            DATA.dust = DATA.dust - 10
            DATA.save()
            walk(math.random(6))
        end
    elseif key == 'escape' then
        SCN.back()
    end
    return true
end

function scene.mouseMove(_, _, dx)
end

function scene.update(dt)
end

function scene.draw()
    GC.replaceTransform(SCR.xOy_ur)
    GC.setColor(COLOR.L)
    GC.mRect('fill', -90, 40, 160, 60, 10)
    GC.setColor(COLOR.D)
    if DATA.dust < 100 then
        FONT.set(50)
        GC.mStr(DATA.dust, -120, 15)
    else
        FONT.set(30)
        GC.mStr(DATA.dust, -120, 25)
    end
    GC.setColor(1, 1, 1)
    if DATA.dust < 0 then
        -- Do nothing
    elseif DATA.dust < 50 then
        GC.mDrawQ(TEX.ui,
            QUAD.ui.gacha.dust[
            DATA.dust <= 1 and 1 or
            DATA.dust == 2 and 2 or
            DATA.dust < 10 and 3 or
            4], -50, 40, 0, .626
        )
    elseif DATA.dust < 500 then
        GC.mDrawQ(TEX.ui, QUAD.ui.gacha.dust[DATA.dust < 100 and 5 or 6], -50, 25, 0, .626)
    else
        GC.mDrawQ(TEX.ui, QUAD.ui.gacha.dust[7], -50, 50, 0, .6)
    end

    GC.replaceTransform(SCR.xOy_d)
    FONT.set(50)
    GC.strokePrint('full', 2, COLOR.dL, COLOR.D, Texts.gacha_help, 0, -60 - 10 * Jump.smooth(), nil, 'center')
    GC.setColor(1, 1, 1)

    GC.translate(0, -120)
    for i = 1, 8 do
        GC.draw(tileMesh[i], 0, 0, 0, 160, 35)
    end

    GC.translate(0, 100 * (-1 + 4 * (bias - .5) ^ 2))
    local skin = TEX.chess[DATA.skinEquip]
    GC.draw(skin.base, 0, 0, 0, .626, .626, 128, 256)
    GC.draw(skin.normal, 0, 0, 0, .626, .626, 128, 256)
end

scene.widgetList = {
    WIDGET.new {
        type = 'button_simp', pos = { 1, 1 },
        x = -100, y = -240, w = 100,
        fillColor = 'L',
        fontSize = 40, fontType = 'norm', text = LANG 'gacha_dice',
        onClick = WIDGET.c_pressKey 'space',
    },
    QuitButton,
}

return scene
