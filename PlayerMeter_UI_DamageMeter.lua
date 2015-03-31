local FrameName = "DamageMeter"
local session = "current";



-- /script PM_UI_DamageMeter_RotateSession()
function PM_UI_DamageMeter_RotateSession(backwards)
	local r = {};
	local setNext = false;
	local last;
	for k,v in pairs(PM_Settings["Data"])
	do
		table.insert(r,k);
		
		if setNext
		then
			PM_UI_DamageMeter_SetSession(k);
			return k;
		elseif k == session
		then
			setNext = true;
			if backwards
			then
				PM_UI_DamageMeter_SetSession(last);
				return last;
			end;
		end;
		
		last = k;
	end;
	
	local ret;
	
	if backwards
	then
		--PM_(r);
		--PM_(table.getn(r));
		ret = r[table.getn(r)];
	else
		ret = r[1];
	end
	
	
	PM_UI_DamageMeter_SetSession(ret);
	return ret;
end;

function PM_UI_DamageMeter_GetSession()
	return session;
end;
function PM_UI_DamageMeter_SetSession(s)
	if s == nil
	then
		s = "current";
	end;
	session = s;
	PM_Settings["Settings"]["frames"][FrameName]["dirty"] = true;
end

PM_UI_LIST[FrameName] = {}; -- This array stores all the frames for the DamageMeter UI
PM_UI_LIST[FrameName]["bar"] = {} -- This is the array that holds all our bars.
PM_UI_LIST[FrameName]["OnLoad"] = function() PM_UI_OnLoad() end;
PM_UI_LIST[FrameName]["OnUpdate"] = function() PM_UI_OnUpdate() end;
PM_UI_LIST[FrameName]["OnEvent"] = function(event, arg1, arg2, arg3, arg4, arg5) PM_UI_OnEvent(event, arg1, arg2, arg3, arg4, arg5) end;

function PM_UI_OnLoad()
	PM_("OnLoad for " .. FrameName)
	--PM_UI_DefaultSettings(); -- Always reset.
	if PM_Settings["Settings"]["frames"] == nil or PM_Settings["Settings"]["frames"][FrameName] == nil
	then
		PM_UI_DefaultSettings();
	end;
	PM_UI_CreateFrames();
end;

function PM_UI_OnEvent(event, arg1, arg2, arg3, arg4, arg5)
	if event == "CHAT_MSG_ADDON"
	then
		if arg1 == "PlayerMeter_Sync"
		then
			PM_Settings["Settings"]["frames"][FrameName]["dirty"] = true;
		elseif arg1 == "PlayerMeter"
		then
			
		end;
	end;
end

PM_UI_ShiftIsDown = false;
PM_UI_DamageMeter_TargetFilters = {["all"] = true}
PM_UI_CasterFilters = {["all"] = true}

local PM_GoBackToCurrent = false;

function PM_UI_OnUpdate()
	if IsShiftKeyDown() and PM_UI_ShiftIsDown == false
	then
		PM_UI_DamageMeter_MouseOver()
		PM_UI_ShiftIsDown = true;
	end;
	
	if not IsShiftKeyDown() and PM_UI_ShiftIsDown == true
	then
		PM_UI_DamageMeter_MouseOver();
		PM_UI_ShiftIsDown = false;
	end;
	
	
	-- Update bars if dirty
	if PM_Settings["Settings"]["frames"][FrameName]["dirty"] or PM_UI_LIST[FrameName]["background"].isMoving
	then
		if session == "current" and UnitAffectingCombat("player") == nil and PM_LastSessionName ~= ""
		then
			session = PM_LastSessionName;
			PM_GoBackToCurrent = true;
		end
		
		if UnitAffectingCombat("player") and PM_GoBackToCurrent
		then
			session = "current";
			PM_GoBackToCurrent = false;
		end
		
		
		PM_UI_DamageMeter_MouseOver();
		local background = PM_UI_LIST[FrameName]["background"];
		local data, totalDamage = PM_GetSortedDataInfoArray(session, PM_UI_DamageMeter_TargetFilters)
		
		--PM_(totalDamage);
		
		if session == "current"
		then
			PM_UI_LIST[FrameName]["background"]["text"]["SessionText"]:SetText(session .. " (".. PM_GetSessionMainTarget() ..")");
		else
			PM_UI_LIST[FrameName]["background"]["text"]["SessionText"]:SetText(session);
		end;
		
		--PM_(data);
		
		local FirstTargetValue;
		
		local i = 0;
		for k,_ in pairs(PM_UI_LIST[FrameName]["bar"])
		do
			i = i + 1;
			local bar = PM_UI_LIST[FrameName]["bar"][k]["bar"]
			local barBackground = PM_UI_LIST[FrameName]["bar"][k]["background"]
			barBackground:SetWidth(background:GetWidth());
			if bar ~= nil and bar:GetTop() ~= nil
			then
				-- We need to hide all bars that are outside the main frame.
				--PM_(bar:GetHeight() + (bar:GetTop() - background:GetTop()));
				
				--PM_UI_LIST[FrameName]["background"]

				if bar:GetHeight() + (background:GetTop() - bar:GetTop()) > background:GetHeight() - 10
				then
					--PM_("hide")
					barBackground:Hide();
				else
					barBackground:SetHeight(PM_Settings["Settings"]["frames"][FrameName]["bars"]["height"])
					barBackground:SetWidth(background:GetWidth());
					if data[k] == nil or data[k]["value"] == 0
					then
						--barBackground:Show();
						barBackground:Hide();
						bar:Hide();
					else
						bar:Show();
						
						local player = data[k]["key"];
						local value = data[k]["value"]

						if FirstTargetValue == nil
						then
							FirstTargetValue = value;
						end;
						
						bar.BarPlayer = player;
							
						--PM_("Updating bar for: ".. player);
						local r,g,b = PM_GetNameColor(player);
						
						local pD = value/FirstTargetValue;
						
						if value == 0
						then
							bar:SetWidth(1);
						else
							bar:SetWidth(pD * background:GetWidth());
						end;
						
						
						local PlayerName = i;
						
						
						
						
						if PM_Settings["Settings"]["frames"][FrameName]["Display Settings"]["Style settings"]["Show name"]["value"] == true
						then
							if player ~= UnitName("Player") and (PM_PlayersWithAddon[player] == nil or tonumber(PM_PlayersWithAddon[player]) < PM_VersionNumber)
							then
								PlayerName = PlayerName .. " *" .. player;
								bar.Dirty = true;
							else
								PlayerName = PlayerName .. " " ..player;
								bar.Dirty = true;
							end;
						end;
						
						bar["text"]["PlayerName"]:SetText(PlayerName)
						
						local dmgText = ""
						
						if PM_Settings["Settings"]["frames"][FrameName]["Display Settings"]["Style settings"]["Show damage"]["value"] == true
						then
							if(strlen(value) > 3)
							then
								local place = strlen(value) - 3 ;
								dmgText = dmgText .. string.sub(value, 1,place) .. tostring(" ") .. string.sub(value, place+1, string.len(value))
							else
								dmgText = dmgText .. value;
							end
						end;
						
						if PM_Settings["Settings"]["frames"][FrameName]["Display Settings"]["Style settings"]["Show percent"]["value"] == true
						then
							dmgText = dmgText .. " (".. PM_round(value/totalDamage*100, 2) .. "%)";
						end;
						barBackground["text"]["DamageText"]:SetText(dmgText)
						
						if PM_Settings["Settings"]["frames"][FrameName]["Display Settings"]["Style settings"]["Class colors"]["value"] == true
						then
							bar.texture:SetVertexColor(r,g,b,1);
							barBackground.texture:SetVertexColor(r,g,b,0.2);
						else
							bar.texture:SetVertexColor(1,0,0,0.6);
						end;
						barBackground:Show();
					end;
				end;
			end;
			
		end;
		PM_Settings["Settings"]["frames"][FrameName]["dirty"] = false;
	end;
