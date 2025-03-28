---@type Zenitha.Scene
local scene = {}

local mode
local str = ""

local function input(i)
    if mode == 'lan_create' and not tonumber(i) then return end
    str = str .. i
end

local function confirm()
    if mode == 'lan_create' then
        if str == "" then str = "" .. math.random(16384, 65535) end
        local port = tonumber(str)
        if not port then return MSG('info', "必须是数字！") end
        if port % 1 ~= 0 then return MSG('info', "必须是整数！") end
        if not MATH.between(port, 16384, 65535) then return MSG('info', "端口必须在16384到65535之间") end
        TCP.S_start(port)
        SCN.go('room', nil, 'host', port)
    elseif mode == 'lan_join' then
        if not str:match("^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?%:%d%d%d%d%d$") then
            return MSG('info', "格式不正确，一般长这样：\n192.168.0.26:26535")
        end
        local ip, port = str:before(':'), tonumber(str:after(':'))
        ---@cast ip string
        ---@cast port number
        local ipNums = TABLE.applyeach(ip:split('.'), tonumber)
        if TABLE.max(ipNums) > 255 or TABLE.min(ipNums) < 0 then return MSG('info', "IP地址格式不正确") end
        if not MATH.between(port, 16384, 65535) then return MSG('info', "端口必须在16384到65535之间") end
        TASK.lock('lan_connecting')
        TASK.new(function()
            TASK.yieldT(.26)
            TCP.C_connect(ip, port)
            if TCP.C_isRunning() then
                SCN.go('room', nil, 'client')
            else
                MSG('info', "连接失败...")
            end
            TASK.unlock('lan_connecting')
        end)
    end
end

function scene.load()
    mode = SCN.args[1]
    str = ""
end

function scene.mouseDown(x, y, k)
end

function scene.keyDown(key, isRep)
    if #key == 1 and tonumber(key) or key == '.' then
        input(key)
    elseif key == ';' then
        input(':')
    elseif key == 'backspace' then
        str = str:sub(1, -2)
    elseif key == 'return' then
        confirm()
    end
    return true
end

function scene.update(dt)
end

function scene.draw()
    GC.setColor(COLOR.D)
    FONT.set(30)
    GC.mStr(Texts.numpad[mode], 500, 15)
    FONT.set(70)
    GC.mStr(str, 500, 55)
end

function scene.overDraw()
    if TASK.getLock('lan_connecting') then
        GC.replaceTransform(SCR.origin)
        GC.setColor(0, 0, 0, .26)
        GC.rectangle('fill', 0, 0, SCR.w, SCR.h)
        GC.setColor(COLOR.D)
        FONT.set(90)
        GC.replaceTransform(SCR.xOy_m)
        GC.strokePrint('full', 5, COLOR.dL, COLOR.D, "连接中...", 0, -62, nil, 'center')
    end
end

local function btn(t)
    return WIDGET.new(TABLE.update({
        type = 'button_simp',
        fillColor = 'dL',
        pos = { .5, .5 },
        w = 100,
        fontSize = 70,
    }, t))
end

scene.widgetList = {
    btn { x = -1 * 110, y = -1 * 110, text = '1', onClick = function() input '1' end },
    btn { x = 0. * 110, y = -1 * 110, text = '2', onClick = function() input '2' end },
    btn { x = 1. * 110, y = -1 * 110, text = '3', onClick = function() input '3' end },
    btn { x = -1 * 110, y = 0. * 110, text = '4', onClick = function() input '4' end },
    btn { x = 0. * 110, y = 0. * 110, text = '5', onClick = function() input '5' end },
    btn { x = 1. * 110, y = 0. * 110, text = '6', onClick = function() input '6' end },
    btn { x = -1 * 110, y = 1. * 110, text = '7', onClick = function() input '7' end },
    btn { x = 0. * 110, y = 1. * 110, text = '8', onClick = function() input '8' end },
    btn { x = 1. * 110, y = 1. * 110, text = '9', onClick = function() input '9' end },
    btn { x = -1 * 110, y = 2. * 110, text = '0', onClick = function() input '0' end },
    btn { x = 0. * 110, y = 2. * 110, text = '.', onClick = function() input '.' end },
    btn { x = 1. * 110, y = 2. * 110, text = ':', onClick = function() input ':' end },
    btn { x = 2. * 110, y = 0. * 110, fillColor = 'dR', text = '清空', onClick = function() str = "" end },
    btn { x = 2. * 110, y = 1. * 110, fillColor = 'lR', text = '退格', onClick = function() str = str:sub(1, -2) end },
    btn { x = 2. * 110, y = 2. * 110, fillColor = 'lG', text = '确定', onClick = confirm, },
    QuitButton,
}

return scene
