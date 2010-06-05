
Script.Load("/lua/utility/SyncMixin.lua")

class 'Elevator' (Entity)

--decrease this value to reduce the jitter the player experances on an elevator but a low number will also mean 
--the server and clients will freeze for longer when creating a new Elevator
local HeightStepSize = 0.05

Elevator.networkVars = {  
	StartHeight = "float", --if Stopped == true this is the current height of the Elevator
	Goal = "float",
	StartTime = "float",
	Speed = "float",
	Stopped = "boolean",
	MinHeight = "float",
	MaxHeight = "float",
}

Elevator.FloorSocketModelPath = "models/props/refinery/refinery_elevator1_floorsockets.model"
Elevator.PistonSectionModelPath = "models/props/refinery/refinery_elevator1_pistons.model"
Elevator.PlatformModelPath = "models/props/refinery/refinery_elevator1_platform.model"
Elevator.StepModelPath = "models/props/refinery/refinery_catwalks_stairs_norails.model"

--

Shared.PrecacheModel(Elevator.FloorSocketModelPath)
Shared.PrecacheModel(Elevator.PistonSectionModelPath)
Shared.PrecacheModel(Elevator.PlatformModelPath)
Shared.PrecacheModel(Elevator.StepModelPath)

local FloorSocketHeight = 0.75

local PistonExtendDistance = 3.25
local UsablePistonHeight = 3.01

--these are negitive offsets
local PistonModelYOffset = 1.01
local PistonModelYOffset2 = 1.21 --includes the ratchet box section

local PlatformThickness = 0.63
local PlatformTopToBase = 0.82

local SocketlessEmbedYOffsetStyle1 = -0.01
local SocketlessEmbedYOffsetStyle2 = -0.08 -- the rims of the based moved below the surface of the platform

local DefaultMinPosition = FloorSocketHeight+PlatformTopToBase
local PistonOffsetFromPlatform = (PlatformThickness+PistonModelYOffset)

local EmptyCoordsArray = CoordsArray()

if(Server) then
	function ElevatorTest(player, maxposition, speed)
		local pos = player:GetOrigin()-Vector(2,0.02,0)
		local e = Server.CreateEntity("elevator", pos)

		if(maxposition) then
			e:SetMaxHeight(pos.y+tonumber(maxposition))
		end

		if(speed) then
			e.Speed = tonumber(speed)
		end
	end

	Event.Hook("Console_elevator", ElevatorTest)
	
	function DestroyAllElevator()

		local elevators = {}
		local elevatorEnt = nil

		repeat
       elevatorEnt = Shared.FindEntityWithClassname("elevator", elevatorEnt)
       table.insert(elevators, elevatorEnt)
    until elevatorEnt == nil
        
    for _,ele in ipairs(elevators) do
			Server.DestroyEntity(ele)
		end
	end

	Event.Hook("Console_removeelevators", DestroyAllElevator)
end


function Elevator:OnCreate()
	Entity.OnCreate(self)

	self.Stopped = true
	
	if(Server) then
		self.MinPosition = DefaultMinPosition
		self.Speed = 1.5
		self.DummyPlatformEntity = Server.CreateEntity("elevator_platform", Vector(0,0,0))
		
		
		self:SetPropagate(Entity.Propagate_Never)
	end

	if(Client) then
		SyncMixin.Init(self, {"StartTime", "StartHeight"})
	
		self.DummyPlatformEntity = Client.CreateEntity("elevator_platform", Vector(0,0,0))

		self.Platform = Client.CreateRenderModel()
		self.Platform:SetModel(Shared.GetModelIndex(Elevator.PlatformModelPath))
		self.Platform:SetIsVisible(false)
		
		self.PistonSections = {}
		self.FloorSocket = Client.CreateRenderModel()
		self.FloorSocket:SetModel(Shared.GetModelIndex(Elevator.FloorSocketModelPath))
		self.FloorSocket:SetIsVisible(false)
		
		self.Steps = Client.CreateRenderModel()
		self.Steps:SetModel(Shared.GetModelIndex(Elevator.StepModelPath))
		self.Steps:SetIsVisible(false)
		

		local Piston = Client.CreateRenderModel()
		Piston:SetModel(Shared.GetModelIndex(Elevator.PistonSectionModelPath))
		
		table.insert(self.PistonSections, Piston)
	end

	self.DummyPlatformEntity.Owner = self
end

function Elevator:OnDestroy()
	if(Client) then
		Client.DestroyRenderModel(self.Platform)
		Client.DestroyRenderModel(self.FloorSocket)
		Client.DestroyRenderModel(self.Steps)
		
		self.Step,self.FloorSocket,self.Platform = nil,nil,nil
		
		for i,sectionmodel in ipairs(self.PistonSections) do
			Client.DestroyRenderModel(sectionmodel)
		end
		self.PistonSections = nil
	end
	
	if(self.Phys) then
		
		for _,platformPosPhys in ipairs(self.Phys) do
			Shared.DestroyPhysicsModel(platformPosPhys)
		end

		self.Phys = nil
	end

	if(self.StepsPhys) then
		Shared.DestroyPhysicsModel(self.StepsPhys)
	end
