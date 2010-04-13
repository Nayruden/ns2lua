-- ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Globals.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

kPlayerReadyRoomSpawn                   = "ready_room_start"
kPlayerSpawn                            = "player_start"
kPlayerTeamLocation                     = "team_location"

kGamerulesMapName                    = "gamerules"
kLightMapName                        = "light"
kSpotLightMapName                    = "light_spot"
kEnvLightMapName                     = "environment_light"
kBuildBotMapName                     = "buildbot"
kBuildBotMineMapName                 = "buildbot_mine"
kPlayerMapName                       = "player"
kSpectatorMapName                    = "spectator"
kRagdollMapName                      = "ragdoll"
kScriptActorMapName                  = "scriptactor"
kOrderableScriptActorMapName         = "orderablescriptactor"
kWeaponMapName                       = "weapon"
kHudModelMapName                     = "hudmodel"
kMarineHudMapName                    = "marinehud"
kResourceTowerMapName                = "resourcetower"
kExtractorMapName                    = "extractor"
kObservatoryMapName                  = "observatory"
kRoboticsFactoryMapName              = "roboticsfactory"
kWeaponsModuleMapName                = "weaponsmodule"
kPrototypeModuleMapName              = "prototypemodule"

kHarvesterMapName                    = "harvester"
kCragMapName                         = "crag"
kWhipMapName                         = "whip"
kShiftMapName                        = "shift"
kShadeMapName                        = "shade"
kResourcePointMapName                = "resource_point"
kTechPointMapName                    = "tech_point"
kCommandStructureMapName             = "commandstructure"
kCommandStationMapName               = "commandstation"
kCommandStationLevel1MapName         = "commandstationl1"
kCommandStationLevel2MapName         = "commandstationl2"
kCommandStationLevel3MapName         = "commandstationl3"
kArmoryMapName                       = "armory"
kInfantryPortalMapName               = "infantryportal"
kMarineBuildHealthMapName            = "buildhealth"
kUpgradedInfantryPortalMapName       = "upginfantryportal"

kMASCMapName                         = "masc"
kSentryMapName                       = "sentry"
kPowerGridNodeMapName                = "power_grid_node"
kMedPackMapName                      = "medpack"
kAmmoPackMapName                     = "ammopack"
kCatPackMapName                      = "catpack"
kPistolMapName                       = "pistol"
kRifleMapName                        = "rifle"
kMinigunMapName                      = "minigun"
kDualMinigunMapName                  = "dualminigun"
kFlamethrowerMapName                 = "flamethrower"
kShotgunMapName                      = "shotgun"
kAxeMapName                          = "axe"
kWelderMapName                       = "welder"
kGrenadeLauncherMapName              = "grenadelauncher"
kWelderMapName                       = "welder"
kJetpackMapName                      = "jetpack"
kExoskeletonMapName                  = "exoskeleton"
kBuildableStructureMapName           = "buildable"
kPoweredStructureMapName             = "powered"
kTechTreeMapName                     = "techtree"
kTechNodeMapName                     = "technode"
kStructureMapName                    = "structure"
kHiveMapName                         = "hive"
kHiveLevel1MapName                   = "hivel1"
kHiveLevel2MapName                   = "hivel2"
kHiveLevel3MapName                   = "hivel3"
kEggMapName                          = "egg"
kDrifterMapName                      = "drifter"
kInfestNodeMapName                   = "infestnode"
kInfestationMapName                  = "infestation"
kHydraMapName                        = "hydra"
kAlienSpawnMapName                   = "alienspawn"
kDoorMapName                         = "door"
kReverbMapName                       = "reverb"
kLocationMapName                     = "location"
kParticlesMapName                    = "particles"
kProjectileMapName                   = "projectile"
kCanalMapName                        = "canal"

kMarineMapName                       = "marine"
kAlienMapName                        = "alien"
kCommanderMapName                    = "commander"
kMarineCommanderMapName              = "marine_commander"
kAlienCommanderMapName               = "alien_commander"
kEmbryoMapName                       = "embryo"
kSkulkMapName                        = "skulk"
kGorgeMapName                        = "gorge"
kLerkMapName                         = "lerk"
kFadeMapName                         = "fade"
kOnosMapName                         = "onos"

kBiteMapName                         = "bite"
kSpitMapName                         = "spit"
kHealthSprayMapName                  = "health_spray"
kChamberAbilityMapName               = "chamber"
kSpikesMapName                       = "spikes"
kSporesMapName                       = "spores"

