PM_VersionNumber = 20131229;
PM_LastValidVersionNumber = 20131222;

SlashCmdList["PLAYERMETER"] = function(arg)
	PM_PlayerMeter(arg);
end;
SLASH_PLAYERMETER1 = "/playermeter"

-- /script PM_(PM_TimeCalc("bacon"));


PM_UI_bracketColor 	= "|cffffa800"
PM_UI_hitColor 		= "|cffffffff";
PM_UI_glancColor 		= "|cff6bc6ff";
PM_UI_critColor 		= "|cffffff00";
PM_UI_missColor 		= "|cffff7c7c";
PM_UI_dpbColor 		= "|cff7cff92";
PM_LastSessionName = "";

function GetDamageModifierColor(damageModifier)
	if damageModifier == "hit"
	then
		return PM_UI_hitColor;
	end;
	
	if damageModifier == "crit"
	then
		return PM_UI_critColor;
	end;
	
	if damageModifier == "glancing"
	then
		return PM_UI_glancColor;
	end;
	
	if damageModifier == "miss" or string.find(damageModifier, "resist")
	then
		return PM_UI_missColor;
	end;
	
	if string.find(damageModifier, "dodge") or string.find(damageModifier, "block") or string.find(damageModifier, "parr")
	then
		return PM_UI_dpbColor;
	end;
	
	return PM_UI_hitColor;
end;


function PM_GetSchoolColor(str)
	if str == nil
	then
		str = "white";
	end;
	str = string.lower(str);
	
	if k == "white" or k == "white pet"
	then
		return {1,1,1}
	elseif str == "physical"
	then
		return {1.00, 0.96, 0.41}
	elseif str == "holy"
	then
		return {255/255, 163/255, 255/255}
	elseif str == "frost"
	then
		return {0, 138/255, 1}
	elseif str == "fire"
	then
		return {1, 0, 0}
	elseif str == "shadow"
	then
		return {114/255, 0/255, 255/255}
	elseif str == "arcane"
	then
		return {141/255, 238/255, 255/255}
	elseif str == "nature"
	then
		return {0/255, 255/255, 78/255}
	elseif str == "healing"
	then
		return {0/255, 255/255, 0/255}
	else
		return {1,1,1};
	end
end;

local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function PM_TimeCalc(to_encode)
    local bit_pattern = ''
    local encoded = ''
    local trailing = ''

    for i = 1, string.len(to_encode) do
        bit_pattern = bit_pattern .. to_binary(string.byte(string.sub(to_encode, i, i)))
    end

    -- Check the number of bytes. If it's not evenly divisible by three,
    -- zero-pad the ending & append on the correct number of ``=``s.
    if math.mod(string.len(bit_pattern), 3) == 2 then
        trailing = '=='
        bit_pattern = bit_pattern .. '0000000000000000'
    elseif math.mod(string.len(bit_pattern), 3) == 1 then
        trailing = '='
        bit_pattern = bit_pattern .. '00000000'
    end

    for i = 1, string.len(bit_pattern), 6 do
        local byte = string.sub(bit_pattern, i, i+5)
        local offset = tonumber(from_binary(byte))
        encoded = encoded .. string.sub(index_table, offset+1, offset+1)
    end

    return string.sub(encoded, 1, -1 - string.len(trailing)) .. trailing
end

function to_binary(integer)
    local remaining = tonumber(integer)
    local bin_bits = ''

    for i = 7, 0, -1 do
        local current_power = math.pow(2, i)

        if remaining >= current_power then
            bin_bits = bin_bits .. '1'
            remaining = remaining - current_power
        else
            bin_bits = bin_bits .. '0'
        end
    end

    return bin_bits
end

function from_binary(bin_bits)
    return tonumber(bin_bits, 2)
end


function PM_PlayerMeter(arg)
	if arg == "toggle"
	then
		if PM_UI_LIST["DamageMeter"]["background"]:IsShown()
		then
			PM_UI_LIST["DamageMeter"]["background"]:Hide()
		else
			PM_UI_LIST["DamageMeter"]["background"]:Show()
		end;
	end;
	
	if arg == "show"
	then
		PM_UI_LIST["DamageMeter"]["background"]:Show()
	end;
	
	if arg == "hide"
	then
		PM_UI_LIST["DamageMeter"]["background"]:Hide()
	end;
	
	if arg == "" or arg == "help"
	then
		ChatFrame1:AddMessage('/playermeter toggle');
		ChatFrame1:AddMessage('/playermeter show');
		ChatFrame1:AddMessage('/playermeter hide');
		ChatFrame1:AddMessage('/playermeter help');
	end;
end;

function IsValidPoint(str)
	local p = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT", "CENTER"}
	for _, point in p
	do
		if string.lower(str) == string.lower(point)
		then
			return true;
		end;
	end;
	return false;
end;

PM_DamageClasses = {"frost","shadow","nature","physical","holy","fire","arcane","healing"};

PM_PlayersWithAddon = {}

function PM_ValidAddonNumber(nr)
	nr = tonumber(nr);
	if nr == nil or nr < PM_LastValidVersionNumber
	then
		return false;
	else
		return true;
	end;
end;

function PM_SendAddonAnnounce()
	SendAddonMessage("PlayerMeter", "VERSION;"..PM_VersionNumber, "RAID")
end;

function PM_RequestAddonVersion()
	if UnitInRaid("player") or UnitInParty("Player")
	then
		SendAddonMessage("PlayerMeter", "REQUESTVERSION;"..PM_VersionNumber, "RAID")
	end;
end;

function PM_IsValidDamgeClass(str)
	for _,class in PM_DamageClasses
	do
		if(string.lower(str) == class)
		then
			return true;
		end;
	end;
	return false;
end;

PM_ClassColors = {
	["druid"] = 	{1.00, 	0.49, 	0.04},
	["hunter"] = 	{0.67, 	0.83, 	0.45},
	["mage"] = 		{0.41, 	0.80, 	0.94},
	["paladin"] = 	{0.96, 	0.55, 	0.73},
	["priest"] = 	{1.00, 	1.00, 	1.00},
	["rogue"] = 	{1.00, 	0.96, 	0.41},
	["shaman"] = 	{ 0.0, 	0.44, 	0.87},
	["warlock"] = 	{0.58, 	0.51, 	0.79},
	["warrior"] = 	{0.78, 	0.61, 	0.43}
}
PM_LastServerMinute = -1;
PM_LastServerMinuteChange = 0;


function PM_GetNameColor(name)
	name = string.lower(name);
	if PM_Settings["NameToClass"][name] == nil
	then
		return 0.4, 0.4, 0.4
	else
		local c = PM_ClassColors[PM_Settings["NameToClass"][name]];
		return c[1], c[2], c[3];
	end
end;

