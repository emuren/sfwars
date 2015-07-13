-- Generated from template

if CSfwarsGameMode == nil then
	_G.CSfwarsGameMode = class({})
end

require("game_init")

if temp_flag == nil then
	temp_flag = 0
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CSfwarsGameMode()
	GameRules.AddonTemplate:InitGameMode()
end



function CSfwarsGameMode:InitGameMode()

	XP_PER_LEVEL_TABLE = {
		0,100,200,350,500,
		650,800,1000,1200,1500,
		1800,2200,2800,3500,4200,
		5000,6000,7100,8500,10000,
		12000,14000,16000,18000,21000
	}

	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetUseBaseGoldBountyOnHeroes( true )
	GameRules:SetRuneSpawnTime( 30 )
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
	GameRules:GetGameModeEntity():SetStashPurchasingDisabled( true )
	GameRules:GetGameModeEntity():SetRecommendedItemsDisabled( true )
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 10 )
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( CSfwarsGameMode, "BountyRunePickupFilter" ), self )
	GameRules:GetGameModeEntity():SetRuneSpawnFilter( Dynamic_Wrap( CSfwarsGameMode, "FilterRuneSpawn" ), self )
	
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CSfwarsGameMode, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap(CSfwarsGameMode, "OnNPCSpawned"), self)
	ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( CSfwarsGameMode, 'OnTeamKillCredit' ), self )

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	--初始化游戏
	if temp_flag == 0 then
		CSfwarsGameMode:_InitGameStats()
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
	end
end

--------------------------------------------------------------------------------
-- Event: BountyRunePickupFilter
--------------------------------------------------------------------------------
function CSfwarsGameMode:BountyRunePickupFilter( filterTable )
    filterTable["xp_bounty"] = 50
    filterTable["gold_bounty"] = 20
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

function CSfwarsGameMode:OnNPCSpawned(keys)
	local unit =  EntIndexToHScript(keys.heroindex)
	if unit:IsHero() then                      --如果是英雄
		local temp_auto6=unit:GetAbilityByIndex(3)
		local temp_auto7=unit:GetAbilityByIndex(4)
		temp_auto6:SetLevel(1)
		temp_auto7:SetLevel(1)
		unit:SetModifierStackCount("modifier_nevermore_necromastery",nil,36) 
	end
end

function CSfwarsGameMode:OnTeamKillCredit( event )
	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	local nTeamKills = event.herokills
	local nKillsRemaining = _GameStats['score_to_win'] - nTeamKills
	if nKillsRemaining <= 0 then
		GameRules:SetCustomVictoryMessage( _GameStats["team_win_message"][nTeamID] )
		GameRules:SetGameWinner( nTeamID )
	end
end

