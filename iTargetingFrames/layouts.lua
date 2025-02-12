--[[---------------------------------------------------------------
----Using-custom-layouts-------------------------------------------
-------------------------------------------------------------------
table should containt only the data that you want to change, iTF will fill out the rest with the default profile
ex:
local t = {
	anchor = {
		x = 200,
	},
	grow = 'BOTTOMLEFT',
	frame = {
		width = 40,
		spacing = 4,
	},
}
iTargetingFrames:AddNewProfile(profileName, t)
Only changes horizontal position, grow direction, frame width and frame spacing, everything else will be filled with default profile

Possible indicator values: glowLeft, glowRight, glowTop, glowBottom, border, statusbar
-------------------------------------------------------------------
--]]---------------------------------------------------------------
-------------------------------------------------------------------



iTargetingFrames = {}

local _, iTF = ...
local layouts = {}

function layouts:Default() 
	local layout = {
		['anchor'] = {
			['x'] = 550, --Horizontal position from UIParent, BOTTOMLEFT
			['y'] = 650, --Vertical position from UIParent, BOTTOMLEFT
		},
		['maxUnits'] = 25, -- Maximum amount of unitframes to show
		['onlyEnemies'] = true, -- Only show enemy units
		['onlyShowInCombat'] = false, -- Only show units while you are in combat
		['grow'] = 'TOPRIGHT', --Anchor for grow direction, 'TOPLEFT'-> Down & Right, BOTTOMRIGHT would be Up & Left etc
		['frame'] = {
			['width'] = 100, --Unit frame width
			['height'] = 40,--Unit frame height
			['vspacing'] = 2, -- Vertical Spacing
			['hspacing'] = 2, -- Horizontal Spacing
			['castBarHeight'] = 14, --Cast bar height
		},
		['icon'] = {
			['width'] = 20, --Aura icon width
			['height'] = 20, --Aura icon height
			['pos'] = 'BOTTOMLEFT', --Aura icon anchor
			['max'] = 5, --Max number of auras shown
			['grow'] = 'LEFT', --Grow anchor (TOP/BOTTOM/LEFT/RIGHT), LEFT = Right, TOP = bottom etc
			['x'] = 1, --Aura icon horizontal position
			['y'] = 1, --Aura icon vertical position
			['spacing'] = 2, -- Aura spacing
			['sort'] = {
				['time'] = true, -- true = sort by time, false = sort by name
				['ascending'] = false, -- true = Ascending, false = descending order
			},
			['durationFont'] = 'Fonts\\ARIALN.TTF', --duration text font
			['durationEnabled'] = true, -- Enable duration text
			['durationSize'] = 13, --name/cast text size
			['durationX'] = 0, --duration text horizontal position
			['durationY'] = 0, --duration text vertical position
			['durationPos'] = 'BOTTOM', --name/cast text anchor
			['durationFlags'] = 'OUTLINE', --Font flags
			['durationDecimals'] = 3, --Show 1 decimal at <X
			['stackFont'] = 'Fonts\\ARIALN.TTF', --Stack text font
			['stackEnabled'] = true, -- Enable stack text
			['stackSize'] = 12, --name/cast text size
			['stackX'] = 5, --duration text horizontal position
			['stackY'] = 5, --duration text vertical position
			['stackPos'] = 'TOPRIGHT', --name/cast text anchor
			['stackFlags'] = 'OUTLINE', --Font flags
			['flashEnabled'] = true, --Enable icon flashing
			['flashTimer'] = 5, --Flash at <X (seconds)
			['flashSpeed'] = 1, --Flash speed (seconds)
		},
		['raidIcon'] = {
			['size'] = 20, --Raid icon size
			['pos'] = 'CENTER', --Raid icon position
			['x'] = 0, --Raid icon horizontal position
			['y'] = 0, --Raid icon vertical position
		},
		['text'] = { -- Name/Cast text
			['pos'] = 'TOPLEFT', --name/cast text anchor
			['size'] = 12, --name/cast text size
			['font'] = 'Fonts\\ARIALN.TTF', --name/cast text font
			['x'] = 2, --name/cast text horizontal position
			['y'] = -2, --name/cast text vertical position
			['abbreviateNames'] = true, -- Shorten names to X. X. XXXX
			['flags'] = 'OUTLINE', --Font flags
		},
		['healthText'] = { -- Health text
			['enabled'] = true, -- Enable health text
			['pos'] = 'RIGHT', --name/cast text anchor
			['size'] = 11, --name/cast text size
			['font'] = 'Fonts\\ARIALN.TTF', --name/cast text font
			['x'] = 2, --name/cast text horizontal position
			['y'] = 0, --name/cast text vertical position
			['flags'] = 'OUTLINE', --Font flags
			['decimal'] = false, -- Show decimals
			['percentage'] = true, -- Show %
		},
		['statusbar'] = {
			['texture'] = 'Interface\\Buttons\\WHITE8x8', --Status bar texture
		},
		['castBar'] = {
			['texture'] = 'Interface\\Buttons\\WHITE8x8', --Cast bar texture
			['enabled'] = false, -- Enable cast bar
			--['pos'] = 'TOP', -- Cast bar position ('TOP' or 'BOTTOM')
			['detached'] = false, -- Detach cast bar from health bar
			['detached_x'] = 0,
			['detached_y'] = 0,
			['detached_height'] = 14,
			['detached_width'] = 83,
			['detached_from'] = 'BOTTOM',
			['detached_to'] = 'TOP',
			['detached_text_pos'] = 'LEFT',
			['detached_text_x'] = 0,
			['detached_text_y'] = 0,
			['detached_text_size'] = 11,
			['detached_text_font'] = 'Fonts\\ARIALN.TTF',
			['detached_text_flags'] = 'OUTLINE',
		},
		['conditionals'] = {
			['interruptRange'] = { --Is in interrupt range (check rangeSpells.lua *.i)
				['indicators'] = {['border'] = true},
				['enable'] = false,
				['color'] = {0,1,0,0.6},
				['weight'] = 100, --Imporantace, higher weight overrides lower
				['update'] = 'onUpdate', --update func
			},
			['currentTarget'] = { --Is current target
				['enable'] = true,
				['color'] = {1,1,1,1},
				['indicators'] = {['border'] = true},
				['weight'] = 100, --Imporantace, higher weight overrides lower
				['update'] = 'targetChanged', --update func
			},
			['outOfCombat'] = { -- NPC is not in combat
				['indicators'] = {['alpha'] = true},
				['color'] = {0.5,0.5,0.5,0.5},
				['alpha'] = 0.35,
				['enable'] = false,
				['weight'] = 10, --Imporantace, higher weight overrides lower
				['update'] = 'onUpdate', --update func
			},
			['maxRange'] = { -- Out side of max range (check rangeSpells.lua *.d)
				['indicators'] = {['alpha'] = true},
				['color'] = {0.5,0.5,0.5,0.5},
				['alpha'] = 0.35,
				['enable'] = false,
				['weight'] = 99, --Imporantace, higher weight overrides lower
				['update'] = 'onUpdate', --update func
				['invert'] = true, -- invert check (in this case, enable if out of range for utility spells)
			},
			['maxRangeDPS'] = { --Is in DPS range (check rangeSpells.lua *.i)
				['indicators'] = {['alpha'] = true},
				['color'] = {1,1,1,1},
				['alpha'] = 0.66,
				['enable'] = false,
				['weight'] = 98, --Imporantace, higher weight overrides lower
				['update'] = 'onUpdate', --update func
				['invert'] = true, -- invert check (in this case, enable if out of range for damage spells)
			},
			['aggro'] = {
				['indicators'] = {['glowRight'] = true,['glowLeft'] = true, ['glowTop'] = true, ['glowBottom'] = true, ['border'] = true},
				['color'] = {1,0,0,1},
				['enable'] = true,
				['weight'] = 99, --Imporantace, higher weight overrides lower
				['roles'] = 3, -- Roles to show, 1 = all, 2 = tank only, 3 = non tanks
				['update'] = 'threat', --update func
			},
			['losingAggro'] = {
				['indicators'] = {['glowRight'] = true,['glowLeft'] = true, ['glowTop'] = true, ['glowBottom'] = true, ['border'] = true},
				['color'] = {1,0.5,0,1},
				['enable'] = true,
				['weight'] = 99, --Imporantace, higher weight overrides lower
				['roles'] = 2, -- Roles to show, 1 = all, 2 = tank only, 3 = non tanks
				['update'] = 'threat', --update func
			},
			['gainingAggro'] = {
				['indicators'] = {['glowRight'] = true,['glowLeft'] = true, ['glowTop'] = true, ['glowBottom'] = true, ['border'] = true},
				['color'] = {1,0.5,0,1},
				['enable'] = true,
				['weight'] = 99, --Imporantace, higher weight overrides lower
				['roles'] = 1, -- Roles to show, 1 = all, 2 = tank only, 3 = non tanks
				['update'] = 'threat', --update func
			},
			['focusTarget'] = { --Is current target
				['enable'] = false,
				['color'] = {1,0.5,1,0.8},
				['indicators'] = {['glowRight'] = true,['glowLeft'] = true},
				['weight'] = 98, --Imporantace, higher weight overrides lower
				['update'] = 'focusUpdate', --update func
			},
			['priorityNPCs'] = { --Priority Npcs
				['enable'] = false,
				['color'] = {1,1,0,1},
				['indicators'] = {['glowRight'] = true,['glowLeft'] = true, ['glowTop'] = true, ['glowBottom'] = true, ['border'] = true},
				['weight'] = 50, --Imporantace, higher weight overrides lower
				['update'] = 'onShow', --update func
				['receive'] = false, -- Allow CHAT_MSG_ADDON npc additions
			},			
		},
		['colS'] = 5, -- Column size/Rows
		['colors'] = {
			['classColor'] = true, --Use class color for players
			['backdrop'] = {
				['bg'] = {0.1,0.1,0.1,0.9}, --Background color
				['border'] = {0,0,0,1}, --Border color
			},
			['statusbar'] = {
				['main'] = {0.7,0,0,1}, --Health bar color
				['cast'] = {0.25,0.4,0.8,0.8}, --Cast bar color
				['backdrop'] = {0.1,0.1,0.1,0.9,}, -- Unitframe background color
				['border'] = {0,0,0,1}, -- Unitframe border color
			},
			['text'] = {
				['main'] = {1,1,1,1}, --Name/Cast text color
				['healthText'] = {1,1,1,1}, --Health text color
				['cast'] = {1,1,0,1}, --Cast text color
				['immune'] = {1,0,0,1}, --Cast immune to interrupts color
				['stack'] = {1,1,1,1}, -- Aura stack count color
				['duration'] = {1,1,1,1}, -- Aura duration color
				['shortDuration'] = {1,0,0,1}, -- Duration color when flashing
			},
		},
	}
	return layout
