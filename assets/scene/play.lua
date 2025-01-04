---@type ReroChess.Game
local game

---@type Zenitha.Scene
local scene={}

function scene.load()
    BG.set('play')
    if SCN.args[1]=='newGame' then
        game=require'assets.game'.new{
            texturePack='default',
            playerData={
                {name='略',skin="一只略",color=COLOR.lY,startLocation='start1'},
                {name='关注',skin="关注娘",color=COLOR.lR,startLocation='start1'},
                {name='普通',skin="普通的棋子娘",color={COLOR.HEX'A0E0F0'},startLocation='start2'},
                {name='十七',skin="十七",color=COLOR.lO,startLocation='start2'},
                {name='？',skin="普通的熊猫人",color=COLOR.LP,startLocation='start3'},
                {name='鬼',skin="长相潦草的幽灵",color=COLOR.DL,startLocation='start3'},
            },
            mapData={
                {x=-3,y=-1.5,prop='label,start1'},
                {dx=1,prop='reverse'},
                {dx=1,prop='!step,2'},
                {dx=1,prop='!stop'},
                {dx=1,prop='move,2'},
                {dx=1},
                {dx=1,prop='teleport,start2'},

                {x=-2,y=0,prop='text,t label,start2'},
                {dx=1,prop='center move,1'},
                {dx=1,prop='label,start3'},
                {dy=1,prop='move,-3'},
                {dy=1,prop='move,2'},
                {dx=-1,prop='teleport,start1'},
                {dx=-1,prop='!reverse'},
                {dy=-1,prop='next,start2'},
            },
        }
    end
end

function scene.mouseDown(x,y,k)
    if k==1 then
        game:step()
    elseif k==2 then
        game:roll()
    end
end

function scene.mouseUp(x,y,k)
    if k==1 then
        CURSOR.set('pointer')
    end
end

function scene.touchDown(x,y,id)
    if not game:step() then
        game:roll()
    end
end

function scene.mouseMove(x,y,dx,dy)
    if love.mouse.isDown(1) then
        CURSOR.set('move')
        game.cam:move(dx,dy)
    end
end

function scene.wheelMove(dx,dy)
    game.cam:scale(1+dy*.1)
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
    GC.replaceTransform(SCR.xOy_m)
    game:draw()
end

scene.widgetList={
    QuitButton,
}
return scene
