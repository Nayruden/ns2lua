
Script.Load("lua/BindingsShared.lua")
KeyBindInfo:Init()

local InputKeybinds = {
	Exit = true,
	Jump = true,
	MovementModifier = true,
	Crouch = true,
	Reload = true,
	Drop = true,
	Buy = true, 
	ToggleFlashlight = true,
	Use = true,
	Taunt = true, 
	Weapon1 = true,
	Weapon2 = true,
	Weapon3 = true,
	Weapon4 = true,
	Weapon5 = true,
	PrimaryAttack = "PrimaryFire",
	SecondaryAttack = "SecondaryFire",
}

local MovementKeybinds = {
	MoveForward = {"z", 1, "MoveForward"},
	MoveBackward = {"z", -1, "MoveBackward"},
	MoveLeft = {"x", 1, "MoveLeft"},
	MoveRight = {"x", -1, "MoveRight"},
}

local InputBitToName = {}

for _,inputname in ipairs(InputEnum) do
	InputBitToName[Move[inputname]] = inputname
end

KeybindMapper = {
	Keybinds = {}, 
	MovementVector = Vector(0,0,0), 
	InputMovementKeyMappings = {},
	InputKeybindMappings = {}, 
	KeybindActions = {},
	MoveInputBitFlags = 0,
	FilteredKeys = {},
	InGameMenuOpen = false,
	ConsoleOpen = false,
	
-- change this to true if you want all keybinds tobe ignored when the console is open
-- this is disabled by default because there issues with dectecting when the console is open
	IgnoreConsoleState = true,
	
}

function KeybindMapper:Init()
	
	if(not self.Loaded) then
		self.fp = Client.CreateFlashPlayer()
		Client.AddFlashPlayerToDisplay(self.fp)

		self.fp:Load("ui/input.swf")
		self.fp:SetBackgroundOpacity(0)
		
		self:RefreshInputKeybinds()
		
		self.Loaded = true
	end
end

function KeybindMapper:RefreshInputKeybinds()

	table.clear(self.InputMovementKeyMappings)
	MovementVector = Vector(0,0,0)

	for bindname,movdir in pairs(MovementKeybinds) do
		local key = KeyBindInfo:GetBoundKey(bindname)
		
		if(key) then
			self.InputMovementKeyMappings[key] = movdir
		else
			Shared.Message("KeybindMapper: Warning no key was bound to movment bind "..bindname)
		end
	end

	table.clear(self.InputKeybindMappings)
	self.MoveInputBitFlags = 0
	
	for bitname,bindname in pairs(InputKeybinds) do
		if(bindname == true) then
			bindname = bitname
		end

		local key = KeyBindInfo:GetBoundKey(bindname)
	
		if(key) then
			self.InputKeybindMappings[key] = Move[bitname]
		end
	end
	
	table.clear(self.Keybinds)

	for bindname,action in pairs(self.KeybindActions) do
		local key = KeyBindInfo:GetBoundKey(bindname)

		if(key) then
			self.Keybinds[key] = action
		end
	end

	--seems tobe hardcoded in the engine atm
	self.ConsoleKey = "Grave"
end

function KeybindMapper:CheckKeybindChanges()
	local changedKeybindsString = Main.GetOptionString("ChangedKeybinds", "")

	if(changedKeybindsString ~= "") then
		local changedKeybinds = Explode(changedKeybindsString, "@")

		KeyBindInfo:ReloadKeyBindInfo()
		self:RefreshInputKeybinds()

		--[[
		for _,bindname in ipairs(changedKeybinds) do
			local change, newkey, oldkey = KeyBindInfo:CheckKeybindChange(bindname)
			
			if(change) then
				PrintDebug("KeybindChange:%s old=%s, new =%s",change, oldkey or "nil", newkey or "nil")
				
				--if the newkey was bound to a input bit before clear it and clear InputMapping key entry
				if(newkey) then
					if(self.InputKeybindMappings[newkey] ~= nil)
						self.MoveInputBitFlags = bit.bxor(self.MoveInputBitFlags, self.InputKeybindMappings[newkey])
						self.InputKeybindMappings[newkey] = nil
					else
						
					end
					
					if(InputKeybinds[bindname] or bindname == "PrimaryFire" or bindname == "SecondaryFire") then
						
						if
	 					self.InputKeybindMappings[newkey] = 
	 				end
	 			end
	 			
			end
			
		end
		]]--
			Main.SetOptionString("ChangedKeybinds", "")
	end
end

function KeybindMapper:ResetMovment()
	self.MovementVector = Vector(0,0,0)