end
function iTargetingFrames:AddNewProfile(profileName, t)
	if type(profileName) == 'string' and type(t) == 'table' then
		local defaultProfile = layouts:Default()
		for k,v in pairs(defaultProfile) do
			if t[k] == nil then
				t[k] = v
			elseif type(v) == 'table' then
				for deeperKey, deeperValue in pairs(v) do
					if t[k][deeperKey] == nil then
						t[k][deeperKey] = deeperValue
					elseif type(deeperValue) == 'table' then
						for inceptionLevelKey, inceptionLevelValue in pairs(deeperValue) do
							if t[k][deeperKey][inceptionLevelKey] == nil then
								t[k][deeperKey][inceptionLevelKey] = inceptionLevelValue
							elseif type(inceptionLevelValue) == 'table' then
								for wtfKey, wtfValue in pairs(inceptionLevelValue) do
									if t[k][deeperKey][inceptionLevelKey][wtfKey] == nil then
										t[k][deeperKey][inceptionLevelKey][wtfKey] = wtfValue
									end
								end
							end
						end
					end
				end
			end
		end
		if not layouts[profileName] then
			layouts[profileName] = function()
				return t
			end
		else
			return t
		end
	else
		if not profileName and t then
			iTF:print('Error: Missing profile name and profile table, usage: iTargetingFrames:AddNewProfile(profileName, profileTable)')
		elseif not profileName then
			iTF:print('Error: Missing profile name, usage: iTargetingFrames:AddNewProfile(profileName, profileTable)')
		else
			iTF:print('Error: Missing profile table, usage: iTargetingFrames:AddNewProfile(profileName, profileTable)')
		end
	end
