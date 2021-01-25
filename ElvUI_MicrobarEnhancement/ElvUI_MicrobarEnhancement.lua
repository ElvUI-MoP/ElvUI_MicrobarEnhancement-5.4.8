local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule("ActionBars")
local EP = E.Libs.EP

local addonName = ...

local _G = _G
local pairs = pairs

local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

local MICRO_BUTTONS = {
	CharacterMicroButton = L["CHARACTER_SYMBOL"],
	SpellbookMicroButton = L["SPELLBOOK_SYMBOL"],
	TalentMicroButton = L["TALENTS_SYMBOL"],
	AchievementMicroButton = L["ACHIEVEMENT_SYMBOL"],
	QuestLogMicroButton = L["QUEST_SYMBOL"],
	GuildMicroButton = L["GUILD_SYMBOL"],
	PVPMicroButton = L["PVP_SYMBOL"],
	LFDMicroButton = L["LFD_SYMBOL"],
	EJMicroButton = L["JOURNAL_SYMBOL"],
	CompanionsMicroButton = L["PETS_SYMBOL"],
	StoreMicroButton = L["STORE_SYMBOL"],
	HelpMicroButton = L["HELP_SYMBOL"],
	MainMenuMicroButton = L["MENU_SYMBOL"]
}

function AB:SetSymbloColor()
	local colorClass = E:ClassColor(E.myclass) or PRIEST_COLOR
	local color = AB.db.microbar.classColor and colorClass or AB.db.microbar.colorS

	for button in pairs(MICRO_BUTTONS) do
		_G[button].text:SetTextColor(color.r, color.g, color.b)
	end
end

local oldHandleMicroButton = AB.HandleMicroButton
function AB:HandleMicroButton(button)
	oldHandleMicroButton(self, button)

	local text = MICRO_BUTTONS[button:GetName()]
	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:FontTemplate()
	button.text:Point("CENTER", button, "CENTER", 1, -1)
	button.text:SetJustifyH("CENTER")
	button.text:SetText(text)
end

local oldUpdateMicroPositionDimensions = AB.UpdateMicroPositionDimensions

function AB:UpdateMicroPositionDimensions()
	oldUpdateMicroPositionDimensions(self)

	local symbol = AB.db.microbar.symbolic

	for button in pairs(MICRO_BUTTONS) do
		local b = _G[button]

		b.backdrop:SetTemplate(symbol and AB.db.microbar.transparentButtons and "Transparent" or "Default", true)

		b:DisableDrawLayer(symbol and "ARTWORK" or "OVERLAY")
		b:EnableDrawLayer(symbol and "OVERLAY" or "ARTWORK")
	end

	GuildMicroButtonTabard.emblem:SetShown(not symbol)
	GuildMicroButtonTabard.background:SetShown(not symbol)

	AB:SetSymbloColor()
end

function AB:EnhancementInit()
	EP:RegisterPlugin(addonName, AB.GetOptions)

	MicroButtonPortrait:SetDrawLayer("ARTWORK", 1)
	PVPMicroButtonTexture:SetDrawLayer("ARTWORK", 1)
	MainMenuBarDownload:SetDrawLayer("ARTWORK", 1)
end

hooksecurefunc(AB, "SetupMicroBar", AB.EnhancementInit)