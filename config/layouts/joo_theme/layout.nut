//////////////////////////////////////////////////////
//													//
// Attract-Mode Frontend - joo Theme				//
// made by sana2dang	( 구퓌 )						//
// sana2dang@naver.com								//
//////////////////////////////////////////////////////

class UserConfig { 
	</ label="게임 실행여부 확인", help="실행여부 Y, N)", options="Y,N", order=1 /> playConfirm = "Y";
	</ label="Marquee 표시 여부", help="실행여부 Y, N)", options="Y,N", order=2 /> marqueeYn = "Y";	
	</ label="즐겨찾기 색상 (R) (0-255) Color", help="즐겨찾기 색상 Red 값", option="54", order=3 /> favoriteR=255;
	</ label="즐겨찾기 색상 (G) (0-255) Color", help="즐겨찾기 색상 Green 값", option="138", order=4 /> favoriteG=255;
	</ label="즐겨찾기 색상 (B) (0-255) Color", help="즐겨찾기 색상 Blue 값", option="255", order=5 />  favoriteB=255;
}

// module 로드
fe.load_module("animate");
fe.load_module("file");
fe.load_module("file-format");


// UserConfig 로드
local my_config = fe.get_config();


// 레이아웃 해상도 설정
local customRate = 1;
local monitor_width = 	854/customRate;		// 레이아웃 width
local monitor_height = 	480/customRate;		// 레이아웃 height


fe.layout.width =  monitor_width;	// Set 레이아웃 해상도 width
fe.layout.height = monitor_height;	// Set 레이아웃 해상도 height
//fe.layout.preserve_aspect_ratio = false;


fe.layout.font="font.ttf";
//fe.layout.font="NANUMBARUNGOTHICBOLD.TTF";



fe.list.filter_index=0;

// 커서이동시 사운드 발생.png
function move_sound()
{
	local selectMusic = fe.add_sound("select.mp3");
	selectMusic.playing=true;
}


// 백그라운드 이미지 설정
fe.add_image( "ui/background.png", 0, 0, fe.layout.width, fe.layout.height); 

local snap = fe.add_artwork( "snap", monitor_width/1.8/customRate, 110/customRate, monitor_width/2.2/customRate, 300/customRate );
snap.preserve_aspect_ratio = false;
snap.trigger = Transition.EndNavigation;
snap.video_flags=Vid.NoLoop;
//snap.video_flags=Vid.ImagesOnly;


// 리스트박스 
local bgColor = fe.add_text( "", 0/customRate, 0, monitor_width/1.8/customRate, monitor_height/customRate );
bgColor.set_bg_rgb( 0, 0, 10);					// 리스트 박스 뒷 배경 색상
bgColor.bg_alpha = 100;							// 선택 리스트 배경 투명도

local listbox = fe.add_listbox( 0/customRate, 90/customRate, monitor_width/1.8/customRate, monitor_height-90/customRate );	// 리스트 박스 생성
listbox.charsize = 27/customRate;								// 폰트 크기
listbox.align = Align.MiddleLeft;					// 리스트 정렬
listbox.set_rgb( 255, 255, 255 );				// 리스트 전체 폰트 색상
//listbox.set_sel_rgb( 255, 255, 255 );				// 선택 리스트 폰트 색상
//listbox.set_selbg_rgb( 255, 255, 255 );				// 선택 리스트 배경 색상
listbox.set_sel_rgb( 0, 0, 0 );				// 선택 리스트 폰트 색상
listbox.set_selbg_rgb( 255, 255, 255 );				// 선택 리스트 배경 색상
listbox.selbg_alpha = 255;							// 선택 리스트 배경 투명도
//listbox.sel_alpha  = 255;								// 선택 리스트 폰트 투명도( 스크롤링때문에 적용 )
listbox.format_string =  "   [Title]";				// msg 출력
listbox.rows = 9;									// 리스트 row 갯수

//local zz = fe.add_text("1", 0/customRate, 90/customRate, monitor_width/1.8/customRate, monitor_height-90/customRate);
//zz.set_bg_rgb(234,234,234);


// 즐겨찾기 표시용 리스트 박스
local favoriteR=abs(("0"+my_config["favoriteR"]).tointeger());
local favoriteG=abs(("0"+my_config["favoriteG"]).tointeger());
local favoriteB=abs(("0"+my_config["favoriteB"]).tointeger());