end
function layouts:Compact()
	local layout = {}
	layout.frame = {
		['width'] = 60,
		['height'] = 30,
		['spacing'] = 2,
		['castBarHeight'] = 8,
	}
	layout.colors = {
		statusbar = {
			['main'] = {0.5,0,0,0.8},
			['cast'] = {0.5,0.5,0.5,0.8},
		},
	}
	return iTargetingFrames:AddNewProfile('Compact', layout)
end
function layouts:Minimal()
	local layout = {
		['colS'] = 20,
		['raidIcon'] = {
			["y"] = 0,
			["x"] = -4,
			["size"] = 18,
			["pos"] = "RIGHT",
		},
		['anchor'] = {
			['y'] = 1050,
			['x'] = 10,
		},
		['frame'] = {
			['height'] = 20,
			['castBarHeight'] = 10,
			['width'] = 60,
			['spacing'] = 2,
		},
		['icon'] = {
			['grow'] = 'LEFT',
			['x'] = 1,
			['width'] = 16,
			['height'] = 16,
			['y'] = 0,
			['max'] = 4,
			['pos'] = 'LEFT',
		},
		['conditionals'] = {
			['aggro'] = {
				['indicators'] = {
					['glowTop'] = true,
				},
				['weight'] = 100,
				['color'] = {
					1, -- [1]
					0.5, -- [2]
					0.5, -- [3]
					0.75, -- [4]
				},
				['enable'] = true,
				['update'] = 'threat',
				['roles'] = 1,
			},
			['currentTarget'] = {
				['indicators'] = {
					['glowRight'] = true,
					['glowLeft'] = true,
				},
				['weight'] = 99,
				['enable'] = true,
				['update'] = 'targetChanged',
				['color'] = {
					1, -- [1]
					0.0274509803921569, -- [2]
					0.976470588235294, -- [3]
					0.846153944730759, -- [4]
				},
			},
			['interruptRange'] = {
				['indicators'] = {
					['border'] = true,
				},
				['weight'] = 100,
				['enable'] = true,
				['update'] = 'onUpdate',
				['color'] = {
					0, -- [1]
					1, -- [2]
					0, -- [3]
					0.6, -- [4]
				},
			},
			['losingAggro'] = {
				['indicators'] = {
					['glowTop'] = true,
				},
				['weight'] = 100,
				['color'] = {
					1, -- [1]
					1, -- [2]
					0.5, -- [3]
					0.75, -- [4]
				},
				['enable'] = true,
				['update'] = 'threat',
				['roles'] = 2,
			},
			['outOfCombat'] = {
				['indicators'] = {
					['glowBottom'] = true,
				},
				['weight'] = 10,
				['color'] = {
					0.5, -- [1]
					0.5, -- [2]
					0.5, -- [3]
					0.5, -- [4]
				},
				['update'] = 'onUpdate',
				['enable'] = false,
			},
			['focusTarget'] = {
				['indicators'] = {
					['glowRight'] = true,
					['glowLeft'] = true,
				},
				['weight'] = 98,
				['enable'] = true,
				['update'] = 'focusUpdate',
				['color'] = {
					1, -- [1]
					0.972549019607843, -- [2]
					0, -- [3]
					0.499999046325684, -- [4]
				},
			},
			['gainingAggro'] = {
				['indicators'] = {
					['glowTop'] = true,
				},
				['weight'] = 100,
				['color'] = {
					0, -- [1]
					1, -- [2]
					1, -- [3]
					0.75, -- [4]
				},
				['enable'] = true,
				['update'] = 'threat',
				['roles'] = 1,
			},
		},
	}
	return iTargetingFrames:AddNewProfile('Minimal', layout)
end

function iTF:GetProfile(profile)
	if layouts[profile] then
		return layouts[profile]()
	else
		return layouts:Default()
	end
end

function iTF:GetProfileList(KV)
	local t = {}
	for k in pairs(layouts) do
		if KV then
			t[k] = v
		else
			table.insert(t, k)
		end
	end
	return t
end