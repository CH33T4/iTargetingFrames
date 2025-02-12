local _, iTF = ...
local L = LibStub('AceLocale-3.0'):GetLocale('iTargetingFrames', true)
LibStub('LibSharedMedia-3.0'):Register('statusbar', 'White 8x8', 'Interface\\Buttons\\WHITE8x8')
function iTF:LoadDefaults(force)
	if not iTFConfig.bindings then --first run
		iTFConfig.bindings = {
			['general'] = {
				['LeftButton'] = {
					['type'] = 'target',
				},
			},
		}
	end
	if not iTFConfig.custom then
		iTFConfig.custom = {}
	end
	if not iTFConfig.blacklist then -- first run
		iTFConfig.blacklist = {}
	end
	if not iTFConfig.priorityNPCs then
		iTFConfig.priorityNPCs = {}
	end
	local defaults = iTF:GetProfile()
	if force then
		if iTFConfig.frame then
			iTFConfig = nil
			iTFConfig = {}
		end
		iTFConfig.layout = defaults
		iTF:updateFrames('conditionals')
	elseif not iTFConfig.layout then
		if not iTFConfig.layout then
			iTFConfig.layout = {}
		end
		for k,v in pairs(defaults) do
			if iTFConfig.layout[k] == nil then
				iTFConfig.layout[k] = v
			elseif type(v) == 'table' then
				for deeperKey, deeperValue in pairs(v) do
					if iTFConfig.layout[k][deeperKey] == nil then
						iTFConfig.layout[k][deeperKey] = deeperValue
					elseif type(deeperValue) == 'table' then
						for inceptionLevelKey, inceptionLevelValue in pairs(deeperValue) do
							if iTFConfig.layout[k][deeperKey][inceptionLevelKey] == nil then
								iTFConfig.layout[k][deeperKey][inceptionLevelKey] = inceptionLevelValue
							elseif type(inceptionLevelValue) == 'table' then
								for wtfKey, wtfValue in pairs(inceptionLevelValue) do
									if wtfKey == 'color' then --Don't override indicators, indicators and colors should be only one this deep
										if iTFConfig.layout[k][deeperKey][inceptionLevelKey][wtfKey] == nil then
											iTFConfig.layout[k][deeperKey][inceptionLevelKey][wtfKey] = wtfValue
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if iTFConfig.frame then
		iTF:print('WTF layout has changed, use "/itf reset" to delete old settings and reset to defaults')
	end
	-- load refresh blacklist
	local temp = {}
	for k,v in pairs(iTF.auraBlacklist) do
		temp[k] = v
	end
	for k,v in pairs(iTFConfig.blacklist) do --replace defaults with user list
		temp[k] = v
	end
	iTFConfig.blacklist = temp
	local npcTemp = {}
	for k,v in pairs(iTF.priorityNPCs) do
		npcTemp[k] = v
	end
	for k,v in pairs(iTFConfig.priorityNPCs) do --replace defaults with user list
		npcTemp[k] = v
	end
	iTFConfig.priorityNPCs = npcTemp
end
local function loadProfile(profile)
	if profile == 'default' then
		iTF:LoadDefaults(true)
	end
end
local optionFuncs = {}

local function MainFrameBG(show)
	if show then
		iTF.mainFrame.tex:Show()
		iTF.show = true
	else
		iTF.mainFrame.tex:Hide()
		iTF.show = nil
	end
end
local profileListing = {}

local function spairs(t, order)
    -- collect the keys
    local keys = {}

    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
local bindings = {}
local customCondTemp = {
	['name'] = '',
	['weight'] = 90,
	['indicators'] = {
		['border'] = true,
	},
	['enable'] = true,
	['update'] = 'onUpdate',
	['color'] = {
		0,
		1,
		0,
		0.6,
	},
	['func'] = "function(unitID)\n  if stuff then\n    return true\n  end\nend",
	['loadFor'] = {},	
}
local isCustomOK = {
	['name'] = false,
	['func'] = false,
}
local bindingStuff = {
	type = 1,
	key = L.clickMe,
	text = '',
}
local priorityNPCsStuff = {
	['text'] = '',
	['comment'] = '',
}
function optionFuncs.getBindings(name)
	local args = {
		type = {
			name = L.bindingType,
			order = 1,
			type = 'select',
			values = {L.spell, L.macro, L.target, L.focus, L.raidIcon .. ': |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t', L.raidIcon .. ': |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t', L.raidIcon .. ': |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:0|t', L.raidIcon .. ' |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t', L.raidIcon .. ': |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t', L.raidIcon .. ': |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t', L.raidIcon .. ': |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t', L.raidIcon .. ': |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t', L.raidIcon .. ': ' .. L.clear},
			get = function() return bindingStuff.type end,
			set = function(val)
				bindingStuff.type = val
			end,
		},
		binding = {
			name = L.key,
			type = 'keybinding',
			order = 2,
			set = function(val)
				bindingStuff.key = tostring(val)
			end,
			get = function()
				return bindingStuff.key
			end,
		},

		text = {
			name = L.text,
			order = 5,
			type = 'input',
			set = function(val)
				bindingStuff.text = val
			end,
			onCharUpdate = true,
			get = function() 
				return bindingStuff.text
			end,
		},
		addNew = {
			name = L.addNew,
			order = 6,
			type = 'button',
			updateOnClick = true,
			func = function()
				if bindingStuff.key and bindingStuff.key ~= L.clickMe then
					local binding = {}
					if bindingStuff.type == 1 then
						binding.type = 'spell'
						if bindingStuff.text and bindingStuff.text:len() >= 2 then
							binding.text = bindingStuff.text
						else
							iTF:print(L.errorTextMissing)
							return
						end
					elseif bindingStuff.type == 3 then
						binding.type = 'target'
					elseif bindingStuff.type == 4 then
						binding.type = 'focus'
					else
						binding.type = 'macro'
						if bindingStuff.type == 13 then
							binding.text = [[/script SetRaidTarget('mouseover', 0)]]
						elseif bindingStuff.type >= 5 then
							binding.text = string.format([[/script SetRaidTarget('mouseover', %s)]], bindingStuff.type-4)
						else
							if bindingStuff.text and bindingStuff.text:len() >= 2 then
								binding.text = bindingStuff.text
							else
								iTF:print(L.errorTextMissing)
							end							
						end
					end
					if name == 'class' then
						iTFConfig.bindings[iTF.class].b[bindingStuff.key] = binding
						iTF:updateFrames('bindings')
					elseif name == 'spec' then
						iTFConfig.bindings[iTF.class][iTF.specID][bindingStuff.key] = binding
						iTF:updateFrames('bindings')
					elseif name == 'general' then
						iTFConfig.bindings.general[bindingStuff.key] = binding
						iTF:updateFrames('bindings')
					end
					bindingStuff = {
						type = 1,
						key = L.clickMe,
						text = '',
					}
					return true
				else
					iTF:print(L.bindingAddNewError)
				end
			end,
		},
	}
	return args
end
function optionFuncs.getValues(get)
	if get == 'all' then
		return {['TOPLEFT'] = L.topLeft, ['TOPRIGHT'] = L.topRight, ['TOP'] = L.top, ['LEFT'] = L.left, ['CENTER'] = L.center, ['RIGHT'] = L.right, ['BOTTOMRIGHT'] = L.bottomRight, ['BOTTOMLEFT'] = L.bottomLeft, ['BOTTOM'] = L.bottom}
	elseif get == 'grow' then
		return {['LEFT'] = L.right, ['RIGHT'] = L.left, ['TOP'] = L.bottom, ['BOTTOM'] = L.top}
	elseif get == 'ind' then
		return {['glowLeft'] = L.glowLeft, ['glowRight'] = L.glowRight, ['glowTop'] = L.glowTop, ['glowBottom'] = L.glowBottom, ['border'] = L.border, ['statusbar'] = L.healthBar, ['alpha'] = L.opacity}
	elseif get == 'growTo' then
		return {['TOPRIGHT'] = L.downLeft, ['TOPLEFT'] = L.downRight, ['BOTTOMRIGHT'] = L.upLeft, ['BOTTOMLEFT'] = L.upRight}
	elseif get == 'textFlags' then
		return {['NONE'] = L.none,['OUTLINE'] = L.outline, ['THICKOUTLINE'] = L.thickOutline, ['MONOCHROME'] = L.monochrome, ['MONOCHROME, OUTLINE'] = L.monochrome .. ' & ' .. L.outline,
		['MONOCHROME, THICKOUTLINE'] = L.monochrome .. ' & ' .. L.thickOutline}
	elseif get == 'sorting' then
		return {['truetrue'] = L.timeAndAscending, ['truefalse'] = L.timeAndDescending, ['falsetrue'] = L.nameAndAscending, ['falsefalse'] = L.nameAndDescending}
	--[[elseif get == 'allSpecs' then
		local t = {}
		for classID = 1, 12 do
			--local className = GetClassInfo(classID)
			t[className] = {}
			for i = 1, GetNumSpecializationsForClassID(classID) do
				local id,name = GetSpecializationInfoForClassID(classID, i)
				t[className][id] = name
			end
		end
		return t]]
	end
end
function optionFuncs.getProfiles()
	profileListing = iTF:GetProfileList()
	return iTF:GetProfileList()