end

function Elevator:OnLoad()

	if(self.MinHeight ~= nil) then
		self.MinHeight = tonumber(self.MinHeight)
	end

	if(self.MaxHeight ~= nil) then
		self.MaxHeight = tonumber(self.MaxHeight)
	end

	if(self.Speed ~= nil) then
		self.Speed = tonumber(self.Speed)
	end
end

function Elevator:SetOrigin(position)
	Entity.SetOrigin(self, position)

	self:OnOriginSet()
end

function Elevator:OnCoordsChanged()

	self.SocketY = self:GetOrigin().y

	local StepCoords = self:GetCoords()*Coords.GetTranslation(Vector(-1.2,0,6))
	
	if(Client) then
		self.FloorSocket:SetCoords(self:GetCoords())
		self.Steps:SetCoords(StepCoords)
	end

	if(self.StepsPhys) then
		Shared.DestroyPhysicsModel(self.StepsPhys)
	end

	self.StepsPhys = Shared.CreatePhysicsModel(Shared.GetModelIndex(Elevator.StepModelPath), StepCoords, EmptyCoordsArray)
	self.StepsPhys:SetGroup(0)

	self.PlatformCoords = Coords(self:GetCoords())
end

function Elevator:OnOriginSet()

	if(Server) then
	else
		if(self.PlatformHeight == nil) then
			self.PlatformHeight = self.SocketY+FloorSocketHeight+PlatformTopToBase
		end
	end
	
	self:OnCoordsChanged()
end

function Elevator:SetMinHeight(height)

	if(self.MaxHeight ~= nil and height > self.MaxHeight) then
		error("Elevator:SetMinHeight cannot set MinHeight larger than MaxHeight")
	end

	local oldminheight = self.MinHeight

	if(self.MinY ~= nil and height < self.MinY) then
		self.MinHeight = self.MinY
	else
		self.MinHeight = height
	end

	if(self.Stopped and self.StartHeight > height) then
		self.StartHeight = height
	end

	if(self.MaxHeight ~= nil) then
		self:OnMinMaxHeightChanged()
	end
end

function Elevator:SetMaxHeight(height)
	
	if(self.MinHeight ~= nil and height < self.MinHeight) then
		error("Elevator:SetMaxHeight cannot set MaxHeight smaller than MinHeight")
	end

	local oldmaxheight = self.MaxHeight
	self.MaxHeight = height

	if(self.Stopped) then
		if(self.StartHeight and self.StartHeight > height) then
			self.StartHeight = height
		end
	else
		if(self.Goal > height) then
			self.Goal = height
		end
	end
	
	if(self.MinHeight ~= nil) then
		self:OnMinMaxHeightChanged(nil, oldmaxheight)
	end
end


function Elevator:OnMinMaxHeightChanged(oldmin, oldmax)
	
	self:ReCreatePistonSections()
	
	if(oldmin or oldmax) then
		--TODO Handle this we can destroy the whole list but that will just leak memory
	else
		local Distance = self.MaxHeight-self.MinHeight
		
		local HeightPoints = Distance/HeightStepSize

		local coords = Coords(self.PlatformCoords)		
		local PlatformIndex = Shared.GetModelIndex(Elevator.PlatformModelPath)
		self.Phys = {}
		
		--pre allocate all 
		for i=0,HeightPoints do
			coords.origin.y = self.MinHeight+(i*HeightStepSize)

			local Phys = Shared.CreatePhysicsModel(PlatformIndex, coords, EmptyCoordsArray)
			Phys:SetEntity(self.DummyPlatformEntity)
			Phys:SetGroup(1) --so nothing collides with it at this stage
			
			self.Phys[i+1] = Phys
		end
	end
end

