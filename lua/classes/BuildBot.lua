class 'BuildBot' (Player)

PlayerClasses.BuildBot = BuildBot

BuildBot.modelName              = "models/marine/build_bot/build_bot.model"
Shared.PrecacheModel(BuildBot.modelName)
BuildBot.extents                = Vector(0.4064, 0.7874, 0.4064)
BuildBot.jumpHeight             =  1.5
BuildBot.gravity                = -4.4
BuildBot.normal_walkSpeed       = 7
BuildBot.normal_sprintSpeed     = 14
BuildBot.backSpeedScale         = 1
BuildBot.defaultHealth          = 100
BuildBot.WeaponLoadout          = { "weapon_peashooter" }
BuildBot.TauntSounds            = { "sound/ns2.fev/marine/voiceovers/robot_taunt" }
for i = 1, #BuildBot.TauntSounds do
    Shared.PrecacheSound(BuildBot.TauntSounds[i])
end

function BuildBot:OnInit()
    
    Player.OnInit(self)
    
    self:SetModel(BuildBot.modelName)
	
    self:SetBaseAnimation("fly", true)
end

function BuildBotPlayer:OnJump(input, forwardAxis, sideAxis)
    self.velocity.x = self.velocity.x + forwardAxis.x*10
    self.velocity.z = self.velocity.z + forwardAxis.z*10
end

Shared.LinkClassToMap("BuildBot", "marineplayer", BuildBot.networkVars )

