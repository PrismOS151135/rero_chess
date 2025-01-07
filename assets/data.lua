local _DATA={}
function _DATA:load()
    TABLE.update(self,FILE.load('data','-canskip') or NONE)
end
function _DATA:save()
    FILE.save(self,'data')
end
function _DATA:getSkin(name)
    if not TABLE.find(self.skin,name) then
        table.insert(self.skin,name)
        SCN.go('get_new_skin','none',name)
        self:save()
    end
end

local DATA={
    fumoDmg=0,
    fumoDieTime=false,
    skin={},
}

return setmetatable(DATA,{__index=_DATA})
