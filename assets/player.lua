---@class ReroChess.Player
---@field index number
---@field name string
---@field location number
local Player={}
Player.__index=Player

---@class ReroChess.PlayerData
---@field name string
---@field location? number

---@param data ReroChess.PlayerData
function Player.new(index,data)
    local player=setmetatable({
        index=index,
        name=data.name,
        location=data.location or 1,
    },Player)
    return player
end

return Player