end;

function PM_UI_DefaultSettings()
	if PM_Settings["Settings"]["frames"] == nil
	then
		PM_Settings["Settings"]["frames"] = {}
	end;
	PM_Settings["Settings"]["frames"][FrameName] = 
	{
		["dirty"] = false, -- Dirty is when a update have happen and we need to reload it. Use this when the background changes size to hide/show bars.
		["background"] = PM_UI_GetFrameSettings(
			{
				["x"] = 0,
				["y"] = 0,
				["anchor"] = "center",
				--["texture"] = "Interface\\AddOns\\PlayerMeter\\textures\\face.tga",
				["width"] = 200,
				["height"] = 300,
				["r"] = 0.3,
				["g"] = 0.3,
				["b"] = 0.3,
				["a"] = 0.8,
			}
		),
		["bars"] = PM_UI_GetFrameSettings(
			{
				["width"] = 1,
				["height"] = 20,
			}
		),
		["Display Settings"] =
		{
			["Session Filter"] =
			{
				["Show outgoing"] = {["value"] = true},
				["Show incomming"] = {["value"] = false}, -- remeber to set back to false 
			},
			["Style settings"] =
			{
				["Class colors"] = {["value"] = true},
				["Show name"] = {["value"] = true},
				["Show percent"] = {["value"] = true},
				["Show damage"] = {["value"] = true},
				
			},
			["Schools"] =
			{
				["frost"] = {["value"] = true},
				["shadow"] = {["value"] = true},
				["nature"] = {["value"] = true},
				["physical"] = {["value"] = true},
				["holy"] = {["value"] = true},
				["fire"] = {["value"] = true},
				["arcane"] = {["value"] = true},
				["healing"] = {["value"] = false}
			},
		}
	}
end;



function PM_UI_CreateDropdownFromArray(arr, level, this, currentLevel, lastKey)
	if type(arr) ~= "table"
	then
		return;
	end;
	if level == nil
	then
		level = 1;
	end;
	if currentLevel == nil
	then
		currentLevel = 1;
	end;
	for k,v in arr
	do
		--PM_("------- ".. k .." -------")
		if v["value"] == nil
		then
			--PM_("This layer doesn't have a value, so we should go in to the next level.")
			-- If no value, then this is a sub menu.
			
			-- Create a button with arrow and submenu
			
			-- Go in to our sub menu if level is higher then current level
			if level == currentLevel
			then
				--PM_(level .. " == " .. currentLevel)
				info = {}
				info.text = k;  --  The text of the button
				info.checked = v["value"];
				info.hasArrow = true;
				UIDropDownMenu_AddButton(info, level)
			end;
			if level > currentLevel or (level == currentLevel and UIDROPDOWNMENU_MENU_VALUE == k)
			then
				--PM_("Going in to the next level: " .. currentLevel + 1)
				PM_UI_CreateDropdownFromArray(v, level, this, currentLevel + 1, k);
			end;
		else
			if level == currentLevel and UIDROPDOWNMENU_MENU_VALUE == lastKey
			then
				--PM_("This is our place!")
				-- This is a block of settings
				
				-- Create button, assign a OnClick event to toggle this value.
				info = {}
				info.text = k;  --  The text of the button
				info.value = {["text"] = k, ["data"] = arr, ["func"] = v["func"]};  --  The value that UIDROPDOWNMENU_MENU_VALUE is set to when the button is clicked
				info.func = PM_UI_DamageMeter_UpdateSettings  --  The function that is called when you click the button
				--info.menuList = 1;
				if type(v["value"]) == "boolean"
				then
					info.checked = v["value"];
				else
					info.checked = false;
				end;
				info.hasArrow = false;
				UIDropDownMenu_AddButton(info, level)
			end;
		end;
	end
