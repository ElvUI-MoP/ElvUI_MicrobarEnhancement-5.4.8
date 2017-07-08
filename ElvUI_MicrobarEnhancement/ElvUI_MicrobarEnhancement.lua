﻿local E, L, V, P, G =  unpack(ElvUI);
local AB = E:GetModule("ActionBars");
local EP = LibStub("LibElvUIPlugin-1.0")
local S = E:GetModule("Skins")
local addon = ...

P.actionbar.microbar.scale = 1
P.actionbar.microbar.symbolic = false
P.actionbar.microbar.backdrop = false
P.actionbar.microbar.colorS = {r = 1,g = 1,b = 1 }
P.actionbar.microbar.classColor = false

function AB:GetOptions()
	E.Options.args.actionbar.args.microbar.args.scale = {
		order = 5,
		type = "range",
		name = L["Set Scale"],
		desc = L["Sets Scale of the Micro Bar"],
		isPercent = true,
		min = 0.3, max = 2, step = 0.01,
		disabled = function() return not AB.db.microbar.enabled end,
		get = function(info) return AB.db.microbar.scale end,
		set = function(info, value) AB.db.microbar.scale = value; AB:UpdateMicroPositionDimensions(); end
	};
	E.Options.args.actionbar.args.microbar.args.backdrop = {
		order = 6,
		type = "toggle",
		name = L["Backdrop"],
		disabled = function() return not AB.db.microbar.enabled end,
		get = function(info) return AB.db.microbar.backdrop end,
		set = function(info, value) AB.db.microbar.backdrop = value; AB:UpdateMicroPositionDimensions(); end
	};
	E.Options.args.actionbar.args.microbar.args.symbolic = {
		order = 7,
		type = "toggle",
		name = L["As Letters"],
		desc = L["Replace icons with letters"],
		disabled = function() return not AB.db.microbar.enabled end,
		get = function(info) return AB.db.microbar.symbolic end,
		set = function(info, value) AB.db.microbar.symbolic = value; AB:MenuShow(); end
	};
	E.Options.args.actionbar.args.microbar.args.color = {
		order = 8,
		type = "color",
		name = L["Text Color"],
		get = function(info)
			local t = AB.db.microbar.colorS;
			local d = P.actionbar.microbar.colorS;
			return t.r, t.g, t.b, d.r, d.g, d.b;
		end,
		set = function(info, r, g, b)
			local t = AB.db.microbar.colorS;
			t.r, t.g, t.b = r, g, b;
			AB:SetSymbloColor();
		end,
		disabled = function() return not AB.db.microbar.enabled or AB.db.microbar.classColor; end
	};
	E.Options.args.actionbar.args.microbar.args.classColor = {
		order = 9,
		type = "toggle",
		name = CLASS,
		disabled = function() return not AB.db.microbar.enabled; end,
		get = function(info) return AB.db.microbar.classColor; end,
		set = function(info, value) AB.db.microbar.classColor = value; AB:SetSymbloColor(); end
	};
end

local _G = _G
local tinsert = tinsert

local HideUIPanel, ShowUIPanel = HideUIPanel, ShowUIPanel
local GameTooltip = GameTooltip
local UnitLevel = UnitLevel
local LoadAddOn = LoadAddOn

local MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"PVPMicroButton",
	"LFDMicroButton",
	"EJMicroButton",
	"CompanionsMicroButton",
	"StoreMicroButton",
	"MainMenuMicroButton"
};

local Sbuttons = {}

function AB:MicroScale()
	ElvUI_MicroBar.mover:SetWidth(AB.MicroWidth*AB.db.microbar.scale);
	ElvUI_MicroBar.mover:SetHeight(AB.MicroHeight*AB.db.microbar.scale);
	ElvUI_MicroBar:SetScale(AB.db.microbar.scale);
	ElvUI_MicroBarS:SetScale(AB.db.microbar.scale);
end

E.UpdateAllMB = E.UpdateAll
function E:UpdateAll()
    E.UpdateAllMB(self);
	AB:MicroScale();
	AB:MenuShow();
end

local function Letter_OnEnter()
	if(AB.db.microbar.mouseover) then
		E:UIFrameFadeIn(ElvUI_MicroBarS, 0.2, ElvUI_MicroBarS:GetAlpha(), AB.db.microbar.alpha);
	end
end

local function Letter_OnLeave()
	if(AB.db.microbar.mouseover) then
		E:UIFrameFadeOut(ElvUI_MicroBarS, 0.2, ElvUI_MicroBarS:GetAlpha(), 0);
	end
end