end
function optionFuncs.getIndicatorArgs(indicator, role, customCond)
	local t = {}
	if indicator == 'AddCustom' then
		t.name = {
			name = L.name,
			order = 1,
			type = 'input',
			onCharUpdate = true,
			set = function(val)
				if not iTFConfig.custom[val] then
					if val:len()>0 then
						customCondTemp.name = val
						isCustomOK.name = true
					end
				else
					iTF:print(L.errorNameInUse)
				end
			end,
			get = function() return customCondTemp.name end,
		}
		t.updateType = {
			name = 'Update on',
			desc = 'When to update',
			order = 2,
			type = 'select',
			values = {['onUpdate'] = 'onUpdate (0.2sec)',  ['onHealth'] = 'Health update', ['onCast'] = 'Event: Cast/Channel start/stop', ['onAura'] = 'Event: UNIT_AURA', ['onShow'] = 'On show'},
			set = function(val)
				customCondTemp.update = val
			end,
			get = function() return customCondTemp.update end,
		}
		t.indicator = {
			name = L.indicators,
			type = 'select',
			multiselect = true,
			order = 3,
			values = optionFuncs.getValues('ind'),
			set = function(k,v)
				if v then
					customCondTemp.indicators[k] = v
				else
					customCondTemp.indicators[k] = nil
				end								
			end,
			get = function(k) return customCondTemp.indicators[k] end,
		}
		t.weight = {
			name = L.weight,
			type = 'slider',
			order = 4,
			min = 1,
			max = 100,
			step = 1,
			set = function(val)
				customCondTemp.weight = val
			end,
			get = function() return customCondTemp.weight end
		}
		t.color = {
			name = L.color,
			type = 'color',
			order = 4,
			hasAlpha = true,
			set = function(r,g,b,a)
				customCondTemp.color = {r,g,b,a}
			end,
			get = function()
				return unpack(customCondTemp.color or {1,1,1,1})
			end,
		}
		t.alpha = {
			name = L.frameOpacity,
			type = 'slider',
			order = 5,
			min = 0,
			max = 100,
			step = 1,
			set = function(val)
				customCondTemp.alpha = min(val/100, 1)
			end,
			get = function() return (customCondTemp.alpha or 1)*100 end
		}
		t.loadTemplate = {
			name = L.loadTemplate,
			type = 'select',
			order = 6,
			updateOnClick = true,
			invertValue = true,
			loadTemplate = true,
			values = iTF:getCustomTemplate(nil, true),
			set = function(val, t)
				customCondTemp.func = iTF:getCustomTemplate(t.arg1)
			end,
			get = function()
				return '' -- too lazy to filter this shit out
			end,
		}
		t.loadFor = {
			name = L.loadFor,
			type = 'select',
			order = 7,
			invertValue = true,
			multiselect = true,
			loadConds = true,
			values = optionFuncs.getValues('allSpecs'),
			set = function(k,v)
				if v then
					customCondTemp.loadFor[k] = v
				else
					customCondTemp.loadFor[k] = nil
				end
			end,
			get = function(k) 
				if customCondTemp.loadFor then
					return customCondTemp.loadFor[k]
				else
					return nil
				end
			end,
		}
		t.editbox = {
			name = L.func,
			type = 'input',
			order = 8,
			size = 'huge',
			code = true,
			set = function(val) 
				customCondTemp.func = val
			end,
			get = function() return customCondTemp.func end,
		}
		t.addNew = {
			name = L.addNew,
			order = 9,
			type = 'button',
			updateOnClick = true,
			refreshTree = true,
			func = function()
				if isCustomOK.name and isCustomOK.func then
					iTFConfig.custom[customCondTemp.name] = customCondTemp
					iTFConfig.custom[customCondTemp.name].name = nil
					customCondTemp = {
						['name'] = '',
						['weight'] = 90,
						['indicators'] = {
							['border'] = true,
						},
						['enable'] = true,
						['update'] = 'onUpdate',
						['color'] = {
							0,
							1,
							0,
							0.6,
						},
						['func'] = "function(unitID)\n  if stuff then\n    return true\n  end\nend",
					}
					isCustomOK = {
						['name'] = false,
						['func'] = false,
					}
					iTF:updateFrames('conditionals')
					return true
				else
					iTF:print(L.errorCustomConditional)
				end
			end,
		}
	elseif customCond then
		t.enable = {
			name = L.enable,
			order = 1,
			type = 'toggle',
			set = function(val) 
				iTFConfig.custom[indicator].enable = val 
				iTF:updateFrames('conditionals')
			end,
			get = function() return iTFConfig.custom[indicator].enable end,
		}
		t.updateType = {
			name = 'Update on',
			desc = 'When to update',
			order = 2,
			type = 'select',
			--values = {['onUpdate'] = 'onUpdate (0.2sec)', ['onAura'] = 'Event: UNIT_AURA', ['onCastStart'] = 'Event: Cast/Channel start', ['onHealth'] = 'Health update', ['targetChanged'] = 'Player target changed', ['threatUpdate'] = 'Threat update'},
			values = {['onUpdate'] = 'onUpdate (0.2sec)',  ['onHealth'] = 'Health update', ['onCast'] = 'Event: Cast/Channel start/stop', ['onAura'] = 'Event: UNIT_AURA', ['onShow'] = 'On show'},
			set = function(val)
				iTFConfig.custom[indicator].update = val
				iTF:updateFrames('conditionals')
			end,
			get = function() return iTFConfig.custom[indicator].update end,
		}
		t.weight = {
			name = L.weight,
			type = 'slider',
			order = 2,
			min = 1,
			max = 100,
			step = 1,
			set = function(val)
				iTFConfig.custom[indicator].weight = val
				iTF:updateFrames('conditionals')
			end,
			get = function() return iTFConfig.custom[indicator].weight end
		}
		t.indicator = {
			name = L.indicators,
			type = 'select',
			multiselect = true,
			order = 3,
			values = optionFuncs.getValues('ind'),
			set = function(k,v)
				if v then
					iTFConfig.custom[indicator].indicators[k] = v
				else
					iTFConfig.custom[indicator].indicators[k] = nil
				end
				iTF:updateFrames('conditionals')
			end,
			get = function(k) return iTFConfig.custom[indicator].indicators[k] end,
		}
		t.color = {
			name = L.color,
			type = 'color',
			order = 4,
			hasAlpha = true,
			set = function(r,g,b,a)
				iTFConfig.custom[indicator].color = {r,g,b,a}
				iTF:updateFrames('conditionals')
			end,
			get = function()
				return unpack(iTFConfig.custom[indicator].color or {1,1,1,1})
			end,
		}
		t.alpha = {
			name = L.frameOpacity,
			type = 'slider',
			order = 5,
			min = 0,
			max = 100,
			step = 1,
			set = function(val)
				iTFConfig.custom[indicator].alpha = min(val/100, 1)
				iTF:updateFrames('conditionals')
			end,
			get = function() return (iTFConfig.custom[indicator].alpha or 1)*100 end
		}
		t.loadFor = {
			name = L.loadFor,
			type = 'select',
			order = 6,
			invertValue = true,
			multiselect = true,
			loadConds = true,
			values = optionFuncs.getValues('allSpecs'),
			set = function(k,v)
				if not iTFConfig.custom[indicator].loadFor then
					iTFConfig.custom[indicator].loadFor = {}
				end
				if v then
					iTFConfig.custom[indicator].loadFor[k] = v
				else
					iTFConfig.custom[indicator].loadFor[k] = nil
				end
				iTF:updateFrames('conditionals')
			end,
			get = function(k) 
				if iTFConfig.custom[indicator].loadFor then
					return iTFConfig.custom[indicator].loadFor[k] 
				else
					return nil
				end
			end,
		}
		t.editbox = {
			name = L.func,
			type = 'input',
			order = 7,
			size = 'huge',
			code = true,
			edit = true,
			set = function(val) 
				iTFConfig.custom[indicator].func = val
				iTF:updateFrames('conditionals')
			end,
			get = function() return iTFConfig.custom[indicator].func end,
		}
		t.delete = {
			name = L.delete,
			order = 8,
			type = 'button',
			updateOnClick = true,
			refreshTree = true,
			func = function()
				iTFConfig.custom[indicator] = nil
				iTF:updateFrames('conditionals')
				return true
			end,
		}
	else
		t.enable = {
			name = L.enable,
			order = 1,
			type = 'toggle',
			set = function(val) 
				iTFConfig.layout.conditionals[indicator].enable = val 
				iTF:updateFrames('conditionals')
			end,
			get = function() return iTFConfig.layout.conditionals[indicator].enable end,
		}
		t.weight = {
			name = L.weight,
			desc = 'Indicator weight, higher overrides lower',
			type = 'slider',
			order = 2,
			min = 1,
			max = 100,
			step = 1,
			set = function(val)
				iTFConfig.layout.conditionals[indicator].weight = val
				iTF:updateFrames('conditionals')
			end,
			get = function() return iTFConfig.layout.conditionals[indicator].weight end
		}
		t.indicator = {
			name = L.indicators,
			type = 'select',
			multiselect = true,
			order = 3,
			values = optionFuncs.getValues('ind'),
			set = function(k,v)
				if v then
					iTFConfig.layout.conditionals[indicator].indicators[k] = v
					if v == 'alpha' then
						iTFConfig.layout.conditionals[indicator].indicators.alpha = iTFConfig.layout.conditionals[indicator].indicators.alpha or 1
					end
				else
					iTFConfig.layout.conditionals[indicator].indicators[k] = nil
				end								
				iTF:updateFrames('conditionals')
			end,
			get = function(k) return iTFConfig.layout.conditionals[indicator].indicators[k] end,
		}
		t.color = {
			name = L.color,
			type = 'color',
			order = 4,
			hasAlpha = true,
			set = function(r,g,b,a)
				iTFConfig.layout.conditionals[indicator].color = {r,g,b,a}
				iTF:updateFrames('conditionals')
			end,
			get = function()
				return unpack(iTFConfig.layout.conditionals[indicator].color or {1,1,1,1})
			end,
		}
		t.alpha = {
			name = L.frameOpacity,
			type = 'slider',
			order = 5,
			min = 0,
			max = 100,
			hidden = function()
				if iTFConfig.layout.conditionals[indicator].indicators.alpha then
					return false
				else
					return true
				end
			end,
			step = 1,
			set = function(val)
				iTFConfig.layout.conditionals[indicator].alpha = min(val/100, 1)
				iTF:updateFrames('conditionals')
			end,
			get = function() return (iTFConfig.layout.conditionals[indicator].alpha or 1)*100 end
		}
		if string.lower(indicator):find('range') then
			t.invert = {
			name = L.invert,
			order = 6,
			type = 'toggle',
			set = function(val) 
				iTFConfig.layout.conditionals[indicator].invert = val
				iTF:updateFrames('conditionals')
			end,
			get = function() return iTFConfig.layout.conditionals[indicator].invert end,
		}
		end
		if role then
			t.roles = {
				name = L.roles, 
				order = 6,
				type = 'select',
				values = {L.all, L.tank, L.dpsHealer},
				set = function(val)
					iTFConfig.layout.conditionals[indicator].roles = val
					iTF:updateFrames('conditionals')
				end,
				get = function() return iTFConfig.layout.conditionals[indicator].roles end
			}
		end
		if indicator == 'priorityNPCs' then
			t.allowReceiving = {
				name = L.allowReceiving,
				order = 6,
				type = 'toggle',
				set = function(val) 
					iTFConfig.layout.conditionals.priorityNPCs.receive = val
				end,
				get = function() return iTFConfig.layout.conditionals.priorityNPCs.receive end,
			}
		end
	end
	
	return t
end
function optionFuncs.getCustomConditionals()
	local t = {}
	local i = 0
	for k,v in pairs(iTFConfig.custom) do
		i = i + 1
		local temp = {}
		temp.args = optionFuncs.getIndicatorArgs(k, nil, true)
		temp.name = k
		temp.order = i
		t[k] = temp
	end
	return t
end
local function showBindingModeWarning(hide)
	if not iTF_BindingModeWarning then
		local bd = {bgFile = 'Interface\\Buttons\\WHITE8x8',edgeFile = 'Interface\\Buttons\\WHITE8x8',edgeSize = 1,insets = {left = -1,right = -1,top = -1,bottom = -1,}}
		local f = CreateFrame('frame', 'iTF_BindingModeWarning', UIParent)
		f:SetBackdrop(bd)
		f:SetBackdropColor(0.4,0.1,0.1,0.9)
		f:SetBackdropBorderColor(0,0,0,1)
		f:SetSize(300,80)
		f:SetPoint('BOTTOM', 'iTFOptions', 'TOP', 0,25)
		f:SetFrameStrata('HIGH')
		f.text = f:CreateFontString()
		f.text:SetFont('Fonts\\ARIALN.TTF', 20, 'outline')
		f.text:SetAllPoints(f)
		f.text:SetJustifyH('center')
		f.text:SetJustifyV('middle')
		f.text:SetText(L.bindingModeWarning)
		f:Show()
	else
		if hide then
			iTF_BindingModeWarning:Hide()
		else
			iTF_BindingModeWarning:Show()
		end
	end
