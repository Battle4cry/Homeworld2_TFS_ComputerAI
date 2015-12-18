-- Pretty-Printed using HW2 Pretty-Printer 1.27 by Mikail.
aitrace("LOADING CPU RESEARCH")

function CpuResearch_Init()	
	if (s_race == Race_Hiigaran) then	
		dofilepath("data:ai/hiigaran_upgrades.lua")
		DoUpgradeDemand = DoUpgradeDemand_Hiigaran
		DoResearchTechDemand = DoResearchTechDemand_Hiigaran
	end
	if (s_race == Race_Vaygr) then	
		dofilepath("data:ai/vaygr_upgrades.lua")
		DoUpgradeDemand = DoUpgradeDemand_Vaygr
		DoResearchTechDemand = DoResearchTechDemand_Vaygr
	end
	if (s_race == 5) then	
		--Fed's (USE AS TEMPLATE NOT ACTUALLY IN TFS)																																																																																																																																																																																																																																												
		dofilepath("data:ai/federation_upgrades.lua")
		DoUpgradeDemand = DoUpgradeDemand_Nothing
		DoResearchTechDemand = DoResearchTechDemand_Nothing
	end
	if (s_race == 6) then	
		--Fed's (USE AS TEMPLATE NOT ACTUALLY IN TFS)
		dofilepath("data:ai/federation_upgrades.lua")
		DoUpgradeDemand = DoUpgradeDemand_Nothing
		DoResearchTechDemand = DoResearchTechDemand_Nothing
	end
	sg_lastUpgradeTime = gameTime()
	sg_upgradeDelayTime = 180 + Rand(80)
	-- this hook allows you to add randomness to the choosing of the best research
	cp_researchDemandRange = 1
	if (g_LOD == 1) then	
		cp_researchDemandRange = 0.5
	end
	if (g_LOD == 0) then	
		cp_researchDemandRange = 1
	end
	if (Override_ResearchInit) then	
		Override_ResearchInit()
	end
end

function CpuResearch_DefaultResearchDemandRules()	
	local threatlevel = UnderAttackThreat()
	-- if we are threatened
	if (threatlevel > 100) then	
		return
	end
	-- add demand for each tech research - could add a global 'tech' demand bonus (a personality trait)
	DoResearchTechDemand()
	local curGameTime = gameTime()
	local timeSinceLastUpgrade = curGameTime - sg_lastUpgradeTime
	local economicValue = 0
	local numCollecting = GetNumCollecting()
	local numRU = GetRU()
	if ((numRU > 2500 and numCollecting > 9) or numRU > 7500) then	
		economicValue = 2
	elseif ((numRU > 1500 and numCollecting > 7) or numRU > 4000) then	
		economicValue = 1
	end
	-- upgrade every so often - every X seconds OR when we have excess amounts of money
	if (sg_doupgrades == 1 and threatlevel <  - 20 and s_militaryPop > 7 and economicValue > 0 and (timeSinceLastUpgrade > sg_upgradeDelayTime or economicValue > 1)) then	
		-- add upgrade demand
		DoUpgradeDemand()
		sg_lastUpgradeTime = gameTime()
	end
end

function CpuResearch_Process()	
	--aitrace("*CpuResearch_Process")
	-- if we are doing poorly economically or we are under quite a bit of threat then do not research
	if (GetNumCollecting() < sg_minNumCollectors and GetRU() < 2000) then	
		return
		0
	end
	-- if we have no research subsystems we can't research
	if (NumResearchSubSystems() == 0) then	
		return
		0
	end
	-- no need to continue processing research requests if the research system is full
	if (IsResearchBusy() == 1) then	
		return
		0
	end
	-- must reset the reset demand every frame - then recaclulate it based on the current world state
	ResearchDemandClear()
	if (Override_ResearchDemand) then	
		Override_ResearchDemand()
	else
		CpuResearch_DefaultResearchDemandRules()
	end
	-- choose the research with the highest demand
	local bestResearch = FindHighDemandResearch()
	if (bestResearch ~= 0) then	
		Research(bestResearch)
		return
		1
	end
	return
	0
end

function DoResearchTechDemand_Vaygr()	
	--
	-- NO RULES YET FOR
	--
	--REPAIRABILITY
	--SCOUTEMPABILITY
  if (Util_CheckResearch(ISAI) ) then
	  ResearchDemandSet( ISAI, 99 )
	end	
	if buildaids == 1 then
   if (Util_CheckResearch(AIBUILDBONUS1) ) then
       ResearchDemandSet( AIBUILDBONUS1, 99 )
	   print("Buildaids Successful.")
	  end
	  end
	  
if buildaids == 2 then
   if (Util_CheckResearch(AIBUILDBONUS2) ) then
       ResearchDemandSet( AIBUILDBONUS2, 99 )
	   	print("Buildaids Successful.")
	  end
	  end
	  
