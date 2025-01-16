---@type ReroChess.Game
local game

---@type Zenitha.Scene
local scene={}

function scene.load()
    BG.set('play')
    if SCN.args[1]=='newGame' then
        MSG('info',"（临时地图）左键走路右键掷骰 键盘回车空格 触屏随便点",5)
        game=require'assets.game'.new(FILE.load('assets/map/lue_first.luaon','-luaon',{TEX=TEX,QUAD=QUAD}))
    end
end

function scene.mouseMove(x,y,dx,dy)
    if love.mouse.isDown(1) then
        CURSOR.set('move')
        game.cam:move(dx,dy)
    end
end

function scene.wheelMove(dx,dy)
    game.cam:scale(1+MATH.sign(dy)*.1)
end

function scene.mouseUp(x,y,k)
    if k==1 then
        CURSOR.set('pointer')
    end
end

function scene.mouseClick(x,y,k)
    if game.selectedPlayer==false then
        -- Select player
        x,y=SCR.xOy:transformPoint(x,y)
        x,y=SCR.xOy_m:inverseTransformPoint(x,y)
        x,y=game.cam.transform:inverseTransformPoint(x,y)
        local pList=TABLE.copy(game.players,0)
        local closest
        for i=#pList,1,-1 do
            local p=pList[i]
            if p.canBeSelected and MATH.distance(p.x,p.y,x,y)<.42 then
                if closest then
                    game.cam.x0,game.cam.y0=p.x,p.y
                    game.cam:scale(2)
                    return
                else
                    closest=p
                end
            end
        end
        if closest then
            game.selectedPlayer=closest
        end
    else
        -- Normal
        if k==1 then
            game:step()
        elseif k==2 then
            game:roll()
        end
    end
end

function scene.touchMove(x,y,dx,dy,id)
    local touches=love.touch.getTouches()
    if #touches<=1 then
        game.cam:move(dx,dy)
    end
end

function scene.touchClick(x,y,id)
    if not game:step() then
        game:roll()
    end
end

function scene.keyDown(key,isRep)
    if isRep then return true end
    if key=='return' then
        game:roll()
    elseif key=='space' then
        game:step()
    elseif key=='escape' then
        SCN.go('quit_sure','none','back')
    end
    return true
end

function scene.update(dt)
    game:update(dt)
end

function scene.draw()
    game:draw()
end

scene.widgetList={
    QuitButton,
}
return scene
