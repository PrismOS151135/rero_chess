local DATA={
    fumoDmg=0,
    fumoDieTime=false,
    skin={},
}

local _DATA={}
function _DATA.load()
    TABLE.update(DATA,FILE.load('data','-canskip') or NONE)
end
local function saver() DATA.save() end
function _DATA.save()
    if not TASK.lock('data_save_fastLock',.0626) then return end
    TWEEN.tag_kill('tag_data_save')
    if TASK.lock('data_save',5) then
        FILE.save(DATA,'data')
    else
        TWEEN.new():setOnFinish(saver):setTag('tag_data_save'):run()
    end
end
function _DATA.getSkin(name)
    if not TABLE.find(DATA.skin,name) then
        table.insert(DATA.skin,name)
        SCN.go('get_new_skin','none',name)
        DATA.save()
    end
end

return setmetatable(DATA,{__index=_DATA})
