const ASSETS_BASE = "/home/odroid/.attract/menu-art/sbx/assets/";
/* ============================================ */
/*               Magic Token 처리               */
/* ============================================ */
// Display MENU에서는 [Emulator] 메직토큰이 안먹히기 때문에 Info.Name으로 대체함
function SBXGet_SystemEmulatorName() {
    return fe.game_info(Info.Name, 0, 0);
    x
}

/* ============================================ */
/*          SNAP 디렉토리를 반환한다.           */
/* ============================================ */
function SBXGet_SnapVideo()
{
  local name = fe.game_info( Info.Name, 0, 0 );
  if( name == "fbneo" || name.find("mame") != null ) name = "arcade";

  return "/roms/"+name+"/snap";
}

function SBXGet_ArtSnapVideo()
{
  local artfile = fe.get_art("snap");
  if( artfile == "" ) artfile = ASSETS_PATH + "images/static.mp4";
  else artfile = artfile;
  return artfile;
}
/* ============================================ */
/*    FanArt 반환한다.                          */
/* ============================================ */
function SBXGet_FanArt()
{
  local name = fe.game_info( Info.Name, 0, 0 );
  if( name == "fbneo" || name.find("mame") != null ) name = "arcade";

  return "/roms/"+name+"/fanart";
}
/* ============================================ */
/*    Marquee 반환한다.                          */
/* ============================================ */
function SBXGet_Marquee()
{
  local name = fe.game_info( Info.Name, 0, 0 );
  if( name == "fbneo" || name.find("mame") != null ) name = "arcade";

  return "/roms/"+name+"/marquee";
}
/* ============================================ */
/*    Wheel 반환한다.                          */
/* ============================================ */
function SBXGet_Wheel()
{
  local name = fe.game_info( Info.Name, 0, 0 );
  if( name == "fbneo" || name.find("mame") != null ) name = "arcade";

  return "/roms/"+name+"/wheel";
}

/* ============================================ */
/*     Assets의 Console 반환한다.               */
/* ============================================ */
function SBXGet_AssetsConsole()
{
  local name = fe.game_info( Info.Name, 0, 0 );
  return ASSETS_BASE + "console/"+name+".png";

}

/* ============================================ */
/*     Assets의 Panel Logo \반환한다.           */
/* ============================================ */
function SBXGet_AssetsPanelLogos()
{
  local name = fe.game_info( Info.Name, 0, 0 );
  return ASSETS_BASE + "panels/"+name+".jpg";
}

/* ============================================ */
/*     Overview 정보를 읽어온다                 */
/* ============================================ */
function SBXGet_AssetsOverview()
{        
  local name = fe.game_info( Info.Name, 0, 0 );
  local result = ASSETS_BASE + "overview/"+name+".xml";
  print( "SBXGet_AssetsOverview ===> "+result);

  return result;
  //return ASSETS_BASE + "overview/neogeo.xml";
}


/* ============================================ */
/*     FanArt 정보를 읽어온다                 */
/* ============================================ */
function SBXGet_AssetsArt()
{
  local name = fe.game_info( Info.Name, 0, 0 );
  return ASSETS_BASE + "arts/"+name+".png";
}