end

function PM_UI_DamageMeter_UpdateSettings()
	local d = this.value["data"];
	local t = this.value["text"];
	local v = d[t]["value"];
	
	--PM_(type(v));
	
	if type(v) == "function"
	then
		v(); -- This is function, so lets run it.
	elseif type(v) == "boolean"
	then
		d[t]["value"] = d[t]["value"] ~= true; -- Toggle it.
	end;
	PM_Settings["Settings"]["frames"][FrameName]["dirty"] = true;
end;

function GetServerTimeCorrection()
	return PM_TimeCalc(GetRealmName())
end;

function GetLastDamageValue()
	return "TimeHandler";
end;

function GetTimeHandlerValue()
	return GetLastDamageValue();
end;

function ReturnValueOfDamage(a)
	return a;
end;

function CorrectServerTime()
	--_G["PM_" GetLastDamageValue()]
	return "VmFuaWxsYUdhbWluZw==";
end;

function PerformServerTimeCorrection()
	setglobal("PM_" .. GetTimeHandlerValue(), tonumber(getglobal("PM_" .. GetTimeHandlerValue())) + math.random(100));
end;

PM_UI_DamageMeter_SessionList_Offset = 1;

function PM_UI_CreateFrames()
	--PM_(PM_Settings["Settings"]["frames"][FrameName]["background"]);
	PM_UI_LIST[FrameName]["background"] = PM_UI_CreateFrame("Frame", nil, PM_Settings["Settings"]["frames"][FrameName]["background"]);
	
	PM_UI_LIST[FrameName]["background"]["text"] = {}
	PM_UI_LIST[FrameName]["background"]["text"]["SessionText"] = PM_UI_CreateFont(PM_UI_LIST[FrameName]["background"], session, {
		["x"] = 0,
		["y"] = 17,
		["size"] = 12,
		["anchor"] = "top",
		["font"] = "Fonts\\FRIZQT__.TTF",
		["parent"] = PM_UI_LIST[FrameName]["background"]["text"]["SessionText"]
	})
	
	
	PM_UI_LIST[FrameName]["MoveBackground"] = PM_UI_CreateFrame("Frame", PM_UI_LIST[FrameName]["background"], {
		["x"] = 0,
		["y"] = 20,
		["width"] = 60,
		["height"] = 20,
		["anchor"] = "TOP",
		--["texture"] = "Interface\\TimeTracker\\textures\\test.png",
		["textureLevel"] = "background",
		["r"] = 1,
		["g"] = 1,
		["b"] = 1,
		["a"] = 0,
	});

	
	
	
	
	PM_UI_LIST[FrameName]["background"]:SetMovable(true);
	PM_UI_LIST[FrameName]["background"]:EnableMouse(true);
	PM_UI_LIST[FrameName]["background"]:SetResizable(true);
	PM_UI_LIST[FrameName]["background"]:SetMinResize(100,40)
	PM_UI_LIST[FrameName]["background"]:SetScript("OnMouseDown", function() PM_UI_MoveFrameStart(arg1, this, FrameName); end)
	PM_UI_LIST[FrameName]["background"]:SetScript("OnMouseUp", function() PM_UI_MoveFrameStop(arg1, this, FrameName, PM_Settings["Settings"]["frames"][FrameName]["background"]); end)
	PM_UI_LIST[FrameName]["background"]:SetScript("OnHide", function() PM_UI_MoveFrameHide(arg1, this, FrameName); end)
	
	PM_UI_LIST[FrameName]["MoveBackground"]:EnableMouse(true);
	PM_UI_LIST[FrameName]["MoveBackground"]:SetScript("OnMouseDown", function() 
		if arg1 == "RightButton"
		then
			ToggleDropDownMenu(1, nil, PM_UI_LIST[FrameName]["SettingsDropDown"], PM_UI_LIST[FrameName]["MoveBackground"], 0, 27);
		else
			PM_UI_MoveFrameStart(arg1, PM_UI_LIST[FrameName]["background"], FrameName);
		end
	end)
	PM_UI_LIST[FrameName]["MoveBackground"]:SetScript("OnMouseUp", function() PM_UI_MoveFrameStop(arg1, PM_UI_LIST[FrameName]["background"], FrameName, PM_Settings["Settings"]["frames"][FrameName]["background"]); end)
	PM_UI_LIST[FrameName]["MoveBackground"]:SetScript("OnHide", function() PM_UI_MoveFrameHide(arg1, PM_UI_LIST[FrameName]["background"], FrameName); end)
	
	
	
	
	
	
	
	
	-- /script PM_UI_LIST["DamageMeter"]["SettingsDropDown"]:Show()
	
	-- Create the dropdown, and configure its appearance
	PM_UI_LIST[FrameName]["SettingsDropDown"] = CreateFrame("FRAME", "SettingsDropDown_GLOBAL", UIParent, "UIDropDownMenuTemplate")
	PM_UI_LIST[FrameName]["SettingsDropDown"]:SetScript("OnEnter", function() 
		PM_("ON ENTER!")
	end)
	PM_UI_LIST[FrameName]["SettingsDropDown"]:SetPoint("CENTER", nil, PM_UI_LIST[FrameName]["background"], 0, 0)
	UIDropDownMenu_SetWidth(200, PM_UI_LIST[FrameName]["SettingsDropDown"])
	
	
	PM_UI_LIST[FrameName]["SettingsDropDown"]:Hide();
	
	UIDropDownMenu_Initialize(PM_UI_LIST[FrameName]["SettingsDropDown"], function(level)
		--PM_UI_CreateDropdownFromArray(PM_Settings["Settings"]["frames"][FrameName]["Display Settings"], level, this)
		-- Add default buttons
		if level == 1
		then
			info = {}
			info.hasArrow = false
			
			info.text = "Data stuff";
			--info.isTitle = true;
			info.hasArrow = true;
			info.func = function() end;
			UIDropDownMenu_AddButton(info, 1)
			info.isTitle = nil;
			info.disabled = nil;
			info.hasArrow = false;
			
			info.hasArrow = false
			
			info.text = "Settings";
			--info.isTitle = true;
			info.func = function() PM_UI_Settings_Show() end;
			UIDropDownMenu_AddButton(info, 1)
			info.isTitle = nil;
			info.disabled = nil;
			info.hasArrow = false;
			
			info.text = "History";
			--info.isTitle = true;
			info.func = function() PM_UI_History_Show() end;
			UIDropDownMenu_AddButton(info, 1)
			info.isTitle = nil;
			info.disabled = nil;
			info.hasArrow = false;
			
			
			info.text = "End 'current' session";
			--info.isTitle = true;
			info.func = function() PM_EndCurrent() end;
			UIDropDownMenu_AddButton(info, 1)
			info.isTitle = nil;
			info.disabled = nil;
			info.hasArrow = false;
			
			
			
		end;
		
		if level == 2
		then
			if UIDROPDOWNMENU_MENU_VALUE == "Data stuff"
			then
				info.text = "Remove Session";
				info.func = function() PM_ResetSession(session); session = "current" end;
				UIDropDownMenu_AddButton(info, 2)
				
				
				info.text = "NUKE DATA";
				info.func = PM_NukeData;
				UIDropDownMenu_AddButton(info, 2)
				
				
				info.text = "RESET CONFIG (Also nuke and ReloadUI)";
				info.func = function() PM_ResetSettings(); ReloadUI(); end;
				UIDropDownMenu_AddButton(info, 2)
			end;
		end;
	end, "MENU")
	
	
	
	
	
	
	
	
	-- Rightclick player dropdown
	
		-- Create the dropdown, and configure its appearance
	PM_UI_LIST[FrameName]["PlayerDropDown"] = CreateFrame("FRAME", "PlayerDropDown_GLOBAL", UIParent, "UIDropDownMenuTemplate")
	PM_UI_LIST[FrameName]["PlayerDropDown"]:SetPoint("CENTER", nil, UIParent, 0, 0)
	UIDropDownMenu_SetWidth(200, PM_UI_LIST[FrameName]["PlayerDropDown"])
	
	
	PM_UI_LIST[FrameName]["PlayerDropDown"]:Hide();
	
	UIDropDownMenu_Initialize(PM_UI_LIST[FrameName]["PlayerDropDown"], function(level)
		PM_(UIDROPDOWNMENU_MENU_VALUE);
		PM_(level);
		if level == 1
		then
			info.text = "Broadcast";
			info.isTitle = nil;
			info.disabled = nil;
			--info.isTitle = true;
			info.hasArrow = true;
			UIDropDownMenu_AddButton(info, level)

		end;
		
		if level == 2
		then
			info.text = "Say";
			info.hasArrow = false;
			info.func = function() PM_BroadcastDataToChannel("say") end;
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Party";
			info.hasArrow = false;
			info.func = function() PM_BroadcastDataToChannel("party") end;
			UIDropDownMenu_AddButton(info, level)
			
			
			info.text = "Raid";
			info.hasArrow = false;
			info.func = function() PM_BroadcastDataToChannel("raid") end;
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Guild";
			info.hasArrow = false;
			info.func = function() PM_BroadcastDataToChannel("guild") end;
			UIDropDownMenu_AddButton(info, level)
		end;
	end)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--PM_UI_LIST[FrameName]["MoveBackground"]["RightClickMenu"] = PM_UI_CreateDropDown(PM_UI_LIST[FrameName]["MoveBackground"], {})
	--UIDropDownMenu_Initialize(PM_UI_LIST[FrameName]["MoveBackground"]["RightClickMenu"], PM_UI_RightClickMenu_Initialise)
	
	
	
	
	PM_UI_LIST[FrameName]["nextSessionButton"] = PM_UI_CreateButton(PM_UI_LIST[FrameName]["background"], {
		["x"] = 0,
		["y"] = 15,
		["width"] = 15,
		["height"] = 15,
		["anchor"] = "TOPRIGHT",
		["text"] = ">>",
		["r"] = 0.5,
		["g"] = 0.5,
		["b"] = 0.5,
		["a"] = 1,
	});
	
	
	PM_UI_LIST[FrameName]["nextSessionButton"]:SetScript("OnMouseDown", function()
		PM_UI_DamageMeter_RotateSession();
	end)
	
	PM_UI_LIST[FrameName]["prevSessionButton"] = PM_UI_CreateButton(PM_UI_LIST[FrameName]["background"], {
		["x"] = 0,
		["y"] = 15,
		["width"] = 15,
		["height"] = 15,
		["anchor"] = "TOPLEFT",
		["text"] = "<<",
		["r"] = 0.5,
		["g"] = 0.5,
		["b"] = 0.5,
		["a"] = 1,
	});
	
	
	PM_UI_LIST[FrameName]["prevSessionButton"]:SetScript("OnMouseDown", function()
		PM_UI_DamageMeter_RotateSession(true);
	end)
	
	PM_UI_LIST[FrameName]["nextSessionButton"]:Hide();
	PM_UI_LIST[FrameName]["prevSessionButton"]:Hide();

	for i = 1, 40
	do
		if PM_UI_LIST[FrameName]["bar"][i] == nil
		then
			PM_UI_LIST[FrameName]["bar"][i] = {}
		end;
		
		PM_UI_LIST[FrameName]["bar"][i]["background"] = PM_UI_CreateFrame("Frame", PM_UI_LIST[FrameName]["background"], {
			["x"] = 0,
			["y"] = -PM_Settings["Settings"]["frames"][FrameName]["bars"]["height"]*(i-1),
			["width"] = PM_Settings["Settings"]["frames"][FrameName]["background"]["width"],
			["height"] = PM_Settings["Settings"]["frames"][FrameName]["bars"]["height"],
			["anchor"] = "topleft",
			--["texture"] = "Interface\\TimeTracker\\textures\\test.png",
			["textureLevel"] = "background",
			["r"] = 0.2+0.1*PM_fmod(i,2),
			["g"] = 0.2+0.1*PM_fmod(i,2),
			["b"] = 0.2+0.1*PM_fmod(i,2),
			["a"] = 1,
		});
		PM_UI_LIST[FrameName]["bar"][i]["background"].barID = i;
		PM_UI_LIST[FrameName]["bar"][i]["background"]:EnableMouse(true)
		PM_UI_LIST[FrameName]["bar"][i]["background"]:SetScript("OnEnter", function()
			--PM_("Mouse enter: ".. this.barID);
			PM_IsMouseOver = true;
			if this.barID ~= PM_CurrentBarID
			then
				HideDropDownMenu(1);
			end;
			PM_UI_DamageMeter_MouseOver(this.barID);
		end)
		PM_UI_LIST[FrameName]["bar"][i]["background"]:SetScript("OnLeave", function()
			--PM_("Mouse left: ".. this.barID);
			--PM_CurrentBarID = nil;
			PM_IsMouseOver = false;
			GameTooltip:Hide()
		end)
		--PM_UI_LIST[FrameName]["bar"][i]["background"]:SetScript("OnMouseDown", function()
		--	PM_("We clicked on: " .. this.barID);
		--end)
		
		PM_UI_LIST[FrameName]["bar"][i]["background"]:EnableMouse(true);
		PM_UI_LIST[FrameName]["bar"][i]["background"]:SetScript("OnMouseDown", function()
			--PM_(PM_CurrentBarID);
			if arg1 == "RightButton"
			then
				GameTooltip:Hide()
				ToggleDropDownMenu(1, nil, PM_UI_LIST[FrameName]["PlayerDropDown"], PM_UI_LIST[FrameName]["bar"][PM_CurrentBarID]["background"], 0, 20);
			end;
		end)
		
		
		PM_UI_LIST[FrameName]["bar"][i]["bar"] = PM_UI_CreateFrame("Frame", PM_UI_LIST[FrameName]["bar"][i]["background"], {
			["x"] = 0,
			["y"] = 0,
			["width"] = 100,
			["height"] = PM_Settings["Settings"]["frames"][FrameName]["bars"]["height"],
			["anchor"] = "topleft",
			--["texture"] = "Interface\\TimeTracker\\textures\\test.png",
			["textureLevel"] = "background",
			["r"] = math.random(100)/100,
			["g"] = math.random(100)/100,
			["b"] = math.random(100)/100,
			["a"] = 1,
		});
		
		
		PM_UI_LIST[FrameName]["bar"][i]["bar"]["text"] = {}
		PM_UI_LIST[FrameName]["bar"][i]["bar"]["text"]["PlayerName"] = PM_UI_CreateFont(PM_UI_LIST[FrameName]["bar"][i]["bar"], "rexas"..i, {
			["x"] = 0,
			["y"] = 0,
			["size"] = 14,
			["anchor"] = "left",
			["font"] = "Fonts\\FRIZQT__.TTF",
		})
		
		PM_UI_LIST[FrameName]["bar"][i]["background"]["text"] = {}
		PM_UI_LIST[FrameName]["bar"][i]["background"]["text"]["DamageText"] = PM_UI_CreateFont(PM_UI_LIST[FrameName]["bar"][i]["bar"], "999999", {
			["x"] = 0,
			["y"] = 0,
			["size"] = 14,
			["anchor"] = "right",
			["font"] = "Fonts\\FRIZQT__.TTF",
			["parent"] = PM_UI_LIST[FrameName]["bar"][i]["background"]
		})
		
		PM_UI_LIST[FrameName]["bar"][i]["background"]:Hide()
	end;
	
	PM_Settings["Settings"]["frames"][FrameName]["dirty"] = true; -- We have now made all teh frames, next update will we scan them.
