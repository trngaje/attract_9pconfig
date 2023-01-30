/*
squirrel file for attractmode
bluetooth setting with bluetoothctl
*/

//fe.layout.font="font.ttf";

local options = [""];

options.clear();

function any_command_callback( tt )
{
	options.append(tt);
};

//fe.plugin_command( "bash", "/home/odroid/blue.sh", "any_command_callback" );
fe.plugin_command( "bash", "btctrl.sh", "any_command_callback" );

local num_of_bt_devices = options.len();
options.append("취소");

local command = fe.overlay.list_dialog( options,  "BT 장치 목록");
local bt_device;
local bt_mac_address;
local bt_name;
if( num_of_bt_devices > 0 && command < num_of_bt_devices )	{
	bt_device = rstrip(options[command]); // have to remove white space

	local bt_device_str = split(bt_device," ");
	bt_mac_address = bt_device_str[0];
	bt_name = bt_device_str[1];

	local btoptions = ["pair", "trust", "connect", "disconnect", "취소"];	
	local btcommand = fe.overlay.list_dialog( btoptions,  bt_mac_address);
	
	if ( btcommand == 0 )
	{
		fe.plugin_command( "/bin/sh", "-c \"bluetoothctl pair " + bt_mac_address + "\"");
	}
	else if (btcommand == 1)
	{
		fe.plugin_command( "/bin/sh", "-c \"bluetoothctl trust " + bt_mac_address + "\"");
	}
	else if (btcommand == 2)
	{
		fe.plugin_command( "btconnect.sh", bt_mac_address);	
	}
	else if (btcommand == 3)
	{
		fe.plugin_command( "/bin/sh", "-c \"bluetoothctl disconnect " + bt_mac_address + "\"");
	}
}
else {
	
}

if (bt_mac_address.len() > 0) {

}
