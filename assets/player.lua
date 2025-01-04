local Prop=require'assets.prop'

---@class ReroChess.Player
---@field game ReroChess.Game
---@field _name love.Text
---
---@field id integer
---@field name string
---@field skin string
---@field color Zenitha.Color
---@field faceDir -1 | 1
---@field face 'normal' | 'forward' | 'backward' | 'selected' | 'jail'
---@field size number
---
---@field location integer
---@field moveDir 'next' | 'prev' | false
---@field dice ReroChess.Dice
---
---Variables for moving in round
---@field moving boolean
---@field moveSignal boolean
---@field stepRemain integer
---@field nextLocation integer
---@field curDir 'next' | 'prev' | false
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
---@field skin? string
---@field startLocation? integer|string
---@field startMoveDir? 'next' | 'prev'
---@field size? number
---@field color? Zenitha.Color
---@field dicePoints? integer[]
---@field diceWeights? number[]

---@param data ReroChess.PlayerData
function Player.new(id,data,game)
    local player=setmetatable({
        game=game,
        id=id,
        name=data.name,
        skin=data.skin or '普通的棋子娘',

        color=data.color or COLOR.dL,
        size=(data.size or 0.7)/256,
        faceDir=1,
        face='normal',
        location=data.startLocation or 1,
        moveDir=data.startMoveDir or 'next',
        dice={
            points=data.dicePoints or {1,2,3,4,5,6,7},
            weights=data.diceWeights or {1,1,1,1,1,1,.01},
            animState='hide',
        },

        x=(id-1)%2==0 and -.26 or .26,
        y=(id-1)%4<=1 and -.26 or .26,
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
        d.x=self.x+.7
        d.y=self.y-.9
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
    self.nextLocation,self.curDir=self.game:getNext(self.location,self.moveDir)

    TASK.new(function()
        while self.stepRemain>0 do
            local sx,sy=self.x,self.y
            local ex,ey=self.game.map[self.nextLocation].x+MATH.rand(-.15,.15),self.game.map[self.nextLocation].y+MATH.rand(-.15,.15)
            local animLock=true
            self.faceDir=sx<=ex and 1 or -1

            -- Wait signal
            repeat coroutine.yield() until self.moveSignal
            self.moveSignal=false

            -- Move chess
            TWEEN.new(function(t)
                self.x=MATH.lerp(sx,ex,t)
                self.y=MATH.lerp(sy,ey,t)+t*(t-1)*1.5
                if t==1 then
                    self.location=self.nextLocation
                    self.nextLocation,self.curDir=self.game:getNext(self.location,self.curDir)
                end
            end):setEase('Linear'):setDuration(0.26):setOnFinish(function()
                animLock=false
            end):run()

            -- Wait until animation end
            repeat coroutine.yield() until not animLock

            self.stepRemain=self.stepRemain-1

            -- Trigger cell property
            self:triggerCell()
            self.game:sortPlayerLayer()
        end
        self.moving=false
        self.face='normal'
    end)
end

function Player:triggerCell()
    for _,prop in next,self.game.map[self.location].propList do
        if prop[0] or self.stepRemain==0 then
            Prop[prop[1]].code(self,unpack(prop,2))
        end
    end
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
local gc_setShader=gc.setShader
local gc_setColor,gc_setLineWidth=gc.setColor,gc.setLineWidth
local gc_rectangle,gc_circle,gc_ellipse=gc.rectangle,gc.circle,gc.ellipse
local gc_draw=gc.draw
local gc_setAlpha=GC.setAlpha
local gc_mRect,gc_mDraw=GC.mRect,GC.mDraw
local text=GC.newText(assert(FONT.get(60)))

function Player:draw()
    local skin=TEX.chess[self.skin]
    while true do
        -- Layer 1
        do if coroutine.yield()~=true then error("Rendering signal mis-match") end
            -- Color Mark
            -- gc_setColor(self.color)
            -- gc_setAlpha(.8)
            -- gc_setLineWidth(0.062)
            -- gc_ellipse('fill',self.x+skin.shadeX,self.y+skin.shadeY,.3,.08)

            -- Shade
            gc_setColor(self.color)
            gc_setAlpha(.4)
            gc_setShader(SHADER.darker)
            gc_ellipse('fill',self.x+skin.shadeX,self.y+skin.shadeY,skin.shadeR,skin.shadeR*.26)
            gc_setShader()
        end

        -- Layer 2
        do coroutine.yield()
            gc_push('transform')
            gc_translate(self.x,self.y)

            -- Chess (circle)
            -- gc_setColor(self.color)
            -- gc_setLineWidth(0.0626)
            -- gc_circle('line',0,0,.26)

            -- Chess
            -- gc_setColor(self.color)
            -- gc_setShader(SHADER.lighter)
            -- gc_draw(skin.base,0-.02,0.1-.02,nil,self.faceDir*self.size,self.size,128,256)
            -- gc_setShader()
            gc_setColor(1,1,1)
            gc_draw(skin.base,0,0.1,nil,self.faceDir*self.size,self.size,128,256)
            gc_draw(skin[self.face],0,0.1,nil,self.faceDir*self.size,self.size,128,256)

            -- Step remain
            if self.moving then
                gc_push('transform')
                gc_translate(.4,-.5)
                -- gc_translate(0,-.1*math.abs(math.sin(love.timer.getTime()*8)))
                gc_rotate(.1*Jump.sin())
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

            gc_pop()
        end

        -- Layer 3
        do coroutine.yield()
            -- Dice
            if self.dice.animState~='hide' then
                gc_push('transform')
                    local d=self.dice
                    gc_translate(d.x,d.y)
                    gc_scale(d.size*.626)
                    gc_setColor(self.color)
                    gc_setAlpha(d.alpha)
                    gc_rectangle('fill',-.5,-.5,1,1)
                    gc_setColor(0,0,0,d.alpha)
                    gc_setLineWidth(0.042)
                    gc_rectangle('line',-.5,-.5,1,1)
                    text:set(tostring(d.value))
                    gc_mDraw(text,0,0,nil,.01)
                gc_pop()
            end
        end

        -- Layer 4
        do coroutine.yield()
            gc_push('transform')
            gc_translate(self.x,self.y)

            -- Name Tag
            gc_translate(0,-.626+10*Jump.nametag(self.id)*self.size)
            gc_setColor(.3,.3,.3,.5)
            gc_mRect('fill',0,0,(self._name:getWidth()+10)*.01,(self._name:getHeight()+2)*.01)
            gc_setColor(self.color)
            gc_mDraw(self._name,0,0,nil,.01)

            gc_pop()
        end
    end
end

return Player
