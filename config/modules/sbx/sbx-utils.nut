fe.load_module( "file" );

function SBXGet_TxtFile(filename)
{
    local result = "";
    local textfile = txt.loadFile( filename );
    foreach( line in textfile.lines )
    {
        result = result + line;
    }        
    return result;
}


// ==================================================
//   지정한 MAX값내에서 랜덤값(정수)를 반환 
// ==================================================
function SBXGet_RandomIntValue(max) {
    // Generate a pseudo-random integer between 0 and max
    local roll = 1.0 * max * rand() / RAND_MAX;
    return roll.tointeger();
}

/* ============================================== */
/*  OVERVIEW 시스템 또는 게임의 정보를 처리한다.  */
/* ============================================== */
function SBXLoad_Overview(filename)
{
    local overview = [
        [ "", "제조사", "판매년도", "", "", "", "", "", "", "" ],
        [ "", "", "", "", "", "", "", "", "", "" ]
    ];

    try
    {
        local xmlfile = xml.loadFile( filename );
        local rootXML = xmlfile.children[0];
        
        local index = 3;
        foreach( child in rootXML.children )
        {
            local tag = child.tag;
            if( tag == "desc" )                 overview[1][OVERVIEW_DESC]         = ( "text" in child ) ? child.text : "";
            else if( tag == "Manufacturer" )    overview[1][OVERVIEW_MANUFACTOR]   = ( "text" in child ) ? child.text : "";
            else if( tag == "Release" )         overview[1][OVERVIEW_RELEASE]      = ( "text" in child ) ? child.text : "";

            else if( tag == "info")
            {
                overview[0][index] = ("label" in child.attr ) ? child.attr["label"] : "";
                overview[1][index] = ( "text" in child ) ? child.text : "";
                index++;
            }
        }
    }
    catch(e)
    {}

    return overview;
}


/* ============================================ */
/*    file_exists   파일이 있는지 검사          */
/*    - Full Path로 넣어야한다, 상대경로 안됨   */
/* ============================================ */
function file_exist(fullpathfilename) {
    try {
        file(fullpathfilename, "r");
        return true;
    } catch (e) {
        return false;
    }
}

/* ============================================ */
/*    시그널 및 도움말 설정                     */
/* ============================================ */
SBX_HelpImage <- null;
function SBXSet_Help( system_type, x, y, w, h )
{
    local help = ASSETS_PATH + "help/system-help.png";
    if( system_type.tolower() != "system" ) help = "[!SBXGet_EmulatorHelp]";

    SBX_HelpImage = fe.add_image( help, x, y, w, h );
    SBX_HelpImage.visible=false;
}

/* ============================================ */
/*    게임목록에서 사용하는                     */
/*    컨트롤(조작) 도움말 이미지를 반환한다.    */
/* ============================================ */
function SBXGet_ControlHelp()
{
  return ASSETS_PATH + "help/detail-control-help.png";
}

/* =================================================== */
/*    게임목록에서 사용하는                            */
/*    에뮬레이터별 (조작) 도움말 이미지를 반환한다.    */
/* =================================================== */
function SBXGet_EmulatorHelp( ioffset )
{
	local emulator = fe.displays[fe.list.display_index].name;
	local full_path = ASSETS_PATH + "help/"+emulator+"-help.png";

	if( file_exist( full_path ) )
	  return full_path;
	else
	  return ASSETS_PATH + "help/detail-help.png";
}

// 커서이동시 사운드 발생.png
function move_sound()
{
	// local selectMusic = fe.add_sound(ASSETS_PATH + "sound/ps2_click.mp3");
	// selectMusic.playing=true;
}

