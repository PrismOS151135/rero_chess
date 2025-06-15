---@type Zenitha.Scene
local scene = {}

function scene.unload()
    DATA.save()
end

local gc = love.graphics
local gc_setColor, gc_setLineWidth, gc_setLineJoin = gc.setColor, gc.setLineWidth, gc.setLineJoin
local gc_print, gc_printf = gc.print, gc.printf

function scene.draw()
    gc_setColor(COLOR.D)
    FONT.set(30)
    gc_print(Texts.setting_help, 110 + 10 * Jump.smooth(), 26)
end

scene.widgetList = {
    WIDGET.new {
        type = 'slider_fill',
        name = 'bgm_vol',
        x = 180, y = 100, w = 420,
        text = LANG 'setting_bgm',
        axis = { 0, 100 },
        disp = function() return DATA.bgm_vol end,
        code = function(v)
            DATA.bgm_vol = v
            BGM.setVol(v / 100)
        end,
    },
    WIDGET.new {
        type = 'slider_fill',
        name = 'sfx_vol',
        x = 180, y = 160, w = 420,
        text = LANG 'setting_sfx',
        axis = { 0, 100 },
        disp = function() return DATA.sfx_vol end,
        code = function(v)
            DATA.sfx_vol = v
            SFX.setVol(v / 100)
        end,
    },
    QuitButton,
}

return scene
