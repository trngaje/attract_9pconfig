//////////////////////////////////////////////////
//						//
// Attract-Mode Frontend - Grid 9p Theme	//
//						//
/////////////////////////////////////////////////

class UserConfig </ help="Navigation controls: Up/Down (to move up and down) and Page Up/Page Down (to move left and right)" />{
	</ label="GRID Artwork 이미지", help="GRID에 표현될 Artwork 종류", options="title,snap,marquee,flyer,wheel", order=1 />
	art="snap";

	</ label="Artwork 원본 비율", help="Artwork 원본 가로세로 비율 유지", options="Yes,No", order=2 />
	aspect_ratio="No";

	</ label="선택 게임 Video 재생", help="GRID에 선택 Snap Video 재생", options="Yes,No", order=3 />
	sel_video="Yes";

	</ label="모든 게임 Video 재생", help="GRID에 모든 Snap Video 재생", options="Yes,No", order=4 />
	all_video="No";

	</ label="현재 시간 출력", help="상단 현재 시간 출력(인터넷연결해야 제대로 표시", options="Yes,No", order=5  /> 
	enable_time="No";

	</ label="타이블 번호", help="상단 현재 시간 출력", options="Y, N", order=6  /> 
	ListEntryYn = "Y";

	</ label="타이틀 정렬", help="상단 현재 시간 출력", options="Left,Center,Right", order=7  /> 
	titleAlign = "Left";
	

	</ label="Red (R) (0-255) Color", help="상단 바 색상 - RGB ( RED 값 )", option="0", order=8 /> 
	red=10;
	</ label="Green (G) (0-255) Color", help="상단 바 색상 - RGB ( GREEN 값 )", option="0", order=9 /> 
	green=80;
	</ label="Blue (B) (0-255) Color", help="상단 바 색상 - RGB ( BLUE 값 )", option="0", order=10 />  
	blue=80;
	</ label="상단바 텍스트 컬러", help="상단 바 텍스트 컬러", option="White, Black", order=11 />  
	textColor="White";
	
	</ label="게임 실행여부 확인", help="실행여부 Y, N)", options="Y,N", order=14 /> playConfirm = "Y";

	</ label="해상도 Width", help="가로 해상도", option="854", order=15 />  user_width="480";
	</ label="해상도 Height", help="세로 해상도" option="480", order=16 />  user_height="320";


}

fe.load_module( "conveyor" );			// 미사용 GRID 모듈
fe.load_module("animate");				// 미사용 에니메이션 모듈

dofile ( fe.script_dir + "conveyor.nut" );			// GRID 표현을 위한 module

local my_config = fe.get_config();			// 레이아웃 옵션 설정 값 저장 배열
///////////////////////////////////////////// 폰트 셋팅 start /////////////////////////////////////////////

fe.layout.font="font";
///////////////////////////////////////////// 폰트 start /////////////////////////////////////////////

///////////////////////////////////////////// 레이아웃 해상도 셋팅 start /////////////////////////////////////////////
local monitor_width = abs((my_config["user_width"]).tointeger());	// 레이아웃 해상도 width 변수
local monitor_height = abs((my_config["user_height"]).tointeger())	// 레이아웃 해상도 height 변수
fe.layout.width =  monitor_width;				// Set 레이아웃 해상도 width
fe.layout.height = monitor_height;				// Set 레이아웃 해상도 height
fe.layout.preserve_aspect_ratio = false;
///////////////////////////////////////////// 레이아웃 해상도 셋팅 end /////////////////////////////////////////////

///////////////////////////////////////////// 기본 base 변수 셋팅 start /////////////////////////////////////////////
local wheelFlag  = "No";

function getRows()
{
	local fp = file( fe.script_dir + "rows","r");
	local result = fp.readn('c');
	fp.close();
	return result;
}

function getCols()
{
	local fp = file( fe.script_dir  + "cols","r");
	local result = fp.readn('c');
	fp.close();
	return result;
}

function setRows(num)
{
	local fp = file( fe.script_dir  + "rows","wb+");
	fp.writen(num,'c');
	fp.close();
}
function setCols(num)
{
	local fp = file( fe.script_dir  + "cols","wb+");
	fp.writen(num,'c');
	fp.close();
}



