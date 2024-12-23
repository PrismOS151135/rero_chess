local Player=require("assets/player")
local Cell=require("assets/cell")

---@class ReroChess.Game
---@field players ReroChess.Player[]
---@field map ReroChess.Cell[]
---@field cam Zenitha.Camera
local Game={}
Game.__index=Game

---@class ReroChess.MapData
---@field playerData ReroChess.PlayerData[]
---@field mapData ReroChess.CellData[]

---@param data ReroChess.MapData
function Game.new(data)
    local game=setmetatable({
        players=(function()
            local l={}
            for i=1,#data.playerData do
                l[i]=Player.new(i,data.playerData[i])
            end
            return l
        end)(),
        map=(function()
            local l={}
            local x,y=0,0
            for i=1,#data.mapData do
                local d=data.mapData[i]
                if d.x then x=d.x elseif d.dx then x=x+d.dx end
                if d.y then y=d.y elseif d.dy then y=y+d.dy end
                l[i]=Cell.new(d,x,y)
            end
            for i=1,#data.mapData-1 do
                l[i].next=l[i+1]
                l[i+1].prev=l[i]
            end
            return l
        end)(),
        cam=GC.newCamera(),
    },Game)
    game.cam:scale(100)
    return game
end

function Game:update(dt)
    self.cam:update(dt)
end

local gc=love.graphics
local gc_push,gc_pop,gc_clear=gc.push,gc.pop,gc.clear
local gc_origin,gc_replaceTransform=gc.origin,gc.replaceTransform
local gc_translate,gc_scale,gc_rotate,gc_shear=gc.translate,gc.scale,gc.rotate,gc.shear
local gc_setCanvas,gc_setShader,gc_setBlendMode=gc.setCanvas,gc.setShader,gc.setBlendMode
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line=gc.draw,gc.line
local gc_rectangle,gc_circle,gc_polygon=gc.rectangle,gc.circle,gc.polygon
local gc_arc,gc_ellipse=gc.arc,gc.ellipse
local gc_print,gc_printf=gc.print,gc.printf
local gc_stencil,gc_setStencilTest=gc.stencil,gc.setStencilTest
local gc_mRect=GC.mRect

function Game:draw()
    self.cam:apply()
    local map=self.map
    gc_setColor(COLOR.L)
    gc_setLineWidth(0.2)
    for i=1,#map do
        local cell=map[i]
        gc_mRect('fill',cell.x,cell.y,.9,.9)
        if cell.next then
            gc_line(cell.x,cell.y,cell.next.x,cell.next.y)
        end
    end
end

return Game