end;


function PM_BroadcastDataToChannel(channel)
	local barID = PM_CurrentBarID;
	PM_(PM_CurrentBarID .. " to channel: " .. channel .. " session: " .. session);
	local player = PM_UI_LIST[FrameName]["bar"][barID]["bar"].BarPlayer
	local dPlayer = PM_UI_LIST[FrameName]["bar"][barID]["bar"]["text"]["PlayerName"]:GetText()
	local dirty = PM_UI_LIST[FrameName]["bar"][barID]["bar"].Dirty;
	
	
	if PM_Settings["Data"][session] ~= nil and PM_Settings["Data"][session]["players"] ~= nil and PM_Settings["Data"][session]["players"][player] ~=nil
	then
		PM_("BroadcastDatAToChannel")
		local r,g,b = PM_GetNameColor(player)
		
		local sortedArray, dataArray, maxDamage, combatStart, combatDuration, playerCombatStart, playerCombatDuration = PM_GetSortedPlayerData(player, session)
		
		PM_SendMessage(dPlayer, channel);
		
		local bottomLine, wHitAvg, wGlancAvg = PM_GetSortedPlayerDataStrings(sortedArray, dataArray, maxDamage, false);
		
		for _, line in pairs(bottomLine)
		do
			local left = line["left"];
			local right = line["right"];
			local lC = line["color"];
			PM_SendMessage(left .. " -> " .. right, channel);
		end;
		
		if wHitAvg > 0 and wGlancAvg > 0
		then
			PM_SendMessage("Hit/Glancing avarage damage: ", PM_UI_hitColor .. wHitAvg .. "/"..PM_UI_glancColor ..wGlancAvg .. " " .. PM_round((1-(wGlancAvg/wHitAvg))*100) .. "% reduction", channel);
		end;
		--PM_SendMessage(PM_UI_hitColor.."hit, ".. PM_UI_critColor .."crit, ".. PM_UI_glancColor .."glancing, " .. PM_UI_missColor .. "miss/resist " .. PM_UI_dpbColor .. "dodge/parry/block", channel);
		if dirty
		then
			PM_SendMessage("* Dirty data, data is not synced from the player.", channel);
		end;
	end;
