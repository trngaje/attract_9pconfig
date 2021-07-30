
class UserConfig { 
	</ label="시계 테마", help="시계 테마", options="2,1", order=1  /> 	theme = "2";
	</ label="시간 타입(12,24)", help="시간 타입(12,24)", options="24,12", order=2 /> hourType = "12";
	</ label="알람 활성화", help="알람 활성화", options="YES,NO", order=3 /> alarm_yn = "NO";
	</ label="알람 시간(hour) 설정", help="알람 시간(hour) 설정", options="23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0", order=4 /> alarm_hour = 7;
	</ label="알람 분(min) 설정", help="알람 분(min) 설정", options="59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0", order=5 /> alarm_min = 0;
	</ label="Ani Gif or 앨범액자 활성화", help="Ani Gif or 앨범액자 활성화", options="YES,NO", order=6 /> useAni="NO";
	</ label="Ani Gif or 앨범액자 변경주기(분)", help="Ani GIf or 앨범액자 변경주기(분)", options="59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1", order=7 /> cycleTime=1;
	</ label="Ani Gif or 앨범액자 위치(시계 앞,뒤)", help="Ani Gif or 앨범액자 위치(시계 앞,뒤)", options="Front,Back", order=7 /> aniType="Front";
	</ label="Ani Gif or 앨범액자 위치(원본,화면꽉차게)", help="Ani Gif or 앨범액자 사이즈(원본,화면꽉차게)", options="Original,Full", order=8 /> aniSize="Full";
}

// UserConfig 로드
local my_config = fe.get_config();
local clockTheme = my_config["theme"];

fe.load_module("animate2");
fe.load_module("file");

fe.layout.font = "font";

fe.layout.width =  854;
fe.layout.height = 480;

local deviceWidth = fe.layout.width;
local deviceHeight  = fe.layout.height;

//////////////////////////////////////////////////////////////////////////////////////////////////////

local themeCount =	2;		// 테마 갯수

local ymd_red = 	255;		// 년.월.요일 rgb( red )
local ymd_green = 	255;		// 년.월.요일 rgb( green )
local ymd_blue = 	255;		// 년.월.요일 rgb( blue )

local clock_alpha = 	50;		// 시계 88:88:88 투명도
local clock_red = 	255;		// 시계 rgb( red )
local clock_green = 	255;		// 시계 rgb( green )
local clock_blue =	255;		// 시계 rgb( blue )

//////////////////////////////////////////////////////////////////////////////////////////////////////

// background color /////////////////////////////////////////////////////////////////////////////////////
//local leftBackground = fe.add_text("", 0, 0, 230, 240);
//local rightBackground = fe.add_text("", 230, 0, 90, 240);
//leftBackground.set_bg_rgb(0,0,0);
//rightBackground.set_bg_rgb(255,255,255);
//////////////////////////////////////////////////////////////////////////////////////////////////////
/*
function getThemeNum()
{
	local fp = file( fe.script_dir + "themeNum","r");
	local result = fp.readn('c');
	fp.close();
	return result;
}

function setThemeNum(num)
{
	local fp = file( fe.script_dir  + "themeNum","wb+");
	fp.writen(num,'c');
	fp.close();
}

local clockTheme = getThemeNum();
*/

//////////////// 랜덤 gif /////////////////////////////////////////////////
function random_file(path) 
{
	local dir = DirectoryListing( path );
	local dir_array = [];
	local filename;
	foreach ( f in dir.results )
	{
		/* 
		if(f.find(".png")!= null )
		{
			dir_array.append(f);
		}
		*/
		dir_array.append(f);
		
	}
	
	return dir_array[ rand()%dir_array.len()];
}

local playCycleTime = abs(("0"+my_config["cycleTime"]).tointeger());

local imageView;
if( my_config["aniType"] == "Back" )
{
	imageView = fe.add_image( "", 0,0,854,480);	
	if( my_config["aniSize"] == "Full" )
		imageView.preserve_aspect_ratio = false;
	else
		imageView.preserve_aspect_ratio = true;
	//imageView.video_flags = Vid.NoLoop | Vid.NoAudio;
	imageView.video_flags = Vid.NoAudio;
}

local usePlay = false;
local initPlay = false;


///////////////////////////////////////////////////////////////////////////



