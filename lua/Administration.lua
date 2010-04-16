
function GetAllPlayers()
    return Shared.FindEntities(GetPlayerClassMapNames())
end

if (Server) then
    -- You can change stuff in these tables if you know what you're doing
    A_AccessGroups = { -- up to eight groups (can be extended later)
        -- Please note that this list is NOT in linear order
        -- You can be an admin and a user, but not a creator. There a number of combinations.
        user    = bit.lshift(1, 0), -- everyone is in this group (not having this is like being banned (you're stuck in the ready room))
        creator = bit.lshift(1, 1), -- can spawn and destroy stuff like turrets and targets
        
        admin   = bit.lshift(1, 6), -- can administrate (kick, ban, grant access, etc)
        
        god     = bit.lshift(1, 7), -- this is for the host (no touchies or you'll deny yourself access!)
        all     = 0xFF, -- IGNORE THIS
    }
    -- Be very careful with this table, it's for Lua coders only!
    A_ConCommands = {
        who = {
            access = A_AccessGroups.all, -- everyone
            run = function(clientObj, ply, args)
                local str, plys == "- ID  GROUPS  NAME", GetAllPlayers()
                for i, ply in ipairs(plys) do
                    local clientObj = A_ClientStore[ply.controller]
                    local groupStr = ""
                    
                    str = str..ply.controller.."  "..
                    if i ~= #plys then
                        str = trs.."\n"
                    end
    }
    
    -- Don't touch stuff below here
    function A_HasAccess(ply_or_group, group)
        return bit.and(type(ply_or_group) == "userdata" and A_ClientStore[ply_or_group.controller].access or ply_or_group, group) > 0
    end
    function A_GrantAccess(ply, group)
        local clientObj = A_ClientStore[ply_or_group.controller]
        clientObj.access = bit.bor(clientObj.access, group)
    end
    function A_RevokeAccess(ply, group)
        local clientObj = A_ClientStore[ply_or_group.controller]
        clientObj.access = bit.bxor(clientObj.access, group)
    end
    function A_RegisterConCommand(name, data)
        A_ConCommands[name] = data
    end
end

