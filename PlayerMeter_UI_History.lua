PM_UI_LIST["History"] = {};
PM_UI_LIST["History"]["tabs"] = {}
PM_UI_LIST["History"]["bar"] = {} -- This is the array that holds all our bars.
PM_UI_LIST["History"]["OnLoad"] = function() PM_UI_History_OnLoad() end;
PM_UI_LIST["History"]["OnUpdate"] = function() PM_UI_History_OnUpdate() end;
PM_UI_LIST["History"]["OnEvent"] = function(event, arg1, arg2, arg3, arg4, arg5) PM_UI_History_OnEvent(event, arg1, arg2, arg3, arg4, arg5) end;

function PM_UI_History_Show()
	PM_UI_LIST["History"]["background"]:Show();
	PM_UI_History_ReloadTab();
end;

function PM_UI_History_OnLoad()
	PM_("OnLoad for " .. "History")
	--PM_UI_DefaultSettings(); -- Always reset.
	if PM_Settings["Settings"]["frames"] == nil or PM_Settings["Settings"]["frames"]["History"] == nil
	then
		PM_UI_History_DefaultSettings();
	end;
	PM_UI_History_CreateFrames();
end;

function PM_UI_History_OnEvent(event, arg1, arg2, arg3, arg4, arg5)
end

function PM_UI_History_OnUpdate()

end;

function PM_UI_History_DefaultSettings()
	if PM_Settings["Settings"]["frames"] == nil
	then
		PM_Settings["Settings"]["frames"] = {}
	end;
	PM_Settings["Settings"]["frames"]["History"] = 
	{
		["dirty"] = false, -- Dirty is when a update have happen and we need to reload it. Use this when the background changes size to hide/show bars.
		["background"] = PM_UI_GetFrameSettings(
			{
				["x"] = 0,
				["y"] = 0,
				["anchor"] = "center",
				--["texture"] = "Interface\\AddOns\\PlayerMeter\\textures\\face.tga",
				["width"] = 510,
				["height"] = 650,
				["r"] = 0.3,
				["g"] = 0.3,
				["b"] = 0.3,
				["a"] = 0.8,
			}
		)
	}
end;

PM_UI_History_CurrentTab = "";

function PM_UI_History_CreateFrames()
	PM_UI_LIST["History"]["background"] = PM_UI_CreateFrame("Frame", nil, PM_Settings["Settings"]["frames"]["History"]["background"]);
	
	PM_UI_LIST["History"]["background"]:Hide();
	
	PM_UI_LIST["History"]["background"]["text"] = {}
	PM_UI_LIST["History"]["background"]["text"]["SessionText"] = PM_UI_CreateFont(PM_UI_LIST["History"]["background"], "History", {
		["x"] = 0,
		["y"] = 17,
		["size"] = 12,
		["anchor"] = "top",
		["font"] = "Fonts\\FRIZQT__.TTF",
		["parent"] = PM_UI_LIST["History"]["background"]["text"]["SessionText"]
	})
	
	
	PM_UI_LIST["History"]["background"]:SetMovable(true);
	PM_UI_LIST["History"]["background"]:EnableMouse(true);
	--PM_UI_LIST["History"]["background"]:SetResizable(true);
	PM_UI_LIST["History"]["background"]:SetMinResize(100,40)
	PM_UI_LIST["History"]["background"]:SetScript("OnMouseDown", function() PM_UI_MoveFrameStart(arg1, this, "History"); end)
	PM_UI_LIST["History"]["background"]:SetScript("OnMouseUp", function() PM_UI_MoveFrameStop(arg1, this, "History", PM_Settings["Settings"]["frames"]["History"]["background"]); end)
	PM_UI_LIST["History"]["background"]:SetScript("OnHide", function() PM_UI_MoveFrameHide(arg1, this, "History"); end)
	
	-- Close button
	
	PM_UI_LIST["History"]["CloseButton"] = PM_UI_CreateButton(PM_UI_LIST["History"]["background"],
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
		
	PM_UI_LIST["History"]["CloseButton"]:SetScript("OnMouseDown", function()
		PM_UI_LIST["History"]["background"]:Hide();
	end)
	
	
	-- Load tabs
	PM_UI_History_CreateFrame_HistoryDisplay();
	
	-- Create buttons
	
	local i = 0;
	local totalWidth = 0;
	for k,v in pairs(PM_UI_LIST["History"]["tabs"])
	do
		if i == 0
		then
			PM_UI_History_CurrentTab = k;
		end;
		local buttonWidth = string.len(k) * 10;
		v["MenuButton"] = PM_UI_CreateButton(PM_UI_LIST["History"]["background"],
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
			PM_UI_History_CurrentTab = this:GetText()
			PM_UI_History_ReloadTab();
		end)
		totalWidth = totalWidth + buttonWidth;
		
		
		i = i + 1;
	end;
	
	
	-- Done, now load the first tab.
	PM_UI_History_ReloadTab()
	
end;

function PM_UI_History_ReloadTab()
	local func;
	for tabName,d in pairs(PM_UI_LIST["History"]["tabs"])
	do
		if tabName == PM_UI_History_CurrentTab
		then
			d["MenuButton"].texture:SetVertexColor(0.4,0.4,0.4,1);
		else
			d["MenuButton"].texture:SetVertexColor(0.2,0.2,0.2,1);
		end;
		for k,v in pairs(d)
		do
			if k == "func" and tabName == PM_UI_History_CurrentTab
			then
				func = v;
			end;
			if k ~= "MenuButton" and k ~= "func"
			then
				if tabName == PM_UI_History_CurrentTab
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

function PM_UI_History_CreateFrame_HistoryDisplay()
	PM_UI_LIST["History"]["tabs"]["History Display"] = {}
	PM_UI_LIST["History"]["tabs"]["History Display"]["func"] = function()
		PM_UI_History_CreateFrame_HistoryDisplay_Update();
	end;
	PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"] = PM_UI_CreateFrame("Frame", PM_UI_LIST["History"]["background"], 
	{
		["x"] = 10,
		["y"] = -50,
		["anchor"] = "TOPLEFT",
		--["texture"] = "Interface\\AddOns\\PlayerMeter\\textures\\face.tga",
		["width"] = PM_UI_LIST["History"]["background"]:GetWidth()-20,
		["height"] = (PM_UI_LIST["History"]["background"]:GetHeight()-100),
		["r"] = 0.4,
		["g"] = 0.4,
		["b"] = 0.4,
		["a"] = 0.8,
	});
	PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]:EnableMouse(true);
	PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]:EnableMouseWheel(true);
	PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]:SetScript("OnMouseWheel", function(self, delta)
		if IsShiftKeyDown()
		then
			PM_UI_History_UpdateScroll(arg1*10, false);
		else
			PM_UI_History_UpdateScroll(arg1, false);
		end
	end)
	
	for i = 0, PM_UI_History_AmountOfLines
	do
		PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]["combatText_"..i] = PM_UI_CreateFont(PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"], "Data Loading", {
		["x"] = 0,
		["y"] = i*16 + 10,
		["size"] = 15,
		["anchor"] = "BOTTOMLEFT",
		["font"] = "Fonts\\FRIZQT__.TTF",
	})
	end