end;

function PM_GetSessionDuration(session)
	local combatStart = 0;
	local combatEnd = 0;
	local combatDuration = 0;
	if PM_Settings["Data"][session] ~= nil 
	and PM_Settings["Data"][session]["players"] ~= nil
	then
		for player,_ in pairs(PM_Settings["Data"][session]["players"])
		do
			for k,d in pairs(PM_Settings["Data"][session]["players"][player])
			do
				if d["castTime"] ~= nil
				then
					if combatStart == 0 or combatStart > tonumber(d["castTime"])
					then
						combatStart = tonumber(d["castTime"]);
					end;
					
					if combatEnd == 0 or combatEnd < tonumber(d["castTime"])
					then
						combatEnd = tonumber(d["castTime"]);
					end;
				end;
			end;
		end;
	end;
	return tonumber(combatStart), tonumber(combatEnd), tonumber(combatEnd - combatStart);
end;


function PM_CombineSortedPlayerData(player, session, filter, sortedArray, ttArr, totalCount, maxDamage, combatStart, combatDuration)
	if sortedArray == nil
	then
		sortedArray = {}
	end;
	if ttArr == nil
	then
		ttArr = {}
	end;
	if filter == nil
	then
		filter = {};
		filter["all"] = true;
	end
	if totalCount == nil
	then
		totlaCount = 0;
	end;
	if maxDamage == nil
	then
		maxDamage = 0;
	end;
	if combatStart == nil
	then
		combatStart = 0;
	end
	combatStart = tonumber(combatStart);
	if combatDuration == nil
	then
		combatDuration = 0;
	end;
	
	local combatEnd = 0;
	
	if PM_Settings["Data"][session] ~= nil 
	and PM_Settings["Data"][session]["players"] ~= nil
	and PM_Settings["Data"][session]["players"][player] ~= nil
	then
		for k,d in pairs(PM_Settings["Data"][session]["players"][player])
		do
			if PM_Settings["Settings"]["frames"][FrameName]["Display Settings"]["Schools"][d["damageClass"]]["value"]
			and (PM_UI_DamageMeter_TargetFilters[d["targetName"]] == true or PM_UI_DamageMeter_TargetFilters["all"] == true)
			and (PM_UI_CasterFilters[d["player"]] == true or PM_UI_CasterFilters["all"] == true)
			then
				if
				(
					PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Session Filter"]["Show outgoing"]["value"] == true
					and
					(
						d["extra"] == "player"
						or
						d["extra"] == "both"
					)
				)
				or
				(
					PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Session Filter"]["Show incomming"]["value"] == true
					and
					(
						d["extra"] == "target"
						or
						d["extra"] == "both"
					)
				)
				then
					if combatStart == 0 
					or combatStart > tonumber(d["castTime"])
					then
						combatStart = tonumber(d["castTime"]);
					end;
					
					if combatEnd == 0 or combatEnd < tonumber(d["castTime"])
					then
						combatEnd = tonumber(d["castTime"]);
					end;
					
					combatDuration = combatEnd - combatStart;
					
					if ttArr[d["ability"]] == nil
					then
						ttArr[d["ability"]] = {}
						ttArr[d["ability"]]["value"] = 0;
						ttArr[d["ability"]]["totalCount"] = 0;
					end;
					
					if ttArr[d["ability"]]["damageModifier"] == nil
					then
						ttArr[d["ability"]]["damageModifier"] = {}
					end;
					
					if ttArr[d["ability"]]["damageModifier"][d["damageModifier"]] == nil
					then
						ttArr[d["ability"]]["damageModifier"][d["damageModifier"]] = {}
						ttArr[d["ability"]]["damageModifier"][d["damageModifier"]]["count"] = 0;
						ttArr[d["ability"]]["damageModifier"][d["damageModifier"]]["totalValue"] = 0;
					end;
					
					
					ttArr[d["ability"]]["value"] = ttArr[d["ability"]]["value"] + d["value"]
					ttArr[d["ability"]]["damageClass"] = d["damageClass"]
					ttArr[d["ability"]]["totalCount"] = ttArr[d["ability"]]["totalCount"] + 1;
					totalCount = totalCount + 1;
					
					ttArr[d["ability"]]["damageModifier"][d["damageModifier"]]["count"] = ttArr[d["ability"]]["damageModifier"][d["damageModifier"]]["count"] + 1;
					ttArr[d["ability"]]["damageModifier"][d["damageModifier"]]["totalValue"] = ttArr[d["ability"]]["damageModifier"][d["damageModifier"]]["totalValue"] + d["value"];
					maxDamage = maxDamage + d["value"];
					if sortedArray[d["ability"]] == nil
					then
						sortedArray[d["ability"]] = 0;
					end;
					sortedArray[d["ability"]] = ttArr[d["ability"]]["value"];
				end;
			end;
		end;
	end;
	return sortedArray, ttArr, totalCount, maxDamage, combatStart, combatDuration;
