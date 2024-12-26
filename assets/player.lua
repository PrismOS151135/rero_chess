---@class ReroChess.Player
---@field game ReroChess.Game
---@field _name love.Text
---
---@field id integer
---@field name string
---@field color Zenitha.Color
---
---@field location integer
---@field moveDir 'next' | 'prev' | false
---@field dice ReroChess.Dice
---
---@field moving boolean
---@field moveSignal boolean
---@field tarLocation integer
---@field stepRemain integer
---
---@field x number
---@field y number
---
local Player={}
Player.__index=Player

---@class ReroChess.Dice
---@field points integer[]
---@field weights number[]
---
---Dice state
---@field valueIndex integer
---@field value integer
---@field animState 'hide' | 'roll' | 'bounce' | 'fade'
---
---Animation properties
---@field x number
---@field y number
---@field alpha number
---@field size number
---@field clipTime number



---@class ReroChess.PlayerData
---@field name string
---@field startLocation? integer
---@field startMoveDir? 'next' | 'prev'
---@field customColor? Zenitha.Color
---@field dicePoints? integer[]
---@field diceWeights? number[]

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
        id=index,
        name=data.name,

        color=data.customColor or defaultColor[index],
        location=data.startLocation or 1,
        moveDir=data.startMoveDir or 'next',
        dice={
            points=data.dicePoints or {1,2,3,4,5,6,7},
            weights=data.diceWeights or {1,1,1,1,1,1,.01},
            animState='hide',
        },

        x=(index-1)%2==0 and -.2 or .2,
        y=(index-1)%4<=1 and -.2 or .2,
    },Player)
    player._name=GC.newText(FONT.get(20),player.name)
    assert(#player.dice.points==#player.dice.weights,"Dice points and weights mismatch")
    return player
end

local diceDisappearingCurve={1,1,.7,.4,0}
function Player:roll()
    local d=self.dice
    if d.animState=='hide' then
        d.animState='roll'
        d.alpha=1
        d.size=1
        d.clipTime=0
        d.x=self.x
        d.y=self.y-1
        TWEEN.new(function(t)
            if t>d.clipTime then
                d.clipTime=t+1/64
                local r
                repeat
                    r=MATH.randFreq(d.weights)
                until r~=d.valueIndex
                d.valueIndex=r
                d.value=d.points[r]
            end
        end):setEase('OutCirc'):setDuration(2.6):setOnFinish(function()
            d.animState='bounce'
            TWEEN.new(function(t)
                d.size=1+math.sin(t*26)/(1+62*t)
            end):setEase('Linear'):setOnFinish(function()
                d.animState='fade'
                TWEEN.new(function(t)
                    d.alpha=MATH.lLerp(diceDisappearingCurve,t)
                end):setDuration(1):setOnFinish(function()
                    d.animState='hide'
                end):run()
            end):run()
        end):run()
    end
end

function Player:move(stepCount)
    self.moving=true
    self.stepRemain=stepCount
    local game=self.game
    local map=game.map
    local pos=self.location
    local nextPos,dir=game:getNext(pos,self.moveDir)

    TASK.new(function()
        while self.stepRemain>0 do
            local sx,sy=self.x,self.y
            local ex,ey=map[nextPos].x+MATH.rand(-.15,.15),map[nextPos].y+MATH.rand(-.15,.15)
            local animLock=true

            -- Wait signal
            repeat coroutine.yield() until self.moveSignal
            self.moveSignal=false

            -- Move chess
            TWEEN.new(function(t)
                self.x=MATH.lerp(sx,ex,t)
                self.y=MATH.lerp(sy,ey,t)+t*(t-1)*1.5
                if t==1 then
                    pos=nextPos
                    self.location=pos
                    nextPos,dir=game:getNext(pos,dir)
                end
            end):setEase('Linear'):setDuration(0.26):setOnFinish(function()
                animLock=false
            end):run()

            -- Wait until Animation end
            repeat coroutine.yield() until not animLock

            -- Check Cell Property
            self.stepRemain=self.stepRemain-1
            if self.stepRemain==0 then
                local cell=map[pos]
                if cell.prop=='move' then
                    self.stepRemain=math.abs(cell.propData)
                    dir=cell.propData>0 and 'next' or 'prev'
                    nextPos,dir=game:getNext(pos,dir)
                    self:popText{
                        text=("%+d"):format(cell.propData),
                        duration=2,
                        x=0.4,
                    }
                elseif cell.prop=='teleport' then
                    pos=cell.propData
                    self.location=pos
                    self.x,self.y=map[pos].x,map[pos].y
                    nextPos,dir=game:getNext(pos,self.moveDir)
                end
            end
        end
        self.moving=false
    end)
end

---@param d {text:string, x?:number, y?:number, k?:number, duration?:number, color?:Zenitha.Color}
function Player:popText(d)
    self.game.text:add{
        text=d.text,
        x=self.x+(d.x or 0),
        y=self.y+(d.y or 0),
        k=0.008*(d.k or 1),
        fontSize=40,
        duration=d.duration or 2,
        color=d.color or 'D',
        style='score',
        styleArg=1,
    }
end

local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_translate,gc_scale,gc_rotate=gc.translate,gc.scale,gc.rotate
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle,gc_circle=gc.rectangle,gc.circle
local gc_setAlpha=GC.setAlpha
local gc_mRect,gc_mDraw=GC.mRect,GC.mDraw
local text=GC.newText(assert(FONT.get(60)))
function Player:draw()
    -- Chess
    gc_setColor(self.color)
    gc_setAlpha(.5)
    gc_setLineWidth(0.0626)
    gc_circle('line',self.x,self.y,.26)

    -- Name tag
    gc_push('transform')
        gc_translate(self.x,self.y-.5+.05*math.sin(love.timer.getTime()+self.id))
        gc_setColor(.3,.3,.3,.5)
        gc_mRect('fill',0,0,(self._name:getWidth()+10)*.01,(self._name:getHeight()+2)*.01)
        gc_setColor(self.color)
        gc_mDraw(self._name,0,0,nil,.01)
        gc_setColor(1,1,1,.62)
        gc_mDraw(self._name,0,0,nil,.01)
    gc_pop()

    -- Step remain
    if self.moving then
        gc_push('transform')
        gc_translate(self.x+.4,self.y-.2)
        -- gc_translate(0,-.1*math.abs(math.sin(love.timer.getTime()*8)))
        gc_rotate(math.sin(love.timer.getTime()*8)*.1)
        local size=.4
        gc_setColor(1,1,1,.9)
        gc_mRect('fill',0,0,size,size)
        gc_setColor(COLOR.D)
        gc_setLineWidth(0.026)
        gc_mRect('line',0,0,size,size)
        text:set(tostring(self.stepRemain))
        gc_mDraw(text,0,0,nil,.005)
        gc_pop()
    end

    -- Dice
    if self.dice.animState~='hide' then
        local d=self.dice
        gc_push('transform')
        gc_translate(d.x,d.y)
        gc_scale(d.size*.626)
        gc_setColor(self.color)
        gc_setAlpha(d.alpha)
        gc_rectangle('fill',-.5,-.5,1,1)
        gc_setColor(1,1,1,.42*d.alpha)
        gc_rectangle('fill',-.5,-.5,1,1)
        gc_setColor(0,0,0,d.alpha)
        gc_setLineWidth(0.042)
        gc_rectangle('line',-.5,-.5,1,1)
        text:set(tostring(d.value))
        gc_mDraw(text,0,0,nil,.01)
        gc_pop()
    end
end

return Player