local listbox_fav = fe.add_listbox( -11, 90/customRate, monitor_width/1.8/customRate, monitor_height-90/customRate);
listbox_fav.charsize = 27/customRate;
listbox_fav.set_sel_rgb( 255-favoriteR, 255-favoriteG, 255-favoriteB);
listbox_fav.set_rgb( favoriteR, favoriteG, favoriteB);
listbox_fav.selbg_alpha = 0;
listbox_fav.align = Align.MiddleLeft;
listbox_fav.format_string =  "[!favoriteIcon]";			// custom 함수 호출
listbox_fav.rows = 9;


// 즐겨찾기 특수문자(★) 출력
function favoriteIcon( index_offset ) 
{
	local fav = fe.game_info(  Info.Favourite , index_offset );
	local Title = fe.game_info(  Info.Title , index_offset );
	if( fav == "1" )
	{
		return  "★ ";
		//return  "★ "+ Title;
	}
	else
	{
		return "";	
	}
}

function koreList( index_offset ) 
{
	local Title = fe.game_info(  Info.Title , index_offset );
	if( Title.find("한글") >= 0 || Title.find("한국") >= 0 || Title.find("korea") >= 0 )
		return Title;
	else
		return "";
}


// 필터명 출력

local filterName = fe.add_text("『 [FilterName] 』", 460/customRate, 20/customRate, 250/customRate, 35/customRate  );	// 리스트 엔트리 위치
filterName.set_rgb( 255, 255, 255 );					// 폰트 색상
filterName.charsize = 25/customRate;						// 폰트 크기
filterName.align = Align.Left;				// 정렬


// 현제 게임 리스트 순선 / 전체 게임 리스트 갯수
local list = fe.add_text("[ListEntry] / [ListSize]", 600/customRate, 20/customRate, 250/customRate, 30/customRate  );	// 리스트 엔트리 위치
list.set_rgb( 255, 255, 255 );					// 폰트 색상
list.charsize = 25/customRate;						// 폰트 크기
list.align = Align.Right;				// 정렬
//list.msg = "1000 / 1000";


// 마퀴 출력 - 설정에서 Yes, No 하도록 만듬
if ( my_config["marqueeYn"] == "Y" )
{
	local marqueeImage = fe.add_artwork( "marquee" , 610/customRate, 60/customRate, 245/customRate, 100/customRate );
	marqueeImage.preserve_aspect_ratio = true;
}


// 에뮬레이터 로고 - 왼쪽 상단
// layout/joo_theme/emulator 폴더의 파일 출력
//local emulatorLogo = fe.add_image( "./logo/"+ "[Emulator]" + ".png" , 	540/customRate, 400/customRate, 250/customRate, 80/customRate );
//emulatorLogo.preserve_aspect_ratio = true;
local emulatorLogo = fe.add_image( "./logo/"+ "[Emulator]" + ".png" , 	0/customRate, 15/customRate, monitor_width/1.8/customRate, 80/customRate );
emulatorLogo.preserve_aspect_ratio = true;



// 선택 리스트 삭제 함수 - 리눅스에서만 작동
function deleteRom()
{
	fe.set_display(  fe.list.display_index   );
	local optionsYn = ["예", "아니오"];
	local command = fe.overlay.list_dialog( optionsYn,  "'" +fe.game_info(Info.Name) + "' 롬파일을 지우시겠습니까?");

	// 0 예  1 아니오  -1 취소
	local emulator = "\""+ fe.game_info(Info.Emulator) + "\"";	
	local filename = "\""+ fe.game_info(Info.Name) + "\"";	

	local del_exec = fe.script_dir + "delRomList.sh";
	local arg_exec = emulator  + " "+ filename;

	print( "del_command : " + del_exec + " " + arg_exec )
	if( command == 0 )	// 예
	{
		fe.plugin_command( del_exec, arg_exec );
		fe.set_display(  fe.list.display_index   );
	}
}




::OBJECTS <- {
	filterSplashText = fe.add_text( "[FilterName]", 0, 10, fe.layout.width, 85),
}

OBJECTS.filterSplashText.set_rgb(23,24,22);
OBJECTS.filterSplashText.set_bg_rgb( 255, 255, 255);
OBJECTS.filterSplashText.bg_alpha = 200;
OBJECTS.filterSplashText.charsize = 40;
OBJECTS.filterSplashText.align = Align.MiddleCentre;
local fade_bg = {
    when = Transition.ToNewList, property = "bg_alpha",
    start = 200,
    end = 0,
    time = 500, 
    delay= 800,   
}

local fade_text = {
    when = Transition.ToNewList, property = "alpha",
    start = 255,
    end = 0,
    time = 500, 
    delay= 800,   
}

