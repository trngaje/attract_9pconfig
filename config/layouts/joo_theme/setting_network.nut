/*
squirrel file for attractmode
network setting with nmcli
*/

fe.layout.font="font.ttf";

local options = ["+Wifi 연결 추가"];

function any_command_callback( tt )
{
	options.append(tt);
};

fe.plugin_command( "nmcli", " -g name connection show", "any_command_callback" );
//fe.plugin_command( "nmcli", " -g uuid connection show", "any_command_callback" );

options.append("취소");
local wifi_ssid_name = "";
local command = fe.overlay.list_dialog( options,  "네트워크 연결");
if( command == 0 )	{
	options.clear();
	fe.plugin_command( "nmcli", "-g ssid device wifi list", "any_command_callback" );
	local num_of_wifi = options.len();
	options.append("취소");
	local wifi_menu = fe.overlay.list_dialog( options,  "Wifi 선택" + format("(%d)", num_of_wifi));
	if (num_of_wifi > 0 && wifi_menu < num_of_wifi)
	{
		wifi_ssid_name = rstrip(options[wifi_menu]); // have to remove white space
	}
}
else {
	
}

if (wifi_ssid_name.len() > 0) {
	// display keyboard to input password
	local wifissid = fe.add_text(wifi_ssid_name, 0, 20, 480, 30 ); 
	wifissid.set_rgb( 0, 255, 0);
	wifissid.set_bg_rgb( 0, 0, 0);
	wifissid.bg_alpha = 255;
	wifissid.charsize = 30;
	wifissid.align = Align.Left;
	wifissid.visible = true;	
	
	local password = fe.add_text( "", 0, 50, 480, 50 ); 
	password.set_rgb( 255, 255, 255);
	password.set_bg_rgb( 0, 0, 0);
	password.bg_alpha = 255;
	password.charsize = 20;
	password.align = Align.Left;
	password.visible = true;


	local keybutton_str = ["1","2","3","4","5","6","7","8","9","0",
						   "A","B","C","D","E","F","G","H","I","J",
						   "K","L","M","N","O","P","Q","R","S","T",
						   "U","V","W","X","Y","Z","","","←","완"];

	local keybutton_text = array(40);

	for(local i=0; i<40; i++){
		keybutton_text[i] = fe.add_text( keybutton_str[i], (i%10) * 48, 100+ (i/10) * 48, 48, 48 ); 
		keybutton_text[i].set_rgb( 255, 255, 255);
		keybutton_text[i].set_bg_rgb( 0, 0, 0);
		keybutton_text[i].bg_alpha = 255;
		keybutton_text[i].charsize = 30;
		keybutton_text[i].align = Align.MiddleCentre;
		keybutton_text[i].visible = true;
	}

	local index=0;
	local password_str="";
	local password_input = array(40);
	local password_input_cnt=0;

	function updatekeyposition()
	{
		for(local j=0; j<40; j++) {
			if (j == index) {
				keybutton_text[j].set_bg_rgb( 0, 0, 255);
			}
			else {
				keybutton_text[j].set_bg_rgb( 0, 0, 0);
			}
		}
	}

	updatekeyposition();

	function get_password_str(opt_hide)
	{
		local str="";
		for(local i=0; i<password_input_cnt; i++) {
			//if (i==0)
			//	str=password_input[i];
			//else 
			if (!opt_hide || i==(password_input_cnt - 1))
				str+=password_input[i];
			else
				str+= "*";
		}
		return str;
	}
	
	fe.add_signal_handler( "on_signal" );
	function on_signal( sig )
	{
		switch ( sig )	
		{
			case "up":				
				index = (index + 40 - 10) % 40;
				updatekeyposition();	
				return true;
			case "down":
				index = (index + 10) % 40;
				updatekeyposition();	
				return true;	
			case "left":
				index = (index / 10) * 10 + (10 + index % 10 -1) % 10;
				updatekeyposition();	
				return true;
			case "right":
				index = (index / 10) * 10 + (index % 10 + 1) % 10;
				updatekeyposition();	
				return true;
			case "select":
				if (index == 39) {
					// enter
					//nmcli dev wifi connect network-ssid password "network-password"
					/*
					for(local i=0; i<password_input_cnt; i++) {
						if (i==0)
							password_str=password_input[i];
						else 
							password_str+=password_input[i];
					}
					*/
					password_str = get_password_str(false);
					
					options.clear();
					fe.plugin_command( "nmcli", format("dev wifi connect %s password %s", wifi_ssid_name, password_str), "any_command_callback" );
					//fe.plugin_command( "nmcli", "dev wifi connect U+NetC483 password 4000002585", "any_command_callback" );

					fe.remove_signal_handler("on_signal");
				}
				else if (password_input_cnt < 40)
				{
					password_input[password_input_cnt] = keybutton_str[index];
					password_input_cnt++;
					/*
					for(local i=0; i<password_input_cnt; i++) {
						if (i==0)
							password_str=password_input[i];
						else 
							password_str+=password_input[i];
					}
					*/
					password_str = get_password_str(true);
					password.msg = password_str;
				}
				return true;
			case "back":
				if (password_input_cnt > 0)
				{
					password_input_cnt--;

					/*
					for(local i=0; i<password_input_cnt; i++) {
						if (i==0)
							password_str=password_input[i];
						else 
							password_str+=password_input[i];
					}
					*/
					password_str = get_password_str(true);
					password.msg = password_str;				
				}
				return true;
		}	

		return false;
	}
}
