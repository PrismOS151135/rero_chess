---@enum (key) ReroChess.CellPropCmd
local cellEvent={

---@param P ReroChess.Player
step=function(P,dist)
    P:popText{
        text=("+%d"):format(dist),
        duration=2,
        x=0.4,
    }
    P.stepRemain=P.stepRemain+dist
end,

---@param P ReroChess.Player
move=function(P,dist)
    P:popText{
        text=("%+d"):format(dist),
        duration=2,
        x=0.4,
    }
    P.stepRemain=math.abs(dist)
    P.curDir=dist>0 and 'next' or 'prev'
    P.nextLocation,P.curDir=P.game:getNext(P.location,P.curDir)
end,

---@param P ReroChess.Player
teleport=function(P,target)
    P:popText{
        text="传送!",
        duration=2,
    }
    P.location=target
    P.x,P.y=P.game.map[P.location].x,P.game.map[P.location].y
    P.nextLocation,P.curDir=P.game:getNext(P.location,P.moveDir)
end,

---@param P ReroChess.Player
stop=function(P)
    if P.stepRemain>0 then
        P:popText{
            text="停止!",
            duration=2,
        }
        P.stepRemain=0
    end
end,

---@param P ReroChess.Player
reverse=function(P)
    P:popText{
        text="反转!",
        duration=2,
    }
    P.moveDir=P.moveDir=='next' and 'prev' or 'next'
    P.curDir=P.curDir=='next' and 'prev' or 'next'
end,

text=true,
}


return cellEvent