local rows = getRows();
local cols = getCols();

//local rows = my_config[ "rows" ].tointeger();			// GRID rows 개수
//local cols = my_config[ "columns" ].tointeger();			// GRID cols 개수
//local height = ( fe.layout.height * 10 / 12 ) / rows.tofloat();		// GRID 전체 height
local height = ( fe.layout.height * 10 / 10.25 ) / rows.tofloat();		// GRID 전체 height

local width = fe.layout.width / cols.tofloat();			// GRID 전체 width
local vert_flow = false;		// GRID 방향( 세로, 가로 )
const PAD=2;						// GRID 패딩
local bgRed=abs(("0"+my_config["red"]).tointeger());		// RGB 중 RED 값
local bgGreen=abs(("0"+my_config["green"]).tointeger());		// RGB 중 GREEN 값
local bgBlue=abs(("0"+my_config["blue"]).tointeger());		// RGB 중 BLUE 값
///////////////////////////////////////////// 기본 base 변수 셋팅 end /////////////////////////////////////////////
//local MovingGameList = fe.add_sound("click.mp3");		// 커서 이동 사운드 click.mp3 미사용 


///////////////////////////////////////////// 배경셋팅 end /////////////////////////////////////////////
/*
local bgArt = fe.add_image("bg_black.png", 0, 0, monitor_width, monitor_height);
local bgArt2 = fe.add_clone(bgArt);
animation.add( PropertyAnimation( bgArt, {when = Transition.StartLayout, property = "x", start = 0, end = -monitor_width, time = 28000, loop=true}));
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = monitor_width, end = 0, time = 28000, loop=true}));			
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));
*/
///////////////////////////////////////////// 배경셋팅 end /////////////////////////////////////////////

///////////////////////////////////////////// 상,하단 Bar 색상 셋팅 start /////////////////////////////////////////////
bgRed=(bgRed>255 ? bgRed % 255 : bgRed);			// RGB 중 RED 색상 변수
bgGreen=(bgGreen>255 ? bgGreen % 255 : bgGreen);		// RGB 중 GREEN 색상 변수
bgBlue=(bgBlue>255 ? bgBlue % 255 : bgBlue);			// RBS 중 BLUE 색상 변수

// Top Background 상단 배경
local lt = fe.add_text( "", 0, 0, fe.layout.width, fe.layout.height/30);		
lt.set_bg_rgb( bgRed, bgGreen, bgBlue );

//local bt = fe.add_text( "", 0, fe.layout.height-(fe.layout.height/24), fe.layout.width, fe.layout.height/24);		
//bt.set_bg_rgb( bgRed, bgGreen, bgBlue );

local move_bt = {
    when =Transition.StartLayout ,property = "alpha", start = 100, end = 255, time = 800, tween = Tween.Linear,  pulse = true
 } 
//local btimg = fe.add_image( "bottom.png", 0, fe.layout.height-(fe.layout.height/24), fe.layout.width, fe.layout.height/24);		
//animation.add( PropertyAnimation( btimg , move_bt ) );
///////////////////////////////////////////// 상,하단 Bar 색상 셋팅 end /////////////////////////////////////////////

///////////////////////////////////////////// 현재 시스템 시간 출력 start /////////////////////////////////////////////
if ( my_config["enable_time"] == "Yes" )
{	
	local dt = fe.add_text( "", 0, 0-8, fe.layout.width, fe.layout.height / 20  );
	dt.align= Align.MiddleCentre;
	dt.charsize = 28;

	if( my_config["textColor"] == "White")
		dt.set_rgb(255,255,255);	
	else
		dt.set_rgb(0,0,0);

	function update_clock( ttime ){
		local now = date();
		dt.msg = format("%02d", now.hour) + " : " + format("%02d", now.min ) + " : " + format("%02d", now.sec );		// 13.23.11
		//dt.msg = format("%02d", now.hour) + "시 " + format("%02d", now.min ) + "분 " + format("%02d", now.sec ) + "초";	// 13시 23분 11초
	}
	fe.add_ticks_callback( this, "update_clock" );
	fe.plugin_command("clear","");

}
///////////////////////////////////////////// 현재 시스템 시간 출력 end /////////////////////////////////////////////