end;

PM_UI_History_ScrollOffset = 0
PM_UI_History_AmountOfLines = 32;

function PM_UI_History_UpdateScroll(amount, setAmount)
	if setAmount
	then
		PM_UI_History_ScrollOffset = amount;
	else
		PM_UI_History_ScrollOffset = PM_UI_History_ScrollOffset + amount;
	end;
	
	if PM_UI_History_ScrollOffset < 0 
	then
		PM_UI_History_ScrollOffset = 0;
	end;
	
	
	if PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]:IsShown()
	then
		PM_UI_History_CreateFrame_HistoryDisplay_Update();
	end;
end

local PM_UI_History_Data = nil;

function PM_UI_History_UpdateData(force)
	if PM_UI_History_Data == nil or force
	then
		if PM_UI_LIST["History"]["background"]:IsShown()
		then
			PM_("data update")
			PM_UI_History_ScrollOffset = 0;
			PM_UI_History_Data = PM_GetRawDataArray(PM_UI_DamageMeter_GetSession(), true)
			--table.reverse(PM_UI_History_Data);
			if force
			then
				PM_UI_History_CreateFrame_HistoryDisplay_Update();
			end;
		else
			PM_("Window is not show, so set nil.");
			PM_UI_History_Data = nil;
		end;
	end;
end;

function PM_UI_History_CreateFrame_HistoryDisplay_Update()
	PM_UI_History_UpdateData();
	for i = 0, PM_UI_History_AmountOfLines
	do
		-- Clear all the rows.
		PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]["combatText_"..i]:SetText("")
	end;
	local i = 0;
	local line = 0;
	local IsDone = false;
	if PM_UI_History_Data == nil
	then
		return;
	end;
	for t,block in pairs(PM_UI_History_Data)
	do
		if IsDone
		then
			break;
		end;
		for k,d in pairs(block)
		do
			i = i +1 ;
			if type(d) == "table"
			then
				if i >= PM_UI_History_ScrollOffset
				then
					if line <= PM_UI_History_AmountOfLines --PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]["combatText"]:GetHeight() < PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]:GetHeight() - 60
					then
						-- GetDamageModifierColor(damageModifier)
						-- PM_GetSchoolColor(school)
						-- PM_GetNameColor(name)
						local r,g,b = PM_GetNameColor(d["player"])
						local playerColor = "|cff" .. PM_num2hex(tonumber(PM_round(r*255))) .. PM_num2hex(tonumber(PM_round(g*255))) .. PM_num2hex(tonumber(PM_round(b*255)));
						local r,g,b = PM_GetNameColor(d["targetName"])
						local targetColor = "|cff" .. PM_num2hex(tonumber(PM_round(r*255))) .. PM_num2hex(tonumber(PM_round(g*255))) .. PM_num2hex(tonumber(PM_round(b*255)));
						local c
						if d["ability"] == "white"
						then
							c = PM_GetSchoolColor("white")
						else
							c = PM_GetSchoolColor(d["damageClass"])
						end
						
						local schoolColor = "|cff" .. PM_num2hex(tonumber(PM_round(c[1]*255))) .. PM_num2hex(tonumber(PM_round(c[2]*255))) .. PM_num2hex(tonumber(PM_round(c[3]*255)));
						
						
						local combatLines = 
						"|cffffffff" .. 
						"[" .. date("%H:%M:%S",d["castTime"]) .. "] " ..
						playerColor .. 
						d["player"] .. 
						" " ..
						schoolColor .. 
						d["ability"] ..
						" " ..
						GetDamageModifierColor(d["damageModifier"]) .. 
						d["damageModifier"] ..
						" " .. 
						targetColor .. 
						d["targetName"] ..
						" " ..
						schoolColor .. 
						d["value"] ..
						"\n";
						PM_UI_LIST["History"]["tabs"]["History Display"]["textBlock"]["combatText_"..line]:SetText(combatLines)
						line = line + 1;
					else
						IsDone = true;
						break;
					end;
				end;
			end;
		end;
	end;
end

PM_UI_History_SessionSelect_Offset = 0;
PM_UI_History_TargetFilter_Offset = 0;
PM_UI_History_SessionSelect_buttonCount = 20;

function PM_UI_History_ChangeOffset(var, increase) -- Not sure why I copy this....
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