// 알람 활성 ////////////////////////////////////////////////////////////////////////////////////////
local alarmMusic = fe.add_sound("alarm/alarm.mp3");			// 알람 소리
local alarm_icon;
local alarm_pulse;
local alarmPlay = false;
/*
if( my_config["alarm_yn"] == "YES" )
{
	alarm_icon = fe.add_image( "./alarm/alarm-icon.png", 480, 40, 70,64);
	alarm_icon.preserve_aspect_ratio = true;
}
//PropertyAnimation(alarm_icon).key("alpha").from(0).to(255).loops(-1).yoyo().speed(2).play();

local alarmAnimation = {
    property = "alpha", start = 0, end = 255, time = 1000, loop = true, pulse = true
} 
local alarmAnimation2 = {
    property = "alpha", start = 255, end = 0, delay=1000, time = 1000, loop = true, pulse = true
} 
animation.add( PropertyAnimation( alarm_icon, alarmAnimation ) );

animation.add( PropertyAnimation( alarm_icon, alarmAnimation2 ) );
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// 시계 테마 1
if( clockTheme == "1" )
{	 
	if( my_config["alarm_yn"] == "YES" )
	{
		alarm_icon = fe.add_image( "./alarm/alarm-icon.png", 480, 40, 70,64);
		alarm_icon.preserve_aspect_ratio = true;
	}

	local clock_size =	270;		// 시계 폰트 크기
	local ymd_size = 	80;		// 년.월.요일 폰트 크기
	local day_size = 	80;		// 요일 크기

	local day1 = fe.add_text("월", 5,  60, 60, 20);	// 월
	local day2 = fe.add_text("화", 65,  60, 60, 20);	// 화
	local day3 = fe.add_text("수", 125, 60, 60, 20);	// 수
	local day4 = fe.add_text("목", 185, 60, 60, 20);	// 목
	local day5 = fe.add_text("금", 245, 60, 60, 20);	// 금
	local day6 = fe.add_text("토", 305, 60, 60, 20);	// 토
	local day0 = fe.add_text("일", 365, 60, 60, 20);	// 일

	day0.font = "BMDOHYEON_ttf";
	day1.font = "BMDOHYEON_ttf";
	day2.font = "BMDOHYEON_ttf";
	day3.font = "BMDOHYEON_ttf";
	day4.font = "BMDOHYEON_ttf";
	day5.font = "BMDOHYEON_ttf";
	day6.font = "BMDOHYEON_ttf";

	day0.align = Align.Centre;
	day1.align = Align.Centre;
	day2.align = Align.Centre;
	day3.align = Align.Centre;
	day4.align = Align.Centre;
	day5.align = Align.Centre;
	day6.align = Align.Centre;

	day0.set_rgb(255,255,255);
	day1.set_rgb(255,255,255);
	day2.set_rgb(255,255,255);
	day3.set_rgb(255,255,255);
	day4.set_rgb(255,255,255);
	day5.set_rgb(255,255,255);
	day6.set_rgb(255,255,255);
	
	day0.charsize = day_size/2.5;
	day1.charsize = day_size/2.5;
	day2.charsize = day_size/2.5;
	day3.charsize = day_size/2.5;
	day4.charsize = day_size/2.5;
	day5.charsize = day_size/2.5;
	day6.charsize = day_size/2.5;

	//day2.style = Style.Underlined;

	local secbarS = fe.add_text( "", 20, 445, 814, 15  );
	secbarS.set_bg_rgb(255,255,255);
	local secbarE = fe.add_text( "", 20, 445, 814, 15  );
	secbarE.set_bg_rgb(100,100,100);


	local yyyymmdd = fe.add_text( "", 480, 50, 400, 30 );
	yyyymmdd.align = Align.Right;
	yyyymmdd.charsize = ymd_size;		
	yyyymmdd.set_rgb( ymd_red, ymd_green, ymd_blue );
	yyyymmdd.font = "BMDOHYEON_ttf";
	//yyyymmdd.set_bg_rgb(200,200,200);

	local clockHourBg = fe.add_text("00", -135, 80, 650, 300);
	clockHourBg.alpha = clock_alpha;
	clockHourBg.font="CLOCK";	
	clockHourBg.style=Style.Bold;
	clockHourBg.charsize = clock_size;
	clockHourBg.set_rgb( clock_red, clock_green, clock_blue );
	clockHourBg.align = Align.Left;

	local clockMinBg = fe.add_text("00", 339, 80, 650, 300 );
	clockMinBg.alpha = clock_alpha;
	clockMinBg.font="CLOCK";	
	clockMinBg.style=Style.Bold;
	clockMinBg.charsize = clock_size;
	clockMinBg.set_rgb( clock_red, clock_green, clock_blue );
	clockMinBg.align = Align.Left;

	local clockDot = fe.add_text(":", 205, 80, 650, 300);
	clockDot.alpha = clock_alpha + 150;
	clockDot.font="CLOCK";	
	clockDot.style=Style.Bold;
	clockDot.charsize = clock_size;
	clockDot.set_rgb( clock_red, clock_green, clock_blue );
	clockDot.align = Align.Left;
	
	local clockHour = fe.add_text( "", -135, 80, 650, 300 );
	clockHour.align = Align.Left;
	clockHour.charsize = clock_size;
	clockHour.set_rgb( clock_red, clock_green, clock_blue );
	clockHour.font="CLOCK";
	clockHour.style=Style.Bold;
	//clockHour.set_bg_rgb(34,34,34);

	local clockMin = fe.add_text( "", 339, 80, 650, 300 );
	clockMin.align = Align.Left;
	clockMin.charsize = clock_size;
	clockMin.set_rgb( clock_red, clock_green, clock_blue );
	clockMin.font="CLOCK";
	clockMin.style=Style.Bold;

	local baseSec = 0;

	function update_clock( ttime )
	{
		local now = date();
		local hour = format("%02d", now.hour ).tointeger();
		local min =  format("%02d", now.min ).tointeger();
		local sec =  format("%02d", now.sec ).tointeger();

		if( baseSec == sec )
			return;
		else
			baseSec = sec;

		local week = "";

		day0.style = day1.style = day2.style = day3.style = day4.style = day5.style = day6.style = Style.Regular;
		day0.set_rgb(255,255,255);day1.set_rgb(255,255,255);day2.set_rgb(255,255,255);day3.set_rgb(255,255,255);day4.set_rgb(255,255,255);day5.set_rgb(255,255,255);day6.set_rgb(255,255,255);
		day0.charsize = day_size/2.5;
		day1.charsize = day_size/2.5;
		day2.charsize = day_size/2.5;
		day3.charsize = day_size/2.5;
		day4.charsize = day_size/2.5;
		day5.charsize = day_size/2.5;
		day6.charsize = day_size/2.5;
		switch( now.wday )
		{
			case 0:		day0.set_rgb(29,219,22); day0.charsize = day_size;	break;
			case 1:		day1.set_rgb(29,219,22); day1.charsize = day_size;	break;
			case 2:		day2.set_rgb(29,219,22); day2.charsize = day_size;	break;
			case 3:		day3.set_rgb(29,219,22); day3.charsize = day_size;	break;
			case 4:		day4.set_rgb(29,219,22); day4.charsize = day_size;	break;
			case 5:		day5.set_rgb(29,219,22); day5.charsize = day_size;	break;
			case 6:		day6.set_rgb(29,219,22); day6.charsize = day_size;	break;
			default:	;	break;
			
		}


		local hourAMPM = format("%02d", now.hour ).tointeger();
		if( my_config["hourType"] == "12" )
		{
			if( hourAMPM > 12 )
				clockHour.msg = "" + format("%02d", hourAMPM-12);
			else
				clockHour.msg = "" + format("%02d", now.hour);
		}
		else
		{
			clockHour.msg = "" + format("%02d", now.hour);
		}

		
		clockMin.msg = "" + format("%02d", now.min );

		local secbarOne = 13.5 * sec;
		secbarE.x = 20 + secbarOne;
		secbarE.width = 814 - secbarOne;

		switch( week )
		{
			case "Mon":	week = "월";	break;
			case "Tue":	week = "화";	break;
			case "Wed":	week = "수";	break;
			case "Thu":	week = "목";	break;
			case "Fri":	week = "금";	break;
			case "Sat":	week = "토";	break;
			case "Sun":	week = "일";	break;
			default:	week = "-";	break;
		}
		
		//yyyymmdd.msg = format("%02d", now.month+1 ) + "." + format("%02d", now.day ) + "." + week ;
		yyyymmdd.msg = format("%02d", now.month+1 ) + "." + format("%02d", now.day );


		// 알람 플레이
		if( alarmPlay == true )
		{
			if( !alarmMusic.playing )
			{
				alarmMusic.playing = true;
			}
		}
		if( my_config["alarm_yn"] == "YES" )
		{
			local alarm_hour = abs(("0"+my_config["alarm_hour"]).tointeger());
			local alarm_min = abs(("0"+my_config["alarm_min"]).tointeger());
			if( hour == alarm_hour && min == alarm_min && sec == 0 )
			{
				alarmPlay = true;
				//PropertyAnimation(alarm_icon).key("alpha").from(0).to(255).loops(-1).yoyo().speed(2).play();
				
			}

		}

		// ani view
		if( my_config["useAni"] == "YES" )
		{
			if( initPlay == false )
			{
				imageView.file_name = random_file("./album");
				initPlay = true;
			}
			
			if( min%playCycleTime == 0 && sec == 0 && usePlay == false )
			{
				imageView.file_name = random_file("./album");
				usePlay = true;
			}	
	
			if( min%playCycleTime == 0 && sec == 1 && usePlay == true )
			{
				usePlay = false;
			}
		}


	}
	fe.add_ticks_callback( this, "update_clock" );

}

// 시계 테마 2
if( clockTheme == "2" )
{
	if( my_config["alarm_yn"] == "YES" )
	{
		alarm_icon = fe.add_image( "./alarm/alarm-icon.png", 200, 365, 70,64);
		alarm_icon.preserve_aspect_ratio = true;
	}
	local clock_size =	270;
	local ymd_size = 	80;		// 년.월.요일 폰트 크기
	local day_size =	80;

	local day = fe.add_text("", -40, 380, 200, 20);
	day.font = "BMDOHYEON_ttf";
	day.align = Align.Centre;
	day.set_rgb(255,255,255);	
	day.charsize = day_size;

	local day2 = fe.add_text("요일", -60, 400, 400, 20);
	day2.font = "BMDOHYEON_ttf";
	day2.align = Align.Centre;
	day2.set_rgb(255,255,255);	
	day2.charsize = day_size/2;


	local secbarS = fe.add_text( "", 20, 465, 814, 15  );
	secbarS.set_bg_rgb(255,255,255);
	local secbarE = fe.add_text( "", 20, 465, 814, 15  );
	secbarE.set_bg_rgb(100,100,100);

	local yyyymmdd = fe.add_text( "", 520, 70, 350, 30 );
	yyyymmdd.align = Align.Right;
	yyyymmdd.charsize = ymd_size;		
	yyyymmdd.set_rgb( ymd_red, ymd_green, ymd_blue );
	yyyymmdd.font = "BMDOHYEON_ttf";
	//yyyymmdd.set_bg_rgb(200,200,200);

	local clockHourBg = fe.add_text("00", -135, 0, 650, 300);
	clockHourBg.alpha = clock_alpha;
	clockHourBg.font="CLOCK";	
	clockHourBg.style=Style.Bold;
	clockHourBg.charsize = clock_size;
	clockHourBg.set_rgb( clock_red, clock_green, clock_blue );
	clockHourBg.align = Align.Left;

	local clockMinBg = fe.add_text("00", 339, 110, 650, 300 );
	clockMinBg.alpha = clock_alpha;
	clockMinBg.font="CLOCK";	
	clockMinBg.style=Style.Bold;
	clockMinBg.charsize = clock_size;
	clockMinBg.set_rgb( clock_red, clock_green, clock_blue );
	clockMinBg.align = Align.Left;

	local clockDot = fe.add_text(":", 205, 70, 650, 300);
	clockDot.alpha = clock_alpha + 150;
	clockDot.font="CLOCK";	
	clockDot.style=Style.Bold;
	clockDot.charsize = clock_size;
	clockDot.set_rgb( clock_red, clock_green, clock_blue );
	clockDot.align = Align.Left;
	
	local clockHour = fe.add_text( "", -135, 0, 650, 300 );
	clockHour.align = Align.Left;
	clockHour.charsize = clock_size;
	clockHour.set_rgb( clock_red, clock_green, clock_blue );
	clockHour.font="CLOCK";
	clockHour.style=Style.Bold;
	//clockHour.set_bg_rgb(34,34,34);

	local clockMin = fe.add_text( "", 339, 110, 650, 300 );
	clockMin.align = Align.Left;
	clockMin.charsize = clock_size;
	clockMin.set_rgb( clock_red, clock_green, clock_blue );
	clockMin.font="CLOCK";
	clockMin.style=Style.Bold;


	local baseSec = 0;
	function update_clock( ttime )
	{
		local now = date();
		local hour = format("%02d", now.hour ).tointeger();
		local min =  format("%02d", now.min ).tointeger();
		local sec =  format("%02d", now.sec ).tointeger();

		if( baseSec == sec )
			return;
		else
			baseSec = sec;
	

		local week = "";

		//clock.msg = "" + format("%02d", now.hour) + ":" + format("%02d", now.min ) + ":" + format("%02d", now.sec );
		local hourAMPM = format("%02d", now.hour ).tointeger();
		if( my_config["hourType"] == "12" )
		{
			if( hourAMPM > 12 )
				clockHour.msg = "" + format("%02d", hourAMPM-12);
			else
				clockHour.msg = "" + format("%02d", now.hour);
		}
		else
		{
			clockHour.msg = "" + format("%02d", now.hour);
		}
		clockMin.msg = "" + format("%02d", now.min );
	
		local secbarOne = 13.5 * sec;
		secbarE.x = 20 + secbarOne;
		secbarE.width = 814 - secbarOne;

		yyyymmdd.msg = format("%02d", now.month+1 ) + "." + format("%02d", now.day );

		switch( now.wday )
		{
			case 0:		day.msg = "일"; break;
			case 1:		day.msg = "월"; break;
			case 2:		day.msg = "화"; break;
			case 3:		day.msg = "수"; break;
			case 4:		day.msg = "목"; break;
			case 5:		day.msg = "금"; break;
			case 6:		day.msg = "토"; break;
			default:	;	break;			
		}

		// 알람 플레이
		if( alarmPlay == true )
		{
			if( !alarmMusic.playing )
			{
				alarmMusic.playing = true;
			}
		}
		if( my_config["alarm_yn"] == "YES" )
		{
			local alarm_hour = abs(("0"+my_config["alarm_hour"]).tointeger());
			local alarm_min = abs(("0"+my_config["alarm_min"]).tointeger());
			if( hour == alarm_hour && min == alarm_min && sec == 0 )
			{
				alarmPlay = true;
				//PropertyAnimation(alarm_icon).key("alpha").from(0).to(255).loops(-1).yoyo().speed(2).play();
			}
		}	

		// ani view
		if( my_config["useAni"] == "YES" )
		{
			if( initPlay == false )
			{
				imageView.file_name = random_file("./album");
				initPlay = true;
			}
			
			if( min%playCycleTime == 0 && sec == 0 && usePlay == false )
			{
				imageView.file_name = random_file("./album");
				usePlay = true;
			}	
	
			if( min%playCycleTime == 0 && sec == 1 && usePlay == true )
			{
				usePlay = false;
			}
		}

	}
	fe.add_ticks_callback( this, "update_clock" );
	
}



// 조작 시그널 핸들러

local rotateFlag = "None";
fe.add_signal_handler(  "on_signal" );
function on_signal( sig )
{
	switch ( sig )	
	{
		case "custom1":
			if( rotateFlag == "None" )
			{
				fe.layout.base_rotation = RotateScreen.Flip;
				rotateFlag = "Flip";
			}
			else
			{
				fe.layout.base_rotation = RotateScreen.None;
				rotateFlag = "None";
			}

			return true;
	}
	
	return false;
}




if( my_config["aniType"] == "Front" )
{
	imageView = fe.add_image( "", 0,0,854,480);	
	if( my_config["aniType"] == "Full" )
		imageView.preserve_aspect_ratio = false;
	else
		imageView.preserve_aspect_ratio = true;
	//imageView.video_flags = Vid.NoLoop | Vid.NoAudio;
	imageView.video_flags = Vid.NoAudio;
}