function PM_ScanForPlayerColors()
	if PM_Settings["NameToClass"] == nil -- If this is nill, then our config is broken.
	then
		PM_ResetSettings();
	end;
	local scanNum = MAX_PARTY_MEMBERS;
	local scanName = "Party"
	
	if UnitInRaid("Player")
	then
		scanNum = GetNumRaidMembers();
		scanName = "Raid";
	end;
	
	for groupindex = 1,scanNum
	do
		local _, unitClassName = UnitClass(scanName..groupindex);
		local name = UnitName(scanName..groupindex);
		if name ~= nil and unitClassName ~= nil
		then
			local name = string.lower(name);
			PM_Settings["NameToClass"][name] = string.lower(unitClassName);
		end;
	end;
	local _, myClassName = UnitClass("Player");
	PM_Settings["NameToClass"][string.lower(UnitName("Player"))] = string.lower(myClassName);
end;


function PM_IsPlayerInGroup(playerName)
	if playerName == UnitName("Player")
	then
		return true;
	end;
	local scanNum = MAX_PARTY_MEMBERS;
	local scanName = "Party"
	
	if UnitInRaid("Player")
	then
		scanNum = GetNumRaidMembers();
		scanName = "Raid";
	end;
	
	for groupindex = 1,scanNum
	do
		-- Check the player
		local _, unitClassName = UnitClass(scanName..groupindex);
		local name = UnitName(scanName..groupindex);
		if name == playerName
		then
			return true;
		end;
		
		-- Check his pet
		local namePet = UnitName(scanName.."pet"..groupindex);
		if namePet == playerName
		then
			return true, name; -- return the owners name so we can use that.
		end;
	end;
	return false;
end;


PM_InCombat = false;
PM_SendAddonMessage = 0;
PM_LastMessageSent = 0;
PM_LastDamageTime = 999999999;

PM_AddonLoaded = false;


function PM_OnUpdateEvent()
	
	if PM_AddonLoaded == false
	then
		return;
	end;
	
	if PM_LastDamageTime + 0.1 <= GetTime()
	then
		-- 10 second since last damage was recorded
		if not PM_InCombat and not UnitAffectingCombat("player")
		then
			-- We are not in combat and it was 10 seconds since we got any data.
			PM_EndCurrent()
		end;
	end;
	
	
	
	if PM_LastMessageSent + 1 < GetTime()
	then
		PM_LastMessageSent = GetTime();
		for k,v in pairs (PM_MessageBuffer)
		do
			SendChatMessage(v["msg"], v["channel"], nil, nil);
			--PM_(v["msg"]);
			table.remove(PM_MessageBuffer, k)
			break;
		end;
	end;
	
	-- Works as both antispam and making sure new players get your announcement :)
	if PM_SendAddonMessage ~= 0 and PM_SendAddonMessage <= GetTime()
	then
		PM_SendAddonAnnounce()
		PM_SendAddonMessage = 0;
	end;
	
	
	
	if PM_AllOutOfCombat() and PM_InCombat
	then
		-- Move all data in to a new block.
		--PM_Settings["Data"]["current"]["info"]["combatEnd"] = PM_GetServerTime()
		--PM_Settings["Data"][PM_Settings["Data"]["current"]["info"]["combatStart"] .. "_" .. PM_Settings["Data"]["current"]["info"]["combatEnd"]] = PM_Settings["Data"]["current"];
		--PM_EndCurrent();
		PM_InCombat = false;
	end;
	
	
	for k,v in pairs(PM_UI_LIST)
	do
		-- Load all the OnLoad functions saved on our interface.
		local func = PM_UI_LIST[k]["OnUpdate"];
		if func ~= nil
		then
			func();
		end;
	end
end;

-- taken from ClockFu thanks <3
function PM_GetLocalOffset()
	local localHour = tonumber(date("%H"))
	local localMinute = tonumber(date("%M"))
	local utcHour = tonumber(date("!%H"))
	local utcMinute = tonumber(date("!%M"))
	local loc = localHour + localMinute / 60
	local utc = utcHour + utcMinute / 60
	local localOffset = floor((loc - utc) * 2 + 0.5) / 2
	if localOffset >= 12
	then
		localOffset = localOffset - 24
	end
	return localOffset
end
 
-- taken from ClockFu thanks <3
function GetServerOffset()
	local serverHour, serverMinute = GetGameTime()
	local utcHour = tonumber(date("!%H"))
	local utcMinute = tonumber(date("!%M"))
	local ser = serverHour + serverMinute / 60
	local utc = utcHour + utcMinute / 60
	local serverOffset = floor((ser - utc) * 2 + 0.5) / 2
	if serverOffset >= 12
	then
		serverOffset = serverOffset - 24
	elseif serverOffset < -12
	then
		serverOffset = serverOffset + 24
	end
	return serverOffset
end

function PM_GetServerTime()
	local h,m = GetGameTime();
	local s = PM_round(GetTime() - PM_LastServerMinuteChange, 2);
	
	local localTime = time(date("*t"));
	localTime = localTime + GetServerOffset()*60*60
	local serverTimeArray = date("*t", localTime);
	
	
	return time(serverTimeArray)
	
	
	--return serverTimeArray["year"], serverTimeArray["month"], serverTimeArray["wday"], serverTimeArray["hour"], serverTimeArray["min"], serverTimeArray["sec"]
	--return h, m, s;
end;

function PM_ResetSettings()
	PM_("Going back to default settings.")
	PM_Settings = {};
	PM_Settings["Settings"] = {};
	PM_Settings["Settings"]["frames"] = {};
	PM_Settings["Data"] = {};
	PM_Settings["Data"]["all"] = {};
	PM_Settings["NameToClass"] = {};
	PM_UI_DefaultSettings();
	PM_UI_Settings_DefaultSettings();
end

function PM_tempprint()
	for k,v in PM_Settings["Data"]
	do
		PM_(k);
	end;
end

function PM_EndCurrent()
	if PM_Settings["Data"]["current"] == nil or PM_Settings["Data"]["current"]["info"] == nil or PM_tablelength(PM_Settings["Data"]["current"]) == 0
	then
		return;
	end;
	PM_Settings["Data"]["current"]["info"]["combatEnd"] = PM_GetServerTime();
	local sName = PM_GetSessionMainTarget("current");
	if sName ~= ""
	then
		local saveSessionName = date("%H%M%S",PM_GetServerTime()) .. " " .. sName;
		if PM_Settings["Data"][saveSessionName] ~= nil
		then
			saveSessionName = saveSessionName .. "_" .. math.random(999999);
		end;
		PM_Settings["Data"][saveSessionName] = PM_Settings["Data"]["current"];
		PM_Settings["Data"]["current"] = {};
		PM_LastSessionName = saveSessionName;
		if PM_Settings["Settings"]["frames"]["DamageMeter"] ~= nil
		then
			PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
		end;
	end;
end;

