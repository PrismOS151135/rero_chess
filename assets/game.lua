local Player=require("assets/player")
local Cell=require("assets/cell")

---@class ReroChess.Game
---@field players ReroChess.Player[]
---@field map ReroChess.Cell[]
---@field cam Zenitha.Camera
---@field text Zenitha.Text
---
---@field roundIndex integer
local Game={}
Game.__index=Game

---@class ReroChess.MapData
---@field playerData ReroChess.PlayerData[]
---@field mapData ReroChess.CellData[]

---@class ReroChess.CellData
---@field dx? number
---@field dy? number
---@field x? number
---@field y? number
---
---@field next? string | string[]
---
---@field label? string
---@field prop? ReroChess.CellProp
---@field propData? any
---
---@field mapCenter? boolean

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
            ---@type ReroChess.Cell[]
            local l={}

            -- Initialize
            local x,y=0,0
            for i=1,#data.mapData do
                local d=data.mapData[i]
                if d.x then x=d.x elseif d.dx then x=x+d.dx end
                if d.y then y=d.y elseif d.dy then y=y+d.dy end
                if d.mapCenter then
                    assert(not initX,"Multiple mapCenter")
                    initX,initY=-x,-y
                end
                l[i]=Cell.new(d,x,y,i)
                if d.label then l[d.label]=l[i] end
            end

            -- Manual next
            for id,d in next,data.mapData do
                if type(d.next)=='string' then
                    table.insert(l[id].next,l[d.next].id)
                elseif type(d.next)=='table' then
                    for _,lbl in next,d.next do
                        table.insert(l[id].next,l[lbl].id)
                    end
                end
            end

            -- Auto next
            for id=1,#l-1 do
                if #l[id].next==0 and MATH.mDist2(0,l[id].x,l[id].y,l[id+1].x,l[id+1].y)<=1 then
                    table.insert(l[id].next,l[id+1].id)
                end
            end

            -- Auto prev
            for _,c in next,l do
                for _,n in next,c.next do
                    table.insert(l[n].prev,c.id)
                end
            end

            return l
        end)(),
        cam=GC.newCamera(),
        text=TEXT.new(),
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
    if p.dice.animState=='hide' and not p.moving then
        TASK.new(function()
            p:roll()
            repeat coroutine.yield() until p.dice.animState=='bounce'
            p:move(p.dice.value)
            repeat coroutine.yield() until not p.moving
            self.roundIndex=self.roundIndex%#self.players+1
            TEXT:add{
                text="Player "..self.roundIndex.." turn",
                r=1,g=1,b=1,a=.4,
                duration=1.4,
                x=500-4,y=300-4,k=1.5,
                fontSize=40,
                style='zoomout',
            }
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

function Game:step()
    local p=self.players[self.roundIndex]
    if p.moving then
        p.moveSignal=true
    end
end

---@param id integer Cell id
---@param dir 'next' | 'prev' | false
---@return integer, 'next' | 'prev' | false
function Game:getNext(id,dir)
    -- No direction
    if not dir then return id,dir end

    -- Reverse direction if no next cell
    local cell=self.map[id]
    if #cell[dir]==0 then dir=dir=='next' and 'prev' or 'next' end

    -- No next cell
    if not cell[dir] then return id,false end

    -- Get next cell id
    local list=cell[dir]
    if #list==0 then return id,dir end
    return list[1],dir
end

function Game:update(dt)
    self.text:update(dt)
    self.cam:update(dt)
end

local gc=love.graphics
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_draw,gc_line=gc.draw,gc.line
local gc_rectangle=gc.rectangle
local gc_mDraw=GC.mDraw
local tileText=GC.newText(assert(FONT.get(40)))

function Game:draw()
    self.cam:apply()

    -- Map
    local map=self.map
    for i=1,#map do
        local cell=map[i]
        if cell.prop~='invis' then
            gc_setColor(COLOR.L)
            gc_rectangle('fill',cell.x-.45,cell.y-.45,.9,.9)
            if #cell.next>0 then
                gc_setLineWidth(0.2)
                for n=1,#cell.next do
                    local next=map[cell.next[n]]
                    gc_line(cell.x,cell.y,next.x,next.y)
                end
            end
            gc_setColor(COLOR.D)
            gc_setLineWidth(0.026)
            gc_rectangle('line',cell.x-.45,cell.y-.45,.9,.9)
            if cell.prop=='move' then
                tileText:set(cell.propData>0 and '+'..cell.propData or cell.propData)
                gc_mDraw(tileText,cell.x,cell.y,nil,.01)
            elseif cell.prop=='teleport' then
                tileText:set('??')
                gc_mDraw(tileText,cell.x,cell.y,nil,.01)
            elseif cell.prop=='text' then
                tileText:set(cell.propData)
                gc_mDraw(tileText,cell.x,cell.y,nil,.01)
            end
        end
    end

    -- Players
    for i=1,#self.players do
        self.players[i]:draw()
    end

    self.text:draw()
end

return Game
