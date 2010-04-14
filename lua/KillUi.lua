KillUI_KillerLog = {}
KillUI_KilledLog = {}

function KillUI_AddKill(killer, killed)
	table.insert(KillUI_KillerLog, 1, killer)
	table.insert(KillUI_KilledLog, 1, killed)
	Shared.Message("--KillUI 2--")	
	Shared.Message("Killer: " .. KillUI_KillerLog[1])
	Shared.Message("Killed: " .. KillUI_KilledLog[1])
	Shared.Message("--KillUI 3--")	
	Shared.Message("Killer: " .. KillUI_GetKiller(1))
	Shared.Message("Killed: " .. KillUI_GetKilled(1))
end

function KillUI_GetKiller(killID)
   return KillUI_KillerLog[ID]
end

function KillUI_GetKilled(killID)
   return KillUI_KilledLog[ID]
end

function KillUI_GetNumberOfKillsInLog()
   return table.getn(KillUI_KillerLog)
end