function PM_eventHandler()
	
		
	if event == "ADDON_LOADED" -- Handle on load stuff.
	then
		if arg1 == "PlayerMeter"
		then
			PM_AddonLoaded = true;
			PM_RequestAddonVersion();
			--SetCVar("CombatLogRangeParty", 150)
			--SetCVar("CombatLogRangePartyPet", 150)
			--SetCVar("CombatLogRangeFriendlyPlayers", 150)
			--SetCVar("CombatLogRangeFriendlyPlayersPets", 150)
			--SetCVar("CombatLogRangeHostilePlayers", 150)
			--SetCVar("CombatLogRangeHostilePlayersPets", 150)
			
			if PM_Settings == nil
			then
				PM_ResetSettings();
			end;
			PM_ScanForPlayerColors();
			for k,v in pairs(PM_UI_LIST)
			do
				-- Load all the OnLoad functions saved on our interface.
				local func = PM_UI_LIST[k]["OnLoad"];
				if func ~= nil
				then
					func();
				end;
			end
		end;
		return;
	end
	
	
	for k,v in pairs(PM_UI_LIST)
	do
		-- Load all the OnLoad functions saved on our interface.
		local func = PM_UI_LIST[k]["OnEvent"];
		if func ~= nil
		then
			func(event, arg1, arg2, arg3, arg4, arg5);
		end;
	end
	--PM_(event);
	if arg1 ~= nil
	then
		--PM_(event .. " -> " .. arg1);
	end;
	

	if event == "PLAYER_REGEN_DISABLED" -- Combat start
	then
		PM_("In combat");
		PM_InCombat = true;
		local serverTime = PM_GetServerTime()
		return;
	end
	
	if event == "PLAYER_REGEN_ENABLED" -- Combat end
	then
		PM_("Out of combat");
		--local m = PM_ArrMemory(PM_Settings);
		--PM_("This array uses: " .. PM_round(m/1024/1024, 2) .. "MB ram (".. m .."B)");		
		return;
	end

	if event == "CHAT_MSG_ADDON" -- Addon message, sorting them and passing them on to the correct function.
	then
		if arg1 == "PlayerMeter_Sync"
		then
			--PM_(arg2);
			local d = PM_strsplit(";", arg2);
			local castTime = d[1];
			local ability = d[2]
			local value = d[3]
			local targetName = d[4]
			local damageModifier = d[5]
			local damageClass = d[6]
			local extra = d[7];
			local player = d[8];
		
			if PM_PlayersWithAddon[arg4] == nil
			then
				--PM_PlayersWithAddon[arg4] = 0; Don't want to add people like that, we don't know if thye have a corrupted version.
			end;
			
			
			if true --ability ~= "white"
			then
				--PM_("[".. castTime .."]" .. player .. " " .. damageModifier .. " " .. targetName .. " for " .. value .. " (".. ability ..", ".. damageClass ..") " .. extraText);
			end;
			
			if damageClass == "healing" and arg4 ~= player
			then
				return; -- We only want to save healing data from the caster, preventing double data.
			end;
			
			--PM_SaveData(castTime, player, ability, value, targetName, damageModifier, damageClass, extra, false)
			
			
			
			
		elseif arg1 == "PlayerMeter"
		then
			local d = PM_strsplit(";", arg2)
			-- This is commands sent to everyone, like reset.
			if d[1] == "reset"
			then
				PM_ResetSession();
			elseif string.lower(d[1]) == "version"
			then
				PM_("Got player with addon: ".. arg4 .. " version: " .. d[2]);
				--PM_PlayersWithAddon[arg4] = tonumber(d[2]);
			elseif string.lower(d[1]) == "requestversion"
			then
				PM_("Got player version request with addon: ".. arg4 .. " version: " .. d[2]);
				--PM_PlayersWithAddon[arg4] = tonumber(d[2]);
				PM_SendAddonAnnounce();
			end;
			
		end;
		return;
	end;
	
	if event == "PARTY_MEMBERS_CHANGED"
	then
		PM_SendAddonMessage = GetTime() + 2;
		PM_ScanForPlayerColors();
		return;
	end;
	
	-- Hits / Crits -- Checked: All
	if event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or evetn == "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS" or event == "CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS" or event == "CHAT_MSG_COMBAT_SELF_HITS" or event == "CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS" or event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS" or event == "CHAT_MSG_COMBAT_PARTY_HITS"
	then
		if string.find(arg1, "suffer") or string.find(arg1, "falls and")
		then
			--PM_("suffer: " .. arg1);
			return;
		end;
		
		--PM_(arg1);
		
		-- PLAYER hit|hits|crit|crits TARGET for DAMAGE.
		
		

		
		local targetName;
		local data = PM_strsplit(" ",arg1)
		local value = tonumber(PM_GetStr(arg1, "(%d+)"));
		local damageModifier = "hit"
		
		local player;
		
		if string.find(arg1, "crit")
		then
			damageModifier = "crit";
			targetName = PM_GetStr(arg1, ".* cri.- (.*) for");
			player = PM_GetStr(arg1, "(.-) crit");
		else
			targetName = PM_GetStr(arg1, ".* hi.- (.*) for");
			player = PM_GetStr(arg1, "(.-) hit");
		end;
		
		local dirty = true;
		
		local playerS = player; -- Store the full string for later searches in here.
		player, playerS, dirty = PM_FixPlayerName(player);		
		
		if string.find(arg1, "glancing")
		then
			damageModifier = "glancing";
		end;
		
				

		
		
		PM_SendData("white", value, targetName, damageModifier, "Physical", nil, dirty, player)
		--PM_(arg1);
		return;
	end;
	
	-- Reflective damage -- Checked: NONE
	if event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS" or event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF"
	then
		--PM_("----------------------")
		
		
		local dirty = true;
		local ability = "reflect";
		local value = tonumber(PM_GetStr(arg1, "(%d+)"))
		if value == nil or not PM_GetStr(arg1, "(reflect)")
		then
			return;
		end;
		
		
		local player = PM_GetStr(arg1, "(.-) reflect");
		local playerS = player; -- Store the full string for later searches in here.
		player, playerS, dirty = PM_FixPlayerName(player);
		
		local targetName = PM_GetStr(arg1, ".*to (.-)%.");
		if targetName == "you"
		then
			targetName = UnitName("Player");
		end;
		
		local damageClass = PM_GetStr(arg1, value.." (.-) damage");
		
		-- We add the damage type name to the ability name since there can be more then 1 reflective.
		-- Helps keepingthe data seperated.
		PM_SendData(ability .. " " .. damageClass, value, targetName, "hit", damageClass, nil, dirty, player)
		return;
	end;
	
	-- Miss, dodge, parry, block (full)  -- Checked All but immune
	if event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" or event == "CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES" or event == "CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES" or event == "CHAT_MSG_COMBAT_SELF_MISSES" or event == "CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES" or event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES" or event == "CHAT_MSG_COMBAT_PARTY_MISSES"
	then
		if string.find(arg1, "afflicated")
		then
			return;
		end;
		
		local player;
		
		PM_("---------".. event .."---------"); PM_(arg1);
		local targetName;
		local damageModifier = "";
		--TT_printDebug(arg1);
		if string.find(arg1, "dodge") -- PLAYER attacks. TARGET dodges.
		then
			targetName = PM_GetStr(arg1, "%. (.*) dod"); -- PLAYER attacks. TARGET dodge.
			player = PM_GetStr(arg1, "(.*) attac");
			damageModifier = "dodge";
		elseif string.find(arg1, "block")
		then
			targetName = PM_GetStr(arg1, "%. (.*) bloc"); -- PLAYER attacks. TARGET block.
			player = PM_GetStr(arg1, "(.*) attac");
			damageModifier = "block";
		elseif string.find(arg1, "parries") or string.find(arg1, "parry")
		then
			targetName = PM_GetStr(arg1, "%. (.*) parr"); -- PLAYER attacks. TARGET parry.
			player = PM_GetStr(arg1, "(.*) attac");
			damageModifier = "parry";
		elseif string.find(arg1, "miss") -- PLAYER misses TARGET.
		then
			targetName = PM_GetStr(arg1, "mis.- (.*)%."); 
			player = PM_GetStr(arg1, "(.*) miss");
			damageModifier = "miss";
		elseif string.find(arg1, "immune")
		then
			PM_(arg1);
			targetName = PM_GetStr(arg1, "%. (.*) immun");
			damageModifier = "immune";
		else
			damageModifier = "unknown";
		end;
		
		local data = PM_strsplit(" ",arg1)
		
		
				
				
		local dirty = true;
		player, playerS, dirty = PM_FixPlayerName(player);
		
		PM_SendData("white", 0, targetName, damageModifier, "Physical", nil, dirty, player)
		return;
	end;
	
	-- Heals -- Checked: Raid, not monsters.
	if event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF" or event == "CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF" or event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF" or event == "CHAT_MSG_SPELL_SELF_BUFF" or event == "CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF" or event == "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF" or event == "CHAT_MSG_SPELL_PARTY_BUFF"
	then
		if not string.find(arg1, "heal")
		then
			return;
		end;
		
		local d = PM_strsplit(" ", arg1);
		
		--Your ABILITY heals TARGET for AMOUNT.
		--Your ABILITY criticaly heals TARGET for AMOUNT.
		
		local dirty = true;
		local player = PM_GetStr(arg1, "(.-) ");
		local playerS = player; -- Store the full string for later searches in here.
		player, playerS, dirty = PM_FixPlayerName(player);
		
		
		local ability;
		local damageModifier = "hit"
		if string.find(arg1, "crit")
		then
			damageModifier = "crit";
			ability = PM_GetStr(arg1, playerS.." (.-) crit");
		else
			ability = PM_GetStr(arg1, playerS.." (.-) heals");
		end;
		
		local targetName = PM_GetStr(arg1, "heals (.-) for");
		if targetName == "you"
		then
			targetName = UnitName("Player");
		end;
		
		local value = tonumber(PM_GetStr(arg1, "for (.-)%.")) -- Heals are negative damage.
		

		--PM_(arg1)
		PM_SendData(ability, value, targetName, damageModifier, "healing", nil, dirty, player)
		return;
	end;

	-- Direct damage spells: Raid, not monsters.
	if event == "CHAT_MSG_SPELL_SELF_DAMAGE" or event == "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_PARTY_DAMAGE" or event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE" or event == "CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE" or event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE"
	then
		PM_(arg1);
		local d = PM_strsplit(" ", arg1);
		
		-- Your ABILITY hits TARGET for DAMAGE.
		-- PLAYER 's ABILITY hits TARGET for %d+ DAMAGE
		-- PLAYER's ABILITY
		
		local dirty = true;
		
		local ability;
		local player = PM_GetStr(arg1, "(.-) ");
		PM_(player)
		local playerS = player; -- Store the full string for later searches in here.
		if string.lower(player) == "you" or string.lower(player) == "your"
		then
			playerS = player;
			player = UnitName("Player");
		else
			player = PM_GetStr(arg1, "(.*) '");
			if player == nil
			then
				return;
			end;
			playerS = player .. " 's"
		end;
		if player == nil
		then
			PM_("Error, Direct Damage, player nil: " .. arg1)
			return; --
		end;
		
		
		local targetName;
		local damageClass = nil;
		
		
		local value = 0;
		
		local damageModifier = "";
		--TT_printDebug(arg1);
		if string.find(arg1, "dodge")
		then
			damageModifier = "dodge";
			ability = PM_GetStr(arg1, playerS.." (.*) was dodged");
			targetName = PM_GetStr(arg1, "by (.-)%.");
		elseif string.find(arg1, "was blocked")
		then
			damageModifier = "block";
			ability = PM_GetStr(arg1, playerS.." (.*) was blocked");
			targetName = PM_GetStr(arg1, "by (.-)%.");
		elseif string.find(arg1, "parrie")
		then
			damageModifier = "parry";
			ability = PM_GetStr(arg1, playerS.." (.*) was parried");
			targetName = PM_GetStr(arg1, "by (.-)%.");
		elseif string.find(arg1, "miss")
		then
			damageModifier = "miss";
			ability = PM_GetStr(arg1, playerS.." (.*) missed");
			targetName = PM_GetStr(arg1, "missed (.-)%.");
		elseif string.find(arg1, "immune")
		then
			damageModifier = "immune";
			ability = PM_GetStr(arg1, playerS.." (.*) failed");
			targetName = PM_GetStr(arg1, "%. (.-) is");
		elseif string.find(arg1, "was resisted")
		then
			damageModifier = "resist";
			ability = PM_GetStr(arg1, playerS.." (.*) was");
			targetName = PM_GetStr(arg1, "by (.-)%.");
			if targetName == nil
			then
				targetName = UnitName("Player");
			end;
		elseif string.find(arg1, "crit")
		then
			damageModifier = "crit";
			if string.find(arg1, " damage.")
			then
				value = PM_GetStr(arg1, "for (.-) ");
			else
				value = PM_GetStr(arg1, "for (.-)%.");
			end;
			ability = PM_GetStr(arg1, playerS.." (.-) crit");
			targetName = PM_GetStr(arg1, "crits (.-) for");
		elseif string.find(arg1, "hit")
		then
			damageModifier = "hit";
			if string.find(arg1, " damage.")
			then
				value = PM_GetStr(arg1, "for (.-) ");
			else
				value = PM_GetStr(arg1, "for (.-)%.");
			end;
			ability = PM_GetStr(arg1, playerS.." (.-) hits");
			targetName = PM_GetStr(arg1, "hits (.-) for");
		else
			damageModifier = "unknown";
			return; -- We don't know what this is.
		end;
		
		--PM_(value);
		value = tonumber(value);
		--PM_(value);
		
		if value == nil
		then
			return false;
		end;
		
		if string.find(arg1, " damage.") and value > 0
		then
			damageClass = PM_GetStr(arg1, value.." (.-) damage%.");
		end;
		
		PM_SendData(ability, value, targetName, damageModifier, damageClass, nill, dirty, player)
		return;
	end;
	
	-- dots -- checked: Raid, not monsters.
	if event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"
	then
		--Faldric suffers 135 Physical damage from Core Hound 's Serrated Bite.
		
		local dirty = true;
		local ability;
		local value = tonumber(PM_GetStr(arg1, "(%d+)"))
		if value == nil or not PM_GetStr(arg1, "(suffer)")
		then
			return;
		end;
		
		
		local player = PM_GetStr(arg1, "from (.-) ");
		local playerS = player; -- Store the full string for later searches in here.
		if string.lower(player) == "you" or string.lower(player) == "your"
		then
			playerS = player;
			player = UnitName("Player");
		else
			player = PM_GetStr(arg1, "from (.*) '");
			if player == nil
			then
				return;
			end;
			playerS = player .. " 's"
		end;
		if player == nil
		then
			PM_("Error, Direct Damage, player nil: " .. arg1)
			return; --
		end;
		
		--PM_(playerS);
		
		ability = PM_GetStr(arg1, playerS.." (.-)%.");
		
		--PM_(ability);
		
		local targetName = PM_GetStr(arg1, "(.-) suffers");
		if targetName == "you"
		then
			targetName = UnitName("Player");
		end;
		
		
		local damageClass = PM_GetStr(arg1, value.." (.-) damage");
		
		if ability == nil
		then
			PM_("ERROR: " .. arg1)
			return
		end;
		
		PM_(arg1);
		
		PM_SendData(ability .. " dot", value, targetName, "hit", damageClass, nil, dirty, player)
		return;
	end;
	
	-- Hots: checked: Raid, not monsters.
	if event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" or event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS" or event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS" or event == "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS"
	then
		if not string.find(arg1, "heal") -- only check for our stuff right now.
		then
			return;
		end;
		
		PM_(arg1);
		
		
		local value = tonumber(PM_GetStr(arg1, "gains (.-) "))
		
		if value == nil
		then
			-- It's nil if we could not find a value, this also happens when a buff is casted.
			return;
		end;
		
		local dirty = false;
		
		-- TARGET gains AMOUNT health from PLAYER ABILITY.
		-- Endboss gains 266 health from Alysana 's Renew.
		
		local player = PM_GetStr(arg1, "from (.-) ");
		local playerS = player; -- Store the full string for later searches in here.
		if string.lower(player) == "you" or string.lower(player) == "your"
		then
			playerS = player;
			player = UnitName("Player");
		else
			player = PM_GetStr(arg1, "from (.*) '");
			if player == nil
			then
				return;
			end;
			playerS = player .. " 's"
		end;
		if player == nil
		then
			PM_("Error, Direct Damage, player nil: " .. arg1)
			return; --
		end;
		
		
		local ability = PM_GetStr(arg1, ".*".. playerS .." (.-)%.");
		local damageModifier = "hit"
		
		local targetName = PM_GetStr(arg1, "(.-) gain");
		if targetName == "you"
		then
			targetName = UnitName("Player");
		end;
		

		
		
		PM_SendData(ability, value, targetName, damageModifier, "healing", nil, dirty, player)
		return;
	end;

	PM_("---------" .. event .. "---------")
	PM_(arg1)
