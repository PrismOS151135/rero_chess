local DATA = {
    regTime = os.time(),
    fumoDmg = 0,
    fumoDieTime = false,
    skin = { '普通的棋子娘', '一只略' },
    skinuse = '普通的棋子娘',
    doodle = { '微笑', '哇噻', '小草', '小花', '流泪', '爱心', '开心' },
    doodleEquip = { '微笑', '开心', '小草', '小花', '流泪' },
}

local _DATA = {}
function _DATA.load()
    TABLE.update(DATA, FILE.load('data', '-canskip') or NONE)
end

local function saver() DATA.save(true) end
function _DATA.save(silent)
    if not TASK.lock('data_save_fastLock', .0626) then return end
    TWEEN.tag_kill('tag_data_save')
    if TASK.lock('data_save', 5) then
        if not silent then
            TEXT:add { text = CHAR.icon.save, x = SCR.w0 - 10, y = SCR.h0 + 5, color = 'D', align = 'bottomright', a = .0626, duration = .62 }
        end
        FILE.save(DATA, 'data')
    else
        TWEEN.new():setOnFinish(saver):setTag('tag_data_save'):run()
    end
end

function _DATA.getSkin(name)
    if not TABLE.find(DATA.skin, name) then
        table.insert(DATA.skin, name)
        table.sort(DATA.skin, function(a, b)
            return ChessData[a].id < ChessData[b].id
        end)
        SCN.go('get_new_skin', 'none', name)
        DATA.save()
    end
end

return setmetatable(DATA, { __index = _DATA })
