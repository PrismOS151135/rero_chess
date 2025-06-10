---@class Member
---@field id string
---@field skin string

---@class MemberList
---@field self Member
---@field selfID string
---@field [number|string] Member
local MemberList = {}

function MemberList.new()
    return setmetatable({}, { __index = MemberList })
end

function MemberList:reset()
    TABLE.clear(self)
end

function MemberList:export()
    local d = {}
    for i = 1, #self do
        d[i] = {
            id = self[i].id,
            skin = self[i].skin
        }
    end
    return d
end

function MemberList:import(data)
    self:reset()
    for i = 1, #data do
        local p = {
            id = data[i].id,
            skin = data[i].skin,
        }
        self[i] = p
        self[p.id] = p
        self.selfID = p.id
        self.self = p
    end
end

function MemberList:add(data)
    if self[data.id] then return MSG('error', "add: id already exists") end
    local p = {
        id = data.id,
        skin = data.skin,
    }
    self[#self + 1] = p
    self[data.id] = p
    if data.self then
        self.selfID = data.id
        self.self = p
    end
end

function MemberList:remove(id)
    if not self[id] then return MSG('error', "remove: id not found") end
    table.remove(self, TABLE.find(self, self[id]))
    self[id] = nil
end

---@return number 0 = not found
function MemberList:getSelfSeat()
    return TABLE.find(self, self.self) or 0
end

return MemberList
