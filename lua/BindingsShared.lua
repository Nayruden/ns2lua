
--[[
Notes

		When a bind has its key clear/unbound we do Main.SetOptionBoolean("ns2lua/UnboundBinds/"BindName) because some of engine keybinds resets to defaults 
		if we set there value to an empty string
		
Public functions:
	string:KeyName GetBoundKey(BindName)
	bool IsKeyBound(string KeyName)
	void SetKeybind(string KeyName, string BindName)
	void UnbindKey(string KeyName)
	void ClearBind(string BindName)

]]--


InputEnum = {
	"PrimaryAttack",
	"SecondaryAttack",
	"NextWeapon",
	"PrevWeapon",
	"Reload",
	"Use",
	"Jump",
	"Crouch",
	"MovementModifier",
	"Minimap",
	"Buy",
	"ToggleFlashlight",
	"Weapon1",
	"Weapon2",
	"Weapon3",
	"Weapon4",
	"Weapon5",
	
	"ScrollBackward",
	"ScrollRight",
	"ScrollLeft",
	"ScrollForward",
	"Exit",
	
	"Drop",
	"Taunt",
	"Scoreboard",
	
	"ToggleSayings1",
	"ToggleSayings2",
	
	"TeamChat",
	"TextChat",
}

KeyBindInfo = {
	Loaded = false,
	KeybindEntrys = {},
	RegisteredKeybinds = {},
	KeybindNameToKey = {},
	BoundKeys = {}, --stores the maping of a key to a keybindname
	KeybindGroups = {},
	LogLevel = 1,
}

KeyBindInfo.MovementKeybinds = {
		BindDefaultKeys = true,
		Description = "Movement",
		Keybinds = {
    	{"MoveForward", "Move forward", "W"},
    	{"MoveBackward", "Move Backward", "S"},
    	{"MoveLeft", "Move Left", "A"},
    	{"MoveRight", "Move Right", "D"},
    	{"Jump", "Jump", "Space"},
    	{"MovementModifier", "Movement special", "LeftShift"},
    	{"Crouch", "Crouch", "LeftControl"},
    }
}

KeyBindInfo.ActionKeybinds = {
		BindDefaultKeys = true,
		Description = "Misc",  
		Keybinds = {
    	{"PrimaryFire", "Primary attack", "MouseButton0"},
    	{"SecondaryFire", "Secondary attack", "MouseButton1"},
    	{"Reload", "Reload", "R"},
    	{"Drop", "Drop weapon", "G"},
  		{"ToggleFlashlight", "Toggle Flashlight", "F"},
  		{"Buy", "Buy", "T"},
  		{"Use", "Use", "E"},
    	{"Taunt", "Taunt", "Z"},
    	{"VoiceChat",  "Use microphone", "F9"},
    	{"ToggleSayings", "Voice menu", "X"},
    	{"TextChat", "Public chat", "Y"},
			{"TeamChat", "Team chat",	"U"},
    	{"Weapon1", "Weapon #1", "1"},
    	{"Weapon2", "Weapon #2", "2"},
    	{"Weapon3", "Weapon #3", "3"},
    	{"Weapon4", "Weapon #4", "4"},
    	{"Weapon5", "Weapon #5", "5"},
    }
}

KeyBindInfo.MiscKeybinds = {
		BindDefaultKeys = true,
		Description = "Misc",  
		Keybinds = {
			{"JoinMarines", 	"Join Marines", 				"F1"},
			{"JoinAliens", 		"Join Aliens",					"F2"},
			{"JoinRandom", 		"Join Random Team", 		"F3"},
			{"ReadyRoom" ,		"Return to Ready Room", "F4"},
			{"ToggleConsole", "Open Console", 				"Grave"},
			{"Exit", 					"Open Main Menu", 			"Escape"},
		}
}

KeyBindInfo.HiddenKeybinds = {
		Hidden = true,
		Keybinds = {
			{"ActivateSteamworksOverlay"},
			{"LockViewFrustum"},
			{"LockViewPoint"},
			{"ToggleDebugging"},
		}
}

KeyBindInfo.EngineProcessed = {
	ToggleConsole = true,
	ActivateSteamworksOverlay = true,
	Voice = true,
  LockViewFrustum = true,
  LockViewPoint = true,
  ToggleDebugging = true,
}

function KeyBindInfo:Init()
	if(not self.Loaded) then
		self:ReloadKeyBindInfo()
	end
