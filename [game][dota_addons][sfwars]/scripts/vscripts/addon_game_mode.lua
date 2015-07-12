-- Generated from template

if CSfwarsGameMode == nil then
	CSfwarsGameMode = class({})
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
	print( "Template addon is loaded." )
	

	---------------------------------------------------------------------------------------
	--设置队伍颜色
	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 52, 85, 255 }	--		Teal
	self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }		--		Yellow
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 61, 210, 150 }		--		Blue
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }		--		Brown
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan
	self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }	--		Olive
	self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }	--		Purple
	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	self.TEAM_KILLS_TO_WIN = 20
	

	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetRuneSpawnTime( 15 )
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
	GameRules:GetGameModeEntity():SetRuneEnabled( 0, false ) --Double Damage

	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	GameRules:GetGameModeEntity():SetBuybackEnabled( false )
	GameRules:GetGameModeEntity():SetRecommendedItemsDisabled( true )
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 10 )
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( CSfwarsGameMode, "BountyRunePickupFilter" ), self )
	GameRules:GetGameModeEntity():SetRuneSpawnFilter( Dynamic_Wrap( CSfwarsGameMode, "FilterRuneSpawn" ), self )
	
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CSfwarsGameMode, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(CSfwarsGameMode, "OnNPCSpawned"), self)
	
	
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
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
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		if numberOfPlayers > 7 then
			self.TEAM_KILLS_TO_WIN = 30
		elseif numberOfPlayers > 4 and numberOfPlayers <= 7 then
			self.TEAM_KILLS_TO_WIN = 25
		else
			self.TEAM_KILLS_TO_WIN = 20
		end

		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } )
	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then

	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

	end
end

--------------------------------------------------------------------------------
-- Event: BountyRunePickupFilter
--------------------------------------------------------------------------------
function CSfwarsGameMode:BountyRunePickupFilter( filterTable )
    filterTable["xp_bounty"] = 2*filterTable["xp_bounty"]
    filterTable["gold_bounty"] = 0.2*filterTable["gold_bounty"]
    return true
end
function CSfwarsGameMode:FilterRuneSpawn( filterTable )

		if ( tostring( filterTable["rune_type"] ) == "0" ) then
			return false
		else
			return true
		end


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
