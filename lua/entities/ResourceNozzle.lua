class 'ResourceNozzle' (Entity)

ResourceNozzle.modelName = "models/misc/resource_nozzle/resource_nozzle.model"
function ResourceNozzle:OnInit()
	self.model = ResourceNozzle.modelName
	--PropDynamic.OnLoad(self)
	Shared.Message("I'm alive")
end

Shared.LinkClassToMap("ResourceNozzle", "resource_point")