function Elevator:ReCreatePistonSections()

	if(Server) then
		return
	end

	local Distance = self.MaxHeight-self.MinHeight
	local SectionCount = math.ceil(Distance/UsablePistonHeight)

	if(#self.PistonSections > SectionCount) then
		
		for SectionI=#self.PistonSections,SectionCount do
			Client.DestroyRenderModel(self.PistonSections[SectionI])
			table.remove(self.PistonSections, SectionI)
		end
	else
		local PistonIndex = Shared.GetModelIndex(Elevator.PistonSectionModelPath)

		for SectionI=1,SectionCount do
			if(self.PistonSections[SectionI] == nil) then
				local Piston = Client.CreateRenderModel()
				Piston:SetModel(PistonIndex)
		
				table.insert(self.PistonSections, Piston)
			end
		end
	end
end

function Elevator:SetGoal(height)
	
	--fill in the default min/max heights if there not setup already
	if(not self.ValuesSetup) then
		self:OnSetupFinished()
	end

	self.Stopped = false

	if(self.PlatformHeight == nil) then
		self.StartHeight = self.MinHeight
		self.PlatformHeight = self.MinHeight
	else
		self.StartHeight = self.PlatformHeight
		if(height > self.MaxHeight) then
			height = self.MaxHeight
		elseif(height < self.MinHeight) then
			height = self.MinHeight
		end

		self.GoingDown = height < self.PlatformHeight
	end

	self.Goal = height
	self.StartTime = Shared.GetTime()
end

--returns true if the PlatformHeight changed
function Elevator:UpdatePlatformHeight()
	local ReachedGoal = false
	local Changed = false


	if(not self.Stopped) then
		local t = Shared.GetTime()-self.StartTime
		local MoveAmount = self.Speed*t

		if(self.GoingDown) then
			self.PlatformHeight = self.StartHeight-MoveAmount
			
			if(self.PlatformHeight <= self.Goal) then
				self.PlatformHeight = self.Goal
				ReachedGoal = true
			end
		else
			self.PlatformHeight = self.StartHeight+MoveAmount
	
			if(self.PlatformHeight >= self.Goal) then
				self.PlatformHeight = self.Goal
				ReachedGoal = true
			end
		end
		
		Changed = true
	else
		--this function will only be called after StartHeight has been set so its safe to depend on it here
		if(self.PlatformHeight == nil or self.PlatformHeight ~= self.StartHeight) then
			self.PlatformHeight = self.StartHeight
			Changed = true
		end
	end

	self.PlatformCoords.origin.y = self.PlatformHeight

	if(ReachedGoal) then
		self:OnStop()
	end

	return Changed
end

function Elevator:OnStop()
	self.Stopped = true

	if(Server) then
		self.StartHeight = self.Goal
		self.Goal = nil
		self.StartTime = nil
		
		self:SetNextThink(2)
	else
		
	end
end

function Elevator:OnThink()

	if(self.GoingDown) then
		self:SetGoal(self.MaxHeight)
	else
		self:SetGoal(self.MinHeight)
	end
end


function Elevator:OnSetupFinished()
	
	local valuechanged = false

	if(self.MinHeight == nil) then
		self.MinHeight = self.SocketY+self.MinPosition
		valuechanged = true
	end

	if(self.MaxHeight == nil) then
		self.MaxHeight = self.MinHeight+4
		valuechanged = true
	end

	if(valuechanged) then
		self:OnMinMaxHeightChanged()
	end

	self.ValuesSetup = true
	
	self:SetGoal(self.MaxHeight)

	self:SetPropagate(Entity.Propagate_Always)
end

function Elevator:OnUpdate()
	Entity.OnUpdate(self)

	if(Server and self.ValuesSetup == nil) then
		self:OnSetupFinished()
	end

	--don't do anything untill StartHeight gets synced to us from the server
	if(Client and self.StartHeight == nil) then
		return
	end

	if(self:UpdatePlatformHeight() or self.PhysIndex == nil) then
		if(self.PhysIndex ~= nil) then
			self.Phys[self.PhysIndex]:SetGroup(1)
		end
		
		local index = math.floor((self.PlatformHeight-self.MinHeight)/HeightStepSize)+1
		self.PhysIndex = index
		self.Phys[index]:SetGroup(0)
		

		self.PhysIndex = index
	end


--[[ or self.Phys == nil)then
		if(self.Phys) then
			--this leaks memory :(
			Shared.DestroyPhysicsModel(self.Phys)
			self.Phys = nil
		end

		self.Phys = Shared.CreatePhysicsModel(Shared.GetModelIndex(Elevator.PlatformModelPath), self.PlatformCoords, EmptyCoordsArray)
		self.Phys:SetEntity(self)
		self.Phys:SetGroup(0)
	end
]]--
	if(Client) then
		self.Platform:SetCoords(self.PlatformCoords)

		local PistonCoords = self:GetCoords()
		local StartingOffset = self.PlatformHeight-PistonOffsetFromPlatform

		for i,section in ipairs(self.PistonSections) do
			PistonCoords.origin.y = StartingOffset-((i-1)*PistonExtendDistance)
			section:SetCoords(PistonCoords)
		end
	end
end

--called by SyncMixin
function Elevator:OnFirstSyncReceived()
	self.PlatformHeight = self.StartHeight
	self:OnOriginSet()

	self:OnMinMaxHeightChanged()

	self.Platform:SetIsVisible(true)
	self.FloorSocket:SetIsVisible(true)
	self.Steps:SetIsVisible(true)
end

function Elevator:OnNetworkVarsChanged(ChangedValues)

	if(ChangedValues["StartTime"]) then
		if(self.StartTime ~= nil) then
			self.GoingDown = self.Goal < self.StartHeight
		end
	else
		
	end

	if(ChangedValues["MinHeight"] or ChangedValues["MaxHeight"]) then
		self:OnMinMaxHeightChanged(ChangedValues["MinHeight"] or self.MinHeight, ChangedValues["MaxHeight"] or self.MaxHeight)
	end
end

SyncMixin.Mixin(Elevator)

Shared.LinkClassToMap("Elevator", "elevator", Elevator.networkVars)

-- dummy 
class 'ElevatorPlatform' (Entity)

function ElevatorPlatform:OnCreate()
	self:SetPropagate(Entity.Propagate_Never)
end


Shared.LinkClassToMap("ElevatorPlatform", "elevator_platform",{})
