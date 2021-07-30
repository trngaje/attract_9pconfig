//
// Attract-Mode Front-End - "Basic" sample layout
//

//fe.load_module("file");
//fe.load_module("file-format");

fe.layout.width=854;
fe.layout.height=480;

fe.layout.font="font.ttf";

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

//local t = fe.add_artwork( "snap", 0, 0, flw, flh );
local t = fe.add_image( "./background/[Title].png", 0, 0, flw, flh );
t.trigger = Transition.EndNavigation;

local overlay = fe.add_image( "overlay.png", 0, 0, flw, fly);
overlay.alpha=200;

/*
local list1 = fe.add_artwork("wheel", 	20,	20,	220,	100);
local list2 = fe.add_artwork("wheel", 	20, 	110, 	220, 	100);
local list4 = fe.add_artwork("wheel", 	20, 	290, 	220, 	100);
local list5 = fe.add_artwork("wheel", 	20, 	380, 	220, 	100);
local list3 = fe.add_artwork("wheel", 	70, 	180, 	400, 	150);
*/

local list1 = fe.add_image("./logo/[Title].png", 	20,	20,	220,	100);
local list2 = fe.add_image("./logo/[Title].png", 	20, 	110, 	220, 	100);
local list4 = fe.add_image("./logo/[Title].png", 	20, 	290, 	220, 	100);
local list5 = fe.add_image("./logo/[Title].png", 	20, 	380, 	220, 	100);
local list3 = fe.add_image("./logo/[Title].png", 	70,	180, 	400, 	150);

/*
local list3 = fe.add_image( "[!aaaa]",  	70,	180, 	400, 	150);
function aaaa( ioffset )
{
	local title = fe.game_info(  Info.Title , ioffset  );
	if(  title == "mame-advmame" || title == "nds" )
		return "./logo/"+title+".png";
	else
		return "./logo/exit.png";
}
*/

list1.index_offset=-2;
list2.index_offset=-1;
list3.index_offset=0;
list4.index_offset=1;
list5.index_offset=2;

list1.alpha=130;
list2.alpha=130;
list3.alpha=255;
list4.alpha=130;
list5.alpha=130;

list1.preserve_aspect_ratio = true;
list2.preserve_aspect_ratio = true;
list3.preserve_aspect_ratio = true;
list4.preserve_aspect_ratio = true;
list5.preserve_aspect_ratio = true;


//local controller = fe.add_artwork("controller", 660, 320, 170, 170);
local controller = fe.add_image("./controller/[Title].png", 660, 320, 170, 170);
controller.preserve_aspect_ratio = true;

local helpImage = fe.add_image( "./help/help.png", flw*0.05, fly*0.05, flw *0.9, fly*0.9);
helpImage.preserve_aspect_ratio = true;
helpImage.visible=false;


// 조작 시그널 핸들러 
fe.add_signal_handler(  "on_signal" );
function on_signal( sig )
{
	//bgColor.bg_alpha = 255;
	switch ( sig )	
	{
		case "left":		// up 버튼 조작시 발생
			//fe.signal( "prev_page" );
			return true;
		case "right":		// right 버튼 조작시 발생
			//fe.signal( "next_page" );
			return true;
		case "custom3":
			if( helpImage.visible )
			{
				helpImage.visible=false;			
			}
			else
			{
				helpImage.visible=true;
			}
			return true;
		case "custom6":
			fe.signal("screen_saver");
			return true;
		case "back":
			if( helpImage.visible )
				helpImage.visible=false;
			else
				fe.signal("reload");
			return true;


	}
	return false;
}