function AB:CreateSymbolButton(name, text, tooltip, click)
	local button = CreateFrame("Button", name, ElvUI_MicroBarS);
	button:SetScript("OnClick", click);
	if click then button:SetScript("OnClick", click) end
	button.tooltip = tooltip
	button.updateInterval = 0
	if tooltip then
		button:SetScript("OnEnter", function(self)
			Letter_OnEnter();
			button.hover = 1
			button.updateInterval = 0
			GameTooltip:SetOwner(self);
			GameTooltip:AddLine(button.tooltip, 1, 1, 1, 1, 1, 1)
			GameTooltip:Show();
		end);
		button:SetScript("OnLeave", function(self)
			Letter_OnLeave();
			button.hover = nil
			GameTooltip:Hide();
		end);
	else
		button:HookScript("OnEnter", Letter_OnEnter);
		button:HookScript("OnEnter", Letter_OnLeave);
	end

	S:HandleButton(button);

	if(text) then
		button.text = button:CreateFontString(nil,"OVERLAY",button);
		button.text:FontTemplate();
		button.text:SetPoint("CENTER", button, "CENTER", 0, -1);
		button.text:SetJustifyH("CENTER");
		button.text:SetText(text);
		button:SetFontString(button.text);
	end

	tinsert(Sbuttons, button);
end

function AB:SetSymbloColor()
	local color = AB.db.microbar.classColor and (E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])) or AB.db.microbar.colorS;
	for i = 1, #Sbuttons do
		Sbuttons[i].text:SetTextColor(color.r, color.g, color.b);
	end
end