class Grid extends Conveyor
{	
	overlay=null;
	frame=null;
	//num_t=null;
	genre_image=null;
	sel_x=0;
	sel_y=0;
	sel_snap=null;
	
	constructor()
	{
		base.constructor();

		sel_x = cols / 2;
		sel_y = rows / 2;
		stride = fe.layout.page_size = vert_flow ? rows : cols;		// GRID 양끝에서 이동시 한칸씩 이동
		//stride = fe.layout.page_size = rows * cols;			// GRID 양끝에서 이동시 rows * cols 만큼 이동

		fe.add_signal_handler( this, "on_signal" );	
		try
		{
			transition_ms = my_config["ttime"].tointeger();
		}
		catch ( e )
		{
			transition_ms = 0;
		}
	}

	

	

	function update_audio()
	{		
		if ( my_config["all_video"] == "Yes" )			
		{			
			local flag1 = Vid.NoAudio;
			local flag2 = 0;					
			foreach ( o in m_objs )
			{
				o.m_art.video_flags = flag1;		             // 모든 GRID 오디오재생 x
			}	
			local sel = get_sel();
			m_objs[ sel ].m_art.video_flags = flag2;		// 선택한 GRID 영상,오디오 재생 o
		}
		else
		{
		}
	}

	function update_frame()
	{		
		if ( my_config["sel_video"] == "No" || my_config["all_video"] == "Yes" )
		{
						
		}
		else if( my_config["sel_video"] == "Yes" )
		{	
			sel_snap.x = width * sel_x + PAD; 				// 선택 GRID snap 위치 x
			sel_snap.y = fe.layout.height / 22 + height * sel_y + PAD;	// 선택 GRID snap 위치 y
			sel_snap.index_offset = get_sel() - selection_index;		// 선택 GRID index
			sel_snap.zorder=50;					// 선택 GRID zorder
			sel_snap.video_flags =  0;				// 선택 GRID snap video flags ( 영상,소리 출력 )
			sel_snap.video_flags=Vid.NoLoop;


		}

		update_audio();		

		frame.x = width * sel_x;					// GRID 선택 Frame 위치 x
		frame.y = fe.layout.height / 22 + height * sel_y;			// GRID 선택 Frame 위치 y
		frame.zorder=100;						// GRID 선택 zorder

		overlay.x = width * sel_x;					// GRID 선택 Frame 위치 x
		overlay.y = fe.layout.height / 22 + height * sel_y + height - height/5.5;			// GRID 선택 Frame 위치 y
		overlay.zorder=100;						// GRID 선택 zorder


		//frame.index_offset= num_t.index_offset = get_sel() - selection_index;	
		//overlay.index_offset=frame.index_offset= num_t.index_offset = get_sel() - selection_index;	
		overlay.index_offset=frame.index_offset= get_sel() - selection_index;	
			
	
	}

	function do_correction()
	{
		local corr = get_sel() - selection_index;
		foreach ( o in m_objs )
		{
			local idx = o.m_art.index_offset - corr;
			o.m_art.rawset_index_offset( idx );
			//sel_snap.rawset_index_offset( idx );	

			if ( o.m_wheels )
			{
				o.m_wheel.rawset_index_offset( idx );
				o.m_wheels.rawset_index_offset( idx );
				o.m_wheelss.rawset_index_offset( idx );
			}
		}
	}

	function get_sel()
	{
		return vert_flow ? ( sel_x * rows + sel_y ) : ( sel_y * cols + sel_x );
	}

