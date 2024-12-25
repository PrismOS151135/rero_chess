---@class ReroChess.Player
---@field game ReroChess.Game
---
---@field index integer
---@field name string
---@field color Zenitha.Color
---
---@field location integer
---@field moveDir 'next' | 'prev' | false
---@field dice ReroChess.Dice
---
---@field moving boolean
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
---@field animState false | 'roll' | 'bounce' | 'fade'
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
        index=index,
        name=data.name,

        color=data.customColor or defaultColor[index],
        location=data.startLocation or 1,
        moveDir=data.startMoveDir or 'next',
        dice={
            points=data.dicePoints or {1,2,3,4,5,6,7},
            weights=data.diceWeights or {1,1,1,1,1,1,.01},
            animState=false,
        },

        x=(index-1)%2==0 and -.1 or .1,
        y=(index-1)%4<=1 and -.1 or .1,
    },Player)
    assert(#player.dice.points==#player.dice.weights,"Dice points and weights mismatch")
    return player
end

local diceDisappearingCurve={1,1,.7,.4,0}
function Player:roll()
    local d=self.dice
    if not d.animState then
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
                    d.animState=false
                end):run()
            end):run()
        end):run()
    end
end

function Player:move(stepCount)
    self.moving=true
    self.stepRemain=stepCount
    local map=self.game.map
    local pos=self.location
    local nextPos,dir=self.game:getNext(pos,self.moveDir)

    TASK.new(function()
        while self.stepRemain>0 do
            local x1,y1=self.x,self.y
            local x2,y2=map[nextPos].x+MATH.rand(-.15,.15),map[nextPos].y+MATH.rand(-.15,.15)
            local animLock=true
            TWEEN.new(function(t)
                self.x=MATH.lerp(x1,x2,t)
                self.y=MATH.lerp(y1,y2,t)+t*(t-1)*1.5
                if t==1 then
                    pos=nextPos
                    self.location=pos
                    nextPos,dir=self.game:getNext(pos,dir)
                end
            end):setEase('Linear'):setDuration(0.26):setOnFinish(function()
                animLock=false
            end):run()
            repeat coroutine.yield() until not animLock
            self.stepRemain=self.stepRemain-1
        end
        self.moving=false
    end)
end

local gc=love.graphics
local gc_push,gc_pop=gc.push,gc.pop
local gc_translate,gc_scale=gc.translate,gc.scale
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle,gc_circle=gc.rectangle,gc.circle
local gc_setAlpha=GC.setAlpha
local gc_mDraw=GC.mDraw
local diceText=GC.newText(assert(FONT.get(60)))
function Player:draw()
    gc_setColor(self.color)
    gc_setAlpha(.5)
    gc_setLineWidth(0.0626)
    gc_circle('line',self.x,self.y,.26)

    if self.dice.animState then
        local d=self.dice
        gc_push('transform')
        gc_translate(d.x,d.y)
        gc_scale(d.size*.626)
        gc_setAlpha(d.alpha)
        gc_rectangle('fill',-.5,-.5,1,1)
        gc_setColor(1,1,1,.42*d.alpha)
        gc_rectangle('fill',-.5,-.5,1,1)
        gc_setColor(0,0,0,d.alpha)
        gc_rectangle('line',-.5,-.5,1,1)
        diceText:set(tostring(d.value))
        gc_mDraw(diceText,0,0,nil,.01)
        gc_pop()
    end
end

return Player
