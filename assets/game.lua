local Prop=require'assets.prop'
local Player=require'assets.player'

---@class ReroChess.Game
---@field map ReroChess.Cell[]
---@field deco table
---@field players ReroChess.Player[]
---@field textBatch love.Text
---@field spriteBatches love.SpriteBatch[]
---@field drawCoroutine {th:thread, p:ReroChess.Player}[]
---@field cam Zenitha.Camera
---@field text Zenitha.Text
---
---@field roundIndex integer
local Game={}
Game.__index=Game

---@class ReroChess.CellProp (string|any)[]
---@field [0]? true Trigger Instant?
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



---@param data string | table
---@return ReroChess.CellProp
local function parseProp(data)
    if data==nil then return {} end

    -- Parse data
    if type(data)=='string' then
        ---@type any
        data=data:split(' ')
        for i=1,#data do
            data[i]=data[i]:split(',')
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
        local event=Prop[prop[1]]
        assertf(event,'Invalid prop command: %s',tostring(prop[1]))
        if event.parse then event.parse(prop) end
    end
    return data
end

local _tempText=GC.newText(FONT.get(40))
local function getTextSize(str)
    _tempText:set(str)
    return _tempText:getDimensions()
end

---@class ReroChess.CellData: ReroChess.Cell
---@field id nil
---@field x? number
---@field y? number
---@field dx? number
---@field dy? number
---@field prop? string

