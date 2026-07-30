// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

#include <a_samp>
#include <lethaldudb2>
#include <ocmd>//SERIALBAN
#include <SII>//SERIALBAN
#include <geolocation>

#include <OnPlayerPause>

//#include <foreach>
#pragma tabsize 0
#pragma dynamic 145000
#define COLOUR_ERRO 0xFF0000FF
#define COLOUR_BRANCO 0xFFFFFFFF


// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

new StringTable[][] =
{
"| ERRO |: Você está em uma arena. Para sair: /sair",
"| ERRO |: O teleporte não aceita este veículo",
"| ERRO |: Você está em um local em que os teleportes são bloqueados",
"| ERRO |: Você não pode se teleportar dentro do evento. Para sair: /SAIR",
"| ERRO |: Este teleporte está temporariamente desabilitado",
"| INFO |: Se os objetos estiverem invisíveis, saia de seu veículo e entre novamente",
"| ERRO |: Você não pode usar este comando com pouca vida",
"| ERRO |: Você deve sair do interior",
"| ERRO |: Você não tem permissão para isso",
"| ERRO |: Você já está em uma arena. Para sair: /sair",
"| ERRO |: Jogador não conectado"
};

/*
|===============================================|
|		--== Adminscript ==--            |
|         -==  Version 6.2  ==--                |
|			   ladmin6v2.pwn                    |
|===============================================|
*/

#define Kick(%0) SetTimerEx("Kicka", 100, false, "i", %0)

forward Kicka(p); public Kicka(p) {
    #undef Kick
    Kick(p);
    #define Kick(%0) SetTimerEx("Kicka", 100, false, "i", %0)
    return 1;
}


#define Ban(%0) SetTimerEx("Bana", 100, false, "i", %0)

forward Bana(p); public Bana(p) {
    #undef Ban
    Ban(p);
    #define Ban(%0) SetTimerEx("Bana", 100, false, "i", %0)
    return 1;
}

//-----------------------------------------------------------------------------------//

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

new bool:BlockSalvador = true;
new MultaAviso[MAX_PLAYERS];
new KillerTick[MAX_PLAYERS];
new LATickCount;
new ComandosNoLOG = 1;
new bool:AdmHidden[MAX_PLAYERS] = false;
new bool:VipHidden[MAX_PLAYERS] = false;
new bool:Direitos[MAX_PLAYERS] = false;
new PermitidoADMMudarNick[MAX_PLAYERS];
new lercmds[MAX_PLAYERS];
new USARDIALOGOS = 1;
new UsarLoginTimeout = 1;
new LoginTimeoutTimer[MAX_PLAYERS];
new bool:StatusHora;


//new StringPaused[256];
new AFK[MAX_PLAYERS];

//new mrj[MAX_PLAYERS];
//new d3x[MAX_PLAYERS];
//new bmf[MAX_PLAYERS];
//new vks[MAX_PLAYERS];
//new mvx[MAX_PLAYERS];
//new boy[MAX_PLAYERS];
//new nrx[MAX_PLAYERS];

//new admnivel2[256];

//#define USE_MENUS       	// Comment to remove all menus.  Uncomment to enable menus
//#define DISPLAY_CONFIG 	// displays configuration in console window on filterscript load
#define SAVE_LOGS           // Comment if your server runs linux (logs wont be saved)
//#define ENABLE_SPEC         // Comment if you are using a spectate system already
#define USE_STATS           // Comment to disable /stats
//#define ANTI_MINIGUN        // Displays who has a minigun
//#define USE_AREGISTER       // Changes /register, /login etc to  /areister, /alogin etc
#define ENABLE_FAKE_CMDS   	// Comment to disable /fakechat, /fakedeath, /fakecmd commanads

//-----------------------------------------------------------------------------------//

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

#define MAX_WARNINGS 3      // /warn command

#define MAX_REPORTS 8
#define MAX_CHAT_LINES 7

#define SPAM_MAX_MSGS 5
#define SPAM_TIMELIMIT 8 // SECONDS

#define PING_MAX_EXCEEDS 4
#define PING_TIMELIMIT 60 // SECONDS

#define MAX_FAIL_LOGINS 4

#define NAMES 24 // 26

//GRANA SERVER-SIDE DECLARAÇÕES
#define ResetMoneyBar ResetPlayerMoney
#define UpdateMoneyBar GivePlayerMoney
new Cash[MAX_PLAYERS];
new ReportTick[MAX_PLAYERS];
new AvisoTick[MAX_PLAYERS];
new HourTimeStamp;

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

// ----------------------------
//new SendCMDToRCON = false;
new MudarNick = 1;
new DGTRY[MAX_PLAYERS];
new ExplodirTimer[MAX_PLAYERS];
//new Text:ANTIFAIL;

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

new CrashNicks[NAMES][] =
{
"com1", "com2", "com3", "com4", "com5", "com6", "com7", "com8", "com9",
"lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9",
"nul", "clock$", "aux", "prn", "con","Pepe"
};

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

// Admin Area
/*new AdminArea[6] = {
377, 	// X
170, 	// Y
1008, 	// Z
90,     // Angle
3,      // Interior
0		// Virtual World
};*/

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

new AdminArea[6] = {
302, 	// X
-1169, 	// Y
81, 	// Z
1,     // Angle
0,      // Interior
0		// Virtual World
};

new VIPAREA[6] = {
528, 	// X
3197, 	// Y
6+2, 	// Z
1,     // Angle
0,      // Interior
0		// Virtual World
};

/*
1801, 	// X
-1303, 	// Y
120, 	// Z
1,     // Angle
0,      // Interior
0		// Virtual World
};
*/


// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com


//-=Main colours=-
#define blue 0x375FFFFF
#define red 0xFF0000AA
#define azulmarinho 0x00FFEEAA
#define green 0x33FF33AA
#define yellow 0xFFFF00AA
#define grey 0xC0C0C0AA
#define blue1 0x2641FEAA
#define lightblue 0x33CCFFAA
#define orange 0xFF9900AA
#define black 0x2C2727AA
#define grey 0xC0C0C0AA
#define red 0xFF0000AA
#define COLOR_LIGHTBLUE 0x009FF6F6
#define COLOR_WHITE	0xFFFFFFAA
#define COLOR_ORANGE	0xFF9900AA
#define Vred 0xFF0000AA
#define COLOR_RED 0xFF0000AA
#define COLOR_NOVO	0x009FF6F6
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_LIMON	0x33FF33AA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_PINK 0xFF66FFAA
#define COLOR_BLUE 0x0000BBAA
#define COLOR_PURPLE 0x800080AA
#define COLOR_BLACK 0x000000AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_GREEN1 0x33AA33AA
#define COLOR_BROWN 0xA52A2AAA

#define COLOR_GREY      0x969696FF//SERIALBAN
#define COLOR_BAN               0xA9C4E4FF//SERIALBAN

#define COLOUR_CHATPROX 0x03F2FFFF

#define COLOUR_INFORMACAO 0x33FF33AA

native gpci(playerid, const serial[ ], maxlen);//SERIALBAN

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

// DCMD
#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

// Caps
#define UpperToLower(%1) for ( new ToLowerChar; ToLowerChar < strlen( %1 ); ToLowerChar ++ ) if ( %1[ ToLowerChar ]> 64 && %1[ ToLowerChar ] < 91 ) %1[ ToLowerChar ] += 32

// Spec
#define ADMIN_SPEC_TYPE_NONE 0
#define ADMIN_SPEC_TYPE_PLAYER 1
#define ADMIN_SPEC_TYPE_VEHICLE 2





new
	Float: p_PlayerBuggerX[ MAX_PLAYERS ],
	Float: p_PlayerBuggerY[ MAX_PLAYERS ],
	Float: p_PlayerBuggerZ[ MAX_PLAYERS ]
;

// Enums
enum PlayerData
{
	Registered,
	//PlayerSkin,
	LoggedIn,
	Level,
	VIP,
	Head,
	HeadLevado,
	Corridas,
	Corridasg2,
	Corridasgg3,
    EVENTOPremiar,
    EVENTOPremiar2,
    EVENTOPremiar3,
	X1Ganhos,
	X1Perdidos,
	X1WGanhos,
	X1WPerdidos,
	X1PGanhos,
	X1PPerdidos,
	X1SGanhos,
	X1SPerdidos,
	X1LGanhos,
	X1LPerdidos,
	PistolaGanhos,
    PistolaPerdidos,
	RUNGanhos,
    RUNPerdidos,
	WALKGanhos,
	WALKPerdidos,
	SNPGanhos,
	SNPPerdidos,
	Muted,
	Caps,
	Jailed,
	JailTime,
	Frozen,
	FreezeTime,
	Kills,
	Deaths,
	hours,
	mins,
	secs,
	TotalTime,
	ConnectTime,
 	MuteWarnings,
	Warnings,
	Spawned,
	TimesSpawned,
	God,
	GodCar,
	DoorsLocked,
	SpamCount,
	SpamTime,
	PingCount,
	PingTime,
	BotPing,
	pPing[PING_MAX_EXCEEDS],
	blip,
	blipS,
	pColour,
	pCar,
//	SpecID,
//	SpecType,
	bool:AllowedIn,
	FailLogin,
	LastSkin,
	LastColor,
	LastGC,
	LastTrancar,
	LastSpree,
	LastPCSStatus,
	LastPCSStatus_I,
	LastPCSStatus_X,
	LastPCSStatus_Y,
	LastPCSStatus_Z,
	LastPCSStatus_F,
	LastRojoes,
//	LastContarHeadShot,
//	LastContarHeadShotLevados,
};
new PlayerInfo[MAX_PLAYERS][PlayerData];

enum ServerData
{
	MaxPing,
	ReadPMs,
	ReadCmds,
	MaxAdminLevel,
	MaxVIPLevel,
	AdminOnlySkins,
	AdminSkin,
	AdminSkin2,
	NameKick,
	PartNameKick,
	AntiBot,
	AntiSpam,
 	AntiSwear,
 	NoCaps,
	Locked,
	Password[128],
	GiveWeap,
	GiveMoney,
	ConnectMessages,
	AdminCmdMsg,
	AutoLogin,
	MaxMuteWarnings,
	DisableChat,
	MustLogin,
	MustRegister,
};
new ServerInfo[ServerData];

new Float:Pos[MAX_PLAYERS][4];

// rcon
new Chat[MAX_CHAT_LINES][128];

//Timers
new PingTimer;
new GodTimer;
new BlipTimer[MAX_PLAYERS];
new JailTimer[MAX_PLAYERS];
new FreezeTimer[MAX_PLAYERS];
new LockKickTimer[MAX_PLAYERS];

//Duel
new CountDown = -1, cdt[MAX_PLAYERS] = -1;
new InDuel[MAX_PLAYERS];

// Menus
#if defined USE_MENUS
new Menu:LMainMenu, Menu:AdminEnable, Menu:AdminDisable,
    Menu:LVehicles, Menu:twodoor, Menu:fourdoor, Menu:fastcar, Menu:Othercars,
	Menu:bikes, Menu:boats, Menu:planes, Menu:helicopters,
    Menu:XWeapons, Menu:XWeaponsBig, Menu:XWeaponsSmall, Menu:XWeaponsMore,
    Menu:LWeather,Menu:LTime,
    Menu:LTuneMenu, Menu:PaintMenu, Menu:LCars, Menu:LCars2,
    Menu:LTele, Menu:LasVenturasMenu, Menu:LosSantosMenu, Menu:SanFierroMenu,
	Menu:DesertMenu, Menu:FlintMenu, Menu:MountChiliadMenu,	Menu:InteriorsMenu;
#endif

// Forbidden Names & Words
new BadNames[100][100], // Whole Names
    BadNameCount = 0,
	BadPartNames[100][100], // Part of name
    BadPartNameCount = 0,
    ForbiddenWords[100][100],
    ForbiddenWordCount = 0;

// Report
new Reports[MAX_REPORTS][128];

// Ping Kick
new PingPos;

new bool:TempADM[MAX_PLAYERS];


new VehicleNames[212][] = {
	"Landstalker","Bravura","Buffalo","Linerunner","Pereniel","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana","Infernus",
	"Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat","Mr Whoopee","BF Injection",
	"Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie",
	"Stallion","Rumpo","RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder",
	"Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
	"Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR3 50","Walton","Regina",
	"Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher","Virgo","Greenwood",
	"Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa","RC Goblin","Hotring Racer A","Hotring Racer B",
	"Bloodring Banger","Rancher","Super GT","Elegant","Journey","Bike","Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain",
	"Nebula","Majestic","Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
	"Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover",
	"Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A",
	"Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight","Trailer",
	"Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer A","Emperor",
	"Wayfarer","Euros","Hotdog","Club","Trailer B","Trailer C","Andromada","Dodo","RC Cam","Launch","Police Car (LSPD)","Police Car (SFPD)",
	"Police Car (LVPD)","Police Ranger","Picador","S.W.A.T. Van","Alpha","Phoenix","Glendale","Sadler","Luggage Trailer A","Luggage Trailer B",
	"Stair Trailer","Boxville","Farm Plow","Utility Trailer"
};

//==============================================================================

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

public OnFilterScriptInit()
{
/*
    if(!fexist("mrj.ini")) dini_Create("mrj.ini");
    if(!fexist("d3x.ini")) dini_Create("d3x.ini");
    if(!fexist("bmf.ini")) dini_Create("bmf.ini");
    if(!fexist("vks.ini")) dini_Create("vks.ini");
    if(!fexist("mvx.ini")) dini_Create("mvx.ini");
    if(!fexist("boy.ini")) dini_Create("boy.ini");
    if(!fexist("nrx.ini")) dini_Create("nrx.ini");
*/
    StatusHora = true;
    BlockSalvador = true;
	if(dini_Exists("server_timestamps.ini")){
	HourTimeStamp = dini_Int("server_timestamps.ini","HourTimeStamp");
	}else{HourTimeStamp = 0;}

    AntiDeAMX();
    
	/*print("\n________________________________________");
	print("________________________________________");
	print("           LAdmin Loading...            ");
	print("________________________________________");*/

	SetTimer("MoneyTimer", 900, 1);
	SetTimer("Update_TS_Hour", 3600000, 1); //HORA EM HORA
//    SetTimer("Tempo",3000,true);
/*
	ANTIFAIL = TextDrawCreate(122.000000, 421.000000, "   ");
	TextDrawBackgroundColor(ANTIFAIL, -1);
	TextDrawFont(ANTIFAIL, 1);
	TextDrawLetterSize(ANTIFAIL, 0.330000, 1.299999);
	TextDrawColor(ANTIFAIL, 65535);
	TextDrawSetOutline(ANTIFAIL, 1);
	TextDrawSetProportional(ANTIFAIL, 1);
*/

	if(!fexist("ladmin/"))
	{
	    print("\n\n > WARNING: Folder Missing From Scriptfiles\n");
	  	SetTimerEx("PrintWarning",2500,0,"s","ladmin");
		return 1;
	}
	if(!fexist("ladmin/logs/"))
	{
	    print("\n\n > WARNING: Folder Missing From Scriptfiles\n");
	  	SetTimerEx("PrintWarning",2500,0,"s","ladmin/logs");
		return 1;
	}
	if(!fexist("ladmin/config/"))
	{
	    print("\n\n > WARNING: Folder Missing From Scriptfiles\n");
	  	SetTimerEx("PrintWarning",2500,0,"s","ladmin/config");
		return 1;
	}
	if(!fexist("ladmin/users/"))
	{
	    print("\n\n > WARNING: Folder Missing From Scriptfiles\n");
	  	SetTimerEx("PrintWarning",2500,0,"s","ladmin/users");
		return 1;
	}
	
	UpdateConfig();

	#if defined DISPLAY_CONFIG
	ConfigInConsole();
	#endif

	//===================== [ The Menus ]===========================//
	#if defined USE_MENUS

	LMainMenu = CreateMenu("Menu Principal", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LMainMenu, 0, "Escolha uma opcao");
	AddMenuItem(LMainMenu, 0, "Ativar");
	AddMenuItem(LMainMenu, 0, "Desativar");
    AddMenuItem(LMainMenu, 0, "Clima");
    AddMenuItem(LMainMenu, 0, "Horario");
 	AddMenuItem(LMainMenu, 0, "Todos veiculos");
	AddMenuItem(LMainMenu, 0, "Carros de admins");
	AddMenuItem(LMainMenu, 0, "Tuning menu");
	AddMenuItem(LMainMenu, 0, "Escolher armas");
	AddMenuItem(LMainMenu, 0, "Teleportes");
	AddMenuItem(LMainMenu, 0, "Sair do menu");//

	AdminEnable = CreateMenu("~b~Configuracao ~g~ Menu",2, 55.0, 200.0, 150.0, 80.0);
	SetMenuColumnHeader(AdminEnable, 0, "Ativar");
	AddMenuItem(AdminEnable, 0, "Anti Palavrao");
	AddMenuItem(AdminEnable, 0, "Anti Nome Mal");
	AddMenuItem(AdminEnable, 0, "Anti Spam");
	AddMenuItem(AdminEnable, 0, "Anti Ping alto");
	AddMenuItem(AdminEnable, 0, "Ler Comandos");
	AddMenuItem(AdminEnable, 0, "Ler PMs");
	AddMenuItem(AdminEnable, 0, "Letras Maiusculas");
	AddMenuItem(AdminEnable, 0, "ConnectMessages");
	AddMenuItem(AdminEnable, 0, "AdminCmdMessages");
	AddMenuItem(AdminEnable, 0, "Auto Login");
	AddMenuItem(AdminEnable, 0, "Retornar");

	AdminDisable = CreateMenu("~b~Configuracao ~g~ Menu",2, 55.0, 200.0, 150.0, 80.0);
	SetMenuColumnHeader(AdminEnable, 0, "Desativar");
	AddMenuItem(AdminDisable, 0, "Anti Palavrao");
	AddMenuItem(AdminDisable, 0, "Anti Nome Mal");
	AddMenuItem(AdminDisable, 0, "Anti Spam");
	AddMenuItem(AdminDisable, 0, "Anti Ping alto");
	AddMenuItem(AdminDisable, 0, "Ler Comandos");
	AddMenuItem(AdminDisable, 0, "Ler PMs");
	AddMenuItem(AdminDisable, 0, "Letras Maiusculas");
	AddMenuItem(AdminDisable, 0, "ConnectMessages");
	AddMenuItem(AdminDisable, 0, "AdminCmdMessages");
	AddMenuItem(AdminDisable, 0, "Auto Login");
	AddMenuItem(AdminDisable, 0, "Retornar");

	LWeather = CreateMenu("~b~Clima ~g~ Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LWeather, 0, "Escolha o Clima");
	AddMenuItem(LWeather, 0, "Ceu Azul Limpo");
	AddMenuItem(LWeather, 0, "Temp. Areia");
	AddMenuItem(LWeather, 0, "Tempestade");
	AddMenuItem(LWeather, 0, "Nebuloso");
	AddMenuItem(LWeather, 0, "Nublado");
	AddMenuItem(LWeather, 0, "Mare Alta");
	AddMenuItem(LWeather, 0, "Ceu Rosa");
	AddMenuItem(LWeather, 0, "Ceu Preto/Branco");
	AddMenuItem(LWeather, 0, "Ceu Preto/Verde");
	AddMenuItem(LWeather, 0, "Onda de Calor");
	AddMenuItem(LWeather,0,"Retornar");

	LTime = CreateMenu("~b~Tempo ~g~ Menu", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LTime, 0, "Escolha o Turno");
	AddMenuItem(LTime, 0, "Manha");
	AddMenuItem(LTime, 0, "Meio Dia");
	AddMenuItem(LTime, 0, "Tarde");
	AddMenuItem(LTime, 0, "Escurecer");
	AddMenuItem(LTime, 0, "Meia Noite");
    AddMenuItem(LTime, 0, "Retornar");

	LCars = CreateMenu("~b~LethaL ~g~Carros", 2,  55.0, 150.0, 100.0, 80.0);
	SetMenuColumnHeader(LCars, 0, "Escolha o Carro");
	AddMenuItem(LCars, 0, "Turismo");
	AddMenuItem(LCars, 0, "Bandito");
	AddMenuItem(LCars, 0, "Vortex");
	AddMenuItem(LCars, 0, "NRG");
	AddMenuItem(LCars, 0, "S.W.A.T");
    AddMenuItem(LCars, 0, "Hunter");
    AddMenuItem(LCars, 0, "Jetmax (boat)");
    AddMenuItem(LCars, 0, "Rhino");
    AddMenuItem(LCars, 0, "Monster Truck");
    AddMenuItem(LCars, 0, "Sea Sparrow");
    AddMenuItem(LCars, 0, "More");
	AddMenuItem(LCars, 0, "Retornar");

	LCars2 = CreateMenu("~b~LethaL ~g~Carros", 2,  55.0, 150.0, 100.0, 80.0);
	SetMenuColumnHeader(LCars2, 0, "Escolha o Carro");
	AddMenuItem(LCars2, 0, "Dumper");
    AddMenuItem(LCars2, 0, "RC Tank");
    AddMenuItem(LCars2, 0, "RC Bandit");
    AddMenuItem(LCars2, 0, "RC Baron");
    AddMenuItem(LCars2, 0, "RC Goblin");
    AddMenuItem(LCars2, 0, "RC Raider");
    AddMenuItem(LCars2, 0, "RC Cam");
    AddMenuItem(LCars2, 0, "Tram");
	AddMenuItem(LCars2, 0, "Retornar");

	LTuneMenu = CreateMenu("~b~Tuning ~g~ Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LTuneMenu, 0, "Tune o Carro");
	AddMenuItem(LTuneMenu,0,"NOS");
	AddMenuItem(LTuneMenu,0,"Hydraulico");
	AddMenuItem(LTuneMenu,0,"Wire Wheels");
	AddMenuItem(LTuneMenu,0,"Twist Wheels");
	AddMenuItem(LTuneMenu,0,"Access Wheels");
	AddMenuItem(LTuneMenu,0,"Mega Wheels");
	AddMenuItem(LTuneMenu,0,"Import Wheels");
	AddMenuItem(LTuneMenu,0,"Atomic Wheels");
	AddMenuItem(LTuneMenu,0,"Offroad Wheels");
	AddMenuItem(LTuneMenu,0,"Classic Wheels");
	AddMenuItem(LTuneMenu,0,"Pinturas");
	AddMenuItem(LTuneMenu,0,"Retornar");

	PaintMenu = CreateMenu("~b~Pintura ~g~ Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(PaintMenu, 0, "Escolha a Pintura");
	AddMenuItem(PaintMenu,0,"Pintura 1");
	AddMenuItem(PaintMenu,0,"Pintura 2");
	AddMenuItem(PaintMenu,0,"Pintura 3");
	AddMenuItem(PaintMenu,0,"Pintura 4");
	AddMenuItem(PaintMenu,0,"Pintura 5");
	AddMenuItem(PaintMenu,0,"Preto");
	AddMenuItem(PaintMenu,0,"Branco");
	AddMenuItem(PaintMenu,0,"Azul");
	AddMenuItem(PaintMenu,0,"Pink");
	AddMenuItem(PaintMenu,0,"Retornar");

	LVehicles = CreateMenu("~b~Vehicles ~g~ Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LVehicles, 0, "Escolha o carro");
	AddMenuItem(LVehicles,0,"2 Portas");
	AddMenuItem(LVehicles,0,"4 Portas");
	AddMenuItem(LVehicles,0,"Rapidos");
	AddMenuItem(LVehicles,0,"Outros");
	AddMenuItem(LVehicles,0,"Bikes");
	AddMenuItem(LVehicles,0,"Botes");
	AddMenuItem(LVehicles,0,"Avioes");
	AddMenuItem(LVehicles,0,"Helicopteros");
	AddMenuItem(LVehicles,0,"Retornar");

 	twodoor = CreateMenu("~b~2 Portas",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(twodoor, 0, "Escolha o carro");
	AddMenuItem(twodoor,0,"Feltzer");//533
	AddMenuItem(twodoor,0,"Stallion");//139
	AddMenuItem(twodoor,0,"Windsor");//555
	AddMenuItem(twodoor,0,"Bobcat");//422
	AddMenuItem(twodoor,0,"Yosemite");//554
	AddMenuItem(twodoor,0,"Broadway");//575
	AddMenuItem(twodoor,0,"Blade");//536
	AddMenuItem(twodoor,0,"Slamvan");//535
	AddMenuItem(twodoor,0,"Tornado");//576
	AddMenuItem(twodoor,0,"Bravura");//401
	AddMenuItem(twodoor,0,"Fortune");//526
	AddMenuItem(twodoor,0,"Retornar");

 	fourdoor = CreateMenu("~b~4 Portas",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(fourdoor, 0, "Escolha o carro");
	AddMenuItem(fourdoor,0,"Perenniel");//404
	AddMenuItem(fourdoor,0,"Tahoma");//566
	AddMenuItem(fourdoor,0,"Voodoo");//412
	AddMenuItem(fourdoor,0,"Admiral");//445
	AddMenuItem(fourdoor,0,"Elegant");//507
	AddMenuItem(fourdoor,0,"Glendale");//466
	AddMenuItem(fourdoor,0,"Intruder");//546
	AddMenuItem(fourdoor,0,"Merit");//551
	AddMenuItem(fourdoor,0,"Oceanic");//467
	AddMenuItem(fourdoor,0,"Premier");//426
	AddMenuItem(fourdoor,0,"Sentinel");//405
	AddMenuItem(fourdoor,0,"Retornar");

 	fastcar = CreateMenu("~b~Rapidos",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(fastcar, 0, "Escolha o carro");
	AddMenuItem(fastcar,0,"Comet");//480
	AddMenuItem(fastcar,0,"Buffalo");//402
	AddMenuItem(fastcar,0,"Cheetah");//415
	AddMenuItem(fastcar,0,"Euros");//587
	AddMenuItem(fastcar,0,"Hotring Racer");//494
	AddMenuItem(fastcar,0,"Infernus");//411
	AddMenuItem(fastcar,0,"Phoenix");//603
	AddMenuItem(fastcar,0,"Super GT");//506
	AddMenuItem(fastcar,0,"Turismo");//451
	AddMenuItem(fastcar,0,"ZR-350");//477
	AddMenuItem(fastcar,0,"Bullet");//541
	AddMenuItem(fastcar,0,"Retornar");

 	Othercars = CreateMenu("~b~Outros Carros",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(Othercars, 0, "Escolha o carro");
	AddMenuItem(Othercars,0,"Monster Truck");//556
	AddMenuItem(Othercars,0,"Trashmaster");//408
	AddMenuItem(Othercars,0,"Bus");//431
	AddMenuItem(Othercars,0,"Coach");//437
	AddMenuItem(Othercars,0,"Enforcer");//427
	AddMenuItem(Othercars,0,"Rhino (Tank)");//432
	AddMenuItem(Othercars,0,"S.W.A.T.Truck");//601
	AddMenuItem(Othercars,0,"Cement Truck");//524
	AddMenuItem(Othercars,0,"Flatbed");//455
	AddMenuItem(Othercars,0,"BF Injection");//424
	AddMenuItem(Othercars,0,"Dune");//573
	AddMenuItem(Othercars,0,"Retornar");

 	bikes = CreateMenu("~b~Bikes",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(bikes, 0, "Escolha a bike");
	AddMenuItem(bikes,0,"BF-400");
	AddMenuItem(bikes,0,"BMX");
	AddMenuItem(bikes,0,"Faggio");
	AddMenuItem(bikes,0,"FCR-900");
	AddMenuItem(bikes,0,"Freeway");
	AddMenuItem(bikes,0,"NRG-500");
	AddMenuItem(bikes,0,"PCJ-600");
	AddMenuItem(bikes,0,"Pizzaboy");
	AddMenuItem(bikes,0,"Quad");
	AddMenuItem(bikes,0,"Sanchez");
	AddMenuItem(bikes,0,"Wayfarer");
	AddMenuItem(bikes,0,"Retornar");

 	boats = CreateMenu("~b~Botes",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(boats, 0, "Escolha o bote");
	AddMenuItem(boats,0,"Coastguard");//472
	AddMenuItem(boats,0,"Dingy");//473
	AddMenuItem(boats,0,"Jetmax");//493
	AddMenuItem(boats,0,"Launch");//595
	AddMenuItem(boats,0,"Marquis");//484
	AddMenuItem(boats,0,"Predator");//430
	AddMenuItem(boats,0,"Reefer");//453
	AddMenuItem(boats,0,"Speeder");//452
	AddMenuItem(boats,0,"Squallo");//446
	AddMenuItem(boats,0,"Tropic");//454
	AddMenuItem(boats,0,"Retornar");

 	planes = CreateMenu("~b~Avioes",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(planes, 0, "Escolha o aviao");
	AddMenuItem(planes,0,"Andromada");//592
	AddMenuItem(planes,0,"AT400");//577
	AddMenuItem(planes,0,"Beagle");//511
	AddMenuItem(planes,0,"Cropduster");//512
	AddMenuItem(planes,0,"Dodo");//593
	AddMenuItem(planes,0,"Hydra");//520
	AddMenuItem(planes,0,"Nevada");//553
	AddMenuItem(planes,0,"Rustler");//476
	AddMenuItem(planes,0,"Shamal");//519
	AddMenuItem(planes,0,"Skimmer");//460
	AddMenuItem(planes,0,"Stuntplane");//513
	AddMenuItem(planes,0,"Retornar");

	helicopters = CreateMenu("~b~Helicopteros",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(helicopters, 0, "Escolha o Heli.");
	AddMenuItem(helicopters,0,"Cargobob");//
	AddMenuItem(helicopters,0,"Hunter");//
	AddMenuItem(helicopters,0,"Leviathan");//
	AddMenuItem(helicopters,0,"Maverick");//
	AddMenuItem(helicopters,0,"News Chopper");//
	AddMenuItem(helicopters,0,"Police Maverick");//
	AddMenuItem(helicopters,0,"Raindance");//
	AddMenuItem(helicopters,0,"Seasparrow");//
	AddMenuItem(helicopters,0,"Sparrow");//
	AddMenuItem(helicopters,0,"Retornar");

 	XWeapons = CreateMenu("~b~Armas ~g~Menu P.",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(XWeapons, 0, "Escolha a arma");
	AddMenuItem(XWeapons,0,"Desert Eagle");//0
	AddMenuItem(XWeapons,0,"M4");
	AddMenuItem(XWeapons,0,"Sawnoff Shotgun");
	AddMenuItem(XWeapons,0,"Combat Shotgun");
	AddMenuItem(XWeapons,0,"UZI");
	AddMenuItem(XWeapons,0,"Rocket Launcher");
	AddMenuItem(XWeapons,0,"Minigun");//6
	AddMenuItem(XWeapons,0,"Sniper Rifle");
	AddMenuItem(XWeapons,0,"Big Armas");
	AddMenuItem(XWeapons,0,"Armas leves");//9
	AddMenuItem(XWeapons,0,"Mais...");
	AddMenuItem(XWeapons,0,"Retornar");//11

 	XWeaponsBig = CreateMenu("~b~Armas ~g~Big Armas",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(XWeaponsBig, 0, "Escolha a arma");
	AddMenuItem(XWeaponsBig,0,"Shotgun");
	AddMenuItem(XWeaponsBig,0,"AK-47");
	AddMenuItem(XWeaponsBig,0,"Country Rifle");
	AddMenuItem(XWeaponsBig,0,"HS Rocket Launcher");
	AddMenuItem(XWeaponsBig,0,"Flamethrower");
	AddMenuItem(XWeaponsBig,0,"SMG");
	AddMenuItem(XWeaponsBig,0,"TEC9");
	AddMenuItem(XWeaponsBig,0,"Retornar");

 	XWeaponsSmall = CreateMenu("~b~Armas ~g~Armas leves",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(XWeaponsBig, 0, "Escolha a arma");
	AddMenuItem(XWeaponsSmall,0,"9mm");
	AddMenuItem(XWeaponsSmall,0,"Silenced 9mm");
	AddMenuItem(XWeaponsSmall,0,"Molotov Cocktail");
	AddMenuItem(XWeaponsSmall,0,"Fire Extinguisher");
	AddMenuItem(XWeaponsSmall,0,"Spraycan");
	AddMenuItem(XWeaponsSmall,0,"Frag Grenades");
	AddMenuItem(XWeaponsSmall,0,"Katana");
	AddMenuItem(XWeaponsSmall,0,"Chainsaw");
	AddMenuItem(XWeaponsSmall,0,"Retornar");

 	XWeaponsMore = CreateMenu("~b~Armas ~g~Mais Armas",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(XWeaponsBig, 0, "Escolha a arma");
	AddMenuItem(XWeaponsMore,0,"Jetpack");
	AddMenuItem(XWeaponsMore,0,"Knife");
	AddMenuItem(XWeaponsMore,0,"Flowers");
	AddMenuItem(XWeaponsMore,0,"Camera");
	AddMenuItem(XWeaponsMore,0,"Pool Cue");
	AddMenuItem(XWeaponsMore,0,"Baseball Bat");
	AddMenuItem(XWeaponsMore,0,"Golf Club");
	AddMenuItem(XWeaponsMore,0,"MUNICAO MAX");
	AddMenuItem(XWeaponsMore,0,"Retornar");

	LTele = CreateMenu("Teleportes", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LTele, 0, "Para onde?");
	AddMenuItem(LTele, 0, "Las Venturas");//0
	AddMenuItem(LTele, 0, "Los Santos");//1
	AddMenuItem(LTele, 0, "San Fierro");//2
	AddMenuItem(LTele, 0, "O Deserto");//3
	AddMenuItem(LTele, 0, "Flint Country");//4
	AddMenuItem(LTele, 0, "Monte Chiliad");//5
	AddMenuItem(LTele, 0, "Interiores");//6
	AddMenuItem(LTele, 0, "Retornar");//8

	LasVenturasMenu = CreateMenu("Las Venturas", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LasVenturasMenu, 0, "Para onde?");
	AddMenuItem(LasVenturasMenu, 0, "The Strip");//0
	AddMenuItem(LasVenturasMenu, 0, "Come-A-Lot");//1
	AddMenuItem(LasVenturasMenu, 0, "LV Airport");//2
	AddMenuItem(LasVenturasMenu, 0, "KACC Military Fuels");//3
	AddMenuItem(LasVenturasMenu, 0, "Yellow Bell Golf Club");//4
	AddMenuItem(LasVenturasMenu, 0, "Baseball Pitch");//5
	AddMenuItem(LasVenturasMenu, 0, "Retornar");//6

	LosSantosMenu = CreateMenu("Los Santos", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LosSantosMenu, 0, "Para onde?");
	AddMenuItem(LosSantosMenu, 0, "Ganton");//0
	AddMenuItem(LosSantosMenu, 0, "LS Airport");//1
	AddMenuItem(LosSantosMenu, 0, "Ocean Docks");//2
	AddMenuItem(LosSantosMenu, 0, "Pershing Square");//3
	AddMenuItem(LosSantosMenu, 0, "Verdant Bluffs");//4
	AddMenuItem(LosSantosMenu, 0, "Santa Maria Beach");//5
	AddMenuItem(LosSantosMenu, 0, "Mulholland");//6
	AddMenuItem(LosSantosMenu, 0, "Richman");//7
	AddMenuItem(LosSantosMenu, 0, "Retornar");//8

	SanFierroMenu = CreateMenu("San Fierro", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(SanFierroMenu, 0, "Para onde?");
	AddMenuItem(SanFierroMenu, 0, "SF Station");//0
	AddMenuItem(SanFierroMenu, 0, "SF Airport");//1
	AddMenuItem(SanFierroMenu, 0, "Ocean Flats");//2
	AddMenuItem(SanFierroMenu, 0, "Avispa Country Club");//3
	AddMenuItem(SanFierroMenu, 0, "Easter Basin (docks)");//4
	AddMenuItem(SanFierroMenu, 0, "Esplanade North");//5
	AddMenuItem(SanFierroMenu, 0, "Battery Point");//6
	AddMenuItem(SanFierroMenu, 0, "Retornar");//7

	DesertMenu = CreateMenu("Deserto", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(DesertMenu, 0, "Para onde?");
	AddMenuItem(DesertMenu, 0, "Aircraft Graveyard");//0
	AddMenuItem(DesertMenu, 0, "Area 51");//1
	AddMenuItem(DesertMenu, 0, "The Big Ear");//2
	AddMenuItem(DesertMenu, 0, "The Sherman Dam");//3
	AddMenuItem(DesertMenu, 0, "Las Barrancas");//4
	AddMenuItem(DesertMenu, 0, "El Quebrados");//5
	AddMenuItem(DesertMenu, 0, "Octane Springs");//6
	AddMenuItem(DesertMenu, 0, "Retornar");//7

	FlintMenu = CreateMenu("Flint Country", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(FlintMenu, 0, "Para onde?");
	AddMenuItem(FlintMenu, 0, "The Lake");//0
	AddMenuItem(FlintMenu, 0, "Leafy Hollow");//1
	AddMenuItem(FlintMenu, 0, "The Farm");//2
	AddMenuItem(FlintMenu, 0, "Shady Cabin");//3
	AddMenuItem(FlintMenu, 0, "Flint Range");//4
	AddMenuItem(FlintMenu, 0, "Becon Hill");//5
	AddMenuItem(FlintMenu, 0, "Fallen Tree");//6
	AddMenuItem(FlintMenu, 0, "Retornar");//7

	MountChiliadMenu = CreateMenu("Mount Chiliad", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(MountChiliadMenu, 0, "Para onde?");
	AddMenuItem(MountChiliadMenu, 0, "Chiliad Jump");//0
	AddMenuItem(MountChiliadMenu, 0, "Bottom Of Chiliad");//1
	AddMenuItem(MountChiliadMenu, 0, "Highest Point");//2
	AddMenuItem(MountChiliadMenu, 0, "Chiliad Path");//3
	AddMenuItem(MountChiliadMenu, 0, "Retornar");//7

	InteriorsMenu = CreateMenu("Interiores", 2,  55.0, 200.0, 130.0, 80.0);
	SetMenuColumnHeader(InteriorsMenu, 0, "Para onde?");
	AddMenuItem(InteriorsMenu, 0, "Planning Department");//0
	AddMenuItem(InteriorsMenu, 0, "LV PD");//1
	AddMenuItem(InteriorsMenu, 0, "Pizza Stack");//2
	AddMenuItem(InteriorsMenu, 0, "RC Battlefield");//3
	AddMenuItem(InteriorsMenu, 0, "Caligula's Casino");//4
	AddMenuItem(InteriorsMenu, 0, "Big Smoke's Crack Palace");//5
	AddMenuItem(InteriorsMenu, 0, "Madd Dogg's Mansion");//6
	AddMenuItem(InteriorsMenu, 0, "Dirtbike Stadium");//7
	AddMenuItem(InteriorsMenu, 0, "Vice Stadium (duel)");//8
	AddMenuItem(InteriorsMenu, 0, "Ammu-nation");//9
	AddMenuItem(InteriorsMenu, 0, "Atrium");//7
	AddMenuItem(InteriorsMenu, 0, "Retornar");//8
	#endif

	for (new i = 0; i < MAX_PLAYERS; i++){if(IsPlayerConnected(i)){{OnPlayerConnect(i);SetPlayerHealth(i,0.0);ForceClassSelection(i);}}}
	for(new i = 1; i < MAX_CHAT_LINES; i++) Chat[i] = "<none>";
	for(new i = 1; i < MAX_REPORTS; i++) Reports[i] = "<none>";

	PingTimer = SetTimer("PingKick",5155,1);
	GodTimer = SetTimer("GodUpdate",2129,1);
	SetTimer("LATickUpdate",1000,1);

	/*new year,month,day;	getdate(year, month, day);
	new hour,minute,second; gettime(hour,minute,second);
	print("________________________________________");
	print("           LAdmin Version 4.0           ");
	print("                Loaded                  ");
	print("________________________________________");
	printf("     Date: %d/%d/%d  Time: %d:%d :%d   ",day,month,year, hour, minute, second);
	print("________________________________________");
	print("________________________________________\n");*/

	LoadConfig();

	SaveToFile("InicioFim","LADMIN Inicializado");
	
	return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

//==============================================================================
public OnFilterScriptExit()
{



	KillTimer(PingTimer);
	KillTimer(GodTimer);
	#if defined USE_MENUS
	DestroyAllMenus();
	#endif

//	TextDrawDestroy(ANTIFAIL);

	
	new year,month,day;	getdate(year, month, day);
	new hour,minute,second; gettime(hour,minute,second);
	//print("\n________________________________________");
	//print("________________________________________");
	//print("           LAdmin Unloaded              ");
	//print("________________________________________");
	//printf("     Date: %d/%d/%d  Time: %d:%d :%d   ",day,month,year, hour, minute, second);
	//print("________________________________________");
	//print("________________________________________\n");
	SaveToFile("InicioFim","LADMIN Finalizado");
	return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

//==============================================================================
public OnPlayerConnect(playerid)
{
/*
if(dini_Isset("mrj.ini",PlayerName2(playerid))) (mrj[playerid] = dini_Int("mrj.ini",PlayerName2(playerid)));
if(dini_Isset("d3x.ini",PlayerName2(playerid))) (d3x[playerid] = dini_Int("d3x.ini",PlayerName2(playerid)));
if(dini_Isset("bmf.ini",PlayerName2(playerid))) (bmf[playerid] = dini_Int("bmf.ini",PlayerName2(playerid)));
if(dini_Isset("vks.ini",PlayerName2(playerid))) (vks[playerid] = dini_Int("vks.ini",PlayerName2(playerid)));
if(dini_Isset("mvx.ini",PlayerName2(playerid))) (mvx[playerid] = dini_Int("mvx.ini",PlayerName2(playerid)));
if(dini_Isset("boy.ini",PlayerName2(playerid))) (boy[playerid] = dini_Int("boy.ini",PlayerName2(playerid)));
if(dini_Isset("nrx.ini",PlayerName2(playerid))) (nrx[playerid] = dini_Int("nrx.ini",PlayerName2(playerid)));
*/


  MultaAviso[playerid] = 0;
    KillerTick[playerid] = LATickCount;
    AdmHidden[playerid] = false;
    VipHidden[playerid] = false;
    Direitos[playerid] = false;
    PermitidoADMMudarNick[playerid] = 0;
	TempADM[playerid] = false;
	lercmds[playerid] = 1;
    SetPlayerColor(playerid, 0xFFFFFFFF);
    KillTimer(LoginTimeoutTimer[playerid]);
    KillTimer(JailTimer[playerid]);
    KillTimer(BlipTimer[playerid]);
    PlayerInfo[playerid][blip] = 0;
    JailTimer[playerid] = 0;
    //TogglePlayerSpectating(playerid,1);
    DGTRY[playerid] = 0;
    ReportTick[playerid] = 0;
    AvisoTick[playerid] = 0;
	KillTimer(ExplodirTimer[playerid]);
	
	//SetPVarInt(playerid, "pCar", -1);
    //SetPVarInt(playerid, "ConnectTime", gettime());
    
	PlayerInfo[playerid][Warnings] = 0;
	PlayerInfo[playerid][Deaths] = 0;
	PlayerInfo[playerid][Kills] = 0;
	PlayerInfo[playerid][Jailed] = 0;
	PlayerInfo[playerid][Frozen] = 0;
	PlayerInfo[playerid][Level] = 0;
	PlayerInfo[playerid][VIP] = 0;
	PlayerInfo[playerid][LoggedIn] = 0;
	PlayerInfo[playerid][Registered] = 0;
	PlayerInfo[playerid][Head] = 0;
	PlayerInfo[playerid][HeadLevado] = 0;
	PlayerInfo[playerid][Corridas] = 0;
	PlayerInfo[playerid][Corridasg2] = 0;
	PlayerInfo[playerid][Corridasgg3] = 0;
	PlayerInfo[playerid][EVENTOPremiar] = 0;
	PlayerInfo[playerid][EVENTOPremiar2] = 0;
	PlayerInfo[playerid][EVENTOPremiar3] = 0;
	PlayerInfo[playerid][X1Ganhos] = 0;
	PlayerInfo[playerid][X1Perdidos] = 0;
	PlayerInfo[playerid][X1WGanhos] = 0;
	PlayerInfo[playerid][X1WPerdidos] = 0;
	PlayerInfo[playerid][X1PGanhos] = 0;
	PlayerInfo[playerid][X1PPerdidos] = 0;
	PlayerInfo[playerid][X1SGanhos] = 0;
	PlayerInfo[playerid][X1SPerdidos] = 0;
	PlayerInfo[playerid][X1LGanhos] = 0;
	PlayerInfo[playerid][X1LPerdidos] = 0;
	PlayerInfo[playerid][PistolaGanhos] = 0;
	PlayerInfo[playerid][PistolaPerdidos] = 0;
	PlayerInfo[playerid][RUNGanhos] = 0;
	PlayerInfo[playerid][RUNPerdidos] = 0;
	PlayerInfo[playerid][WALKGanhos] = 0;
	PlayerInfo[playerid][WALKPerdidos] = 0;
	PlayerInfo[playerid][SNPGanhos] = 0;
	PlayerInfo[playerid][SNPPerdidos] = 0;
	PlayerInfo[playerid][God] = 0;
	PlayerInfo[playerid][GodCar] = 0;
	PlayerInfo[playerid][TimesSpawned] = 0;
	PlayerInfo[playerid][Muted] = 0;
	PlayerInfo[playerid][MuteWarnings] = 0;
	PlayerInfo[playerid][Warnings] = 0;
	PlayerInfo[playerid][Caps] = 0;
	PlayerInfo[playerid][DoorsLocked] = 0;
	PlayerInfo[playerid][pCar] = -1;
	for(new i; i<PING_MAX_EXCEEDS; i++) PlayerInfo[playerid][pPing][i] = 0;
	PlayerInfo[playerid][SpamCount] = 0;
	PlayerInfo[playerid][SpamTime] = 0;
	PlayerInfo[playerid][PingCount] = 0;
	PlayerInfo[playerid][PingTime] = 0;
	PlayerInfo[playerid][FailLogin] = 0;
	
	PlayerInfo[playerid][LastColor] = 0;
	PlayerInfo[playerid][LastSkin] = 0;
	PlayerInfo[playerid][LastTrancar] = 0;
	PlayerInfo[playerid][LastGC] = 0;
	PlayerInfo[playerid][LastSpree] = 0;
	
	PlayerInfo[playerid][LastPCSStatus] = 0;
	PlayerInfo[playerid][LastPCSStatus_I] = 0;
	PlayerInfo[playerid][LastPCSStatus_X] = 0;
	PlayerInfo[playerid][LastPCSStatus_Y] = 0;
	PlayerInfo[playerid][LastPCSStatus_Z] = 0;
	PlayerInfo[playerid][LastPCSStatus_F] = 0;
	PlayerInfo[playerid][LastRojoes] = 0;
	PlayerInfo[playerid][ConnectTime] = gettime();
	SetPlayerScore(playerid, 0);
	SetPlayerCash(playerid, 0);

//    PlayerInfo[playerid][LastContarHeadShot] = 0;
//    PlayerInfo[playerid][LastContarHeadShotLevados] = 0;

	//MANUTENÇÃO DO AKA
	if(fexist("ladmin/config/aka.txt")){
	new File:AkaList = fopen("ladmin/config/aka.txt", io_readwrite);
	if(flength(AkaList) > 153600){
	fclose(AkaList);
	fremove("ladmin/config/aka.txt");
	AkaList = fopen("ladmin/config/aka.txt", io_write);
	fwrite(AkaList," ");
	print("[MANUTENÇÃO]: AKA LIMPO AUTOMATICAMENTE POR PASSAR DE 150 KB");}
	fclose(AkaList);}
	
	//--------------------------------B----------------------
	new PlayerName[MAX_PLAYER_NAME], string[128], file[256];//str[128]
	GetPlayerName(playerid, PlayerName, MAX_PLAYER_NAME);
	new tmp3[50]; GetPlayerIp(playerid,tmp3,50);
	//-----------------------------------------------------
/*
	if(ServerInfo[ConnectMessages] == 1)
	{
	    new pAKA[256]; pAKA = dini_Get("ladmin/config/aka.txt",tmp3);
		if (strlen(pAKA) < 3) format(str,sizeof(str),"{00FFFB}*** %s {FFFFFF}(%d) {00FFFB}entrou no servidor", PlayerName, playerid);
		else if (!strcmp(pAKA,PlayerName,true)) format(str,sizeof(str),"*** %s (%d) entrou no servidor", PlayerName, playerid);
		else format(str,sizeof(str),"*** %s (%d) entrou no servidor (aka %s)", PlayerName, playerid, pAKA );

		for (new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && playerid != i)
		{
			if(PlayerInfo[i][Level] > 2) SendClientMessage(i,grey,str);
			else {
				format(string,sizeof(string),"*** %s (%d) entrou no servidor", PlayerName, playerid);
			 	SendClientMessage(i,grey,string);
			}
		}
	}*/
	//-----------------------------------------------------
 if(fexist(GetPlayerSerialINI(playerid))) {
                SendClientMessage(playerid,COLOR_BAN,"Voce Esta banido deste servidor!-Serial-Ban.");
                Ban(playerid);
        }
	//-----------------------------------------------------
    if (dUserINT(PlayerName2(playerid)).("banned") == 1)
    {
		format(string,sizeof(string),"%s ID:%d foi auto-kickado. Motivo: OLD",PlayerName,playerid);
		GameTextForPlayer(playerid,"_~n~_~n~_~n~_~n~_~n~_~n~_~n~~r~VOCE ESTA BANIDO DAQUI SEU N00B!",10000,3);
		//SendClientMessageToAll(grey, string); //Mensagem OLD
		SendClientMessage(playerid, red, "");
		SendClientMessage(playerid, red, "VOCÊ ESTÁ BANIDO DESTE SERVIDOR");
		SendClientMessage(playerid, red, "");
		print(string);
		SaveToFile("KickLog",string);  Kick(playerid);
    }
	//-----------------------------------------------------
	    if (dUserINT(PlayerName2(playerid)).("tmpb") == 1)
   	 {
    	if((HourTimeStamp - dUserINT(PlayerName2(playerid)).("tmpbs")) < dUserINT(PlayerName2(playerid)).("tmpbh")){
		new tmpstr[200];
		format(string,sizeof(string),"%s ID:%d foi auto-kickado. Motivo: TEMPORARIAMENTE BANIDO",PlayerName,playerid);
		format(tmpstr,sizeof(tmpstr),"DURAÇÃO DO BAN: %i HORAS",dUserINT(PlayerName2(playerid)).("tmpbh"));
		GameTextForPlayer(playerid,"_~n~_~n~_~n~_~n~_~n~_~n~_~n~~r~VOCE ESTA BANIDO DAQUI!",10000,3);
		SendClientMessageToAll(grey, string);
		SendClientMessage(playerid, red, "");
		SendClientMessage(playerid, red, "VOCÊ ESTÁ TEMPORARIAMENTE BANIDO DESTE SERVIDOR");
		SendClientMessage(playerid, green, tmpstr);
		SendClientMessage(playerid, red, "");
		print(string);
		SaveToFile("KickLog",string);  Kick(playerid);
		}else{
		new accfile[255];
		format(accfile,sizeof(accfile),"/ladmin/users/%s.sav",udb_encode(PlayerName));
		//dUserSetINT(PlayerName2(playerid)).("tmpb",0);
		//dUserSetINT(PlayerName2(playerid)).("tmpbs",0);
		//dUserSetINT(PlayerName2(playerid)).("tmpbh",0);
		dini_Unset(accfile,"tmpb");
		dini_Unset(accfile,"tmpbs");
        dini_Unset(accfile,"tmpbh");
		}
	 }
	//-----------------------------------------------------
	
	
	if(ServerInfo[NameKick] == 1) {
		for(new s = 0; s < BadNameCount; s++) {
  			if(!strcmp(BadNames[s],PlayerName,true)) {
				SendClientMessage(playerid,red, "Seu nome esta na lista de nomes proibidos, voce foi kickado.");
				format(string,sizeof(string),"{00FFFB}%s ID:%d foi auto-kickado. (Motivo: Nome proibido)",PlayerName,playerid);
				SendClientMessageToAll(grey, string);  print(string);
				 Kick(playerid); SaveToFile("KickLog",string);  Kick(playerid);
				return 1;
			}
		}
	}
	//-----------------------------------------------------
	if(ServerInfo[PartNameKick] == 1) {
		for(new s = 0; s < BadPartNameCount; s++) {
			new pos;
			while((pos = strfind(PlayerName,BadPartNames[s],true)) != -1) for(new i = pos, j = pos + strlen(BadPartNames[s]); i < j; i++)
			{
				SendClientMessage(playerid,red, "Seu nickname nao e permitido neste servidor, voce foi kickado.");
				format(string,sizeof(string),"%s ID:%d foi auto-kickado. (Motivo: Nome proibido)",PlayerName,playerid);
				SendClientMessageToAll(grey, string);  print(string);
				SaveToFile("KickLog",string);  Kick(playerid);
				return 1;
			}
		}
	}
	//-----------------------------------------------------
	if(ServerInfo[Locked] == 1) {
		PlayerInfo[playerid][AllowedIn] = false;
		SendClientMessage(playerid,red,"O Servidor esta bloqueado!  Voce tem 20 segundos para fazer login, ou sera kickado.");
		SendClientMessage(playerid,red," Digite /password [senha]");
		LockKickTimer[playerid] = SetTimerEx("AutoKick", 20000, 0, "i", playerid);
	}
	//-----------------------------------------------------
	if(strlen(dini_Get("ladmin/config/aka.txt", tmp3)) == 0) dini_Set("ladmin/config/aka.txt", tmp3, PlayerName);
 	else
	{
	    if( strfind( dini_Get("ladmin/config/aka.txt", tmp3), PlayerName, true) == -1 )
		{
		    format(string,sizeof(string),"%s,%s", dini_Get("ladmin/config/aka.txt",tmp3), PlayerName);
		    dini_Set("ladmin/config/aka.txt", tmp3, string);
		}
	}
	//-----------------------------------------------------
	
	

	

	if(USARDIALOGOS == 1){
	if(!udb_Exists(PlayerName2(playerid)))
	{

	}
	else
	{
	KillTimer(LoginTimeoutTimer[playerid]);
    LoginTimeoutTimer[playerid] = SetTimerEx("KickLoginTimeout",60000,0, "i", playerid);
 	PlayerInfo[playerid][Registered] = 1;
	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName));
	new tmp2[256]; tmp2 = dini_Get(file,"ip");
	if( (!strcmp(tmp3,tmp2,true)) && (ServerInfo[AutoLogin] == 1) )
	{
		LoginPlayer(playerid);
		if(PlayerInfo[playerid][Level] > 0)
		{
			format(string,sizeof(string),"| CONTA |: Voce foi automaticamente logado. (Nivel %d)", PlayerInfo[playerid][Level] );
			if (PlayerInfo[playerid][Level] > 6)
			{
				format(string,sizeof(string),"| CONTA |: Voce foi automaticamente logado. (Nivel %d - OWNER DO SERVIDOR)", PlayerInfo[playerid][Level] );
			}
			SendClientMessage(playerid,green,string);
   		}
	   	else SendClientMessage(playerid,green,"| CONTA |: Voce foi automaticamente logado.");
  	    }else {
		//ShowPlayerDialog(playerid,541,DIALOG_STYLE_INPUT,"Login","o Dos BR 2015 Login:","OK","Sair");
		}}

		}else{

if(!udb_Exists(PlayerName2(playerid))) SendClientMessage(playerid,orange, "| CONTA | : Digite /registrar [senha] para criar uma conta");
	else
	{
	    PlayerInfo[playerid][Registered] = 1;
		format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName));
		new tmp2[256]; tmp2 = dini_Get(file,"ip");
		if( (!strcmp(tmp3,tmp2,true)) && (ServerInfo[AutoLogin] == 1) )
		{
			LoginPlayer(playerid);
			if(PlayerInfo[playerid][Level] > 0)
			{

				format(string,sizeof(string),"| CONTA |: Voce foi automaticamente logado. (Nivel %d)", PlayerInfo[playerid][Level] );

				if (PlayerInfo[playerid][Level] > 6)
				{
				format(string,sizeof(string),"| CONTA |: Voce foi automaticamente logado. (Nivel %d - OWNER DO SERVIDOR)", PlayerInfo[playerid][Level] );
				}
				SendClientMessage(playerid,green,string);

				
       		}
	   		else SendClientMessage(playerid,green,"| CONTA |: Voce foi automaticamente logado.");
  	    }
 		else SendClientMessage(playerid, green, "| CONTA |: Voce esta registrado, entre na sua conta digitando /logar [senha]");
	}

 }



 	return 1;
}





public OnPlayerUpdate(playerid)
{

	static
		Float: X, Float: Y, Float: Z
	;
	GetPlayerPos( playerid, X, Y, Z );


	if( X >= 99999.0 || Y >= 99999.0 || Z >= 99999.0 || X <= -99999.0 || Y <= -99999.0 || Z <= -99999.0 ) {
        Kick(playerid);
		SetPlayerPos( playerid, p_PlayerBuggerX[ playerid ], p_PlayerBuggerY[ playerid ], p_PlayerBuggerZ[ playerid ] );
	}
	else
	{
	    p_PlayerBuggerX[ playerid ] = X;
	    p_PlayerBuggerY[ playerid ] = Y;
	    p_PlayerBuggerZ[ playerid ] = Z;
	}
return 1;
}










// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

//==============================================================================

forward KickLoginTimeout(playerid);
public KickLoginTimeout(playerid)
{

if(IsPlayerConnected(playerid) && UsarLoginTimeout == 1){
if(PlayerInfo[playerid][LoggedIn] == 0)
{
    new kstring[128],kPlayerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);
	format(kstring, sizeof(kstring), "{00FFFB}%s o N00B foi kickado. (Não logou-se)", kPlayerName);
	SendClientMessageToAll(grey, kstring);
	SpawnPlayer(playerid);
	SetPlayerInterior(playerid,0);
	GameTextForPlayer(playerid,"  ",4000,3);
	SendClientMessage(playerid, red, "");
	SendClientMessage(playerid, red, "VOCÊ FOI KICKADO POR NÃO LOGAR-SE");
	SendClientMessage(playerid, red, "");
	Kick(playerid);
}}

return 1;
}



forward AutoKick(playerid);
public AutoKick(playerid)
{
	if( IsPlayerConnected(playerid) && ServerInfo[Locked] == 1 && PlayerInfo[playerid][AllowedIn] == false) {
		new string[128];
		SendClientMessage(playerid,grey,"Voce foi auto-kickado. Motivo: Servidor bloqueado");
		format(string,sizeof(string),"%s ID:%d foi auto-kickado. Motivo: Servidor bloqueado",PlayerName2(playerid),playerid);
		SaveToFile("KickLog",string);  Kick(playerid);
		SendClientMessageToAll(grey, string); print(string);
	}
	return 1;
}

//==============================================================================

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

public OnPlayerDisconnect(playerid, reason)
{
/*
dini_IntSet("mrj.ini",PlayerName2(playerid),mrj[playerid]);
dini_IntSet("d3x.ini",PlayerName2(playerid),d3x[playerid]);
dini_IntSet("bmf.ini",PlayerName2(playerid),bmf[playerid]);
dini_IntSet("vks.ini",PlayerName2(playerid),vks[playerid]);
dini_IntSet("mvx.ini",PlayerName2(playerid),mvx[playerid]);
dini_IntSet("boy.ini",PlayerName2(playerid),boy[playerid]);
dini_IntSet("nrx.ini",PlayerName2(playerid),nrx[playerid]);
*/

    KillTimer(JailTimer[playerid]);
    KillTimer(LoginTimeoutTimer[playerid]);
	KillTimer(ExplodirTimer[playerid]);
	new PlayerName[MAX_PLAYER_NAME];//str[128]
	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
/*
	if(ServerInfo[ConnectMessages] == 1)
	{
		switch (reason) {
			case 0:	format(str, sizeof(str), "*** %s (%d) deixou o servidor (Problemas de conexao)", PlayerName, playerid);
			case 1:	format(str, sizeof(str), "*** %s (%d) deixou o servidor (Resolveu sair)", PlayerName, playerid);
			case 2:	format(str, sizeof(str), "*** %s (%d) deixou o servidor (Kickado/Banido)", PlayerName, playerid);
		}
		SendClientMessageToAll(grey, str);
}*/
	
	
	
new Player[MAX_PLAYER_NAME], stringx[256];
GetPlayerName(playerid,Player,sizeof(Player));
for(new names = 0; names < NAMES; names++)
{
if(strcmp(Player, CrashNicks[names], true) == 0)
{
printf(stringx);
return 1;
}
}

	if(PlayerInfo[playerid][LoggedIn] == 1)	SavePlayer(playerid);
	if(udb_Exists(PlayerName2(playerid))) dUserSetINT(PlayerName2(playerid)).("loggedin",0);
	
  	PlayerInfo[playerid][LoggedIn] = 0;
	PlayerInfo[playerid][Level] = 0;
	PlayerInfo[playerid][VIP] = 0;
	PlayerInfo[playerid][Jailed] = 0;
	PlayerInfo[playerid][Frozen] = 0;
	
	if(PlayerInfo[playerid][Frozen] == 1) KillTimer( FreezeTimer[playerid] );
	if(ServerInfo[Locked] == 1)	KillTimer( LockKickTimer[playerid] );

	if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
	/*
	#if defined ENABLE_SPEC
	for (new x = 0; x < MAX_PLAYERS; x++) if(IsPlayerConnected(x))
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid)
   		   	AdvanceSpectate(x);
	#endif
	*/
 	return 1;
}

forward DelayKillPlayer(playerid);
public DelayKillPlayer(playerid)
{
	SetPlayerHealth(playerid,0.0);
	ForceClassSelection(playerid);
}

// -------------------------------------------------------------------------------------------- MANDAR PARA GM
/*
forward GetLastContarHeadShotLevados(playerid);
public GetLastContarHeadShotLevados(playerid){return PlayerInfo[playerid][LastContarHeadShotLevados];}

forward GetLastContarHeadShot(playerid);
public GetLastContarHeadShot(playerid){return PlayerInfo[playerid][LastContarHeadShot];}
*/


forward GetPlayerLastSkin(playerid);
public GetPlayerLastSkin(playerid){return PlayerInfo[playerid][LastSkin];}

forward GetPlayerLastColor(playerid);
public GetPlayerLastColor(playerid){return PlayerInfo[playerid][LastColor];}

forward GetLastGCStatus(playerid);
public GetLastGCStatus(playerid){return PlayerInfo[playerid][LastGC];}

forward GetLastSpreeStatus(playerid);
public GetLastSpreeStatus(playerid){return PlayerInfo[playerid][LastSpree];}

forward GetLastTrancarStatus(playerid);
public GetLastTrancarStatus(playerid){return PlayerInfo[playerid][LastTrancar];}

forward GetLastRojoesStatus(playerid);
public GetLastRojoesStatus(playerid){return PlayerInfo[playerid][LastRojoes];}

forward GetLastPCSStatus(playerid);
public GetLastPCSStatus(playerid){return PlayerInfo[playerid][LastPCSStatus];}

forward GetLastPCSStatus_I(playerid);
public GetLastPCSStatus_I(playerid){return PlayerInfo[playerid][LastPCSStatus_I];}

forward GetLastPCSStatus_X(playerid);
public GetLastPCSStatus_X(playerid){return PlayerInfo[playerid][LastPCSStatus_X];}

forward GetLastPCSStatus_Y(playerid);
public GetLastPCSStatus_Y(playerid){return PlayerInfo[playerid][LastPCSStatus_Y];}

forward GetLastPCSStatus_Z(playerid);
public GetLastPCSStatus_Z(playerid){return PlayerInfo[playerid][LastPCSStatus_Z];}

forward GetLastPCSStatus_F(playerid);
public GetLastPCSStatus_F(playerid){return PlayerInfo[playerid][LastPCSStatus_F];}
// -------------------------------------------------------------------------------------------------------------

forward GetHourTimeStamp();public GetHourTimeStamp(){return HourTimeStamp;}

//==============================================================================


//COLOCA EM BAIXO DE QUALQUER PUBLIC
public OnPlayerPause(playerid)
{
AFK[playerid] = true;

    new kPlayerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);

if(PlayerInfo[playerid][Level] > 0)
{
	if(AdmHidden[playerid] == true)
	{
		printf("[--CONSOLE--]: | ESC | O Administrador %s ficou ausente.", kPlayerName);
	}
	else
	{
	//	format(StringPaused, sizeof(StringPaused), "| ESC | O Administrador %s ficou ausente.", kPlayerName);
	//	SendClientMessageToAll(yellow, StringPaused);
	}
}
return 1;
}
// =============================================================================
public OnPlayerUnpause(playerid)
{
AFK[playerid] = false;

    new kPlayerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);

if(PlayerInfo[playerid][Level] > 0)
{
	if(AdmHidden[playerid] == true)
	{
		printf("[--CONSOLE--]: | ESC | O Administrador %s ficou ausente.", kPlayerName);
	}
	else
	{
	//	format(StringPaused, sizeof(StringPaused), "| ESC | O Administrador %s não está mais ausente.", kPlayerName);
	//	SendClientMessageToAll(yellow, StringPaused);
	}
}
return 1;
}


public OnPlayerSpawn(playerid)
{

	if(ServerInfo[Locked] == 1 && PlayerInfo[playerid][AllowedIn] == false)
	{
		GameTextForPlayer(playerid,"~r~Servidor bloqueado~n~Voce deve entrar com sua senha~n~/password <senha>",4000,3);
		SetTimerEx("DelayKillPlayer", 2500,0,"d",playerid);
		return 1;
	}

	if(ServerInfo[MustLogin] == 1 && PlayerInfo[playerid][Registered] == 1 && PlayerInfo[playerid][LoggedIn] == 0)
	{
		GameTextForPlayer(playerid,"~r~Voce deve estar logado para poder jogar~n~~y~/logar <senha> ~n~~b~Ou entre com outro nome!",6000,3);
		SetTimerEx("DelayKillPlayer", 2500,0,"d",playerid);
		if(USARDIALOGOS == 1){KickPlayerEx(playerid, "Nasceu sem logar-se");}
		return 1;
	}

	if(ServerInfo[MustRegister] == 1 && PlayerInfo[playerid][Registered] == 0)
	{
		GameTextForPlayer(playerid,"~r~Voce deve registrar-se antes de jogar!",4000,3);
		SetTimerEx("DelayKillPlayer", 2500,0,"d",playerid);
		if(USARDIALOGOS == 1){KickPlayerEx(playerid, "Nasceu sem registrar-se");}
		return 1;
	}
	

	PlayerInfo[playerid][Spawned] = 1;

	if(PlayerInfo[playerid][Frozen] == 1) {
		TogglePlayerControllable(playerid,false); return SendClientMessage(playerid,red,"Voce nao pode escapar de sua punicao. Você esta travado.");
	}
	
	if(PlayerInfo[playerid][Jailed] == 1) {
	    SetTimerEx("JailPlayer",3000,0,"d",playerid); return SendClientMessage(playerid,red,"Voce não pode escapar de sua punição. Você esta preso.");
	}
	
	if(ServerInfo[AdminOnlySkins] == 1) {
		if( (GetPlayerSkin(playerid) == ServerInfo[AdminSkin]) || (GetPlayerSkin(playerid) == ServerInfo[AdminSkin2]) ) {
			if(PlayerInfo[playerid][Level] >= 2)
				GameTextForPlayer(playerid,"~b~BemVindo~n~~w~Admin",3000,1);
			else {
				GameTextForPlayer(playerid,"~r~Este skin e para~n~Administradores~n~Somente",4000,1);
				SetTimerEx("DelayKillPlayer", 2500,0,"d",playerid);
				return 1;
			}
		}
	}
	
	
	if((dUserINT(PlayerName2(playerid)).("UseSkin")) == 1)
		if((PlayerInfo[playerid][Level] >= 2) && (PlayerInfo[playerid][LoggedIn] == 1))
    		SetPlayerSkin(playerid,(dUserINT(PlayerName2(playerid)).("FavSkin")) );
    		

	if(ServerInfo[GiveWeap] == 1) {
		if(PlayerInfo[playerid][LoggedIn] == 1) {
			PlayerInfo[playerid][TimesSpawned]++;
			if(PlayerInfo[playerid][TimesSpawned] == 1)
			{
 				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap1"), dUserINT(PlayerName2(playerid)).("weap1ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap2"), dUserINT(PlayerName2(playerid)).("weap2ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap3"), dUserINT(PlayerName2(playerid)).("weap3ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap4"), dUserINT(PlayerName2(playerid)).("weap4ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap5"), dUserINT(PlayerName2(playerid)).("weap5ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap6"), dUserINT(PlayerName2(playerid)).("weap6ammo")	);
			}
		}
	}

	return 1;
}

public OnPlayerRequestSpawn(playerid)
{

if(PlayerInfo[playerid][Registered] != 1 && USARDIALOGOS == 1)
{
GameTextForPlayer(playerid,"_~n~_~n~_~n~_~n~_~n~_~n~_~n~~r~REGISTRE-SE ANTES!",4000,3);
RegisterDialog(playerid);
return 0;
}

if(PlayerInfo[playerid][LoggedIn] == 0 && USARDIALOGOS == 1){
GameTextForPlayer(playerid,"_~n~_~n~_~n~_~n~_~n~_~n~_~n~~r~VOCE NAO ESTA LOGADO!",4000,3);
LoginDialog(playerid);
return 0;}

new Nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, Nome, sizeof(Nome));//verificar Nome do Jogador
    if(strfind(Nome, "[SBN]", true) != -1) return isPlayerClaSBN(playerid);
    if(strfind(Nome, "[SPN]", true) != -1) return isPlayerClaAYS(playerid);
/*
    if(strfind(Nome, "[BASE]", true) != -1) return isPlayerClaBASE(playerid);
    if(strfind(Nome, "[BASE2]", true) != -1) return isPlayerClaBASE2(playerid);
    if(strfind(Nome, "[BASE3]", true) != -1) return isPlayerClaBASE3(playerid);
    if(strfind(Nome, "[BASE4]", true) != -1) return isPlayerClaBASE4(playerid);
    if(strfind(Nome, "[BASE5]", true) != -1) return isPlayerClaBASE5(playerid);
    if(strfind(Nome, "[H78]", true) != -1) return isPlayerClaBASE6(playerid);
    if(strfind(Nome, "[BASE7]", true) != -1) return isPlayerClaBASE7(playerid);
    if(strfind(Nome, "[BASE8]", true) != -1) return isPlayerClaBASE8(playerid);
    if(strfind(Nome, "[BASE9]", true) != -1) return isPlayerClaBASE9(playerid);
    if(strfind(Nome, "[BASE10]", true) != -1) return isPlayerClaBASE10(playerid);
    if(strfind(Nome, "[BASE11]", true) != -1) return isPlayerClaBASE11(playerid);
    if(strfind(Nome, "[BASE12]", true) != -1) return isPlayerClaBASE12(playerid);
    if(strfind(Nome, "[BASE13]", true) != -1) return isPlayerClaBASE13(playerid);
    if(strfind(Nome, "[BASE14]", true) != -1) return isPlayerClaBASE14(playerid);
    if(strfind(Nome, "[BASE15]", true) != -1) return isPlayerClaBASE15(playerid);
    if(strfind(Nome, "[BASE16]", true) != -1) return isPlayerClaBASE16(playerid);
    if(strfind(Nome, "[BASE17]", true) != -1) return isPlayerClaBASE17(playerid);
    if(strfind(Nome, "[BASE18]", true) != -1) return isPlayerClaBASE18(playerid);
    if(strfind(Nome, "[BASE19]", true) != -1) return isPlayerClaBASE19(playerid);
    if(strfind(Nome, "[BASE20]", true) != -1) return isPlayerClaBASE20(playerid);
    if(strfind(Nome, "[BASE21]", true) != -1) return isPlayerClaBASE21(playerid);
    if(strfind(Nome, "[BASE22]", true) != -1) return isPlayerClaBASE22(playerid);
    if(strfind(Nome, "[BASE23]", true) != -1) return isPlayerClaBASE23(playerid);
    if(strfind(Nome, "[BASE24]", true) != -1) return isPlayerClaBASE24(playerid);
    if(strfind(Nome, "[BASE25]", true) != -1) return isPlayerClaBASE25(playerid);
    if(strfind(Nome, "[BASE26]", true) != -1) return isPlayerClaBASE26(playerid);
    if(strfind(Nome, "[BASE27]", true) != -1) return isPlayerClaBASE27(playerid);
    if(strfind(Nome, "[BASE28]", true) != -1) return isPlayerClaBASE28(playerid);
    if(strfind(Nome, "[BASE29]", true) != -1) return isPlayerClaBASE29(playerid);
    if(strfind(Nome, "[BASE30]", true) != -1) return isPlayerClaBASE30(playerid);
*/
return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

if(PlayerInfo[playerid][Registered] != 1 && USARDIALOGOS == 1)
{
RegisterDialog(playerid);
return 0;
}

if(PlayerInfo[playerid][LoggedIn] == 0 && USARDIALOGOS == 1){
LoginDialog(playerid);
return 0;}

return 1;
}

/*
stock LoginDialog(playerid)
{
ShowPlayerDialog(playerid,541,DIALOG_STYLE_PASSWORD,"{FF0000}Digite sua senha","{00EEFF}Este nick esta registrado!\nDigite sua senha abaixo:","{00FFFF}Logar","{00FFFF}Cancelar");
return 1;
}

stock RegisterDialog(playerid)
{
ShowPlayerDialog(playerid,542,DIALOG_STYLE_INPUT,"{FF0000}Você deve registrar uma conta","{00EEFF}Digite uma senha para criar sua conta\n{00EEFF}e salvar seu dinheiro e status!","{00FFFF}Registrar","{00FFFF}Cancelar");
return 1;
}
*/
/*
stock Loguear(playerid)
{
    new Version[56], string[356], string2[120], string3[120];
	GetPlayerVersion(playerid,Version,56);format(string,sizeof(string),"Bienvenido a {B9C9BF}.:|Revolución Latina FR(0.3.7) [Español]|:.{FFFFFF}. Su versión de SA-MP es  {B9C9BF}%s{FFFFFF}.",Version);SendClientMessage(playerid,-1,string);SendClientMessage(playerid,blue,".:|RL|:.{FFFFFF} Usa {00FF00}/ayuda {FFFFFF}-{00FF00} /admins{FFFFFF}-{00FF00} /teles{FFFFFF}-{00FF00} /juegos{FFFFFF}.");
	SendClientMessage(playerid,blue,".:|RL|:.{FFFFFF} Recuerda que el servidor está realizado desde {00FF00}0 {FFFFFF}. Cualquier error avisarlo inmediatamente.");SendClientMessage(playerid,blue,".:|RL|:.{FFFFFF} Si tienes dudas o problemas no debes dudar en contactar al {00FF00}STAFF{FFFFFF} del servidor.");format(string2,sizeof(string2),"{FFFFFF}Bienvenido {00FF00}%s{FFFFFF}.\nEsta cuenta no se encuentra registrada, ingresa una contraseña para comenzar.",pName(playerid));
	format(string3,sizeof(string3),"{FFFFFF}Bienvenido {00FF00}%s{FFFFFF}.\nEsta cuenta se encuentra registrada, ingresa una contraseña para comenzar.",pName(playerid));
	Spawneo[playerid] = 0;
	if(!udb_Exists(pName(playerid))){ShowPlayerDialog(playerid,REGISTRO,DIALOG_STYLE_INPUT,"|| Registro ||",string2,"Registrar","Cancelar");
	} else	ShowPlayerDialog(playerid,LOGUEO,DIALOG_STYLE_PASSWORD,"|| Logueo ||",string3,"Loguear","Cancelar");
	return 1;
}
*/
stock LoginDialog(playerid)
{
//ShowPlayerDialog(playerid,541,DIALOG_STYLE_PASSWORD,"{FFFFFF}Tela de Login:","{FF0000}Este nick está registrado Em Nosso Banco De Dados.\n\n{FF0000}Digita Sua Senha Para Você Logar Em Sua Conta para poder Jogar\n\n","Logar","Cancelar");
new kPlayerName[MAX_PLAYER_NAME];
GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);
new Pais[64];
GetPlayerCountry(playerid, Pais, sizeof(Pais));

//ShowPlayerDialog(playerid,542,DIALOG_STYLE_INPUT,"{FFFFFF}Tela de Registro","{FF0000}Seja bem-vindo\n\n{FF0000}Status: {FFFFFF}Conta não registrada\n\nDigite sua senha no campo para poder se registrarno server\nE para  salvar | Score,Matou,Morreu,Corrida,Evento, etc |","{FFFFFF}Registrar","{FF0000}Cancelar");
new string3[250];
format(string3,sizeof(string3),"{00FF00}Seja Bem-vindo novamente {FFFFFF}%s\n\n{00FF00}Seu País: {FFFFFF}%s\n{00FF00}Seu ID no servidor: {FFFFFF}%i\n{00FF00}Seu nick: {FFFFFF}%s\n{00FF00}Status: {FFFFFF}Conta Registrada\n\n{00FF00}Digite sua senha no campo para poder jogar",kPlayerName,Pais,playerid,kPlayerName);
ShowPlayerDialog(playerid,541,DIALOG_STYLE_INPUT,"Tela de Login",string3,"Logar","Cancelar");


return 1;
}
stock RegisterDialog(playerid)
{
new kPlayerName[MAX_PLAYER_NAME];
GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);
new Pais[64];
GetPlayerCountry(playerid, Pais, sizeof(Pais));

//ShowPlayerDialog(playerid,542,DIALOG_STYLE_INPUT,"{FFFFFF}Tela de Registro","{FF0000}Seja bem-vindo\n\n{FF0000}Status: {FFFFFF}Conta não registrada\n\nDigite sua senha no campo para poder se registrarno server\nE para  salvar | Score,Matou,Morreu,Corrida,Evento, etc |","{FFFFFF}Registrar","{FF0000}Cancelar");
new string3[350];
format(string3,sizeof(string3),"{FF0000}Seja Bem-vindo {FFFFFF}%s\n\n{FF0000}Seu País: {FFFFFF}%s\n{FF0000}Seu ID no servidor: {FFFFFF}%i\n{FF0000}Seu nick: {FFFFFF}%s\n{FF0000}Status: {FFFFFF}Conta não Registrada\n\n{FF0000}Digite sua senha no campo para poder se registrar no server\npara salvar {FFFFFF}|score,matou,morreu,spree,evento,corrida | {FF0000}etc...",kPlayerName,Pais,playerid,kPlayerName);
ShowPlayerDialog(playerid,542,DIALOG_STYLE_INPUT,"Tela de Registro",string3,"Registrar","Cancelar");

return 1;
}

/*
stock RegisterDialog(playerid)
{
new kPlayerName[MAX_PLAYER_NAME];
GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);
new Pais[64];
GetPlayerCountry(playerid, Pais, sizeof(Pais));

ShowPlayerDialog(playerid,542,DIALOG_STYLE_INPUT,"Registrar","Cancelar","{FFFFFF}Tela de Registro","{FF0000}Seja bem-vindo: %s\n\n{FF0000}Seu País %s\n\n{FF0000}Seu ID no servidor %i\n\n{FF0000}Status: {FFFFFF}Conta não registrada\n\nDigite sua senha no campo para poder se registrarno server\nE para  salvar |Score,Matou,Morreu,Corrida,Evento, etc|",kPlayerName,Pais,playerid);
return 1;
}
*/
stock isPlayerAdm2(playerid)
{
    ShowPlayerDialog(playerid,7326,DIALOG_STYLE_PASSWORD,"{00FF00}Você tem a rcon prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerAdm(playerid)
{
    ShowPlayerDialog(playerid,7327,DIALOG_STYLE_PASSWORD,"{00FF00}Você e adm Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaSBN(playerid)
{
    ShowPlayerDialog(playerid,7328,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [SBN] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaAYS(playerid)
{
    ShowPlayerDialog(playerid,7329,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [SPN] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}
/*
stock isPlayerClaBASE(playerid)
{
    ShowPlayerDialog(playerid,7330,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE2(playerid)
{
    ShowPlayerDialog(playerid,7331,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE2] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE3(playerid)
{
    ShowPlayerDialog(playerid,7332,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE3] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE4(playerid)
{
    ShowPlayerDialog(playerid,7333,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE4] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE5(playerid)
{
    ShowPlayerDialog(playerid,7334,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE5] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE6(playerid)
{
    ShowPlayerDialog(playerid,7335,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [H78] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE7(playerid)
{
    ShowPlayerDialog(playerid,7336,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE7] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE8(playerid)
{
    ShowPlayerDialog(playerid,7337,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE8] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE9(playerid)
{
    ShowPlayerDialog(playerid,7338,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE9] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE10(playerid)
{
    ShowPlayerDialog(playerid,7339,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE10] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE11(playerid)
{
    ShowPlayerDialog(playerid,7340,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE11] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE12(playerid)
{
    ShowPlayerDialog(playerid,7341,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE12] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE13(playerid)
{
    ShowPlayerDialog(playerid,7342,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE13] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE14(playerid)
{
    ShowPlayerDialog(playerid,7343,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE14] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE15(playerid)
{
    ShowPlayerDialog(playerid,7344,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE15] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE16(playerid)
{
    ShowPlayerDialog(playerid,7345,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE16] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE17(playerid)
{
    ShowPlayerDialog(playerid,7346,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE17] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE18(playerid)
{
    ShowPlayerDialog(playerid,73347,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE18] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE19(playerid)
{
    ShowPlayerDialog(playerid,7348,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE19] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE20(playerid)
{
    ShowPlayerDialog(playerid,7349,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE20] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE21(playerid)
{
    ShowPlayerDialog(playerid,7350,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE21] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE22(playerid)
{
    ShowPlayerDialog(playerid,7351,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE22] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE23(playerid)
{
    ShowPlayerDialog(playerid,7352,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE23] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE24(playerid)
{
    ShowPlayerDialog(playerid,7353,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE24] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE25(playerid)
{
    ShowPlayerDialog(playerid,7354,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE25] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE26(playerid)
{
    ShowPlayerDialog(playerid,7355,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE26] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE27(playerid)
{
    ShowPlayerDialog(playerid,7356,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE27] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE28(playerid)
{
    ShowPlayerDialog(playerid,7357,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE28] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE29(playerid)
{
    ShowPlayerDialog(playerid,7358,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE29] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}

stock isPlayerClaBASE30(playerid)
{
    ShowPlayerDialog(playerid,7359,DIALOG_STYLE_PASSWORD,"{00FF00}Você e do cla [BASE30] Prove? ","{FF00FF}Estamos fazendo isso por motivos de segurança","Confirmar","");
	return 1;
}
*/
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
new params[196];


if(dialogid == 541) //LOGIN
{
    if(USARDIALOGOS != 1) return 1;
	if(!response){
	if(DGTRY[playerid] > 3){
    new kstring[128],kPlayerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);
	format(kstring, sizeof(kstring), "{00FFFB}» %s foi kickado. (Não logou-se)", kPlayerName);
	SendClientMessageToAll(grey, kstring);
	SpawnPlayer(playerid);
	SetPlayerInterior(playerid,0);
//	GameTextForPlayer(playerid,"  ",4000,3);
	SendClientMessage(playerid, red, "");
	SendClientMessage(playerid, red, "VOCÊ FOI KICKADO POR NÃO LOGAR-SE");
	SendClientMessage(playerid, red, "");
	Kick(playerid);}
	LoginDialog(playerid);
	DGTRY[playerid]++;
	GameTextForPlayer(playerid,"_~n~_~n~_~n~_~n~_~n~_~n~_~n~~r~SE NAO LOGAR SERA KICKADO N00B",4000,3);
	return 1;}
    
    format(params, sizeof(params), "%s", inputtext);
    
    if (strlen(params)==0) return LoginDialog(playerid);
    if (udb_CheckLogin(PlayerName2(playerid),params)){
	new file[256], tmp3[100], string[128];
	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(playerid)) );
   	GetPlayerIp(playerid,tmp3,100);
	dini_Set(file,"ip",tmp3);
	LoginPlayer(playerid);
//	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	if(PlayerInfo[playerid][Level] > 0 || PlayerInfo[playerid][VIP] > 0) {
    if(PlayerInfo[playerid][Level] > 1) { }//PlayerInfo[playerid][LoggedIn] = 0;//isPlayerAdm(playerid);
	format(string,sizeof(string),"{00FF00}| CONTA |:{FFFF00} Logado com sucesso. {00FF00}[AdmLevel: %d | VipLevel: %d]", PlayerInfo[playerid][Level],PlayerInfo[playerid][VIP] );
	return SendClientMessage(playerid,green,string);
    }else return SendClientMessage(playerid,green,"{00FF00}| CONTA |:{FFFF00} Logado com sucesso.");}else {
	PlayerInfo[playerid][FailLogin]++;
	printf("» LOGIN: %s falhou no login, Senha errada (%s) Tentativa (%d)", PlayerName2(playerid), params, PlayerInfo[playerid][FailLogin] );
	if(PlayerInfo[playerid][FailLogin] == MAX_FAIL_LOGINS)
	{
	SetPlayerInterior(playerid,0);
	SpawnPlayer(playerid);
	new string[128]; format(string, sizeof(string), "{00FFFB}| ID:%i |: %s foi kickado (Falhou no login)",playerid,PlayerName2(playerid));
	SendClientMessageToAll(grey, string);
//	GameTextForPlayer(playerid,"  ",4000,3);
	SendClientMessage(playerid, red, "");
	SendClientMessage(playerid, red, "VOCÊ FOI KICKADO POR FALHAR NO LOGIN");
	SendClientMessage(playerid, red, "");
	print(string);
	Kick(playerid);
	}
	LoginDialog(playerid);
	SendClientMessage(playerid,red,"| CONTA |: Falha no login, senha incorreta");
	return 1;
	}
	
    
}



if(dialogid == 542) //REGISTRAR
{
	if(USARDIALOGOS != 1) return 1;
	if(!response){
	if(DGTRY[playerid] > 3){
    new kstring[128],kPlayerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);
	format(kstring, sizeof(kstring), "{00FFFB}| ID:%i |: %s foi kickado. (Não registrou-se)",playerid ,kPlayerName);
	SendClientMessageToAll(grey, kstring);
	SpawnPlayer(playerid);
	SetPlayerInterior(playerid,0);
//	GameTextForPlayer(playerid,"  ",4000,3);
	SendClientMessage(playerid, red, "");
	SendClientMessage(playerid, red, "VOCÊ FOI KICKADO POR NÃO REGISTRAR-SE");
	SendClientMessage(playerid, red, "");
	Kick(playerid);}
	RegisterDialog(playerid);
	DGTRY[playerid]++;
	GameTextForPlayer(playerid,"_~n~_~n~_~n~_~n~_~n~_~n~_~n~~r~SE REGISTRA AI N00B OU SERÁ KICKADO!",4000,3);
	return 1;}
	
	
	
    format(params, sizeof(params), "%s", inputtext);
    
    if (strlen(params) < 4 || strlen(params) > 20) {
	SendClientMessage(playerid,red,"| CONTA |: A senha deve ser maior que 3 caracteres");
	RegisterDialog(playerid);
	return 1;}

    if (udb_Create(PlayerName2(playerid),params))
	{
    	new file[256],name[MAX_PLAYER_NAME], tmp3[100];
    	new strdate[20], year,month,day;	getdate(year, month, day);
		GetPlayerName(playerid,name,sizeof(name)); format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(name));
     	GetPlayerIp(playerid,tmp3,100);	dini_Set(file,"ip",tmp3);
//    	dini_Set(file,"password",params);
	    dUserSetINT(PlayerName2(playerid)).("registered",1);
   		format(strdate, sizeof(strdate), "%d/%d/%d",day,month,year);
		dini_Set(file,"RegisteredDate",strdate);
		
		dUserSetINT(PlayerName2(playerid)).("loggedin",1);
		dUserSetINT(PlayerName2(playerid)).("banned",0);
		dUserSetINT(PlayerName2(playerid)).("level",0);
		dUserSetINT(PlayerName2(playerid)).("VIP",0);
		dUserSetINT(PlayerName2(playerid)).("Head",0);
    	dUserSetINT(PlayerName2(playerid)).("HeadLevado",0);
    	dUserSetINT(PlayerName2(playerid)).("Corridas",0);
    	dUserSetINT(PlayerName2(playerid)).("Corridasg2",0);
    	dUserSetINT(PlayerName2(playerid)).("Corridasgg3",0);
		dUserSetINT(PlayerName2(playerid)).("EVENTOPremiar",0);
		dUserSetINT(PlayerName2(playerid)).("EVENTOPremiar2",0);
		dUserSetINT(PlayerName2(playerid)).("EVENTOPremiar3",0);
    	dUserSetINT(PlayerName2(playerid)).("X1Ganhos",0);
		dUserSetINT(PlayerName2(playerid)).("X1Perdidos",0);
    	dUserSetINT(PlayerName2(playerid)).("X1WGanhos",0);
		dUserSetINT(PlayerName2(playerid)).("X1WPerdidos",0);
		dUserSetINT(PlayerName2(playerid)).("X1PGanhos",0);
		dUserSetINT(PlayerName2(playerid)).("X1PPerdidos",0);
		dUserSetINT(PlayerName2(playerid)).("X1SGanhos",0);
		dUserSetINT(PlayerName2(playerid)).("X1SPerdidos",0);
		dUserSetINT(PlayerName2(playerid)).("X1LGanhos",0);
		dUserSetINT(PlayerName2(playerid)).("X1LPerdidos",0);
		dUserSetINT(PlayerName2(playerid)).("PistolaGanhos",0);
		dUserSetINT(PlayerName2(playerid)).("PistolaPerdidos",0);
		dUserSetINT(PlayerName2(playerid)).("RUNGanhos",0);
		dUserSetINT(PlayerName2(playerid)).("RUNPerdidos",0);
		dUserSetINT(PlayerName2(playerid)).("WALKGanhos",0);
		dUserSetINT(PlayerName2(playerid)).("WALKPerdidos",0);
		dUserSetINT(PlayerName2(playerid)).("SNPGanhos",0);
		dUserSetINT(PlayerName2(playerid)).("SNPPerdidos",0);
	    dUserSetINT(PlayerName2(playerid)).("LastOn",0);
    	dUserSetINT(PlayerName2(playerid)).("money",0);
    	dUserSetINT(PlayerName2(playerid)).("kills",0);
	   	dUserSetINT(PlayerName2(playerid)).("deaths",0);
	   	dUserSetINT(PlayerName2(playerid)).("hours",0);
	   	dUserSetINT(PlayerName2(playerid)).("minutes",0);
	   	dUserSetINT(PlayerName2(playerid)).("seconds",0);
	   	dUserSetINT(PlayerName2(playerid)).("PlayerColor",0);
	   	dUserSetINT(PlayerName2(playerid)).("PlayerSkin",0);
	   	dUserSetINT(PlayerName2(playerid)).("score",0);
	   	dUserSetINT(PlayerName2(playerid)).("CS",0);
	   	dUserSetINT(PlayerName2(playerid)).("CS_X",0);
	   	dUserSetINT(PlayerName2(playerid)).("CS_Y",0);
	   	dUserSetINT(PlayerName2(playerid)).("CS_Z",0);
	   	dUserSetINT(PlayerName2(playerid)).("CS_F",0);
	   	dUserSetINT(PlayerName2(playerid)).("CS_I",0);
	   	dUserSetINT(PlayerName2(playerid)).("LastRojoes",0);
	   	dUserSetINT(PlayerName2(playerid)).("WantedLevel",0);

SetPlayerCash(playerid, 0);

/*
    if(!fexist("mrj.ini")) dini_Create("mrj.ini");
    if(!fexist("d3x.ini")) dini_Create("d3x.ini");
    if(!fexist("bmf.ini")) dini_Create("bmf.ini");
    if(!fexist("vks.ini")) dini_Create("vks.ini");
    if(!fexist("mvx.ini")) dini_Create("mvx.ini");
    if(!fexist("boy.ini")) dini_Create("boy.ini");
    if(!fexist("nrx.ini")) dini_Create("nrx.ini");

mrj[playerid] = 0;
d3x[playerid] = 0;
bmf[playerid] = 0;
vks[playerid] = 0;
mvx[playerid] = 0;
boy[playerid] = 0;
nrx[playerid] = 0;
*/
//	   	dUserSetINT(PlayerName2(playerid)).("LastContarHeadShotLevados",0);
//	   	dUserSetINT(PlayerName2(playerid)).("LastContarHeadShot",0);

	    PlayerInfo[playerid][LoggedIn] = 1;
	    PlayerInfo[playerid][Registered] = 1;
//	    SendClientMessage(playerid, green, "| CONTA |: Voce esta registrado, e foi logado automaticamente");
	    SendClientMessage(playerid, green, "{00FF00}| CONTA |:{FFFF00} Voce esta registrado, e foi logado automaticamente");
//		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return 1;
	}

}

if(dialogid == 7326)//SENHA ADM2
{

	if(strfind(inputtext, "Minhaavojogamelhorquevc", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green,"{FFFFFF}SERVER: You are logged in as admin.");
	} else return Kick(playerid);

   return 1;
}
/*
if(dialogid == 7327)//SENHA ADM
{

	if(strfind(inputtext, "aiquexerekalindaMdM", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
	} else return Kick(playerid);

   return 1;
}
*/
if(dialogid == 7328)//SENHA SBN
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}

if(dialogid == 7329)//SENHA SPN
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}

/*
if(dialogid == 7330)//SENHA [BASE]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}

if(dialogid == 7331)//SENHA [BASE2]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7332)//SENHA [BASE3]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7333)//SENHA [BASE4]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7334)//SENHA [BASE5]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}

if(dialogid == 7335)//SENHA [BASE6]
{

	if(strfind(inputtext, "hardsmatadoresh78", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}

if(dialogid == 7336)//SENHA [BASE7]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7337)//SENHA [BASE8]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7338)//SENHA [BASE9]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7339)//SENHA [BASE10]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7340)//SENHA [BASE11]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7341)//SENHA [BASE12]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7342)//SENHA [BASE13]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7343)//SENHA [BASE14]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7344)//SENHA [BASE15]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7345)//SENHA [BASE16]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7346)//SENHA [BASE17]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7347)//SENHA [BASE18]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7348)//SENHA [BASE19]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7349)//SENHA [BASE20]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}

if(dialogid == 7350)//SENHA [BASE21]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7351)//SENHA [BASE22]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7352)//SENHA [BASE23]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7353)//SENHA [BASE24]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7354)//SENHA [BASE25]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7355)//SENHA [BASE26]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7356)//SENHA [BASE27]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7357)//SENHA [BASE28]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7358)//SENHA [BASE29]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
if(dialogid == 7359)//SENHA [BASE30]
{

	if(strfind(inputtext, "DdeliciaD", true) != -1)
	{
PlayerInfo[playerid][LoggedIn] = 1;
SendClientMessage(playerid, green, "{00FF00}» CONTA CLAN:{FFFF00} Logado com sucesso");
	} else return Kick(playerid);

   return 1;
}
*/
return 1;
}


//==============================================================================

public OnPlayerDeath(playerid, killerid, reason)
{

//AntiAbusoX
if(killerid != INVALID_PLAYER_ID){
if(LATickCount - KillerTick[killerid] <= 3){
KillerTick[killerid] = LATickCount;
return 1;}
KillerTick[killerid] = LATickCount;}

//ANTI FAKE-KILL
//if(GetPlayerState(playerid) != PLAYER_STATE_WASTED) return 1;


//PlayerInfo[playerid][PlayerSkin] = GetPlayerSkin(playerid);
KillTimer(ExplodirTimer[playerid]);

	#if defined USE_STATS
    PlayerInfo[playerid][Deaths]++;
	#endif
    InDuel[playerid] = 0;
    
	if(IsPlayerConnected(killerid) && killerid != INVALID_PLAYER_ID)
	{
		#if defined USE_STATS
		PlayerInfo[killerid][Kills]++;
	    #endif
	    
		if(InDuel[playerid] == 1 && InDuel[killerid] == 1)
		{
			GameTextForPlayer(playerid,"Perdedor !",3000,3);
			GameTextForPlayer(killerid,"Vencedor !",3000,3);
			InDuel[killerid] = 0;
			SetPlayerPos(killerid, 0.0, 0.0, 0.0);
			SpawnPlayer(killerid);
		}
		else if(InDuel[playerid] == 1 && InDuel[killerid] == 0)
		{
			GameTextForPlayer(playerid,"Perdedor !",3000,3);
		}
	}
/*
	#if defined ENABLE_SPEC
	for (new x = 0; x < MAX_PLAYERS; x++) if(IsPlayerConnected(x))
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid)
	       AdvanceSpectate(x);
	#endif
	
*/
	return 1;
}

//==============================================================================

public OnPlayerText(playerid, text[])
{
/*
if(strfind(text, "f.dp", true) != -1 || strfind(text, "fd.p", true) != -1 || strfind(text, "fdp.", true) != -1 || strfind(text, "f.dpta", true) != -1 || strfind(text, "fd.pta", true) != -1
|| strfind(text, "fdp.ta", true) != -1 || strfind(text, "fdp", true) != -1 || strfind(text, "fdpta", true) != -1 || strfind(text, "fd..p", true) != -1 || strfind(text, "f.d.p", true) != -1
|| strfind(text, "f..dp", true) != -1 || strfind(text, ".fdp", true) != -1 || strfind(text, "f;dp", true) != -1 || strfind(text, "f;d;p", true) != -1 || strfind(text, "fdp;", true) != -1 || strfind(text, ";fdp", true) != -1
|| strfind(text, "f d p", true) != -1 || strfind(text, "fd p", true) != -1 || strfind(text, "f dp", true) != -1 || strfind(text, "f d p.", true) != -1 || strfind(text, "f. d p", true) != -1
|| strfind(text, "filho da puta", true) != -1 || strfind(text, "filho da putaa", true) != -1 || strfind(text, "fi da puta", true) != -1 || strfind(text, "filho duma puta", true) != -1 || strfind(text, "filhoo da puta", true) != -1 || strfind(text, "filho daa puta", true) != -1
|| strfind(text, "filha da puta", true) != -1 || strfind(text, "filha da putaa", true) != -1 || strfind(text, "fi da puta", true) != -1 || strfind(text, "filha duma puta", true) != -1 || strfind(text, "filhaa da puta", true) != -1 || strfind(text, "filha daa puta", true) != -1
|| strfind(text, "filho da p.uta", true) != -1 || strfind(text, "filho da pu.ta", true) != -1 || strfind(text, "f_dp", true) != -1 || strfind(text, "fd_p", true) != -1 || strfind(text, "f,dp", true) != -1 || strfind(text, "fd,p", true) != -1
|| strfind(text, "filha da p.uta", true) != -1 || strfind(text, "filha da pu.ta", true) != -1 || strfind(text, "_fdp", true) != -1 || strfind(text, "fdp_", true) != -1 || strfind(text, ",fdp", true) != -1 || strfind(text, "fdp,", true) != -1)
{
SetTimerEx("BotAvisar", 4000, false, "i", playerid);
}
*/
/*
if(strfind(text, "hack", true) != -1 || strfind(text, "racker", true) != -1 || strfind(text, "raki", true) != -1 || strfind(text, "hask", true) != -1 || strfind(text, "rackerzin", true) != -1
|| strfind(text, "hacke", true) != -1 || strfind(text, "hacki", true) != -1 || strfind(text, "hak", true) != -1 || strfind(text, "raker", true) != -1
|| strfind(text, "hakin", true) != -1 || strfind(text, "hackerzin", true) != -1 || strfind(text, "hackerzinho", true) != -1 || strfind(text, "rask", true) != -1 || strfind(text, "hackkk", true) != -1 || strfind(text, "hakk", true) != -1)
{
SetTimerEx("BotAviso", 3000, false, "i", playerid);
}
*/


//{FFFF00}[STT][VIP] CHAT: {FF00FF}[SBN]DEAN[SPN]: {FFFF00}(13):  vip chat legal teste
	if(text[0] == '#' && PlayerInfo[playerid][Level] >= 2) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF0000}[CHAT ADMIN]: {4EEE94}%s (iD:%i): %s",string,playerid,text[1]); MessageToAdmins(green,string);
	    return 0;
	}

	if(text[0] == '$' && PlayerInfo[playerid][Level] >= 6) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF0000}[CHAT OWNERS]: {4EEE94}%s (iD:%i): {FF00FF}%s",string,playerid,text[1]); MessageToOwners(green,string);
	    return 0;
	}

	//	if(text[0] == '@' && PlayerInfo[playerid][Level] >= 1) {
	//    new string[138]; GetPlayerName(playerid,string,sizeof(string));
	//	format(string,sizeof(string),"{FFFF00}[CHAT VIP$]: {FF00FF}%s {FFFF00}(iD:%i): %s",string,playerid,text[1]); MessageToVips(green,string);
//	    return 0;
//	}

	if(text[0] == '@' && PlayerInfo[playerid][VIP] >= 1) {
	    new string[128]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF0000}[CHAT-VIP]»{FFFFFF} %s: [ID:%i]{00FF00}» %s",string,playerid,text[1]); MessageToVIPS(COLOR_PURPLE,string);
	    return 0;
	}


	if(text[0] == ';' && PlayerInfo[playerid][Level] >= 1) {
	    new chat[128]; format(chat, sizeof(chat), "%s",text);
		ChatProximo(playerid, COLOUR_CHATPROX, text[1]);
	    return 0;
	}
	
	
	
		if(text[0] == '.' && PlayerInfo[playerid][Level] >= 1) {
	//Enviar mensagem para o grupo
	new GrupoChatSTR[170],pname[100];
	GetPlayerName(playerid, pname, MAX_PLAYER_NAME);
	for(new i; i < GetMaxPlayers(); i++)
	{
		if(IsPlayerConnected(i))
		{
			if(GetPVarInt(i,"GrupoChat") == GetPVarInt(playerid,"GrupoChat"))
			{
			format(GrupoChatSTR, sizeof(GrupoChatSTR), "{FFFF00}» [%i]:{00FFFF} %s (%i): {FFFFFF}%s", GetPVarInt(playerid,"GrupoChat"), pname, playerid, text[1]);
			SendClientMessage(i, COLOUR_INFORMACAO, GrupoChatSTR);
			PlayerPlaySound(i,1056,0.0,0.0,0.0);
			}
		}
	}
		    return 0;
	}
/*
    if(PlayerInfo[playerid][Level] >= 1 && AdmHidden[playerid] == false)
	{
if(PlayerInfo[playerid][Level] >= 1 && AdmHidden[playerid] == false){
 	new chat[128]; format(chat, sizeof(chat), "%s",text);
 	new string[128]; GetPlayerName(playerid,string,sizeof(string));
 	format(string,sizeof(string),"%s: {FFFFFF}(%i): [ADMIN]: {00FFFF}%s",string,playerid,text);
    SendClientMessageToAll(GetPlayerColor(playerid),string);
 	SetPlayerChatBubble(playerid, chat, -1, 20.0, 10000);
}else{
if(PlayerInfo[playerid][Level] >= 1 && AdmHidden[playerid] == true){
 	new chat[128]; format(chat, sizeof(chat), "%s",text);
 	new string[128]; GetPlayerName(playerid,string,sizeof(string));
 	format(string,sizeof(string),"%s: {FFFFFF}(%i): {FFFFFF}%s",string,playerid,text);
    SendClientMessageToAll(GetPlayerColor(playerid),string);
 	SetPlayerChatBubble(playerid, chat, -1, 20.0, 10000);
}
}
return 0;
}
	
if(PlayerInfo[playerid][VIP] >= 1 && VipHidden[playerid] == false)
	{
if(PlayerInfo[playerid][VIP] >= 1 && VipHidden[playerid] == false){
 	new chat[128]; format(chat, sizeof(chat), "%s",text);
 	new string[128]; GetPlayerName(playerid,string,sizeof(string));
 	format(string,sizeof(string),"%s: {FFFFFF}(%i): [VIP]: {C0FF3E}%s",string,playerid,text);
 //	SendClientMessageToAll(playerid,string);
    SendClientMessageToAll(GetPlayerColor(playerid),string);
 	SetPlayerChatBubble(playerid, chat, -1, 20.0, 10000);
}else{
if(PlayerInfo[playerid][Level] >= 1 && VipHidden[playerid] == true){
 	new chat[128]; format(chat, sizeof(chat), "%s",text);
 	new string[128]; GetPlayerName(playerid,string,sizeof(string));
 	format(string,sizeof(string),"%s: {FFFFFF}(%i): {FFFFFF}%s",string,playerid,text);
    SendClientMessageToAll(GetPlayerColor(playerid),string);
 	SetPlayerChatBubble(playerid, chat, -1, 20.0, 10000);
}
}
return 0;
}
*/





/*
////////////// chat bases
	if(text[0] == '!' && mrj[playerid] >= 1) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF00FF}[CHAT BASE 1]: {FFFF00}%s (iD:%i): %s",string,playerid,text[1]); MessageToClaBase1(green,string);
	    return 0;
	}

	if(text[0] == '!' && d3x[playerid] >= 1) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF00FF}[CHAT BASE 2]: {FFFF00}%s (iD:%i): %s",string,playerid,text[1]); MessageToClaBase2(green,string);
	    return 0;
	}

	if(text[0] == '!' && bmf[playerid] >= 1) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF00FF}[CHAT BASE 3]: {FFFF00}%s (iD:%i): %s",string,playerid,text[1]); MessageToClaBase3(green,string);
	    return 0;
	}

	if(text[0] == '!' && vks[playerid] >= 1) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF00FF}[CHAT BASE 4]: {FFFF00}%s (iD:%i): %s",string,playerid,text[1]); MessageToClaBase4(green,string);
	    return 0;
	}

	if(text[0] == '!' && mvx[playerid] >= 1) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF00FF}[CHAT BASE 5]: {FFFF00}%s (iD:%i): %s",string,playerid,text[1]); MessageToClaBase5(green,string);
	    return 0;
	}

	if(text[0] == '!' && boy[playerid] >= 1) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF00FF}[CHAT BASE 6]: {FFFF00}%s (iD:%i): %s",string,playerid,text[1]); MessageToClaBase6(green,string);
	    return 0;
	}

	if(text[0] == '!' && nrx[playerid] >= 1) {
	    new string[138]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{FF00FF}[CHAT BASE 7]: {FFFF00}%s (iD:%i): %s",string,playerid,text[1]); MessageToClaBase7(green,string);
	    return 0;
	}

///////////// chat bases
*/
new chat[128]; format(chat, sizeof(chat), "%s",text);
if(text[0] == ';'){ChatProximo(playerid, COLOUR_CHATPROX, text[1]);return 0;}

// Chat em GRUPO
if(text[0] == '.')
{
	//Jogador não tem grupo
	if(GetPVarInt(playerid,"GrupoChat") == -0)
	{
	SendClientMessage(playerid,COLOUR_INFORMACAO,"** Usar um ponto antes do chat significa chat em grupo");
	SendClientMessage(playerid,COLOUR_INFORMACAO,"** Para criar ou entrar em um grupo use: {FFFFFF}/grupo <id do grupo>");
	SendClientMessage(playerid,COLOUR_INFORMACAO,"** Somente os membros do grupo verão as mensagens!");
	return 0;
	}

	new GrupoChatSTR[170],pname[100];
	GetPlayerName(playerid, pname, MAX_PLAYER_NAME);

	//Para os admins lerem - Grupo anonimo = 5876312
	if(GetPVarInt(playerid,"GrupoChat") != 3816317)
	{
 		for(new i; i < GetMaxPlayers(); i++)
 		{
 			if(IsPlayerConnected(i))
		 	{
				if(CallRemoteFunction("GetPlayerAdminLevel","i",i) >= 4)
				{
					if(GetPVarInt(i,"GrupoChat") != GetPVarInt(playerid,"GrupoChat"))
					{
					format(GrupoChatSTR, sizeof(GrupoChatSTR), "» [%i]: %s (%i): %s", GetPVarInt(playerid,"GrupoChat"), pname, playerid, text[1]);
					SendClientMessage(i, 0xFF9900AA, GrupoChatSTR);
					}
				}
			}
		}
	}

	//Enviar mensagem para o grupo
	for(new i; i < GetMaxPlayers(); i++)
	{
		if(IsPlayerConnected(i))
		{
			if(GetPVarInt(i,"GrupoChat") == GetPVarInt(playerid,"GrupoChat"))
			{
			format(GrupoChatSTR, sizeof(GrupoChatSTR), "{FFFF00}» [%i]:{00FFFF} %s (%i): {FFFFFF}%s", GetPVarInt(playerid,"GrupoChat"), pname, playerid, text[1]);
			SendClientMessage(i, COLOUR_INFORMACAO, GrupoChatSTR);
			PlayerPlaySound(i,1056,0.0,0.0,0.0);
			}
		}
	}

return 0;
}


//if(text[0] == ';' && PlayerInfo[playerid][Level] >= 2){ChatProximo(playerid, COLOUR_CHATPROX, text[1]);return 0;}

	if(ServerInfo[MustLogin] == 1 && PlayerInfo[playerid][Registered] == 1 && PlayerInfo[playerid][LoggedIn] == 0)
	{
	SendClientMessage(playerid,red,"Você não está logado!");
	return 0;
	}

	if(ServerInfo[DisableChat] == 1) {
		SendClientMessage(playerid,red,"O chat esta desativado.");
	 	return 0;
	}
	
 	if(PlayerInfo[playerid][Muted] == 1)
	{
 		PlayerInfo[playerid][MuteWarnings]++;
 		new string[128];
		if(PlayerInfo[playerid][MuteWarnings] < ServerInfo[MaxMuteWarnings]) {
			format(string, sizeof(string),"[AVISO]: Se continuar latindo sera kickado. (%d / %d)", PlayerInfo[playerid][MuteWarnings], ServerInfo[MaxMuteWarnings] );
			SendClientMessage(playerid,red,string);
		} else {
			SendClientMessage(playerid,red,"[AVISO]: Voce foi avisado! Voce será kickado!");
			format(string, sizeof(string),"{00FFFB}***%s (ID %d) foi kickado por não parar de latir essa cadela", PlayerName2(playerid), playerid);
			SendClientMessageToAll(grey,string);
			SaveToFile("KickLog",string); Kick(playerid);
		} return 0;
	}
	
	if(ServerInfo[AntiSpam] == 1 && (PlayerInfo[playerid][Level] == 0 && !IsPlayerAdmin(playerid)) )
	{
		if(PlayerInfo[playerid][SpamCount] == 0) PlayerInfo[playerid][SpamTime] = TimeStamp();

	    PlayerInfo[playerid][SpamCount]++;
		if(TimeStamp() - PlayerInfo[playerid][SpamTime] > SPAM_TIMELIMIT) { // Its OK your messages were far enough apart
			PlayerInfo[playerid][SpamCount] = 0;
			PlayerInfo[playerid][SpamTime] = TimeStamp();
		}
		else if(PlayerInfo[playerid][SpamCount] == SPAM_MAX_MSGS) {
			new string[64]; format(string,sizeof(string),"{00FFFB}%s foi kickado (Flood/Spam)", PlayerName2(playerid));
			SendClientMessageToAll(grey,string); print(string);
			SaveToFile("KickLog",string);
			Kick(playerid);
		}
		else if(PlayerInfo[playerid][SpamCount] == SPAM_MAX_MSGS-1) {
			SendClientMessage(playerid,red,"[AVISO]: No próximo flood você será kickado seu N00B!");
			return 0;
		}
	}

	if(ServerInfo[AntiSwear] == 1 && PlayerInfo[playerid][Level] < ServerInfo[MaxAdminLevel])
	for(new s = 0; s < ForbiddenWordCount; s++)
    {
		new pos;
		while((pos = strfind(text,ForbiddenWords[s],true)) != -1) for(new i = pos, j = pos + strlen(ForbiddenWords[s]); i < j; i++) text[i] = '*';
	}

	if(PlayerInfo[playerid][Caps] == 1) UpperToLower(text);
	if(ServerInfo[NoCaps] == 1) UpperToLower(text);

	for(new i = 1; i < MAX_CHAT_LINES-1; i++) Chat[i] = Chat[i+1];
 	new ChatSTR[128]; GetPlayerName(playerid,ChatSTR,sizeof(ChatSTR)); format(ChatSTR,128,"[lchat]%s: %s",ChatSTR, text[0] );
	Chat[MAX_CHAT_LINES-1] = ChatSTR;
	return 1;
}

//==============================================================================


stock ChatProximo(playerid, color, const string[])
{
        new output[128], pNameX[MAX_PLAYER_NAME],outadm[128],rawstring[128];
        GetPlayerName(playerid, pNameX, sizeof(pNameX));

        format(output, sizeof(output), "%s: (%i): %s", pNameX, playerid, string);
        format(rawstring, sizeof(rawstring), "%s",string);

        new Float:PosX, Float:PosY, Float:PosZ;
        GetPlayerPos(playerid, PosX, PosY, PosZ);

        format(outadm, sizeof(outadm), "CHATP >> %s: (%i): %s", pNameX,playerid,string);
        for(new i; i < GetMaxPlayers(); i++){if(IsPlayerConnected(i)){
		if(CallRemoteFunction("GetPlayerAdminLevel","i",i) >= 4){
		if(!IsPlayerInRangeOfPoint(i, 20.0, PosX, PosY, PosZ)){
		SendClientMessage(i, 0xFF9900AA, outadm);}}}}

        for(new i; i < GetMaxPlayers(); i++){if(IsPlayerConnected(i)){
        if(IsPlayerInRangeOfPoint(i, 20.0, PosX, PosY, PosZ)){
		SendClientMessage(i, color, output);
		PlayerPlaySound(i,1057,0.0,0.0,0.0);}}}
		SetPlayerChatBubble(playerid, rawstring, COLOUR_CHATPROX, 20.0, 10000);

        return 1;
}



forward HighLight2(playerid);
public HighLight2(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(PlayerInfo[playerid][blipS] == 0) { SetPlayerColor(playerid, 0xFF0000AA); PlayerInfo[playerid][blipS] = 1; }
	else { SetPlayerColor(playerid, 0x00FFEEAA); PlayerInfo[playerid][blipS] = 0; }
	return 0;
}

forward HighLight(playerid);
public HighLight(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(PlayerInfo[playerid][blipS] == 0) { SetPlayerColor(playerid, 0xFF0000AA); PlayerInfo[playerid][blipS] = 1; }
	else { SetPlayerColor(playerid, 0x33FF33AA); PlayerInfo[playerid][blipS] = 0; }
	return 0;
}

//===================== [ DCMD Commands ]=======================================


dcmd_tocarmusicavip(playerid, params[])
{
  	if(CallRemoteFunction("GetPlayerAdminLevel", "i", playerid) > 2)
	{
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /tocarmusicavip [url stream]");
		for (new i; i < GetMaxPlayers(); i++)
		{
			PlayAudioStreamForPlayer(i, params);
		}
	CMDMessageToAdmins(playerid, "TOCARMUSICA");
		new nomeadmin[MAX_PLAYER_NAME];
		GetPlayerName(playerid, nomeadmin, sizeof(nomeadmin));
		SendClientMessage(playerid, red, "| INFO |: Sua URL tentará ser tocada para todos!");
		new string[256];
		format(string, sizeof(string), "O Vip (a) %s colocou uma musica para todos, para não ouvir digite /OFF.", nomeadmin);
        SendClientMessageToAll(0x00FF00FF, string);
        return 1;
	} else return SendClientMessage(playerid, red, "| ERRO |: Você não tem permissão para isso.");
}


dcmd_yt(playerid, params[])
{
  	if(CallRemoteFunction("GetPlayerAdminLevel", "i", playerid) > 1)
	{
format(params, 300, "http://ultramendoza-mp3.herokuapp.com/download?v=%s", params);
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /yt [url stream]");
		for (new i; i < GetMaxPlayers(); i++)
		{
			PlayAudioStreamForPlayer(i, params);
		}
	CMDMessageToAdmins(playerid, "YT YOUTUBE");
		new nomeadmin[MAX_PLAYER_NAME];
		GetPlayerName(playerid, nomeadmin, sizeof(nomeadmin));
		SendClientMessage(playerid, red, "| INFO |: Sua URL tentará ser tocada para todos!");
		new string[300];
		format(string, sizeof(string), "O Administrador (a) %s colocou uma musica para todos, para não ouvir digite /OFF.", nomeadmin);
        SendClientMessageToAll(0x00FF00FF, string);
        return 1;
	} else return SendClientMessage(playerid, red, "| ERRO |: Você não tem permissão para isso.");
}
/*
dcmd_pormusica(playerid, params[])
{
  	if(CallRemoteFunction("GetPlayerAdminLevel", "i", playerid) > 2)
	{
format(params, 145, "https://6t.pe/?song=%s", params);
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /PORMUSICA [Nome da Musica");
		for (new i; i < GetMaxPlayers(); i++)
		{
			PlayAudioStreamForPlayer(i, params);
		}
	CMDMessageToAdmins(playerid, "YT YOUTUBE");
		new nomeadmin[MAX_PLAYER_NAME];
		GetPlayerName(playerid, nomeadmin, sizeof(nomeadmin));
		SendClientMessage(playerid, red, "| INFO |: Sua MUSICA tentará ser tocada para todos!");
		new string[256];
		format(string, sizeof(string), "O Administrador (a) %s colocou uma musica para todos, para não ouvir digite /OFF.", nomeadmin);
        SendClientMessageToAll(0x00FF00FF, string);
        return 1;
	} else return SendClientMessage(playerid, red, "| ERRO |: Você não tem permissão para isso.");
}
*/

dcmd_musica(playerid,params[]){
if(!strlen(params)) return SendClientMessage(playerid, COLOUR_ERRO,"{FF0000}| USO |: /MUSICA [URL DO YOUTUBE]");//http://www.youtubeinmp3.com/fetch/?video=
if(strlen(params) < 3) return SendClientMessage(playerid,COLOUR_ERRO,"| ERRO |: Nome da musica online muito curta!");
{
new str[70];
format(str, sizeof(str), "matamataguerradm.000webhostapp.com/music.php?q=%s", params);//http://www.youtube.com/watch?v=//6t.pe/?song=%s //http://search.4shared.com/ //4t.pe/?mp3= //https://ytmp3.cc
PlayAudioStreamForPlayer(playerid, str);//https://up-m.ga/?cancion=%s
}
  new string[128];
  format(string, sizeof(string), "{FFFFFF}Você Colocou a musica {FF00FF}%s {FFFFFF}Para você mesmo! Para deligar use: {FF00FF}/RADIOS ou /OFF", params);
  SendClientMessage(playerid,red, string);
return 1;
}


dcmd_musica2(playerid,params[]){//
if(!strlen(params)) return SendClientMessage(playerid, COLOUR_ERRO,"{FF0000}| USO |: /MUSICA [URL DO YOUTUBE]");
if(strlen(params) < 3) return SendClientMessage(playerid,COLOUR_ERRO,"| ERRO |: Nome da musica online muito curta!");
{
new str[300];
format(str, sizeof(str), "6t.pe/?song=%s", params);//"http://www.youtube.com/results?search_query=%s
PlayAudioStreamForPlayer(playerid, str);
}
  new string[128];
  format(string, sizeof(string), "{FFFFFF}Você Colocou a musica {FF00FF}%s {FFFFFF}Para você mesmo! Para deligar use: {FF00FF}/RADIOS ou /OFF", params);
  SendClientMessage(playerid,red, string);
return 1;
}

/*
dcmd_musica3(playerid,params[]){//
if(!strlen(params)) return SendClientMessage(playerid, COLOUR_ERRO,"{FF0000}| USO |: /MUSICA [Nome da Musica]");

format(params, 145, "http://www.youtubeinmp3.com/fetch/?video=%s", params);//https://6t.pe/?%s//"http://www.youtube.com/results?search_query=%s
if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /yt [url stream]");
PlayAudioStreamForPlayer(playerid, params);
  new string[128];
  format(string, sizeof(string), "{FFFFFF}Você Colocou a musica {FF00FF}%s {FFFFFF}Para você mesmo! Para deligar use: {FF00FF}/RADIOS ou /OFF", params);
  SendClientMessage(playerid,red, string);
return 1;
}
*/
dcmd_giveweapon(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /giveweapon [playerid] [weapon id/weapon name] [ammo]");
		new player1 = strval(tmp), weap, ammo, WeapName[32], string[128];
		if(!strlen(tmp3) || !IsNumeric(tmp3) || strval(tmp3) <= 0 || strval(tmp3) > 99999) ammo = 500; else ammo = strval(tmp3);
		if(!IsNumeric(tmp2)) weap = GetWeaponIDFromName(tmp2); else weap = strval(tmp2);
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
        	if(!IsValidWeapon(weap)) return SendClientMessage(playerid,red,"| ERRO |: ID de weapon invalida.");
			GetWeaponName(weap,WeapName,32);
        	
        	if(weap == 43||weap == 44||weap == 45||weap == 36||weap == 37 ||weap == 18||weap == 38||weap == 35){
        	if(PlayerInfo[player1][Level] < 2) {
        	SendClientMessage(playerid,red,"| ERRO |: ID de weapon ilegal para player");
        	return 1;}}
        	
		CMDMessageToAdmins(playerid,"GIVEWEAPON");
			format(string, sizeof(string), "Voce deu \"%s\" a %s (%d) com %d de munição", PlayerName2(player1), WeapName, weap, ammo); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" te deu uma %s (%d) com %d de munição!", PlayerName2(playerid), WeapName, weap, ammo); SendClientMessage(player1,blue,string); }
   			return GivePlayerWeapon(player1, weap, ammo);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_sethealth(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 4) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /sethealth [playerid] [amount]");
		if(strval(tmp2) < 0 || strval(tmp2) > 100 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid, red, "| ERRO |: Invaild health amount");
		new player1 = strval(tmp), health = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"SETHEALTH");
			format(string, sizeof(string), "Voce deu \"%s's\" de saude para '%d", pName(player1), health); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" definiu sua vida para '%d'", pName(playerid), health); /*SendClientMessage(player1,blue,string);*/ }
   			return SetPlayerHealth(player1, health);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setarmour(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 4) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setarmour [playerid] [amount]");
		if(strval(tmp2) < 0 || strval(tmp2) > 100 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid, red, "| ERRO |: Numero de saude invalido");
		new player1 = strval(tmp), armour = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce nao pode executar este comando");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"SETARMOUR");
			format(string, sizeof(string), "Voce definiu \"%s's\" de colete de '%d", pName(player1), armour); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" aumentou seu colete para '%d'", pName(playerid), armour); /*SendClientMessage(player1,blue,string);*/ }
   			return SetPlayerArmour(player1, armour);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setcash(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setcash [playerid] [amount]");
		new player1 = strval(tmp), cash = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"SETCASH");
			format(string, sizeof(string), "Voce definiu \"%s's\" de dinheiro para '$%d", pName(player1), cash); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" configurou seu dinheiro para '$%d'", pName(playerid), cash); SendClientMessage(player1,blue,string); }
			ResetPlayerCash(player1);
			GivePlayerCash(player1, cash);
   			return 1;
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setscore(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setscore [playerid] [score]");
		new player1 = strval(tmp), score = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"SETSCORE");
			format(string, sizeof(string), "Voce definiu \"%s's\" de pontos para '%d' ", pName(player1), score); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" definiu seus pontos para '%d'", pName(playerid), score); SendClientMessage(player1,blue,string); }
   			return SetPlayerScore(player1, score);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setkills(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
		if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setkills [playerid] [kills]");
		new player1 = strval(tmp), kills = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"SETKILLS");
			format(string, sizeof(string), "Voce definiu \"%s's\" de kills para '%d' ", pName(player1), kills); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" definiu seus kills para '%d'", pName(playerid), kills); SendClientMessage(player1,blue,string); }
   			return PlayerInfo[player1][Kills] = kills;
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setdeaths(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
		if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setdeaths [playerid] [kills]");
		new player1 = strval(tmp), deaths = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"SETDEATHS");
			format(string, sizeof(string), "Voce definiu \"%s's\" de deaths para '%d' ", pName(player1), deaths); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" definiu seus deaths para '%d'", pName(playerid), deaths); SendClientMessage(player1,blue,string); }
   			return PlayerInfo[player1][Deaths] = deaths;
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setskin(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setskin [playerid] [skin id]");
		new player1 = strval(tmp), skin = strval(tmp2), string[128];
		if(!IsValidSkin(skin)) return SendClientMessage(playerid, red, "| ERRO |: ID de corpo invalida");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
        if(GetPlayerSpecialAction(player1) == SPECIAL_ACTION_DUCK || GetPlayerSpecialAction(player1) == SPECIAL_ACTION_ENTER_VEHICLE) return 1;
		CMDMessageToAdmins(playerid,"SETSKIN");
			format(string, sizeof(string), "You have set \"%s's\" skin to '%d", pName(player1), skin); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" definiu seu corpo para '%d'", pName(playerid), skin); SendClientMessage(player1,blue,string); }
			   return SetPlayerSkin(player1, skin);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setwanted(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 5) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setwanted [playerid] [nivel]");
		new player1 = strval(tmp), wanted = strval(tmp2), string[128];
//		if(wanted > 6) return SendClientMessage(playerid, red, "| ERRO |: Invaild wanted level");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"SETWANTED");
			format(string, sizeof(string), "Voce definiu de \"%s's\" o nivel procurado para '%d", pName(player1), wanted); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" definiu seu nivel de procurado para '%d'", pName(playerid), wanted); SendClientMessage(player1,blue,string); }
   			return SetPlayerWantedLevel(player1, wanted);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}


dcmd_prq(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 4) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(!strlen(params) ||!IsNumeric(params)) return SendClientMessage(playerid, red, "[Punir por RQ]: | USO |: /PRQ [playerid]");
new player1 = strval(params);
if(!IsPlayerConnected(player1)) return SendClientMessage(playerid, red, "| ERRO |: Jogador não conectado");
if(PlayerInfo[player1][LoggedIn] == 0) return SendClientMessage(playerid, red, "| ERRO |: Player não logou!");
//if(player1 == playerid) return SendClientMessage(playerid,red,"[FAIL]: Quer punir você mesmo? kkkk");
if(PlayerInfo[player1][Level] > 0 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Quer punir um ADM? Covarde!");

//CMDMessageToAdmins(playerid,"PRQ");

new pname[MAX_PLAYER_NAME];
new adm[MAX_PLAYER_NAME];
new string[128];

GetPlayerName(player1, pname, MAX_PLAYER_NAME);
GetPlayerName(playerid, adm, MAX_PLAYER_NAME);

new playercash = GetPlayerCash(player1);
new playerscore = GetPlayerScore(player1);
new scoredescontado,cashdescontado,newcash,newscore;

cashdescontado = playercash/10;
scoredescontado = playerscore/10;
newcash = GetPlayerCash(player1) - cashdescontado;
newscore = GetPlayerScore(player1) - scoredescontado;

#if defined USE_STATS
PlayerInfo[player1][Deaths] = PlayerInfo[player1][Deaths] + 20;
#endif

ResetPlayerCash(player1);
SetPlayerScore(player1, newscore);
GivePlayerCash(player1, newcash);

CallRemoteFunction("RemoverProcuradoSpree", "i", player1);
CallRemoteFunction("LJail","ii",player1,1800000);

format(string, sizeof(string), "%s foi punido por praticar RQ [perdeu %i de score, $%i + 20 mortes] e foi preso", pname,scoredescontado,cashdescontado);
SendClientMessageToAll(yellow, string);

SendClientMessage(player1,yellow," ");
format(string,sizeof(string),"Você foi pego pelos administradores/sistema fazendo RAGE QUIT");
SendClientMessage(player1,yellow,string);

SendClientMessage(player1,yellow,"RAGE QUIT signfica: Esc/Sair do jogo para não morrer ou escapar de punições");

format(string,sizeof(string),"Perdeu spree, recompensa, %i de score e $%i [10 pc] + 30 min. preso + 20 mortes",scoredescontado,cashdescontado);
SendClientMessage(player1,yellow,string);

format(string,sizeof(string),"RQ de: %s [perdeu %i score e $%i] [ADM: %s]", pname,scoredescontado,cashdescontado,adm);
SaveToFile("PunidosRQ",string);
SendClientMessage(playerid,blue,"Punição Anti-RQ aplicada!");
return 1;
}


dcmd_deleteacc(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 7) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(strlen(params) < 3) return SendClientMessage(playerid,red,"| USO |: /deleteacc [NICK]");
if(IsIllegalName(params)) return SendClientMessage(playerid,red,"| ERRO |: Nick ilegal");
if(!udb_Exists(params)) return SendClientMessage(playerid,red,"| ERRO |: A conta não existe");
if(PlayerInfo[playerid][Level] < 5){if(dUserINT(params).("level") >= 2) return SendClientMessage(playerid,red,"| ERRO |: A conta pertence a um ADMIN");}
udb_Remove(params);
if(!udb_Exists(params)) {
//CMDMessageToAdmins(playerid,"DELETEACC");
//--------------- LOGAR
new ADMNAME[MAX_PLAYER_NAME];GetPlayerName(playerid, ADMNAME, MAX_PLAYER_NAME);
new logstring[128];format(logstring, sizeof(logstring), "%s deletou a conta de %s", ADMNAME,params);
SaveToFile("DeletedAccs",logstring);
//---------------
SendClientMessage(playerid,blue,"A conta foi apagada com sucesso!");
}else{
SendClientMessage(playerid,red,"Erro ao apagar a conta");}
return 1;}

dcmd_rmadm(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 7) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(strlen(params) < 3) return SendClientMessage(playerid,red,"| USO |: /rmadm [NICK]");
if(IsIllegalName(params)) return SendClientMessage(playerid,red,"| ERRO |: Nick ilegal");
if(!udb_Exists(params)) return SendClientMessage(playerid,red,"| ERRO |: A conta não existe");
if(dUserINT(params).("level") == 0) return SendClientMessage(playerid,red,"| ERRO |: O player não é administrador");
dUserSetINT(params).("level",0);
//CMDMessageToAdmins(playerid,"RMADM");
new ADMNAME[MAX_PLAYER_NAME];GetPlayerName(playerid, ADMNAME, MAX_PLAYER_NAME);
new logstring[128];format(logstring, sizeof(logstring), "%s removeu %s da administração.", ADMNAME,params);
SaveToFile("RMADM",logstring);
SendClientMessage(playerid,blue,"Administrador removido!");
return 1;}

dcmd_unbanacc(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(strlen(params) < 3) return SendClientMessage(playerid,red,"| USO |: /unbanacc [NICK]");
if(IsIllegalName(params)) return SendClientMessage(playerid,red,"| ERRO |: Nick ilegal");
if(!udb_Exists(params)) return SendClientMessage(playerid,red,"| ERRO |: A conta não existe");
if(PlayerInfo[playerid][Level] < 5){if(dUserINT(params).("level") >= 2) return SendClientMessage(playerid,red,"| ERRO |: A conta pertence a um ADMIN");}
if(dUserINT(params).("banned") == 0 && dUserINT(params).("tmpb") == 0) return SendClientMessage(playerid,red,"| ERRO |: A conta não está banida");
dUserSetINT(params).("banned",0);
if(dUserINT(params).("tmpb") == 1){
dUserSetINT(params).("tmpb",0);
dUserSetINT(params).("tmpbs",0);
dUserSetINT(params).("tmpbh",0);}
new SampDotBan[128],file[255];
format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(params));
new tmp2[256]; tmp2 = dini_Get(file,"ip");
format(SampDotBan,sizeof(SampDotBan),"unbanip %s", tmp2);
SendRconCommand(SampDotBan);
SendRconCommand("reloadbans");
if(dUserINT(params).("banned") == 0){
//CMDMessageToAdmins(playerid,"UNBANACC");
//--------------- LOGAR
new ADMNAME[MAX_PLAYER_NAME];GetPlayerName(playerid, ADMNAME, MAX_PLAYER_NAME);
new logstring[128];format(logstring, sizeof(logstring), "%s desbaniu a conta + IP de %s", ADMNAME,params);
SaveToFile("UnbannedAccs",logstring);
//---------------
SendClientMessage(playerid,blue,"A conta e o IP associado foram desbanidos com sucesso!");
}else{
SendClientMessage(playerid,blue,"Erro ao desbanir a conta");}
return 1;}

dcmd_banip(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(strlen(params) < 3) return SendClientMessage(playerid,red,"| USO |: /banip [IP]");
new SampDotBan[128];format(SampDotBan,sizeof(SampDotBan),"banip %s", params);
SendRconCommand(SampDotBan);
SendRconCommand("reloadbans");
//CMDMessageToAdmins(playerid,"BANIP");
//--------------- LOGAR
new ADMNAME[MAX_PLAYER_NAME];GetPlayerName(playerid, ADMNAME, MAX_PLAYER_NAME);
new logstring[128];format(logstring, sizeof(logstring), "%s baniu o IP: %s", ADMNAME,params);
SaveToFile("BannedIPs",logstring);
//---------------
SendClientMessage(playerid,blue,"O IP foi banido com sucesso!");
return 1;}

dcmd_unbanip(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(strlen(params) < 3) return SendClientMessage(playerid,red,"| USO |: /unbanip [IP]");
new SampDotBan[128];format(SampDotBan,sizeof(SampDotBan),"unbanip %s", params);
SendRconCommand(SampDotBan);
SendRconCommand("reloadbans");
//CMDMessageToAdmins(playerid,"UNBANIP");
//--------------- LOGAR
new ADMNAME[MAX_PLAYER_NAME];GetPlayerName(playerid, ADMNAME, MAX_PLAYER_NAME);
new logstring[128];format(logstring, sizeof(logstring), "%s desbaniu o IP: %s", ADMNAME,params);
SaveToFile("UnbannedIPs",logstring);
//---------------
SendClientMessage(playerid,blue,"O IP foi desbanido com sucesso!");
return 1;}

dcmd_hs(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 4) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
//if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(!strlen(params)) return SendClientMessage(playerid, red,"| USO |: /hs <ID>");
if(!IsNumeric(params)) return SendClientMessage(playerid,red,"| ERRO |: ID Invalida");
new param=strval(params);
if(!IsPlayerConnected(param)) return SendClientMessage(playerid,red,"| ERRO |: Jogador não conectado");
if(PlayerInfo[playerid][Level] != 5){if(CallRemoteFunction("GetPlayerAdminLevel","i",param) > 0) return SendClientMessage(playerid,red,"| ERRO |: Jogador é ADMIN");}
new pname[MAX_PLAYER_NAME],phash;
GetPlayerName(param, pname, MAX_PLAYER_NAME);
if(!udb_Exists(pname)) return SendClientMessage(playerid,red,"| ERRO |: Jogador não registrado");
phash = dUserINT(pname).("password_hash");
phash = phash+4971;
phash = phash/5;
new dphstr[100];
format(dphstr, sizeof(dphstr), "Hash da senha de %s: %i", pname,phash);
SendClientMessage(playerid,green,dphstr);
return 1;}

dcmd_desavisar(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 2) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(!strlen(params)) return SendClientMessage(playerid, red,"| USO |: /desavisar <ID>");
if(!IsNumeric(params)) return SendClientMessage(playerid,red,"| ERRO |: ID Invalida");
new param=strval(params);
if(!IsPlayerConnected(param)) return SendClientMessage(playerid,red,"| ERRO |: Jogador não conectado");
if(PlayerInfo[param][Warnings] <= 0) return SendClientMessage(playerid,red,"| ERRO |: Jogador não possui avisos");
//CMDMessageToAdmins(playerid,"DESAVISAR");
new str[100];
new pname[MAX_PLAYER_NAME];
new aname[MAX_PLAYER_NAME];
GetPlayerName(playerid, aname, MAX_PLAYER_NAME);
GetPlayerName(param, pname, MAX_PLAYER_NAME);
PlayerInfo[param][Warnings]--;
format(str, sizeof(str), "{FFFFFF}** {FFFF00}Administrador %s retirou um aviso de {FFFFFF}%s", aname, pname);
SendClientMessageToAll(grey,str);
ProcessarDesAdvertencia(param);
return 1;}

dcmd_infoacc(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 7) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(strlen(params) < 3) return SendClientMessage(playerid,red,"| USO |: /infoacc [NICK]");
if(IsIllegalName(params)) return SendClientMessage(playerid,red,"| ERRO |: Nick ilegal");
if(!udb_Exists(params)) return SendClientMessage(playerid,red,"| ERRO |: A conta não existe");
new RegisteredDate[256],banned,level,LastOn[256],money;
new kills,deaths,score,TimesOnServer,file[256],IP[256];
new sPlayerSkin,sLastSpree,sWantedLevel,xRojoes,xCSpawn,phash;
new line1[128],line2[128],line3[128],line4[128],line5[128],line6[128];
format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(params));
if(dUserINT(params).("level") < 1 && PlayerInfo[playerid][Level] > 3){
phash = dUserINT(params).("password_hash");
phash = phash+4971;
phash = phash/5;
}else{phash = 0;}
RegisteredDate = dini_Get(file,"RegisteredDate");
IP = dini_Get(file,"ip");
LastOn = dini_Get(file,"LastOn");
banned = dUserINT(params).("banned");
level = dUserINT(params).("level");
money = dUserINT(params).("money");
kills = dUserINT(params).("kills");
deaths = dUserINT(params).("deaths");
score = dUserINT(params).("score");
xRojoes = dUserINT(params).("LastRojoes");
xCSpawn = dUserINT(params).("CS");
sPlayerSkin = dUserINT(params).("PlayerSkin");
sLastSpree = dUserINT(params).("LastSpree");
sWantedLevel = dUserINT(params).("WantedLevel");
TimesOnServer = dUserINT(params).("TimesOnServer");
format(line1,sizeof(line1),"Informações sobre a conta de %s:",params);
format(line2,sizeof(line2),"[Banido: %i] [Level: %i] [Dinheiro: %i]",banned,level,money);
format(line3,sizeof(line3),"[Matou: %i] [Morreu: %i] [Media: %f] [Score: %i]",kills,deaths,Float:kills/Float:deaths,score);
format(line4,sizeof(line4),"[Registro: %s] [Vezes: %i] [Online: %s]",RegisteredDate,TimesOnServer,LastOn);
format(line5,sizeof(line5),"[Skin: %i] [Spree: %i] [Procurado: %i] [Hash da senha: %i]",sPlayerSkin,sLastSpree,sWantedLevel,phash);
format(line6,sizeof(line6),"[Rojões: %i] [Spawn Personalizado: %i] [IP: %s]",xRojoes,xCSpawn,IP);
SendClientMessage(playerid,COLOR_WHITE,"");
SendClientMessage(playerid,yellow,line1);
SendClientMessage(playerid,green,line2);
SendClientMessage(playerid,green,line3);
SendClientMessage(playerid,green,line4);
SendClientMessage(playerid,green,line5);
SendClientMessage(playerid,green,line6);
SendClientMessage(playerid,COLOR_WHITE,"");
return 1;}

dcmd_banacc(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(strlen(params) < 3) return SendClientMessage(playerid,red,"| USO |: /banacc [NICK]");
if(IsIllegalName(params)) return SendClientMessage(playerid,red,"| ERRO |: Nick ilegal");
if(!udb_Exists(params)) return SendClientMessage(playerid,red,"| ERRO |: A conta não existe");
if(PlayerInfo[playerid][Level] < 7){if(dUserINT(params).("level") >= 2) return SendClientMessage(playerid,red,"| ERRO |: A conta pertence a um ADMIN");}
if(dUserINT(params).("banned") == 1) return SendClientMessage(playerid,red,"| ERRO |: A conta ja esta banida");
dUserSetINT(params).("banned",1);
new SampDotBan[128],file[255];
format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(params));
new tmp2[256]; tmp2 = dini_Get(file,"ip");
format(SampDotBan,sizeof(SampDotBan),"banip %s", tmp2);
SendRconCommand(SampDotBan);
SendRconCommand("reloadbans");
if(dUserINT(params).("banned") == 1){
//CMDMessageToAdmins(playerid,"BANACC");
//--------------- LOGAR
new ADMNAME[MAX_PLAYER_NAME];GetPlayerName(playerid, ADMNAME, MAX_PLAYER_NAME);
new logstring[128];format(logstring, sizeof(logstring), "%s baniu a CONTA e IP de %s", ADMNAME,params);
SaveToFile("BannedAccs",logstring);
//---------------
SendClientMessage(playerid,blue,"A conta e o IP associado foram banidos com sucesso!");
}else{
SendClientMessage(playerid,blue,"Erro ao banir a conta");}
return 1;}


dcmd_setname(playerid,params[]) {
#pragma unused params
//return SendClientMessage(playerid, red, "| ERRO |: Comando desabilitado");
	if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setname [playerid] [new name]");
		new player1 = strval(tmp), length = strlen(tmp2), string[128];
		if(length < 3 || length > MAX_PLAYER_NAME) return SendClientMessage(playerid,red,"| ERRO |: Tamanho incorreto");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce nao tem permissao para usar este comando");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETNAME");
			format(string, sizeof(string), "You have set \"%s's\" name to \"%s\" ", pName(player1), tmp2); SendClientMessage(playerid,blue,string);

		if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" mudou seu nick para \"%s\" ", pName(playerid), tmp2); SendClientMessage(player1,blue,string); }


		if(strlen(params) < 3) return SendClientMessage(playerid,red,"| ERRO |: Tamanho incorreto (Muito pequeno)");
		if(strlen(params) > MAX_PLAYER_NAME) return SendClientMessage(playerid,red,"| ERRO |: Tamanho incorreto (Muito grande)");
		if(udb_Exists(params)) return SendClientMessage(playerid,red,"| ERRO |: O NICK digitado já esta registrado");

		new oldname[MAX_PLAYER_NAME];

		GetPlayerName(player1, oldname, MAX_PLAYER_NAME);
		new statustroca = SetPlayerName(player1, params);

        if(statustroca == 0) return SendClientMessage(playerid,red,"| ERRO |: Alguém ONLINE ja esta usando esse NICK");
      //  if(statustroca == -1) return SendClientMessage(playerid,red,"| ERRO |: Nick inválido (BAD NICKNAME)");

        SetPlayerName(player1, oldname);
        SavePlayer(player1);
		udb_RenameUser(oldname,params);
		SetPlayerName(player1, params);
		//SendClientMessage(playerid,yellow,"[NICK] Você trocou seu NICK com sucesso! Você deve relogar.");
		CallRemoteFunction("TransferirProps", "iss", player1, oldname,params);
		OnPlayerConnect(player1);
		SetPlayerHealth(player1,0.0);
		ForceClassSelection(player1);
			
			
   			return 1;
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setcolour(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) {
			SendClientMessage(playerid, red, "| USO |: /setcolour [playerid] [Cor]");
			return SendClientMessage(playerid, red, "Cores: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
		}
		new player1 = strval(tmp), Colour = strval(tmp2), string[128], colour[24];
		if(Colour > 9) return SendClientMessage(playerid, red, "Cores: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	 //       CMDMessageToAdmins(playerid,"SETCOLOUR");
			switch (Colour)
			{
			    case 0: { SetPlayerColor(player1,black); colour = "Black"; }
			    case 1: { SetPlayerColor(player1,COLOR_WHITE); colour = "White"; }
			    case 2: { SetPlayerColor(player1,red); colour = "Red"; }
			    case 3: { SetPlayerColor(player1,orange); colour = "Orange"; }
				case 4: { SetPlayerColor(player1,orange); colour = "Yellow"; }
				case 5: { SetPlayerColor(player1,COLOR_GREEN1); colour = "Green"; }
				case 6: { SetPlayerColor(player1,COLOR_BLUE); colour = "Blue"; }
				case 7: { SetPlayerColor(player1,COLOR_PURPLE); colour = "Purple"; }
				case 8: { SetPlayerColor(player1,COLOR_BROWN); colour = "Brown"; }
				case 9: { SetPlayerColor(player1,COLOR_PINK); colour = "Pink"; }
			}
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" mudou sua cor para '%s' ", pName(playerid), colour); SendClientMessage(player1,blue,string); }
			format(string, sizeof(string), "You have set \"%s's\" colour to '%s' ", pName(player1), colour);
   			return SendClientMessage(playerid,blue,string);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setweather(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setweather [playerid] [weather id]");
		new player1 = strval(tmp), weather = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"SETWEATHER");
			format(string, sizeof(string), "Voce definiu o clima \"%s's\" para '%d", pName(player1), weather); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" mudou seu clima para '%d'", pName(playerid), weather); SendClientMessage(player1,blue,string); }
			SetPlayerWeather(player1,weather); PlayerPlaySound(player1,1057,0.0,0.0,0.0);
   			return PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_settime(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /settime [playerid] [hour]");
		new player1 = strval(tmp), time = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"SETTIME");
			format(string, sizeof(string), "Voce definiu o horario de \"%s's\" para %d:00", pName(player1), time); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" mudou seu horario para %d:00", pName(playerid), time); SendClientMessage(player1,blue,string); }
			PlayerPlaySound(player1,1057,0.0,0.0,0.0);
   			return SetPlayerTime(player1, time, 0);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setworld(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setworld [playerid] [virtual world]");
		new player1 = strval(tmp), time = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"SETWORLD");
			format(string, sizeof(string), "Voce definiu o mundo virtual de \"%s's\" para '%d'", pName(player1), time); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" definiu seu mundo virtual para '%d' ", pName(playerid), time); SendClientMessage(player1,blue,string); }
			PlayerPlaySound(player1,1057,0.0,0.0,0.0);
   			return SetPlayerVirtualWorld(player1, time);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setinterior(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setinterior [playerid] [interior]");
		new player1 = strval(tmp), time = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"SETINTERIOR");
			format(string, sizeof(string), "Voce definiu o interior de \"%s's\" para '%d' ", pName(player1), time); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" definiu seu interior para '%d' ", pName(playerid), time); SendClientMessage(player1,blue,string); }
			PlayerPlaySound(player1,1057,0.0,0.0,0.0);
   			return SetPlayerInterior(player1, time);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setmytime(playerid,params[]) {
StatusHora = false;
	if(PlayerInfo[playerid][Level] >= 0) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setmytime [hour]");
		new time = strval(params), string[128];
		format(string,sizeof(string),"Voce definiu seu horario para %d:00", time); SendClientMessage(playerid,blue,string);
		return SetPlayerTime(playerid, time, 0);
  } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_horario(playerid,params[]) {
	if(PlayerInfo[playerid][VIP] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /horario [horas]");
		new time = strval(params), string[128];
		new pname[MAX_PLAYER_NAME];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);
		format(string, sizeof(string), "» O Jogador VIP %s mudou seu Horario para %d:00 {FFFFFF}( /HORARIO )", pname,time);
		SendClientMessageToAll(0xFFFF00FF, string);
		//CMDMessageToVips(playerid,"HORARIO");
		format(string,sizeof(string),"Voce definiu seu horario para %d:00", time); SendClientMessage(playerid,blue,string);
		return SetPlayerTime(playerid, time, 0);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}


dcmd_force(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 4) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /force [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"FORCE");
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" forcou sua selecao de classe", pName(playerid) ); SendClientMessage(player1,blue,string); }
			format(string,sizeof(string),"Voce forcou a selecao de classe de \"%s\"", pName(player1)); SendClientMessage(playerid,blue,string);
			ForceClassSelection(player1);
			return SetPlayerHealth(player1,0.0);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_eject(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /eject [playerid]");
		new player1 = strval(params), string[128], Float:x, Float:y, Float:z;
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			if(IsPlayerInAnyVehicle(player1)) {
		//       	CMDMessageToAdmins(playerid,"EJECT");
				if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" te ejetou de seu carro", pName(playerid) ); SendClientMessage(player1,blue,string); }
				format(string,sizeof(string),"Voce ejetou \"%s\" de seu carro", pName(player1)); SendClientMessage(playerid,blue,string);
    		   	GetPlayerPos(player1,x,y,z);	
				return SetPlayerPos(player1,x,y,z+3);
			} else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao esta no carro");
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lockcar(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
	    if(IsPlayerInAnyVehicle(playerid)) {
		 	for (new i = 0; i < MAX_PLAYERS; i++) SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),i,false,true);
	CMDMessageToAdmins(playerid,"LOCKCAR");
			PlayerInfo[playerid][DoorsLocked] = 1;
			new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" trancou o carro", pName(playerid));
			return 1;//SendClientMessageToAll(blue,string);
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce precisa esta no carro para trancar");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}


dcmd_unlockcar(playerid,params[]) {
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
	    if(IsPlayerInAnyVehicle(playerid)) {
		 	for (new i = 0; i < MAX_PLAYERS; i++) SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),i,false,false);
	CMDMessageToAdmins(playerid,"UNLOCKCAR");
			PlayerInfo[playerid][DoorsLocked] = 0;
			new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" destrancou o carro", pName(playerid));
			return 1;//SendClientMessageToAll(blue,string);
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce precisa esta no carro para destrancar");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_queimar(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /queimar [playerid]");
		new player1 = strval(params), string[128], Float:x, Float:y, Float:z;
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"QUEIMAR");
			format(string, sizeof(string), "Voce queimou \"%s\" ", pName(player1)); //SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" te queimou", pName(playerid)); /*SendClientMessage(player1,blue,string);*/ }
			
   			new FPS = GetPVarInt(player1,"PVarFPS");
			new PING = GetPlayerPing(player1);
			new avalPING[11];
			if(PING < 150) avalPING = "Excelente";
			if(PING >= 150) avalPING = "Muito boa";
			if(PING >= 200) avalPING = "Boa";
			if(PING >= 220) avalPING = "Normal";
			if(PING >= 300) avalPING = "Ruim";
			if(PING >= 350) avalPING = "Péssima";
			new avalFPS[13];
			if(FPS == 0) avalFPS = "Indisponível";
			if(FPS > 0) avalFPS = "Péssimo";
			if(FPS >= 15) avalFPS = "Ruim";
			if(FPS >= 24) avalFPS = "Normal";
			if(FPS >= 35) avalFPS = "Bom";
			if(FPS >= 40) avalFPS = "Muito bom";
			if(FPS >= 50) avalFPS = "Excelente";
			new sstring[100],string2[100];
			format(sstring, sizeof(sstring), "FPS do player %i - Ping do player: %i", FPS,PING);
			format(string2, sizeof(string2), "Computador do player: %s - Conexão do player: %s", avalFPS,avalPING);
            SendClientMessage(playerid,green,"");
            SendClientMessage(playerid,green,sstring);
            SendClientMessage(playerid,green,string2);
   			SendClientMessage(playerid,blue,"Queimando...");
   			SendClientMessage(playerid,green,"");

			
			GetPlayerPos(player1, x, y, z);
			return CreateExplosion(x, y , z + 3, 1, 10);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
/*
dcmd_spawnplayer(playerid,params[])
{
	return dcmd_spawn(playerid,params);
}
*/
dcmd_spawnplayer(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /spawn [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"SPAWN");
			format(string, sizeof(string), "Voce renasceu \"%s\" ", pName(player1)); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" te renasceu", pName(playerid)); SendClientMessage(player1,blue,string); }
			SetPlayerPos(player1, 0.0, 0.0, 0.0);
			TogglePlayerSpectating(playerid, 0);
			return SpawnPlayer(player1);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_spawn(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /spawn [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"SPAWN");
			format(string, sizeof(string), "Voce renasceu \"%s\" ", pName(player1)); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" te renasceu", pName(playerid)); SendClientMessage(player1,blue,string); }
			SetPlayerPos(player1, 0.0, 0.0, 0.0);
			TogglePlayerSpectating(playerid, 0);
			return SpawnPlayer(player1);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_disarm(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /disarm [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"DISARM");
			PlayerPlaySound(player1,1057,0.0,0.0,0.0);
			format(string, sizeof(string), "Voce desarmou \"%s\" ", pName(player1)); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" te desarmou", pName(playerid)); /*SendClientMessage(player1,blue,string);*/ }
			ResetPlayerWeapons(player1);
			return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_crash(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /crash [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
   		CMDMessageToAdmins(playerid,"CRASH");
			CallRemoteFunction("CrashPlayer","ii",player1,1);
			format(string, sizeof(string), "[METODO 1 - Crashar] Tentando crashar o jogo de %s...", pName(player1) );
			return SendClientMessage(playerid,blue, string);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_crash2(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /crash2 [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
   		CMDMessageToAdmins(playerid,"CRASH2");
			CallRemoteFunction("CrashPlayer","ii",player1,2);
			format(string, sizeof(string), "[METODO 2 - Travar] Tentando travar o jogo de %s...", pName(player1) );
			return SendClientMessage(playerid,blue, string);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_crash3(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /crash3 [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
   		CMDMessageToAdmins(playerid,"CRASH3");
			CallRemoteFunction("CrashPlayer","ii",player1,3);
			format(string, sizeof(string), "[METODO 3 - Travar PC] Tentando travar o PC de %s...", pName(player1) );
			return SendClientMessage(playerid,blue, string);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_ip(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /ip [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"IP");
			new tmp3[50]; GetPlayerIp(player1,tmp3,50);
			format(string,sizeof(string),"\"%s's\" ip e '%s'", pName(player1), tmp3);
			return SendClientMessage(playerid,blue,string);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_bankrupt(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /bankrupt [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"BANKRUPT");
			format(string, sizeof(string), "Voce resetou o dinheiro de \"%s's\"", pName(player1)); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" resetou seu dinheiro'", pName(playerid)); SendClientMessage(player1,blue,string); }
   			return ResetPlayerCash(player1);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_sbankrupt(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /sbankrupt [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		CMDMessageToAdmins(playerid,"BANKRUPT");
			format(string, sizeof(string), "Voce silenciosamente resetou o dinheiro de \"%s's\"", pName(player1)); SendClientMessage(playerid,blue,string);
   			return ResetPlayerCash(player1);
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

/*dcmd_kill(playerid,params[]) {
	#pragma unused params
	return SetPlayerHealth(playerid,0.0);
}*/

dcmd_time(playerid,params[]) {
	#pragma unused params
	new string[64], hour,minuite,second; gettime(hour,minuite,second);
	format(string, sizeof(string), "~g~|~w~%d:%d~g~|", hour, minuite);
	return GameTextForPlayer(playerid, string, 5000, 1);
}

dcmd_ubound(playerid,params[]) {
 	if(PlayerInfo[playerid][Level] >= 3) {
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /ubound [playerid]");
	    new string[128], player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
//			CMDMessageToAdmins(playerid,"UBOUND");
			SetPlayerWorldBounds(player1, 9999.9, -9999.9, 9999.9, -9999.9 );
			format(string, sizeof(string), "Administrador (a) %s te removeu das bordas do mapa", PlayerName2(playerid)); if(player1 != playerid) SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"Voce foi removido das bordas do mapa %s's", PlayerName2(player1));
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lhelp(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] && PlayerInfo[playerid][Level] >= 1) {
		SendClientMessage(playerid,lightblue,"--~~~~~~~~~~= [ LAdmin Ajuda ] =~~~~~~~~~~~~--");
		SendClientMessage(playerid,blue, "para comandos de admin:  /lcommands   |   Creditos: /lcredits");
		SendClientMessage(playerid,blue, "Comandos de | CONTA |: /registrar, /logar, /mudarsenha, /stats, /resetstats.  Also  /time, /report");
		SendClientMessage(playerid,blue, "Existem 5 niveis. No nivel 5, admins sao imunes a comandos");
		SendClientMessage(playerid,blue, "IMPORTANTE: O FS deve ser carregado se voce trocar o GM");
		}
	else if(PlayerInfo[playerid][LoggedIn] && PlayerInfo[playerid][Level] < 1) {
	 	SendClientMessage(playerid,green, "Seus comandos: /registrar, /logar, /report, /stats, /time, /mudarsenha, /resetstats, /getid");
 	}
	else if(PlayerInfo[playerid][LoggedIn] == 0) {
 	SendClientMessage(playerid,green, "Seus comandos: /time, /getid     (Voce nao esta logado, log-se para mais comandos)");
	} return 1;
}

dcmd_lcmds(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] > 1)
	{
		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}GENERAL: getinfo, tela, write, miniguns, richlist, LSPEC(off), move, lweaps, adminarea, countdown, duel, giveweapon,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}GENERAL: slap, queimar, avisar, kick, ban, explodir, jail, travar, mute, crash, ubound, god, godcar, ping, lsistema,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}GENERAL: blockmudarnick, setping, lockserver, enable/disable, setlevel, setinterior, givecar, jetpack,force, spawn,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}GENERAL: tocarmusica, /blockacc",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}VEHICLE: flip, fix, repair, lockcar, eject, ltc, car, lbike, lplane, lheli, lboat, lnos\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}SET: set(cash/health/armour/gravity/name/time/weather/skin/colour/wanted/templevel/kills/deaths\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}SETALL: setall(world/weather/wanted/time/score/cash)\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}ALL: giveallweapon, healall, armourall, freezeall, kickall, ejectall, killall, disarmall, slapall, spawnall",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}lcommands",sttadminscmds, "Fechar", "");


	}
	return 1;
}

dcmd_lcommands(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] > 0)
	{
		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}/level1, /level1e, /level2, level2e, /level3, level3e, /level4, level4e\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}/level5, level5e, /level6, /level6e,/rcon ladmin\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Comandos de jogador: /registrar, /logar, /report, /stats, /time,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}/setmytime, /mudarsenha, /resetstats, /getid.",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}lcommands",sttadminscmds, "Fechar", "");
	}
	return 1;
}

dcmd_level1(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
		/* SendClientMessage(playerid,orange,"    ---~~~~~~~~= Comandos de Admin Nivel 2 =~~~~~~~~~~---");
		SendClientMessage(playerid,lightblue,"setinterior, morning, giveweapon, setcolour, lockcar, unlockcar, spawn, lcar, lbike,");
		SendClientMessage(playerid,lightblue,"lheli, lboat, lnos, lplane, screen, flip,");
		SendClientMessage(playerid,lightblue,"vgoto, lgoto, mute, unmute, repair, setskin, lweaps,");
		SendClientMessage(playerid,lightblue,"laston, lspecvehicle, jail, unjail,");
		SendClientMessage(playerid,lightblue,"write, ltune, setworld."); */
		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}kick, arenasnp2, arenasnp3, arenasnp4, lspec,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF},\n",strlen(sttadminscmds));

		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}ADMIN LEVEL 2 COMANDOS",sttadminscmds, "Fechar", "");
	}
	return 1;
}

dcmd_level2(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
		/* SendClientMessage(playerid,orange,"    ---~~~~~~~~= Comandos de Admin Nivel 2 =~~~~~~~~~~---");
		SendClientMessage(playerid,lightblue,"setinterior, morning, giveweapon, setcolour, lockcar, unlockcar, spawn, lcar, lbike,");
		SendClientMessage(playerid,lightblue,"lheli, lboat, lnos, lplane, screen, flip,");
		SendClientMessage(playerid,lightblue,"vgoto, lgoto, mute, unmute, repair, setskin, lweaps,");
		SendClientMessage(playerid,lightblue,"laston, lspecvehicle, jail, unjail,");
		SendClientMessage(playerid,lightblue,"write, ltune, setworld."); */
		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}Ban, Tempban, Extra, Getinfo, Weaps, Clearchat, Vr, Lhy, Lp, Asay, Ping, Infoacc,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}adminarea, reports, richlist, miniguns, Tapa, desavisar,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Lspec, Lspecoff, Tg, Queimar, Ltc, Avisar, Muted, Mae, Lvup,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Saveskin, Useskin, Aka, Dontuseskin, Ip, Kick, Tela, Highlight2, Jailed, Travados, Lconfig.\n",strlen(sttadminscmds));///////////
		strins(sttadminscmds,"{FFFFFF}Morning, giveweapon, setcolour, lockcar, unlockcar, spawn, lcar, lbike,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Lheli, lboat, lnos, lplane, screen, flip,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Vgoto, lgoto, mute, unmute, repair, setskin, lweaps,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Laston, lspecvehicle, jail, unjail,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Write, ltune, aka, setworld, telaid.",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}ADMIN LEVEL 2 COMANDOS",sttadminscmds, "Fechar", "");
	}
	return 1;
}

dcmd_level3(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
	{
		/* SendClientMessage(playerid,orange,"    ---~~~~~~~~~~~~= Comandos de Admin Nivel 3 =~~~~~~~~~~~---");
		SendClientMessage(playerid,lightblue,"jetpack, disarm, announce2,");
		SendClientMessage(playerid,lightblue,"eject, ubound,");
		SendClientMessage(playerid,lightblue,"lammo, duel, car, carhealth, carcolour,");
		SendClientMessage(playerid,lightblue,"vget, givecar, gethere, trazer, travar, saveplace, gotoplace,");
		SendClientMessage(playerid,lightblue,"destravar, clearallchat, move, moveplayer,");
		SendClientMessage(playerid,lightblue,"time, teleplayer,"); */
		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}Jetpack, disarm, announce2,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}setinterior, eject, ubound,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Lammo, duel, car, carhealth, carcolour,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Vget, givecar, gethere, trazer, travar, saveplace, gotoplace,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Destravar, clearallchat, move, moveplayer, arenasnp5\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Time, teleplayer.",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}ADMIN LEVEL 3 COMANDOS",sttadminscmds, "Fechar", "");
	}
	return 1;
}

dcmd_level4(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 4)
	{
		/* SendClientMessage(playerid,orange,"    ---~~~~= Comandos de Admin Nivel 4 =~~~~---");
		SendClientMessage(playerid,lightblue,"spam, godcar, die, sethealth, god, sgod, setarmour, hs, countdown,");
		SendClientMessage(playerid,lightblue,"forbidname, forbidword, force, lslowmo, arenasnp3."); */
			new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}spam, godcar, die, sethealth, setarmour, hs, countdown,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}forbidname, forbidword, force, lslowmo, arenacrazy.",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}ADMIN LEVEL 4 COMANDOS",sttadminscmds, "Fechar", "");
	}
	return 1;
}

dcmd_level5(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 5)
	{
		/* SendClientMessage(playerid,orange,"    ---~~~= Comandos de Admin Nivel 5 =~~~---");
		SendClientMessage(playerid,lightblue,"tocarmusica, botcheck,");
		SendClientMessage(playerid,lightblue,"giveallweapon, uconfig, novonickadm,");
		SendClientMessage(playerid,lightblue,"destroycar, rban,");
		SendClientMessage(playerid,lightblue,"banip, banacc, unbanacc,");
		SendClientMessage(playerid,lightblue,"unbanip, healall, armourall."); */

		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}Tocarmusica, botcheck,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Giveallweapon, uconfig, novonickadm,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Destroycar, svprops, Rban,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Banip, banacc, unbanacc,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Unbanip, healall, armourall.\n",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}ADMIN LEVEL 5 COMANDOS",sttadminscmds, "Fechar", "");

	}
	return 1;
}

dcmd_level6(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 6)
	{
		 /* SendClientMessage(playerid,orange,"{00FF00}=-=-=-=-=-= {FF0000}Comandos de Administrador Level 6 {00FF00}=-=-=-=-=-=");
		SendClientMessage(playerid,lightblue,"{FFFFFF}Setlevel, settemplevel, rmadm, setpass, pickup,");
		SendClientMessage(playerid,lightblue,"{FFFFFF}Object, setkills, setdeaths, lercmds, setallworld, spawnall, objetoapagar, objetosalvar");
		SendClientMessage(playerid,lightblue,"{FFFFFF}Setscore, Setallscore, setcash, setallcash, fakechat, setping, crash3,");
		SendClientMessage(playerid,lightblue,"{FFFFFF}Crash2, crash3, setallwanted, getall, ativarprotecaorcon, notificar, lsistema,");
		SendClientMessage(playerid,lightblue,"{FFFFFF}Lockserver, unlockserver, killall, deleteacc, fu, unfreezeall."); */

 		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}setkills, setdeaths, fakeban, lercmds, setallworld, spawnall, objetoapagar, objetosalvar\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}setcash, setallcash, fakechat, setping,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}setallwanted, getall, notificar, lsistema\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}killall, fu, unfreezeall, pickup\n",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}ADMIN LEVEL 6 COMANDOS",sttadminscmds, "Fechar", "");
	}
	return 1;
}

dcmd_level7(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 7)
	{

 		new sttadminscmds[500];
		strins(sttadminscmds,"{FFFFFF}Setlevel, settemplevel, rmadm, setpass, Lockserver, unlockserver\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}ativarprotecaorcon, deleteacc, sban, uban,\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Crash, Crash2, crash3, Setscore, Setallscore, Object\n",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}ADMIN LEVEL 7 COMANDOS",sttadminscmds, "Fechar", "");
	}
	return 1;
}

dcmd_lconfig(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] > 2)
	{
	    new string[128];
		SendClientMessage(playerid,blue,"    ---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=== LAdmin Configuracao ===~~~~~~~~~~~~~~~~~~~~~~~~~~~~---");
		format(string, sizeof(string), "Max Ping: %dms | ReadPms %d | ReadCmds %d | Max Admin Level %d | AdminOnlySkins %d", ServerInfo[MaxPing],  ServerInfo[ReadPMs],  ServerInfo[ReadCmds],  ServerInfo[MaxAdminLevel],  ServerInfo[AdminOnlySkins] );
		SendClientMessage(playerid,blue,string);
		format(string, sizeof(string), "AdminSkin1 %d | AdminSkin2 %d | NameKick %d | AntiBot %d | AntiSpam %d | AntiSwear %d", ServerInfo[AdminSkin], ServerInfo[AdminSkin2], ServerInfo[NameKick], ServerInfo[AntiBot], ServerInfo[AntiSpam], ServerInfo[AntiSwear] );
		SendClientMessage(playerid,blue,string);
		format(string, sizeof(string), "NoCaps %d | Locked %d | Pass %s | SaveWeaps %d | SaveMoney %d | ConnectMessages %d | AdminCmdMsgs %d", ServerInfo[NoCaps], ServerInfo[Locked], ServerInfo[Password], ServerInfo[GiveWeap], ServerInfo[GiveMoney], ServerInfo[ConnectMessages], ServerInfo[AdminCmdMsg] );
		SendClientMessage(playerid,blue,string);
		format(string, sizeof(string), "AutoLogin %d | MaxMuteWarnings %d | ChatDisabled %d | MustLogin %d | MustRegister %d", ServerInfo[AutoLogin], ServerInfo[MaxMuteWarnings], ServerInfo[DisableChat], ServerInfo[MustLogin], ServerInfo[MustRegister] );
		SendClientMessage(playerid,blue,string);
	}
	return 1;
}

dcmd_getinfo(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |: /getinfo [playerid]");
	    new player1, string[128];
	    player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		    new Float:player1health, Float:player1armour, playerip[128], Float:x, Float:y, Float:z, tmp2[256], file[256],
				year, month, day, P1Jailed[4], P1Frozen[4], P1Logged[4], P1Register[4], RegDate[256], TimesOn;

			GetPlayerHealth(player1,player1health);
			GetPlayerArmour(player1,player1armour);
	    	GetPlayerIp(player1, playerip, sizeof(playerip));
	    	GetPlayerPos(player1,x,y,z);
			getdate(year, month, day);
			format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(player1)));

			if(PlayerInfo[player1][Jailed] == 1) P1Jailed = "Yes"; else P1Jailed = "No";
			if(PlayerInfo[player1][Frozen] == 1) P1Frozen = "Yes"; else P1Frozen = "No";
			if(PlayerInfo[player1][LoggedIn] == 1) P1Logged = "Yes"; else P1Logged = "No";
			if(fexist(file)) P1Register = "Yes"; else P1Register = "No";
			if(dUserINT(PlayerName2(player1)).("LastOn")==0) tmp2 = "Never"; else tmp2 = dini_Get(file,"LastOn");
			if(strlen(dini_Get(file,"RegisteredDate")) < 3) RegDate = "n/a"; else RegDate = dini_Get(file,"RegisteredDate");
			TimesOn = dUserINT(PlayerName2(player1)).("TimesOnServer");

		    new Sum, Average, w;
			while (w < PING_MAX_EXCEEDS) {
				Sum += PlayerInfo[player1][pPing][w];
				w++;
			}
			Average = (Sum / PING_MAX_EXCEEDS);

	  		format(string, sizeof(string),"(Player Info)  ---====> Nome: %s  ID: %d <====---", PlayerName2(player1), player1);
			SendClientMessage(playerid,lightblue,string);
		  	format(string, sizeof(string),"Saude: %d  Colete: %d  Pontos: %d  Dinheiro: %d  Corpo: %d  IP: %s  Ping: %d  Ping Medio: %d",floatround(player1health),floatround(player1armour),
			GetPlayerScore(player1),GetPlayerCash(player1),GetPlayerSkin(player1),playerip,GetPlayerPing(player1), Average );
			SendClientMessage(playerid,red,string);
			format(string, sizeof(string),"Interior: %d  Mundo Virtual: %d  Nivel de Procurado: %d  X %0.1f  Y %0.1f  Z %0.1f", GetPlayerInterior(player1), GetPlayerVirtualWorld(player1), GetPlayerWantedLevel(player1), Float:x,Float:y,Float:z);
			SendClientMessage(playerid,orange,string);
			format(string, sizeof(string),"Vezes no Servidor: %d  Matou: %d  Morreu: %d  Media: %0.2f  NivelAdmin: %d", TimesOn, PlayerInfo[player1][Kills], PlayerInfo[player1][Deaths], Float:PlayerInfo[player1][Kills]/Float:PlayerInfo[player1][Deaths], PlayerInfo[player1][Level] );
			SendClientMessage(playerid,yellow,string);
			format(string, sizeof(string),"Registrado: %s  Loggado: %s  Preso: %s  Travado: %s", P1Register, P1Logged, P1Jailed, P1Frozen );
			SendClientMessage(playerid,green,string);
			format(string, sizeof(string),"Ultima jogada: %s  Data do registro: %s  Hoje: %d/%d/%d", tmp2, RegDate, day,month,year );
			SendClientMessage(playerid,COLOR_GREEN,string);

			if(IsPlayerInAnyVehicle(player1)) {
				new Float:VHealth, carid = GetPlayerVehicleID(playerid); GetVehicleHealth(carid,VHealth);
				format(string, sizeof(string),"VehicleID: %d  Modelo: %d  Nome: %s  Saude: %d",carid, GetVehicleModel(carid), VehicleNames[GetVehicleModel(carid)-400], floatround(VHealth) );
				SendClientMessage(playerid,COLOR_BLUE,string);
			}

			new slot, ammo, weap, Count, WeapName[24], WeapSTR[128], p; WeapSTR = "Armas: ";
			for (slot = 0; slot < 14; slot++) {	GetPlayerWeaponData(player1, slot, weap, ammo); if( ammo != 0 && weap != 0) Count++; }
			if(Count < 1) return SendClientMessage(playerid,lightblue,"Jogador nao tem armas");
			else {
				for (slot = 0; slot < 14; slot++)
				{
					GetPlayerWeaponData(player1, slot, weap, ammo);
					if (ammo > 0 && weap > 0)
					{
						GetWeaponName(weap, WeapName, sizeof(WeapName) );
						if (ammo == 65535 || ammo == 1) format(WeapSTR,sizeof(WeapSTR),"%s%s (1)",WeapSTR, WeapName);
						else format(WeapSTR,sizeof(WeapSTR),"%s%s (%d)",WeapSTR, WeapName, ammo);
						p++;
						if(p >= 5) { SendClientMessage(playerid, lightblue, WeapSTR); format(WeapSTR, sizeof(WeapSTR), "Armas: "); p = 0;
						} else format(WeapSTR, sizeof(WeapSTR), "%s,  ", WeapSTR);
					}
				}
				if(p <= 4 && p > 0) {
					string[strlen(string)-3] = '.';
				    SendClientMessage(playerid, lightblue, WeapSTR);
				}
			}
			return 1;
		} else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser administrador nivel 2 para usar este comando");
}

dcmd_disable(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) {
			SendClientMessage(playerid,red,"| USO |: /disable [antiswear / namekick / antispam / ping / readcmds / readpms /caps / admincmdmsgs");
			return SendClientMessage(playerid,red,"       /connectmsgs / autologin ]");
		}
	    new string[128], file[256]; format(file,sizeof(file),"ladmin/config/Config.ini");
		if(strcmp(params,"antiswear",true) == 0) {
			ServerInfo[AntiSwear] = 0;
			dini_IntSet(file,"AntiSwear",0);
			format(string,sizeof(string),"Administrador (a) %s has desativou Anti-Palavrão", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"namekick",true) == 0) {
			ServerInfo[NameKick] = 0;
			dini_IntSet(file,"NameKick",0);
			format(string,sizeof(string),"Administrador (a) %s desativou NameKick", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
	 	} else if(strcmp(params,"antispam",true) == 0)	{
			ServerInfo[AntiSpam] = 0;
			dini_IntSet(file,"AntiSpam",0);
			format(string,sizeof(string),"Administrador (a) %s desativou AntiSpam", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"ping",true) == 0)	{
			ServerInfo[MaxPing] = 0;
			dini_IntSet(file,"MaxPing",0);
			format(string,sizeof(string),"Administrador (a) %s desativou PingLimit", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"readcmds",true) == 0) {
			ServerInfo[ReadCmds] = 0;
			dini_IntSet(file,"ReadCMDs",0);
			format(string,sizeof(string),"Administrador (a) %s desativou leitura de comandos", PlayerName2(playerid));
			MessageToAdmins(blue,string);
		} else if(strcmp(params,"readpms",true) == 0) {
			ServerInfo[ReadPMs] = 0;
			dini_IntSet(file,"ReadPMs",0);
			format(string,sizeof(string),"Administrador (a) %s desativou leitura de PMs", PlayerName2(playerid));
			MessageToAdmins(blue,string);
  		} else if(strcmp(params,"caps",true) == 0)	{
			ServerInfo[NoCaps] = 1;
			dini_IntSet(file,"NoCaps",1);
			format(string,sizeof(string),"Administrador (a) %s desativou letras maiusculas no chat", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"admincmdmsgs",true) == 0) {
			ServerInfo[AdminCmdMsg] = 0;
			dini_IntSet(file,"AdminCMDMessages",0);
			format(string,sizeof(string),"Administrador (a) %s desativou mensagens de comandos admin", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else if(strcmp(params,"connectmsgs",true) == 0)	{
			ServerInfo[ConnectMessages] = 0;
			dini_IntSet(file,"ConnectMessages",0);
			format(string,sizeof(string),"Administrador (a) %s desativou notificacoes de conexao", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else if(strcmp(params,"autologin",true) == 0)	{
			ServerInfo[AutoLogin] = 0;
			dini_IntSet(file,"AutoLogin",0);
			format(string,sizeof(string),"Administrador (a) %s desativou auto-login", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else {
			SendClientMessage(playerid,red,"| USO |: /disable [antiswear / namekick / antispam / ping / readcmds / readpms /caps /cmdmsg ]");
		} return 1;
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_enable(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) {
			SendClientMessage(playerid,red,"| USO |: /enable [antiswear / namekick / antispam / ping / readcmds / readpms /caps / admincmdmsgs");
			return SendClientMessage(playerid,red,"       /connectmsgs / autologin ]");
		}
	    new string[128], file[256]; format(file,sizeof(file),"ladmin/config/Config.ini");
		if(strcmp(params,"antiswear",true) == 0) {
			ServerInfo[AntiSwear] = 1;
			dini_IntSet(file,"AntiSwear",1);
			format(string,sizeof(string),"Administrador (a) %s ativou anti-palavrao", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"namekick",true) == 0)	{
			ServerInfo[NameKick] = 1;
			format(string,sizeof(string),"Administrador (a) %s ativou namekick", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
 		} else if(strcmp(params,"antispam",true) == 0)	{
			ServerInfo[AntiSpam] = 1;
			dini_IntSet(file,"AntiSpam",1);
			format(string,sizeof(string),"Administrador (a) %s ativou AntiSpam", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"ping",true) == 0)	{
			ServerInfo[MaxPing] = 800;
			dini_IntSet(file,"MaxPing",800);
			format(string,sizeof(string),"Administrador (a) %s ativou PingLimit", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"readcmds",true) == 0)	{
			ServerInfo[ReadCmds] = 1;
			dini_IntSet(file,"ReadCMDs",1);
			format(string,sizeof(string),"Administrador (a) %s ativou leitura de comandos", PlayerName2(playerid));
			MessageToAdmins(blue,string);
		} else if(strcmp(params,"readpms",true) == 0) {
			ServerInfo[ReadPMs] = 1;
			dini_IntSet(file,"ReadPMs",1);
			format(string,sizeof(string),"Administrador (a) %s ativou leitura de PMs", PlayerName2(playerid));
			MessageToAdmins(blue,string);
		} else if(strcmp(params,"caps",true) == 0)	{
			ServerInfo[NoCaps] = 0;
			dini_IntSet(file,"NoCaps",0);
			format(string,sizeof(string),"Administrador (a) %s permitiu letras maiusculas no chat", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"admincmdmsgs",true) == 0)	{
			ServerInfo[AdminCmdMsg] = 1;
			dini_IntSet(file,"AdminCmdMessages",1);
			format(string,sizeof(string),"Administrador (a) %s ativou mensagens de comandos de admin", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else if(strcmp(params,"connectmsgs",true) == 0) {
			ServerInfo[ConnectMessages] = 1;
			dini_IntSet(file,"ConnectMessages",1);
			format(string,sizeof(string),"Administrador (a) %s ativou notificacoes de conexao", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else if(strcmp(params,"autologin",true) == 0) {
			ServerInfo[AutoLogin] = 1;
			dini_IntSet(file,"AutoLogin",1);
			format(string,sizeof(string),"Administrador (a) %s ativou auto-login", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else {
			SendClientMessage(playerid,red,"| USO |: /enable [antiswear / namekick / antispam / ping / readcmds / readpms /caps /cmdmsg ]");
		} return 1;
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lweaps(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		GivePlayerWeapon(playerid,28,1000); GivePlayerWeapon(playerid,31,1000); GivePlayerWeapon(playerid,34,1000);
		GivePlayerWeapon(playerid,38,1000); GivePlayerWeapon(playerid,16,1000);	GivePlayerWeapon(playerid,42,1000);
		GivePlayerWeapon(playerid,14,1000); GivePlayerWeapon(playerid,46,1000);	GivePlayerWeapon(playerid,9,1);
		GivePlayerWeapon(playerid,24,1000); GivePlayerWeapon(playerid,26,1000); return 1;
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_countdown(playerid,params[]) {
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        if(CountDown == -1) {
			CountDown = 6;
			SetTimer("countdown",1000,0);
			return CMDMessageToAdmins(playerid,"COUNTDOWN");
		} else return SendClientMessage(playerid,red,"| ERRO |: Contagem em progresso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_duel(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp) || !IsNumeric(tmp2)) {
			SendClientMessage(playerid, red, "| USO |: /duel [player1 id] [player2 id] [location]   (Locations: 1, 2, 3]");
			return SendClientMessage(playerid, red, "Se a localidade nao for especificada, o duelo comecara onde eles estao");
		}
		new player1 = strval(tmp), player2 = strval(tmp2), location, string[128];
		if(!strlen(tmp3)) location = 0; else location = strval(tmp3);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
		if(PlayerInfo[player2][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
		if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
 		 	if(IsPlayerConnected(player2) && player2 != INVALID_PLAYER_ID) {
				if(InDuel[player1] == 1) return SendClientMessage(playerid,red,"| ERRO |: Jogador 1 ja esta no duelo");
				if(InDuel[player2] == 1) return SendClientMessage(playerid,red,"| ERRO |: Jogador 2 ja esta no duelo");
		
				if(location == 1)   {
					SetPlayerInterior(player1,16); SetPlayerPos(player1,-1404.067, 1270.3706, 1042.8672);
					SetPlayerInterior(player2,16); SetPlayerPos(player2,-1395.067, 1261.3706, 1042.8672);
				} else if(location == 2)   {
					SetPlayerInterior(player1,0); SetPlayerPos(player1,1353.407,2188.155,11.02344); 
					SetPlayerInterior(player2,0); SetPlayerPos(player2,1346.255,2142.843,11.01563); 
				} else if(location == 3)   {
					SetPlayerInterior(player1,10); SetPlayerPos(player1,-1041.037,1078.729,1347.678); SetPlayerFacingAngle(player1,135);
					SetPlayerInterior(player2,10); SetPlayerPos(player2,-1018.061,1052.502,1346.327); SetPlayerFacingAngle(player2,45);
				}
				InDuel[player1] = 1;
				InDuel[player2] = 1;
			CMDMessageToAdmins(playerid,"DUEL");
				cdt[player1] = 6;
				SetTimerEx("Duel",1000,0,"dd", player1, player2);
				format(string, sizeof(string), "Administrador (a) \"%s\" iniciou um duelo entre \"%s\" e \"%s\" ", pName(playerid), pName(player1), pName(player2) );
				SendClientMessage(player1, blue, string); SendClientMessage(player2, blue, string);
				return SendClientMessage(playerid, blue, string);
 		 	} else return SendClientMessage(playerid, red, "Jogador 2 nao conectado");
		} else return SendClientMessage(playerid, red, "Jogador 1 nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lammo(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3) {
		MaxAmmo(playerid);
		return CMDMessageToAdmins(playerid,"LAMMO");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_vr(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if (IsPlayerInAnyVehicle(playerid)) {
			SetVehicleHealth(GetPlayerVehicleID(playerid),1250.0);
			return SendClientMessage(playerid,blue,"Veiculo Fixo");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce nao esta no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_fix(playerid,params[])
{
	return dcmd_vr(playerid, params);
}
/*
dcmd_repair(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if (IsPlayerInAnyVehicle(playerid)) {
			GetPlayerPos(playerid,Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]);
			GetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[playerid][3]);
			SetPlayerCameraPos(playerid, 1929.0, 2137.0, 11.0);
			SetPlayerCameraLookAt(playerid,1935.0, 2138.0, 11.5);
			SetVehiclePos(GetPlayerVehicleID(playerid), 1974.0,2162.0,11.0);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), -90);
			SetTimerEx("RepairCar",5000,0,"i",playerid);
	    	return SendClientMessage(playerid,blue,"Seu carro estara pronto em 5 segundos...");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce nao esta no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
*/
/*
dcmd_ltune(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3) {
		if(IsPlayerInAnyVehicle(playerid)) {
        new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
        switch(LModel)
		{
			case 441,581,523,462,521,463,522,461,448,468,586,509,481,510,472,473,493,595,484,430,453,452,446,454,590,569,537,538,570,449,513,520,476:
			return SendClientMessage(playerid,red,"| ERRO |: Voce nao pode tunar este veiculo");
		}
//       CMDMessageToAdmins(playerid,"LTUNE");
//		SetVehicleHealth(LVehicleID,2000.0);
		TuneLCar(LVehicleID);
		return PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce nao esta no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser nivel 0 para usar este comando");
}
*/
dcmd_lhy(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if(IsPlayerInAnyVehicle(playerid)) {
        new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
        switch(LModel)
		{
			case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
			return SendClientMessage(playerid,red,"| ERRO |: Voce nao pode tunar este veiculo");
		}
        AddVehicleComponent(LVehicleID, 1087);
		return PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce nao esta no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser nivel 2 para usar este comando");
}

dcmd_lcar(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,415);
		CMDMessageToAdmins(playerid,"LCAR");
			return SendClientMessage(playerid,blue,"Divirta-se com seu novo carro!");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lbike(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,522);
		CMDMessageToAdmins(playerid,"LBIKE");
			return SendClientMessage(playerid,blue,"Divirta-se com sua nova moto!");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lheli(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,487);
		CMDMessageToAdmins(playerid,"LHELI");
			return SendClientMessage(playerid,blue,"Divirta-se com seu novo Helicoptero!");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lboat(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,493);
		CMDMessageToAdmins(playerid,"LBOAT");
			return SendClientMessage(playerid,blue,"Divirta-se com seu novo bote!");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lplane(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,513);
		CMDMessageToAdmins(playerid,"LPLANE");
			return SendClientMessage(playerid,blue,"Divirta-se com seu novo aviao!");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lnos(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if(IsPlayerInAnyVehicle(playerid)) {
	        switch(GetVehicleModel( GetPlayerVehicleID(playerid) )) {
				case 441,581,523,462,521,463,522,461,448,468,586,509,481,510,472,473,493,595,484,430,453,452,446,454,590,569,537,538,570,449,513,520,476:
				return SendClientMessage(playerid,red,"| ERRO |: Voce nao pode tunar este veiculo");
			}
	        AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
			return PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar no veiculo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_linkcar(playerid,params[]) {
	#pragma unused params
	if(IsPlayerInAnyVehicle(playerid)) {
    	LinkVehicleToInterior(GetPlayerVehicleID(playerid),GetPlayerInterior(playerid));
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid),GetPlayerVirtualWorld(playerid));
	    return SendClientMessage(playerid,lightblue, "Este veiculo esta em seu mundo virtual e interior");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar no veiculo");
 }

dcmd_car(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index); tmp3 = strtok(params,Index);
	    if(!strlen(tmp)) return SendClientMessage(playerid, red, "| USO |: /car [Modelid/Name] [colour1] [colour2]");
		new car, colour1, colour2, string[128];
   		if(!IsNumeric(tmp)) car = GetVehicleModelIDFromName(tmp); else car = strval(tmp);
		if(car < 400 || car > 611) return  SendClientMessage(playerid, red, "| ERRO |: Modelo invalido");
		if(!strlen(tmp2)) colour1 = random(126); else colour1 = strval(tmp2);
		if(!strlen(tmp3)) colour2 = random(126); else colour2 = strval(tmp3);
		if(PlayerInfo[playerid][pCar] != -1 && !IsPlayerAdmin(playerid) ) CarDeleter(PlayerInfo[playerid][pCar]);
		new LVehicleID,Float:X,Float:Y,Float:Z, Float:Angle,int1;	GetPlayerPos(playerid, X,Y,Z);	GetPlayerFacingAngle(playerid,Angle);   int1 = GetPlayerInterior(playerid);
		LVehicleID = CreateVehicle(car, X+3,Y,Z, Angle, colour1, colour2, -1); LinkVehicleToInterior(LVehicleID,int1);
		PlayerInfo[playerid][pCar] = LVehicleID;
		SetVehicleVirtualWorld(LVehicleID, GetPlayerVirtualWorld(playerid));
	CMDMessageToAdmins(playerid,"CAR");
		format(string, sizeof(string), "%s fez nascer \"%s\" (Modelo:%d) cor (%d, %d), at %0.2f, %0.2f, %0.2f", pName(playerid), VehicleNames[car-400], car, colour1, colour2, X, Y, Z);
        SaveToFile("CarSpawns",string);
		format(string, sizeof(string), "Voce fez nascer um \"%s\" (Modelo:%d) cor (%d, %d)", VehicleNames[car-400], car, colour1, colour2);
		return SendClientMessage(playerid,lightblue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_carhealth(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /carhealth [playerid] [amount]");
		new player1 = strval(tmp), health = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
            if(IsPlayerInAnyVehicle(player1)) {
		   //    	CMDMessageToAdmins(playerid,"CARHEALTH");
				format(string, sizeof(string), "Voce definiu a saude do veiculo de \"%s's\" para '%d", pName(player1), health); SendClientMessage(playerid,blue,string);
				if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" modificou a saude de seu veiculo para '%d'", pName(playerid), health); SendClientMessage(player1,blue,string); }
   				return SetVehicleHealth(GetPlayerVehicleID(player1), health);
			} else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao esta no carro");
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_carcolour(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index); tmp3 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !strlen(tmp3) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /carcolour [playerid] [colour1] [colour2]");
		new player1 = strval(tmp), colour1, colour2, string[128];
		if(!strlen(tmp2)) colour1 = random(126); else colour1 = strval(tmp2);
		if(!strlen(tmp3)) colour2 = random(126); else colour2 = strval(tmp3);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
            if(IsPlayerInAnyVehicle(player1)) {
		   //    	CMDMessageToAdmins(playerid,"CARCOLOUR");
				format(string, sizeof(string), "You have changed the colour of \"%s's\" %s to '%d,%d'", pName(player1), VehicleNames[GetVehicleModel(GetPlayerVehicleID(player1))-400], colour1, colour2 ); SendClientMessage(playerid,blue,string);
				if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" trocou a cor para %s to '%d,%d''", pName(playerid), VehicleNames[GetVehicleModel(GetPlayerVehicleID(player1))-400], colour1, colour2 ); SendClientMessage(player1,blue,string); }
   				return ChangeVehicleColor(GetPlayerVehicleID(player1), colour1, colour2);
			} else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao esta no carro");
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_god(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 4 || IsPlayerAdmin(playerid)) {
    	if(PlayerInfo[playerid][God] == 0)	{
   	    	PlayerInfo[playerid][God] = 1;
    	    SetPlayerHealth(playerid,100000);
			//GivePlayerWeapon(playerid,16,50000); GivePlayerWeapon(playerid,26,50000);
           	SendClientMessage(playerid,green,"GODMODE ON");
			return CMDMessageToAdmins(playerid,"GOD");
		} else {
   	        PlayerInfo[playerid][God] = 0;
       	    SendClientMessage(playerid,red,"GODMODE OFF");
        	SetPlayerHealth(playerid, 100);
		} return 1; //GivePlayerWeapon(playerid,35,0);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_sgod(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
   		if(PlayerInfo[playerid][God] == 0)	{
        	PlayerInfo[playerid][God] = 1;
	        SetPlayerHealth(playerid,100000);
			GivePlayerWeapon(playerid,16,50000); GivePlayerWeapon(playerid,26,50000);
            return SendClientMessage(playerid,green,"GODMODE ON");
		} else	{
   	        PlayerInfo[playerid][God] = 0;
            SendClientMessage(playerid,red,"GODMODE OFF");
	        SetPlayerHealth(playerid, 100); return GivePlayerWeapon(playerid,35,0);	}
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_godcar(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 4 || IsPlayerAdmin(playerid)) {
		if(IsPlayerInAnyVehicle(playerid)) {
	    	if(PlayerInfo[playerid][GodCar] == 0) {
        		PlayerInfo[playerid][GodCar] = 1;
   			CMDMessageToAdmins(playerid,"GODCAR");
            	return SendClientMessage(playerid,green,"GODCARMODE ON");
			} else {
	            PlayerInfo[playerid][GodCar] = 0;
    	        return SendClientMessage(playerid,red,"GODCARMODE OFF"); }
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar no carro para usar este comando");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_die(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 4 || IsPlayerAdmin(playerid)) {
		new Float:x, Float:y, Float:z ;
		GetPlayerPos( playerid, Float:x, Float:y, Float:z );
		CreateExplosion(Float:x+10, Float:y, Float:z, 8,10.0);
		CreateExplosion(Float:x-10, Float:y, Float:z, 8,10.0);
		CreateExplosion(Float:x, Float:y+10, Float:z, 8,10.0);
		CreateExplosion(Float:x, Float:y-10, Float:z, 8,10.0);
		CreateExplosion(Float:x+10, Float:y+10, Float:z, 8,10.0);
		CreateExplosion(Float:x-10, Float:y+10, Float:z, 8,10.0);
		return CreateExplosion(Float:x-10, Float:y-10, Float:z, 8,10.0);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_getid(playerid,params[]) {
	if(!strlen(params)) return SendClientMessage(playerid,blue,"Uso correto: /getid [part of nick]");
	new found, string[128], playername[MAX_PLAYER_NAME];
	format(string,sizeof(string),"Procurou por: \"%s\" ",params);
	SendClientMessage(playerid,blue,string);
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
	  		GetPlayerName(i, playername, MAX_PLAYER_NAME);
			new namelen = strlen(playername);
			new bool:searched=false;
	    	for(new pos=0; pos <= namelen; pos++)
			{
				if(searched != true)
				{
					if(strfind(playername,params,true) == pos)
					{
		                found++;
						format(string,sizeof(string),"%d. %s (ID %d)",found,playername,i);
						SendClientMessage(playerid, green ,string);
						searched = true;
					}
				}
			}
		}
	}
	if(found == 0) SendClientMessage(playerid, lightblue, "Nao ha jogadores com este nick");
	return 1;
}

dcmd_grupo(playerid,params[]){
if(!strlen(params)) return SendClientMessage(playerid, COLOUR_ERRO,"| USO |: /grupo <id do grupo>");
if(!IsNumeric(params)) return SendClientMessage(playerid,COLOUR_ERRO,"| ERRO |: ID de grupo inválida (Use de 1 até 99999999)");
new param=strval(params);
if(param >= 99999999 || param < 1) return SendClientMessage(playerid,COLOUR_ERRO,"| ERRO |: ID de grupo inválida");
new string[128];
format(string, sizeof(string), "*** Você acabou de entrar no grupo: {FFFFFF}%i", param);
SendClientMessage(playerid, COLOUR_INFORMACAO, string);
SendClientMessage(playerid, COLOUR_INFORMACAO, "** Para usar o chat do grupo use o . (ponto) antes da frase!");
SendClientMessage(playerid, COLOUR_INFORMACAO, "** Para sair do grupo digite: {FFFFFF}/gruposair");
SendClientMessage(playerid, COLOUR_INFORMACAO, "** Para saber quantos players online tem no grupo: {FFFFFF}/grupoons");
SetPVarInt(playerid, "GrupoChat", param);
return 1;}


dcmd_asay(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
 		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /asay [text]");
		new string[128]; format(string, sizeof(string), "{00FFE1}(=>ADM<=){FF0000} %s: %s", PlayerName2(playerid), params[0] );
		return SendClientMessageToAll(COLOR_PINK,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_vipsay(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][VIP] >= 1) {
 		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /vipasay [text]");
		new string[128]; format(string, sizeof(string), "{F0F404}[=>VIP<=] {08CC46}%s:{F0F404} %s", PlayerName2(playerid), params[0] );
	//	CMDMessageToVips(playerid,"VIPASAY");
		return SendClientMessageToAll(COLOR_PINK,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não é VIP. compre usando {F0F404}/PLANOSVIP !");
}

dcmd_setping(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
 		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setping [ping]   Set to 0 to disable");
	    new string[128], ping = strval(params);
		ServerInfo[MaxPing] = ping;
	CMDMessageToAdmins(playerid,"SETPING");
		new file[256]; format(file,sizeof(file),"ladmin/config/Config.ini");
		dini_IntSet(file,"MaxPing",ping);
		for (new i = 0; i < MAX_PLAYERS; i++) PlayerPlaySound(i,1057,0.0,0.0,0.0);
		if(ping == 0) format(string,sizeof(string),"Administrador (a) %s desativou ping maximo", PlayerName2(playerid), ping);
		else format(string,sizeof(string),"Administrador (a) %s definiu o ping maximo para %d", PlayerName2(playerid), ping);
		return SendClientMessageToAll(blue,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_ping(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /ping [playerid]");
		new player1 = strval(params), string[128];
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		    new Sum, Average, x;
			while (x < PING_MAX_EXCEEDS) {
				Sum += PlayerInfo[player1][pPing][x];
				x++;
			}
			Average = (Sum / PING_MAX_EXCEEDS);
			format(string, sizeof(string), "\"%s\" (id %d) Ping Medio: %d   (Ultimos pings: %d, %d, %d, %d)", PlayerName2(player1), player1, Average, PlayerInfo[player1][pPing][0], PlayerInfo[player1][pPing][1], PlayerInfo[player1][pPing][2], PlayerInfo[player1][pPing][3] );
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_highlight2(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |: /highlight [playerid]");
	    new player1, playername[MAX_PLAYER_NAME], string[128];
	    player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		 	GetPlayerName(player1, playername, sizeof(playername));
	 	    if(PlayerInfo[player1][blip] == 0) {
			CMDMessageToAdmins(playerid,"HIGHLIGHT2");
				PlayerInfo[player1][pColour] = GetPlayerColor(player1);
				PlayerInfo[player1][blip] = 1;
				BlipTimer[player1] = SetTimerEx("HighLight2", 250, 1, "i", player1);
				format(string,sizeof(string),"Voce destacou %s's", playername);
			} else {
				KillTimer( BlipTimer[player1] );
				PlayerInfo[player1][blip] = 0;
				SetPlayerColor(player1, PlayerInfo[player1][pColour] );
				format(string,sizeof(string),"Voce parou de destacar %s's", playername);
			}
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_highlight(playerid,params[]) {
#pragma unused params
    if(PlayerInfo[playerid][VIP] >= 3 && PlayerInfo[playerid][Level] >= 1) {
	 	    if(PlayerInfo[playerid][blip] == 0) {
				PlayerInfo[playerid][pColour] = GetPlayerColor(playerid);
				PlayerInfo[playerid][blip] = 1;
				BlipTimer[playerid] = SetTimerEx("HighLight", 250, 1, "i", playerid);
				SendClientMessage(playerid,green,"[!]: Você se destacou-se ");
			} else {
				KillTimer( BlipTimer[playerid] );
				PlayerInfo[playerid][blip] = 0;
				SetPlayerColor(playerid, PlayerInfo[playerid][pColour] );
				SendClientMessage(playerid,green,"[!]: Você parou de se destacar ");

			}
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;
}
			
dcmd_setgravitymm(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)||!(strval(params)<=50&&strval(params)>=-50)) return SendClientMessage(playerid,red,"| USO |: /setgravity <-50.0 - 50.0>");
    //    CMDMessageToAdmins(playerid,"SETGRAVITY");
		new string[128],adminname[MAX_PLAYER_NAME]; GetPlayerName(playerid, adminname, sizeof(adminname)); new Float:Gravity = floatstr(params);format(string,sizeof(string),"Admnistrator %s has set the gravity to %f",adminname,Gravity);
		SetGravity(Gravity); return SendClientMessageToAll(blue,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lcredits(playerid,params[]) {
	#pragma unused params
	return SendClientMessage(playerid,green,"LAdmin. Adminscript for sa-mp 0.3.7 Created by 	 - DEAN & i[T]une$. Version: 6. Released: /2015");
}

dcmd_serverinfo(playerid,params[]) {
	#pragma unused params
    new TotalVehicles = CreateVehicle(411, 0, 0, 0, 0, 0, 0, 1000);    DestroyVehicle(TotalVehicles);
	new numo = CreateObject(1245,0,0,1000,0,0,0);	DestroyObject(numo);
	new nump = CreatePickup(371,2,0,0,1000);	DestroyPickup(nump);
	new gz = GangZoneCreate(3,3,5,5);	GangZoneDestroy(gz);

	new model[250], nummodel;
	for(new i=1;i<TotalVehicles;i++) model[GetVehicleModel(i)-400]++;
	for(new i=0;i<250;i++)	if(model[i]!=0)	nummodel++;

	new string[256];
	format(string,sizeof(string),"Server Info: [ Jogadores conectados: %d || Maximo: %d ] [Media %0.2f ]",ConnectedPlayers(),GetMaxPlayers(),Float:ConnectedPlayers() / Float:GetMaxPlayers() );
	SendClientMessage(playerid,green,string);
	format(string,sizeof(string),"Server Info: [ Veiculos: %d || Modelos %d || Jogadores em veculos: %d || Carro %d / Moto %d ]",TotalVehicles-1,nummodel, InVehCount(),InCarCount(),OnBikeCount() );
	SendClientMessage(playerid,green,string);
	format(string,sizeof(string),"Server Info: [ Objetos: %d || Coletas %d || Gangzones %d ]",numo-1, nump, gz);
	SendClientMessage(playerid,green,string);
	format(string,sizeof(string),"Server Info: [ Jogadores na cadeia %d || Jogadores travados %d || Calados %d ]",JailedPlayers(),FrozenPlayers(), MutedPlayers() );
	return SendClientMessage(playerid,green,string);
}

dcmd_tela(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
    	if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |: /tela <text>");
    	if(StringTXTBugado(params)) return SendClientMessage(playerid,red,"| ERRO |: Seu texto está com erros e foi bloqueado para evitar crash's");
    CMDMessageToAdmins(playerid,"TELA");
		return GameTextForAll(params,5000,3);
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_telaid(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /screen [playerid] [texto]");
    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
		player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
			GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
	CMDMessageToAdmins(playerid,"SCREEN");
			format(string,sizeof(string),"Administrador %s mandou a você uma mensagem de tela",adminname);	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"Você enviou a %s uma mensagem de tela (%s)", playername, params[2]); SendClientMessage(playerid,blue,string);
			return GameTextForPlayer(player1, params[2],4000,3);
		} else return SendClientMessage(playerid, red, "Jogador não conectado ou é você mesmo ou é um admin com nível alto");
	} else return SendClientMessage(playerid,red,"ERRO: Você não tem nível alto suficiente para usar este comando");
}



dcmd_announce2(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 3 || IsPlayerAdmin(playerid)) {
        new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index) ,tmp3 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!strlen(tmp3)) return SendClientMessage(playerid,red,"| USO |: /announce2 <style> <time> <text>");
		if(!(strval(tmp) >= 0 && strval(tmp) <= 6) || strval(tmp) == 2)	return SendClientMessage(playerid,red,"| ERRO |: Estilo invalido. Use: 0 - 6");
		if(StringTXTBugado(params)) return SendClientMessage(playerid,red,"| ERRO |: Seu texto está com erros e foi bloqueado para evitar crash's");
	CMDMessageToAdmins(playerid,"ANNOUNCE2");
		return GameTextForAll(params[(strlen(tmp)+strlen(tmp2)+2)], strval(tmp2), strval(tmp));
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lslowmo(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		new Float:x, Float:y, Float:z; GetPlayerPos(playerid, x, y, z); CreatePickup(1241, 4, x, y, z);
		return CMDMessageToAdmins(playerid,"LSLOWMO");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
/*
dcmd_jetpack(playerid,params[]) {
    if(!strlen(params))	{
    	if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
			SendClientMessage(playerid,blue,"Jetpack criado.");
		CMDMessageToAdmins(playerid,"JETPACK");
			return SetPlayerSpecialAction(playerid, 2);
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else {
	    new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
    	player1 = strval(params);
		if(PlayerInfo[playerid][Level] >= 4)	{
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid)	{
				CMDMessageToAdmins(playerid,"JETPACK");		SetPlayerSpecialAction(player1, 2);
				GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
				format(string,sizeof(string),"Administrador (a) \"%s\" te deu um jetpack",adminname); SendClientMessage(player1,blue,string);
				format(string,sizeof(string),"Voce deu a %s um jetpack!", playername);
				return SendClientMessage(playerid,blue,string);
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado or is yourself");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}
}
*/



dcmd_aflip(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) {
		    if(IsPlayerInAnyVehicle(playerid)) {
			new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle; GetPlayerPos(playerid, X, Y, Z); VehicleID = GetPlayerVehicleID(playerid);
			GetVehicleZAngle(VehicleID, Angle);	SetVehiclePos(VehicleID, X, Y, Z); SetVehicleZAngle(VehicleID, Angle); SetVehicleHealth(VehicleID,1000.0);
			CMDMessageToAdmins(playerid,"AFLIP"); return SendClientMessage(playerid, blue,"Carro virado. Pode usar: /aflip [playerid]");
			} else return SendClientMessage(playerid,red,"| ERRO |: Voce nao esta no veiculo. Voce pode usar: /aflip [playerid]");
		}
	    new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
	    player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
			CMDMessageToAdmins(playerid,"AFLIP");
			if (IsPlayerInAnyVehicle(player1)) {
				new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle; GetPlayerPos(player1, X, Y, Z); VehicleID = GetPlayerVehicleID(player1);
				GetVehicleZAngle(VehicleID, Angle);	SetVehiclePos(VehicleID, X, Y, Z); SetVehicleZAngle(VehicleID, Angle); SetVehicleHealth(VehicleID,1000.0);
				CMDMessageToAdmins(playerid,"AFLIP");
				GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
				format(string,sizeof(string),"Administrador (a) %s desvirou seu veiculo",adminname); SendClientMessage(player1,blue,string);
				format(string,sizeof(string),"Voce desvirou o veiculo de %s's", playername);
				return SendClientMessage(playerid, blue,string);
			} else return SendClientMessage(playerid,red,"| ERRO |: Jogador fora do carro");
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado or is yourself");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_destroycar(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 5) return EraseVehicle(GetPlayerVehicleID(playerid));
	else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
/*
dcmd_ltc(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if(!IsPlayerInAnyVehicle(playerid)) {
			if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
			new Float:X,Float:Y,Float:Z,Float:Angle,LVehicleIDt;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
	        LVehicleIDt = CreateVehicle(560,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0); CMDMessageToAdmins(playerid,"LTunedCar");	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);
			AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
		    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
		    AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,0);
	   	   	SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
			return PlayerInfo[playerid][pCar] = LVehicleIDt;
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce ja esta no carro");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
*/
dcmd_warp(playerid,params[])
{
	return dcmd_teleplayer(playerid,params);
}

dcmd_teleplayer(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 3 || IsPlayerAdmin(playerid)) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /teleplayer [playerid] to [playerid]");
		new player1 = strval(tmp), player2 = strval(tmp2), string[128], Float:plocx,Float:plocy,Float:plocz;
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
 		 	if(IsPlayerConnected(player2) && player2 != INVALID_PLAYER_ID) {
	 		 CMDMessageToAdmins(playerid,"TELEPLAYER");
				GetPlayerPos(player2, plocx, plocy, plocz);
				new intid = GetPlayerInterior(player2);	SetPlayerInterior(player1,intid);
				SetPlayerVirtualWorld(player1,GetPlayerVirtualWorld(player2));
				if (GetPlayerState(player1) == PLAYER_STATE_DRIVER)
				{
					new VehicleID = GetPlayerVehicleID(player1);
					SetVehiclePos(VehicleID, plocx, plocy+4, plocz); LinkVehicleToInterior(VehicleID,intid);
					SetVehicleVirtualWorld(VehicleID, GetPlayerVirtualWorld(player2) );
				}
				else SetPlayerPos(player1,plocx,plocy+2, plocz);
				format(string,sizeof(string),"Administrador (a) \"%s\" se teleportou de \"%s\" para \"%s's\"", pName(playerid), pName(player1), pName(player2) );
				SendClientMessage(player1,blue,string); SendClientMessage(player2,blue,string);
				format(string,sizeof(string),"Voce se teleportou de \"%s\" para \"%s's\"", pName(player1), pName(player2) );
 		 	    return SendClientMessage(playerid,blue,string);
 		 	} else return SendClientMessage(playerid, red, "Jogador 2 nao conectado");
		} else return SendClientMessage(playerid, red, "Jogador 1 nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_ir(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 3 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |: /ir [playerid]");
	    new player1, string[128];
		if(!IsNumeric(params)) player1 = ReturnPlayerID(params);
	   	else player1 = strval(params);
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
	CMDMessageToAdmins(playerid,"IR");
			new Float:x, Float:y, Float:z;	GetPlayerPos(player1,x,y,z); SetPlayerInterior(playerid,GetPlayerInterior(player1));
			SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(player1));
			if(GetPlayerState(playerid) == 2) {
				SetVehiclePos(GetPlayerVehicleID(playerid),x+3,y,z);	LinkVehicleToInterior(GetPlayerVehicleID(playerid),GetPlayerInterior(player1));
				SetVehicleVirtualWorld(GetPlayerVehicleID(playerid),GetPlayerVirtualWorld(player1));
			} else SetPlayerPos(playerid,x+2,y,z);
			format(string,sizeof(string),"Voce se teleportou para \"%s\"", pName(player1));
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_vgoto(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |: /vgoto [vehicleid]");
	    new player1, string[128];
	    player1 = strval(params);
	CMDMessageToAdmins(playerid,"VGOTO");
		new Float:x, Float:y, Float:z;	GetVehiclePos(player1,x,y,z);
		SetPlayerVirtualWorld(playerid,GetVehicleVirtualWorld(player1));
		if(GetPlayerState(playerid) == 2) {
			SetVehiclePos(GetPlayerVehicleID(playerid),x+3,y,z);
			SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetVehicleVirtualWorld(player1) );
		} else SetPlayerPos(playerid,x+2,y,z);
		format(string,sizeof(string),"Voce se teleportou para o veiculoid: %d", player1);
		return SendClientMessage(playerid,blue,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_vget(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 3 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |: /vget [vehicleid]");
	    new player1, string[128];
	    player1 = strval(params);
	CMDMessageToAdmins(playerid,"VGET");
		new Float:x, Float:y, Float:z;	GetPlayerPos(playerid,x,y,z);
		SetVehiclePos(player1,x+3,y,z);
		SetVehicleVirtualWorld(player1,GetPlayerVirtualWorld(playerid));
		format(string,sizeof(string),"Voce adquiriu o carro %d para sua localidade", player1);
		return SendClientMessage(playerid,blue,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lgoto(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
		new Float:x, Float:y, Float:z;
        new tmp[256], tmp2[256], tmp3[256];
		new string[128], Index;	tmp = strtok(params,Index); tmp2 = strtok(params,Index); tmp3 = strtok(params,Index);
    	if(!strlen(tmp) || !strlen(tmp2) || !strlen(tmp3)) return SendClientMessage(playerid,red,"| USO |: /lgoto [x] [y] [z]");
	    x = strval(tmp);		y = strval(tmp2);		z = strval(tmp3);
	CMDMessageToAdmins(playerid,"LGOTO");
		if(GetPlayerState(playerid) == 2) SetVehiclePos(GetPlayerVehicleID(playerid),x,y,z);
		else SetPlayerPos(playerid,x,y,z);
		format(string,sizeof(string),"Voce se teleportou para %f, %f, %f", x,y,z); return SendClientMessage(playerid,blue,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_givecar(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 3 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |: /givecar [playerid]");
	    new player1 = strval(params), playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
	    if(IsPlayerInAnyVehicle(player1)) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja tem um carro");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
		CMDMessageToAdmins(playerid,"GIVECAR");
			new Float:x, Float:y, Float:z;	GetPlayerPos(player1,x,y,z);
			CarSpawner(player1,415);
			GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
			format(string,sizeof(string),"Administrador (a) %s te deu um carro",adminname);	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"Voce deu um carro para %s", playername); return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado or is yourself");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_gethere(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /gethere [playerid]");
    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
		player1 = strval(params);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
		CMDMessageToAdmins(playerid,"GETHERE");
			new Float:x, Float:y, Float:z;	GetPlayerPos(playerid,x,y,z); SetPlayerInterior(player1,GetPlayerInterior(playerid));
			SetPlayerVirtualWorld(player1,GetPlayerVirtualWorld(playerid));
			if(GetPlayerState(player1) == 2)	{
			    new VehicleID = GetPlayerVehicleID(player1);
				SetVehiclePos(VehicleID,x+3,y,z);   LinkVehicleToInterior(VehicleID,GetPlayerInterior(playerid));
				SetVehicleVirtualWorld(GetPlayerVehicleID(player1),GetPlayerVirtualWorld(playerid));
			} else SetPlayerPos(player1,x+2,y,z);
			GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
			format(string,sizeof(string),"Voce se teleportou para o setor administrativo: %s's",adminname);	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"Voce se teleportou para seu setor administrativo", playername); return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado or is yourself");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_trazer(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 3|| IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /trazer [playerid]");
    	new player1, string[128];
		if(!IsNumeric(params)) player1 = ReturnPlayerID(params);
	   	else player1 = strval(params);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
	CMDMessageToAdmins(playerid,"TRAZER");
			new Float:x, Float:y, Float:z;	GetPlayerPos(playerid,x,y,z); SetPlayerInterior(player1,GetPlayerInterior(playerid));
			SetPlayerVirtualWorld(player1,GetPlayerVirtualWorld(playerid));
			if(GetPlayerState(player1) == 3)	{
			    new VehicleID = GetPlayerVehicleID(player1);
				SetVehiclePos(VehicleID,x+3,y,z);   LinkVehicleToInterior(VehicleID,GetPlayerInterior(playerid));
				SetVehicleVirtualWorld(GetPlayerVehicleID(player1),GetPlayerVirtualWorld(playerid));
			} else SetPlayerPos(player1,x+2,y,z);
			format(string,sizeof(string),"Voce foi teleportado para o Administrador (a) \"%s's\"", pName(playerid) );	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"Voce teleportou \"%s\" para voce", pName(player1) );
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado or is yourself");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_fu(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /fu [playerid]");
    	new player1 = strval(params), string[128], NewName[MAX_PLAYER_NAME];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	CMDMessageToAdmins(playerid,"FU");
			SetPlayerHealth(player1,1.0); SetPlayerArmour(player1,0.0); ResetPlayerWeapons(player1);ResetPlayerCash(player1);GivePlayerWeapon(player1,13,1);
			SetPlayerSkin(player1, 252); SetPlayerScore(player1, 0); SetPlayerColor(player1,COLOR_PINK); SetPlayerWeather(player1,19); SetPlayerWantedLevel(player1,6);
			format(NewName,sizeof(NewName),"[N0OB]%s", pName(player1) ); SetPlayerName(player1,NewName);
			if(IsPlayerInAnyVehicle(player1)) EraseVehicle(GetPlayerVehicleID(player1));
			if(player1 != playerid)	{ format(string,sizeof(string),"~w~%s: ~r~Foda-se", pName(playerid) ); GameTextForPlayer(player1, string, 2500, 3); }
			format(string,sizeof(string),"Fuck you \"%s\"", pName(player1) ); return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_tg(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /tg [playerid]");
    	new player1 = strval(params);
    	if(!IsPlayerSpawned(player1)) return SendClientMessage(playerid, red, "Jogador não nascido.");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	    if(PlayerInfo[player1][Level] >= PlayerInfo[playerid][Level]) return SendClientMessage(playerid, red, "Jogador é ADM como você. ou ADM SUPERIOR.");
	CMDMessageToAdmins(playerid,"TG");
			
			if(IsPlayerInAnyVehicle(player1)){RemovePlayerFromVehicle(player1);}
			
			//player1
			 new Float:health;GetPlayerHealth(player1,health);
			 new Float:armour;GetPlayerArmour(player1,armour);
			new Float:burnx, Float:burny, Float:burnz; GetPlayerPos(player1,burnx, burny, burnz); CreateExplosion(burnx, burny , burnz, 7,5.0);
			//new Float:Health, Float:x, Float:y, Float:z; GetPlayerHealth(player1,Health); //SetPlayerHealth(player1,Health-10);
			//GetPlayerPos(player1,x,y,z); SetPlayerPos(player1,x,y,z+20); PlayerPlaySound(playerid,1190,0.0,0.0,0.0); PlayerPlaySound(player1,1190,0.0,0.0,0.0);
			KillTimer(ExplodirTimer[player1]);
            ExplodirTimer[player1] = SetTimerEx("RestaurarPlayer",3000, 0, "iff",player1, health, armour);
            
            new FPS = GetPVarInt(player1,"PVarFPS");
			new PING = GetPlayerPing(player1);
			new avalPING[11];
			if(PING < 150) avalPING = "Excelente";
			if(PING >= 150) avalPING = "Muito boa";
			if(PING >= 200) avalPING = "Boa";
			if(PING >= 220) avalPING = "Normal";
			if(PING >= 300) avalPING = "Ruim";
			if(PING >= 350) avalPING = "Péssima";
			new avalFPS[13];
			if(FPS == 0) avalFPS = "Indisponível";
			if(FPS > 0) avalFPS = "Péssimo";
			if(FPS >= 15) avalFPS = "Ruim";
			if(FPS >= 24) avalFPS = "Normal";
			if(FPS >= 35) avalFPS = "Bom";
			if(FPS >= 40) avalFPS = "Muito bom";
			if(FPS >= 50) avalFPS = "Excelente";
			new string[100],string2[100];
			format(string, sizeof(string), "FPS do player %i - Ping do player: %i", FPS,PING);
			format(string2, sizeof(string2), "Computador do player: %s - Conexão do player: %s", avalFPS,avalPING);
            SendClientMessage(playerid,green,"");
            SendClientMessage(playerid,green,string);
            SendClientMessage(playerid,green,string2);
   			SendClientMessage(playerid,blue,"O colete e HP será restaurado em 1 segundo...");
   			SendClientMessage(playerid,green,"");
   			return 1;
   			
   			
			
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_testargod(playerid,params[]) {
#pragma unused params
if(PlayerInfo[playerid][Level] >= 2){SendClientMessage(playerid, red, "Comando movido para: /TG");}return 1;}

dcmd_avisar(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /avisar [playerid] [motivo]");
    	new warned = strval(tmp), str[200];
		if(PlayerInfo[warned][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
	 	if(IsPlayerConnected(warned) && warned != INVALID_PLAYER_ID) {
 	    	if(warned != playerid) {
				if(TimeStamp()-AvisoTick[warned] < 10) return SendClientMessage(playerid,red,"| ERRO |: Você deve aguardar 10 segundos para advertir um player já advertido anteriormente");
		//	    CMDMessageToAdmins(playerid,"AVISAR");
				PlayerInfo[warned][Warnings]++;
				AvisoTick[warned] = TimeStamp();
				if( PlayerInfo[warned][Warnings] == MAX_WARNINGS) {
					format(str, sizeof (str), "**Administrador (a) \"%s\" kickou \"%s\".  (Motivo: %s) (Aviso: %d/%d)**", pName(playerid), pName(warned), params[1+strlen(tmp)], PlayerInfo[warned][Warnings], MAX_WARNINGS);
					SendClientMessageToAll(grey, str);
					SaveToFile("KickLog",str);	Kick(warned);
					return 1;
				} else {
					ProcessarAdvertencia(warned, params[1+strlen(tmp)]);
					format(str, sizeof (str), "**Administrador (a) \"%s\" advertiu \"%s\".  (Motivo: %s) (Aviso: %d de %d)**", pName(playerid), pName(warned), params[1+strlen(tmp)], PlayerInfo[warned][Warnings], MAX_WARNINGS);
					return SendClientMessageToAll(yellow, str);
				}
			} else return SendClientMessage(playerid, red, "| ERRO |: Voce nao pode advertir voce mesmo");
		} else return SendClientMessage(playerid, red, "| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_mae(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = "Proibido xingamento a mãe/parentesco";
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /mae [playerid]");
    	new warned = strval(tmp), str[200];
		if(PlayerInfo[warned][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
		
		if(!IsNumeric(tmp)) return SendClientMessage(playerid,red,"| ERRO |: ID Invalida");
		
	 	if(IsPlayerConnected(warned) && warned != INVALID_PLAYER_ID) {
 	    	if(warned != playerid) {
 	    	if(TimeStamp()-AvisoTick[warned] < 10) return SendClientMessage(playerid,red,"| ERRO |: Você deve aguardar 10 segundos para advertir um player já advertido anteriormente");
		//	    CMDMessageToAdmins(playerid,"MAE");
				PlayerInfo[warned][Warnings]++;
				AvisoTick[warned] = TimeStamp();
				if( PlayerInfo[warned][Warnings] == MAX_WARNINGS) {
					format(str, sizeof (str), "**Administrador (a) \"%s\" kickou \"%s\".  (Motivo: %s) (Aviso: %d/%d)**", pName(playerid), pName(warned),tmp2, PlayerInfo[warned][Warnings], MAX_WARNINGS);
					SendClientMessageToAll(grey, str);
					SaveToFile("KickLog",str);	Kick(warned);
					return 1;
				} else {
					ProcessarAdvertencia(warned, tmp2);
					format(str, sizeof (str), "**Administrador (a) \"%s\" advertiu \"%s\".  (Motivo: %s) (Aviso: %d de %d)**", pName(playerid), pName(warned), tmp2, PlayerInfo[warned][Warnings], MAX_WARNINGS);
					return SendClientMessageToAll(yellow, str);
				}
			} else return SendClientMessage(playerid, red, "| ERRO |: Voce nao pode advertir voce mesmo");
		} else return SendClientMessage(playerid, red, "| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_kick(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
	    if(PlayerInfo[playerid][Level] >= 1) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /kick [playerid] [Motivo]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[140];
			player1 = strval(tmp);
			
			if(!IsNumeric(tmp)) return SendClientMessage(playerid,red,"| ERRO |: ID Invalida");

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
		//		CMDMessageToAdmins(playerid,"KICK");
				if(!strlen(tmp2)) {
					format(string,sizeof(string),"{00FFFB}%s {FFFFFF}foi kickado pelo Administrador {00FFFB}%s {FF0000}[Motivo: Violação das /REGRAS] ",playername,adminname); SendClientMessageToAll(grey,string);
					SaveToFile("KickLog",string); print(string); return Kick(player1);
				} else {
					format(string,sizeof(string),"{00FFFB}%s {FFFFFF}foi kickado pelo Administrador {00FFFB}%s {FF0000}[Motivo: %s] ",playername,adminname,params[2]); SendClientMessageToAll(grey,string);
					SaveToFile("KickLog",string); print(string); return Kick(player1); }
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_fakeban(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /ban [playerid] [motivo]");
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| ERRO |: Voce deve especificar um motivo");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[140];
			player1 = strval(tmp);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {

		 	if(PlayerInfo[player1][Level] >= 2 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Você não pode banir um Admin!");
		 	if(!IsNumeric(tmp)) return SendClientMessage(playerid,red,"| ERRO |: ID Invalida");

				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
				new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
		//		CMDMessageToAdmins(playerid,"BAN");
				format(string,sizeof(string),"{00FFFB}%s {FFFFFF}foi banido pelo Administrador {00FFFB}%s {FF0000}[Motivo: %s] [Data: %d/%d/%d] [Hora: %d:%d]",playername,adminname,params[2],day,month,year,hour,minuite);
				SendClientMessageToAll(grey,string);
				print(string);
				if(udb_Exists(PlayerName2(player1)) && PlayerInfo[player1][LoggedIn] == 1) dUserSetINT(PlayerName2(player1)).("banned",0);
				format(string,sizeof(string),"banido pelo Administrador %s. Motivo: %s", adminname, params[2] );

new stringmeu[500];
if(player1 != playerid) { format(stringmeu, sizeof(stringmeu), "{FF0000}Você foi banido do servidor !\n{FF0000}Administrador: {FFFFFF}%s\n{FF0000}Hora e data: {FFFFFF}%d:%d do dia %d/%d/%d\n{FF0000}Motivo: {FFFFFF}%s\n{FF0000}Se acha que foi banido por engano, dê um print(F8)\ne envia para nossa página do facebook.\nLink: www.facebook.com/MundoDosMitos2018", adminname, hour,minuite,day,month,year,params[2]); }
    ShowPlayerDialog(player1, 2525,  DIALOG_STYLE_MSGBOX, "{FF0000}» {FFFFFF}Você foi Banido", stringmeu, "Ok", "");

				//BanNotify(player1);
				return SendClientMessage(player1,0x808080FF,"Server closed the connection");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}


dcmd_tempbanmm(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 2)  return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /tempban [playerid] [horas] [motivo]");
new string[140];
new player,horas;
player = strval(tmp);
horas = strval(tmp2);
if(PlayerInfo[player][LoggedIn] != 1) return SendClientMessage(playerid, red, "| ERRO |: Jogador não esta logado");
if(!IsPlayerConnected(player)) return SendClientMessage(playerid, red, "| ERRO |: Jogador não conectado");
if(player == playerid) return SendClientMessage(playerid, red, "| ERRO |: É seu ID, sua anta!");
if(PlayerInfo[player][Level] >= 6) return SendClientMessage(playerid, red, "| ERRO |: Jogador é ADMIN! Seu noob!");
if(horas > 336) return SendClientMessage(playerid, red, "| ERRO |: Máximo de horas: 336");
if(horas <= 0) return SendClientMessage(playerid, red, "| ERRO |: Mínimo de horas: 1");
if(!strlen(params[4])) return SendClientMessage(playerid, red, "| ERRO |: Você deve especificar um motivo");
//CMDMessageToAdmins(playerid,"TEMPBAN");
new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
new playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME];
GetPlayerName(player, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
new string2[100],string3[100];
format(string,sizeof(string),"{00FFFB}%s {FFFFFF}foi TEMP-BAN por {00FFFB}%s {FF0000}[Horas: %i] [Motivo: %s] [Data: %d/%d/%d] [Hora: %d:%d]",playername,adminname,horas,params[strlen(tmp)+strlen(tmp2)+1],day,month,year,hour,minuite);
format(string3,sizeof(string3),"Você foi banido temporariamente. Motivo: %s",params[4]);
format(string2,sizeof(string2),"Sua conta será desbanida automaticamente em %i horas",horas);
SendClientMessageToAll(grey,string);
SaveToFile("BanLog",string);
dUserSetINT(PlayerName2(player)).("tmpb",1);
dUserSetINT(PlayerName2(player)).("tmpbs",HourTimeStamp);
dUserSetINT(PlayerName2(player)).("tmpbh",horas);
SendClientMessage(player, red, "");
SendClientMessage(player, yellow, string3);
SendClientMessage(player, green, string2);
SendClientMessage(player, red, "");
Kick(player);
return 1;
}



dcmd_ban(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /ban [playerid] [motivo]");
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| ERRO |: Voce deve especificar um motivo");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[140];
			player1 = strval(tmp);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
		 	
		 	if(PlayerInfo[player1][Level] >= 2 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Você não pode banir um Admin!");
		 	if(!IsNumeric(tmp)) return SendClientMessage(playerid,red,"| ERRO |: ID Invalida");
		 	
				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
				new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
		//		CMDMessageToAdmins(playerid,"BAN");
				format(string,sizeof(string),"{00FFFB}%s {FFFFFF}foi banido pelo Administrador {00FFFB}%s {FF0000}[Motivo: %s] [Data: %d/%d/%d] [Hora: %d:%d]",playername,adminname,params[2],day,month,year,hour,minuite);
				SendClientMessageToAll(grey,string);
				SaveToFile("BanLog",string);
				print(string);
				if(udb_Exists(PlayerName2(player1)) && PlayerInfo[player1][LoggedIn] == 1) dUserSetINT(PlayerName2(player1)).("banned",1);
				format(string,sizeof(string),"banido pelo Administrador %s. Motivo: %s", adminname, params[2] );
				BanNotify(player1);
new stringmeu[500];
if(player1 != playerid) { format(stringmeu, sizeof(stringmeu), "{FF0000}Você foi banido do servidor !\n{FF0000}Administrador: {FFFFFF}%s\n{FF0000}Hora e data: {FFFFFF}%d:%d do dia %d/%d/%d\n{FF0000}Motivo: {FFFFFF}%s\n{FF0000}Se acha que foi banido por engano, dê um print(F8)\ne envia para nossa página do facebook.\nLink: www.facebook.com/MundoDosMitos2018", adminname, hour,minuite,day,month,year,params[2]); }
    ShowPlayerDialog(player1, 2525,  DIALOG_STYLE_MSGBOX, "{FF0000}» {FFFFFF}Você foi Banido", stringmeu, "Ok", "");

				return BanEx(player1, string);
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_rbanmm(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 5) {
		    new ip[128], tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /rban [playerid] [Motivo]");
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| ERRO |: Voce deve especificar um motivo");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[140];
			player1 = strval(tmp);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
				new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
			CMDMessageToAdmins(playerid,"RBAN");
				format(string,sizeof(string),"{00FFFB}%s {FFFFFF}foi banido em range por {00FFFB}%s {FF0000}[Motivo: %s] [Data: %d/%d/%d] [Hora: %d:%d]",playername,adminname,params[2],day,month,year,hour,minuite);
				SendClientMessageToAll(grey,string);
				SaveToFile("BanLog",string);
				print(string);
				if(udb_Exists(PlayerName2(player1)) && PlayerInfo[player1][LoggedIn] == 1) dUserSetINT(PlayerName2(player1)).("banned",1);
				GetPlayerIp(player1,ip,sizeof(ip));
	            strdel(ip,strlen(ip)-2,strlen(ip));
    	        format(ip,128,"%s**",ip);
				format(ip,128,"banip %s",ip);
            	SendRconCommand(ip);
				return 1;
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_slap(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /slap [playerid] [motivo/with]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SLAP");
		        new Float:Health, Float:x, Float:y, Float:z; GetPlayerHealth(player1,Health); SetPlayerHealth(player1,Health-25);
				GetPlayerPos(player1,x,y,z); SetPlayerPos(player1,x,y,z+5); PlayerPlaySound(playerid,1190,0.0,0.0,0.0); PlayerPlaySound(player1,1190,0.0,0.0,0.0);

				if(strlen(tmp2)) {
					format(string,sizeof(string),"Voce foi slapeado pelo Administrador (a) %s %s ",adminname,params[2]);	//SendClientMessage(player1,red,string);
					format(string,sizeof(string),"Voce slapeou de %s %s ",playername,params[2]); return SendClientMessage(playerid,blue,string);
				} else {
					format(string,sizeof(string),"Voce foi slapeado pelo Administrador (a) %s ",adminname);	//SendClientMessage(player1,red,string);
					format(string,sizeof(string),"Voce slapeou de %s",playername); return SendClientMessage(playerid,blue,string); }
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_jail(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
		    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /jail [playerid] [minutos] [motivo]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				if(PlayerInfo[player1][Jailed] == 0) {
					GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
					new jtime = strval(tmp2);
					if(jtime == 0) jtime = 9999;

			    //   	CMDMessageToAdmins(playerid,"JAIL");
					PlayerInfo[player1][JailTime] = jtime*1000*60;
    			    SetTimerEx("JailPlayer",5000,0,"d",player1);
		    	    SetTimerEx("Jail1",1000,0,"d",player1);
		        	PlayerInfo[player1][Jailed] = 1;
                    PlayerInfo[player1][Muted] = 1;
					//if(PlayerInfo[playerid][Level] = 2) PlayerInfo[player1][Muted] = 0;

					if(jtime == 9999) {
						if(!strlen(params[strlen(tmp2)+1])) format(string,sizeof(string),"Administrador (a) %s prendeu %s ",adminname, playername);
						else format(string,sizeof(string),"Administrador (a) %s prendeu %s [Motivo: %s]",adminname, playername, params[strlen(tmp)+1] );
   					} else {
						if(!strlen(tmp3)) format(string,sizeof(string),"Administrador (a) %s prendeu %s por %d minutos",adminname, playername, jtime);
						else format(string,sizeof(string),"Administrador (a) %s prendeu %s por %d minutos [Motivo: %s]",adminname, playername, jtime, params[strlen(tmp2)+strlen(tmp)+1] );
					}
	    			return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Jogador ja esta preso");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_unjail(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
		    new tmp[256], Index; tmp = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /unjail [playerid]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player1][Jailed] == 1) {
					GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
					format(string,sizeof(string),"Administrador (a) %s te soltou da cadeia",adminname);	SendClientMessage(player1,blue,string);
					format(string,sizeof(string),"Administrador (a) %s soltou %s a cadeia",adminname, playername);
					JailRelease(player1);
					return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Jogador ja esta preso");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_jailed(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
	 		new bool:First2 = false, Count, adminname[MAX_PLAYER_NAME], string[128], i;
		    for(i = 0; i < GetMaxPlayers(); i++) if(IsPlayerConnected(i) && PlayerInfo[i][Jailed]) Count++;
			if(Count == 0) return SendClientMessage(playerid,red, "Sem jogadores presos");

		    for(i = 0; i < GetMaxPlayers(); i++) if(IsPlayerConnected(i) && PlayerInfo[i][Jailed]) {
	    		GetPlayerName(i, adminname, sizeof(adminname));
				if(!First2) { format(string, sizeof(string), "Jogadores presos: (%d)%s", i,adminname); First2 = true; }
		        else format(string,sizeof(string),"%s, (%d)%s ",string,i,adminname);
	        }
		    return SendClientMessage(playerid,COLOR_WHITE,string);
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_travar(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 3) {
		    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /travar [playerid] [minutos] [motivo]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player1][Frozen] == 0) {
					GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
					new ftime = strval(tmp2);
					if(ftime == 0) ftime = 9999;

			   //    	CMDMessageToAdmins(playerid,"TRAVAR");
					TogglePlayerControllable(player1,false); PlayerInfo[player1][Frozen] = 1; PlayerPlaySound(player1,1057,0.0,0.0,0.0);
					PlayerInfo[player1][FreezeTime] = ftime*1000*60;
			        FreezeTimer[player1] = SetTimerEx("UnFreezeMe",PlayerInfo[player1][FreezeTime],0,"d",player1);

					if(ftime == 9999) {
						if(!strlen(params[strlen(tmp2)+1])) format(string,sizeof(string),"Administrador (a) %s travou %s ",adminname, playername);
						else format(string,sizeof(string),"Administrador (a) %s travou %s [Motivo: %s]",adminname, playername, params[strlen(tmp)+1] );
	   				} else {
						if(!strlen(tmp3)) format(string,sizeof(string),"Administrador (a) %s travou %s por %d minutos",adminname, playername, ftime);
						else format(string,sizeof(string),"Administrador (a) %s travou %s por %d minutos [Motivos: %s]",adminname, playername, ftime, params[strlen(tmp2)+strlen(tmp)+1] );
					}
		    		return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Jogador ja esta travado");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_destravar(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
	    if(PlayerInfo[playerid][Level] >= 3|| IsPlayerAdmin(playerid)) {
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /destravar [playerid]");
	    	new player1, string[128];
			player1 = strval(params);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		 	    if(PlayerInfo[player1][Frozen] == 1) {
			  //     	CMDMessageToAdmins(playerid,"DESTRAVAR");
					UnFreezeMe(player1);
					format(string,sizeof(string),"Administrador (a) %s te destravou", PlayerName2(playerid) ); SendClientMessage(player1,blue,string);
					format(string,sizeof(string),"Administrador (a) %s destravou %s", PlayerName2(playerid), PlayerName2(player1));
		    		return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Jogador nao esta travado");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_travados(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
	 		new bool:First2 = false, Count, adminname[MAX_PLAYER_NAME], string[128], i;
		    for(i = 0; i < GetMaxPlayers(); i++) if(IsPlayerConnected(i) && PlayerInfo[i][Frozen]) Count++;
			if(Count == 0) return SendClientMessage(playerid,red, "Sem jogadores travados");
			
		    for(i = 0; i < GetMaxPlayers(); i++) if(IsPlayerConnected(i) && PlayerInfo[i][Frozen]) {
	    		GetPlayerName(i, adminname, sizeof(adminname));
				if(!First2) { format(string, sizeof(string), "Jogadores travados: (%d)%s", i,adminname); First2 = true; }
		        else format(string,sizeof(string),"%s, (%d)%s ",string,i,adminname);
	        }
		    return SendClientMessage(playerid,COLOR_WHITE,string);
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_mute(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /mute [playerid] [motivo]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
		 	    if(PlayerInfo[player1][Muted] == 0) {
					GetPlayerName(player1, playername, sizeof(playername)); 	GetPlayerName(playerid, adminname, sizeof(adminname));
				CMDMessageToAdmins(playerid,"MUTE");
					PlayerPlaySound(player1,1057,0.0,0.0,0.0);  PlayerInfo[player1][Muted] = 1; PlayerInfo[player1][MuteWarnings] = 0;

					if(strlen(tmp2)) {
						format(string,sizeof(string),"Voce foi calado pelo (a) Administrador (a) %s [Motivo: %s]",adminname,params[2]); SendClientMessage(player1,blue,string);
						format(string,sizeof(string),"Voce calou %s [Motivo: %s]", playername,params[2]); return SendClientMessage(playerid,blue,string);
					} else {
						format(string,sizeof(string),"Voce foi calado pelo Administrador (a) %s",adminname); SendClientMessage(player1,blue,string);
						format(string,sizeof(string),"Voce calou %s", playername); return SendClientMessage(playerid,blue,string); }
				} else return SendClientMessage(playerid, red, "Jogador ja esta mudo");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_unmute(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /unmute [playerid]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(params);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
		 	    if(PlayerInfo[player1][Muted] == 1) {
					GetPlayerName(player1, playername, sizeof(playername)); 	GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"UNMUTE");
					PlayerPlaySound(player1,1057,0.0,0.0,0.0);  PlayerInfo[player1][Muted] = 0; PlayerInfo[player1][MuteWarnings] = 0;
					format(string,sizeof(string),"Voce foi descalado pelo Administrador (a) %s",adminname); SendClientMessage(player1,blue,string);
					format(string,sizeof(string),"Voce descalou %s", playername); return SendClientMessage(playerid,blue,string);
				} else return SendClientMessage(playerid, red, "Jogador nao esta calado");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado ou e vc mesmo ou admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_muted(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 2) {
	 		new bool:First2 = false, Count, adminname[MAX_PLAYER_NAME], string[128], i;
		    for(i = 0; i < GetMaxPlayers(); i++) if(IsPlayerConnected(i) && PlayerInfo[i][Muted]) Count++;
			if(Count == 0) return SendClientMessage(playerid,red, "Sem jogadores calados");

		    for(i = 0; i < GetMaxPlayers(); i++) if(IsPlayerConnected(i) && PlayerInfo[i][Muted]) {
	    		GetPlayerName(i, adminname, sizeof(adminname));
				if(!First2) { format(string, sizeof(string), "Jogadores calados: (%d)%s", i,adminname); First2 = true; }
		        else format(string,sizeof(string),"%s, (%d)%s ",string,i,adminname);
	        }
		    return SendClientMessage(playerid,COLOR_WHITE,string);
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_akill(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
	    if(PlayerInfo[playerid][Level] >= 6|| IsPlayerAdmin(playerid)) {
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /akill [playerid]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(params);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if( (PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel] ) )
					return SendClientMessage(playerid, red, "Voce nao pode matar um admin de alto nivel");
			CMDMessageToAdmins(playerid,"AKILL");
				GetPlayerName(player1, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
				format(string,sizeof(string),"Administrador (a) %s te matou",adminname);	SendClientMessage(player1,blue,string);
				format(string,sizeof(string),"Voce foi morto - %s",playername); SendClientMessage(playerid,blue,string);
				return SetPlayerHealth(player1,0.0);
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_weaps(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /weaps [playerid]");
    	new player1, string[128], string2[64], WeapName[24], slot, weap, ammo, Count, x;
		player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			format(string2,sizeof(string2),"[>> %s Armas (id:%d) <<]", PlayerName2(player1), player1); SendClientMessage(playerid,blue,string2);
			for (slot = 0; slot < 14; slot++) {	GetPlayerWeaponData(player1, slot, weap, ammo); if( ammo != 0 && weap != 0) Count++; }
			if(Count < 1) return SendClientMessage(playerid,blue,"Jogador nao tem armas");

			if(Count >= 1)
			{
				for (slot = 0; slot < 14; slot++)
				{
					GetPlayerWeaponData(player1, slot, weap, ammo);
					if( ammo != 0 && weap != 0)
					{
						GetWeaponName(weap, WeapName, sizeof(WeapName) );
						if(ammo == 65535 || ammo == 1) format(string,sizeof(string),"%s%s (1)",string, WeapName );
						else format(string,sizeof(string),"%s%s (%d)",string, WeapName, ammo );
						x++;
						if(x >= 5)
						{
						    SendClientMessage(playerid, blue, string);
						    x = 0;
							format(string, sizeof(string), "");
						}
						else format(string, sizeof(string), "%s,  ", string);
					}
			    }
				if(x <= 4 && x > 0) {
					string[strlen(string)-3] = '.';
				    SendClientMessage(playerid, blue, string);
				}
		    }
		    return 1;
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_bot(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
 		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /bot [text]");
		new string[128]; format(string, sizeof(string), "{00FFEE}» [ADMIN] ChuckNorris {FFFFFF}(101): {00FFFF}%s", params[0] );
		return SendClientMessageToAll(COLOR_PINK,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_aka(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /aka [playerid]");
    	new player1, playername[MAX_PLAYER_NAME], str[128], tmp3[50];
		player1 = strval(params);
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
  		  	GetPlayerIp(player1,tmp3,50);
			GetPlayerName(player1, playername, sizeof(playername));
		    format(str,sizeof(str),"AKA: [%s id:%d] [%s] %s", playername, player1, tmp3, dini_Get("ladmin/config/aka.txt",tmp3) );
	        return SendClientMessage(playerid,blue,str);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado or is yourself");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_screen(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /screen [playerid] [texto]");
    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256];
		player1 = strval(params);
		

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
			GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
		CMDMessageToAdmins(playerid,"SCREEN");
			
			new SACSB[100];
			new pnamea[MAX_PLAYER_NAME];
			new pnameb[MAX_PLAYER_NAME];
			GetPlayerName(playerid, pnamea, MAX_PLAYER_NAME);
			GetPlayerName(player1, pnameb, MAX_PLAYER_NAME);
			format(SACSB, sizeof(SACSB), "| ADM |: Screen de %s para %s: %s", pnamea, pnameb, params[2]);
			CallRemoteFunction("MessageToAdmins","is",yellow,SACSB);
			
			format(string,sizeof(string),"Administrador (a) %s te enviou uma mensagem",adminname);	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"Voce enviou a %s uma mensagem (%s)", playername, params[2]); SendClientMessage(playerid,blue,string);
			

			return GameTextForPlayer(player1, params[2],4000,3);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado or is yourself ou e vc mesmo ou admin de alto nivel");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_laston(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2) {
    	new tmp2[256], file[256],player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], str[128];
		GetPlayerName(playerid, adminname, sizeof(adminname));

	    if(!strlen(params)) {
			format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(adminname));
			if(!fexist(file)) return SendClientMessage(playerid, red, "| ERRO |: Arquivo inexistente, jogador nao registrado");
			if(dUserINT(PlayerName2(playerid)).("LastOn")==0) {	format(str, sizeof(str),"Never"); tmp2 = str;
			} else { tmp2 = dini_Get(file,"LastOn"); }
			format(str, sizeof(str),"Voce esteve no servidor anteriormente em %s",tmp2);
			return SendClientMessage(playerid, red, str);
		}
		player1 = strval(params);
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
		CMDMessageToAdmins(playerid,"LASTON");
   	    	GetPlayerName(player1,playername,sizeof(playername)); format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(playername));
			if(!fexist(file)) return SendClientMessage(playerid, red, "| ERRO |: Arquivo nao existe, jogador nao registrado");
			if(dUserINT(PlayerName2(player1)).("LastOn")==0) { format(str, sizeof(str),"Never"); tmp2 = str;
			} else { tmp2 = dini_Get(file,"LastOn"); }
			format(str, sizeof(str),"%s esteve no servidor anteriormente em %s",playername,tmp2);
			return SendClientMessage(playerid, red, str);
		} else return SendClientMessage(playerid, red, "Jogador nao esta conectado or is yourself");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
/*
dcmd_admins(playerid,params[]) {
#pragma unused params
//Alertar admins para quem digitar o comando /admins
if(PlayerInfo[playerid][Level] < 2){
new pname[MAX_PLAYER_NAME],SACSB[100];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);
format(SACSB, sizeof(SACSB), "| ADM |: %s (%i) digitou /ADMINS", pname, playerid);
CallRemoteFunction("MessageToAdmins","is",yellow,SACSB);}
//Estrutura do comando /admins
new Adms[650],ADMsDialog[810],Name[MAX_PLAYER_NAME],level,admscount;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
 {
  if(PlayerInfo[i][Level] > 1)
  {
   if(AdmHidden[i] == false || PlayerInfo[playerid][Level] > 0)
   {
   level = PlayerInfo[i][Level];
   GetPlayerName(i, Name, sizeof(Name));
   if(admscount < 15) format(Adms, sizeof(Adms), "%s\n%s (%i) - [Nível %i]", Adms,Name,i,level);
   admscount++;
   }
  }
 }
}
if(admscount > 0)
format(ADMsDialog, sizeof(ADMsDialog), "{FFFFFF}Total de administradores online: {FFFF00}%i{FFFFFF}{09D19B}\n%s\n\n{FFFFFF}Use /report ID Motivo para reportar \ncheaters e violações as {FFFF00}/regras", admscount,Adms);
else
format(ADMsDialog, sizeof(ADMsDialog), "{FF0000}Nenhum administrador online\n\n{FFFFFF}Caso veje alguém com cheats, tire um \nprint e poste em nossa comunidade", admscount,Adms);
ShowPlayerDialog(playerid,1000,DIALOG_STYLE_MSGBOX,"Administradores do servidor:",ADMsDialog,"OK","Voltar");
return 1;}
*/


dcmd_admins(playerid,params[])
{
#pragma unused params

if(PlayerInfo[playerid][Level] < 2)
{
	new pname[MAX_PLAYER_NAME],SACSB[100];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);
	format(SACSB, sizeof(SACSB), "| ADM | %s [ID: %i] digitou /Admins", pname, playerid);
	CallRemoteFunction("MessageToAdmins","is",yellow,SACSB);
}

new String[1000], String2[1000], AFKp[30];
new bool:contador = false;
format(String, sizeof(String),"ID\tNome\tLevel\tEstado\n");
strcat(String2, String);


for(new i,a = GetMaxPlayers(); i < a ;i++)
{
	if(IsPlayerConnected(i))
	{
  		if(PlayerInfo[i][Level] > 0)
		{
			if(AdmHidden[i] == false || PlayerInfo[playerid][Level] > 0)
			{

new pname[MAX_PLAYER_NAME];GetPlayerName(i, pname, MAX_PLAYER_NAME);


				if(! contador ) ShowPlayerDialog(playerid, 2425, DIALOG_STYLE_TABLIST_HEADERS, "Administradores",String2,"{FF0000}X", #);
				if(IsPlayerPaused(i)) AFKp = "{FF0000}ESC";
				if(!IsPlayerPaused(i)) AFKp = "Jogando";

				format(String, sizeof(String),"%d\t{48ce80}%s\t{FFFFFF}%d\t{48ce80}%s\n", i, pname, PlayerInfo[i][Level], AFKp);
				strcat(String2, String);
				ShowPlayerDialog(playerid, 2425, DIALOG_STYLE_TABLIST_HEADERS, "Administradores",String2,"{FF0000}X", #);
				contador = true;
	  		}
		  }
		}
	  }
new str[400];
format(str, sizeof(str), "{FF0000}Nenhum administrador online.\n\n{FFFFFF}Caso veje alguém com hack's, tire um print\ne poste em nossa página do facebook:\n\n{FF0000}www.facebook.com/MundoDosMitos2018");
if(! contador) ShowPlayerDialog(playerid, 7895, DIALOG_STYLE_MSGBOX, "Administradores", str ,"{FF0000}X", #);
return 1;
}


dcmd_vips(playerid,params[])
{
#pragma unused params

if(PlayerInfo[playerid][Level] < 2)
{
	new pname[MAX_PLAYER_NAME],SACSB[100];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);
	format(SACSB, sizeof(SACSB), "| ADM | %s [ID: %i] digitou /VIPS", pname, playerid);
	CallRemoteFunction("MessageToAdmins","is",yellow,SACSB);
}

new String[1000], String2[1000], AFKp[30];
new bool:contador = false;
format(String, sizeof(String),"ID\tNome\tLevel\tEstado\n");
strcat(String2, String);


for(new i,a = GetMaxPlayers(); i < a ;i++)
{
	if(IsPlayerConnected(i))
	{
  		if(PlayerInfo[i][VIP] > 0)
		{
			if(AdmHidden[i] == false || PlayerInfo[playerid][VIP] > 0)
			{

new pname[MAX_PLAYER_NAME];GetPlayerName(i, pname, MAX_PLAYER_NAME);


				if(! contador ) ShowPlayerDialog(playerid, 2425, DIALOG_STYLE_TABLIST_HEADERS, "VIPs",String2,"{FF0000}X", #);
				if(IsPlayerPaused(i)) AFKp = "{FF0000}ESC";
				if(!IsPlayerPaused(i)) AFKp = "Jogando";

				format(String, sizeof(String),"%d\t{48ce80}%s\t{FFFFFF}%d\t{48ce80}%s\n", i, pname, PlayerInfo[i][VIP], AFKp);
				strcat(String2, String);
				ShowPlayerDialog(playerid, 2425, DIALOG_STYLE_TABLIST_HEADERS, "VIPs",String2,"{FF0000}X", #);
				contador = true;
	  		}
		  }
		}
	  }
new str[400];
format(str, sizeof(str), "{FF0000}Nenhum VIP online.\n\n{FFFFFF}Para adiquirir o seu digite /planosvip\alguma duvida ou sugestão\nentre em nossa página do facebook:\n\n{FF0000}www.facebook.com/MundoDosMitos2018");
if(! contador) ShowPlayerDialog(playerid, 7895, DIALOG_STYLE_MSGBOX, "VIPs", str ,"{FF0000}X", #);
return 1;
}

/*
dcmd_vips(playerid,params[]) {
#pragma unused params
new Adms[650],ADMsDialog[810],Name[MAX_PLAYER_NAME],level,admscount;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
		if(PlayerInfo[i][VIP] > 0)
		{
		level = PlayerInfo[i][VIP];
		GetPlayerName(i, Name, sizeof(Name));
		if(admscount < 15) format(Adms, sizeof(Adms), "{0095FF}%s\n{0095FF}%s {0095FF}(%i) {0095FF}[Vip Level: %i]", Adms,Name,i,level);
		admscount++;
		}

	}
}
if(admscount > 0)
format(ADMsDialog, sizeof(ADMsDialog), "{FFFFFF}Jogadores VIP's online: {00FF00}%i{FFFFFF}{FFFFFF}\n{FFFFFF}%s", admscount,Adms);
else
format(ADMsDialog, sizeof(ADMsDialog), "{FFFF00}Nenhum VIP online", admscount,Adms);
ShowPlayerDialog(playerid,1000,DIALOG_STYLE_MSGBOX,"VIP's",ADMsDialog,"Ok","Fechar");
return 1;}
*/

dcmd_radmins(playerid,params[]) {
#pragma unused params
if(PlayerInfo[playerid][Level] < 4) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
//Estrutura do comando /radmins
new Adms[650],ADMsDialog[810],Name[MAX_PLAYER_NAME],admscount;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
		if(IsPlayerAdmin(i))
		{
		GetPlayerName(i, Name, sizeof(Name));
		if(admscount < 15) format(Adms, sizeof(Adms), "%s\n%s (%i)", Adms,Name,i);
		admscount++;
		}

	}
}
if(admscount > 0)
format(ADMsDialog, sizeof(ADMsDialog), "{00FFFF}Total de administradores RCON 0N: {FFFF00}%i{FF00FF}{09D19B}\n%s", admscount,Adms);
else
format(ADMsDialog, sizeof(ADMsDialog), "{FF0000}Nenhum administrador RCON 0N!{FFFFFF}", admscount,Adms);
ShowPlayerDialog(playerid,1000,DIALOG_STYLE_MSGBOX,"Administradores RCON do server:",ADMsDialog,"OK","Voltar");
return 1;}



/*
dcmd_base1(playerid,params[]) {
#pragma unused params
if(mrj[playerid] < 1){
new pname[MAX_PLAYER_NAME];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);}
new Adms2[650],ADMsDialog2[810],Name2[MAX_PLAYER_NAME],admscount2;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
        if(mrj[i] == 1) admnivel2="{EB4E10}Convidado --> (S.K)";
        if(mrj[i] == 2) admnivel2="{EB4E10}Membro --> (S.K)";
        if(mrj[i] == 3) admnivel2="{EB4E10}Recrutador --> (S.K)";
        if(mrj[i] == 4) admnivel2="{EB4E10}Sub-Lider --> (S.K)";
        if(mrj[i] == 5) admnivel2="{EB4E10}Lider --> (S.K)";
        if(mrj[i] == 6) admnivel2="{EB4E10}Dono --> (S.K)";
        {
		   if(mrj[i] > 0)
		    {
			    if(AdmHidden[i] == false || mrj[playerid] > 0)
			    {
			    GetPlayerName(i, Name2, sizeof(Name2));
			    if(admscount2 < 15) format(Adms2, sizeof(Adms2), "{FFFFFF}%s\n{FFFFFF}%s (ID:%i) - {FFFFFF}%s", Adms2,Name2,i,admnivel2);
			    admscount2++;
			    }
			}
		}
	}
}
if(admscount2 > 0)
format(ADMsDialog2, sizeof(ADMsDialog2), "%s\n", Adms2);
else
format(ADMsDialog2, sizeof(ADMsDialog2), "{FF0000}Nenhum membro (S.K) online.", admscount2,Adms2);
ShowPlayerDialog(playerid,1001,DIALOG_STYLE_MSGBOX,"{EB4E10}Membros Oficiais (S.K):",ADMsDialog2,"OK","");
return 1;}


dcmd_base2(playerid,params[]) {
#pragma unused params
if(d3x[playerid] < 1){
new pname[MAX_PLAYER_NAME];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);}
new Adms2[650],ADMsDialog2[810],Name2[MAX_PLAYER_NAME],admscount2;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
        if(d3x[i] == 1) admnivel2="{DDE332}Convidade --> [base2]";
        if(d3x[i] == 2) admnivel2="{DDE332}Membro --> [base2]";
        if(d3x[i] == 3) admnivel2="{DDE332}Recrutador --> [base2]";
        if(d3x[i] == 4) admnivel2="{DDE332}Sub-Lider --> [base2]";
        if(d3x[i] == 5) admnivel2="{DDE332}Lider --> [base2]";
        if(d3x[i] == 6) admnivel2="{DDE332}Dono --> [base2]";
        {
		   if(d3x[i] > 0)
		    {
			    if(AdmHidden[i] == false || d3x[playerid] > 0)
			    {
			    GetPlayerName(i, Name2, sizeof(Name2));
			    if(admscount2 < 15) format(Adms2, sizeof(Adms2), "{FFFFFF}%s\n{FFFFFF}%s (ID:%i) - {FFFFFF}%s", Adms2,Name2,i,admnivel2);
			    admscount2++;
			    }
			}
		}
	}
}
if(admscount2 > 0)
format(ADMsDialog2, sizeof(ADMsDialog2), "%s\n", Adms2);
else
format(ADMsDialog2, sizeof(ADMsDialog2), "{FF0000}Nenhum membro [base2] online.", admscount2,Adms2);
ShowPlayerDialog(playerid,1001,DIALOG_STYLE_MSGBOX,"{DDE332}Membros Oficiais [base2]:",ADMsDialog2,"OK","");
return 1;}

dcmd_base3(playerid,params[]) {
#pragma unused params
if(bmf[playerid] < 1){
new pname[MAX_PLAYER_NAME];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);}
new Adms2[650],ADMsDialog2[810],Name2[MAX_PLAYER_NAME],admscount2;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
        if(bmf[i] == 1) admnivel2="{00FFD0}Convidado --> [base3]";
        if(bmf[i] == 2) admnivel2="{00FFD0}Membro --> [base3]";
        if(bmf[i] == 3) admnivel2="{00FFD0}Recrutador --> [base3]";
        if(bmf[i] == 4) admnivel2="{00FFD0}Sub-Lider --> [base3]";
        if(bmf[i] == 5) admnivel2="{00FFD0}Lider --> [base3]";
        if(bmf[i] == 6) admnivel2="{00FFD0}Dono --> [base3]";
        {
		   if(bmf[i] > 0)
		    {
			    if(AdmHidden[i] == false || bmf[playerid] > 0)
			    {
			    GetPlayerName(i, Name2, sizeof(Name2));
			    if(admscount2 < 15) format(Adms2, sizeof(Adms2), "{FFFFFF}%s\n{FFFFFF}%s (ID:%i) - {FFFFFF}%s", Adms2,Name2,i,admnivel2);
			    admscount2++;
			    }
			}
		}
	}
}
if(admscount2 > 0)
format(ADMsDialog2, sizeof(ADMsDialog2), "%s\n", Adms2);
else
format(ADMsDialog2, sizeof(ADMsDialog2), "{FF0000}Nenhum membro [base3] online.", admscount2,Adms2);
ShowPlayerDialog(playerid,1001,DIALOG_STYLE_MSGBOX,"{00FFD0}Membros Oficiais [base3]:",ADMsDialog2,"OK","");
return 1;}


dcmd_base4(playerid,params[]) {
#pragma unused params
if(vks[playerid] < 1){
new pname[MAX_PLAYER_NAME];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);}
new Adms2[650],ADMsDialog2[810],Name2[MAX_PLAYER_NAME],admscount2;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
        if(vks[i] == 1) admnivel2="{BF4D00}Convidado --> [base4]";
        if(vks[i] == 2) admnivel2="{BF4D00}Membro --> [base4]";
        if(vks[i] == 3) admnivel2="{BF4D00}Recrutador --> [base4]";
        if(vks[i] == 4) admnivel2="{BF4D00}Sub-Lider --> [base4]";
        if(vks[i] == 5) admnivel2="{BF4D00}Lider --> [base4]";
        if(vks[i] == 6) admnivel2="{BF4D00}Dono --> [base4]";
        {
		   if(vks[i] > 0)
		    {
			    if(AdmHidden[i] == false || vks[playerid] > 0)
			    {
			    GetPlayerName(i, Name2, sizeof(Name2));
			    if(admscount2 < 15) format(Adms2, sizeof(Adms2), "{FFFFFF}%s\n{FFFFFF}%s (ID:%i) - {FFFFFF}%s", Adms2,Name2,i,admnivel2);
			    admscount2++;
			    }
			}
		}
	}
}
if(admscount2 > 0)
format(ADMsDialog2, sizeof(ADMsDialog2), "%s\n", Adms2);
else
format(ADMsDialog2, sizeof(ADMsDialog2), "{FF0000}Nenhum membro [base4] online.", admscount2,Adms2);
ShowPlayerDialog(playerid,1001,DIALOG_STYLE_MSGBOX,"{BF4D00}Membros Oficiais [base4]:",ADMsDialog2,"OK","");
return 1;}

dcmd_base5(playerid,params[]) {
#pragma unused params
if(mvx[playerid] < 1){
new pname[MAX_PLAYER_NAME];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);}
new Adms2[650],ADMsDialog2[810],Name2[MAX_PLAYER_NAME],admscount2;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
        if(mvx[i] == 1) admnivel2="{420E0B}Convidado --> [base5]";
        if(mvx[i] == 2) admnivel2="{420E0B}Membro --> [base5]";
        if(mvx[i] == 3) admnivel2="{420E0B}Recrutador --> [base5]";
        if(mvx[i] == 4) admnivel2="{420E0B}Sub-Lider --> [base5]";
        if(mvx[i] == 5) admnivel2="{420E0B}Lider --> [base5]";
        if(mvx[i] == 6) admnivel2="{420E0B}Dono --> [base5]";
        {
		   if(mvx[i] > 0)
		    {
			    if(AdmHidden[i] == false || mvx[playerid] > 0)
			    {
			    GetPlayerName(i, Name2, sizeof(Name2));
			    if(admscount2 < 15) format(Adms2, sizeof(Adms2), "{FFFFFF}%s\n{FFFFFF}%s (ID:%i) - {FFFFFF}%s", Adms2,Name2,i,admnivel2);
			    admscount2++;
			    }
			}
		}
	}
}
if(admscount2 > 0)
format(ADMsDialog2, sizeof(ADMsDialog2), "%s\n", Adms2);
else
format(ADMsDialog2, sizeof(ADMsDialog2), "{FF0000}Nenhum membro [base5] online.", admscount2,Adms2);
ShowPlayerDialog(playerid,1001,DIALOG_STYLE_MSGBOX,"{DDE332}Membros Oficiais [base5]:",ADMsDialog2,"OK","");
return 1;}

dcmd_base6(playerid,params[]) {
#pragma unused params
if(boy[playerid] < 1){
new pname[MAX_PLAYER_NAME];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);}
new Adms2[650],ADMsDialog2[810],Name2[MAX_PLAYER_NAME],admscount2;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
        if(boy[i] == 1) admnivel2="{D9FF00}Convidado --> [TnK]";
        if(boy[i] == 2) admnivel2="{D9FF00}Membro --> [TnK]";
        if(boy[i] == 3) admnivel2="{D9FF00}Recrutador --> [TnK]";
        if(boy[i] == 4) admnivel2="{D9FF00}Sub-Lider --> [TnK]";
        if(boy[i] == 5) admnivel2="{D9FF00}Lider --> [TnK]";
        if(boy[i] == 6) admnivel2="{D9FF00}Dono --> [TnK]";
        {
		   if(boy[i] > 0)
		    {
			    if(AdmHidden[i] == false || boy[playerid] > 0)
			    {
			    GetPlayerName(i, Name2, sizeof(Name2));
			    if(admscount2 < 15) format(Adms2, sizeof(Adms2), "{FFFFFF}%s\n{FFFFFF}%s (ID:%i) - {FFFFFF}%s", Adms2,Name2,i,admnivel2);
			    admscount2++;
			    }
			}
		}
	}
}
if(admscount2 > 0)
format(ADMsDialog2, sizeof(ADMsDialog2), "%s\n", Adms2);
else
format(ADMsDialog2, sizeof(ADMsDialog2), "{FF0000}Nenhum membro [TnK] online.", admscount2,Adms2);
ShowPlayerDialog(playerid,1001,DIALOG_STYLE_MSGBOX,"{D9FF00}Membros Oficiais [TnK]:",ADMsDialog2,"OK","");
return 1;}


dcmd_base7(playerid,params[]) {
#pragma unused params
if(nrx[playerid] < 1){
new pname[MAX_PLAYER_NAME];GetPlayerName(playerid, pname, MAX_PLAYER_NAME);}
new Adms2[650],ADMsDialog2[810],Name2[MAX_PLAYER_NAME],admscount2;
for(new i,a = GetMaxPlayers();i < a;i++)
{
    if(IsPlayerConnected(i))
	{
        if(nrx[i] == 1) admnivel2="{FF0000}Convidado --> [base7]";
        if(nrx[i] == 2) admnivel2="{FF0000}Membro --> [base7]";
        if(nrx[i] == 3) admnivel2="{FF0000}Recrutador --> [base7]";
        if(nrx[i] == 4) admnivel2="{FF0000}Sub-Lider --> [base7]";
        if(nrx[i] == 5) admnivel2="{FF0000}Lider --> [base7]";
        if(nrx[i] == 6) admnivel2="{FF0000}Dono --> [base7]";
        {
		   if(nrx[i] > 0)
		    {
			    if(AdmHidden[i] == false || nrx[playerid] > 0)
			    {
			    GetPlayerName(i, Name2, sizeof(Name2));
			    if(admscount2 < 15) format(Adms2, sizeof(Adms2), "{FFFFFF}%s\n{FFFFFF}%s (ID:%i) - {FFFFFF}%s", Adms2,Name2,i,admnivel2);
			    admscount2++;
			    }
			}
		}
	}
}
if(admscount2 > 0)
format(ADMsDialog2, sizeof(ADMsDialog2), "%s\n", Adms2);
else
format(ADMsDialog2, sizeof(ADMsDialog2), "{FF0000}Nenhum membro [base7] online.", admscount2,Adms2);
ShowPlayerDialog(playerid,1001,DIALOG_STYLE_MSGBOX,"{0044FF}Membros Oficiais [base7]:",ADMsDialog2,"OK","");
return 1;}
*/










stock IsPlayerAdminDISABLED(playerid)
{
#pragma unused playerid
return 0;
} 

dcmd_morning(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
      //  CMDMessageToAdmins(playerid,"MORNING");
        return SetPlayerTime(playerid,7,0);
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_adminarea(playerid,params[]) {
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
      //  CMDMessageToAdmins(playerid,"ADMINAREA");
	    SetPlayerPos(playerid, AdminArea[0], AdminArea[1], AdminArea[2]);
	    SetPlayerFacingAngle(playerid, AdminArea[3]);
	    SetPlayerInterior(playerid, AdminArea[4]);
		SetPlayerVirtualWorld(playerid, AdminArea[5]);
		return GameTextForPlayer(playerid,"Bem Vindo Admin!",1000,3);
	} else {
//	   	SetPlayerHealth(playerid,1.0);
   		new string[100]; //format(string, sizeof(string),"%s e usado na adminarea", PlayerName2(playerid) );
	   	MessageToAdmins(red,string);
	} return SendClientMessage(playerid,red, "| ERRO |: Voce deve ser um administrador para usar este comando");
}

dcmd_areavip(playerid,params[]) {
	#pragma unused params
//new string2[300]; //
//new pname[MAX_PLAYER_NAME];
//GetPlayerName(playerid, pname, MAX_PLAYER_NAME);
//format(string2, sizeof(string2), "| INFO |:{00FFE1}O [VIP] {FFFFFF}%s FOI PARA A AREA VIP{00FFE1}(adquira o seu vip em /planosadmin)", pname);
//SendClientMessageToAll(red, string2);

    if(PlayerInfo[playerid][VIP] >= 1 || PlayerInfo[playerid][Level] >= 1) {
      //  CMDMessageToAdmins(playerid,"VIPAREA");
	    SetPlayerPos(playerid, VIPAREA[0], VIPAREA[1], VIPAREA[2]);
	    SetPlayerFacingAngle(playerid, VIPAREA[3]);
	    SetPlayerInterior(playerid, VIPAREA[4]);
		SetPlayerVirtualWorld(playerid, AdminArea[5]);
		return GameTextForPlayer(playerid,"Bem Vindo VIP!",1000,3);
	} else {
	  // 	SetPlayerHealth(playerid,1.0);
   		new string[100]; //format(string, sizeof(string),"%s e usado na adminarea", PlayerName2(playerid));
	   	MessageToAdmins(red,string);
	} return SendClientMessage(playerid,red, "| ERRO |: Voce deve ser um VIP ou Administrador para usar este comando");
}

dcmd_setlevel(playerid,params[]) {
new Nome[MAX_PLAYER_NAME];
GetPlayerName(playerid, Nome, sizeof(Nome));
if(strcmp(Nome, "[SBN]DEAN[SPN]", true) && strcmp(Nome, "(AYS)Xx_Biyel_xX", true)&& strcmp(Nome, "SnowBand", true) && strcmp(Nome, "Spyro", true)&& strcmp(Nome, "[STT]Shadow_RPG.exe", true) && strcmp(Nome, "Deupt", true)) return SendClientMessage(playerid, red, "Você não pode tirar o admin do criador do servidor!");
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 7 || IsPlayerAdmin(playerid)) {
		if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setlevel [playerid] [level]");
	    	new player1, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setlevel [playerid] [level]");
			level = strval(tmp2);

			if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player1][LoggedIn] == 1) {
					if(level > ServerInfo[MaxAdminLevel] ) return SendClientMessage(playerid,red,"| ERRO |: Nivel incorreto");
					if(level == PlayerInfo[player1][Level]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste nivel");
					//if(PlayerInfo[player1][Level] >= 5) return SendClientMessage(playerid,red,"Impossivel rebaixar um Admin level 5");
	       			CMDMessageToAdmins(playerid,"SETLEVEL");
					GetPlayerName(player1, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
			       	new year,month,day;   getdate(year, month, day); new hour,minute,second; gettime(hour,minute,second);

					if(level > 0) format(string,sizeof(string),"Administrador (a) %s definiu seu status de administrador (a) [Nivel %d]",adminname, level);
					else format(string,sizeof(string),"Administrador (a) %s configurou seu status de ADMIN [nivel %d]",adminname, level);
					SendClientMessage(player1,blue,string);

					if(level > PlayerInfo[player1][Level]) GameTextForPlayer(player1,"~b~]ADMIN PROMOVIDO PARABEN!", 2000, 3);
					else GameTextForPlayer(player1,"~r~]ADMIN REBAIXADO SEU N00B!", 2000, 3);

					format(string,sizeof(string),"Voce fez a %s o Nivel %d em %d/%d/%d at %d:%d:%d", playername, level, day, month, year, hour, minute, second); SendClientMessage(playerid,blue,string);
					format(string,sizeof(string),"Administrador %s fez a %s Nivel %d em %d/%d/%d at %d:%d:%d",adminname, playername, level, day, month, year, hour, minute, second);
					SaveToFile("AdminLog",string);
					dUserSetINT(PlayerName2(player1)).("level",(level));
					PlayerInfo[player1][Level] = level;
					return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}


dcmd_setvip(playerid,params[]) {
new Nome[MAX_PLAYER_NAME];
GetPlayerName(playerid, Nome, sizeof(Nome));
if(strcmp(Nome, "[SBN]DEAN[SPN]", true) && strcmp(Nome, "(AYS)Xx_Biyel_xX", true)&& strcmp(Nome, "SnowBand", true) && strcmp(Nome, "Spyro", true)&& strcmp(Nome, "[STT]Shadow_RPG.exe", true) && strcmp(Nome, "Deupt", true)) return SendClientMessage(playerid, red, "Você não pode tirar o admin do criador do servidor!");
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 7 || IsPlayerAdmin(playerid)) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setvip [playerid] [level]");
	    	new player1, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setvip [playerid] [level]");
			level = strval(tmp2);

			if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player1][LoggedIn] == 1) {
				 if(level > ServerInfo[MaxVIPLevel] ) return SendClientMessage(playerid,red,"| ERRO |: Nivel incorreto");
					if(level == PlayerInfo[player1][VIP]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste nivel");
					CMDMessageToAdmins(playerid,"SETVIP");
					GetPlayerName(player1, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
			       	new year,month,day;   getdate(year, month, day); new hour,minute,second; gettime(hour,minute,second);

					if(level > 0) format(string,sizeof(string),"Administrador (a) %s definiu seu VIP (a) [Nivel %d]",adminname, level);
					else format(string,sizeof(string),"Administrador (a) %s configurou seu VIP [nivel %d]",adminname, level);
					SendClientMessage(player1,blue,string);

					if(level > PlayerInfo[player1][VIP]) GameTextForPlayer(player1,"~s~~>~VOCE GANHOU VIP!~<~", 2000, 3);
					else GameTextForPlayer(player1,"~r~~>~VIP RETIRADO!~<~", 2000, 3);

					//format(string,sizeof(string),"Voce fez a %s o Nivel %d em %d/%d/%d at %d:%d:%d", playername, level, day, month, year, hour, minute, second); SendClientMessage(playerid,blue,string);
					format(string,sizeof(string),"Administrador %s fez a %s VIP NIVEL %d em %d/%d/%d at %d:%d:%d",adminname, playername, level, day, month, year, hour, minute, second);
					SaveToFile("VIPLog",string);
					dUserSetINT(PlayerName2(player1)).("VIP",(level));
					PlayerInfo[player1][VIP] = level;
					return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}


dcmd_settemplevel(playerid,params[]) {
new Nome[MAX_PLAYER_NAME];
GetPlayerName(playerid, Nome, sizeof(Nome));
if(strcmp(Nome, "[SBN]DEAN[SPN]", true) && strcmp(Nome, "(AYS)Xx_Biyel_xX", true)&& strcmp(Nome, "SnowBand", true) && strcmp(Nome, "Spyro", true)&& strcmp(Nome, "[STT]Shadow_RPG.exe", true) && strcmp(Nome, "Deupt", true)) return SendClientMessage(playerid, red, "Você não pode tirar o admin do criador do servidor!");
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 7 || IsPlayerAdmin(playerid)) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /settemplevel [playerid] [level]");
	    	new player1, level, string[128];
			player1 = strval(tmp);
			level = strval(tmp2);

			if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			
			if(PlayerInfo[playerid][Level] < 6){if(level >= 3) return SendClientMessage(playerid,red,"| ERRO |: Nivel Incorreto. Max: 2");}
			
			
				if(PlayerInfo[player1][LoggedIn] == 1) {
					//if(level > ServerInfo[MaxAdminLevel] ) return SendClientMessage(playerid,red,"| ERRO |: Nivel Incorreto");
					if(level >= 6) return SendClientMessage(playerid,red,"| ERRO |: Nivel Incorreto. Max: 5");
					if(level == PlayerInfo[player1][Level]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste nivel");
	       			CMDMessageToAdmins(playerid,"SETTEMPLEVEL");
			       	new year,month,day; getdate(year, month, day); new hour,minute,second; gettime(hour,minute,second);

					if(level > 0) format(string,sizeof(string),"Administrador (a) %s temporariamente definiu seus privilégios administrativos [Nivel %d]", pName(playerid), level);
					else format(string,sizeof(string),"Administrador (a) %s temporariamente definiu seus privilegios administrativos [Nivel %d]", pName(playerid), level);
					SendClientMessage(player1,blue,string);

					if(level > PlayerInfo[player1][Level]) GameTextForPlayer(player1,"~g~PROMOVIDO]~n~]TEMP-ADMIN!", 2000, 3);
					else GameTextForPlayer(player1,"~r~]Removido~n~]TEMP-ADMIN!", 2000, 3);

					format(string,sizeof(string),"Voce definiu ao %s Nivel %d em %d/%d/%d at %d:%d:%d", pName(player1), level, day, month, year, hour, minute, second); SendClientMessage(playerid,blue,string);
					format(string,sizeof(string),"Administrador (a) %s definiu %s de nivel temporario em %d on %d/%d/%d at %d:%d:%d",pName(playerid), pName(player1), level, day, month, year, hour, minute, second);
					SaveToFile("TempAdminLog",string);
					PlayerInfo[player1][Level] = level;

					if(PlayerInfo[player1][Level] > 0)
					TempADM[player1] = true;
					else
					TempADM[player1] = false;
					
					return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}





/*
dcmd_setbase1(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
		if(mrj[playerid] >= 0) {

		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /Setbase1 [playerid] [Nivel]");
	    	new player1, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], string2[256], string3[256], string4[256];
			player1 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /Setbase1 [playerid] [Nivel]");
			level = strval(tmp2);

			if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player1][LoggedIn] == 1) {
					if(level == mrj[player1]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste cargo");
                    if(level >= 8) return SendClientMessage(playerid, red, "| ERRO |: Máximo de cargo: 8");
					GetPlayerName(player1, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
					if(level == 0)
					{
					format(string,sizeof(string),"Você removeu o %s do clã (base)",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s Te removeu do clã (base)",adminname);
					SendClientMessage(player1,0xFF0000FF,string);
					}
					if(level == 1)
					{
					format(string2,sizeof(string2),"Você colocou o %s como convidado do clã (base)",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como convidado do clã (base)",adminname);
					SendClientMessage(player1,0xFF0000FF,string2);
					}
					if(level == 2)
					{
					format(string2,sizeof(string2),"Você colocou o %s como membro do clã (base)",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como membro do clã (base)",adminname);
					SendClientMessage(player1,0xFF0000FF,string2);
					}
					if(level == 3)
					{
					format(string3,sizeof(string3),"Você colocou o %s como recrutador do clã (base)",playername);
					SendClientMessage(playerid,0xFF0000FF,string3);
					format(string3,sizeof(string3),"%s colocou você como recrutador do clã (base)",adminname);
					SendClientMessage(player1,0xFF0000FF,string3);
					}
					if(level == 4)
					{
					format(string4,sizeof(string4),"Você colocou o %s como Sub-Lider do clã (base)",playername);
					SendClientMessage(playerid,0xFF0000FF,string4);
					format(string4,sizeof(string4),"%s colocou você como Sub-Lider do clã (base)",adminname);
					SendClientMessage(player1,0xFF0000FF,string4);
					}
                    if(level == 5)
					{
					format(string,sizeof(string),"Você colocou o %s como Lider do clã (base)",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como Lider do clã (base)",adminname);
					SendClientMessage(player1,0xFF0000FF,string);
					}
					if(level == 6)
					{
					format(string,sizeof(string),"Você colocou o %s como dono do clã (base)",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como dono do clã (base)",adminname);
					SendClientMessage(player1,0xFF0000FF,string);
					}

					return mrj[player1] = level;
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}


dcmd_setbase2(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
		if(d3x[playerid] >= 0) {

		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /Setbase2 [playerid] [Nivel]");
	    	new player2, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], string2[256], string3[256], string4[256];
			player2 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /Setbase2 [playerid] [Nivel]");
			level = strval(tmp2);

			if(IsPlayerConnected(player2) && player2 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player2][LoggedIn] == 1) {
					if(level == d3x[player2]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste cargo");
                    if(level >= 7) return SendClientMessage(playerid, red, "| ERRO |: Máximo de cargo: 7");
					GetPlayerName(player2, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
					if(level == 0)
					{
					format(string,sizeof(string),"Você removeu o %s do clã [base2]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s Te removeu do clã [base2]",adminname);
					SendClientMessage(player2,0xFF0000FF,string);
					}
					if(level == 1)
					{
					format(string2,sizeof(string2),"Você colocou o %s como convidado do clã [base2]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como convidado do clã [base2]",adminname);
					SendClientMessage(player2,0xFF0000FF,string2);
					}
					if(level == 2)
					{
					format(string2,sizeof(string2),"Você colocou o %s como membro do clã [base2]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como membro do clã [base2]",adminname);
					SendClientMessage(player2,0xFF0000FF,string2);
					}
					if(level == 3)
					{
					format(string3,sizeof(string3),"Você colocou o %s como recrutador do clã [base2]",playername);
					SendClientMessage(playerid,0xFF0000FF,string3);
					format(string3,sizeof(string3),"%s colocou você como recrutador do clã [base2]",adminname);
					SendClientMessage(player2,0xFF0000FF,string3);
					}
					if(level == 4)
					{
					format(string4,sizeof(string4),"Você colocou o %s como Sub-Lider do clã [base2]",playername);
					SendClientMessage(playerid,0xFF0000FF,string4);
					format(string4,sizeof(string4),"%s colocou você como Sub-Lider do clã [base2]",adminname);
					SendClientMessage(player2,0xFF0000FF,string4);
					}
                    if(level == 5)
					{
					format(string,sizeof(string),"Você colocou o %s como Lider do clã [base2]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como Lider do clã [base2]",adminname);
					SendClientMessage(player2,0xFF0000FF,string);
					}
					if(level == 6)
					{
					format(string,sizeof(string),"Você colocou o %s como dono do clã [base2]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como dono do clã [base2]",adminname);
					SendClientMessage(player2,0xFF0000FF,string);
					}

					return d3x[player2] = level;
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}





dcmd_setbase3(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
		if(bmf[playerid] >= 0) {

		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /Setbase3 [playerid] [Nivel]");
	    	new player3, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], string2[256], string3[256], string4[256];
			player3 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /Setbase3 [playerid] [Nivel]");
			level = strval(tmp2);

			if(IsPlayerConnected(player3) && player3 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player3][LoggedIn] == 1) {
					if(level == bmf[player3]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste cargo");
                    if(level >= 7) return SendClientMessage(playerid, red, "| ERRO |: Máximo de cargo: 7");
					GetPlayerName(player3, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
					if(level == 0)
					{
					format(string,sizeof(string),"Você removeu o %s do clã [base3]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s Te removeu do clã [base3]",adminname);
					SendClientMessage(player3,0xFF0000FF,string);
					}
					if(level == 1)
					{
					format(string2,sizeof(string2),"Você colocou o %s como convidado do clã [base3]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como convidado do clã [base3]",adminname);
					SendClientMessage(player3,0xFF0000FF,string2);
					}
					if(level == 2)
					{
					format(string2,sizeof(string2),"Você colocou o %s como membro do clã [base3]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como membro do clã [base3]",adminname);
					SendClientMessage(player3,0xFF0000FF,string2);
					}
					if(level == 3)
					{
					format(string3,sizeof(string3),"Você colocou o %s como recrutador do clã [base3]",playername);
					SendClientMessage(playerid,0xFF0000FF,string3);
					format(string3,sizeof(string3),"%s colocou você como recrutador do clã [base3]",adminname);
					SendClientMessage(player3,0xFF0000FF,string3);
					}
					if(level == 4)
					{
					format(string4,sizeof(string4),"Você colocou o %s como Sub-Lider do clã [base3]",playername);
					SendClientMessage(playerid,0xFF0000FF,string4);
					format(string4,sizeof(string4),"%s colocou você como Sub-Lider do clã [base3]",adminname);
					SendClientMessage(player3,0xFF0000FF,string4);
					}
                    if(level == 5)
					{
					format(string,sizeof(string),"Você colocou o %s como Lider do clã [base3]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como Lider do clã [base3]",adminname);
					SendClientMessage(player3,0xFF0000FF,string);
					}
					if(level == 6)
					{
					format(string,sizeof(string),"Você colocou o %s como dono do clã [base3]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como dono do clã [base3]",adminname);
					SendClientMessage(player3,0xFF0000FF,string);
					}

					return bmf[player3] = level;
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_setbase4(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
		if(vks[playerid] >= 0) {

		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /Setbase4 [playerid] [Nivel]");
	    	new player4, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], string2[256], string3[256], string4[256];
			player4 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /Setbase4 [playerid] [Nivel]");
			level = strval(tmp2);

			if(IsPlayerConnected(player4) && player4 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player4][LoggedIn] == 1) {
					if(level == vks[player4]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste cargo");
                    if(level >= 7) return SendClientMessage(playerid, red, "| ERRO |: Máximo de cargo: 7");
					GetPlayerName(player4, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
					if(level == 0)
					{
					format(string,sizeof(string),"Você removeu o %s do clã [base4]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s Te removeu do clã [base4]",adminname);
					SendClientMessage(player4,0xFF0000FF,string);
					}
					if(level == 1)
					{
					format(string2,sizeof(string2),"Você colocou o %s como convidado do clã [base4]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como convidado do clã [base4]",adminname);
					SendClientMessage(player4,0xFF0000FF,string2);
					}
					if(level == 2)
					{
					format(string2,sizeof(string2),"Você colocou o %s como membro do clã [base4]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como membro do clã [base4]",adminname);
					SendClientMessage(player4,0xFF0000FF,string2);
					}
					if(level == 3)
					{
					format(string3,sizeof(string3),"Você colocou o %s como recrutador do clã [base4]",playername);
					SendClientMessage(playerid,0xFF0000FF,string3);
					format(string3,sizeof(string3),"%s colocou você como recrutador do clã [base4]",adminname);
					SendClientMessage(player4,0xFF0000FF,string3);
					}
					if(level == 4)
					{
					format(string4,sizeof(string4),"Você colocou o %s como Sub-Lider do clã [base4]",playername);
					SendClientMessage(playerid,0xFF0000FF,string4);
					format(string4,sizeof(string4),"%s colocou você como Sub-Lider do clã [base4]",adminname);
					SendClientMessage(player4,0xFF0000FF,string4);
					}
                    if(level == 5)
					{
					format(string,sizeof(string),"Você colocou o %s como Lider do clã [base4]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como Lider do clã [base4]",adminname);
					SendClientMessage(player4,0xFF0000FF,string);
					}
					if(level == 6)
					{
					format(string,sizeof(string),"Você colocou o %s como dono do clã [base4]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como dono do clã [base4]",adminname);
					SendClientMessage(player4,0xFF0000FF,string);
					}

					return vks[player4] = level;
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}



dcmd_setbase5(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
		if(mvx[playerid] >= 0) {

		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /Setbase5 [playerid] [Nivel]");
	    	new player5, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], string2[256], string3[256], string4[256];
			player5 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /Setbase5 [playerid] [Nivel]");
			level = strval(tmp2);

			if(IsPlayerConnected(player5) && player5 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player5][LoggedIn] == 1) {
					if(level == mvx[player5]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste cargo");
                    if(level >= 7) return SendClientMessage(playerid, red, "| ERRO |: Máximo de cargo: 7");
					GetPlayerName(player5, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
					if(level == 0)
					{
					format(string,sizeof(string),"Você removeu o %s do clã [base5]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s Te removeu do clã [base5]",adminname);
					SendClientMessage(player5,0xFF0000FF,string);
					}
					if(level == 1)
					{
					format(string2,sizeof(string2),"Você colocou o %s como convidado do clã [base5]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como convidado do clã [base5]",adminname);
					SendClientMessage(player5,0xFF0000FF,string2);
					}
					if(level == 2)
					{
					format(string2,sizeof(string2),"Você colocou o %s como membro do clã [base5]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como membro do clã [base5]",adminname);
					SendClientMessage(player5,0xFF0000FF,string2);
					}
					if(level == 3)
					{
					format(string3,sizeof(string3),"Você colocou o %s como recrutador do clã [base5]",playername);
					SendClientMessage(playerid,0xFF0000FF,string3);
					format(string3,sizeof(string3),"%s colocou você como recrutador do clã [base5]",adminname);
					SendClientMessage(player5,0xFF0000FF,string3);
					}
					if(level == 4)
					{
					format(string4,sizeof(string4),"Você colocou o %s como Sub-Lider do clã [base5]",playername);
					SendClientMessage(playerid,0xFF0000FF,string4);
					format(string4,sizeof(string4),"%s colocou você como Sub-Lider do clã [base5]",adminname);
					SendClientMessage(player5,0xFF0000FF,string4);
					}
                    if(level == 5)
					{
					format(string,sizeof(string),"Você colocou o %s como Lider do clã [base5]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como Lider do clã [base5]",adminname);
					SendClientMessage(player5,0xFF0000FF,string);
					}
					if(level == 6)
					{
					format(string,sizeof(string),"Você colocou o %s como dono do clã [base5]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como dono do clã [base5]",adminname);
					SendClientMessage(player5,0xFF0000FF,string);
					}

					return mvx[player5] = level;
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}


dcmd_setbase6(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
		if(boy[playerid] >= 0) {

		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /Setbase6 [playerid] [Nivel]");
	    	new player6, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], string2[256], string3[256], string4[256];
			player6 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /Setbase6 [playerid] [Nivel]");
			level = strval(tmp2);

			if(IsPlayerConnected(player6) && player6 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player6][LoggedIn] == 1) {
					if(level == boy[player6]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste cargo");
                    if(level >= 7) return SendClientMessage(playerid, red, "| ERRO |: Máximo de cargo: 7");
					GetPlayerName(player6, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
					if(level == 0)
					{
					format(string,sizeof(string),"Você removeu o %s do clã [base6]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s Te removeu do clã [base6]",adminname);
					SendClientMessage(player6,0xFF0000FF,string);
					}
					if(level == 1)
					{
					format(string2,sizeof(string2),"Você colocou o %s como convidado do clã [base6]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como convidado do clã [base6]",adminname);
					SendClientMessage(player6,0xFF0000FF,string2);
					}
					if(level == 2)
					{
					format(string2,sizeof(string2),"Você colocou o %s como membro do clã [base6]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como membro do clã [base6]",adminname);
					SendClientMessage(player6,0xFF0000FF,string2);
					}
					if(level == 3)
					{
					format(string3,sizeof(string3),"Você colocou o %s como recrutador do clã [base6]",playername);
					SendClientMessage(playerid,0xFF0000FF,string3);
					format(string3,sizeof(string3),"%s colocou você como recrutador do clã [base6]",adminname);
					SendClientMessage(player6,0xFF0000FF,string3);
					}
					if(level == 4)
					{
					format(string4,sizeof(string4),"Você colocou o %s como Sub-Lider do clã [base6]",playername);
					SendClientMessage(playerid,0xFF0000FF,string4);
					format(string4,sizeof(string4),"%s colocou você como Sub-Lider do clã [base6]",adminname);
					SendClientMessage(player6,0xFF0000FF,string4);
					}
                    if(level == 5)
					{
					format(string,sizeof(string),"Você colocou o %s como Lider do clã [base6]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como Lider do clã [base6]",adminname);
					SendClientMessage(player6,0xFF0000FF,string);
					}
					if(level == 6)
					{
					format(string,sizeof(string),"Você colocou o %s como dono do clã [base6]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como dono do clã [base6]",adminname);
					SendClientMessage(player6,0xFF0000FF,string);
					}

					return boy[player6] = level;
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

dcmd_setbase7(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1) {
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
		if(nrx[playerid] >= 0) {

		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /Setbase7 [playerid] [Nivel]");
	    	new player7, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], string2[256], string3[256], string4[256];
			player7 = strval(tmp);
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /Setbase7 [playerid] [Nivel]");
			level = strval(tmp2);

			if(IsPlayerConnected(player7) && player7 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player7][LoggedIn] == 1) {
					if(level == nrx[player7]) return SendClientMessage(playerid,red,"| ERRO |: Jogador ja esta neste cargo");
                    if(level >= 7) return SendClientMessage(playerid, red, "| ERRO |: Máximo de cargo: 7");
					GetPlayerName(player7, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
					if(level == 0)
					{
					format(string,sizeof(string),"Você removeu o %s do clã [base7]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s Te removeu do clã [base7]",adminname);
					SendClientMessage(player7,0xFF0000FF,string);
					}
					if(level == 1)
					{
					format(string2,sizeof(string2),"Você colocou o %s como convidado do clã [base7]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como convidado do clã [base7]",adminname);
					SendClientMessage(player7,0xFF0000FF,string2);
					}
					if(level == 2)
					{
					format(string2,sizeof(string2),"Você colocou o %s como membro do clã [base7]",playername);
					SendClientMessage(playerid,0xFF0000FF,string2);
					format(string2,sizeof(string2),"%s colocou você como membro do clã [base7]",adminname);
					SendClientMessage(player7,0xFF0000FF,string2);
					}
					if(level == 3)
					{
					format(string3,sizeof(string3),"Você colocou o %s como recrutador do clã [base7]",playername);
					SendClientMessage(playerid,0xFF0000FF,string3);
					format(string3,sizeof(string3),"%s colocou você como recrutador do clã [base7]",adminname);
					SendClientMessage(player7,0xFF0000FF,string3);
					}
					if(level == 4)
					{
					format(string4,sizeof(string4),"Você colocou o %s como Sub-Lider do clã [base7]",playername);
					SendClientMessage(playerid,0xFF0000FF,string4);
					format(string4,sizeof(string4),"%s colocou você como Sub-Lider do clã [base7]",adminname);
					SendClientMessage(player7,0xFF0000FF,string4);
					}
                    if(level == 5)
					{
					format(string,sizeof(string),"Você colocou o %s como Lider do clã [base7]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como Lider do clã [base7]",adminname);
					SendClientMessage(player7,0xFF0000FF,string);
					}
					if(level == 6)
					{
					format(string,sizeof(string),"Você colocou o %s como dono do clã [base7]",playername);
					SendClientMessage(playerid,0xFF0000FF,string);
					format(string,sizeof(string),"%s colocou você como dono do clã [base7]",adminname);
					SendClientMessage(player7,0xFF0000FF,string);
					}

					return nrx[player7] = level;
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
				} else return SendClientMessage(playerid,red,"| ERRO |: Jogador deve estar registrado e logado como admin");
			} else return SendClientMessage(playerid, red, "Jogador nao esta conectado");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve estar logado para usar estes comandos");
}

*/











dcmd_report(playerid,params[])
{
TakeReport(playerid,params);
return 1;
}

dcmd_reportar(playerid,params[])
{
TakeReport(playerid,params);
return 1;
}

dcmd_x9(playerid,params[])
{
TakeReport2(playerid,params);
return 1;
}

TakeReport(playerid,params[]) {
    new reported, tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /report [playerid] [motivo]");
    if(!IsNumeric(tmp) || !strlen(tmp)) return SendClientMessage(playerid, red, "| USO |: /report [playerid] [motivo]");
    if(!strlen(params[strlen(tmp)+1])) return SendClientMessage(playerid, red, "| USO |: /report [playerid] [motivo]");
    if(strlen(params[strlen(tmp)+1]) > 60) return SendClientMessage(playerid, red, "| ERRO |: O report está muito grande");
    if(strlen(params[strlen(tmp)+1]) < 2) return SendClientMessage(playerid, red, "| ERRO |: O report está muito pequeno");
	reported = strval(tmp);
 	if(IsPlayerConnected(reported) && reported != INVALID_PLAYER_ID) {
		if(PlayerInfo[reported][Level] >= 2 && AdmHidden[reported] == false) return SendClientMessage(playerid,red,"| ERRO |: Você não pode reportar um administrador");
		if(TimeStamp()-ReportTick[playerid] < 60) return SendClientMessage(playerid,red,"| ERRO |: Você só pode efetuar um report por minuto. Aguarde e tente novamente mais tarde");
		if(playerid == reported) return SendClientMessage(playerid,red,"| ERRO |: Você não pode se reportar");
			new reportedname[MAX_PLAYER_NAME], reporter[MAX_PLAYER_NAME], str[128], hour,minute,second; gettime(hour,minute,second);
			GetPlayerName(reported, reportedname, sizeof(reportedname));	GetPlayerName(playerid, reporter, sizeof(reporter));
			format(str, sizeof(str), "[REPORT]: %s(%d) reportou %s(%d) Motivo: %s |@%d:%d:%d|", reporter,playerid, reportedname, reported, params[strlen(tmp)+1], hour,minute,second);
			ReportTick[playerid] = TimeStamp();
			MessageToAdmins(COLOR_WHITE,str);
			BeepToAdmins();
			GameTextToAdmins("_~n~_~n~_~n~_~n~_~n~~r~~h~>>> ~y~NOVO REPORT ~r~~h~<<<",5000,5);
			printf(str);
			SaveToFile("ReportLog",str);
			format(str, sizeof(str), "[%d:%d:%d]: %s(%d) reportou %s(%d) Motivo: %s", hour,minute,second, reporter,playerid, reportedname, reported, params[strlen(tmp)+1]);
			for(new i = 1; i < MAX_REPORTS-1; i++) Reports[i] = Reports[i+1];
			Reports[MAX_REPORTS-1] = str;
			return SendClientMessage(playerid,green, "| INFO |: Seu report foi enviado a todos os administradores online!");
	} else return SendClientMessage(playerid, red, "| ERRO |: O jogador não está online");
}

TakeReport2(playerid,params[]) {
    new reported, tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /x9 [playerid] [motivo]");
    if(!IsNumeric(tmp) || !strlen(tmp)) return SendClientMessage(playerid, red, "| USO |: /x9 [playerid] [motivo]");
    if(!strlen(params[strlen(tmp)+1])) return SendClientMessage(playerid, red, "| USO |: /x9 [playerid] [motivo]");
    if(strlen(params[strlen(tmp)+1]) > 60) return SendClientMessage(playerid, red, "| ERRO |: O report está muito grande");
    if(strlen(params[strlen(tmp)+1]) < 2) return SendClientMessage(playerid, red, "| ERRO |: O report está muito pequeno");
	reported = strval(tmp);
 	if(IsPlayerConnected(reported) && reported != INVALID_PLAYER_ID) {
		if(PlayerInfo[reported][Level] >= 2 && AdmHidden[reported] == false) return SendClientMessage(playerid,red,"| ERRO |: Você não pode reportar um administrador");
		if(TimeStamp()-ReportTick[playerid] < 60) return SendClientMessage(playerid,red,"| ERRO |: Você só pode efetuar um report por minuto. Aguarde e tente novamente mais tarde");
		if(playerid == reported) return SendClientMessage(playerid,red,"| ERRO |: Você não pode se reportar");
			new reportedname[MAX_PLAYER_NAME], reporter[MAX_PLAYER_NAME], str[128], hour,minute,second; gettime(hour,minute,second);
			GetPlayerName(reported, reportedname, sizeof(reportedname));	GetPlayerName(playerid, reporter, sizeof(reporter));
			format(str, sizeof(str), "[REPORT]: %s(%d) reportou %s(%d) Motivo: %s |@%d:%d:%d|", reporter,playerid, reportedname, reported, params[strlen(tmp)+1], hour,minute,second);
			ReportTick[playerid] = TimeStamp();
			MessageToAdmins(COLOR_WHITE,str);
			BeepToAdmins();
			GameTextToAdmins("_~n~_~n~_~n~_~n~_~n~_~n~~r~~h~>>> ~y~NOVO REPORT ~r~~h~<<<",5000,5);
			printf(str);
			SaveToFile("ReportLog",str);
			format(str, sizeof(str), "[%d:%d:%d]: %s(%d) reportou %s(%d) Motivo: %s", hour,minute,second, reporter,playerid, reportedname, reported, params[strlen(tmp)+1]);
			for(new i = 1; i < MAX_REPORTS-1; i++) Reports[i] = Reports[i+1];
			Reports[MAX_REPORTS-1] = str;
			return SendClientMessage(playerid,green, "| INFO |: Seu report foi enviado a todos os administradores online!");
	} else return SendClientMessage(playerid, red, "| ERRO |: O jogador não está online");
}

dcmd_reports(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        new ReportCount;
		for(new i = 1; i < MAX_REPORTS; i++)
		{
			if(strcmp( Reports[i], "<none>", true) != 0) { ReportCount++; SendClientMessage(playerid,COLOR_WHITE,Reports[i]); }
		}
		if(ReportCount == 0) SendClientMessage(playerid,green,"| INFO |: Sem reports");
    } else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;
}

dcmd_richlist(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
 		new string[128], Slot1 = -1, Slot2 = -1, Slot3 = -1, Slot4 = -1, HighestCash = -9999;
 		SendClientMessage(playerid,COLOR_WHITE,"Mais ricos (ELITE):");

		for(new x=0; x<MAX_PLAYERS; x++) if (IsPlayerConnected(x)) if (GetPlayerCash(x) >= HighestCash) {
			HighestCash = GetPlayerCash(x);
			Slot1 = x;
		}
		HighestCash = -9999;
		for(new x=0; x<MAX_PLAYERS; x++) if (IsPlayerConnected(x) && x != Slot1) if (GetPlayerCash(x) >= HighestCash) {
			HighestCash = GetPlayerCash(x);
			Slot2 = x;
		}
		HighestCash = -9999;
		for(new x=0; x<MAX_PLAYERS; x++) if (IsPlayerConnected(x) && x != Slot1 && x != Slot2) if (GetPlayerCash(x) >= HighestCash) {
			HighestCash = GetPlayerCash(x);
			Slot3 = x;
		}
		HighestCash = -9999;
		for(new x=0; x<MAX_PLAYERS; x++) if (IsPlayerConnected(x) && x != Slot1 && x != Slot2 && x != Slot3) if (GetPlayerCash(x) >= HighestCash) {
			HighestCash = GetPlayerCash(x);
			Slot4 = x;
		}
		format(string, sizeof(string), "(%d) %s - $%d", Slot1,PlayerName2(Slot1),GetPlayerCash(Slot1) );
		SendClientMessage(playerid,COLOR_WHITE,string);
		if(Slot2 != -1)	{
			format(string, sizeof(string), "(%d) %s - $%d", Slot2,PlayerName2(Slot2),GetPlayerCash(Slot2) );
			SendClientMessage(playerid,COLOR_WHITE,string);
		}
		if(Slot3 != -1)	{
			format(string, sizeof(string), "(%d) %s - $%d", Slot3,PlayerName2(Slot3),GetPlayerCash(Slot3) );
			SendClientMessage(playerid,COLOR_WHITE,string);
		}
		if(Slot4 != -1)	{
			format(string, sizeof(string), "(%d) %s - $%d", Slot4,PlayerName2(Slot4),GetPlayerCash(Slot4) );
			SendClientMessage(playerid,COLOR_WHITE,string);
		}
		return 1;
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_miniguns(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
		new bool:First2 = false, Count, string[128], i, slot, weap, ammo;
		for(i = 0; i < GetMaxPlayers(); i++) {
			if(IsPlayerConnected(i)) {
				for(slot = 0; slot < 14; slot++) {
					GetPlayerWeaponData(i, slot, weap, ammo);
					if(ammo != 0 && weap == 38) {
					    Count++;
						if(!First2) { format(string, sizeof(string), "Minigun: (%d)%s(ammo%d)", i, PlayerName2(i), ammo); First2 = true; }
				        else format(string,sizeof(string),"%s, (%d)%s(ammo%d) ",string, i, PlayerName2(i), ammo);
					}
				}
    	    }
		}
		if(Count == 0) return SendClientMessage(playerid,COLOR_WHITE,"Nao existe jogadores com minigun"); else return SendClientMessage(playerid,COLOR_WHITE,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_uconfig(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 7)
	{
		UpdateConfig();
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return CMDMessageToAdmins(playerid,"UCONFIG");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_botcheck(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 5) {
		for(new i; i < GetMaxPlayers(); i++) BotCheck(i);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return CMDMessageToAdmins(playerid,"BOTCHECK");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lockservermm(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /lockserver [password]");
    	new adminname[MAX_PLAYER_NAME], string[128];
		ServerInfo[Locked] = 1;
		strmid(ServerInfo[Password], params[0], 0, strlen(params[0]), 128);
		GetPlayerName(playerid, adminname, sizeof(adminname));
		format(string, sizeof(string), "Administrador (a) \"%s\" travou o servidor",adminname);
  		SendClientMessageToAll(red,"________________________________________");
  		SendClientMessageToAll(red," ");
		SendClientMessageToAll(red,string);
		SendClientMessageToAll(red,"________________________________________");
		for(new i = 0; i <= MAX_PLAYERS; i++) if(IsPlayerConnected(i)) { PlayerPlaySound(i,1057,0.0,0.0,0.0); PlayerInfo[i][AllowedIn] = true; }
		CMDMessageToAdmins(playerid,"LOCKSERVER");
		format(string, sizeof(string), "Administrador (a) \"%s\" definiu a senha do servidor para '%s'",adminname, ServerInfo[Password] );
		return MessageToAdmins(COLOR_WHITE, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_unlockservermm(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 7) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(ServerInfo[Locked] == 1) {
	    	new adminname[MAX_PLAYER_NAME], string[128];
			ServerInfo[Locked] = 0;
			strmid(ServerInfo[Password], "", 0, strlen(""), 128);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			format(string, sizeof(string), "Administrador (a) \"%s\" destravou o servidor",adminname);
  			SendClientMessageToAll(green,"________________________________________");
	  		SendClientMessageToAll(green," ");
			SendClientMessageToAll(green,string);
			SendClientMessageToAll(green,"________________________________________");
			for(new i = 0; i <= MAX_PLAYERS; i++) if(IsPlayerConnected(i)) { PlayerPlaySound(i,1057,0.0,0.0,0.0); PlayerInfo[i][AllowedIn] = true; }
			return CMDMessageToAdmins(playerid,"UNLOCKSERVER");
		} else return SendClientMessage(playerid,red,"| ERRO |: Servidor nao esta travado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_passwordmm(playerid,params[]) {
	if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /password [password]");
	if(ServerInfo[Locked] == 1) {
	    if(PlayerInfo[playerid][AllowedIn] == false) {
			if(!strcmp(ServerInfo[Password],params[0],true)) {
				KillTimer( LockKickTimer[playerid] );
				PlayerInfo[playerid][AllowedIn] = true;
				new string[128];
				SendClientMessage(playerid,COLOR_WHITE,"Voce entrou com sucesso no servidor com a senha");
				format(string, sizeof(string), "%s entrou com sucesso no servidor com a senha",PlayerName2(playerid));
				return MessageToAdmins(COLOR_WHITE, string);
			} else return SendClientMessage(playerid,red,"| ERRO |: Senha do servidor incorreta");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce ja esta logado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Servidor nao esta trancado");
}

//------------------------------------------------------------------------------
dcmd_forbidname(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 4) {
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /forbidname [nickname]");
		new File:BLfile, string[128];
		BLfile = fopen("ladmin/config/ForbiddenNames.cfg",io_append);
		format(string,sizeof(string),"%s\r\n",params[1]);
		fwrite(BLfile,string);
		fclose(BLfile);
		UpdateConfig();
	CMDMessageToAdmins(playerid,"FORBIDNAME");
		format(string, sizeof(string), "Administrador (a) \"%s\" adicionou o nome \"%s\" na lista de nicks bloqueados", pName(playerid), params );
		return MessageToAdmins(green,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_forbidword(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 4) {
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /forbidword [word]");
		new File:BLfile, string[128];
		BLfile = fopen("ladmin/config/ForbiddenWords.cfg",io_append);
		format(string,sizeof(string),"%s\r\n",params[1]);
		fwrite(BLfile,string);
		fclose(BLfile);
		UpdateConfig();
	CMDMessageToAdmins(playerid,"FORBIDWORD");
		format(string, sizeof(string), "Administrador (a) \"%s\" adicionou o nome \"%s\" na lista de nicks bloqueados", pName(playerid), params );
		return MessageToAdmins(green,string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
/*
//==========================[ Spectate Commands ]===============================
#if defined ENABLE_SPEC

dcmd_lspec(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params) || !IsNumeric(params)) return SendClientMessage(playerid, red, "| USO |: /lspec [playerid]");
		new specplayerid = strval(params);
		if(PlayerInfo[specplayerid][Level] == ServerInfo[MaxAdminLevel]+1 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(specplayerid) && specplayerid != INVALID_PLAYER_ID) {
			if(specplayerid == playerid) return SendClientMessage(playerid, red, "| ERRO |: Voce nao pode se assistir");
			if(GetPlayerState(specplayerid) == PLAYER_STATE_SPECTATING && PlayerInfo[specplayerid][SpecID] != INVALID_PLAYER_ID) return SendClientMessage(playerid, red, "Spectate: Player spectating someone else");
			if(!IsPlayerSpawned(specplayerid)){return SendClientMessage(playerid, red, "| ERRO |: Jogador não está nascido.");}
			if(GetPlayerState(specplayerid) != 1 && GetPlayerState(specplayerid) != 2 && GetPlayerState(specplayerid) != 3) return SendClientMessage(playerid, red, "Spectate: Player not spawned");
			if( (PlayerInfo[specplayerid][Level] != ServerInfo[MaxAdminLevel]) || (PlayerInfo[specplayerid][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] == ServerInfo[MaxAdminLevel]) )	{
				StartSpectate(playerid, specplayerid);
				CMDMessageToAdmins(playerid,"LSPEC");
				GetPlayerPos(playerid,Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]);
				GetPlayerFacingAngle(playerid,Pos[playerid][3]);
				return SendClientMessage(playerid,blue,"Assistindo...");
			} else return SendClientMessage(playerid,red,"| ERRO |: Voce nao pode assistir um admin de alto nivel");
		} else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_lspecvehicle(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /lspecvehicle [vehicleid]");
	    if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid, red, "| ERRO |: Comando desativado");
		new specvehicleid = strval(params);
		if(specvehicleid < MAX_VEHICLES) {
			TogglePlayerSpectating(playerid, 1);
			PlayerSpectateVehicle(playerid, specvehicleid);
			PlayerInfo[playerid][SpecID] = specvehicleid;
			PlayerInfo[playerid][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
			CMDMessageToAdmins(playerid,"SPEC VEHICLE");
			GetPlayerPos(playerid,Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]);
			GetPlayerFacingAngle(playerid,Pos[playerid][3]);
			return SendClientMessage(playerid,blue,"Assitindo...");
		} else return SendClientMessage(playerid,red, "| ERRO |: ID de veiculo invalida");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
dcmd_lspecoff(playerid,params[]) {
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
        if(PlayerInfo[playerid][SpecType] != ADMIN_SPEC_TYPE_NONE) {
			StopSpectate(playerid);
			//SetTimerEx("PosAfterSpec",3000,0,"d",playerid);
			return SendClientMessage(playerid,blue,"Nao esta mais assistindo");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce nao esta assistindo");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

#endif
*/
//==========================[ CHAT COMMANDS ]===================================

dcmd_disablechat(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
		CMDMessageToAdmins(playerid,"DISABLECHAT");
		new string[128];
		if(ServerInfo[DisableChat] == 0) {
			ServerInfo[DisableChat] = 1;
			format(string,sizeof(string),"Administrador (a) \"%s\" desativou o chat", pName(playerid) );
		} else {
			ServerInfo[DisableChat] = 0;
			format(string,sizeof(string),"Administrador (a) \"%s\" ativou o chat", pName(playerid) );
		} return SendClientMessageToAll(blue,string);
 	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_clearchat(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		CMDMessageToAdmins(playerid,"CLEARCHAT");
		for(new i = 0; i < 11; i++) SendClientMessageToAll(green," "); return 1;
 	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_clearallchat(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3) {
	for(new i = 0; i < 100; i++) SendClientMessageToAll(green," ");
		CMDMessageToAdmins(playerid,"CLEARALLCHAT");
		return 1;
 	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_caps(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    if(PlayerInfo[playerid][Level] >= 6) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || IsNumeric(tmp2)) return SendClientMessage(playerid, red, "| USO |: /caps [playerid] [\"on\" / \"off\"]");
		new player1 = strval(tmp), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			if(strcmp(tmp2,"on",true) == 0)	{
		//		CMDMessageToAdmins(playerid,"CAPS");
				PlayerInfo[player1][Caps] = 0;
				if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" permitiu maiusculas no chat", pName(playerid) ); SendClientMessage(playerid,blue,string); }
				format(string,sizeof(string),"Voce permitiu \"%s\" usar maiusculas no chat", pName(player1) ); return SendClientMessage(playerid,blue,string);
			} else if(strcmp(tmp2,"off",true) == 0)	{
		CMDMessageToAdmins(playerid,"CAPS");
				PlayerInfo[player1][Caps] = 1;
				if(player1 != playerid) { format(string,sizeof(string),"Administrador (a) \"%s\" desativou o uso de maiusculas no chat", pName(playerid) ); SendClientMessage(playerid,blue,string); }
				format(string,sizeof(string),"Voce desativou \"%s\" de usar maiusculas no chat", pName(player1) ); return SendClientMessage(playerid,blue,string);
			} else return SendClientMessage(playerid, red, "| USO |: /caps [playerid] [\"on\" / \"off\"]");
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

//==================[ Object & Pickup ]=========================================
dcmd_pickup(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    if(PlayerInfo[playerid][Level] >= 5 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |: /pickup [pickup id]");
	    new pickup = strval(params), string[128], Float:x, Float:y, Float:z, Float:a;
	  //  CMDMessageToAdmins(playerid,"PICKUP");
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);
		x += (3 * floatsin(-a, degrees));
		y += (3 * floatcos(-a, degrees));
		CreatePickup(pickup, 2, x+2, y, z);
		format(string, sizeof(string), "CreatePickup(%d, 2, %0.2f, %0.2f, %0.2f);", pickup, x+2, y, z);
       	SaveToFile("Pickups",string);
		return SendClientMessage(playerid,yellow, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_object(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    if(PlayerInfo[playerid][Level] >= 7 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"| USO |:ect [object id]");
	    new object = strval(params), string[128], Float:x, Float:y, Float:z, Float:a;
	  //  CMDMessageToAdmins(playerid,"OBJECT");
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);
		x += (3 * floatsin(-a, degrees));
		y += (3 * floatcos(-a, degrees));
		CreateObject(object, x, y, z, 0.0, 0.0, a);
		format(string, sizeof(string), "CreateObject(%d, %0.2f, %0.2f, %0.2f, 0.00, 0.00, %0.2f);", object, x, y, z, a);
       	SaveToFile("Objects",string);
		format(string, sizeof(string), "Voce criou um objeto: %d, at %0.2f, %0.2f, %0.2f Angle %0.2f", object, x, y, z, a);
		return SendClientMessage(playerid,yellow, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

//===================[ Move ]===================================================

dcmd_move(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /move [up / down / +x / -x / +y / -y / off]");
		new Float:X, Float:Y, Float:Z;
		if(strcmp(params,"up",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X,Y,Z+5); SetCameraBehindPlayer(playerid); }
		else if(strcmp(params,"down",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X,Y,Z-5); SetCameraBehindPlayer(playerid); }
		else if(strcmp(params,"+x",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X+5,Y,Z);	}
		else if(strcmp(params,"-x",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X-5,Y,Z); }
		else if(strcmp(params,"+y",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X,Y+5,Z);	}
		else if(strcmp(params,"-y",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X,Y-5,Z);	}
	    else if(strcmp(params,"off",true) == 0)	{
			TogglePlayerControllable(playerid,true);	}
		else return SendClientMessage(playerid,red,"| USO |: /move [up / down / +x / -x / +y / -y / off]");
		return 1;
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_moveplayer(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp)) return SendClientMessage(playerid, red, "| USO |: /moveplayer [playerid] [up / down / +x / -x / +y / -y / off]");
	    new Float:X, Float:Y, Float:Z, player1 = strval(tmp);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
		if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			if(strcmp(tmp2,"up",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X,Y,Z+5); SetCameraBehindPlayer(player1);	}
			else if(strcmp(tmp2,"down",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X,Y,Z-5); SetCameraBehindPlayer(player1);	}
			else if(strcmp(tmp2,"+x",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X+5,Y,Z);	}
			else if(strcmp(tmp2,"-x",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X-5,Y,Z); }
			else if(strcmp(tmp2,"+y",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X,Y+5,Z);	}
			else if(strcmp(tmp2,"-y",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X,Y-5,Z);	}
			else SendClientMessage(playerid,red,"| USO |: /moveplayer [up / down / +x / -x / +y / -y / off]");
			return 1;
		} else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

//===================[ Fake ]===================================================

#if defined ENABLE_FAKE_CMDS
dcmd_fakedeath(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 6) {
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !strlen(tmp3)) return SendClientMessage(playerid, red, "| USO |: /fakedeath [killer] [killee] [weapon]");
		new killer = strval(tmp), killee = strval(tmp2), weap = strval(tmp3);
		if(!IsValidWeapon(weap)) return SendClientMessage(playerid,red,"| ERRO |: ID de arma invalida");
		if(PlayerInfo[killer][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
		if(PlayerInfo[killee][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");

        if(IsPlayerConnected(killer) && killer != INVALID_PLAYER_ID) {
	        if(IsPlayerConnected(killee) && killee != INVALID_PLAYER_ID) {
	    //	  	CMDMessageToAdmins(playerid,"FAKEDEATH");
				SendDeathMessage(killer,killee,weap);
				return SendClientMessage(playerid,blue,"Mensagem de morte falsa enviada");
		    } else return SendClientMessage(playerid,red,"| ERRO |: Killee nao esta conectado");
	    } else return SendClientMessage(playerid,red,"| ERRO |: Killer nao esta conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_fakechat(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /fakechat [playerid] [text]");
		new player1 = strval(tmp);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	   //     CMDMessageToAdmins(playerid,"FAKECHAT");
			SendPlayerMessageToAll(player1, params[strlen(tmp)+1]);
			return SendClientMessage(playerid,blue,"Mensagem falsa enviada");
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_fakecmd(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 6) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /fakecmd [playerid] [command]");
		new player1 = strval(tmp);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"| ERRO |: Voce deve ser admin de nivel maior");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	  //      CMDMessageToAdmins(playerid,"FAKECMD");
	        CallRemoteFunction("OnPlayerCommandText", "is", player1, tmp2);
			return SendClientMessage(playerid,blue,"Comando falso enviado");
	    } else return SendClientMessage(playerid,red,"| ERRO |: Jogador nao conectado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
#endif

//----------------------------------------------------------------------------//
// 		             	/all Commands                                         //
//----------------------------------------------------------------------------//

dcmd_spawnall(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
CMDMessageToAdmins(playerid,"SPAWNAll");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerPos(i, 0.0, 0.0, 0.0); SpawnPlayer(i);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" fez renascer todos os jogadores", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_muteall(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
	CMDMessageToAdmins(playerid,"MUTEALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); PlayerInfo[i][Muted] = 1; PlayerInfo[i][MuteWarnings] = 0;
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" calou todos", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_unmuteall(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
		CMDMessageToAdmins(playerid,"UNMUTEAll");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); PlayerInfo[i][Muted] = 0; PlayerInfo[i][MuteWarnings] = 0;
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" descalou a todos", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_getall(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
CMDMessageToAdmins(playerid,"GETAll");
		new Float:x,Float:y,Float:z, interior = GetPlayerInterior(playerid);
    	GetPlayerPos(playerid,x,y,z);
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerPos(i,x+(playerid/4)+1,y+(playerid/4),z); SetPlayerInterior(i,interior);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" teleportou todos", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_healall(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 5) {
	CMDMessageToAdmins(playerid,"HEALALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerHealth(i,100.0);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" curou todos os jogadores", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_armourall(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 5) {
	CMDMessageToAdmins(playerid,"ARMOURALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerArmour(i,100.0);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" restaurou o colete de todos", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_killall(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
	CMDMessageToAdmins(playerid,"KILLALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerHealth(i,0.0);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" matou todos os jogadores", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_freezeall(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
	CMDMessageToAdmins(playerid,"FREEZEALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); TogglePlayerControllable(playerid,false); PlayerInfo[i][Frozen] = 1;
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" travou todos os jogadores", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_unfreezeall(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
	CMDMessageToAdmins(playerid,"UNFREEZEALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); TogglePlayerControllable(playerid,true); PlayerInfo[i][Frozen] = 0;
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" destravou todos os jogadores", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_kickallmm(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
	CMDMessageToAdmins(playerid,"KICKALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); Kick(i);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" kickou todos os jogadores", pName(playerid) );
		SaveToFile("KickLog",string);
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_slapall(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 5) {
	CMDMessageToAdmins(playerid,"SLAPALL");
		new Float:x, Float:y, Float:z;
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1190,0.0,0.0,0.0); GetPlayerPos(i,x,y,z);	SetPlayerPos(i,x,y,z+4);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" slapeou todos", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_explodeall(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
	CMDMessageToAdmins(playerid,"EXPLODEALL");
		new Float:x, Float:y, Float:z;
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1190,0.0,0.0,0.0); GetPlayerPos(i,x,y,z);	CreateExplosion(x, y , z, 7, 10.0);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" explodiu todos", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_disarmall(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
	CMDMessageToAdmins(playerid,"DISARMALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); ResetPlayerWeapons(i);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" desarmou todos os jogadores", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_ejectall(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
  //  	CMDMessageToAdmins(playerid,"EJECTALL");
        new Float:x, Float:y, Float:z;
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
			    if(IsPlayerInAnyVehicle(i)) {
					PlayerPlaySound(i,1057,0.0,0.0,0.0); GetPlayerPos(i,x,y,z); SetPlayerPos(i,x,y,z+3);
				}
			}
		}
		new string[128]; format(string,sizeof(string),"Administrador (a) \"%s\" ejetou todos", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

//-------------==== Set All Commands ====-------------//

dcmd_setallskin(playerid,params[]) {
if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	if(PlayerInfo[playerid][Level] >= 5) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setallskin [skinid]");
		new var = strval(params), string[128];
		if(!IsValidSkin(var)) return SendClientMessage(playerid, red, "| ERRO |: Corpo invalido");
     //  	CMDMessageToAdmins(playerid,"SETALLSKIN");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerSkin(i,var);
			}
		}
		format(string,sizeof(string),"Administrador (a) \"%s\" deixou todos os jogadores com o skin '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setallwanted(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setallwanted [wanted level]");
		new var = strval(params), string[128];
    //   	CMDMessageToAdmins(playerid,"SETALLWANTED");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerWantedLevel(i,var);
			}
		}
		format(string,sizeof(string),"Administrador (a) \"%s\" deixou todos os jogadores com o nivel de procurado '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setallweather(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setallweather [weather ID]");
		new var = strval(params), string[128];
  //     	CMDMessageToAdmins(playerid,"SETALLWEATHER");
		SetWeather(var);
		dini_IntSet("ZNS.ini","clima",var);
		format(string,sizeof(string),"Administrador (a) \"%s\" definiu o clima para '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setalltime(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setalltime [hour]");
		new var = strval(params), string[128];
		if(var > 24) return SendClientMessage(playerid, red, "| ERRO |: Horario invalido");
   //    	CMDMessageToAdmins(playerid,"SETALLTIME");
		SetWorldTime(var);
		dini_IntSet("ZNS.ini","horario",var);
		format(string,sizeof(string),"Administrador (a) \"%s\" definiu o horario para '%d:00'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setallworld(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setallworld [virtual world]");
		new var = strval(params), string[128];
    //   	CMDMessageToAdmins(playerid,"SETALLWORLD");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerVirtualWorld(i,var);
			}
		}
		format(string,sizeof(string),"Administrador (a) \"%s\" definiu o mundo virtual de todos os jogadores para '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setallscore(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 7) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setallscore [score]");
		new var = strval(params), string[128];
  //     	CMDMessageToAdmins(playerid,"SETALLSCORE");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerScore(i,var);
			}
		}
		format(string,sizeof(string),"Administrador (a) \"%s\" configurou os pontos de todos os jogadores para '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_setallcash(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /setallcash [Amount]");
		new var = strval(params), string[128];
    //   	CMDMessageToAdmins(playerid,"SETALLCASH");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				ResetPlayerCash(i);
				GivePlayerCash(i,var);
			}
		}
		format(string,sizeof(string),"Administrador (a) \"%s\" definiu o dinheiro de todos para '$%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_giveallcash(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 6) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /giveallcash [Amount]");
		new var = strval(params), string[128];
		if(!IsPlayerAdmin(playerid)) if(var > 2000000) return SendClientMessage(playerid, red, "| ERRO |: Valor muito alto!");
     //  	CMDMessageToAdmins(playerid,"GIVEALLCASH");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				GivePlayerCash(i,var);
			}
		}
		format(string,sizeof(string),"Administrador (a) \"%s\" deu a todos os jogadores a quantia de '$%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

dcmd_giveallweapon(playerid,params[]) {
	if(PlayerInfo[playerid][Level] >= 5) {
	    new tmp[256], tmp2[256], Index, ammo, weap, WeapName[32], string[128]; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) ) return SendClientMessage(playerid, red, "| USO |: /giveallweapon [weapon id/weapon name] [ammo]");
		if(!strlen(tmp2) || !IsNumeric(tmp2) || strval(tmp2) <= 0 || strval(tmp2) > 99999) ammo = 500;
		if(!IsNumeric(tmp)) weap = GetWeaponIDFromName(tmp); else weap = strval(tmp);
	  	if(!IsValidWeapon(weap)) return SendClientMessage(playerid,red,"| ERRO |: Invalid weapon ID");
	  	
       	if(weap == 43||weap == 44||weap == 45||weap == 36||weap == 37 ||weap == 18||weap == 38||weap == 35){
       	SendClientMessage(playerid,red,"| ERRO |: ID de weapon ilegal para player");
       	return 1;}

     // 	CMDMessageToAdmins(playerid,"GIVEALLWEAPON");
		for (new i = 0; i < MAX_PLAYERS; i++) {
		if(IsPlayerConnected(i)){
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				GivePlayerWeapon(i,weap,ammo);
				}
			}
		GetWeaponName(weap, WeapName, sizeof(WeapName) );
		format(string,sizeof(string),"Administrador (a) \"%s\" deu a todos os jogadores uma %s (%d) com %d de munição", pName(playerid), WeapName, weap, ammo);
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}


//================================[ Menu Commands ]=============================

#if defined USE_MENUS

dcmd_lmenu(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LMainMenu,playerid);
        } else return ShowMenuForPlayer(LMainMenu,playerid);
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
dcmd_ltele(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LTele,playerid);
        } else return ShowMenuForPlayer(LTele,playerid);
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
dcmd_lweather(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 3) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LWeather,playerid);
        } else return ShowMenuForPlayer(LWeather,playerid);
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
dcmd_ltime(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 3) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LTime,playerid);
        } else return ShowMenuForPlayer(LTime,playerid);
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
dcmd_cm(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,red,"| ERRO |: You already have a car.");
        else { ShowMenuForPlayer(LCars,playerid); return TogglePlayerControllable(playerid,false);  }
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
dcmd_ltmenu(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        if(IsPlayerInAnyVehicle(playerid)) {
		new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
        switch(LModel) { case 448,461,462,463,468,471,509,510,521,522,523,581,586,449: return SendClientMessage(playerid,red,"| ERRO |: You can not tune this vehicle!"); }
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LTuneMenu,playerid);
        } else return SendClientMessage(playerid,red,"| ERRO |: You do not have a vehicle to tune");
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
dcmd_lweapons(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 3) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(XWeapons,playerid);
        } else return ShowMenuForPlayer(XWeapons,playerid);
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}
dcmd_lvehicle(playerid,params[]) {
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
 		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
        else { ShowMenuForPlayer(LVehicles,playerid); return TogglePlayerControllable(playerid,false);  }
    } else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

#endif

//----------------------===== Place & Skin Saving =====-------------------------
dcmd_gotoplace(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1 && PlayerInfo[playerid][Level] >= 3)	{
	    if (dUserINT(PlayerName2(playerid)).("x")!=0) {
		    PutAtPos(playerid);
			SetPlayerVirtualWorld(playerid, (dUserINT(PlayerName2(playerid)).("world")) );
			return SendClientMessage(playerid,yellow,"Voce se teleportou com sucesso ao local salvo");
		} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve salvar um lugar antes de se teleportar");
	} else return SendClientMessage(playerid,red, "| ERRO |: Voce deve ser uma administrador para usar este comando");
}

dcmd_saveplace(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1 && PlayerInfo[playerid][Level] >= 4)	{
		new Float:x,Float:y,Float:z, interior;
		GetPlayerPos(playerid,x,y,z);	interior = GetPlayerInterior(playerid);
		dUserSetINT(PlayerName2(playerid)).("x",floatround(x));
		dUserSetINT(PlayerName2(playerid)).("y",floatround(y));
		dUserSetINT(PlayerName2(playerid)).("z",floatround(z));
		dUserSetINT(PlayerName2(playerid)).("interior",interior);
		dUserSetINT(PlayerName2(playerid)).("world", (GetPlayerVirtualWorld(playerid)) );
		return SendClientMessage(playerid,yellow,"Voce salvou com sucesso essas coordenadas");
	} else return SendClientMessage(playerid,red, "| ERRO |: Voce deve eser administrador para usar este comando");
}

dcmd_saveskin(playerid,params[]) {
 	if(PlayerInfo[playerid][Level] >= 2 && PlayerInfo[playerid][LoggedIn] == 1) {
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /saveskin [skinid]");
		new string[128], SkinID = strval(params);
		if((SkinID == 0)||(SkinID == 7)||(SkinID >= 9 && SkinID <= 41)||(SkinID >= 43 && SkinID <= 64)||(SkinID >= 66 && SkinID <= 73)||(SkinID >= 75 && SkinID <= 85)||(SkinID >= 87 && SkinID <= 118)||(SkinID >= 120 && SkinID <= 148)||(SkinID >= 150 && SkinID <= 207)||(SkinID >= 209 && SkinID <= 264)||(SkinID >= 274 && SkinID <= 288)||(SkinID >= 290 && SkinID <= 299))
		{
 			dUserSetINT(PlayerName2(playerid)).("FavSkin",SkinID);
		 	format(string, sizeof(string), "Voce salvou com sucesso este corpo (ID %d)",SkinID);
		 	SendClientMessage(playerid,yellow,string);
			SendClientMessage(playerid,yellow,"Digite: /useskin para usar seu corpo ao nascer /dontuseskin para nao usar mais");
			dUserSetINT(PlayerName2(playerid)).("UseSkin",1);
		 	return CMDMessageToAdmins(playerid,"SAVESKIN");
		} else return SendClientMessage(playerid, green, "| ERRO |: Corpo invalido");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve eser administrador para usar este comando");
}

dcmd_useskin(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 2 && PlayerInfo[playerid][LoggedIn] == 1) {
	    dUserSetINT(PlayerName2(playerid)).("UseSkin",1);
    	SetPlayerSkin(playerid,dUserINT(PlayerName2(playerid)).("FavSkin"));
		return SendClientMessage(playerid,yellow,"Corpo agora em uso");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve eser administrador para usar este comando");
}

dcmd_dontuseskin(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 2 && PlayerInfo[playerid][LoggedIn] == 1) {
	    dUserSetINT(PlayerName2(playerid)).("UseSkin",0);
		return SendClientMessage(playerid,yellow,"O Corpo nao sera mais usado");
	} else return SendClientMessage(playerid,red,"| ERRO |: Voce deve eser administrador para usar este comando");
}

//====================== [REGISTER  &  LOGIN] ==================================
#if defined USE_AREGISTER

dcmd_aregister(playerid,params[])
{
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"| CONTA |: Voce ja esta registrado e logado");
    if (udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"| CONTA |: Essa conta ja existe, por favor use '/alogin [senha]'.");
    if (strlen(params) == 0) return SendClientMessage(playerid,red,"| CONTA |: Uso correto: '/aregister [senha]'");
    if (strlen(params) < 4 || strlen(params) > 20) return SendClientMessage(playerid,red,"| CONTA |: Senha deve ser maior que tres caracteres");
    if (udb_Create(PlayerName2(playerid),params))
	{
    	new file[256],name[MAX_PLAYER_NAME], tmp3[100];
    	new strdate[20], year,month,day;	getdate(year, month, day);
		GetPlayerName(playerid,name,sizeof(name)); format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(name));
     	GetPlayerIp(playerid,tmp3,100);	dini_Set(file,"ip",tmp3);
//    	dini_Set(file,"password",params);
	    dUserSetINT(PlayerName2(playerid)).("registered",1);
   		format(strdate, sizeof(strdate), "%d/%d/%d",day,month,year);
		dini_Set(file,"RegisteredDate",strdate);
		dUserSetINT(PlayerName2(playerid)).("loggedin",1);
		dUserSetINT(PlayerName2(playerid)).("banned",0);
		dUserSetINT(PlayerName2(playerid)).("level",0);
	    dUserSetINT(PlayerName2(playerid)).("LastOn",0);
    	dUserSetINT(PlayerName2(playerid)).("money",0);
    	dUserSetINT(PlayerName2(playerid)).("kills",0);
	   	dUserSetINT(PlayerName2(playerid)).("deaths",0);
	    PlayerInfo[playerid][LoggedIn] = 1;
	    PlayerInfo[playerid][Registered] = 1;
	    SendClientMessage(playerid, green, "| CONTA |: Voce esta registrado, voce foi logado automaticamente.");
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return 1;
	}
    return 1;
}

dcmd_alogin(playerid,params[])
{
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"| CONTA |: Voce ja esta logado.");
    if (!udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"| CONTA |: Sua conta nao existe, registre usando: '/aregister [senha]'.");
    if (strlen(params)==0) return SendClientMessage(playerid,red,"| CONTA |: Uso correto: '/alogin [senha]'");
    if (udb_CheckLogin(PlayerName2(playerid),params))
	{
	   	new file[256], tmp3[100], string[128];
	   	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(playerid)) );
   		GetPlayerIp(playerid,tmp3,100);
	   	dini_Set(file,"ip",tmp3);
		LoginPlayer(playerid);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		if(PlayerInfo[playerid][Level] > 0) {
			format(string,sizeof(string),"| CONTA |: Logado com sucesso. (Nivel %d)", PlayerInfo[playerid][Level] );
			return SendClientMessage(playerid,green,string);
       	} else return SendClientMessage(playerid,green,"| CONTA |: Logado com sucesso");
	}
	else {
		PlayerInfo[playerid][FailLogin]++;
		printf("LOGIN: %s falhou no login, Senha errada (%s) Tentativa (%d)", PlayerName2(playerid), params, PlayerInfo[playerid][FailLogin] );
		if(PlayerInfo[playerid][FailLogin] == MAX_FAIL_LOGINS)
		{
			new string[128]; format(string, sizeof(string), "%s doi kickado (Falha no login)", PlayerName2(playerid) );
			SendClientMessageToAll(grey, string); print(string);
			Kick(playerid);
		}
		return SendClientMessage(playerid,red,"| CONTA |: Falha no login! Senha incorreta");
	}
}

dcmd_achangepass(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /achangepass [new password]");
		if(strlen(params) < 4) return SendClientMessage(playerid,red,"| CONTA |: Tamanho da senha incorreto");
		new string[128];
		dUserSetINT(PlayerName2(playerid)).("password_hash",udb_hash(params) );
		dUserSet(PlayerName2(playerid)).("Password",params);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
        format(string, sizeof(string),"| CONTA |: Voce trocou sua senha para [ %s ]",params);
		return SendClientMessage(playerid,yellow,string);
	} else return SendClientMessage(playerid,red, "| ERRO |: Voce deve ter conta para usar este comando");
}

dcmd_asetpass(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 6) {
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    new string[128], tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /asetpass [playername] [new password]");
		if(strlen(tmp2) < 4 || strlen(tmp2) > MAX_PLAYER_NAME) return SendClientMessage(playerid,red,"| ERRO |: Tamanho da senha incorreto");
		if(udb_Exists(tmp)) {
			dUserSetINT(tmp).("password_hash", udb_hash(tmp2));
			PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
    	    format(string, sizeof(string),"| CONTA |: Voce configurou com sucesso: \"%s's\" a senha para \"%s\"", tmp, tmp2);
			return SendClientMessage(playerid,yellow,string);
		} else return SendClientMessage(playerid,red, "| ERRO |: Este jogador nao tem conta");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

#if defined USE_STATS
dcmd_aresetstats(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
		// save as backup
	   	dUserSetINT(PlayerName2(playerid)).("oldkills",PlayerInfo[playerid][Kills]);
	   	dUserSetINT(PlayerName2(playerid)).("olddeaths",PlayerInfo[playerid][Deaths]);
		// stats reset
		PlayerInfo[playerid][Kills] = 0;
		PlayerInfo[playerid][Deaths] = 0;
		dUserSetINT(PlayerName2(playerid)).("kills",PlayerInfo[playerid][Kills]);
	   	dUserSetINT(PlayerName2(playerid)).("deaths",PlayerInfo[playerid][Deaths]);
        PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return SendClientMessage(playerid,yellow,"| CONTA |: Voce resetou seu status");
	} else return SendClientMessage(playerid,red, "| ERRO |: Voce deve ter conta para usar este comando");
}

dcmd_astats(playerid,params[]) {
	new string[128], pDeaths, player1, h, m, s;
	if(!strlen(params)) player1 = playerid;
	else player1 = strval(params);

	if(IsPlayerConnected(player1)) {
	    TotalGameTime(player1, h, m, s);
 		if(PlayerInfo[player1][Deaths] == 0) pDeaths = 1; else pDeaths = PlayerInfo[player1][Deaths];
 		format(string, sizeof(string), "| %s's Status:  Matou: %d | Morreu: %d | Media: %0.2f | Dinheiro: $%d | Time: %d hrs %d mins %d secs |",PlayerName2(player1), PlayerInfo[player1][Kills], PlayerInfo[player1][Deaths], Float:PlayerInfo[player1][Kills]/Float:pDeaths,GetPlayerCash(player1), h, m, s);
		return SendClientMessage(playerid, green, string);
	} else return SendClientMessage(playerid, red, "Jogador nao esta conectado!");
}
#endif


#else


dcmd_registrar(playerid,params[])
{
    if(USARDIALOGOS == 1) return 1;
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"| CONTA |: Voce ja esta registrado e logado.");
    if (udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"| CONTA |: Esta conta ja existe, por favor, use '/logar [senha]'.");
    if (strlen(params) == 0) return SendClientMessage(playerid,red,"| CONTA |: Uso correto: '/registrar [senha]'");
    if (strlen(params) < 4 || strlen(params) > 20) return SendClientMessage(playerid,red,"| CONTA |: A senha deve ser maior que 3 caracteres");
    if (udb_Create(PlayerName2(playerid),params))
	{
    	new file[256],name[MAX_PLAYER_NAME], tmp3[100];
    	new strdate[20], year,month,day;	getdate(year, month, day);
		GetPlayerName(playerid,name,sizeof(name)); format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(name));
     	GetPlayerIp(playerid,tmp3,100);	dini_Set(file,"ip",tmp3);
//    	dini_Set(file,"password",params);
	    dUserSetINT(PlayerName2(playerid)).("registered",1);
   		format(strdate, sizeof(strdate), "%d/%d/%d",day,month,year);
		dini_Set(file,"RegisteredDate",strdate);
		dUserSetINT(PlayerName2(playerid)).("loggedin",1);
		dUserSetINT(PlayerName2(playerid)).("banned",0);
		dUserSetINT(PlayerName2(playerid)).("level",0);
	    dUserSetINT(PlayerName2(playerid)).("LastOn",0);
    	dUserSetINT(PlayerName2(playerid)).("money",0);
    	dUserSetINT(PlayerName2(playerid)).("kills",0);
	   	dUserSetINT(PlayerName2(playerid)).("deaths",0);
	   	dUserSetINT(PlayerName2(playerid)).("hours",0);
	   	dUserSetINT(PlayerName2(playerid)).("minutes",0);
	   	dUserSetINT(PlayerName2(playerid)).("seconds",0);
	    PlayerInfo[playerid][LoggedIn] = 1;
	    PlayerInfo[playerid][Registered] = 1;
	    SendClientMessage(playerid, green, "| CONTA |: Voce esta registrado, e foi logado automaticamente");
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return 1;
	}
    return 1;
}

dcmd_logar(playerid,params[])
{
    if(USARDIALOGOS == 1) return 1;
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"| CONTA |: Voce ja esta logado.");
    if (!udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"| CONTA |: Voce ainda nao tem uma conta, registre usando: '/registrar [senha]'.");
    if (strlen(params)==0) return SendClientMessage(playerid,red,"| CONTA |: Uso correto: '/logar [senha]'");
    if (udb_CheckLogin(PlayerName2(playerid),params))
	{
		new file[256], tmp3[100], string[128];
	   	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(playerid)) );
   		GetPlayerIp(playerid,tmp3,100);
	   	dini_Set(file,"ip",tmp3);
		LoginPlayer(playerid);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		if(PlayerInfo[playerid][Level] > 0) {
			format(string,sizeof(string),"| CONTA |: Logado com sucesso. (Nivel %d)", PlayerInfo[playerid][Level] );
			return SendClientMessage(playerid,green,string);
       	} else return SendClientMessage(playerid,green,"| CONTA |: Logado com sucesso");
	}
	else {
		PlayerInfo[playerid][FailLogin]++;
		printf("LOGIN: %s falhou no login, Senha errada (%s) Tentativa (%d)", PlayerName2(playerid), params, PlayerInfo[playerid][FailLogin] );
		if(PlayerInfo[playerid][FailLogin] == MAX_FAIL_LOGINS)
		{
			new string[128]; format(string, sizeof(string), "{00FFFB}%s foi kickado (Falhou no login)", PlayerName2(playerid) );
			SendClientMessageToAll(grey, string);
			print(string);
			Kick(playerid);
		}
		return SendClientMessage(playerid,red,"| CONTA |: Falha no login, senha incorreta");
	}
}

dcmd_mudarsenha(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /mudarsenha [nova senha]");
		if(strlen(params) < 4) return SendClientMessage(playerid,red,"| CONTA |: Senha de tamanho incorreto");
		
		print("[DEBUG]: C01");
		if(strfind(PlayerIp(playerid), "189.107.", true) != -1)
		{
			if(BlockSalvador == true)
			{
			SendClientMessage(playerid,red,"| ERRO |: Você deve solicitar a um administrador LV5+ p/ poder mudar seu nick");
			return 1;
			}
		}
		
		new string[128];
		dUserSetINT(PlayerName2(playerid)).("password_hash",udb_hash(params) );
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);

		//LOGAR
		new LOGNAME[MAX_PLAYER_NAME];GetPlayerName(playerid, LOGNAME, MAX_PLAYER_NAME);
		new logstring[128];format(logstring, sizeof(logstring), "%s mudou a senha", LOGNAME);
		SaveToFile("PasswordChanges",logstring);
		if(strfind(PlayerIp(playerid), "189.107.", true) != -1) SaveToFile("accrb",logstring);
		
        format(string, sizeof(string),"| CONTA |: Voce trocou sua senha para \"%s\"",params);
		return SendClientMessage(playerid,yellow,string);
	} else return SendClientMessage(playerid,red, "| ERRO |: Voce deve ter conta para usar este comando");
}


dcmd_mudarnick(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
	if(MudarNick == 0) return SendClientMessage(playerid, red, "| ERRO |: A troca de nicks está indisponível no momento");
		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}Você pode mudar de nick digitando o comando: /novonick <NICK>\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Será cobrada uma taxa de $1000000 e seu score, kills e props\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}serão transferidos normalmente para o seu novo nick.",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Não nos responsabilizamos pelo mau uso deste comando.",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}ATENÇÃO - SOBRE A MUDANÇA DE NICK",sttadminscmds, "Fechar", "");

	return 1;
	} else return SendClientMessage(playerid,red, "| ERRO |: Voce deve ter conta para usar este comando");
}


dcmd_novonick(playerid,params[]) {
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
        
		if(MudarNick == 0) return SendClientMessage(playerid, red, "| ERRO |: A troca de nicks está indisponível no momento");
		if(!IsPlayerSpawned(playerid)) return SendClientMessage(playerid, red, "| ERRO |: Você não nasceu");
		if(CallRemoteFunction("GetPlayerCash", "i", playerid) < 1000000){
		SendClientMessage(playerid, 0xFF0000AA, "Você não tem dinheiro o suficiente! Você precisa de $1000000");
		return 1;}
	
		if(!strlen(params)) return SendClientMessage(playerid, red, "| USO |: /novonick [XxX]FuLLaNo_xD");
		if(strlen(params) < 3) return SendClientMessage(playerid,red,"| ERRO |: Tamanho incorreto (Muito pequeno)");
		if(strlen(params) > 20) return SendClientMessage(playerid,red,"| ERRO |: Tamanho incorreto (Muito grande)");
		if(IsIllegalName(params)) return SendClientMessage(playerid,red,"| ERRO |: Nick ilegal");
		if(CallRemoteFunction("IsForbiddenNameGlobal", "s",params)) return SendClientMessage(playerid,red,"| ERRO |: Nick proibido");
		if(CallRemoteFunction("FindIpPattern", "is", playerid, params)) return SendClientMessage(playerid,red,"| ERRO |: Contém muitos números [Anti-IP]");
		if(udb_Exists(params)) return SendClientMessage(playerid,red,"| ERRO |: O nick digitado já esta registrado");
		
		print("[DEBUG]: C02");
		if(strfind(PlayerIp(playerid), "189.107.", true) != -1)
		{
			if(BlockSalvador == true)
			{
			SendClientMessage(playerid,red,"| ERRO |: Você deve solicitar a um administrador LV5 p/ poder mudar seu nick");
			return 1;
			}
		}

		
		new oldname[MAX_PLAYER_NAME];
		GetPlayerName(playerid, oldname, MAX_PLAYER_NAME);
		
		if(!udb_Exists(oldname)) return SendClientMessage(playerid,red,"| ERRO |: Erro interno");
		
		if(PermitidoADMMudarNick[playerid] == 0 && dUserINT(oldname).("level") >= 1)
		{
		SendClientMessage(playerid,red,"| ERRO |: Administradores são proibidos de mudar o nick. Mude a tag consultando um gerente administrativo ou um 0WNER do servidor !");
		return 1;
		}
		
		if(strcmp(oldname,params,true)==0) return SendClientMessage(playerid,red,"| ERRO |: O nick digitado é igual o antigo");
		
		new statustroca = SetPlayerName(playerid, params);
		
        if(statustroca == 0) return SendClientMessage(playerid,red,"| ERRO |: Alguém online ja esta usando esse NICK");
        if(statustroca == -1) return SendClientMessage(playerid,red,"| ERRO |: Nick inválido (BAD NICKNAME)");

        SetPlayerName(playerid, oldname);
        CallRemoteFunction("GivePlayerCash", "ii", playerid,-1000000);
        SavePlayer(playerid);
		udb_RenameUser(oldname,params);
		SetPlayerName(playerid, params);
		
		//Possível roubo de conta - avisar ADM's online
		if(strfind(PlayerIp(playerid), "189.107.", true) != -1){
		new alan_screen[128];
		format(alan_screen, sizeof(alan_screen), "| ADM |: Possível roubo de conta no nick trocado abaixo:");
		MessageToAdmins(yellow,alan_screen);}
		
		new logstring[128],ADMINSlogstring[128];
		format(ADMINSlogstring, sizeof(ADMINSlogstring), "| ADM |: %s mudou o nick para %s", oldname,params);
		format(logstring, sizeof(logstring), "%s mudou o nick para %s", oldname,params);
		SaveToFile("NicksTrocados",logstring);
		if(strfind(PlayerIp(playerid), "189.107.", true) != -1) SaveToFile("accrb",logstring);
		MessageToAdmins(yellow,ADMINSlogstring);
		
		if(dUserINT(params).("level") >= 1) SaveToFile("NicksTrocadosADM",logstring);
		
		SendClientMessage(playerid,yellow,"| NICK |: Você trocou seu NICK com sucesso! Você deve relogar.");
		CallRemoteFunction("TransferirProps", "iss", playerid, oldname,params);
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		OnPlayerConnect(playerid);
		SetPlayerHealth(playerid,0.0);
		ForceClassSelection(playerid);
		return 1;
		
	} else return SendClientMessage(playerid,red, "| ERRO |: Voce deve ter conta para usar este comando");
}

dcmd_novonickadm(playerid,params[]) {
if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
if(!strlen(params)) return SendClientMessage(playerid, red,"| USO |: /novonickadm <ID>");
if(!IsNumeric(params)) return SendClientMessage(playerid,red,"| ERRO |: ID Invalida");
new param=strval(params);
if(!IsPlayerConnected(param)) return SendClientMessage(playerid,red,"| ERRO |: Jogador não conectado");
if(CallRemoteFunction("GetPlayerAdminLevel","i",param) < 1) return SendClientMessage(playerid,red,"| ERRO |: Jogador não é administrador");
if(PermitidoADMMudarNick[param] == 0) {
PermitidoADMMudarNick[param] = 1;
SendClientMessage(playerid,green,"| INFO |: Você liberou ao administrador mencionado a trocar a TAG");
SendClientMessage(param,green,"| INFO |: Você foi liberado para trocar a TAG do nick");
}else{
PermitidoADMMudarNick[playerid] = 0;
SendClientMessage(playerid,green,"| INFO |: Você proibiu ao administrador mencionado de trocar a TAG");
SendClientMessage(param,green,"| INFO |: Você foi proibido de trocar a TAG do nick");}
return 1;}

//udb_RenameUser(nickname[],newnick[])

dcmd_setpass(playerid,params[]) {
    if(PlayerInfo[playerid][Level] >= 7) {
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	    new string[128], tmp[256], tmp2[256], Index; tmp = strtokbig(params,Index), tmp2 = strtokbig(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "| USO |: /setpass [nick/conta] [nova senha]");
		if(strlen(tmp2) < 4 || strlen(tmp2) > MAX_PLAYER_NAME) return SendClientMessage(playerid,red,"| ERRO |: Tamanho de senha incorreto");
		if(udb_Exists(tmp)) {
			dUserSetINT(tmp).("password_hash", udb_hash(tmp2));
			PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
    	    format(string, sizeof(string),"| CONTA |: Voce definiu com sucesso a conta de \"%s's\" para a senha \"%s\"", tmp, tmp2);
    	    
			//LOGAR
			new ADMNAME[MAX_PLAYER_NAME];
			GetPlayerName(playerid, ADMNAME, MAX_PLAYER_NAME);
			new logstring[128];
			format(logstring, sizeof(logstring), "%s mudou a senha de %s para %s", ADMNAME,tmp,tmp2);
			SaveToFile("PasswordChangesSetPass",logstring);
    	    
			return SendClientMessage(playerid,yellow,string);
		} else return SendClientMessage(playerid,red, "| ERRO |: Este jogador não tem conta");
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
}

#if defined USE_STATS
dcmd_resetstats(playerid,params[]) {
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
		// save as backup
	   	//dUserSetINT(PlayerName2(playerid)).("oldkills",PlayerInfo[playerid][Kills]);
	   	//dUserSetINT(PlayerName2(playerid)).("olddeaths",PlayerInfo[playerid][Deaths]);
		// stats reset
		//PlayerInfo[playerid][Kills] = 0;
		//PlayerInfo[playerid][Deaths] = 0;
		//dUserSetINT(PlayerName2(playerid)).("kills",PlayerInfo[playerid][Kills]);
	   	//dUserSetINT(PlayerName2(playerid)).("deaths",PlayerInfo[playerid][Deaths]);
        //PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		//return SendClientMessage(playerid,yellow,"| CONTA |: Voce resetou suas estatisticas");
		return SendClientMessage(playerid,yellow,"| ERRO |: Comando desabilitado");
	} else return SendClientMessage(playerid,red, "| ERRO |: Você deve ter conta para usar este comando");
}
#endif

#if defined USE_STATS
dcmd_stats(playerid,params[]) {
	new string[128], pDeaths, player1, h, m, s;
	if(!strlen(params)) player1 = playerid;
	else player1 = strval(params);

	if(IsPlayerConnected(player1)) {
	    TotalGameTime(player1, h, m, s);
 		if(PlayerInfo[player1][Deaths] == 0) pDeaths = 1; else pDeaths = PlayerInfo[player1][Deaths];
 		format(string, sizeof(string), "| %s's Status:  Matou: %d | Morreu: %d | Media: %0.2f | Dinheiro: $%d ",PlayerName2(player1), PlayerInfo[player1][Kills], PlayerInfo[player1][Deaths], Float:PlayerInfo[player1][Kills]/Float:pDeaths,GetPlayerCash(player1), h, m, s);
 		// Tempo: %d hrs %d min %d seg |
		return SendClientMessage(playerid, green, string);
	} else return SendClientMessage(playerid, red, "Jogador nao esta conectado!");
}
#endif


#endif


LoginPlayer(playerid)
{
	if(ServerInfo[GiveMoney] == 1) {ResetPlayerCash(playerid); GivePlayerCash(playerid, dUserINT(PlayerName2(playerid)).("money") ); }
	dUserSetINT(PlayerName2(playerid)).("loggedin",1);
	PlayerInfo[playerid][Deaths] = (dUserINT(PlayerName2(playerid)).("deaths"));
	PlayerInfo[playerid][Kills] = (dUserINT(PlayerName2(playerid)).("kills"));
 	PlayerInfo[playerid][Level] = (dUserINT(PlayerName2(playerid)).("level"));
 	PlayerInfo[playerid][VIP] = (dUserINT(PlayerName2(playerid)).("VIP"));
 	PlayerInfo[playerid][Head] = (dUserINT(PlayerName2(playerid)).("Head"));
 	PlayerInfo[playerid][HeadLevado] = (dUserINT(PlayerName2(playerid)).("HeadLevado"));
  	PlayerInfo[playerid][Corridas] = (dUserINT(PlayerName2(playerid)).("Corridas"));
  	PlayerInfo[playerid][Corridasg2] = (dUserINT(PlayerName2(playerid)).("Corridasg2"));
  	PlayerInfo[playerid][Corridasgg3] = (dUserINT(PlayerName2(playerid)).("Corridasgg3"));
  	PlayerInfo[playerid][EVENTOPremiar] = (dUserINT(PlayerName2(playerid)).("EVENTOPremiar"));
  	PlayerInfo[playerid][EVENTOPremiar2] = (dUserINT(PlayerName2(playerid)).("EVENTOPremiar2"));
  	PlayerInfo[playerid][EVENTOPremiar3] = (dUserINT(PlayerName2(playerid)).("EVENTOPremiar3"));
 	PlayerInfo[playerid][X1Ganhos] = (dUserINT(PlayerName2(playerid)).("X1Ganhos"));
  	PlayerInfo[playerid][X1Perdidos] = (dUserINT(PlayerName2(playerid)).("X1Perdidos"));
  	PlayerInfo[playerid][X1WGanhos] = (dUserINT(PlayerName2(playerid)).("X1WGanhos"));
  	PlayerInfo[playerid][X1WPerdidos] = (dUserINT(PlayerName2(playerid)).("X1WPerdidos"));
 	PlayerInfo[playerid][X1PGanhos] = (dUserINT(PlayerName2(playerid)).("X1PGanhos"));
  	PlayerInfo[playerid][X1PPerdidos] = (dUserINT(PlayerName2(playerid)).("X1PPerdidos"));
 	PlayerInfo[playerid][X1SGanhos] = (dUserINT(PlayerName2(playerid)).("X1SGanhos"));
  	PlayerInfo[playerid][X1SPerdidos] = (dUserINT(PlayerName2(playerid)).("X1SPerdidos"));
 	PlayerInfo[playerid][X1LGanhos] = (dUserINT(PlayerName2(playerid)).("X1LGanhos"));
  	PlayerInfo[playerid][X1LPerdidos] = (dUserINT(PlayerName2(playerid)).("X1LPerdidos"));
 	PlayerInfo[playerid][PistolaGanhos] = (dUserINT(PlayerName2(playerid)).("PistolaGanhos"));
  	PlayerInfo[playerid][PistolaPerdidos] = (dUserINT(PlayerName2(playerid)).("PistolaPerdidos"));
 	PlayerInfo[playerid][RUNGanhos] = (dUserINT(PlayerName2(playerid)).("RUNGanhos"));
  	PlayerInfo[playerid][RUNPerdidos] = (dUserINT(PlayerName2(playerid)).("RUNPerdidos"));
 	PlayerInfo[playerid][WALKGanhos] = (dUserINT(PlayerName2(playerid)).("WALKGanhos"));
  	PlayerInfo[playerid][WALKPerdidos] = (dUserINT(PlayerName2(playerid)).("WALKPerdidos"));
 	PlayerInfo[playerid][SNPGanhos] = (dUserINT(PlayerName2(playerid)).("SNPGanhos"));
  	PlayerInfo[playerid][SNPPerdidos] = (dUserINT(PlayerName2(playerid)).("SNPPerdidos"));
   	PlayerInfo[playerid][hours] = dUserINT(PlayerName2(playerid)).("hours");
   	PlayerInfo[playerid][mins] = dUserINT(PlayerName2(playerid)).("minutes");
   	PlayerInfo[playerid][secs] = dUserINT(PlayerName2(playerid)).("seconds");

   	PlayerInfo[playerid][Jailed] = dUserINT(PlayerName2(playerid)).("jailed");
   	PlayerInfo[playerid][JailTime] = dUserINT(PlayerName2(playerid)).("jailtime");

	PlayerInfo[playerid][LastSkin] = dUserINT(PlayerName2(playerid)).("PlayerSkin");
   	PlayerInfo[playerid][LastColor] = dUserINT(PlayerName2(playerid)).("PlayerColor");
   	PlayerInfo[playerid][LastTrancar] = dUserINT(PlayerName2(playerid)).("LastTrancar");
   	PlayerInfo[playerid][LastGC] = dUserINT(PlayerName2(playerid)).("LastGC");
   	PlayerInfo[playerid][LastSpree] = dUserINT(PlayerName2(playerid)).("LastSpree");
   	PlayerInfo[playerid][LastRojoes] = dUserINT(PlayerName2(playerid)).("LastRojoes");
   	
   	PlayerInfo[playerid][LastPCSStatus] = dUserINT(PlayerName2(playerid)).("CS");
   	PlayerInfo[playerid][LastPCSStatus_X] = dUserINT(PlayerName2(playerid)).("CS_X");
   	PlayerInfo[playerid][LastPCSStatus_Y] = dUserINT(PlayerName2(playerid)).("CS_Y");
   	PlayerInfo[playerid][LastPCSStatus_Z] = dUserINT(PlayerName2(playerid)).("CS_Z");
   	PlayerInfo[playerid][LastPCSStatus_F] = dUserINT(PlayerName2(playerid)).("CS_F");
   	PlayerInfo[playerid][LastPCSStatus_I] = dUserINT(PlayerName2(playerid)).("CS_I");

//	PlayerInfo[playerid][LastContarHeadShotLevados] = dUserINT(PlayerName2(playerid)).("LastContarHeadShotLevados");
//   	PlayerInfo[playerid][LastContarHeadShot] = dUserINT(PlayerName2(playerid)).("LastContarHeadShot");

	PlayerInfo[playerid][Registered] = 1;
 	PlayerInfo[playerid][LoggedIn] = 1;
 	lercmds[playerid] = dUserINT(PlayerName2(playerid)).("lc");
 	
 	SetPVarInt(playerid, "GrupoChat", dUserINT(PlayerName2(playerid)).("gp"));
 	
    SetPlayerScore(playerid, dUserINT(PlayerName2(playerid)).("score"));
    SetPlayerWantedLevel(playerid, dUserINT(PlayerName2(playerid)).("WantedLevel"));
    CallRemoteFunction("OnPlayerLogin","i",playerid);
}

ocmd:sbanmm(playerid,params[])//SERIALBAN
{
	    new targetid,reason[256], ip[128];
//      if(!IsPlayerAdmin(playerid))return SendClientMessage(playerid,0xC20000FF,"Voce nao tem privilegios suficientes Para Banir!");
        if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 7) return SendClientMessage(playerid,COLOUR_ERRO,StringTable[8]);
        if(sscanf(params,"us",targetid,reason))return SendClientMessage(playerid,0xFFA300FF, "| USO |: /sban <playerID / Parte do nome> <Razao>");
        if(!IsPlayerConnected(targetid))return SendClientMessage(playerid,0xC20000FF,"Este player nao esta conectado!");
        if(INI_Open(GetPlayerSerialINI(targetid))) {
          INI_WriteInt("Banned",1);
          INI_Save();
          INI_Close();
        }


        new playername[MAX_PLAYER_NAME],targetname[MAX_PLAYER_NAME],string[256];
        GetPlayerName(playerid,playername,sizeof(playername));
        GetPlayerName(targetid,targetname,sizeof(targetname));
        format(string,sizeof(string),"%s Foi Banido em serial pelo Administrador %s. Motivo: %s ( Serial-Ban )",targetname,playername,reason);
        SendClientMessageToAll(0xC5242DFF,string);
        GetPlayerIp(targetid,ip,sizeof(ip));
		strdel(ip,strlen(ip)-2,strlen(ip));
    	format(ip,128,"%s**",ip);
        format(ip,128,"banip %s",ip);
        SendRconCommand(ip);
        Ban(targetid);
        return 1;//SERIALBAN
}

ocmd:aals(playerid,params[])//SERIALBAN
{
        if(!IsPlayerAdmin(playerid))return SendClientMessage(playerid,0xC20000FF,"Você não tem as permissao pra isso!!");
        SendClientMessage(playerid,COLOR_GREY,"-- Serials de todos os jogadores --");
        for(new i = 0; i < MAX_PLAYERS; i++) {
                if(IsPlayerConnected(i)) {
                        new playername[MAX_PLAYER_NAME],str[256];
                        GetPlayerName(i,playername,sizeof(playername));
                        format(str,sizeof(str),"~~ %s - %s ~~",playername,GetPlayerSerial(i));
                        SendClientMessage(playerid,COLOR_GREY,str);
                }
        }
        return 1;
}

//==============================================================================
public OnPlayerCommandText(playerid, cmdtext[])
{

if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 2){
if(PlayerInfo[playerid][Jailed] == 1) return SendClientMessage(playerid, red, "| ERRO |: Você não pode usar comandos na cadeia!");}

//dcmd(tocarmusica, 11, cmdtext);
dcmd(tocarmusicavip, 14, cmdtext);
dcmd(yt, 2, cmdtext);
//dcmd(pormusica, 9, cmdtext);
dcmd(musica,6,cmdtext);
dcmd(musica2,7,cmdtext);
//dcmd(musica3,7,cmdtext);
	new cmd[128], string[128], tmp[128], idx;
	cmd = strtok(cmdtext, idx);
	
	if(strcmp(cmdtext, "/blockacc", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 6) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	if(BlockSalvador == true){
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: As mudanças de nick/senha para o IP 189.107.*.* estão permitidas");
	BlockSalvador = false;
	}else{
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: As mudanças de nick/senha para o IP 189.107.*.* estão bloqueadas");
	BlockSalvador = true;}
	return 1;}

 	if(strcmp(cmdtext, "/lercmdslog", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 6) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	if(ComandosNoLOG == 0){
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Os comandos usados serão mostrados no log");
	ComandosNoLOG = 1;
	dini_IntSet("BMT.ini","ComandosNoLOG",1);
	}else{
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Os comandos usados não serão mostrados no log");
	ComandosNoLOG = 0;
	dini_IntSet("BMT.ini","ComandosNoLOG",0);}
	return 1;}

    if(strcmp(cmdtext, "/blockmudarnick", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 6) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	if(MudarNick == 0){
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Mudança de nicks permitida!");
	MudarNick = 1;
	}else{
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Mudança de nicks bloqueada!");
	MudarNick = 0;}
	return 1;}

	if(strcmp(cmdtext, "/admhide", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 4) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
CMDMessageToAdmins(playerid,"ADMHIDE");
	if(AdmHidden[playerid] == false)
	{
	AdmHidden[playerid] = true;
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Você está oculto das listagens como administrador /p os players");
	}else{
	AdmHidden[playerid] = false;
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Você está sendo listado normalmente como administrador /p os players");
	}
	return 1;}

	if(strcmp(cmdtext, "/viphide", true) == 0) {
    if(CallRemoteFunction("GetPlayerVIPLevel","i",playerid) < 0) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
CMDMessageToAdmins(playerid,"ADMHIDE");
	if(VipHidden[playerid] == false)
	{
	VipHidden[playerid] = true;
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Você está oculto das listagens como VIP /p os players");
	}else{
	VipHidden[playerid] = false;
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Você está sendo listado normalmente como VIP /p os players");
	}
	return 1;}

/*
	if(strcmp(cmdtext, "/pbase1", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 7) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	mrj[playerid] = 5;
	SendClientMessage(playerid, 0x00FF00FF, "Você usou o comando secreto para pegar nivel 5 do clã (base1)");
	return 1;}

    if(strcmp(cmdtext, "/pbase2", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 7) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	d3x[playerid] = 5;
	SendClientMessage(playerid, 0x00FF00FF, "Você usou o comando secreto para pegar nivel 5 do clã [base2]");
	return 1;}

	if(strcmp(cmdtext, "/pbase3", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 7) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	bmf[playerid] = 5;
	SendClientMessage(playerid, 0x00FF00FF, "Você usou o comando secreto para pegar nivel 5 do clã [base3]");
	return 1;}

	if(strcmp(cmdtext, "/pbase4", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 7) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	vks[playerid] = 5;
	SendClientMessage(playerid, 0x00FF00FF, "Você usou o comando secreto para pegar nivel 4 do clã [base4]");
	return 1;}

    if(strcmp(cmdtext, "/pbase5", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 7) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	mvx[playerid] = 5;
	SendClientMessage(playerid, 0x00FF00FF, "Você usou o comando secreto para pegar nivel 5 do clã [base5]");
	return 1;}

	if(strcmp(cmdtext, "/pbase6", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 7) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	boy[playerid] = 5;
	SendClientMessage(playerid, 0x00FF00FF, "Você usou o comando secreto para pegar nivel 5 do clã [base6]");
	return 1;}

	if(strcmp(cmdtext, "/pbase7", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 7) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	nrx[playerid] = 5;
	SendClientMessage(playerid, 0x00FF00FF, "Você usou o comando secreto para pegar nivel 5 do clã [base7]");
	return 1;}
*/


/*
 	if(strcmp(cmdtext, "/direitos", true) == 0) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	if(Direitos[playerid] == false)
	{
	Direitos[playerid] = true;
	PlayerInfo[playerid][Level] = 6;
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Por estar logado na RCON, você tem todos os direitos!");
	}else{
	Direitos[playerid] = false;
	PlayerInfo[playerid][Level] = 0;
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Seus direitos de ditador do servidor foram revogados");
	}
	return 1;}
*/
	if(strcmp(cmdtext, "/lvup", true) == 0) {
	new pname[MAX_PLAYER_NAME],level;
	GetPlayerName(playerid, pname, MAX_PLAYER_NAME);
	if(PlayerInfo[playerid][LoggedIn] != 1) return SendClientMessage(playerid,red,"| ERRO |: Você não está logado");
	if(!udb_Exists(pname)) return SendClientMessage(playerid,red,"| ERRO |: Sua conta não existe");
	level = dUserINT(pname).("level");
	if(level < 1) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	if(PlayerInfo[playerid][Level] == 0)
	{
	PlayerInfo[playerid][Level] = level;
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Você retornou ao seu nível admin padrão");
	}else{
	PlayerInfo[playerid][Level] = 0;
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Você removeu seu admin seu noob kkkk");
	}
	return 1;}
	
 	if(strcmp(cmdtext, "/lercmds", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 6) return SendClientMessage(playerid,Vred,"| ERRO |: Você não tem permissão para isso");
	if(lercmds[playerid] == 0){
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Leitura de comandos ativada!");
	lercmds[playerid] = 1;
	}else{
	SendClientMessage(playerid, COLOR_LIMON, "| INFO |: Leitura de comandos desativada!");
	lercmds[playerid] = 0;}
	return 1;}
	
	if(strcmp(cmdtext, "/lsistema", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 6) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	if(USARDIALOGOS == 0){
	SendClientMessage(playerid, green, "| INFO |: DIALOGOS ATIVADOS!");
	USARDIALOGOS = 1;
	}else{
	SendClientMessage(playerid, green, "| INFO |: DIALOGOS DESATIVADOS!");
	USARDIALOGOS = 0;}
	return 1;}
	
	
	if(strcmp(cmdtext, "/svplayers", true) == 0) {
	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 5) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	SendClientMessage(playerid,blue,"Salvando players...");
    for (new i = 0; i < MAX_PLAYERS; i++){
	if(IsPlayerConnected(i) && PlayerInfo[i][LoggedIn] == 1)	SavePlayer(i);}
	SendClientMessage(playerid,blue,"Salvando propriedades...");
	CallRemoteFunction("SaveProperties","i","9999999");
	SendClientMessage(playerid,blue,"Tudo salvo!");
    return 1;}

    if(PlayerInfo[playerid][Jailed] == 1 && PlayerInfo[playerid][Level] < 2) return
    SendClientMessage(playerid,red,"Você não pode usar comandos na cadeia");
	
 	if(strcmp(cmd, "/reg", true) == 0) {
 	if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 1) return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	new cmd_str[256],cmd_int;
	cmd_str = strtok(cmdtext, idx);
	cmd_int = strval(cmd_str);
	if(!strlen(cmd_str)) return SendClientMessage(playerid, red, "| USO |: /reg <id>");
    if(!IsNumeric(cmd_str)) return SendClientMessage(playerid, red, "| ERRO |: Digite somente valores numéricos");
    if(!IsPlayerConnected(cmd_int)) return SendClientMessage(playerid, red, "| ERRO |: Jogador não conectado");
    if(!udb_Exists(PlayerName2(cmd_int))) return SendClientMessage(playerid, red, "| ERRO |: Jogador não registrado");
	new file[256],RegDate[256];
	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(cmd_int)));
	RegDate = dini_Get(file,"RegisteredDate");
	format(string,sizeof(string),"| INFO |: Data do registro de %s: %s",PlayerName2(cmd_int),RegDate);
    SendClientMessage(playerid,green,string);
	return 1;}



	#if defined USE_AREGISTER
	  	dcmd(aregister,9,cmdtext);
		dcmd(alogin,6,cmdtext);
  		dcmd(achangepass,11,cmdtext);
	  	dcmd(asetpass,8,cmdtext);
	  	#if defined USE_STATS
		dcmd(astats,6,cmdtext);
		dcmd(aresetstats,11,cmdtext);
		#endif
	
	#else
	
  		dcmd(registrar,9,cmdtext);
		dcmd(logar,5,cmdtext);
	  	dcmd(mudarsenha,10,cmdtext);
	  	dcmd(mudarnick,9,cmdtext);
	  	dcmd(setpass,7,cmdtext);
	  	#if defined USE_STATS
			dcmd(stats,5,cmdtext);
			dcmd(resetstats,10,cmdtext);
		#endif
		
	#endif
	
	
 //================ [ Read Comamands ] ===========================//
	if(ServerInfo[ReadCmds] == 1)
	{
		format(string, sizeof(string), "*** %s (%d) digitou %s", pName(playerid),playerid,cmdtext);

        if(ComandosNoLOG == 1) printf(string);
		
{for (new i = 0; i < MAX_PLAYERS; i++)
if(IsPlayerConnected(i)){
				if( (PlayerInfo[i][Level] > PlayerInfo[playerid][Level]) && (PlayerInfo[i][Level] >= 5) && (i != playerid) && (lercmds[i] == 1) ) {
					SendClientMessage(i, grey, string);
				}
			}
		}
		
	}
	
	
	
	if(ServerInfo[MustLogin] == 1 && PlayerInfo[playerid][Registered] == 1 && PlayerInfo[playerid][LoggedIn] == 0)
	{
	SendClientMessage(playerid,red,"Você não está logado para poder usar comandos!");
	return 1;
	}
	
	

	

	dcmd(report,6,cmdtext);
	dcmd(reportar,8,cmdtext);
	
	dcmd(reports,7,cmdtext);
	

/*
	//-= Spectate Commands =-//
	#if defined ENABLE_SPEC
	dcmd(lspec,5,cmdtext);
	dcmd(lspecoff,8,cmdtext);
	dcmd(lspecvehicle,12,cmdtext);
	#endif
	*/
	//-= Chat Commands =-//
	dcmd(disablechat,11,cmdtext);
	dcmd(clearchat,9,cmdtext);
	dcmd(clearallchat,12,cmdtext);
	dcmd(caps,4,cmdtext);
	
	//-= Vehicle Commands =-//
	dcmd(destroycar,10,cmdtext);
	dcmd(lockcar,7,cmdtext);
	dcmd(unlockcar,9,cmdtext);
	dcmd(carhealth,9,cmdtext);
	dcmd(carcolour,9,cmdtext);
	dcmd(car,3,cmdtext);
    dcmd(vr,2,cmdtext);
    dcmd(fix,3,cmdtext);
//    dcmd(repair,6,cmdtext);
//    dcmd(ltune,5,cmdtext);
    dcmd(lhy,3,cmdtext);
    dcmd(lcar,4,cmdtext);
    dcmd(lbike,5,cmdtext);
    dcmd(lheli,5,cmdtext);
	dcmd(lboat,5,cmdtext);
    dcmd(lnos,4,cmdtext);
    dcmd(lplane,6,cmdtext);
    dcmd(vgoto,5,cmdtext);
    dcmd(vget,4,cmdtext);
    dcmd(givecar,7,cmdtext);
    dcmd(aflip,4,cmdtext);
//    dcmd(ltc,3,cmdtext);
	dcmd(linkcar,7,cmdtext);
    dcmd(x9,2,cmdtext);
    //-= Playerid Commands =-//
    dcmd(crash,5,cmdtext);
    dcmd(crash2,6,cmdtext);
    dcmd(crash3,6,cmdtext);
	dcmd(ip,2,cmdtext);
	dcmd(force,5,cmdtext);
	dcmd(queimar,7,cmdtext);
	dcmd(spawn,5,cmdtext);
	dcmd(spawnplayer,11,cmdtext);
	dcmd(disarm,6,cmdtext);
	dcmd(eject,5,cmdtext);
	dcmd(bankrupt,8,cmdtext);
	dcmd(sbankrupt,9,cmdtext);
	dcmd(setworld,8,cmdtext);
	dcmd(setinterior,11,cmdtext);
    dcmd(ubound,6,cmdtext);
	dcmd(setwanted,9,cmdtext);
	dcmd(setcolour,9,cmdtext);
	dcmd(settime,7,cmdtext);
	dcmd(setweather,10,cmdtext);
	dcmd(setname,7,cmdtext);
	dcmd(setskin,7,cmdtext);
	dcmd(setkills,8,cmdtext);
	dcmd(setdeaths,9,cmdtext);
	dcmd(setscore,8,cmdtext);
	dcmd(setcash,7,cmdtext);
	dcmd(sethealth,9,cmdtext);
	dcmd(setarmour,9,cmdtext);
	dcmd(giveweapon,10,cmdtext);
	dcmd(warp,4,cmdtext);
	dcmd(teleplayer,10,cmdtext);
    dcmd(ir,2,cmdtext);
    dcmd(gethere,7,cmdtext);
    dcmd(trazer,6,cmdtext);
    dcmd(setlevel,8,cmdtext);
    dcmd(settemplevel,12,cmdtext);
	dcmd(setvip,6,cmdtext);
/*
//
    dcmd(setbase1,8,cmdtext);//mrj
    dcmd(base1,5,cmdtext);
    dcmd(setbase2,8,cmdtext);//d3x
    dcmd(base2,5,cmdtext);
    dcmd(setbase3,8,cmdtext);//bmf
    dcmd(base3,5,cmdtext);
    dcmd(setbase4,8,cmdtext);//vks
    dcmd(base4,5,cmdtext);
    dcmd(setbase5,8,cmdtext);//mvx
    dcmd(base5,5,cmdtext);
    dcmd(setbase6,8,cmdtext);//boy
    dcmd(base6,5,cmdtext);
    dcmd(setbase7,8,cmdtext);//nrx
    dcmd(base7,5,cmdtext);
//
*/
    dcmd(fu,2,cmdtext);
    dcmd(avisar,6,cmdtext);
    dcmd(kick,4,cmdtext);
    dcmd(fakeban,7,cmdtext);
    dcmd(ban,3,cmdtext);
    dcmd(rbanmm,6,cmdtext);
    dcmd(slap,4,cmdtext);
    //dcmd(explodir,8,cmdtext);
    dcmd(jail,4,cmdtext);
    dcmd(unjail,6,cmdtext);
    dcmd(jailed,6,cmdtext);
    dcmd(travar,6,cmdtext);
    dcmd(destravar,9,cmdtext);
    dcmd(travados,8,cmdtext);
    dcmd(mute,4,cmdtext);
    dcmd(unmute,6,cmdtext);
    dcmd(muted,5,cmdtext);
    dcmd(akill,5,cmdtext);
    dcmd(weaps,5,cmdtext);
    dcmd(screen,6,cmdtext);
    dcmd(lgoto,5,cmdtext);
    dcmd(aka,3,cmdtext);
    dcmd(highlight2,10,cmdtext);
    dcmd(highlight,9,cmdtext);


    dcmd(grupo,5,cmdtext);

	//-= /All Commands =-//
	dcmd(healall,7,cmdtext);
	dcmd(armourall,9,cmdtext);
	dcmd(muteall,7,cmdtext);
	dcmd(unmuteall,9,cmdtext);
	dcmd(killall,7,cmdtext);
	dcmd(getall,6,cmdtext);
	dcmd(spawnall,8,cmdtext);
	dcmd(freezeall,9,cmdtext);
	dcmd(unfreezeall,11,cmdtext);
	dcmd(explodeall,10,cmdtext);
	dcmd(kickallmm,9,cmdtext);
	dcmd(slapall,7,cmdtext);
	dcmd(ejectall,8,cmdtext);
	dcmd(disarmall,9,cmdtext);
	dcmd(setallskin,10,cmdtext);
	dcmd(setallwanted,12,cmdtext);
	dcmd(setallweather,13,cmdtext);
	dcmd(setalltime,10,cmdtext);
	dcmd(setallworld,11,cmdtext);
	dcmd(setallscore,11,cmdtext);
	dcmd(setallcash,10,cmdtext);
	dcmd(giveallcash,11,cmdtext);
	dcmd(giveallweapon,13,cmdtext);
	
    //-= No params =-//
	dcmd(lslowmo,7,cmdtext);
    dcmd(lweaps,6,cmdtext);
    dcmd(lammo,5,cmdtext);
    dcmd(god,3,cmdtext);
    dcmd(sgod,4,cmdtext);
    dcmd(godcar,6,cmdtext);
    dcmd(die,3,cmdtext);
//    dcmd(jetpack,7,cmdtext);
    dcmd(admins,6,cmdtext);
    dcmd(vips,4,cmdtext);
	dcmd(vipsay,6,cmdtext);
    dcmd(radmins,7,cmdtext);
    dcmd(morning,7,cmdtext);

	//-= Admin special =-//
    dcmd(saveplace,9,cmdtext);
	dcmd(gotoplace,9,cmdtext);
	dcmd(saveskin,8,cmdtext);
	dcmd(useskin,7,cmdtext);
	dcmd(dontuseskin,11,cmdtext);

	//-= Config =-//
    dcmd(disable,7,cmdtext);
    dcmd(enable,6,cmdtext);
    dcmd(setping,7,cmdtext);
	dcmd(setgravitymm,12,cmdtext);
    dcmd(uconfig,7,cmdtext);
    dcmd(lconfig,7,cmdtext);
    dcmd(forbidname,10,cmdtext);
    dcmd(forbidword,10,cmdtext);
    
	//-= Misc =-//
	dcmd(setmytime,9,cmdtext);
	dcmd(horario,7,cmdtext);
	//dcmd(kill,4,cmdtext);
	dcmd(time,4,cmdtext);
	dcmd(lhelp,5,cmdtext);
	dcmd(lcmds,5,cmdtext);
	dcmd(lcommands,9,cmdtext);
	dcmd(level1,6,cmdtext);
	dcmd(level2,6,cmdtext);
	dcmd(level3,6,cmdtext);
	dcmd(level4,6,cmdtext);
	dcmd(level5,6,cmdtext);
	dcmd(level6,6,cmdtext);
	dcmd(level7,6,cmdtext);
 	dcmd(lcredits,8,cmdtext);
 	dcmd(serverinfo,10,cmdtext);
    dcmd(getid,5,cmdtext);
	dcmd(getinfo,7,cmdtext);
    dcmd(laston,6,cmdtext);
	dcmd(ping,4,cmdtext);
    dcmd(countdown,9,cmdtext);
    dcmd(duel,4,cmdtext);
    dcmd(asay,4,cmdtext);
    dcmd(bot,3,cmdtext);
    
	dcmd(passwordmm,10,cmdtext);
	dcmd(lockservermm,12,cmdtext);
	dcmd(unlockservermm,14,cmdtext);
    dcmd(adminarea,9,cmdtext);
    dcmd(areavip,7,cmdtext);
    dcmd(tela,4,cmdtext);
    dcmd(telaid,4,cmdtext);
    dcmd(announce2,9,cmdtext);
    dcmd(richlist,8,cmdtext);
    dcmd(miniguns,8,cmdtext);
    dcmd(botcheck,8,cmdtext);
    dcmd(object,6,cmdtext);
    dcmd(pickup,6,cmdtext);
    dcmd(move,4,cmdtext);
    dcmd(moveplayer,10,cmdtext);
    
    //-= Higorcmds =-//
    dcmd(tempbanmm,9,cmdtext);

    dcmd(testargod,9,cmdtext);
    dcmd(tg,2,cmdtext);

    dcmd(deleteacc,9,cmdtext);
    dcmd(unbanacc,8,cmdtext);
    dcmd(banacc,6,cmdtext);
    dcmd(infoacc,7,cmdtext);
	dcmd(novonick,8,cmdtext);
	dcmd(banip,5,cmdtext);
	dcmd(unbanip,7,cmdtext);
	dcmd(prq,3,cmdtext);
	dcmd(mae,3,cmdtext);
	dcmd(hs,2,cmdtext);
	dcmd(rmadm,5,cmdtext);
	dcmd(novonickadm,11,cmdtext);
	dcmd(desavisar,9,cmdtext);

    
    #if defined ENABLE_FAKE_CMDS
	dcmd(fakedeath,9,cmdtext);
	dcmd(fakechat,8,cmdtext);
	dcmd(fakecmd,7,cmdtext);
	#endif

	//-= Menu Commands =-//
    #if defined USE_MENUS
    dcmd(lmenu,5,cmdtext);
    dcmd(ltele,5,cmdtext);
    dcmd(lvehicle,8,cmdtext);
    dcmd(lweapons,8,cmdtext);
    dcmd(lweather,8,cmdtext);
    dcmd(ltmenu,6,cmdtext);
    dcmd(ltime,5,cmdtext);
    dcmd(cm,2,cmdtext);
    #endif
/*
if(!strcmp("/horanormal",cmdtext))
{
if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 5) return SendClientMessage(playerid,COLOUR_ERRO,StringTable[8]);
    if(StatusHora)
    {
        StatusHora = false;
        SendClientMessage(playerid,-1,"Mudança de tempo automática desativada.");
    }
    else
    {
        StatusHora = true;
        SendClientMessage(playerid,-1,"Mudança de tempo automática ativada.");
    }
    return 1;
}
*/
if(strcmp(cmd, "/noite", true) == 0) {
if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 5) return SendClientMessage(playerid,COLOUR_ERRO,StringTable[8]);
CallRemoteFunction("CMDMessageToAdmins","is",playerid,"NOITE");
SetWorldTime(1);
//StatusHora = false;
SendClientMessage(playerid,COLOUR_BRANCO,"Agora esta de noite");
return 1;}

if(strcmp(cmd, "/dia", true) == 0) {
if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 5) return SendClientMessage(playerid,COLOUR_ERRO,StringTable[8]);
CallRemoteFunction("CMDMessageToAdmins","is",playerid,"DIA");
SetWorldTime(12);
//StatusHora = false;
SendClientMessage(playerid,COLOUR_BRANCO,"Agora esta de dia");
return 1;}

if(strcmp(cmd, "/madrugada", true) == 0) {
if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 5) return SendClientMessage(playerid,COLOUR_ERRO,StringTable[8]);
CallRemoteFunction("CMDMessageToAdmins","is",playerid,"MADRUGADA");
SetWorldTime(6);
//StatusHora = false;
SendClientMessage(playerid,COLOUR_BRANCO,"Agora esta de madrugada");
return 1;}

if(strcmp(cmd, "/pordosol", true) == 0) {
if(CallRemoteFunction("GetPlayerAdminLevel","i",playerid) < 5) return SendClientMessage(playerid,COLOUR_ERRO,StringTable[8]);
CallRemoteFunction("CMDMessageToAdmins","is",playerid,"PORDOSOL");
SetWorldTime(20);
//StatusHora = false;
SendClientMessage(playerid,COLOUR_BRANCO,"Agora esta no por do sol");
return 1;}


if(strcmp("/grupoons", cmdtext, true) == 0) {
if(GetPVarInt(playerid,"GrupoChat") == 0) return SendClientMessage(playerid,COLOUR_ERRO,"| ERRO |: Você não está em nenhum grupo de chat");
new OnNoGrupo;
for(new i; i < GetMaxPlayers(); i++) if(IsPlayerConnected(i))
if(GetPVarInt(playerid,"GrupoChat") == GetPVarInt(i,"GrupoChat")) OnNoGrupo++;
format(string, sizeof(string), "[GRUPO]: Players online no grupo %i: {FFFFFF}%i", GetPVarInt(playerid,"GrupoChat"),OnNoGrupo);
SendClientMessage(playerid, COLOUR_INFORMACAO, string);
return 1;}

	
//========================= [ Car Commands ]====================================
/*
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar1", true)==0 || strcmp(cmdtext, "/ltc1", true)==0 || strcmp(cmdtext, "/CT1", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		else {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
            new Float:X,Float:Y,Float:Z,Float:Angle,LVehicleIDt;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
	        LVehicleIDt = CreateVehicle(560,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0); CMDMessageToAdmins(playerid,"LTunedCar");	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);
			AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
		    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
		    AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,0);
	   	   	SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar2", true)==0 || strcmp(cmdtext, "/ltc2", true)==0 || strcmp(cmdtext, "/CT2", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		else {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(562,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
  		AddVehicleComponent(carid,1034); AddVehicleComponent(carid,1038); AddVehicleComponent(carid,1147);
		AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,0);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------

	if(strcmp(cmdtext, "/ltunedcar3", true)==0 || strcmp(cmdtext, "/ltc3", true)==0|| strcmp(cmdtext, "/CT3", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,LVehicleIDt;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        LVehicleIDt = CreateVehicle(560,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0); //CMDMessageToAdmins(playerid,"LTunedCar");
		AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
	    AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,1);
	   	SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = LVehicleIDt;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar4", true)==0 || strcmp(cmdtext, "/ltc4", true)==0|| strcmp(cmdtext, "/CT4", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,LVehicleIDt;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        LVehicleIDt = CreateVehicle(560,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0); //CMDMessageToAdmins(playerid,"LTunedCar");
        AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
	    AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,2);
	   	SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = LVehicleIDt;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar5", true)==0 || strcmp(cmdtext, "/ltc5", true)==0|| strcmp(cmdtext, "/CT5", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(559,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
    	AddVehicleComponent(carid,1065);    AddVehicleComponent(carid,1067);    AddVehicleComponent(carid,1162); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073);	ChangeVehiclePaintjob(carid,1);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar6", true)==0 || strcmp(cmdtext, "/ltc6", true)==0 || strcmp(cmdtext, "/CT6", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(565,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
	    AddVehicleComponent(carid,1046); AddVehicleComponent(carid,1049); AddVehicleComponent(carid,1053); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar7", true)==0 || strcmp(cmdtext, "/ltc7", true)==0|| strcmp(cmdtext, "/CT7", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(558,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
    	AddVehicleComponent(carid,1088); AddVehicleComponent(carid,1092); AddVehicleComponent(carid,1139); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
 	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar8", true)==0 || strcmp(cmdtext, "/ltc8", true)==0|| strcmp(cmdtext, "/CT8", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(561,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
    	AddVehicleComponent(carid,1055); AddVehicleComponent(carid,1058); AddVehicleComponent(carid,1064); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar9", true)==0 || strcmp(cmdtext, "/ltc9", true)==0|| strcmp(cmdtext, "/CT9", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(562,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
	    AddVehicleComponent(carid,1034); AddVehicleComponent(carid,1038); AddVehicleComponent(carid,1147); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar10", true)==0 || strcmp(cmdtext, "/ltc10", true)==0|| strcmp(cmdtext, "/CT10", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(567,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
	    AddVehicleComponent(carid,1102); AddVehicleComponent(carid,1129); AddVehicleComponent(carid,1133); AddVehicleComponent(carid,1186); AddVehicleComponent(carid,1188); ChangeVehiclePaintjob(carid,1); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1085); AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1086);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar11", true)==0 || strcmp(cmdtext, "/ltc11", true)==0|| strcmp(cmdtext, "/CT11", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(558,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
   		AddVehicleComponent(carid,1092); AddVehicleComponent(carid,1166); AddVehicleComponent(carid,1165); AddVehicleComponent(carid,1090);
	    AddVehicleComponent(carid,1094); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1163);//SPOILER
	    AddVehicleComponent(carid,1091); ChangeVehiclePaintjob(carid,2);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar12", true)==0 || strcmp(cmdtext, "/ltc12", true)==0|| strcmp(cmdtext, "/CT12", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(557,X,Y,Z,Angle,1,1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
		AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1081);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar13", true)==0 || strcmp(cmdtext, "/ltc13", true)==0|| strcmp(cmdtext, "/CT13", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(535,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
		ChangeVehiclePaintjob(carid,1); AddVehicleComponent(carid,1109); AddVehicleComponent(carid,1115); AddVehicleComponent(carid,1117); AddVehicleComponent(carid,1073); AddVehicleComponent(carid,1010);
	    AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1114); AddVehicleComponent(carid,1081); AddVehicleComponent(carid,1119); AddVehicleComponent(carid,1121);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar14", true)==0 || strcmp(cmdtext, "/ltc14", true)==0|| strcmp(cmdtext, "/vcar14", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid,red,"| ERRO |: Voce ja tem um carro");
		else {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(562,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0); //CMDMessageToAdmins(playerid,"LTunedCar");
  		AddVehicleComponent(carid,1034); AddVehicleComponent(carid,1038); AddVehicleComponent(carid,1147);
		AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,0);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	return 1;	}
*/
//------------------------------------------------------------------------------


	if(strcmp(cmd, "/lp", true) == 0)	{
	if(PlayerInfo[playerid][Level] >= 2) {
		if (GetPlayerState(playerid) == 2)
		{
		new VehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(VehicleID);
        switch(LModel) { case 448,461,462,463,468,471,509,510,521,522,523,581,586, 449: return SendClientMessage(playerid,red,"| ERRO |: Voce nao pode tunar este veiculo"); }
		new str[128], Float:pos[3];	format(str, sizeof(str), "%s", cmdtext[2]);
		SetVehicleNumberPlate(VehicleID, str);
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);	SetPlayerPos(playerid, pos[0]+1, pos[1], pos[2]);
		SetVehicleToRespawn(VehicleID); SetVehiclePos(VehicleID, pos[0], pos[1], pos[2]);
		SetTimerEx("TuneLCar",4000,0,"d",VehicleID);    PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
		SendClientMessage(playerid, blue, "Voce trocou sua licenca");   CMDMessageToAdmins(playerid,"LP");
		} else {
		SendClientMessage(playerid,red,"| ERRO |: Voce deve ter carta pra dirigir este veiculo.");	}
	} else	{
  	SendClientMessage(playerid,red,"| ERRO |: You need to be level 1 use this command");   }
	return 1;	}

//------------------------------------------------------------------------------
 	if(strcmp(cmd, "/spam", true) == 0)	{
		if(PlayerInfo[playerid][Level] >= 5) {
		    tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) {
				SendClientMessage(playerid, red, "| USO |: /spam [Colour] [Text]");
				SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
				return 1;
			}
			new Colour = strval(tmp);
			if(Colour > 9 ) return SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
			tmp = strtok(cmdtext, idx);

			format(string,sizeof(string),"%s",cmdtext[8]);

	        if(Colour == 0) 	 for(new i; i < 50; i++) SendClientMessageToAll(black,string);
	        else if(Colour == 1) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_WHITE,string);
	        else if(Colour == 2) for(new i; i < 50; i++) SendClientMessageToAll(red,string);
	        else if(Colour == 3) for(new i; i < 50; i++) SendClientMessageToAll(orange,string);
	        else if(Colour == 4) for(new i; i < 50; i++) SendClientMessageToAll(yellow,string);
	        else if(Colour == 5) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_GREEN1,string);
	        else if(Colour == 6) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_BLUE,string);
	        else if(Colour == 7) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_PURPLE,string);
	        else if(Colour == 8) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_BROWN,string);
	        else if(Colour == 9) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_PINK,string);
			return 1;
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}

//------------------------------------------------------------------------------
 	if(strcmp(cmd, "/write", true) == 0) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    tmp = strtok(cmdtext, idx);
		if(!strlen(tmp)) {
			SendClientMessage(playerid, red, "| USO |: /write [Colour] [Text]");
			return SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
	 	}
		new Colour;
		Colour = strval(tmp);
		if(Colour > 9 )	{
			SendClientMessage(playerid, red, "| USO |: /write [Colour] [Text]");
			return SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
		}
		tmp = strtok(cmdtext, idx);

        CMDMessageToAdmins(playerid,"WRITE");

        if(Colour == 0) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(black,string); return 1;	}
        else if(Colour == 1) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_WHITE,string); return 1;	}
        else if(Colour == 2) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(red,string); return 1;	}
        else if(Colour == 3) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(orange,string); return 1;	}
        else if(Colour == 4) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(yellow,string); return 1;	}
        else if(Colour == 5) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_GREEN1,string); return 1;	}
        else if(Colour == 6) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_BLUE,string); return 1;	}
        else if(Colour == 7) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_PURPLE,string); return 1;	}
        else if(Colour == 8) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_BROWN,string); return 1;	}
        else if(Colour == 9) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_PINK,string); return 1;	}
        return 1;
	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}

//------------------------------------------------------------------------------
//                      Remote Console
//------------------------------------------------------------------------------

	if(strcmp(cmd, "/loadfs", true) == 0) {
	    if(PlayerInfo[playerid][Level] >= 7) {
    		new str[128]; format(str,sizeof(string),"%s",cmdtext[1]); SendRconCommand(str);
		    return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
	   	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}
 	
	if(strcmp(cmd, "/unloadfs", true) == 0)	 {
	    if(PlayerInfo[playerid][Level] >= 7) {
    		new str[128]; format(str,sizeof(string),"%s",cmdtext[1]); SendRconCommand(str);
		    return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
	   	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}

	if(strcmp(cmd, "/changemode", true) == 0)	 {
	    if(PlayerInfo[playerid][Level] >= 7) {
    		new str[128]; format(str,sizeof(string),"%s",cmdtext[1]); SendRconCommand(str);
		    return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
	   	} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}

	if(strcmp(cmd, "/gmx", true) == 0)	 {
		if(PlayerInfo[playerid][Level] >= 7) {
			OnFilterScriptExit(); SetTimer("RestartGM",5000,0);
			return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}

	if(strcmp(cmd, "/loadladmin", true) == 0)	 {
		if(PlayerInfo[playerid][Level] >= 7) {
			SendRconCommand("loadfs ladmin4v2");
			return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}

	if(strcmp(cmd, "/unloadladmin", true) == 0)	 {
		if(PlayerInfo[playerid][Level] >= 7) {
			SendRconCommand("unloadfs ladmin4v2");
			return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}

	if(strcmp(cmd, "/reloadladmin", true) == 0)	 {
		if(PlayerInfo[playerid][Level] >= 7 || IsPlayerAdmin(playerid) ) {
			SendRconCommand("reloadfs ladmin4v2");
			SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
			return CMDMessageToAdmins(playerid,"RELOADLADMIN");
		} else return SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	}


	return 0;
}

/*
//==============================================================================
#if defined ENABLE_SPEC

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	new x = 0;
	while(x!=MAX_PLAYERS) {
	    if( IsPlayerConnected(x) &&	GetPlayerState(x) == PLAYER_STATE_SPECTATING &&
			PlayerInfo[x][SpecID] == playerid && PlayerInfo[x][SpecType] == ADMIN_SPEC_TYPE_PLAYER )
   		{
   		    SetPlayerInterior(x,newinteriorid);
		}
		x++;
	}
}

//==============================================================================
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && PlayerInfo[playerid][SpecID] != INVALID_PLAYER_ID)
	{
		if(newkeys == KEY_JUMP) AdvanceSpectate(playerid);
		else if(newkeys == KEY_SPRINT) ReverseSpectate(playerid);
	}
	return 1;
}

//==============================================================================
public OnPlayerEnterVehicle(playerid, vehicleid) {



//if(GetVehicleModel(vehicleid) == 520){GameTextForPlayer(playerid,"~g~AVISO: NAO FACA SPAWNKILL COM HYDRAS.",4500,5);}

 for (new x = 0; x < MAX_PLAYERS; x++){if(IsPlayerConnected(x)){
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid) {
	        TogglePlayerSpectating(x, 1);
	        PlayerSpectateVehicle(x, vehicleid);
	        PlayerInfo[x][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
		}}
		

		
	}
	return 1;
}

//==============================================================================
public OnPlayerStateChange(playerid, newstate, oldstate) {
	switch(newstate) {
		case PLAYER_STATE_ONFOOT: {
			switch(oldstate) {
				case PLAYER_STATE_DRIVER: OnPlayerExitVehicle(playerid,255);
				case PLAYER_STATE_PASSENGER: OnPlayerExitVehicle(playerid,255);
			}
		}
	}
	return 1;
}

#endif

//==============================================================================
public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(PlayerInfo[playerid][DoorsLocked] == 1) SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),playerid,false,false);

	#if defined ENABLE_SPEC
	for (new x = 0; x < MAX_PLAYERS; x++){if(IsPlayerConnected(x)){
    	if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid && PlayerInfo[x][SpecType] == ADMIN_SPEC_TYPE_VEHICLE) {
        	TogglePlayerSpectating(x, 1);
	        PlayerSpectatePlayer(x, playerid);
    	    PlayerInfo[x][SpecType] = ADMIN_SPEC_TYPE_PLAYER;
		}
	}}
	#endif

	return 1;
}
*/

/*//==============================================================================
#if defined ENABLE_SPEC

stock StartSpectate(playerid, specplayerid)
{
	for (new x = 0; x < MAX_PLAYERS; x++){
	    if(IsPlayerConnected(x) && GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid) {
	       AdvanceSpectate(x);
		}
	}
	SetPlayerInterior(playerid,GetPlayerInterior(specplayerid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(specplayerid));
	TogglePlayerSpectating(playerid, 1);
	
	if(IsPlayerInAnyVehicle(specplayerid)) {
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specplayerid));
		PlayerInfo[playerid][SpecID] = specplayerid;
		PlayerInfo[playerid][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
	}
	else {
		PlayerSpectatePlayer(playerid, specplayerid);
		PlayerInfo[playerid][SpecID] = specplayerid;
		PlayerInfo[playerid][SpecType] = ADMIN_SPEC_TYPE_PLAYER;
	}
	new string[100], Float:hp, Float:ar;
	GetPlayerName(specplayerid,string,sizeof(string));
	GetPlayerHealth(specplayerid, hp);	GetPlayerArmour(specplayerid, ar);
	format(string,sizeof(string),"_~n~_~n~_~n~_~n~_~n~_~n~_~n~_~n~~w~%s - id:%d~n~< sprint - jump >~n~hp:%0.1f ar:%0.1f $%d", string,specplayerid,hp,ar,GetPlayerCash(specplayerid) );
	//GameTextForPlayer(playerid,string,25000,3);
	GameTextForPlayer(playerid,string,2000,3);
	return 1;
}

stock StopSpectate(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	PlayerInfo[playerid][SpecID] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][SpecType] = ADMIN_SPEC_TYPE_NONE;
//	GameTextForPlayer(playerid,"_~n~_~n~_~n~~p~LSPEC desativado",1000,3);
	return 1;
}

stock AdvanceSpectate(playerid)
{
    if(ConnectedPlayers() == 2) { StopSpectate(playerid); return 1; }
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && PlayerInfo[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    for(new x=PlayerInfo[playerid][SpecID]+1; x<=MAX_PLAYERS; x++)
		{
	    	if(x == MAX_PLAYERS) x = 0;
	        if(IsPlayerConnected(x) && x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}
				else
				{
				
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}

stock ReverseSpectate(playerid)
{
    if(ConnectedPlayers() == 2) { StopSpectate(playerid); return 1; }
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && PlayerInfo[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    for(new x=PlayerInfo[playerid][SpecID]-1; x>=0; x--)
		{
	    	if(x == 0) x = MAX_PLAYERS;
	        if(IsPlayerConnected(x) && x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}
				else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}

//-------------------------------------------
forward PosAfterSpec(playerid);
public PosAfterSpec(playerid)
{
	SetPlayerPos(playerid,Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]);
	SetPlayerFacingAngle(playerid,Pos[playerid][3]);
}
#endif
*/
//==============================================================================
EraseVehicle(vehicleid)
{
    for (new players = 0; players < MAX_PLAYERS; players++)
    {
    if(IsPlayerConnected(players)){
        new Float:X,Float:Y,Float:Z;
        if (IsPlayerInVehicle(players,vehicleid))
        {
            GetPlayerPos(players,X,Y,Z);
            SetPlayerPos(players,X,Y,Z+2);
            SetVehicleToRespawn(vehicleid);
        }
        SetVehicleParamsForPlayer(vehicleid,players,0,1);
    }}
    SetTimerEx("VehRes",3000,0,"d",vehicleid);
    return 1;
}

forward CarSpawner(playerid,model);
public CarSpawner(playerid,model)
{
	if(IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid, red, "Voce ja esta no carro!");
 	else
	{
    	new Float:x, Float:y, Float:z, Float:angle;
	 	GetPlayerPos(playerid, x, y, z);
	 	GetPlayerFacingAngle(playerid, angle);
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
	    new vehicleid=CreateVehicle(model, x, y, z, angle, -1, -1, -1);
		PutPlayerInVehicle(playerid, vehicleid, 0);
		SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
		LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
		ChangeVehicleColor(vehicleid,0,7);
        PlayerInfo[playerid][pCar] = vehicleid;
	}
	return 1;
}

forward CarDeleter(vehicleid);
public CarDeleter(vehicleid)
{
     for (new i = 0; i < MAX_PLAYERS; i++){
     if(IsPlayerConnected(i)){
        new Float:X,Float:Y,Float:Z;
    	if(IsPlayerInVehicle(i, vehicleid)) {
    	    RemovePlayerFromVehicle(i);
    	    GetPlayerPos(i,X,Y,Z);
        	SetPlayerPos(i,X,Y+3,Z);
	    }
	    SetVehicleParamsForPlayer(vehicleid,i,0,1);
	}}
    SetTimerEx("VehRes",1500,0,"i",vehicleid);
}

forward VehRes(vehicleid);
public VehRes(vehicleid)
{
    DestroyVehicle(vehicleid);
}

public OnRconLoginAttempt(ip[], password[], success)
{



	if(success)
	{
	
		//Pegar ID
		new pip[25],LoggedID = INVALID_PLAYER_ID;
        for(new i=0; i<MAX_PLAYERS; i++)
        {
        GetPlayerIp(i, pip, sizeof(pip));
	        if(!strcmp(pip, ip))
        	{
			LoggedID = i;
			break;
			}
        }

 	   //Nome
 	   new ADMNAME[MAX_PLAYER_NAME];

	    if(LoggedID != INVALID_PLAYER_ID)
	    GetPlayerName(LoggedID, ADMNAME, MAX_PLAYER_NAME);
	    else
	    ADMNAME = "[Login remoto]";

	    //Salvar em LOG
		new logstring[128];
		format(logstring, sizeof(logstring), "%s - %s - Logou-se com sucesso na RCON.", ADMNAME,ip);
		SaveToFile("RCONLogins",logstring);
	}
return 1;
}


public OnVehicleSpawn(vehicleid)
{
  for (new i = 0; i < MAX_PLAYERS; i++)
	{
        if(vehicleid==PlayerInfo[i][pCar])
		{
		    CarDeleter(vehicleid);
	        PlayerInfo[i][pCar]=-1;
        }
	}
	return 1;
}
//==============================================================================
forward TuneLCar(VehicleID);
public TuneLCar(VehicleID)
{
	ChangeVehicleColor(VehicleID,0,7);
	AddVehicleComponent(VehicleID, 1010);  AddVehicleComponent(VehicleID, 1087);
}

forward RestaurarPlayer(playerid, health, armour);
public RestaurarPlayer(playerid, health, armour)
{
if(IsPlayerConnected(playerid)){
if(IsPlayerSpawned(playerid)){
KillTimer(ExplodirTimer[playerid]);
SetPlayerHealth(playerid, Float:health);
SetPlayerArmour(playerid, Float:armour);}}
}
//==============================================================================

public OnRconCommand(cmd[])
{

new rcmd[128];
new idx;
//new tmp[128];
rcmd = strtok(cmd, idx);

if( strlen(cmd) > 50 || strlen(cmd) == 1 ) return print("Comando invalido (excede 50 caracteres)");

if(strcmp(cmd, "ladmin", true)==0) {
print("Comandos do console RCON:");
print("info, aka, pm, asay, ann, uconfig, chat, crash, svplayers");
return true;}
	
	if(strcmp(cmd, "info", true)==0)
	{
	    new TotalVehicles = CreateVehicle(411, 0, 0, 0, 0, 0, 0, 1000);    DestroyVehicle(TotalVehicles);
		new numo = CreateObject(1245,0,0,1000,0,0,0);	DestroyObject(numo);
		new nump = CreatePickup(371,2,0,0,1000);	DestroyPickup(nump);
		new gz = GangZoneCreate(3,3,5,5);	GangZoneDestroy(gz);

		new model[250], nummodel;
		for(new i=1;i<TotalVehicles;i++) model[GetVehicleModel(i)-400]++;
		for(new i=0;i<250;i++) { if(model[i]!=0) {	nummodel++;	}	}

		new string[256];
		print(" ===========================================================================");
		printf("                           Server Info:");
		format(string,sizeof(string),"[ Jogadores Conectados: %d || Maximo de jogadores: %d ] [Media %0.2f ]",ConnectedPlayers(),GetMaxPlayers(),Float:ConnectedPlayers() / Float:GetMaxPlayers() );
		printf(string);
		format(string,sizeof(string),"[ Veiculos: %d || Modelos %d || Jogadores em veiculos: %d ]",TotalVehicles-1,nummodel, InVehCount() );
		printf(string);
		format(string,sizeof(string),"[ Carro %d  ||  Moto %d ]",InCarCount(),OnBikeCount() );
		printf(string);
		format(string,sizeof(string),"[ Objetos: %d || Coletas %d  || Gangzones %d]",numo-1, nump, gz);
		printf(string);
		format(string,sizeof(string),"[ Jogadores na cadeia %d || Jogadores travados %d || Mudos %d ]",JailedPlayers(),FrozenPlayers(), MutedPlayers() );
	    printf(string);
	    format(string,sizeof(string),"[ Admins online %d  RCON admins online %d ]",AdminCount(), RconAdminCount() );
	    printf(string);
		print(" ===========================================================================");
		return true;
	}

	if(!strcmp(cmd, "pm", .length = 2))
	{
	    new arg_1 = argpos(cmd), arg_2 = argpos(cmd, arg_1),targetid = strval(cmd[arg_1]), message[128];

    	if ( !cmd[arg_1] || cmd[arg_1] < '0' || cmd[arg_1] > '9' || targetid > MAX_PLAYERS || targetid < 0 || !cmd[arg_2])
	        print("| USO |: \"pm <playerid> <message>\"");

	    else if ( !IsPlayerConnected(targetid) ) print("Jogador nao esta conectado!");
    	else
	    {
	        format(message, sizeof(message), "[PM DO RCON] PM: %s", cmd[arg_2]);
	        SendClientMessage(targetid, COLOR_WHITE, message);
   	        printf("Rcon PM '%s' sent", cmd[arg_1] );
    	}
	    return true;
	}

	if(!strcmp(cmd, "asay", .length = 4))
	{
	    new arg_1 = argpos(cmd), message[128];

    	if ( !cmd[arg_1] || cmd[arg_1] < '0') print("| USO |: \"asay  <mensagem>\" (MessageToAdmins)");
	    else
	    {
	        format(message, sizeof(message), "[MENSAGEM DO RCON] MessageToAdmins: %s", cmd[arg_1]);
	        MessageToAdmins(COLOR_WHITE, message);
	        printf("Admin Message '%s' sent", cmd[arg_1] );
    	}
	    return true;
	}
	

if(!strcmp(cmd, "svplayers", .length = 9)){
print("Salvando players...");
for (new i = 0; i < MAX_PLAYERS; i++){
if(IsPlayerConnected(i) && PlayerInfo[i][LoggedIn] == 1)SavePlayer(i);}
print("Salvando propriedades...");
CallRemoteFunction("SaveProperties","i","9999999");
print("Tudo salvo!");
return true;}
	
if(!strcmp(cmd, "admins", .length = 6)){
new admins,str[100],PlayerName[MAX_PLAYER_NAME],pIP[16];
print("==================== /ADMINS ====================");
for (new i = 0; i < MAX_PLAYERS; i++)
{
    if(IsPlayerConnected(i))
    {
		if(PlayerInfo[i][Level] > 0 || IsPlayerAdmin(i))
		{
		GetPlayerName(i, PlayerName, MAX_PLAYER_NAME);
		GetPlayerIp(i, pIP, sizeof(pIP));
		format(str,sizeof(str),">> %s - [%i] - %s",PlayerName, PlayerInfo[i][Level], pIP);
		print(str);
		admins++;
		}
	}
}
format(str,sizeof(str),"> Total de administradores online: %i",admins);
print(str);
print("=================================================");
return true;}
	
	


if(!strcmp(cmd, "ann", .length = 3))
	{
	    new arg_1 = argpos(cmd), message[128];
    	if ( !cmd[arg_1] || cmd[arg_1] < '0') print("| USO |: \"ann  <mensagem>\" (GameTextForAll)");
	    else
	    {
	        format(message, sizeof(message), "%s", cmd[arg_1]);
	        GameTextForAll(message,3000,3);
	        printf("GameText '%s' enviado!", cmd[arg_1] );
    	}
	    return true;
	}

	if(!strcmp(cmd, "msg", .length = 3))
	{
	    new arg_1 = argpos(cmd), message[128];
    	if ( !cmd[arg_1] || cmd[arg_1] < '0') print("| USO |: \"msg  <mensagem>\" (SendClientMessageToAll)");
	    else
	    {
	        format(message, sizeof(message), "%s", cmd[arg_1]);
	        SendClientMessageToAll(COLOR_WHITE, message);
	        printf("MessageToAll '%s' sent", cmd[arg_1] );
    	}
	    return true;
	}
	
	if(strcmp(cmd, "uconfig", true)==0)
	{
		UpdateConfig();
		print("Config. Atualizada com sucesso!");
		return true;
	}

	if(!strcmp(cmd, "aka", .length = 3))
	{
	    new arg_1 = argpos(cmd), targetid = strval(cmd[arg_1]);

    	if ( !cmd[arg_1] || cmd[arg_1] < '0' || cmd[arg_1] > '9' || targetid > MAX_PLAYERS || targetid < 0)
	        print("| USO |: aka <playerid>");
	    else if ( !IsPlayerConnected(targetid) ) print("Jogador nao esta conectado!");
    	else
	    {
			new tmp3[50], playername[MAX_PLAYER_NAME];
	  		GetPlayerIp(targetid,tmp3,50);
			GetPlayerName(targetid, playername, sizeof(playername));
			printf("AKA: [%s id:%d] [%s] %s", playername, targetid, tmp3, dini_Get("ladmin/config/aka.txt",tmp3) );
    	}
	    return true;
	}
	
	
	if(!strcmp(cmd, "crash", .length = 5))
	{
	    new arg_1 = argpos(cmd), targetid = strval(cmd[arg_1]);

    	if ( !cmd[arg_1] || cmd[arg_1] < '0' || cmd[arg_1] > '9' || targetid > MAX_PLAYERS || targetid < 0)
	        print("| USO |: crash <playerid>");
	    else if ( !IsPlayerConnected(targetid) ) print("Jogador nao esta conectado!");
    	else
	    {
			new playername[MAX_PLAYER_NAME];
			GetPlayerName(targetid, playername, sizeof(playername));CallRemoteFunction("CrashPlayer","ii",targetid,1);
			printf("CRASH: [ID%i] %s foi crashado com sucesso!", targetid, playername);
    	}
	    return true;
	}

	if(!strcmp(cmd, "chat", .length = 4)) {
	for(new i = 1; i < MAX_CHAT_LINES; i++) print(Chat[i]);
    return true;
	}

	return 0;
}

//==============================================================================
//							Menus
//==============================================================================

#if defined USE_MENUS
public OnPlayerSelectedMenuRow(playerid, row) {
  	new Menu:Current = GetPlayerMenu(playerid);
  	new string[128];

    if(Current == LMainMenu) {
        switch(row)
		{
 			case 0:
			{
				if(PlayerInfo[playerid][Level] >= 4) ShowMenuForPlayer(AdminEnable,playerid);
   				else {
   					SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	   				TogglePlayerControllable(playerid,true);
   				}
			}
			case 1:
			{
				if(PlayerInfo[playerid][Level] >= 4) ShowMenuForPlayer(AdminDisable,playerid);
   				else {
   					SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso");
	   				TogglePlayerControllable(playerid,true);
   				}
			}
 			case 2: ShowMenuForPlayer(LWeather,playerid);
 			case 3: ShowMenuForPlayer(LTime,playerid);
   			case 4:	ShowMenuForPlayer(LVehicles,playerid);
			case 5:	ShowMenuForPlayer(LCars,playerid);
 			case 6:
            {
				if(PlayerInfo[playerid][Level] >= 2)
				{
        			if(IsPlayerInAnyVehicle(playerid))
					{
						new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
					    switch(LModel)
						{
							case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
							{
								SendClientMessage(playerid,red,"| ERRO |: Voce nao pode tunar este veiculo");  TogglePlayerControllable(playerid,true);
								return 1;
							}
						}
					    TogglePlayerControllable(playerid,false);	ShowMenuForPlayer(LTuneMenu,playerid);
			        }
					else { SendClientMessage(playerid,red,"| ERRO |: Voce nao tem veiculo para tunar"); TogglePlayerControllable(playerid,true); }
		    	} else { SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso"); TogglePlayerControllable(playerid,true);	}
			}
  			case 7:
	  		{
	  			if(PlayerInfo[playerid][Level] >= 3) ShowMenuForPlayer(XWeapons,playerid);
			  	else SendClientMessage(playerid,red,"| ERRO |: Você não tem permissão para isso"); TogglePlayerControllable(playerid,true);
			}
			case 8:	 ShowMenuForPlayer(LTele,playerid);
			case 9:
			{
				new Menu:Currentxmenu = GetPlayerMenu(playerid);
	    		HideMenuForPlayer(Currentxmenu,playerid);   TogglePlayerControllable(playerid,true);
		    }
		}
		return 1;
	}//-------------------------------------------------------------------------
	if(Current == AdminEnable) {
		new adminname[MAX_PLAYER_NAME], file[256]; GetPlayerName(playerid, adminname, sizeof(adminname));
		format(file,sizeof(file),"ladmin/config/Config.ini");
		switch(row){
			case 0: { ServerInfo[AntiSwear] = 1; dini_IntSet(file,"AntiSwear",1); format(string,sizeof(string),"Administrador (a) %s ativou Anti-Palavrao",adminname); SendClientMessageToAll(blue,string);	}
			case 1: { ServerInfo[NameKick] = 1; dini_IntSet(file,"NameKick",1); format(string,sizeof(string),"Administrador (a) %s ativou Namenick",adminname); SendClientMessageToAll(blue,string);	}
			case 2:	{ ServerInfo[AntiSpam] = 1; dini_IntSet(file,"AntiSpam",1); format(string,sizeof(string),"Administrador (a) %s ativou AntiSpam",adminname); SendClientMessageToAll(blue,string);	}
			case 3:	{ ServerInfo[MaxPing] = 1000; dini_IntSet(file,"MaxPing",1000); format(string,sizeof(string),"Administrador (a) %s ativou PingKick",adminname); SendClientMessageToAll(blue,string);	}
			case 4:	{ ServerInfo[ReadCmds] = 1; dini_IntSet(file,"ReadCmds",1); format(string,sizeof(string),"Administrador (a) %s ativou leitura de comandos",adminname); MessageToAdmins(green,string);	}
			case 5:	{ ServerInfo[ReadPMs] = 1; dini_IntSet(file,"ReadPMs",1); format(string,sizeof(string),"Administrador (a) %s ativou leitura de PMs",adminname); MessageToAdmins(green,string); }
			case 6:	{ ServerInfo[NoCaps] = 0; dini_IntSet(file,"NoCaps",0); format(string,sizeof(string),"Administrador (a) %s ativou letras maiusculas no CHAT",adminname); SendClientMessageToAll(blue,string); }
			case 7:	{ ServerInfo[ConnectMessages] = 1; dini_IntSet(file,"ConnectMessages",1); format(string,sizeof(string),"Administrador (a) %s ativou mensagens de conexao",adminname); SendClientMessageToAll(blue,string); }
			case 8:	{ ServerInfo[AdminCmdMsg] = 1; dini_IntSet(file,"AdminCmdMessages",1); format(string,sizeof(string),"Administrador (a) %s ativou mensagens de comando e admin",adminname); MessageToAdmins(green,string); }
			case 9:	{ ServerInfo[AutoLogin] = 1; dini_IntSet(file,"AutoLogin",1); format(string,sizeof(string),"Administrador (a) %s ativou Auto-Login",adminname); SendClientMessageToAll(blue,string); }
            case 10: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}//------------------------------------------------------------------------
	if(Current == AdminDisable) {
		new adminname[MAX_PLAYER_NAME], file[256]; GetPlayerName(playerid, adminname, sizeof(adminname));
		format(file,sizeof(file),"ladmin/config/Config.ini");
		switch(row){
			case 0: { ServerInfo[AntiSwear] = 0; dini_IntSet(file,"AntiSwear",0); format(string,sizeof(string),"Administrador (a) %s desativou Anti-Palavrao",adminname); SendClientMessageToAll(blue,string);	}
			case 1: { ServerInfo[NameKick] = 0; dini_IntSet(file,"NameKick",0); format(string,sizeof(string),"Administrador (a) %s desativou Namenick",adminname); SendClientMessageToAll(blue,string);	}
			case 2:	{ ServerInfo[AntiSpam] = 0; dini_IntSet(file,"AntiSpam",0); format(string,sizeof(string),"Administrador (a) %s desativou AntiSpam",adminname); SendClientMessageToAll(blue,string);	}
			case 3:	{ ServerInfo[MaxPing] = 0; dini_IntSet(file,"MaxPing",0); format(string,sizeof(string),"Administrador (a) %s desativou PingKick",adminname); SendClientMessageToAll(blue,string);	}
			case 4:	{ ServerInfo[ReadCmds] = 0; dini_IntSet(file,"ReadCmds",0); format(string,sizeof(string),"Administrador (a) %s desativou leitura de comandos",adminname); MessageToAdmins(green,string);	}
			case 5:	{ ServerInfo[ReadPMs] = 0; dini_IntSet(file,"ReadPMs",0); format(string,sizeof(string),"Administrador (a) %s desativou leitura de PMs",adminname); MessageToAdmins(green,string); }
			case 6:	{ ServerInfo[NoCaps] = 1; dini_IntSet(file,"NoCaps",1); format(string,sizeof(string),"Administrador (a) %s desativou letras maiusculas no CHAT",adminname); SendClientMessageToAll(blue,string); }
			case 7:	{ ServerInfo[ConnectMessages] = 0; dini_IntSet(file,"ConnectMessages",0); format(string,sizeof(string),"Administrador (a) %s desativou mensagens de conexao",adminname); SendClientMessageToAll(blue,string); }
			case 8:	{ ServerInfo[AdminCmdMsg] = 0; dini_IntSet(file,"AdminCmdMessages",0); format(string,sizeof(string),"Administrador (a) %s desativou mensagens de comando e admin",adminname); MessageToAdmins(green,string); }
			case 9:	{ ServerInfo[AutoLogin] = 0; dini_IntSet(file,"AutoLogin",0); format(string,sizeof(string),"Administrador (a) %s desativou Auto-Login",adminname); SendClientMessageToAll(blue,string); }
            case 10: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}//-------------------------------------------------------------------------
	if(Current==LVehicles){
		switch(row){
			case 0: ChangeMenu(playerid,Current,twodoor);
			case 1: ChangeMenu(playerid,Current,fourdoor);
			case 2: ChangeMenu(playerid,Current,fastcar);
			case 3: ChangeMenu(playerid,Current,Othercars);
			case 4: ChangeMenu(playerid,Current,bikes);
			case 5: ChangeMenu(playerid,Current,boats);
			case 6: ChangeMenu(playerid,Current,planes);
			case 7: ChangeMenu(playerid,Current,helicopters);
			case 8: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return 1;
	}
	if(Current==twodoor){
		new vehid;
		switch(row){
			case 0: vehid = 533;
			case 1: vehid = 439;
			case 2: vehid = 555;
			case 3: vehid = 422;
			case 4: vehid = 554;
			case 5: vehid = 575;
			case 6: vehid = 536;
			case 7: vehid = 535;
			case 8: vehid = 576;
			case 9: vehid = 401;
			case 10: vehid = 526;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==fourdoor){
		new vehid;
		switch(row){
			case 0: vehid = 404;
			case 1: vehid = 566;
			case 2: vehid = 412;
			case 3: vehid = 445;
			case 4: vehid = 507;
			case 5: vehid = 466;
			case 6: vehid = 546;
			case 7: vehid = 511;
			case 8: vehid = 467;
			case 9: vehid = 426;
			case 10: vehid = 405;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==fastcar){
		new vehid;
		switch(row){
			case 0: vehid = 480;
			case 1: vehid = 402;
			case 2: vehid = 415;
			case 3: vehid = 587;
			case 4: vehid = 494;
			case 5: vehid = 411;
			case 6: vehid = 603;
			case 7: vehid = 506;
			case 8: vehid = 451;
			case 9: vehid = 477;
			case 10: vehid = 541;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==Othercars){
		new vehid;
		switch(row){
			case 0: vehid = 556;
			case 1: vehid = 408;
			case 2: vehid = 431;
			case 3: vehid = 437;
			case 4: vehid = 427;
			case 5: vehid = 432;
			case 6: vehid = 601;
			case 7: vehid = 524;
			case 8: vehid = 455;
			case 9: vehid = 424;
			case 10: vehid = 573;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==bikes){
		new vehid;
		switch(row){
			case 0: vehid = 581;
			case 1: vehid = 481;
			case 2: vehid = 462;
			case 3: vehid = 521;
			case 4: vehid = 463;
			case 5: vehid = 522;
			case 6: vehid = 461;
			case 7: vehid = 448;
			case 8: vehid = 471;
			case 9: vehid = 468;
			case 10: vehid = 586;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==boats){
		new vehid;
		switch(row){
			case 0: vehid = 472;
			case 1: vehid = 473;
			case 2: vehid = 493;
			case 3: vehid = 595;
			case 4: vehid = 484;
			case 5: vehid = 430;
			case 6: vehid = 453;
			case 7: vehid = 452;
			case 8: vehid = 446;
			case 9: vehid = 454;
			case 10: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==planes){
		new vehid;
		switch(row){
			case 0: vehid = 592;
			case 1: vehid = 577;
			case 2: vehid = 511;
			case 3: vehid = 512;
			case 4: vehid = 593;
			case 5: vehid = 520;
			case 6: vehid = 553;
			case 7: vehid = 476;
			case 8: vehid = 519;
			case 9: vehid = 460;
			case 10: vehid = 513;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==helicopters){
		new vehid;
		switch(row){
			case 0: vehid = 548;
			case 1: vehid = 425;
			case 2: vehid = 417;
			case 3: vehid = 487;
			case 4: vehid = 488;
			case 5: vehid = 497;
			case 6: vehid = 563;
			case 7: vehid = 447;
			case 8: vehid = 469;
			case 9: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}

	if(Current==XWeapons){
		switch(row){
			case 0: { GivePlayerWeapon(playerid,24,500); }
			case 1: { GivePlayerWeapon(playerid,31,500); }
			case 2: { GivePlayerWeapon(playerid,26,500); }
			case 3: { GivePlayerWeapon(playerid,27,500); }
			case 4: { GivePlayerWeapon(playerid,28,500); }
			case 5: { GivePlayerWeapon(playerid,35,500); }
			case 6: { GivePlayerWeapon(playerid,38,1000); }
			case 7: { GivePlayerWeapon(playerid,34,500); }
			case 8: return ChangeMenu(playerid,Current,XWeaponsBig);
        	case 9: return ChangeMenu(playerid,Current,XWeaponsSmall);
        	case 10: return ChangeMenu(playerid,Current,XWeaponsMore);
        	case 11: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

	if(Current==XWeaponsBig){
		switch(row){
			case 0: { GivePlayerWeapon(playerid,25,500);  }
			case 1: { GivePlayerWeapon(playerid,30,500); }
			case 2: { GivePlayerWeapon(playerid,33,500); }
			case 3: { GivePlayerWeapon(playerid,36,500); }
			case 4: { GivePlayerWeapon(playerid,37,500); }
			case 5: { GivePlayerWeapon(playerid,29,500); }
			case 6: { GivePlayerWeapon(playerid,32,1000); }
			case 7: return ChangeMenu(playerid,Current,XWeapons);
		}
		return TogglePlayerControllable(playerid,true);
	}

	if(Current==XWeaponsSmall){
		switch(row){
			case 0: { GivePlayerWeapon(playerid,22,500); }//9mm
			case 1: { GivePlayerWeapon(playerid,23,500); }//s9
			case 2: { GivePlayerWeapon(playerid,18,500); }// MC
			case 3: { GivePlayerWeapon(playerid,42,500); }//FE
			case 4: { GivePlayerWeapon(playerid,41,500); }//spraycan
			case 5: { GivePlayerWeapon(playerid,16,500); }//grenade
			case 6: { GivePlayerWeapon(playerid,8,500); }//Katana
			case 7: { GivePlayerWeapon(playerid,9,1000); }//chainsaw
			case 8: return ChangeMenu(playerid,Current,XWeapons);
		}
		return TogglePlayerControllable(playerid,true);
	}

	if(Current==XWeaponsMore){
		switch(row){
			case 0: SetPlayerSpecialAction(playerid, 2);
			case 1: GivePlayerWeapon(playerid,4,500);
			case 2: GivePlayerWeapon(playerid,14,500);
			case 3: GivePlayerWeapon(playerid,43,500);
			case 4: GivePlayerWeapon(playerid,7,500);
			case 5: GivePlayerWeapon(playerid,5,500);
			case 6: GivePlayerWeapon(playerid,2,1000);
			case 7: MaxAmmo(playerid);
			case 8: return ChangeMenu(playerid,Current,XWeapons);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LTele)
	{
        switch(row)
		{
			case 0: ChangeMenu(playerid,Current,LasVenturasMenu);
			case 1: ChangeMenu(playerid,Current,LosSantosMenu);
			case 2: ChangeMenu(playerid,Current,SanFierroMenu);
			case 3: ChangeMenu(playerid,Current,DesertMenu);
			case 4: ChangeMenu(playerid,Current,FlintMenu);
			case 5: ChangeMenu(playerid,Current,MountChiliadMenu);
			case 6: ChangeMenu(playerid,Current,InteriorsMenu);
			case 7: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return 1;
	}

    if(Current == LasVenturasMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,2037.0,1343.0,12.0); SetPlayerInterior(playerid,0); }// strip
			case 1: { SetPlayerPos(playerid,2163.0,1121.0,23); SetPlayerInterior(playerid,0); }// come a lot
			case 2: { SetPlayerPos(playerid,1688.0,1615.0,12.0); SetPlayerInterior(playerid,0); }// lv airport
			case 3: { SetPlayerPos(playerid,2503.0,2764.0,10.0); SetPlayerInterior(playerid,0); }// military fuel
			case 4: { SetPlayerPos(playerid,1418.0,2733.0,10.0); SetPlayerInterior(playerid,0); }// golf lv
			case 5: { SetPlayerPos(playerid,1377.0,2196.0,9.0); SetPlayerInterior(playerid,0); }// pitch match
			case 6: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LosSantosMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,2495.0,-1688.0,13.0); SetPlayerInterior(playerid,0); }// ganton
			case 1: { SetPlayerPos(playerid,1979.0,-2241.0,13.0); SetPlayerInterior(playerid,0); }// ls airport
			case 2: { SetPlayerPos(playerid,2744.0,-2435.0,15.0); SetPlayerInterior(playerid,0); }// docks
			case 3: { SetPlayerPos(playerid,1481.0,-1656.0,14.0); SetPlayerInterior(playerid,0); }// square
			case 4: { SetPlayerPos(playerid,1150.0,-2037.0,69.0); SetPlayerInterior(playerid,0); }// veradant bluffs
			case 5: { SetPlayerPos(playerid,425.0,-1815.0,6.0); SetPlayerInterior(playerid,0); }// santa beach
			case 6: { SetPlayerPos(playerid,1240.0,-744.0,95.0); SetPlayerInterior(playerid,0); }// mullholland
			case 7: { SetPlayerPos(playerid,679.0,-1070.0,49.0); SetPlayerInterior(playerid,0); }// richman
			case 8: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == SanFierroMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,-1990.0,137.0,27.0); SetPlayerInterior(playerid,0); } // sf station
			case 1: { SetPlayerPos(playerid,-1528.0,-206.0,14.0); SetPlayerInterior(playerid,0); }// sf airport
			case 2: { SetPlayerPos(playerid,-2709.0,198.0,4.0); SetPlayerInterior(playerid,0); }// ocean flats
			case 3: { SetPlayerPos(playerid,-2738.0,-295.0,6.0); SetPlayerInterior(playerid,0); }// avispa country club
			case 4: { SetPlayerPos(playerid,-1457.0,465.0,7.0); SetPlayerInterior(playerid,0); }// easter basic docks
			case 5: { SetPlayerPos(playerid,-1853.0,1404.0,7.0); SetPlayerInterior(playerid,0); }// esplanadae north
			case 6: { SetPlayerPos(playerid,-2620.0,1373.0,7.0); SetPlayerInterior(playerid,0); }// battery point
			case 7: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == DesertMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,416.0,2516.0,16.0); SetPlayerInterior(playerid,0); } // plane graveyard
			case 1: { SetPlayerPos(playerid,81.0,1920.0,17.0); SetPlayerInterior(playerid,0); }// area51
			case 2: { SetPlayerPos(playerid,-324.0,1516.0,75.0); SetPlayerInterior(playerid,0); }// big ear
			case 3: { SetPlayerPos(playerid,-640.0,2051.0,60.0); SetPlayerInterior(playerid,0); }// dam
			case 4: { SetPlayerPos(playerid,-766.0,1545.0,27.0); SetPlayerInterior(playerid,0); }// las barrancas
			case 5: { SetPlayerPos(playerid,-1514.0,2597.0,55.0); SetPlayerInterior(playerid,0); }// el qyebrados
			case 6: { SetPlayerPos(playerid,442.0,1427.0,9.0); SetPlayerInterior(playerid,0); }// actane springs
			case 7: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == FlintMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,-849.0,-1940.0,13.0);  SetPlayerInterior(playerid,0); }// lake
			case 1: { SetPlayerPos(playerid,-1107.0,-1619.0,76.0);  SetPlayerInterior(playerid,0); }// leafy hollow
			case 2: { SetPlayerPos(playerid,-1049.0,-1199.0,128.0);  SetPlayerInterior(playerid,0); }// the farm
			case 3: { SetPlayerPos(playerid,-1655.0,-2219.0,32.0);  SetPlayerInterior(playerid,0); }// shady cabin
			case 4: { SetPlayerPos(playerid,-375.0,-1441.0,25.0); SetPlayerInterior(playerid,0); }// flint range
			case 5: { SetPlayerPos(playerid,-367.0,-1049.0,59.0); SetPlayerInterior(playerid,0); }// beacon hill
			case 6: { SetPlayerPos(playerid,-494.0,-555.0,25.0); SetPlayerInterior(playerid,0); }// fallen tree
			case 7: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == MountChiliadMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,-2308.0,-1657.0,483.0);  SetPlayerInterior(playerid,0); }// chiliad jump
			case 1: { SetPlayerPos(playerid,-2331.0,-2180.0,35.0); SetPlayerInterior(playerid,0); }// bottom chiliad
			case 2: { SetPlayerPos(playerid,-2431.0,-1620.0,526.0);  SetPlayerInterior(playerid,0); }// highest point
			case 3: { SetPlayerPos(playerid,-2136.0,-1775.0,208.0);  SetPlayerInterior(playerid,0); }// chiliad path
			case 4: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == InteriorsMenu)
	{
        switch(row)
		{
			case 0: {	SetPlayerPos(playerid,386.5259, 173.6381, 1008.3828);	SetPlayerInterior(playerid,3); }
			case 1: {	SetPlayerPos(playerid,288.4723, 170.0647, 1007.1794);	SetPlayerInterior(playerid,3); }
			case 2: {	SetPlayerPos(playerid,372.5565, -131.3607, 1001.4922);	SetPlayerInterior(playerid,5); }
			case 3: {	SetPlayerPos(playerid,-1129.8909, 1057.5424, 1346.4141);	SetPlayerInterior(playerid,10); }
			case 4: {	SetPlayerPos(playerid,2233.9363, 1711.8038, 1011.6312);	SetPlayerInterior(playerid,1); }
			case 5: {	SetPlayerPos(playerid,2536.5322, -1294.8425, 1044.125);	SetPlayerInterior(playerid,2); }
			case 6: {	SetPlayerPos(playerid,1267.8407, -776.9587, 1091.9063);	SetPlayerInterior(playerid,5); }
  			case 7: {	SetPlayerPos(playerid,-1421.5618, -663.8262, 1059.5569);	SetPlayerInterior(playerid,4); }
   			case 8: {	SetPlayerPos(playerid,-1401.067, 1265.3706, 1039.8672);	SetPlayerInterior(playerid,16); }
   			case 9: {	SetPlayerPos(playerid,285.8361, -39.0166, 1001.5156);	SetPlayerInterior(playerid,1); }
    		case 10: {	SetPlayerPos(playerid,1727.2853, -1642.9451, 20.2254);	SetPlayerInterior(playerid,18); }
			case 11: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LWeather)
	{
		new adminname[MAX_PLAYER_NAME]; GetPlayerName(playerid, adminname, sizeof(adminname));
        switch(row)
		{
			case 0:	{	SetWeather(5);	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);	CMDMessageToAdmins(playerid,"SETWEATHER"); format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
   			case 1:	{	SetWeather(19); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 2:	{	SetWeather(8);  PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 3:	{	SetWeather(20);	PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 4:	{	SetWeather(9);  PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 5:	{	SetWeather(16); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 6:	{	SetWeather(45); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 7:	{	SetWeather(44); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 8:	{	SetWeather(22); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 9:	{	SetWeather(11); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"SETWEATHER");	format(string,sizeof(string),"Administrador (a) %s mudou o clima",adminname); SendClientMessageToAll(blue,string); }
			case 10: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LTuneMenu)
	{
        switch(row)
		{
			case 0:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1010); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
   			case 1:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1087); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado"); }
			case 2:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1081); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
			case 3: {	AddVehicleComponent(GetPlayerVehicleID(playerid),1078); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
			case 4:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1098); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
			case 5:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1074); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
			case 6:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1082); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
			case 7:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1085); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
			case 8:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1025); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
			case 9:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1077); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Componente de veiculo adcionado");	}
			case 10: return ChangeMenu(playerid,Current,PaintMenu);
			case 11: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == PaintMenu)
	{
        switch(row)
		{
			case 0:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),0); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Pintura de veiculo modificada para Pintura 1"); }
			case 1:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),1); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Pintura de veiculo modificada para Pintura 2"); }
			case 2:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),2); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Pintura de veiculo modificada para Pintura 3"); }
			case 3:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),3); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Pintura de veiculo modificada para Pintura 4"); }
			case 4:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),4); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Pintura de veiculo modificada para Pintura 5"); }
			case 5:	{ ChangeVehicleColor(GetPlayerVehicleID(playerid),0,0); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Pintura de veiculo modificada para Preto"); }
			case 6:	{ ChangeVehicleColor(GetPlayerVehicleID(playerid),1,1); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Pintura de veiculo modificada para Branco"); }
			case 7:	{ ChangeVehicleColor(GetPlayerVehicleID(playerid),79,158); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Pintura de veiculo modificada para Preto"); }
			case 8:	{ ChangeVehicleColor(GetPlayerVehicleID(playerid),146,183); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"VPintura de veiculo modificada para Preto"); }
			case 9: return ChangeMenu(playerid,Current,LTuneMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LTime)
	{
		new adminname[MAX_PLAYER_NAME]; GetPlayerName(playerid, adminname, sizeof(adminname));
        switch(row)
		{
			case 0:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,7,0);	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);	CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Administrador %s mudou o horario",adminname); SendClientMessageToAll(blue,string); }
   			case 1:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,12,0); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Administrador %s mudou o horario",adminname); SendClientMessageToAll(blue,string); }
			case 2:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,16,0);  PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Administrador %s mudou o horario",adminname); SendClientMessageToAll(blue,string); }
			case 3:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,20,0);	PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Administrador %s mudou o horario",adminname); SendClientMessageToAll(blue,string); }
			case 4:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,0,0);  PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Administrador %s mudou o horario",adminname); SendClientMessageToAll(blue,string); }
			case 5: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LCars)
	{
		new vehid;
        switch(row) {
			case 0: vehid = 451;//Turismo
			case 1: vehid = 568;//Bandito
			case 2: vehid = 539;//Vortex
			case 3: vehid = 522;//nrg
			case 4: vehid = 601;//s.w.a.t
			case 5: vehid = 425; //hunter
			case 6: vehid = 493;//jetmax
			case 7: vehid = 432;//rhino
			case 8: vehid = 444; //mt
			case 9: vehid = 447; //sea sparrow
			case 10: return ChangeMenu(playerid,Current,LCars2);
			case 11: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return SelectCar(playerid,vehid,Current);
	}

    if(Current == LCars2)
	{
		new vehid;
        switch(row) {
			case 0: vehid = 406;// dumper
			case 1: vehid = 564; //rc tank
			case 2: vehid = 441;//RC Bandit
			case 3: vehid = 464;// rc baron
			case 4: vehid = 501; //rc goblin
			case 5: vehid = 465; //rc raider
			case 6: vehid = 594; // rc cam
			case 7: vehid = 449; //tram
			case 8: return ChangeMenu(playerid,Current,LCars);
		}
		return SelectCar(playerid,vehid,Current);
	}

	return 1;
}

//==============================================================================



//ANTI BULLET CRASH
forward OnPlayerWeaponShot( playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ );
public OnPlayerWeaponShot( playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ )
{
    if( hittype != BULLET_HIT_TYPE_NONE ) // Bullet Crashing uses just this hittype
	{
        if( !( -1000.0 <= fX <= 1000.0 ) || !( -1000.0 <= fY <= 1000.0 ) || !( -1000.0 <= fZ <= 1000.0 ) ) // a valid offset, it's impossible that a offset bigger than 1000 is legit (also less than -1000.0 is impossible, not used by this hack, but still, let's check for it, just for the future, who knows what hacks will appear). The object with biggest offset is having ~700-800 radius.
		{
			/*
				If you want, here you can kick the cheater
			*/
			return 0; // let's desynchronize that bullet, so players won't crash
		}
	}
    return 1;
}


//ANTI BIKE AND TRAIN CRASH
public OnVehicleMod(playerid,vehicleid,componentid)
{
    printf("Vehicle %d was modded by ID %d with the componentid %d",vehicleid,playerid,componentid);
    if(GetPlayerInterior(playerid) == 0)
    {
         BanEx(playerid, "Tuning Hacks");
    }
    return 1;
}




// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

public OnPlayerExitedMenu(playerid)
{
    new Menu:Current = GetPlayerMenu(playerid);
    HideMenuForPlayer(Current,playerid);
    return TogglePlayerControllable(playerid,true);
}

//==============================================================================

ChangeMenu(playerid,Menu:oldmenu,Menu:newmenu)
{
	if(IsValidMenu(oldmenu)) {
		HideMenuForPlayer(oldmenu,playerid);
		ShowMenuForPlayer(newmenu,playerid);
	}
	return 1;
}

CloseMenu(playerid,Menu:oldmenu)
{
	HideMenuForPlayer(oldmenu,playerid);
	TogglePlayerControllable(playerid,1);
	return 1;
}
SelectCar(playerid,vehid,Menu:menu)
{
	CloseMenu(playerid,menu);
	SetCameraBehindPlayer(playerid);
	CarSpawner(playerid,vehid);
	return 1;
}
#endif

//==============================================================================
forward countdown();
public countdown()
{
	if(CountDown==6) GameTextForAll("~p~Iniciando...",1000,6);

	CountDown--;
	if(CountDown==0)
	{
		GameTextForAll("~b~GO~ r~!",1000,6);
		CountDown = -1;
		for (new i = 0; i < MAX_PLAYERS; i++) {
			TogglePlayerControllable(i,true);
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		}
		return 0;
	}
	else
	{
		new text[7]; format(text,sizeof(text),"~w~%d",CountDown);
		for (new i = 0; i < MAX_PLAYERS; i++) {
			PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
			TogglePlayerControllable(i,false);
		}
	 	GameTextForAll(text,1000,6);
	}
	
	SetTimer("countdown",1000,0);
	return 0;
}

forward Duel(player1, player2);
public Duel(player1, player2)
{
	if(cdt[player1]==6) {
		GameTextForPlayer(player1,"~p~Iniciando duelo...",1000,6); GameTextForPlayer(player2,"~p~Iniciando duelo...",1000,6);
	}

	cdt[player1]--;
	if(cdt[player1]==0)
	{
		TogglePlayerControllable(player1,1); TogglePlayerControllable(player2,1);
		PlayerPlaySound(player1, 1057, 0.0, 0.0, 0.0); PlayerPlaySound(player2, 1057, 0.0, 0.0, 0.0);
		GameTextForPlayer(player1,"~g~GO~ r~!",1000,6); GameTextForPlayer(player2,"~g~GO~ r~!",1000,6);
		return 0;
	}
	else
	{
		new text[7]; format(text,sizeof(text),"~w~%d",cdt[player1]);
		PlayerPlaySound(player1, 1056, 0.0, 0.0, 0.0); PlayerPlaySound(player2, 1056, 0.0, 0.0, 0.0);
		TogglePlayerControllable(player1,0); TogglePlayerControllable(player2,0);
		GameTextForPlayer(player1,text,1000,6); GameTextForPlayer(player2,text,1000,6);
	}

	SetTimerEx("Duel",1000,0,"dd", player1, player2);
	return 0;
}

//==================== [ Jail & Freeze ]========================================

forward Jail1(player1);
public Jail1(player1)
{
	TogglePlayerControllable(player1,false);
	new Float:x, Float:y, Float:z;	GetPlayerPos(player1,x,y,z);
	SetPlayerCameraPos(player1,x+10,y,z+10);SetPlayerCameraLookAt(player1,x,y,z);
	SetTimerEx("Jail2",1000,0,"d",player1);
}

forward Jail2(player1);
public Jail2(player1)
{
	new Float:x, Float:y, Float:z; GetPlayerPos(player1,x,y,z);
	SetPlayerCameraPos(player1,x+7,y,z+5); SetPlayerCameraLookAt(player1,x,y,z);
	if(GetPlayerState(player1) == PLAYER_STATE_ONFOOT) SetPlayerSpecialAction(player1,SPECIAL_ACTION_HANDSUP);
	GameTextForPlayer(player1,"~r~Voce esta preso!",3000,3);
	SetTimerEx("Jail3",1000,0,"d",player1);
}

forward Jail3(player1);
public Jail3(player1)
{
	new Float:x, Float:y, Float:z; GetPlayerPos(player1,x,y,z);
	SetPlayerCameraPos(player1,x+3,y,z); SetPlayerCameraLookAt(player1,x,y,z);
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward LJail(playerid,timems);
public LJail(playerid,timems)
{
KillTimer(JailTimer[playerid]);
PlayerInfo[playerid][JailTime] = timems;
JailPlayer(playerid);
return 1;
}

forward JailPlayer(player1);
public JailPlayer(player1)
{
	KillTimer(JailTimer[player1]);
	TogglePlayerControllable(player1,0);
	ResetPlayerWeapons(player1);
	SetPlayerPos(player1,197.6661,173.8179,1003.0234);
	SetPlayerInterior(player1,3);
	SetCameraBehindPlayer(player1);
	JailTimer[player1] = SetTimerEx("ProcessarCadeiaSegundo",1000,1,"i",player1);
    PlayAudioStreamForPlayer(player1, "http://online.radiorecord.ru:8101/rr_320");
	PlayerInfo[player1][Jailed] = 1;
	SetPlayerVirtualWorld(player1, 1000);
}

forward JailRelease(player1);
public JailRelease(player1)
{
	KillTimer(JailTimer[player1]);
	TogglePlayerControllable(player1,1);
	PlayerInfo[player1][JailTime] = 0;  PlayerInfo[player1][Jailed] = 0;
PlayerInfo[player1][Muted] = 0;
	SetPlayerInterior(player1,0); SetPlayerPos(player1, 0.0, 0.0, 0.0); SpawnPlayer(player1);
	PlayerPlaySound(player1,1057,0.0,0.0,0.0);
	GameTextForPlayer(player1,"_~n~_~n~_~n~_~n~_~n~_~n~~y~~g~Solto da cadeia!",5000,3);
}                              


forward ProcessarCadeiaSegundo(playerid);
public ProcessarCadeiaSegundo(playerid)
{
PlayerInfo[playerid][JailTime] = PlayerInfo[playerid][JailTime]-1000 ;
if(PlayerInfo[playerid][JailTime] <= 0) {JailRelease(playerid); return 1;}
new str[100];           
format(str,sizeof(str),"_~n~_~n~_~n~_~n~_~n~_~n~~y~Voce sera solto em:~n~~w~%i ~y~segundos", PlayerInfo[playerid][JailTime]/1000);
GameTextForPlayer(playerid,str,10000,3);
return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

//------------------------------------------------------------------------------
forward UnFreezeMe(player1);
public UnFreezeMe(player1)
{
	KillTimer( FreezeTimer[player1] );
	TogglePlayerControllable(player1,true);   PlayerInfo[player1][Frozen] = 0;
	PlayerPlaySound(player1,1057,0.0,0.0,0.0);	GameTextForPlayer(player1,"~g~Destravado",3000,3);
}

//==============================================================================
forward RepairCar(playerid);
public RepairCar(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(GetPlayerVehicleID(playerid),Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]+0.5);
	SetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[playerid][3]);
	SetCameraBehindPlayer(playerid);
}

//============================ [ Timers ]=======================================

forward PingKick();
public PingKick()
{
	if(ServerInfo[MaxPing] != 0)
	{
	    PingPos++; if(PingPos > PING_MAX_EXCEEDS) PingPos = 0;
	    
		for(new i,a = GetMaxPlayers();i < a;i++)
		{
			PlayerInfo[i][pPing][PingPos] = GetPlayerPing(i);
			
		    if(GetPlayerPing(i) > ServerInfo[MaxPing])
			{
				if(PlayerInfo[i][PingCount] == 0) PlayerInfo[i][PingTime] = TimeStamp();

	   			PlayerInfo[i][PingCount]++;
				if(TimeStamp() - PlayerInfo[i][PingTime] > PING_TIMELIMIT)
				{
	    			PlayerInfo[i][PingTime] = TimeStamp();
					PlayerInfo[i][PingCount] = 1;
				}
				else if(PlayerInfo[i][PingCount] >= PING_MAX_EXCEEDS)
				{
				    new Sum, Average, x, string[128];
					while (x < PING_MAX_EXCEEDS) {
						Sum += PlayerInfo[i][pPing][x];
						x++;
					}
					Average = (Sum / PING_MAX_EXCEEDS);
					format(string,sizeof(string),"{00FFFB}%s foi kickado do servidor. (Motivo: Alto Ping (%d) | Media (%d) | Maximo Permitido (%d) )", PlayerName2(i), GetPlayerPing(i), Average, ServerInfo[MaxPing] );
  		    		SendClientMessageToAll(grey,string);
					SaveToFile("KickLog",string);
					Kick(i);
				}
			}
			else if(GetPlayerPing(i) < 1 && ServerInfo[AntiBot] == 1)
		    {
				PlayerInfo[i][BotPing]++;
				if(PlayerInfo[i][BotPing] >= 3) BotCheck(i);
		    }
		    else
			{
				PlayerInfo[i][BotPing] = 0;
			}
		}
	}

	#if defined ANTI_MINIGUN
	new weap, ammo;
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && PlayerInfo[i][Level] == 0)
		{
			GetPlayerWeaponData(i, 7, weap, ammo);
			if(ammo > 1 && weap == 38) {
				new string[128]; format(string,sizeof(string),"INFO: %s tem uma minigun com %d de municao", PlayerName2(i), ammo);
				MessageToAdmins(COLOR_WHITE,string);
			}
		}
	}
	#endif
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
//mmmi //vermelhor {FF0000}Player Comum


//meu  //roxo {8A2BE2}Gerente™ Administrativo
//meu  //azul fortim {1E90FF}Player VIP!
/*
if(source == CLICK_SOURCE_SCOREBOARD)
{
	new admstring[128],P1NAME[MAX_PLAYER_NAME],P2NAME[MAX_PLAYER_NAME];
 	GetPlayerName(playerid, P1NAME, sizeof(P1NAME));GetPlayerName(clickedplayerid, P2NAME, sizeof(P2NAME));
    format(admstring, sizeof(admstring), "» CLICK >> %s Clicou em %s na scoreboard.",P1NAME,P2NAME);
    for (new i = 0; i < MAX_PLAYERS; i++){
	if(IsPlayerConnected(i) && PlayerInfo[i][Level] >= 5) {
	SendClientMessage(i,0xFF9900AA,admstring);}}

	new string[1800],string2[1800],posto[128],pDeaths;
	switch(PlayerInfo[clickedplayerid][Level]){
	case 0: format(posto, sizeof(posto), "{A52A2A}Player MIT0!");
	case 1: format(posto, sizeof(posto), "{8A2BE2}Administrador(a) Novato!!!");
	case 2: format(posto, sizeof(posto), "{1E90FF}Administrador(a) Aprendiz!!!");
	case 3: format(posto, sizeof(posto), "{1E90FF}Administrador(a) Responsavel!!!!");
	case 4: format(posto, sizeof(posto), "{1E90FF}Administrador(a) Experiente!!!!!");
	case 5: format(posto, sizeof(posto), "{1E90FF}Gerente™ Administrativo!!!!!!");//GERENTE™ ADM1NISTRAT1V0!");
	case 6: format(posto, sizeof(posto), "{C0FF3E}SUB-OWNER™!!!!!!!");
	case 7: format(posto, sizeof(posto), "{C0FF3E}OWNER™!!!!!!!!");}
	if(TempADM[clickedplayerid] == true)
	format(posto, sizeof(posto), "{FF1493}Administrador(a) Temporário!");

	if(AdmHidden[clickedplayerid] == true && PlayerInfo[playerid][Level] < 1) format(posto, sizeof(posto), "{A52A2A}Player MIT0!");
	
	if(PlayerInfo[clickedplayerid][Deaths] == 0) pDeaths = 1; else pDeaths = PlayerInfo[clickedplayerid][Deaths];

	new Float:media = Float:PlayerInfo[clickedplayerid][Kills]/Float:pDeaths;
	new aval[22];
	if(media == 0) aval = "{EAFF00}Sossegado";
	if(media > 0 && media <= 0.3) aval = "{FF0000}Fracassado";
	if(media > 0.3 && media <= 0.5) aval = "{FF3C00}Péssimo";
	if(media > 0.5 && media <= 0.7) aval = "{FF8800}Muito ruim";
	if(media > 0.7 && media <= 0.9) aval = "{FFBF00}Ruim";
	if(media > 0.9 && media < 1.0) aval = "{FFD900}Fraco";
	if(media == 1.0) aval = "{EAFF00}Médio";
	if(media > 1.0 && media <= 2) aval = "{BBFF00}Quase bom";
	if(media > 2 && media <= 4) aval = "{8CFF00}Bom";
	if(media > 4 && media <= 6) aval = "{37FF00}Muito bom";
	if(media > 6 && media <= 8) aval = "{00FF00}Excelente";
	if(media > 8 && media <= 10) aval = "{00FF00}Viciado";
	if(media > 10) aval = "{00FF00}Chuck Norris";

	new X1G = CallRemoteFunction("GetPlayerX1Ganho", "i", clickedplayerid);
	new X1P = CallRemoteFunction("GetPlayerX1Perdido", "i", clickedplayerid);
//////////// MEDIA X1 TESTE
	new Float:mediaX1 = Float:X1G/Float:X1P;
	new avalX1[22];
	if(mediaX1 == 0) avalX1 = "{EAFF00}Sossegado";
	if(mediaX1 > 0 && mediaX1 <= 0.3) avalX1 = "{FF0000}Fracassado";
	if(mediaX1 > 0.3 && mediaX1 <= 0.5) avalX1 = "{FF3C00}Péssimo";
	if(mediaX1 > 0.5 && mediaX1 <= 0.7) avalX1 = "{FF8800}Muito ruim";
	if(mediaX1 > 0.7 && mediaX1 <= 0.9) avalX1 = "{FFBF00}Ruim";
	if(mediaX1 > 0.9 && mediaX1 < 1.0) avalX1 = "{FFD900}Fraco";
	if(mediaX1 == 1.0) avalX1 = "{EAFF00}Médio";
	if(mediaX1 > 1.0 && mediaX1 <= 2) avalX1 = "{BBFF00}Quase bom";
	if(mediaX1 > 2 && mediaX1 <= 4) avalX1 = "{8CFF00}Bom";
	if(mediaX1 > 4 && mediaX1 <= 6) avalX1 = "{37FF00}Muito bom";
	if(mediaX1 > 6 && mediaX1 <= 8) avalX1 = "{00FF00}Excelente";
	if(mediaX1 > 8 && mediaX1 <= 10) avalX1 = "{00FF00}Viciado";
	if(mediaX1 > 10) avalX1 = "{00FF00}Chuck Norris";
//////////// MEDIA X1 TESTE


	new X1WG = CallRemoteFunction("GetPlayerX1WGanho", "i", clickedplayerid);
	new X1WP = CallRemoteFunction("GetPlayerX1WPerdido", "i", clickedplayerid);
//////////// MEDIA X1W TESTE
	new Float:mediaX1W = Float:X1WG/Float:X1WP;
	new avalX1W[22];
	if(mediaX1W == 0) avalX1W = "{EAFF00}Sossegado";
	if(mediaX1W > 0 && mediaX1W <= 0.3) avalX1W = "{FF0000}Fracassado";
	if(mediaX1W > 0.3 && mediaX1W <= 0.5) avalX1W = "{FF3C00}Péssimo";
	if(mediaX1W > 0.5 && mediaX1W <= 0.7) avalX1W = "{FF8800}Muito ruim";
	if(mediaX1W > 0.7 && mediaX1W <= 0.9) avalX1W = "{FFBF00}Ruim";
	if(mediaX1W > 0.9 && mediaX1W < 1.0) avalX1W = "{FFD900}Fraco";
	if(mediaX1W == 1.0) avalX1W = "{EAFF00}Médio";
	if(mediaX1W > 1.0 && mediaX1W <= 2) avalX1W = "{BBFF00}Quase bom";
	if(mediaX1W > 2 && mediaX1W <= 4) avalX1W = "{8CFF00}Bom";
	if(mediaX1W > 4 && mediaX1W <= 6) avalX1W = "{37FF00}Muito bom";
	if(mediaX1W > 6 && mediaX1W <= 8) avalX1W = "{00FF00}Excelente";
	if(mediaX1W > 8 && mediaX1W <= 10) avalX1W = "{00FF00}Viciado";
	if(mediaX1W > 10) avalX1W = "{00FF00}Chuck Norris";
//////////// MEDIA X1W TESTE



	new X1PG = CallRemoteFunction("GetPlayerX1PGanho", "i", clickedplayerid);
	new X1PP = CallRemoteFunction("GetPlayerX1PPerdido", "i", clickedplayerid);
//////////// MEDIA X1P TESTE
	new Float:mediaX1P = Float:X1PG/Float:X1PP;
	new avalX1P[22];
	if(mediaX1P == 0) avalX1P = "{EAFF00}Sossegado";
	if(mediaX1P > 0 && mediaX1P <= 0.3) avalX1P = "{FF0000}Fracassado";
	if(mediaX1P > 0.3 && mediaX1P <= 0.5) avalX1P = "{FF3C00}Péssimo";
	if(mediaX1P > 0.5 && mediaX1P <= 0.7) avalX1P = "{FF8800}Muito ruim";
	if(mediaX1P > 0.7 && mediaX1P <= 0.9) avalX1P = "{FFBF00}Ruim";
	if(mediaX1P > 0.9 && mediaX1P < 1.0) avalX1P = "{FFD900}Fraco";
	if(mediaX1P == 1.0) avalX1P = "{EAFF00}Médio";
	if(mediaX1P > 1.0 && mediaX1P <= 2) avalX1P = "{BBFF00}Quase bom";
	if(mediaX1P > 2 && mediaX1P <= 4) avalX1P = "{8CFF00}Bom";
	if(mediaX1P > 4 && mediaX1P <= 6) avalX1P = "{37FF00}Muito bom";
	if(mediaX1P > 6 && mediaX1P <= 8) avalX1P = "{00FF00}Excelente";
	if(mediaX1P > 8 && mediaX1P <= 10) avalX1P = "{00FF00}Viciado";
	if(mediaX1P > 10) avalX1P = "{00FF00}Chuck Norris";
//////////// MEDIA X1P TESTE

	new X1SG = CallRemoteFunction("GetPlayerX1SGanho", "i", clickedplayerid);
	new X1SP = CallRemoteFunction("GetPlayerX1SPerdido", "i", clickedplayerid);
//////////// MEDIA X1S TESTE
	new Float:mediaX1S = Float:X1SG/Float:X1SP;
	new avalX1S[22];
	if(mediaX1S == 0) avalX1S = "{EAFF00}Sossegado";
	if(mediaX1S > 0 && mediaX1S <= 0.3) avalX1S = "{FF0000}Fracassado";
	if(mediaX1S > 0.3 && mediaX1S <= 0.5) avalX1S = "{FF3C00}Péssimo";
	if(mediaX1S > 0.5 && mediaX1S <= 0.7) avalX1S = "{FF8800}Muito ruim";
	if(mediaX1S > 0.7 && mediaX1S <= 0.9) avalX1S = "{FFBF00}Ruim";
	if(mediaX1S > 0.9 && mediaX1S < 1.0) avalX1S = "{FFD900}Fraco";
	if(mediaX1S == 1.0) avalX1S = "{EAFF00}Médio";
	if(mediaX1S > 1.0 && mediaX1S <= 2) avalX1S = "{BBFF00}Quase bom";
	if(mediaX1S > 2 && mediaX1S <= 4) avalX1S = "{8CFF00}Bom";
	if(mediaX1S > 4 && mediaX1S <= 6) avalX1S = "{37FF00}Muito bom";
	if(mediaX1S > 6 && mediaX1S <= 8) avalX1S = "{00FF00}Excelente";
	if(mediaX1S > 8 && mediaX1S <= 10) avalX1S = "{00FF00}Viciado";
	if(mediaX1S > 10) avalX1S = "{00FF00}Chuck Norris";
//////////// MEDIA X1S TESTE

	new X1LG = CallRemoteFunction("GetPlayerX1LGanho", "i", clickedplayerid);
	new X1LP = CallRemoteFunction("GetPlayerX1LPerdido", "i", clickedplayerid);
//////////// MEDIA X1L TESTE
	new Float:mediaX1L = Float:X1LG/Float:X1LP;
	new avalX1L[22];
	if(mediaX1L == 0) avalX1L = "{EAFF00}Sossegado";
	if(mediaX1L > 0 && mediaX1L <= 0.3) avalX1L = "{FF0000}Fracassado";
	if(mediaX1L > 0.3 && mediaX1L <= 0.5) avalX1L = "{FF3C00}Péssimo";
	if(mediaX1L > 0.5 && mediaX1L <= 0.7) avalX1L = "{FF8800}Muito ruim";
	if(mediaX1L > 0.7 && mediaX1L <= 0.9) avalX1L = "{FFBF00}Ruim";
	if(mediaX1L > 0.9 && mediaX1L < 1.0) avalX1L = "{FFD900}Fraco";
	if(mediaX1L == 1.0) avalX1L = "{EAFF00}Médio";
	if(mediaX1L > 1.0 && mediaX1L <= 2) avalX1L = "{BBFF00}Quase bom";
	if(mediaX1L > 2 && mediaX1L <= 4) avalX1L = "{8CFF00}Bom";
	if(mediaX1L > 4 && mediaX1L <= 6) avalX1L = "{37FF00}Muito bom";
	if(mediaX1L > 6 && mediaX1L <= 8) avalX1L = "{00FF00}Excelente";
	if(mediaX1L > 8 && mediaX1L <= 10) avalX1L = "{00FF00}Viciado";
	if(mediaX1L > 10) avalX1L = "{00FF00}Chuck Norris";
//////////// MEDIA X1L TESTE


	new SP = CallRemoteFunction("GetPlayerSpreeStatus", "i", clickedplayerid);
	new FPS = GetPVarInt(clickedplayerid,"PVarFPS");
	new PING = GetPlayerPing(clickedplayerid);
	new avalPING[22];
	if(PING < 150) avalPING = "{00FF00}Excelente";
	if(PING >= 150) avalPING = "{00FF00}Muito boa";
	if(PING >= 200) avalPING = "{00FF00}Boa";
	if(PING >= 220) avalPING = "{EAFF00}Normal";
	if(PING >= 300) avalPING = "{FF0000}Ruim";
	if(PING >= 350) avalPING = "{FF0000}Péssima";
	new avalFPS[22];
	if(FPS == 0) avalFPS = "{EAFF00}Pc Da XUXA";
	if(FPS > 0) avalFPS = "{FF0000}Péssimo";
	if(FPS >= 15) avalFPS = "{FF0000}Ruim";
	if(FPS >= 24) avalFPS = "{EAFF00}Normal";
	if(FPS >= 35) avalFPS = "{00FF00}Bom";
	if(FPS >= 40) avalFPS = "{00FF00}Muito bom";
	if(FPS >= 50) avalFPS = "{00FFFB}PC Da Nasa";

	new HSL = CallRemoteFunction("GetPlayerHeadShotLevados", "i", clickedplayerid);
	new HSA = CallRemoteFunction("GetPlayerHeadShot", "i", clickedplayerid);
//////////// MEDIA HS A/L TESTE
	new Float:mediaHS = Float:HSA/Float:HSL;
	new avalHS[22];
	if(mediaHS == 0) avalHS = "{EAFF00}Sossegado";
	if(mediaHS > 0 && mediaHS <= 0.3) avalHS = "{FF0000}Fracassado";
	if(mediaHS > 0.3 && mediaHS <= 0.5) avalHS = "{FF3C00}Péssimo";
	if(mediaHS > 0.5 && mediaHS <= 0.7) avalHS = "{FF8800}Muito ruim";
	if(mediaHS > 0.7 && mediaHS <= 0.9) avalHS = "{FFBF00}Ruim";
	if(mediaHS > 0.9 && mediaHS < 1.0) avalHS = "{FFD900}Fraco";
	if(mediaHS == 1.0) avalHS = "{EAFF00}Médio";
	if(mediaHS > 1.0 && mediaHS <= 2) avalHS = "{BBFF00}Quase bom";
	if(mediaHS > 2 && mediaHS <= 4) avalHS = "{8CFF00}Bom";
	if(mediaHS > 4 && mediaHS <= 6) avalHS = "{37FF00}Muito bom";
	if(mediaHS > 6 && mediaHS <= 8) avalHS = "{00FF00}Excelente";
	if(mediaHS > 8 && mediaHS <= 10) avalHS = "{00FF00}Viciado";
	if(mediaHS > 10) avalHS = "{00FF00}Chuck Norris";
/////////// MEDIA HS A/L TESTE



	new CG1 = CallRemoteFunction("GetPlayerCORRIDAganha1", "i", clickedplayerid);
	new CG2 = CallRemoteFunction("GetPlayerCORRIDAganha2", "i", clickedplayerid);
	new CG3 = CallRemoteFunction("GetPlayerCORRIDAganha3", "i", clickedplayerid);

	new EG = CallRemoteFunction("GetPlayerEVENTOPremiar", "i", clickedplayerid);
	new EG2 = CallRemoteFunction("GetPlayerEVENTOPremiar2", "i", clickedplayerid);
	new EG3 = CallRemoteFunction("GetPlayerEVENTOPremiar3", "i", clickedplayerid);

	new PISTOLAGG = CallRemoteFunction("GetPlayerPISTOLAGanho", "i", clickedplayerid);
	new PISTOLAPP = CallRemoteFunction("GetPlayerPISTOLAPerdido", "i", clickedplayerid);
//////////// MEDIA PISTOLA TESTE
	new Float:mediaPISTOLA = Float:PISTOLAGG/Float:PISTOLAPP;
	new avalPISTOLA[22];
	if(mediaPISTOLA == 0) avalPISTOLA = "{EAFF00}Sossegado";
	if(mediaPISTOLA > 0 && mediaPISTOLA <= 0.3) avalPISTOLA = "{FF0000}Fracassado";
	if(mediaPISTOLA > 0.3 && mediaPISTOLA <= 0.5) avalPISTOLA = "{FF3C00}Péssimo";
	if(mediaPISTOLA > 0.5 && mediaPISTOLA <= 0.7) avalPISTOLA = "{FF8800}Muito ruim";
	if(mediaPISTOLA > 0.7 && mediaPISTOLA <= 0.9) avalPISTOLA = "{FFBF00}Ruim";
	if(mediaPISTOLA > 0.9 && mediaPISTOLA < 1.0) avalPISTOLA = "{FFD900}Fraco";
	if(mediaPISTOLA == 1.0) avalPISTOLA = "{EAFF00}Médio";
	if(mediaPISTOLA > 1.0 && mediaPISTOLA <= 2) avalPISTOLA = "{BBFF00}Quase bom";
	if(mediaPISTOLA > 2 && mediaPISTOLA <= 4) avalPISTOLA = "{8CFF00}Bom";
	if(mediaPISTOLA > 4 && mediaPISTOLA <= 6) avalPISTOLA = "{37FF00}Muito bom";
	if(mediaPISTOLA > 6 && mediaPISTOLA <= 8) avalPISTOLA = "{00FF00}Excelente";
	if(mediaPISTOLA > 8 && mediaPISTOLA <= 10) avalPISTOLA = "{00FF00}Viciado";
	if(mediaPISTOLA > 10) avalPISTOLA = "{00FF00}Chuck Norris";
//////////// MEDIA PISTOLA TESTE


	new WALKGG = CallRemoteFunction("GetPlayerAWALKGanho", "i", clickedplayerid);
	new WALKPP = CallRemoteFunction("GetPlayerAWALKPerdido", "i", clickedplayerid);
//////////// MEDIA ARENASWALK TESTE
	new Float:mediaARENAWALK = Float:WALKGG/Float:WALKPP;
	new avalARENAWALK[22];
	if(mediaARENAWALK == 0) avalARENAWALK = "{EAFF00}Sossegado";
	if(mediaARENAWALK > 0 && mediaARENAWALK <= 0.3) avalARENAWALK = "{FF0000}Fracassado";
	if(mediaARENAWALK > 0.3 && mediaARENAWALK <= 0.5) avalARENAWALK = "{FF3C00}Péssimo";
	if(mediaARENAWALK > 0.5 && mediaARENAWALK <= 0.7) avalARENAWALK = "{FF8800}Muito ruim";
	if(mediaARENAWALK > 0.7 && mediaARENAWALK <= 0.9) avalARENAWALK = "{FFBF00}Ruim";
	if(mediaARENAWALK > 0.9 && mediaARENAWALK < 1.0) avalARENAWALK = "{FFD900}Fraco";
	if(mediaARENAWALK == 1.0) avalARENAWALK = "{EAFF00}Médio";
	if(mediaARENAWALK > 1.0 && mediaARENAWALK <= 2) avalARENAWALK = "{BBFF00}Quase bom";
	if(mediaARENAWALK > 2 && mediaARENAWALK <= 4) avalARENAWALK = "{8CFF00}Bom";
	if(mediaARENAWALK > 4 && mediaARENAWALK <= 6) avalARENAWALK = "{37FF00}Muito bom";
	if(mediaARENAWALK > 6 && mediaARENAWALK <= 8) avalARENAWALK = "{00FF00}Excelente";
	if(mediaARENAWALK > 8 && mediaARENAWALK <= 10) avalARENAWALK = "{00FF00}Viciado";
	if(mediaARENAWALK > 10) avalARENAWALK = "{00FF00}Chuck Norris";
//////////// MEDIA ARENASWALK TESTE
	
	new RUNGG = CallRemoteFunction("GetPlayerARUNGanho", "i", clickedplayerid);
	new RUNPP = CallRemoteFunction("GetPlayerARUNPerdido", "i", clickedplayerid);
//////////// MEDIA ARENASRUN TESTE
	new Float:mediaARENARUN = Float:RUNGG/Float:RUNPP;
	new avalARENARUN[22];
	if(mediaARENARUN == 0) avalARENARUN = "{EAFF00}Sossegado";
	if(mediaARENARUN > 0 && mediaARENARUN <= 0.3) avalARENARUN = "{FF0000}Fracassado";
	if(mediaARENARUN > 0.3 && mediaARENARUN <= 0.5) avalARENARUN = "{FF3C00}Péssimo";
	if(mediaARENARUN > 0.5 && mediaARENARUN <= 0.7) avalARENARUN = "{FF8800}Muito ruim";
	if(mediaARENARUN > 0.7 && mediaARENARUN <= 0.9) avalARENARUN = "{FFBF00}Ruim";
	if(mediaARENARUN > 0.9 && mediaARENARUN < 1.0) avalARENARUN = "{FFD900}Fraco";
	if(mediaARENARUN == 1.0) avalARENARUN = "{EAFF00}Médio";
	if(mediaARENARUN > 1.0 && mediaARENARUN <= 2) avalARENARUN = "{BBFF00}Quase bom";
	if(mediaARENARUN > 2 && mediaARENARUN <= 4) avalARENARUN = "{8CFF00}Bom";
	if(mediaARENARUN > 4 && mediaARENARUN <= 6) avalARENARUN = "{37FF00}Muito bom";
	if(mediaARENARUN > 6 && mediaARENARUN <= 8) avalARENARUN = "{00FF00}Excelente";
	if(mediaARENARUN > 8 && mediaARENARUN <= 10) avalARENARUN = "{00FF00}Viciado";
	if(mediaARENARUN > 10) avalARENARUN = "{00FF00}Chuck Norris";
//////////// MEDIA ARENASRUN TESTE

	new SNPGG = CallRemoteFunction("GetPlayerASNPGanho", "i", clickedplayerid);
	new SNPPP = CallRemoteFunction("GetPlayerASNPPerdido", "i", clickedplayerid);
//////////// MEDIA ARENASRUN TESTE
	new Float:mediaARENASNP = Float:SNPGG/Float:SNPPP;
	new avalARENASNP[22];
	if(mediaARENASNP == 0) avalARENASNP = "{EAFF00}Sossegado";
	if(mediaARENASNP > 0 && mediaARENASNP <= 0.3) avalARENASNP = "{FF0000}Fracassado";
	if(mediaARENASNP > 0.3 && mediaARENASNP <= 0.5) avalARENASNP = "{FF3C00}Péssimo";
	if(mediaARENASNP > 0.5 && mediaARENASNP <= 0.7) avalARENASNP = "{FF8800}Muito ruim";
	if(mediaARENASNP > 0.7 && mediaARENASNP <= 0.9) avalARENASNP = "{FFBF00}Ruim";
	if(mediaARENASNP > 0.9 && mediaARENASNP < 1.0) avalARENASNP = "{FFD900}Fraco";
	if(mediaARENASNP == 1.0) avalARENASNP = "{EAFF00}Médio";
	if(mediaARENASNP > 1.0 && mediaARENASNP <= 2) avalARENASNP = "{BBFF00}Quase bom";
	if(mediaARENASNP > 2 && mediaARENASNP <= 4) avalARENASNP = "{8CFF00}Bom";
	if(mediaARENASNP > 4 && mediaARENASNP <= 6) avalARENASNP = "{37FF00}Muito bom";
	if(mediaARENASNP > 6 && mediaARENASNP <= 8) avalARENASNP = "{00FF00}Excelente";
	if(mediaARENASNP > 8 && mediaARENASNP <= 10) avalARENASNP = "{00FF00}Viciado";
	if(mediaARENASNP > 10) avalARENASNP = "{00FF00}Chuck Norris";
//////////// MEDIA ARENASRUN TESTE

	format(string, sizeof(string), "{00FF00}%s: {FFFFFF}[ID: %i]:\n", PlayerName2(clickedplayerid),clickedplayerid);//00FFEE azul claro
	strcat(string2, string);
	format(string, sizeof(string), "%s\n",posto);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}Score: {1E90FF}%d {FFFFFF}Spree: {1E90FF}%i {FFFFFF}Dinheiro: {00FF00}$%d\n", GetPlayerScore(clickedplayerid),SP,GetPlayerCash(clickedplayerid));
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}Matou: {00FF00}%d {FFFFFF}Morreu: {FF0000}%d {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}HS Infos:\n", PlayerInfo[clickedplayerid][Kills],PlayerInfo[clickedplayerid][Deaths],Float:PlayerInfo[clickedplayerid][Kills]/Float:pDeaths,aval);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Morreu: {FF0000}%d\n", PlayerInfo[clickedplayerid][Deaths]);
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Media: {FFFF00}%0.2f\n", Float:PlayerInfo[clickedplayerid][Kills]/Float:pDeaths);
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Spree: {1E90FF}%i\n", SP);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}HS-Acertados: {00FF00}%i {FFFFFF}Levados: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}Corrida-Ganhadas Infos:\n", HSA,HSL,Float:HSA/Float:HSL,avalHS);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}HS-Levados: {FF0000}%i\n", HSL);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}1Lugar: {00FF00}%i {FFFFFF}2Lugar: {FF3C00}%i {FFFFFF}3Lugar: {FF0000}%i\n\n{FFFF00}Eventos-Ganhados Infos:\n", CG1,CG2,CG3);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Corrida-Ganhadas 2Lugar: {FF3C00}%i\n", CG2);
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Corrida-Ganhadas 3Lugar: {FF0000}%i\n", CG3);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}1Lugar: {00FF00}%i {FFFFFF}2Lugar: {FF3C00}%i {FFFFFF}3Lugar: {FF0000}%i%i\n\n{FFFF00}Duelos Infos:\n", EG,EG2,EG3);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}X1-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", X1G,X1P,Float:X1G/Float:X1P,avalX1);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}X1W-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", X1WG,X1WP,Float:X1WG/Float:X1WP,avalX1W);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}X1P-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", X1PG,X1PP,Float:X1PG/Float:X1PP,avalX1P);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}X1S-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", X1SG,X1SP,Float:X1SG/Float:X1SP,avalX1S);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}X1L-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}Arenas Infos:\n", X1LG,X1LP,Float:X1LG/Float:X1LP,avalX1L);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}PISTOLA: Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", PISTOLAGG,PISTOLAPP,Float:PISTOLAGG/Float:PISTOLAPP,avalPISTOLA);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}WALK: Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", WALKGG,WALKPP,Float:WALKGG/Float:WALKPP,avalARENAWALK);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}RUN: Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", RUNGG,RUNPP,Float:RUNGG/Float:RUNPP,avalARENARUN);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}SNP: Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}Desempenho/Conexão:\n", SNPGG,SNPPP,Float:SNPGG/Float:SNPPP,avalARENASNP);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Dinheiro: {00FF00}$%d\n", GetPlayerCash(clickedplayerid));     
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Habilidade: %s\n", aval);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}Computador: %s{FFFFFF} - (%i FPS)\n", avalFPS,FPS);
	strcat(string2, string);
	format(string, sizeof(string), "Conexão: %s {FFFFFF}- (%i PING)\n", avalPING,PING);
	strcat(string2, string);
	ShowPlayerDialog(playerid,911,DIALOG_STYLE_MSGBOX,"   {FF0000}Viciados em GTA {FFFFFF}- Status Do Jogador", string2, "OK", "Voltar");
	}
*/
if(source == CLICK_SOURCE_SCOREBOARD)
{
	new admstring[128],P1NAME[MAX_PLAYER_NAME],P2NAME[MAX_PLAYER_NAME];
 	GetPlayerName(playerid, P1NAME, sizeof(P1NAME));GetPlayerName(clickedplayerid, P2NAME, sizeof(P2NAME));
    format(admstring, sizeof(admstring), "CLICK >> %s Clicou em %s na scoreboard.",P1NAME,P2NAME);
    for (new i = 0; i < MAX_PLAYERS; i++){
	if(IsPlayerConnected(i) && PlayerInfo[i][Level] >= 5) {
	SendClientMessage(i,0xFF9900AA,admstring);}}

	new string[1800],string2[1800],posto[128],pDeaths;
	switch(PlayerInfo[clickedplayerid][Level]){
	case 0: format(posto, sizeof(posto), "{A52A2A}Player MIT0!");
	case 1: format(posto, sizeof(posto), "{8A2BE2}Administrador(a) Novato!!!");
	case 2: format(posto, sizeof(posto), "{1E90FF}Administrador(a) Aprendiz!!!");
	case 3: format(posto, sizeof(posto), "{1E90FF}Administrador(a) Responsavel!!!!");
	case 4: format(posto, sizeof(posto), "{1E90FF}Administrador(a) Experiente!!!!!");
	case 5: format(posto, sizeof(posto), "{1E90FF}Gerente™ Administrativo!!!!!!");//GERENTE™ ADM1NISTRAT1V0!");
	case 6: format(posto, sizeof(posto), "{C0FF3E}SUB-DONO™!!!!!!!");
	case 7: format(posto, sizeof(posto), "{C0FF3E}DONO™!!!!!!!!");}
	if(TempADM[clickedplayerid] == true)
	format(posto, sizeof(posto), "{FF1493}Administrador(a) Temporário!");

	if(AdmHidden[clickedplayerid] == true && PlayerInfo[playerid][Level] < 1) format(posto, sizeof(posto), "{A52A2A}Player MIT0!");

	if(PlayerInfo[clickedplayerid][Deaths] == 0) pDeaths = 1; else pDeaths = PlayerInfo[clickedplayerid][Deaths];

	new Float:media = Float:PlayerInfo[clickedplayerid][Kills]/Float:pDeaths;
	new aval[22];
	if(media == 0) aval = "{EAFF00}Sossegado";
	if(media > 0 && media <= 0.3) aval = "{FF0000}Fracassado";
	if(media > 0.3 && media <= 0.5) aval = "{FF3C00}Péssimo";
	if(media > 0.5 && media <= 0.7) aval = "{FF8800}Muito ruim";
	if(media > 0.7 && media <= 0.9) aval = "{FFBF00}Ruim";
	if(media > 0.9 && media < 1.0) aval = "{FFD900}Fraco";
	if(media == 1.0) aval = "{EAFF00}Médio";
	if(media > 1.0 && media <= 2) aval = "{BBFF00}Quase bom";
	if(media > 2 && media <= 4) aval = "{8CFF00}Bom";
	if(media > 4 && media <= 6) aval = "{37FF00}Muito bom";
	if(media > 6 && media <= 8) aval = "{00FF00}Excelente";
	if(media > 8 && media <= 10) aval = "{00FF00}Viciado";
	if(media > 10) aval = "{00FF00}Chuck Norris";

//	new X1G = CallRemoteFunction("GetPlayerX1Ganho", "i", clickedplayerid);
//	new X1P = CallRemoteFunction("GetPlayerX1Perdido", "i", clickedplayerid);
//////////// MEDIA X1 TESTE
	new Float:mediaX1 = Float:PlayerInfo[clickedplayerid][X1Ganhos]/Float:PlayerInfo[clickedplayerid][X1Perdidos];
	new avalX1[22];
	if(mediaX1 == 0) avalX1 = "{EAFF00}Sossegado";
	if(mediaX1 > 0 && mediaX1 <= 0.3) avalX1 = "{FF0000}Fracassado";
	if(mediaX1 > 0.3 && mediaX1 <= 0.5) avalX1 = "{FF3C00}Péssimo";
	if(mediaX1 > 0.5 && mediaX1 <= 0.7) avalX1 = "{FF8800}Muito ruim";
	if(mediaX1 > 0.7 && mediaX1 <= 0.9) avalX1 = "{FFBF00}Ruim";
	if(mediaX1 > 0.9 && mediaX1 < 1.0) avalX1 = "{FFD900}Fraco";
	if(mediaX1 == 1.0) avalX1 = "{EAFF00}Médio";
	if(mediaX1 > 1.0 && mediaX1 <= 2) avalX1 = "{BBFF00}Quase bom";
	if(mediaX1 > 2 && mediaX1 <= 4) avalX1 = "{8CFF00}Bom";
	if(mediaX1 > 4 && mediaX1 <= 6) avalX1 = "{37FF00}Muito bom";
	if(mediaX1 > 6 && mediaX1 <= 8) avalX1 = "{00FF00}Excelente";
	if(mediaX1 > 8 && mediaX1 <= 10) avalX1 = "{00FF00}Viciado";
	if(mediaX1 > 10) avalX1 = "{00FF00}Chuck Norris";
//////////// MEDIA X1 TESTE


//	new X1WG = CallRemoteFunction("GetPlayerX1WGanho", "i", clickedplayerid);
//	new X1WP = CallRemoteFunction("GetPlayerX1WPerdido", "i", clickedplayerid);
//////////// MEDIA X1W TESTE
	new Float:mediaX1W = Float:PlayerInfo[clickedplayerid][X1WGanhos]/Float:PlayerInfo[clickedplayerid][X1WPerdidos];
	new avalX1W[22];
	if(mediaX1W == 0) avalX1W = "{EAFF00}Sossegado";
	if(mediaX1W > 0 && mediaX1W <= 0.3) avalX1W = "{FF0000}Fracassado";
	if(mediaX1W > 0.3 && mediaX1W <= 0.5) avalX1W = "{FF3C00}Péssimo";
	if(mediaX1W > 0.5 && mediaX1W <= 0.7) avalX1W = "{FF8800}Muito ruim";
	if(mediaX1W > 0.7 && mediaX1W <= 0.9) avalX1W = "{FFBF00}Ruim";
	if(mediaX1W > 0.9 && mediaX1W < 1.0) avalX1W = "{FFD900}Fraco";
	if(mediaX1W == 1.0) avalX1W = "{EAFF00}Médio";
	if(mediaX1W > 1.0 && mediaX1W <= 2) avalX1W = "{BBFF00}Quase bom";
	if(mediaX1W > 2 && mediaX1W <= 4) avalX1W = "{8CFF00}Bom";
	if(mediaX1W > 4 && mediaX1W <= 6) avalX1W = "{37FF00}Muito bom";
	if(mediaX1W > 6 && mediaX1W <= 8) avalX1W = "{00FF00}Excelente";
	if(mediaX1W > 8 && mediaX1W <= 10) avalX1W = "{00FF00}Viciado";
	if(mediaX1W > 10) avalX1W = "{00FF00}Chuck Norris";
//////////// MEDIA X1W TESTE



//	new X1PG = CallRemoteFunction("GetPlayerX1PGanho", "i", clickedplayerid);
//	new X1PP = CallRemoteFunction("GetPlayerX1PPerdido", "i", clickedplayerid);
//////////// MEDIA X1P TESTE
	new Float:mediaX1P = Float:PlayerInfo[clickedplayerid][X1PGanhos]/Float:PlayerInfo[clickedplayerid][X1PPerdidos];
	new avalX1P[22];
	if(mediaX1P == 0) avalX1P = "{EAFF00}Sossegado";
	if(mediaX1P > 0 && mediaX1P <= 0.3) avalX1P = "{FF0000}Fracassado";
	if(mediaX1P > 0.3 && mediaX1P <= 0.5) avalX1P = "{FF3C00}Péssimo";
	if(mediaX1P > 0.5 && mediaX1P <= 0.7) avalX1P = "{FF8800}Muito ruim";
	if(mediaX1P > 0.7 && mediaX1P <= 0.9) avalX1P = "{FFBF00}Ruim";
	if(mediaX1P > 0.9 && mediaX1P < 1.0) avalX1P = "{FFD900}Fraco";
	if(mediaX1P == 1.0) avalX1P = "{EAFF00}Médio";
	if(mediaX1P > 1.0 && mediaX1P <= 2) avalX1P = "{BBFF00}Quase bom";
	if(mediaX1P > 2 && mediaX1P <= 4) avalX1P = "{8CFF00}Bom";
	if(mediaX1P > 4 && mediaX1P <= 6) avalX1P = "{37FF00}Muito bom";
	if(mediaX1P > 6 && mediaX1P <= 8) avalX1P = "{00FF00}Excelente";
	if(mediaX1P > 8 && mediaX1P <= 10) avalX1P = "{00FF00}Viciado";
	if(mediaX1P > 10) avalX1P = "{00FF00}Chuck Norris";
//////////// MEDIA X1P TESTE

//	new X1SG = CallRemoteFunction("GetPlayerX1SGanho", "i", clickedplayerid);
//	new X1SP = CallRemoteFunction("GetPlayerX1SPerdido", "i", clickedplayerid);
//////////// MEDIA X1S TESTE
	new Float:mediaX1S = Float:PlayerInfo[clickedplayerid][X1SGanhos]/Float:PlayerInfo[clickedplayerid][X1SPerdidos];
	new avalX1S[22];
	if(mediaX1S == 0) avalX1S = "{EAFF00}Sossegado";
	if(mediaX1S > 0 && mediaX1S <= 0.3) avalX1S = "{FF0000}Fracassado";
	if(mediaX1S > 0.3 && mediaX1S <= 0.5) avalX1S = "{FF3C00}Péssimo";
	if(mediaX1S > 0.5 && mediaX1S <= 0.7) avalX1S = "{FF8800}Muito ruim";
	if(mediaX1S > 0.7 && mediaX1S <= 0.9) avalX1S = "{FFBF00}Ruim";
	if(mediaX1S > 0.9 && mediaX1S < 1.0) avalX1S = "{FFD900}Fraco";
	if(mediaX1S == 1.0) avalX1S = "{EAFF00}Médio";
	if(mediaX1S > 1.0 && mediaX1S <= 2) avalX1S = "{BBFF00}Quase bom";
	if(mediaX1S > 2 && mediaX1S <= 4) avalX1S = "{8CFF00}Bom";
	if(mediaX1S > 4 && mediaX1S <= 6) avalX1S = "{37FF00}Muito bom";
	if(mediaX1S > 6 && mediaX1S <= 8) avalX1S = "{00FF00}Excelente";
	if(mediaX1S > 8 && mediaX1S <= 10) avalX1S = "{00FF00}Viciado";
	if(mediaX1S > 10) avalX1S = "{00FF00}Chuck Norris";
//////////// MEDIA X1S TESTE

//	new X1LG = CallRemoteFunction("GetPlayerX1LGanho", "i", clickedplayerid);
//	new X1LP = CallRemoteFunction("GetPlayerX1LPerdido", "i", clickedplayerid);
//////////// MEDIA X1L TESTE
	new Float:mediaX1L = Float:PlayerInfo[clickedplayerid][X1LGanhos]/Float:PlayerInfo[clickedplayerid][X1LPerdidos];
	new avalX1L[22];
	if(mediaX1L == 0) avalX1L = "{EAFF00}Sossegado";
	if(mediaX1L > 0 && mediaX1L <= 0.3) avalX1L = "{FF0000}Fracassado";
	if(mediaX1L > 0.3 && mediaX1L <= 0.5) avalX1L = "{FF3C00}Péssimo";
	if(mediaX1L > 0.5 && mediaX1L <= 0.7) avalX1L = "{FF8800}Muito ruim";
	if(mediaX1L > 0.7 && mediaX1L <= 0.9) avalX1L = "{FFBF00}Ruim";
	if(mediaX1L > 0.9 && mediaX1L < 1.0) avalX1L = "{FFD900}Fraco";
	if(mediaX1L == 1.0) avalX1L = "{EAFF00}Médio";
	if(mediaX1L > 1.0 && mediaX1L <= 2) avalX1L = "{BBFF00}Quase bom";
	if(mediaX1L > 2 && mediaX1L <= 4) avalX1L = "{8CFF00}Bom";
	if(mediaX1L > 4 && mediaX1L <= 6) avalX1L = "{37FF00}Muito bom";
	if(mediaX1L > 6 && mediaX1L <= 8) avalX1L = "{00FF00}Excelente";
	if(mediaX1L > 8 && mediaX1L <= 10) avalX1L = "{00FF00}Viciado";
	if(mediaX1L > 10) avalX1L = "{00FF00}Chuck Norris";
//////////// MEDIA X1L TESTE


	new SP = CallRemoteFunction("GetPlayerSpreeStatus", "i", clickedplayerid);
	new FPS = GetPVarInt(clickedplayerid,"PVarFPS");
	new PING = GetPlayerPing(clickedplayerid);
	new avalPING[22];
	if(PING < 150) avalPING = "{00FF00}Excelente";
	if(PING >= 150) avalPING = "{00FF00}Muito boa";
	if(PING >= 200) avalPING = "{00FF00}Boa";
	if(PING >= 220) avalPING = "{EAFF00}Normal";
	if(PING >= 300) avalPING = "{FF0000}Ruim";
	if(PING >= 350) avalPING = "{FF0000}Péssima";
	new avalFPS[22];
	if(FPS == 0) avalFPS = "{EAFF00}Pc Da XUXA";
	if(FPS > 0) avalFPS = "{FF0000}Péssimo";
	if(FPS >= 15) avalFPS = "{FF0000}Ruim";
	if(FPS >= 24) avalFPS = "{EAFF00}Normal";
	if(FPS >= 35) avalFPS = "{00FF00}Bom";
	if(FPS >= 40) avalFPS = "{00FF00}Muito bom";
	if(FPS >= 50) avalFPS = "{00FFFB}PC Da Nasa";

//	new HSL = CallRemoteFunction("GetPlayerHeadShotLevados", "i", clickedplayerid);
//	new HSA = CallRemoteFunction("GetPlayerHeadShot", "i", clickedplayerid);
//////////// MEDIA HS A/L TESTE
	new Float:mediaHS = Float:PlayerInfo[clickedplayerid][Head]/Float:PlayerInfo[clickedplayerid][HeadLevado];
	new avalHS[22];
	if(mediaHS == 0) avalHS = "{EAFF00}Sossegado";
	if(mediaHS > 0 && mediaHS <= 0.3) avalHS = "{FF0000}Fracassado";
	if(mediaHS > 0.3 && mediaHS <= 0.5) avalHS = "{FF3C00}Péssimo";
	if(mediaHS > 0.5 && mediaHS <= 0.7) avalHS = "{FF8800}Muito ruim";
	if(mediaHS > 0.7 && mediaHS <= 0.9) avalHS = "{FFBF00}Ruim";
	if(mediaHS > 0.9 && mediaHS < 1.0) avalHS = "{FFD900}Fraco";
	if(mediaHS == 1.0) avalHS = "{EAFF00}Médio";
	if(mediaHS > 1.0 && mediaHS <= 2) avalHS = "{BBFF00}Quase bom";
	if(mediaHS > 2 && mediaHS <= 4) avalHS = "{8CFF00}Bom";
	if(mediaHS > 4 && mediaHS <= 6) avalHS = "{37FF00}Muito bom";
	if(mediaHS > 6 && mediaHS <= 8) avalHS = "{00FF00}Excelente";
	if(mediaHS > 8 && mediaHS <= 10) avalHS = "{00FF00}Viciado";
	if(mediaHS > 10) avalHS = "{00FF00}Chuck Norris";
/////////// MEDIA HS A/L TESTE

//	new CG1 = CallRemoteFunction("GetPlayerCORRIDAganha1", "i", clickedplayerid);
//	new CG2 = CallRemoteFunction("GetPlayerCORRIDAganha2", "i", clickedplayerid);
//	new CG3 = CallRemoteFunction("GetPlayerCORRIDAganha3", "i", clickedplayerid);

//	new EG = CallRemoteFunction("GetPlayerEVENTOPremiar", "i", clickedplayerid);
//	new EG2 = CallRemoteFunction("GetPlayerEVENTOPremiar2", "i", clickedplayerid);
//	new EG3 = CallRemoteFunction("GetPlayerEVENTOPremiar3", "i", clickedplayerid);

//	new PISTOLAGG = CallRemoteFunction("GetPlayerPISTOLAGanho", "i", clickedplayerid);
//	new PISTOLAPP = CallRemoteFunction("GetPlayerPISTOLAPerdido", "i", clickedplayerid);
//////////// MEDIA PISTOLA TESTE
	new Float:mediaPISTOLA = Float:PlayerInfo[clickedplayerid][PistolaGanhos]/Float:PlayerInfo[clickedplayerid][PistolaPerdidos];
	new avalPISTOLA[22];
	if(mediaPISTOLA == 0) avalPISTOLA = "{EAFF00}Sossegado";
	if(mediaPISTOLA > 0 && mediaPISTOLA <= 0.3) avalPISTOLA = "{FF0000}Fracassado";
	if(mediaPISTOLA > 0.3 && mediaPISTOLA <= 0.5) avalPISTOLA = "{FF3C00}Péssimo";
	if(mediaPISTOLA > 0.5 && mediaPISTOLA <= 0.7) avalPISTOLA = "{FF8800}Muito ruim";
	if(mediaPISTOLA > 0.7 && mediaPISTOLA <= 0.9) avalPISTOLA = "{FFBF00}Ruim";
	if(mediaPISTOLA > 0.9 && mediaPISTOLA < 1.0) avalPISTOLA = "{FFD900}Fraco";
	if(mediaPISTOLA == 1.0) avalPISTOLA = "{EAFF00}Médio";
	if(mediaPISTOLA > 1.0 && mediaPISTOLA <= 2) avalPISTOLA = "{BBFF00}Quase bom";
	if(mediaPISTOLA > 2 && mediaPISTOLA <= 4) avalPISTOLA = "{8CFF00}Bom";
	if(mediaPISTOLA > 4 && mediaPISTOLA <= 6) avalPISTOLA = "{37FF00}Muito bom";
	if(mediaPISTOLA > 6 && mediaPISTOLA <= 8) avalPISTOLA = "{00FF00}Excelente";
	if(mediaPISTOLA > 8 && mediaPISTOLA <= 10) avalPISTOLA = "{00FF00}Viciado";
	if(mediaPISTOLA > 10) avalPISTOLA = "{00FF00}Chuck Norris";
//////////// MEDIA PISTOLA TESTE


//	new WALKGG = CallRemoteFunction("GetPlayerAWALKGanho", "i", clickedplayerid);
//	new WALKPP = CallRemoteFunction("GetPlayerAWALKPerdido", "i", clickedplayerid);
//////////// MEDIA ARENASWALK TESTE
	new Float:mediaARENAWALK = Float:PlayerInfo[clickedplayerid][WALKGanhos]/Float:PlayerInfo[clickedplayerid][WALKPerdidos];
	new avalARENAWALK[22];
	if(mediaARENAWALK == 0) avalARENAWALK = "{EAFF00}Sossegado";
	if(mediaARENAWALK > 0 && mediaARENAWALK <= 0.3) avalARENAWALK = "{FF0000}Fracassado";
	if(mediaARENAWALK > 0.3 && mediaARENAWALK <= 0.5) avalARENAWALK = "{FF3C00}Péssimo";
	if(mediaARENAWALK > 0.5 && mediaARENAWALK <= 0.7) avalARENAWALK = "{FF8800}Muito ruim";
	if(mediaARENAWALK > 0.7 && mediaARENAWALK <= 0.9) avalARENAWALK = "{FFBF00}Ruim";
	if(mediaARENAWALK > 0.9 && mediaARENAWALK < 1.0) avalARENAWALK = "{FFD900}Fraco";
	if(mediaARENAWALK == 1.0) avalARENAWALK = "{EAFF00}Médio";
	if(mediaARENAWALK > 1.0 && mediaARENAWALK <= 2) avalARENAWALK = "{BBFF00}Quase bom";
	if(mediaARENAWALK > 2 && mediaARENAWALK <= 4) avalARENAWALK = "{8CFF00}Bom";
	if(mediaARENAWALK > 4 && mediaARENAWALK <= 6) avalARENAWALK = "{37FF00}Muito bom";
	if(mediaARENAWALK > 6 && mediaARENAWALK <= 8) avalARENAWALK = "{00FF00}Excelente";
	if(mediaARENAWALK > 8 && mediaARENAWALK <= 10) avalARENAWALK = "{00FF00}Viciado";
	if(mediaARENAWALK > 10) avalARENAWALK = "{00FF00}Chuck Norris";
//////////// MEDIA ARENASWALK TESTE

//	new RUNGG = CallRemoteFunction("GetPlayerARUNGanho", "i", clickedplayerid);
//	new RUNPP = CallRemoteFunction("GetPlayerARUNPerdido", "i", clickedplayerid);
//////////// MEDIA ARENASRUN TESTE
	new Float:mediaARENARUN = Float:PlayerInfo[clickedplayerid][RUNGanhos]/Float:PlayerInfo[clickedplayerid][RUNPerdidos];
	new avalARENARUN[22];
	if(mediaARENARUN == 0) avalARENARUN = "{EAFF00}Sossegado";
	if(mediaARENARUN > 0 && mediaARENARUN <= 0.3) avalARENARUN = "{FF0000}Fracassado";
	if(mediaARENARUN > 0.3 && mediaARENARUN <= 0.5) avalARENARUN = "{FF3C00}Péssimo";
	if(mediaARENARUN > 0.5 && mediaARENARUN <= 0.7) avalARENARUN = "{FF8800}Muito ruim";
	if(mediaARENARUN > 0.7 && mediaARENARUN <= 0.9) avalARENARUN = "{FFBF00}Ruim";
	if(mediaARENARUN > 0.9 && mediaARENARUN < 1.0) avalARENARUN = "{FFD900}Fraco";
	if(mediaARENARUN == 1.0) avalARENARUN = "{EAFF00}Médio";
	if(mediaARENARUN > 1.0 && mediaARENARUN <= 2) avalARENARUN = "{BBFF00}Quase bom";
	if(mediaARENARUN > 2 && mediaARENARUN <= 4) avalARENARUN = "{8CFF00}Bom";
	if(mediaARENARUN > 4 && mediaARENARUN <= 6) avalARENARUN = "{37FF00}Muito bom";
	if(mediaARENARUN > 6 && mediaARENARUN <= 8) avalARENARUN = "{00FF00}Excelente";
	if(mediaARENARUN > 8 && mediaARENARUN <= 10) avalARENARUN = "{00FF00}Viciado";
	if(mediaARENARUN > 10) avalARENARUN = "{00FF00}Chuck Norris";
//////////// MEDIA ARENASRUN TESTE

//	new SNPGG = CallRemoteFunction("GetPlayerASNPGanho", "i", clickedplayerid);
//	new SNPPP = CallRemoteFunction("GetPlayerASNPPerdido", "i", clickedplayerid);
//////////// MEDIA ARENASRUN TESTE
	new Float:mediaARENASNP = Float:PlayerInfo[clickedplayerid][SNPGanhos]/Float:PlayerInfo[clickedplayerid][SNPPerdidos];
	new avalARENASNP[22];
	if(mediaARENASNP == 0) avalARENASNP = "{EAFF00}Sossegado";
	if(mediaARENASNP > 0 && mediaARENASNP <= 0.3) avalARENASNP = "{FF0000}Fracassado";
	if(mediaARENASNP > 0.3 && mediaARENASNP <= 0.5) avalARENASNP = "{FF3C00}Péssimo";
	if(mediaARENASNP > 0.5 && mediaARENASNP <= 0.7) avalARENASNP = "{FF8800}Muito ruim";
	if(mediaARENASNP > 0.7 && mediaARENASNP <= 0.9) avalARENASNP = "{FFBF00}Ruim";
	if(mediaARENASNP > 0.9 && mediaARENASNP < 1.0) avalARENASNP = "{FFD900}Fraco";
	if(mediaARENASNP == 1.0) avalARENASNP = "{EAFF00}Médio";
	if(mediaARENASNP > 1.0 && mediaARENASNP <= 2) avalARENASNP = "{BBFF00}Quase bom";
	if(mediaARENASNP > 2 && mediaARENASNP <= 4) avalARENASNP = "{8CFF00}Bom";
	if(mediaARENASNP > 4 && mediaARENASNP <= 6) avalARENASNP = "{37FF00}Muito bom";
	if(mediaARENASNP > 6 && mediaARENASNP <= 8) avalARENASNP = "{00FF00}Excelente";
	if(mediaARENASNP > 8 && mediaARENASNP <= 10) avalARENASNP = "{00FF00}Viciado";
	if(mediaARENASNP > 10) avalARENASNP = "{00FF00}Chuck Norris";
//////////// MEDIA ARENASRUN TESTE

	format(string, sizeof(string), "{00FF00}%s: {FFFFFF}[ID: %i]:\n", PlayerName2(clickedplayerid),clickedplayerid);//00FFEE azul claro
	strcat(string2, string);
	format(string, sizeof(string), "%s\n",posto);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}Score: {1E90FF}%d {FFFFFF}Spree: {1E90FF}%i {FFFFFF}Dinheiro: {00FF00}$%d\n", GetPlayerScore(clickedplayerid),SP,GetPlayerCash(clickedplayerid));
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}Matou: {00FF00}%d {FFFFFF}Morreu: {FF0000}%d {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}HS Infos:\n", PlayerInfo[clickedplayerid][Kills],PlayerInfo[clickedplayerid][Deaths],Float:PlayerInfo[clickedplayerid][Kills]/Float:pDeaths,aval);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Morreu: {FF0000}%d\n", PlayerInfo[clickedplayerid][Deaths]);
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Media: {FFFF00}%0.2f\n", Float:PlayerInfo[clickedplayerid][Kills]/Float:pDeaths);
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Spree: {1E90FF}%i\n", SP);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}HS-Acertados: {00FF00}%i {FFFFFF}Levados: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}Corrida-Ganhadas Infos:\n", PlayerInfo[clickedplayerid][Head],PlayerInfo[clickedplayerid][HeadLevado],Float:PlayerInfo[clickedplayerid][Head]/Float:PlayerInfo[clickedplayerid][HeadLevado],avalHS);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}HS-Levados: {FF0000}%i\n", HSL);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}1Lugar: {00FF00}%i {FFFFFF}2Lugar: {FF3C00}%i {FFFFFF}3Lugar: {FF0000}%i\n\n{FFFF00}Eventos-Ganhados Infos:\n", PlayerInfo[clickedplayerid][Corridas],PlayerInfo[clickedplayerid][Corridasg2],PlayerInfo[clickedplayerid][Corridasgg3]);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Corrida-Ganhadas 2Lugar: {FF3C00}%i\n", CG2);
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Corrida-Ganhadas 3Lugar: {FF0000}%i\n", CG3);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}1Lugar: {00FF00}%i {FFFFFF}2Lugar: {FF3C00}%i {FFFFFF}3Lugar: {FF0000}%i%i\n\n{FFFF00}Duelos Infos:\n", PlayerInfo[clickedplayerid][EVENTOPremiar],PlayerInfo[clickedplayerid][EVENTOPremiar2],PlayerInfo[clickedplayerid][EVENTOPremiar3]);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}X1-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", PlayerInfo[clickedplayerid][X1Ganhos],PlayerInfo[clickedplayerid][X1Perdidos],Float:PlayerInfo[clickedplayerid][X1Ganhos]/Float:PlayerInfo[clickedplayerid][X1Perdidos],avalX1);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}X1W-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}Arenas Infos:\n", PlayerInfo[clickedplayerid][X1WGanhos],PlayerInfo[clickedplayerid][X1WPerdidos],Float:PlayerInfo[clickedplayerid][X1WGanhos]/Float:PlayerInfo[clickedplayerid][X1WPerdidos],avalX1W);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}X1P-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", PlayerInfo[clickedplayerid][X1PGanhos],PlayerInfo[clickedplayerid][X1PPerdidos],Float:PlayerInfo[clickedplayerid][X1PGanhos]/Float:PlayerInfo[clickedplayerid][X1PPerdidos],avalX1P);
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}X1S-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", PlayerInfo[clickedplayerid][X1SGanhos],PlayerInfo[clickedplayerid][X1SPerdidos],Float:PlayerInfo[clickedplayerid][X1SGanhos]/Float:PlayerInfo[clickedplayerid][X1SPerdidos],avalX1S);
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}X1L-Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}Arenas Infos:\n", PlayerInfo[clickedplayerid][X1LGanhos],PlayerInfo[clickedplayerid][X1LPerdidos],Float:PlayerInfo[clickedplayerid][X1LGanhos]/Float:PlayerInfo[clickedplayerid][X1LPerdidos],avalX1L);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}PISTOLA: Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", PlayerInfo[clickedplayerid][PistolaGanhos],PlayerInfo[clickedplayerid][PistolaPerdidos],Float:PlayerInfo[clickedplayerid][PistolaGanhos]/Float:PlayerInfo[clickedplayerid][PistolaPerdidos],avalPISTOLA);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}WALK: Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", PlayerInfo[clickedplayerid][WALKGanhos],PlayerInfo[clickedplayerid][WALKPerdidos],Float:PlayerInfo[clickedplayerid][WALKGanhos]/Float:PlayerInfo[clickedplayerid][WALKPerdidos],avalARENAWALK);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}RUN: Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n", PlayerInfo[clickedplayerid][RUNGanhos],PlayerInfo[clickedplayerid][RUNPerdidos],Float:PlayerInfo[clickedplayerid][RUNGanhos]/Float:PlayerInfo[clickedplayerid][RUNPerdidos],avalARENARUN);
	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}SNP: Ganhou: {00FF00}%i {FFFFFF}Perdeu: {FF0000}%i {FFFFFF}Media: {FF3C00}%0.2f %s\n\n{FFFF00}Desempenho/Conexão:\n", PlayerInfo[clickedplayerid][SNPGanhos],PlayerInfo[clickedplayerid][SNPPerdidos],Float:PlayerInfo[clickedplayerid][SNPGanhos]/Float:PlayerInfo[clickedplayerid][SNPPerdidos],avalARENASNP);
	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Dinheiro: {00FF00}$%d\n", GetPlayerCash(clickedplayerid));
//	strcat(string2, string);
//	format(string, sizeof(string), "{FFFFFF}Habilidade: %s\n", aval);
//	strcat(string2, string);
	format(string, sizeof(string), "{FFFFFF}Computador: %s{FFFFFF} - (%i FPS)\n", avalFPS,FPS);
	strcat(string2, string);
	format(string, sizeof(string), "Conexão: %s {FFFFFF}- (%i PING)\n", avalPING,PING);
	strcat(string2, string);
	ShowPlayerDialog(playerid,911,DIALOG_STYLE_MSGBOX," {FF0000}VICIADOS EM GTA {FFFFFF}- Status Do Jogador", string2, "OK", "Voltar");
	}

return 1;
}


forward LATickUpdate();
public LATickUpdate()
{
LATickCount++;
}


//==============================================================================
forward GodUpdate();
public GodUpdate()
{
	for(new i,a = GetMaxPlayers();i < a;i++)
	{
		if(IsPlayerConnected(i) && PlayerInfo[i][God] == 1)
		{
			SetPlayerHealth(i,100000);
		}
		if(IsPlayerConnected(i) && PlayerInfo[i][GodCar] == 1 && IsPlayerInAnyVehicle(i))
		{
			SetVehicleHealth(GetPlayerVehicleID(i),10000);
		}
	}
}

//==========================[ Server Info  ]====================================

forward ConnectedPlayers();
public ConnectedPlayers()
{
	new Connected;
	for (new i = 0; i < MAX_PLAYERS; i++)if(IsPlayerConnected(i)){ Connected++;}
	return Connected;
}

forward JailedPlayers();
public JailedPlayers()
{
	new JailedCount;
	for (new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)){if(PlayerInfo[i][Jailed] == 1) JailedCount++;}
	return JailedCount;
}

forward FrozenPlayers();
public FrozenPlayers()
{
	new FrozenCount; for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Frozen] == 1) FrozenCount++;
	return FrozenCount;
}

forward MutedPlayers();
public MutedPlayers()
{
	new Count; for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Muted] == 1) Count++;
	return Count;
}

forward InVehCount();
public InVehCount()
{
	new InVeh; for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i)) InVeh++;
	return InVeh;
}

forward OnBikeCount();
public OnBikeCount()
{
	new BikeCount;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i)) {
		new LModel = GetVehicleModel(GetPlayerVehicleID(i));
		switch(LModel)
		{
			case 448,461,462,463,468,471,509,510,521,522,523,581,586:  BikeCount++;
		}
	}
	return BikeCount;
}

forward InCarCount();
public InCarCount()
{
	new PInCarCount;
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i)) {
			new LModel = GetVehicleModel(GetPlayerVehicleID(i));
			switch(LModel)
			{
				case 448,461,462,463,468,471,509,510,521,522,523,581,586: {}
				default: PInCarCount++;
			}
		}
	}
	return PInCarCount;
}

forward AdminCount();
public AdminCount()
{
	new LAdminCount;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Level] >= 1)	LAdminCount++;
	return LAdminCount;
}

forward RconAdminCount();
public RconAdminCount()
{
	new rAdminCount;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerAdmin(i)) rAdminCount++;
	return rAdminCount;
}

//==========================[ Remote Console ]==================================

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward RestartGM();
public RestartGM()
{
	SendRconCommand("gmx");
}

forward UnloadFS();
public UnloadFS()
{
	SendRconCommand("unloadfs ladmin4v2");
}

forward PrintWarning(const string[]);
public PrintWarning(const string[])
{
    new str[128];
    print("\n\n>		WARNING:\n");
    format(str, sizeof(str), " The  %s  folder is missing from scriptfiles", string);
    print(str);
    print("\n Please Create This Folder And Reload the Filterscript\n\n");
}

//============================[ Bot Check ]=====================================
forward BotCheck(playerid);
public BotCheck(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(GetPlayerPing(playerid) < 1)
		{
			new string[128], ip[20];  GetPlayerIp(playerid,ip,sizeof(ip));
			format(string,sizeof(string),"BOT: %s id:%d ip: %s ping: %d",PlayerName2(playerid),playerid,ip,GetPlayerPing(playerid));
			SaveToFile("BotKickLog",string);
		    SaveToFile("KickLog",string);
			printf("[ADMIN] Possible bot has been detected (Kicked %s ID:%d)", PlayerName2(playerid), playerid);
			Kick(playerid);
		}
	}
}

//==============================================================================
forward PutAtPos(playerid);
public PutAtPos(playerid)
{
	if (dUserINT(PlayerName2(playerid)).("x")!=0) {
     	SetPlayerPos(playerid, float(dUserINT(PlayerName2(playerid)).("x")), float(dUserINT(PlayerName2(playerid)).("y")), float(dUserINT(PlayerName2(playerid)).("z")) );
 		SetPlayerInterior(playerid,	(dUserINT(PlayerName2(playerid)).("interior"))	);
	}
}

forward PutAtDisconectPos(playerid);
public PutAtDisconectPos(playerid)
{
	if (dUserINT(PlayerName2(playerid)).("x1")!=0) {
    	SetPlayerPos(playerid, float(dUserINT(PlayerName2(playerid)).("x1")), float(dUserINT(PlayerName2(playerid)).("y1")), float(dUserINT(PlayerName2(playerid)).("z1")) );
		SetPlayerInterior(playerid,	(dUserINT(PlayerName2(playerid)).("interior1"))	);
	}
}

TotalGameTime(playerid, &h=0, &m=0, &s=0)
{
    PlayerInfo[playerid][TotalTime] = ( (gettime() - PlayerInfo[playerid][ConnectTime]) + (PlayerInfo[playerid][hours]*60*60) + (PlayerInfo[playerid][mins]*60) + (PlayerInfo[playerid][secs]) );

    h = floatround(PlayerInfo[playerid][TotalTime] / 3600, floatround_floor);
    m = floatround(PlayerInfo[playerid][TotalTime] / 60,   floatround_floor) % 60;
    s = floatround(PlayerInfo[playerid][TotalTime] % 60,   floatround_floor);

    return PlayerInfo[playerid][TotalTime];
}

//==============================================================================
MaxAmmo(playerid)
{
	new slot, weap, ammo;
	for (slot = 0; slot < 14; slot++)
	{
    	GetPlayerWeaponData(playerid, slot, weap, ammo);
		if(IsValidWeapon(weap))
		{
		   	GivePlayerWeapon(playerid, weap, 99999);
		}
	}
	return 1;
}

stock PlayerName2(playerid) {
  new name[MAX_PLAYER_NAME];
  GetPlayerName(playerid, name, sizeof(name));
  return name;
}

stock pName(playerid)
{
  new name[MAX_PLAYER_NAME];
  GetPlayerName(playerid, name, sizeof(name));
  return name;
}

stock TimeStamp()
{
	new time = GetTickCount() / 1000;
	return time;
}

stock PlayerSoundForAll(SoundID)
{
	for (new i = 0; i < MAX_PLAYERS; i++) PlayerPlaySound(i, SoundID, 0.0, 0.0, 0.0);
}

stock IsValidWeapon(weaponid)
{
    if (weaponid > 0 && weaponid < 19 || weaponid > 21 && weaponid < 47) return 1;
    return 0;
}

stock IsValidSkin(SkinID)
{
	if((SkinID == 0)||(SkinID == 7)||(SkinID >= 9 && SkinID <= 41)||(SkinID >= 43 && SkinID <= 64)||(SkinID >= 66 && SkinID <= 73)||(SkinID >= 75 && SkinID <= 85)||(SkinID >= 87 && SkinID <= 118)||(SkinID >= 120 && SkinID <= 148)||(SkinID >= 150 && SkinID <= 207)||(SkinID >= 209 && SkinID <= 264)||(SkinID >= 274 && SkinID <= 288)||(SkinID >= 290 && SkinID >= 299 && SkinID <= 311)) return true;
	else return false;
}

stock IsNumeric(string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

stock ReturnPlayerID(PlayerName[])
{
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
	if(IsPlayerConnected(i)){
	
			if(strfind(pName(i),PlayerName,true)!=-1) return i;
	}}
	return INVALID_PLAYER_ID;
}

GetVehicleModelIDFromName(vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if ( strfind(VehicleNames[i], vname, true) != -1 )
			return i + 400;
	}
	return -1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

stock GetWeaponIDFromName(WeaponName[])
{
	if(strfind("molotov",WeaponName,true)!=-1) return 18;
	for(new i = 0; i <= 46; i++)
	{
		switch(i)
		{
			case 0,19,20,21,44,45: continue;
			default:
			{
				new name[32]; GetWeaponName(i,name,32);
				if(strfind(name,WeaponName,true) != -1) return i;
			}
		}
	}
	return -1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

stock DisableWord(const badword[], text[])
{
   	for(new i=0; i<256; i++)
   	{
		if (strfind(text[i], badword, true) == 0)
		{
			for(new a=0; a<256; a++)
			{
				if (a >= i && a < i+strlen(badword)) text[a]='*';
			}
		}
	}
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

argpos(const string[], idx = 0, sep = ' ')// (by yom)
{
    for(new i = idx, j = strlen(string); i < j; i++)
        if (string[i] == sep && string[i+1] != sep)
            return i+1;

    return -1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

//==============================================================================


/*
forward MessageToClaBase1(color,const string[]);
public MessageToClaBase1(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
 	{
    	if(IsPlayerConnected(i))
     	{
  		if (mrj[i] >= 1){
  		SendClientMessage(i, color, string);}
  		}

	}
 	return 1;
}

forward MessageToClaBase2(color,const string[]);
public MessageToClaBase2(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
 	{
    	if(IsPlayerConnected(i))
     	{
  		if (d3x[i] >= 1){
  		SendClientMessage(i, color, string);}
  		}

	}
 	return 1;
}

forward MessageToClaBase3(color,const string[]);
public MessageToClaBase3(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
 	{
    	if(IsPlayerConnected(i))
     	{
  		if (bmf[i] >= 1){
  		SendClientMessage(i, color, string);}
  		}

	}
 	return 1;
}

forward MessageToClaBase4(color,const string[]);
public MessageToClaBase4(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
 	{
    	if(IsPlayerConnected(i))
     	{
  		if (vks[i] >= 1){
  		SendClientMessage(i, color, string);}
  		}

	}
 	return 1;
}

forward MessageToClaBase5(color,const string[]);
public MessageToClaBase5(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
 	{
    	if(IsPlayerConnected(i))
     	{
  		if (mvx[i] >= 1){
  		SendClientMessage(i, color, string);}
  		}

	}
 	return 1;
}

forward MessageToClaBase6(color,const string[]);
public MessageToClaBase6(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
 	{
    	if(IsPlayerConnected(i))
     	{
  		if (boy[i] >= 1){
  		SendClientMessage(i, color, string);}
  		}

	}
 	return 1;
}

forward MessageToClaBase7(color,const string[]);
public MessageToClaBase7(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
 	{
    	if(IsPlayerConnected(i))
     	{
  		if (nrx[i] >= 1){
  		SendClientMessage(i, color, string);}
  		}

	}
 	return 1;
}
*/


forward MessageToAdmins(color,const string[]);
public MessageToAdmins(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
	{
	    if(IsPlayerConnected(i))
	    {
		if (PlayerInfo[i][Level] >= 2){
		SendClientMessage(i, color, string);}
		}
		
	}
	return 1;
}

forward MessageToOwners(color,const string[]);
public MessageToOwners(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
	{
	    if(IsPlayerConnected(i))
	    {
		if (PlayerInfo[i][Level] >= 6){
		SendClientMessage(i, color, string);}
		}

	}
	return 1;
}

forward MessageToVIPS(color,const string[]);
public MessageToVIPS(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
	{
	    if(IsPlayerConnected(i))
	    {
		if (PlayerInfo[i][VIP] >= 1){
		SendClientMessage(i, color, string);}
		}

	}
	return 1;
}


/*
forward MessageToVips(color,const string[]);
public MessageToVips(color,const string[])
{
	for(new i; i < GetMaxPlayers(); i++)
 	{
    	if(IsPlayerConnected(i))
     	{
  		if (PlayerInfo[i][Level] >= 1){
  		SendClientMessage(i, color, string);}
  		}

	}
 	return 1;
}
*/

//GameTextToAdmins("_~n~_~n~_~n~_~n~_~n~_~n~_~n~~w~NOVO ~r~REPORT!",3000,5);
//GameTextForPlayer(id,"_~n~_~n~_~n~_~n~_~n~_~n~_~n~~y~PM RECEBIDA!", 3000, 5);
forward GameTextToAdmins(const string[],time,style);
public GameTextToAdmins(const string[],time,style)
{
	for(new i; i < GetMaxPlayers(); i++)
	{
	    if(IsPlayerConnected(i))
	    {
		if (PlayerInfo[i][Level] >= 2){
		GameTextForPlayer(i, string, time, style);}
		}

	}
	return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward BeepToAdmins();
public BeepToAdmins()
{
	for(new i; i < GetMaxPlayers(); i++)
	{
	    if(IsPlayerConnected(i))
	    {
		if (PlayerInfo[i][Level] >= 2){PlayerPlaySound(i,1057,0.0,0.0,0.0);}
		}

	}
	return 1;
}


forward CMDMessageToAdmins(playerid,command[]);
public CMDMessageToAdmins(playerid,command[])
{
	if(ServerInfo[AdminCmdMsg] == 0) return 1;
	//if(PlayerInfo[playerid][Level] == 5) return 1;
	new string[128]; GetPlayerName(playerid,string,sizeof(string));
	format(string,sizeof(string),"{C0FF3E}[ADMIN]:{FFFFFF} %s usou o comando {C0FF3E}%s",string,command);
	return MessageToAdmins(green,string);
}

//==============================================================================
SavePlayer(playerid)
{
    dUserSetINT(PlayerName2(playerid)).("gp",GetPVarInt(playerid,"GrupoChat"));

    dUserSetINT(PlayerName2(playerid)).("PlayerSkin",GetPlayerSkin(playerid));
   	dUserSetINT(PlayerName2(playerid)).("money",GetPlayerCash(playerid));
   	dUserSetINT(PlayerName2(playerid)).("kills",PlayerInfo[playerid][Kills]);
   	dUserSetINT(PlayerName2(playerid)).("deaths",PlayerInfo[playerid][Deaths]);

   	dUserSetINT(PlayerName2(playerid)).("VIP",PlayerInfo[playerid][VIP]);

	dUserSetINT(PlayerName2(playerid)).("Head",PlayerInfo[playerid][Head]);
	dUserSetINT(PlayerName2(playerid)).("HeadLevado",PlayerInfo[playerid][HeadLevado]);
	dUserSetINT(PlayerName2(playerid)).("Corridas",PlayerInfo[playerid][Corridas]);
	dUserSetINT(PlayerName2(playerid)).("Corridasg2",PlayerInfo[playerid][Corridasg2]);
	dUserSetINT(PlayerName2(playerid)).("Corridasgg3",PlayerInfo[playerid][Corridasgg3]);
	dUserSetINT(PlayerName2(playerid)).("EVENTOPremiar",PlayerInfo[playerid][EVENTOPremiar]);
	dUserSetINT(PlayerName2(playerid)).("EVENTOPremiar2",PlayerInfo[playerid][EVENTOPremiar2]);
	dUserSetINT(PlayerName2(playerid)).("EVENTOPremiar3",PlayerInfo[playerid][EVENTOPremiar3]);
	dUserSetINT(PlayerName2(playerid)).("X1Ganhos",PlayerInfo[playerid][X1Ganhos]);
	dUserSetINT(PlayerName2(playerid)).("X1Perdidos",PlayerInfo[playerid][X1Perdidos]);
	dUserSetINT(PlayerName2(playerid)).("X1WGanhos",PlayerInfo[playerid][X1WGanhos]);
	dUserSetINT(PlayerName2(playerid)).("X1WPerdidos",PlayerInfo[playerid][X1WPerdidos]);
	dUserSetINT(PlayerName2(playerid)).("X1PGanhos",PlayerInfo[playerid][X1PGanhos]);
	dUserSetINT(PlayerName2(playerid)).("X1PPerdidos",PlayerInfo[playerid][X1PPerdidos]);
	dUserSetINT(PlayerName2(playerid)).("X1SGanhos",PlayerInfo[playerid][X1SGanhos]);
	dUserSetINT(PlayerName2(playerid)).("X1SPerdidos",PlayerInfo[playerid][X1SPerdidos]);
	dUserSetINT(PlayerName2(playerid)).("X1LGanhos",PlayerInfo[playerid][X1LGanhos]);
	dUserSetINT(PlayerName2(playerid)).("X1LPerdidos",PlayerInfo[playerid][X1LPerdidos]);
	dUserSetINT(PlayerName2(playerid)).("PistolaGanhos",PlayerInfo[playerid][PistolaGanhos]);
	dUserSetINT(PlayerName2(playerid)).("PistolaPerdidos",PlayerInfo[playerid][PistolaPerdidos]);
	dUserSetINT(PlayerName2(playerid)).("RUNGanhos",PlayerInfo[playerid][RUNGanhos]);
	dUserSetINT(PlayerName2(playerid)).("RUNPerdidos",PlayerInfo[playerid][RUNPerdidos]);
	dUserSetINT(PlayerName2(playerid)).("WALKGanhos",PlayerInfo[playerid][WALKGanhos]);
	dUserSetINT(PlayerName2(playerid)).("WALKPerdidos",PlayerInfo[playerid][WALKPerdidos]);
	dUserSetINT(PlayerName2(playerid)).("SNPGanhos",PlayerInfo[playerid][SNPGanhos]);
	dUserSetINT(PlayerName2(playerid)).("SNPPerdidos",PlayerInfo[playerid][SNPPerdidos]);

  	new score = GetPlayerScore(playerid);
    dUserSetINT(PlayerName2(playerid)).("score",score);

	new h, m, s;
    TotalGameTime(playerid, h, m, s);

	dUserSetINT(PlayerName2(playerid)).("hours", h);
	dUserSetINT(PlayerName2(playerid)).("minutes", m);
	dUserSetINT(PlayerName2(playerid)).("seconds", s);
	
   	new Float:x,Float:y,Float:z, interior;
   	GetPlayerPos(playerid,x,y,z);	interior = GetPlayerInterior(playerid);
    dUserSetINT(PlayerName2(playerid)).("x1",floatround(x));
	dUserSetINT(PlayerName2(playerid)).("y1",floatround(y));
	dUserSetINT(PlayerName2(playerid)).("z1",floatround(z));
    dUserSetINT(PlayerName2(playerid)).("interior1",interior);
    dUserSetINT(PlayerName2(playerid)).("jailed",PlayerInfo[playerid][Jailed]);
    dUserSetINT(PlayerName2(playerid)).("jailtime",PlayerInfo[playerid][JailTime]);

	new weap1, ammo1, weap2, ammo2, weap3, ammo3, weap4, ammo4, weap5, ammo5, weap6, ammo6;
	GetPlayerWeaponData(playerid,2,weap1,ammo1);// hand gun
	GetPlayerWeaponData(playerid,3,weap2,ammo2);//shotgun
	GetPlayerWeaponData(playerid,4,weap3,ammo3);// SMG
	GetPlayerWeaponData(playerid,5,weap4,ammo4);// AK47 / M4
	GetPlayerWeaponData(playerid,6,weap5,ammo5);// rifle
	GetPlayerWeaponData(playerid,7,weap6,ammo6);// rocket launcher
   	dUserSetINT(PlayerName2(playerid)).("weap1",weap1); dUserSetINT(PlayerName2(playerid)).("weap1ammo",ammo1);
  	dUserSetINT(PlayerName2(playerid)).("weap2",weap2);	dUserSetINT(PlayerName2(playerid)).("weap2ammo",ammo2);
  	dUserSetINT(PlayerName2(playerid)).("weap3",weap3);	dUserSetINT(PlayerName2(playerid)).("weap3ammo",ammo3);
	dUserSetINT(PlayerName2(playerid)).("weap4",weap4); dUserSetINT(PlayerName2(playerid)).("weap4ammo",ammo4);
  	dUserSetINT(PlayerName2(playerid)).("weap5",weap5);	dUserSetINT(PlayerName2(playerid)).("weap5ammo",ammo5);
	dUserSetINT(PlayerName2(playerid)).("weap6",weap6); dUserSetINT(PlayerName2(playerid)).("weap6ammo",ammo6);

	new	Float:health;	GetPlayerHealth(playerid, Float:health);
	new	Float:armour;	GetPlayerArmour(playerid, Float:armour);
	new year,month,day;	getdate(year, month, day);
	new strdate[20];	format(strdate, sizeof(strdate), "%d.%d.%d",day,month,year);
	new file[256]; 		format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(playerid)) );
	
	dini_IntSet(file,"PlayerColor",CallRemoteFunction("GetColorStatus","i",playerid));
	
	
	dUserSetINT(PlayerName2(playerid)).("lc",lercmds[playerid]);
	
	dUserSetINT(PlayerName2(playerid)).("LastGC",CallRemoteFunction("GetPlayerGCStatus","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("LastSpree",CallRemoteFunction("GetPlayerSpreeStatus","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("LastTrancar",CallRemoteFunction("GetPlayerTrancarStatus","i",playerid));
	
	dUserSetINT(PlayerName2(playerid)).("CS",CallRemoteFunction("GetPCSStatus","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("CS_X",CallRemoteFunction("GetPCSStatus_X","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("CS_Y",CallRemoteFunction("GetPCSStatus_Y","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("CS_Z",CallRemoteFunction("GetPCSStatus_Z","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("CS_F",CallRemoteFunction("GetPCSStatus_F","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("CS_I",CallRemoteFunction("GetPCSStatus_I","i",playerid));
	
	dUserSetINT(PlayerName2(playerid)).("LastRojoes",CallRemoteFunction("GetRojoesStatus","i",playerid));

	dUserSetINT(PlayerName2(playerid)).("LastContarHeadShotLevados",CallRemoteFunction("GetPlayerContarHeadShotLevados","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("LastContarHeadShot",CallRemoteFunction("GetPlayerContarHeadShot","i",playerid));


	dUserSetINT(PlayerName2(playerid)).("WantedLevel",GetPlayerWantedLevel(playerid));
	dUserSetINT(PlayerName2(playerid)).("PlayerSkin",CallRemoteFunction("GetSkinStatus","i",playerid));
	dUserSetINT(PlayerName2(playerid)).("health",floatround(health));
    dUserSetINT(PlayerName2(playerid)).("armour",floatround(armour));
	dini_Set(file,"LastOn",strdate);
	dUserSetINT(PlayerName2(playerid)).("loggedin",0);
	dUserSetINT(PlayerName2(playerid)).("TimesOnServer",(dUserINT(PlayerName2(playerid)).("TimesOnServer"))+1);
}

//==============================================================================
#if defined USE_MENUS
DestroyAllMenus()
{
	DestroyMenu(LVehicles); DestroyMenu(twodoor); DestroyMenu(fourdoor); DestroyMenu(fastcar); DestroyMenu(Othercars);
	DestroyMenu(bikes); DestroyMenu(boats); DestroyMenu(planes); DestroyMenu(helicopters ); DestroyMenu(LTime);
	DestroyMenu(XWeapons); DestroyMenu(XWeaponsBig); DestroyMenu(XWeaponsSmall); DestroyMenu(XWeaponsMore);
	DestroyMenu(LWeather); DestroyMenu(LTuneMenu); DestroyMenu(PaintMenu); DestroyMenu(LCars); DestroyMenu(LCars2);
	DestroyMenu(LTele); DestroyMenu(LasVenturasMenu); DestroyMenu(LosSantosMenu); DestroyMenu(SanFierroMenu);
	DestroyMenu(LMainMenu); DestroyMenu(DesertMenu); DestroyMenu(FlintMenu); DestroyMenu(MountChiliadMenu); DestroyMenu(InteriorsMenu);
	DestroyMenu(AdminEnable); DestroyMenu(AdminDisable);
}
#endif

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

//==============================================================================
#if defined DISPLAY_CONFIG
stock ConfigInConsole()
{
	print(" ________ Configuracao ___________\n");
	print(" __________ Chat & Messages ______");
	if(ServerInfo[AntiSwear] == 0) print("  Anti Swear:              Disabled "); else print("  Anti Swear:             Enabled ");
	if(ServerInfo[AntiSpam] == 0)  print("  Anti Spam:               Disabled "); else print("  Anti Spam:              Enabled ");
	if(ServerInfo[ReadCmds] == 0)  print("  Read Cmds:               Disabled "); else print("  Read Cmds:              Enabled ");
	if(ServerInfo[ReadPMs] == 0)   print("  Read PMs:                Disabled "); else print("  Read PMs:               Enabled ");
	if(ServerInfo[ConnectMessages] == 0) print("  Connect Messages:        Disabled "); else print("  Connect Messages:       Enabled ");
  	if(ServerInfo[AdminCmdMsg] == 0) print("  Admin Cmd Messages:     Disabled ");  else print("  Admin Cmd Messages:     Enabled ");
	if(ServerInfo[ReadPMs] == 0)   print("  Anti capital letters:    Disabled \n"); else print("  Anti capital letters:   Enabled \n");
	print(" __________ Skins ________________");
	if(ServerInfo[AdminOnlySkins] == 0) print("  AdminOnlySkins:         Disabled "); else print("  AdminOnlySkins:         Enabled ");
	printf("  Admin Skin 1 is:         %d", ServerInfo[AdminSkin] );
	printf("  Admin Skin 2 is:         %d\n", ServerInfo[AdminSkin2] );
	print(" ________ Server Protection ______");
	if(ServerInfo[AntiBot] == 0) print("  Anti Bot:                Disabled "); else print("  Anti Bot:                Enabled ");
	if(ServerInfo[NameKick] == 0) print("  Bad Name Kick:           Disabled\n"); else print("  Bad Name Kick:           Enabled\n");
	print(" __________ Ping Control _________");
	if(ServerInfo[MaxPing] == 0) print("  Ping Control:            Disabled"); else print("  Ping Control:            Enabled");
	printf("  Max Ping:                %d\n", ServerInfo[MaxPing] );
	print(" __________ Players ______________");
	if(ServerInfo[GiveWeap] == 0) print("  Save/Give Weaps:         Disabled"); else print("  Save/Give Weaps:         Enabled");
	if(ServerInfo[GiveMoney] == 0) print("  Save/Give Money:         Disabled\n"); else print("  Save/Give Money:         Enabled\n");
	print(" __________ Other ________________");
	printf("  Max Admin Level:         %d", ServerInfo[MaxAdminLevel] );
	if(ServerInfo[Locked] == 0) print("  Server Locked:           No"); else print("  Server Locked:           Yes");
	if(ServerInfo[AutoLogin] == 0) print("  Auto Login:             Disabled\n"); else print("  Auto Login:              Enabled\n");
}
#endif

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

//=====================[ Configuration ] =======================================
stock UpdateConfig()
{
	new file[256], File:file2, string[100]; format(file,sizeof(file),"ladmin/config/Config.ini");
	ForbiddenWordCount = 0;
	BadNameCount = 0;
	BadPartNameCount = 0;
	
	if(!dini_Exists("ladmin/config/aka.txt")) dini_Create("ladmin/config/aka.txt");
	
	if(!dini_Exists(file))
	{
		dini_Create(file);
		print("\n >Configuration File Successfully Created");
	}

	if(!dini_Isset(file,"MaxPing")) dini_IntSet(file,"MaxPing",1200);
	if(!dini_Isset(file,"ReadPms")) dini_IntSet(file,"ReadPMs",1);
	if(!dini_Isset(file,"ReadCmds")) dini_IntSet(file,"ReadCmds",1);
	if(!dini_Isset(file,"MaxAdminLevel")) dini_IntSet(file,"MaxAdminLevel",7);
	if(!dini_Isset(file,"MaxVIPLevel")) dini_IntSet(file,"MaxVIPLevel",3);
	if(!dini_Isset(file,"AdminOnlySkins")) dini_IntSet(file,"AdminOnlySkins",0);
	if(!dini_Isset(file,"AdminSkin")) dini_IntSet(file,"AdminSkin",217);
	if(!dini_Isset(file,"AdminSkin2")) dini_IntSet(file,"AdminSkin2",214);
	if(!dini_Isset(file,"AntiBot")) dini_IntSet(file,"AntiBot",1);
	if(!dini_Isset(file,"AntiSpam")) dini_IntSet(file,"AntiSpam",1);
	if(!dini_Isset(file,"AntiSwear")) dini_IntSet(file,"AntiSwear",1);
	if(!dini_Isset(file,"NameKick")) dini_IntSet(file,"NameKick",1);
 	if(!dini_Isset(file,"PartNameKick")) dini_IntSet(file,"PartNameKick",1);
	if(!dini_Isset(file,"NoCaps")) dini_IntSet(file,"NoCaps",0);
	if(!dini_Isset(file,"Locked")) dini_IntSet(file,"Locked",0);
	if(!dini_Isset(file,"SaveWeap")) dini_IntSet(file,"SaveWeap",1);
	if(!dini_Isset(file,"SaveMoney")) dini_IntSet(file,"SaveMoney",1);
	if(!dini_Isset(file,"ConnectMessages")) dini_IntSet(file,"ConnectMessages",1);
	if(!dini_Isset(file,"AdminCmdMessages")) dini_IntSet(file,"AdminCmdMessages",1);
	if(!dini_Isset(file,"AutoLogin")) dini_IntSet(file,"AutoLogin",1);
	if(!dini_Isset(file,"MaxMuteWarnings")) dini_IntSet(file,"MaxMuteWarnings",4);
	if(!dini_Isset(file,"MustLogin")) dini_IntSet(file,"MustLogin",0);
	if(!dini_Isset(file,"MustRegister")) dini_IntSet(file,"MustRegister",0);

	if(dini_Exists(file))
	{
		ServerInfo[MaxPing] = dini_Int(file,"MaxPing");
		ServerInfo[ReadPMs] = dini_Int(file,"ReadPMs");
		ServerInfo[ReadCmds] = dini_Int(file,"ReadCmds");
		ServerInfo[MaxAdminLevel] = dini_Int(file,"MaxAdminLevel");
        ServerInfo[MaxVIPLevel] = dini_Int(file,"MaxVIPLevel");
		ServerInfo[AdminOnlySkins] = dini_Int(file,"AdminOnlySkins");
		ServerInfo[AdminSkin] = dini_Int(file,"AdminSkin");
		ServerInfo[AdminSkin2] = dini_Int(file,"AdminSkin2");
		ServerInfo[AntiBot] = dini_Int(file,"AntiBot");
		ServerInfo[AntiSpam] = dini_Int(file,"AntiSpam");
		ServerInfo[AntiSwear] = dini_Int(file,"AntiSwear");
		ServerInfo[NameKick] = dini_Int(file,"NameKick");
		ServerInfo[PartNameKick] = dini_Int(file,"PartNameKick");
		ServerInfo[NoCaps] = dini_Int(file,"NoCaps");
		ServerInfo[Locked] = dini_Int(file,"Locked");
		ServerInfo[GiveWeap] = dini_Int(file,"SaveWeap");
		ServerInfo[GiveMoney] = dini_Int(file,"SaveMoney");
		ServerInfo[ConnectMessages] = dini_Int(file,"ConnectMessages");
		ServerInfo[AdminCmdMsg] = dini_Int(file,"AdminCmdMessages");
		ServerInfo[AutoLogin] = dini_Int(file,"AutoLogin");
		ServerInfo[MaxMuteWarnings] = dini_Int(file,"MaxMuteWarnings");
		ServerInfo[MustLogin] = dini_Int(file,"MustLogin");
		ServerInfo[MustRegister] = dini_Int(file,"MustRegister");
		//print("\n -Configuration Settings Loaded");
	}

	//forbidden names
	if((file2 = fopen("ladmin/config/ForbiddenNames.cfg",io_read)))
	{
		while(fread(file2,string))
		{
		    for(new i = 0, j = strlen(string); i < j; i++) if(string[i] == '\n' || string[i] == '\r') string[i] = '\0';
            BadNames[BadNameCount] = string;
            BadNameCount++;
		}
		fclose(file2);	//printf(" -%d Forbidden Names Loaded", BadNameCount);
	}

	//forbidden part of names
	if((file2 = fopen("ladmin/config/ForbiddenPartNames.cfg",io_read)))
	{
		while(fread(file2,string))
		{
		    for(new i = 0, j = strlen(string); i < j; i++) if(string[i] == '\n' || string[i] == '\r') string[i] = '\0';
            BadPartNames[BadPartNameCount] = string;
            BadPartNameCount++;
		}
		fclose(file2);	//printf(" -%d Forbidden Tags Loaded", BadPartNameCount);
	}

	//forbidden words
	if((file2 = fopen("ladmin/config/ForbiddenWords.cfg",io_read)))
	{
		while(fread(file2,string))
		{
		    for(new i = 0, j = strlen(string); i < j; i++) if(string[i] == '\n' || string[i] == '\r') string[i] = '\0';
            ForbiddenWords[ForbiddenWordCount] = string;
            ForbiddenWordCount++;
		}
		fclose(file2);	//printf(" -%d Forbidden Words Loaded", ForbiddenWordCount);
	}
}
//=====================[ SAVING DATA ] =========================================

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward SaveToFile(filename[],text[]);
public SaveToFile(filename[],text[])
{
	#if defined SAVE_LOGS
	new File:LAdminfile, filepath[256], string[150], year,month,day, hour,minute,second;
	getdate(year,month,day); gettime(hour,minute,second);
	
	format(filepath,sizeof(filepath),"ladmin/logs/%s.txt",filename);
	LAdminfile = fopen(filepath,io_append);
	
	if(fexist(filepath)) //Limitador dos LOGS e Arquivador
	{
		if(flength(LAdminfile) > 262144) // Limite LOG > 256 KB = Arquivar
		{
		fclose(LAdminfile);
		new ArchStr[256];
	 	format(ArchStr,sizeof(ArchStr),"%s_%i-%i-%i_%i.%i.%i.txt",filepath,year,month,day,hour,minute,second);
		frename(filepath,ArchStr);
		LAdminfile = fopen(filepath,io_append);
		}
	}
	
	format(string,sizeof(string),"[%d.%d.%d %d:%d:%d] %s\r\n",day,month,year,hour,minute,second,text);
	fwrite(LAdminfile,string);
	fclose(LAdminfile);
	#endif
	
	return 1;
}

//============================[ EOF ]===========================================

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

IsPlayerSpawned(playerid){
new statex = GetPlayerState(playerid);
if(statex != PLAYER_STATE_NONE && statex != PLAYER_STATE_WASTED && statex != PLAYER_STATE_SPAWNED){
if(statex != PLAYER_STATE_SPECTATING)
{return true;}}return false;}

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É ADMIN FORA DO LADMIN
forward GetPlayerAdminLevel(playerid);
public GetPlayerAdminLevel(playerid) return PlayerInfo[playerid][Level];

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É VIP FORA DO LADMIN
forward GetPlayerVIPLevel(playerid);
public GetPlayerVIPLevel(playerid) return PlayerInfo[playerid][VIP];


/*
//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É DO CLAN FORA DO LADMIN
forward GetPlayerBaseLevel(playerid);
public GetPlayerBaseLevel(playerid) return mrj[playerid];

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É DO CLAN FORA DO LADMIN
forward GetPlayerBase2Level(playerid);
public GetPlayerBase2Level(playerid) return d3x[playerid];

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É DO CLAN FORA DO LADMIN
forward GetPlayerBase3Level(playerid);
public GetPlayerBase3Level(playerid) return bmf[playerid];

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É DO CLAN FORA DO LADMIN
forward GetPlayerBase4Level(playerid);
public GetPlayerBase4Level(playerid) return vks[playerid];

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É DO CLAN FORA DO LADMIN
forward GetPlayerBase5Level(playerid);
public GetPlayerBase5Level(playerid) return mvx[playerid];

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É DO CLAN FORA DO LADMIN
forward GetPlayerBase6Level(playerid);
public GetPlayerBase6Level(playerid) return boy[playerid];

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É DO CLAN FORA DO LADMIN
forward GetPlayerBase7Level(playerid);
public GetPlayerBase7Level(playerid) return nrx[playerid];
*/




//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É REGISTRADO E LOGADO FORA DO LADMIN
forward GetPlayerRegisteredAndLogged(playerid);
public GetPlayerRegisteredAndLogged(playerid){
if(PlayerInfo[playerid][LoggedIn] == 1){
if(PlayerInfo[playerid][Registered] == 1){
return 1;}}return 0;}

//FUNÇÃO EXTERNA PARA CHECAR SE PLAYER É LOGADO FORA DO LADMIN
forward GetPlayerLogged(playerid);
public GetPlayerLogged(playerid){
if(PlayerInfo[playerid][LoggedIn] == 1){return 1;}
return 0;}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com
	
// DINHEIRO SERVER-SIDE
forward GivePlayerCash(playerid, money);
public GivePlayerCash(playerid, money)
{if((Cash[playerid]+money) >= 999999999)
{Cash[playerid] = 999999999;}else{Cash[playerid] += money;}
ResetMoneyBar(playerid);//Resets the money in the original moneybar, Do not remove!
UpdateMoneyBar(playerid,Cash[playerid]);//Sets the money in the moneybar to the serverside cash, Do not remove!
return Cash[playerid];}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward SetPlayerCash(playerid, money);
public SetPlayerCash(playerid, money)
{if((Cash[playerid]+money) >= 999999999)
{Cash[playerid] = 999999999;}else{Cash[playerid] = money;}
ResetMoneyBar(playerid);//Resets the money in the original moneybar, Do not remove!
UpdateMoneyBar(playerid,Cash[playerid]);//Sets the money in the moneybar to the serverside cash, Do not remove!
return Cash[playerid];}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward ResetPlayerCash(playerid);
public ResetPlayerCash(playerid)
{Cash[playerid] = 0;
ResetMoneyBar(playerid);//Resets the money in the original moneybar, Do not remove!
UpdateMoneyBar(playerid,Cash[playerid]);//Sets the money in the moneybar to the serverside cash, Do not remove!
return Cash[playerid];}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward GetPlayerCash(playerid);
public GetPlayerCash(playerid)
{return Cash[playerid];}

forward Update_TS_Hour();
public Update_TS_Hour(){
HourTimeStamp++;
if(!dini_Exists("server_timestamps.ini")) dini_Create("server_timestamps.ini");
dini_IntSet("server_timestamps.ini","HourTimeStamp",HourTimeStamp);
return 1;}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward MoneyTimer();
public MoneyTimer()
{
//new username[MAX_PLAYER_NAME];
for(new i; i < GetMaxPlayers(); i++)
{
if(IsPlayerConnected(i))
{
if(GetPlayerCash(i) != GetPlayerMoney(i))
{
ResetMoneyBar(i);//Resets the money in the original moneybar, Do not remove!
UpdateMoneyBar(i,GetPlayerCash(i));//Sets the money in the moneybar to the serverside cash, Do not remove!
//new hack = GetPlayerMoney(i) - GetPlayerCash(i);
//GetPlayerName(i,username,sizeof(username));
//printf("%s pegou/spawnou a quatia de $%d.", username,hack);
}}}}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward KickPlayerEx(playerid, const motivo[]);
public KickPlayerEx(playerid, const motivo[])
{
new kstring[128],kstring2[128],kPlayerName[MAX_PLAYER_NAME];
GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);
format(kstring, sizeof(kstring), "%s foi kickado. (%s)", kPlayerName,motivo);
format(kstring2, sizeof(kstring2), "VOCÊ FOI KICKADO: (%s)", motivo);
SaveToFile("KickLog",kstring);
printf("[KickPlayerEx] %s",kstring);
SendClientMessageToAll(grey, kstring);
SpawnPlayer(playerid);
SetPlayerInterior(playerid,0);
GameTextForPlayer(playerid,"  ",4000,3);
SendClientMessage(playerid, red, "");
SendClientMessage(playerid, red, kstring2);
SendClientMessage(playerid, red, "");
PlayerPlaySound( playerid, 1188, 0.0, 0.0, 0.0 );
Kick(playerid);
return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward BanirPlayerEx(playerid, const motivo[]);
public BanirPlayerEx(playerid, const motivo[])
{
new kstring[128],kstring2[128],kPlayerName[MAX_PLAYER_NAME];
GetPlayerName(playerid, kPlayerName, MAX_PLAYER_NAME);
format(kstring, sizeof(kstring), "%s foi banido. (%s)", kPlayerName,motivo);
SaveToFile("BanLog",kstring);
printf("[BanirPlayerEx] %s",kstring);
format(kstring2, sizeof(kstring2), "VOCÊ FOI BANIDO: (%s)", motivo);
if(udb_Exists(PlayerName2(playerid)) && PlayerInfo[playerid][LoggedIn] == 1) dUserSetINT(PlayerName2(playerid)).("banned",1);
SendClientMessageToAll(grey, kstring);
SpawnPlayer(playerid);
SetPlayerInterior(playerid,0);
GameTextForPlayer(playerid,"  ",4000,3);
SendClientMessage(playerid, red, "");
SendClientMessage(playerid, red, kstring2);
SendClientMessage(playerid, red, "");
PlayerPlaySound( playerid, 1188, 0.0, 0.0, 0.0 );
BanEx(playerid, motivo);
return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

IsIllegalName(name[]){
for(new i; i<sizeof(CrashNicks); i++){
if(strcmp(CrashNicks[i],name,true)==0){
return 1;}}return 0;}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

AntiDeAMX()
{
    new a[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused a
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

stock LoadConfig()
{
if(!dini_Exists("BMT.ini")) dini_Create("BMT.ini");
ComandosNoLOG = dini_Int("BMT.ini","ComandosNoLOG");
return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

stock NomeDoPlayer(playerid)
{
new N[MAX_PLAYER_NAME];
GetPlayerName(playerid, N, sizeof(N));
return N;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward BanNotify(playerid);
public BanNotify(playerid)
{
		new sttadminscmds[1000];
		strins(sttadminscmds,"{FFFFFF}SEU N0OB VOCÊ ACABA DE SER BANIDO DO SERVIDOR POR DESCUMPRIR NOSSAS /REGRAS\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Se você acha que foi um erro nosso, comunique-se com um dos owners do servidor\n",strlen(sttadminscmds));
		strins(sttadminscmds,"{FFFFFF}Nossa pagina no Facebook: www.facebook.com/groups//\n",strlen(sttadminscmds));
		ShowPlayerDialog(playerid,8469, DIALOG_STYLE_MSGBOX, "{FF0000}VOCE FOI BANIDO",sttadminscmds, "Fechar", "");

//GameTextForPlayer(playerid,"~r~VOCE FOI BANIDO",4000,3);
return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

stock StringTXTBugado(string[])
{
new tils;
for(new i; i < strlen(string); i++)
if(string[i] == '~') tils++;
return tils % 2;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

stock IsAColorHackText(text[])
{
new bool:state1,bool:state2;
if(strfind(text, "{", false) != -1) state1 = true; else state1 = false;
if(strfind(text, "}", false) != -1) state2 = true; else state2 = false;
if(state1 == true && state2 == true) return 1;
return 0;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward ProcessarAdvertencia(playerid, aviso[]);
public ProcessarAdvertencia(playerid, aviso[])
{
new avstring[400],MultaValor;
MultaValor = CallRemoteFunction("GetPlayerCash", "i", playerid) * 1 /100;
MultaAviso[playerid] = MultaValor;
format(avstring, sizeof(avstring), "{FFFFFF}Você acabou de levar uma advertência\npor quebrar as /regras do servidor:{FFFF00}\n\n%s\n\n{FFFFFF}Se continuar a quebrar as regras\npoderá ser kickado ou banido.\n\n{0FDC79}Você foi multado em $%i", aviso,MultaValor);
ShowPlayerDialog(playerid,999991,DIALOG_STYLE_MSGBOX," ",avstring,"OK","");
CallRemoteFunction("GivePlayerCash", "ii", playerid,-MultaValor);
return 1;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

forward ProcessarDesAdvertencia(playerid);
public ProcessarDesAdvertencia(playerid)
{
new avstring[400];
CallRemoteFunction("GivePlayerCash", "ii", playerid,MultaAviso[playerid]);
MultaAviso[playerid] = 0;
format(avstring, sizeof(avstring), "{0FDC79}Sua advertência foi um engano da administração\n\n{FFFFFF}Pedimos desculpas pelo inconveniente!\n\nDevolvemos o dinheiro da multa e retiramos a advertência.");
ShowPlayerDialog(playerid,999991,DIALOG_STYLE_MSGBOX," ",avstring,"OK","");
return 1;
}

forward GetggPlayerDeaths(issuerid);
public GetggPlayerDeaths(issuerid)
{
#if defined USE_STATS
return PlayerInfo[issuerid][Kills]++;
#endif
}

forward GetggPlayerKills(playerid);
public GetggPlayerKills(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][Deaths]++;
#endif
}


/////////////////////////////// STATUS DA GM mostra quantos tem no status
forward CorridasGanhasSTATUS(playerid);
public CorridasGanhasSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][Corridas];
#endif
}

forward CorridasGanhas2STATUS(playerid);
public CorridasGanhas2STATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][Corridasg2];
#endif
}


forward CorridasGanhas3STATUS(playerid);
public CorridasGanhas3STATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][Corridasgg3];
#endif
}

forward EVENTOGanhasSTATUS(playerid);
public EVENTOGanhasSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][EVENTOPremiar];
#endif
}

forward EVENTOGanhas2STATUS(playerid);
public EVENTOGanhas2STATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][EVENTOPremiar2];
#endif
}


forward EVENTOGanhas3STATUS(playerid);
public EVENTOGanhas3STATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][EVENTOPremiar3];
#endif
}
/////////////////////////////// STATUS DA GM mostra quantos tem no status

/////////////////////////////// STATUS DA GM mostra quantos tem no status
forward X1GanhosSalvosSTATUS(playerid);
public X1GanhosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1Ganhos];
#endif
}

forward X1PerdidosSalvosSTATUS(playerid);
public X1PerdidosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1Perdidos];
#endif
}

forward X1WGanhosSalvosSTATUS(playerid);
public X1WGanhosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1WGanhos];
#endif
}

forward X1WPerdidosSalvosSTATUS(playerid);
public X1WPerdidosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1WPerdidos];
#endif
}



forward PistolaGanhosSalvosSTATUS(playerid);
public PistolaGanhosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][PistolaGanhos];
#endif
}

forward PistolaPerdidosSalvosSTATUS(playerid);
public  PistolaPerdidosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][PistolaPerdidos];
#endif
}


forward RUNGanhosSalvosSTATUS(playerid);
public RUNGanhosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][RUNGanhos];
#endif
}

forward RUNPerdidosSalvosSTATUS(playerid);
public  RUNPerdidosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][RUNPerdidos];
#endif
}


forward WALKGanhosSalvosSTATUS(playerid);
public WALKGanhosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][WALKGanhos];
#endif
}

forward WALKPerdidosSalvosSTATUS(playerid);
public  WALKPerdidosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][WALKPerdidos];
#endif
}


forward SNPGanhosSalvosSTATUS(playerid);
public SNPGanhosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][SNPGanhos];
#endif
}

forward SNPPerdidosSalvosSTATUS(playerid);
public  SNPPerdidosSalvosSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][SNPPerdidos];
#endif
}


/////////////////////////////// STATUS DA GM mostra quantos tem no status


/////////////////////////////// STATUS DA GM mostra quantos tem no status
forward HeadSalvoSTATUS(playerid);
public HeadSalvoSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][Head];
#endif
}

forward HeadSalvoLevadoSTATUS(playerid);
public HeadSalvoLevadoSTATUS(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][HeadLevado];
#endif
}
/////////////////////////////// STATUS DA GM mostra quantos tem no status
forward HeadSalvo(issuerid);
public HeadSalvo(issuerid)
{
#if defined USE_STATS
return PlayerInfo[issuerid][Head]++;
#endif
}

forward HeadSalvoLevado(playerid);
public HeadSalvoLevado(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][HeadLevado]++;
#endif
}

forward CorridasGanhas(playerid);
public CorridasGanhas(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][Corridas]++;
#endif
}

forward CorridasGanhas2(playerid);
public CorridasGanhas2(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][Corridasg2]++;
#endif
}


forward CorridasGanhas3(playerid);
public CorridasGanhas3(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][Corridasgg3]++;
#endif
}

forward EVENTOGanhas(playerid);
public EVENTOGanhas(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][EVENTOPremiar]++;
#endif
}

forward EVENTOGanhas2(playerid);
public EVENTOGanhas2(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][EVENTOPremiar2]++;
#endif
}


forward EVENTOGanhas3(playerid);
public EVENTOGanhas3(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][EVENTOPremiar3]++;
#endif
}

forward X1GanhosSalvos(killerid);
public X1GanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][X1Ganhos]++;
#endif
}

forward X1PerdidosSalvos(playerid);
public X1PerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1Perdidos]++;
#endif
}

forward X1WGanhosSalvos(killerid);
public X1WGanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][X1WGanhos]++;
#endif
}

forward X1WPerdidosSalvos(playerid);
public X1WPerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1WPerdidos]++;
#endif
}



forward X1PGanhosSalvos(killerid);
public X1PGanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][X1PGanhos]++;
#endif
}

forward X1PPerdidosSalvos(playerid);
public X1PPerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1PPerdidos]++;
#endif
}


forward X1SGanhosSalvos(killerid);
public X1SGanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][X1SGanhos]++;
#endif
}

forward X1SPerdidosSalvos(playerid);
public X1SPerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1SPerdidos]++;
#endif
}


forward X1LGanhosSalvos(killerid);
public X1LGanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][X1LGanhos]++;
#endif
}

forward X1LPerdidosSalvos(playerid);
public X1LPerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][X1LPerdidos]++;
#endif
}



forward PistolaGanhosSalvos(killerid);
public PistolaGanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][PistolaGanhos]++;
#endif
}

forward PistolaPerdidosSalvos(playerid);
public  PistolaPerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][PistolaPerdidos]++;
#endif
}


forward RUNGanhosSalvos(killerid);
public RUNGanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][RUNGanhos]++;
#endif
}

forward RUNPerdidosSalvos(playerid);
public  RUNPerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][RUNPerdidos]++;
#endif
}


forward WALKGanhosSalvos(killerid);
public WALKGanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][WALKGanhos]++;
#endif
}

forward WALKPerdidosSalvos(playerid);
public  WALKPerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][WALKPerdidos]++;
#endif
}


forward SNPGanhosSalvos(killerid);
public SNPGanhosSalvos(killerid)
{
#if defined USE_STATS
return PlayerInfo[killerid][SNPGanhos]++;
#endif
}

forward SNPPerdidosSalvos(playerid);
public  SNPPerdidosSalvos(playerid)
{
#if defined USE_STATS
return PlayerInfo[playerid][SNPPerdidos]++;
#endif
}






// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

strtokbig(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[100];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com

stock PlayerIp(playerid)
{
new ip[16];
GetPlayerIp(playerid, ip, sizeof(ip));
return ip;
}


stock GetPlayerSerial(playerid)//SERIALBAN
{
        new serial[512];
        gpci(playerid,serial,sizeof(serial));
        return serial;
}

stock GetPlayerSerialINI(playerid)
{
        new serialini[512];
        format(serialini,sizeof(serialini),"Serialbans/%s.sb",GetPlayerSerial(playerid));
        return serialini;//SERIALBAN
}

stock sscanf(string[], format[], {Float,_}:...)//SERIALBAN
{//SERIALBAN
        #if defined isnull
                if (isnull(string))
        #else
                if (string[0] == 0 || (string[0] == 1 && string[1] == 0))
        #endif
                {
                        return format[0];
                }
        #pragma tabsize 4
        new
                formatPos = 0,
                stringPos = 0,
                paramPos = 2,
                paramCount = numargs(),
                delim = ' ';
        while (string[stringPos] && string[stringPos] <= ' ')//SERIALBAN
        {
                stringPos++;
        }
        while (paramPos < paramCount && string[stringPos])//SERIALBAN
        {
                switch (format[formatPos++])//SERIALBAN
                {
                        case '\0':
                        {
                                return 0;
                        }
                        case 'i', 'd':
                        {
                                new
                                        neg = 1,
                                        num = 0,
                                        ch = string[stringPos];//SERIALBAN
                                if (ch == '-')
                                {
                                        neg = -1;
                                        ch = string[++stringPos];
                                }
                                do
                                {
                                        stringPos++;
                                        if ('0' <= ch <= '9')
                                        {
                                                num = (num * 10) + (ch - '0');//SERIALBAN
                                        }
                                        else
                                        {
                                                return -1;
                                        }
                                }
                                while ((ch = string[stringPos]) > ' ' && ch != delim);//SERIALBAN
                                setarg(paramPos, 0, num * neg);
                        }
                        case 'h', 'x':
                        {
                                new
                                        num = 0,
                                        ch = string[stringPos];//SERIALBAN
                                do
                                {
                                        stringPos++;
                                        switch (ch)
                                        {
                                                case 'x', 'X':
                                                {
                                                        num = 0;
                                                        continue;
                                                }
                                                case '0' .. '9':
                                                {
                                                        num = (num << 4) | (ch - '0');//SERIALBAN
                                                }
                                                case 'a' .. 'f':
                                                {
                                                        num = (num << 4) | (ch - ('a' - 10));
                                                }
                                                case 'A' .. 'F':
                                                {
                                                        num = (num << 4) | (ch - ('A' - 10));//SERIALBAN
                                                }
                                                default:
                                                {
                                                        return -1;//SERIALBAN
                                                }
                                        }
                                }
                                while ((ch = string[stringPos]) > ' ' && ch != delim);//SERIALBAN
                                setarg(paramPos, 0, num);
                        }
                        case 'c':
                        {
                                setarg(paramPos, 0, string[stringPos++]);//SERIALBAN
                        }
                        case 'f':
                        {

                                new changestr[16], changepos = 0, strpos = stringPos;
                                while(changepos < 16 && string[strpos] && string[strpos] != delim)//SERIALBAN
                                {
                                        changestr[changepos++] = string[strpos++];//SERIALBAN
                                }
                                changestr[changepos] = '\0';
                                setarg(paramPos,0,_:floatstr(changestr));//SERIALBAN
                        }
                        case 'p':
                        {
                                delim = format[formatPos++];//SERIALBAN
                                continue;
                        }
                        case '\'':
                        {
                                new
                                        end = formatPos - 1,
                                        ch;
                                while ((ch = format[++end]) && ch != '\'') {}//SERIALBAN
                                if (!ch)
                                {
                                        return -1;
                                }
                                format[end] = '\0';
                                if ((ch = strfind(string, format[formatPos], false, stringPos)) == -1)//SERIALBAN
                                {
                                        if (format[end + 1])
                                        {
                                                return -1;
                                        }
                                        return 0;
                                }
                                format[end] = '\'';
                                stringPos = ch + (end - formatPos);//SERIALBAN
                                formatPos = end + 1;
                        }
                        case 'u':
                        {
                                new
                                        end = stringPos - 1,
                                        id = 0,
                                        bool:num = true,
                                        ch;
                                while ((ch = string[++end]) && ch != delim)
                                {
                                        if (num)
                                        {
                                                if ('0' <= ch <= '9')
                                                {
                                                        id = (id * 10) + (ch - '0');//SERIALBAN
                                                }
                                                else
                                                {
                                                        num = false;//SERIALBAN
                                                }
                                        }
                                }
                                if (num && IsPlayerConnected(id))
                                {
                                        setarg(paramPos, 0, id);//SERIALBAN
                                }
                                else//SERIALBAN
                                {
                                        #if !defined foreach
                                                #define foreach(%1,%2) for (new %2 = 0; %2 < MAX_PLAYERS; %2++) if (IsPlayerConnected(%2))
                                                #define __SSCANF_FOREACH__
                                        #endif
                                        string[end] = '\0';
                                        num = false;
                                        new
                                                name[MAX_PLAYER_NAME];//SERIALBAN
                                        id = end - stringPos;
                                        foreach (Player, playerid)
                                        {
                                                GetPlayerName(playerid, name, sizeof (name));
                                                if (!strcmp(name, string[stringPos], true, id))
                                                {
                                                        setarg(paramPos, 0, playerid);
                                                        num = true;
                                                        break;
                                                }
                                        }
                                        if (!num)//SERIALBAN
                                        {
                                                setarg(paramPos, 0, INVALID_PLAYER_ID);//SERIALBAN
                                        }//SERIALBAN
                                        string[end] = ch;
                                        #if defined __SSCANF_FOREACH__
                                                #undef foreach
                                                #undef __SSCANF_FOREACH__//SERIALBAN
                                        #endif
                                }
                                stringPos = end;//SERIALBAN
                        }
                        case 's', 'z':
                        {
                                new
                                        i = 0,
                                        ch;
                                if (format[formatPos])
                                {
                                        while ((ch = string[stringPos++]) && ch != delim)//SERIALBAN
                                        {
                                                setarg(paramPos, i++, ch);
                                        }
                                        if (!i)
                                        {
                                                return -1;
                                        }
                                }
                                else
                                {
                                        while ((ch = string[stringPos++]))
                                        {
                                                setarg(paramPos, i++, ch);
                                        }
                                }
                                stringPos--;
                                setarg(paramPos, i, '\0');
                        }
                        default:
                        {
                                continue;//SERIALBAN
                        }
                }
                while (string[stringPos] && string[stringPos] != delim && string[stringPos] > ' ')//SERIALBAN
                {
                        stringPos++;
                }
                while (string[stringPos] && (string[stringPos] == delim || string[stringPos] <= ' '))
                {
                        stringPos++;
                }
                paramPos++;//SERIALBAN
        }
        do
        {
                if ((delim = format[formatPos++]) > ' ')
                {
                        if (delim == '\'')
                        {
                                while ((delim = format[formatPos++]) && delim != '\'') {}//SERIALBAN
                        }
                        else if (delim != 'z')
                        {
                                return delim;
                        }
                }
        }
        while (delim > ' ');
        return 0;//SERIALBAN
}//SERIALBAN

/*
forward BotAvisar(playerid);
public BotAvisar(playerid)
{
new Nome[MAX_PLAYER_NAME];
GetPlayerName(playerid, Nome, sizeof(Nome));
//if(!strcmp(Nome, "[SBN]DEAN[SPN]", true) && strcmp(Nome, "[STT]HARDCORE_RPG", true)&& strcmp(Nome, "[STT]iTune$", true)&& strcmp(Nome, "[STT]Shadow_RPG.exe", true)) return 1;
if(!strcmp(Nome, "[SBN]DEAN[SPN]", true)) return 1;
if(!strcmp(Nome, "NeYMaR.[V.G].", true)) return 1;
if(!strcmp(Nome, "(AYS)Xx_Biyel_xX", true)) return 1;
if(!strcmp(Nome, "NeYMaR.[V.G].", true)) return 1;
if(!strcmp(Nome, "ChuckNorris", true)) return 1;
if(!strcmp(Nome, "(AYS)Xx_Biyel_xX", true)) return 1;
if(!strcmp(Nome, "NeYMaR.[V.G].", true)) return 1;
new str[200];
PlayerInfo[playerid][Warnings]++;
AvisoTick[playerid] = TimeStamp();
if(PlayerInfo[playerid][Warnings] == MAX_WARNINGS) {
format(str, sizeof (str), "Administrador \"ChuckNorris\" kickou \"%s\". (Motivo: Proibido xingamento a mãe/parentesco) (Aviso: %d/%d)",pName(playerid), PlayerInfo[playerid][Warnings], MAX_WARNINGS);
SendClientMessageToAll(grey, str);
SaveToFile("KickLog",str);	Kick(playerid);
return 1;
}else{
if(!strcmp(Nome, "[SBN]DEAN[SPN]", true)) return 1;
if(!strcmp(Nome, "NeYMaR.[V.G].", true)) return 1;
if(!strcmp(Nome, "(AYS)Xx_Biyel_xX", true)) return 1;
if(!strcmp(Nome, "NeYMaR.[V.G].", true)) return 1;
if(!strcmp(Nome, "ChuckNorris", true)) return 1;
if(!strcmp(Nome, "(AYS)Xx_Biyel_xX", true)) return 1;
if(!strcmp(Nome, "NeYMaR.[V.G].", true)) return 1;
ProcessarAdvertencia(playerid,str);
format(str, sizeof (str), "Administrador \"ChuckNorris\" advertiu \"%s\". (Motivo: Proibido xingamento a mãe/parentesco) (Aviso: %d de %d)", pName(playerid), PlayerInfo[playerid][Warnings], MAX_WARNINGS);
return SendClientMessageToAll(yellow, str);
}
}
*/
/*
forward BotAviso(playerid);
public BotAviso(playerid)
{
new aviso[200];
format(aviso, sizeof (aviso), "{00FFFF}ChuckNorris: {FFFFFF}(101): %s seu delicia! Use /report id motivo para reportar o hack", pName(playerid));
return SendClientMessageToAll(yellow, aviso);
}
*/

forward GetPlayerDeaths(playerid);
public GetPlayerDeaths(playerid) return PlayerInfo[playerid][Kills];

forward GetPlayerKills(playerid);
public GetPlayerKills(playerid) return PlayerInfo[playerid][Deaths];

/*
forward GetPlayerHeadShotLevados(playerid);
public GetPlayerHeadShotLevados(playerid) return PlayerInfo[playerid][LastContarHeadShotLevados];

forward GetPlayerHeadShot(playerid);
public GetPlayerHeadShot(playerid) return PlayerInfo[playerid][LastContarHeadShot];
*/
/*
forward Tempo();
public Tempo()
{
    if(StatusHora)
    {
        new Horas,Minutos,Segundos;
        gettime(Horas,Minutos,Segundos);
        SetWorldTime(Horas);
    }
    return 1;
}
*/


// Striker Samp - Tudo Para Seu Servidor SA-MP
// www.strikersamp.blogspot.com
