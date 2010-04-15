--=============================================================================
--
-- RifleRange/Game.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
-- This file contains the Game class  which handles the rules for the game.
-- This class derives from entity to take advantage of the networking and
-- synchronization facilities of the engine.
--
--=============================================================================

class 'Game' (Entity)

Game.updateInterval = 1
Game.networkVars =
    {
        startTime = "float",
    }

--
-- Returns a table of all the entities in the world with the specified class name.
--/
function GetEntitiesWithClassname(className)

    local entities = { }
    local startEntity = nil

    repeat

        startEntity = Shared.FindEntityWithClassname(className, startEntity)

        if (startEntity ~= nil) then
            table.insert(entities, startEntity)
        end

    until (startEntity == nil)

    return entities

end

function Game:OnInit()

    Entity.OnInit(self)

    Game.instance = self
	self.delete_queue = {}
	
    if (Server) then

        -- Make the game always propagate to all clients (no visibility checks).
        self:SetPropagate(Entity.Propagate_Always)
        self:SetNextThink(self.updateInterval)

        -- Get all of the target spawn points in the level.
        self.targetSpawns = GetEntitiesWithClassname("target_spawn")
        self.numTargets = 0

    end

    self.startTime = 0

    if (Client) then
        Shared.ConsoleCommand( "nick " .. Main.GetDefaultPlayerName() )
    end

end

--
-- Returns the number of seconds that have elapsed since the game started.
-- Note this can be negative if the game hasn't started yet.
--/
function Game:GetGameTime()

    if (self.startTime ~= 0) then
        return Shared.GetTime() - self.startTime
    else
        return 0
    end

end

--
-- Returns true if the game has started. The game does not immediately start,
-- there is an initial countdown period.
--/
function Game:GetHasGameStarted()
    return self:GetGameTime() > 0
end

if (Server) then

    function Game:StartGame()

        -- Start the game in 5 seconds.
        if (self.startTime == 0) then
            self.startTime = Shared.GetTime() + 5
        end


    end

    function Game:OnThink()

        if (self.startTime > 0 and Shared.GetTime() > self.startTime) then

            -- Popup any targets based on spawns.

            local numTargetSpawns = table.maxn(self.targetSpawns)

            if (self.numTargets == 0 and numTargetSpawns > 0) then

                -- Create new targets.

                local spawnIndex  = math.random(1, numTargetSpawns)
                local spawnOrigin = self.targetSpawns[spawnIndex]:GetOrigin()
                local spawnAngles = self.targetSpawns[spawnIndex]:GetAngles()

                local target = Server.CreateEntity( "target",  spawnOrigin )
                target:SetAngles( spawnAngles )
                target:Popup()

                self.numTargets = 1

            end

        end
		
		--Destroy any queued entities
		local time = Shared.GetTime()
		for i = #self.delete_queue,1,-1 do
			if (time > self.delete_queue[i].DeleteTime) then
				Server.DestroyEntity(self.delete_queue[i].Entity)
				table.remove(self.delete_queue, i)
			end
		end
	
        self:SetNextThink(self.updateInterval)

    end

    --
    -- * Destroys the specified target.
    -- */
    function Game:DestroyTarget(player, target)

        self.numTargets = self.numTargets - 1

    end

end

Shared.LinkClassToMap("Game", "game", Game.networkVars)
