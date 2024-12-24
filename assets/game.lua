local Player=require("assets/player")
local Cell=require("assets/cell")

---@class ReroChess.Game
---@field players ReroChess.Player[]
---@field map ReroChess.Cell[]
---@field cam Zenitha.Camera
---
---@field roundIndex integer
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
        roundIndex=1,
    },Game)
    for _,p in next,game.players do p.game=game end
    if initX then
        game.cam:move(initX,initY)
        game.cam:update(1)
    end
    game.cam:scale(100)
    return game
end

function Game:roll()
    local p=self.players[self.roundIndex]
    if not p.dice.animState then
        TASK.new(function()
            p:roll()
            repeat coroutine.yield() until p.dice.animState=='bounce'
            TASK.yieldT(0.26)
            p:move(p.dice.value)
            repeat coroutine.yield() until not p.moving
            self.roundIndex=self.roundIndex%#self.players+1
            TEXT:add{
                text="Player "..self.roundIndex.." turn",
                color=self.players[self.roundIndex].color,
                duration=1.6,
                x=500,y=300,k=1.5,
                fontSize=40,
                style='zoomout',
            }
        end)
    end
end

function Game:update(dt)
    self.cam:update(dt)
end

local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line=gc.draw,gc.line
local gc_rectangle=gc.rectangle

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
    for i=1,#self.players do
        self.players[i]:draw()
    end
end

return Game
