//=============================================================================
//
// RifleRange/Target.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

class 'Target' (Actor)

Target.modelName  = "models/misc/target/target.model"
Target.spawnSound = "sound/ns2.fev/marine/structures/armory_open"
Target.dieSound   = "sound/ns2.fev/marine/common/health"

Shared.PrecacheModel(Target.modelName)

Shared.PrecacheSound(Target.spawnSound)
Shared.PrecacheSound(Target.dieSound)

Target.State = enum { 'Unpopped', 'Popped', 'Killed', 'Respawned' }

Target.thinkInterval = 0.25
Target.respawnInterval = 1
Target.networkVars = 
    {
        impulsePosition  = "vector",
        impulseDirection = "vector",
    }

function Target:OnInit()
	self.NextRespawn = 0
    Actor.OnInit(self)
    
	//self:SetModel(self.modelName)
    //self:SetAnimation( "idle" )
	
    self.impulsePosition  = Vector(0, 0, 0)
    self.impulseDirection = Vector(0, 0, 0)
    
    if (Client) then    
        // Don't collide with the player (once we're physically simulated)
        // since the simulation is different on the server and client.
        self.physicsGroup = 1
    end
    
    if (Server) then
        
        self.popupTime  = 0
		self.popupRadius  = 393.7
		self.popupDelay = 0
		
        self.state      = Target.State.Unpopped
        
        self:SetNextThink(Target.thinkInterval)
        
    end
    
end

function Target:OnLoad()
    Actor.OnLoad(self)

    self.popupRadius = tonumber(self.popupRadius)
    self.popupDelay  = tonumber(self.popupDelay)

end

function Target:Popup()
    
    self:SetModel(self.modelName)
    self:SetAnimation( "popup" )
    
    self:PlaySound(self.spawnSound)
    
    self.state = Target.State.Popped
    
end

if (Client) then

    function Target:TakeDamage(attacker, damage, doer, point, direction)
     
        // Push the physics model around on the client when we shoot it.
        // This won't affect the model on other clients, but it's just for
        // show anyway (doesn't affect player movement).
        if (self.physicsModel ~= nil) then
            self.physicsModel:AddImpulse(point, direction * 0.01)
        end
        
    end

end

if (Server) then

    function Target:TakeDamage(attacker, damage, doer, point, direction)
        
        if (self.state == Target.State.Popped) then
        
            self:PlaySound(self.dieSound)
            
            self.state = Target.State.Killed
            
            // Inform the game that a target was destroyed so that points
            // can be awarded, etc.
            Game.instance:DestroyTarget(attacker, self)
			self.NextRespawn = Game.instance:GetGameTime() + 30
            
            // Create a rag doll.
            self:SetPhysicsActor()
            
            // Give the target an impulse at the kill location to make it
            // fly around a bit.
            self.impulsePosition  = point
            self.impulseDirection = direction
            
            self:SetNextThink(Target.respawnInterval)
            
        end
        
    end

    function Target:OnThink()
    
        Actor.OnThink(self)
        
        if (self.state == Target.State.Unpopped) then
        
            local time = Shared.GetTime()
        
            if (self.popupTime ~= 0 and time > self.popupTime) and Server.targetsEnabled == true then
                self:Popup()
            else
            
                local player = Server.FindEntityWithClassnameInRadius("player", self:GetOrigin(), self.popupRadius, nil)
                
                if (player ~= nil) then
                    // Trigger a popup in the future (with the mean being the specfied delay).
                    self.popupTime = time + Shared.GetRandomFloat(0, self.popupDelay * 2)
                end
                
            end
            
        end
        
        if (self.state == Target.State.Killed and Game.instance:GetGameTime() > self.NextRespawn ) then
            local player = Server.FindEntityWithClassnameInRadius("player", self:GetOrigin(), self.popupRadius, nil)                
			
			if (player ~= nil) then
				// Wait until the player leaves
				self.NextRespawn = Game.instance:GetGameTime() + 5
            else
				local target = Server.CreateEntity( "target",  self:GetOrigin() )
				target:SetAngles( self:GetAngles() )
				self.state = Target.State.Respawned			
			end
			
      	end         	
        
        self:SetNextThink(Target.thinkInterval)

    end
    
end

if (Client) then

    /**
     * Called when the network variables for the actor are updated from values
     * from the server.
     */
    function Target:OnSynchronized()
    
        // Apply the impulse if we haven't created the physics model yet.
        local applyImpulse = (self.physicsModel == nil)
    
        Actor.OnSynchronized(self)
        
        // Apply the impulse to the new physics model.
        if (applyImpulse and self.physicsModel ~= nil) then
            self.physicsModel:AddImpulse(self.impulsePosition, self.impulseDirection * 0.2)
        end
        
        
    end
    
end

Shared.LinkClassToMap("Target", "target", Target.networkVars )