-- Team numbers - corresponds with teamNumber in editor_setup.xml
kNeutralTeamType = 0
kMarineTeamType = 1
kAlienTeamType = 2
kRandomTeamType = 3

-- Initial class when joining a team
kMarineSpawnClass                       = kMarineMapName
kAlienSpawnClass                        = kSkulkMapName

-- Team colors 
kMarineTeamColor = 0x4DB1FF
kAlienTeamColor = 0xFFCA3A
kNeutralTeamColor = 0xEEEEEE
kChatTextColor = 0xDDDDDD

-- Team indices
kTeamInvalid = -1
kTeamReadyRoom = 0
kTeam1Index = 1
kTeam2Index = 2
kSpectatorIndex = 3

-- Marines vs. Aliens
kTeam1Type = kMarineTeamType
kTeam2Type = kAlienTeamType

-- Used for playing team and scoreboard
kTeam1Name = "Frontiersmen"
kTeam2Name = "Kharaa"
kSpectatorTeamName = "Ready room"
kDefaultPlayerName = "NsPlayer"

-- Weapon slots (marine only)
kPrimaryWeaponSlot = 1
kSecondaryWeaponSlot = 2
kTertiaryWeaponSlot = 3

-- Damage types - keep very simple
kGenericDamageType = 0
kMeleeDamageType = 1
kProjectileDamageType = 2
kAirDamageType = 3

-- Player modes. When outside the default player mode, input isn't processed from the player
kDefaultMode = 0
kTauntMode = 1
kGorgeStructureMode = 2
kGorgeStartArmorMode = 3
kGorgeArmorMode = 4
kGorgeEndArmorMode = 5
-- transitioning to sliding
kGorgeStartSlideMode = 6
-- sliding
kGorgeSlidingMode = 7
-- transitioning from sliding
kGorgeEndSlideMode = 8

-- For components that are purely visual and should never interfere (resource display)
kLowestZ = -2

-- Commander input, marquee when not active
kCommanderInput = -1

-- Default
kNormalZ = 0

-- Logout button
kHighPriorityZ = 1

-- Scroll components (should be higher priority then all other static components so we always pan)
kScrollZ = 2

-- Marquee while active, to ensure we get mouse release event even if on top of other component
kHighestPriorityZ = 3

-- How often to compute LOS visibility for entities (seconds)
kLOSUpdateInterval = .5

-- How often to send kills, deaths, nick name changes, etc. for scoreboard
kScoreboardUpdateInterval = .5

-- How often to send ping updates
kUpdatePingsInterval = 1.25

-- How often to send client ping up to server
kClientPingUpdateInterval = 2

-- How often blips sent to alien players
kHiveSightUpdateInterval = 2.0
kBlipTypeUndefined = -1
kBlipTypeSighted = 0
kBlipTypeFriendly = 2
kBlipTypeFriendlyUnderAttack = 3
kBlipTypeHive = 6

-- Flash player indices
kSharedFlashIndex = 1
-- Use for marine, skulk, gorge, Commander, etc. specific flash UI
kClassFlashIndex = 2
-- Used for menu on top of class 
kMenuFlashIndex = 3

-- Fade to black time (then to spectator mode)
kFadeToBlackTime = 2

-- Constant to prevent z-fighting 
kZFightingConstant = 0.001

-- Fade blink mode (used for trying different methods)
-- 1 = billiards
-- 2 = billiards but using velocity and minimum velocity
-- 3 = spec/flying
-- 4 = flying bouncing with fixed start direction
kFadeBlinkMode = 3

-- libswf's default for the flash "undefined" value
kLibSwfUndefined = 2147483648

-- Max players allowed in game
kMaxPlayers = 32

-- Max distance to propagate entities with
kMaxRelevancyDistance = 40

-- Options keys
kNicknameOptionsKey = "nickname"
kVisualDetailOptionsKey = "visualDetail"
kSoundVolumeOptionsKey = "soundVolume"
kMusicVolumeOptionsKey = "musicVolume"
kFullscreenOptionsKey = "graphics/display/fullscreen"
kDisplayQualityOptionsKey = "graphics/display/quality"

kGraphicsXResolutionOptionsKey = "graphics/display/x-resolution"
kGraphicsYResolutionOptionsKey = "graphics/display/y-resolution"

kMouseSensitivityScalar         = 50

-- Sayings
--kSayingsMenu = enum( { 'Needs', 'Orders', 'Animations' } )
--kSaying = enum({ 'MedPack', 'Ammo', 'Order' })