function AB:SetupSymbolBar()
	local frame = CreateFrame("Frame", "ElvUI_MicroBarS", E.UIParent);
	frame:SetPoint("CENTER", ElvUI_MicroBar, 0, 0);
	frame:EnableMouse(true);
	frame:SetScript("OnEnter", Letter_OnEnter);
	frame:SetScript("OnLeave", Letter_OnLeave);

	E.FrameLocks["ElvUI_MicroBarS"] = true;

	AB:CreateSymbolButton("EMB_Character", "C", MicroButtonTooltipText(CHARACTER_INFO, "TOGGLECHARACTER0"), function()
		if(CharacterFrame:IsShown()) then
			HideUIPanel(CharacterFrame);
		else
			ShowUIPanel(CharacterFrame);
		end
	end);
	AB:CreateSymbolButton("EMB_Spellbook", "S", MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"), function()
		if(SpellBookFrame:IsShown()) then
			HideUIPanel(SpellBookFrame);
		else
			ShowUIPanel(SpellBookFrame);
		end
	end);
	AB:CreateSymbolButton("EMB_Talents", "T", MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS"), function()
		if(UnitLevel("player") >= 10) then
			if(PlayerTalentFrame) then
				if(PlayerTalentFrame:IsShown()) then
					HideUIPanel(PlayerTalentFrame);
				else
					ShowUIPanel(PlayerTalentFrame);
				end
			else
				LoadAddOn("Blizzard_TalentUI");
				ShowUIPanel(PlayerTalentFrame);
			end
		end
	end)
	AB:CreateSymbolButton("EMB_Achievement", "A", MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT"), function() ToggleAchievementFrame(); end);
	AB:CreateSymbolButton("EMB_Quest", "Q", MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG"), function()
		if(QuestLogFrame:IsShown()) then
			HideUIPanel(QuestLogFrame);
		else
			ShowUIPanel(QuestLogFrame);
		end
	end);
	AB:CreateSymbolButton("EMB_Guild", "G",  MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB"), function() ToggleGuildFrame(); end);
	AB:CreateSymbolButton("EMB_PVP", "P", MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4"), function() TogglePVPUI(); end)
	AB:CreateSymbolButton("EMB_LFD", "D", MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT"), function() ToggleLFDParentFrame(); end);
	AB:CreateSymbolButton("EMB_Journal", "J", MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL"), function() ToggleEncounterJournal(); end);
	AB:CreateSymbolButton("EMB_PetJournal", "M", MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEPETJOURNAL"), function() TogglePetJournal(); end);
	AB:CreateSymbolButton("EMB_Shop", "Sh", BLIZZARD_STORE, function() ToggleStoreUI(); end);
	AB:CreateSymbolButton("EMB_MenuSys", "?", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU"), function()
		if(GameMenuFrame:IsShown()) then
			PlaySound("igMainMenuQuit");
			HideUIPanel(GameMenuFrame);
		else
			PlaySound("igMainMenuOpen");
			ShowUIPanel(GameMenuFrame);
		end
	end);

	AB:UpdateMicroPositionDimensions();
end

function AB:UpdateMicroPositionDimensions()
	if(not ElvUI_MicroBar) then return; end

	local numRows = 1;
	for i = 1, #MICRO_BUTTONS do
		local button = _G[MICRO_BUTTONS[i]];
		local prevButton = _G[MICRO_BUTTONS[i-1]] or ElvUI_MicroBar;
		local lastColumnButton = _G[MICRO_BUTTONS[i-self.db.microbar.buttonsPerRow]];

		button:ClearAllPoints();
		if(prevButton == ElvUI_MicroBar) then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", -2 + E.Border, 28 - E.Border);
		elseif((i - 1) % self.db.microbar.buttonsPerRow == 0) then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, 28 - self.db.microbar.yOffset);	
			numRows = numRows + 1;
		else
			button:Point("LEFT", prevButton, "RIGHT", - 4 + self.db.microbar.xOffset, 0);
		end
	end

	if(AB.db.microbar.mouseover) then
		ElvUI_MicroBar:SetAlpha(0);
	else
		ElvUI_MicroBar:SetAlpha(self.db.microbar.alpha);
	end

	AB.MicroWidth = ((CharacterMicroButton:GetWidth() - 4) * self.db.microbar.buttonsPerRow) + (self.db.microbar.xOffset * (self.db.microbar.buttonsPerRow-1)) + E.Border*2;
	AB.MicroHeight = ((CharacterMicroButton:GetHeight() - 28) * numRows) + (self.db.microbar.yOffset * (numRows-1)) + E.Border*2;

	ElvUI_MicroBar:SetWidth(AB.MicroWidth);
	ElvUI_MicroBar:SetHeight(AB.MicroHeight);

	if(not ElvUI_MicroBar.backdrop) then
		ElvUI_MicroBar:CreateBackdrop("Transparent");
	end

	if(self.db.microbar.enabled) then
		ElvUI_MicroBar:Show();
	else
		ElvUI_MicroBar:Hide();
	end

	if(not Sbuttons[1]) then return; end
	AB:MenuShow();
	local numRowsS = 1;
	for i = 1, #Sbuttons do
		local button = Sbuttons[i];
		local prevButton = Sbuttons[i-1] or ElvUI_MicroBarS;
		local lastColumnButton = Sbuttons[i-self.db.microbar.buttonsPerRow];
		button:Width(28 - 4)
		button:Height(58 - 28);

		button:ClearAllPoints();
		if(prevButton == ElvUI_MicroBarS) then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", E.Border, -E.Border);
		elseif((i - 1) % self.db.microbar.buttonsPerRow == 0) then
			button:Point("TOP", lastColumnButton, "BOTTOM", 0, -self.db.microbar.yOffset);	
			numRowsS = numRowsS + 1;
		else
			button:Point("LEFT", prevButton, "RIGHT", self.db.microbar.xOffset, 0);
		end

		prevButton = button;
	end

	ElvUI_MicroBarS:SetWidth(AB.MicroWidth);
	ElvUI_MicroBarS:SetHeight(AB.MicroHeight);

	if(not ElvUI_MicroBarS.backdrop) then
		ElvUI_MicroBarS:CreateBackdrop("Transparent");
	end

	if(AB.db.microbar.backdrop) then
		ElvUI_MicroBar.backdrop:Show();
		ElvUI_MicroBarS.backdrop:Show();
	else
		ElvUI_MicroBar.backdrop:Hide();
		ElvUI_MicroBarS.backdrop:Hide();
	end

	if(AB.db.microbar.mouseover) then
		ElvUI_MicroBarS:SetAlpha(0);
	elseif(not AB.db.microbar.mouseover and  AB.db.microbar.symbolic) then
		ElvUI_MicroBarS:SetAlpha(AB.db.microbar.alpha);
	end

	AB:MicroScale();
	AB:SetSymbloColor();
end

function AB:MenuShow()
	if AB.db.microbar.symbolic then
		if AB.db.microbar.enabled then
			ElvUI_MicroBar:Hide()
			ElvUI_MicroBarS:Show()
			if not AB.db.microbar.mouseover then
				E:UIFrameFadeIn(ElvUI_MicroBarS, 0.2, ElvUI_MicroBarS:GetAlpha(), AB.db.microbar.alpha)
			end
		else
			ElvUI_MicroBarS:Hide()
		end
	else
		if AB.db.microbar.enabled then
			ElvUI_MicroBar:Show()
		end
		ElvUI_MicroBarS:Hide()
	end
end

function AB:EnhancementInit()
	EP:RegisterPlugin(addon, AB.GetOptions);
	AB:SetupSymbolBar();
	AB:MenuShow();

	_G["EMB_MenuSys"]:SetScript("OnUpdate", function(self, elapsed)
		if self.updateInterval > 0 then
			self.updateInterval = self.updateInterval - elapsed
		else
			self.updateInterval = PERFORMANCEBAR_UPDATE_INTERVAL
			if self.hover then
				MainMenuBarPerformanceBarFrame_OnEnter(_G["MainMenuMicroButton"])
			end
		end
	end)
end

hooksecurefunc(AB, "SetupMicroBar", AB.EnhancementInit)

local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	AB:MicroScale();
end);