	function on_signal( sig )
	{
		switch ( sig )	
		{
		case "up":	// up 키를 눌렀을 때
			if ( vert_flow && ( sel_y > 0 ) )
			{
				sel_y--;
				update_frame();
				move_sound();
			}
			else if ( !vert_flow )
			{
				if( sel_y == 0 )
				{
					do_correction();
					fe.signal( "prev_page" );
					
				}
				else
				{
					sel_y--;
					update_frame();
					move_sound();
				}
				
			}
			else if ( vert_flow && ( sel_y == 0 ) )
			{
				if( sel_x == 0 && sel_y == 0 )	// 화면 막다른 곳에 위치했을 때( 왼쪽 상단 )
				{
					sel_x = 0;
					sel_y = 0;
					do_correction();
					fe.signal( "prev_page" );	
					
					//for ( local i=0; i< cols; i++ )
					//{
					//	do_correction();
					//					
					//}
				}
				else
				{			
					sel_x--;
					sel_y = rows - 1; 
					update_frame();
					move_sound();
				}
			}
			return true;

		case "down":	// down 키를 눌렀을 때
			if ( vert_flow && ( sel_y < rows - 1 ))
			{
				sel_y++;
				update_frame();
				move_sound();
			}
			else if ( !vert_flow )
			{
				if( sel_y == rows-1 )
				{
					do_correction();
					fe.signal( "next_page" );
					
				}
				else
				{
					sel_y++;
					update_frame();
					move_sound();
				}
				
			}
			else if ( vert_flow && ( sel_y == rows - 1 ))
			{
				if( sel_x == cols-1 && sel_y == rows-1 )	// 화면 막다른 곳에 위치했을 때( 오른쪽 하단 )
				{
					
					do_correction();
					fe.signal( "next_page" );
					sel_x = cols-1;		
					sel_y = rows-1;

					//for ( local i=0; i< cols; i++ )
					//{
					//	do_correction();
					//	fe.signal( "next_page" );				
					//}
				}
				else
				{
					sel_y = 0;
					sel_x++;
					update_frame();
					move_sound();
				}	

			}			
			return true;

		case "left":	// left 키를 눌렀을 때
			if ( vert_flow && ( sel_x > 0 ))
			{
				sel_x--;
				update_frame();
				move_sound();
			}
			else if ( !vert_flow && ( sel_x > 0 ) )
			{
				sel_x--;
				update_frame();
				move_sound();
			}
			else if ( !vert_flow && ( sel_x == 0 ) )
			{
				if( sel_y == 0)
				{
					transition_swap_point=0.0;
					do_correction();
					fe.signal( "prev_page" );
					sel_x = cols-1;
				}
				else
				{
					sel_x = cols-1;
					sel_y--;
					update_frame();
					move_sound();
				}
			}
			else	// 화면 막다른 곳에 위치했을 때( 좌측 )
			{
				transition_swap_point=0.0;
				do_correction();
				fe.signal( "prev_page" );				

				//for ( local i=0; i< cols; i++ )
				//{
				//	do_correction();
				//	fe.signal( "prev_page" );				
				//}
			}
			return true;

		case "right":	// right 키를 눌렀을 때
			if ( vert_flow && ( sel_x < cols - 1 ) )
			{
				sel_x++;								
				update_frame();
				move_sound();
			}
			else if ( !vert_flow && ( sel_x >= 0 ) )
			{
				if( sel_x == cols -1 )
				{
					if( sel_y == rows-1 )
					{
						transition_swap_point=0.0;
						do_correction();
						fe.signal( "next_page" );	
						sel_x=0;
						
					}	
					else
					{
						sel_x=0;
						sel_y++;
						update_frame();	
						move_sound();
					}
				}
				else
				{
					sel_x++;
					update_frame();
					move_sound();
				}

			}			
			else	// 막다른 곳에 위치했을 때( 우측 )
			{
				transition_swap_point=0.0;
				do_correction();
				fe.signal( "next_page" );				
	
				//for ( local i=0; i< cols; i++ )
				//{
				//	do_correction();
				//	fe.signal( "next_page" );				
				//}
				
			}
			return true;
		case "custom1":
			if(rows == 2)
			{
				if( cols == 2 )
					setCols(3);
				else
					setRows(3);
			}
			if(rows == 3 )
			{
				if( cols == 3 )
					setCols(4);
				else
					setRows(4);
			}
			if(rows == 4 )
			{
				setRows(2);
				setCols(2);
			}
			


			fe.signal( "reload" );
			break;		
		case "exit":
		case "exit_no_menu":
			break;
		case "select":
			
			enabled=false; // turn conveyor off for this switch
			local frame_index = get_sel();
			fe.list.index += frame_index - selection_index;

			set_selection( frame_index );

			if ( my_config["playConfirm"] == "Y" )
			{
				local optionsYn = ["예", "아니오"];
				local command = fe.overlay.list_dialog( optionsYn,  "'" +fe.game_info(Info.Title) + "' 을 실행합니까?");
			
				// 0 예  1 아니오  -1 취소

				if( command == 0 )	// 예
				{
					update_frame();
					move_sound();
					enabled=true; // re-enable conveyor
					return false;
				}
				else
				{
					update_frame();
					move_sound();
					enabled=true; // re-enable conveyor
					return true;				
				}
			}
			else
			{
				// 바로 실행
			}

			
			break;
		default:
			// Correct the list index if it doesn't align with
			// the game our frame is on

			enabled=false; // turn conveyor off for this switch
			local frame_index = get_sel();
			fe.list.index += frame_index - selection_index;

			set_selection( frame_index );


			



			update_frame();
			move_sound();
			enabled=true; // re-enable conveyor
			break;

		}

		return false;
	}

