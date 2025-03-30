---@type Zenitha.Scene
local scene = {}

local mode, port
NetRoom = class(require 'assets/memberList')

function scene.load(_)
    mode = SCN.args[1]
    NetRoom:reset()
    if mode == 'host' then
        port = SCN.args[2]
        NetRoom:add('0')
        NetRoom:setSelf()
    end
end

function scene.mouseDown(x, y, k)
end

function scene.keyDown(key, isRep)
    if key == 's' then
        TCP.C_send("123", '0')
    end
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
        GC.print(port, 100, 40)
    end

    for i = 1, #NetRoom do
        local m = NetRoom[i]
        GC.setColor(m == NetRoom.self and COLOR.G or COLOR.D)
        GC.print(m.id, 100, 90 + i * 25)
    end
end

scene.widgetList = {
    QuitButton,
}

return scene
