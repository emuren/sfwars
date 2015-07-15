--游戏初始化
function _InitGameStats()
--定义随机数种子
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','') 
	math.randomseed(tonumber(timeTxt))
--初始化游戏表
   _PlayerStats={}
   _GameStats={}
   _GameStats['number_of_players'] = 10
   _GameStats['score_to_win'] = 25
   for i=0,9 do
     _PlayerStats[i]={}  --每个玩家的数据包
     _PlayerStats[i]['score']=0
   end
 --设置队伍血条颜色
	_GameStats["team_color"]={}
	_GameStats["team_color"][DOTA_TEAM_GOODGUYS] = { 52, 85, 255 }	--		lan
	_GameStats["team_color"][DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }	--		fen
	_GameStats["team_color"][DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      qing
	_GameStats["team_color"][DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	_GameStats["team_color"][DOTA_TEAM_CUSTOM_3] = { 61, 210, 150 }		--		Blue
	_GameStats["team_color"][DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	_GameStats["team_color"][DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }		--		Brown
	_GameStats["team_color"][DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan
	_GameStats["team_color"][DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }	--		Olive
	_GameStats["team_color"][DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }	--		Purple zi
	
	for team = 0, (DOTA_TEAM_COUNT-1) do
		local color = _GameStats["team_color"][ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end
--设置队伍胜利信息
	_GameStats["team_win_message"] = {}
	_GameStats["team_win_message"][DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	_GameStats["team_win_message"][DOTA_TEAM_BADGUYS]  = "#VictoryMessage_BadGuys"
	_GameStats["team_win_message"][DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"
	_GameStats["team_win_message"][DOTA_TEAM_CUSTOM_2] = "#VictoryMessage_Custom2"
	_GameStats["team_win_message"][DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	_GameStats["team_win_message"][DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	_GameStats["team_win_message"][DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	_GameStats["team_win_message"][DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"
	_GameStats["team_win_message"][DOTA_TEAM_CUSTOM_7] = "#VictoryMessage_Custom7"
	_GameStats["team_win_message"][DOTA_TEAM_CUSTOM_8] = "#VictoryMessage_Custom8"

end
function _UpdatePlayerColor( nPlayerID )
	if nPlayerID == nil then
		return
	end
	local teamID = PlayerResource:GetTeam( nPlayerID )
	local color = _GameStats["team_color"][teamID]
	if color then
		PlayerResource:SetCustomPlayerColor( nPlayerID, color[1], color[2], color[3] )
	end
end

function _NotificationShop()
	CustomUI:DynamicHud_Create(-1,"mainWin","file://{resources}/layout/custom_game/sfwars_notification.xml",nil)
end
	