	function on_transition( ttype, var, ttime )
	{
		switch ( ttype )
		{
		case Transition.StartLayout:
		case Transition.FromGame:
			/*
			if ( ttime < transition_ms )
			{
				for ( local i=0; i< m_objs.len(); i++ )
				{
					local r = i % rows;
					local c = i / rows;
					local num = rows + cols - 2;
					if ( num < 1 )
						num = 1;

					local temp = 510 * ( num - r - c ) / num * ttime / transition_ms;
					m_objs[i].set_alpha( ( temp > 255 ) ? 255 : temp );
				}

				frame.alpha = 255 * ttime / transition_ms;
				return true;
			}
			*/

			local old_alpha = m_objs[ m_objs.len()-1 ].m_art.alpha;


			foreach ( o in m_objs )
				o.set_alpha( 255 );

			frame.alpha = 255;

			if ( old_alpha != 255 )
				return true;

			break;

		case Transition.ToGame:
		case Transition.EndLayout:
			/*
			if ( ttime < transition_ms )
			{
				for ( local i=0; i< m_objs.len(); i++ )
				{
					local r = i % rows;
					local c = i / rows;
					local num = rows + cols - 2;
					if ( num < 1 )
						num = 1;

					local temp = 255 - 510 * ( num - r - c ) / num * ttime / transition_ms;
					m_objs[i].set_alpha( ( temp < 0 ) ? 0 : temp );
				}
				frame.alpha = 255 - 255 * ttime / transition_ms;
				

				return true;
			}
			*/

			local old_alpha = m_objs[ m_objs.len()-1 ].m_art.alpha;


			foreach ( o in m_objs )
				o.set_alpha( 0 );

			frame.alpha = 0;
			
			

			if ( old_alpha != 0 )
				return true;

			break;
		case Transition.FromOldSelection:
		case Transition.ToNewList:
			update_audio();

			foreach ( o in m_objs )
				o.dim_if_needed();
			break;
		}

		return base.on_transition( ttype, var, ttime );
	}

	function move_sound()
	{
		//local selectMusic = fe.add_sound("select.mp3")
	     	//selectMusic.playing=true;
	}

}

::gridc <- Grid();

class MySlot extends ConveyorSlot
{
	m_num = 0;
	m_shifted = false;
	m_art = null;
	m_art_imt = null;

	m_wheel = null;
	m_wheels = null;
	m_wheelss = null;
	
	m_ttt = null;
	m_fav = null;


