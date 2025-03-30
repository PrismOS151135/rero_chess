---@class Member
---@field id string

---@class MemberList
---@field self Member
---@field selfID string
---@field [number|string] Member
local MemberList = {}

function MemberList:reset()
    TABLE.clear(self)
end

function MemberList:export()
    local d = {}
    for i = 1, #self do
        d[i] = self[i].id
    end
    return d
end

function MemberList:import(data)
    self:reset()
    for i = 1, #data do
        local id = data[i]
        local p = { id = id }
        self[i] = p
        self[p.id] = p
    end
end

function MemberList:add(id)
    if self[id] then return MSG('error', "add: id already exists") end
    local p = { id = id }
    self[#self + 1] = p
    self[id] = p
end

function MemberList:setSelf(id)
    if id == nil then id = self[#self].id end
    if not self[id] then return MSG('error', "setSelf: id not found") end
    self.selfID = id
    self.self = self[id]
end

function MemberList:remove(id)
    if not self[id] then return MSG('error', "remove: id not found") end
    TABLE.deleteAll(self, self[id])
end

return MemberList
