-- ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Balance.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

-- INTEGER VALUES
kArmoryCost = 10
kArmoryHealAmount = 20
kBaseBuildableDefaultHealth = 500
kBaseBuildableDefaultArmor = 250
kBlinkMode1Length = 10
kBuildBotCost = 4
kBuildBotHealth = 200
kBuildBotArmor = 50
kBuildBotMoveSpeed = 4
kBuildBotHoverHeight = 1.5
kBuildBotStartDistance = 3
kBuildDistance = 75
kBuildBotWeldDistance = 1
kBuyDistance = 200
kCommandStationCost = 25
kCommandStationHealth = 1000
kCommandStationBuildTime = 30
kCommandStationLevel2ResearchTime = 60
kCommandStationLevel3ResearchTime = 120
kMASCSplashTechResearchTime = 30
kMASCSplashTechResearchCost = 20
kMASCArmorTechResearchCost = 20
kMASCArmorTechResearchTime = 30 
kTechMinesResearchCost = 10
kTechMinesResearchTime = 20
kTechEMPResearchCost = 10
kTechEMPResearchTime = 20
kJetpackTechResearchCost = 20
kJetpackTechResearchTime = 60
kJetpackFuelTechResearchCost = 20
kJetpackFuelTechResearchTime = 60
kJetpackArmorTechResearchCost = 20
kJetpackArmorTechResearchTime = 60
kExoskeletonTechResearchCost = 20
kExoskeletonTechResearchTime = 60
kExoskeletonLockdownTechResearchCost = 20
kExoskeletonLockdownTechResearchTime = 60
kExoskeletonUpgradeTechResearchCost = 20
kExoskeletonUpgradeTechResearchTime = 60
kFlamethrowerTechResearchCost = 20
kFlamethrowerTechResearchTime = 60
kFlamethrowerAltTechResearchCost = 20
kFlamethrowerAltTechResearchTime = 60
kNerveGasTechResearchCost = 20
kNerveGasTechResearchTime = 60
kDualMinigunTechResearchCost = 20
kDualMinigunTechResearchTime = 60
kScanCost = 10
kDistressBeaconCost = 10
kBuildBotMineCost = 5
kDefaultFOV = 90
kDefaultStructureCost = 10
kStructureCircleRange = 4
kWeapons1ResearchCost = 10
kWeapons2ResearchCost = 20
kWeapons3ResearchCost = 30
kArmor1ResearchCost = 10
kArmor2ResearchCost = 20
kArmor3ResearchCost = 30
kWeapons1ResearchTime = 10
kWeapons2ResearchTime = 20
kWeapons3ResearchTime = 30
kArmor1ResearchTime = 10
kArmor2ResearchTime = 20
kArmor3ResearchTime = 30
kCatPackTechResearchCost = 10
kCatPackTechResearchTime = 15
kObservatoryHealth = 500
kRoboticsFactoryHealth = 1500
kEggCost = 0
kEggSpawnTime = 10
kCanalCost = 5
kInfantryPortalCost = 10
kInfantryPortalUpgradeCost = 10
kPhaseTechResearchCost = 15
kInfantryPortalSpawnTime = 8
kInfantryPortalUpgradeResearchTime = 20
kInfestCost = 10
kInfestNodeMoveSpeed = .8
-- 128 units
kInfestationSize = 3.25
kRifleCost = 5
kRifleUpgradeCost = 10
kPistolCost = 5
kRecycleMetalReward = 5
kTooltipDisplayTime = 6
kTooltipHelpInterval = 1
kTooltipHelpEntityRadius = 4
kTooltipHelpImportantInterval = 10
kUnitMaxLOSDistance = 30
kUnitMinLOSDistance = 8

kJetpackCost = 15
kExoskeletonCost = 20

-- Balanced for ~15 minute game with 1 node, 7.5 minutes with 2, 5 minutes with 3
kResourceTowerResourceInterval = 4
kUpgradedExtractorResourceInterval = 1
kResourceTowerNaniteInjection = 1
kResourceTowerMetalInjection = 1
kObliterateVictoryMetalNeeded = 500

