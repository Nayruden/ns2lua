SyncMixin = {}
local FakeNil = {}

function SyncMixin.Mixin(classtable)
	classtable.Orignal_OnSynchronized = classtable.OnSynchronized
	classtable.OnSynchronized = SyncMixin.OnSynchronized
end

function SyncMixin.Init(self, networkVaribleTable)
	
	if(Server) then
		return
	end
	
	self.SyncNumber = 0
	self.FakeNil = FakeNil
	self.SyncMixin_CurrentValues = {}
	self.SyncMixin_PrevChangedValues = {}

	local networkvars = networkVaribleTable or self.networkVars

	if(networkvars == nil) then
		error("SyncMixin:Mixin networkVaribleTable can only be null if self.networkVars exists")
	end

	--convert the networkvars table into an array if an hashtable got passed in
	if(networkvars[1] == nil) then
		self.SyncMixin_NetworkVars = {}

		for name,_ in pairs(networkvars) do
			table.insert(self.SyncMixin_NetworkVars, name)
		end
	else
		self.SyncMixin_NetworkVars = networkvars
	end

	for _,varname in ipairs(self.SyncMixin_NetworkVars) do
		self.SyncMixin_CurrentValues[varname] = self[varname] or FakeNil
	end
end

function SyncMixin:OnSynchronized()

	if(self.Orignal_OnSynchronized and (Server or self.PreCallReal)) then
		self:Orignal_OnSynchronized()
	end

	if(Client) then
		local CurrentValues = self.SyncMixin_PrevChangedValues
		local OldValues = self.SyncMixin_CurrentValues

		self.SyncMixin_CurrentValues = CurrentValues
		self.SyncMixin_PrevChangedValues = OldValues

		for varname,_ in pairs(self.SyncMixin_NetworkVars) do
			local value = self[varname] or FakeNil
			CurrentValues[varname] = value

  		--nil out any values that havn't changed
			if(value == OldValues[varname]) then
				OldValues[varname] = nil
			end
		end
  	
		if(self.SyncNumber == 0) then
			if(self.OnFirstSyncReceived) then
				self:OnFirstSyncReceived(OldValues)
			end
		else
			self:OnNetworkVarsChanged(OldValues)
		end
	end

	if(self.Orignal_OnSynchronized and not self.PreCallReal) then
		self:Orignal_OnSynchronized()
	end
	
	self.SyncNumber = self.SyncNumber+1
end
