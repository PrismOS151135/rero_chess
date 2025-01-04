local DATA={
    fumoHealth=100,
}

local function _load(t)
    TABLE.update(t,FILE.load('data','-canskip') or NONE)
end
local function _save(t)
    FILE.save(t,'data')
end

return setmetatable(DATA,{
    __index=function(t,k)
        if k=='_load' then
            return _load
        elseif k=='_save' then
            return _save
        else
            error("Attempt to access invalid data key '"..tostring(k).."'",2)
        end
    end
})
