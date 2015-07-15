"use strict";

function UpdateTimer( data )
{
	var timerValue = Game.GetDOTATime(false,false);
	var sec = Math.floor( timerValue % 60 );
	var min = Math.floor( timerValue / 60 );

	var timerText = "";
	if ( min < 10 )
	{
		timerText += "0";
	}
	timerText += min;
	timerText += ":";
	if ( sec < 10 )
	{
		timerText += "0";
	}
	timerText += sec;

	$( "#Timer" ).text = timerText;

	$.Schedule( 0.2, UpdateTimer );
}


function UpdateKillsToWin()
{
	var victory_condition = CustomNetTables.GetTableValue( "game_state", "victory_condition" );
	if ( victory_condition )
	{
		$("#VictoryPoints").text = victory_condition.kills_to_win;
	}
}


(function()
{
	UpdateKillsToWin();
	UpdateTimer();
})();

