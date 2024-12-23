--------------------------------------------------------------
-- Setup lua & love2d

math.randomseed(os.time())

love.mouse.setVisible(false)

--------------------------------------------------------------
-- Setup Zenitha

require'Zenitha'

ZENITHA.setFirstScene('menu')
ZENITHA.setAppName(require'version'.appName)
ZENITHA.setMaxFPS(60)
ZENITHA.setShowFPS(false)

SCR.setSize(1000,600)

STRING.install()

local cursorWid=.8
local cursorPolygon={
    0*math.cos(0),0*math.sin(0),
    30*math.cos(0),0*math.sin(0),
    20*math.cos(cursorWid/2.1),20*math.sin(cursorWid/2.1),
    30*math.cos(cursorWid),30*math.sin(cursorWid),
}
function ZENITHA.globalEvent.drawCursor(x,y)
    GC.setColor(COLOR.L)
    GC.translate(x,y)
    GC.rotate(.6)
    GC.polygon('fill',cursorPolygon)
    GC.setColor(COLOR.D)
    GC.setLineWidth(3)
    GC.setLineJoin('bevel')
    GC.polygon('line',cursorPolygon)
end
function ZENITHA.globalEvent.clickFX(x,y)
    for i=1,3 do
        local a=-i-math.random()+.26
        local sr=MATH.rand(6,12)
        local er=MATH.rand(15,22)
        local sx,sy=x+sr*math.cos(a),y+sr*math.sin(a)
        local ex,ey=x+er*math.cos(a),y+er*math.sin(a)
        SYSFX.beam(0.16,sx,sy,ex,ey,4,0,0,0)
    end
end

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
