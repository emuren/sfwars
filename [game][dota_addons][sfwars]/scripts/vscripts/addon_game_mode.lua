-- Generated from template

if CSfwarsGameMode == nil then
	CSfwarsGameMode = class({})
end

require("game_init")

if temp_flag == nil then
	temp_flag = 0
end
function PrecacheEveryThingFromKV( context )
	local kv_files = {"scripts/npc/npc_units_custom.txt","scripts/npc/npc_abilities_custom.txt","scripts/npc/npc_heroes_custom.txt","scripts/npc/npc_abilities_override.txt","scripts/npc/npc_items_custom.txt"}
	for _, kv in pairs(kv_files) do
		local kvs = LoadKeyValues(kv)
		if kvs then
			print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
			PrecacheEverythingFromTable( context, kvs)
		end
	end
    print("done loading shiping")
end
function PrecacheEverythingFromTable( context, kvtable)
	for key, value in pairs(kvtable) do
		if type(value) == "table" then
			PrecacheEverythingFromTable( context, value )
		else
			if string.find(value, "vpcf") then
				PrecacheResource( "particle",  value, context)
				print("PRECACHE PARTICLE RESOURCE", value)
			end
			if string.find(value, "vmdl") then 	
				PrecacheResource( "model",  value, context)
				print("PRECACHE MODEL RESOURCE", value)
			end
			if string.find(value, "vsndevts") then
				PrecacheResource( "soundfile",  value, context)
				print("PRECACHE SOUND RESOURCE", value)
			end
		end
	end

   
end
function Precache( context )
	print("BEGIN TO PRECACHE RESOURCE")
	local time = GameRules:GetGameTime()
	PrecacheEveryThingFromKV( context )
	PrecacheUnitByNameSync("npc_dota_hero_nevermore", context)
	time = time - GameRules:GetGameTime()
	print("DONE PRECACHEING IN:"..tostring(time).."Seconds")
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CSfwarsGameMode()
	GameRules.AddonTemplate:InitGameMode()
end



function CSfwarsGameMode:InitGameMode()

	XP_PER_LEVEL_TABLE = {
		0,240,480,740,1040,
		1360,1680,2120,2520,3000,
		3100,3200,3400,3500,4200,
		5000,6000,7100,8500,10000,
		12000,14000,16000,18000,21000
	}

	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetUseBaseGoldBountyOnHeroes( true )
	GameRules:SetRuneSpawnTime( 60 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )


	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	GameRules:GetGameModeEntity():SetBuybackEnabled( false )
	GameRules:GetGameModeEntity():SetRecommendedItemsDisabled( true )
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 10 )
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( CSfwarsGameMode, "BountyRunePickupFilter" ), self )
	GameRules:GetGameModeEntity():SetRuneSpawnFilter( Dynamic_Wrap( CSfwarsGameMode, "FilterRuneSpawn" ), self )
	
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CSfwarsGameMode, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap(CSfwarsGameMode, "OnPlayerPickHero"), self)
	ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( CSfwarsGameMode, 'OnTeamKillCredit' ), self )
    --ListenToGameEvent( "player_disconnect", Dynamic_Wrap(CSfwarsGameMode, "OnPlayerDisconnect"), self)
	--ListenToGameEvent( "player_reconnect", Dynamic_Wrap(CSfwarsGameMode, "OnPlayerReconnect"), self)
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	--初始化游戏
	if temp_flag == 0 then
		_InitGameStats()
		temp_flag =1
	end
	
end

-- Evaluate the state of the game
function CSfwarsGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function CSfwarsGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	--print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then

	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		_GameStats['number_of_players'] = PlayerResource:GetPlayerCount()
		if _GameStats['number_of_players'] > 7 then
			_GameStats['score_to_win'] = 30
		elseif _GameStats['number_of_players'] > 4 and _GameStats['number_of_players'] <= 7 then
			_GameStats['score_to_win'] = 25
		else
			_GameStats['score_to_win'] = 20
		end
		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = _GameStats['score_to_win'] } )
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		 _NotificationShop()
	end
end

--------------------------------------------------------------------------------
-- Event: BountyRunePickupFilter
--------------------------------------------------------------------------------
function CSfwarsGameMode:BountyRunePickupFilter( filterTable )
    filterTable["xp_bounty"] = 120
    filterTable["gold_bounty"] = 100
    return true
end
function CSfwarsGameMode:FilterRuneSpawn( filterTable )
	local sfwars_rune_type =  math.random( 5 ) 
	if  sfwars_rune_type == 2 or sfwars_rune_type == nil then
		sfwars_rune_type = 5
	end
	filterTable["rune_type"] = sfwars_rune_type
	return true
end

function CSfwarsGameMode:OnPlayerPickHero(keys)
	local unit =  EntIndexToHScript(keys.heroindex)
	if unit:IsHero() then                      --如果是英雄
		local nPlayerid = unit:GetPlayerID()
		local temp_auto6=unit:GetAbilityByIndex(3)
		local temp_auto7=unit:GetAbilityByIndex(4)
		temp_auto6:SetLevel(1)
		temp_auto7:SetLevel(1)
		unit:SetModifierStackCount("modifier_nevermore_necromastery",nil,36) 
		_UpdatePlayerColor( nPlayerid )
	end
end

function CSfwarsGameMode:OnTeamKillCredit( event )
	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	local nTeamKills = event.herokills
	local nKillsRemaining = _GameStats['score_to_win'] - nTeamKills
	
	local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		team_kills = nTeamKills,
		kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}
	
	if nKillsRemaining <= 0 then
		GameRules:SetCustomVictoryMessage( _GameStats["team_win_message"][nTeamID] )
		GameRules:SetGameWinner( nTeamID )
		broadcast_kill_event.victory = 1
	elseif nKillsRemaining == 1 then
		broadcast_kill_event.very_close_to_victory = 1
	elseif nKillsRemaining > 0 and nKillsRemaining <= 5 then
		broadcast_kill_event.close_to_victory = 1
	end
	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

--[[function CSfwarsGameMode:OnPlayerDisconnect( keys )
    local unit =  PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
	if unit:IsHero() then                    
		unit:AddNewModifier(unit, nil, "modifier_invulnerable", nil)
	end
end

function CSfwarsGameMode:OnPlayerReconnect( keys )
    local unit =  PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
	if unit:IsHero() then                    
		unit:RemoveModifierByName("modifier_invulnerable")
	end
end
]]