end
function optionFuncs.getOptions()
	local options = {
		global = {
			name = L.global,
			order = 1,
			args = {
				font = {
					name = L.globalFont,
					type = 'scrollSelect',
					order = 1,
					font = true,
					set = function(val)
						local font = LibStub('LibSharedMedia-3.0'):Fetch('font', val)
						iTFConfig.layout.text.font = font
						iTFConfig.layout.healthText.font = font
						iTFConfig.layout.castBar.detached_text_font = font	
						iTFConfig.layout.icon.durationFont = font
						iTFConfig.layout.icon.stackFont = font
										
						iTF:updateFrames('text')
						iTF:updateFrames('auraText')
						iTF:updateFrames('castbar')
						iTF:updateFrames('healthText')
					end,
					invertValue = true,
					get = function()
						local font = iTFConfig.layout.text.font
						if (font == iTFConfig.layout.healthText.font) and (font == iTFConfig.layout.castBar.detached_text_font) and (font == iTFConfig.layout.icon.durationFont) and (font == iTFConfig.layout.icon.stackFont) then
							local fonts = LibStub('LibSharedMedia-3.0'):HashTable('font')
							for k,v in pairs(fonts) do
								if v == font then
									return k
								end
							end
						else
							return ' '
						end
					end,
					values = LibStub('LibSharedMedia-3.0'):List('font'),
				},
				texture = {
					name = L.globalTexture,
					type = 'scrollSelect',
					order = 2,
					set = function(val)
						local texture = LibStub('LibSharedMedia-3.0'):Fetch('statusbar', val)
						iTFConfig.layout.castBar.texture = texture
						iTFConfig.layout.statusbar.texture = texture
						iTF:updateFrames('statusbar')
					end,
					invertValue = true,
					get = function()
						if iTFConfig.layout.castBar.texture == iTFConfig.layout.statusbar.texture then
							local textures = LibStub('LibSharedMedia-3.0'):HashTable('statusbar')
							for k,v in pairs(textures) do
								if v == iTFConfig.layout.statusbar.texture then
									return k
								end
							end
						else
							return ' '
						end
					end,
					values = LibStub('LibSharedMedia-3.0'):List('statusbar'),
				},
			},
		},
		frameOptions = {
			name = L.frame,
			order = 2,
			args = {
				showMaxSize = {
					name = L.showMaxSize,
					type = 'toggle',
					order = 15,
					set = function(val) MainFrameBG(val) end,
					get = function() return iTF.show end
				},
				xPos = {
					name = L.horizontalPos,
					type = 'slider',
					order = 1,
					min = 0,
					max = math.floor(GetScreenWidth()),
					step = 1,
					set = function(val)
						iTFConfig.layout.anchor.x = val
						iTF:updateFrames('pos')
					end,
					get = function() return iTFConfig.layout.anchor.x end
					},
				yPos = {
					name = L.verticalPos,
					type = 'slider',
					order = 2,
					min = 0,
					max = math.floor(GetScreenHeight()),
					step = 1,
					set = function(val)
						iTFConfig.layout.anchor.y = val
						iTF:updateFrames('pos')
					end,
					get = function() return iTFConfig.layout.anchor.y end
				},
				rows = {
					name = L.rows,
					type = 'slider',
					order = 3,
					min = 1,
					max = 40,
					step = 1,
					set = function(val)
						iTFConfig.layout.colS = val
						iTF:updateFrames('pos')
					end,
					get = function() return iTFConfig.layout.colS end
				},
				grow = {
					name = L.grow,
					type = 'select',
					order = 4,
					values = optionFuncs.getValues('growTo'),
					set = function(val)
						iTFConfig.layout.grow = val
						iTF:updateFrames('pos')
					end,
					get = function() return iTFConfig.layout.grow end
				},
				hSpacing = {
					name = L.horizontalSpacing,
					type = 'slider',
					order = 5,
					min = 0,
					max = 200,
					step = 1,
					set = function(val)
						iTFConfig.layout.frame.hspacing = val
						iTF:updateFrames('pos')
					end,
					get = function() return iTFConfig.layout.frame.hspacing end
				},
				vSpacing = {
					name = L.verticalSpacing,
					type = 'slider',
					order = 5,
					min = 0,
					max = 200,
					step = 1,
					set = function(val)
						iTFConfig.layout.frame.vspacing = val
						iTF:updateFrames('pos')
					end,
					get = function() return iTFConfig.layout.frame.vspacing end
				},
				width = {
					name = L.width,
					type = 'slider',
					order = 6,
					min = 5,
					max = 300,
					step = 1,
					
					set = function(val)
						iTFConfig.layout.frame.width = val
						iTF:updateFrames('size')
					end,
					get = function() return iTFConfig.layout.frame.width end
				},
				height = {
					name = L.height,
					type = 'slider',
					order = 7,
					min = 5,
					max = 300,
					step = 1,
					set = function(val)
						iTFConfig.layout.frame.height = val
						iTF:updateFrames('size')
					end,
					get = function() return iTFConfig.layout.frame.height end
				},
				frameColor = {
					name = L.frameColor,
					type = 'color',
					order = 9,
					hasAlpha = true,
					set = function(r,g,b,a)
						iTFConfig.layout.colors.statusbar.backdrop = {r,g,b,a}
						iTF:updateFrames('frameColor')
					end,
					get = function()
						return unpack(iTFConfig.layout.colors.statusbar.backdrop)
					end,
				},
				borderColor = {
					name = L.borderColor,
					type = 'color',
					order = 10,
					hasAlpha = true,
					set = function(r,g,b,a)
						iTFConfig.layout.colors.statusbar.border = {r,g,b,a}
						iTF:updateFrames('frameColor')
					end,
					get = function()
						return unpack(iTFConfig.layout.colors.statusbar.border)
					end,
				},
				maxUnits = {
					name = L.maxUnits,
					type = 'slider',
					order = 11,
					min = 1,
					max = 40,
					step = 1,
					set = function(val)
						iTFConfig.layout.maxUnits = val
						iTF:updateMainFrameAttributes(true)
						iTF:updateFrames('size')
					end,
					get = function() return iTFConfig.layout.maxUnits end,
				},
				onlyshowEnemies = {
					name = L.onlyShowEnemies,
					type = 'toggle',
					order = 12,
					set = function(val) 
						iTFConfig.layout.onlyEnemies = val
						iTF:updateNameplateStateDrivers(true)
					end,
					get = function() return iTFConfig.layout.onlyEnemies end
				},
				onlyShowInCombat = {
					name = L.onlyShowInCombat,
					type = 'toggle',
					order = 13,
					set = function(val) 
						iTFConfig.layout.onlyShowInCombat = val
						iTF:updateNameplateStateDrivers(true)
					end,
					get = function() return iTFConfig.layout.onlyShowInCombat end
				}
			},
			subGroups = {
				text = { --
					name = L.nameCastText,
					order = 1,
					args = {
						size = {
							name = L.size,
							desc = 'Font size',
							type = 'slider',
							order = 1,
							min = 6,
							max = 60,
							step = 1,
							set = function(val)
								iTFConfig.layout.text.size = val
								iTF:updateFrames('text')
							end,
							get = function() return iTFConfig.layout.text.size end
						},
						textPosition = {
							name = L.textPos,
							type = 'select',
							order = 2,
							values = optionFuncs.getValues('all'),
							set = function(val)
								iTFConfig.layout.text.pos = val
								iTF:updateFrames('text')
							end,
							get = function() return iTFConfig.layout.text.pos end
						},
						horizontal = {
							name = L.horizontalPos,
							type = 'slider',
							order = 3,
							min = -150,
							max = 150,
							step = 1,
							set = function(val)
								iTFConfig.layout.text.x = val
								iTF:updateFrames('text')
							end,
							get = function() return iTFConfig.layout.text.x end
						},
						vertical = {
							name = L.verticalPos,
							type = 'slider',
							order = 4,
							min = -150,
							max = 150,
							step = 1,
							set = function(val)
								iTFConfig.layout.text.y = val
								iTF:updateFrames('text')
							end,
							get = function() return iTFConfig.layout.text.y end
						},
						nameColor = {
							name = L.nameColor,
							type = 'color',
							order = 5,
							hasAlpha = true,
							set = function(r,g,b,a)
								iTFConfig.layout.colors.text.main = {r,g,b,a}
								iTF:updateFrames('text')
							end,
							get = function()
								return unpack(iTFConfig.layout.colors.text.main)
							end,
						},
						font = {
							name = L.font,
							type = 'scrollSelect',
							order = 8,
							font = true,
							set = function(val)
								iTFConfig.layout.text.font = LibStub('LibSharedMedia-3.0'):Fetch('font', val)
								iTF:updateFrames('text')
							end,
							invertValue = true,
							get = function()
								local fonts = LibStub('LibSharedMedia-3.0'):HashTable('font')
								for k,v in pairs(fonts) do
									if v == iTFConfig.layout.text.font then
										return k
									end
								end
							end,
							values = LibStub('LibSharedMedia-3.0'):List('font'),
						},
						textFlags = {
							name = L.textFlags,
							type = 'select',
							order = 8,
							values = optionFuncs.getValues('textFlags'),
							set = function(val)
								if val == 'NONE' then
									iTFConfig.layout.text.flags = nil
								else
									iTFConfig.layout.text.flags = val
								end
								iTF:updateFrames('text')
							end,
							get = function() return iTFConfig.layout.text.flags or 'NONE' end
						},
						abbreviateNames = {
							name = L.abbreviateNames,
							type = 'toggle',
							order = 9,
							set = function(val) 
								iTFConfig.layout.text.abbreviateNames = val
								iTF:updateFrames('text')
							end,
							get = function() return iTFConfig.layout.text.abbreviateNames end
						},
					},
				},
				healtText = { --
					name = L.healthText,
					order = 2,
					args = {
						enabled = {
							name = L.enable,
							type = 'toggle',
							order = 1,
							updateOnClick = true,
							set = function(val) 
								iTFConfig.layout.healthText.enabled = val
								iTF:updateFrames('healthText')
							end,
							get = function() 
								return iTFConfig.layout.healthText.enabled
							end
						},
						size = {
							name = L.size,
							desc = 'Font size',
							type = 'slider',
							order = 2,
							min = 6,
							max = 60,
							step = 1,
							show = function() return iTFConfig.layout.healthText.enabled end,
							set = function(val)
								iTFConfig.layout.healthText.size = val
								iTF:updateFrames('healthText')
							end,
							get = function() return iTFConfig.layout.healthText.size end
						},
						textPosition = {
							name = L.textPos,
							type = 'select',
							order = 2,
							show = function() return iTFConfig.layout.healthText.enabled end,
							values = optionFuncs.getValues('all'),
							set = function(val)
								iTFConfig.layout.healthText.pos = val
								iTF:updateFrames('healthText')
							end,
							get = function() return iTFConfig.layout.healthText.pos end
						},
						horizontal = {
							name = L.horizontalPos,
							type = 'slider',
							order = 3,
							min = -150,
							max = 150,
							step = 1,
							show = function() return iTFConfig.layout.healthText.enabled end,
							set = function(val)
								iTFConfig.layout.healthText.x = val
								iTF:updateFrames('healthText')
							end,
							get = function() return iTFConfig.layout.healthText.x end
						},
						vertical = {
							name = L.verticalPos,
							type = 'slider',
							order = 4,
							min = -150,
							max = 150,
							step = 1,
							show = function() return iTFConfig.layout.healthText.enabled end,
							set = function(val)
								iTFConfig.layout.healthText.y = val
								iTF:updateFrames('healthText')
							end,
							get = function() return iTFConfig.layout.healthText.y end
						},
						nameColor = {
							name = L.color,
							type = 'color',
							order = 5,
							show = function() return iTFConfig.layout.healthText.enabled end,
							hasAlpha = true,
							set = function(r,g,b,a)
								iTFConfig.layout.colors.text.healthText = {r,g,b,a}
								iTF:updateFrames('healthText')
							end,
							get = function()
								return unpack(iTFConfig.layout.colors.text.healthText)
							end,
						},
						textFlags = {
							name = L.textFlags,
							type = 'select',
							order = 8,
							show = function() return iTFConfig.layout.healthText.enabled end,
							values = optionFuncs.getValues('textFlags'),
							set = function(val)
								if val == 'NONE' then
									iTFConfig.layout.healthText.flags = nil
								else
									iTFConfig.layout.healthText.flags = val
								end
								iTF:updateFrames('healthText')
							end,
							get = function() return iTFConfig.layout.healthText.flags or 'NONE' end
						},
						font = {
							name = L.font,
							type = 'scrollSelect',
							order = 8,
							show = function() return iTFConfig.layout.healthText.enabled end,
							font = true,
							set = function(val)
								iTFConfig.layout.healthText.font = LibStub('LibSharedMedia-3.0'):Fetch('font', val)
								iTF:updateFrames('healthText')
							end,
							invertValue = true,
							get = function()
								local fonts = LibStub('LibSharedMedia-3.0'):HashTable('font')
								for k,v in pairs(fonts) do
									if v == iTFConfig.layout.healthText.font then
										return k
									end
								end
							end,
							values = LibStub('LibSharedMedia-3.0'):List('font'),
						},
						decimals = {
							name = L.healthDecimals,
							type = 'toggle',
							order = 9,
							show = function() return iTFConfig.layout.healthText.enabled end,
							set = function(val) 
								iTFConfig.layout.healthText.decimal = val
								iTF:updateFrames('healthText')
							end,
							get = function() 
								return iTFConfig.layout.healthText.decimal
							end
						},
						percentageSign = {
							name = L.showPercentage,
							type = 'toggle',
							order = 10,
							show = function() return iTFConfig.layout.healthText.enabled end,
							set = function(val)
								iTFConfig.layout.healthText.percentage = val
								iTF:updateFrames('healthText')
							end,
							get = function()
								return iTFConfig.layout.healthText.percentage
							end
						},
						
					},
				},
				castBar = { --
					name = L.castBar,
					order = 3,
					args = {
						enabled = {
							name = L.enable,
							type = 'toggle',
							order = 1,
							updateOnClick = true,
							set = function(val) iTFConfig.layout.castBar.enabled = val end,
							get = function() return iTFConfig.layout.castBar.enabled end
						},
						height = {
							name = L.height,
							desc = 'Cast bar height',
							type = 'slider',
							show = function()
								if iTFConfig.layout.castBar.enabled and not iTFConfig.layout.castBar.detached then
									return true
								end
							end,
							order = 4,
							min = 0,
							max = 300,
							step = 1,
							set = function(val)
								iTFConfig.layout.frame.castBarHeight = val
								iTF:updateFrames('size')
							end,
							get = function() return iTFConfig.layout.frame.castBarHeight end
						},						
						castColor = {
							name = L.castColor,
							type = 'color',
							order = 2,
							hasAlpha = true,
							show = function() return iTFConfig.layout.castBar.enabled end,
							set = function(r,g,b,a)
								iTFConfig.layout.colors.text.cast = {r,g,b,a}
								iTF:updateFrames('text')
							end,
							get = function()
								return unpack(iTFConfig.layout.colors.text.cast)
							end,
						},
						immuneColor = {
							name = L.nonInterruptibleCastColor,
							type = 'color',
							order = 3,
							hasAlpha = true,
							show = function() return iTFConfig.layout.castBar.enabled end,
							set = function(r,g,b,a)
								iTFConfig.layout.colors.text.immune = {r,g,b,a}
								iTF:updateFrames('text')
							end,
							get = function()
								return unpack(iTFConfig.layout.colors.text.immune)
							end,
						},
						color = {
							name = L.barColor,
							type = 'color',
							order = 3,
							hasAlpha = true,
							show = function() return iTFConfig.layout.castBar.enabled end,
							set = function(r,g,b,a)
								iTFConfig.layout.colors.statusbar.cast = {r,g,b,a}
								iTF:updateFrames('castbar')
							end,
							get = function()
								return unpack(iTFConfig.layout.colors.statusbar.cast)
							end,
						},
						texture = {
							name = L.castBarTexture,
							type = 'scrollSelect',
							order = 4,
							show = function() return iTFConfig.layout.castBar.enabled end,
							set = function(val)
								iTFConfig.layout.castBar.texture = LibStub('LibSharedMedia-3.0'):Fetch('statusbar', val)
								iTF:updateFrames('statusbar')
							end,
							invertValue = true,
							get = function()
								local textures = LibStub('LibSharedMedia-3.0'):HashTable('statusbar')
								for k,v in pairs(textures) do
									if v == iTFConfig.layout.castBar.texture then
										return k
									end
								end
							end,
							values = LibStub('LibSharedMedia-3.0'):List('statusbar'),
						},
						detached = {
							name = L.detached,
							type = 'toggle',
							order = 3,
							updateOnClick = true,
							show = function() return iTFConfig.layout.castBar.enabled end,
							set = function(val) 
								iTFConfig.layout.castBar.detached = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached end
						},
						detached_fromPoint = {
							name = L.from,
							type = 'select',
							order = 5,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							values = optionFuncs.getValues('all'),
							set = function(val)
								iTFConfig.layout.castBar.detached_from = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_from end
						},
						detached_toPoint = {
							name = L.to,
							type = 'select',
							order = 5,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							values = optionFuncs.getValues('all'),
							set = function(val)
								iTFConfig.layout.castBar.detached_to = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_from end
						},
						detached_width = {
							name = L.width,
							type = 'slider',
							order = 6,
							min = 5,
							max = 300,
							step = 1,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							set = function(val)
								iTFConfig.layout.castBar.detached_width = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_width end
						},
						detached_height = {
							name = L.height,
							type = 'slider',
							order = 6,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							min = 5,
							max = 300,
							step = 1,
							set = function(val)
								iTFConfig.layout.castBar.detached_height = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_height end
						},
						detached_xPos = {
							name = L.horizontalPos,
							type = 'slider',
							order = 7,
							min = -300,
							max = 300,
							step = 1,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							set = function(val)
								iTFConfig.layout.castBar.detached_x = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_x end
							},
						detached_yPos = {
							name = L.verticalPos,
							type = 'slider',
							order = 8,
							min = -300,
							max = 300,
							step = 1,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							set = function(val)
								iTFConfig.layout.castBar.detached_y = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_y end
						},
						text_size = {
							name = L.size,
							desc = 'Font size',
							type = 'slider',
							order = 9,
							min = 6,
							max = 60,
							step = 1,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							set = function(val)
								iTFConfig.layout.castBar.detached_text_size = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_text_size end
						},
						text_position = {
							name = L.textPos,
							type = 'select',
							order = 10,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							values = optionFuncs.getValues('all'),
							set = function(val)
								iTFConfig.layout.castBar.detached_text_pos = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_text_pos end
						},
						text_horizontal = {
							name = L.horizontalPos,
							type = 'slider',
							order = 11,
							min = -150,
							max = 150,
							step = 1,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							set = function(val)
								iTFConfig.layout.castBar.detached_text_x = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_text_x end
						},
						text_vertical = {
							name = L.verticalPos,
							type = 'slider',
							order = 12,
							min = -150,
							max = 150,
							step = 1,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							set = function(val)
								iTFConfig.layout.castBar.detached_text_y = val
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_text_y end
						},
						font = {
							name = L.font,
							type = 'scrollSelect',
							order = 13,
							font = true,
							set = function(val)
								iTFConfig.layout.castBar.detached_text_font = LibStub('LibSharedMedia-3.0'):Fetch('font', val)
								iTF:updateFrames('castbar')
							end,
							invertValue = true,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							get = function()
								local fonts = LibStub('LibSharedMedia-3.0'):HashTable('font')
								for k,v in pairs(fonts) do
									if v == iTFConfig.layout.castBar.detached_text_font then
										return k
									end
								end
							end,
							values = LibStub('LibSharedMedia-3.0'):List('font'),
						},
						textFlags = {
							name = L.textFlags,
							type = 'select',
							order = 14,
							show = function() return (iTFConfig.layout.castBar.detached and iTFConfig.layout.castBar.enabled)end,
							values = optionFuncs.getValues('textFlags'),
							set = function(val)
								if val == 'NONE' then
									iTFConfig.layout.castBar.detached_text_flags = nil
								else
									iTFConfig.layout.castBar.detached_text_flags = val
								end
								iTF:updateFrames('castbar')
							end,
							get = function() return iTFConfig.layout.castBar.detached_text_flags or 'NONE' end
						},
					},
				},
				statusbar = { --
					name = L.healthBar,
					type = 'group',
					order = 4,
					args = {
						classColor = {
							name = L.useClassColors,
							type = 'toggle',
							order = 1,
							set = function(val) 
								iTFConfig.layout.colors.classColor = val
								iTF:updateFrames('statusBarColor')
							end,
							get = function() 
								return iTFConfig.layout.colors.classColor
							end
						},
						color = {
							name = L.barColor,
							type = 'color',
							order = 2,
							hasAlpha = true,
							set = function(r,g,b,a)
								iTFConfig.layout.colors.statusbar.main = {r,g,b,a}
								iTF:updateFrames('statusBarColor')
							end,
							get = function(info)
								return unpack(iTFConfig.layout.colors.statusbar.main)
							end,
						},
						texture = {
							name = L.statusBarTexture,
							type = 'scrollSelect',
							order = 3,
							set = function(val)
								iTFConfig.layout.statusbar.texture = LibStub('LibSharedMedia-3.0'):Fetch('statusbar', val)
								iTF:updateFrames('statusbar')
							end,
							invertValue = true,
							get = function()
								local textures = LibStub('LibSharedMedia-3.0'):HashTable('statusbar')
								for k,v in pairs(textures) do
									if v == iTFConfig.layout.statusbar.texture then
										return k
									end
								end
							end,
							values = LibStub('LibSharedMedia-3.0'):List('statusbar'),
						},
					},
				},
				raidIcon = { --
					name = L.raidIcon,
					order = 5,
					args = {
						size = {
							name = L.size,
							type = 'slider',
							order = 1,
							min = 0,
							max = 300,
							step = 1,
							set = function(val)
								iTFConfig.layout.raidIcon.size = val
								iTF:updateFrames('raidIcon')
							end,
							get = function() return iTFConfig.layout.raidIcon.size end
						},
						iconPosition = {
							name = L.pos,
							type = 'select',
							order = 2,
							values = optionFuncs.getValues('all'),
							set = function(val)
								iTFConfig.layout.raidIcon.pos = val
								iTF:updateFrames('raidIcon')
							end,
							get = function() return iTFConfig.layout.raidIcon.pos end
						},
						horizontal = {
							name = L.horizontalPos,
							type = 'slider',
							order = 3,
							min = -150,
							max = 150,
							step = 1,
							set = function(val)
								iTFConfig.layout.raidIcon.x = val
								iTF:updateFrames('raidIcon')
							end,
							get = function() return iTFConfig.layout.raidIcon.x end
						},
						vertical = {
							name = L.verticalPos,
							type = 'slider',
							order = 4,
							min = -150,
							max = 150,
							step = 1,
							set = function(val)
								iTFConfig.layout.raidIcon.y = val
								iTF:updateFrames('raidIcon')
							end,
							get = function() return iTFConfig.layout.raidIcon.y end
						},
					},
				},
			},
		},
		auras = {
			name = L.auras,
			order = 3,
			args = {},
			subGroups = {
				icon = { -- Icon options
					name = L.icon,
					order = 1,
					args = {
						height = {
							name = L.height,
							type = 'slider',
							order = 1,
							min = 0,
							max = 300,
							step = 1,
							set = function(val)
								iTFConfig.layout.icon.height = val
								iTF:updateFrames('auraIcon')
							end,
							get = function() return iTFConfig.layout.icon.height end
						},
						width = {
							name = L.width,
							type = 'slider',
							order = 2,
							min = 0,
							max = 300,
							step = 1,
							set = function(val)
								iTFConfig.layout.icon.width = val
								iTF:updateFrames('auraIcon')
							end,
							get = function() return iTFConfig.layout.icon.width end
						},
						horizontal = {
							name = L.horizontalPos,
							type = 'slider',
							order = 3,
							min = -150,
							max = 150,
							step = 1,
							set = function(val)
								iTFConfig.layout.icon.x = val
								iTF:updateFrames('auraIcon')
							end,
							get = function() return iTFConfig.layout.icon.x end
						},
						vertical = {
							name = L.verticalPos,
							type = 'slider',
							order = 4,
							min = -150,
							max = 150,
							step = 1,
							set = function(val)
								iTFConfig.layout.icon.y = val
								iTF:updateFrames('auraIcon')
							end,
							get = function() return iTFConfig.layout.icon.y end
						},
						position = {
							name = L.pos,
							type = 'select',
							order = 5,
							values = optionFuncs.getValues('all'),
							set = function(val)
								iTFConfig.layout.icon.pos = val
								iTF:updateFrames('auraIcon')
							end,
							get = function() return iTFConfig.layout.icon.pos end
						},
						spacing = {
							name = L.spacing,
							type = 'slider',
							order = 6,
							min = 0,
							max = 50,
							step = 1,
							set = function(val)
								iTFConfig.layout.icon.spacing = val
								iTF:updateFrames('auraIcon')
							end,
							get = function() return iTFConfig.layout.icon.spacing end
						},
						grow = {
							name = L.grow,
							type = 'select',
							order = 6,
							values = optionFuncs.getValues('grow'),
							set = function(val)
								iTFConfig.layout.icon.grow = val
								iTF:updateFrames('auraIcon')
							end,
							get = function() return iTFConfig.layout.icon.grow end
						},
						maxAuras = {
							name = L.maxAuras,
							type = 'slider',
							order = 7,
							min = 0,
							max = 20,
							step = 1,
							set = function(val)
								iTFConfig.layout.icon.max = val
								iTF:updateFrames('auraIcon')
							end,
							get = function() return iTFConfig.layout.icon.max end
						},
						sortAuras = {
							name = L.sortAuras,
							type = 'select',
							order = 8,
							--invertValue = true,
							values = optionFuncs.getValues('sorting'),
							set = function(val)
								if val == 'truetrue' then
									iTFConfig.layout.icon.sort.time = true
									iTFConfig.layout.icon.sort.ascending = true
								elseif val == 'truefalse' then
									iTFConfig.layout.icon.sort.time = true
									iTFConfig.layout.icon.sort.ascending = false
								elseif val == 'falsetrue' then
									iTFConfig.layout.icon.sort.time = false
									iTFConfig.layout.icon.sort.ascending = true
								elseif val == 'falsefalse' then
									iTFConfig.layout.icon.sort.time = false
									iTFConfig.layout.icon.sort.ascending = false
								end
								iTF:updateFrames('auraIcon')
							end,
							get = function()
								local values = optionFuncs.getValues('sorting')
								local k = tostring(iTFConfig.layout.icon.sort.time)..tostring(iTFConfig.layout.icon.sort.ascending)
								return k
							end,
						},
					},
					subGroups = {
						durationText = {
							name = L.durationText,
							order = 1,
							args = {
								enabled = {
									name = L.enable,
									type = 'toggle',
									order = 1,
									updateOnClick = true,
									set = function(val)
										if val then
											iTFConfig.layout.icon.durationEnabled = true
										else
											iTFConfig.layout.icon.durationEnabled = false
										end
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.durationEnabled end
								},
								font = {
									name = L.font,
									type = 'scrollSelect',
									order = 2,
									font = true,
									show = function() return iTFConfig.layout.icon.durationEnabled end,
									set = function(val)
										iTFConfig.layout.icon.durationFont = LibStub('LibSharedMedia-3.0'):Fetch('font', val)
										iTF:updateFrames('auraText')
									end,
									invertValue = true,
									get = function()
										local fonts = LibStub('LibSharedMedia-3.0'):HashTable('font')
										for k,v in pairs(fonts) do
											if v == iTFConfig.layout.icon.durationFont then
												return k
											end
										end
									end,
									values = LibStub('LibSharedMedia-3.0'):List('font'),
								},
								textFlags = {
									name = L.textFlags,
									type = 'select',
									order = 3,
									values = optionFuncs.getValues('textFlags'),
									show = function() return iTFConfig.layout.icon.durationEnabled end,
									set = function(val)
										if val == 'NONE' then
											iTFConfig.layout.icon.durationFlags = nil
										else
											iTFConfig.layout.icon.durationFlags = val
										end
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.durationFlags or 'NONE' end
								},
								textPosition = {
									name = L.textPos,
									type = 'select',
									order = 4,
									values = optionFuncs.getValues('all'),
									show = function() return iTFConfig.layout.icon.durationEnabled end,
									set = function(val)
										iTFConfig.layout.icon.durationPos = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.durationPos end
								},
								horizontal = {
									name = L.horizontalPos,
									type = 'slider',
									order = 5,
									min = -50,
									max = 50,
									step = 1,
									show = function() return iTFConfig.layout.icon.durationEnabled end,
									set = function(val)
										iTFConfig.layout.icon.durationX = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.durationX end
								},
								vertical = {
									name = L.verticalPos,
									type = 'slider',
									order = 6,
									min = -50,
									max = 50,
									step = 1,
									show = function() return iTFConfig.layout.icon.durationEnabled end,
									set = function(val)
										iTFConfig.layout.icon.durationY = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.durationY end
								},
								size = {
									name = L.size,
									desc = 'Font size',
									type = 'slider',
									order = 7,
									min = 6,
									max = 60,
									step = 1,
									show = function() return iTFConfig.layout.icon.durationEnabled end,
									set = function(val)
										iTFConfig.layout.icon.durationSize = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.durationSize end
								},
								decimals = {
									name = L.showDecimals,
									type = 'slider',
									order = 8,
									min = 0,
									max = 10,
									step = 5,
									show = function() return iTFConfig.layout.icon.durationEnabled end,
									allowDecimals = 2,
									set = function(val)
										iTFConfig.layout.icon.durationDecimals = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.durationDecimals end
								},
								color = {
									name = L.color,
									type = 'color',
									order = 9,
									hasAlpha = true,
									show = function() return iTFConfig.layout.icon.durationEnabled end,
									set = function(r,g,b,a)
										iTFConfig.layout.colors.text.duration = {r,g,b,a}
										iTF:updateFrames('auraText')
									end,
									get = function()
										return unpack(iTFConfig.layout.colors.text.duration)
									end,
								},
							},
						},
						stackText = {
							name = L.stackText,
							order = 1,
							args = {
								enabled = {
									name = L.enable,
									type = 'toggle',
									order = 1,
									updateOnClick = true,
									set = function(val)
										if val then
											iTFConfig.layout.icon.stackEnabled = true
										else
											iTFConfig.layout.icon.stackEnabled = false
										end
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.stackEnabled end
								},
								font = {
									name = L.font,
									type = 'scrollSelect',
									order = 2,
									font = true,
									show = function() return iTFConfig.layout.icon.stackEnabled end,
									set = function(val)
										iTFConfig.layout.icon.stackFont = LibStub('LibSharedMedia-3.0'):Fetch('font', val)
										iTF:updateFrames('auraText')
									end,
									invertValue = true,
									get = function()
										local fonts = LibStub('LibSharedMedia-3.0'):HashTable('font')
										for k,v in pairs(fonts) do
											if v == iTFConfig.layout.icon.stackFont then
												return k
											end
										end
									end,
									values = LibStub('LibSharedMedia-3.0'):List('font'),
								},
								textFlags = {
									name = L.textFlags,
									type = 'select',
									order = 3,
									show = function() return iTFConfig.layout.icon.stackEnabled end,
									values = optionFuncs.getValues('textFlags'),
									set = function(val)
										if val == 'NONE' then
											iTFConfig.layout.icon.stackFlags = nil
										else
											iTFConfig.layout.icon.stackFlags = val
										end
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.stackFlags or 'NONE' end
								},
								textPosition = {
									name = L.textPos,
									type = 'select',
									order = 4,
									show = function() return iTFConfig.layout.icon.stackEnabled end,
									values = optionFuncs.getValues('all'),
									set = function(val)
										iTFConfig.layout.icon.stackPos = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.stackPos end
								},
								horizontal = {
									name = L.horizontalPos,
									type = 'slider',
									order = 5,
									min = -50,
									max = 50,
									step = 1,
									show = function() return iTFConfig.layout.icon.stackEnabled end,
									set = function(val)
										iTFConfig.layout.icon.stackX = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.stackX end
								},
								vertical = {
									name = L.verticalPos,
									type = 'slider',
									order = 6,
									min = -50,
									max = 50,
									step = 1,
									show = function() return iTFConfig.layout.icon.stackEnabled end,
									set = function(val)
										iTFConfig.layout.icon.stackY = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.stackY end
								},
								size = {
									name = L.size,
									desc = 'Font size',
									type = 'slider',
									order = 7,
									min = 6,
									max = 60,
									step = 1,
									show = function() return iTFConfig.layout.icon.stackEnabled end,
									set = function(val)
										iTFConfig.layout.icon.stackSize = val
										iTF:updateFrames('auraText')
									end,
									get = function() return iTFConfig.layout.icon.stackSize end
								},
								color = {
									name = L.color,
									type = 'color',
									order = 8,
									hasAlpha = true,
									show = function() return iTFConfig.layout.icon.stackEnabled end,
									set = function(r,g,b,a)
										iTFConfig.layout.colors.text.stack = {r,g,b,a}
										iTF:updateFrames('auraText')
									end,
									get = function()
										return unpack(iTFConfig.layout.colors.text.stack)
									end,
								},
							},
						},
						flash = {
							name = L.flashText,
							order = 1,
							args = {
								enabled = {
									name = L.enable,
									type = 'toggle',
									order = 1,
									updateOnClick = true,
									set = function(val)
										if val then
											iTFConfig.layout.icon.flashEnabled = true
										else
											iTFConfig.layout.icon.flashEnabled = false
										end
										iTF:updateFrames('flash')
									end,
									get = function() return iTFConfig.layout.icon.flashEnabled end
								},
								speed = {
									name = L.flashSpeed,
									type = 'slider',
									order = 2,
									min = 0,
									max = 3,
									allowDecimals = 4,
									show = function() return iTFConfig.layout.icon.flashEnabled end,
									set = function(val)
										iTFConfig.layout.icon.flashSpeed = val
										iTF:updateFrames('flash')
									end,
									get = function() return iTFConfig.layout.icon.flashSpeed end
								},
								start = {
									name = L.flashStart,
									type = 'slider',
									order = 3,
									min = 0,
									max = 20,
									allowDecimals = 2,
									show = function() return iTFConfig.layout.icon.flashEnabled end,
									set = function(val)
										iTFConfig.layout.icon.flashTimer = val
										iTF:updateFrames('flash')
									end,
									get = function() return iTFConfig.layout.icon.flashTimer end
								},
								textColor = {
									name = L.durationColor,
									type = 'color',
									order = 4,
									hasAlpha = true,
									show = function() return iTFConfig.layout.icon.flashEnabled end,
									set = function(r,g,b,a)
										iTFConfig.layout.colors.text.shortDuration = {r,g,b,a}
										iTF:updateFrames('auraText')
									end,
									get = function()
										return unpack(iTFConfig.layout.colors.text.shortDuration)
									end,
								},
							},
						},
					
					},
				},
				blacklist = {
					name = L.blacklist,
					order = 2,
					blacklist = true,
					args = {
						text = {
							name = L.spellIDorSpellName,
							order = 1,
							type = 'input',
							updateOnClick = true,
							set = function(val)
								if tonumber(val) then
									val = tonumber(val)
								end
								if string.len(val) <= 2 then
									return
								end
								if iTFConfig.blacklist then
									iTFConfig.blacklist[val] = true
								else
									iTFConfig.blacklist = {}
									iTFConfig.blacklist[val] = true
								end
							end,
							get = function() 
								return ''
							end,
						},
					},
				},
			},
		},
		indicators = {
			name = L.indicators,
			order = 4,
			args = {},
			subGroups = {
				outOfCombat = {
					name = L.outOfCombat,
					order = 1,
					args = optionFuncs.getIndicatorArgs('outOfCombat'),
				},
				targeting = {
					name = L.currentTarget,
					order = 2,
					args = optionFuncs.getIndicatorArgs('currentTarget'),
				},
				focus = {
					name = L.focusTarget,
					order = 3, 
					args = optionFuncs.getIndicatorArgs('focusTarget'),
				},
				interruptRange = {
					name = L.interruptRange,
					order = 4,
					args = optionFuncs.getIndicatorArgs('interruptRange'),
				},
				DPSrange = {
					name = L.dpsRange,
					order = 5,
					args = optionFuncs.getIndicatorArgs('maxRangeDPS'),
				},
				utilityRange = {
					name = L.utilityRange,
					order = 6,
					args = optionFuncs.getIndicatorArgs('maxRange'),
				},
				prioNPC = {
					name = L.prioNPC,
					order = 7,
					priorityNPCs = true,
					args = optionFuncs.getIndicatorArgs('priorityNPCs'),
				},
				threat = { --
					name = L.threat,
					order = 8,
					args = {},
					subGroups = {
						aggro = { -- 
							name = L.aggro,
							order = 1,
							args = optionFuncs.getIndicatorArgs('aggro', true),
						},
						losingAggro = { --  
							name = L.losingAggro,
							order = 2,
							args = optionFuncs.getIndicatorArgs('losingAggro', true),
						},
						gainingAggro = {
							name = L.gainingAggro,
							order = 3,
							args = optionFuncs.getIndicatorArgs('gainingAggro', true),
						},
					},
				},
				custom = {
					name = L.custom,
					order = 9,
					args = optionFuncs.getIndicatorArgs('AddCustom'),
					subGroups = optionFuncs.getCustomConditionals(),
				},
			},
		},
		bindings = {
			name = L.bindings,
			order = 5,
			args = {},
			subGroups = {
				general = {
					name = L.general,
					order = 1,
					bindings = 'general',
					args = optionFuncs.getBindings('general'),
				},
				class = {
					name = L.class, 
					order = 2,
					bindings = 'class',
					args = optionFuncs.getBindings('class'),
				},
				spec = {
					name = L.spec,
					order = 3,
					bindings = 'spec',
					args = optionFuncs.getBindings('spec'),
				},
			},
		},
		layouts = {
			name = 'Layouts',
			order = 7,
			args = {
				profiles = {
					name = 'Load layout', 
					order = 1,
					type = 'select',
					values = optionFuncs.getProfiles(),
					confirm = true,
					confirmText = 'Are you sure? This will delete your current settings.',
					set = function(val)
						iTFConfig.layout = iTF:GetProfile(profileListing[val])
						iTF:updateFrames()
						iTF:print('Loaded: "' .. profileListing[val] .. '" profile.')
					end,
					get = function() return false end
				},
			},
		},
	}
	return options
