---@type Zenitha.Scene
local scene = {}

local mode, address
NetRoom = require 'assets.roomList'.new()

local cache = {}

function scene.load(_)
    mode = SCN.args[1]
    NetRoom:reset()
    if mode == 'host' then
        local dns = require 'socket'.dns
        address = dns.toip(dns.gethostname())
    end
    -- NetRoom:add({ id = '1', self = true, skin = DATA.skinEquip })
    -- TCP.C_send({ event = 'skin', skin = DATA.skinEquip })
    scene.widgetList.start:setVisible(mode == 'host')
    for i = 1, 6 do cache[i] = TABLE.getRandom(QUAD.world.tile) end
end

function scene.mouseDown(x, y, k)
end

function scene.keyDown(key, isRep)
    if key == 'return' then
        if mode == 'host' then
            if #NetRoom > 1 then
                TCP.S_send({ event = "start" })
                SCN.swapTo('play', nil, 'netgame', mode == 'host')
            else
                MSG('other', Texts.room_notEnoughPlayers, 1)
            end
        end
    elseif key == 'escape' then
        if mode == 'host' then
            TCP.S_stop()
        end
        TCP.C_disconnect()
        SCN.back()
    end
    return true
end

local updateDelta = 0
function scene.update(dt)
    updateDelta = updateDelta - dt
    if updateDelta < 0 then
        updateDelta = .0626
        local d
        while true do
            d = TCP.S_receive()
            if not d then break end
            -- print("S_recv", TABLE.dump(d))

            local pack = d.data
            if d.event == 'client.connect' then
                NetRoom:add({ id = d.sender })
                -- TCP.S_send({ event = 'init', data = NetRoom:export() })
                TCP.S_send({ event = 'init', data = NetRoom:export() }, d.sender)
                TCP.S_send({ event = 'join', id = d.sender })
            elseif d.event == 'client.disconnect' then
                TCP.S_send({ event = 'quit', id = d.sender })
            elseif pack.event == 'skin' then
                TCP.S_send({ event = 'skin', id = d.sender, skin = pack.skin })
            end
        end

        while true do
            d = TCP.C_receive()
            if not d then break end
            if d.sender then break end -- only accept broadcast messages
            -- print("C_recv", TABLE.dump(d))

            local pack = d.data
            if pack.event == 'init' then
                NetRoom:import(pack.data)
            elseif pack.event == 'join' then
                if NetRoom.selfID == pack.id then
                    TCP.C_send({ event = 'skin', skin = DATA.skinEquip })
                elseif mode ~= 'host' then
                    NetRoom:add({ id = pack.id })
                end
            elseif pack.event == 'quit' then
                NetRoom:remove(pack.id)
            elseif pack.event == 'start' then
                SCN.swapTo('play', nil, 'netgame', mode == 'host')
            elseif pack.event == 'skin' then
                NetRoom[pack.id].skin = pack.skin
            end
        end
    end
end

local pos = {
    { 250, 200 }, { 500, 200 }, { 750, 200 },
    { 250, 400 }, { 500, 400 }, { 750, 400 },
}

function scene.draw()
    FONT.set(30)

    GC.setColor(COLOR.D)
    if mode == 'host' then
        GC.print(Texts.room_host, 100, 10)
        GC.print(address, 100, 40)
    end

    for i = 1, 6 do
        GC.push('transform')
        GC.translate(pos[i][1], pos[i][2])
        GC.scale(.5)
        GC.setColor(1, 1, 1)
        GC.mDrawQ(TEX.world.default, cache[i])
        local m = NetRoom[i]
        if m then
            -- m == NetRoom.self
            GC.setColor(COLOR.D)
            GC.ucs_move('s', 2, 2)
            GC.mStr("玩家" .. m.id, 0, -120)
            if m.skin then
                GC.setColor(1, 1, 1)
                GC.mDraw(TEX.chess[m.skin].base, 0, -26, 0, .42)
                GC.mDraw(TEX.chess[m.skin].normal, 0, -26, 0, .42)
            end
            GC.ucs_back()
        end
        GC.pop()
    end
end

scene.widgetList = {
    WIDGET.new {
        name = 'start',
        type = 'button_simp',
        pos = { .5, 1 },
        y = -70, w = 160, h = 80,
        fontSize = 40,
        text = LANG 'room_start',
        onClick = WIDGET.c_pressKey 'return',
    },
    QuitButton,
}

return scene
