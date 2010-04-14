class 'Door' (Actor)

Door.modelName = "models/misc/door/door.model"
Shared.PrecacheModel(Door.modelName)

Door.thinkInterval = 0.25
Door.State = enum { 'Open', 'Closed' }
Door.Activity = enum {'None', 'Animating', 'StayingOpen'}
Door.animTime = 1

function Door:OnInit()
	Actor.OnInit(self)
	self:SetModel(self.modelName)
	self:SetIsVisible(true)
	
	if (Server) then		
		self:SetNextThink(Door.thinkInterval)
    end    
end


function Door:OnLoad()
    Actor.OnLoad(self)

    self.behaviorType = tonumber(self.behaviorType)
    self.touchRadius  = tonumber(self.touchRadius)
end

if (Server) then
	function Door:Open() 
		self.state = Door.State.Open
		self.activity = Door.Activity.Animating
		self.activityEnd = Shared.GetTime() + self:GetAnimationLength( "open" )
		self:SetAnimation( "open" )
	end

	function Door:Close() 
		self.state = Door.State.Closed
		self.activity = Door.Activity.Animating
		self.activityEnd = Shared.GetTime() + self:GetAnimationLength( "close" )	
		self:SetAnimation( "close" )
	end

	function Door:Idle() 
		if (self.state == Door.State.Closed) then
			self:SetAnimation( "closed" )
		else
			self:SetAnimation( "opened" )
		end
	end

	function Door:TestProximity() 
		local player
		player = Server.FindEntityWithClassnameInRadius("player", self:GetOrigin(), self.touchRadius, nil)
		if (player ~= nil) then
			return true
		end
		return false
	end
	
	function Door:OnThink()
		Actor.OnThink(self)
    	
		if (self:TestProximity()) then
			self:Open()
		else
			self:Close()
		end
		
        self:SetNextThink(self.thinkInterval)
    end
end

Shared.LinkClassToMap("Door", "door")