end;

function testtest()
	PM_("test");
end;

-- /script PM_(string.gsub("test.test", "%.", "%%%."))
function PM_FixPlayerName(player)
	if player == nil
	then
		return nil, nil, nil;
	end;
	player = string.gsub(player, "%.", "%%%.")
	local playerS = player;
	local dirty;
	if string.lower(player) ~= "your" and string.lower(player) ~= "you"
	then
		dirty = true;
		playerS = "'s";
		if string.find(player, "'")
		then
			player = PM_GetStr(players, "(.-)'");
		end;
	else
		player = UnitName("Player"); -- It's our 
		dirty = false;
	end;
	return player, playerS, dirty
end;

-- Event stuff

PM_MainFrame = CreateFrame("FRAME", "TTMainFrame");
PM_MainFrame:SetScript("OnUpdate", PM_OnUpdateEvent);
PM_MainFrame:SetScript("OnEvent", PM_eventHandler);
PM_MainFrame:RegisterEvent("ENTER_WORLD");
PM_MainFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
PM_MainFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
PM_MainFrame:RegisterEvent("CHAT_MSG_ADDON");
PM_MainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
PM_MainFrame:RegisterEvent("ADDON_LOADED");


PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_PARTY_HITS");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_PARTY_MISSES");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF");

PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE");

PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE");


PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS");




PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE");


PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF");
PM_MainFrame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF");

PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS");


PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES");
PM_MainFrame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES");





PM_TimeHandler = 0;

function PM_ResetSession(session)
	if session == nil
	then
		session = "current";
	end;
	PM_Settings["Data"][session] = nil;
	if session == "current" or session == "all"
	then
		PM_Settings["Data"][session] = {};
	end;
	PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
end;

function PM_NukeData()
	if session == nil
	then
		session = "current";
	end;
	PM_Settings["Data"] = {};
	PM_Settings["Data"]["all"] = {};
	PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
end;

function PM_SaveData(castTime, player, ability, value, targetName, damageModifier, damageClass, extra, dirty)
	--PM_("------- SaveData -------")
	--PM_(ability)
	--PM_(value)
	--PM_(targetName)
	--PM_(damageModifier)
	--PM_(damageClass)
	--PM_(dirty);
	--PM_(player);
	local InGroup, petOwner = PM_IsPlayerInGroup(player)
	local InGroup2, petOwner2 = PM_IsPlayerInGroup(targetName)
	if 	(not InGroup or (dirty and PM_ValidAddonNumber(PM_PlayersWithAddon[player])))
		and
		(not InGroup2 or (dirty and PM_ValidAddonNumber(PM_PlayersWithAddon[targetName])))
	then
		--PM_("Can't use this data, not in group or player have the addon and should be sending us it.")
		--PM_("player: " .. player)
		--PM_(not InGroup)
		--PM_((dirty and PM_ValidAddonNumber(PM_PlayersWithAddon[player])));
		--PM_("target: ".. targetName)
		--PM_(not InGroup2);
		--PM_(dirty and PM_ValidAddonNumber(PM_PlayersWithAddon[targetName]));
		return false;
	end;
	
	if UnitAffectingCombat("player") == nil
	then
		return false;
	end;
	
	setglobal("PM_" .. GetLastDamageValue(), ReturnValueOfDamage(value));
	if petOwner ~= nil
	then
		player = petOwner;
		ability = ability .. " pet";
	end;
	
	if GetServerTimeCorrection() == CorrectServerTime(castTime)
	then
		ServerTimeCorrection = PerformServerTimeCorrection()
		PM_("We are on the server.")
	end;
	
	if InGroup
	then
		extra = "player"
	end;

	if InGroup2
	then
		if extra == "player"
		then
			extra = "both"; -- PVP damage, lets ignore this for now.
			if damageClass ~= "healing"
			then
				PM_("Save Error: PVP damage, ignored.")
				return false;
			end;
		else
			extra = "target"
		end
	end;
	
	damageModifier = string.lower(damageModifier)
	damageClass = string.lower(damageClass)
	
	local session = "current";
	
	-- Data design
	
	-- /script PM_(PM_Settings["Data"]["current"]["info"])
	
	-- PM_Settings["Data"][session] -- Session array
	
	-- PM_Settings["Data"][session]["info"] -- Here is data about this session stored. This is used for the UI so it doesn't have to loop the raw data during combat.
	-- PM_Settings["Data"][session]["info"]["combatStart"] -- string
	-- PM_Settings["Data"][session]["info"]["combatEnd"] -- string
	-- PM_Settings["Data"][session]["info"]["totalDamage"] -- string
	-- PM_Settings["Data"][session]["info"]["totalHealing"] -- string
	-- PM_Settings["Data"][session]["info"]["playerData"] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player]["totalDamage"] -- number
	-- PM_Settings["Data"][session]["info"]["playerData"][player]["totalHealing"] -- number
	-- PM_Settings["Data"][session]["info"]["playerData"][player]["dirty"] -- bool
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass]["totalValue"] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier] -- list
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["count"] -- number
	-- PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["value"] -- number
	
	value = getglobal("PM_" .. GetLastDamageValue());
	
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
	

	if PM_Settings["Data"][session] == nil then PM_Settings["Data"][session] = {} end;
	
	-- Create all arrays we need.
	if PM_Settings["Data"][session]["info"] == nil then PM_Settings["Data"][session]["info"] = {} end;
	if PM_Settings["Data"][session]["info"]["playerData"] == nil then PM_Settings["Data"][session]["info"]["playerData"] = {} end;
	if PM_Settings["Data"][session]["info"]["playerData"][player] == nil then PM_Settings["Data"][session]["info"]["playerData"][player] = {} end;
	if PM_Settings["Data"][session]["info"]["playerData"][player][damageClass] == nil then PM_Settings["Data"][session]["info"]["playerData"][player][damageClass] = {} end;
	if PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability] == nil then PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability] = {} end;
	if PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier] == nil then PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier] = {} end;
	
	-- set default data
	if PM_Settings["Data"][session]["info"]["combatStart"] == nil then PM_Settings["Data"][session]["info"]["combatStart"] = tonumber(castTime) end;
	if PM_Settings["Data"][session]["info"]["combatEnd"] == nil then PM_Settings["Data"][session]["info"]["combatEnd"] = tonumber(castTime) end;
	if PM_Settings["Data"][session]["info"]["combatStart"] > tonumber(castTime) then PM_Settings["Data"][session]["info"]["combatStart"] = tonumber(castTime) end;
	if PM_Settings["Data"][session]["info"]["combatEnd"] < tonumber(castTime) then PM_Settings["Data"][session]["info"]["combatEnd"] = tonumber(castTime) end;
	
	if dirty then PM_Settings["Data"][session]["info"]["playerData"][player]["dirty"] = true else PM_Settings["Data"][session]["info"]["playerData"][player]["dirty"] = false; end;
	
	if PM_Settings["Data"][session]["info"]["playerData"][player]["totalHealing"] == nil then PM_Settings["Data"][session]["info"]["playerData"][player]["totalHealing"] = 0 end;
	if PM_Settings["Data"][session]["info"]["playerData"][player]["totalDamage"] == nil then PM_Settings["Data"][session]["info"]["playerData"][player]["totalDamage"] = 0 end;
	if PM_Settings["Data"][session]["info"]["playerData"][player][damageClass]["totalValue"] == nil then PM_Settings["Data"][session]["info"]["playerData"][player][damageClass]["totalValue"] = 0; end
	if PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["value"] == nil then PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["value"] = 0; end
	if PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["count"] == nil then PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["count"] = 0 end;
	if PM_Settings["Data"][session]["info"]["totalDamage"] == nil then PM_Settings["Data"][session]["info"]["totalDamage"] = 0 end;
	if PM_Settings["Data"][session]["info"]["totalHealing"] == nil then PM_Settings["Data"][session]["info"]["totalHealing"] = 0 end;
	
	if PM_Settings["Data"][session]["players"] == nil then PM_Settings["Data"][session]["players"] = {} end;
	
	if PM_Settings["Data"][session]["players"][player] == nil then PM_Settings["Data"][session]["players"][player] = {} end;
	
	-- Update cached data.
	
	
	PM_Settings["Data"][session]["info"]["playerData"][player][damageClass]["totalValue"] = PM_Settings["Data"][session]["info"]["playerData"][player][damageClass]["totalValue"] + value;
	PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["count"] = PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["count"] + 1;
	PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["value"] = PM_Settings["Data"][session]["info"]["playerData"][player][damageClass][ability][damageModifier]["value"] + value;
	
	
	
	if damageClass == "healing"
	then
		PM_Settings["Data"][session]["info"]["playerData"][player]["totalHealing"] = PM_Settings["Data"][session]["info"]["playerData"][player]["totalHealing"] + value;
		PM_Settings["Data"][session]["info"]["totalHealing"] = PM_Settings["Data"][session]["info"]["totalHealing"] + value;
	else
		PM_Settings["Data"][session]["info"]["totalDamage"] = PM_Settings["Data"][session]["info"]["totalDamage"] + value;
		PM_Settings["Data"][session]["info"]["playerData"][player]["totalDamage"] = PM_Settings["Data"][session]["info"]["playerData"][player]["totalDamage"] + value;
	end;
	
	
	
	-- Insert raw data
	
	table.insert(PM_Settings["Data"][session]["players"][player], 
		{
			["castTime"] 			= tonumber(castTime),
			["player"] 				= player,
			["ability"]				= ability,
			["value"] 				= tonumber(value),
			["targetName"] 			= targetName,
			["damageModifier"] 		= damageModifier,
			["damageClass"] 		= damageClass,
			["extra"] 				= extra
		}
	)
	PM_Settings["Settings"]["frames"]["DamageMeter"]["dirty"] = true;
	if damageClass ~= "healing"
	then
		PM_LastDamageTime = GetTime();
	end;