	constructor( num )
	{
		m_num = num;

		
		m_art = fe.add_artwork( my_config["art"], 0, 0,
				width - 2*PAD, height - 2*PAD );		
		m_art.preserve_aspect_ratio = (my_config["aspect_ratio"]=="Yes");
		m_art.video_flags = Vid.NoAudio;	
		if ( my_config["all_video"] == "No" )
			m_art.video_flags = Vid.ImagesOnly | Vid.NoAudio;
		
		
		
		m_art.alpha = 0;

		if ( wheelFlag == "Yes" )
		{
			m_wheels = fe.add_artwork( "wheel", 0, 0,
					width - 4*PAD, height - 4*PAD );
			m_wheels.preserve_aspect_ratio = false;
			m_wheelss = fe.add_clone( m_wheels );
			m_wheel = fe.add_clone( m_wheels );
			m_wheels.set_rgb( 0, 0, 0 );
			m_wheelss.set_rgb( 0, 0, 0 );
		}

		if( my_config["ListEntryYn"] == "Y")
			m_ttt = fe.add_text( "[ListEntry]. [!title_format]", 0, 0, width - 2*PAD, height/6);
		else
			m_ttt = fe.add_text( " [!title_format]", 0, 0, width - 2*PAD, height/6);


		m_ttt.charsize = width/16;
		m_ttt.set_rgb(255,255,255);				
		m_ttt.set_bg_rgb(0,0,0);
		m_ttt.zorder=90;
		m_ttt.word_wrap=true;
		m_ttt.bg_alpha = 180;
	
		if( my_config["titleAlign"]== "Left")
			m_ttt.align=Align.TopLeft;
		if( my_config["titleAlign"]== "Center")
			m_ttt.align=Align.TopCentre;
		if( my_config["titleAlign"]== "Right")
			m_ttt.align=Align.TopRight;


		//m_ttt.margin = 5;
		
		
		m_fav = fe.add_image( "[!gamefav]", 0, 0, width/3, height/2.5 );	
		m_fav.zorder=90;
		
		/*
		m_fav = fe.add_text( "[!gamefavStar]", 0, 0, width/4, height/5 );	
		m_fav.font = "font";
		m_fav.charsize = width/5;
		m_fav.set_rgb( 255, 228, 0 );
		//m_fav.set_bg_rgb(0,1,1);
		m_fav.zorder=90;
		m_fav.word_wrap=true;
		*/

		

		base.constructor();
	}

	
	function on_progress( progress, var )
	{
		if ( var == 0 )
			m_shifted = false;

		if ( vert_flow )
		{
			local r = m_num % rows;
			local c = m_num / rows;

			if ( abs( var ) < rows )
			{
				m_art.x = c * width + PAD;
				m_art.y = fe.layout.height / 30
					+ ( fe.layout.height * 10 / 10.4 ) * ( progress * cols - c ) + PAD;
			}
			else
			{
				local prog = ::gridc.transition_progress;
				if ( prog > ::gridc.transition_swap_point )
				{
					if ( var > 0 ) c++;
					else c--;
				}

				if ( var > 0 ) prog *= -1;

				m_art.x = ( c + prog ) * width + PAD;
				m_art.y = fe.layout.height / 10.4 + r * height + PAD;
			}
		}
		else
		{
			local r = m_num / cols;
			local c = m_num % cols;

			if ( abs( var ) < cols )
			{
				m_art.x = fe.layout.width * ( progress * rows - r ) + PAD;
				m_art.y = fe.layout.height / 22 + r * height + PAD;
			}
			else
			{
				local prog = ::gridc.transition_progress;
				if ( prog > ::gridc.transition_swap_point )
				{
					if ( var > 0 ) r++;
					else r--;
				}

				if ( var > 0 ) prog *= -1;

				m_art.x = c * width + PAD;
				m_art.y = ( r + prog ) * height + PAD;
			}
		}

		m_ttt.x = m_art.x;
		m_ttt.y = m_art.y+height-(height/5.5);
		
		m_fav.x = m_art.x;
		m_fav.y = m_art.y;




		if ( m_wheel )
		{
			m_wheels.x = m_art.x + PAD + 1;
			m_wheels.y = m_art.y + PAD + 1;
			m_wheelss.x = m_art.x + PAD - 1;
			m_wheelss.y = m_art.y + PAD - 1;
			m_wheel.x = m_art.x + PAD;
			m_wheel.y = m_art.y + PAD;
		}

		dim_if_needed();
	}

	function swap( other )
	{
		m_art.swap( other.m_art );
		//m_ttt.swap( other.m_ttt );

		if ( m_wheel )
		{
			m_wheel.swap( other.m_wheel );
			m_wheels.swap( other.m_wheels );
			m_wheelss.swap( other.m_wheelss );
		}
	}

	function set_index_offset( io )
	{
		m_art.index_offset = io;
		m_ttt.index_offset = io;
		m_fav.index_offset = io;

		if ( m_wheel )
		{
			m_wheel.index_offset = io;
			m_wheels.index_offset = io;
			m_wheelss.index_offset = io;
		}
	}

