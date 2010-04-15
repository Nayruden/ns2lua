class 'Door' (Actor)

Door.modelName = "models/misc/door/door.model"
Shared.PrecacheModel(Door.modelName)

Door.thinkInterval = 0.25
Door.State = enum { 'Open', 'Closed' }
Door.Activity = enum {'None', 'Animating', 'StayingOpen'}
Door.Behavior = enum {'Proximity', 'AlwaysOpen', 'AlwaysClosed'}

Door.networkVars = 
{
	touchRadius = "float",
	openTime 	= "float",
    behavior 	= "integer(1 to 3)",
	state 		= "predicted integer(1 to 2)",	
	activity 	= "predicted integer(1 to 3)",
	activityEnd = "predicted float"
}

function Door:OnInit()
	Actor.OnInit(self)
	self:SetModel(self.modelName)
	self:SetIsVisible(true)
	
	self.state = Door.State.Closed
	self.activity = Door.Activity.None
	self.activityEnd = 0
	
	self:SetNextThink(Door.thinkInterval)
end

function Door:OnLoad()
	Actor.OnLoad(self)

	self.behaviorType = tonumber(self.behaviorType)
	self.touchRadius  = tonumber(self.touchRadius)
	self.openTime     = tonumber(self.openTime)
end

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

function Door:TestProximity() 
	local player
	for key, value in pairs(PlayerClasses) do
		player = Server.FindEntityWithClassnameInRadius(value.mapName, self:GetOrigin(), self.touchRadius, nil)
		if (player ~= nil) then
			return true
		end
	end
	return false
end

function Door:OnThink()
	Actor.OnThink(self)
	
	local time = Shared.GetTime()    
	if (time > self.activityEnd) then
		if (self.activity == Door.Activity.Animating) then 				
			if (self.state == Door.State.Open) then -- If we are open, we need to stay open for a bit.
				self.activity = Door.Activity.StayingOpen
				self.activityEnd = time + self.openTime
			else
				self.activity = Door.Activity.None
			end				
		elseif (self.activity == Door.Activity.StayingOpen) then
			if (self:TestProximity()) then -- If someone is nearby, stay open longer
				self.activityEnd = time + self.openTime
			else
				self:Close()
			end
		elseif (self.state == Door.State.Closed) then
			if (self:TestProximity()) then
				self:Open()
			end
		end
	end
	
	self:SetNextThink(self.thinkInterval)
end

Shared.LinkClassToMap("Door", "door")