animation.add( PropertyAnimation( OBJECTS.filterSplashText, fade_bg) );
animation.add( PropertyAnimation( OBJECTS.filterSplashText, fade_text) );


//local longTitle = fe.add_text( "[Title]", 	monitor_width/customRate, 241/customRate, 240/customRate, 54/customRate );
local longTitle = fe.add_text( "[Title]", 	0/customRate, monitor_height-60/customRate, monitor_width/customRate, 60/customRate );

//longTitle.align = Align.Left;							// 정렬
longTitle.charsize = 30;
longTitle.set_rgb( 0, 0, 0 );							// 폰트 색상
longTitle.alpha = 0;
longTitle.set_bg_rgb( 255, 255, 255 );					// 배경 색상
longTitle.bg_alpha = 0;
longTitle.align = Align.MiddleCentre
longTitle.word_wrap = true;
//longTitle.style = Style.Bold;


local longText_bg = {
    when = Transition.ToNewSelection, property = "bg_alpha",
    start = 0,
    end = 230,
    time = 300, 
    delay= 500,
}
local longText_text = {
    when = Transition.ToNewSelection, property = "alpha",
    start = 0,
    end = 255,
    time = 300, 
    delay= 500,   
}

animation.add( PropertyAnimation( longTitle , longText_bg) );
animation.add( PropertyAnimation( longTitle , longText_text) );



//////////////////////////////////////////////////////////////////////////////////////////////////
// 세이브 status 활성화
local saveBg = fe.add_text( "", 0, 0, monitor_width, monitor_height);
saveBg.charsize=100;
saveBg.set_rgb( 255, 255, 255);
saveBg.align = Align.MiddleCentre;
saveBg.set_bg_rgb( 0, 0, 0 );
saveBg.bg_alpha=150;
saveBg.visible=false;

local saveTitle = fe.add_text( "【 퀵 로드 슬롯 선택 】", 0, -20, monitor_width, 160 ); 
saveTitle.set_rgb( 255, 255, 255);
saveTitle.charsize=25;
saveTitle.align = Align.MiddleCentre;
saveTitle.word_wrap = true;
saveTitle.visible=false;

local saveText = fe.add_text( "", 0, 347, monitor_width, 160 );
saveText.set_rgb(255, 255, 255);
saveText.charsize=20;
saveText.align = Align.MiddleCentre;
saveText.word_wrap = true;


local saveImageFrame = fe.add_text( "", 177-5, 100-5, 500+10, 300+10);
saveImageFrame.set_bg_rgb( 255, 255, 255 );
saveImageFrame.visible=false;

local saveImage = fe.add_image( "", 177, 100, 500, 300);
saveImage.visible=false;

local saveImagePre = fe.add_image( "", -340, 100, 500, 300);
local saveImageNext = fe.add_image( "", 690, 100, 500, 300);
saveImagePre.visible=false;
saveImageNext.visible=false;
saveImagePre.alpha=130;
saveImageNext.alpha=130;



local saveIndex = 0;
local saveSize=0;
local textfile;
local saveFile;


function saveInit()
{
	saveImage.visible=false;
	saveBg.visible=false;
	saveTitle.visible=false;
	saveText.visible=false;
	saveImagePre.visible=false;
	saveImageNext.visible=false;
	saveImageFrame.visible=false;
	saveIndex=0;
	saveSize=0;

}

function saveStart()
{
	// 0 예  1 아니오  -1 취소
	local emulator = "\""+ fe.game_info(Info.Emulator) + "\"";	
	local filename = "\""+ fe.game_info(Info.Name) + "\"";	
	local temp = split( textfile.lines[saveIndex],"|");
	local saveFile = "\"" + temp[0]  + "\"";
	

	local sh_exec = fe.script_dir + "saveStart.sh";
	local arg_exec = emulator + " "+ filename +" "+ saveFile;

	print( "sh_command : " + sh_exec + " " + arg_exec )

	fe.plugin_command( sh_exec, arg_exec );
}