	function reset_index_offset()
	{
		m_ttt.index_offset = m_base_io;
		m_fav.index_offset = m_base_io;


		m_art.rawset_index_offset( m_base_io ); 
		if ( m_wheel )
		{
			m_wheel.rawset_index_offset( m_base_io );
			m_wheels.rawset_index_offset( m_base_io );
			m_wheelss.rawset_index_offset( m_base_io );
		}
	}

	function set_alpha( alpha )
	{
		m_art.alpha = alpha; 
		//m_ttt.alpha = alpha;
		if ( m_wheel )
		{
			m_wheel.alpha = alpha;
			m_wheels.alpha = alpha;
			m_wheelss.alpha = alpha;
		}
	}

	function dim_if_needed()
	{
		if ( m_wheel )
		{			
			// If we have an art and a wheel, make the art a bit darker			
			if (( m_wheel.file_name.len() > 0 )
					&& ( m_art.file_name.len() > 0 ))
				m_art.set_rgb( 140, 140, 140 );
			else
				m_art.set_rgb( 255, 255, 255 );
		}
	}
}




local my_array = [];
for ( local i=0; i<rows*cols; i++ )
	my_array.push( MySlot( i ) );

gridc.set_slots( my_array, gridc.get_sel() );


///////////////////////////////////////////// GRID Frame 이미지 셋팅 start /////////////////////////////////////////////
//
//  frame/ 폴더에 에뮬레이명칭 별로 .png 파일이 존재하여야 함( ex : Nintendo SNES.png )
//
function frame_format( ioffset )
{
	local f_name = fe.game_info( Info.Emulator, ioffset );		
	if( f_name.len() < 0 )
		return "frame/default.png";

	return "frame/" + f_name + ".png";
}

gridc.frame=fe.add_image( "frame.png", width * 2, height * 2, width, height-1*PAD );


//gridc.overlay=fe.add_text( " [!title_format]",  width * 2, height * 2, width,  height/7 );
if( my_config["ListEntryYn"] == "Y")
	gridc.overlay=fe.add_text( "[ListEntry]. [!title_format]",  width * 2, height * 2, width,  height/6 );
else
	gridc.overlay=fe.add_text( " [!title_format]",  width * 2, height * 2, width,  height/6 );

gridc.overlay.charsize = width/16;
gridc.overlay.set_bg_rgb(255,255,255);
gridc.overlay.set_rgb(0,0,0);
gridc.overlay.bg_alpha= 255;
gridc.overlay.word_wrap=true;
//gridc.overlay.margin = 3;
if( my_config["titleAlign"]== "Left")
	gridc.overlay.align=Align.TopLeft;
if( my_config["titleAlign"]== "Center")
	gridc.overlay.align=Align.TopCentre;
if( my_config["titleAlign"]== "Right")
	gridc.overlay.align=Align.TopRight;



local move_frame = {
    when =Transition.StartLayout ,property = "alpha", start = 100, end = 255, time = 800, tween = Tween.Linear,  pulse = true
 } 

animation.add( PropertyAnimation( gridc.frame, move_frame ) );

//gridc.frame=fe.add_image( "[!frame_format]", width * 2, height * 2, width, height );	// GRID Frame 이미지
///////////////////////////////////////////// GRID Frame 이미지 셋팅 end /////////////////////////////////////////////

// 스크롤링 title ( 미사용 )
//local scroller = ScrollingText.add( "[Title]", fe.layout.width/2, 0, fe.layout.width/2, fe.layout.height / 18, ScrollType.HORIZONTAL_LEFT );
//scroller.settings.delay = 500;
//scroller.settings.loop = -1;

///////////////////////////////////////////// 게임 타이틀 셋팅 start /////////////////////////////////////////////
function title_format( ioffset )
{
	local m = fe.game_info( Info.Title, ioffset );
	if (  m.len()   >  60  )
		return m.slice(0,60) + "...";	// 60문자가 넘을경우 뒤에 ...을 붙이기
	return m;
}

function title_fontsize( titleName )
{
	if (  titleName.len()   >  16  )
		return width/16;

	return width/13;
;
}