end;

function PM_CombineSortedDataArrays(session, targetFilter, dArr, totalDamage)
	if dArr == nil
	then
		dArr = {}
	end;
	if totalDamage == nil
	then
		totalDamage = 0;
	end;
	if PM_Settings["Data"][session] ~= nil
	then
		if session == "current" and UnitAffectingCombat("player") == nil and PM_LastSessionName ~= ""
		then
			session = PM_LastSessionName;
		end
		
		--PM_(PM_Settings["Data"][session]["info"]["playerData"]);
		if PM_Settings["Data"][session]["info"] ~= nil
		then
				-- We have filters
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
			for player,playerList in pairs(PM_Settings["Data"][session]["players"])
			do
				for _,d in pairs(playerList)
				do
					if dArr[player] == nil
					then
						dArr[player] = 0;
					end;
					for filter,_ in pairs(targetFilter)
					do
						if PM_IsValidDamgeClass(d["damageClass"]) and PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Schools"][d["damageClass"]]["value"] == true
						then
							if d["targetName"] == filter or targetFilter["all"] == true
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
									dArr[player] = dArr[player] + d["value"]
									totalDamage = totalDamage + d["value"];
								end;
								if  targetFilter["all"] == true
								then
									break;
								end;
							end;
						end
					end;
				end;
			end;
		end;
	end
	return dArr, totalDamage;
end

-- /script PM_(PM_GetSortedDataInfoArray("current"))
function PM_GetSortedDataInfoArray(s, targetFilter)
	local dArr = {}
	local session = s;
	
	local totalDamage = 0;
	if s == "all"
	then
		--PM_("Got all session")
		for session,_ in pairs(PM_Settings["Data"])
		do
			--PM_(session)
			dArr, totalDamage = PM_CombineSortedDataArrays(session, targetFilter, dArr, totalDamage)
		end;
	else
		dArr, totalDamage = PM_CombineSortedDataArrays(s, targetFilter, dArr, totalDamage)
	end;
	dArr = PM_SortArrayByValue(dArr)
	return dArr, totalDamage;
end;


