PM_UI_LIST["SettingsWindow"] = {};
PM_UI_LIST["SettingsWindow"]["tabs"] = {}
PM_UI_LIST["SettingsWindow"]["bar"] = {} -- This is the array that holds all our bars.
PM_UI_LIST["SettingsWindow"]["OnLoad"] = function() PM_UI_Settings_OnLoad() end;
PM_UI_LIST["SettingsWindow"]["OnUpdate"] = function() PM_UI_Settings_OnUpdate() end;
PM_UI_LIST["SettingsWindow"]["OnEvent"] = function(event, arg1, arg2, arg3, arg4, arg5) PM_UI_Settings_OnEvent(event, arg1, arg2, arg3, arg4, arg5) end;

function PM_UI_Settings_Show()
	PM_UI_LIST["SettingsWindow"]["background"]:Show();
	PM_UI_Settings_ReloadTab();
end;

function PM_UI_Settings_OnLoad()
	PM_("OnLoad for " .. "SettingsWindow")
	--PM_UI_DefaultSettings(); -- Always reset.
	if PM_Settings["Settings"]["frames"] == nil or PM_Settings["Settings"]["frames"]["SettingsWindow"] == nil
	then
		PM_UI_Settings_DefaultSettings();
	end;
	PM_UI_Settings_CreateFrames();
end;

function PM_UI_Settings_OnEvent(event, arg1, arg2, arg3, arg4, arg5)
end

function PM_UI_Settings_OnUpdate()

end;

function PM_UI_Settings_DefaultSettings()
	if PM_Settings["Settings"]["frames"] == nil
	then
		PM_Settings["Settings"]["frames"] = {}
	end;
	PM_Settings["Settings"]["frames"]["SettingsWindow"] = 
	{
		["dirty"] = false, -- Dirty is when a update have happen and we need to reload it. Use this when the background changes size to hide/show bars.
		["background"] = PM_UI_GetFrameSettings(
			{
				["x"] = 0,
				["y"] = 0,
				["anchor"] = "center",
				--["texture"] = "Interface\\AddOns\\PlayerMeter\\textures\\face.tga",
				["width"] = 810,
				["height"] = 650,
				["r"] = 0.3,
				["g"] = 0.3,
				["b"] = 0.3,
				["a"] = 0.8,
			}
		)
	}
end;

PM_UI_Settings_CurrentTab = "";

