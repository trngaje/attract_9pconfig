class UserConfig {

	</ label="상단 상태바", help="와이파이, 소리, 밝기, 배터리 상태", options="Y,N", order=1 /> topBar="Y";
	</ label="하단 설명바", help="조작 설명", options="Y,N", order=2 /> bottomBar="Y";
}


// UserConfig 로드
local my_config = fe.get_config();


if ( my_config["topBar"] == "Y" )
{
	// OGA 상태바
	local statusBar = fe.add_text("", 0, 0, 480 + 374, 15);
	statusBar.set_bg_rgb( 0, 0, 1);
	statusBar.bg_alpha = 200;

	local clock = fe.add_text( "", 10, -2, 100, 18 );
	clock.align = Align.Left;


	local romiconText = fe.add_text( "-", 135+187, -2, 45, 18 );

	local wifiIcon = fe.add_image( "icon/wifi_white.png", 270, 0, 20, 15 );
	wifiIcon.visible=false;

	local ipText = fe.add_text( "-", 290, -2, 137, 18 );
	ipText.align = Align.Left;

	local soundIcon = fe.add_image( "icon/sound_white.png", 680, 0, 15, 15 );
	local soundText = fe.add_text( "-", 685, -2, 45, 18 );
	soundText.align = Align.Right;

	local brightIcon  = fe.add_image( "icon/bright_white.png", 740, 0, 15, 15 );
	local brightText = fe.add_text( "-", 745, -2, 45, 18 );
	brightText.align = Align.Right;

	local batteryIcon= fe.add_image( "icon/battery_nocharging_white.png", 800, 0, 10, 15 );
	//batteryIcon.preserve_aspect_ratio = false;
	local batteryText= fe.add_text( "-" , 805, -2, 45, 18 );
	batteryText.align = Align.Right;

	local cpufreqText= fe.add_text( "-" , 430, -2, 100, 18 );
	cpufreqText.align = Align.Right;

	local tempText= fe.add_text( "-" , 530, -2, 100, 18 );
	tempText.align = Align.Right;



	local output="";
	function any_command_callback( tt )
	{
		//output = rstrip( tt ) + "\n";
		output = rstrip( tt );
	};


	local now = date();
	local hour = format("%02d", now.hour ).tointeger();
	local min =  format("%02d", now.min ).tointeger();
	local sec =  format("%02d", now.sec ).tointeger();

	if ( !ScreenSaverActive )
	{
		clock.msg = "" + format("%02d", now.hour) + ":" + format("%02d", now.min );
		clock.visible=true;
	}
	else
	{
		clock.visible=false;
	}

	fe.add_ticks_callback( this, "fnc_ogaStatus" );
	local fflag = true;
	function fnc_ogaStatus( ttime )
	{
			if( fe.get_input_state( "Joy0 Button8" ) || fe.get_input_state( "Joy0 Button9" ) || fe.get_input_state( "Joy0 Button14" ) || fe.get_input_state( "Joy0 Button15" ) )
			{
				ogaStatus();
			}

			now = date();
			hour = format("%02d", now.hour ).tointeger();
			min =  format("%02d", now.min ).tointeger();
			sec =  format("%02d", now.sec ).tointeger();
			local secCheck = format("%d", now.sec );
			
			if( secCheck == "0" && fflag)
			{
				clock.msg = "" + format("%02d", now.hour) + ":" + format("%02d", now.min );		
				ogaStatus();
				fflag = false;
			}
			if( secCheck == "1" && fflag == false )
				fflag = true;

	}

	function ogaStatus()
	{
		fe.plugin_command( "/bin/sh", "-c \"echo `amixer sget Playback | grep 'Right:' | awk -F'[][%]' '{ print $2 }'`\"", "any_command_callback" );
		soundText.msg = output;
		//soundText.msg = 100;
		fe.plugin_command( "/bin/sh", "-c \"expr `cat /sys/class/backlight/backlight/brightness` \\* 100 / 160\"", "any_command_callback" );
		brightText.msg = output;
		//brightText.msg = 100;
		fe.plugin_command( "/bin/sh", "-c \"cat /sys/class/power_supply/battery/capacity\"", "any_command_callback" );
		batteryText.msg = output;
		//batteryText.msg = 100;

		fe.plugin_command( "/bin/sh", "-c "+ fe.script_dir + "/cpufreq.sh", "any_command_callback" );
		cpufreqText.msg = output;

		fe.plugin_command( "/bin/sh", "-c " + fe.script_dir + "/temp.sh", "any_command_callback" );
		tempText.msg = output;



		fe.plugin_command( "/bin/sh", "-c \"cat /sys/class/power_supply/battery/status\"", "any_command_callback" );
		if( output.find("Charging") != null )
			batteryIcon.file_name = "icon/battery_charging_white.png";
		else
			batteryIcon.file_name = "icon/battery_nocharging_white.png";
			


		fe.plugin_command( "/bin/sh", "-c \"cat /sys/class/net/wlan0/operstate\"", "any_command_callback" );
		if( output.find("up") != null  )
			wifiIcon.visible=true;
		else
			wifiIcon.visible=false;
		
		fe.plugin_command( "/bin/sh", "-c \"hostname -I\"", "any_command_callback" );
		ipText.msg = output;
/*
		fe.plugin_command( "/bin/sh", "-c \"sudo find /mnt/ -maxdepth 1 -name 9p\"", "any_command_callback" );
		if( output.find("9p") != null )
			romiconText.msg = "USB";
		else
*/
			romiconText.msg = "";

		//print("ogaStatus\n");
		
	}

	ogaStatus();

}


if ( my_config["bottomBar"] == "Y" )
{
	if ( (fe.list.name == "Displays Menu") || ScreenSaverActive )
	{
	}
	else
	{
		// 하단 설명 바
		local a = fe.add_image("icon/a.png", 500, 450, 30, 30);
		local b = fe.add_image("icon/b.png", 620, 450, 30, 30);
		local f3 = fe.add_image("icon/f3.png", 730, 450, 30, 30);
		//local x = fe.add_image("icon/x.png", 660, 450, 30, 30);

		local bottomBar = fe.add_text("           선택                뒤로               도움말", 480, 450, 500, 27);
		bottomBar.charsize = 20;								// 폰트 크기	
		bottomBar.align = Align.Left;
		//bottomBar.set_bg_rgb( 255, 255, 255);
		//bottomBar.set_rgb( 0, 0, 1 );						// 폰트 색상
		//bottomBar.align = Align.Left;							// 정렬
		//bottomBar.bg_alpha = 200;

	}
}




fe.add_signal_handler(  "on_signal2" );
function on_signal2( sig )
{
	switch ( sig )	
	{
		case "custom4":
			local optionsSubMenu = ["블루투스 설정", "와이파이 설정", "전원 끄기", "취소"];
			local command = fe.overlay.list_dialog( optionsSubMenu,  "메뉴를 선택해 주세요?");
			
			if ( command == 0 )
			{
				fe.do_nut("/home/odroid/.attract/plugins/setting_bt.nut");
			}
			else if ( command == 1 )
			{
				fe.do_nut("/home/odroid/.attract/plugins/setting_network.nut");
			}			
			else if( command == 2 )	
			{
				fe.plugin_command( "/bin/sh", "-c \"sudo shutdown -h now\"");
			}
				
			return true;
				
//			fe.do_nut("setting_network.nut");
			return true;
//		case "custom5":
//			fe.do_nut("setting_bt.nut");
//			return true;

	}

	

	
	return false;
}