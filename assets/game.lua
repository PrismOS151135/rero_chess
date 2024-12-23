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
    local initX,initY
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
                if d.mapCenter then
                    assert(not initX,"Multiple mapCenter")
                    initX,initY=-x,-y
                end
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
    if initX then
        game.cam:move(initX,initY)
        game.cam:update(1)
    end
    game.cam:scale(100)
    return game
end

function Game:roll()
    local p=self.players[1]
    p.dice:roll()
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
local gc_setAlpha=GC.setAlpha

function Game:draw()
    self.cam:apply()

    -- Map
    local map=self.map
    for i=1,#map do
        gc_setColor(COLOR.L)
        local cell=map[i]
        gc_rectangle('fill',cell.x-.45,cell.y-.45,.9,.9)
        if cell.next then
            gc_setLineWidth(0.2)
            gc_line(cell.x,cell.y,cell.next.x,cell.next.y)
        end
        gc_setColor(COLOR.D)
        gc_setLineWidth(0.026)
        gc_rectangle('line',cell.x-.45,cell.y-.45,.9,.9)
    end

    -- Players
    gc_setLineWidth(0.0626)
    for i=1,#self.players do
        local p=self.players[i]
        local cell=map[p.location]
        gc_setColor(p.color)
        gc_setAlpha(.5)
        gc_circle('line',cell.x+p.biasX,cell.y+p.biasY,.26)

        if p.dice.enable then
            gc_push('transform')
            gc_translate(cell.x,cell.y)
            p.dice:draw()
            gc_pop()
        end
    end
end

return Game
