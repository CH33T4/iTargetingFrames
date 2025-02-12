local _, iTF = ...
local templates = {}


templates['Health threshold, <50%'] = [[
function(unitID, data)
    if data.health <= 50 then
        return true
    end
end
]]
templates['Health threshold, <20% & <35%'] = [[
function(unitID, data) 
    if data.health <= 20 then
        return true, {1,1,1,1}
    elseif data.health <= 35 then
        return true
    end
end]]
templates['Magic buff'] = [[
function(unitID, data)
    for i = 1, 40 do
        if UnitBuff(unitID, i) then
            local _,_,_,_,buffType = UnitBuff(unitID, i)
            if buffType and buffType == 'Magic' then
                return true
            end
        else
            return
        end
    end
end
]]



function iTF:getCustomTemplate(id, list)
	if list then
		local t = {}
		for k,v in pairs(templates) do
			table.insert(t, k)
		end
		return t
	end
	return templates[id]
end
