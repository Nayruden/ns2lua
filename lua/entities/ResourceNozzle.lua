class 'ResourceNozzle' (Actor)

ResourceNozzle.modelName = "models/misc/resource_nozzle/resource_nozzle.model"
Shared.PrecacheModel(ResourceNozzle.modelName)

function ResourceNozzle:OnInit()
	Actor.OnInit(self)
	self:SetModel(self.modelName)
	self:SetIsVisible(true)
end

Shared.LinkClassToMap("ResourceNozzle", "resource_point")