end

function KeyBindInfo:MainVMLazyLoad()
	if(not self.Loaded and not self.LazyLoad) then
		self:AddDefaultKeybindGroups()
		self.LazyLoad = true
	end
end

function KeyBindInfo:ReloadKeyBindInfo()
	table.clear(self.KeybindEntrys)
	table.clear(self.KeybindGroups)
	table.clear(self.RegisteredKeybinds)
	table.clear(self.KeybindNameToKey)
	table.clear(self.BoundKeys)

	self:AddDefaultKeybindGroups()

	self:LoadAndValidateSavedKeyBinds()
	self.Loaded = true
	self.LazyLoad = nil
end

function KeyBindInfo:AddDefaultKeybindGroups()
	self:AddKeybindGroup(self.MovementKeybinds)
	self:AddKeybindGroup(self.ActionKeybinds)
	self:AddKeybindGroup(self.MiscKeybinds)
	self:AddKeybindGroup(self.HiddenKeybinds)
end

--
function KeyBindInfo:AddKeybindGroup(keybindGroup)
	table.insert(self.KeybindGroups, keybindGroup)

	for _,keybind in ipairs(keybindGroup.Keybinds) do
		self.RegisteredKeybinds[keybind[1]] = keybind

		self.KeybindEntrys[#self.KeybindEntrys+1] = keybind
	end
end

function KeyBindInfo:LoadAndValidateSavedKeyBinds()

	for _,bindinfo in ipairs(self.KeybindEntrys) do
		local key = Main.GetOptionString("input/"..bindinfo[1], "")

		if(key ~= "" and not Main.GetOptionBoolean("ns2lua/UnboundBinds/"..bindinfo[1], false)) then
			if(self:IsKeyBound(key)) then
				self:Log(1, string.format("ignoreing \"%s\" bind because \"%s\" is alreay bound to the same key which is \"%s\"", bindinfo[1], self.BoundKeys[key], key), 2 )
			else
				self:InternalBindKey(key, bindinfo[1])
			end
		end
	end
	
	local keybindversion = Main.GetOptionString("ns2lua/KeybindVersion", "")
	
	
	if(keybindversion == "") then
		self:FixBinds()
		Main.SetOptionString("ns2lua/KeybindVersion", "1")
	end

	--add any keybinds where they default key is currently unbound and which have BindDefautKeys set to true for there keybind group
	for _,bindgroup in ipairs(self.KeybindGroups) do
		if(bindgroup.BindDefaultKeys) then
			for _,bind in ipairs(bindgroup.Keybinds) do
				if(not self:GetBoundKey(bind[1]) and  not self:IsKeyBound(bind[3])) then
					self:InternalBindKey(bind[3], bind[1])
				end
			end
		end
	end	
end

--{BindName, Engine default key or false to always unbind this bind, new key or false to use the DefaultKey for the keybind}
local BindFixs = {
	--do TeamChat before TextChat so we free up Y for TextChat
	{"TeamChat", "Y", false},
	{"TextChat", "Return", false},

	--shift these 2 to diffent F keys so we can use the F keys for randomteam and readyroom
	{"ActivateSteamworksOverlay","F3", "F10"},
	{"LockViewFrustum", "F4", "F11"},
}

function KeyBindInfo:FixBinds()

	for _,KeyInfo in ipairs(BindFixs) do
		local bindName = KeyInfo[1]
		local currentKey = self:GetBoundKey(bindName)

		if(KeyInfo[2]) then
			if(not currentKey or currentKey == KeyInfo[2]) then
				local newkey = KeyInfo[3] or self.RegisteredKeybinds[bindName][3]

				if(not self:IsKeyBound(newkey)) then
					self:SetKeybind(newkey, bindName)
				end
			end
		else
			if(currentKey) then
				self:UnbindKey(currentKey)
			end
		end
	end
end

function KeyBindInfo:RegisterKeyBindGroup(label, keybinds)

	if(self.Loaded) then
		self:AddKeybindGroup(label, keybinds)
	end
end

function KeyBindInfo:GetBindingDialogTable()
	if(not self.Loaded and not self.LazyLoad) then
		self:MainVMLazyLoad()
	end

	if(not self.BindingDialogTable) then
		local bindTable = {}
		local index = 1

		for _,bindgroup in ipairs(self.KeybindGroups) do
			if(not bindgroup.Hidden) then
				bindTable[index] = bindgroup.Description 
				bindTable[index+1] = "title"
				bindTable[index+2] = bindgroup.Description
				bindTable[index+3] = ""
			 
			 	index = index+4
					
				for _,bind in ipairs(bindgroup.Keybinds) do
					bindTable[index] = bind[1] 
					bindTable[index+1] = "input"
					bindTable[index+2] =  bind[2]
					bindTable[index+3] =  bind[3]
				 
				 	index = index+4
				end
			end
		end
		
		self.BindingDialogTable = bindTable
	end

	return self.BindingDialogTable
end

function KeyBindInfo:GetBoundKey(keybindname)

	if(self.RegisteredKeybinds[keybindname] == nil) then
		error("GetBoundKey: keybind called \""..keybindname.."\" does not exist")
	end

	return self.KeybindNameToKey[keybindname]
end

function KeyBindInfo:IsKeyBound(key)	
	return self.BoundKeys[key] ~= nil
end

function KeyBindInfo:SetKeybind(key, bindname, dontSave)
	self:CheckKeyBindsLoaded()

	if(self.RegisteredKeybinds[bindname] == nil and not self.EngineProcessed[bindname]) then
		error("SetKeyBind: keybind called \""..bindname.."\" does not exist")
	end
	
	--if keybind had a key already set clear the record of it in our BoundKeys table
	if(self.KeybindNameToKey[bindname]) then
		self.BoundKeys[self.KeybindNameToKey[bindname]] = nil
	end

	if(self.BoundKeys[key]) then
		self:UnbindKey(key)
	end

	self:InternalBindKey(key, bindname)

	if(not dontSave) then
		Main.SetOptionString("ns2lua/UnboundBinds/"..bindname, nil)
		Main.SetOptionString("input/"..bindname, key)		
	end
end

function KeyBindInfo:UnbindKey(key, dontSave)
	
	if(self.BoundKeys[key] == nil) then
			self:Log(1, "\""..key.."\" is already unbound")
		return
	end

	local bindName = self.BoundKeys[key]

	if(not dontSave) then
		Main.SetOptionString("input/"..bindName, "")
		Main.SetOptionBoolean("ns2lua/UnboundBinds/"..bindName, true)
	end

	self.KeybindNameToKey[bindName] = nil
	self.BoundKeys[key] = nil
end

function KeyBindInfo:ClearBind(bindname)

	Main.SetOptionString("input/"..bindName, "")
	Main.SetOptionBoolean("ns2lua/UnboundBinds/"..bindName, true)

	if(self.KeybindNameToKey[bindName] == nil) then
		self:Log(1, "\""..bindname.."\" is already unbound")
	else
		local key = self.KeybindNameToKey[bindName]
	
		self.KeybindNameToKey[bindName] = nil
		self.BoundKeys[key] = nil
	end
end

function KeyBindInfo:CheckKeybindChange(bindName)
	
	local newkey = Main.GetOptionString("input/"..bindName, "")
	local oldkey = self.KeybindNameToKey[bindName]
	
	if(newkey == "") then
		newkey = nil
	end

	local ChangeType = false

	if(newkey ~= oldkey) then
		if(oldkey) then
			if(newkey) then
				ChangeType = "ReBind"
			else
				ChangeType = "ClearBind"
			end
		else
			ChangeType = "SetBind"
		end
	end
	
	self:SetKeybind(bindName, newkey, true)
	
	return ChangeType, newkey, oldkey
end

function KeyBindInfo:CheckKeyBindsLoaded()
	--check if we populated the table already
	if(next(self.BoundKeys) ~= nil) then
		return
	else
		self:LoadAndValidateSavedKeyBinds()
	end
end

function KeyBindInfo:InternalBindKey(key, bindname)	
	self.BoundKeys[key] = bindname
	self.KeybindNameToKey[bindname] = key
end

function KeyBindInfo:ResetGroupToDefaults()
	
end

function KeyBindInfo:ResetKeybindsToDefaults()
	for _,bindgroup in ipairs(self.KeybindGroups) do
		for _,bind in ipairs(bindgroup.Keybinds) do
			Main.SetOptionString("input/"..bind[1], bind[3])
			self:InternalBindKey(bind[3], bind[1])
		end
	end
end

function KeyBindInfo:Log(level, msg)
	
	if(level > self.LogLevel) then
		return
	end
	
	if(Shared) then
		Shared.Message(msg)
	else
		print(msg)
	end
end