kShotgunCost = 15
kShotgunPrimaryRange = 100
kShotgunSecondaryRange = 10
kMASCHealth = 400
kMASCStartDistance = 4
kMinigunCost = 25
kDualMinigunCost = 35
kFlamethrowerCost = 30
kGrenadeLauncherCost = 15
kRifleUpgradeTechResearchCost = 10              
kAdvancedArmoryUpgradeCost = 20
kWeaponsModuleAddonCost = 20
kPrototypeModuleAddonCost = 20
kRifleUpgradeTechResearchTime = 20
kAdvancedArmoryResearchTime = 180
kWeaponsModuleAddonTime = 120
kPrototypeModuleAddonTime = 120
kShotgunTechResearchCost = 15
kDualMinigunTechResearchCost = 15
kGrenadeLauncherTechResearchCost = 25
kShotgunTechResearchTime = 20
kDualMinigunTechResearchTime = 20
kMinigunClipSize = 250
kMinigunRange = 400
kMinigunDamage = 25
kGrenadeLauncherTechResearchTime = 20
kHealthSprayMin = 5
kHiveCost = 20
kHiveLevel2Cost = 20
kHiveLevel3Cost = 30
kHiveLevel2ResearchTime = 20
kHiveLevel3ResearchTime = 50
kHiveHealth = 2000
kHiveInitialEnergy = 100
kNumInitialInfestNodes = 2
kHiveMaxEnergy = 200
-- Units per second
kEnergyUpdateRate = 1
kDrifterCost = 1
kDrifterHealth = 100
kDrifterArmor = 25
kDrifterMoveSpeed = 4
kDrifterFlareTechResearchCost = 10
kDrifterFlareTechResearchTime = 25
kDrifterFlareBlindTime = 10
kInitialNanites = 10
kInfantryPortalTechResearchTime = 10
kInfantryPortalResearchCost = 20
kLoginBreakingDistance = 150
kRifleClipSize = 30
kMaxClips = 5
-- Keep weapon feel responsive by enforcing this max time
kMaxDrawTime = .5
kRifleRange = 250
kPistolClipSize = 10
kPistolDamage = 15
kPistolAltDamage = 30
kPistolRange = 200
kPlayerEyeHeight = 64
kBaseArmorAbsorption = .7
kProjectileArmorAbsorption = .6
kArmorHealthScalar = 2
kMarineHealth = 100
kRagDollPersistTime = 10
kResourceTowerBuildDistance = 200
kExtractorCost = 5
kObservatoryCost = 5
kRoboticsFactoryCost = 15
kWeaponsModuleCost = 10
kPrototypeModuleCost = 10
kHarvesterCost = 5
kResourceUpgradeResearchCost = 10
kResourceUpgradeResearchTime = 20
kSentryCost = 5
kSentryPingInterval = 4
kSentryFov = 90
kSentryROF = 1.0
kSentryBulletsPerSalvo = 5
kSentryDamagePerBullet = 5
-- Degrees per second to scan back and forth with no target
kSentryBarrelScanRate = 60
-- Degrees per second to move sentry orientation towards target or back to flat when untargeted
kSentryBarrelMoveRate = 100
kSentryTargetCheckTime = .5
kSentryRange = 16
kSentryHealth = 250
kMASCCost = 20
kAmmoPackCost = 1
kMedPackCost = 2
kCatPackCost = 2
kCatPackDuration = 6
kAmmoPackBullets = 100
kDropPackLifetime = 20
kPackThinkInterval = .3
kMedPackHealth = 50
kSpitDamage = 25
kSpikeDamage = 20
kSpikesDelay = .1
kSpikesZoomDelay = .3
kSporesDelay = .8
kInfantryPortalTransponderUseTime = .5
kResourceTowerDimensions = 30
kResourcesForKill = 200
kShotgunClipSize = 8
kShotgunDamage = 20
kGorgeHealth = 250
kLerkHealth = 250
kFadeHealth = 300
kOnosHealth = 500
kSkulkHealth = 70
kSkulkArmor = 10
kGorgeArmor = 50
kLerkArmor = 25
kFadeArmor = 100
kOnosArmor = 200
kCragHealth = 500
kWhipHealth = 500
kShiftHealth = 500
kShadeHealth = 500
kMarineBaseArmor = 30
kMarineArmorPerUpgradeLevel = 20
kTeamStartMetal = 50
kWelderCost = 5
kSkulkCost = 2
kGorgeCost = 5
kLerkCost = 8
kFadeCost = 9
kOnosCost = 10
kHydraCost = 6
kCragCost = 10
kWhipCost = 10
kShiftCost = 10
kShadeCost = 10
-- Normally -9.8 but more gravity has a better feel
kPlayerGravity = -12

kCommanderFov = 60
kSkulkFov = 110
kGorgeFov = 95
kLerkFov = 100
kLerkZoomedFov = 35
kFadeFov = 90
kOnosFov = 95

-- Player weights
kHumanMass = 90.7 -- ~200 pounds (incl. armor, weapons)
kSkulkMass = 45 -- ~100 pounds
kGorgeMass = 80 -- Fatty
kLerkMass = 54  -- ~120 pounds
kFadeMass = 158 -- ~350 pounds
kOnosMass = 453 -- Half a ton
kStructureMass = 100

kHumanJumpForce = 6.5
kSkulkJumpForce = 6.5
kGorgeJumpForce = 7
kLerkJumpForce = 8
kFadeJumpForce = 8
kOnosJumpForce = 7

