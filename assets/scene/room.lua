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
        NetRoom:add({ id = '0', self = true, skin = DATA.skinEquip })
    elseif mode == 'client' then
        TCP.C_send({ e = 'skin', skin = DATA.skinEquip })
    end
    scene.widgetList.start:setVisible(mode == 'host')
    for i = 1, 6 do cache[i] = TABLE.getRandom(QUAD.world.tile) end
end

function scene.mouseDown(x, y, k)
end

function scene.keyDown(key, isRep)
    if mode == 'host' then
        if key == 'return' then
            if #NetRoom > 1 then
                TCP.S_send({ e = "start" })
                SCN.swapTo('play', nil, 'netgame', mode == 'host')
            else
                MSG('other', Texts.room_notEnoughPlayers, 1)
            end
        elseif key == 'escape' then
            TCP.S_stop()
            SCN.back()
        end
    elseif mode == 'client' then
        if key == 'escape' then
            TCP.C_disconnect()
            SCN.back()
        end
    end
    return true
end

function scene.update(dt)
    if TASK.lock('test', .26) then
        if mode == 'host' then
            local d = TCP.S_receive()
            if d then
                print("S_recv", TABLE.dump(d))
                local pack = d.data
                if d.event == 'client.connect' then
                    NetRoom:add({ id = d.sender })
                    TCP.S_send({ e = "join", id = d.sender })
                    TCP.S_send({ e = "init", d = NetRoom:export() }, d.sender)
                elseif d.event == 'client.disconnect' then
                    NetRoom:remove(d.sender)
                    TCP.S_send({ e = "quit", id = d.sender })
                elseif pack.e == 'skin' then
                    NetRoom[d.sender].skin = pack.skin
                    TCP.S_send({ e = "skin", id = d.sender, skin = pack.skin })
                end
            end
        elseif mode == 'client' then
            local d = TCP.C_receive()
            if d then
                print("C_recv", TABLE.dump(d))
                local pack = d.data
                if pack.e == 'join' then
                    NetRoom:add({ id = pack.id })
                elseif pack.e == 'quit' then
                    NetRoom:remove(pack.id)
                elseif pack.e == 'init' then
                    NetRoom:import(pack.d)
                elseif pack.e == 'start' then
                    SCN.swapTo('play', nil, 'netgame', mode == 'host')
                elseif pack.e == 'skin' then
                    NetRoom[pack.id].skin = pack.skin
                end
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
    GC.print(mode, 100, 10)
    if mode == 'host' then
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
