--------------------------------------------------------------
-- Setup lua & love2d

math.randomseed(os.time())

love.mouse.setVisible(false)

--------------------------------------------------------------
-- Setup Zenitha

require'Zenitha'

ZENITHA.setFirstScene('menu')
ZENITHA.setAppName(require'version'.appName)
ZENITHA.setMainLoopSpeed(60)
ZENITHA.setShowFPS(false)

SCR.setSize(1000,600)

STRING.install()

local button_simp=WIDGET.newClass('button_simp','button')
function button_simp:draw()
    GC.push('transform')
    GC.translate(self._x,self._y)

    if self._pressTime>0 then
        GC.scale(1-self._pressTime/self._pressTimeMax*.0626)
    end
    local w,h=self.w,self.h

    -- Background
    GC.setColor(self.fillColor)
    GC.mRect('fill',0,0,w,h,self.cornerR)

    -- Highlight
    if self._hoverTime>0 then
        GC.setColor(1,1,1,.42*self._hoverTime/self._hoverTimeMax)
        GC.mRect('fill',0,0,w,h,self.cornerR)
    end

    -- Frame
    GC.setLineWidth(self.lineWidth)
    GC.setColor(self.frameColor)
    GC.mRect('line',0,0,w,h,self.cornerR)

    -- Drawable
    if self._image then
        GC.setColor(1,1,1)
        WIDGET._alignDraw(self,self._image)
    end
    if self._text then
        GC.setColor(self.textColor)
        WIDGET._alignDraw(self,self._text)
    end
    GC.pop()
end
WIDGET.setDefaultOption{
    base={
        color='D',
        textColor='D',
        fillColor='D',
        frameColor='D',
        activeColor='D',
        lineWidth=6,
        cornerR=4,
    },
    button={},
    button_simp={
        cornerR=10,
        lineWidth=4,
        fillColor='dL',
    },
    slider={
        frameColor='LD',
        fillColor='lD',
    },
    switch={},
    slider_fill={},
    checkBox={},
    selector={},
    listBox={},
    inputBox={},
}

do -- Image & Texture & Quad
    local path='assets/texture/'
    TEX=IMG.init({
        chess=(function()
            local t={}
            for _,meta in next,{
                {name="普通的棋子娘",shadeX=0.015},
                {name="一只略",shadeX=0},
                {name="十七",shadeX=0.02},
                {name="棠棠猫",shadeX=0.013},
                {name="关注娘",shadeX=0.013},
                {name="铅笔略",shadeX=0.013},
                {name="长相潦草的幽灵",shadeX=0.013},
                {name="普通的熊猫人",shadeX=0.013},
            } do
                t[meta.name]={
                    backward =("$1chess/$2/backward.png"):repD(path,meta.name),
                    base     =("$1chess/$2/base.png"    ):repD(path,meta.name),
                    forward  =("$1chess/$2/forward.png" ):repD(path,meta.name),
                    jail     =("$1chess/$2/jail.png"    ):repD(path,meta.name),
                    normal   =("$1chess/$2/normal.png"  ):repD(path,meta.name),
                    selected =("$1chess/$2/selected.png"):repD(path,meta.name),
                    shadeX=meta.shadeX,
                }
            end
            return t
        end)(),
        ui=path..'ui.png',
        doodle=path..'doodle.png',
        world={
            default=path..'world_default.png',
        },
        menu=GC.newArrayImage{
            path..'menu_anim_1.png',
            path..'menu_anim_2.png',
            path..'menu_anim_3.png',
            path..'menu_anim_4.png',
            path..'menu_anim_5.png',
            path..'menu_anim_6.png',
        },
    },true)

    NULL(TEX.world.default)

    -- Quad generator based on 128x128 grid
    local function q(x,y,w,h) return GC.newQuad(x*128,y*128,(w or 1)*128,(h or w or 1)*128,2048,2048) end
    QUAD={
        world={
            tile={---@type love.Quad[]
                q(0,0,2),
                q(0,2,2),
                q(0,4,2),
                q(0,6,2),
                q(0,8,2),
                q(0,10,2),
            },
            moveF    =q(2  ,0  ,0.5),
            moveB    =q(2  ,0.5,0.5),
            warn     =q(2.5,0  ,0.5),
            quetion  =q(2.5,0.5,0.5),
            hospital =q(3,0),
            exit     =q(2,1),
        },
        doodle={
            smile     =q(0,0),
            what      =q(1,0),
            explosion =q(2,0),
            grass     =q(3,0),
            flower    =q(4,0),
            otto      =q(5,0),
            drool     =q(6,0),
            long_tu   =q(7,0),
            ant       =q(8,0),
            cat       =q(9,0),
            poop      =q(10,0),
            cry       =q(11,0),
            heart     =q(12,0),
            happy     =q(13,0),
            banana    =q(14,0),
            -- _      =crop128(15,0),
            -- _      =crop128(0,1),
        },
    }
end

FONT.load{
    norm='assets/fonts/codePixelCJK-Regular.ttf',
    symbol='assets/fonts/symbols.otf',
}
FONT.setDefaultFont('norm')
FONT.setDefaultFallback('symbol')

SCN.addSwapStyle('swipe',{
    duration=.5,timeChange=.25,
    draw=function(t)
        t=t*2
        GC.setColor(COLOR.LI)
        GC.setAlpha(1-math.abs(t-.5))
        t=t*t*(2*t-3)*2+1
        GC.rectangle('fill',0,t*SCR.h,SCR.w,SCR.h)
    end,
})
SCN.setDefaultSwap('swipe')

LANG.add{zh="assets/text_zh.lua"}
LANG.setDefault('zh')


--------------------------------------------------------------
--- Setup Project & Load Assets

---@type ReroChess.I18N
Texts=LANG.set('zh')

CHAR=require'assets.char'
CURSOR=require'assets.cursor'

for _,v in next,love.filesystem.getDirectoryItems('assets/background') do
    if FILE.isSafe('assets/background/'..v) and v:sub(-3)=='lua' then
        local name=v:sub(1,-5)
        BG.add(name,FILE.load('assets/background/'..v,'-lua'))
    end
end

for _,v in next,love.filesystem.getDirectoryItems('assets/scene') do
    if FILE.isSafe('assets/scene/'..v) then
        local sceneName=v:sub(1,-5)
        SCN.add(sceneName,FILE.load('assets/scene/'..v,'-lua'))
    end
end
