---@class ReroChess.CellEvent
local Prop={}

Prop.label={
    tag=true,
    parse=function(prop)
        assert(
            type(prop[2])=='string',
            'label[1] must be string'
        )
    end,
}
Prop.next={
    tag=true,
    parse=function(prop)
        for i=2,#prop do
            prop[i]=tonumber(prop[i]) or prop[i]
            assert(
                type(prop[i])=='string' or
                type(prop[i])=='number' and prop[i]%1==0 and prop[i]>0,
                'next[*] must be positive integer'
            )
        end
    end,
}
Prop.center={
    tag=true,
}



Prop.text={
    tag=true,
    parse=function(prop)
        assert(
            type(prop[2])=='string',
            'text[1] must be string'
        )
    end,
}



Prop.step={
    parse=function(prop)
        prop[2]=tonumber(prop[2])
        assert(
            type(prop[2])=='number' and prop[2]%1==0 and prop[2]>0,
            'step[1] must be positive integer'
        )
    end,
    ---@param P ReroChess.Player
    code=function(P,dist)
        P:popText{
            text=("+%d"):format(dist),
            duration=2,
            x=0.4,
        }
        P.stepRemain=P.stepRemain+dist
        P.face='forward'
    end,
}

Prop.move={
    parse=function(prop)
        prop[2]=tonumber(prop[2])
        assert(
            type(prop[2])=='number' and prop[2]%1==0,
            'move[1] must be integer'
        )
    end,
    ---@param P ReroChess.Player
    code=function(P,dist)
        P:popText{
            text=("%+d"):format(dist),
            duration=2,
            x=0.4,
        }
        P.stepRemain=math.abs(dist)
        P.curDir=dist>0 and 'next' or 'prev'
        P.nextLocation,P.curDir=P.game:getNext(P.location,P.curDir)
        P.face=P.curDir==P.moveDir and 'forward' or 'backward'
    end,
}

Prop.teleport={
    parse=function(prop)
        prop[2]=tonumber(prop[2]) or prop[2]
        assert(
            type(prop[2])=='string' or
            type(prop[2])=='number' and prop[2]%1==0,
            'teleport[1] must be integer or string'
        )
    end,
    ---@param P ReroChess.Player
    code=function(P,target)
        P:popText{
            text="传送!",
            duration=2,
        }
        P.location=target
        P.x,P.y=P.game.map[P.location].x,P.game.map[P.location].y
        P.nextLocation,P.curDir=P.game:getNext(P.location,P.moveDir)
        P.face='jail'
    end,
}

Prop.stop={
    ---@param P ReroChess.Player
    code=function(P)
        if P.stepRemain>0 then
            P:popText{
                text="停止!",
                duration=2,
            }
            P.stepRemain=0
        end
    end,
}

Prop.reverse={
    ---@param P ReroChess.Player
    code=function(P)
        P:popText{
            text="反转!",
            duration=2,
        }
        P.moveDir=P.moveDir=='next' and 'prev' or 'next'
        P.curDir=P.curDir=='next' and 'prev' or 'next'
        P.nextLocation,P.curDir=P.game:getNext(P.location,P.curDir)
        P.face='backward'
    end,
}

local modifiers={
    ['+']=true,
    ['-']=true,
    ['*']=true,
    ['/']=true,
    ['^']=true,
    ['&']=true,
}
Prop.diceMod={
    parse=function(prop)
        prop[3]=tonumber(prop[3])
        assert(
            modifiers[prop[2]] and
            type(prop[3])=='number',
            'diceMod[1] must be operator and diceMod[2] must be number'
        )
    end,
    ---@param P ReroChess.Player
    code=function(P,op,num)
        P:popText{
            text=("下一次点数%s%d"):format(op,num),
            duration=2,
        }
        table.insert(P.diceMod,{op,num})
    end,
}

Prop.exTurn={
    parse=function(prop)
        if prop[2]==nil then prop[2]=1 end
        prop[2]=tonumber(prop[2])
        assert(
            type(prop[2])=='number' and prop[2]%1==0 and prop[2]~=0,
            'exTurn[1] must be non-zero integer'
        )
    end,
    ---@param P ReroChess.Player
    code=function(P,cnt)
        P:popText{
            text=cnt>0 and "额外回合!" or "跳过回合!",
            duration=2,
        }
        P.extraTurn=P.extraTurn+cnt
    end,
}

return Prop
