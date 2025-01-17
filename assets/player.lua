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
---Variables between rounds
---@field extraTurn integer
---@field diceMod table[]
---
---Variables for moving in round
---@field moving boolean
---@field stepRemain integer
---@field nextLocation integer
---@field curDir 'next' | 'prev' | false
---
---@field canBeSelected boolean
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
            points={1,2,3,4,5,6,7},
            weights={1,1,1,1,1,1,.01},
            animState='hide',
        },

        extraTurn=0,
        diceMod={},

        x=(id-1)%2==0 and -.26 or .26,
        y=(id-1)%4<=1 and -.26 or .26,
    },Player)
    if data.dicePoints and data.diceWeights then
        player.dice.points=data.dicePoints
        player.dice.weights=data.diceWeights
    elseif data.dicePoints then
        player.dice.points=data.dicePoints
        player.dice.weights=TABLE.new(1,#data.dicePoints)
    elseif data.diceWeights then
        player.dice.weights=data.diceWeights
        player.dice.points={}
        for i=1,#data.diceWeights do player.dice.points[i]=i end
    end
    assertf(#player.dice.points==#player.dice.weights,"Dice points and weights mismatch (%d vs %d)",#player.dice.points,#player.dice.weights)
    player._name=GC.newText(FONT.get(20),player.name)
    return player
end

local diceDisappearingCurve={1,1,.7,.4,0}
function Player:roll()
    local d=self.dice
    if d.animState=='hide' then
        d.animState='roll'

        -- Size
        TWEEN.new(function(t) d.size=.4+.6*t end):setDuration(0.26):run()

        -- Position
        local sx,sy=self.x,self.y
        local dist=MATH.rand(.62,1.26)
        local rot=MATH.rand(0,-math.pi)
        local ex,ey=self.x+dist*math.cos(rot),self.y+dist*math.sin(rot)*.5
        TWEEN.new(function(t)
            d.x=MATH.lerp(sx,ex,t)
            d.y=MATH.lerp(sy,ey,t)+t*(t-1)*2.6
        end):setEase('Linear'):setDuration(0.62):run()

        -- Value
        d.alpha=1
        d.clipTime=0
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
            if #self.diceMod>0 then
                local mod=table.remove(self.diceMod,1)
                if mod[1]=='+' then
                    d.value=d.value+mod[2]
                elseif mod[1]=='-' then
                    d.value=d.value-mod[2]
                elseif mod[1]=='*' then
                    d.value=d.value*mod[2]
                elseif mod[1]=='/' then
                    d.value=d.value/mod[2]
                elseif mod[1]=='^' then
                    d.value=d.value^mod[2]
                end
                self:popText{
                    text=mod[1]..mod[2],
                    duration=1,
                    x=self.dice.x-self.x,
                    y=self.dice.y-self.y+0.2,
                }
                d.value=MATH.sign(d.value)*math.floor(math.abs(d.value)+.00001)
            end
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

---@param self ReroChess.Player
---@param stepCount integer
---@param manual boolean
local function moveThread(self,stepCount,manual)
    self.moving=true
    self.game.roundInfo.step=false
    self.nextLocation,self.curDir=self.game:getNext(self.location,stepCount>0 and self.moveDir or self.moveDir=='next' and 'prev' or 'next')

    while math.abs(self.stepRemain)>=1 do
        local sx,sy=self.x,self.y
        local ex,ey=self.game.map[self.nextLocation].x+MATH.rand(-.15,.15),self.game.map[self.nextLocation].y+MATH.rand(-.15,.15)
        local animLock=true
        self.faceDir=sx<=ex and 1 or -1

        -- Wait signal
        if manual then
            repeat TASK.yieldT(.1) until self.game.roundInfo.step
            self.game.roundInfo.step=false
        end

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

        self.stepRemain=MATH.linearApproach(self.stepRemain,0,1)

        -- Trigger cell property
        self:triggerCell()
        self.game:sortPlayerLayer()
    end

    self.moving=false
    self.face='normal'
end

function Player:move(stepCount,manual)
    self.stepRemain=stepCount
    if self.moving then
        self.curDir=stepCount>0 and 'next' or 'prev'
        self.nextLocation,self.curDir=self.game:getNext(self.location,self.curDir)
        self.face=self.curDir==self.moveDir and 'forward' or 'backward'
    else
        TASK.new(moveThread,self,stepCount,manual)
    end
end

function Player:triggerCell()
    for _,prop in next,self.game.map[self.location].propList do
        if prop[0] or self.stepRemain==0 then
            local args=TABLE.sub(prop,2)
            local suc
            for i=1,#args do
                if tostring(args[i]):sub(1,1)=='@' then
                    args[i]=self.game:parsePlayer(self,args[i])
                    if args[i]==false then suc=true end
                end
            end
            if suc then
                self:popText{text='没有目标!'}
                Prop[prop[1]].code(self,unpack(args))
            end
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
local gc_line,gc_rectangle,gc_circle,gc_ellipse=gc.line,gc.rectangle,gc.circle,gc.ellipse
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

            -- Target Mark
            if self.canBeSelected then
                gc_push('transform')
                gc_translate(0,-0.2)
                gc_rotate(love.timer.getTime()*(1+self.id/10))
                gc_setColor(1,.26,.26)
                gc_setLineWidth(0.12)
                gc_circle('line',0,0,0.62)
                for _=0,3 do
                    gc_rotate(MATH.tau/4)
                    gc_line(0.4,0,0.942,0)
                end
                gc_pop()
            end

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