function PM_UI_Settings_CreateFrames()
	PM_UI_LIST["SettingsWindow"]["background"] = PM_UI_CreateFrame("Frame", nil, PM_Settings["Settings"]["frames"]["SettingsWindow"]["background"]);
	
	PM_UI_LIST["SettingsWindow"]["background"]:Hide();
	--PM_UI_LIST["SettingsWindow"]["background"]:Show();
	
	PM_UI_LIST["SettingsWindow"]["background"]["text"] = {}
	PM_UI_LIST["SettingsWindow"]["background"]["text"]["SessionText"] = PM_UI_CreateFont(PM_UI_LIST["SettingsWindow"]["background"], "settings", {
		["x"] = 0,
		["y"] = 17,
		["size"] = 12,
		["anchor"] = "top",
		["font"] = "Fonts\\FRIZQT__.TTF",
		["parent"] = PM_UI_LIST["SettingsWindow"]["background"]["text"]["SessionText"]
	})
	
	
	PM_UI_LIST["SettingsWindow"]["background"]:SetMovable(true);
	PM_UI_LIST["SettingsWindow"]["background"]:EnableMouse(true);
	--PM_UI_LIST["SettingsWindow"]["background"]:SetResizable(true);
	PM_UI_LIST["SettingsWindow"]["background"]:SetMinResize(100,40)
	PM_UI_LIST["SettingsWindow"]["background"]:SetScript("OnMouseDown", function() PM_UI_MoveFrameStart(arg1, this, "SettingsWindow"); end)
	PM_UI_LIST["SettingsWindow"]["background"]:SetScript("OnMouseUp", function() PM_UI_MoveFrameStop(arg1, this, "SettingsWindow", PM_Settings["Settings"]["frames"]["SettingsWindow"]["background"]); end)
	PM_UI_LIST["SettingsWindow"]["background"]:SetScript("OnHide", function() PM_UI_MoveFrameHide(arg1, this, "SettingsWindow"); end)
	
	-- Close button
	
	PM_UI_LIST["SettingsWindow"]["CloseButton"] = PM_UI_CreateButton(PM_UI_LIST["SettingsWindow"]["background"],
	{
		["x"] = 0,
		["y"] = 0,
		["width"] = 20,
		["height"] = 20,
		["anchor"] = "TOPRIGHT",
		["text"] = "X",
		["r"] = 0.5,
		["g"] = 0.5,
		["b"] = 0.5,
		["a"] = 1,
	});
		
	PM_UI_LIST["SettingsWindow"]["CloseButton"]:SetScript("OnMouseDown", function()
		PM_UI_LIST["SettingsWindow"]["background"]:Hide();
	end)
	
	
	-- Load tabs
	PM_UI_Settings_CreateFrame_SessionSelect();
	PM_UI_Settings_CreateFrame_DamageMeterStyle();
	
	-- Create buttons
	
	local i = 0;
	local totalWidth = 0;
	for k,v in pairs(PM_UI_LIST["SettingsWindow"]["tabs"])
	do
		if i == 0
		then
			PM_UI_Settings_CurrentTab = k;
		end;
		local buttonWidth = string.len(k) * 10;
		v["MenuButton"] = PM_UI_CreateButton(PM_UI_LIST["SettingsWindow"]["background"],
		{
			["x"] = totalWidth,
			["y"] = 0,
			["width"] = buttonWidth,
			["height"] = 15,
			["anchor"] = "TOPLEFT",
			["text"] = k,
			["r"] = 0.5,
			["g"] = 0.5,
			["b"] = 0.5,
			["a"] = 1,
		});
		
		v["MenuButton"]:SetScript("OnMouseDown", function()
			PM_UI_Settings_CurrentTab = this:GetText()
			PM_UI_Settings_ReloadTab();
		end)
		totalWidth = totalWidth + buttonWidth;
		
		
		i = i + 1;
	end;
	
	
	-- Done, now load the first tab.
	PM_UI_Settings_ReloadTab()
	
end;

function PM_UI_Settings_ReloadTab()
	local func;
	for tabName,d in pairs(PM_UI_LIST["SettingsWindow"]["tabs"])
	do
		if tabName == PM_UI_Settings_CurrentTab
		then
			d["MenuButton"].texture:SetVertexColor(0.2,0.6,0.2,1);
		else
			d["MenuButton"].texture:SetVertexColor(0.2,0.2,0.2,1);
		end;
		for k,v in pairs(d)
		do
			if k == "func" and tabName == PM_UI_Settings_CurrentTab
			then
				func = v;
			end;
			if k ~= "MenuButton" and k ~= "func"
			then
				if tabName == PM_UI_Settings_CurrentTab
				then
					v:Show();
				else
					v:Hide();
				end;
			end;
		end;
	end;
	if func ~= nil
	then
		func();
	end;
end;

function MyModScrollBar_Update()
	PM_("lalalala");
end;

