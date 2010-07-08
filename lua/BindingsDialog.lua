--=============================================================================
--
-- lua/BindingsDialog.lua
-- 
-- Populate and manage key bindings in options screen.
--
-- Created by Henry Kropf and Charlie Cleveland
-- Copyright 2010, Unknown Worlds Entertainment
--
--=============================================================================

Script.Load("lua/BindingsShared.lua")


local specialKeys = {
    [" "] = "SPACE"
}


local LazyLoadMode = true
local ChangedKeybinds = {}

if(Main.GetOptionString("ChangedKeybinds", "") ~= "") then
	Main.SetOptionString("ChangedKeybinds", "")
end
--
-- Get the value of the input control
--/
function BindingsUI_GetInputValue(controlId)
	  
	  if(LazyLoadMode) then
	  	KeyBindInfo:Init()
	  	LazyLoadMode = false
	  end
	  
    return KeyBindInfo:GetBoundKey(controlId) or ""
end

--
-- Set the value of the input control
--/
function BindingsUI_SetInputValue(controlId, controlValue)
		
	if(LazyLoadMode) then
	 	KeyBindInfo:Init()
	  LazyLoadMode = false
	end
	  
  if(controlId ~= nil) then
		KeyBindInfo:SetKeybind(controlValue, controlId)
		
		if(Client) then
   		ChangedKeybinds[#ChangedKeybinds+1]	= controlId
		end
  end  
end

--
-- Return data in linear array of config elements
-- controlId, "input", name, value
-- controlId, "title", name, instructions
-- controlId, "separator", unused, unused
--/
function BindingsUI_GetBindingsData()
   return KeyBindInfo:GetBindingDialogTable()   
end

--
-- Returns list of control ids and text to display for each.
--/
function BindingsUI_GetBindingsTranslationData()

    local bindingsTranslationData = {}

    for i = 0, 255 do
    
        local text = string.upper(string.char(i))
        
        -- Add special values (must match any values in 'defaults' above)
        for j = 1, table.count(specialKeys) do
        
            if(specialKeys[j][1] == text) then
            
                text = specialKeys[j][2]
                
            end
            
        end
        
        table.insert(bindingsTranslationData, {i, text})
        
    end
    
    local tableData = table.tostring(bindingsTranslationData)
    
    return bindingsTranslationData
    
end

--
-- Called when bindings is exited and something was changed.
--/
function BindingsUI_ExitDialog()
    
    Main.ReloadKeyOptions()
    
    if(#ChangedKeybinds ~= 0) then
    	if(Client) then
    		Main.SetOptionString("ChangedKeybinds", table.concat(ChangedKeybinds, "@"))
    		table.clear(ChangedKeybinds)
    	else
    		table.clear(ChangedKeybinds)
    		Main.SetOptionString("ChangedKeybinds", "")
    	end
    end
end
