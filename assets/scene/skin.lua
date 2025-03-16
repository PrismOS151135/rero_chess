---@type Zenitha.Scene
local scene = {}

local rnd = {
    rq1 = nil,
    rq2 = nil,
}
local page ---@type number
local maxPage ---@type number
local selected ---@type ReroChess.Skin.Select
local skinFace
local showFaceName
local showFaceNameList = {
    normal = "普通",
    forward = "前进",
    backward = "后退",
    selected = "被选中",
    jail = "坐牢",
}

local function selectOne(name)
    ---@class ReroChess.Skin.Select
    selected = {
        name = name,
        texture = TEX.chess[name],
        nameText = GC.newText(FONT.get(25), ChessData[name].name),
        descText = GC.newText(FONT.get(25)),
    }
    selected.descText:setf(ChessData[name].desc, 340, 'left')
    skinFace = 'normal'
    showFaceName = false
    scene.widgetList.equip:setVisible(name ~= DATA.skinuse)
    scene.widgetList.equipped:setVisible(name == DATA.skinuse)
end

local cacheData = {}
local function refreshPage()
    for i = 1, 12 do
        local B = scene.widgetList[i]
        if page ~= maxPage or i <= #DATA.skin % 12 then
            local name = DATA.skin[(page - 1) * 12 + i]
            cacheData[i] = {
                name = name,
                tileQuad = TABLE.getRandom(QUAD.world.tile),
                texture = TEX.chess[name],
                -- Apply for tile
                rndX = MATH.rand(-3, 3),
                rndY = MATH.rand(-3, 3),
                rndR = MATH.rand(-.02, .02),
                -- Apply for skin
                rndX2 = MATH.rand(-5, 5),
                rndY2 = MATH.rand(-5, 5),
            }
            B:setVisible(true)
        else
            B:setVisible(false)
        end
    end
end

function scene.load()
    rnd.rq1 = TABLE.getRandom(QUAD.world.tile)
    rnd.rq2 = TABLE.getRandom(QUAD.world.tile)
    page = 1
    maxPage = math.ceil(#DATA.skin / 12)
    selectOne(DATA.skinuse)
    refreshPage()
end

local gc = love.graphics
local gc_push, gc_pop = gc.push, gc.pop
local gc_translate, gc_scale = gc.translate, gc.scale
local gc_rotate, gc_shear = gc.rotate, gc.shear
local gc_setColor, gc_setLineWidth, gc_setLineJoin = gc.setColor, gc.setLineWidth, gc.setLineJoin
local gc_draw, gc_line = gc.draw, gc.line
local gc_rectangle, gc_circle, gc_polygon = gc.rectangle, gc.circle, gc.polygon
local gc_print, gc_printf = gc.print, gc.printf

function scene.draw()
    gc_setColor(COLOR.D)
    FONT.set(30)
    gc_print("棋子皮肤 ——查看棋子说明或使用，戳戳预览表情", 110, -5)

    gc_setColor(1, 1, 1)

    -- Big panel
    GC.ucs_move('m', 110, 30)
    GC.rDrawQ(TEX.world.default, rnd.rq1, 0, 0, 380, 540)
    GC.ucs_back()

    -- Skin preview
    GC.ucs_move('m', 750, 200)
    GC.mDraw(selected.texture.base)
    GC.mDraw(selected.texture[skinFace])
    if showFaceName then
        gc_setColor(COLOR.lD)
        gc_print(showFaceNameList[skinFace], 110, -110)
    end
    GC.ucs_back()

    -- Name & Desc
    GC.ucs_move('m', 560, 360)
    gc_setColor(1, 1, 1)
    gc_rectangle('fill', 10, 10, 360, 160)
    GC.rDrawQ(TEX.world.default, rnd.rq2, 0, 0, 380, 180)
    GC.strokeDraw('full', 2, selected.nameText, 25, 15)
    GC.strokeDraw('full', 2, selected.descText, 25, 55)
    gc_setLineWidth(6)
    gc_line(25 - 2, 50, 355 + 2, 50)
    gc_setColor(COLOR.D)
    gc_draw(selected.nameText, 25, 15)
    gc_draw(selected.descText, 25, 55)
    gc_setLineWidth(2)
    gc_line(25, 50, 355, 50)
    GC.ucs_back()
end

scene.widgetList = {}

local button_skin = WIDGET.newClass('button_skin', 'button')

function button_skin:draw()
    gc_push('transform')
    local cache = cacheData[tonumber(self.name)]
    gc_translate(self._x + cache.rndX, self._y + cache.rndY)
    gc_rotate(cache.rndR)
    gc_scale(1 - self._pressTime / self._pressTimeMax * .05 + self._hoverTime / self._hoverTimeMax * .05)
    gc_setColor(1, 1, 1)
    GC.mDrawQ(TEX.world.default, cache.tileQuad, 0, 0, 0, self.w / 256, self.h / 256)
    GC.mDraw(cache.texture.base, cache.rndX2, cache.rndY2, 0, .3)
    GC.mDraw(cache.texture.normal, cache.rndX2, cache.rndY2, 0, .3)
    gc_pop()
end

local id = 0
for y = -1.5, 1.5 do
    for x = -1, 1 do
        id = id + 1
        local cid = id
        table.insert(scene.widgetList, WIDGET.new {
            type = 'button_skin',
            name = tostring(cid),
            x = 300 + x * 110, y = 300 + y * 120, w = 100, h = 110,
            onClick = function()
                selectOne(cacheData[cid].name)
            end,
        })
    end
end

local faceSlide = { 'normal', 'forward', 'backward', 'selected', 'jail' }
table.insert(scene.widgetList, WIDGET.new {
    type = 'button_invis',
    x = 750, y = 200, w = 200, h = 260,
    onPress = function()
        skinFace = TABLE.next(faceSlide, skinFace, true)
        showFaceName = true
    end
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'button_simp', name = 'equip',
    x = 560 + 360 - 50, y = 360 + 160 - 15, w = 90, h = 50,
    text = "选择",
    cornerR = 5,
    lineWidth = 2,
    onClick = function()
        DATA.skinuse = selected.name
        DATA.save()
        selectOne(selected.name)
    end
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'text', name = 'equipped',
    x = 560 + 360 - 50, y = 360 + 160 - 15,
    text = "使用中",
})
table.insert(scene.widgetList, QuitButton)

return scene
