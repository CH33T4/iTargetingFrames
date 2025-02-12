local _, iTF = ...
local maxRanges = {
	--Death Knight
	[250] = { --Blood
		utility = 49576,	--Death Grip (30yd)
		interrupt = 47528,	--Mind Freeze (15yd)
		dps = 49998,		--Death Strike (Melee)
		tank = true,		--Tank
	},
	[251] = { --Frost
		utility = 49576,	--Death Grip (30yd)
		interrupt = 47528,	--Mind Freeze (15yd)
		dps = 49143,		--Frost Strike (Melee)
	},
	[252] = { --Unholy,
		utility = 49576,	--Death Grip (30yd)
		interrupt = 47528,	--Mind Freeze (15yd)
		dps = 55090,		--Scourge Strike (Melee)
	},

	--Druid
	[102] = { --Balance
		utility = 48461,	-- Wrath (30yd)
		dps = 48461,		-- Wrath (30yd)
	},
	[103] = { --Feral,
		utility = 16857,	--Faerie Fire (Feral) (30yd)
		dps = 5221,			--Shred (Melee)
	},
	[104] = { --Guardian
		utility = 16857,	--Faerie Fire (Feral) (30yd)
		dps = 6807,			--Maul (Melee)
		tank = true,		--Tank
	},
	[105] = { --Restoration
		utility = 5176,		-- Wrath (30yd)
		dps = 5176,			-- Wrath (30yd)
	},

	--Hunter
	[253] = { --Beastmastery
		utility = 49052,	--Steady Shot (40yd)
		dps = 49052,		--Steady Shot (40yd)
	},
	[254] = { --Marksmanship
		utility = 53209,	--Chimera Shot (40yd+)
		interrupt = 34490,	--Silencing Shot (40yd)
		dps = 53209,		--Chimera Shot (40yd+)
	},
	[255] = { --Survival
		utility = 60053,	--Explosive Shot (40yd)
		dps = 60053,		--Explosive Shot (40yd)
	},
	--Mage
	[62] = { --Arcane
		utility = 42897,	--Arcane Blast (30yd)
		interrupt = 2139,	--Counterspell (30yd)
		dps = 42897,		--Arcane Blast (30yd)
	},
	[63] = { --Fire
		utility = 133,		--Fireball (40yd)
		interrupt = 2139,	--Counterspell (30yd)
		dps = 133,			--Fireball (40yd)
	},
	[64] = { --Frost
		utility = 116,		--Frostbolt (40yd)
		interrupt = 2139,	--Counterspell (30yd)
		dps = 116,			--Frostbolt (40yd)
	},

	--Paladin
	[65] = { --Holy
		utility = 62124,	--Hand of Reckoning (30yd)
		dps = 20271,		--Judgment (30yd), TO DO: maybe switch to melee ability? (or Holy Shock, 40yd)
	},
	[66] = { --Protection
		utility = 62124,	--Hand of Reckoning (30yd)
		interrupt = 48827,	--Avenger's Shield (30yd)
		dps = 53600,		--Shield of the Righteous (meele)
		tank = true,		--Tank
	},
	[70] = { --Retribution
		utility = 62124,	--Hand of Reckoning (30yd)
		dps = 35395,		--Crusader Strike
	},
	--Priest
	
	[256] = { --Discipline
		utility = 585,		--Smite (30yd)
		dps = 585,			--Smite (30yd)
	},
	[257] = { --Holy
		utility = 585,		--Smite (30yd)
		dps = 585,			--Smite (30yd)
	},
	[258] = { --Shadow
		utility = 589,		--Shadow Word: Pain (30yd)
		interrupt = 15487,	--Silence (30yd)
		dps = 589,			--Shadow Word: Pain (30yd)
	},

	--Rogue
	[259] = { --Assassination
		utility =2094,		--blind (25yd)
		interrupt = 1766,	--Kick (Melee)
		dps = 1329,			--Mutilate (Melee)
	},
	[260] = { --Combat 
		utility = 2094,		--Pistol Shot (20yd)
		interrupt = 1766,	--Kick (Melee)
		dps = 193315,		--Saber Slash (Melee)
	},
	[261] = { --Sublety
		utility = 36554,	--Shadowstep (25yd)
		interrupt = 1766,	--Kick (Melee)
		dps = 53,			--Backstab (Melee)
	},

	--Shaman
	[262] = { --Elemental
		utility = 403,		--Lightning Bolt (30yd)
		interrupt = 57994,	--Wind Shear (25yd)
		dps = 403,			--Lightning Bolt (30yd)
	},
	[263] = { --Enhancement
		utility = 8050,		--Flame Shock (25yd)
		interrupt = 57994,	--Wind Shear (25yd)
		dps = 17364,		--Stormstrike (Melee)
	},
	[264] = { --Restoration
		utility = 8050,		--Flame Shock (25yd)
		interrupt = 57994,	--Wind Shear (25yd)
		dps = 8050,			--Flame Shock (25yd)
	},

	--Warlock --TO DO: add pets
	[265] = { --Affliction
		utility = 172,	--Corruption (40yd)
		dps = 172,		--Corruption (40yd)
	},
	[266] = { --Demonology
		utility = 686,	--Shadow Bolt (40yd)
		dps = 686,		--Shadow Bolt (40yd)
	},
	[267] = { --Descrution
		utility = 29722,--Incinerate (40yd)
		dps = 29722,	--Incinerate (40yd)
	},

	--Warrior
	[71] = { --Arms
		utility = 355,		--Taunt (30yd)
		interrupt = 6552,	--Pummel (Melee)
		dps = 12294,		--Mortal Strike (Melee)
	},
	[72] = { --Fury
		utility = 355,		--Taunt (30yd)
		interrupt = 6552,	--Pummel (Melee)
		dps = 23881,		--Bloodthirst (Melee)
	},
	[73] = { --Protection
		utility = 355,		--Taunt (30yd)
		interrupt = 6552,	--Pummel (Melee)
		dps = 20243,		--Devastate (Melee)
		tank = true,		--Tank
	},

}
local function convertIdsToNames(t)
	local temp = {}
	for k,v in pairs(maxRanges) do
		if type(v) == 'table' then
			temp[k] = {}
			for dK,dV in pairs(v) do
				if type(dV) == 'number' then
					temp[k][dK] = GetSpellInfo(dV)
				end
			end
		end
	end
	return temp
end
iTF.spells = {
	['range'] = convertIdsToNames(maxRanges),
}