function PM_UI_Settings_CreateFrame_SessionSelect()
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"] = {}
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["func"] = function()
		PM_UI_Settings_Update_SessionSelect();
	end;
	
	local buttonWidth = 250;
	local buttonHeight = 20;
	local buttonWidthPadding = 2;
	local buttonHeightPadding = 0;
	local x = 0;
	local y = 0;
	
	
	-- Session selection 
	
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionSelect_text"] = PM_UI_CreateFont(PM_UI_LIST["SettingsWindow"]["background"], "Session select", {
		["x"] = 80,
		["y"] = -22,
		["size"] = 15,
		["anchor"] = "topleft",
		["font"] = "Fonts\\FRIZQT__.TTF",
	})
	
	
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterSelect_text"] = PM_UI_CreateFont(PM_UI_LIST["SettingsWindow"]["background"], "Caster select", {
		["x"] = 350,
		["y"] = -22,
		["size"] = 15,
		["anchor"] = "topleft",
		["font"] = "Fonts\\FRIZQT__.TTF",
	})
	
		
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetSelect_text"] = PM_UI_CreateFont(PM_UI_LIST["SettingsWindow"]["background"], "Target select", {
		["x"] = 600,
		["y"] = -22,
		["size"] = 15,
		["anchor"] = "topleft",
		["font"] = "Fonts\\FRIZQT__.TTF",
	})
	
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SchoolSelect_text"] = PM_UI_CreateFont(PM_UI_LIST["SettingsWindow"]["background"], "School select", {
		["x"] = 0,
		["y"] = -((PM_UI_Settings_SessionSelect_buttonCount * (buttonHeight + buttonHeightPadding)) + 50),
		["size"] = 15,
		["anchor"] = "top",
		["font"] = "Fonts\\FRIZQT__.TTF",
	})
	
	
	for i = 0, PM_UI_Settings_SessionSelect_buttonCount-1
	do
		if x * (buttonWidth + buttonWidthPadding) + (buttonWidth + buttonWidthPadding) > PM_UI_LIST["SettingsWindow"]["background"]:GetWidth()
		then
			y = y + 1;
			x = 0;
		end;
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. i] = PM_UI_CreateButton(PM_UI_LIST["SettingsWindow"]["background"],
		{
			["x"] = x*(buttonWidth + buttonWidthPadding) + buttonWidthPadding,
			["y"] = y*(-buttonHeight - buttonHeightPadding) - buttonHeightPadding- 40,
			["width"] = buttonWidth,
			["height"] = buttonHeight,
			["anchor"] = "TOPLEFT",
			["text"] = "",
			["r"] = 0.4,
			["g"] = 0.4,
			["b"] = 0.4,
			["a"] = 1,
		});
		if i == 0
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. i]:SetScript("OnMouseDown", function() PM_UI_Settings_SessionSelect_Offset = PM_UI_Settings_ChangeOffset(PM_UI_Settings_SessionSelect_Offset, false); PM_UI_Settings_Update_SessionSelect(); end)
		elseif i == PM_UI_Settings_SessionSelect_buttonCount-1 
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. i]:SetScript("OnMouseDown", function() PM_UI_Settings_SessionSelect_Offset = PM_UI_Settings_ChangeOffset(PM_UI_Settings_SessionSelect_Offset, true); PM_UI_Settings_Update_SessionSelect(); end)
		else
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. i]:EnableMouseWheel(true);
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. i]:SetScript("OnMouseWheel", function(self, delta)
				if IsShiftKeyDown()
				then
					PM_UI_Settings_SessionSelect_Offset = PM_UI_Settings_SessionSelect_Offset + -(arg1*10);
				else
					PM_UI_Settings_SessionSelect_Offset = PM_UI_Settings_SessionSelect_Offset + -arg1;
				end
				if PM_UI_Settings_SessionSelect_Offset < 0
				then
					PM_UI_Settings_SessionSelect_Offset = 0;
				end;
				PM_UI_Settings_Update_SessionSelect();
			end)
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. i]:SetScript("OnMouseDown", function()
				PM_UI_DamageMeter_TargetFilters = {["all"] = true};
				PM_UI_DamageMeter_SetSession(this:GetText());
				PM_UI_Settings_Update_SessionSelect();
				PM_UI_History_UpdateData(true);
			end)
		end;
		
		
		y = y + 1;
	end;
	
	
	
	-- Target filter
	x = 0;
	y = 0;
	
	
	for i = 0, PM_UI_Settings_SessionSelect_buttonCount-1
	do
		if x * (buttonWidth + buttonWidthPadding) + (buttonWidth + buttonWidthPadding) > PM_UI_LIST["SettingsWindow"]["background"]:GetWidth()
		then
			y = y + 1;
			x = 0;
		end;
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. i] = PM_UI_CreateButton(PM_UI_LIST["SettingsWindow"]["background"],
		{
			["x"] = ((buttonWidth + buttonWidthPadding) + (buttonWidthPadding*3)*2) + buttonWidth,
			["y"] = y*(-buttonHeight - buttonHeightPadding) - buttonHeightPadding - 40,
			["width"] = buttonWidth,
			["height"] = buttonHeight,
			["anchor"] = "TOPLEFT",
			["text"] = "",
			["r"] = 0.5,
			["g"] = 0.5,
			["b"] = 0.5,
			["a"] = 1,
		});
		if i == 0
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. i]:SetScript("OnMouseDown", function() PM_UI_Settings_TargetFilter_Offset = PM_UI_Settings_ChangeOffset(PM_UI_Settings_TargetFilter_Offset, false); PM_UI_Settings_Update_SessionSelect(); end)
		elseif i == PM_UI_Settings_SessionSelect_buttonCount-1 
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. i]:SetScript("OnMouseDown", function() PM_UI_Settings_TargetFilter_Offset = PM_UI_Settings_ChangeOffset(PM_UI_Settings_TargetFilter_Offset, true); PM_UI_Settings_Update_SessionSelect(); end)
		else
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. i]:EnableMouseWheel(true);
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. i]:SetScript("OnMouseWheel", function(self, delta)
				if IsShiftKeyDown()
				then
					PM_UI_Settings_TargetFilter_Offset = PM_UI_Settings_TargetFilter_Offset + -(arg1*10);
				else
					PM_UI_Settings_TargetFilter_Offset = PM_UI_Settings_TargetFilter_Offset + -arg1;
				end
				if PM_UI_Settings_TargetFilter_Offset < 0
				then
					PM_UI_Settings_TargetFilter_Offset = 0;
				end;
				PM_UI_Settings_Update_SessionSelect();
			end)
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. i]:SetScript("OnMouseDown", function()
				if this:GetText() == "all"
				then
					PM_UI_DamageMeter_TargetFilters = {["all"] = true};
				else
					PM_UI_DamageMeter_TargetFilters["all"] = false;
					PM_UI_DamageMeter_TargetFilters[this:GetText()] = (PM_UI_DamageMeter_TargetFilters[this:GetText()] ~= true);
					if not PM_UI_DamageMeter_TargetFilters[this:GetText()]
					then
						PM_UI_DamageMeter_TargetFilters[this:GetText()] = nil; -- Make it null so it gets removed.
					end
					if PM_tablelength(PM_UI_DamageMeter_TargetFilters) == 1
					then
						PM_UI_DamageMeter_TargetFilters = {["all"] = true};
					end;
				end;
				PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
				PM_UI_Settings_Update_SessionSelect();
				PM_UI_History_UpdateData(true);
			end)
		end;
		
		
		y = y + 1;
	end;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		-- Caster filter (Filter who is casting it)
	x = 0;
	y = 0;
	
	
	for i = 0, PM_UI_Settings_SessionSelect_buttonCount-1
	do
		if x * (buttonWidth + buttonWidthPadding) + (buttonWidth + buttonWidthPadding) > PM_UI_LIST["SettingsWindow"]["background"]:GetWidth()
		then
			y = y + 1;
			x = 0;
		end;
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. i] = PM_UI_CreateButton(PM_UI_LIST["SettingsWindow"]["background"],
		{
			["x"] = x*(buttonWidth + buttonWidthPadding) + (buttonWidthPadding*3) + buttonWidth,
			["y"] = y*(-buttonHeight - buttonHeightPadding) - buttonHeightPadding - 40,
			["width"] = buttonWidth,
			["height"] = buttonHeight,
			["anchor"] = "TOPLEFT",
			["text"] = "",
			["r"] = 0.5,
			["g"] = 0.5,
			["b"] = 0.5,
			["a"] = 1,
		});
		if i == 0
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. i]:SetScript("OnMouseDown", function() PM_UI_Settings_CasterFilter_Offset = PM_UI_Settings_ChangeOffset(PM_UI_Settings_CasterFilter_Offset, false); PM_UI_Settings_Update_SessionSelect(); end)
		elseif i == PM_UI_Settings_SessionSelect_buttonCount-1 
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. i]:SetScript("OnMouseDown", function() PM_UI_Settings_CasterFilter_Offset = PM_UI_Settings_ChangeOffset(PM_UI_Settings_CasterFilter_Offset, true); PM_UI_Settings_Update_SessionSelect(); end)
		else
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. i]:EnableMouseWheel(true);
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. i]:SetScript("OnMouseWheel", function(self, delta)
				if IsShiftKeyDown()
				then
					PM_UI_Settings_CasterFilter_Offset = PM_UI_Settings_CasterFilter_Offset + -(arg1*10);
				else
					PM_UI_Settings_CasterFilter_Offset = PM_UI_Settings_CasterFilter_Offset + -arg1;
				end
				if PM_UI_Settings_CasterFilter_Offset < 0
				then
					PM_UI_Settings_CasterFilter_Offset = 0;
				end;
				PM_UI_Settings_Update_SessionSelect();
			end)
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. i]:SetScript("OnMouseDown", function()
				if this:GetText() == "all"
				then
					PM_UI_CasterFilters = {["all"] = true};
				else
					PM_UI_CasterFilters["all"] = false;
					PM_UI_CasterFilters[this:GetText()] = (PM_UI_CasterFilters[this:GetText()] ~= true);
					if not PM_UI_CasterFilters[this:GetText()]
					then
						PM_UI_CasterFilters[this:GetText()] = nil; -- Make it null so it gets removed.
					end
					if PM_tablelength(PM_UI_CasterFilters) == 1
					then
						PM_UI_CasterFilters = {["all"] = true};
					end;
				end;
				PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
				PM_UI_Settings_Update_SessionSelect();
				PM_UI_History_UpdateData(true);
			end)
		end;
		
		
		y = y + 1;
	end;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	-- Damage class filter
	
	local i = 0;
	local line = 0;
	
	
	for school,v in pairs(PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Schools"])
	do
		if PM_fmod(i,2) == 0
		then
			line = line + 1;
		end;
		local c = PM_GetSchoolColor(school);
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SchoolFilter_" .. school] = PM_UI_CreateButton(PM_UI_LIST["SettingsWindow"]["background"],
		{
			["x"] = PM_fmod(i,2)*(buttonWidth + buttonWidthPadding) + buttonWidthPadding,
			["y"] = -((line * buttonHeight) + (PM_UI_Settings_SessionSelect_buttonCount * (buttonHeight + buttonHeightPadding)) + 50),
			["width"] = buttonWidth,
			["height"] = buttonHeight,
			["anchor"] = "TOPLEFT",
			["text"] = school,
			["size"] = 20,
			["style"] = "OUTLINE",
			["fr"] = c[1],
			["fg"] = c[2],
			["fb"] = c[3],
		});
		
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SchoolFilter_" .. school]:SetScript("OnMouseDown", function()
			PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Schools"][this:GetText()]["value"] = PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Schools"][this:GetText()]["value"] ~= true;
			PM_UI_Settings_Update_SessionSelect();
			PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
			PM_UI_History_UpdateData(true);
		end)
		i = i + 1;
	end;
	
	
	-- 
	
	
	local i = 0;
	local buttonWidth = 250;
	local buttonHeight = 20;
	local buttonWidthPadding = 2;
	local buttonHeightPadding = 2;
	local x = 0;
	local y = 0;
	local line = 0;
	for k,v in pairs(PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Session Filter"])
	do
		if PM_fmod(i,2) == 0
		then
			line = line + 1;
		end;
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionFilter_" .. k] = PM_UI_CreateButton(PM_UI_LIST["SettingsWindow"]["background"],
		{
			["x"] = PM_fmod(i,2)*(buttonWidth + buttonWidthPadding) + buttonWidthPadding,
			["y"] = -(((line * buttonHeight) + (PM_UI_Settings_SessionSelect_buttonCount * (buttonHeight + buttonHeightPadding)) + 50) + 100),
			["width"] = buttonWidth,
			["height"] = buttonHeight,
			["anchor"] = "TOPLEFT",
			["text"] = k,
			["size"] = 15,
			["style"] = "BOLD",
		});
		
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionFilter_" .. k]:SetScript("OnMouseDown", function()
			PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Session Filter"][this:GetText()]["value"] = PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Session Filter"][this:GetText()]["value"] ~= true;
			PM_UI_Settings_Update_SessionSelect();
			PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
			PM_UI_History_UpdateData(true);
		end)
		i = i + 1;
	end;