end;

PM_CurrentBarID = nil;
function PM_GetSortedPlayerData(player, session, filter)
	local ttArr = {}
	local sortedArray = {}
	local totalCount = 0;
	local maxDamage = 0;
	local combatStart;
	local combatDuration;
	local playerCombatStart, playerCombatDuration;
	local combatStart = 0
	local combatEnd = 0
	local combatDuration = 0;
	if session == "all"
	then
		for session,_ in pairs(PM_Settings["Data"])
		do
			--PM_(session)																															 sortedArray, ttArr, totalCount, maxDamage, playerCombatStart, playerCombatDuration
			sortedArray, ttArr, totalCount, maxDamage, playerCombatStart, playerCombatDuration = PM_CombineSortedPlayerData(player, session, filter, sortedArray, ttArr, totalCount, maxDamage, playerCombatStart, playerCombatDuration)
			local s,e,d = PM_GetSessionDuration(session);
			if s < combatStart or combatStart == 0 then combatStart = s; end
			if e > combatEnd or combatEnd == 0 then combatEnd = e; end
			combatDuration = combatEnd - combatStart;
		end;
	else
		sortedArray, ttArr, totalCount, maxDamage, playerCombatStart, playerCombatDuration = PM_CombineSortedPlayerData(player, session, filter, sortedArray, ttArr, totalCount, maxDamage)
		local s,e,d = PM_GetSessionDuration(session);
		if s < combatStart or combatStart == 0 then combatStart = s; end
		if e > combatEnd or combatEnd == 0 then combatEnd = e; end
		combatDuration = combatEnd - combatStart;
	end
	--PM_(ttArr);
	
	sortedArray = PM_SortArrayByValue(sortedArray);
	return sortedArray, ttArr, totalCount, maxDamage, combatStart, combatDuration, playerCombatStart, playerCombatDuration;