function saveInfo(type)
{
	if( type == "I" )
	{
		// load 스테이터스
		//textfile = txt.loadFile("/roms/gba/건스타 슈퍼 히어로즈 (한글).saveInfo");
		textfile = txt.loadFile("/roms/"+fe.game_info(Info.Emulator)+"/"+fe.game_info(Info.Name)+".saveInfo");
		saveSize = fncSaveSize( textfile );
		if( saveSize == 0 ) return true;
	}
	if( type == "R" )
	{
		saveIndex = saveIndex+1;
	}
	if( type == "L" )
	{
		saveIndex = saveIndex-1;
	}

	saveImage.visible=true;
	saveBg.visible=true;
	saveText.visible=true;
	saveTitle.visible=true;
	saveImagePre.visible=true;
	saveImageNext.visible=true;
	saveImageFrame.visible=true;


	local temp = split( textfile.lines[saveIndex],"|");
	local title = temp[0];
	local date = temp[1];
	local sizeMb = temp[2];

	saveImage.file_name = title;

	if( (saveIndex != 0) && (saveSize != 1) )
	{
		local preTemp = split( textfile.lines[saveIndex-1],"|");
		local preTitle = preTemp[0];

		saveImagePre.file_name = preTitle;
	}
	else
	{
		saveImagePre.file_name = "";
	}

	if( (saveIndex != saveSize-1 ) && ( saveSize != 1 ) )
	{
		local nextTemp = split( textfile.lines[saveIndex+1],"|");
		local nextTitle = nextTemp[0];

		saveImageNext.file_name = nextTitle;
	}
	else
	{
		saveImageNext.file_name = "";
	}

	local slotName = split( title, ".");
	saveText.msg = date + "\n"+slotName[1] + " ("+sizeMb+")";
	//saveText.msg = slotName[1] + " ("+sizeMb+")";

	saveTitle.msg="【 퀵 로드 슬롯 선택 】\n"+fe.game_info(Info.Title);

}

