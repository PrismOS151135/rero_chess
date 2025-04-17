---@type Zenitha.Scene
local scene = {}

local mode, address
NetRoom = require 'assets/memberList'.new()

function scene.load(_)
    mode = SCN.args[1]
    NetRoom:reset()
    if mode == 'host' then
        local dns = require 'socket'.dns
        address = dns.toip(dns.gethostname())
        NetRoom:add('0')
        NetRoom:setSelf()
    end
    scene.widgetList.start:setVisible(mode == 'host')
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
                if d.event == 'client.connect' then
                    NetRoom:add(d.sender)
                    TCP.S_send({ e = "join", id = d.sender })
                    TCP.S_send({ e = "init", d = NetRoom:export() }, d.sender)
                elseif d.event == 'client.disconnect' then
                    TCP.S_send({ e = "quit", id = d.sender })
                end
            end
        elseif mode == 'client' then
            local d = TCP.C_receive()
            if d then
                print("C_recv", TABLE.dump(d))
                local pack = d.data
                if pack.e == 'join' then
                    NetRoom:add(pack.id)
                elseif pack.e == 'quit' then
                    for i = 1, #NetRoom do
                        if NetRoom[i].id == pack.id then
                            table.remove(NetRoom, i)
                            break
                        end
                    end
                elseif pack.e == 'init' then
                    NetRoom:import(pack.d)
                    NetRoom:setSelf()
                elseif pack.e == 'start' then
                    SCN.swapTo('play', nil, 'netgame', mode == 'host')
                end
            end
        end
    end
end

function scene.draw()
    FONT.set(30)

    GC.setColor(COLOR.D)
    GC.print(mode, 100, 10)
    if mode == 'host' then
        GC.print(address, 100, 40)
    end

    GC.setColor(COLOR.D)
    for i = 1, #NetRoom do
        local m = NetRoom[i]
        GC.print("玩家" .. m.id, 126, 90 + i * 25)
        if m == NetRoom.self then
            GC.print("我→", 62, 90 + i * 25)
        end
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