//gridc.name_t =  fe.add_text( "[Title]", 0, 	fe.layout.height - fe.layout.height / 13, 	fe.layout.width, fe.layout.height / 24 );
//gridc.name_t.align = Align.Left;
///////////////////////////////////////////// 게임 타이틀 셋팅 end /////////////////////////////////////////////

/*
///////////////////////////////////////////// 에뮬레이터명 / 필터명 셋팅 start /////////////////////////////////////////////
//local title = fe.add_text( "[DisplayName] - [FilterName]",	0, 0, fe.layout.width/2, fe.layout.height / 30 );
//local title = fe.add_text( "[DisplayName] - [FilterName]",	0, 0-8, fe.layout.width/2, fe.layout.height / 20 );
title.align = Align.MiddleLeft;
title.charsize = 28;



if( my_config["textColor"] == "White")
	title.set_rgb(255,255,255);	
else
	title.set_rgb(0,0,0);
*/

///////////////////////////////////////////// 에뮬레이터명 / 필터명 셋팅 end /////////////////////////////////////////////


/*
///////////////////////////////////////////// 게임 리스트, 카테고리, 풀네임, 프레이어수 셋팅 start /////////////////////////////////////////////
gridc.num_t = fe.add_text( "[ListEntry] / [ListSize]",	fe.layout.width/2, 0-8, fe.layout.width/2, fe.layout.height / 20 );
gridc.num_t.align= Align.MiddleRight;
gridc.num_t.charsize = 28;

if( my_config["textColor"] == "White")
	gridc.num_t.set_rgb(255,255,255);	
else
	gridc.num_t.set_rgb(0,0,0);
///////////////////////////////////////////// 게임 리스트, 카테고리, 풀네임, 프레이어수 셋팅 end /////////////////////////////////////////////
*/

///////////////////////////////////////////// 선택 Grid Snap 셋팅 start /////////////////////////////////////////////
if ( my_config["sel_video"] == "No" || my_config["all_video"] == "Yes" )
{
	// 아무작업 안함
}
else
{
	gridc.sel_snap=fe.add_artwork( "snap", width * 2, height * 2, width - 2*PAD, height - 2*PAD);
	gridc.sel_snap.video_flags =  Vid.NoAudio;
	//gridc.sel_snap.preserve_aspect_ratio = (my_config["aspect_ratio"]=="Yes");
	gridc.sel_snap.preserve_aspect_ratio = false;

}
//gridc.sel_snap.trigger = Transition.EndNavigation;
///////////////////////////////////////////// 선택 Grid Snap 셋팅 end /////////////////////////////////////////////



///////////////////////////////////////////// Scnaline 셋팅 end /////////////////////////////////////////////
gridc.update_frame();


///////////////////////////////////////////// 즐겨찾기 셋팅 start /////////////////////////////////////////////
 function gamefav( index_offset ) {

	local fav = fe.game_info(  Info.Favourite , index_offset );
	if( fav == "1" )
	{
		return  "favoriteStarMini.png";
	}
	else
	{
		return "empty.png";

	}


 return "";
}

 function gamefavStar( index_offset ) {

	local fav = fe.game_info(  Info.Favourite , index_offset );
	if( fav == "1" )
	{
		return  "★";
	}
	else
	{
		return "empty.png";

	}


 return "";
}

///////////////////////////////////////////// 즐겨찾기 셋팅 end /////////////////////////////////////////////

function deleteRom()
{
	fe.set_display(  fe.list.display_index   );
	local optionsYn = ["예", "아니오"];
	local command = fe.overlay.list_dialog( optionsYn,  "'" +fe.game_info(Info.Name) + "' 롬파일을 지우시겠습니까?");
	// 0 예  1 아니오  -1 취소

	local emulator = "\""+ fe.game_info(Info.Emulator ) + "\"";	
	local filename = "\""+ fe.game_info(Info.Name ) + "\"";	

	local del_exec = "/home/pi/dev/delRomList";
//	local arg_exec = "\"" +emulator  + "\" \""  + filename + "\"";
	local arg_exec = emulator  + " "+ filename;

	if( command == 0 )	// 예
	{
		fe.plugin_command( del_exec, arg_exec );
		fe.set_display(  fe.list.display_index   );
		//fe.signal( "reset_window" );
			
	}
	else
	{
	}
}