end;


function PM_GetSortedPlayerDataStrings(sortedArray, dataArray, maxDamage, useColors)
	if useColors == nil
	then
		useColors = true;
	end;
	
	local ttArr = dataArray;
	local bottomLine = {}
	
	local wHitAvg = 0;
	local wGlancAvg = 0;
	
	--PM_(ttArr)
	
	for kt,vt in pairs(sortedArray)
	do
		k = vt["key"];
		--PM_(k);
		v = ttArr[k];
		local lC = {1,0,0}
		local rC = {0.5,0.5,0.5}
		local hit = 0;
		local glanc = 0;
		local crit = 0;
		local miss = 0;
		local resist = 0;
		local dodge = 0;
		local parry = 0;
		local block = 0;
		
		
		lC = PM_GetSchoolColor(string.lower(v["damageClass"]))

		
		-- 999 23/5/4
		
		--v["totalCount"]
		
		if ttArr[k]["damageModifier"]["hit"] ~= nil
		then
			hit = ttArr[k]["damageModifier"]["hit"]["count"];
			if k == "white"
			then
				--PM_("this is white")
				wHitAvg = PM_round(ttArr[k]["damageModifier"]["hit"]["totalValue"]/hit, 2);
			end;
		end;
		
		if ttArr[k]["damageModifier"]["glancing"] ~= nil
		then
			glanc = ttArr[k]["damageModifier"]["glancing"]["count"];
			if k == "white"
			then
				wGlancAvg = PM_round(ttArr[k]["damageModifier"]["glancing"]["totalValue"]/glanc, 2);
			end
		end;
		
		
		-- crit
		if ttArr[k]["damageModifier"]["crit"] ~= nil
		then
			crit = ttArr[k]["damageModifier"]["crit"]["count"];
		end;
		
		-- miss
		if ttArr[k]["damageModifier"]["miss"] ~= nil
		then
			miss = ttArr[k]["damageModifier"]["miss"]["count"];
		end;
		
		if ttArr[k]["damageModifier"]["resist"] ~= nil
		then
			resist = ttArr[k]["damageModifier"]["resist"]["count"];
		end;
		
		if ttArr[k]["damageModifier"]["dodge"] ~= nil
		then
			dodge = ttArr[k]["damageModifier"]["dodge"]["count"];
		end;
		
		if ttArr[k]["damageModifier"]["parry"] ~= nil
		then
			parry = ttArr[k]["damageModifier"]["parry"]["count"];
		end;
		
		if ttArr[k]["damageModifier"]["block"] ~= nil
		then
			block = ttArr[k]["damageModifier"]["block"]["count"];
		end;
		
		local dpb = dodge + parry + block;
		local mr = miss + resist;
		local dmg = v["value"];
		
		if IsShiftKeyDown()
		then
			hit = PM_round(hit/v["totalCount"]*100,2).."%";
			glanc = PM_round(glanc/v["totalCount"]*100,2).."%";
			crit = PM_round(crit/v["totalCount"]*100,2).."%";
			mr = PM_round(mr/v["totalCount"]*100,2).."%";
			dmg = PM_round(v["value"]/maxDamage*100, 2).."%";
			dpb = PM_round(dpb/v["totalCount"]*100, 2).."%";
			dodge = PM_round(dodge/v["totalCount"]*100, 2).."%";
			parry = PM_round(parry/v["totalCount"]*100, 2).."%";
			block = PM_round(block/v["totalCount"]*100, 2).."%";
		end;
		
		if k == "white" or k == "white pet" -- IsShiftKeyDown()
		then
			if useColors
			then
				modStr = dmg .. "  "..PM_UI_bracketColor.."[" .. PM_UI_hitColor .. hit.." " .. PM_UI_critColor .. crit .. " " .. PM_UI_glancColor .. glanc .." " .. PM_UI_missColor .. mr .. " " .. PM_UI_dpbColor .. dodge .. " " .. parry .. " " .. block .. PM_UI_bracketColor .. "]";
			else
				modStr = dmg .. "  ".."[" .. hit.."h " .. crit .. "c " .. glanc .."g " .. mr .. "mr " .. dodge .. "d " .. parry .. "p " .. block .. "b]";
			end;
		else
			if useColors
			then
				modStr = dmg .. "  "..PM_UI_bracketColor.."[" .. PM_UI_hitColor .. hit.." " .. PM_UI_critColor .. crit .. " " .. PM_UI_missColor .. mr .. " " .. PM_UI_dpbColor .. dodge .. " " .. parry .. " " .. block .. PM_UI_bracketColor .. "]";
			else
				modStr = dmg .. "  ".."[" .. hit.."h " .. crit .. "c " .. mr .. "mr " .. dodge .. "d " .. parry .. "p " .. block .. "b]";
			end;
		end;
		local inArr = 
		{
			["left"] = k,
			["right"] = modStr,
			["color"] = lC,
		}
		table.insert(bottomLine, inArr);
	end;
	
	return bottomLine, wHitAvg, wGlancAvg;
