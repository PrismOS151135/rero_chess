---@class ReroChess.Dice
---Setting
---@field points number[]
---
---Dice state
---@field state integer
---@field enable boolean
---
---Animation properties
---@field alpha number
---@field size number
---@field clipTime number
local Dice={}
Dice.__index=Dice

---@class ReroChess.DiceData
---@field points? number[]

---@param data ReroChess.DiceData
function Dice.new(data)
    local dice=setmetatable({
        points=data.points or {1,2,3,4,5,6},
        state=0,

        enable=false,
        alpha=0,
    },Dice)
    return dice
end

local diceDisappearingCurve={1,1,.7,.4,0}
function Dice:roll()
    if not self.enable then
        self.enable=true
        self.alpha=1
        self.size=1
        self.clipTime=0
        TWEEN.new(function(t)
            if t>self.clipTime then
                self.clipTime=t+1/64
                local r
                repeat
                    r=math.random(#self.points)
                until r~=self.state
                self.state=r
            end
        end):setEase('OutCirc'):setDuration(2.6):setOnFinish(function()
            TWEEN.new(function(t)
                self.size=1+math.sin(t*26)/(1+62*t)
            end):setEase('Linear'):setOnFinish(function()
                TWEEN.new(function(t)
                    self.alpha=MATH.lLerp(diceDisappearingCurve,t)
                end):setDuration(1):setOnFinish(function()
                    self.enable=false
                end):run()
            end):run()
        end):run()
    end
end

function Dice:getValue()
    return self.points[self.state] or 0
end

local gc=love.graphics
local gc_translate,gc_scale,gc_rotate,gc_shear=gc.translate,gc.scale,gc.rotate,gc.shear
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle,gc_circle,gc_polygon=gc.rectangle,gc.circle,gc.polygon
local gc_mDraw=GC.mDraw

local diceText=GC.newText(FONT.get(60))

function Dice:draw()
    gc_translate(0,-1)
    gc_scale(self.size*.626)
    gc_setColor(1,1,1,self.alpha)
    gc_rectangle('fill',-.5,-.5,1,1)
    gc_setColor(1,1,1,.42*self.alpha)
    gc_rectangle('fill',-.5,-.5,1,1)
    gc_setColor(0,0,0,self.alpha)
    gc_rectangle('line',-.5,-.5,1,1)
    diceText:set(self:getValue())
    gc_mDraw(diceText,0,0,nil,.01)
end

return Dice
