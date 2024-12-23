---@class ReroChess.Player
---@field index number
---@field name string
---@field location number
---@field color Zenitha.Color
---@field biasX number
---@field biasY number
local Player={}
Player.__index=Player

---@class ReroChess.PlayerData
---@field name string
---@field location? number
---@field color? Zenitha.Color

local defaultColor={
    COLOR.R,
    COLOR.Y,
    COLOR.C,
    COLOR.P,
    COLOR.O,
    COLOR.G,
    COLOR.B,
}

---@param data ReroChess.PlayerData
function Player.new(index,data)
    local player=setmetatable({
        index=index,
        name=data.name,
        location=data.location or 1,
        color=data.color or defaultColor[index],
    },Player)
    player.biasX=(index-1)%2==0 and -.1 or .1
    player.biasY=(index-1)%4<=1 and -.1 or .1
    return player
end

return Player