end;

PM_UI_Settings_SessionSelect_Offset = 0;
PM_UI_Settings_TargetFilter_Offset = 0;
PM_UI_Settings_CasterFilter_Offset = 0;
PM_UI_Settings_SessionSelect_buttonCount = 20;

function PM_UI_Settings_ChangeOffset(var, increase)
	if increase
	then
		var = var + 1
	else
		var = var - 1
	end;
	
	if var < 0
	then
		var = 0
	end;
	
	return var;
end;

function PM_UI_Settings_Update_SessionSelect()
	--PM_UI_History_UpdateData(true); -- lets see if this lags.
	-- Session select
	local i = 1;
	local button = 1;
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. 0]:SetText("/ ".. PM_UI_Settings_SessionSelect_Offset .." \\");
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. 0].texture:SetVertexColor(0.2,0.2,0.2,1);
	local sortedList = {}
	for s,_ in pairs(PM_Settings["Data"])
	do
		if s ~= "all" and s ~= "current"
		then
			table.insert(sortedList, s);
		end;
	end;
	table.sort(sortedList)
	-- Put all and current on top.
	table.insert(sortedList, 1, "current");
	table.insert(sortedList, 1, "all");
	
	for i = 1, PM_UI_Settings_SessionSelect_buttonCount-1
	do
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. i]:SetText(" ")
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. i].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
		
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. i]:SetText(" ")
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. i].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
	end;
	
	--i = 0;
	for _,s in pairs(sortedList)
	do
		if button < PM_UI_Settings_SessionSelect_buttonCount -1
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. button+1]:SetText(" ")
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. button+1].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. button].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
		end;
		if i > PM_UI_Settings_SessionSelect_Offset and i < PM_UI_Settings_SessionSelect_buttonCount + PM_UI_Settings_SessionSelect_Offset-1
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. button]:SetText(s)
			if s == PM_UI_DamageMeter_GetSession()
			then
				PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. button].texture:SetVertexColor(0.3,0.6,0.3,1);
			end;
			button = button + 1;
		end;
		i = i + 1;
	end;
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. PM_UI_Settings_SessionSelect_buttonCount-1]:SetText("\\ " .. PM_UI_Settings_SessionSelect_Offset .. " /");
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionButton" .. PM_UI_Settings_SessionSelect_buttonCount-1].texture:SetVertexColor(0.2,0.2,0.2,1);
	
	
	
	-- Target filter
	
					
	
	
	local i = 1;
	local button = 1;
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. 0]:SetText("/ ".. PM_UI_Settings_TargetFilter_Offset .." \\");
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. 0].texture:SetVertexColor(0.2,0.2,0.2,1);
	local targets = PM_GetSessionTargets(PM_UI_DamageMeter_GetSession());
	local sortedList = {}
	for s,_ in pairs(targets)
	do
		if s ~= "all"
		then
			table.insert(sortedList, s);
		end;
	end;
	table.sort(sortedList)
	-- Put all and current on top.
	table.insert(sortedList, 1, "all");
	PM_(sortedList)
	
	for _,s in pairs(sortedList)
	do
		if button < PM_UI_Settings_SessionSelect_buttonCount -1
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. button+1]:SetText(" ")
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. button+1].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. button].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
		end;
		if i > PM_UI_Settings_TargetFilter_Offset and i < PM_UI_Settings_SessionSelect_buttonCount + PM_UI_Settings_TargetFilter_Offset-1
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. button]:SetText(s)
			if PM_UI_DamageMeter_TargetFilters[s] == true
			then
				PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. button].texture:SetVertexColor(0.3,0.6,0.3,1);
			else
				PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. button].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
			end;
			button = button + 1;
		end;
		i = i + 1;
	end;
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. PM_UI_Settings_SessionSelect_buttonCount-1]:SetText("\\ " .. PM_UI_Settings_TargetFilter_Offset .. " /");
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["TargetFilterButton" .. PM_UI_Settings_SessionSelect_buttonCount-1].texture:SetVertexColor(0.2,0.2,0.2,1);
	
	
	
	
	
		
	--- Caster filter
	
	
	local i = 1;
	local button = 1;
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. 0]:SetText("/ ".. PM_UI_Settings_CasterFilter_Offset .." \\");
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. 0].texture:SetVertexColor(0.2,0.2,0.2,1);
	local targets = PM_GetSessionTargets(PM_UI_DamageMeter_GetSession(), true);
	local sortedList = {}
	for s,_ in pairs(targets)
	do
		if s ~= "all"
		then
			table.insert(sortedList, s);
		end;
	end;
	table.sort(sortedList)
	-- Put all and current on top.
	table.insert(sortedList, 1, "all");
	
		
	for tmp = 1, PM_UI_Settings_SessionSelect_buttonCount -1
	do
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. tmp]:SetText(" ")
		PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. tmp].texture:SetVertexColor(0.3 + PM_fmod(tmp,2)*0.1,0.3 + PM_fmod(tmp,2)*0.1,0.3 + PM_fmod(tmp,2)*0.1,1);
	end;
	
	
	
	for _,s in pairs(sortedList)
	do
		if button < PM_UI_Settings_SessionSelect_buttonCount -1
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. button+1]:SetText(" ")
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. button+1].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. button].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
		end;
		if i > PM_UI_Settings_CasterFilter_Offset and i < PM_UI_Settings_SessionSelect_buttonCount + PM_UI_Settings_CasterFilter_Offset-1
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. button]:SetText(s)
			if PM_UI_CasterFilters[s] == true
			then
				PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. button].texture:SetVertexColor(0.3,0.6,0.3,1);
			else
				PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. button].texture:SetVertexColor(0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,0.3 + PM_fmod(i,2)*0.1,1);
			end;
			button = button + 1;
		end;
		i = i + 1;
	end;
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. PM_UI_Settings_SessionSelect_buttonCount-1]:SetText("\\ " .. PM_UI_Settings_CasterFilter_Offset .. " /");
	PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["CasterFilterButton" .. PM_UI_Settings_SessionSelect_buttonCount-1].texture:SetVertexColor(0.2,0.2,0.2,1);
	
	
	
	
	
	
	
	
	--- School
	
	for school,v in pairs(PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Schools"])
	do
		if v["value"]
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SchoolFilter_" .. school].texture:SetVertexColor(0.4,0.4,0.4,1);
		else
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SchoolFilter_" .. school].texture:SetVertexColor(0.3,0.3,0.3,1);
		end;
	end;
	
	-- Session settings
	
	for k,v in pairs(PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Session Filter"])
	do
		if v["value"]
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionFilter_" .. k].texture:SetVertexColor(0.4,0.4,0.4,1);
		else
			PM_UI_LIST["SettingsWindow"]["tabs"]["Session Select"]["SessionFilter_" .. k].texture:SetVertexColor(0.3,0.3,0.3,1);
		end;
	end;
	
end;


function PM_UI_Settings_CreateFrame_DamageMeterStyle()
	PM_UI_LIST["SettingsWindow"]["tabs"]["Damage Meter"] = {}
	PM_UI_LIST["SettingsWindow"]["tabs"]["Damage Meter"]["func"] = function()
		PM_UI_Settings_Update_DamageMeterStyle();
	end;
	local i = 0;
	local buttonWidth = 250;
	local buttonHeight = 20;
	local buttonWidthPadding = 2;
	local buttonHeightPadding = 2;
	local x = 0;
	local y = 0;
	local line = 0;
	for k,v in pairs(PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Style settings"])
	do
		if PM_fmod(i,2) == 0
		then
			line = line + 1;
		end;
		PM_UI_LIST["SettingsWindow"]["tabs"]["Damage Meter"]["setting_" .. k] = PM_UI_CreateButton(PM_UI_LIST["SettingsWindow"]["background"],
		{
			["x"] = PM_fmod(i,2)*(buttonWidth + buttonWidthPadding) + buttonWidthPadding,
			["y"] = -((line * buttonHeight) + 50),
			["width"] = buttonWidth,
			["height"] = buttonHeight,
			["anchor"] = "TOPLEFT",
			["text"] = k,
			["size"] = 15,
			["style"] = "BOLD",
		});
		
		PM_UI_LIST["SettingsWindow"]["tabs"]["Damage Meter"]["setting_" .. k]:SetScript("OnMouseDown", function()
			PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Style settings"][this:GetText()]["value"] = PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Style settings"][this:GetText()]["value"] ~= true;
			PM_UI_Settings_Update_DamageMeterStyle();
			PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
		end)
		i = i + 1;
	end;
end;

function PM_UI_Settings_Update_DamageMeterStyle()
	for k,v in pairs(PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Style settings"])
	do
		local c = PM_GetSchoolColor(school);
		if v["value"]
		then
			PM_UI_LIST["SettingsWindow"]["tabs"]["Damage Meter"]["setting_" .. k].texture:SetVertexColor(0.4,0.4,0.4,1);
		else
			PM_UI_LIST["SettingsWindow"]["tabs"]["Damage Meter"]["setting_" .. k].texture:SetVertexColor(0.3,0.3,0.3,1);
		end;
	end;
end;