function PM_CombineRawDataArray(session, dArr, totalDamage)
	targetFilter = PM_UI_DamageMeter_TargetFilters;
	if PM_Settings["Settings"]["frames"]["DamageMeter"] == nil
	then
		return dArr;
	end;
	if dArr == nil
	then
		dArr = {}
	end;
	if totalDamage == nil
	then
		totalDamage = 0;
	end;
	if PM_Settings["Data"][session] ~= nil
	then
		--PM_(PM_Settings["Data"][session]["info"]["playerData"]);
		if PM_Settings["Data"][session]["info"] ~= nil
		then
				-- We have filters
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
			for player,playerList in pairs(PM_Settings["Data"][session]["players"])
			do
				for _,d in pairs(playerList)
				do
					if PM_IsValidDamgeClass(d["damageClass"]) and PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Schools"][d["damageClass"]]["value"] == true
					then
						if
						(
							--PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Session Filter"]["Show outgoing"]["value"] == true
							--and
							PM_UI_CasterFilters[d["player"]] == true
							or
							PM_UI_CasterFilters["all"] == true
						)
						and
						(
							--PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Session Filter"]["Show incomming"]["value"] == true
							--and
							PM_UI_DamageMeter_TargetFilters[d["targetName"]] == true
							or
							PM_UI_DamageMeter_TargetFilters["all"] == true
						)
						then
							if dArr[tonumber(d["castTime"])] == nil
							then
								dArr[tonumber(d["castTime"])] = {};
							end;
							table.insert(dArr[tonumber(d["castTime"])], d);
						end;
					end
				end;
			end;
		end;
	end
	return dArr, totalDamage;
end

function PM_GetRawDataArray(s, sortArray)
	local dArr = {}
	local session = s;
	
	local totalDamage = 0;
	if s == "all"
	then
		--PM_("Got all session")
		for session,_ in pairs(PM_Settings["Data"])
		do
			--PM_(session)
			dArr, totalDamage = PM_CombineRawDataArray(session, dArr, totalDamage)
		end;
	else
		dArr, totalDamage = PM_CombineRawDataArray(s, dArr, totalDamage)
	end;
	
	--PM_(dArr);
	
	if sortArray
	then
		PM_("sort the array");
		local tArr = {}
		for k,v in pairs(dArr)
		do
			local i = 1;
			if PM_tablelength(tArr) == 0
			then
				PM_("Empty table, inert first value in to it");
				table.insert(tArr, v);
			else
				local foundPlace = false;
				for k2,v2 in pairs(tArr)
				do
					if tonumber(v[1]["castTime"]) < tonumber(v2[1]["castTime"])
					then
						table.insert(tArr, i, v);
						foundPlace = true;
						break;
					end;
					i = i+1;
				end;
				if foundPlace == false
				then
					--PM_("This is higher then all other values, put in last.");
					table.insert(tArr, v);
				end;
			end;
		end;
		dArr = tArr;
	end;
	
	return dArr, totalDamage;
end;

function table.reverse ( tab )
    local newTable = {}
	if tab == nil
	then
		return nil;
	end;
    for i,v in ipairs ( tab )
	do
        table.insert(newTable, 1, v);
    end
 
    return newTable
end

function PM_SortArrayByValue(arr)
	--PM_(arr);
	local r = {}
	for k,v in pairs(arr)
	do
		local i = 1;
		if table.getn(r) == 0
		then
			--PM_("Empty table, inert first value in to it");
			table.insert(r, i, {["key"] = k, ["value"] = v});
		else
			local foundPlace = false;
			for k2,v2 in pairs(r)
			do
				if tonumber(v) < tonumber(v2["value"])
				then
					--PM_(v .." < " .. v2["value"]);
					table.insert(r, i, {["key"] = k, ["value"] = v});
					foundPlace = true;
					break;
				end;
				i = i+1;
			end;
			if foundPlace == false
			then
				--PM_("This is higher then all other values, put in last.");
				table.insert(r, {["key"] = k, ["value"] = v});
			end;
		end;
		
		--PM_(r);
	end;
	return table.reverse(r);
end;

function PM_ConvertTime(castTime)
	local t = PM_strsplit(":", castTime);
	local h = tonumber(t[1])
	local m = tonumber(t[2]);
	local s = tonumber(t[3]);
	
	return h,m,s;
end

function PM_GetStr(str, pattern)
	if str == nil or pattern == nil
	then
		return nil;
	end;
	local start,stop, test = string.find(str, pattern);
	return test;
	--return string.sub(str, start, stop);
end

function PM_SendData(ability, value, targetName, damageModifier, damageClass, extra, dirty, player)
		PM_("----- TEST ------")
		PM_(ability)
		PM_(value)
		PM_(targetName)
		PM_(damageModifier)
		PM_(damageClass)
		PM_(dirty);
		PM_(player);
		PM_("----- TEST ------")
	if ability == nil or value == nil or targetName == nil or damageModifier == nil
	then
		PM_("------------ Got nil value ------------")
		PM_(ability)
		PM_(value)
		PM_(targetName)
		PM_(damageModifier)
		PM_(damageClass)
		return false;
	end;
	
	if dirty and player == nil
	then
		PM_("------------ Got nil value (player) ------------")
		PM_(ability)
		PM_(value)
		PM_(targetName)
		PM_(damageModifier)
		PM_(damageClass)
		PM_(dirty);
		PM_(player)
		return false;
	end;
	
	extra = 0;
	
	if damageClass == nil
	then
		damageClass = "Physical"
	end;
	
	local serverTime = PM_GetServerTime()
	
	
	if player == "you" or player == "your" or player == UnitName("player")
	or targetName == "you" or targetName == "your" or targetName == UnitName("player")
	then
		dirty = false;
	end;
	
	if player == nil or string.lower(player) == "you" or string.lower(player) == "your" or player == UnitName("Player")
	then
		dirty = false; -- This data is about us, so it can't be dirty inside this function.
		player = UnitName("Player");
	end;
	
	if targetName == nil or string.lower(targetName) == "you" or string.lower(targetName) == "your" or targetName == UnitName("Player")
	then
		dirty = false; -- This data is about us, so it can't be dirty inside this function.
		targetName = UnitName("Player");
	end;
	
	
	
	local msgStr = "";
	
	msgStr = msgStr .. serverTime;
	msgStr = msgStr .. ";" .. ability;
	msgStr = msgStr .. ";" .. value;
	msgStr = msgStr .. ";" .. targetName;
	msgStr = msgStr .. ";" .. damageModifier;
	msgStr = msgStr .. ";" .. damageClass;
	if extra
	then
		msgStr = msgStr .. ";" .. extra;
	else
		msgStr = msgStr .. ";";
	end
	msgStr = msgStr .. ";" .. player;
	
	--player = string.gsub(player, " ", "");
	
	local InGroup = (UnitInParty("Player") and UnitInRaid("Player"));
	
	if (player == UnitName("Player") or targetName == UnitName("Player")) and false -- temp disable.
	then
		-- This data is related to us, so broadcast it.
		PM_("SentMessage: '".. msgStr .."'");
		SendAddonMessage("PlayerMeter_Sync", msgStr , "RAID")
	else
		local serverTime = PM_GetServerTime()
		local castTime = serverTime;
		--PM_("Dirty data")
		--PM_(dirty);
		PM_SaveData(castTime, player, ability, value, targetName, damageModifier, damageClass, nil, dirty)
	end
