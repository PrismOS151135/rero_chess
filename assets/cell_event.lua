local cellEvent={}

---@param P ReroChess.Player
function cellEvent.move(P,dist)
    P:popText{
        text=("%+d"):format(dist),
        duration=2,
        x=0.4,
    }
    P.stepRemain=P.stepRemain+math.abs(dist)
    P.curDir=dist>0 and 'next' or 'prev'
    P.nextLocation,P.curDir=P.game:getNext(P.location,P.curDir)
end

---@param P ReroChess.Player
function cellEvent.teleport(P,target)
    P:popText{
        text="传送!",
        duration=2,
    }
    P.location=target
    P.x,P.y=P.game.map[P.location].x,P.game.map[P.location].y
    P.nextLocation,P.curDir=P.game:getNext(P.location,P.moveDir)
end

---@param P ReroChess.Player
function cellEvent.stop(P)
    P:popText{
        text="停止!",
        duration=2,
    }
    P.stepRemain=0
end

return cellEvent