end
--Create options
function iTF:toggleConfig(forceHide)
	if not iTFOptions and not InCombatLockdown() and not forceHide then
		local options = optionFuncs.getOptions()
		local bd = {bgFile = 'Interface\\Buttons\\WHITE8x8',edgeFile = 'Interface\\Buttons\\WHITE8x8',edgeSize = 1,insets = {left = -1,right = -1,top = -1,bottom = -1,}}
		local width = 600
		local height = 500
		local font = NumberFont_Shadow_Small:GetFont()
		local f = CreateFrame('frame', 'iTFOptions', UIParent)
		f:SetSize(width,height)
		f:SetPoint('CENTER', UIParent, 'CENTER', 0,0)
		f:SetMovable(true)
		f:SetFrameStrata('HIGH')
		iTF:testMode(true)
		f:SetScript('OnShow', function()
			iTF:testMode(true)
		end)
		f:SetScript('OnHide', function()
			iTF:testMode()
		end)
		--Title
		f.title = CreateFrame('frame', nil, f)
		f.title:SetSize(width, 20)
		f.title:SetBackdrop(bd)
		f.title:SetBackdropColor(0.1,0.1,0.1,0.9)
		f.title:SetBackdropBorderColor(0,0,0,1)
		f.title:SetPoint('BOTTOM', f, 'TOP', 0, -1)
		f.title:EnableMouse(true)
		f.title:SetScript('OnMouseDown', function(self,button)
			f:ClearAllPoints()
			f:StartMoving()
		end)
		f.title:SetScript('OnMouseUp', function(self, button)
			f:StopMovingOrSizing()
		end)
		f.titleText = f.title:CreateFontString('iTargetingFrames_OptionsTitleText')
		f.titleText:SetFont(font, 12, 'OUTLINE')
		f.titleText:SetPoint('CENTER', f.title, 'CENTER', 0,0)
		f.titleText:SetText('iTargetingFrames')
		--scroll frame
		f.scrollFrame = CreateFrame('ScrollFrame', nil, f)
		f.scrollFrame:SetSize(150, height)
		f.scrollFrame:SetPoint('TOPLEFT', f, 'TOPLEFT', 0,0)
		f.scrollFrame:SetBackdrop(bd)
		f.scrollFrame:SetBackdropColor(0.1,0.1,0.1,0.9)
		f.scrollFrame:SetBackdropBorderColor(0,0,0,1)
		f.scrollFrame:EnableMouseWheel(true)

		--Tree box
		f.treeBox = CreateFrame('frame', nil, f)
		f.treeBox:SetSize(150, height*2)
		f.treeBox:SetPoint('TOPLEFT', f, 'TOPLEFT', 0,0)
		f.scrollFrame:SetScrollChild(f.treeBox)
		
		--Slider
		f.slider = CreateFrame('Slider', nil, f)
		f.slider:SetSize(8,height)
		f.slider:SetThumbTexture('Interface\\AddOns\\iTargetingFrames\\media\\thumb')
		f.slider:SetBackdrop(bd)
		f.slider:SetBackdropColor(0.1,0.1,0.1,0.9)
		f.slider:SetBackdropBorderColor(0,0,0,1)
		f.slider:SetPoint('LEFT', f.scrollFrame, 'RIGHT', -1,0)
		f.slider:SetMinMaxValues(0, 500)
		f.slider:SetValue(0)
		f.slider:EnableMouseWheel(true)
		f.slider:SetScript('OnValueChanged', function(self, value)
			f.scrollFrame:SetVerticalScroll(value)
		end)
		local scrollFunc = function(self, delta)
			if delta == -1 then --down
				local value = f.slider:GetValue()+20
				local min, max = f.slider:GetMinMaxValues()
				value = math.min(value, max)
				f.slider:SetValue(value)
			else -- up
				local value = f.slider:GetValue()-20
				value = max(0, value)
				f.slider:SetValue(value)
			end
		end
		f.scrollFrame:SetScript('OnMouseWheel', scrollFunc)
		f.slider:SetScript('OnMouseWheel', scrollFunc)
		
		--Content frame scrollBox
		--Content box
		f.contentScrollFrame = CreateFrame('ScrollFrame', nil, f)
		f.contentScrollFrame:SetSize(437, height)
		f.contentScrollFrame:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -7,0)
		f.contentScrollFrame:SetBackdrop(bd)
		f.contentScrollFrame:SetBackdropColor(0.1,0.1,0.1,0.9)
		f.contentScrollFrame:SetBackdropBorderColor(0,0,0,1)
		f.contentScrollFrame:EnableMouseWheel(true)
		
		f.contentBox = CreateFrame('frame', nil, f)
		f.contentBox:SetSize(437, height*2)
		f.contentBox:SetPoint('TOP', f.contentScrollFrame, 'TOP', 0,0)
		f.contentScrollFrame:SetScrollChild(f.contentBox)
		
		--Contentbox Scroll
		f.contentSlider = CreateFrame('Slider', nil, f)
		f.contentSlider:SetSize(8,height)
		f.contentSlider:SetThumbTexture('Interface\\AddOns\\iTargetingFrames\\media\\thumb')
		f.contentSlider:SetBackdrop(bd)
		f.contentSlider:SetBackdropColor(0.1,0.1,0.1,0.9)
		f.contentSlider:SetBackdropBorderColor(0,0,0,1)
		--f.slider:SetOrientation('vertical')
		f.contentSlider:SetPoint('LEFT', f.contentScrollFrame, 'RIGHT', -1,0)
		f.contentSlider:SetMinMaxValues(0, 500)
		f.contentSlider:SetValue(0)
		f.contentSlider:EnableMouseWheel(true)
		f.contentSlider:SetScript('OnValueChanged', function(self, value)
			f.contentScrollFrame:SetVerticalScroll(value)
		end)
		local contentScrollFunc = function(self, delta)
			if delta == -1 then --down
				local value = f.contentSlider:GetValue()+20
				local min, max = f.contentSlider:GetMinMaxValues()
				value = math.min(value, max)
				f.contentSlider:SetValue(value)
			else -- up
				local value = f.contentSlider:GetValue()-20
				value = max(0, value)
				f.contentSlider:SetValue(value)
			end
		end
		f.contentScrollFrame:SetScript('OnMouseWheel', contentScrollFunc)
		f.contentSlider:SetScript('OnMouseWheel', contentScrollFunc)

		--Exit Button
		f.exit = CreateFrame('BUTTON', nil, f)
		f.exit:SetSize(18, 18)
		f.exit:SetBackdrop(bd)
		f.exit:SetBackdropColor(0.1,0.1,0.1,0.9)
		f.exit:SetBackdropBorderColor(0.8,0,0,1)
		f.exit:SetPoint('TOPRIGHT', f.title, 'TOPRIGHT', -1,-1)
		f.exit:RegisterForClicks('AnyUp')
		f.exit:SetFrameStrata('DIALOG')
		f.exit:SetScript('OnClick', function()
			iTF:toggleConfig(true)
		end)
		f.exit.text = f.exit:CreateFontString()
		f.exit.text:SetFont(font, 12, 'OUTLINE')
		f.exit.text:SetPoint('CENTER', f.exit, 'CENTER',0,0)
		f.exit.text:SetText('X')

		f:Show()	
		-- content/tree stuff
		f.frames = {
				['button'] = {},
		}
		f.content = {
				['button'] = {},
				['slider'] = {},
				['anchor'] = {},
				['toggle'] = {},
				['color'] = {},
				['select'] = {},
				['keybinding'] = {},
				['input'] = {},
				['text']= {},
				['exitButton'] = {},
				['scrollSelect'] = {},
				['scrollSelectChild'] = {},
		}
		local function getFrame(type, content, hideAll, count)
			local function isAvailable()
				if content then
					if hideAll then
						for k,v in pairs(f.content) do
							for i = 1, #f.content[k] do
								f.content[k][i]:Hide()
								f.content[k][i].inUse = false
							end
						end
					else
						for i = 1, #f.content[type] do
							if not f.content[type][i].inUse then
								return i
							end
						end
					end
				else
					if hideAll then
						for k,v in pairs(f.frames) do
							for i = 1, #f.frames[k] do
								f.frames[k][i]:Hide()
								f.frames[k][i].inUse = false
							end
						end
					else
						for i = 1, #f.frames[type] do
							if not f.frames[type][i].inUse then
								return i
							end
						end
					end
				end
			end
			local frame = isAvailable()
			if frame and not count then
				return frame
			end
			if content then
				local buttonBD = bd
				buttonBD.insets = {left = 1,right = 1,top = 1,bottom = 1}
				if type == 'button' then
					frame = #f.content.button+1
					f.content[type][frame] = CreateFrame('button', nil, f.contentBox)
					f.content[type][frame]:SetBackdrop(buttonBD)
					f.content[type][frame]:SetBackdropColor(0.2,0.2,0.2,0.9)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame]:RegisterForClicks('AnyUp')
					f.content[type][frame].text = f.content[type][frame]:CreateFontString()
					f.content[type][frame].text:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].text:SetPoint('CENTER', f.content[type][frame], 'CENTER', 2,0)
					f.content[type][frame].text:SetText(' ')
					return frame
				elseif type == 'slider' then
					frame = #f.content.slider+1
					f.content[type][frame] = CreateFrame('Slider', nil, f.contentBox)
					f.content[type][frame]:SetOrientation('horizontal')
					f.content[type][frame]:SetSize(100,8)
					f.content[type][frame]:SetThumbTexture('Interface\\AddOns\\iTargetingFrames\\media\\vthumb')
					f.content[type][frame]:SetBackdrop(bd)
					f.content[type][frame]:SetBackdropColor(0.2,0.2,0.2,0.9)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame].editbox = CreateFrame('Editbox',nil, f.content[type][frame])
					f.content[type][frame].editbox:SetBackdrop(bd)
					f.content[type][frame].editbox:SetBackdropColor(0.2,0.2,0.2,0.9)
					f.content[type][frame].editbox:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame].editbox:SetJustifyH('center')
					f.content[type][frame].editbox:SetAutoFocus(false)
					f.content[type][frame].editbox:SetSize(40, 16)
					f.content[type][frame].editbox:SetTextInsets(2, 2, 1, 0)
					f.content[type][frame].editbox:SetPoint('TOP', f.content[type][frame], 'BOTTOM', 0,-1)
					f.content[type][frame].editbox:SetFont(font, 12, 'OUTLINE')
					
					f.content[type][frame].text = f.content[type][frame]:CreateFontString()
					f.content[type][frame].text:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].text:SetPoint('BOTTOM', f.content[type][frame], 'TOP', 0,1)
					f.content[type][frame].text:SetText(' ')
					return frame
				elseif type == 'toggle' then
					frame = #f.content.toggle+1
					f.content[type][frame] = CreateFrame('CheckButton', nil, f.contentBox)
					f.content[type][frame].text = f.content[type][frame]:CreateFontString()
					f.content[type][frame]:SetBackdrop(buttonBD)
					f.content[type][frame]:SetBackdropColor(0.2,0.2,0.2,0.9)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame]:SetSize(16,16)
					f.content[type][frame]:SetCheckedTexture('Interface\\Buttons\\UI-CheckBox-Check')
					f.content[type][frame]:SetPoint('RIGHT', f.content[type][frame].text, 'LEFT', -2,0)
					
					f.content[type][frame].text:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].text:SetText(' ')
					return frame
				elseif type == 'select' then
					frame = #f.content[type]+1
					f.content[type][frame] = CreateFrame('button', nil, f.contentBox)
					f.content[type][frame]:SetBackdrop(buttonBD)
					f.content[type][frame]:SetBackdropColor(0.2,0.2,0.2,0.9)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame]:SetSize(100,20)
					f.content[type][frame]:EnableMouse(true)
					f.content[type][frame].text = f.content[type][frame]:CreateFontString()
					f.content[type][frame].text:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].text:SetPoint('CENTER', f.content[type][frame], 'CENTER', 0,0)
					f.content[type][frame].text:SetWidth(100)
					f.content[type][frame].text:SetHeight(20)
					f.content[type][frame].text:SetText(' ')
					f.content[type][frame].title = f.content[type][frame]:CreateFontString()
					f.content[type][frame].title:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].title:SetPoint('BOTTOM', f.content[type][frame], 'TOP', 0,3)
					f.content[type][frame].title:SetText(' ')				
					f.content[type][frame].menu = CreateFrame('Frame', 'iTF_EasyMenu' .. frame, f.contentBox, 'UIDropDownMenuTemplate')
					return frame
				elseif type == 'color' then
					frame = #f.content[type]+1
					f.content[type][frame] = CreateFrame('button', nil, f.contentBox)
					f.content[type][frame].text = f.content[type][frame]:CreateFontString()
					f.content[type][frame]:SetSize(16,16)
					f.content[type][frame]:SetBackdrop(buttonBD)
					f.content[type][frame]:SetBackdropColor(0,0,0,0)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame]:RegisterForClicks('AnyUp')
					f.content[type][frame]:SetPoint('RIGHT', f.content[type][frame].text, 'LEFT', -2,0)
					f.content[type][frame].text:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].text:SetText(' ')
					return frame
				elseif type == 'text' then
					frame = #f.content[type]+1
					f.content[type][frame] = f.contentBox:CreateFontString()
					f.content[type][frame]:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame]:SetText(' ')
					return frame
				elseif type == 'exitButton' then
					frame = #f.content.exitButton+1
					f.content[type][frame] = CreateFrame('button', nil, f.contentBox)
					f.content[type][frame]:SetSize(10,30)
					f.content[type][frame]:SetBackdrop(buttonBD)
					f.content[type][frame]:SetBackdropColor(1,0,0,0.9)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame]:RegisterForClicks('AnyUp')
					return frame
				elseif type == 'keybinding' then
					return getFrame('button', true)
				elseif type == 'input' then
					frame = #f.content[type]+1
					f.content[type][frame] = CreateFrame('editbox', nil, f.contentBox)
					f.content[type][frame]:SetSize(100,20)
					f.content[type][frame]:SetAutoFocus(false)
					f.content[type][frame]:SetTextInsets(2, 2, 1, 0)
					f.content[type][frame]:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame]:SetBackdrop(buttonBD)
					f.content[type][frame]:SetBackdropColor(0.2,0.2,0.2,0.9)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame].text = f.content[type][frame]:CreateFontString()
					f.content[type][frame].text:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].text:SetPoint('BOTTOM', f.content[type][frame], 'TOP', 0,3)
					return frame
				elseif type == 'scrollSelect' then
					frame = #f.content[type]+1
					f.content[type][frame] = CreateFrame('button', nil, f)
					f.content[type][frame]:SetBackdrop(buttonBD)
					f.content[type][frame]:SetBackdropColor(0.9,0.9,0.9,0.9)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame]:SetSize(100,20)
					f.content[type][frame]:EnableMouse(true)
					f.content[type][frame].text = f.content[type][frame]:CreateFontString()
					f.content[type][frame].text:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].text:SetPoint('CENTER', f.content[type][frame], 'CENTER', 0,0)
					f.content[type][frame].text:SetWidth(100)
					f.content[type][frame].text:SetHeight(20)
					f.content[type][frame].text:SetText(' ')
					f.content[type][frame].title = f.content[type][frame]:CreateFontString()
					f.content[type][frame].title:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].title:SetPoint('BOTTOM', f.content[type][frame], 'TOP', 0,3)
					f.content[type][frame].title:SetText(' ')
					f.content[type][frame].scrollFrame = CreateFrame('ScrollFrame', nil, f.content[type][frame])
					f.content[type][frame].scrollFrame:SetSize(100, 200)
					f.content[type][frame].scrollFrame:SetPoint('TOP', f.content[type][frame], 'BOTTOM', 0,0)
					f.content[type][frame].scrollFrame:SetBackdrop(bd)
					f.content[type][frame].scrollFrame:SetBackdropColor(0.1,0.1,0.1,0.9)
					f.content[type][frame].scrollFrame:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame].scrollFrame:EnableMouseWheel(true)
					--Menu
					f.content[type][frame].menu = CreateFrame('frame', nil, f.content[type][frame].scrollFrame)
					f.content[type][frame].menu:SetSize(100, 200)
					f.content[type][frame].menu:SetPoint('TOPLEFT', f.content[type][frame].scrollFrame, 'TOPLEFT', 0,0)
					f.content[type][frame].scrollFrame:SetScrollChild(f.content[type][frame].menu)
					
					--Slider
					f.content[type][frame].slider = CreateFrame('Slider', nil, f.content[type][frame].scrollFrame)
					f.content[type][frame].slider:SetSize(8,200)
					f.content[type][frame].slider:SetThumbTexture('Interface\\AddOns\\iTargetingFrames\\media\\thumb')
					f.content[type][frame].slider:SetBackdrop(bd)
					f.content[type][frame].slider:SetBackdropColor(0.1,0.1,0.1,0.9)
					f.content[type][frame].slider:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame].slider:SetPoint('LEFT', f.content[type][frame].scrollFrame, 'RIGHT', -1,0)
					f.content[type][frame].slider:SetMinMaxValues(0, 500)
					f.content[type][frame].slider:SetValue(0)
					f.content[type][frame].slider:EnableMouseWheel(true)
					f.content[type][frame].slider:SetScript('OnValueChanged', function(self, value)
						f.content[type][frame].scrollFrame:SetVerticalScroll(value)
					end)
					local function scrollFunc(self, delta)
						if delta == -1 then --down
							local value = f.content[type][frame].slider:GetValue()+20
							local min, max = f.content[type][frame].slider:GetMinMaxValues()
							value = math.min(value, max)
							f.content[type][frame].slider:SetValue(value)
						else -- up
							local value = f.content[type][frame].slider:GetValue()-20
							value = max(0, value)
							f.content[type][frame].slider:SetValue(value)
						end
					end
					f.content[type][frame].scrollFrame:SetScript('OnMouseWheel', scrollFunc)
					f.content[type][frame].slider:SetScript('OnMouseWheel', scrollFunc)
					f.content[type][frame]:SetScript('OnClick',function()
						if f.content[type][frame].scrollFrame:IsShown() then
							f.content[type][frame].scrollFrame:Hide()
							return
						end
						f.content[type][frame].scrollFrame:Show()
					end)
					return frame
				elseif type == 'scrollSelectChild' then
					frame = #f.content[type]+1
					f.content[type][frame] = CreateFrame('button', nil, f)
					f.content[type][frame]:SetBackdrop(buttonBD)
					f.content[type][frame]:SetBackdropColor(0.2,0.2,0.2,0.9)
					f.content[type][frame]:SetBackdropBorderColor(0,0,0,1)
					f.content[type][frame]:RegisterForClicks('AnyUp')
					f.content[type][frame].text = f.content[type][frame]:CreateFontString()
					f.content[type][frame].text:SetFont(font, 12, 'OUTLINE')
					f.content[type][frame].text:SetPoint('LEFT', f.content[type][frame], 'LEFT', 2,0)
					f.content[type][frame].text:SetText(' ')
					return frame
				elseif type == 'anchor' then
					while count > #f.content[type] do
						frame = #f.content[type]+1
						f.content[type][frame] = CreateFrame('frame', 'ITF_ '.. frame, f.contentBox)
						f.content[type][frame]:SetSize(146,60)
						f.content[type][frame]:SetFrameLevel(2)
						if frame == 1 then
							f.content[type][frame]:SetPoint('TOPLEFT', f.contentBox, 'TOPLEFT', 0,0)
						elseif frame == 2 then
							f.content[type][frame]:SetPoint('TOP', f.contentBox, 'TOP', 0,0)
						elseif frame == 3 then
							f.content[type][frame]:SetPoint('TOPRIGHT', f.contentBox, 'TOPRIGHT', 0,0)
						else
							if frame % 3 == 0 then
								f.content[type][frame]:SetPoint('TOPRIGHT', f.content[type][frame-3], 'BOTTOMRIGHT', 0,-1)
							else
								f.content[type][frame]:SetPoint('TOPLEFT', f.content[type][frame-3], 'BOTTOMLEFT', 0,-1)
							end
						end
						f.content[type][frame]:SetBackdrop(bd)
						f.content[type][frame]:SetBackdropColor(0,0,0,0)
						f.content[type][frame]:SetBackdropBorderColor(0,0,0,0)
					end
				end
			else
				if type == 'button' then
					local buttonBD = bd
					buttonBD.insets = {left = 1,right = 1,top = 1,bottom = 1}
					frame = #f.frames.button+1
					f.frames.button[frame] = CreateFrame('button', nil, f.treeBox)
					f.frames.button[frame]:SetBackdrop(buttonBD)
					f.frames.button[frame]:SetBackdropColor(0.2,0.2,0.2,0.9)
					f.frames.button[frame]:SetBackdropBorderColor(0,0,0,1)
					f.frames.button[frame]:RegisterForClicks('AnyUp')
					f.frames.button[frame].text = f.frames.button[frame]:CreateFontString()
					f.frames.button[frame].text:SetFont(font, 12, 'OUTLINE')
					f.frames.button[frame].text:SetPoint('LEFT', f.frames.button[frame], 'LEFT', 2,0)
					f.frames.button[frame].text:SetText(' ')
					return frame
				end
			end
		end
		local optionStuff = {}
		
		local function fillContent(keys)
			local t = optionFuncs.getOptions()
			for i = 1, #keys do
				if i == 1 then
					t = t[keys[i]]
				else
					if t.subGroups[keys[i]] then
						t = t.subGroups[keys[i]]
					end
				end
			end
			getFrame(nil, true, true)
			local argCount = 0
			local function resizeScrollFrame()
				local size = 0
				for i = 1, argCount, 3 do
					size = size + f.content.anchor[i]:GetHeight() + 1
				end
				size = size + 5
				f.contentBox:SetHeight(size)
				f.contentSlider:SetMinMaxValues(0, math.max(size-height+3,0))
			end
			for k,v in spairs(t.args,function(t,a,b) return t[b].order > t[a].order end) do
				if not v.show or (v.show and v.show()) then
					argCount = argCount + 1
					getFrame('anchor', true, nil, argCount)
					f.content.anchor[argCount]:SetSize(146,60)
					f.content.anchor[argCount]:SetBackdropColor(0,0,0,0)
					f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,0)
					local name = v.name
					local id = getFrame(v.type, true)
					if v.type == 'button' then
						f.content[v.type][id]:SetSize(100, 20)
						f.content[v.type][id]:ClearAllPoints()
						f.content[v.type][id]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,0)
						if v.updateOnClick and v.refreshTree then
							f.content[v.type][id]:SetScript('OnClick', function()
								local refresh = v.func()
								if refresh then
									optionStuff.loadTree()
									fillContent(keys)
								end
							end)
						elseif v.refreshTree then
							f.content[v.type][id]:SetScript('OnClick', function()
								local refresh = v.func()
								if refresh then
									v.func()
									optionStuff.loadTree()
								end
							end)
						elseif v.updateOnClick then
							f.content[v.type][id]:SetScript('OnClick', function()
								local refresh = v.func()
								if refresh then
									fillContent(keys)
								end
							end)
						else
							f.content[v.type][id]:SetScript('OnClick', v.func)
						end
						f.content[v.type][id].inUse = k
						f.content[v.type][id].text:SetText(v.name)
						f.content[v.type][id]:Show()
					elseif v.type == 'slider' then
						f.content.slider[id]:ClearAllPoints()
						f.content.slider[id]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,0)
						f.content.slider[id]:SetScript('OnValueChanged', nil)
						f.content.slider[id]:SetMinMaxValues(v.min,v.max)
						f.content.slider[id]:SetValue(v.get())
						f.content.slider[id].editbox:SetNumber(v.get())
						f.content.slider[id].inUse = k
						f.content.slider[id]:Show()
						f.content.slider[id].text:SetText(v.name)
						f.content.slider[id].editbox:SetScript('OnEnterPressed', function(self)
							self:ClearFocus()
							if tonumber(self:GetText()) then
								f.content.slider[id]:SetValue(tonumber(self:GetText()))
							else
								f.content.slider[id]:SetValue(0)
							end
						end)
						f.content.slider[id]:SetScript('OnValueChanged', function(self, value)
							if v.allowDecimals then
								value = math.floor((value*v.allowDecimals)+0.5)/v.allowDecimals
							else
								value = math.floor(value)
							end
							v.set(value)
							f.content.slider[id].editbox:SetNumber(value)
						end)
					elseif v.type == 'toggle' then
						f.content.toggle[id].text:ClearAllPoints()
						f.content.toggle[id].text:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 9,0)
						f.content.toggle[id]:SetChecked(v.get())
						f.content.toggle[id].inUse = k
						f.content.toggle[id].text:SetText(v.name)
						f.content.toggle[id]:Show()
						f.content.toggle[id]:SetScript('OnClick', function(self, button, down)
							v.set(self:GetChecked())
							if v.updateOnClick then
								fillContent(keys)
							end
						end)
					elseif v.type == 'select' then
						f.content[v.type][id]:ClearAllPoints()
						f.content[v.type][id]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,-5)
						f.content[v.type][id].title:SetText(v.name)
						local function setButtonText(str)
							if v.multiselect then
								local temp = {}
								if v.values then
									for subK,subV in spairs(v.values) do
										if type(subV) == 'table' then
											for subKey, subValue in pairs(subV) do
												if v.get(subKey) then
													table.insert(temp, subValue)
												end
											end
										else
											if v.get(subK) then
												table.insert(temp,subV)
											end
										end
									end
								end
								if #temp == 0 and str then
									f.content.select[id].text:SetText(str)
								else
									f.content.select[id].text:SetText(table.concat(temp, ','))
								end
							else
								if t.bindings then
									f.content[v.type][id].text:SetText(bindingStuff.mode)
								else
									if v.invertValue then
										local valueToFind = v.get()
										for key,value in pairs(v.values) do
											if value == valueToFind then
												f.content[v.type][id].text:SetText(value)
												return
											end
										end
									else
										f.content[v.type][id].text:SetText(v.values[v.get()])
									end
								end
							end
						end
						local function getMenuTable()
							local t = {}
							for subK,subV in spairs(v.values) do
								if type(subV) == 'table' then
									local temp = {}
									temp.text = subK
									temp.isTitle = true
									temp.isNotRadio = true
									temp.disabled = true
									temp.notCheckable = true
									temp.notClickable = true
									table.insert(t,temp)
									for subKey, subValue in pairs(subV) do
										temp = {}
										temp.text = subValue
										temp.keepShownOnClick = true
										temp.isNotRadio = true
										temp.checked = v.get(subKey)
										temp.func = function(data,_,_,checked)
											v.set(subKey,checked)
											setButtonText(L.all)
										end
										table.insert(t, temp)
									end
								else
									local temp = {}
									temp.text = subV
									if not tonumber(k) then
										temp.value = subK
									end
									if v.multiselect then
										temp.keepShownOnClick = true
										temp.isNotRadio = true
										temp.checked = v.get(subK)
										temp.func = function(data,_,_,checked)
											v.set(subK,checked)
											setButtonText()
										end
									
									else
										temp.arg1 = subV
										temp.notCheckable = true
										temp.func = function(data)
											v.set(data.value, data)
											f.content.select[id].text:SetText(v.values[data.value])
											if v.updateOnClick then
												fillContent(keys)
											end
										end
									end
									table.insert(t, temp)
								end
							end
							table.insert(t, {text = L.close, func = function() CloseDropDownMenus() end, notCheckable = true})
							return t
						end
						f.content[v.type][id]:SetScript('OnClick',function()
							if UIDROPDOWNMENU_OPEN_MENU then
								CloseDropDownMenus()
								UIDROPDOWNMENU_OPEN_MENU = nil;
								return
							end
							EasyMenu(getMenuTable(), f.content[v.type][id].menu,f.content[v.type][id], 0 , 0)
						end)
						f.content[v.type][id].inUse = k
						f.content[v.type][id]:Show()
						setButtonText(v.loadConds and L.all)
					elseif v.type == 'color' then
						f.content[v.type][id].text:ClearAllPoints()
						f.content[v.type][id].text:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 9,0)
						f.content[v.type][id].inUse = k
						f.content[v.type][id].text:SetText(v.name)
						f.content[v.type][id]:SetBackdropColor(v.get())
						f.content[v.type][id]:SetScript('OnClick' , function()
							local r,g,b,a = v.get()
							ColorPickerFrame.hasOpacity = true 
							ColorPickerFrame.opacity = 1-a
							ColorPickerFrame.previousValues = {r,g,b,a}
							ColorPickerFrame.func = function()
									local a = OpacitySliderFrame:GetValue()
									local r,g,b = ColorPickerFrame:GetColorRGB()
									a = 1-a
									f.content[v.type][id]:SetBackdropColor(r,g,b,a)
									v.set(r,g,b,a)
							end
							ColorPickerFrame.opacityFunc = function()
									local a = OpacitySliderFrame:GetValue()
									local r,g,b = ColorPickerFrame:GetColorRGB()
									a = 1-a
									f.content[v.type][id]:SetBackdropColor(r,g,b,a)
									v.set(r,g,b,a)
							end
							ColorPickerFrame.cancelFunc = function(colors)
								v.set(unpack(colors))
								f.content[v.type][id]:SetBackdropColor(unpack(colors))
							end
							ColorPickerFrame:SetColorRGB(r,g,b)
							ColorPickerFrame:Hide() -- Need to run the OnShow handler.
							ColorPickerFrame:Show()
						end)
						f.content[v.type][id]:Show()
					elseif v.type == 'keybinding' then
						f.content.button[id]:SetSize(100, 20)
						f.content.button[id]:ClearAllPoints()
						f.content.button[id]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,-5)
						local keyMode = false
						local clickTime = GetTime()
						local function key(key)
							clickTime = GetTime()
							if string.find(key, 'ALT') or string.find(key, 'CTRL') or string.find(key, 'SHIFT') then
								return
							end
							--alt-ctrl-shift-type
							local toShow = ''
							local modifier = ''
							if IsAltKeyDown() then
								modifier = modifier .. 'ALT-'
								toShow = toShow .. 'Alt+'
							end
							if IsControlKeyDown() then
								modifier = modifier .. 'CTRL-'
								toShow = toShow .. 'Ctrl+'
							end
							if IsShiftKeyDown() then
								modifier = modifier .. 'SHIFT-'
								toShow = toShow .. 'Shift+'
							end
							toShow = toShow .. key
							if key == 'ESCAPE' then
								
							else
								v.set(modifier..key)
								f.content.button[id].text:SetText(toShow)
							end
							
							showBindingModeWarning(true)
							f.content.button[id]:EnableKeyboard(false)
							f.content.button[id]:EnableMouseWheel(false)
							f.content.button[id]:SetBackdropColor(0.2,0.2,0.2,0.9)
							keyMode = false
						end
						f.content.button[id]:SetScript('OnClick', function()
							if not keyMode and (GetTime() - clickTime > 0.2)then
								keyMode = true
								showBindingModeWarning()
								f.content.button[id]:SetScript('OnMouseDown', function(self, k) if keyMode then key(k) end end)
								f.content.button[id]:SetScript('OnMouseWheel', function(self, delta)
									if delta == -1 then 
										key('MouseWheelDown')
									else
										key('MouseWheelUp')
									end
								end)
								f.content.button[id]:SetScript('OnKeyDown', function(self, k) key(k) end)
								f.content.button[id]:SetBackdropColor(0.5,0,0,1)
								f.content.button[id]:EnableKeyboard(true)
								f.content.button[id]:EnableMouseWheel(true)
							end
						end)
						local bindingText = getFrame('text', true)
						f.content.text[bindingText]:ClearAllPoints()
						f.content.text[bindingText]:SetWidth(0)
						f.content.text[bindingText]:SetPoint('BOTTOM', f.content.button[id], 'TOP', 0,3)
						f.content.text[bindingText].inUse = k
						f.content.text[bindingText]:SetText(v.name)
						f.content.text[bindingText]:Show()
						f.content.button[id].inUse = k
						f.content.button[id].text:SetText(bindingStuff.key)
						f.content.button[id]:Show()
					elseif v.type == 'scrollSelect' then
						f.content[v.type][id]:ClearAllPoints()
						f.content[v.type][id]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,-5)
						f.content[v.type][id].title:SetText(v.name)
						local function setButtonText()
							if v.invertValue then
								--local valueToFind = v.get()
								--for key,value in pairs(v.values) do
								--	if value == valueToFind then
								--		f.content[v.type][id].text:SetText(value)
								--		return
								--	end
								--end
								f.content[v.type][id].text:SetText(v.get())
							else
								f.content[v.type][id].text:SetText(v.values[v.get()])
							end
						end
						local i = 0
						--spairs(spells, function(t,a,b) return t[b].spell > t[a].spell end)
						for subK,subV in spairs(v.values, function(t,a,b) return t[a] > t[b] end) do
							i = i + 1 
							local button = getFrame('scrollSelectChild', true)
							f.content.scrollSelectChild[button]:ClearAllPoints()
							f.content.scrollSelectChild[button]:SetParent(f.content[v.type][id].menu)
							f.content.scrollSelectChild[button]:SetSize(100, 20)
							if v.font then
								f.content.scrollSelectChild[button].text:SetFont(LibStub('LibSharedMedia-3.0'):Fetch('font', subV), 12, 'Outline')
							else
								f.content.scrollSelectChild[button].text:SetFont(font, 12, 'Outline')
							end
							f.content.scrollSelectChild[button].text:SetText(subV)
							f.content.scrollSelectChild[button]:SetPoint('TOP', f.content[v.type][id].menu, 'BOTTOM', 0,(i-1)*20)					
							f.content.scrollSelectChild[button].inUse = 'scrollSelect'
							f.content.scrollSelectChild[button]:SetScript('OnClick', function()
								if not tonumber(subK) then
									v.set(subK)
									f.content[v.type][id].text:SetText(subK)
								else
									v.set(subV)
									f.content[v.type][id].text:SetText(subV)
								end
							end)
							f.content.scrollSelectChild[button]:Show()
						end
						f.content[v.type][id].menu:SetHeight((i-1)*20)
						f.content[v.type][id].slider:SetMinMaxValues(0, math.max((i-1)*20-200,0))
						f.content[v.type][id].scrollFrame:Hide()
						f.content[v.type][id].inUse = k
						f.content[v.type][id]:Show()
						setButtonText()
					elseif v.type == 'input' then
						f.content[v.type][id]:ClearAllPoints()
						f.content[v.type][id]:SetText('')
						if v.size and v.size == 'huge' then
							if argCount % 3 == 0 then
								argCount = argCount + 1
							elseif argCount % 3 == 2 then
								argCount = argCount + 2
							end
							getFrame('anchor', true, nil, argCount+2)
							f.content[v.type][id]:SetSize(433, 15)
							local count = argCount
							f.content[v.type][id]:SetPoint('TOPLEFT', f.content.anchor[argCount], 'TOPLEFT', 2,0)
							f.content[v.type][id]:SetMultiLine(true)
							f.content[v.type][id]:SetText(v.get())
							f.content[v.type][id]:SetScript('OnSizeChanged', function(self, width, height)
								f.content.anchor[count]:SetHeight(height + 20)
								f.content.anchor[count+1]:SetHeight(height + 20)
								f.content.anchor[count+2]:SetHeight(height + 20)
								resizeScrollFrame()
							end)
							f.content.anchor[argCount]:SetHeight(f.content[v.type][id]:GetHeight() + 20)
							if v.code then
								local function getFunc(str)
									local f, err = loadstring('return ' .. str .. ' ', 'nameplate1')
									if f then return f() else return f, err end
								end
								local okButton = getFrame('button', true)
								f.content.button[okButton]:ClearAllPoints()
								f.content.button[okButton]:SetSize(100, 20)
								f.content.button[okButton].text:SetText(L.ok)
								f.content.button[okButton]:SetPoint('BOTTOMLEFT', f.content.anchor[argCount], 'BOTTOMLEFT', 2,-1)
								f.content.button[okButton].inUse = 'editbox'
								f.content.button[okButton]:SetScript('OnClick', function()
									if v.edit then
										local func, e = getFunc(f.content[v.type][id]:GetText())
										if e then
											iTF:print(L.errorCustomCode)
										else
											f.content[v.type][id]:ClearFocus()
											v.set(f.content[v.type][id]:GetText())
										end
									else
										if isCustomOK.func then
											customCondTemp.func = f.content[v.type][id]:GetText()
											f.content[v.type][id]:ClearFocus()
										else
											iTF:print(L.errorCustomCode)
										end
									end
								end)
								f.content.button[okButton]:Show()

								local errorText = getFrame('text', true)
								f.content.text[errorText]:ClearAllPoints()
								f.content.text[errorText]:SetPoint('TOPLEFT',	f.content.button[okButton], 'TOPRIGHT', 2,0)
								f.content.text[errorText]:SetWidth(331)
								f.content.text[errorText]:SetHeight(40)
								f.content.text[errorText]:SetJustifyH('LEFT')
								f.content.text[errorText]:SetJustifyV('TOP')
								f.content.text[errorText].inUse = 'customCond'
								f.content.text[errorText]:SetText('')
								f.content.text[errorText]:Show()
								f.content[v.type][id]:SetScript('OnTextChanged', function(self)
									local func, e = getFunc(self:GetText())
									if e then
										f.content.text[errorText]:SetText(e)
										if not v.edit then
											isCustomOK.func = false
										end
									else
										f.content.text[errorText]:SetText('')
										if not v.edit then
											isCustomOK.func = true
										end
									end
								end)
								f.content[v.type][id]:SetScript('OnEnterPressed', nil)
							else
								f.content[v.type][id]:SetScript('OnTextChanged', nil)
							end
						else
							if v.onCharUpdate then
								f.content[v.type][id]:SetScript('OnTextChanged', function(self)
									v.set(self:GetText())
								end)
							else
								f.content[v.type][id]:SetScript('OnTextChanged', nil)
							end
							f.content[v.type][id]:SetSize(100, 20)
							f.content[v.type][id]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,-5)
							f.content[v.type][id]:SetMultiLine(false)
							f.content[v.type][id]:SetText(v.get())
							f.content[v.type][id]:SetScript('OnEnterPressed', function(self)
								v.set(self:GetText())
								self:ClearFocus()
								if v.updateOnClick then
									self:SetText('')
									fillContent(keys)
								end
							end)
						end
						f.content[v.type][id].inUse = k
						f.content[v.type][id].text:SetText(v.name)
						f.content[v.type][id]:Show()
					else
						iTF:print('debug: option type: ',v.type, ', report it.') --DEBUG
					end
					f.content.anchor[argCount].inUse = k
					f.content.anchor[argCount]:Show()
					if v.size and v.size == 'huge' then
						argCount = argCount + 2
						getFrame('anchor', true, nil, argCount)
					end
				end
			end
			if t.bindings then -- Use different layout for bindings tab
				local tableToLoop
				if t.bindings == 'general' then
					tableToLoop = iTFConfig.bindings.general
					--titleText = titleText .. 'General'
				elseif t.bindings == 'class' then
					tableToLoop = iTFConfig.bindings[iTF.class].b
				else --spec
					tableToLoop = iTFConfig.bindings[iTF.class][iTF.specID]
					--titleText = titleText .. select(2,GetSpecializationInfoByID(iTF.specID))			
				end
				
				-- making sure bindings start at the first column
				if argCount % 3 == 2 then
					argCount = argCount + 1
				elseif argCount % 3 == 1 then
					argCount = argCount + 2
				end
				for key,v in spairs(tableToLoop) do
					argCount = argCount + 1
					while (argCount % 3 == 2) do
						argCount = argCount + 1
					end
					getFrame('anchor', true, nil, argCount)
					f.content.anchor[argCount]:SetSize(218,30)
					f.content.anchor[argCount].inUse = 'bindings'
					f.content.anchor[argCount]:SetBackdropColor(0.2,0.2,0.2,0.5)
					f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,1)
					
					local exitButton = getFrame('exitButton', true)
					f.content.exitButton[exitButton]:SetHeight(30)
					f.content.exitButton[exitButton]:ClearAllPoints()
					f.content.exitButton[exitButton]:SetPoint('LEFT', f.content.anchor[argCount], 'LEFT', 0,0)
					f.content.exitButton[exitButton].inUse = 'bindings'
					f.content.exitButton[exitButton]:SetScript('OnClick', function()
						if t.bindings == 'general' then
							iTFConfig.bindings.general[key] = nil
						elseif t.bindings == 'class' then
							iTFConfig.bindings[iTF.class].b[key] = nil
						else --spec
							iTFConfig.bindings[iTF.class][iTF.specID][key] = nil
						end
						fillContent(keys)
						iTF:updateFrames('bindings')
					end)
					f.content.exitButton[exitButton]:Show()
					
					local bindingText = getFrame('text', true)
					f.content.text[bindingText]:ClearAllPoints()
					if not v.text then
						f.content.text[bindingText]:SetPoint('LEFT', f.content.exitButton[exitButton], 'RIGHT', 2,0)
					else
						f.content.text[bindingText]:SetPoint('TOPLEFT', f.content.exitButton[exitButton], 'TOPRIGHT', 2,0)
					end
					f.content.text[bindingText].inUse = 'bindings'
					f.content.text[bindingText]:SetText(key .. ' (' .. L[v.type] .. ')')
					f.content.text[bindingText]:Show()
					
					if v.text then
						local contentText = getFrame('text', true)
						f.content.text[contentText]:ClearAllPoints()
						f.content.text[contentText]:SetPoint('BOTTOMLEFT', f.content.exitButton[exitButton], 'BOTTOMRIGHT', 2,1)
						f.content.text[contentText]:SetWidth(214)
						f.content.text[contentText]:SetHeight(12)
						f.content.text[contentText]:SetJustifyH('LEFT')
						f.content.text[contentText]:SetJustifyV('BOTTOM')
						f.content.text[contentText].inUse = 'bindings'
						if v.text:match("%/script SetRaidTarget%('mouseover', (%d)%)") then
							local raidIcon = v.text:match("%/script SetRaidTarget%('mouseover', (%d)%)")
							if raidIcon == '0' then
								f.content.text[contentText]:SetText(L.raidIcon .. ': ' .. L.clear)
							else
								f.content.text[contentText]:SetText(string.format('%s: |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t', L.raidIcon, raidIcon))
							end
						else
							f.content.text[contentText]:SetText(v.text)
						end
						f.content.text[contentText]:Show()
					end
					f.content.anchor[argCount]:Show()
				end
			end
			if t.blacklist then -- Use different layout for blacklist tab
				local spells = {}
				for k,v in pairs(iTFConfig.blacklist) do
					if v then
						if tonumber(k) then
							local spellName = GetSpellInfo(tonumber(k))
							table.insert(spells, {['spell'] = string.format('%s (%s)', spellName or L.spellNotFound, k), ['id'] = k})
						else
							table.insert(spells, {['spell'] = k, ['id'] = k})
						end
					end
				end
				-- making sure blacklist starts at the first column
				if #spells >= 1 then
					if argCount % 3 == 2 then
						argCount = argCount + 1
					elseif argCount % 3 == 1 then
						argCount = argCount + 2
					end
				end
				for k,v in spairs(spells, function(t,a,b) return t[b].spell > t[a].spell end) do
					argCount = argCount + 1
					while (argCount % 3 == 2) do
						argCount = argCount + 1
					end
					getFrame('anchor', true, nil, argCount)
					f.content.anchor[argCount]:SetSize(218,20)
					f.content.anchor[argCount].inUse = 'blacklist'
					f.content.anchor[argCount]:SetBackdropColor(0.2,0.2,0.2,0.5)
					f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,1)
					
					local exitButton = getFrame('exitButton', true)
					f.content.exitButton[exitButton]:SetHeight(20)
					f.content.exitButton[exitButton]:ClearAllPoints()
					f.content.exitButton[exitButton]:SetPoint('LEFT', f.content.anchor[argCount], 'LEFT', 0,0)
					f.content.exitButton[exitButton].inUse = 'blacklist'
					f.content.exitButton[exitButton]:SetScript('OnClick', function()
						if iTF.auraBlacklist[v.id] then
							iTFConfig.blacklist[v.id] = false
						else
							iTFConfig.blacklist[v.id] = nil
						end
						fillContent(keys)
					end)
					f.content.exitButton[exitButton]:Show()
					local contentText = getFrame('text', true)
					f.content.text[contentText]:ClearAllPoints()
					f.content.text[contentText]:SetPoint('LEFT', f.content.exitButton[exitButton], 'RIGHT', 2,0)
					f.content.text[contentText]:SetWidth(214)
					f.content.text[contentText]:SetHeight(15)
					f.content.text[contentText]:SetJustifyH('LEFT')
					f.content.text[contentText]:SetJustifyV('MIDDLE')
					f.content.text[contentText].inUse = 'blacklist'
					f.content.text[contentText]:SetText(v.spell)
					f.content.text[contentText]:Show()
					f.content.anchor[argCount]:Show()
				end
			end
			if t.priorityNPCs then -- Use different layout for blacklist tab
				local npcs = {}
				for k,v in pairs(iTFConfig.priorityNPCs) do
					if v then
						if type(v) == 'boolean' then
							table.insert(npcs, {['npc'] = k, ['id'] = k})
						else
							table.insert(npcs, {['npc'] = string.format('%s (%s)', tostring(k), v), ['id'] = k})
						end
					end
				end
				-- making sure npc stuff starts at the first column
				if argCount % 3 == 0 then
					f.content.anchor[argCount]:SetHeight(60)
					f.content.anchor[argCount].inUse = 'priorityNpcs'
					f.content.anchor[argCount]:SetBackdropColor(0,0,0,0)
					f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,0)
					f.content.anchor[argCount]:Show()
					argCount = argCount + 1
				elseif argCount % 3 == 2 then
					f.content.anchor[argCount]:SetHeight(60)
					f.content.anchor[argCount].inUse = 'priorityNpcs'
					f.content.anchor[argCount]:SetBackdropColor(0,0,0,0)
					f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,0)
					if f.content.anchor[argCount+1] then
						f.content.anchor[argCount+1]:SetHeight(60)
						f.content.anchor[argCount+1].inUse = 'priorityNpcs'
						f.content.anchor[argCount+1]:SetBackdropColor(0,0,0,0)
						f.content.anchor[argCount+1]:SetBackdropBorderColor(0,0,0,0)
						f.content.anchor[argCount+1]:Show()
					end
					argCount = argCount + 2
				end
				getFrame('anchor', true, nil, argCount+6)
				f.content.anchor[argCount]:SetSize(433, 20)
				f.content.anchor[argCount].inUse = 'priorityNpcs'
				f.content.anchor[argCount]:Show()
				f.content.anchor[argCount]:SetBackdropColor(0.2,0.2,0.2,0.5)
				f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,1)
				local titleText = getFrame('text', true)
				f.content.text[titleText]:ClearAllPoints()
				f.content.text[titleText]:SetPoint('LEFT', f.content.anchor[argCount], 'LEFT', 2,0)
				f.content.text[titleText]:SetJustifyH('LEFT')
				f.content.text[titleText]:SetJustifyV('MIDDLE')
				f.content.text[titleText].inUse = 'priorityNpcs'
				f.content.text[titleText]:SetText(L.priorityNPCs)
				f.content.text[titleText]:Show()
				argCount = argCount + 1
				f.content.anchor[argCount]:SetHeight(20)
				f.content.anchor[argCount].inUse = 'priorityNpcs'
				f.content.anchor[argCount]:SetBackdropColor(0,0,0,0)
				f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,0)
				f.content.anchor[argCount]:Show()
				argCount = argCount + 1
				f.content.anchor[argCount]:SetHeight(20)
				f.content.anchor[argCount].inUse = 'priorityNpcs'
				f.content.anchor[argCount]:SetBackdropColor(0,0,0,0)
				f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,0)
				f.content.anchor[argCount]:Show()
				argCount = argCount + 1
				--NPC
				--getFrame('anchor', true, nil, argCount)
				f.content.anchor[argCount]:SetSize(146,60)
				f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,0)
				f.content.anchor[argCount]:SetBackdropColor(0,0,0,0)
				f.content.anchor[argCount].inUse = 'priorityNpcs'
				local npcEditBox = getFrame('input', true, nil, argCount)
				f.content.input[npcEditBox]:ClearAllPoints()
				f.content.input[npcEditBox]:SetScript('OnTextChanged', nil)
				f.content.input[npcEditBox]:SetSize(100, 20)
				f.content.input[npcEditBox]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,-5)
				f.content.input[npcEditBox]:SetMultiLine(false)
				f.content.input[npcEditBox]:SetText('')
				f.content.input[npcEditBox]:SetScript('OnEnterPressed', function(self)
					priorityNPCsStuff.text = self:GetText()
					self:ClearFocus()
				end)
				f.content.input[npcEditBox].inUse = 'priorityNpcs'
				f.content.input[npcEditBox].text:SetText(L.npcIDorName)
				f.content.input[npcEditBox]:Show()
				f.content.anchor[argCount]:Show()
				argCount = argCount + 1
				--Comment
				--getFrame('anchor', true, nil, argCount)
				f.content.anchor[argCount]:SetSize(146,60)
				f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,0)
				f.content.anchor[argCount]:SetBackdropColor(0,0,0,0)
				f.content.anchor[argCount].inUse = 'priorityNpcs'
				local commentBox = getFrame('input', true, nil, argCount)
				f.content.input[commentBox]:ClearAllPoints()
				f.content.input[commentBox]:SetScript('OnTextChanged', nil)
				f.content.input[commentBox]:SetSize(100, 20)
				f.content.input[commentBox]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,-5)
				f.content.input[commentBox]:SetMultiLine(false)
				f.content.input[commentBox]:SetText('')
				f.content.input[commentBox]:SetScript('OnEnterPressed', function(self)
					priorityNPCsStuff.comment = self:GetText()
					self:ClearFocus()
				end)
				f.content.input[commentBox].inUse = 'priorityNpcs'
				f.content.input[commentBox].text:SetText(L.comment)
				f.content.input[commentBox]:Show()
				f.content.anchor[argCount]:Show()
				argCount = argCount + 1
				--Add new
				--getFrame('anchor', true, nil, argCount)
				f.content.anchor[argCount]:SetSize(146,60)
				f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,0)
				f.content.anchor[argCount]:SetBackdropColor(0,0,0,0)
				f.content.anchor[argCount]:Show()
				f.content.anchor[argCount].inUse = 'priorityNpcs'
				local addNewNPC = getFrame('button', true, nil, argCount)
				f.content.button[addNewNPC]:SetSize(100, 20)
				f.content.button[addNewNPC]:ClearAllPoints()
				f.content.button[addNewNPC]:SetPoint('CENTER', f.content.anchor[argCount], 'CENTER', 0,-5)
				f.content.button[addNewNPC]:SetScript('OnClick', function()
					if priorityNPCsStuff.text and priorityNPCsStuff.text:len() >= 2 then
						if priorityNPCsStuff.comment and priorityNPCsStuff.comment:len() >= 1 then
							iTargetingFrames:PrioNPC(priorityNPCsStuff.text,priorityNPCsStuff.comment)
						else
							iTargetingFrames:PrioNPC(priorityNPCsStuff.text)
						end
						priorityNPCsStuff.text = ''
						priorityNPCsStuff.comment = ''
						fillContent(keys)
					else
						iTF:print(L.errorNPC)
					end
				end)
				f.content.button[addNewNPC].inUse = 'priorityNpcs'
				f.content.button[addNewNPC].text:SetText(L.addNew)
				f.content.button[addNewNPC]:Show()
				for k,v in spairs(npcs, function(t,a,b) return t[b].npc > t[a].npc end) do
					argCount = argCount + 1
					while (argCount % 3 == 2) do
						argCount = argCount + 1
					end
					getFrame('anchor', true, nil, argCount)
					f.content.anchor[argCount]:SetSize(218,20)
					f.content.anchor[argCount].inUse = 'priorityNpcs'
					f.content.anchor[argCount]:SetBackdropColor(0.2,0.2,0.2,0.5)
					f.content.anchor[argCount]:SetBackdropBorderColor(0,0,0,1)
					
					local exitButton = getFrame('exitButton', true)
					f.content.exitButton[exitButton]:SetHeight(20)
					f.content.exitButton[exitButton]:ClearAllPoints()
					f.content.exitButton[exitButton]:SetPoint('LEFT', f.content.anchor[argCount], 'LEFT', 0,0)
					f.content.exitButton[exitButton].inUse = 'priorityNpcs'
					f.content.exitButton[exitButton]:SetScript('OnClick', function()
						if iTF.priorityNPCs[v.id] then
							iTFConfig.priorityNPCs[v.id] = false
						else
							iTFConfig.priorityNPCs[v.id] = nil
						end
						iTF:updateFrames('conditionals')
						fillContent(keys)
					end)
					f.content.exitButton[exitButton]:Show()
					local contentText = getFrame('text', true)
					f.content.text[contentText]:ClearAllPoints()
					f.content.text[contentText]:SetPoint('LEFT', f.content.exitButton[exitButton], 'RIGHT', 2,0)
					f.content.text[contentText]:SetWidth(214)
					f.content.text[contentText]:SetHeight(15)
					f.content.text[contentText]:SetJustifyH('LEFT')
					f.content.text[contentText]:SetJustifyV('MIDDLE')
					f.content.text[contentText].inUse = 'priorityNpcs'
					f.content.text[contentText]:SetText(v.npc)
					f.content.text[contentText]:Show()
					f.content.anchor[argCount]:Show()
				end
			end
			--resize scrollframe
			resizeScrollFrame()
		end
		function optionStuff.loadTree()
			options = optionFuncs.getOptions()
			for k in pairs(f.frames.button) do
				f.frames.button[k]:Hide()
				f.frames.button[k].inUse = false
			end
			local isFirst = true
			local line = 0
			for k,v in spairs(options, function(t,a,b) return t[b].order > t[a].order end) do
			--for i = 1, #options do -- w = 146
				line = line + 1
				local name = v.name
				local id = getFrame('button')
				f.frames.button[id]:SetSize(146, 20)
				if isFirst then
					f.frames.button[id]:SetPoint('TOPRIGHT', f.treeBox, 'TOPRIGHT', -2,-2)
					isFirst = false
				else
					f.frames.button[id]:SetPoint('TOPRIGHT', f.frames.button[id-1], 'BOTTOMRIGHT', 0,-1)
				end
				f.frames.button[id].inUse = k
				f.frames.button[id]:Show()
				f.frames.button[id]:SetScript('OnClick',function()
					CloseDropDownMenus()
					for k,v in pairs(f.frames.button) do
						if k == id then
							f.frames.button[id]:SetBackdropBorderColor(1,1,0,1)
						else
							f.frames.button[k]:SetBackdropBorderColor(0,0,0,1)
						end
					end
					fillContent({k})
				end)
				--sub options
				local function createSubGroups(t, depth, keys)
					for subK,subV in spairs(t, function(t,a,b) return t[b].order > t[a].order end) do
					--for subI = 1, #t do
						local keyTable = {}
						
						for i = 1, #keys do
							table.insert(keyTable, keys[i])
						end
						table.insert(keyTable, subK)
						local buttonKey = table.concat(keyTable, '-')
						line = line + 1
						local name = subV.name
						local id = getFrame('button')
						local width = 146 - depth * 26
						f.frames.button[id]:SetSize(width, 20)
						f.frames.button[id]:SetPoint('TOPRIGHT', f.frames.button[id-1], 'BOTTOMRIGHT', 0,-1)
						f.frames.button[id].text:SetText(' ' .. name)
						f.frames.button[id].inUse = buttonKey
						f.frames.button[id]:Show()
						f.frames.button[id]:SetScript('OnClick',function()
							CloseDropDownMenus()
							for k,v in pairs(f.frames.button) do
								if k == id then
									f.frames.button[id]:SetBackdropBorderColor(1,1,0,1)
								else
									f.frames.button[k]:SetBackdropBorderColor(0,0,0,1)
								end
							end
							fillContent(keyTable)
						end)
						if subV.subGroups then
							f.frames.button[id].text:SetText('-  ' .. name)
							createSubGroups(subV.subGroups, depth+1, keyTable)
						else
							f.frames.button[id].text:SetText(' ' .. name)
						end
					end
				end
				if v.subGroups then
					f.frames.button[id].text:SetText('-  ' .. name)
					createSubGroups(v.subGroups, 1, {k})
				else
					f.frames.button[id].text:SetText(' ' .. name)
				end
			end
			f.treeBox:SetHeight(line*22)
			f.slider:SetMinMaxValues(0, math.max(line*21-height+3, 0))
		end
		optionStuff.loadTree()
	elseif forceHide then
		if iTFOptions then
			iTFOptions:Hide()
		end
	elseif iTFOptions:IsShown() then
		iTFOptions:Hide()
	elseif not InCombatLockdown() then
		iTFOptions:Show()
	end
end