end;

-- Generic functions

-- /script PM_(PM_GetSessionMainTarget())
function PM_GetSessionMainTarget(s)
	local session;
	if session == nil
	then
		session = "current";
	else
		session = s;
	end;
	local nameArr = {};
	local currentName = ""
	local currentValue = 0;
	--PM_Settings["Data"][session]["players"][player][I++]["targetName"] 			= targetName,
	if PM_Settings["Data"][session] ~= nil and PM_Settings["Data"][session]["players"] ~= nil
	then
		for player,playerData in pairs(PM_Settings["Data"][session]["players"])
		do
			for _,d in pairs(playerData)
			do
				if d ~= nil
				then
					if d["damageClass"] ~= "healing" and d["extra"] == "player" -- ignore healing and only stuff done by us.
					then
						if nameArr[d["targetName"]]  == nil
						then
							nameArr[d["targetName"]] = 0;
						end;
						nameArr[d["targetName"]] = nameArr[d["targetName"]] + d["value"];
						if nameArr[d["targetName"]] > currentValue
						then
							currentValue = nameArr[d["targetName"]];
							currentName = d["targetName"]
						end;
					end;
				end;
			end;
		end;
		return currentName;
	else
		return ""
	end
end;

function PM_CombineSessionTargets(session, targets, getCaster)
	if getCaster == nil
	then
		getCaster = false;
	end;
	if targets == nil
	then
		targets = {}
	end;
	if session == "all" or session == nil or PM_Settings["Data"][session]["players"] == nil
	then
		return targets
	end;
	--PM_(PM_Settings["Data"][session]);
	for player,playerData in pairs(PM_Settings["Data"][session]["players"])
	do
		for _,d in pairs(playerData)
		do
			if d ~= nil
			then
				if PM_Settings["Settings"]["frames"]["DamageMeter"]["Display Settings"]["Schools"][d["damageClass"]]["value"] == true
				then
					if
						true
						--(PM_UI_DamageMeter_TargetFilters[d["targetName"]] == true or PM_UI_DamageMeter_TargetFilters["all"] == true)
						--and
						--(PM_UI_CasterFilters[d["player"]] == true or PM_UI_CasterFilters["all"] == true)
					then
						if getCaster
						then
							targets[d["player"]] = {};
						else
							targets[d["targetName"]] = {}; -- Might wanna save data here later.
						end;
					end;
				end;
			end;
		end;
	end;
	return targets;
end

function PM_GetSessionTargets(s, getCaster)
	local session;
	
	if getCaster == nil
	then
		getCaster = false;
	end;
	
	if s == nil
	then
		session = "current";
	else
		session = s;
	end;
	--PM_Settings["Data"][session]["players"][player][I++]["targetName"] 			= targetName,
	if PM_Settings["Data"][session] ~= nil
	then
		local targets = {}
		if s == "all"
		then
			for session, _ in pairs(PM_Settings["Data"])
			do
				targets = PM_CombineSessionTargets(session, targets, getCaster)
			end;
		else
			targets = PM_CombineSessionTargets(session, targets, getCaster)
		end;
		return targets;
	else
		return {}
	end
end;


PM_MessageBuffer = {}

function PM_SendMessage(msg, channel)
	local r = 
	{
		["msg"] = msg,
		["channel"] = channel,
	}
	table.insert(PM_MessageBuffer, r);
end;


function PM_(str)
	if true
	then
		return;
	end;
	local c = ChatFrame1;
	
	if ChatFrame5 ~= nil
	then
		c = ChatFrame5;
	end;
	
	
	if str == nil
	then
		c:AddMessage('DEBUG: NIL'); --ChatFrame1
	elseif type(str) == "boolean"
	then
		if str == true
		then
			c:AddMessage('DEBUG: true');
		else
			c:AddMessage('DEBUG: false');
		end;
	elseif type(str) == "table"
	then
		c:AddMessage('DEBUG: array');
		PM_printArray(str);
	else
		c:AddMessage('DEBUG: '..str);
	end;
end;


function PM_printArray(arr, n)
	if n == nil
	then
		 n = "arr";
	end
	for key,value in pairs(arr)
	do
		if type(arr[key]) == "table"
		then
			PM_printArray(arr[key], n .. "[\"" .. key .. "\"]");
		else
			if type(arr[key]) == "string"
			then
				PM_(n .. "[\"" .. key .. "\"] = \"" .. arr[key] .."\"");
			elseif type(arr[key]) == "number" 
			then
				PM_(n .. "[\"" .. key .. "\"] = " .. arr[key]);
			elseif type(arr[key]) == "boolean" 
			then
				if arr[key]
				then
					PM_(n .. "[\"" .. key .. "\"] = true");
				else
					PM_(n .. "[\"" .. key .. "\"] = false");
				end;
			else
				PM_(n .. "[\"" .. key .. "\"] = " .. type(arr[key]));
				
			end;
		end;
	end
end;

-- /script local m = PM_ArrMemory(PM_Settings); PM_("This array uses: " .. m/1024 .. "MB ram (".. m .."B)");
function PM_ArrMemory(arr, memory)
	if memory == nil
	then
		 memory = 0;
	end
	for key,value in pairs(arr)
	do
		if type(arr[key]) == "table"
		then
			memory = PM_ArrMemory(arr[key], memory + 2 + string.len(key)); -- 2 byte + 1 byte per character in the name.
		else
			memory = memory + 2 + string.len(key);
			if type(arr[key]) == "string"
			then
				memory = memory + string.len(value)
			end;
		end;
	end
	return memory;
end;


function PM_strsplit(sep,str)
	local arr = {}
	local tmp = "";
	
	--PM_(string.len(str));
	local chr;
	for i = 1, string.len(str)
	do
		chr = string.sub(str, i, i);
		if chr == sep
		then
			table.insert(arr,tmp);
			tmp = "";
		else
			tmp = tmp..chr;
		end;
	end
	table.insert(arr,tmp);
	
	return arr
end

function PM_tablelength(T)
	if T == nil
	then
		return 0;
	end;
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end


function PM_num2hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = PM_fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
	if string.len(s) == 1
	then
		s = "0" .. s 
	end;
    return s
end

--/script PM_(100 - math.floor(100/3)*3)
function PM_fmod(a,b)
	 return a - math.floor(a/b)*b
end;

function PM_round(val, decimal)
	val = tonumber(val);
	if (decimal)
	then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal);
	else
		return math.floor(val+0.5);
	end;
end;


function PM_AllOutOfCombat()
		local scanNum = MAX_PARTY_MEMBERS;
	local scanName = "Party"
	
	if UnitInRaid("Player")
	then
		scanNum = GetNumRaidMembers();
		scanName = "Raid";
	end;
	
	for groupindex = 1,scanNum
	do
		local unitID = scanName .. groupindex;
		if UnitAffectingCombat(unitID)
		then
			return false;
		end;
	end;
	return true;
end

