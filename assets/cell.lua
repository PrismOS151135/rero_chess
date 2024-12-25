---@alias ReroChess.CellProp 'invis' | 'move' | 'teleport' | '' | string

---@class ReroChess.Cell
---@field id integer
---@field x number
---@field y number
---@field next? number[]
---@field prev? number[]
---@field prop? ReroChess.CellProp
---@field propData? any
local Cell={}
Cell.__index=Cell

---@param data ReroChess.CellData
function Cell.new(data,x,y,id)
    local cell=setmetatable({
        id=id,
        x=x,y=y,

        next={},
        prev={},
        prop=data.prop,
        propData=data.propData,
    },Cell)
    return cell
end

return Cell