end

function KeybindMapper:InGameMenuOpened()
	self:ResetMovment()
	self.MoveInputBitFlags = 0
	self.InGameMenuOpen = true
end

function KeybindMapper:OnKeyDown(key)
	
	--The Engines Console input event handler should be filtering all key input events when the console is open
	--so they don't get sent to other input handlers but doesn't for some dumb reason
	if(not self.IgnoreConsoleState and key == self.ConsoleKey) then
			self.ConsoleOpen = not self.ConsoleOpen			
		return
	end
	
	if(not self.IgnoreConsoleState and self.ConsoleOpen) then
		return
	end

	if(self.FilteredKeys[key]) then
		for _,action in ipairs(self.FilteredKeys[key]) do
			--if a filter action returns true we don't let anything else process this key event and just return
			if(self:ActivateAction(action, key, true)) then
				return
			end
		end
	end

	local movedir = self.InputMovementKeyMappings[key]

	if(movedir) then
		--don't do anything if the the opposite movment key is already being held down i.e. our movement vector field is non zero
		if(self.MovementVector[movedir[1]] == 0) then
			self.MovementVector[movedir[1]] = movedir[2] 
		end
		
		return
	end
	
	--check to see if this is one of the Move.input keybinds if it is set the bit it coresponds to
	if(self.InputKeybindMappings[key]) then
		--PrintDebug("OnKeyDown input", InputBitToName[self.InputKeybindMappings[key]])
		self.MoveInputBitFlags = bit.bor(self.MoveInputBitFlags, self.InputKeybindMappings[key])
	 return
	end

	--PrintDebug("OnKeyDown ", key)

	local action = self.Keybinds[key]

	if(action) then
		self:ActivateAction(action, key, true)
	end
end

function KeybindMapper:OnKeyUp(key)
	local movedir = self.InputMovementKeyMappings[key]

	if(movedir) then
		--don't do anything if the the opposite movment key is already being held down i.e. our movement vector field is not equal to our direction number
		if(self.MovementVector[movedir[1]] == movedir[2]) then
			self.MovementVector[movedir[1]] = 0
		end

		return
	end

	--check to see if this is one of the Move.input keybinds and if the bit is set. then unset the bit it coresponds to.
	if(self.InputKeybindMappings[key] and bit.band(self.MoveInputBitFlags, self.InputKeybindMappings[key]) ~= 0) then
		--PrintDebug("OnKeyDown input", InputBitToName[self.InputKeybindMappings[key]])
		self.MoveInputBitFlags = bit.bxor(self.MoveInputBitFlags, self.InputKeybindMappings[key])
	 return
	end

	local action = self.Keybinds[key]

	if(action) then
		self:ActivateAction(action, key, false)
	end
end

function KeybindMapper:ActivateAction(action, key, down)
	
	local func = action.OnDown
	local result = false

	if(not down) then
		func = action.OnUp
	end

	if(func) then
		if(action.args) then
			result = func(unpack(action.args))
		else
			result = func()
		end
	end
	
	return result
end

function KeybindMapper:LinkBindToFunction(bindname, func, updown, arg)
	
	local keybindEntry = {}
	
	if(updown == nil or updown == "down") then
		keybindEntry.OnDown = func
	elseif(updown == "up") then
		keybindEntry.OnUp = func
	end
	keybindEntry.arg1 = arg

	self:RegisterActionToBind(bindname, keybindEntry)
end

--if the fuction name is not provided the name of the bind is used as the function name
function KeybindMapper:LinkBindToSelfFunction(bindname, selfobj, funcname, updown)
	
	if(funcname == nil) then
		funcname = bindname
	end
	
	local keybindAction = {BindName = bindname, SelfFunction = funcname}
	
	if(updown == nil or updown == "down") then
		keybindAction.OnDown = selfobj[funcname]
	elseif(updown == "up") then
		keybindAction.OnUp = selfobj[funcname]
	end
	
	keybindAction.args = {selfobj}
	
	self:RegisterActionToBind(bindname, keybindAction)
end

function KeybindMapper:LinkBindToConsoleCmd(bindname, commandstring, updown)

	local keybindAction = {
		ConsoleCommand = commandstring,
		BindName = bindname,
	}

	local func = function() Shared.ConsoleCommand(commandstring) end

	if(updown == nil or updown == "down") then
		keybindAction.OnDown = func
	elseif(updown == "up") then
		keybindAction.OnUp = func
	end

	self:RegisterActionToBind(bindname, keybindAction)
end

