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
        if prop[3]==nil then prop[3]='@self' end
        assert(
            PlayerRef[prop[3]],
            'move[3] must be @str'
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
        if prop[3]==nil then prop[3]='@self' end
        assert(
            PlayerRef[prop[3]],
            'teleport[3] must be @str'
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
            text=("下次点数%s%d"):format(op,num),
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

Prop.swap={
    parse=function(prop)
        assert(
            PlayerRef[prop[2]],
            'swap[2] must be @str'
        )
        if prop[3]==nil then prop[3]='@self' end
        assert(
            PlayerRef[prop[3]],
            'swap[3] must be @str'
        )
    end,
    ---@param P1 ReroChess.Player
    ---@param P2 ReroChess.Player
    code=function(P1,P2)
        P1.x,P2.x=P2.x,P1.x
        P1.y,P2.y=P2.y,P1.y
        P1.location,P2.location=P2.location,P1.location
        P1.moveDir,P2.moveDir=P2.moveDir,P1.moveDir
        P1.faceDir,P2.faceDir=P2.faceDir,P1.faceDir
    end,
}

Prop.exit={
    parse=function(prop)
        assert(
            PlayerRef[prop[2]],
            'exit[1] must be @str'
        )
        assert(
            type(prop[3])=='string',
            'exit[2] must be integer'
        )
        assert(
            type(prop[4])=='string',
            'exit[3] must be @str'
        )
    end,
    ---@param P ReroChess.Player
    code=function(P,player,exitId,target)
        -- TODO
    end,
}

return Prop
