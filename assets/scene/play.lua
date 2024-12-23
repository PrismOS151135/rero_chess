---@type ReroChess.Game
local game

---@type Zenitha.Scene
local scene={}

function scene.load()
    game=require'assets.game'.new{
        playerData={
            {name='Alice'},
            {name='Bob'},
        },
        mapData={
            {},{dx=1},{dx=1},{dx=1},{dx=1},
            {dy=1},
            {dx=-1,dy=.626},
            {dx=-1,dy=.626},
            {dx=-1,dy=.626},
            {dx=-1,dy=.626},
            {dy=1},
            {dx=1},{dx=1},{dx=1},{dx=1},
        },
    }
end

function scene.mouseDown(x,y,k)
end

function scene.mouseMove(x,y,dx,dy)
    if love.mouse.isDown(1) then
        game.cam:move(dx,dy)
    end
end

function scene.wheelMove(dx,dy)
    game.cam:scale(1+dy*.1)
end

function scene.keyDown(key,isRep)
end

function scene.update(dt)
    game:update(dt)
end

function scene.draw()
    GC.replaceTransform(SCR.xOy_m)
    game:draw()
end

scene.widgetList={
    WIDGET.new{type='button_simp',pos={1,1},x=-120,y=-80,w=160,h=80,sound_press='back',fontSize=60,text=CHAR.icon.back,code=WIDGET.c_backScn()},
}
return scene