if buildaids == 3 then
   if (Util_CheckResearch(AIBUILDBONUS3) ) then
       ResearchDemandSet( AIBUILDBONUS3, 99 )
	   print("Buildaids Successful.")
	  end
	  end
	if (Util_CheckResearch(HYPERSPACEGATETECH)) then	
		local demand = ShipDemandGet(kShipYard)
		if (demand > 0) then	
			ResearchDemandSet(HYPERSPACEGATETECH, demand + 0.5)
		end
	end
	-- battle cruiser ion weapons - required for battle cruiser to build - piggy backs its demand
	-- check to see if have any or if any shipyards are being built
	local numShipyards = NumSquadrons(kShipYard) + NumSquadronsQ(kShipYard)
	--local numHyperspaceSS = NumSubSystems(HYPERSPACE)+NumSubSystemsQ(HYPERSPACE)
	-- do battlecruiser research (only if we are in the process of getting hyperspace module)
	if (numShipyards > 0 and Util_CheckResearch(BATTLECRUISERIONWEAPONS)) then	
		local battleCruiserDemand = ShipDemandGet(kBattleCruiser)
		if (battleCruiserDemand > 0) then	
			ResearchDemandSet(BATTLECRUISERIONWEAPONS, battleCruiserDemand)
		end
	end
	if (numShipyards > 0 and Util_CheckResearch(BATTLESHIPTECH)) then	
		local battleShipDemand = ShipDemandGet(VGR_ARTILLERYBATTLECRUISER)
		if (battleShipDemand > 0) then	
			ResearchDemandSet(BATTLESHIPTECH, battleShipDemand)
		end
	end
	-- CHL-97 Heavy Cruiser demand 
	if (numShipyards > 0 and Util_CheckResearch(HEAVYCRUISERTECH)) then	
		local CHLDemand = ShipDemandGet(VGR_HEAVYCRUISER)
		if (CHLDemand > 0) then	
			ResearchDemandSet(HEAVYCRUISERTECH, CHLDemand)
		end
	end
	-- do destroyer research (but only if we are getting cap ship module
	if (Util_CheckResearch(DESTROYERGUNS)) then	
		local demand = ShipDemandGet(VGR_DESTROYER)
		if (demand > 0) then	
			ResearchDemandSet(DESTROYERGUNS, demand)
		end
	end
	if (Util_CheckResearch(DDGBATTLEMANAGEMENTSYSTEMS)) then	
		local DDGdemand = ShipDemandGet(VGR_DESTROYERLEADER)
		if (DDGdemand > 1) then	
			ResearchDemandSet(DDGBATTLEMANAGEMENTSYSTEMS, DDGdemand + 0.6)
		end
	end
	if (Util_CheckResearch(HEAVYFIGHTERCHASSIS)) then	
		local ftrdemand = ShipDemandMaxByClass(eFighter)
		if (ftrdemand > 0) then	
			ResearchDemandSet(HEAVYFIGHTERCHASSIS, ftrdemand + 0.6)
		end
	end
	if (Util_CheckResearch(LANCEBEAMS)) then	
		local lancedemand = ShipDemandGet(VGR_LANCEFIGHTER)
		if (lancedemand > 0) then	
			ResearchDemandSet(LANCEBEAMS, lancedemand + 0.5)
			-- offset because its cheap
		end
	end
	if (Util_CheckResearch(PLASMABOMBS)) then	
		local bomberdemand = ShipDemandGet(VGR_BOMBER)
		if (bomberdemand > 0) then	
			ResearchDemandSet(PLASMABOMBS, bomberdemand + 1)
			-- offset because its cheap
		end
	end
	if (Util_CheckResearch(LONGRANGETORPS)) then	
		local torpbomberdemand = ShipDemandGet(VGR_BOMBER_STRATEGIC)
		if (torpbomberdemand > 0) then	
			ResearchDemandSet(LONGRANGETORPS, torpbomberdemand + 0.4)
			-- offset because its cheap
		end
	end
	if (Util_CheckResearch(HEAVYLANCEBEAMS)) then	
		local laserfighterdemand = ShipDemandGet(VGR_LASERBOMBER)
		if (laserfighterdemand > 0) then	
			ResearchDemandSet(HEAVYLANCEBEAMS, laserfighterdemand + 0.4)
			-- offset because its cheap
		end
	end
	if (Util_CheckResearch(LASERBOMBERIMPROVEDBOMBS)) then	
		local numLaserBombers = NumSquadrons(VGR_LASERBOMBER)
		if (numLaserBombers > 5) then	
			ResearchDemandSet(LASERBOMBERIMPROVEDBOMBS, numLaserBombers)
		end
	end
	--IMPROVED FHG-37 MISSILES
	if (Util_CheckResearch(STANDOFFFRIGATEIMPROVEDMISSILES)) then	
		local numFHGs = NumSquadrons(VGR_LRCTS)
		local numEnemyDefenseFieldUnits = PlayersUnitTypeCount(player_enemy, player_total, eShield)
		if (numEnemyDefenseFieldUnits > 0) and (numFHGs > 1) then	
			ResearchDemandSet(STANDOFFFRIGATEIMPROVEDMISSILES, numFHGs)
		end
	end
	if (Util_CheckResearch(DEFENDERTECH)) then	
		local lrcmdemand = ShipDemandGet(VGR_FIGHTER_LRCM)
		if (lrcmdemand > 0) then	
			ResearchDemandSet(DEFENDERTECH, lrcmdemand + 0.4)
		end
	end
	if (Util_CheckResearch(CORVETTELASER)) then	
		local laserdemand = ShipDemandGet(VGR_LASERCORVETTE)
		if (laserdemand > 0) then	
			ResearchDemandSet(CORVETTELASER, laserdemand + 0.25)
		end
	end
	if (Util_CheckResearch(CORVETTELANCE)) then	
		local lancegunshipdemand = ShipDemandGet(VGR_MULTILANCECORVETTE)
		if (lancegunshipdemand > 0) then	
			ResearchDemandSet(CORVETTELANCE, lancegunshipdemand + 0.3)
		end
	end
	if (Util_CheckResearch(ADVCORVETTECHASSIS)) then	
		local corvdemand = ShipDemandMaxByClass(eCorvette)
		if (corvdemand > 1) then	
			ResearchDemandSet(ADVCORVETTECHASSIS, corvdemand + 0.35)
		end
	end
	if (Util_CheckResearch(ADVCORVETTECLOAK)) then	
		local CCHdemand = ShipDemandGet(VGR_SHAMSHIRIICTG)
		if (CCHdemand > 0) then	
			ResearchDemandSet(ADVCORVETTECLOAK, CCHdemand + 0.3)
		end
	end
	if (Util_CheckResearch(FRIGATEASSAULT)) then	
		local demand = ShipDemandGet(VGR_ASSAULTFRIGATE)
		if (demand > 0) then	
			ResearchDemandSet(FRIGATEASSAULT, demand)
		end
	end
	if (Util_CheckResearch(FRIGATELASER)) then	
		local demand = ShipDemandGet(VGR_ARTILLERYFRIGATE)
		if (demand > 0) then	
			ResearchDemandSet(FRIGATELASER, demand)
		end
	end
	if (Util_CheckResearch(PLATFORMLIGHTMISSILES)) then	
		local demand = ShipDemandGet(VGR_WEAPONPLATFORM_SRDFM)
		if (demand > 0) then	
			ResearchDemandSet(PLATFORMLIGHTMISSILES, demand)
		end
	end
	if (Util_CheckResearch(PLATFORMHEAVYMISSILES)) then	
		local demand = ShipDemandGet(VGR_WEAPONPLATFORM_MISSILE)
		if (demand > 1) then	
			ResearchDemandSet(PLATFORMHEAVYMISSILES, demand)
		end
	end
	if (Util_CheckResearch(BOMBERIMPROVEDBOMBS)) then	
		local numBombers = NumSquadrons(kBomber)
		if (numBombers > 2) then	
			ResearchDemandSet(BOMBERIMPROVEDBOMBS, numBombers)
		end
	end
	if (Util_CheckResearch(UWPMISSILEUPGRADE1)) then	
		local numlightmissileplats = NumSquadrons(VGR_WEAPONPLATFORM_SRDFM)
		if (numlightmissileplats > 2) then	
			ResearchDemandSet(UWPMISSILEUPGRADE1, numlightmissileplats)
		end
	end
	if (Util_CheckResearch(UWPMISSILERANGE)) then	
		local nummissileplats = NumSquadrons(VGR_WEAPONPLATFORM_MISSILE)
		if (nummissileplats > 1) then	
			ResearchDemandSet(UWPMISSILERANGE, nummissileplats)
		end
	end
	if (Util_CheckResearch(STRIKEBOMBERCONCUSSIONMISSILES)) then	
		local numStrikeBombers = NumSquadrons(VGR_BOMBER_INTERDICTION)
		if (numStrikeBombers > 1) then	
			ResearchDemandSet(STRIKEBOMBERCONCUSSIONMISSILES, numStrikeBombers)
		end
	end
	if (Util_CheckResearch(CORVETTEIMPROVEDLASERS)) then	
		local numLaserCorvettes = NumSquadrons(VGR_LASERCORVETTE)
		if (numLaserCorvettes > 4) then	
			ResearchDemandSet(CORVETTEIMPROVEDLASERS, numLaserCorvettes)
		end
	end
	if (Util_CheckResearch(DEFENDERHEALTHUPGRADE1)) then	
		local numDefenders = NumSquadrons(VGR_FIGHTER)
		if (numDefenders > 2) then	
			ResearchDemandSet(DEFENDERHEALTHUPGRADE1, numDefenders)
		end
	end
	if (Util_CheckResearch(CORVETTETECH)) then	
		local corvdemand = ShipDemandMaxByClass(eCorvette)
		if (corvdemand > 0) then	
			ResearchDemandSet(CORVETTETECH, corvdemand + 0.5)
		end
	end
	if (Util_CheckResearch(FRIGATETECH)) then	
		local frigdemand = ShipDemandMaxByClass(eFrigate)
		if (frigdemand > 0) then	
			ResearchDemandSet(FRIGATETECH, frigdemand + 0.5)
		end
	end
	if (Util_CheckResearch(HEAVYFRIGATECHASSIS)) then	
		local ffhdemand = ShipDemandMaxByClass(eFrigate)
		if (ffhdemand > 0) then	
			ResearchDemandSet(HEAVYFRIGATECHASSIS, ffhdemand + 0.35)
		end
	end
	if (Util_CheckResearch(FRIGATEEWS)) then	
		local demand = ShipDemandGet(VGR_SCOUTFRIGATE)
		if (demand > 0) then	
			ResearchDemandSet(FRIGATEEWS, demand)
		end
	end
	if (Util_CheckResearch(STRIKECARRIERIMPROVEDMISSILES)) then	
		local numCVGs = NumSquadrons(VGR_STRIKECARRIER)
		if (numCVGs > 0) then	
			ResearchDemandSet(STRIKECARRIERIMPROVEDMISSILES, numCVGs)
		end
	end
	if (s_militaryPop > 9 and GetRU() > 500) then	
		if (Util_CheckResearch(MODULARWEAPONSYSTEMS)) then	
			local CVGdemand = ShipDemandGet(VGR_STRIKECARRIER)
			if (CVGdemand > 0) then	
				ResearchDemandSet(MODULARWEAPONSYSTEMS, CVGdemand)
			end
		end
		if (Util_CheckResearch(FRIGATEIMPCONCUSSIONMISSILES)) then	
			local numLightMissileFrigate = NumSquadrons(VGR_ESCORTFRIGATE)
			if (numLightMissileFrigate > 0) then	
				ResearchDemandSet(FRIGATEIMPCONCUSSIONMISSILES, numLightMissileFrigate)
			end
		end
		if (Util_CheckResearch(ASSAULTFRIGATEIMPROVEDGUNS)) then	
			local numAssaultFrigate = NumSquadrons(VGR_ASSAULTFRIGATE)
			if (numAssaultFrigate > 2) then	
				ResearchDemandSet(ASSAULTFRIGATEIMPROVEDGUNS, numAssaultFrigate)
			end
		end
		if (Util_CheckResearch(MISSILECRUISERTECH)) then	
			local CLGdemand = ShipDemandGet(VGR_LIGHTCRUISER)
			if (CLGdemand > 0) then	
				ResearchDemandSet(MISSILECRUISERTECH, CLGdemand)
			end
		end
	end
	if (s_militaryPop > 15 and GetRU() > 750) then	
		if (Util_CheckResearch(CORVETTEGRAVITICATTRACTION)) then	
			local mineLayerDemand = ShipDemandGet(VGR_MINELAYERCORVETTE)
			if (mineLayerDemand > 0) then	
				ResearchDemandSet(CORVETTEGRAVITICATTRACTION, mineLayerDemand)
			end
		end
		-- ECM PROBES FOR HARD CPU
		if (Util_CheckResearch(PROBESENSORDISRUPTION)) then	
			local ECMProbeDemand = ShipDemandGet(VGR_PROBE_ECM)
			if (g_LOD > 0) and (ECMProbeDemand > 0) then	
				ResearchDemandSet(PROBESENSORDISRUPTION, ECMProbeDemand)
			end
		end
		-- MOBILE INHIBITORS FOR HARD ADAPTIVE CPU
		if (Util_CheckResearch(MOBILEINHIBITORTECH)) then	
			local MobileInhibDemand = ShipDemandGet(VGR_MOBILE_INHIBITOR)
			if (g_LOD > 2) and (MobileInhibDemand > 0) then	
				ResearchDemandSet(MOBILEINHIBITORTECH, MobileInhibDemand)
			end
		end
		if (Util_CheckResearch(CORVETTECOMMAND)) then	
			local commanddemand = ShipDemandGet(VGR_COMMANDCORVETTE)
			if (commanddemand > 0) then	
				ResearchDemandSet(CORVETTECOMMAND, commanddemand)
			end
		end
		if (Util_CheckResearch(FRIGATEINFILTRATIONTECH)) then	
			local demand = ShipDemandGet(VGR_INFILTRATORFRIGATE)
			if (demand > 0) then	
				ResearchDemandSet(FRIGATEINFILTRATIONTECH, demand)
			end
		end
		if (Util_CheckResearch(HEAVYMODULARWEAPONSYSTEMS)) then	
			local bcdemand = ShipDemandGet(kBattleCruiser)
			if (bcdemand > 0) then	
				ResearchDemandSet(HEAVYMODULARWEAPONSYSTEMS, bcdemand)
			end
		end
		if (Util_CheckResearch(MISSILEBOMBERIMPROVEDMISSILES)) then	
			local numHeavyMissileBombers = NumSquadrons(VGR_BOMBER_STRATEGIC)
			if (numHeavyMissileBombers > 1) then	
				ResearchDemandSet(MISSILEBOMBERIMPROVEDMISSILES, numHeavyMissileBombers)
			end
		end
		-- UPGRADE SHIPYARD VGR WEAPONS 
		if (Util_CheckResearch(SHIPYARDMRM)) then	
			local numShipYards = NumSquadrons(VGR_SHIPYARD)
			if (numShipYards > 0) then	
			ResearchDemandSet(SHIPYARDMRM, numShipYards)
			end
		end
		if (Util_CheckResearch(UTILITYHEALTHUPGRADE1)) then	
			local numCollectors = NumSquadrons(kCollector)
			if (numCollectors > 10) then	
				ResearchDemandSet(UTILITYHEALTHUPGRADE1, numCollectors)
				ResearchDemandSet(UTILITYHEALTHUPGRADE2, numCollectors)
			end
		end
	end
end

-- check to see if research is not done but currently available

function Util_CheckResearch(researchId)	
	if (IsResearchDone(researchId) == 0 and IsResearchAvailable(researchId) == 1) then	
		return
		1
	end
	return
	nil
end

function DoResearchTechDemand_Hiigaran()	
	-- NO RULES YET FOR
	--
	--REPAIRABILITY
	--SCOUTEMPABILITY
	--SCOUTPINGABILITY
  if (Util_CheckResearch(ISAI) ) then
	  ResearchDemandSet( ISAI, 99 )
	end	
	if buildaids == 1 then
   if (Util_CheckResearch(AIBUILDBONUS1) ) then
       ResearchDemandSet( AIBUILDBONUS1, 99 )
	   print("Buildaids Successful.")
	  end
	  end
	  
if buildaids == 2 then
   if (Util_CheckResearch(AIBUILDBONUS2) ) then
       ResearchDemandSet( AIBUILDBONUS2, 99 )
	   	print("Buildaids Successful.")
	  end
	  end
	  
if buildaids == 3 then
   if (Util_CheckResearch(AIBUILDBONUS3) ) then
       ResearchDemandSet( AIBUILDBONUS3, 99 )
	   print("Buildaids Successful.")
	  end
	  end
	local numShipyards = NumSquadrons(kShipYard) + NumSquadronsQ(kShipYard)
	-- battle cruiser ion weapons - required for battle cruiser to build - piggy backs its demand
	if (numShipyards > 0 and Util_CheckResearch(BATTLECRUISERIONWEAPONS)) then	
		local battleCruiserDemand = ShipDemandGet(kBattleCruiser)
		if (battleCruiserDemand > 0) then	
			ResearchDemandSet(BATTLECRUISERIONWEAPONS, battleCruiserDemand)
		end
	end
	if (numShipyards > 0 and Util_CheckResearch(BATTLESHIPIONWEAPONS)) then	
		local battleCruiserDemand = ShipDemandGet(kBattleCruiser)
		if (battleCruiserDemand > 0) then	
			ResearchDemandSet(BATTLESHIPIONWEAPONS, battleCruiserDemand)
		end
	end
	-- ionturret - needed to build ion turrets so use the same demand value
	if (Util_CheckResearch(PLATFORMIONWEAPONS)) then	
		local ionTurretDemand = ShipDemandGet(HGN_IONTURRET)
		if (ionTurretDemand > 0) then	
			ResearchDemandSet(PLATFORMIONWEAPONS, ionTurretDemand)
		end
	end
	if (Util_CheckResearch(PLATFORMLASERWEAPONS)) then	
		local LaserPlatDemand = ShipDemandGet(HGN_PULSARTURRET)
		if (LaserPlatDemand > 0) then	
			ResearchDemandSet(PLATFORMLASERWEAPONS, LaserPlatDemand)
		end
	end
	if (Util_CheckResearch(DESTROYERTECH)) then	
		-- get the demand for destroyer
		local destroyerDemand = ShipDemandGet(HGN_DESTROYER)
		if (destroyerDemand > 0) then	
			ResearchDemandSet(DESTROYERTECH, destroyerDemand)
		end
	end
	if (Util_CheckResearch(ADVANCEDDESTROYERTECH)) then	
		-- get the demand for destroyerleader
		local destroyerleaderDemand = ShipDemandGet(HGN_DESTROYERLEADER)
		if (destroyerleaderDemand > 0) then	
			ResearchDemandSet(ADVANCEDDESTROYERTECH, destroyerleaderDemand)
		end
	end
	if (Util_CheckResearch(ESCORTDESTROYERDEFENSEFIELD)) then	
		local escortdestroyerDemand = ShipDemandGet(HGN_ESCORTDESTROYER)
		if (escortdestroyerDemand > 0) then	
			ResearchDemandSet(ESCORTDESTROYERDEFENSEFIELD, escortdestroyerDemand)
		end
	end
	if (Util_CheckResearch(ASSAULTCARRIERTECH)) then	
		-- get the demand for assaultcarrier
		local assaultcarrierDemand = ShipDemandGet(HGN_ASSAULTCARRIER)
		if (assaultcarrierDemand > 0) then	
			ResearchDemandSet(ASSAULTCARRIERTECH, assaultcarrierDemand)
		end
	end
	if (Util_CheckResearch(ATTACKBOMBERIMPROVEDBOMBS)) then	
		local numBombers = NumSquadrons(kBomber)
		if (numBombers > 1) then	
			ResearchDemandSet(ATTACKBOMBERIMPROVEDBOMBS, numBombers)
		end
	end
	if (Util_CheckResearch(ATTACKBOMBERIMPROVEDROCKETS)) then	
		local numRocketBombers = NumSquadrons(HGN_ROCKETBOMBER)
		if (numRocketBombers > 5) then	
			ResearchDemandSet(ATTACKBOMBERIMPROVEDROCKETS, numRocketBombers)
		end
	end
	if (Util_CheckResearch(IONTURRETIMPROVEDRANGE)) then	
		local numIonPlats = NumSquadrons(HGN_IONTURRET)
		if (numIonPlats > 2) then	
			ResearchDemandSet(IONTURRETIMPROVEDRANGE, numIonPlats)
		end
	end
	if (Util_CheckResearch(RWSPROXIMITYBURSTSHELLS)) then	
		local numGunPlats = NumSquadrons(HGN_GUNTURRET)
		if (numGunPlats > 2) then	
			ResearchDemandSet(RWSPROXIMITYBURSTSHELLS, numGunPlats)
		end
	end
	if (Util_CheckResearch(DEFENDERTECH)) then	
		local ftrdemand = ShipDemandMaxByClass(eFighter)
		if (ftrdemand > 0) then	
			ResearchDemandSet(DEFENDERTECH, ftrdemand + 0.4)
		end
	end
	if (Util_CheckResearch(FIGHTERPULSARTECH)) then	
		local ftrdemand = ShipDemandMaxByClass(eFighter)
		if (ftrdemand > 0) then	
			ResearchDemandSet(FIGHTERPULSARTECH, ftrdemand + 0.2)
		end
	end
	if (Util_CheckResearch(DEFENDERCLUSTERMISSILETECH)) then	
		local ftrdemand = ShipDemandMaxByClass(eFighter)
		if (ftrdemand > 0) then	
			ResearchDemandSet(DEFENDERCLUSTERMISSILETECH, ftrdemand + 0.2)
		end
	end
	if (Util_CheckResearch(ELITEINTERCEPTORTECH)) then	
		local ftrdemand = ShipDemandMaxByClass(eFighter)
		if (ftrdemand > 0) then	
			ResearchDemandSet(ELITEINTERCEPTORTECH, ftrdemand + 0.6)
		end
	end
	if (Util_CheckResearch(BOMBERMISSILES)) then	
		local ftrdemand = ShipDemandMaxByClass(eFighter)
		if (ftrdemand > 0) then	
			ResearchDemandSet(BOMBERMISSILES, ftrdemand + 0.8)
		end
	end
	if (Util_CheckResearch(HEAVYGUNSHIPRESEARCH)) then	
		local corvdemand = ShipDemandMaxByClass(eCorvette)
		if (corvdemand > 0) then	
			ResearchDemandSet(HEAVYGUNSHIPRESEARCH, corvdemand + 0.4)
		end
	end
	if (Util_CheckResearch(HEAVYCORVETTETECH)) then	
		local corvdemand = ShipDemandMaxByClass(eCorvette)
		if (corvdemand > 0) then	
			ResearchDemandSet(HEAVYCORVETTETECH, corvdemand + 0.25)
		end
	end
	if (Util_CheckResearch(IMPROVEDTORPEDO)) then	
		local numTorpedoFrigs = NumSquadrons(HGN_TORPEDOFRIGATE)
		if (numTorpedoFrigs > 2) then	
			ResearchDemandSet(IMPROVEDTORPEDO, numTorpedoFrigs)
		end
	end
	if (Util_CheckResearch(IMPROVEDCLUSTERTORPEDO)) then	
		local numTorpedoFrigs = NumSquadrons(HGN_TORPEDOFRIGATEADVANCED)
		if (numTorpedoFrigs > 1) then	
			ResearchDemandSet(IMPROVEDCLUSTERTORPEDO, numTorpedoFrigs)
		end
	end
	if (Util_CheckResearch(IMPROVEDPULSARGUNSHIP)) then	
		local numPulsars = NumSquadrons(HGN_PULSARCORVETTE)
		if (numPulsars > 2) then	
			ResearchDemandSet(IMPROVEDPULSARGUNSHIP, numPulsars)
		end
	end
	if (Util_CheckResearch(IMPROVEDFRIGATERESEARCH)) then	
		local frigdemand = ShipDemandMaxByClass(eFrigate)
		if (frigdemand > 0) then	
			ResearchDemandSet(IMPROVEDFRIGATERESEARCH, frigdemand + 0.35)
		end
	end
	if (Util_CheckResearch(ARTILLERYFRIGATERESEARCH)) then	
		local frigdemand = ShipDemandMaxByClass(eFrigate)
		if (frigdemand > 0) then	
			ResearchDemandSet(ARTILLERYFRIGATERESEARCH, frigdemand + 0.25)
		end
	end
	if (Util_CheckResearch(CRUISERCHASSISTECH)) then
		local CHKdemand = ShipDemandGet(HGN_LIGHTCRUISER)
		if (CHKdemand > 1) then	
			ResearchDemandSet(CRUISERCHASSISTECH, CHKdemand)
		end
	end

--CLG-88 Demand
		if (Util_CheckResearch(MISSILECRUISERCHASSIS)) then	
			local CLGdemand = ShipDemandGet(HGN_MISSILECRUISER)
			if (CLGdemand > 0) then	
				ResearchDemandSet(MISSILECRUISERCHASSIS, CLGdemand)
			end
		end
	if (Util_CheckResearch(MODULARTURRETTECH)) then	
		local bcdemand = ShipDemandGet(kBattleCruiser)
		if (bcdemand > 0) then	
			ResearchDemandSet(MODULARTURRETTECH, bcdemand)
		end
	end
	
	-- Upgrade Shipyard weapons only if attack is imminent
	if (Util_CheckResearch(SHIPYARDMRM)) then	
		local numShipYards = NumSquadrons(HGN_SHIPYARD)
		if (numShipYards > 0) then	
			ResearchDemandSet(SHIPYARDMRM, numShipYards)
		end
	end

	-- Individual Unit Upgrades
	if (Util_CheckResearch(ATTACKBOMBERHEALTHUPGRADE1)) then	
		local numBombers = NumSquadrons(kBomber)
		if (numBombers > 1) then	
			ResearchDemandSet(ATTACKBOMBERHEALTHUPGRADE1, numBombers)
			ResearchDemandSet(ATTACKBOMBERHEALTHUPGRADE2, numBombers)
		end
	end
	if (Util_CheckResearch(STRIKEFIGHTERENGINES1)) then	
		local numStrikeFightersLRCT = NumSquadrons(HGN_FIGHTER_LRCT)
		if (numStrikeFightersLRCT > 4) then	
			ResearchDemandSet(STRIKEFIGHTERENGINES1, numStrikeFightersLRCT)
		end
	end
	if (Util_CheckResearch(ASSAULTCORVETTEHEALTHUPGRADE1)) then	
		local numAssaultCorvette = NumSquadrons(HGN_ASSAULTCORVETTE)
		if (numAssaultCorvette > 1) then	
			ResearchDemandSet(ASSAULTCORVETTEHEALTHUPGRADE1, numAssaultCorvette)
			ResearchDemandSet(ASSAULTCORVETTEHEALTHUPGRADE2, numAssaultCorvette)
		end
	end
	if (Util_CheckResearch(PULSARCORVETTEHEALTHUPGRADE1)) then	
		local numPulsarCorvette = NumSquadrons(HGN_PULSARCORVETTE)
		if (numPulsarCorvette > 1) then	
			ResearchDemandSet(PULSARCORVETTEHEALTHUPGRADE1, numPulsarCorvette)
			ResearchDemandSet(PULSARCORVETTEHEALTHUPGRADE2, numPulsarCorvette)
		end
	end
	if (Util_CheckResearch(HEAVYGUNSHIPHEALTHUPGRADE)) then	
		local numMultiGunCorvette = NumSquadrons(HGN_MULTIGUNCORVETTE)
		if (numMultiGunCorvette > 0) then	
			ResearchDemandSet(HEAVYGUNSHIPHEALTHUPGRADE, numMultiGunCorvette)
		end
	end
	if (s_militaryPop > 15 and GetRU() > 750) then	
		if (Util_CheckResearch(DEFENSEFIELDFRIGATESHIELD)) then	
			local DFFDemand = ShipDemandGet(HGN_DEFENSEFIELDFRIGATE)
			if (DFFDemand > 0) then	
				ResearchDemandSet(DEFENSEFIELDFRIGATESHIELD, DFFDemand)
			end
		end
		if (Util_CheckResearch(ECMPROBE)) then	
			local ecmProbeDemand = ShipDemandGet(HGN_ECMPROBE)
			if (ecmProbeDemand > 0) then	
				ResearchDemandSet(ECMPROBE, ecmProbeDemand)
			end
		end
		if (Util_CheckResearch(GRAVITICATTRACTIONMINES)) then	
			local mineLayerDemand = ShipDemandGet(HGN_MINELAYERCORVETTE)
			if (mineLayerDemand > 0) then	
				ResearchDemandSet(GRAVITICATTRACTIONMINES, mineLayerDemand)
			end
		end
		if (Util_CheckResearch(HEAVYBOMBERIMPROVEDMISSILES)) then	
			local numHeavyBombers = NumSquadrons(HGN_HEAVYBOMBER)
			if (numHeavyBombers > 1) then	
				ResearchDemandSet(HEAVYBOMBERIMPROVEDMISSILES, numHeavyBombers)
			end
		end
		if (Util_CheckResearch(RESOURCECOLLECTORHEALTHUPGRADE1)) then	
			local numCollectors = NumSquadrons(kCollector)
			if (numCollectors > 10) then	
				ResearchDemandSet(RESOURCECOLLECTORHEALTHUPGRADE1, numCollectors)
				ResearchDemandSet(RESOURCECOLLECTORHEALTHUPGRADE2, numCollectors)
			end
		end
	end
end

function DoUpgradeDemand_Hiigaran()	
	-- based on the actual count of each ship determine which upgrades to do
	-- make sure we are winning before doing some of these upgrades
	if (s_militaryStrength > 9 or g_LOD == 0) then	
		---economic status 
		local economicallysound = 0
		if GetRU() > 3000 then	
			economicallysound = 50
		elseif GetRU() > 5000 then	
			economicallysound = 75
		elseif GetRU() > 7500 then	
			economicallysound = 100
		end
		-- mothership upgrades
		-- if underattack (or some random factor - need more intel here)
		inc_upgrade_demand(rt_mothership, 0.5)
		-- also demand for build speed upgrade on the MS
		ResearchDemandAdd(MOTHERSHIPBUILDSPEEDUPGRADE1, 0.5)
		-- hyperspace upgrades - what prereqs ? num carriers, 
		--inc_upgrade_demand( rt_hyperspace, 0.5  )
		-- do platforms
		local numPlatforms = numActiveOfClass(s_playerIndex, ePlatform)
		if (numPlatforms > 1) then	
			local numGunTurret = NumSquadrons(HGN_GUNTURRET)
			if (numGunTurret > 1) then	
				inc_upgrade_demand(rt_platform.gunturret, numGunTurret * 1)
			end
			local numIonTurret = NumSquadrons(HGN_IONTURRET)
			if (numIonTurret > 1) then	
				inc_upgrade_demand(rt_platform.gunturret, numIonTurret * 1)
			end
		end
		-- collectors are always around - good to upgrades these (unless playtesters tell us otherwise)
		local numCollectors = NumSquadrons(kCollector)
		if (numCollectors > 0) then	
			inc_upgrade_demand(rt_collector, numCollectors * 0.1)
		end
		local numRefinery = NumSquadrons(kRefinery)
		if (numRefinery > 0) then	
			inc_upgrade_demand(rt_refinery, numRefinery * 1.5)
		end
		-- carrier
		local numCarrier = NumSquadrons(kCarrier)
		if (numCarrier > 0) then	
			ResearchDemandSet(CARRIERBUILDSPEEDUPGRADE1, numCarrier * 3)
			ResearchDemandSet(CARRIERHEALTHUPGRADE1, 2)
			ResearchDemandSet(CARRIERHEALTHUPGRADE2, numCarrier * 0.75)
			ResearchDemandSet(CARRIERMAXSPEEDUPGRADE1, numCarrier * 0.75)
			ResearchDemandSet(CARRIERMAXSPEEDUPGRADE2, numCarrier * 0.5)
		end
		-- shipyard
		local numShipYards = NumSquadrons(kShipYard)
		if (numShipYards > 0) then	
			inc_upgrade_demand(rt_shipyard, numShipYards * 1.5)
			ResearchDemandSet(SHIPYARDBUILDSPEEDUPGRADE1, numShipYards * 1.75)
		end
	end
	-- do fighter upgrades
	local numFighter = numActiveOfClass(s_playerIndex, eFighter)
	if (numFighter > 1) then	
		-- interceptors
		-- bombers
		local numBombers = NumSquadrons(HGN_ATTACKBOMBER)
		if (numBombers > 1) then	
			ResearchDemandSet(ATTACKBOMBERHEALTHUPGRADE1, numBombers * 2)
			ResearchDemandSet(ATTACKBOMBERHEALTHUPGRADE2, numBombers * 1)
		end
		-- strike fighters
		local numStrikeFighters = NumSquadrons(HGN_FIGHTER)
		if (numStrikeFighters > 3) then	
			ResearchDemandSet(STRIKEFIGHTERENGINES1, numStrikeFighters * 2)
		end
		-- strategic bombers
		local numHeavyBombers = NumSquadrons(HGN_HEAVYBOMBER)
		if (numHeavyBombers > 1) then	
			ResearchDemandSet(HEAVYBOMBERIMPROVEDMISSILES, numHeavyBombers * 2)
		end
	end
	-- battlecruiser upgrades
	local numBattleCruiser = NumSquadrons(HGN_BATTLECRUISER)
	if (numBattleCruiser > 0) then	
		inc_upgrade_demand(rt_battlecruiser, numBattleCruiser * 2.5)
	end
	-- heavy cruiser CHK upgrades
	local numLightCruiser = NumSquadrons(HGN_LIGHTCRUISER)
	if (numLightCruiser > 0) then	
		inc_upgrade_demand(rt_lightcruiser, numLightCruiser * 2)
	end
	-- torpedo cruiser upgrades
	local numTorpedoCruiser = NumSquadrons(HGN_MISSILECRUISER)
	if (numTorpedoCruiser > 0) then	
		inc_upgrade_demand(rt_missilecruiser, numTorpedoCruiser * 1)
	end
	-- destroyer upgrades
	local numDestroyers = NumSquadrons(HGN_DESTROYER)
	if (numDestroyers > 0) then	
		inc_upgrade_demand(rt_destroyer, numDestroyers * 2)
	end
	-- battleship upgrades
	local numStrikeBattleCruiser = NumSquadrons(HGN_STRIKEBATTLECRUISER)
	if (numStrikeBattleCruiser > 0) then	
		inc_upgrade_demand(rt_battleship, numStrikeBattleCruiser * 2.5)
	end
	-- missile destroyer upgrades
	local numDestroyerleader = NumSquadrons(HGN_DESTROYERLEADER)
	if (numDestroyerleader > 0) then	
		inc_upgrade_demand(rt_destroyerleader, numDestroyerleader * 2.5)
	end
	-- ion destroyer upgrades
	local numIonDestroyer = NumSquadrons(HGN_IONDESTROYER)
	if (numIonDestroyer > 0) then	
		inc_upgrade_demand(rt_destroyerion, numIonDestroyer * 2.5)
	end
	-- assault carrier upgrades
	local numAssaultCarrier = NumSquadrons(HGN_ASSAULTCARRIER)
	if (numAssaultCarrier > 0) then	
		inc_upgrade_demand(rt_assaultcarrier, numAssaultCarrier * 1.5)
	end
	-- do corvette upgrades
	local numCorvette = numActiveOfClass(s_playerIndex, eCorvette)
	if (numCorvette > 1) then	
		local numAssaultCorvette = NumSquadrons(HGN_ASSAULTCORVETTE)
		if (numAssaultCorvette > 1) then	
			ResearchDemandSet(ASSAULTCORVETTEHEALTHUPGRADE1, numAssaultCorvette * 1.5)
			ResearchDemandSet(ASSAULTCORVETTEHEALTHUPGRADE2, numAssaultCorvette * 1)
		end
		local numPulsarCorvette = NumSquadrons(HGN_PULSARCORVETTE)
		if (numPulsarCorvette > 1) then	
			ResearchDemandSet(PULSARCORVETTEHEALTHUPGRADE1, numPulsarCorvette * 1.75)
			ResearchDemandSet(PULSARCORVETTEHEALTHUPGRADE2, numPulsarCorvette * 1.25)
		end
		local numMultigunCorvette = NumSquadrons(HGN_MULTIGUNCORVETTE)
		if (numMultigunCorvette > 1) then	
			ResearchDemandSet(HEAVYGUNSHIPHEALTHUPGRADE, numMultigunCorvette * 1.75)
			ResearchDemandSet(HEAVYGUNSHIPHEALTHUPGRADE2, numMultigunCorvette * 1.25)
		end
		local numHeavyCorvette = NumSquadrons(HGN_HEAVYCORVETTE)
		if (numHeavyCorvette > 1) then	
			ResearchDemandSet(HEAVYCORVETTEHEALTHUPGRADE, numHeavyCorvette * 1.75)
		end
		local numBomberCorvette = NumSquadrons(HGN_BOMBERVETTE)
		if (numBomberCorvette > 1) then	
			ResearchDemandSet(BOMBERCORVETTESPEEDUPGRADE, numBomberCorvette * 1.5)
			ResearchDemandSet(BOMBERCORVETTEHEALTHUPGRADE, numBomberCorvette * 1.5)
		end
	end
	-- do frigate upgrades
	local numFrigate = numActiveOfClass(s_playerIndex, eFrigate)
	if (numFrigate > 2) then	
		local numTorpedoFrigate = NumSquadrons(HGN_TORPEDOFRIGATE)
		if (numTorpedoFrigate > 2) then	
			inc_upgrade_demand(rt_frigate.torpedo, numTorpedoFrigate * 1.5)
		end
		local numIonFrigate = NumSquadrons(HGN_IONCANNONFRIGATE)
		if (numIonFrigate > 2) then	
			inc_upgrade_demand(rt_frigate.ioncannon, numIonFrigate * 1.5)
		end
		local numAssaultFrigate = NumSquadrons(HGN_ASSAULTFRIGATE)
		if (numAssaultFrigate > 2) then	
			inc_upgrade_demand(rt_frigate.assault, numAssaultFrigate * 1.5)
		end
		local numflakfrigate = NumSquadrons(HGN_FLAKFRIGATE)
		if (numflakfrigate > 2) then	
			inc_upgrade_demand(rt_frigate.flak, numflakfrigate * 1.5)
		end
		local numlrms = NumSquadrons(HGN_LRMS)
		if (numlrms > 2) then	
			inc_upgrade_demand(rt_frigate.lrms, numlrms * 1.5)
		end
		local numartillery = NumSquadrons(HGN_ARTILLERYFRIGATE)
		if (numartillery > 1) then	
			inc_upgrade_demand(rt_frigate.artillery, numartillery * 1.5)
		end
		local numtorpedofrigateadvanced = NumSquadrons(HGN_TORPEDOFRIGATEADVANCED)
		if (numtorpedofrigateadvanced > 1) then	
			inc_upgrade_demand(rt_frigate.torpedofrigateadvanced, numtorpedofrigateadvanced * 1.5)
		end
	end
end

function DoUpgradeDemand_Vaygr()	
	-- based on the actual count of each ship determine which upgrades to do
	if (s_militaryStrength > 9 or g_LOD == 0) then	
		---economic status 
		local economicallysound = 0
		if GetRU() > 3000 then	
			economicallysound = 50
		elseif GetRU() > 5000 then	
			economicallysound = 75
		elseif GetRU() > 7500 then	
			economicallysound = 100
		end
		-- mothership upgrades
		-- if underattack (or some random factor - need more intel here)
		inc_upgrade_demand(rt_mothership, 0.5)
		-- also demand for build speed upgrade on the MS
		ResearchDemandAdd(MOTHERSHIPBUILDSPEEDUPGRADE1, 0.5)
		-- do corvette upgrades
		local numCorvette = numActiveOfClass(s_playerIndex, eCorvette)
		if (numCorvette > 2) then	
			inc_upgrade_demand(rt_corvette, numCorvette)
		end
		-- do frigate upgrades
		local numFrigate = numActiveOfClass(s_playerIndex, eFrigate)
		if (numFrigate > 2) then	
			inc_upgrade_demand(rt_frigate, numFrigate * 1)
		end
		-- do platforms
		local numPlatforms = numActiveOfClass(s_playerIndex, ePlatform)
		if (numPlatforms > 0) then	
			inc_upgrade_demand(rt_platform, numPlatforms * 1)
		end
		local numCapital = numActiveOfClass(s_playerIndex, eCapital)
		if (numCapital > 1) then	
			inc_upgrade_demand(rt_capital, numCapital * 0.5)
		end
		-- carrier
		local numCarrier = NumSquadrons(kCarrier)
		if (numCarrier > 0) then	
			ResearchDemandAdd(CARRIERBUILDSPEEDUPGRADE1, numCarrier * 1.25)
		end
		-- shipyard
		local numShipYards = NumSquadrons(kShipYard)
		if (numShipYards > 0) then	
			ResearchDemandAdd(SHIPYARDBUILDSPEEDUPGRADE1, numShipYards * 1.75)
		end
	end
end

function DoUpgradeDemand_Nothing()	
end

function DoResearchTechDemand_Nothing()	
end

-- RESEARCH HELPER FUNCTIONS
-- could move this to code if its too slow

function inc_research_demand(researchtype, val)	
	local typeis = typeid(researchtype)
	-- recursive function that 
	if (typeis == LT_TABLE) then	
		for i, v in researchtype do	
			inc_research_demand(v, val)
		end
	else
		if (Util_CheckResearch(researchtype)) then	
			ResearchDemandAdd(researchtype, val)
		end
	end
end

function inc_upgrade_demand(upgradetype, val)	
	inc_research_demand(upgradetype, val)
end