-- FLOAT VALUES
kArmoryResupplyInterval = .9
kArmoryLoginRange = 2
kBaseBuildableExistThinkInterval = 0.10
-- DI regen think time
kAlienRegenThinkInterval = 1.0
-- Percentage per DI regen
kAlienInnateRegenerationPercentage = 0.02
kInfantryPortalThinkInterval = 0.25
kDefaultStructureBuildTime = 8.00
kDroppedWeaponLifetime = 10.00
kEggThinkRate = .5
kHumanWalkBackwardSpeedScalar = 0.6
kAxeBaseDamage = 40.00
kAxeFireDelay = 0.6
kAxeRange = 1.5
kMinigunFireDelay = .06
kMinigunSpread = .06
kMinigunSpinUpTime = .995
kHealthSprayPercent = 0.05
kRifleFireDelay = 0.0714
kRifleButtDelay = 0.6
kRifleButtDamage = 35
kRifleButtRange = 1.5
kRifleSpread = .003
kRifleDamage = 10
kWelderFireDelay = .5
kWelderRange = 2
kWelderDamage = 25
kGrenadeLauncherFireDelay = 1.0
kGrenadeLauncherClipSize = 4
-- 6 to match artwork
kGrenadeLauncherStartingAmmo = 6
kHumanXZExtents = 0.35
kHumanYExtents = .95
kHumanViewOffset = kHumanYExtents * 2 - 0.24 -- Eyes are about 9 to 10 inches below the top of the head 
kSkulkXExtents = .45
kSkulkYExtents = .45
kSkulkZExtents = .45
kLerkGlideGravityScalar = .1
kGlobalGravityScalar = 1.3
kPistolFireDelay = 0.15
kPistolAltFireDelay = 0.5
kPistolSpread = 0.01
kPistolAltSpread = 0.0015
kPlayerFriction = 3.00
kPlayerThinkInterval = .2
kResourceTowerBuildDelay = 4.00
kResourceTowerDeploySoundTime = 2.00
kResourceTowerUpdateInterval = 1.00
kRespawnInterval = 15.00
kRestartRoundTime = 6.00
kShotgunFireDelay = .7
kShotgunSecondaryFireDelay = 0.5
kShotgunSpread = 0.04
kBuildBotOrderScanRadius = 3.0
kSkulkBiteDamage = 75.00
kSkulkLeapVerticalAmount = 2
kSkulkLeapTime = 0.2
kSkulkLeapForce = 25
kSkulkBiteRange = 1.5
kHydraRange = 20.0
kHydraROF = 1.0
kStructureBuildDelay = 1.50
kPlayingTeamThinkInterval = .3
kTechTreeUpdateTime = .5
kBuildableStructureBuildSoundInterval = 0.3
kBuildableStructurePostBuildUseDelay  = 2.0
kEnergyRecuperationRate = 10.0
kMASCDeployTime = 3.0
kMASCUndeployTime = 3.0
kCatPackWeaponDelayModifer = .7
kCatPackMoveSpeedScalar = 1.2

-- L2/L3 health upgrades
kL2CommandStructureHealthMultiplier = 1.5
kL3CommandStructureHealthMultiplier = 2.0

-- Damage per alien energy unit that can be soaked
kGorgeDamageEnergyFactor = 3.0

-- Player speeds
kHumanWalkMaxSpeed = 4.4 -- Four miles an hour = 6,437 meters/hour = 1.8 meters/second (increase for FPS tastes)
kHumanStartRunMaxSpeed = 7.0 -- 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)
kHumanRunMaxSpeed = 6 -- 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)
kHumanRunTime = 10 -- Time it takes to get to top speed
kSkulkMaxSpeed = 7.6
kSkulkMaxWalkSpeed = 4
kGorgeMaxSpeed = 6.5
kLerkMaxSpeed = 8
kFadeMaxSpeed = 7
kOnosMaxSpeed = 9

-- Out of breath
kTimeToLoseBreath = 10
kTimeToGainBreath = 20
kEnergyBreathScalar = .5

kHumanAcceleration = 32
kHumanRunAcceleration = 20
kAirSpeedAcceleration = 15
kSkulkAcceleration = 45
kGorgeAcceleration = 40
kLerkAcceleration = 40
kFadeAcceleration = 40
kOnosAcceleration = 15

-- Point values
kDefaultPlayerPointValue = 10
kMarinePointValue = 10
kSkulkPointValue = 10
kGorgePointValue = 15
kLerkPointValue = 15
kFadePointValue = 25
kOnosPointValue = 50

-- MASC
kMASCFireThinkInterval = .3
kMASCMoveThinkInterval = .05

-- Must be greater than fireToHitInterval
kMASCAttackInterval = 8.0
kMASCFireToHitInterval = 6.0
kMASCAttackDamage = 300
kMASCDeployInterval = 3.0
kMASCUndeployInterval = 3.0

-- 75 feet, from mockup
kMASCFireRange = 22.86
kMASCSplashRadius = 10
kMASCUpgradedSplashRadius = 13

-- units per second
kMASCMoveSpeed = 2.5