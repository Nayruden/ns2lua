class 'BuildBotPlayer' (Player)

PlayerClasses.buildbot = BuildBotPlayer

BuildBotPlayer.modelName              = "models/marine/build_bot/build_bot.model"
Shared.PrecacheModel(BuildBotPlayer.modelName)
Shared.PrecacheModel(BuildBotPlayer.modelName)
BuildBotPlayer.extents                = Vector(0.4064, 0.7874, 0.4064)
BuildBotPlayer.jumpHeight             =  1.5
BuildBotPlayer.gravity                = -4.4
BuildBotPlayer.normal_walkSpeed       = 7
BuildBotPlayer.normal_sprintSpeed     = 14
BuildBotPlayer.backSpeedScale         = 1
BuildBotPlayer.defaultHealth          = 100
BuildBotPlayer.WeaponLoadout          = { "weapon_peashooter" }
BuildBotPlayer.TauntSounds            = { "sound/ns2.fev/marine/voiceovers/robot_taunt" }
BuildBotPlayer.stoodViewOffset          = Vector(0, 0.6, 0)
BuildBotPlayer.crouchedViewOffset       = Vector(0, 0.6, 0)
for i = 1, #BuildBotPlayer.TauntSounds do
    Shared.PrecacheSound(BuildBotPlayer.TauntSounds[i])
end

function BuildBotPlayer:OnInit()
    
    Player.OnInit(self)
	
    self:SetBaseAnimation("fly", true)
end

function BuildBotPlayer:OnSetBaseAnimation(activity)
    return  nil,
            false
end

function BuildBotPlayer:GetCanJump(input, ground, groundNormal)
    return true
end

function BuildBotPlayer:OnJump(input, forwardAxis, sideAxis)
    self.velocity.x = self.velocity.x + forwardAxis.x*10
    self.velocity.z = self.velocity.z + forwardAxis.z*10
end

BuildBotPlayer.mapName = "buildbotplayer"
Shared.LinkClassToMap("BuildBotPlayer", "buildbotplayer", BuildBotPlayer.networkVars )

