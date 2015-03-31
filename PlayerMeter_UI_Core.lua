PM_UI_LIST = {} -- This list holds all the UI elements

function PM_UI_GetFrameSettings(settings)
	local cfg = {}
	cfg["x"] = 0;
	cfg["y"] = 0;
	cfg["width"] = 1;
	cfg["height"] = 1;
	cfg["anchor"] = "topleft";
	cfg["texture"] = "Interface\\Tooltips\\UI-Tooltip-Background";--"Interface\\AddOns\\PlayerMeter\\textures\\test.tga";--"Interface\\TimeTracker\\textures\\test.png";
	cfg["textureLevel"] = "background";
	cfg["r"] = 1;
	cfg["g"] = 1;
	cfg["b"] = 1;
	cfg["a"] = 1;
	
	
	-- Overwrite all cfg commands sent in by the settings array.
	for k,v in pairs(cfg)
	do
		if settings[k] ~= nil
		then
			cfg[k] = settings[k];
		end;
	end;
	return cfg;
end;

function PM_UI_GetDropdownSettings(settings)
	local cfg = {}
	cfg["x"] = 0;
	cfg["y"] = 0;
	cfg["width"] = 1;
	cfg["height"] = 1;
	cfg["anchor"] = "topleft";
	cfg["texture"] = "Interface\\AddOns\\PlayerMeter\\textures\\test.tga";--"Interface\\TimeTracker\\textures\\test.png";
	cfg["textureLevel"] = "background";
	cfg["r"] = 1;
	cfg["g"] = 1;
	cfg["b"] = 1;
	cfg["a"] = 1;
	
	
	-- Overwrite all cfg commands sent in by the settings array.
	for k,v in pairs(cfg)
	do
		if settings[k] ~= nil
		then
			cfg[k] = settings[k];
		end;
	end;
	return cfg;
end

function PM_UI_GetButtonSettings(settings)
	local cfg = {}
	cfg["x"] = 0;
	cfg["y"] = 0;
	cfg["width"] = 1;
	cfg["height"] = 1;
	cfg["anchor"] = "topleft";
	cfg["texture"] = "Interface\\AddOns\\PlayerMeter\\textures\\test.tga";--"Interface\\TimeTracker\\textures\\test.png";
	cfg["textureLevel"] = "background";
	cfg["font"] = "Fonts\\FRIZQT__.TTF";
	cfg["size"] = 15;
	cfg["text"] = "";
	cfg["style"] = "OUTLINE";
	cfg["r"] = 1;
	cfg["g"] = 1;
	cfg["b"] = 1;
	cfg["a"] = 1;
	cfg["fr"] = 0.9;
	cfg["fg"] = 0.9;
	cfg["fb"] = 0.9;
	
	
	-- Overwrite all cfg commands sent in by the settings array.
	if settings ~= nil
	then
		for k,v in pairs(cfg)
		do
			if settings[k] ~= nil
			then
				cfg[k] = settings[k];
			end;
		end;
	end;
	return cfg;
end;

function PM_UI_GetFontSettings(settings)
	local cfg = {
		["x"] = 0,
		["y"] = 0,
		["width"] = 0,
		["height"] = 0,
		["size"] = 10,
		["anchor"] = "topleft",
		["font"] = "Fonts\\FRIZQT__.TTF",
		["parent"] = ""
	}
	
	--PM_(settings);
	-- Overwrite all cfg commands sent in by the settings array.
	for k,v in pairs(cfg)
	do
		if settings[k] ~= nil
		then
			--PM_(k);
			cfg[k] = settings[k];
		end;
	end;
	
	--PM_(cfg);
	
	return cfg;
end;


function PM_UI_CreateFrame(frameType, parent, settings)
	if parent == nil
	then
		-- If nill, set it to default parrent.
		parent = UIParent;
	end;
	local cfg = PM_UI_GetFrameSettings(settings);
	
	--PM_(cfg);
	
	local f = CreateFrame(frameType, nil,parent);
	f.texture = f:CreateTexture(nil,cfg["textureLevel"]);
	f.texture:SetTexture(cfg["texture"]);
	f:SetWidth(cfg["width"])
	f:SetHeight(cfg["height"])
	f:SetPoint(cfg["anchor"],cfg["x"],cfg["y"])
	f.texture:SetVertexColor(cfg["r"],cfg["g"],cfg["b"],cfg["a"])
	f:SetFrameStrata(cfg["textureLevel"])
	f.texture:SetAllPoints(f)
	
	return f;
