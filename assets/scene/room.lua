---@type Zenitha.Scene
local scene = {}

local mode, port
local members = class(require 'assets/memberList')

function scene.load(_)
    mode = SCN.args[1]
    members:reset()
    if mode == 'host' then
        port = SCN.args[2]
        members:add('0')
        members:setSelf()
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
                    members:add(d.sender)
                    TCP.S_send({ e = "join", id = d.sender })
                    TCP.S_send({ e = "init", d = members:export() }, d.sender)
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
                    members:add(pack.id)
                elseif pack.e == 'quit' then
                    for i = 1, #members do
                        if members[i].id == pack.id then
                            table.remove(members, i)
                            break
                        end
                    end
                elseif pack.e == 'init' then
                    members:import(pack.d)
                    members:setSelf()
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

    for i = 1, #members do
        local m = members[i]
        GC.setColor(m == members.self and COLOR.G or COLOR.D)
        GC.print(m.id, 100, 90 + i * 25)
    end
end

scene.widgetList = {
    QuitButton,
}

return scene
