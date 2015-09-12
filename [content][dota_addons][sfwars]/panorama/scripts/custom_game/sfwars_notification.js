"use strict";
function OnNotificationShop()
{
	$.GetContextPanel().SetHasClass( "showcontent", true );
	GameUI.PingMinimapAtLocation( "2368 -2368 128" );
	GameUI.PingMinimapAtLocation( "-2368 2368 128" );
	$( "#NtText" ).html = true;
	$( "#NtText" ).text = "商店已在小地图上标出，请注意查看";

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

