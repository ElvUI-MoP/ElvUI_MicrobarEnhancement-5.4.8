local E, _, V, P, G = unpack(ElvUI)
local L = E.Libs.ACL:GetLocale("ElvUI", E.global.general.locale)
local AB = E:GetModule("ActionBars")

function AB:GetOptions()
	if not E.Options.args.elvuiPlugins then
		E.Options.args.elvuiPlugins = {
			order = 50,
			type = "group",
			name = "|cff00fcceE|r|cffe5e3e3lvUI |r|cff00fcceP|r|cffe5e3e3lugins|r",
			args = {}
		}
	end

	E.Options.args.elvuiPlugins.args.microbarEnhanced = {
		type = "group",
		name = "|cff00fcceM|r|cffe5e3e3icrobar |r|cff00fcceE|r|cffe5e3e3nhancement|r",
		get = function(info) return E.db.actionbar.microbar[info[#info]] end,
		set = function(info, value) E.db.actionbar.microbar[info[#info]] = value AB:UpdateMicroPositionDimensions() end,
		args = {
			symbolic = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				desc = L["Replace icons with letters"],
				disabled = function() return not AB.db.microbar.enabled end
			},
			spacer = {
				order = 2,
				type = "description",
				name = ""
			},
			transparentButtons = {
				order = 3,
				type = "toggle",
				name = L["Transparent Buttons"],
				disabled = function() return not AB.db.microbar.enabled or not AB.db.microbar.symbolic end
			},
			classColor = {
				order = 4,
				type = "toggle",
				name = L["Use Class Color"],
				get = function(info) return AB.db.microbar.classColor end,
				set = function(info, value) AB.db.microbar.classColor = value AB:SetSymbloColor() end,
				disabled = function() return not AB.db.microbar.enabled or not AB.db.microbar.symbolic end,
			},
			color = {
				order = 5,
				type = "color",
				name = L["COLOR"],
				get = function(info)
					local t = AB.db.microbar.colorS
					local d = P.actionbar.microbar.colorS
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = AB.db.microbar.colorS
					t.r, t.g, t.b = r, g, b
					AB:SetSymbloColor()
				end,
				disabled = function() return not AB.db.microbar.enabled or AB.db.microbar.classColor or not AB.db.microbar.symbolic end
			}
		}
	}
end