// 선택 리스트 삭제 함수 - 리눅스에서만 작동
function deleteSaveState()
{
	local emulator = "\""+ fe.game_info(Info.Emulator) + "\"";	
	local temp = split( textfile.lines[saveIndex],"|");
	local title = temp[0];
	local slotName = split( title, ".");

	local optionsYn = ["예", "아니오"];
	local command = fe.overlay.list_dialog( optionsYn,  "'" +slotName[1]+ "' 슬롯을 지우시겠습니까?");

	// 0 예  1 아니오  -1 취소
	local filename = "\""+ fe.game_info(Info.Name) +"\"";
	local savefile = "\""+ fe.game_info(Info.Name) + "." + slotName[1]  +"\"";
	
	local del_exec = fe.script_dir + "delSaveState.sh";
	local arg_exec = emulator + " " + filename + " " + savefile;

	print( "delSaveState_command : " + del_exec + " " + arg_exec )
	if( command == 0 )	// 예
	{
		fe.plugin_command( del_exec, arg_exec );
		//fe.set_display(  fe.list.display_index   );
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////

// 메뉴 overlay 시 스타일 설정

// translucent background
local overlayBackground = fe.add_text("",0,0,monitor_width, monitor_height);
overlayBackground.set_bg_rgb( 1, 1, 1);
overlayBackground.bg_alpha = 110;
overlayBackground.visible = false;

local overlayBoxBg = fe.add_text("", monitor_width/10/customRate, monitor_height/10/customRate, (monitor_width - monitor_width/10*2)/customRate, (monitor_height - monitor_height/10*2)/customRate);
overlayBoxBg.set_bg_rgb( 1, 1, 1);
overlayBoxBg.bg_alpha = 200;
overlayBoxBg.visible = false;


local overlay_lb = fe.add_listbox( monitor_width/10/customRate, monitor_height/10/customRate, (monitor_width - monitor_width/10*2)/customRate, (monitor_height - monitor_height/10*2)/customRate); 	// Add the listbox
overlay_lb.rows = 6; // the listbox will have 6 slots
overlay_lb.charsize = 40/customRate;
overlay_lb.set_rgb( 128, 128, 128 );
overlay_lb.sel_style = Style.Bold;
overlay_lb.set_bg_rgb(255,255,255);
overlay_lb.set_sel_rgb( 255, 255, 255 );
overlay_lb.set_selbg_rgb( 255,130,0 );
overlay_lb.visible = false;

local overlayMenuTitle = fe.add_text("[DisplayName]", monitor_width/10/customRate, monitor_height/10/customRate, (monitor_width - monitor_width/10*2)/customRate, (monitor_height/5)/customRate);
overlayMenuTitle.word_wrap = true;
overlayMenuTitle.charsize=32/customRate;
//overlayMenuTitle.style = Style.Bold;
overlayMenuTitle.set_rgb(0,0,0);
overlayMenuTitle.set_bg_rgb(255,255,255);
overlayMenuTitle.bg_alpha=230;
overlayMenuTitle.visible = false;


fe.overlay.set_custom_controls( overlayMenuTitle, overlay_lb );

fe.add_transition_callback( "option_menu" );
function option_menu( ttype, var, ttime )
{
	switch ( ttype )
	{	
		case Transition.ShowOverlay:
			overlayBackground.visible = true;
			overlayBoxBg.visible = true;
			overlay_lb.visible = true;
			overlayMenuTitle.visible = true;		
		break;
		case Transition.HideOverlay:		
			overlayBackground.visible = false;
			overlayBoxBg.visible = false;
			overlay_lb.visible = false;
			overlayMenuTitle.visible = false;		
			fe.signal("reload");
		break;
	}
	return false;
}


function fncSaveSize( file )
{
	local size = 0;
	foreach( line in file.lines )
	{
		size++;
	}
	return size;
}


// 도움말

local helpImage = fe.add_image( "[!help_format]", monitor_width*0.05, monitor_height*0.05, monitor_width*0.9, monitor_height*0.9);
//local helpImage = fe.add_image( "./help/[Emulator].png", monitor_width*0.05, monitor_height*0.05, monitor_width*0.9, monitor_height*0.9);

//helpImage.preserve_aspect_ratio = true;

function help_format( ioffset )
{
	local emulator = fe.displays[fe.list.display_index].name;
	//print( emulator );
	//print( emulator );
	//print( emulator );
	if( file_exist( "/home/odroid/.attract/layouts/joo_theme/help/"+emulator+".png" ) ) 
		return "./help/"+emulator+".png";
	else
		return "./help/default.png";
}

function file_exist(fullpathfilename)
{
   try {file(fullpathfilename, "r" );return true;}catch(e){return false;}
}



/*
local saveTitle = fe.add_text( "【 퀵 로드 슬롯 선택 】", 0, -20, monitor_width, 160 ); 
saveTitle.set_rgb( 255, 255, 255);
saveTitle.charsize=25;
saveTitle.align = Align.MiddleCentre;
saveTitle.word_wrap = true;
saveTitle.visible=false;
*/


helpImage.visible=false;

// 조작 시그널 핸들러
fe.add_signal_handler(  "on_signal" );
function on_signal( sig )
{

	longTitle.alpha = 0;
	longTitle.bg_alpha = 0;
	switch ( sig )	
	{
		case "up":				// up 버튼 조작시 발생
			if( saveImage.visible )
				saveInit();
			fe.signal( "prev_game" );
			return true;
		case "down":			// down 버튼 조작시 발생
			if( saveImage.visible )
				saveInit();
			fe.signal( "next_game");
			return true;		
		case "left":			// left 버튼 조작시 발생
			if( !saveImage.visible )
			{			
				//fe.signal( "prev_page" );
				OBJECTS.filterSplashText.bg_alpha = 200;
				OBJECTS.filterSplashText.alpha = 255;
				fe.signal( "prev_filter" );
			}
			else
			{
				if( saveIndex == 0 )
					return true;
				else
					saveInfo("L");
			}
			return true;
		case "right":			// right 버튼 조작시 발생
			if( !saveImage.visible )
			{						
				//fe.signal( "next_page" );
				OBJECTS.filterSplashText.bg_alpha = 200;
				OBJECTS.filterSplashText.alpha = 255;
				fe.signal( "next_filter" );	
			}
			else
			{
				if( saveIndex == saveSize-1 )
					return true;
				else
					saveInfo("R");
			}
			return true;	
		case "select":			// 리스트 선택시 발생
			if ( my_config["playConfirm"] == "Y" )
			{
				//건스타 슈퍼 히어로즈 (한글).state.auto
				local optionsYn = ["예", "아니오"];
				local command = fe.overlay.list_dialog( optionsYn,  "'" +fe.game_info(Info.Title) + "' 을 실행합니까?");
				if( command == 0 )	// 예 일경우
				{
					if( saveImage.visible )
					{
						saveStart();
					}
					return false;		
				}
				else
					return true;
			}
			break;
		case "custom1":
			if( saveImage.visible )
			{
				saveInit();
			}
			else
			{
				saveInfo("I");	
			}
			return true;
		case "custom2":			// 리눅스 전용 롬파일 지우기
			if( saveImage.visible )
			{
				//saveInit();
				// 세이브포인트 지우기
				deleteSaveState();
			}
			else
			{
				deleteRom();
			}
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
			if( saveImage.visible )
				saveInit();
			else
			{
				if( helpImage.visible )
					helpImage.visible=false;			
				else
					fe.signal( "displays_menu" );
			}
			return true;
	}
	if( saveImage.visible )
		saveInit();

//	if( helpImage.visible )
//		helpImage.visible=false;			

	
	//selectText.x = -20/customRate;		//  스크롤 텍스트 x 좌표 초기화	
	
	return false;
}



