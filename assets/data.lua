local DATA={
    fumoDmg=0,
    fumoDieTime=false,
    skin={},
}

local _DATA={}
function _DATA:load()
    TABLE.update(self,FILE.load('data','-canskip') or NONE)
end
local function saver() DATA:save() end
function _DATA:save()
    TWEEN.tag_kill('tag_data_save')
    if TASK.lock('data_save',5) then
        FILE.save(self,'data')
    else
        TWEEN.new():setOnFinish(saver):setTag('tag_data_save'):run()
    end
end
function _DATA:getSkin(name)
    if not TABLE.find(self.skin,name) then
        table.insert(self.skin,name)
        SCN.go('get_new_skin','none',name)
        self:save()
    end
end

return setmetatable(DATA,{__index=_DATA})
