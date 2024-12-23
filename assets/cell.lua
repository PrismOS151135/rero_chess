---@alias ReroChess.CellType nil|''|''|''|string

---@class ReroChess.Cell
---@field type ReroChess.CellType
---@field x number
---@field y number
---@field prev? ReroChess.Cell
---@field next? ReroChess.Cell
local Cell={}
Cell.__index=Cell

---@class ReroChess.CellData
---@field type ReroChess.CellType
---@field x? number
---@field y? number
---@field dx? number
---@field dy? number

---@param data ReroChess.CellData
function Cell.new(data,x,y)
    local cell=setmetatable({
        type=data.type,
        x=x,y=y,
    },Cell)
    return cell
end

return Cell
