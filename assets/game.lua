local CellEvent=require'assets.cell_event'
local Player=require'assets.player'

---@class ReroChess.Game
---@field players ReroChess.Player[]
---@field map ReroChess.Cell[]
---@field cam Zenitha.Camera
---@field text Zenitha.Text
---
---@field roundIndex integer
local Game={}
Game.__index=Game

---@class ReroChess.CellProp (string|any)[]
---@field [0]? true Instant trigger
---@field [1] string
---@field [...] any

---@class ReroChess.Cell
---@field id integer
---@field x number
---@field y number
---@field next? number[]
---@field prev? number[]
---@field propList? ReroChess.CellProp[]
---
---@field sprite? string
---@field text? string



---@param data string | table
---@return ReroChess.CellProp
local function parseProp(data)
    if data==nil then return {} end

    -- Parse data
    if type(data)=='string' then
        ---@type any
        data=STRING.split(data,' ')
        for i=1,#data do
            data[i]=STRING.split(data[i],',')
        end
    elseif type(data)=='table' then
        if type(data[1])=='string' then
            data={data}
        else
            assertf(
                type(data[1])=='table',
                'Invalid prop data format: %s',
                type(data[1])
            )
        end
    else
        errorf('Invalid prop type: %s',type(data))
    end

    -- Check data format
    for _,prop in next,data do
        if prop[1]:sub(1,1)=='!' then
            prop[0]=true
            prop[1]=prop[1]:sub(2)
        end
        assertf(CellEvent[prop[1]],'Invalid prop command: %s',tostring(prop[1]))
        if prop[1]=='step' then
            prop[2]=tonumber(prop[2])
            assert(
                type(prop[2])=='number' and prop[2]%1==0 and prop[2]>0,
                'prop(step).dist must be positive integer'
            )
        elseif prop[1]=='move' then
            prop[2]=tonumber(prop[2])
            assert(
                type(prop[2])=='number' and prop[2]%1==0,
                'prop(move).dist must be integer'
            )
        elseif prop[1]=='teleport' then
            prop[2]=tonumber(prop[2]) or prop[2]
            assert(
                type(prop[2])=='string' or
                type(prop[2])=='number' and prop[2]%1==0,
                'prop(teleport).target must be integer or string'
            )
        end
    end
    return data
end

---@class ReroChess.CellData: ReroChess.Cell
---@field id? integer
---@field x? number
---@field y? number
---@field dx? number
---@field dy? number
---@field next? string | string[]
---@field label? string
---@field prop? string
---@field mapCenter? any

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
            ---@type ReroChess.Cell[]
            local cells={}

            -- Initialize
            local x,y=0,0
            for i=1,#data.mapData do
                local d=data.mapData[i]
                x=d.x or d.dx and x+d.dx or x
                y=d.y or d.dy and y+d.dy or y
                if d.mapCenter then
                    assert(not initX,"Multiple mapCenter")
                    initX,initY=-x,-y
                end
                ---@type ReroChess.Cell
                cells[i]={
                    id=i,x=x,y=y,
                    next={},prev={},
                    propList=parseProp(d.prop),
                }
                if d.label then cells[d.label]=cells[i] end
            end

            -- Manual next
            for id,d in next,data.mapData do
                if type(d.next)=='string' then
                    table.insert(cells[id].next,cells[d.next].id)
                elseif type(d.next)=='table' then
                    for _,label in next,d.next do
                        table.insert(cells[id].next,cells[label].id)
                    end
                end
            end

            -- Auto next
            for id=1,#cells-1 do
                if #cells[id].next==0 and MATH.mDist2(0,cells[id].x,cells[id].y,cells[id+1].x,cells[id+1].y)<=1 then
                    table.insert(cells[id].next,cells[id+1].id)
                end
            end

            -- Auto prev
            for _,cell in next,cells do
                for _,n in next,cell.next do
                    table.insert(cells[n].prev,cell.id)
                end
            end

            -- Postprocess
            for _,cell in next,cells do
                local remCount=0
                for i=1,#cell.propList do
                    i=i-remCount
                    local prop=cell.propList[i]

                    if prop[1]=='step' then
                        cell.text={prop[0] and COLOR.R or COLOR.D,("(%d)"):format(prop[2])}
                    elseif prop[1]=='move' then
                        cell.text={prop[0] and COLOR.R or COLOR.D,("%+d"):format(prop[2])}
                    elseif prop[1]=='teleport' then
                        cell.text={prop[0] and COLOR.R or COLOR.D,"T"}
                        if type(prop[2])=='string' then
                            prop[2]=assert(cells[prop[2]],'Invalid teleport target: %s',prop[2]).id
                        end
                        cells[prop[2]].text={prop[0] and COLOR.R or COLOR.D,"t"}
                    elseif prop[1]=='stop' then
                        cell.text={prop[0] and COLOR.R or COLOR.D,"X"}
                    elseif prop[1]=='reverse' then
                        cell.text={prop[0] and COLOR.R or COLOR.D,"R"}
                    end

                    if CellEvent[prop[1]]==true then
                        table.remove(cell.propList,i)
                        remCount=remCount+1
                    end
                end
            end

            return cells
        end)(),
        cam=GC.newCamera(),
        text=TEXT.new(),
        roundIndex=1,
    },Game)
    for id,p in next,game.players do
        p.game=game
        local cell=assert(game.map[p.location],"Invalid start location for player "..id)
        p.location=cell.id
        p.x,p.y=p.x+cell.x,p.y+cell.y
    end
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
    do -- Line beneath
        gc_setLineWidth(0.2)
        gc_setColor(COLOR.L)
        for i=1,#map do
            local cell=map[i]
            for n=1,#cell.next do
                local next=map[cell.next[n]]
                gc_line(cell.x,cell.y,next.x,next.y)
            end
        end
    end
    do -- Cell
        gc_setLineWidth(0.026)
        for i=1,#map do
            local cell=map[i]
            if cell.propList~='invis' then
                local x,y=cell.x,cell.y
                gc_setColor(COLOR.L)
                gc_rectangle('fill',x-.45,y-.45,.9,.9)
                gc_setColor(COLOR.D)
                gc_rectangle('line',x-.45,y-.45,.9,.9)
                if cell.text then
                    gc_setColor(1,1,1)
                    tileText:set(cell.text)
                    gc_mDraw(tileText,x,y,nil,.01)
                end
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