function KeybindMapper:RegisterActionToBind(bindname, keybindaction)
	
	if(not keybindaction) then
		error("RegisterActionToBind: was passed a nil action")
	end

	self.KeybindActions[bindname] = keybindaction

	--map the key that the bindname is set to if were loaded already
	if(self.Loaded) then
		local key = KeyBindInfo:GetBoundKey(bindname)

		if(key and key ~= "") then
			self.Keybinds[key] = keybindaction
		end
	end
end

function KeybindMapper:GetDescriptionForBoundKey(key)

	if(self.InputMovementKeyMappings[key]) then
		return "Movement Keybind:"..self.InputMovementKeyMappings[key][3]
	end
	
	if(self.InputKeybindMappings[key]) then
		return "Move.input bit Keybind:"..self.InputBitToName[self.InputKeybindMappings[key]]
	end
	
	local action = self.Keybinds[key]
	
	if(action) then
		if(action.ConsoleCommand) then
			if(action.BindName) then
				return string.format("Console command \"%s\" Assocated with bind \"%s\"", action.ConsoleCommand, action.BindName)
			elseif(action.UserCreatedBind) then
				
			end
		end
	end
	
end

function KeybindMapper:ClearKey(key)

	if(self.InputKeybindMappings[key]) then
		self.MoveInputBitFlags = bit.band(self.MoveInputBitFlags, bit.bnot(self.InputKeybindMappings[key]))
		self.InputKeybindMappings[key] = nil
	end

	if(self.InputMovementKeyMappings[key]) then
		local movdir = self.InputMovementKeyMappings[key]
		
		if(self.MovementVector[movedir[1]] == movedir[2]) then
			self.MovementVector[movedir[1]] = 0
		end
		
		self.InputMovementKeyMappings[key] = nil
	end
	
	self.Keybinds[key] = nil	

end

function KeybindMapper:BindKeyToConsoleCommand(key, commandstring)
	
	local keybindAction = {
		ConsoleCommand = commandstring,
		UserCreatedBind = true,
	}

	local func = function() Shared.ConsoleCommand(commandstring) end

	if(updown == nil or updown == "down") then
		keybindAction.OnDown = func
	elseif(updown == "up") then
		keybindAction.OnUp = func
	end
	
	self.Keybinds[key] = keybindAction
end

function BindConsoleCommand(player, key, ...)
	
	local upperkey = key:upper()
	local RealKeyName = false
	
	for i,keyname in ipairs(InputKeyNames) do
		if(upperkey == keyname:upper()) then
				RealKeyName = keyname
			break
		end
	end

	if(RealKeyName) then
		KeybindMapper:ClearKey(RealKeyName)
		
		local command = table.concat({...}, " ")
		
		KeybindMapper:BindKeyToConsoleCommand(RealKeyName, command)
	else
		Shared.Message("bind:Unreconized key "..key)
	end
end

Event.Hook("Console_bind",  BindConsoleCommand)


--called by flash
function IsInputTrackingDisabled()

	if(KeybindMapper.InGameMenuOpen and not Client.GetMouseVisible()) then
		KeybindMapper.InGameMenuOpen = false
	end

	return ChatUI.ChatOpened == true or KeybindMapper.InGameMenuOpen == true
end

--[[
function SetModiferKeyState(key, down)
	
end
]]--

--called by flash
function OnKeyDown(key, code)
	KeybindMapper:OnKeyDown(key)
end

--called by flash
function OnKeyUp(key, code)
	KeybindMapper:OnKeyUp(key)
end

Event.Hook("MapPostLoad", function() 
	KeybindMapper:Init() 
	--Client.CreateEntity("keybindwatcher", Vector(0,0,0))
end )

--KeybindMapper:RefreshInputKeybinds()

if(not KeybindMapper.IgnoreConsoleState) then
	Event.Hook("Console_km_rcs", function() KeybindMapper.ConsoleOpen = true end )
	KeybindMapper.ConsoleOpen = Main.GetOptionBoolean("ConsoleOpen", false)
	Script.AddShutdownFunction(function() Main.SetOptionBoolean("ConsoleOpen", KeybindMapper.ConsoleOpen) end )
end

KeybindMapper:LinkBindToConsoleCmd("JoinMarines", "changeclass marine")
KeybindMapper:LinkBindToConsoleCmd("JoinAliens", "changeclass skulk")
KeybindMapper:LinkBindToConsoleCmd("ReadyRoom", "readyroom")
KeybindMapper:LinkBindToConsoleCmd("ToggleThirdPerson", "thirdperson")
