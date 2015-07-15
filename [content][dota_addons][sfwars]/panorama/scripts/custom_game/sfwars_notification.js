"use strict";
function OnNotificationShop()
{
	$.GetContextPanel().SetHasClass( "showcontent", true );
	GameUI.PingMinimapAtLocation( "4416 1984 128" );
	GameUI.PingMinimapAtLocation( "-1472 -1280 128" );
	$( "#NtText" ).html = true;
	$( "#NtText" ).text = "商店已在小地图上标出，请注意查看\n神符刷新点位于地图中间的高地";

	$.Schedule( 5, ClearNotificationShop );
	
}
function ClearNotificationShop()
{
	$.GetContextPanel().SetHasClass( "showcontent", false );
	$( "#NtText" ).html = false;
	$( "#NtText" ).text = "";
}
(function()
{
	OnNotificationShop();
})();

