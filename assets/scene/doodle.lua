---@type Zenitha.Scene
local scene = {}

local rnd = {
    rq1 = nil,
    rq2 = nil,
}
local page ---@type number
local maxPage ---@type number
local doodleSel ---@type false | table

local function selectOne(name)
    if name then
        doodleSel = {
            nameText = GC.newText(FONT.get(25), DoodleData[name].name),
            descText = GC.newText(FONT.get(25)),
        }
        doodleSel.descText:setf(DoodleData[name].desc, 340, 'left')
    else
        doodleSel = false
    end
end

local cacheData = {}
local function refreshPage()
    for i = 1, 12 do
        local B = scene.widgetList[i]
        if page ~= maxPage or i <= #DATA.doodle % 12 then
            local name = DATA.doodle[(page - 1) * 12 + i]
            cacheData[i] = {
                name = name,
                tileQuad = TABLE.getRandom(QUAD.world.tile),
                doodleQuad = QUAD.doodle[name],
                -- Apply for tile
                rndX = MATH.rand(-3, 3),
                rndY = MATH.rand(-3, 3),
                rndR = MATH.rand(-.02, .02),
            }
            B:setVisible(true)
        else
            B:setVisible(false)
        end
    end
    scene.widgetList.prevPage:setVisible(page > 1)
    scene.widgetList.nextPage:setVisible(page < maxPage)
end

function scene.load()
    rnd.rq1 = TABLE.getRandom(QUAD.world.tile)
    rnd.rq2 = TABLE.getRandom(QUAD.world.tile)
    page = 1
    maxPage = math.ceil(#DATA.doodle / 12)
    selectOne()
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
    gc_print("涂鸦 ——查看涂鸦说明或装备", 110, 5)

    gc_setColor(1, 1, 1)

    -- Big panel
    GC.ucs_move('m', 110, 30)
    GC.rDrawQ(TEX.world.default, rnd.rq1, 0, 10, 390, 560)
    GC.ucs_back()

    -- Skin preview
    GC.ucs_move('m', 750, 180)
    GC.mDrawQ(TEX.ui, QUAD.ui.doodle.equipped, 0, 0, 0, 1.3)
    for i = 1, 5 do
        local D = DATA.doodleEquip[i]
        if D then
            local a = -1.62 + MATH.tau / 5 * (i - 1)
            GC.mDrawQ(TEX.doodle, QUAD.doodle[D], 100 * math.cos(a), 100 * math.sin(a), 0, .5)
        end
    end
    GC.ucs_back()

    -- Name & Desc
    GC.ucs_move('m', 560, 360)
    gc_rectangle('fill', 10, 10, 360, 160)
    GC.rDrawQ(TEX.world.default, rnd.rq2, 0, 0, 380, 180)
    if doodleSel then
        gc_setLineWidth(6)
        gc_line(25 - 2, 50, 355 + 2, 50)
        GC.strokeDraw('full', 2, doodleSel.nameText, 25, 15)
        GC.strokeDraw('full', 2, doodleSel.descText, 25, 55)
        gc_setColor(COLOR.D)
        gc_draw(doodleSel.nameText, 25, 15)
        gc_draw(doodleSel.descText, 25, 55)
        gc_setLineWidth(2)
        gc_line(25, 50, 355, 50)
    end
    GC.ucs_back()
end

scene.widgetList = {}

local button_doodle = WIDGET.newClass('button_doodle', 'button')

function button_doodle:draw()
    gc_push('transform')
    local cache = cacheData[tonumber(self.name)]
    gc_translate(self._x + cache.rndX, self._y + cache.rndY)
    gc_rotate(cache.rndR)
    gc_scale(1 - self._pressTime / self._pressTimeMax * .05 + self._hoverTime / self._hoverTimeMax * .05)
    gc_setColor(1, 1, 1)
    GC.mDrawQ(TEX.world.default, cache.tileQuad, 0, 0, 0, self.w / 256, self.h / 256)
    GC.mDrawQ(TEX.doodle, cache.doodleQuad, 0, 0, 0, .5)
    gc_pop()
end

local id = 0
for y = -1.5, 1.5 do
    for x = -1, 1 do
        id = id + 1
        local cid = id
        table.insert(scene.widgetList, WIDGET.new {
            type = 'button_doodle',
            name = tostring(cid),
            x = 300 + x * 110, y = 300 + y * 115, w = 100, h = 105,
            onClick = function()
                selectOne(cacheData[cid].name)
            end,
        })
    end
end

table.insert(scene.widgetList, WIDGET.new {
    type = 'button_tile', name = 'prevPage',
    x = 300 - 110, y = 560,
    w = 70, h = 40, lineWidth = 2,
    text = "←",
    onClick = function()
        page = page - 1
        refreshPage()
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'button_tile', name = 'nextPage',
    x = 300 + 110, y = 560,
    w = 70, h = 40, lineWidth = 2,
    text = "→",
    onClick = function()
        page = page + 1
        refreshPage()
    end,
})

table.insert(scene.widgetList, QuitButton)

return scene