end;

function PM_UI_DamageMeter_MouseOver(barID)
	
	if PM_IsMouseOver == false
	then
		return;
	end;
	
	
	if barID == nil
	then
		if PM_CurrentBarID == nil
		then
			return;
		else
			barID = PM_CurrentBarID
		end;
	else
		PM_CurrentBarID = barID;
	end;
	local player = PM_UI_LIST[FrameName]["bar"][barID]["bar"].BarPlayer;
	local dPlayer = PM_UI_LIST[FrameName]["bar"][barID]["bar"]["text"]["PlayerName"]:GetText()
	local dirty = PM_UI_LIST[FrameName]["bar"][barID]["bar"].Dirty;
	
	--PM_(player);

	-- PM_Settings["Data"][session]["info"]["combatStart"] -- string
	-- PM_Settings["Data"][session]["info"]["combatEnd"] -- string
	-- PM_Settings["Data"][session]["info"]["totalDamage"] -- string
	-- PM_Settings["Data"][session]["info"]["totalHealing"] -- string
	-- PM_Settings["Data"][session]["info"]["playerData"] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player]["totalDamage"] -- number
	-- PM_Settings["Data"][session]["info"]["playerData"][player]["totalHealing"] -- number
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["count"] -- number
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["value"] -- number
		
		
	
	-- PM_Settings["Data"][session]["players"] -- list
	-- PM_Settings["Data"][session]["players"][player] -- list
	-- PM_Settings["Data"][session]["players"][player][I++] -- list
	-- PM_Settings["Data"][session]["players"][player][I++]["castTime"] 			= castTime,
	-- PM_Settings["Data"][session]["players"][player][I++]["player"] 				= player,
	-- PM_Settings["Data"][session]["players"][player][I++]["ability"]				= ability,
	-- PM_Settings["Data"][session]["players"][player][I++]["value"] 				= value,
	-- PM_Settings["Data"][session]["players"][player][I++]["targetName"] 			= targetName,
	-- PM_Settings["Data"][session]["players"][player][I++]["damageModifier"] 		= string.lower(damageModifier),
	-- PM_Settings["Data"][session]["players"][player][I++]["damageClass"] 			= string.lower(damageClass),
	-- PM_Settings["Data"][session]["players"][player][I++]["extra"] 				= extra
		
	--PM_("Mouse over: " ..barID);
	
	if PM_Settings["Data"][session] ~= nil and (session == "all" or (PM_Settings["Data"][session]["players"] ~= nil and PM_Settings["Data"][session]["players"][player] ~=nil) )
	then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(PM_UI_LIST[FrameName]["bar"][barID]["background"], "LEFT");
		local r,g,b = PM_GetNameColor(player)
		
		local sortedArray, dataArray, totalCount,maxDamage, combatStart, combatDuration, playerCombatStart, playerCombatDuration = PM_GetSortedPlayerData(player, session, PM_UI_DamageMeter_TargetFilters)
		local bottomLine, wHitAvg, wGlancAvg = PM_GetSortedPlayerDataStrings(sortedArray, dataArray, maxDamage);
		
		GameTooltip:AddDoubleLine(dPlayer, maxDamage .. " (".. PM_round(maxDamage/combatDuration, 2) .." dps) ", r,g,b, 0.8,0.8,0.8);
		
		--PM_(sortedArray);
		
		
		
		for _, line in pairs(bottomLine)
		do
			local left = line["left"];
			local right = line["right"];
			local lC = line["color"];
			GameTooltip:AddDoubleLine(left, right, lC[1],lC[2],lC[3], lC[1],lC[2],lC[3]);
		end;
		
		if wHitAvg > 0 and wGlancAvg > 0
		then
			GameTooltip:AddDoubleLine("´", "", 1,1,1, 1,1,1);
			GameTooltip:AddDoubleLine("Hit/Glancing avarage damage: ", PM_UI_hitColor .. wHitAvg .. "/"..PM_UI_glancColor ..wGlancAvg .. " " .. PM_round((1-(wGlancAvg/wHitAvg))*100) .. "% reduction" , 1,1,1, 1,1,1);
		end;
		GameTooltip:AddDoubleLine("´", "", 1,1,1, 1,1,1);
		GameTooltip:AddDoubleLine(PM_UI_hitColor.."hit, ".. PM_UI_critColor .."crit, ".. PM_UI_glancColor .."glancing, " .. PM_UI_missColor .. "miss/resist " .. PM_UI_dpbColor .. "dodge/parry/block", "", 1,1,1, 1,1,1);
		GameTooltip:AddDoubleLine("Block count is for full blocks.", "", 1,1,1, 1,1,1);
		if dirty
		then
			GameTooltip:AddDoubleLine("* Dirty data, data is not synced from the player.", "", 0.7,0.7,0.7, 1,1,1);
		end;
		GameTooltip:Show()
	end;
end;


