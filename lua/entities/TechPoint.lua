class 'TechPoint' (Actor)

TechPoint.modelName = "models/misc/tech_point/tech_point.model"
Shared.PrecacheModel(TechPoint.modelName)

function TechPoint:OnInit()
	Actor.OnInit(self)
	self:SetModel(self.modelName)
	self:SetIsVisible(true)
end

Shared.LinkClassToMap("TechPoint", "tech_point")