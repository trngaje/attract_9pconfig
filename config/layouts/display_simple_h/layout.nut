fe.layout.width=854;
fe.layout.height=480;

fe.layout.font="font.ttf";

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

local bb = fe.add_text("",0,0,flw,fly);
bb.set_bg_rgb( 220, 220, 220);


local imageW = 200;
local centerP = 427-(imageW/2);
local padding = 3;


local snapAlpha = 100;
local logoAlpha = 120;

local snap1 = fe.add_image("./background/[Title].png", 	centerP-(imageW*2)-padding*2,	0,	imageW,		fly);
local snap2 = fe.add_image("./background/[Title].png", 	centerP-(imageW)-padding, 	0, 	imageW, 	fly);
local snap3 = fe.add_image("./background/[Title].png", 	centerP,			0, 	imageW, 	fly);
local snap4 = fe.add_image("./background/[Title].png", 	centerP+(imageW)+padding, 	0, 	imageW, 	fly);
local snap5 = fe.add_image("./background/[Title].png", 	centerP+(imageW*2)+padding*2, 	0, 	imageW, 	fly);

snap1.index_offset=-2;
snap2.index_offset=-1;
snap3.index_offset=0;
snap4.index_offset=1;
snap5.index_offset=2;

snap1.alpha=snapAlpha ;
snap2.alpha=snapAlpha ;
//snap3.alpha=255;
snap4.alpha=snapAlpha ;
snap5.alpha=snapAlpha ;

snap1.preserve_aspect_ratio = false;
snap2.preserve_aspect_ratio = false;
snap3.preserve_aspect_ratio = false;
snap4.preserve_aspect_ratio = false;
snap5.preserve_aspect_ratio = false;

//snap1.skew_x = 50;
//snap2.skew_x = 50;
//snap3.skew_x = 50
//snap4.skew_x = 50;
//snap5.skew_x = 50;



local logo1 = fe.add_image("./logo/[Title].png", 	centerP-(imageW*2)-padding*2,	350, 	imageW, 	150);
local logo2 = fe.add_image("./logo/[Title].png", 	centerP-(imageW)-padding,	350, 	imageW, 	150);
local logo4 = fe.add_image("./logo/[Title].png", 	centerP+(imageW)+padding,	350, 	imageW, 	150);
local logo5 = fe.add_image("./logo/[Title].png", 	centerP+(imageW*2)+padding*2,	350, 	imageW, 	150);
local logo3 = fe.add_image("./logo/[Title].png", 	centerP-(imageW/2),		220, 	imageW*2, 	150);

logo1.index_offset=-2;
logo2.index_offset=-1;
logo3.index_offset=-0;
logo4.index_offset=1;
logo5.index_offset=2;

logo1.alpha=logoAlpha;
logo2.alpha=logoAlpha;
//logo3.alpha=255;
logo4.alpha=logoAlpha;
logo5.alpha=logoAlpha;

logo1.preserve_aspect_ratio = true;
logo2.preserve_aspect_ratio = true;
logo3.preserve_aspect_ratio = true;
logo4.preserve_aspect_ratio = true;
logo5.preserve_aspect_ratio = true;



//local controller = fe.add_artwork("controller", 660, 320, 170, 170);
//local controller = fe.add_image("./controller/[Title].png", 660, 320, 170, 170);
//controller.preserve_aspect_ratio = true;

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
			fe.signal( "up" );
			return true;
		case "right":		// right 버튼 조작시 발생
			fe.signal( "down" );
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

