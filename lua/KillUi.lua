function KillUI_GetKiller(killID)
    return Kill.instance:GetKillerFromLog(killID)
end

function KillUI_GetKilled(killID)
    return Kill.instance:GetKilledFromLog(killID)
end

function KillUI_GetNumberOfKillsInLog()
    return Kill.instance:GetNumberOfKillsInLog()
end