---@class ReroChess.MapData
---@field texturePack? string
---@field playerData ReroChess.PlayerData[]
---@field decoData Zenitha.drawingCommand[]
---@field mapData ReroChess.CellData[]
--
---@param data ReroChess.MapData
function Game.new(data)
    assert(data.mapData,"Missing field 'mapData'")
    assert(data.playerData,"Missing field 'playerData'")
    assert(data.decoData==nil or type(data.decoData)=='table',"Invalid field 'decoData'")

    ---@type ReroChess.Game
    local game=setmetatable({
        map={},
        deco=data.decoData or {},
        players={},

        spriteBatches={},
        textBatch=GC.newText(FONT.get(40)),
        drawCoroutine={},

        cam=GC.newCamera(),
        text=TEXT.new(),
        roundIndex=1,
    },Game)

    -- for i=1,#game.deco do
    --     -- TODO
    -- end

    local worldTexture=TEX.world[data.texturePack==nil and 'default' or data.texturePack] or error("Invalid texture pack: "..tostring(data.texturePack))
    game.spriteBatches[1]=GC.newSpriteBatch(worldTexture,nil,'dynamic') -- BG
    game.spriteBatches[2]=GC.newSpriteBatch(worldTexture,nil,'dynamic') -- Path
    game.spriteBatches[3]=GC.newSpriteBatch(worldTexture,nil,'dynamic') -- FG
    game.spriteBatches[4]=GC.newSpriteBatch(TEX.doodle,  nil,'dynamic') -- Doodle

    local bgSB=game.spriteBatches[1]
    local pathSB=game.spriteBatches[2]
    local textB=game.textBatch
    local decoSB=game.spriteBatches[3]

    -- Tool func
    local function getQuadCenter(quad)
        local _,_,w,h=quad:getViewport()
        return w/2,h/2
    end
    local strokeColor={.9,.9,.9,.42}
    local instColor,normalColor={.26,0,0},{.05,.05,.05}
    local function addQ(mode,cell,prop,item)
        if mode=='text' then
            local w,h=getTextSize(item)
            local k=0.65/math.max(w,h)
            for dx=-2,2,4 do for dy=-2,2,4 do
                textB:addf(
                    {strokeColor,item},
                    620,'center',
                    cell.x+(-310+dx)*k,cell.y-h/2*k+dy*k,
                    nil,k
                )
            end end
            textB:addf(
                {prop[0] and instColor or normalColor,item},
                620,'center',
                cell.x+(-310)*k,cell.y-h/2*k,
                nil,k
            )
        elseif mode=='deco' then
            -- decoSB:add(
            pathSB:add(
                item,
                cell.x-.26,cell.y-.26,
                nil,0.004,nil,
                -- cell.x,cell.y,
                -- nil,0.01,nil,
                getQuadCenter(item)
            )
        elseif mode=='DECO' then
            -- decoSB:add(
            pathSB:add(
                item,
                -- cell.x+.22,cell.y-.22,
                -- nil,0.006,nil,
                cell.x,cell.y,
                nil,0.01,nil,
                getQuadCenter(item)
            )
        end
    end

    do -- Initialize map
        ---@type ReroChess.Cell[]
        local map=game.map

        -- Initialize
        local x,y=0,0
        local centered
        for i=1,#data.mapData do
            local d=data.mapData[i]
            if not not d[1]~=not not d[2] then
                errorf('Incomplete delta position for cell %d',i)
            end
            x=d.x or x+(d.dx or d[1] or 0)
            y=d.y or y+(d.dy or d[2] or 0)
            ---@type ReroChess.Cell
            local cell={
                id=i,x=x,y=y,
                next={},prev={},
                propList=parseProp(d.prop),
            }
            local quad=QUAD.world.tile[i%6+1]
            pathSB:add(
                quad,
                x+MATH.rand(-.01,.01),
                y+MATH.rand(-.01,.01),
                MATH.rand(-.03,.03),
                0.0038,nil,
                getQuadCenter(quad)
            )
            for _,prop in next,cell.propList do
                if prop[1]=='label' then
                    map[prop[2]]=cell
                elseif prop[1]=='center' then
                    assert(not centered,"Multiple map center")
                    centered=true
                    game.cam:move(-x,-y)
                    game.cam:update(1)
                elseif prop[1]=='next' then
                    for j=2,#prop do
                        table.insert(cell.next,prop[j])
                    end
                end
            end
            map[i]=cell
        end

        -- Process props
        for _,cell in next,map do
            local remCount=0
            for i=1,#cell.propList do
                i=i-remCount
                local prop=cell.propList[i]

                if prop[1]=='text' then
                    addQ('text',cell,prop,prop[2])
                elseif prop[1]=='step' then
                    addQ('text',cell,prop,("+%d步"):format(prop[2]))
                    addQ('deco',cell,prop,QUAD.world.moveF)
                elseif prop[1]=='move' then
                    addQ('text',cell,prop,("%s%d格"):format(prop[2]>0 and '进' or '退',math.abs(prop[2])))
                    addQ('deco',cell,prop,prop[2]>0 and QUAD.world.moveF or QUAD.world.moveB)
                elseif prop[1]=='teleport' then
                    if type(prop[2])=='string' then
                        prop[2]=assertf(map[prop[2]],'Invalid teleport target: %s',prop[2]).id
                    end
                    addQ('deco',cell,prop,QUAD.world.warn)
                elseif prop[1]=='stop' then
                    addQ('text',cell,prop,"停止")
                    addQ('deco',cell,prop,QUAD.world.warn)
                elseif prop[1]=='reverse' then
                    addQ('text',cell,prop,"反转")
                    addQ('deco',cell,prop,QUAD.world.warn)
                elseif prop[1]=='diceMod' then
                    addQ('text',cell,prop,"下次点数"..prop[2]..prop[3]) -- TODO
                    addQ('deco',cell,prop,QUAD.world.warn)
                elseif prop[1]=='exTurn' then
                    addQ('text',cell,prop,(prop[2]>0 and "再骰%d次" or "跳过%d回合"):format(math.abs(prop[2])))
                    addQ('deco',cell,prop,QUAD.world.warn)
                end

                if Prop[prop[1]].tag then
                    table.remove(cell.propList,i)
                    remCount=remCount+1
                end
            end
        end

        -- Manual next
        for _,cell in next,map do
            for i,label in next,cell.next do
                cell.next[i]=(map[label] or error("Invalid nextCell label/id: "..label)).id
            end
        end

        -- Auto next
        for id=1,#map-1 do
            if #map[id].next==0 and MATH.mDist2(0,map[id].x,map[id].y,map[id+1].x,map[id+1].y)<=1.026 then
                table.insert(map[id].next,map[id+1].id)
            end
        end

        -- Generate Path
        for id=1,#map do
            for _,n in next,map[id].next do
                local c1,c2=map[id],map[n]
                if MATH.mDist2(0,c1.x,c1.y,c2.x,c2.y)<=1.026 then
                    local quad=QUAD.world.path
                    bgSB:add(
                        quad,
                        (c1.x+c2.x)/2,
                        (c1.y+c2.y)/2,
                        MATH.roundUnit(math.atan2(c2.y-c1.y,c2.x-c1.x)+math.pi/2,math.pi/2),
                        0.0035,nil,
                        getQuadCenter(quad)
                    )
                end
            end
        end

        -- Auto prev
        for _,cell in next,map do
            for _,n in next,cell.next do
                table.insert(map[n].prev,cell.id)
            end
        end
    end

    -- Initialize players
    for i=1,#data.playerData do
        local p=Player.new(i,data.playerData[i],game)
        local cell=game.map[p.location] or error("Invalid start location for player "..i)
        p.location=cell.id
        p.x,p.y=p.x+cell.x,p.y+cell.y

        local nextLocation=game:getNext(p.location,p.moveDir)
        if nextLocation then
            local nCell=game.map[nextLocation]
            p.faceDir=p.x<=nCell.x and 1 or -1
        end

        local drawCo=coroutine.create(Player.draw)
        coroutine.resume(drawCo,p)
        game.drawCoroutine[i]={th=drawCo,p=p}

        game.players[i]=p
    end

    game.cam.minK=10
    game.cam.maxK=200
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
            self:updateTurn()
        end)
    end
end

function Game:updateTurn()
    local p=self.players[self.roundIndex]
    if p.extraTurn>0 then
        p.extraTurn=p.extraTurn-1
        MSG('other',"玩家"..self.roundIndex.."的额外回合")
    else
        while true do
            self.roundIndex=self.roundIndex%#self.players+1
            p=self.players[self.roundIndex]
            if p.extraTurn>=0 then break end
            p.extraTurn=p.extraTurn+1
        end
        MSG('other',"玩家"..self.roundIndex.."的回合")
    end
end

---@param a {p:ReroChess.Player}
local function coSorter(a,b)
    return a.p.y<b.p.y
end
function Game:sortPlayerLayer()
    local drawCo=self.drawCoroutine
    table.sort(drawCo,coSorter)
    -- for i=1,#drawCo-1 do
    --     if drawCo[i].p.id==self.roundIndex then
    --         drawCo[i],drawCo[i+1]=drawCo[i+1],drawCo[i]
    --     end
    -- end
end
function Game:step()
    local p=self.players[self.roundIndex]
    if p.moving then
        p.moveSignal=true
        return true
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
local resume=coroutine.resume

function Game:draw()
    self.cam:apply()

    gc_setColor(1,1,1)
    GC.execute(self.deco)

    local SB=self.spriteBatches
    gc_setColor(1,1,1)
    gc_draw(SB[1]) -- BG
    gc_draw(SB[2]) -- Path
    gc_draw(self.textBatch)
    gc_draw(SB[3]) -- FG
    gc_draw(SB[4]) -- Doodle

    if false then
        -- Map (Debug)

        -- Line beneath
        local map=self.map
        gc_setLineWidth(0.2)
        gc_setColor(1,1,1,.2)
        for i=1,#map do
            local cell=map[i]
            for n=1,#cell.next do
                local next=map[cell.next[n]]
                gc_line(cell.x,cell.y,next.x,next.y)
            end
        end

        -- Cell
        gc_setLineWidth(0.026)
        for i=1,#map do
            local cell=map[i]
                local x,y=cell.x,cell.y
                gc_setColor(1,1,1,.2)
                gc_rectangle('fill',x-.45,y-.45,.9,.9)
                gc_setColor(0,0,0,.2)
                gc_rectangle('line',x-.45,y-.45,.9,.9)
        end
    end

    --Player
    local pList=self.players
    local co=self.drawCoroutine
    for i=1,#pList do resume(co[i].th,true) end
    for i=1,#pList do resume(co[i].th) end
    for i=1,#pList do resume(co[i].th) end
    for i=1,#pList do resume(co[i].th) end

    self.text:draw()
end

return Game
