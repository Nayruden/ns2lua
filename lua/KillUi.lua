KillUI_KillLog = { }

function KillUI_AddKill(killer, killed)
	table.insert(KillUI_KillLog, 1, {		
		attacker=killer, 
		victim=killed
	});
end

function KillUI_GetKiller(ID)
   return KillUI_KillLog[ID].attacker
end

function KillUI_GetKilled(ID)
   return KillUI_KillLog[ID].victim
end

function KillUI_GetNumberOfKillsInLog()
   return table.getn(KillUI_KillLog)
end