end;

function PM_UI_CreateButton(parent, settings)
	if parent == nil
	then
		-- If nill, set it to default parrent.
		parent = UIParent;
	end;
	local cfg = PM_UI_GetButtonSettings(settings);
	
	local button = CreateFrame("Button", nil, parent);
	button.texture = button:CreateTexture(nil,cfg["textureLevel"]);
	button.texture:SetTexture(cfg["texture"]);
	button:SetWidth(cfg["width"])
	button:SetHeight(cfg["height"])
	button:SetPoint(cfg["anchor"],cfg["x"],cfg["y"])
	button:SetFont(cfg["font"], cfg["size"], cfg["style"], "");
	button:SetText(cfg["text"]);
	button:SetTextColor(cfg["fr"],cfg["fg"],cfg["fb"])
	button.texture:SetVertexColor(cfg["r"],cfg["g"],cfg["b"],cfg["a"])
	button:SetFrameStrata(cfg["textureLevel"])
	button.texture:SetAllPoints(button)
	
	return button;
end;


function PM_UI_CreateFont(frame, text, settings)
	if frame == nil or text == nil
	then
		return false;
	end;
	local cfg = PM_UI_GetFontSettings(settings);
	
	local font = frame:CreateFontString();
	font:SetFont(cfg["font"], cfg["size"], "OUTLINE", "");
	if cfg["parent"] ~= ""
	then
		--PM_("We have another frame to anchor to.")
		font:SetPoint(cfg["anchor"], cfg["parent"],cfg["x"],cfg["y"])
	else
		--PM_("nope")
		font:SetPoint(cfg["anchor"], cfg["x"],cfg["y"])
	end;
	
	if cfg["width"] ~= 0
	then
		font:SetWidth(cfg["width"]);
	end;
	
	if cfg["height"] ~= 0
	then
		font:SetHeight(cfg["height"]);
	end;
	
	font:SetText(text);
	return font;
end;

function PM_UI_CreateDropDown(parent, settings)
	if parent == nil
	then
		-- If nill, set it to default parrent.
		parent = UIParent;
	end;
	local cfg = PM_UI_GetDropdownSettings(settings);
	
	--PM_(cfg);
	
	local f = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate");
	f.texture = f:CreateTexture(nil,cfg["textureLevel"]);
	f.texture:SetTexture(cfg["texture"]);
	f:SetWidth(cfg["width"])
	f:SetHeight(cfg["height"])
	f:SetPoint(cfg["anchor"],cfg["x"],cfg["y"])
	f.texture:SetVertexColor(cfg["r"],cfg["g"],cfg["b"],cfg["a"])
	f:SetFrameStrata(cfg["textureLevel"])
	f.texture:SetAllPoints(f)
	
	return f;
end;



function PM_UI_MoveFrameStart(arg1, frame, FrameName)
	PM_(FrameName);
	if not frame.isMoving
	then
		if arg1 == "LeftButton" and frame:IsMovable()
		then
			frame:StartMoving();
			frame.isMoving = true;
		end
		if arg1 == "RightButton" and frame:IsResizable()
		then
			frame:StartSizing("BOTTOMRIGHT")
			frame.isMoving = true;
		end
	end;
end;

function PM_UI_MoveFrameStop(arg1, frame, FrameName, settings)
	if frame.isMoving
	then
		PM_(FrameName);
		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
		settings["x"] = xOfs;
		settings["y"] = yOfs;
		settings["width"] = frame:GetWidth();
		settings["height"] = frame:GetHeight();
		--PM_(frame:GetRight() - frame:GetLeft())
		--PM_(frame:GetTop() - frame:GetBottom())
		PM_Settings["Settings"]["frames"][FrameName]["dirty"] = true;
		settings["anchor"] = point;
		
		frame:StopMovingOrSizing();
		frame.isMoving = false;
	end
end;

function PM_UI_MoveFrameHide(arg1, frame, FrameName)
	if ( frame.isMoving ) then
		frame:StopMovingOrSizing();
		frame.isMoving = false;
	end
end;
