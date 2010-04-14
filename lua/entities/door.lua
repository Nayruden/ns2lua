class 'Door' (Actor)

Door.modelName = "models/misc/door/door.model"
Shared.PrecacheModel(Door.modelName)

Door.thinkInterval = 0.25
Door.State = enum { 'Open', 'Closed' }
Door.Activity = enum {'None', 'Opening', 'Closing'}

function Door:OnInit()
	Actor.OnInit(self)
    self:SetAnimation( "closed" )
	self:SetModel(self.modelName)
	self:SetIsVisible(true)
	
	self.State = Door.State.Closed
	self.Activity = Door.Activity.None
	self.activityEnd = 0
	
	if (Server) then
        self:SetNextThink(Target.thinkInterval)
    end    
end

function Door:OnLoad()
    Actor.OnLoad(self)

    self.behaviorType = tonumber(self.behaviorType)
    self.touchRadius  = tonumber(self.touchRadius)

end

if (Server) then
	function Door:OnThink()
    
        Actor.OnThink(self)
	--[[	
    	local time = Shared.GetTime()    
		if (self.Activity ~= Door.Activity.None and time > self.activityEnd and ) then
			self.Activity = Door.Activity.None
		else
			return 
		end
		
		if (self.State == Door.State.Closed) then
			
			
		end
	
    
			
		
        if (self.state == Target.State.Unpopped) then
        
            local time = Shared.GetTime()
        
            if (self.popupTime ~= 0 and time > self.popupTime) and Server.targetsEnabled == true then
                self:Popup()
            else
            
                local player = Server.FindEntityWithClassnameInRadius("player", self:GetOrigin(), self.popupRadius, nil)
                
                if (player ~= nil) then
                    -- Trigger a popup in the future (with the mean being the specfied delay).
                    self.popupTime = time + Shared.GetRandomFloat(0, self.popupDelay * 2)
                end
                
            end
            
        end
        
        if (self.state == Target.State.Killed and Game.instance:GetGameTime() > self.NextRespawn ) then
            local player = Server.FindEntityWithClassnameInRadius("player", self:GetOrigin(), self.popupRadius, nil)                
			
			if (player ~= nil) then
				-- Wait until the player leaves
				self.NextRespawn = Game.instance:GetGameTime() + 5
            else
				local target = Server.CreateEntity( "target",  self:GetOrigin() )
				target:SetAngles( self:GetAngles() )
				self.state = Target.State.Respawned			
			end
			
      	end         	
        
        self:SetNextThink(Target.thinkInterval)
]]
    end
end
	
Shared.LinkClassToMap("Door", "door")