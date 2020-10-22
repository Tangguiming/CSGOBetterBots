#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <eItems>
#include <csutils>
#include <smlib>
#include <navmesh>
#include <dhooks>

char g_szMap[128];
bool g_bFreezetimeEnd = false;
bool g_bBombPlanted = false;
bool g_bHasThrownNade[MAXPLAYERS+1], g_bHasThrownSmoke[MAXPLAYERS+1], g_bCanAttack[MAXPLAYERS+1], g_bCanThrowSmoke[MAXPLAYERS+1], g_bCanThrowFlash[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iSmoke[MAXPLAYERS+1], g_iPositionToHold[MAXPLAYERS+1], g_iUncrouchChance[MAXPLAYERS+1], g_iUSPChance[MAXPLAYERS+1], g_iM4A1SChance[MAXPLAYERS+1], g_iProfileRankOffset, g_iRndExecute, g_iRoundStartedTime;
float g_fHoldPos[MAXPLAYERS+1][3];
ConVar g_cvPredictionConVar = null;
CNavArea navArea[MAXPLAYERS+1];
Handle g_hBotMoveTo;
Handle g_hLookupBone;
Handle g_hGetBonePosition;
Handle g_hBotAttack;
Handle g_hBotIsVisible;
Handle g_hBotIsBusy;
Handle g_hBotIsHiding;
Handle g_hBotEquipBestWeapon;
Handle g_hBotSetLookAt;
Handle g_hBotBendLineOfSight;
Handle g_hBOTBlindDetour;
Handle g_hBOTSetLookAtDetour;

enum RouteType
{
	DEFAULT_ROUTE = 0,
	FASTEST_ROUTE = 1,
	SAFEST_ROUTE = 2,
	RETREAT_ROUTE = 3,
}

enum PriorityType
{
	PRIORITY_LOW = 0,
	PRIORITY_MEDIUM = 1,
	PRIORITY_HIGH = 2,
	PRIORITY_UNINTERRUPTABLE = 3,
}

static char g_szBotName[][] = {
	//MIBR Players
	"kNgV-",
	"FalleN",
	"fer",
	"TACO",
	"trk",
	//FaZe Players
	"Kjaerbye",
	"broky",
	"NiKo",
	"rain",
	"coldzera",
	//Astralis Players
	"gla1ve",
	"device",
	"es3tag",
	"Magisk",
	"dupreeh",
	//NiP Players
	"twist",
	"Plopski",
	"nawwk",
	"hampus",
	"REZ",
	//C9 Players
	"JT",
	"Sonic",
	"motm",
	"oSee",
	"floppy",
	//G2 Players
	"huNter-",
	"kennyS",
	"nexa",
	"JaCkz",
	"AmaNEk",
	//fnatic Players
	"flusha",
	"JW",
	"KRIMZ",
	"Brollan",
	"Golden",
	//North Players
	"MSL",
	"Lekr0",
	"aizy",
	"cajunb",
	"gade",
	//mouz Players
	"karrigan",
	"chrisJ",
	"Bymas",
	"frozen",
	"ropz",
	//TYLOO Players
	"Summer",
	"Attacker",
	"SLOWLY",
	"somebody",
	"DANK1NG",
	//EG Players
	"stanislaw",
	"tarik",
	"Brehze",
	"Ethan",
	"CeRq",
	//Vireo.Pro Players
	"Hendy",
	"armen",
	"vein",
	"walker",
	"Ryze",
	//Na´Vi Players
	"electronic",
	"s1mple",
	"flamie",
	"Boombl4",
	"Perfecto",
	//Liquid Players
	"Stewie2K",
	"NAF",
	"Grim",
	"ELiGE",
	"Twistzz",
	//AGO Players
	"Furlan",
	"GruBy",
	"dgl",
	"F1KU",
	"leman",
	//ENCE Players
	"suNny",
	"allu",
	"sergej",
	"Aerial",
	"Jamppi",
	//Vitality Players
	"shox",
	"ZywOo",
	"apEX",
	"RpK",
	"Misutaaa",
	//BIG Players
	"tiziaN",
	"syrsoN",
	"XANTARES",
	"tabseN",
	"k1to",
	//FURIA Players
	"yuurih",
	"arT",
	"VINI",
	"KSCERATO",
	"HEN1",
	//c0ntact Players
	"Snappi",
	"ottoNd",
	"smooya",
	"Spinx",
	"EspiranTo",
	//coL Players
	"k0nfig",
	"poizon",
	"oBo",
	"RUSH",
	"blameF",
	//ViCi Players
	"zhokiNg",
	"kaze",
	"aumaN",
	"JamYoung",
	"advent",
	//forZe Players
	"facecrack",
	"xsepower",
	"FL1T",
	"almazer",
	"Jerry",
	//Winstrike Players
	"Lack1",
	"KrizzeN",
	"NickelBack",
	"El1an",
	"bondik",
	//Sprout Players
	"snatchie",
	"dycha",
	"Spiidi",
	"faveN",
	"denis",
	//Heroic Players
	"TeSeS",
	"b0RUP",
	"nikozan",
	"cadiaN",
	"stavn",
	//INTZ Players
	"guZERA",
	"BALEROSTYLE",
	"dukka",
	"paredao",
	"chara",
	//VP Players
	"YEKINDAR",
	"Jame",
	"qikert",
	"SANJI",
	"buster",
	//Apeks Players
	"Marcelious",
	"jkaem",
	"Grusarn",
	"Nasty",
	"dennis",
	//aTTaX Players
	"stfN",
	"slaxz",
	"ScrunK",
	"kressy",
	"mirbit",
	//RNG Players
	"INS",
	"sico",
	"dexter",
	"Hatz",
	"malta",
	//Envy Players
	"Nifty",
	"Thomas",
	"Calyx",
	"MICHU",
	"LEGIJA",
	//Spirit Players
	"mir",
	"iDISBALANCE",
	"somedieyoung",
	"chopper",
	"magixx",
	//LDLC Players
	"afroo",
	"Lambert",
	"hAdji",
	"bodyy",
	"SIXER",
	//GamerLegion Players
	"dobbo",
	"eraa",
	"Zero",
	"RuStY",
	"Adam9130",
	//DIVIZON Players
	"devus",
	"akay",
	"striNg",
	"kryptoN",
	"bLooDyyY",
	//Wolsung Players
	"hyskeee",
	"rAW",
	"Gekons",
	"keen",
	"shield",
	//PDucks Players
	"ChLo",
	"sTaR",
	"wizzem",
	"maxz",
	"Cl34v3rs",
	//HAVU Players
	"ZOREE",
	"sLowi",
	"doto",
	"xseveN",
	"sAw",
	//Lyngby Players
	"birdfromsky",
	"Twinx",
	"Maccen",
	"Raalz",
	"Cabbi",
	//GODSENT Players
	"maden",
	"farlig",
	"kRYSTAL",
	"zehN",
	"STYKO",
	//Nordavind Players
	"tenzki",
	"NaToSaphiX",
	"sense",
	"HS",
	"cromen",
	//SJ Players
	"arvid",
	"LYNXi",
	"SADDYX",
	"KHRN",
	"jemi",
	//Bren Players
	"Papichulo",
	"witz",
	"Pro.",
	"JA",
	"Derek",
	//Giants Players
	"NOPEEj",
	"fox",
	"pr",
	"obj",
	"RIZZ",
	//Lions Players
	"HooXi",
	"acoR",
	"Sjuush",
	"refrezh",
	"roeJ",
	//Riders Players
	"mopoz",
	"shokz",
	"steel",
	"alex*",
	"larsen",
	//OFFSET Players
	"rafaxF",
	"KILLDREAM",
	"EasTor",
	"ZELIN",
	"drifking",
	//eSuba Players
	"NIO",
	"Levi",
	"The eLiVe",
	"Blogg1s",
	"luko",
	//Nexus Players
	"BTN",
	"XELLOW",
	"SEMINTE",
	"iM",
	"sXe",
	//PACT Players
	"darko",
	"lunAtic",
	"Goofy",
	"MINISE",
	"Sobol",
	//Heretics Players
	"Python",
	"Maka",
	"xms",
	"kioShiMa",
	"Lucky",
	//Nemiga Players
	"speed4k",
	"mds",
	"lollipop21k",
	"Jyo",
	"boX",
	//pro100 Players
	"dimasick",
	"WorldEdit",
	"pipsoN",
	"wayLander",
	"AiyvaN",
	//YaLLa Players
	"Remind",
	"eku",
	"Kheops",
	"Senpai",
	"Lyhn",
	//Yeah Players
	"tatazin",
	"RCF",
	"f4stzin",
	"Swisher",
	"dumau",
	//Singularity Players
	"Casle",
	"notaN",
	"Remoy",
	"TOBIZ",
	"Celrate",
	//DETONA Players
	"nak",
	"piria",
	"v$m",
	"Lucaozy",
	"zevy",
	//Infinity Players
	"k1Nky",
	"tor1towOw",
	"spamzzy",
	"chuti",
	"points",
	//Isurus Players
	"JonY BoY",
	"Noktse",
	"Reversive",
	"decov9jse",
	"caike",
	//paiN Players
	"PKL",
	"saffee",
	"NEKIZ",
	"biguzera",
	"hardzao",
	//Sharks Players
	"supLex",
	"jnt",
	"leo_drunky",
	"exit",
	"Luken",
	//One Players
	"prt",
	"Maluk3",
	"malbsMd",
	"pesadelo",
	"b4rtiN",
	//W7M Players
	"skullz",
	"raafa",
	"Tuurtle",
	"pancc",
	"realziN",
	//Avant Players
	"BL1TZ",
	"sterling",
	"apoc",
	"ofnu",
	"HaZR",
	//Chiefs Players
	"HUGHMUNGUS",
	"Vexite",
	"apocdud",
	"zeph",
	"soju_j",
	//ORDER Players
	"J1rah",
	"aliStair",
	"Rickeh",
	"USTILO",
	"Valiance",
	//SKADE Players
	"Duplicate",
	"dennyslaw",
	"Oxygen",
	"Rainwaker",
	"SPELLAN",
	//Paradox Players
	"rbz",
	"Versa",
	"ekul",
	"bedonka",
	"dangeR",
	//Beyond Players
	"MAIROLLS",
	"Olivia",
	"Kntz",
	"stk",
	"qqGod",
	//BOOM Players
	"chelo",
	"yeL",
	"shz",
	"boltz",
	"felps",
	//NASR Players
	"proxyyb",
	"Real1ze",
	"BOROS",
	"Dementor",
	"Just1ce",
	//Revolution Players
	"Rambutan",
	"Fog",
	"Tee",
	"Jaybk",
	"kun",
	//SHIFT Players
	"Young KillerS",
	"Kishi",
	"tozz",
	"huyhart",
	"Imcarnus",
	//nxl Players
	"soifong",
	"Foscmorc",
	"frgd[ibtJ]",
	"Lmemore",
	"xera",
	//LLL Players
	"simix",
	"Stev0se",
	"ritchiEE",
	"rilax",
	"FASHR",
	//Energy Players
	"pnd",
	"disTroiT",
	"Lichl0rd",
	"Tiaantije",
	"mango",
	//Furious Players
	"nbl",
	"tom1",
	"Owensinho",
	"iKrystal",
	"pablek",
	//GroundZero Players
	"BURNRUOk",
	"Laes",
	"Llamas",
	"Noobster",
	"Mayker",
	//AVEZ Players
	"byali",
	"Markoś",
	"tudsoN",
	"Kylar",
	"nawrot",
	//GTZ Players
	"StepA",
	"snapy",
	"slaxx",
	"Dante",
	"fakes2",
	//x6tence Players
	"Queenix",
	"zEVES",
	"maNkz",
	"mertz",
	"Nodios",
	//K23 Players
	"neaLaN",
	"mou",
	"n0rb3r7",
	"kade0",
	"Keoz",
	//Goliath Players
	"massacRe",
	"Dweezil",
	"adM",
	"ELUSIVE",
	"ZipZip",
	//Secret Players
	"juanflatroo",
	"smF",
	"PERCY",
	"sinnopsyy",
	"anarkez",
	//UOL Players
	"crisby",
	"kzy",
	"Andyy",
	"JDC",
	"P4TriCK",
	//RADIX Players
	"mrhui",
	"joss",
	"brky",
	"entz",
	"eZo",
	//Illuminar Players
	"Vegi",
	"Snax",
	"mouz",
	"reatz",
	"phr",
	//Queso Players
	"TheClaran",
	"thinkii",
	"HUMANZ",
	"mik",
	"Yaba",
	//IG Players
	"bottle",
	"DeStRoYeR",
	"flying",
	"Viva",
	"XiaosaGe",
	//HR Players
	"kAliNkA",
	"jR",
	"Flarich",
	"ProbLeM",
	"JIaYm",
	//Dice Players
	"XpG",
	"nonick",
	"Kan4",
	"Polox",
	"Djoko",
	//PlanetKey Players
	"LapeX",
	"Printek",
	"glaVed",
	"ND",
	"impulsG",
	//Vexed Players
	"dox",
	"shyyne",
	"leafy",
	"shateri",
	"volt",
	//HLE Players
	"d1Ledez",
	"DrobnY",
	"Raijin",
	"Forester",
	"svyat",
	//Gambit Players
	"nafany",
	"sh1ro",
	"interz",
	"Ax1Le",
	"Hobbit",
	//Wisla Players
	"hades",
	"SZPERO",
	"mynio",
	"ponczek",
	"jedqr",
	//Imperial Players
	"fnx",
	"zqk",
	"adr",
	"iDk",
	"SHOOWTiME",
	//Pompa Players
	"iso",
	"SKRZYNKA",
	"LAYNER",
	"OLIMP",
	"blacktear5",
	//Unique Players
	"crush",
	"H1te",
	"shalfey",
	"SELLTER",
	"fenvicious",
	//Izako Players
	"Siuhy",
	"szejn",
	"EXUS",
	"avis",
	"TOAO",
	//ATK Players
	"bLazE",
	"MisteM",
	"SloWye",
	"Fadey",
	"Doru",
	//Chaos Players
	"Xeppaa",
	"vanity",
	"leaf",
	"MarKE",
	"Jonji",
	//Wings Players
	"ChildKing",
	"lan",
	"MarT1n",
	"DD",
	"gas",
	//Lynn Players
	"XG",
	"mitsuha",
	"Aree",
	"EXPRO",
	"XinKoiNg",
	//Triumph Players
	"Shakezullah",
	"Junior",
	"ryann",
	"penny",
	"moose",
	//FATE Players
	"blocker",
	"Patrick",
	"harn",
	"Mar",
	"niki1",
	//Canids Players
	"DeStiNy",
	"nythonzinho",
	"heat",
	"latto",
	"KHTEX",
	//ESPADA Players
	"Patsanchick",
	"degster",
	"FinigaN",
	"S0tF1k",
	"Dima",
	//OG Players
	"NBK-",
	"mantuu",
	"Aleksib",
	"valde",
	"ISSAA",
	//Wizards Players
	"Bernard",
	"blackie",
	"kzealos",
	"eneshan",
	"dreez",
	//Tricked Players
	"kiR",
	"kwezz",
	"Luckyv1",
	"sycrone",
	"PR1mE",
	//Gen.G Players
	"autimatic",
	"koosta",
	"daps",
	"s0m",
	"BnTeT",
	//Endpoint Players
	"Surreal",
	"CRUC1AL",
	"MiGHTYMAX",
	"robiin",
	"flameZ",
	//sAw Players
	"arki",
	"stadodo",
	"JUST",
	"MUTiRiS",
	"rmn",
	//DIG Players
	"H4RR3",
	"hallzerk",
	"f0rest",
	"friberg",
	"HEAP",
	//D13 Players
	"Tamiraarita",
	"hasteka",
	"shinobi",
	"sK0R",
	"ANNIHILATION",
	//ZIGMA Players
	"NIFFY",
	"Reality",
	"JUSTCAUSE",
	"PPOverdose",
	"RoLEX",
	//Ambush Players
	"Inzta",
	"Ryxxo",
	"zeq",
	"Typos",
	"IceBerg",
	//KOVA Players
	"pietola",
	"spargo",
	"uli",
	"peku",
	"Twixie",
	//eXploit Players
	"pizituh",
	"BuJ",
	"sark",
	"renatoohaxx",
	"BLOODZ",
	//AGF Players
	"fr0slev",
	"Kristou",
	"netrick",
	"TMB",
	"Lukki",
	//GameAgents Players
	"markk",
	"renne",
	"s0und",
	"regali",
	"smekk-",
	//Keyd Players
	"bnc",
	"mawth",
	"tifa",
	"jota",
	"puni",
	//Epsilon Players
	"ALEXJ",
	"smogger",
	"Celebrations",
	"Masti",
	"Blytz",
	//TIGER Players
	"erkaSt",
	"nin9",
	"dobu",
	"kabal",
	"rate",
	//LEISURE Players
	"stefank0k0",
	"BischeR",
	"farmaG",
	"FabeeN",
	"bustrex",
	//PENTA Players
	"pdy",
	"red",
	"s1n",
	"xenn",
	"skyye",
	//FTW Players
	"sh1zlEE",
	"Jaepe",
	"brA",
	"plat",
	"Cunha",
	//Titans Players
	"doublemagic",
	"KalubeR",
	"rafftu",
	"sarenii",
	"viltrex",
	//9INE Players
	"CyderX",
	"xfl0ud",
	"qRaxs",
	"Izzy",
	"QutionerX",
	//QBF Players
	"JACKPOT",
	"Quantium",
	"Kas9k",
	"hiji",
	"lesswill",
	//Tigers Players
	"MAXX",
	"Lastík",
	"zyored",
	"wEAMO",
	"manguss",
	//9z Players
	"dgt",
	"try",
	"maxujas",
	"bit",
	"meyern",
	//Malvinas Players
	"ABM",
	"fakzwall",
	"minimal",
	"kary",
	"rushardo",
	//Sinister5 Players
	"zerOchaNce",
	"FreakY",
	"deviaNt",
	"Lately",
	"slayeRyEyE",
	//SINNERS Players
	"ZEDKO",
	"CaNNiE",
	"SHOCK",
	"beastik",
	"NEOFRAG",
	//Impact Players
	"DaneJoris",
	"JoJo",
	"ERIC",
	"Koalanoob",
	"insane",
	//ERN Players
	"j1NZO",
	"preet",
	"ReacTioNNN",
	"FreeZe",
	"S3NSEY",
	//BL4ZE Players
	"Rossi",
	"Marzil",
	"SkRossi",
	"Raph",
	"cara",
	//Global Players
	"HellrangeR",
	"Karam1L",
	"hellff",
	"DEATHMAKER",
	"Lightningfast",
	//Conquer Players
	"NiNLeX",
	"RONDE",
	"S1rva",
	"jelo",
	"KonZero",
	//Rooster Players
	"DannyG",
	"nettik",
	"chelleos",
	"ADK",
	"asap",
	//Flames Players
	"nicoodoz",
	"AcilioN",
	"Basso",
	"Jabbi",
	"Daffu",
	//Baecon Players
	"emp",
	"vts",
	"kst",
	"whatz",
	"shellzi",
	//KPI Players
	"pounh",
	"SAYN",
	"Aaron",
	"Butters",
	"ztr",
	//hREDS Players
	"eDi",
	"oopee",
	"VORMISTO",
	"Samppa",
	"xartE",
	//Lemondogs Players
	"xelos",
	"kaktus",
	"hemzk9",
	"Mann3n",
	"gamersdont",
	//Alpha Players
	"Medi",
	"dez1per",
	"LeguliaS",
	"NolderN",
	"fakeZ",
	//CeX Players
	"JackB",
	"Impact",
	"RezzeD",
	"fluFFS",
	"ifan"
};
 
public Plugin myinfo =
{
	name = "BOT Stuff",
	author = "manico",
	description = "Improves bots and does other things.",
	version = "1.0",
	url = "http://steamcommunity.com/id/manico001"
};

public void OnPluginStart()
{
	HookEventEx("player_spawn", OnPlayerSpawn);
	HookEventEx("round_start", OnRoundStart);
	HookEventEx("round_freeze_end", OnFreezetimeEnd);
	HookEventEx("bomb_planted", OnBombPlanted);
	HookEventEx("bomb_defused", OnBombDefusedOrExploded);
	HookEventEx("bomb_exploded", OnBombDefusedOrExploded);
	
	g_cvPredictionConVar = FindConVar("weapon_recoil_scale");
	
	LoadSDK();
	LoadDetours();
	
	RegConsoleCmd("team_nip", Team_NiP);
	RegConsoleCmd("team_mibr", Team_MIBR);
	RegConsoleCmd("team_faze", Team_FaZe);
	RegConsoleCmd("team_astralis", Team_Astralis);
	RegConsoleCmd("team_c9", Team_C9);
	RegConsoleCmd("team_g2", Team_G2);
	RegConsoleCmd("team_fnatic", Team_fnatic);
	RegConsoleCmd("team_north", Team_North);
	RegConsoleCmd("team_mouz", Team_mouz);
	RegConsoleCmd("team_tyloo", Team_TYLOO);
	RegConsoleCmd("team_eg", Team_EG);
	RegConsoleCmd("team_vireopro", Team_VireoPro);
	RegConsoleCmd("team_navi", Team_NaVi);
	RegConsoleCmd("team_liquid", Team_Liquid);
	RegConsoleCmd("team_ago", Team_AGO);
	RegConsoleCmd("team_ence", Team_ENCE);
	RegConsoleCmd("team_vitality", Team_Vitality);
	RegConsoleCmd("team_big", Team_BIG);
	RegConsoleCmd("team_furia", Team_FURIA);
	RegConsoleCmd("team_contact", Team_c0ntact);
	RegConsoleCmd("team_col", Team_coL);
	RegConsoleCmd("team_vici", Team_ViCi);
	RegConsoleCmd("team_forze", Team_forZe);
	RegConsoleCmd("team_winstrike", Team_Winstrike);
	RegConsoleCmd("team_sprout", Team_Sprout);
	RegConsoleCmd("team_heroic", Team_Heroic);
	RegConsoleCmd("team_intz", Team_INTZ);
	RegConsoleCmd("team_vp", Team_VP);
	RegConsoleCmd("team_apeks", Team_Apeks);
	RegConsoleCmd("team_attax", Team_aTTaX);
	RegConsoleCmd("team_rng", Team_Renegades);
	RegConsoleCmd("team_envy", Team_Envy);
	RegConsoleCmd("team_spirit", Team_Spirit);
	RegConsoleCmd("team_ldlc", Team_LDLC);
	RegConsoleCmd("team_gamerlegion", Team_GamerLegion);
	RegConsoleCmd("team_divizon", Team_DIVIZON);
	RegConsoleCmd("team_wolsung", Team_Wolsung);
	RegConsoleCmd("team_pducks", Team_PDucks);
	RegConsoleCmd("team_havu", Team_HAVU);
	RegConsoleCmd("team_lyngby", Team_Lyngby);
	RegConsoleCmd("team_godsent", Team_GODSENT);
	RegConsoleCmd("team_nordavind", Team_Nordavind);
	RegConsoleCmd("team_sj", Team_SJ);
	RegConsoleCmd("team_bren", Team_Bren);
	RegConsoleCmd("team_giants", Team_Giants);
	RegConsoleCmd("team_lions", Team_Lions);
	RegConsoleCmd("team_riders", Team_Riders);
	RegConsoleCmd("team_offset", Team_OFFSET);
	RegConsoleCmd("team_esuba", Team_eSuba);
	RegConsoleCmd("team_nexus", Team_Nexus);
	RegConsoleCmd("team_pact", Team_PACT);
	RegConsoleCmd("team_heretics", Team_Heretics);
	RegConsoleCmd("team_nemiga", Team_Nemiga);
	RegConsoleCmd("team_pro100", Team_pro100);
	RegConsoleCmd("team_yalla", Team_YaLLa);
	RegConsoleCmd("team_yeah", Team_Yeah);
	RegConsoleCmd("team_singularity", Team_Singularity);
	RegConsoleCmd("team_detona", Team_DETONA);
	RegConsoleCmd("team_infinity", Team_Infinity);
	RegConsoleCmd("team_isurus", Team_Isurus);
	RegConsoleCmd("team_pain", Team_paiN);
	RegConsoleCmd("team_sharks", Team_Sharks);
	RegConsoleCmd("team_one", Team_One);
	RegConsoleCmd("team_w7m", Team_W7M);
	RegConsoleCmd("team_avant", Team_Avant);
	RegConsoleCmd("team_chiefs", Team_Chiefs);
	RegConsoleCmd("team_order", Team_ORDER);
	RegConsoleCmd("team_skade", Team_SKADE);
	RegConsoleCmd("team_paradox", Team_Paradox);
	RegConsoleCmd("team_beyond", Team_Beyond);
	RegConsoleCmd("team_boom", Team_BOOM);
	RegConsoleCmd("team_nasr", Team_NASR);
	RegConsoleCmd("team_revolution", Team_Revolution);
	RegConsoleCmd("team_shift", Team_SHIFT);
	RegConsoleCmd("team_nxl", Team_nxl);
	RegConsoleCmd("team_lll", Team_LLL);
	RegConsoleCmd("team_energy", Team_energy);
	RegConsoleCmd("team_furious", Team_Furious);
	RegConsoleCmd("team_groundzero", Team_GroundZero);
	RegConsoleCmd("team_avez", Team_AVEZ);
	RegConsoleCmd("team_gtz", Team_GTZ);
	RegConsoleCmd("team_x6tence", Team_x6tence);
	RegConsoleCmd("team_k23", Team_K23);
	RegConsoleCmd("team_goliath", Team_Goliath);
	RegConsoleCmd("team_secret", Team_Secret);
	RegConsoleCmd("team_uol", Team_UOL);
	RegConsoleCmd("team_radix", Team_RADIX);
	RegConsoleCmd("team_illuminar", Team_Illuminar);
	RegConsoleCmd("team_queso", Team_Queso);
	RegConsoleCmd("team_ig", Team_IG);
	RegConsoleCmd("team_hr", Team_HR);
	RegConsoleCmd("team_dice", Team_Dice);
	RegConsoleCmd("team_planetkey", Team_PlanetKey);
	RegConsoleCmd("team_vexed", Team_Vexed);
	RegConsoleCmd("team_hle", Team_HLE);
	RegConsoleCmd("team_gambit", Team_Gambit);
	RegConsoleCmd("team_wisla", Team_Wisla);
	RegConsoleCmd("team_imperial", Team_Imperial);
	RegConsoleCmd("team_pompa", Team_Pompa);
	RegConsoleCmd("team_Unique", Team_Unique);
	RegConsoleCmd("team_izako", Team_Izako);
	RegConsoleCmd("team_atk", Team_ATK);
	RegConsoleCmd("team_chaos", Team_Chaos);
	RegConsoleCmd("team_wings", Team_Wings);
	RegConsoleCmd("team_lynn", Team_Lynn);
	RegConsoleCmd("team_triumph", Team_Triumph);
	RegConsoleCmd("team_fate", Team_FATE);
	RegConsoleCmd("team_canids", Team_Canids);
	RegConsoleCmd("team_espada", Team_ESPADA);
	RegConsoleCmd("team_og", Team_OG);
	RegConsoleCmd("team_wizards", Team_Wizards);
	RegConsoleCmd("team_tricked", Team_Tricked);
	RegConsoleCmd("team_geng", Team_GenG);
	RegConsoleCmd("team_endpoint", Team_Endpoint);
	RegConsoleCmd("team_saw", Team_sAw);
	RegConsoleCmd("team_dig", Team_DIG);
	RegConsoleCmd("team_d13", Team_D13);
	RegConsoleCmd("team_zigma", Team_ZIGMA);
	RegConsoleCmd("team_ambush", Team_Ambush);
	RegConsoleCmd("team_kova", Team_KOVA);
	RegConsoleCmd("team_exploit", Team_eXploit);
	RegConsoleCmd("team_agf", Team_AGF);
	RegConsoleCmd("team_gameagents", Team_GameAgents);
	RegConsoleCmd("team_keyd", Team_Keyd);
	RegConsoleCmd("team_epsilon", Team_Epsilon);
	RegConsoleCmd("team_tiger", Team_TIGER);
	RegConsoleCmd("team_leisure", Team_LEISURE);
	RegConsoleCmd("team_penta", Team_PENTA);
	RegConsoleCmd("team_ftw", Team_FTW);
	RegConsoleCmd("team_titans", Team_Titans);
	RegConsoleCmd("team_9ine", Team_9INE);
	RegConsoleCmd("team_qbf", Team_QBF);
	RegConsoleCmd("team_tigers", Team_Tigers);
	RegConsoleCmd("team_9z", Team_9z);
	RegConsoleCmd("team_malvinas", Team_Malvinas);
	RegConsoleCmd("team_sinister5", Team_Sinister5);
	RegConsoleCmd("team_sinners", Team_SINNERS);
	RegConsoleCmd("team_impact", Team_Impact);
	RegConsoleCmd("team_ern", Team_ERN);
	RegConsoleCmd("team_bl4ze", Team_BL4ZE);
	RegConsoleCmd("team_global", Team_Global);
	RegConsoleCmd("team_conquer", Team_Conquer);
	RegConsoleCmd("team_rooster", Team_Rooster);
	RegConsoleCmd("team_flames", Team_Flames);
	RegConsoleCmd("team_baecon", Team_Baecon);
	RegConsoleCmd("team_kpi", Team_KPI);
	RegConsoleCmd("team_hreds", Team_hREDS);
	RegConsoleCmd("team_lemondogs", Team_Lemondogs);
	RegConsoleCmd("team_alpha", Team_Alpha);
	RegConsoleCmd("team_cex", Team_CeX);
}

public Action Team_NiP(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "twist");
		ServerCommand("bot_add_ct %s", "hampus");
		ServerCommand("bot_add_ct %s", "nawwk");
		ServerCommand("bot_add_ct %s", "Plopski");
		ServerCommand("bot_add_ct %s", "REZ");
		ServerCommand("mp_teamlogo_1 nip");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "twist");
		ServerCommand("bot_add_t %s", "hampus");
		ServerCommand("bot_add_t %s", "nawwk");
		ServerCommand("bot_add_t %s", "Plopski");
		ServerCommand("bot_add_t %s", "REZ");
		ServerCommand("mp_teamlogo_2 nip");
	}
	
	return Plugin_Handled;
}

public Action Team_MIBR(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kNgV-");
		ServerCommand("bot_add_ct %s", "FalleN");
		ServerCommand("bot_add_ct %s", "fer");
		ServerCommand("bot_add_ct %s", "TACO");
		ServerCommand("bot_add_ct %s", "trk");
		ServerCommand("mp_teamlogo_1 mibr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kNgV-");
		ServerCommand("bot_add_t %s", "FalleN");
		ServerCommand("bot_add_t %s", "fer");
		ServerCommand("bot_add_t %s", "TACO");
		ServerCommand("bot_add_t %s", "trk");
		ServerCommand("mp_teamlogo_2 mibr");
	}
	
	return Plugin_Handled;
}

public Action Team_FaZe(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Kjaerbye");
		ServerCommand("bot_add_ct %s", "broky");
		ServerCommand("bot_add_ct %s", "NiKo");
		ServerCommand("bot_add_ct %s", "rain");
		ServerCommand("bot_add_ct %s", "coldzera");
		ServerCommand("mp_teamlogo_1 faze");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Kjaerbye");
		ServerCommand("bot_add_t %s", "broky");
		ServerCommand("bot_add_t %s", "NiKo");
		ServerCommand("bot_add_t %s", "rain");
		ServerCommand("bot_add_t %s", "coldzera");
		ServerCommand("mp_teamlogo_2 faze");
	}
	
	return Plugin_Handled;
}

public Action Team_Astralis(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "gla1ve");
		ServerCommand("bot_add_ct %s", "device");
		ServerCommand("bot_add_ct %s", "es3tag");
		ServerCommand("bot_add_ct %s", "Magisk");
		ServerCommand("bot_add_ct %s", "dupreeh");
		ServerCommand("mp_teamlogo_1 astr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "gla1ve");
		ServerCommand("bot_add_t %s", "device");
		ServerCommand("bot_add_t %s", "es3tag");
		ServerCommand("bot_add_t %s", "Magisk");
		ServerCommand("bot_add_t %s", "dupreeh");
		ServerCommand("mp_teamlogo_2 astr");
	}
	
	return Plugin_Handled;
}

public Action Team_C9(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JT");
		ServerCommand("bot_add_ct %s", "Sonic");
		ServerCommand("bot_add_ct %s", "motm");
		ServerCommand("bot_add_ct %s", "oSee");
		ServerCommand("bot_add_ct %s", "floppy");
		ServerCommand("mp_teamlogo_1 c9");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JT");
		ServerCommand("bot_add_t %s", "Sonic");
		ServerCommand("bot_add_t %s", "motm");
		ServerCommand("bot_add_t %s", "oSee");
		ServerCommand("bot_add_t %s", "floppy");
		ServerCommand("mp_teamlogo_2 c9");
	}
	
	return Plugin_Handled;
}

public Action Team_G2(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "huNter-");
		ServerCommand("bot_add_ct %s", "kennyS");
		ServerCommand("bot_add_ct %s", "nexa");
		ServerCommand("bot_add_ct %s", "JaCkz");
		ServerCommand("bot_add_ct %s", "AmaNEk");
		ServerCommand("mp_teamlogo_1 g2");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "huNter-");
		ServerCommand("bot_add_t %s", "kennyS");
		ServerCommand("bot_add_t %s", "nexa");
		ServerCommand("bot_add_t %s", "JaCkz");
		ServerCommand("bot_add_t %s", "AmaNEk");
		ServerCommand("mp_teamlogo_2 g2");
	}
	
	return Plugin_Handled;
}

public Action Team_fnatic(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "flusha");
		ServerCommand("bot_add_ct %s", "JW");
		ServerCommand("bot_add_ct %s", "KRIMZ");
		ServerCommand("bot_add_ct %s", "Brollan");
		ServerCommand("bot_add_ct %s", "Golden");
		ServerCommand("mp_teamlogo_1 fnatic");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "flusha");
		ServerCommand("bot_add_t %s", "JW");
		ServerCommand("bot_add_t %s", "KRIMZ");
		ServerCommand("bot_add_t %s", "Brollan");
		ServerCommand("bot_add_t %s", "Golden");
		ServerCommand("mp_teamlogo_2 fnatic");
	}
	
	return Plugin_Handled;
}

public Action Team_North(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MSL");
		ServerCommand("bot_add_ct %s", "Lekr0");
		ServerCommand("bot_add_ct %s", "aizy");
		ServerCommand("bot_add_ct %s", "cajunb");
		ServerCommand("bot_add_ct %s", "gade");
		ServerCommand("mp_teamlogo_1 north");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MSL");
		ServerCommand("bot_add_t %s", "Lekr0");
		ServerCommand("bot_add_t %s", "aizy");
		ServerCommand("bot_add_t %s", "cajunb");
		ServerCommand("bot_add_t %s", "gade");
		ServerCommand("mp_teamlogo_2 north");
	}
	
	return Plugin_Handled;
}

public Action Team_mouz(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "karrigan");
		ServerCommand("bot_add_ct %s", "chrisJ");
		ServerCommand("bot_add_ct %s", "Bymas");
		ServerCommand("bot_add_ct %s", "frozen");
		ServerCommand("bot_add_ct %s", "ropz");
		ServerCommand("mp_teamlogo_1 mss");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "karrigan");
		ServerCommand("bot_add_t %s", "chrisJ");
		ServerCommand("bot_add_t %s", "Bymas");
		ServerCommand("bot_add_t %s", "frozen");
		ServerCommand("bot_add_t %s", "ropz");
		ServerCommand("mp_teamlogo_2 mss");
	}
	
	return Plugin_Handled;
}

public Action Team_TYLOO(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Summer");
		ServerCommand("bot_add_ct %s", "Attacker");
		ServerCommand("bot_add_ct %s", "SLOWLY");
		ServerCommand("bot_add_ct %s", "somebody");
		ServerCommand("bot_add_ct %s", "DANK1NG");
		ServerCommand("mp_teamlogo_1 tyl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Summer");
		ServerCommand("bot_add_t %s", "Attacker");
		ServerCommand("bot_add_t %s", "SLOWLY");
		ServerCommand("bot_add_t %s", "somebody");
		ServerCommand("bot_add_t %s", "DANK1NG");
		ServerCommand("mp_teamlogo_2 tyl");
	}
	
	return Plugin_Handled;
}

public Action Team_EG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stanislaw");
		ServerCommand("bot_add_ct %s", "tarik");
		ServerCommand("bot_add_ct %s", "Brehze");
		ServerCommand("bot_add_ct %s", "Ethan");
		ServerCommand("bot_add_ct %s", "CeRq");
		ServerCommand("mp_teamlogo_1 eg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stanislaw");
		ServerCommand("bot_add_t %s", "tarik");
		ServerCommand("bot_add_t %s", "Brehze");
		ServerCommand("bot_add_t %s", "Ethan");
		ServerCommand("bot_add_t %s", "CeRq");
		ServerCommand("mp_teamlogo_2 eg");
	}
	
	return Plugin_Handled;
}

public Action Team_VireoPro(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Hendy");
		ServerCommand("bot_add_ct %s", "armen");
		ServerCommand("bot_add_ct %s", "vein");
		ServerCommand("bot_add_ct %s", "walker");
		ServerCommand("bot_add_ct %s", "Ryze");
		ServerCommand("mp_teamlogo_1 vireo");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Hendy");
		ServerCommand("bot_add_t %s", "armen");
		ServerCommand("bot_add_t %s", "vein");
		ServerCommand("bot_add_t %s", "walker");
		ServerCommand("bot_add_t %s", "Ryze");
		ServerCommand("mp_teamlogo_2 vireo");
	}
	
	return Plugin_Handled;
}

public Action Team_NaVi(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "electronic");
		ServerCommand("bot_add_ct %s", "s1mple");
		ServerCommand("bot_add_ct %s", "flamie");
		ServerCommand("bot_add_ct %s", "Boombl4");
		ServerCommand("bot_add_ct %s", "Perfecto");
		ServerCommand("mp_teamlogo_1 navi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "electronic");
		ServerCommand("bot_add_t %s", "s1mple");
		ServerCommand("bot_add_t %s", "flamie");
		ServerCommand("bot_add_t %s", "Boombl4");
		ServerCommand("bot_add_t %s", "Perfecto");
		ServerCommand("mp_teamlogo_2 navi");
	}
	
	return Plugin_Handled;
}

public Action Team_Liquid(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Stewie2K");
		ServerCommand("bot_add_ct %s", "NAF");
		ServerCommand("bot_add_ct %s", "Grim");
		ServerCommand("bot_add_ct %s", "ELiGE");
		ServerCommand("bot_add_ct %s", "Twistzz");
		ServerCommand("mp_teamlogo_1 liq");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Stewie2K");
		ServerCommand("bot_add_t %s", "NAF");
		ServerCommand("bot_add_t %s", "Grim");
		ServerCommand("bot_add_t %s", "ELiGE");
		ServerCommand("bot_add_t %s", "Twistzz");
		ServerCommand("mp_teamlogo_2 liq");
	}
	
	return Plugin_Handled;
}

public Action Team_AGO(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Furlan");
		ServerCommand("bot_add_ct %s", "GruBy");
		ServerCommand("bot_add_ct %s", "dgl");
		ServerCommand("bot_add_ct %s", "F1KU");
		ServerCommand("bot_add_ct %s", "leman");
		ServerCommand("mp_teamlogo_1 ago");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Furlan");
		ServerCommand("bot_add_t %s", "GruBy");
		ServerCommand("bot_add_t %s", "dgl");
		ServerCommand("bot_add_t %s", "F1KU");
		ServerCommand("bot_add_t %s", "leman");
		ServerCommand("mp_teamlogo_2 ago");
	}
	
	return Plugin_Handled;
}

public Action Team_ENCE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "suNny");
		ServerCommand("bot_add_ct %s", "allu");
		ServerCommand("bot_add_ct %s", "sergej");
		ServerCommand("bot_add_ct %s", "Aerial");
		ServerCommand("bot_add_ct %s", "Jamppi");
		ServerCommand("mp_teamlogo_1 enc");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "suNny");
		ServerCommand("bot_add_t %s", "allu");
		ServerCommand("bot_add_t %s", "sergej");
		ServerCommand("bot_add_t %s", "Aerial");
		ServerCommand("bot_add_t %s", "Jamppi");
		ServerCommand("mp_teamlogo_2 enc");
	}
	
	return Plugin_Handled;
}

public Action Team_Vitality(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "shox");
		ServerCommand("bot_add_ct %s", "ZywOo");
		ServerCommand("bot_add_ct %s", "apEX");
		ServerCommand("bot_add_ct %s", "RpK");
		ServerCommand("bot_add_ct %s", "Misutaaa");
		ServerCommand("mp_teamlogo_1 vita");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "shox");
		ServerCommand("bot_add_t %s", "ZywOo");
		ServerCommand("bot_add_t %s", "apEX");
		ServerCommand("bot_add_t %s", "RpK");
		ServerCommand("bot_add_t %s", "Misutaaa");
		ServerCommand("mp_teamlogo_2 vita");
	}
	
	return Plugin_Handled;
}

public Action Team_BIG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tiziaN");
		ServerCommand("bot_add_ct %s", "syrsoN");
		ServerCommand("bot_add_ct %s", "XANTARES");
		ServerCommand("bot_add_ct %s", "tabseN");
		ServerCommand("bot_add_ct %s", "k1to");
		ServerCommand("mp_teamlogo_1 big");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tiziaN");
		ServerCommand("bot_add_t %s", "syrsoN");
		ServerCommand("bot_add_t %s", "XANTARES");
		ServerCommand("bot_add_t %s", "tabseN");
		ServerCommand("bot_add_t %s", "k1to");
		ServerCommand("mp_teamlogo_2 big");
	}
	
	return Plugin_Handled;
}

public Action Team_FURIA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "yuurih");
		ServerCommand("bot_add_ct %s", "arT");
		ServerCommand("bot_add_ct %s", "VINI");
		ServerCommand("bot_add_ct %s", "KSCERATO");
		ServerCommand("bot_add_ct %s", "HEN1");
		ServerCommand("mp_teamlogo_1 furi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "yuurih");
		ServerCommand("bot_add_t %s", "arT");
		ServerCommand("bot_add_t %s", "VINI");
		ServerCommand("bot_add_t %s", "KSCERATO");
		ServerCommand("bot_add_t %s", "HEN1");
		ServerCommand("mp_teamlogo_2 furi");
	}
	
	return Plugin_Handled;
}

public Action Team_c0ntact(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Snappi");
		ServerCommand("bot_add_ct %s", "ottoNd");
		ServerCommand("bot_add_ct %s", "smooya");
		ServerCommand("bot_add_ct %s", "Spinx");
		ServerCommand("bot_add_ct %s", "EspiranTo");
		ServerCommand("mp_teamlogo_1 c0n");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Snappi");
		ServerCommand("bot_add_t %s", "ottoNd");
		ServerCommand("bot_add_t %s", "smooya");
		ServerCommand("bot_add_t %s", "Spinx");
		ServerCommand("bot_add_t %s", "EspiranTo");
		ServerCommand("mp_teamlogo_2 c0n");
	}
	
	return Plugin_Handled;
}

public Action Team_coL(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k0nfig");
		ServerCommand("bot_add_ct %s", "poizon");
		ServerCommand("bot_add_ct %s", "oBo");
		ServerCommand("bot_add_ct %s", "RUSH");
		ServerCommand("bot_add_ct %s", "blameF");
		ServerCommand("mp_teamlogo_1 col");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k0nfig");
		ServerCommand("bot_add_t %s", "poizon");
		ServerCommand("bot_add_t %s", "oBo");
		ServerCommand("bot_add_t %s", "RUSH");
		ServerCommand("bot_add_t %s", "blameF");
		ServerCommand("mp_teamlogo_2 col");
	}
	
	return Plugin_Handled;
}

public Action Team_ViCi(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zhokiNg");
		ServerCommand("bot_add_ct %s", "kaze");
		ServerCommand("bot_add_ct %s", "aumaN");
		ServerCommand("bot_add_ct %s", "JamYoung");
		ServerCommand("bot_add_ct %s", "advent");
		ServerCommand("mp_teamlogo_1 vici");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zhokiNg");
		ServerCommand("bot_add_t %s", "kaze");
		ServerCommand("bot_add_t %s", "aumaN");
		ServerCommand("bot_add_t %s", "JamYoung");
		ServerCommand("bot_add_t %s", "advent");
		ServerCommand("mp_teamlogo_2 vici");
	}
	
	return Plugin_Handled;
}

public Action Team_forZe(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "facecrack");
		ServerCommand("bot_add_ct %s", "xsepower");
		ServerCommand("bot_add_ct %s", "FL1T");
		ServerCommand("bot_add_ct %s", "almazer");
		ServerCommand("bot_add_ct %s", "Jerry");
		ServerCommand("mp_teamlogo_1 forz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "facecrack");
		ServerCommand("bot_add_t %s", "xsepower");
		ServerCommand("bot_add_t %s", "FL1T");
		ServerCommand("bot_add_t %s", "almazer");
		ServerCommand("bot_add_t %s", "Jerry");
		ServerCommand("mp_teamlogo_2 forz");
	}
	
	return Plugin_Handled;
}

public Action Team_Winstrike(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Lack1");
		ServerCommand("bot_add_ct %s", "KrizzeN");
		ServerCommand("bot_add_ct %s", "NickelBack");
		ServerCommand("bot_add_ct %s", "El1an");
		ServerCommand("bot_add_ct %s", "bondik");
		ServerCommand("mp_teamlogo_1 win");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Lack1");
		ServerCommand("bot_add_t %s", "KrizzeN");
		ServerCommand("bot_add_t %s", "NickelBack");
		ServerCommand("bot_add_t %s", "El1an");
		ServerCommand("bot_add_t %s", "bondik");
		ServerCommand("mp_teamlogo_2 win");
	}
	
	return Plugin_Handled;
}

public Action Team_Sprout(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "snatchie");
		ServerCommand("bot_add_ct %s", "dycha");
		ServerCommand("bot_add_ct %s", "Spiidi");
		ServerCommand("bot_add_ct %s", "faveN");
		ServerCommand("bot_add_ct %s", "denis");
		ServerCommand("mp_teamlogo_1 spr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "snatchie");
		ServerCommand("bot_add_t %s", "dycha");
		ServerCommand("bot_add_t %s", "Spiidi");
		ServerCommand("bot_add_t %s", "faveN");
		ServerCommand("bot_add_t %s", "denis");
		ServerCommand("mp_teamlogo_2 spr");
	}
	
	return Plugin_Handled;
}

public Action Team_Heroic(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TeSeS");
		ServerCommand("bot_add_ct %s", "b0RUP");
		ServerCommand("bot_add_ct %s", "nikozan");
		ServerCommand("bot_add_ct %s", "cadiaN");
		ServerCommand("bot_add_ct %s", "stavn");
		ServerCommand("mp_teamlogo_1 heroi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TeSeS");
		ServerCommand("bot_add_t %s", "b0RUP");
		ServerCommand("bot_add_t %s", "nikozan");
		ServerCommand("bot_add_t %s", "cadiaN");
		ServerCommand("bot_add_t %s", "stavn");
		ServerCommand("mp_teamlogo_2 heroi");
	}
	
	return Plugin_Handled;
}

public Action Team_INTZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "guZERA");
		ServerCommand("bot_add_ct %s", "BALEROSTYLE");
		ServerCommand("bot_add_ct %s", "dukka");
		ServerCommand("bot_add_ct %s", "paredao");
		ServerCommand("bot_add_ct %s", "chara");
		ServerCommand("mp_teamlogo_1 intz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "guZERA");
		ServerCommand("bot_add_t %s", "BALEROSTYLE");
		ServerCommand("bot_add_t %s", "dukka");
		ServerCommand("bot_add_t %s", "paredao");
		ServerCommand("bot_add_t %s", "chara");
		ServerCommand("mp_teamlogo_2 intz");
	}
	
	return Plugin_Handled;
}

public Action Team_VP(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "YEKINDAR");
		ServerCommand("bot_add_ct %s", "Jame");
		ServerCommand("bot_add_ct %s", "qikert");
		ServerCommand("bot_add_ct %s", "SANJI");
		ServerCommand("bot_add_ct %s", "buster");
		ServerCommand("mp_teamlogo_1 virtus");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "YEKINDAR");
		ServerCommand("bot_add_t %s", "Jame");
		ServerCommand("bot_add_t %s", "qikert");
		ServerCommand("bot_add_t %s", "SANJI");
		ServerCommand("bot_add_t %s", "buster");
		ServerCommand("mp_teamlogo_2 virtus");
	}
	
	return Plugin_Handled;
}

public Action Team_Apeks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Marcelious");
		ServerCommand("bot_add_ct %s", "jkaem");
		ServerCommand("bot_add_ct %s", "Grusarn");
		ServerCommand("bot_add_ct %s", "Nasty");
		ServerCommand("bot_add_ct %s", "dennis");
		ServerCommand("mp_teamlogo_1 ape");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Marcelious");
		ServerCommand("bot_add_t %s", "jkaem");
		ServerCommand("bot_add_t %s", "Grusarn");
		ServerCommand("bot_add_t %s", "Nasty");
		ServerCommand("bot_add_t %s", "dennis");
		ServerCommand("mp_teamlogo_2 ape");
	}
	
	return Plugin_Handled;
}

public Action Team_aTTaX(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stfN");
		ServerCommand("bot_add_ct %s", "slaxz");
		ServerCommand("bot_add_ct %s", "ScrunK");
		ServerCommand("bot_add_ct %s", "kressy");
		ServerCommand("bot_add_ct %s", "mirbit");
		ServerCommand("mp_teamlogo_1 alt");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stfN");
		ServerCommand("bot_add_t %s", "slaxz");
		ServerCommand("bot_add_t %s", "ScrunK");
		ServerCommand("bot_add_t %s", "kressy");
		ServerCommand("bot_add_t %s", "mirbit");
		ServerCommand("mp_teamlogo_2 alt");
	}
	
	return Plugin_Handled;
}

public Action Team_Renegades(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "INS");
		ServerCommand("bot_add_ct %s", "sico");
		ServerCommand("bot_add_ct %s", "dexter");
		ServerCommand("bot_add_ct %s", "Hatz");
		ServerCommand("bot_add_ct %s", "malta");
		ServerCommand("mp_teamlogo_1 ren");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "INS");
		ServerCommand("bot_add_t %s", "sico");
		ServerCommand("bot_add_t %s", "dexter");
		ServerCommand("bot_add_t %s", "Hatz");
		ServerCommand("bot_add_t %s", "malta");
		ServerCommand("mp_teamlogo_2 ren");
	}
	
	return Plugin_Handled;
}

public Action Team_Envy(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Nifty");
		ServerCommand("bot_add_ct %s", "Thomas");
		ServerCommand("bot_add_ct %s", "Calyx");
		ServerCommand("bot_add_ct %s", "MICHU");
		ServerCommand("bot_add_ct %s", "LEGIJA");
		ServerCommand("mp_teamlogo_1 envy");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Nifty");
		ServerCommand("bot_add_t %s", "Thomas");
		ServerCommand("bot_add_t %s", "Calyx");
		ServerCommand("bot_add_t %s", "MICHU");
		ServerCommand("bot_add_t %s", "LEGIJA");
		ServerCommand("mp_teamlogo_2 envy");
	}
	
	return Plugin_Handled;
}

public Action Team_Spirit(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mir");
		ServerCommand("bot_add_ct %s", "iDISBALANCE");
		ServerCommand("bot_add_ct %s", "somedieyoung");
		ServerCommand("bot_add_ct %s", "chopper");
		ServerCommand("bot_add_ct %s", "magixx");
		ServerCommand("mp_teamlogo_1 spir");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mir");
		ServerCommand("bot_add_t %s", "iDISBALANCE");
		ServerCommand("bot_add_t %s", "somedieyoung");
		ServerCommand("bot_add_t %s", "chopper");
		ServerCommand("bot_add_t %s", "magixx");
		ServerCommand("mp_teamlogo_2 spir");
	}
	
	return Plugin_Handled;
}

public Action Team_LDLC(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "afroo");
		ServerCommand("bot_add_ct %s", "Lambert");
		ServerCommand("bot_add_ct %s", "hAdji");
		ServerCommand("bot_add_ct %s", "bodyy");
		ServerCommand("bot_add_ct %s", "SIXER");
		ServerCommand("mp_teamlogo_1 ldl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "afroo");
		ServerCommand("bot_add_t %s", "Lambert");
		ServerCommand("bot_add_t %s", "hAdji");
		ServerCommand("bot_add_t %s", "bodyy");
		ServerCommand("bot_add_t %s", "SIXER");
		ServerCommand("mp_teamlogo_2 ldl");
	}
	
	return Plugin_Handled;
}

public Action Team_GamerLegion(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dobbo");
		ServerCommand("bot_add_ct %s", "eraa");
		ServerCommand("bot_add_ct %s", "Zero");
		ServerCommand("bot_add_ct %s", "RuStY");
		ServerCommand("bot_add_ct %s", "Adam9130");
		ServerCommand("mp_teamlogo_1 glegion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dobbo");
		ServerCommand("bot_add_t %s", "eraa");
		ServerCommand("bot_add_t %s", "Zero");
		ServerCommand("bot_add_t %s", "RuStY");
		ServerCommand("bot_add_t %s", "Adam9130");
		ServerCommand("mp_teamlogo_2 glegion");
	}
	
	return Plugin_Handled;
}

public Action Team_DIVIZON(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "devus");
		ServerCommand("bot_add_ct %s", "akay");
		ServerCommand("bot_add_ct %s", "striNg");
		ServerCommand("bot_add_ct %s", "kryptoN");
		ServerCommand("bot_add_ct %s", "bLooDyyY");
		ServerCommand("mp_teamlogo_1 divi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "devus");
		ServerCommand("bot_add_t %s", "akay");
		ServerCommand("bot_add_t %s", "striNg");
		ServerCommand("bot_add_t %s", "kryptoN");
		ServerCommand("bot_add_t %s", "bLooDyyY");
		ServerCommand("mp_teamlogo_2 divi");
	}
	
	return Plugin_Handled;
}

public Action Team_Wolsung(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hyskeee");
		ServerCommand("bot_add_ct %s", "rAW");
		ServerCommand("bot_add_ct %s", "Gekons");
		ServerCommand("bot_add_ct %s", "keen");
		ServerCommand("bot_add_ct %s", "shield");
		ServerCommand("mp_teamlogo_1 wols");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hyskeee");
		ServerCommand("bot_add_t %s", "rAW");
		ServerCommand("bot_add_t %s", "Gekons");
		ServerCommand("bot_add_t %s", "keen");
		ServerCommand("bot_add_t %s", "shield");
		ServerCommand("mp_teamlogo_2 wols");
	}
	
	return Plugin_Handled;
}

public Action Team_PDucks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ChLo");
		ServerCommand("bot_add_ct %s", "sTaR");
		ServerCommand("bot_add_ct %s", "wizzem");
		ServerCommand("bot_add_ct %s", "maxz");
		ServerCommand("bot_add_ct %s", "Cl34v3rs");
		ServerCommand("mp_teamlogo_1 playin");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ChLo");
		ServerCommand("bot_add_t %s", "sTaR");
		ServerCommand("bot_add_t %s", "wizzem");
		ServerCommand("bot_add_t %s", "maxz");
		ServerCommand("bot_add_t %s", "Cl34v3rs");
		ServerCommand("mp_teamlogo_2 playin");
	}
	
	return Plugin_Handled;
}

public Action Team_HAVU(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ZOREE");
		ServerCommand("bot_add_ct %s", "sLowi");
		ServerCommand("bot_add_ct %s", "doto");
		ServerCommand("bot_add_ct %s", "xseveN");
		ServerCommand("bot_add_ct %s", "sAw");
		ServerCommand("mp_teamlogo_1 havu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ZOREE");
		ServerCommand("bot_add_t %s", "sLowi");
		ServerCommand("bot_add_t %s", "doto");
		ServerCommand("bot_add_t %s", "xseveN");
		ServerCommand("bot_add_t %s", "sAw");
		ServerCommand("mp_teamlogo_2 havu");
	}
	
	return Plugin_Handled;
}

public Action Team_Lyngby(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "birdfromsky");
		ServerCommand("bot_add_ct %s", "Twinx");
		ServerCommand("bot_add_ct %s", "Maccen");
		ServerCommand("bot_add_ct %s", "Raalz");
		ServerCommand("bot_add_ct %s", "Cabbi");
		ServerCommand("mp_teamlogo_1 lyng");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "birdfromsky");
		ServerCommand("bot_add_t %s", "Twinx");
		ServerCommand("bot_add_t %s", "Maccen");
		ServerCommand("bot_add_t %s", "Raalz");
		ServerCommand("bot_add_t %s", "Cabbi");
		ServerCommand("mp_teamlogo_2 lyng");
	}
	
	return Plugin_Handled;
}

public Action Team_GODSENT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "maden");
		ServerCommand("bot_add_ct %s", "farlig");
		ServerCommand("bot_add_ct %s", "kRYSTAL");
		ServerCommand("bot_add_ct %s", "zehN");
		ServerCommand("bot_add_ct %s", "STYKO");
		ServerCommand("mp_teamlogo_1 god");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "maden");
		ServerCommand("bot_add_t %s", "farlig");
		ServerCommand("bot_add_t %s", "kRYSTAL");
		ServerCommand("bot_add_t %s", "zehN");
		ServerCommand("bot_add_t %s", "STYKO");
		ServerCommand("mp_teamlogo_2 god");
	}
	
	return Plugin_Handled;
}

public Action Team_Nordavind(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tenzki");
		ServerCommand("bot_add_ct %s", "NaToSaphiX");
		ServerCommand("bot_add_ct %s", "sense");
		ServerCommand("bot_add_ct %s", "HS");
		ServerCommand("bot_add_ct %s", "cromen");
		ServerCommand("mp_teamlogo_1 nord");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tenzki");
		ServerCommand("bot_add_t %s", "NaToSaphiX");
		ServerCommand("bot_add_t %s", "sense");
		ServerCommand("bot_add_t %s", "HS");
		ServerCommand("bot_add_t %s", "cromen");
		ServerCommand("mp_teamlogo_2 nord");
	}
	
	return Plugin_Handled;
}

public Action Team_SJ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "arvid");
		ServerCommand("bot_add_ct %s", "LYNXi");
		ServerCommand("bot_add_ct %s", "SADDYX");
		ServerCommand("bot_add_ct %s", "KHRN");
		ServerCommand("bot_add_ct %s", "jemi");
		ServerCommand("mp_teamlogo_1 sjg");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "arvid");
		ServerCommand("bot_add_t %s", "LYNXi");
		ServerCommand("bot_add_t %s", "SADDYX");
		ServerCommand("bot_add_t %s", "KHRN");
		ServerCommand("bot_add_t %s", "jemi");
		ServerCommand("mp_teamlogo_2 sjg");
	}
	
	return Plugin_Handled;
}

public Action Team_Bren(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Papichulo");
		ServerCommand("bot_add_ct %s", "witz");
		ServerCommand("bot_add_ct %s", "Pro.");
		ServerCommand("bot_add_ct %s", "JA");
		ServerCommand("bot_add_ct %s", "Derek");
		ServerCommand("mp_teamlogo_1 bren");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Papichulo");
		ServerCommand("bot_add_t %s", "witz");
		ServerCommand("bot_add_t %s", "Pro.");
		ServerCommand("bot_add_t %s", "JA");
		ServerCommand("bot_add_t %s", "Derek");
		ServerCommand("mp_teamlogo_2 bren");
	}
	
	return Plugin_Handled;
}

public Action Team_Giants(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NOPEEj");
		ServerCommand("bot_add_ct %s", "fox");
		ServerCommand("bot_add_ct %s", "pr");
		ServerCommand("bot_add_ct %s", "obj");
		ServerCommand("bot_add_ct %s", "RIZZ");
		ServerCommand("mp_teamlogo_1 giant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NOPEEj");
		ServerCommand("bot_add_t %s", "fox");
		ServerCommand("bot_add_t %s", "pr");
		ServerCommand("bot_add_t %s", "obj");
		ServerCommand("bot_add_t %s", "RIZZ");
		ServerCommand("mp_teamlogo_2 giant");
	}
	
	return Plugin_Handled;
}

public Action Team_Lions(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HooXi");
		ServerCommand("bot_add_ct %s", "acoR");
		ServerCommand("bot_add_ct %s", "Sjuush");
		ServerCommand("bot_add_ct %s", "refrezh");
		ServerCommand("bot_add_ct %s", "roeJ");
		ServerCommand("mp_teamlogo_1 lion");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HooXi");
		ServerCommand("bot_add_t %s", "acoR");
		ServerCommand("bot_add_t %s", "Sjuush");
		ServerCommand("bot_add_t %s", "refrezh");
		ServerCommand("bot_add_t %s", "roeJ");
		ServerCommand("mp_teamlogo_2 lion");
	}
	
	return Plugin_Handled;
}

public Action Team_Riders(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mopoz");
		ServerCommand("bot_add_ct %s", "shokz");
		ServerCommand("bot_add_ct %s", "steel");
		ServerCommand("bot_add_ct %s", "\"alex*\"");
		ServerCommand("bot_add_ct %s", "larsen");
		ServerCommand("mp_teamlogo_1 movis");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mopoz");
		ServerCommand("bot_add_t %s", "shokz");
		ServerCommand("bot_add_t %s", "steel");
		ServerCommand("bot_add_t %s", "\"alex*\"");
		ServerCommand("bot_add_t %s", "larsen");
		ServerCommand("mp_teamlogo_2 movis");
	}
	
	return Plugin_Handled;
}

public Action Team_OFFSET(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "rafaxF");
		ServerCommand("bot_add_ct %s", "KILLDREAM");
		ServerCommand("bot_add_ct %s", "EasTor");
		ServerCommand("bot_add_ct %s", "ZELIN");
		ServerCommand("bot_add_ct %s", "drifking");
		ServerCommand("mp_teamlogo_1 offs");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "rafaxF");
		ServerCommand("bot_add_t %s", "KILLDREAM");
		ServerCommand("bot_add_t %s", "EasTor");
		ServerCommand("bot_add_t %s", "ZELIN");
		ServerCommand("bot_add_t %s", "drifking");
		ServerCommand("mp_teamlogo_2 offs");
	}
	
	return Plugin_Handled;
}

public Action Team_eSuba(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NIO");
		ServerCommand("bot_add_ct %s", "Levi");
		ServerCommand("bot_add_ct %s", "\"The eLiVe\"");
		ServerCommand("bot_add_ct %s", "Blogg1s");
		ServerCommand("bot_add_ct %s", "luko");
		ServerCommand("mp_teamlogo_1 esu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NIO");
		ServerCommand("bot_add_t %s", "Levi");
		ServerCommand("bot_add_t %s", "\"The eLiVe\"");
		ServerCommand("bot_add_t %s", "Blogg1s");
		ServerCommand("bot_add_t %s", "luko");
		ServerCommand("mp_teamlogo_2 esu");
	}
	
	return Plugin_Handled;
}

public Action Team_Nexus(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BTN");
		ServerCommand("bot_add_ct %s", "XELLOW");
		ServerCommand("bot_add_ct %s", "SEMINTE");
		ServerCommand("bot_add_ct %s", "iM");
		ServerCommand("bot_add_ct %s", "sXe");
		ServerCommand("mp_teamlogo_1 nex");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BTN");
		ServerCommand("bot_add_t %s", "XELLOW");
		ServerCommand("bot_add_t %s", "SEMINTE");
		ServerCommand("bot_add_t %s", "iM");
		ServerCommand("bot_add_t %s", "sXe");
		ServerCommand("mp_teamlogo_2 nex");
	}
	
	return Plugin_Handled;
}

public Action Team_PACT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "darko");
		ServerCommand("bot_add_ct %s", "lunAtic");
		ServerCommand("bot_add_ct %s", "Goofy");
		ServerCommand("bot_add_ct %s", "MINISE");
		ServerCommand("bot_add_ct %s", "Sobol");
		ServerCommand("mp_teamlogo_1 pact");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "darko");
		ServerCommand("bot_add_t %s", "lunAtic");
		ServerCommand("bot_add_t %s", "Goofy");
		ServerCommand("bot_add_t %s", "MINISE");
		ServerCommand("bot_add_t %s", "Sobol");
		ServerCommand("mp_teamlogo_2 pact");
	}
	
	return Plugin_Handled;
}

public Action Team_Heretics(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Python");
		ServerCommand("bot_add_ct %s", "Maka");
		ServerCommand("bot_add_ct %s", "xms");
		ServerCommand("bot_add_ct %s", "kioShiMa");
		ServerCommand("bot_add_ct %s", "Lucky");
		ServerCommand("mp_teamlogo_1 here");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Python");
		ServerCommand("bot_add_t %s", "Maka");
		ServerCommand("bot_add_t %s", "xms");
		ServerCommand("bot_add_t %s", "kioShiMa");
		ServerCommand("bot_add_t %s", "Lucky");
		ServerCommand("mp_teamlogo_2 here");
	}
	
	return Plugin_Handled;
}

public Action Team_Nemiga(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "speed4k");
		ServerCommand("bot_add_ct %s", "mds");
		ServerCommand("bot_add_ct %s", "lollipop21k");
		ServerCommand("bot_add_ct %s", "Jyo");
		ServerCommand("bot_add_ct %s", "boX");
		ServerCommand("mp_teamlogo_1 nem");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "speed4k");
		ServerCommand("bot_add_t %s", "mds");
		ServerCommand("bot_add_t %s", "lollipop21k");
		ServerCommand("bot_add_t %s", "Jyo");
		ServerCommand("bot_add_t %s", "boX");
		ServerCommand("mp_teamlogo_2 nem");
	}
	
	return Plugin_Handled;
}

public Action Team_pro100(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dimasick");
		ServerCommand("bot_add_ct %s", "WorldEdit");
		ServerCommand("bot_add_ct %s", "pipsoN");
		ServerCommand("bot_add_ct %s", "wayLander");
		ServerCommand("bot_add_ct %s", "AiyvaN");
		ServerCommand("mp_teamlogo_1 pro");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dimasick");
		ServerCommand("bot_add_t %s", "WorldEdit");
		ServerCommand("bot_add_t %s", "pipsoN");
		ServerCommand("bot_add_t %s", "wayLander");
		ServerCommand("bot_add_t %s", "AiyvaN");
		ServerCommand("mp_teamlogo_2 pro");
	}
	
	return Plugin_Handled;
}

public Action Team_YaLLa(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Remind");
		ServerCommand("bot_add_ct %s", "eku");
		ServerCommand("bot_add_ct %s", "Kheops");
		ServerCommand("bot_add_ct %s", "Senpai");
		ServerCommand("bot_add_ct %s", "Lyhn");
		ServerCommand("mp_teamlogo_1 yall");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Remind");
		ServerCommand("bot_add_t %s", "eku");
		ServerCommand("bot_add_t %s", "Kheops");
		ServerCommand("bot_add_t %s", "Senpai");
		ServerCommand("bot_add_t %s", "Lyhn");
		ServerCommand("mp_teamlogo_2 yall");
	}
	
	return Plugin_Handled;
}

public Action Team_Yeah(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tatazin");
		ServerCommand("bot_add_ct %s", "RCF");
		ServerCommand("bot_add_ct %s", "f4stzin");
		ServerCommand("bot_add_ct %s", "Swisher");
		ServerCommand("bot_add_ct %s", "dumau");
		ServerCommand("mp_teamlogo_1 yeah");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tatazin");
		ServerCommand("bot_add_t %s", "RCF");
		ServerCommand("bot_add_t %s", "f4stzin");
		ServerCommand("bot_add_t %s", "Swisher");
		ServerCommand("bot_add_t %s", "dumau");
		ServerCommand("mp_teamlogo_2 yeah");
	}
	
	return Plugin_Handled;
}

public Action Team_Singularity(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Casle");
		ServerCommand("bot_add_ct %s", "notaN");
		ServerCommand("bot_add_ct %s", "Remoy");
		ServerCommand("bot_add_ct %s", "TOBIZ");
		ServerCommand("bot_add_ct %s", "Celrate");
		ServerCommand("mp_teamlogo_1 sing");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Casle");
		ServerCommand("bot_add_t %s", "notaN");
		ServerCommand("bot_add_t %s", "Remoy");
		ServerCommand("bot_add_t %s", "TOBIZ");
		ServerCommand("bot_add_t %s", "Celrate");
		ServerCommand("mp_teamlogo_2 sing");
	}
	
	return Plugin_Handled;
}

public Action Team_DETONA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nak");
		ServerCommand("bot_add_ct %s", "piria");
		ServerCommand("bot_add_ct %s", "v$m");
		ServerCommand("bot_add_ct %s", "Lucaozy");
		ServerCommand("bot_add_ct %s", "zevy");
		ServerCommand("mp_teamlogo_1 deto");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nak");
		ServerCommand("bot_add_t %s", "piria");
		ServerCommand("bot_add_t %s", "v$m");
		ServerCommand("bot_add_t %s", "Lucaozy");
		ServerCommand("bot_add_t %s", "zevy");
		ServerCommand("mp_teamlogo_2 deto");
	}
	
	return Plugin_Handled;
}

public Action Team_Infinity(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k1Nky");
		ServerCommand("bot_add_ct %s", "tor1towOw");
		ServerCommand("bot_add_ct %s", "spamzzy");
		ServerCommand("bot_add_ct %s", "chuti");
		ServerCommand("bot_add_ct %s", "points");
		ServerCommand("mp_teamlogo_1 infi");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k1Nky");
		ServerCommand("bot_add_t %s", "tor1towOw");
		ServerCommand("bot_add_t %s", "spamzzy");
		ServerCommand("bot_add_t %s", "chuti");
		ServerCommand("bot_add_t %s", "points");
		ServerCommand("mp_teamlogo_2 infi");
	}
	
	return Plugin_Handled;
}

public Action Team_Isurus(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JonY BoY");
		ServerCommand("bot_add_ct %s", "Noktse");
		ServerCommand("bot_add_ct %s", "Reversive");
		ServerCommand("bot_add_ct %s", "decov9jse");
		ServerCommand("bot_add_ct %s", "caike");
		ServerCommand("mp_teamlogo_1 isu");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JonY BoY");
		ServerCommand("bot_add_t %s", "Noktse");
		ServerCommand("bot_add_t %s", "Reversive");
		ServerCommand("bot_add_t %s", "decov9jse");
		ServerCommand("bot_add_t %s", "caike");
		ServerCommand("mp_teamlogo_2 isu");
	}
	
	return Plugin_Handled;
}

public Action Team_paiN(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "PKL");
		ServerCommand("bot_add_ct %s", "saffee");
		ServerCommand("bot_add_ct %s", "NEKIZ");
		ServerCommand("bot_add_ct %s", "biguzera");
		ServerCommand("bot_add_ct %s", "hardzao");
		ServerCommand("mp_teamlogo_1 pain");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "PKL");
		ServerCommand("bot_add_t %s", "saffee");
		ServerCommand("bot_add_t %s", "NEKIZ");
		ServerCommand("bot_add_t %s", "biguzera");
		ServerCommand("bot_add_t %s", "hardzao");
		ServerCommand("mp_teamlogo_2 pain");
	}
	
	return Plugin_Handled;
}

public Action Team_Sharks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "supLex");
		ServerCommand("bot_add_ct %s", "jnt");
		ServerCommand("bot_add_ct %s", "leo_drunky");
		ServerCommand("bot_add_ct %s", "exit");
		ServerCommand("bot_add_ct %s", "Luken");
		ServerCommand("mp_teamlogo_1 shark");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "supLex");
		ServerCommand("bot_add_t %s", "jnt");
		ServerCommand("bot_add_t %s", "leo_drunky");
		ServerCommand("bot_add_t %s", "exit");
		ServerCommand("bot_add_t %s", "Luken");
		ServerCommand("mp_teamlogo_2 shark");
	}
	
	return Plugin_Handled;
}

public Action Team_One(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "prt");
		ServerCommand("bot_add_ct %s", "Maluk3");
		ServerCommand("bot_add_ct %s", "malbsMd");
		ServerCommand("bot_add_ct %s", "pesadelo");
		ServerCommand("bot_add_ct %s", "b4rtiN");
		ServerCommand("mp_teamlogo_1 tone");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "prt");
		ServerCommand("bot_add_t %s", "Maluk3");
		ServerCommand("bot_add_t %s", "malbsMd");
		ServerCommand("bot_add_t %s", "pesadelo");
		ServerCommand("bot_add_t %s", "b4rtiN");
		ServerCommand("mp_teamlogo_2 tone");
	}
	
	return Plugin_Handled;
}

public Action Team_W7M(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "skullz");
		ServerCommand("bot_add_ct %s", "raafa");
		ServerCommand("bot_add_ct %s", "Tuurtle");
		ServerCommand("bot_add_ct %s", "pancc");
		ServerCommand("bot_add_ct %s", "realziN");
		ServerCommand("mp_teamlogo_1 w7m");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "skullz");
		ServerCommand("bot_add_t %s", "raafa");
		ServerCommand("bot_add_t %s", "Tuurtle");
		ServerCommand("bot_add_t %s", "pancc");
		ServerCommand("bot_add_t %s", "realziN");
		ServerCommand("mp_teamlogo_2 w7m");
	}
	
	return Plugin_Handled;
}

public Action Team_Avant(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BL1TZ");
		ServerCommand("bot_add_ct %s", "sterling");
		ServerCommand("bot_add_ct %s", "apoc");
		ServerCommand("bot_add_ct %s", "ofnu");
		ServerCommand("bot_add_ct %s", "HaZR");
		ServerCommand("mp_teamlogo_1 avant");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BL1TZ");
		ServerCommand("bot_add_t %s", "sterling");
		ServerCommand("bot_add_t %s", "apoc");
		ServerCommand("bot_add_t %s", "ofnu");
		ServerCommand("bot_add_t %s", "HaZR");
		ServerCommand("mp_teamlogo_2 avant");
	}
	
	return Plugin_Handled;
}

public Action Team_Chiefs(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HUGHMUNGUS");
		ServerCommand("bot_add_ct %s", "Vexite");
		ServerCommand("bot_add_ct %s", "apocdud");
		ServerCommand("bot_add_ct %s", "zeph");
		ServerCommand("bot_add_ct %s", "soju_j");
		ServerCommand("mp_teamlogo_1 chief");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HUGHMUNGUS");
		ServerCommand("bot_add_t %s", "Vexite");
		ServerCommand("bot_add_t %s", "apocdud");
		ServerCommand("bot_add_t %s", "zeph");
		ServerCommand("bot_add_t %s", "soju_j");
		ServerCommand("mp_teamlogo_2 chief");
	}
	
	return Plugin_Handled;
}

public Action Team_ORDER(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "J1rah");
		ServerCommand("bot_add_ct %s", "aliStair");
		ServerCommand("bot_add_ct %s", "Rickeh");
		ServerCommand("bot_add_ct %s", "USTILO");
		ServerCommand("bot_add_ct %s", "Valiance");
		ServerCommand("mp_teamlogo_1 order");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "J1rah");
		ServerCommand("bot_add_t %s", "aliStair");
		ServerCommand("bot_add_t %s", "Rickeh");
		ServerCommand("bot_add_t %s", "USTILO");
		ServerCommand("bot_add_t %s", "Valiance");
		ServerCommand("mp_teamlogo_2 order");
	}
	
	return Plugin_Handled;
}

public Action Team_SKADE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Duplicate");
		ServerCommand("bot_add_ct %s", "dennyslaw");
		ServerCommand("bot_add_ct %s", "Oxygen");
		ServerCommand("bot_add_ct %s", "Rainwaker");
		ServerCommand("bot_add_ct %s", "SPELLAN");
		ServerCommand("mp_teamlogo_1 ska");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Duplicate");
		ServerCommand("bot_add_t %s", "dennyslaw");
		ServerCommand("bot_add_t %s", "Oxygen");
		ServerCommand("bot_add_t %s", "Rainwaker");
		ServerCommand("bot_add_t %s", "SPELLAN");
		ServerCommand("mp_teamlogo_2 ska");
	}
	
	return Plugin_Handled;
}

public Action Team_Paradox(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "rbz");
		ServerCommand("bot_add_ct %s", "Versa");
		ServerCommand("bot_add_ct %s", "ekul");
		ServerCommand("bot_add_ct %s", "bedonka");
		ServerCommand("bot_add_ct %s", "dangeR");
		ServerCommand("mp_teamlogo_1 para");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "rbz");
		ServerCommand("bot_add_t %s", "Versa");
		ServerCommand("bot_add_t %s", "ekul");
		ServerCommand("bot_add_t %s", "bedonka");
		ServerCommand("bot_add_t %s", "dangeR");
		ServerCommand("mp_teamlogo_2 para");
	}
	
	return Plugin_Handled;
}

public Action Team_Beyond(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MAIROLLS");
		ServerCommand("bot_add_ct %s", "Olivia");
		ServerCommand("bot_add_ct %s", "Kntz");
		ServerCommand("bot_add_ct %s", "stk");
		ServerCommand("bot_add_ct %s", "qqGod");
		ServerCommand("mp_teamlogo_1 bey");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MAIROLLS");
		ServerCommand("bot_add_t %s", "Olivia");
		ServerCommand("bot_add_t %s", "Kntz");
		ServerCommand("bot_add_t %s", "stk");
		ServerCommand("bot_add_t %s", "qqGod");
		ServerCommand("mp_teamlogo_2 bey");
	}
	
	return Plugin_Handled;
}

public Action Team_BOOM(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "chelo");
		ServerCommand("bot_add_ct %s", "yeL");
		ServerCommand("bot_add_ct %s", "shz");
		ServerCommand("bot_add_ct %s", "boltz");
		ServerCommand("bot_add_ct %s", "felps");
		ServerCommand("mp_teamlogo_1 boom");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "chelo");
		ServerCommand("bot_add_t %s", "yeL");
		ServerCommand("bot_add_t %s", "shz");
		ServerCommand("bot_add_t %s", "boltz");
		ServerCommand("bot_add_t %s", "felps");
		ServerCommand("mp_teamlogo_2 boom");
	}
	
	return Plugin_Handled;
}

public Action Team_NASR(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "proxyyb");
		ServerCommand("bot_add_ct %s", "Real1ze");
		ServerCommand("bot_add_ct %s", "BOROS");
		ServerCommand("bot_add_ct %s", "Dementor");
		ServerCommand("bot_add_ct %s", "Just1ce");
		ServerCommand("mp_teamlogo_1 nasr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "proxyyb");
		ServerCommand("bot_add_t %s", "Real1ze");
		ServerCommand("bot_add_t %s", "BOROS");
		ServerCommand("bot_add_t %s", "Dementor");
		ServerCommand("bot_add_t %s", "Just1ce");
		ServerCommand("mp_teamlogo_2 nasr");
	}
	
	return Plugin_Handled;
}

public Action Team_Revolution(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Rambutan");
		ServerCommand("bot_add_ct %s", "Fog");
		ServerCommand("bot_add_ct %s", "Tee");
		ServerCommand("bot_add_ct %s", "Jaybk");
		ServerCommand("bot_add_ct %s", "kun");
		ServerCommand("mp_teamlogo_1 revo");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Rambutan");
		ServerCommand("bot_add_t %s", "Fog");
		ServerCommand("bot_add_t %s", "Tee");
		ServerCommand("bot_add_t %s", "Jaybk");
		ServerCommand("bot_add_t %s", "kun");
		ServerCommand("mp_teamlogo_2 revo");
	}
	
	return Plugin_Handled;
}

public Action Team_SHIFT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "\"Young KillerS\"");
		ServerCommand("bot_add_ct %s", "Kishi");
		ServerCommand("bot_add_ct %s", "tozz");
		ServerCommand("bot_add_ct %s", "huyhart");
		ServerCommand("bot_add_ct %s", "Imcarnus");
		ServerCommand("mp_teamlogo_1 shift");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "\"Young KillerS\"");
		ServerCommand("bot_add_t %s", "Kishi");
		ServerCommand("bot_add_t %s", "tozz");
		ServerCommand("bot_add_t %s", "huyhart");
		ServerCommand("bot_add_t %s", "Imcarnus");
		ServerCommand("mp_teamlogo_2 shift");
	}
	
	return Plugin_Handled;
}

public Action Team_nxl(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "soifong");
		ServerCommand("bot_add_ct %s", "Foscmorc");
		ServerCommand("bot_add_ct %s", "frgd[ibtJ]");
		ServerCommand("bot_add_ct %s", "Lmemore");
		ServerCommand("bot_add_ct %s", "xera");
		ServerCommand("mp_teamlogo_1 nxl");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "soifong");
		ServerCommand("bot_add_t %s", "Foscmorc");
		ServerCommand("bot_add_t %s", "frgd[ibtJ]");
		ServerCommand("bot_add_t %s", "Lmemore");
		ServerCommand("bot_add_t %s", "xera");
		ServerCommand("mp_teamlogo_2 nxl");
	}
	
	return Plugin_Handled;
}

public Action Team_LLL(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "simix");
		ServerCommand("bot_add_ct %s", "Stev0se");
		ServerCommand("bot_add_ct %s", "ritchiEE");
		ServerCommand("bot_add_ct %s", "rilax");
		ServerCommand("bot_add_ct %s", "FASHR");
		ServerCommand("mp_teamlogo_1 lll");
	}
	
	if(strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "simix");
		ServerCommand("bot_add_t %s", "Stev0se");
		ServerCommand("bot_add_t %s", "ritchiEE");
		ServerCommand("bot_add_t %s", "rilax");
		ServerCommand("bot_add_t %s", "FASHR");
		ServerCommand("mp_teamlogo_2 lll");
	}
	
	return Plugin_Handled;
}

public Action Team_energy(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pnd");
		ServerCommand("bot_add_ct %s", "disTroiT");
		ServerCommand("bot_add_ct %s", "Lichl0rd");
		ServerCommand("bot_add_ct %s", "Tiaantije");
		ServerCommand("bot_add_ct %s", "mango");
		ServerCommand("mp_teamlogo_1 ener");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pnd");
		ServerCommand("bot_add_t %s", "disTroiT");
		ServerCommand("bot_add_t %s", "Lichl0rd");
		ServerCommand("bot_add_t %s", "Tiaantije");
		ServerCommand("bot_add_t %s", "mango");
		ServerCommand("mp_teamlogo_2 ener");
	}
	
	return Plugin_Handled;
}

public Action Team_Furious(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nbl");
		ServerCommand("bot_add_ct %s", "tom1");
		ServerCommand("bot_add_ct %s", "Owensinho");
		ServerCommand("bot_add_ct %s", "iKrystal");
		ServerCommand("bot_add_ct %s", "pablek");
		ServerCommand("mp_teamlogo_1 furio");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nbl");
		ServerCommand("bot_add_t %s", "tom1");
		ServerCommand("bot_add_t %s", "Owensinho");
		ServerCommand("bot_add_t %s", "iKrystal");
		ServerCommand("bot_add_t %s", "pablek");
		ServerCommand("mp_teamlogo_2 furio");
	}
	
	return Plugin_Handled;
}

public Action Team_GroundZero(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BURNRUOk");
		ServerCommand("bot_add_ct %s", "Laes");
		ServerCommand("bot_add_ct %s", "Llamas");
		ServerCommand("bot_add_ct %s", "Noobster");
		ServerCommand("bot_add_ct %s", "Mayker");
		ServerCommand("mp_teamlogo_1 ground");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BURNRUOk");
		ServerCommand("bot_add_t %s", "Laes");
		ServerCommand("bot_add_t %s", "Llamas");
		ServerCommand("bot_add_t %s", "Noobster");
		ServerCommand("bot_add_t %s", "Mayker");
		ServerCommand("mp_teamlogo_2 ground");
	}
	
	return Plugin_Handled;
}

public Action Team_AVEZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "byali");
		ServerCommand("bot_add_ct %s", "\"Markoś\"");
		ServerCommand("bot_add_ct %s", "tudsoN");
		ServerCommand("bot_add_ct %s", "Kylar");
		ServerCommand("bot_add_ct %s", "nawrot");
		ServerCommand("mp_teamlogo_1 avez");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "byali");
		ServerCommand("bot_add_t %s", "\"Markoś\"");
		ServerCommand("bot_add_t %s", "tudsoN");
		ServerCommand("bot_add_t %s", "Kylar");
		ServerCommand("bot_add_t %s", "nawrot");
		ServerCommand("mp_teamlogo_2 avez");
	}
	
	return Plugin_Handled;
}

public Action Team_GTZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "StepA");
		ServerCommand("bot_add_ct %s", "snapy");
		ServerCommand("bot_add_ct %s", "slaxx");
		ServerCommand("bot_add_ct %s", "Dante");
		ServerCommand("bot_add_ct %s", "fakes2");
		ServerCommand("mp_teamlogo_1 gtz");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "StepA");
		ServerCommand("bot_add_t %s", "snapy");
		ServerCommand("bot_add_t %s", "slaxx");
		ServerCommand("bot_add_t %s", "Dante");
		ServerCommand("bot_add_t %s", "fakes2");
		ServerCommand("mp_teamlogo_2 gtz");
	}
	
	return Plugin_Handled;
}

public Action Team_x6tence(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Queenix");
		ServerCommand("bot_add_ct %s", "zEVES");
		ServerCommand("bot_add_ct %s", "maNkz");
		ServerCommand("bot_add_ct %s", "mertz");
		ServerCommand("bot_add_ct %s", "Nodios");
		ServerCommand("mp_teamlogo_1 x6t");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Queenix");
		ServerCommand("bot_add_t %s", "zEVES");
		ServerCommand("bot_add_t %s", "maNkz");
		ServerCommand("bot_add_t %s", "mertz");
		ServerCommand("bot_add_t %s", "Nodios");
		ServerCommand("mp_teamlogo_2 x6t");
	}
	
	return Plugin_Handled;
}

public Action Team_K23(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "neaLaN");
		ServerCommand("bot_add_ct %s", "mou");
		ServerCommand("bot_add_ct %s", "n0rb3r7");
		ServerCommand("bot_add_ct %s", "kade0");
		ServerCommand("bot_add_ct %s", "Keoz");
		ServerCommand("mp_teamlogo_1 k23");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "neaLaN");
		ServerCommand("bot_add_t %s", "mou");
		ServerCommand("bot_add_t %s", "n0rb3r7");
		ServerCommand("bot_add_t %s", "kade0");
		ServerCommand("bot_add_t %s", "Keoz");
		ServerCommand("mp_teamlogo_2 k23");
	}
	
	return Plugin_Handled;
}

public Action Team_Goliath(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "massacRe");
		ServerCommand("bot_add_ct %s", "Dweezil");
		ServerCommand("bot_add_ct %s", "adM");
		ServerCommand("bot_add_ct %s", "ELUSIVE");
		ServerCommand("bot_add_ct %s", "ZipZip");
		ServerCommand("mp_teamlogo_1 gol");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "massacRe");
		ServerCommand("bot_add_t %s", "Dweezil");
		ServerCommand("bot_add_t %s", "adM");
		ServerCommand("bot_add_t %s", "ELUSIVE");
		ServerCommand("bot_add_t %s", "ZipZip");
		ServerCommand("mp_teamlogo_2 gol");
	}
	
	return Plugin_Handled;
}

public Action Team_Secret(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "juanflatroo");
		ServerCommand("bot_add_ct %s", "smF");
		ServerCommand("bot_add_ct %s", "PERCY");
		ServerCommand("bot_add_ct %s", "sinnopsyy");
		ServerCommand("bot_add_ct %s", "anarkez");
		ServerCommand("mp_teamlogo_1 secr");
	}
	
	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "juanflatroo");
		ServerCommand("bot_add_t %s", "smF");
		ServerCommand("bot_add_t %s", "PERCY");
		ServerCommand("bot_add_t %s", "sinnopsyy");
		ServerCommand("bot_add_t %s", "anarkez");
		ServerCommand("mp_teamlogo_2 secr");
	}
	
	return Plugin_Handled;
}

public Action Team_UOL(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "crisby");
		ServerCommand("bot_add_ct %s", "kzy");
		ServerCommand("bot_add_ct %s", "Andyy");
		ServerCommand("bot_add_ct %s", "JDC");
		ServerCommand("bot_add_ct %s", "P4TriCK");
		ServerCommand("mp_teamlogo_1 uni");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "crisby");
		ServerCommand("bot_add_t %s", "kzy");
		ServerCommand("bot_add_t %s", "Andyy");
		ServerCommand("bot_add_t %s", "JDC");
		ServerCommand("bot_add_t %s", "P4TriCK");
		ServerCommand("mp_teamlogo_2 uni");
	}

	return Plugin_Handled;
}

public Action Team_RADIX(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mrhui");
		ServerCommand("bot_add_ct %s", "joss");
		ServerCommand("bot_add_ct %s", "brky");
		ServerCommand("bot_add_ct %s", "entz");
		ServerCommand("bot_add_ct %s", "eZo");
		ServerCommand("mp_teamlogo_1 radix");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mrhui");
		ServerCommand("bot_add_t %s", "joss");
		ServerCommand("bot_add_t %s", "brky");
		ServerCommand("bot_add_t %s", "entz");
		ServerCommand("bot_add_t %s", "eZo");
		ServerCommand("mp_teamlogo_2 radix");
	}

	return Plugin_Handled;
}

public Action Team_Illuminar(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Vegi");
		ServerCommand("bot_add_ct %s", "Snax");
		ServerCommand("bot_add_ct %s", "mouz");
		ServerCommand("bot_add_ct %s", "reatz");
		ServerCommand("bot_add_ct %s", "phr");
		ServerCommand("mp_teamlogo_1 illu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Vegi");
		ServerCommand("bot_add_t %s", "Snax");
		ServerCommand("bot_add_t %s", "mouz");
		ServerCommand("bot_add_t %s", "reatz");
		ServerCommand("bot_add_t %s", "phr");
		ServerCommand("mp_teamlogo_2 illu");
	}

	return Plugin_Handled;
}

public Action Team_Queso(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TheClaran");
		ServerCommand("bot_add_ct %s", "thinkii");
		ServerCommand("bot_add_ct %s", "HUMANZ");
		ServerCommand("bot_add_ct %s", "mik");
		ServerCommand("bot_add_ct %s", "Yaba");
		ServerCommand("mp_teamlogo_1 ques");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TheClaran");
		ServerCommand("bot_add_t %s", "thinkii");
		ServerCommand("bot_add_t %s", "HUMANZ");
		ServerCommand("bot_add_t %s", "mik");
		ServerCommand("bot_add_t %s", "Yaba");
		ServerCommand("mp_teamlogo_2 ques");
	}

	return Plugin_Handled;
}

public Action Team_IG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bottle");
		ServerCommand("bot_add_ct %s", "DeStRoYeR");
		ServerCommand("bot_add_ct %s", "flying");
		ServerCommand("bot_add_ct %s", "Viva");
		ServerCommand("bot_add_ct %s", "XiaosaGe");
		ServerCommand("mp_teamlogo_1 ig");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bottle");
		ServerCommand("bot_add_t %s", "DeStRoYeR");
		ServerCommand("bot_add_t %s", "flying");
		ServerCommand("bot_add_t %s", "Viva");
		ServerCommand("bot_add_t %s", "XiaosaGe");
		ServerCommand("mp_teamlogo_2 ig");
	}

	return Plugin_Handled;
}

public Action Team_HR(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kAliNkA");
		ServerCommand("bot_add_ct %s", "jR");
		ServerCommand("bot_add_ct %s", "Flarich");
		ServerCommand("bot_add_ct %s", "ProbLeM");
		ServerCommand("bot_add_ct %s", "JIaYm");
		ServerCommand("mp_teamlogo_1 hr");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kAliNkA");
		ServerCommand("bot_add_t %s", "jR");
		ServerCommand("bot_add_t %s", "Flarich");
		ServerCommand("bot_add_t %s", "ProbLeM");
		ServerCommand("bot_add_t %s", "JIaYm");
		ServerCommand("mp_teamlogo_2 hr");
	}

	return Plugin_Handled;
}

public Action Team_Dice(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XpG");
		ServerCommand("bot_add_ct %s", "nonick");
		ServerCommand("bot_add_ct %s", "Kan4");
		ServerCommand("bot_add_ct %s", "Polox");
		ServerCommand("bot_add_ct %s", "Djoko");
		ServerCommand("mp_teamlogo_1 dice");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XpG");
		ServerCommand("bot_add_t %s", "nonick");
		ServerCommand("bot_add_t %s", "Kan4");
		ServerCommand("bot_add_t %s", "Polox");
		ServerCommand("bot_add_t %s", "Djoko");
		ServerCommand("mp_teamlogo_2 dice");
	}

	return Plugin_Handled;
}

public Action Team_PlanetKey(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "LapeX");
		ServerCommand("bot_add_ct %s", "Printek");
		ServerCommand("bot_add_ct %s", "glaVed");
		ServerCommand("bot_add_ct %s", "ND");
		ServerCommand("bot_add_ct %s", "impulsG");
		ServerCommand("mp_teamlogo_1 planet");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "LapeX");
		ServerCommand("bot_add_t %s", "Printek");
		ServerCommand("bot_add_t %s", "glaVed");
		ServerCommand("bot_add_t %s", "ND");
		ServerCommand("bot_add_t %s", "impulsG");
		ServerCommand("mp_teamlogo_2 planet");
	}

	return Plugin_Handled;
}

public Action Team_Vexed(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dox");
		ServerCommand("bot_add_ct %s", "shyyne");
		ServerCommand("bot_add_ct %s", "leafy");
		ServerCommand("bot_add_ct %s", "shateri");
		ServerCommand("bot_add_ct %s", "volt");
		ServerCommand("mp_teamlogo_1 vex");
	}

	if(strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dox");
		ServerCommand("bot_add_t %s", "shyyne");
		ServerCommand("bot_add_t %s", "leafy");
		ServerCommand("bot_add_t %s", "shateri");
		ServerCommand("bot_add_t %s", "volt");
		ServerCommand("mp_teamlogo_2 vex");
	}

	return Plugin_Handled;
}

public Action Team_HLE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "d1Ledez");
		ServerCommand("bot_add_ct %s", "DrobnY");
		ServerCommand("bot_add_ct %s", "Raijin");
		ServerCommand("bot_add_ct %s", "Forester");
		ServerCommand("bot_add_ct %s", "svyat");
		ServerCommand("mp_teamlogo_1 hle");
	}

	if(strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "d1Ledez");
		ServerCommand("bot_add_t %s", "DrobnY");
		ServerCommand("bot_add_t %s", "Raijin");
		ServerCommand("bot_add_t %s", "Forester");
		ServerCommand("bot_add_t %s", "svyat");
		ServerCommand("mp_teamlogo_2 hle");
	}

	return Plugin_Handled;
}

public Action Team_Gambit(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nafany");
		ServerCommand("bot_add_ct %s", "sh1ro");
		ServerCommand("bot_add_ct %s", "interz");
		ServerCommand("bot_add_ct %s", "Ax1Le");
		ServerCommand("bot_add_ct %s", "Hobbit");
		ServerCommand("mp_teamlogo_1 gambit");
	}

	if(strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nafany");
		ServerCommand("bot_add_t %s", "sh1ro");
		ServerCommand("bot_add_t %s", "interz");
		ServerCommand("bot_add_t %s", "Ax1Le");
		ServerCommand("bot_add_t %s", "Hobbit");
		ServerCommand("mp_teamlogo_2 gambit");
	}

	return Plugin_Handled;
}

public Action Team_Wisla(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hades");
		ServerCommand("bot_add_ct %s", "SZPERO");
		ServerCommand("bot_add_ct %s", "mynio");
		ServerCommand("bot_add_ct %s", "ponczek");
		ServerCommand("bot_add_ct %s", "jedqr");
		ServerCommand("mp_teamlogo_1 wisla");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hades");
		ServerCommand("bot_add_t %s", "SZPERO");
		ServerCommand("bot_add_t %s", "mynio");
		ServerCommand("bot_add_t %s", "ponczek");
		ServerCommand("bot_add_t %s", "jedqr");
		ServerCommand("mp_teamlogo_2 wisla");
	}

	return Plugin_Handled;
}

public Action Team_Imperial(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fnx");
		ServerCommand("bot_add_ct %s", "zqk");
		ServerCommand("bot_add_ct %s", "adr");
		ServerCommand("bot_add_ct %s", "iDk");
		ServerCommand("bot_add_ct %s", "SHOOWTiME");
		ServerCommand("mp_teamlogo_1 imp");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fnx");
		ServerCommand("bot_add_t %s", "zqk");
		ServerCommand("bot_add_t %s", "adr");
		ServerCommand("bot_add_t %s", "iDk");
		ServerCommand("bot_add_t %s", "SHOOWTiME");
		ServerCommand("mp_teamlogo_2 imp");
	}

	return Plugin_Handled;
}

public Action Team_Pompa(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "iso");
		ServerCommand("bot_add_ct %s", "SKRZYNKA");
		ServerCommand("bot_add_ct %s", "LAYNER");
		ServerCommand("bot_add_ct %s", "OLIMP");
		ServerCommand("bot_add_ct %s", "blacktear5");
		ServerCommand("mp_teamlogo_1 pompa");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "iso");
		ServerCommand("bot_add_t %s", "SKRZYNKA");
		ServerCommand("bot_add_t %s", "LAYNER");
		ServerCommand("bot_add_t %s", "OLIMP");
		ServerCommand("bot_add_t %s", "blacktear5");
		ServerCommand("mp_teamlogo_2 pompa");
	}

	return Plugin_Handled;
}

public Action Team_Unique(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "crush");
		ServerCommand("bot_add_ct %s", "H1te");
		ServerCommand("bot_add_ct %s", "shalfey");
		ServerCommand("bot_add_ct %s", "SELLTER");
		ServerCommand("bot_add_ct %s", "fenvicious");
		ServerCommand("mp_teamlogo_1 uniq");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "crush");
		ServerCommand("bot_add_t %s", "H1te");
		ServerCommand("bot_add_t %s", "shalfey");
		ServerCommand("bot_add_t %s", "SELLTER");
		ServerCommand("bot_add_t %s", "fenvicious");
		ServerCommand("mp_teamlogo_2 uniq");
	}

	return Plugin_Handled;
}

public Action Team_Izako(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Siuhy");
		ServerCommand("bot_add_ct %s", "szejn");
		ServerCommand("bot_add_ct %s", "EXUS");
		ServerCommand("bot_add_ct %s", "avis");
		ServerCommand("bot_add_ct %s", "TOAO");
		ServerCommand("mp_teamlogo_1 izak");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Siuhy");
		ServerCommand("bot_add_t %s", "szejn");
		ServerCommand("bot_add_t %s", "EXUS");
		ServerCommand("bot_add_t %s", "avis");
		ServerCommand("bot_add_t %s", "TOAO");
		ServerCommand("mp_teamlogo_2 izak");
	}

	return Plugin_Handled;
}

public Action Team_ATK(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bLazE");
		ServerCommand("bot_add_ct %s", "MisteM");
		ServerCommand("bot_add_ct %s", "SloWye");
		ServerCommand("bot_add_ct %s", "Fadey");
		ServerCommand("bot_add_ct %s", "Doru");
		ServerCommand("mp_teamlogo_1 atk");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bLazE");
		ServerCommand("bot_add_t %s", "MisteM");
		ServerCommand("bot_add_t %s", "SloWye");
		ServerCommand("bot_add_t %s", "Fadey");
		ServerCommand("bot_add_t %s", "Doru");
		ServerCommand("mp_teamlogo_2 atk");
	}

	return Plugin_Handled;
}

public Action Team_Chaos(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Xeppaa");
		ServerCommand("bot_add_ct %s", "vanity");
		ServerCommand("bot_add_ct %s", "leaf");
		ServerCommand("bot_add_ct %s", "MarKE");
		ServerCommand("bot_add_ct %s", "Jonji");
		ServerCommand("mp_teamlogo_1 chaos");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Xeppaa");
		ServerCommand("bot_add_t %s", "vanity");
		ServerCommand("bot_add_t %s", "leaf");
		ServerCommand("bot_add_t %s", "MarKE");
		ServerCommand("bot_add_t %s", "Jonji");
		ServerCommand("mp_teamlogo_2 chaos");
	}

	return Plugin_Handled;
}

public Action Team_Wings(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ChildKing");
		ServerCommand("bot_add_ct %s", "lan");
		ServerCommand("bot_add_ct %s", "MarT1n");
		ServerCommand("bot_add_ct %s", "DD");
		ServerCommand("bot_add_ct %s", "gas");
		ServerCommand("mp_teamlogo_1 wings");
	}

	if(strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ChildKing");
		ServerCommand("bot_add_t %s", "lan");
		ServerCommand("bot_add_t %s", "MarT1n");
		ServerCommand("bot_add_t %s", "DD");
		ServerCommand("bot_add_t %s", "gas");
		ServerCommand("mp_teamlogo_2 wings");
	}

	return Plugin_Handled;
}

public Action Team_Lynn(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XG");
		ServerCommand("bot_add_ct %s", "mitsuha");
		ServerCommand("bot_add_ct %s", "Aree");
		ServerCommand("bot_add_ct %s", "EXPRO");
		ServerCommand("bot_add_ct %s", "XinKoiNg");
		ServerCommand("mp_teamlogo_1 lynn");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XG");
		ServerCommand("bot_add_t %s", "mitsuha");
		ServerCommand("bot_add_t %s", "Aree");
		ServerCommand("bot_add_t %s", "EXPRO");
		ServerCommand("bot_add_t %s", "XinKoiNg");
		ServerCommand("mp_teamlogo_2 lynn");
	}

	return Plugin_Handled;
}

public Action Team_Triumph(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Shakezullah");
		ServerCommand("bot_add_ct %s", "Junior");
		ServerCommand("bot_add_ct %s", "ryann");
		ServerCommand("bot_add_ct %s", "penny");
		ServerCommand("bot_add_ct %s", "moose");
		ServerCommand("mp_teamlogo_1 tri");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Shakezullah");
		ServerCommand("bot_add_t %s", "Junior");
		ServerCommand("bot_add_t %s", "ryann");
		ServerCommand("bot_add_t %s", "penny");
		ServerCommand("bot_add_t %s", "moose");
		ServerCommand("mp_teamlogo_2 tri");
	}

	return Plugin_Handled;
}

public Action Team_FATE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "blocker");
		ServerCommand("bot_add_ct %s", "Patrick");
		ServerCommand("bot_add_ct %s", "harn");
		ServerCommand("bot_add_ct %s", "Mar");
		ServerCommand("bot_add_ct %s", "niki1");
		ServerCommand("mp_teamlogo_1 fate");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "blocker");
		ServerCommand("bot_add_t %s", "Patrick");
		ServerCommand("bot_add_t %s", "harn");
		ServerCommand("bot_add_t %s", "Mar");
		ServerCommand("bot_add_t %s", "niki1");
		ServerCommand("mp_teamlogo_2 fate");
	}

	return Plugin_Handled;
}

public Action Team_Canids(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DeStiNy");
		ServerCommand("bot_add_ct %s", "nythonzinho");
		ServerCommand("bot_add_ct %s", "heat");
		ServerCommand("bot_add_ct %s", "latto");
		ServerCommand("bot_add_ct %s", "KHTEX");
		ServerCommand("mp_teamlogo_1 red");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DeStiNy");
		ServerCommand("bot_add_t %s", "nythonzinho");
		ServerCommand("bot_add_t %s", "heat");
		ServerCommand("bot_add_t %s", "latto");
		ServerCommand("bot_add_t %s", "KHTEX");
		ServerCommand("mp_teamlogo_2 red");
	}

	return Plugin_Handled;
}

public Action Team_ESPADA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Patsanchick");
		ServerCommand("bot_add_ct %s", "degster");
		ServerCommand("bot_add_ct %s", "FinigaN");
		ServerCommand("bot_add_ct %s", "S0tF1k");
		ServerCommand("bot_add_ct %s", "Dima");
		ServerCommand("mp_teamlogo_1 esp");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Patsanchick");
		ServerCommand("bot_add_t %s", "degster");
		ServerCommand("bot_add_t %s", "FinigaN");
		ServerCommand("bot_add_t %s", "S0tF1k");
		ServerCommand("bot_add_t %s", "Dima");
		ServerCommand("mp_teamlogo_2 esp");
	}

	return Plugin_Handled;
}

public Action Team_OG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NBK-");
		ServerCommand("bot_add_ct %s", "mantuu");
		ServerCommand("bot_add_ct %s", "Aleksib");
		ServerCommand("bot_add_ct %s", "valde");
		ServerCommand("bot_add_ct %s", "ISSAA");
		ServerCommand("mp_teamlogo_1 og");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NBK-");
		ServerCommand("bot_add_t %s", "mantuu");
		ServerCommand("bot_add_t %s", "Aleksib");
		ServerCommand("bot_add_t %s", "valde");
		ServerCommand("bot_add_t %s", "ISSAA");
		ServerCommand("mp_teamlogo_2 og");
	}

	return Plugin_Handled;
}

public Action Team_Wizards(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Bernard");
		ServerCommand("bot_add_ct %s", "blackie");
		ServerCommand("bot_add_ct %s", "kzealos");
		ServerCommand("bot_add_ct %s", "eneshan");
		ServerCommand("bot_add_ct %s", "dreez");
		ServerCommand("mp_teamlogo_1 wiz");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Bernard");
		ServerCommand("bot_add_t %s", "blackie");
		ServerCommand("bot_add_t %s", "kzealos");
		ServerCommand("bot_add_t %s", "eneshan");
		ServerCommand("bot_add_t %s", "dreez");
		ServerCommand("mp_teamlogo_2 wiz");
	}

	return Plugin_Handled;
}

public Action Team_Tricked(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kiR");
		ServerCommand("bot_add_ct %s", "kwezz");
		ServerCommand("bot_add_ct %s", "Luckyv1");
		ServerCommand("bot_add_ct %s", "sycrone");
		ServerCommand("bot_add_ct %s", "PR1mE");
		ServerCommand("mp_teamlogo_1 trick");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kiR");
		ServerCommand("bot_add_t %s", "kwezz");
		ServerCommand("bot_add_t %s", "Luckyv1");
		ServerCommand("bot_add_t %s", "sycrone");
		ServerCommand("bot_add_t %s", "PR1mE");
		ServerCommand("mp_teamlogo_2 trick");
	}

	return Plugin_Handled;
}

public Action Team_GenG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "autimatic");
		ServerCommand("bot_add_ct %s", "koosta");
		ServerCommand("bot_add_ct %s", "daps");
		ServerCommand("bot_add_ct %s", "s0m");
		ServerCommand("bot_add_ct %s", "BnTeT");
		ServerCommand("mp_teamlogo_1 gen");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "autimatic");
		ServerCommand("bot_add_t %s", "koosta");
		ServerCommand("bot_add_t %s", "daps");
		ServerCommand("bot_add_t %s", "s0m");
		ServerCommand("bot_add_t %s", "BnTeT");
		ServerCommand("mp_teamlogo_2 gen");
	}

	return Plugin_Handled;
}

public Action Team_Endpoint(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Surreal");
		ServerCommand("bot_add_ct %s", "CRUC1AL");
		ServerCommand("bot_add_ct %s", "MiGHTYMAX");
		ServerCommand("bot_add_ct %s", "robiin");
		ServerCommand("bot_add_ct %s", "flameZ");
		ServerCommand("mp_teamlogo_1 endp");
	}

	if(strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Surreal");
		ServerCommand("bot_add_t %s", "CRUC1AL");
		ServerCommand("bot_add_t %s", "MiGHTYMAX");
		ServerCommand("bot_add_t %s", "robiin");
		ServerCommand("bot_add_t %s", "flameZ");
		ServerCommand("mp_teamlogo_2 endp");
	}

	return Plugin_Handled;
}

public Action Team_sAw(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "arki");
		ServerCommand("bot_add_ct %s", "stadodo");
		ServerCommand("bot_add_ct %s", "JUST");
		ServerCommand("bot_add_ct %s", "MUTiRiS");
		ServerCommand("bot_add_ct %s", "rmn");
		ServerCommand("mp_teamlogo_1 saw");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "arki");
		ServerCommand("bot_add_t %s", "stadodo");
		ServerCommand("bot_add_t %s", "JUST");
		ServerCommand("bot_add_t %s", "MUTiRiS");
		ServerCommand("bot_add_t %s", "rmn");
		ServerCommand("mp_teamlogo_2 saw");
	}

	return Plugin_Handled;
}

public Action Team_DIG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "H4RR3");
		ServerCommand("bot_add_ct %s", "hallzerk");
		ServerCommand("bot_add_ct %s", "f0rest");
		ServerCommand("bot_add_ct %s", "friberg");
		ServerCommand("bot_add_ct %s", "HEAP");
		ServerCommand("mp_teamlogo_1 dign");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "H4RR3");
		ServerCommand("bot_add_t %s", "hallzerk");
		ServerCommand("bot_add_t %s", "f0rest");
		ServerCommand("bot_add_t %s", "friberg");
		ServerCommand("bot_add_t %s", "HEAP");
		ServerCommand("mp_teamlogo_2 dign");
	}

	return Plugin_Handled;
}

public Action Team_D13(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Tamiraarita");
		ServerCommand("bot_add_ct %s", "hasteka");
		ServerCommand("bot_add_ct %s", "shinobi");
		ServerCommand("bot_add_ct %s", "sK0R");
		ServerCommand("bot_add_ct %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_1 d13");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Tamiraarita");
		ServerCommand("bot_add_t %s", "hasteka");
		ServerCommand("bot_add_t %s", "shinobi");
		ServerCommand("bot_add_t %s", "sK0R");
		ServerCommand("bot_add_t %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_2 d13");
	}

	return Plugin_Handled;
}

public Action Team_ZIGMA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NIFFY");
		ServerCommand("bot_add_ct %s", "Reality");
		ServerCommand("bot_add_ct %s", "JUSTCAUSE");
		ServerCommand("bot_add_ct %s", "PPOverdose");
		ServerCommand("bot_add_ct %s", "RoLEX");
		ServerCommand("mp_teamlogo_1 zigma");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NIFFY");
		ServerCommand("bot_add_t %s", "Reality");
		ServerCommand("bot_add_t %s", "JUSTCAUSE");
		ServerCommand("bot_add_t %s", "PPOverdose");
		ServerCommand("bot_add_t %s", "RoLEX");
		ServerCommand("mp_teamlogo_2 zigma");
	}

	return Plugin_Handled;
}

public Action Team_Ambush(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Inzta");
		ServerCommand("bot_add_ct %s", "Ryxxo");
		ServerCommand("bot_add_ct %s", "zeq");
		ServerCommand("bot_add_ct %s", "Typos");
		ServerCommand("bot_add_ct %s", "IceBerg");
		ServerCommand("mp_teamlogo_1 ambu");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Inzta");
		ServerCommand("bot_add_t %s", "Ryxxo");
		ServerCommand("bot_add_t %s", "zeq");
		ServerCommand("bot_add_t %s", "Typos");
		ServerCommand("bot_add_t %s", "IceBerg");
		ServerCommand("mp_teamlogo_2 ambu");
	}

	return Plugin_Handled;
}

public Action Team_KOVA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pietola");
		ServerCommand("bot_add_ct %s", "spargo");
		ServerCommand("bot_add_ct %s", "uli");
		ServerCommand("bot_add_ct %s", "peku");
		ServerCommand("bot_add_ct %s", "Twixie");
		ServerCommand("mp_teamlogo_1 kova");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pietola");
		ServerCommand("bot_add_t %s", "spargo");
		ServerCommand("bot_add_t %s", "uli");
		ServerCommand("bot_add_t %s", "peku");
		ServerCommand("bot_add_t %s", "Twixie");
		ServerCommand("mp_teamlogo_2 kova");
	}

	return Plugin_Handled;
}

public Action Team_eXploit(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pizituh");
		ServerCommand("bot_add_ct %s", "BuJ");
		ServerCommand("bot_add_ct %s", "sark");
		ServerCommand("bot_add_ct %s", "renatoohaxx");
		ServerCommand("bot_add_ct %s", "BLOODZ");
		ServerCommand("mp_teamlogo_1 expl");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pizituh");
		ServerCommand("bot_add_t %s", "BuJ");
		ServerCommand("bot_add_t %s", "sark");
		ServerCommand("bot_add_t %s", "renatoohaxx");
		ServerCommand("bot_add_t %s", "BLOODZ");
		ServerCommand("mp_teamlogo_2 expl");
	}

	return Plugin_Handled;
}

public Action Team_AGF(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fr0slev");
		ServerCommand("bot_add_ct %s", "Kristou");
		ServerCommand("bot_add_ct %s", "netrick");
		ServerCommand("bot_add_ct %s", "TMB");
		ServerCommand("bot_add_ct %s", "Lukki");
		ServerCommand("mp_teamlogo_1 agf");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fr0slev");
		ServerCommand("bot_add_t %s", "Kristou");
		ServerCommand("bot_add_t %s", "netrick");
		ServerCommand("bot_add_t %s", "TMB");
		ServerCommand("bot_add_t %s", "Lukki");
		ServerCommand("mp_teamlogo_2 agf");
	}

	return Plugin_Handled;
}

public Action Team_GameAgents(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "markk");
		ServerCommand("bot_add_ct %s", "renne");
		ServerCommand("bot_add_ct %s", "s0und");
		ServerCommand("bot_add_ct %s", "regali");
		ServerCommand("bot_add_ct %s", "smekk-");
		ServerCommand("mp_teamlogo_1 game");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "markk");
		ServerCommand("bot_add_t %s", "renne");
		ServerCommand("bot_add_t %s", "s0und");
		ServerCommand("bot_add_t %s", "regali");
		ServerCommand("bot_add_t %s", "smekk-");
		ServerCommand("mp_teamlogo_2 game");
	}

	return Plugin_Handled;
}

public Action Team_Keyd(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bnc");
		ServerCommand("bot_add_ct %s", "mawth");
		ServerCommand("bot_add_ct %s", "tifa");
		ServerCommand("bot_add_ct %s", "jota");
		ServerCommand("bot_add_ct %s", "puni");
		ServerCommand("mp_teamlogo_1 keyds");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bnc");
		ServerCommand("bot_add_t %s", "mawth");
		ServerCommand("bot_add_t %s", "tifa");
		ServerCommand("bot_add_t %s", "jota");
		ServerCommand("bot_add_t %s", "puni");
		ServerCommand("mp_teamlogo_2 keyds");
	}

	return Plugin_Handled;
}

public Action Team_Epsilon(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ALEXJ");
		ServerCommand("bot_add_ct %s", "smogger");
		ServerCommand("bot_add_ct %s", "Celebrations");
		ServerCommand("bot_add_ct %s", "Masti");
		ServerCommand("bot_add_ct %s", "Blytz");
		ServerCommand("mp_teamlogo_1 eps");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ALEXJ");
		ServerCommand("bot_add_t %s", "smogger");
		ServerCommand("bot_add_t %s", "Celebrations");
		ServerCommand("bot_add_t %s", "Masti");
		ServerCommand("bot_add_t %s", "Blytz");
		ServerCommand("mp_teamlogo_2 eps");
	}

	return Plugin_Handled;
}

public Action Team_TIGER(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "erkaSt");
		ServerCommand("bot_add_ct %s", "nin9");
		ServerCommand("bot_add_ct %s", "dobu");
		ServerCommand("bot_add_ct %s", "kabal");
		ServerCommand("bot_add_ct %s", "rate");
		ServerCommand("mp_teamlogo_1 tiger");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "erkaSt");
		ServerCommand("bot_add_t %s", "nin9");
		ServerCommand("bot_add_t %s", "dobu");
		ServerCommand("bot_add_t %s", "kabal");
		ServerCommand("bot_add_t %s", "rate");
		ServerCommand("mp_teamlogo_2 tiger");
	}

	return Plugin_Handled;
}

public Action Team_LEISURE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stefank0k0");
		ServerCommand("bot_add_ct %s", "BischeR");
		ServerCommand("bot_add_ct %s", "farmaG");
		ServerCommand("bot_add_ct %s", "FabeeN");
		ServerCommand("bot_add_ct %s", "bustrex");
		ServerCommand("mp_teamlogo_1 leis");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stefank0k0");
		ServerCommand("bot_add_t %s", "BischeR");
		ServerCommand("bot_add_t %s", "farmaG");
		ServerCommand("bot_add_t %s", "FabeeN");
		ServerCommand("bot_add_t %s", "bustrex");
		ServerCommand("mp_teamlogo_2 leis");
	}

	return Plugin_Handled;
}

public Action Team_PENTA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pdy");
		ServerCommand("bot_add_ct %s", "red");
		ServerCommand("bot_add_ct %s", "s1n");
		ServerCommand("bot_add_ct %s", "xenn");
		ServerCommand("bot_add_ct %s", "skyye");
		ServerCommand("mp_teamlogo_1 penta");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pdy");
		ServerCommand("bot_add_t %s", "red");
		ServerCommand("bot_add_t %s", "s1n");
		ServerCommand("bot_add_t %s", "xenn");
		ServerCommand("bot_add_t %s", "skyye");
		ServerCommand("mp_teamlogo_2 penta");
	}

	return Plugin_Handled;
}

public Action Team_FTW(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "sh1zlEE");
		ServerCommand("bot_add_ct %s", "Jaepe");
		ServerCommand("bot_add_ct %s", "brA");
		ServerCommand("bot_add_ct %s", "plat");
		ServerCommand("bot_add_ct %s", "Cunha");
		ServerCommand("mp_teamlogo_1 ftw");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "sh1zlEE");
		ServerCommand("bot_add_t %s", "Jaepe");
		ServerCommand("bot_add_t %s", "brA");
		ServerCommand("bot_add_t %s", "plat");
		ServerCommand("bot_add_t %s", "Cunha");
		ServerCommand("mp_teamlogo_2 ftw");
	}

	return Plugin_Handled;
}

public Action Team_Titans(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "doublemagic");
		ServerCommand("bot_add_ct %s", "KalubeR");
		ServerCommand("bot_add_ct %s", "rafftu");
		ServerCommand("bot_add_ct %s", "sarenii");
		ServerCommand("bot_add_ct %s", "viltrex");
		ServerCommand("mp_teamlogo_1 titans");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "doublemagic");
		ServerCommand("bot_add_t %s", "KalubeR");
		ServerCommand("bot_add_t %s", "rafftu");
		ServerCommand("bot_add_t %s", "sarenii");
		ServerCommand("bot_add_t %s", "viltrex");
		ServerCommand("mp_teamlogo_2 titans");
	}

	return Plugin_Handled;
}

public Action Team_9INE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "CyderX");
		ServerCommand("bot_add_ct %s", "xfl0ud");
		ServerCommand("bot_add_ct %s", "qRaxs");
		ServerCommand("bot_add_ct %s", "Izzy");
		ServerCommand("bot_add_ct %s", "QutionerX");
		ServerCommand("mp_teamlogo_1 9ine");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "CyderX");
		ServerCommand("bot_add_t %s", "xfl0ud");
		ServerCommand("bot_add_t %s", "qRaxs");
		ServerCommand("bot_add_t %s", "Izzy");
		ServerCommand("bot_add_t %s", "QutionerX");
		ServerCommand("mp_teamlogo_2 9ine");
	}

	return Plugin_Handled;
}

public Action Team_QBF(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JACKPOT");
		ServerCommand("bot_add_ct %s", "Quantium");
		ServerCommand("bot_add_ct %s", "Kas9k");
		ServerCommand("bot_add_ct %s", "hiji");
		ServerCommand("bot_add_ct %s", "lesswill");
		ServerCommand("mp_teamlogo_1 qbf");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JACKPOT");
		ServerCommand("bot_add_t %s", "Quantium");
		ServerCommand("bot_add_t %s", "Kas9k");
		ServerCommand("bot_add_t %s", "hiji");
		ServerCommand("bot_add_t %s", "lesswill");
		ServerCommand("mp_teamlogo_2 qbf");
	}

	return Plugin_Handled;
}

public Action Team_Tigers(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MAXX");
		ServerCommand("bot_add_ct %s", "Lastík");
		ServerCommand("bot_add_ct %s", "zyored");
		ServerCommand("bot_add_ct %s", "wEAMO");
		ServerCommand("bot_add_ct %s", "manguss");
		ServerCommand("mp_teamlogo_1 tigers");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MAXX");
		ServerCommand("bot_add_t %s", "Lastík");
		ServerCommand("bot_add_t %s", "zyored");
		ServerCommand("bot_add_t %s", "wEAMO");
		ServerCommand("bot_add_t %s", "manguss");
		ServerCommand("mp_teamlogo_2 tigers");
	}

	return Plugin_Handled;
}

public Action Team_9z(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dgt");
		ServerCommand("bot_add_ct %s", "try");
		ServerCommand("bot_add_ct %s", "maxujas");
		ServerCommand("bot_add_ct %s", "bit");
		ServerCommand("bot_add_ct %s", "meyern");
		ServerCommand("mp_teamlogo_1 9z");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dgt");
		ServerCommand("bot_add_t %s", "try");
		ServerCommand("bot_add_t %s", "maxujas");
		ServerCommand("bot_add_t %s", "bit");
		ServerCommand("bot_add_t %s", "meyern");
		ServerCommand("mp_teamlogo_2 9z");
	}

	return Plugin_Handled;
}

public Action Team_Malvinas(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ABM");
		ServerCommand("bot_add_ct %s", "fakzwall");
		ServerCommand("bot_add_ct %s", "minimal");
		ServerCommand("bot_add_ct %s", "kary");
		ServerCommand("bot_add_ct %s", "rushardo");
		ServerCommand("mp_teamlogo_1 malv");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ABM");
		ServerCommand("bot_add_t %s", "fakzwall");
		ServerCommand("bot_add_t %s", "minimal");
		ServerCommand("bot_add_t %s", "kary");
		ServerCommand("bot_add_t %s", "rushardo");
		ServerCommand("mp_teamlogo_2 malv");
	}

	return Plugin_Handled;
}

public Action Team_Sinister5(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zerOchaNce");
		ServerCommand("bot_add_ct %s", "FreakY");
		ServerCommand("bot_add_ct %s", "deviaNt");
		ServerCommand("bot_add_ct %s", "Lately");
		ServerCommand("bot_add_ct %s", "slayeRyEyE");
		ServerCommand("mp_teamlogo_1 sini");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zerOchaNce");
		ServerCommand("bot_add_t %s", "FreakY");
		ServerCommand("bot_add_t %s", "deviaNt");
		ServerCommand("bot_add_t %s", "Lately");
		ServerCommand("bot_add_t %s", "slayeRyEyE");
		ServerCommand("mp_teamlogo_2 sini");
	}

	return Plugin_Handled;
}

public Action Team_SINNERS(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ZEDKO");
		ServerCommand("bot_add_ct %s", "CaNNiE");
		ServerCommand("bot_add_ct %s", "SHOCK");
		ServerCommand("bot_add_ct %s", "beastik");
		ServerCommand("bot_add_ct %s", "NEOFRAG");
		ServerCommand("mp_teamlogo_1 sinn");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ZEDKO");
		ServerCommand("bot_add_t %s", "CaNNiE");
		ServerCommand("bot_add_t %s", "SHOCK");
		ServerCommand("bot_add_t %s", "beastik");
		ServerCommand("bot_add_t %s", "NEOFRAG");
		ServerCommand("mp_teamlogo_2 sinn");
	}

	return Plugin_Handled;
}

public Action Team_Impact(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));

	if(StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DaneJoris");
		ServerCommand("bot_add_ct %s", "JoJo");
		ServerCommand("bot_add_ct %s", "ERIC");
		ServerCommand("bot_add_ct %s", "Koalanoob");
		ServerCommand("bot_add_ct %s", "insane");
		ServerCommand("mp_teamlogo_1 impa");
	}

	if(StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DaneJoris");
		ServerCommand("bot_add_t %s", "JoJo");
		ServerCommand("bot_add_t %s", "ERIC");
		ServerCommand("bot_add_t %s", "Koalanoob");
		ServerCommand("bot_add_t %s", "insane");
		ServerCommand("mp_teamlogo_2 impa");
	}

	return Plugin_Handled;
}

public Action Team_ERN(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "j1NZO");
		ServerCommand("bot_add_ct %s", "preet");
		ServerCommand("bot_add_ct %s", "ReacTioNNN");
		ServerCommand("bot_add_ct %s", "FreeZe");
		ServerCommand("bot_add_ct %s", "S3NSEY");
		ServerCommand("mp_teamlogo_1 ern");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "j1NZO");
		ServerCommand("bot_add_t %s", "preet");
		ServerCommand("bot_add_t %s", "ReacTioNNN");
		ServerCommand("bot_add_t %s", "FreeZe");
		ServerCommand("bot_add_t %s", "S3NSEY");
		ServerCommand("mp_teamlogo_2 ern");
	}

	return Plugin_Handled;
}

public Action Team_BL4ZE(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Rossi");
		ServerCommand("bot_add_ct %s", "Marzil");
		ServerCommand("bot_add_ct %s", "SkRossi");
		ServerCommand("bot_add_ct %s", "Raph");
		ServerCommand("bot_add_ct %s", "cara");
		ServerCommand("mp_teamlogo_1 bl4ze");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Rossi");
		ServerCommand("bot_add_t %s", "Marzil");
		ServerCommand("bot_add_t %s", "SkRossi");
		ServerCommand("bot_add_t %s", "Raph");
		ServerCommand("bot_add_t %s", "cara");
		ServerCommand("mp_teamlogo_2 bl4ze");
	}

	return Plugin_Handled;
}

public Action Team_Global(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HellrangeR");
		ServerCommand("bot_add_ct %s", "Karam1L");
		ServerCommand("bot_add_ct %s", "hellff");
		ServerCommand("bot_add_ct %s", "DEATHMAKER");
		ServerCommand("bot_add_ct %s", "Lightningfast");
		ServerCommand("mp_teamlogo_1 global");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HellrangeR");
		ServerCommand("bot_add_t %s", "Karam1L");
		ServerCommand("bot_add_t %s", "hellff");
		ServerCommand("bot_add_t %s", "DEATHMAKER");
		ServerCommand("bot_add_t %s", "Lightningfast");
		ServerCommand("mp_teamlogo_2 global");
	}

	return Plugin_Handled;
}

public Action Team_Conquer(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NiNLeX");
		ServerCommand("bot_add_ct %s", "RONDE");
		ServerCommand("bot_add_ct %s", "S1rva");
		ServerCommand("bot_add_ct %s", "jelo");
		ServerCommand("bot_add_ct %s", "KonZero");
		ServerCommand("mp_teamlogo_1 conq");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NiNLeX");
		ServerCommand("bot_add_t %s", "RONDE");
		ServerCommand("bot_add_t %s", "S1rva");
		ServerCommand("bot_add_t %s", "jelo");
		ServerCommand("bot_add_t %s", "KonZero");
		ServerCommand("mp_teamlogo_2 conq");
	}

	return Plugin_Handled;
}

public Action Team_Rooster(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DannyG");
		ServerCommand("bot_add_ct %s", "nettik");
		ServerCommand("bot_add_ct %s", "chelleos");
		ServerCommand("bot_add_ct %s", "ADK");
		ServerCommand("bot_add_ct %s", "asap");
		ServerCommand("mp_teamlogo_1 roos");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DannyG");
		ServerCommand("bot_add_t %s", "nettik");
		ServerCommand("bot_add_t %s", "chelleos");
		ServerCommand("bot_add_t %s", "ADK");
		ServerCommand("bot_add_t %s", "asap");
		ServerCommand("mp_teamlogo_2 roos");
	}

	return Plugin_Handled;
}

public Action Team_Flames(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nicoodoz");
		ServerCommand("bot_add_ct %s", "AcilioN");
		ServerCommand("bot_add_ct %s", "Basso");
		ServerCommand("bot_add_ct %s", "Jabbi");
		ServerCommand("bot_add_ct %s", "Daffu");
		ServerCommand("mp_teamlogo_1 flames");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nicoodoz");
		ServerCommand("bot_add_t %s", "AcilioN");
		ServerCommand("bot_add_t %s", "Basso");
		ServerCommand("bot_add_t %s", "Jabbi");
		ServerCommand("bot_add_t %s", "Daffu");
		ServerCommand("mp_teamlogo_2 flames");
	}

	return Plugin_Handled;
}

public Action Team_Baecon(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "emp");
		ServerCommand("bot_add_ct %s", "vts");
		ServerCommand("bot_add_ct %s", "kst");
		ServerCommand("bot_add_ct %s", "whatz");
		ServerCommand("bot_add_ct %s", "shellzi");
		ServerCommand("mp_teamlogo_1 baec");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "emp");
		ServerCommand("bot_add_t %s", "vts");
		ServerCommand("bot_add_t %s", "kst");
		ServerCommand("bot_add_t %s", "whatz");
		ServerCommand("bot_add_t %s", "shellzi");
		ServerCommand("mp_teamlogo_2 baec");
	}

	return Plugin_Handled;
}

public Action Team_KPI(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pounh");
		ServerCommand("bot_add_ct %s", "SAYN");
		ServerCommand("bot_add_ct %s", "Aaron");
		ServerCommand("bot_add_ct %s", "Butters");
		ServerCommand("bot_add_ct %s", "ztr");
		ServerCommand("mp_teamlogo_1 kpi");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pounh");
		ServerCommand("bot_add_t %s", "SAYN");
		ServerCommand("bot_add_t %s", "Aaron");
		ServerCommand("bot_add_t %s", "Butters");
		ServerCommand("bot_add_t %s", "ztr");
		ServerCommand("mp_teamlogo_2 kpi");
	}

	return Plugin_Handled;
}

public Action Team_hREDS(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "eDi");
		ServerCommand("bot_add_ct %s", "oopee");
		ServerCommand("bot_add_ct %s", "VORMISTO");
		ServerCommand("bot_add_ct %s", "Samppa");
		ServerCommand("bot_add_ct %s", "xartE");
		ServerCommand("mp_teamlogo_1 hreds");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "eDi");
		ServerCommand("bot_add_t %s", "oopee");
		ServerCommand("bot_add_t %s", "VORMISTO");
		ServerCommand("bot_add_t %s", "Samppa");
		ServerCommand("bot_add_t %s", "xartE");
		ServerCommand("mp_teamlogo_2 hreds");
	}

	return Plugin_Handled;
}

public Action Team_Lemondogs(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "xelos");
		ServerCommand("bot_add_ct %s", "kaktus");
		ServerCommand("bot_add_ct %s", "hemzk9");
		ServerCommand("bot_add_ct %s", "Mann3n");
		ServerCommand("bot_add_ct %s", "gamersdont");
		ServerCommand("mp_teamlogo_1 lemon");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xelos");
		ServerCommand("bot_add_t %s", "kaktus");
		ServerCommand("bot_add_t %s", "hemzk9");
		ServerCommand("bot_add_t %s", "Mann3n");
		ServerCommand("bot_add_t %s", "gamersdont");
		ServerCommand("mp_teamlogo_2 lemon");
	}

	return Plugin_Handled;
}

public Action Team_Alpha(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Medi");
		ServerCommand("bot_add_ct %s", "dez1per");
		ServerCommand("bot_add_ct %s", "LeguliaS");
		ServerCommand("bot_add_ct %s", "NolderN");
		ServerCommand("bot_add_ct %s", "fakeZ");
		ServerCommand("mp_teamlogo_1 alpha");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Medi");
		ServerCommand("bot_add_t %s", "dez1per");
		ServerCommand("bot_add_t %s", "LeguliaS");
		ServerCommand("bot_add_t %s", "NolderN");
		ServerCommand("bot_add_t %s", "fakeZ");
		ServerCommand("mp_teamlogo_2 alpha");
	}

	return Plugin_Handled;
}

public Action Team_CeX(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));

	if(strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JackB");
		ServerCommand("bot_add_ct %s", "Impact");
		ServerCommand("bot_add_ct %s", "RezzeD");
		ServerCommand("bot_add_ct %s", "fluFFS");
		ServerCommand("bot_add_ct %s", "ifan");
		ServerCommand("mp_teamlogo_1 cex");
	}

	if(strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JackB");
		ServerCommand("bot_add_t %s", "Impact");
		ServerCommand("bot_add_t %s", "RezzeD");
		ServerCommand("bot_add_t %s", "fluFFS");
		ServerCommand("bot_add_t %s", "ifan");
		ServerCommand("mp_teamlogo_2 cex");
	}

	return Plugin_Handled;
}

public void OnMapStart()
{
	g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	
	GameRules_SetProp("m_bIsValveDS", 1);
	GameRules_SetProp("m_bIsQuestEligible", 1);
	
	GetCurrentMap(g_szMap, sizeof(g_szMap));

	CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, OnThinkPost);
}

public Action Timer_CheckPlayer(Handle hTimer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{
			int iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			bool bInBuyZone = view_as<bool>(GetEntProp(i, Prop_Send, "m_bInBuyZone"));
			
			if(Math_GetRandomInt(1,100) <= 5)
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			
			if(iAccount == 800 && bInBuyZone)
			{
				FakeClientCommand(i, "buy vest");
			}
			else if((iAccount > 3000 || GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY) != -1) && bInBuyZone)
			{
				if(GetEntProp(i, Prop_Data, "m_ArmorValue") < 50 || GetEntProp(i, Prop_Send, "m_bHasHelmet") == 0)
				{
					FakeClientCommand(i, "buy vesthelm");
				}
				
				if (GetClientTeam(i) == CS_TEAM_CT && GetEntProp(i, Prop_Send, "m_bHasDefuser") == 0) 
				{
					FakeClientCommand(i, "buy defuser");
				}
			}
		}
	}	
}

public void OnMapEnd()
{
	SDKUnhook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, OnThinkPost);
}

public void OnClientPostAdminCheck(int client)
{
	g_iProfileRank[client] = Math_GetRandomInt(1,40);

	if(IsValidClient(client) && IsFakeClient(client))
	{
		char szBotName[512];
		GetClientName(client, szBotName, sizeof(szBotName));
		
		Pro_Players(szBotName, client);
		
		SetCustomPrivateRank(client);
		
		g_iUSPChance[client] = Math_GetRandomInt(1,100);
		g_iM4A1SChance[client] = Math_GetRandomInt(1,100);
		
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
}

public void OnRoundStart(Event eEvent, char[] szName, bool bDontBroadcast)
{	
	g_bFreezetimeEnd = false;
	g_bBombPlanted = false;
	g_iRoundStartedTime = GetTime();
	
	
	for (int i = 1; i <= MaxClients; i++)
	{				
		if(IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{
			g_bHasThrownNade[i] = false;
			g_bHasThrownSmoke[i] = false;
			g_iUncrouchChance[i] = Math_GetRandomInt(1,100);
			g_bCanAttack[i] = false;
			g_bCanThrowSmoke[i] = false;
			g_bCanThrowFlash[i] = false;
		}
	}
}

public void OnFreezetimeEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = true;
	
	if(strcmp(g_szMap, "de_mirage") == 0)
	{
		g_iRndExecute = Math_GetRandomInt(1,3);
	}
	else if(strcmp(g_szMap, "de_dust2") == 0)
	{
		g_iRndExecute = Math_GetRandomInt(1,4);
	}
	else if(strcmp(g_szMap, "de_inferno") == 0)
	{
		g_iRndExecute = Math_GetRandomInt(1,3);
	}
	
	int[] clients = new int[MaxClients];

	Client_Get(clients, CLIENTFILTER_TEAMONE);
	
	if(strcmp(g_szMap, "de_mirage") == 0)
	{
		switch(g_iRndExecute)
		{
			case 1:
			{
				g_iSmoke[clients[0]] = 1; //A Execute
				g_iSmoke[clients[1]] = 2; //A Execute
				g_iSmoke[clients[2]] = 3; //A Execute
				g_iSmoke[clients[3]] = 0; //A Execute
				g_iSmoke[clients[4]] = 0; //A Execute
				
				g_iPositionToHold[clients[0]] = 0; //A Execute
				g_iPositionToHold[clients[1]] = 0; //A Execute
				g_iPositionToHold[clients[2]] = 0; //A Execute
				g_iPositionToHold[clients[3]] = 1; //A Execute
				g_iPositionToHold[clients[4]] = 2; //A Execute
				
				int iRampAreaIDs[] = {
					2805, 341, 3507, 2854, 2852
				};
				
				int iPalaceAreaIDs[] = {
					3468, 203, 3465, 96, 3475, 3476, 3463, 147, 146
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iRampAreaIDs[Math_GetRandomInt(0, sizeof(iRampAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iPalaceAreaIDs[Math_GetRandomInt(0, sizeof(iPalaceAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
			}
			case 2:
			{
				g_iSmoke[clients[0]] = 4; //Mid Execute
				g_iSmoke[clients[1]] = 5; //Mid Execute
				g_iSmoke[clients[2]] = 6; //Mid Execute
				g_iSmoke[clients[3]] = 7; //Mid Execute
				g_iSmoke[clients[4]] = 8; //Mid Execute
				
				g_iPositionToHold[clients[0]] = 0; //Mid Execute
				g_iPositionToHold[clients[1]] = 0; //Mid Execute
				g_iPositionToHold[clients[2]] = 0; //Mid Execute
				g_iPositionToHold[clients[3]] = 0; //Mid Execute
				g_iPositionToHold[clients[4]] = 0; //Mid Execute
			}
			case 3:
			{
				g_iSmoke[clients[0]] = 9; //B Execute
				g_iSmoke[clients[1]] = 10; //B Execute
				g_iSmoke[clients[2]] = 11; //B Execute
				g_iSmoke[clients[3]] = 12; //B Execute
				g_iSmoke[clients[4]] = 0; //B Execute
				
				g_iPositionToHold[clients[0]] = 0; //B Execute
				g_iPositionToHold[clients[1]] = 0; //B Execute
				g_iPositionToHold[clients[2]] = 0; //B Execute
				g_iPositionToHold[clients[3]] = 0; //B Execute
				g_iPositionToHold[clients[4]] = 3; //B Execute
				
				int iUnderpassAreaIDs[] = {
					921, 270, 885
				};
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iUnderpassAreaIDs[Math_GetRandomInt(0, sizeof(iUnderpassAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
			}
		}
	}
	else if(strcmp(g_szMap, "de_dust2") == 0)
	{
		switch(g_iRndExecute)
		{
			case 1:
			{
				g_iSmoke[clients[0]] = 1; //B Execute
				g_iSmoke[clients[1]] = 2; //B Execute
				g_iSmoke[clients[2]] = 3; //B Execute
				g_iSmoke[clients[3]] = 0; //B Execute
				g_iSmoke[clients[4]] = 0; //B Execute
				
				g_iPositionToHold[clients[0]] = 0; //B Execute
				g_iPositionToHold[clients[1]] = 0; //B Execute
				g_iPositionToHold[clients[2]] = 0; //B Execute
				g_iPositionToHold[clients[3]] = 1; //B Execute
				g_iPositionToHold[clients[4]] = 2; //B Execute
				
				int iLowerTunnelAreaIDs[] = {
					7998, 8002, 6617, 6659, 8001, 6616, 6668, 6641
				};
				
				int iBAreaIDs[] = {
					8224, 1230, 7957
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iLowerTunnelAreaIDs[Math_GetRandomInt(0, sizeof(iLowerTunnelAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iBAreaIDs[Math_GetRandomInt(0, sizeof(iBAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
			}
			case 2:
			{
				g_iSmoke[clients[0]] = 4; //Mid to B Execute
				g_iSmoke[clients[1]] = 5; //Mid to B Execute
				g_iSmoke[clients[2]] = 0; //Mid to B Execute
				g_iSmoke[clients[3]] = 0; //Mid to B Execute
				g_iSmoke[clients[4]] = 0; //Mid to B Execute
				
				g_iPositionToHold[clients[0]] = 0; //Mid to B Execute
				g_iPositionToHold[clients[1]] = 0; //Mid to B Execute
				g_iPositionToHold[clients[2]] = 3; //Mid to B Execute
				g_iPositionToHold[clients[3]] = 4; //Mid to B Execute
				g_iPositionToHold[clients[4]] = 5; //Mid to B Execute
				
				int iLongPushAreaIDs[] = {
					7789, 7788, 7791, 7801, 7790
				};
				
				int iShortPushAreaIDs[] = {
					8776, 9127, 9126, 317, 8112, 8113
				};
				
				int iMidAreaIDs[] = {
					8020, 5241, 5319, 5268
				};
				
				navArea[clients[2]] = NavMesh_FindAreaByID(iLongPushAreaIDs[Math_GetRandomInt(0, sizeof(iLongPushAreaIDs) - 1)]);
				navArea[clients[2]].GetRandomPoint(g_fHoldPos[clients[2]]);
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iShortPushAreaIDs[Math_GetRandomInt(0, sizeof(iShortPushAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iMidAreaIDs[Math_GetRandomInt(0, sizeof(iMidAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
			}
			case 3:
			{
				g_iSmoke[clients[0]] = 6; //Short A Execute
				g_iSmoke[clients[1]] = 7; //Short A Execute
				g_iSmoke[clients[2]] = 8; //Short A Execute
				g_iSmoke[clients[3]] = 9; //Short A Execute
				g_iSmoke[clients[4]] = 0; //Short A Execute
				
				g_iPositionToHold[clients[0]] = 0; //Short A Execute
				g_iPositionToHold[clients[1]] = 0; //Short A Execute
				g_iPositionToHold[clients[2]] = 0; //Short A Execute
				g_iPositionToHold[clients[3]] = 0; //Short A Execute
				g_iPositionToHold[clients[4]] = 6; //Short A Execute
				
				int iMidAreaIDs[] = {
					7566, 7558, 4051, 7581, 4139
				};
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iMidAreaIDs[Math_GetRandomInt(0, sizeof(iMidAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
			}
			case 4:
			{
				g_iSmoke[clients[0]] = 10; //Long A Execute
				g_iSmoke[clients[1]] = 11; //Long A Execute
				g_iSmoke[clients[2]] = 12; //Long A Execute
				g_iSmoke[clients[3]] = 0; //Long A Execute
				g_iSmoke[clients[4]] = 0; //Long A Execute
				
				g_iPositionToHold[clients[0]] = 0; //Long A Execute
				g_iPositionToHold[clients[1]] = 0; //Long A Execute
				g_iPositionToHold[clients[2]] = 0; //Long A Execute
				g_iPositionToHold[clients[3]] = 7; //Long A Execute
				g_iPositionToHold[clients[4]] = 8; //Long A Execute
				
				int iMidPushAreaIDs[] = {
					7342, 7343, 7348, 5370
				};
				
				int iLongAreaIDs[] = {
					3661, 9156, 9155, 3698, 9154, 9153, 3659
				};
				
				navArea[clients[3]] = NavMesh_FindAreaByID(iMidPushAreaIDs[Math_GetRandomInt(0, sizeof(iMidPushAreaIDs) - 1)]);
				navArea[clients[3]].GetRandomPoint(g_fHoldPos[clients[3]]);
				
				navArea[clients[4]] = NavMesh_FindAreaByID(iLongAreaIDs[Math_GetRandomInt(0, sizeof(iLongAreaIDs) - 1)]);
				navArea[clients[4]].GetRandomPoint(g_fHoldPos[clients[4]]);
			}
		}
	}
	else if(strcmp(g_szMap, "de_inferno") == 0)
	{
		switch(g_iRndExecute)
		{
			case 1:
			{
				g_iSmoke[clients[0]] = 1; //B Execute
				g_iSmoke[clients[1]] = 2; //B Execute
				g_iSmoke[clients[2]] = 0; //B Execute
				g_iSmoke[clients[3]] = 0; //B Execute
				g_iSmoke[clients[4]] = 0; //B Execute
				
				g_iPositionToHold[clients[0]] = 0; //B Execute
				g_iPositionToHold[clients[1]] = 0; //B Execute
				g_iPositionToHold[clients[2]] = 1; //B Execute
				g_iPositionToHold[clients[3]] = 2; //B Execute
				g_iPositionToHold[clients[4]] = 3; //B Execute
			}
			case 2:
			{
				g_iSmoke[clients[0]] = 3; //A Short/Apps Execute
				g_iSmoke[clients[1]] = 4; //A Short/Apps Execute
				g_iSmoke[clients[2]] = 5; //A Short/Apps Execute
				g_iSmoke[clients[3]] = 6; //A Short/Apps Execute
				g_iSmoke[clients[4]] = 0; //A Short/Apps Execute
				
				g_iPositionToHold[clients[0]] = 0; //B Execute
				g_iPositionToHold[clients[1]] = 0; //B Execute
				g_iPositionToHold[clients[2]] = 0; //B Execute
				g_iPositionToHold[clients[3]] = 0; //B Execute
				g_iPositionToHold[clients[4]] = 4; //B Execute
			}
			case 3:
			{
				g_iSmoke[clients[0]] = 7; //A Long Execute
				g_iSmoke[clients[1]] = 8; //A Long Execute
				g_iSmoke[clients[2]] = 9; //A Long Execute
				g_iSmoke[clients[3]] = 10; //A Long Execute
				g_iSmoke[clients[4]] = 0; //A Long Execute
				
				g_iPositionToHold[clients[0]] = 0; //B Execute
				g_iPositionToHold[clients[1]] = 0; //B Execute
				g_iPositionToHold[clients[2]] = 0; //B Execute
				g_iPositionToHold[clients[3]] = 0; //B Execute
				g_iPositionToHold[clients[4]] = 4; //B Execute
			}
		}
	}
}

public void OnBombPlanted(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	g_bBombPlanted = true;
}

public void OnBombDefusedOrExploded(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	g_bBombPlanted = false;
}

public void OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS+1);
}

public Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(IsValidClient(victim) && IsFakeClient(victim))
	{
		g_bCanAttack[victim] = true;
	}
}

public Action CS_OnBuyCommand(int client, const char[] szWeapon)
{
	if(IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
	{	
		if(strcmp(szWeapon, "molotov") == 0 || strcmp(szWeapon, "incgrenade") == 0 || strcmp(szWeapon, "decoy") == 0 || strcmp(szWeapon, "flashbang") == 0 || strcmp(szWeapon, "hegrenade") == 0
		|| strcmp(szWeapon, "smokegrenade") == 0 || strcmp(szWeapon, "vest") == 0 || strcmp(szWeapon, "vesthelm") == 0 || strcmp(szWeapon, "defuser") == 0)
		{
			return Plugin_Continue;
		}
		else if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1 && (strcmp(szWeapon, "galilar") == 0 || strcmp(szWeapon, "famas") == 0 || strcmp(szWeapon, "ak47") == 0
		|| strcmp(szWeapon, "m4a1") == 0	|| strcmp(szWeapon, "ssg08") == 0 || strcmp(szWeapon, "aug") == 0 || strcmp(szWeapon, "sg556") == 0 || strcmp(szWeapon, "awp") == 0
		|| strcmp(szWeapon, "scar20") == 0 || strcmp(szWeapon, "g3sg1") == 0 || strcmp(szWeapon, "nova") == 0 || strcmp(szWeapon, "xm1014") == 0 || strcmp(szWeapon, "mag7") == 0
		|| strcmp(szWeapon, "m249") == 0 || strcmp(szWeapon, "negev") == 0 || strcmp(szWeapon, "mac10") == 0 || strcmp(szWeapon, "mp9") == 0 || strcmp(szWeapon, "mp7") == 0
		|| strcmp(szWeapon, "ump45") == 0 || strcmp(szWeapon, "p90") == 0 || strcmp(szWeapon, "bizon") == 0))
		{
			return Plugin_Handled;
		}
	
		int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		
		if(strcmp(szWeapon, "m4a1") == 0)
		{
			if(g_iM4A1SChance[client] <= 30)
			{
				CSGO_SetMoney(client, iAccount - 2900);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_m4a1_silencer");
				
				return Plugin_Changed; 
			}
			
			if(Math_GetRandomInt(1,100) <= 5)
			{
				CSGO_SetMoney(client, iAccount - 3300);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_aug");
				
				return Plugin_Changed; 
			}
			
			return Plugin_Continue;
		}
		else if(strcmp(szWeapon, "ak47") == 0)
		{
			if(Math_GetRandomInt(1,100) <= 5)
			{
				CSGO_SetMoney(client, iAccount - 3000);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_sg556");
				
				return Plugin_Changed; 
			}
		}
		else if(strcmp(szWeapon, "mac10") == 0)
		{
			if(Math_GetRandomInt(1,100) <= 40)
			{
				CSGO_SetMoney(client, iAccount - 1800);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_galilar");
				
				return Plugin_Changed; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if(strcmp(szWeapon, "mp9") == 0)
		{
			if(Math_GetRandomInt(1,100) <= 40)
			{
				CSGO_SetMoney(client, iAccount - 2050);
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_famas");
				
				return Plugin_Changed; 
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}

public MRESReturn Detour_OnBOTBlind(Handle hParams)
{
	if(DHookGetParam(hParams, 2) < 2.0)
	{
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

public MRESReturn Detour_OnBOTSetLookAt(Handle hParams)
{
	char szDesc[64];
	
	DHookGetParamString(hParams, 1, szDesc, sizeof(szDesc));
	
	if(strcmp(szDesc, "Defuse bomb") == 0 || strcmp(szDesc, "Use entity") == 0 || strcmp(szDesc, "Open door") == 0 || strcmp(szDesc, "Breakable") == 0 
	|| strcmp(szDesc, "Hostage") == 0 || strcmp(szDesc, "Avoid Flashbang") == 0 || strcmp(szDesc, "Plant bomb on floor") == 0)
	{
		return MRES_Ignored;
	}
	else if(strcmp(szDesc, "GrenadeThrowBend") == 0)
	{
		float fPos[3];
		
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += Math_GetRandomFloat(25.0, 75.0);
		DHookSetParamVector(hParams, 2, fPos);
		
		return MRES_ChangedHandled;
	}
	else
	{
		float fPos[3];
		
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += 30.0;
		DHookSetParamVector(hParams, 2, fPos);
		
		return MRES_ChangedHandled;
	}
}

public Action OnPlayerRunCmd(int client, int& iButtons, int& iImpulse, float fVel[3], float fAngles[3], int& iWeapon, int& iSubtype, int& iCmdNum, int& iTickCount, int& iSeed, int iMouse[2])
{
	if (!IsFakeClient(client)) return Plugin_Continue;
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	if (iActiveWeapon == -1)  return Plugin_Continue;
	
	int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !eItems_IsDefIndexKnife(iDefIndex))
		{
			FakeClientCommandEx(client, "use weapon_knife");
		}
		
		float fClientLoc[3];
		
		GetClientAbsOrigin(client, fClientLoc);
		
		CNavArea currAea = NavMesh_GetNearestArea(fClientLoc);
		
		if(currAea.Attributes & NAV_MESH_WALK)
		{
			iButtons |= IN_SPEED;
			return Plugin_Changed;
		}
		
		if(currAea.Attributes & NAV_MESH_RUN)
		{
			iButtons &= ~IN_SPEED;
			return Plugin_Changed;
		}

		char szBotName[128];
		GetClientName(client, szBotName, sizeof(szBotName));
		
		for(int i = 0; i <= sizeof(g_szBotName) - 1; i++)
		{
			if(strcmp(szBotName, g_szBotName[i]) == 0)
			{				
				float fClientEyes[3], fTargetEyes[3];
				GetClientEyePosition(client, fClientEyes);
				int iEnt = GetClosestClient(client);
				
				if(iEnt == -1)
				{
					g_bCanAttack[client] = false;
				}
				
				if(IsValidClient(iEnt) && g_bFreezetimeEnd && g_bCanAttack[client])
				{
					if(eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE && GetEntityMoveType(client) != MOVETYPE_LADDER)
					{
						BotEquipBestWeapon(client, true);
					}
					
					if(Weapon_IsReloading(iActiveWeapon))
					{
						if(Math_GetRandomInt(1,100) <= 50)
						{
							moveSide(fVel, 250.0);
						}
						else
						{
							moveSide2(fVel, 250.0);
						}
					}
					
					if(GetEntityMoveType(client) == MOVETYPE_LADDER)
					{
						return Plugin_Continue;
					}
					
					if((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_PRIMARY && iDefIndex != 40 && iDefIndex != 11 && iDefIndex != 38 && iDefIndex != 9 && iDefIndex != 27 && iDefIndex != 29 && iDefIndex != 35) || iDefIndex == 63)
					{
						if(Math_GetRandomInt(1,4) == 1)
						{
							int iBone = LookupBone(iEnt, "head_0");
							if(iBone < 0)
								return Plugin_Continue;
								
							float fHead[3], fBad[3];
							GetBonePosition(iEnt, iBone, fHead, fBad);
							
							fTargetEyes = fHead;
						}
						else
						{
							int iBone = LookupBone(iEnt, "spine_2");
							
							if(iBone < 0)
								return Plugin_Continue;
								
							float fBody[3], fBad[3];
							GetBonePosition(iEnt, iBone, fBody, fBad);
							
							if(BotIsVisible(client, fBody, false, -1))
							{
								fTargetEyes = fBody;
							}
							else
							{
								iBone = LookupBone(iEnt, "head_0");
								if(iBone < 0)
									return Plugin_Continue;
									
								float fHead[3];
								GetBonePosition(iEnt, iBone, fHead, fBad);
								
								fTargetEyes = fHead;
							}
						}	
						
						if(IsTargetInSightRange(client, iEnt, 10.0) && GetVectorDistance(fClientEyes, fTargetEyes) < 2000.0 && !Weapon_IsReloading(iActiveWeapon))
						{
							iButtons |= IN_ATTACK;
						}
						
						if(iButtons & IN_ATTACK && !(GetEntityFlags(client) & FL_DUCKING))
						{
							fVel[0] = 0.0;
							fVel[1] = 0.0;
							fVel[2] = 0.0;
						}
					}
					else if((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_SECONDARY && iDefIndex != 63 && iDefIndex != 1) || iDefIndex == 27 || iDefIndex == 29 || iDefIndex == 35)
					{
						if(Math_GetRandomInt(1,4) == 1)
						{
							int iBone = LookupBone(iEnt, "head_0");
							if(iBone < 0)
								return Plugin_Continue;
								
							float fHead[3], fBad[3];
							GetBonePosition(iEnt, iBone, fHead, fBad);
							
							fTargetEyes = fHead;
						}
						else
						{
							int iBone = LookupBone(iEnt, "spine_2");
							
							if(iBone < 0)
								return Plugin_Continue;
								
							float fBody[3], fBad[3];
							GetBonePosition(iEnt, iBone, fBody, fBad);
							
							if(BotIsVisible(client, fBody, false, -1))
							{
								fTargetEyes = fBody;
							}
							else
							{
								iBone = LookupBone(iEnt, "head_0");
								if(iBone < 0)
									return Plugin_Continue;
									
								float fHead[3];
								GetBonePosition(iEnt, iBone, fHead, fBad);
								
								fTargetEyes = fHead;
							}
						}
						
						if(Math_GetRandomInt(1,100) <= 50)
						{
							moveSide(fVel, 250.0);
						}
						else
						{
							moveSide2(fVel, 250.0);
						}
					}
					else if(iDefIndex == 1)
					{
						int iBone = LookupBone(iEnt, "head_0");
						if(iBone < 0)
							return Plugin_Continue;
							
						float fHead[3], fBad[3];
						GetBonePosition(iEnt, iBone, fHead, fBad);
						
						fTargetEyes = fHead;	
						
						if(iButtons & IN_ATTACK && !(GetEntityFlags(client) & FL_DUCKING))
						{
							fVel[0] = 0.0;
							fVel[1] = 0.0;
							fVel[2] = 0.0;
						}
					}
					else if(iDefIndex == 40 || iDefIndex == 11 || iDefIndex == 38)
					{
						if(Math_GetRandomInt(1,4) == 1)
						{
							int iBone = LookupBone(iEnt, "head_0");
							if(iBone < 0)
								return Plugin_Continue;
								
							float fHead[3], fBad[3];
							GetBonePosition(iEnt, iBone, fHead, fBad);
							
							fTargetEyes = fHead;
						}
						else
						{
							int iBone = LookupBone(iEnt, "spine_2");
							
							if(iBone < 0)
								return Plugin_Continue;
								
							float fBody[3], fBad[3];
							GetBonePosition(iEnt, iBone, fBody, fBad);
							
							if(BotIsVisible(client, fBody, false, -1))
							{
								fTargetEyes = fBody;
							}
							else
							{
								iBone = LookupBone(iEnt, "head_0");
								if(iBone < 0)
									return Plugin_Continue;
									
								float fHead[3];
								GetBonePosition(iEnt, iBone, fHead, fBad);
								
								fTargetEyes = fHead;
							}
						}
					}
					else if(iDefIndex == 9)
					{							
						int iBone = LookupBone(iEnt, "spine_2");
						if(iBone < 0)
							return Plugin_Continue;
							
						float fBody[3], fBad[3];
						GetBonePosition(iEnt, iBone, fBody, fBad);
						
						if(BotIsVisible(client, fBody, false, -1))
						{
							fTargetEyes = fBody;
						}
						else
						{
							iBone = LookupBone(iEnt, "head_0");
							if(iBone < 0)
								return Plugin_Continue;
								
							float fHead[3];
							GetBonePosition(iEnt, iBone, fHead, fBad);
							
							fTargetEyes = fHead;
						}
					}
					else
					{
						return Plugin_Continue;
					}

					float flAng[3];
					GetClientEyeAngles(client, flAng);
					
					// get normalised direction from target to client
					float desired_dir[3];
					MakeVectorFromPoints(fClientEyes, fTargetEyes, desired_dir);
					GetVectorAngles(desired_dir, desired_dir);
					
					// ease the current direction to the target direction
					flAng[0] += AngleNormalize(desired_dir[0] - flAng[0]);
					flAng[1] += AngleNormalize(desired_dir[1] - flAng[1]);

					float fPunchAngle[3];
					
					GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", fPunchAngle);
					
					if(g_cvPredictionConVar != null)
					{
						flAng[0] -= fPunchAngle[0] * GetConVarFloat(g_cvPredictionConVar);
						flAng[1] -= fPunchAngle[1] * GetConVarFloat(g_cvPredictionConVar);
					}
					
					if(IsTargetInSightRange(client, iEnt, 5.0))
					{
						TeleportEntity(client, NULL_VECTOR, flAng, NULL_VECTOR);
					}
					else
					{
						TF2_LookAtPos(client, fTargetEyes, Math_GetRandomFloat(0.01, 0.30));
					}
					
					BotAttack(client, iEnt);
					
					if (iButtons & IN_ATTACK && (iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28))
					{
						iButtons |= IN_DUCK;
						return Plugin_Changed;
					}
					
					return Plugin_Changed;
				}
				
				if(BotIsHiding(client) && g_iUncrouchChance[client] <= 50)
				{
					iButtons &= ~IN_DUCK;
					return Plugin_Changed;
				}
				
				int iPlantedC4 = GetNearestEntity(client, "planted_c4");
				
				if(IsValidEntity(iPlantedC4) && GetClientTeam(client) == CS_TEAM_CT)
				{
					float fPlantedC4Location[3];
					GetEntPropVector(iPlantedC4, Prop_Send, "m_vecOrigin", fPlantedC4Location);
					
					float fClientLocation[3];
					GetClientAbsOrigin(client, fClientLocation);

					float fPlantedC4Distance;					
					
					fPlantedC4Distance = GetVectorDistance(fClientLocation, fPlantedC4Location);
					
					if(fPlantedC4Distance > 1500.0 && !BotIsBusy(client) && GetClosestClient(client) == -1 && !eItems_IsDefIndexKnife(iDefIndex))
					{
						FakeClientCommandEx(client, "use weapon_knife");
					}
				}
				
				int iHostage = GetNearestEntity(client, "hostage_entity");
				float fHostageDistance;
				
				if(IsValidEntity(iHostage) && GetClientTeam(client) == CS_TEAM_CT)
				{
					float fHostageLocation[3];
					GetEntPropVector(iHostage, Prop_Send, "m_vecOrigin", fHostageLocation);
					
					float fClientLocation[3];
					GetClientAbsOrigin(client, fClientLocation);		
					
					fHostageDistance = GetVectorDistance(fClientLocation, fHostageLocation);
				}
				
				if(g_bFreezetimeEnd && !g_bBombPlanted && !BotIsBusy(client) && !BotIsHiding(client) && (fHostageDistance > 100.0 || !IsValidEntity(iHostage)))
				{
					//Rifles
					int iAK47 = GetNearestEntity(client, "weapon_ak47"); 
					int iM4A1 = GetNearestEntity(client, "weapon_m4a1"); 
					int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					int iPrimaryDefIndex;
					
					if(IsValidEntity(iAK47))
					{
						float fAK47Location[3];
						
						if(iPrimary != -1)
						{
							iPrimaryDefIndex = GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex");
						}

						if(iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9)
						{
							GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);
							
							if(fAK47Location[0] != 0.0 && fAK47Location[1] != 0.0 && fAK47Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);

								if(GetVectorDistance(fClientLocation, fAK47Location) < 500.0)
								{
									BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
								}
							}
						}
						else if(iPrimary == -1)
						{
							GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);		
							
							if(fAK47Location[0] != 0.0 && fAK47Location[1] != 0.0 && fAK47Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);		

								if(GetVectorDistance(fClientLocation, fAK47Location) < 500.0)
								{
									BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
								}
							}
						}
					}
					
					if(IsValidEntity(iM4A1))
					{
						float fM4A1Location[3];
						
						if(iPrimary != -1)
						{
							iPrimaryDefIndex = GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex");
						}

						if(iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9 && iPrimaryDefIndex != 16 && iPrimaryDefIndex != 60)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);
							
							if(fM4A1Location[0] != 0.0 && fM4A1Location[1] != 0.0 && fM4A1Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);

								if(GetVectorDistance(fClientLocation, fM4A1Location) < 500.0)
								{
									BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
									
									if(GetVectorDistance(fClientLocation, fM4A1Location) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
									{
										CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), false, false);
									}
								}
							}
						}
						else if(iPrimary == -1)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);		
							
							if(fM4A1Location[0] != 0.0 && fM4A1Location[1] != 0.0 && fM4A1Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);

								if(GetVectorDistance(fClientLocation, fM4A1Location) < 500.0)
								{
									BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
								}
							}
						}
					}
					
					//Pistols
					int iUSP = GetNearestEntity(client, "weapon_hkp2000"); 
					int iP250 = GetNearestEntity(client, "weapon_p250"); 
					int iFiveSeven = GetNearestEntity(client, "weapon_fiveseven"); 
					int iTec9 = GetNearestEntity(client, "weapon_tec9"); 
					int iDeagle = GetNearestEntity(client, "weapon_deagle"); 
					int iSecondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					int iSecondaryDefIndex;
					
					if(IsValidEntity(iDeagle))
					{
						float fDeagleLocation[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36 || iSecondaryDefIndex == 30 || iSecondaryDefIndex == 3 || iSecondaryDefIndex == 63)
						{
							GetEntPropVector(iDeagle, Prop_Send, "m_vecOrigin", fDeagleLocation);	
							
							if(fDeagleLocation[0] != 0.0 && fDeagleLocation[1] != 0.0 && fDeagleLocation[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								if(GetVectorDistance(fClientLocation, fDeagleLocation) < 500.0)
								{
									BotMoveTo(client, fDeagleLocation, FASTEST_ROUTE);
									
									if(GetVectorDistance(fClientLocation, fDeagleLocation) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									{
										CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
									}
								}
							}
						}
					}
					
					if(IsValidEntity(iTec9))
					{
						float fTec9Location[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
						{
							GetEntPropVector(iTec9, Prop_Send, "m_vecOrigin", fTec9Location);	
							
							if(fTec9Location[0] != 0.0 && fTec9Location[1] != 0.0 && fTec9Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);
								
								if(GetVectorDistance(fClientLocation, fTec9Location) < 500.0)
								{
									BotMoveTo(client, fTec9Location, FASTEST_ROUTE);
									
									if(GetVectorDistance(fClientLocation, fTec9Location) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									{
										CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
									}
								}
							}
						}
					}
					
					if(IsValidEntity(iFiveSeven))
					{
						float fFiveSevenLocation[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
						{
							GetEntPropVector(iFiveSeven, Prop_Send, "m_vecOrigin", fFiveSevenLocation);	
							
							if(fFiveSevenLocation[0] != 0.0 && fFiveSevenLocation[1] != 0.0 && fFiveSevenLocation[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								if(GetVectorDistance(fClientLocation, fFiveSevenLocation) < 500.0)
								{
									BotMoveTo(client, fFiveSevenLocation, FASTEST_ROUTE);
									
									if(GetVectorDistance(fClientLocation, fFiveSevenLocation) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									{
										CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
									}
								}
							}
						}
					}
					
					if(IsValidEntity(iP250))
					{
						float fP250Location[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61)
						{
							GetEntPropVector(iP250, Prop_Send, "m_vecOrigin", fP250Location);	
							
							if(fP250Location[0] != 0.0 && fP250Location[1] != 0.0 && fP250Location[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);
								
								if(GetVectorDistance(fClientLocation, fP250Location) < 500.0)
								{
									BotMoveTo(client, fP250Location, FASTEST_ROUTE);
									
									if(GetVectorDistance(fClientLocation, fP250Location) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									{
										CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
									}
								}
							}
						}
					}
					
					if(IsValidEntity(iUSP))
					{
						float fUSPLocation[3];
						
						if(iSecondary != -1)
						{
							iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
						}	
						
						if(iSecondaryDefIndex == 4)
						{
							GetEntPropVector(iUSP, Prop_Send, "m_vecOrigin", fUSPLocation);	
							
							if(fUSPLocation[0] != 0.0 && fUSPLocation[1] != 0.0 && fUSPLocation[2] != 0.0)
							{
								float fClientLocation[3];
								GetClientAbsOrigin(client, fClientLocation);	
								
								if(GetVectorDistance(fClientLocation, fUSPLocation) < 500.0)
								{
									BotMoveTo(client, fUSPLocation, FASTEST_ROUTE);
									
									if(GetVectorDistance(fClientLocation, fUSPLocation) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									{
										CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
									}
								}
							}
						}
					}
				}
				
				if (g_bFreezetimeEnd && !g_bBombPlanted && (GetTotalRoundTime() - GetCurrentRoundTime() >= 60) && GetClientTeam(client) == CS_TEAM_T && !g_bHasThrownNade[client] && GetAliveTeamCount(CS_TEAM_T) >= 3)
				{					
					if(strcmp(g_szMap, "de_mirage") == 0)
					{
						DoMirageSmokes(client);
					}
					else if(strcmp(g_szMap, "de_dust2") == 0)
					{
						DoDust2Smokes(client);
					}
					else if(strcmp(g_szMap, "de_inferno") == 0)
					{
						DoInfernoSmokes(client);
					}
				}
			}
		}
	}

	return Plugin_Changed;
}

public void CSU_OnThrowGrenade(int client, int iEntity, GrenadeType grenadeType, const float fOrigin[3], const float fVelocity[3])
{
	if(IsValidClient(client))
	{
		PrintToChat(client, "float fOrigin[3] = { %f, %f, %f };", fOrigin[0], fOrigin[1], fOrigin[2]);
		PrintToChat(client, "float fVelocity[3] = { %f, %f, %f };", fVelocity[0], fVelocity[1], fVelocity[2]);
	}
}

public void OnPlayerSpawn(Handle hEvent, const char[] szName, bool bDontBroadcast) 
{
	for (int i = 1; i <= MaxClients; i++)
	{		
		if(IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{			
			CreateTimer(1.0, RFrame_CheckBuyZoneValue, GetClientSerial(i)); 
			
			if(g_iUSPChance[i] >= 25)
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					char szUSP[32];
					
					GetClientWeapon(i, szUSP, sizeof(szUSP));

					if(strcmp(szUSP, "weapon_hkp2000") == 0)
					{
						CSGO_ReplaceWeapon(i, CS_SLOT_SECONDARY, "weapon_usp_silencer");
					}
				}
			}
		}
	}
}

public Action RFrame_CheckBuyZoneValue(Handle hTimer, int iSerial) 
{
	int client = GetClientFromSerial(iSerial);

	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
	int iTeam = GetClientTeam(client);
	if (iTeam < 2) return Plugin_Stop;

	int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	
	bool bInBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
	
	if (!bInBuyZone) return Plugin_Stop;
	
	int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	
	char szDefaultPrimary[64];
	GetClientWeapon(client, szDefaultPrimary, sizeof(szDefaultPrimary));

	if((iAccount > 2000) && (iAccount < 3000) && iPrimary == -1 && (strcmp(szDefaultPrimary, "weapon_hkp2000") == 0 || strcmp(szDefaultPrimary, "weapon_usp_silencer") == 0 || strcmp(szDefaultPrimary, "weapon_glock") == 0))
	{		
		int iRndPistol = Math_GetRandomInt(1,3);
		
		switch(iRndPistol)
		{
			case 1:
			{
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_p250");
			}
			case 2:
			{
				if(iTeam == CS_TEAM_CT)
				{
					int iCZ = Math_GetRandomInt(1,2);
					
					switch(iCZ)
					{
						case 1:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_fiveseven");
						}
						case 2:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_cz75a");
						}
					}
				}
				else if(iTeam == CS_TEAM_T)
				{
					int iCZ = Math_GetRandomInt(1,2);
					
					switch(iCZ)
					{
						case 1:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_tec9");
						}
						case 2:
						{
							CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_cz75a");
						}
					}
				}
			}
			case 3:
			{
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_deagle");
			}
		}
	}
	return Plugin_Stop;
}

public void OnClientDisconnect(int client)
{
	if(IsValidClient(client) && IsFakeClient(client))
	{
		g_iProfileRank[client] = 0;
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
}

public void eItems_OnItemsSynced()
{	
	ServerCommand("changelevel %s", g_szMap);
}

public void LoadSDK()
{
	Handle hGameConfig = LoadGameConfigFile("botstuff.games");
	if (hGameConfig == INVALID_HANDLE)
		SetFailState("Failed to find botstuff.games game config.");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::MoveTo");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer); // Move Position As Vector, Pointer
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // Move Type As Integer
	if ((g_hBotMoveTo = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::MoveTo signature!");	
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBaseAnimating::LookupBone");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::LookupBone signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::GetBonePosition signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::Attack");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	if ((g_hBotAttack = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::Attack signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsVisible");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsVisible = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::IsVisible signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsBusy");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsBusy = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::IsBusy signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsAtHidingSpot");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsHiding = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::IsAtHidingSpot signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::EquipBestWeapon");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotEquipBestWeapon = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::EquipBestWeapon signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::SetLookAt");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotSetLookAt = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::SetLookAt signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::BendLineOfSight");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	if ((g_hBotBendLineOfSight = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CCSBot::BendLineOfSight signature!");
	
	delete hGameConfig;
}

public void LoadDetours()
{
	Handle hGameData = LoadGameConfigFile("botstuff.games");
	if (!hGameData)
	{
		SetFailState("Failed to load botstuff gamedata.");
		return;
	}
	
	g_hBOTBlindDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
	if (!g_hBOTBlindDetour)
		SetFailState("Failed to setup detour for CCSBot::Blind");

	if (!DHookSetFromConf(g_hBOTBlindDetour, hGameData, SDKConf_Signature, "CCSBot::Blind"))
		SetFailState("Failed to load CCSBot::Blind signature from gamedata");

	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // holdTime
	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // fadeTime
	DHookAddParam(g_hBOTBlindDetour, HookParamType_Float); // startingAlpha
	
	if (!DHookEnableDetour(g_hBOTBlindDetour, false, Detour_OnBOTBlind))
		SetFailState("Failed to detour CCSBot::Blind.");
	
	g_hBOTSetLookAtDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
	if (!g_hBOTSetLookAtDetour)
		SetFailState("Failed to setup detour for CCSBot::SetLookAt");

	if (!DHookSetFromConf(g_hBOTSetLookAtDetour, hGameData, SDKConf_Signature, "CCSBot::SetLookAt"))
		SetFailState("Failed to load CCSBot::SetLookAt signature from gamedata");
		
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_CharPtr); // desc
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_VectorPtr); // pos
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Int); // pri
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Float); // duration
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Bool); // clearIfClose
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Float); // angleTolerance
	DHookAddParam(g_hBOTSetLookAtDetour, HookParamType_Bool); // attack
	
	if (!DHookEnableDetour(g_hBOTSetLookAtDetour, false, Detour_OnBOTSetLookAt))
		SetFailState("Failed to detour CCSBot::SetLookAt.");
		
	delete hGameData;
}

public void BotMoveTo(int client, float fOrigin[3], RouteType routeType)
{
	SDKCall(g_hBotMoveTo, client, fOrigin, routeType);
}

public void BotAttack(int client, int iEnemy)
{
	SDKCall(g_hBotAttack, client, iEnemy);
}

public bool BotIsVisible(int client, float fPos[3], bool bTestFOV, int iIgnore)
{
	return SDKCall(g_hBotIsVisible, client, fPos, bTestFOV, iIgnore);
}

public bool BotIsBusy(int client)
{
	return SDKCall(g_hBotIsBusy, client);
}

public bool BotIsHiding(int client)
{
	return SDKCall(g_hBotIsHiding, client);
}

public int BotEquipBestWeapon(int client, bool bMustEquip)
{
	SDKCall(g_hBotEquipBestWeapon, client, bMustEquip);
}

public int BotSetLookAt(int client, const char[] szDesc, const float fPos[3], PriorityType pri, float fDuration, bool bClearIfClose, float fAngleTolerance, bool bAttack)
{
	SDKCall(g_hBotSetLookAt, client, szDesc, fPos, pri, fDuration, bClearIfClose, fAngleTolerance, bAttack);
}

public int BotBendLineOfSight(int client, const float fEye[3], const float fTarget[3], float fBend[3], float fAngleLimit)
{
	SDKCall(g_hBotBendLineOfSight, client, fEye, fTarget, fBend, fAngleLimit);
}

public int LookupBone(int iEntity, const char[] szName)
{
	return SDKCall(g_hLookupBone, iEntity, szName);
}

public void GetBonePosition(int iEntity, int iBone, float fOrigin[3], float fAngles[3])
{
	SDKCall(g_hGetBonePosition, iEntity, iBone, fOrigin, fAngles);
}

public int GetNearestEntity(int client, char[] szClassname)
{
    int iNearestEntity = -1;
    float fClientOrigin[3], fEntityOrigin[3];
    
    GetEntPropVector(client, Prop_Data, "m_vecOrigin", fClientOrigin); // Line 2607
    
    //Get the distance between the first entity and client
    float fDistance, fNearestDistance = -1.0;
    
    //Find all the entity and compare the distances
    int iEntity = -1;
    while ((iEntity = FindEntityByClassname(iEntity, szClassname)) != -1)
    {
        GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fEntityOrigin); // Line 2610
        fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
        
        if (fDistance < fNearestDistance || fNearestDistance == -1.0)
        {
            iNearestEntity = iEntity;
            fNearestDistance = fDistance;
        }
    }
    
    return iNearestEntity;
}

float moveSide(float fVel[3], float fMaxSpeed)
{
	fVel[1] = fMaxSpeed;
	return fVel;
}

float moveSide2(float fVel[3],float fMaxSpeed)
{
	fVel[1] = -fMaxSpeed;
	return fVel;
}

stock void CSGO_SetMoney(int client, int iAmount)
{
	if (iAmount < 0)
		iAmount = 0;
	
	int iMax = FindConVar("mp_maxmoney").IntValue;
	
	if (iAmount > iMax)
		iAmount = iMax;
	
	SetEntProp(client, Prop_Send, "m_iAccount", iAmount);
}

stock int CSGO_ReplaceWeapon(int client, int iSlot, const char[] szClass)
{
	int iWeapon = GetPlayerWeaponSlot(client, iSlot);

	if (IsValidEntity(iWeapon))
	{
		if (GetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity") != client)
			SetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity", client);

		CS_DropWeapon(client, iWeapon, false, true);
		AcceptEntityInput(iWeapon, "Kill");
	}

	iWeapon = GivePlayerItem(client, szClass);

	if (IsValidEntity(iWeapon))
		EquipPlayerWeapon(client, iWeapon);

	return iWeapon;
}

stock int GetTotalRoundTime()
{
	return GameRules_GetProp("m_iRoundTime");
}

stock int GetCurrentRoundTime() 
{
	Handle hFreezeTime = FindConVar("mp_freezetime"); // Freezetime Handle
	int iFreezeTime = GetConVarInt(hFreezeTime); // Freezetime in seconds (5 by default)
	return (GetTime() - g_iRoundStartedTime) - iFreezeTime;
}

stock int GetClosestClient(int client)
{
	float fClientOrigin[3], fTargetOrigin[3];
	
	GetClientAbsOrigin(client, fClientOrigin);
	
	int iClientTeam = GetClientTeam(client);
	int iClosestTarget = -1;
	
	float fClosestDistance = -1.0;
	float fTargetDistance;
	char szClanTag[64];
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
	int iDefIndex;
	if (iActiveWeapon != -1)
	{
		iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	}
	
	CS_GetClientClanTag(client, szClanTag, sizeof(szClanTag));
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (client == i || GetClientTeam(i) == iClientTeam || !IsPlayerAlive(i))
			{
				continue;
			}
			
			GetClientAbsOrigin(i, fTargetOrigin);
			fTargetDistance = GetVectorDistance(fClientOrigin, fTargetOrigin);

			if (fTargetDistance > fClosestDistance && fClosestDistance > -1.0)
			{
				continue;
			}

			if (!ClientCanSeeTarget(client, i))
			{
				continue;
			}

			if (GetEngineVersion() == Engine_CSGO)
			{
				if (GetEntPropFloat(i, Prop_Send, "m_fImmuneToGunGameDamageTime") > 0.0)
				{
					continue;
				}
			}

			if(strcmp(szClanTag, "Gambit") == 0) //30th
			{
				if (!IsTargetInSightRange(client, i, 50.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Endpoint") == 0) //29th
			{
				if (!IsTargetInSightRange(client, i, 60.0))
					continue;	
			}
			else if(strcmp(szClanTag, "VP") == 0) //28th
			{
				if (!IsTargetInSightRange(client, i, 70.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Lions") == 0) //27th
			{
				if (!IsTargetInSightRange(client, i, 80.0))
					continue;	
			}
			else if(strcmp(szClanTag, "C9") == 0) //26th
			{
				if (!IsTargetInSightRange(client, i, 90.0))
					continue;	
			}
			else if(strcmp(szClanTag, "forZe") == 0) //25th
			{
				if (!IsTargetInSightRange(client, i, 100.0))
					continue;	
			}
			else if(strcmp(szClanTag, "North") == 0) //24th
			{
				if (!IsTargetInSightRange(client, i, 110.0))
					continue;	
			}
			else if(strcmp(szClanTag, "One") == 0) //23rd
			{
				if (!IsTargetInSightRange(client, i, 120.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Gen.G") == 0) //22nd
			{
				if (!IsTargetInSightRange(client, i, 130.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Chaos") == 0) //21st
			{
				if (!IsTargetInSightRange(client, i, 140.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Sprout") == 0) //20th
			{
				if (!IsTargetInSightRange(client, i, 150.0))
					continue;	
			}
			else if(strcmp(szClanTag, "GODSENT") == 0) //19th
			{
				if (!IsTargetInSightRange(client, i, 160.0))
					continue;	
			}
			else if(strcmp(szClanTag, "ENCE") == 0) //18th
			{
				if (!IsTargetInSightRange(client, i, 170.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Spirit") == 0) //17th
			{
				if (!IsTargetInSightRange(client, i, 180.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Thieves") == 0) //16th
			{
				if (!IsTargetInSightRange(client, i, 190.0))
					continue;	
			}
			else if(strcmp(szClanTag, "NiP") == 0) //15th
			{
				if (!IsTargetInSightRange(client, i, 200.0))
					continue;	
			}
			else if(strcmp(szClanTag, "mouz") == 0) //14th
			{
				if (!IsTargetInSightRange(client, i, 210.0))
					continue;	
			}
			else if(strcmp(szClanTag, "coL") == 0) //13th
			{
				if (!IsTargetInSightRange(client, i, 220.0))
					continue;	
			}
			else if(strcmp(szClanTag, "fnatic") == 0) //12th
			{
				if (!IsTargetInSightRange(client, i, 230.0))
					continue;	
			}
			else if(strcmp(szClanTag, "G2") == 0) //11th
			{
				if (!IsTargetInSightRange(client, i, 240.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Liquid") == 0) //10th
			{
				if (!IsTargetInSightRange(client, i, 250.0))
					continue;	
			}
			else if(strcmp(szClanTag, "FaZe") == 0) //9th
			{
				if (!IsTargetInSightRange(client, i, 260.0))
					continue;	
			}
			else if(strcmp(szClanTag, "OG") == 0) //8th
			{
				if (!IsTargetInSightRange(client, i, 270.0))
					continue;	
			}
			else if(strcmp(szClanTag, "BIG") == 0) //7th
			{
				if (!IsTargetInSightRange(client, i, 280.0))
					continue;	
			}
			else if(strcmp(szClanTag, "EG") == 0) //6th
			{
				if (!IsTargetInSightRange(client, i, 290.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Na´Vi") == 0) //5th
			{
				if (!IsTargetInSightRange(client, i, 300.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Vitality") == 0) //4th
			{
				if (!IsTargetInSightRange(client, i, 310.0))
					continue;	
			}
			else if(strcmp(szClanTag, "FURIA") == 0) //3rd
			{
				if (!IsTargetInSightRange(client, i, 320.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Heroic") == 0) //2nd
			{
				if (!IsTargetInSightRange(client, i, 330.0))
					continue;	
			}
			else if(strcmp(szClanTag, "Astralis") == 0) //1st
			{
				if (!IsTargetInSightRange(client, i, 340.0))
					continue;	
			}
			else
			{
				if (!IsTargetInSightRange(client, i))
					continue;
			}
			
			fClosestDistance = fTargetDistance;
			iClosestTarget = i;
			
			if(iDefIndex == 9 || iDefIndex == 11 || iDefIndex == 38 || iDefIndex == 40)
			{
				g_bCanAttack[client] = true;
			}
			else
			{
				CreateTimer(0.17, Timer_Attack, client);
			}
		}
	}
	
	return iClosestTarget;
}

public Action Timer_Attack(Handle hTimer, int client)
{
	g_bCanAttack[client] = true;
}

public Action Timer_ThrowSmoke(Handle hTimer, int client)
{
	g_bCanThrowSmoke[client] = true;
}

public Action Timer_ThrowFlash(Handle hTimer, int client)
{
	g_bCanThrowFlash[client] = true;
}

stock bool IsTargetInSightRange(int client, int iTarget, float fAngle = 40.0, float fDistance = 0.0, bool bHeightcheck = true, bool bNegativeangle = false)
{
	if (fAngle > 360.0)
		fAngle = 360.0;
	
	if (fAngle < 0.0)
		return false;
	
	float fClientPos[3];
	float fTargetPos[3];
	float fAngleVector[3];
	float fTargetVector[3];
	float fResultAngle;
	float fResultDistance;
	
	GetClientEyeAngles(client, fAngleVector);
	fAngleVector[0] = fAngleVector[2] = 0.0;
	GetAngleVectors(fAngleVector, fAngleVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fAngleVector, fAngleVector);
	if (bNegativeangle)
		NegateVector(fAngleVector);
	
	GetClientAbsOrigin(client, fClientPos);
	GetClientAbsOrigin(iTarget, fTargetPos);
	
	if (bHeightcheck && fDistance > 0)
		fResultDistance = GetVectorDistance(fClientPos, fTargetPos);
	
	fClientPos[2] = fTargetPos[2] = 0.0;
	MakeVectorFromPoints(fClientPos, fTargetPos, fTargetVector);
	NormalizeVector(fTargetVector, fTargetVector);
	
	fResultAngle = RadToDeg(ArcCosine(GetVectorDotProduct(fTargetVector, fAngleVector)));
	
	if (fResultAngle <= fAngle / 2)
	{
		if (fDistance > 0)
		{
			if (!bHeightcheck)
				fResultDistance = GetVectorDistance(fClientPos, fTargetPos);
			
			if (fDistance >= fResultDistance)
				return true;
			else return false;
		}
		else return true;
	}
	
	return false;
}

stock bool ClientCanSeeTarget(int client, int iTarget, float fDistance = 0.0, float fHeight = 50.0)
{
	float fClientPosition[3], fHead[3], fBad[3];
	
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", fClientPosition);
	fClientPosition[2] += fHeight;
	
	int iBone = LookupBone(iTarget, "head_0");
	if(iBone < 0)
		return false;
	
	GetBonePosition(iTarget, iBone, fHead, fBad);
	
	if (fDistance == 0.0 || GetVectorDistance(fClientPosition, fHead, false) < fDistance)
	{
		if(BotIsVisible(client, fHead, false, -1))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	return false;
}

stock void TF2_LookAtPos(int client, float flGoal[3], float flAimSpeed = 0.05)
{
    float flPos[3];
    GetClientEyePosition(client, flPos);

    float flAng[3];
    GetClientEyeAngles(client, flAng);
    
    // get normalised direction from target to client
    float desired_dir[3];
    MakeVectorFromPoints(flPos, flGoal, desired_dir);
    GetVectorAngles(desired_dir, desired_dir);
    
    // ease the current direction to the target direction
    flAng[0] += AngleNormalize(desired_dir[0] - flAng[0]) * flAimSpeed;
    flAng[1] += AngleNormalize(desired_dir[1] - flAng[1]) * flAimSpeed;

    TeleportEntity(client, NULL_VECTOR, flAng, NULL_VECTOR);
}

stock float AngleNormalize(float fAngle)
{
	fAngle -= RoundToFloor(fAngle / 360.0) * 360.0;
	
	if (fAngle > 180)
		fAngle -= 360;
	
	if (fAngle < -180)
		fAngle += 360;
	
	return fAngle;
}

stock int GetAliveTeamCount(int iTeam)
{
    int iNumber = 0;
    for (int i=1; i<=MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam) 
            iNumber++;
    }
    return iNumber;
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}

public void DoMirageSmokes(int client)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);

	//T Side Smokes
	float fCTSmoke[3] = { 1086.991821, -1017.052612, -258.250946 };
	float fStairsSmoke[3] = { 1147.428345, -1183.695313, -205.599060 };
	float fJungleSmoke[3] = { 815.810974, -1404.633789, -108.968750 };
	float fTopMidSmoke[3] = { 1422.968750, 70.759926, -112.902664 };
	float fMidShortSmoke[3] = { 1423.128906, -231.116898, -140.400681 };
	float fWindowSmoke[3] = { 1391.968750, -1012.190308, -167.968750 };
	float fBottomConSmoke[3] = { 1135.986816, 647.868591, -261.387939 };
	float fTopConSmoke[3] = { 1391.974731, -1051.666992, -167.968750 };
	float fShortLeftSmoke[3] = { -824.853577, 522.031250, -78.349075 };
	float fShortRightSmoke[3] = { -148.031250, 353.031250, -34.427696 };
	float fMarketDoorSmoke[3] = { -160.018127, 887.968750, -135.328125 };
	float fMarketWindowSmoke[3] = { -160.018127, 887.968750, -135.328125 };

	float fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
	float fStairsSmokeDis = GetVectorDistance(fClientLocation, fStairsSmoke);
	float fJungleSmokeDis = GetVectorDistance(fClientLocation, fJungleSmoke);
	float fTopMidSmokeDis = GetVectorDistance(fClientLocation, fTopMidSmoke);
	float fMidShortSmokeDis = GetVectorDistance(fClientLocation, fMidShortSmoke);
	float fWindowSmokeDis = GetVectorDistance(fClientLocation, fWindowSmoke);
	float fBottomConSmokeDis = GetVectorDistance(fClientLocation, fBottomConSmoke);
	float fTopConSmokeDis = GetVectorDistance(fClientLocation, fTopConSmoke);
	float fShotLeftSmokeDis = GetVectorDistance(fClientLocation, fShortLeftSmoke);
	float fShortRightSmokeDis = GetVectorDistance(fClientLocation, fShortRightSmoke);
	float fMarketDoorSmokeDis = GetVectorDistance(fClientLocation, fMarketDoorSmoke);
	float fMarketWindowSmokeDis = GetVectorDistance(fClientLocation, fMarketWindowSmoke);
	
	//T Side Flashes
	
	float fLampFlash[3] = { 871.768738, -1036.026489, -251.968750 };
	float fASiteFlash[3] = { 815.461670, -1497.127197, -108.968750 };
	float fMidFlash[3] = { 686.608215, 671.248047, -135.968750 };
	float fConnectorFlash[3] = { 360.075439, -691.968750, -162.496780 };
	float fBCarFlash[3] = { -161.022049, 571.791138, -69.669495 };
	float fBShortFlash[3] = { -736.012878, 623.968750, -75.968750 };
	float fBCornerFlash[3] = { -905.040466, 522.031250, -80.139946 };
	
	float fLampFlashDis = GetVectorDistance(fClientLocation, fLampFlash);
	float fMidFlashDis = GetVectorDistance(fClientLocation, fMidFlash);
	float fASiteFlashDis = GetVectorDistance(fClientLocation, fASiteFlash);
	float fConnectorFlashDis = GetVectorDistance(fClientLocation, fConnectorFlash);
	float fBCarFlashDis = GetVectorDistance(fClientLocation, fBCarFlash);
	float fBShortFlashDis = GetVectorDistance(fClientLocation, fBShortFlash);
	float fBCornerFlashDis = GetVectorDistance(fClientLocation, fBCornerFlash);
	
	switch(g_iSmoke[client])
	{
		case 1: //CT Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fCTSmoke, FASTEST_ROUTE);
				if(fCTSmokeDis < 25.0)
				{
					float fOrigin[3] = { 1062.656372, -1034.303344, -133.994354 };
					float fVelocity[3] = { -442.833282, -313.916076, 635.902832 };
					float fLookAt[3] = { -968.578002, -2475.483886, 1247.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(7.0, Timer_ThrowSmoke, client);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fLampFlash, FASTEST_ROUTE);
					
				if(fLampFlashDis < 25.0)
				{
					float fOrigin[3] = { 846.057006, -1048.617797, -164.538711 };
					float fVelocity[3] = { -467.880340, -229.124023, 419.202911 };
					float fLookAt[3] = { -1101.290527, -2002.246459, 1247.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 2: //Stairs Smoke
		{
			BotMoveTo(client, fStairsSmoke, FASTEST_ROUTE);
			if(fStairsSmokeDis < 25.0)
			{
				float fOrigin[3] = { 1122.725341, -1190.267456, -114.875701 };
				float fVelocity[3] = { -449.523773, -119.596504, 479.131927 };
				float fLookAt[3] = { -381.378540, -1587.050903, 1247.968750 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 3: //Jungle Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fJungleSmoke, FASTEST_ROUTE);
				if(fJungleSmokeDis < 25.0)
				{
					float fOrigin[3] = { 786.237731, -1409.484741, -23.414875 };
					float fVelocity[3] = { -540.984558, -82.985595, 385.062072 };
					float fLookAt[3] = { -1490.079833, -1764.229858, 1247.968750 };
					
					CreateTimer(1.5, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fASiteFlash, FASTEST_ROUTE);
					
				if(fASiteFlashDis < 25.0)
				{
					float fOrigin[3] = { 784.713562, -1499.222778, -24.482593 };
					float fVelocity[3] = { -559.527160, -38.136615, 365.632720 };
					float fLookAt[3] = { -1739.268310, -1671.254150, 1247.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 4: //Top-Mid Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fTopMidSmoke, FASTEST_ROUTE);
				if(fTopMidSmokeDis < 25.0)
				{
					float fOrigin[3] = { 1395.121459, 63.597442, -25.689208 };
					float fVelocity[3] = { -506.739288, -134.136840, 415.261779 };
					float fLookAt[3] = { -534.322998, -440.784057, 1247.968750 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fConnectorFlash, FASTEST_ROUTE);
					
				if(fConnectorFlashDis < 25.0)
				{
					float fOrigin[3] = { 325.308929, -695.885864, -86.328613 };
					float fVelocity[3] = { -632.651184, -71.279739, 214.269134 };
					float fLookAt[3] = { -673.912231, -807.603210, 89.318618 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 5: //Mid-Short Smoke
		{
			BotMoveTo(client, fMidShortSmoke, FASTEST_ROUTE);
			if(fMidShortSmokeDis < 25.0)
			{
				float fOrigin[3] = { 1392.466430, -231.284988, -17.280963 };
				float fVelocity[3] = { -557.085876, 4.736944, 615.806396 };
				float fLookAt[3] = { 1026.031250, -228.226913, 129.468246 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 6: //Window Smoke
		{
			BotMoveTo(client, fWindowSmoke, FASTEST_ROUTE);
			if(fWindowSmokeDis < 25.0)
			{
				float fOrigin[3] = { 1274.139526, -996.191772, -76.605072 };
				float fVelocity[3] = { -746.536376, 103.599502, 490.783843 };
				float fLookAt[3] = { -58.549804, -807.813232, 1247.968750 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 7: //Bottom Con Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fBottomConSmoke, FASTEST_ROUTE);
				if(fBottomConSmokeDis < 25.0)
				{
					float fOrigin[3] = { 1114.211303, 629.887756, -135.189559 };
					float fVelocity[3] = { -395.924011, -329.148590, 671.177124 };
					float fLookAt[3] = { 869.895507, 426.846496, 36.145904 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fMidFlash, FASTEST_ROUTE);
					
				if(fMidFlashDis < 25.0)
				{
					float fOrigin[3] = { 552.326171, 556.816955, -26.138240 };
					float fVelocity[3] = { -735.888305, -627.101074, 373.389343 };
					float fLookAt[3] = { 215.999969, 271.140686, -50.784938 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 8: //Top Con Smoke
		{
			BotMoveTo(client, fTopConSmoke, FASTEST_ROUTE);
			if(fTopConSmokeDis < 25.0)
			{
				float fOrigin[3] = { 1359.137817, -1055.348144, -44.989799 };
				float fVelocity[3] = { -577.226684, -63.052207, 614.102783 };
				float fLookAt[3] = { -1195.210327, -1349.580322, 1247.968627 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 9: //Short-Left Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fShortLeftSmoke, FASTEST_ROUTE);
				if(fShotLeftSmokeDis < 25.0)
				{
					float fOrigin[3] = { -831.811828, 521.822814, 21.893959 };
					float fVelocity[3] = { -127.920066, -5.121991, 652.748229 };
					float fLookAt[3] = { -1101.803833, 510.950866, 1247.968750 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fBCornerFlash, FASTEST_ROUTE);
					
				if(fBCornerFlashDis < 25.0)
				{
					float fOrigin[3] = { -1107.965820, 644.296081, -5.499357 };
					float fVelocity[3] = { -816.253417, 491.802368, 183.356262 };
					float fLookAt[3] = { -1373.903564, 803.997192, 55.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 10: //Short-Right Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fShortRightSmoke, FASTEST_ROUTE);
				if(fShortRightSmokeDis < 25.0)
				{
					float fOrigin[3] = { -162.757492, 350.828277, 63.391471 };
					float fVelocity[3] = { -267.975524, -39.678741, 608.255371 };
					float fLookAt[3] = { -755.933654, 268.693511, 1247.968750 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fBCarFlash, FASTEST_ROUTE);
					
				if(fBCarFlashDis < 25.0)
				{
					float fOrigin[3] = { -353.906921, 570.741271, 37.888614 };
					float fVelocity[3] = { -918.088073, -4.998743, 519.744873 };
					float fLookAt[3] = { -942.028808, 567.538757, 230.933624 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 11: //Market Door Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fMarketDoorSmoke, FASTEST_ROUTE);
				if(fMarketDoorSmokeDis < 25.0)
				{
					float fOrigin[3] = { -177.884231, 876.140869, -2.832973 };
					float fVelocity[3] = { -324.872985, -215.233276, 785.820922 };
					float fLookAt[3] = { -737.791992, 506.064849, 766.888061 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fBShortFlash, FASTEST_ROUTE);
					
				if(fBShortFlashDis < 25.0)
				{
					float fOrigin[3] = { -756.722534, 617.715454, 18.007228 };
					float fVelocity[3] = { -376.857208, -113.791618, 538.320251 };
					float fLookAt[3] = { -1752.971801, 316.899139, 1247.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 12: //Market Window Smoke
		{
			BotMoveTo(client, fMarketWindowSmoke, FASTEST_ROUTE);
			if(fMarketWindowSmokeDis < 25.0)
			{
				float fOrigin[3] = { -182.219451, 876.147033, -5.846139 };
				float fVelocity[3] = { -403.761627, -215.121276, 730.989990 };
				float fLookAt[3] = { -876.840881, 506.064788, 659.370727 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
	
	switch(g_iPositionToHold[client])
	{
		case 1: //Ramp Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 226.302078, -1511.023315, -111.906189 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 2: //Palace Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 164.354736, -2315.041016, 24.093811 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.5, Timer_ThrowSmoke, client);
				}
			}
		}
		case 3: //Underpass Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -1012.153503, 387.799988, -303.906189 };
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(5.0, Timer_ThrowSmoke, client);
				}
			}
		}
	}
}

public void DoDust2Smokes(int client)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);

	//T Side Smokes
	float fBDoorsSmoke[3] = { -2185.968750, 1059.031250, 39.799171 };
	float fBPlatSmoke[3] = { -2168.989990, 1042.031250, 40.191010 };
	float fBWindowSmoke[3] = { -2054.375977, 1042.031250, 39.598633 };
	float fMidToBSmoke[3] = { -275.031250, 1345.382568, -122.631432 };
	float fMidToBBoxSmoke[3] = { -275.031250, 1345.633301, -120.613678 };
	float fXBOXSmoke[3] = { -299.968750, -1163.974243, 77.698128 };
	float fShortASmoke[3] = { 489.995728, 1446.031250, 0.553116 };
	float fShortBoostSmoke[3] = { 489.995789, 1943.968750, 96.031250 };
	float fASiteSmoke[3] = { 273.018829, 1650.439819, 26.153511 };
	float fLongCornerSmoke[3] = { 487.991608, -363.999390, 9.031250 };
	float fACrossSmoke[3] = { 860.031250, 790.031250, 4.314228 };
	float fCTSmoke[3] = { 516.031250, 983.891907, 1.477413 };

	float fBDoorsSmokeDis = GetVectorDistance(fClientLocation, fBDoorsSmoke);
	float fBPlatSmokeDis = GetVectorDistance(fClientLocation, fBPlatSmoke);
	float fBWindowSmokeDis = GetVectorDistance(fClientLocation, fBWindowSmoke);
	float fMidToBSmokeDis = GetVectorDistance(fClientLocation, fMidToBSmoke);
	float fMidToBBoxSmokeDis = GetVectorDistance(fClientLocation, fMidToBBoxSmoke);
	float fXBOXSmokeDis = GetVectorDistance(fClientLocation, fXBOXSmoke);
	float fShortASmokeDis = GetVectorDistance(fClientLocation, fShortASmoke);
	float fShortBoostSmokeDis = GetVectorDistance(fClientLocation, fShortBoostSmoke);
	float fASiteSmokeDis = GetVectorDistance(fClientLocation, fASiteSmoke);
	float fLongCornerSmokeDis = GetVectorDistance(fClientLocation, fLongCornerSmoke);
	float fACrossSmokeDis = GetVectorDistance(fClientLocation, fACrossSmoke);
	float fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
	
	//T Side Flashes
	
	float fBSiteFlash[3] = { -1832.914917, 1224.700439, 32.116920 };
	float fBPopFlash[3] = { -1923.962769, 1244.391357, 31.543159 };
	float fMidToBPopFlash[3] = { -275.031250, 1345.370117, -122.732834 };
	float fMidToBFlash[3] = { -275.057678, 1279.997314, -115.976547 };
	float fASiteFlash[3] = { 489.968750, 1886.926636, 96.759674 };
	float fLongFlash[3] = { 363.996399, -383.321991, 6.365173 };
	
	float fBSiteFlashDis = GetVectorDistance(fClientLocation, fBSiteFlash);
	float fBPopFlashDis = GetVectorDistance(fClientLocation, fBPopFlash);
	float fMidToBPopFlashDis = GetVectorDistance(fClientLocation, fMidToBPopFlash);
	float fMidToBFlashDis = GetVectorDistance(fClientLocation, fMidToBFlash);
	float fASiteFlashDis = GetVectorDistance(fClientLocation, fASiteFlash);
	float fLongFlashDis = GetVectorDistance(fClientLocation, fLongFlash);
	
	switch(g_iSmoke[client])
	{
		case 1: //B Doors Smoke
		{
			BotMoveTo(client, fBDoorsSmoke, FASTEST_ROUTE);
			if(fBDoorsSmokeDis < 25.0)
			{
				float fOrigin[3] = { -2173.929443, 1075.293701, 134.734024 };
				float fVelocity[3] = { 219.085433, 295.929992, 555.731384 };
				float fLookAt[3] = { -2047.082763, 1246.631835, 411.427185 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 2: //B Plat Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fBPlatSmoke, FASTEST_ROUTE);
				if(fBPlatSmokeDis < 25.0)
				{
					float fOrigin[3] = { -2033.899902, 1089.731445, 136.258239 };
					float fVelocity[3] = { 175.069198, 407.834411, 595.961975 };
					float fLookAt[3] = { -1986.193725, 1201.230834, 411.259735 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}				
				}
			}
			else
			{
				BotMoveTo(client, fBPopFlash, FASTEST_ROUTE);
					
				if(fBPopFlashDis < 25.0)
				{
					float fOrigin[3] = { -1950.988403, 1393.770385, 106.644531 };
					float fVelocity[3] = { -166.773712, 921.804016, 230.978759 };
					float fLookAt[3] = { -2188.969726, 2712.631835, 418.597137 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 3: //B Window Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fBWindowSmoke, FASTEST_ROUTE);
				if(fBWindowSmokeDis < 25.0)
				{
					float fOrigin[3] = { -2154.974365, 1070.799804, 144.198379 };
					float fVelocity[3] = { 254.659484, 523.506591, 584.126586 };
					float fLookAt[3] = { -1993.429443, 1404.036376, 274.870574 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}				
				}
			}
			else
			{
				BotMoveTo(client, fBSiteFlash, FASTEST_ROUTE);
					
				if(fBSiteFlashDis < 25.0)
				{
					float fOrigin[3] = { -1849.123291, 1252.855957, 95.863258 };
					float fVelocity[3] = { -294.947082, 512.348876, 315.775756 };
					float fLookAt[3] = { -2033.325439, 1572.494140, 251.417327 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 4: //Mid to B Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fMidToBSmoke, FASTEST_ROUTE);
				if(fMidToBSmokeDis < 25.0)
				{
					float fOrigin[3] = { -294.034057, 1366.645751, -35.065914 };
					float fVelocity[3] = { -345.797119, 386.926208, 421.668273 };
					float fLookAt[3] = { -303.336486, 1377.001586, -30.637153 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}				
				}
			}
			else
			{
				BotMoveTo(client, fMidToBPopFlash, FASTEST_ROUTE);
					
				if(fMidToBPopFlashDis < 25.0)
				{
					float fOrigin[3] = { -261.502349, 1368.830200, -33.540878 };
					float fVelocity[3] = { 246.186660, 426.909759, 451.264770 };
					float fLookAt[3] = { -256.251983, 1377.717651, -30.328649 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 5: //Mid to B Box Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fMidToBBoxSmoke, FASTEST_ROUTE);
				if(fMidToBBoxSmokeDis < 25.0)
				{
					float fOrigin[3] = { -297.029571, 1373.973510, -8.979913 };
					float fVelocity[3] = { -400.306671, 515.712158, 406.203491 };
					float fLookAt[3] = { -297.873901, 1375.061157, -53.067520 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}				
				}
			}
			else
			{
				BotMoveTo(client, fMidToBFlash, FASTEST_ROUTE);
					
				if(fMidToBFlashDis < 25.0)
				{
					float fOrigin[3] = { -286.042205, 1308.943847, -31.702926 };
					float fVelocity[3] = { -199.886840, 526.745666, 361.765106 };
					float fLookAt[3] = { -1069.885986, 3374.528076, 1055.968750 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 6: //XBOX Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fXBOXSmoke, FASTEST_ROUTE);
				if(fXBOXSmokeDis < 25.0)
				{
					float fOrigin[3] = { -299.978637, -1131.513061, 197.856338 };
					float fVelocity[3] = { -0.179589, 590.701232, 561.324279 };
					float fLookAt[3] = { -308.900268, 297.964477, 711.968750 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}				
				}
			}
			else
			{
				BotMoveTo(client, fASiteFlash, FASTEST_ROUTE);
					
				if(fASiteFlashDis < 25.0)
				{
					float fOrigin[3] = { 476.668670, 1919.604370, 172.058532 };
					float fVelocity[3] = { -242.023056, 594.641418, 198.449981 };
					float fLookAt[3] = { 255.999984, 2461.778808, 258.907592 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 7: //Short A Smoke
		{
			BotMoveTo(client, fShortASmoke, FASTEST_ROUTE);
			if(fShortASmokeDis < 25.0)
			{
				float fOrigin[3] = { 491.129272, 1481.866210, 73.910873 };
				float fVelocity[3] = { 20.627548, 652.093811, 163.127685 };
				float fLookAt[3] = { 499.854309, 1766.076904, 95.390281 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 8: //Short-Boost Smoke
		{
			BotMoveTo(client, fShortBoostSmoke, FASTEST_ROUTE);
			if(fShortBoostSmokeDis < 25.0)
			{
				float fOrigin[3] = { 494.089050, 1972.633056, 142.517364 };
				float fVelocity[3] = { 60.845504, 423.293975, 88.089668 };
				float fLookAt[3] = { 600.057556, 2711.972656, 204.540893 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 9: //A Site Smoke
		{
			BotMoveTo(client, fASiteSmoke, FASTEST_ROUTE);
			if(fASiteSmokeDis < 25.0)
			{
				float fOrigin[3] = { 285.125366, 1662.108886, 105.060981 };
				float fVelocity[3] = { 220.304000, 212.345291, 591.664916 };
				float fLookAt[3] = { 679.261413, 2042.006347, 1055.968750 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 10: //Long Corner Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fLongCornerSmoke, FASTEST_ROUTE);
				if(fLongCornerSmokeDis < 25.0)
				{
					float fOrigin[3] = { 499.140136, -342.580871, 101.033569 };
					float fVelocity[3] = { 202.870849, 389.755371, 502.405334 };
					float fLookAt[3] = { 788.981933, 217.204040, 711.968750 };
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}				
				}
			}
			else
			{
				BotMoveTo(client, fLongFlash, FASTEST_ROUTE);
					
				if(fLongFlashDis < 25.0)
				{
					float fOrigin[3] = { 387.518829, -356.528503, 118.807830 };
					float fVelocity[3] = { 428.041076, 487.564605, 420.922576 };
					float fLookAt[3] = { 771.587707, 80.362823, 141.908721 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(1.0, Timer_ThrowFlash, client);
					
					if(g_bCanThrowFlash[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
						g_bHasThrownNade[client] = true;
					}
				}
			}
		}
		case 11: //A Cross Smoke
		{
			BotMoveTo(client, fACrossSmoke, FASTEST_ROUTE);
			if(fACrossSmokeDis < 25.0)
			{
				float fOrigin[3] = { 997.804809, 921.088378, 85.138679 };
				float fVelocity[3] = { 625.270690, 596.416015, 370.031616 };
				float fLookAt[3] = { 1734.690307, 1623.968750, 691.947387 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
		case 12: //CT Smoke
		{
			BotMoveTo(client, fCTSmoke, FASTEST_ROUTE);
			if(fCTSmokeDis < 25.0)
			{
				float fOrigin[3] = { 516.424987, 1004.355773, 96.256927 };
				float fVelocity[3] = { 7.165000, 372.383453, 552.942443 };
				float fLookAt[3] = { 525.635009, 1483.022705, 711.968750 };
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}				
			}
		}
	}
	
	switch(g_iPositionToHold[client])
	{
		case 1: //Lower Tunnel Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -1134.639282, 1099.567749, 44.114410 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 2: //B Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -1975.937500, 1821.490356, 96.745338 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 3: //Long Push Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 176.276123, 353.036530, 63.525383 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 4: //Short Push Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 342.916260, 1485.740845, 65.328796 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 5: //Mid Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -458.858887, 1653.003052, -60.461395 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 6: //A Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 776.948059, 2607.570801, 158.780182 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 7: //Mid Push Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { -161.266556, 398.383514, 62.534039 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
		case 8: //Long Position
		{
			if(!g_bCanThrowSmoke[client])
			{
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if(fHoldSpotDis < 25.0)
				{
					float fLookAt[3] = { 1328.326050, 1216.048950, 62.165554 };
					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, 1.0, true, 5.0, false);
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
				}
			}
		}
	}
}

public void DoInfernoSmokes(int client)
{
	float fClientLocation[3];

	GetClientAbsOrigin(client, fClientLocation);

	//T Side Smokes
	float fCTSmoke[3] = { 110.841888, 1569.614014, 132.013962 };
	float fCoffinSmoke[3] = { 119.548485, 1587.026001, 114.601593 };
	float fLongASmoke[3] = { 726.033081, 246.665131, 91.568497 };
	float fSiteLibrarySmoke[3] = { 941.968750, 429.357513, 88.082214 };
	float fPitSmoke[3] = { 492.249695, -267.968750, 88.031250 };
	float fBalconySmoke[3] = { 1562.242065, -274.097748, 256.031250 };
	float fShortASmoke[3] = { 538.006470, 699.968750, 93.837555 };
	float fArchSmoke[3] = { 726.017151, 186.010574, 97.474045 };
	float fGraveyardSmoke[3] = { 716.031250, 692.481201, 95.031250 };
	float fLibrarySmoke[3] = { 721.115723, 49.073799, 94.202866 };

	float fCTSmokeDis = GetVectorDistance(fClientLocation, fCTSmoke);
	float fCoffinSmokeDis = GetVectorDistance(fClientLocation, fCoffinSmoke);
	float fLongASmokeDis = GetVectorDistance(fClientLocation, fLongASmoke);
	float fSiteLibrarySmokeDis = GetVectorDistance(fClientLocation, fSiteLibrarySmoke);
	float fPitSmokeDis = GetVectorDistance(fClientLocation, fPitSmoke);
	float fBalconySmokeDis = GetVectorDistance(fClientLocation, fBalconySmoke);
	float fShortASmokeDis = GetVectorDistance(fClientLocation, fShortASmoke);
	float fArchSmokeDis = GetVectorDistance(fClientLocation, fArchSmoke);
	float fGraveyardSmokeDis = GetVectorDistance(fClientLocation, fGraveyardSmoke);
	float fLibrarySmokeDis = GetVectorDistance(fClientLocation, fLibrarySmoke);
	
	//T Side Molotovs
	
	float fQuadMolotov[3] = { 479.274414, 2017.968750, 128.409363 };
	float fFirstBoxMolotov[3] = { 409.326080, 2009.151367, 128.031250 };
	float fSecondBoxMolotov[3] = { 409.326080, 2009.151367, 128.031250 };
	float fPitMolotov[3] = { 1841.031250, -160.031250, 256.031250 };
	
	float fQuadMolotovDis = GetVectorDistance(fClientLocation, fQuadMolotov);
	float fFirstBoxMolotovDis = GetVectorDistance(fClientLocation, fFirstBoxMolotov);
	float fSecondBoxMolotovDis = GetVectorDistance(fClientLocation, fSecondBoxMolotov);
	float fPitMolotovDis = GetVectorDistance(fClientLocation, fPitMolotov);
	
	//T Side Flashes
	
	float fCTFlash[3] = { 194.896042, 1737.721069, 122.031250 };
	float fBSiteFlash[3] = { 460.446747, 1828.490723, 136.114029 };
	float fPitFlash[3] = { 1155.149902, 589.968750, 122.031250 };
	float fBalconyFlash[3] = { 1511.952637, -365.968750, 256.031250 };
	float fASiteFlash[3] = { 970.794312, 434.021057, 88.949677 };
	
	float fCTFlashDis = GetVectorDistance(fClientLocation, fCTFlash);
	float fBSiteFlashDis = GetVectorDistance(fClientLocation, fBSiteFlash);
	float fPitFlashDis = GetVectorDistance(fClientLocation, fPitFlash);
	float fBalconyFlashDis = GetVectorDistance(fClientLocation, fBalconyFlash);
	float fASiteFlashDis = GetVectorDistance(fClientLocation, fASiteFlash);

	switch(g_iSmoke[client])
	{
		case 1: //CT Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fCTSmoke, FASTEST_ROUTE);
				if(fCTSmokeDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 126.242744;
					fOrigin[1] = 1594.645996;
					fOrigin[2] = 218.488510;
					
					fVelocity[0] = 280.251098;
					fVelocity[1] = 455.511444;
					fVelocity[2] = 401.817474;
					
					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					TF2_LookAtPos(client, fOrigin, 0.40);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fCTFlash, FASTEST_ROUTE);
					
				if(fCTFlashDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 232.221496;
					fOrigin[1] = 1771.950439;
					fOrigin[2] = 206.091247;
					
					fVelocity[0] = 510.910461;
					fVelocity[1] = 451.589202;
					fVelocity[2] = 357.878143;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 2: //Coffin Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fCoffinSmoke, FASTEST_ROUTE);
				if(fCoffinSmokeDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 123.908531;
					fOrigin[1] = 1608.801513;
					fOrigin[2] = 208.180404;
					
					fVelocity[0] = 80.479454;
					fVelocity[1] = 398.531372;
					fVelocity[2] = 528.814270;

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					TF2_LookAtPos(client, fOrigin, 0.40);
						
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fBSiteFlash, FASTEST_ROUTE);
					
				if(fBSiteFlashDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 502.760955;
					fOrigin[1] = 1877.219116;
					fOrigin[2] = 211.888961;
					
					fVelocity[0] = 518.502197;
					fVelocity[1] = 597.576538;
					fVelocity[2] = 270.139526;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 3: //Long A Smoke
		{
			BotMoveTo(client, fLongASmoke, FASTEST_ROUTE);
			if(fLongASmokeDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 748.566589;
				fOrigin[1] = 268.015136;
				fOrigin[2] = 177.583160;
				
				fVelocity[0] = 410.540039;
				fVelocity[1] = 353.701324;
				fVelocity[2] = 392.463989;

				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 4: //Site-Library Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fSiteLibrarySmoke, FASTEST_ROUTE);
				if(fSiteLibrarySmokeDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 966.898254;
					fOrigin[1] = 435.972778;
					fOrigin[2] = 178.775451;
					
					fVelocity[0] = 453.395233;
					fVelocity[1] = 104.332847;
					fVelocity[2] = 479.052581;

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					TF2_LookAtPos(client, fOrigin, 0.40);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fPitFlash, FASTEST_ROUTE);
					
				if(fPitFlashDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1246.527587;
					fOrigin[1] = 503.508178;
					fOrigin[2] = 240.461380;
					
					fVelocity[0] = 639.973205;
					fVelocity[1] = -519.588073;
					fVelocity[2] = 649.552429;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 5: //Pit Smoke
		{
			BotMoveTo(client, fPitSmoke, FASTEST_ROUTE);
			if(fPitSmokeDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 514.735900;
				fOrigin[1] = -263.404022;
				fOrigin[2] = 180.432846;
				
				fVelocity[0] = 422.690643;
				fVelocity[1] = 83.064659;
				fVelocity[2] = 509.670959;

				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 6: //Balcony Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fBalconySmoke, FASTEST_ROUTE);
				if(fBalconySmokeDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1589.689697;
					fOrigin[1] = -296.319335;
					fOrigin[2] = 331.451446;
					
					fVelocity[0] = 496.743469;
					fVelocity[1] = -405.579101;
					fVelocity[2] = 200.657302;

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fBalconyFlash, FASTEST_ROUTE);
					
				if(fBalconyFlashDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1538.285522;
					fOrigin[1] = -377.717254;
					fOrigin[2] = 324.803131;
					
					fVelocity[0] = 485.635070;
					fVelocity[1] = -213.789443;
					fVelocity[2] = 407.226135;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 7: //Short A Smoke
		{
			if(!g_bHasThrownSmoke[client])
			{
				BotMoveTo(client, fShortASmoke, FASTEST_ROUTE);
				if(fShortASmokeDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 571.783935;
					fOrigin[1] = 689.233459;
					fOrigin[2] = 168.702438;
					
					fVelocity[0] = 614.202392;
					fVelocity[1] = -195.350540;
					fVelocity[2] = 190.545516;

					CreateTimer(3.0, Timer_ThrowSmoke, client);
					
					TF2_LookAtPos(client, fOrigin, 0.40);
					
					if(g_bCanThrowSmoke[client])
					{
						CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
						g_bHasThrownSmoke[client] = true;
					}
				}
			}
			else
			{
				BotMoveTo(client, fASiteFlash, FASTEST_ROUTE);
					
				if(fASiteFlashDis < 25.0)
				{
					float fVelocity[3], fOrigin[3];
					
					fOrigin[0] = 1289.101684;
					fOrigin[1] = 485.080993;
					fOrigin[2] = 247.019332;
					
					fVelocity[0] = 729.877929;
					fVelocity[1] = 116.153884;
					fVelocity[2] = 752.654418;
					
					CSU_ThrowGrenade(client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					CSU_DelayThrowGrenade(0.5, client, GrenadeTypeFromString("flash"), fOrigin, fVelocity);
					
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 8: //Arch Smoke
		{
			BotMoveTo(client, fArchSmoke, FASTEST_ROUTE);
			if(fArchSmokeDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 748.447692;
				fOrigin[1] = 209.271453;
				fOrigin[2] = 217.875152;
				
				fVelocity[0] = 408.306976;
				fVelocity[1] = 423.423950;
				fVelocity[2] = 565.772216;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 9: //Graveyard Smoke
		{
			BotMoveTo(client, fGraveyardSmoke, FASTEST_ROUTE);
			if(fGraveyardSmokeDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 749.527038;
				fOrigin[1] = 682.661010;
				fOrigin[2] = 209.790649;
				
				fVelocity[0] = 609.527587;
				fVelocity[1] = -178.700210;
				fVelocity[2] = 463.080993;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 10: //Library Smoke
		{
			BotMoveTo(client, fLibrarySmoke, FASTEST_ROUTE);
			if(fLibrarySmokeDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 747.903747;
				fOrigin[1] = 67.559135;
				fOrigin[2] = 214.205093;
				
				fVelocity[0] = 487.465698;
				fVelocity[1] = 336.380218;
				fVelocity[2] = 558.485595;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("smoke"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
	
	switch(g_iPositionToHold[client])
	{
		case 1: //Quad Molotov
		{
			BotMoveTo(client, fQuadMolotov, FASTEST_ROUTE);
			if(fQuadMolotovDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 465.565948;
				fOrigin[1] = 2039.379638;
				fOrigin[2] = 257.628387;
				
				fVelocity[0] = -249.454605;
				fVelocity[1] = 389.615020;
				fVelocity[2] = 726.204895;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("molotov"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 2: //First Box Molotov
		{
			BotMoveTo(client, fFirstBoxMolotov, FASTEST_ROUTE);
			if(fFirstBoxMolotovDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 414.437194;
				fOrigin[1] = 2032.446166;
				fOrigin[2] = 258.654602;
				
				fVelocity[0] = 93.188972;
				fVelocity[1] = 423.755950;
				fVelocity[2] = 751.759277;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("molotov"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 3: //Second Box Molotov
		{
			BotMoveTo(client, fSecondBoxMolotov, FASTEST_ROUTE);
			if(fSecondBoxMolotovDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 393.667388;
				fOrigin[1] = 2036.708984;
				fOrigin[2] = 249.528472;
				
				fVelocity[0] = -284.762115;
				fVelocity[1] = 501.325134;
				fVelocity[2] = 585.690124;
				
				CreateTimer(3.0, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("molotov"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
		case 4: //Pit Molotov
		{
			BotMoveTo(client, fPitMolotov, FASTEST_ROUTE);
			if(fPitMolotovDis < 25.0)
			{
				float fVelocity[3], fOrigin[3];
				
				fOrigin[0] = 1892.494628;
				fOrigin[1] = -161.390838;
				fOrigin[2] = 323.485076;
				
				fVelocity[0] = 775.491088;
				fVelocity[1] = -20.896572;
				fVelocity[2] = 55.693138;
				
				CreateTimer(0.2, Timer_ThrowSmoke, client);
				
				TF2_LookAtPos(client, fOrigin, 0.40);
					
				if(g_bCanThrowSmoke[client])
				{
					CSU_ThrowGrenade(client, GrenadeTypeFromString("molotov"), fOrigin, fVelocity);
					g_bHasThrownNade[client] = true;
				}
			}
		}
	}
}

public void Pro_Players(char[] szBotName, int client)
{

	//MIBR Players
	if((StrEqual(szBotName, "kNgV-")) || (StrEqual(szBotName, "FalleN")) || (StrEqual(szBotName, "fer")) || (StrEqual(szBotName, "TACO")) || (StrEqual(szBotName, "trk")))
	{
		CS_SetClientClanTag(client, "MIBR");
	}
	
	//FaZe Players
	if((StrEqual(szBotName, "Kjaerbye")) || (StrEqual(szBotName, "broky")) || (StrEqual(szBotName, "NiKo")) || (StrEqual(szBotName, "rain")) || (StrEqual(szBotName, "coldzera")))
	{
		CS_SetClientClanTag(client, "FaZe");
	}
	
	//Astralis Players
	if((StrEqual(szBotName, "gla1ve")) || (StrEqual(szBotName, "device")) || (StrEqual(szBotName, "es3tag")) || (StrEqual(szBotName, "Magisk")) || (StrEqual(szBotName, "dupreeh")))
	{
		CS_SetClientClanTag(client, "Astralis");
	}
	
	//NiP Players
	if((StrEqual(szBotName, "twist")) || (StrEqual(szBotName, "Plopski")) || (StrEqual(szBotName, "nawwk")) || (StrEqual(szBotName, "hampus")) || (StrEqual(szBotName, "REZ")))
	{
		CS_SetClientClanTag(client, "NiP");
	}
	
	//C9 Players
	if((StrEqual(szBotName, "JT")) || (StrEqual(szBotName, "Sonic")) || (StrEqual(szBotName, "motm")) || (StrEqual(szBotName, "oSee")) || (StrEqual(szBotName, "floppy")))
	{
		CS_SetClientClanTag(client, "C9");
	}
	
	//G2 Players
	if((StrEqual(szBotName, "huNter-")) || (StrEqual(szBotName, "kennyS")) || (StrEqual(szBotName, "nexa")) || (StrEqual(szBotName, "JaCkz")) || (StrEqual(szBotName, "AmaNEk")))
	{
		CS_SetClientClanTag(client, "G2");
	}
	
	//fnatic Players
	if((StrEqual(szBotName, "flusha")) || (StrEqual(szBotName, "JW")) || (StrEqual(szBotName, "KRIMZ")) || (StrEqual(szBotName, "Brollan")) || (StrEqual(szBotName, "Golden")))
	{
		CS_SetClientClanTag(client, "fnatic");
	}
	
	//North Players
	if((StrEqual(szBotName, "MSL")) || (StrEqual(szBotName, "Lekr0")) || (StrEqual(szBotName, "aizy")) || (StrEqual(szBotName, "cajunb")) || (StrEqual(szBotName, "gade")))
	{
		CS_SetClientClanTag(client, "North");
	}
	
	//mouz Players
	if((StrEqual(szBotName, "karrigan")) || (StrEqual(szBotName, "chrisJ")) || (StrEqual(szBotName, "Bymas")) || (StrEqual(szBotName, "frozen")) || (StrEqual(szBotName, "ropz")))
	{
		CS_SetClientClanTag(client, "mouz");
	}
	
	//TYLOO Players
	if((StrEqual(szBotName, "Summer")) || (StrEqual(szBotName, "Attacker")) || (StrEqual(szBotName, "SLOWLY")) || (StrEqual(szBotName, "somebody")) || (StrEqual(szBotName, "DANK1NG")))
	{
		CS_SetClientClanTag(client, "TYLOO");
	}
	
	//EG Players
	if((StrEqual(szBotName, "stanislaw")) || (StrEqual(szBotName, "tarik")) || (StrEqual(szBotName, "Brehze")) || (StrEqual(szBotName, "Ethan")) || (StrEqual(szBotName, "CeRq")))
	{
		CS_SetClientClanTag(client, "EG");
	}
	
	//Vireo.Pro Players
	if((StrEqual(szBotName, "Hendy")) || (StrEqual(szBotName, "armen")) || (StrEqual(szBotName, "vein")) || (StrEqual(szBotName, "walker")) || (StrEqual(szBotName, "Ryze")))
	{
		CS_SetClientClanTag(client, "Vireo.Pro");
	}
	
	//Na´Vi Players
	if((StrEqual(szBotName, "electronic")) || (StrEqual(szBotName, "s1mple")) || (StrEqual(szBotName, "flamie")) || (StrEqual(szBotName, "Boombl4")) || (StrEqual(szBotName, "Perfecto")))
	{
		CS_SetClientClanTag(client, "Na´Vi");
	}
	
	//Liquid Players
	if((StrEqual(szBotName, "Stewie2K")) || (StrEqual(szBotName, "NAF")) || (StrEqual(szBotName, "Grim")) || (StrEqual(szBotName, "ELiGE")) || (StrEqual(szBotName, "Twistzz")))
	{
		CS_SetClientClanTag(client, "Liquid");
	}
	
	//AGO Players
	if((StrEqual(szBotName, "Furlan")) || (StrEqual(szBotName, "GruBy")) || (StrEqual(szBotName, "dgl")) || (StrEqual(szBotName, "F1KU")) || (StrEqual(szBotName, "leman")))
	{
		CS_SetClientClanTag(client, "AGO");
	}
	
	//ENCE Players
	if((StrEqual(szBotName, "suNny")) || (StrEqual(szBotName, "Aerial")) || (StrEqual(szBotName, "allu")) || (StrEqual(szBotName, "sergej")) || (StrEqual(szBotName, "Jamppi")))
	{
		CS_SetClientClanTag(client, "ENCE");
	}
	
	//Vitality Players
	if((StrEqual(szBotName, "shox")) || (StrEqual(szBotName, "ZywOo")) || (StrEqual(szBotName, "apEX")) || (StrEqual(szBotName, "RpK")) || (StrEqual(szBotName, "Misutaaa")))
	{
		CS_SetClientClanTag(client, "Vitality");
	}
	
	//BIG Players
	if((StrEqual(szBotName, "tiziaN")) || (StrEqual(szBotName, "syrsoN")) || (StrEqual(szBotName, "XANTARES")) || (StrEqual(szBotName, "tabseN")) || (StrEqual(szBotName, "k1to")))
	{
		CS_SetClientClanTag(client, "BIG");
	}
	
	//FURIA Players
	if((StrEqual(szBotName, "yuurih")) || (StrEqual(szBotName, "arT")) || (StrEqual(szBotName, "VINI")) || (StrEqual(szBotName, "KSCERATO")) || (StrEqual(szBotName, "HEN1")))
	{
		CS_SetClientClanTag(client, "FURIA");
	}
	
	//c0ntact Players
	if((StrEqual(szBotName, "Snappi")) || (StrEqual(szBotName, "ottoNd")) || (StrEqual(szBotName, "smooya")) || (StrEqual(szBotName, "Spinx")) || (StrEqual(szBotName, "EspiranTo")))
	{
		CS_SetClientClanTag(client, "c0ntact");
	}
	
	//coL Players
	if((StrEqual(szBotName, "k0nfig")) || (StrEqual(szBotName, "poizon")) || (StrEqual(szBotName, "oBo")) || (StrEqual(szBotName, "RUSH")) || (StrEqual(szBotName, "blameF")))
	{
		CS_SetClientClanTag(client, "coL");
	}
	
	//ViCi Players
	if((StrEqual(szBotName, "zhokiNg")) || (StrEqual(szBotName, "kaze")) || (StrEqual(szBotName, "aumaN")) || (StrEqual(szBotName, "JamYoung")) || (StrEqual(szBotName, "advent")))
	{
		CS_SetClientClanTag(client, "ViCi");
	}
	
	//forZe Players
	if((StrEqual(szBotName, "facecrack")) || (StrEqual(szBotName, "xsepower")) || (StrEqual(szBotName, "FL1T")) || (StrEqual(szBotName, "almazer")) || (StrEqual(szBotName, "Jerry")))
	{
		CS_SetClientClanTag(client, "forZe");
	}
	
	//Winstrike Players
	if((StrEqual(szBotName, "Lack1")) || (StrEqual(szBotName, "KrizzeN")) || (StrEqual(szBotName, "NickelBack")) || (StrEqual(szBotName, "El1an")) || (StrEqual(szBotName, "bondik")))
	{
		CS_SetClientClanTag(client, "Winstrike");
	}
	
	//Sprout Players
	if((StrEqual(szBotName, "snatchie")) || (StrEqual(szBotName, "dycha")) || (StrEqual(szBotName, "Spiidi")) || (StrEqual(szBotName, "faveN")) || (StrEqual(szBotName, "denis")))
	{
		CS_SetClientClanTag(client, "Sprout");
	}
	
	//Heroic Players
	if((StrEqual(szBotName, "TeSeS")) || (StrEqual(szBotName, "b0RUP")) || (StrEqual(szBotName, "nikozan")) || (StrEqual(szBotName, "cadiaN")) || (StrEqual(szBotName, "stavn")))
	{
		CS_SetClientClanTag(client, "Heroic");
	}
	
	//INTZ Players
	if((StrEqual(szBotName, "guZERA")) || (StrEqual(szBotName, "BALEROSTYLE")) || (StrEqual(szBotName, "dukka")) || (StrEqual(szBotName, "paredao")) || (StrEqual(szBotName, "chara")))
	{
		CS_SetClientClanTag(client, "INTZ");
	}
	
	//VP Players
	if((StrEqual(szBotName, "YEKINDAR")) || (StrEqual(szBotName, "Jame")) || (StrEqual(szBotName, "qikert")) || (StrEqual(szBotName, "SANJI")) || (StrEqual(szBotName, "buster")))
	{
		CS_SetClientClanTag(client, "VP");
	}
	
	//Apeks Players
	if((StrEqual(szBotName, "Marcelious")) || (StrEqual(szBotName, "jkaem")) || (StrEqual(szBotName, "Grusarn")) || (StrEqual(szBotName, "Nasty")) || (StrEqual(szBotName, "dennis")))
	{
		CS_SetClientClanTag(client, "Apeks");
	}
	
	//aTTaX Players
	if((StrEqual(szBotName, "stfN")) || (StrEqual(szBotName, "slaxz")) || (StrEqual(szBotName, "ScrunK")) || (StrEqual(szBotName, "kressy")) || (StrEqual(szBotName, "mirbit")))
	{
		CS_SetClientClanTag(client, "aTTaX");
	}
	
	//RNG Players
	if((StrEqual(szBotName, "INS")) || (StrEqual(szBotName, "sico")) || (StrEqual(szBotName, "dexter")) || (StrEqual(szBotName, "Hatz")) || (StrEqual(szBotName, "malta")))
	{
		CS_SetClientClanTag(client, "RNG");
	}
	
	//Envy Players
	if((StrEqual(szBotName, "Nifty")) || (StrEqual(szBotName, "Thomas")) || (StrEqual(szBotName, "Calyx")) || (StrEqual(szBotName, "MICHU")) || (StrEqual(szBotName, "LEGIJA")))
	{
		CS_SetClientClanTag(client, "Envy");
	}
	
	//Spirit Players
	if((StrEqual(szBotName, "mir")) || (StrEqual(szBotName, "iDISBALANCE")) || (StrEqual(szBotName, "somedieyoung")) || (StrEqual(szBotName, "chopper")) || (StrEqual(szBotName, "magixx")))
	{
		CS_SetClientClanTag(client, "Spirit");
	}
	
	//LDLC Players
	if((StrEqual(szBotName, "afroo")) || (StrEqual(szBotName, "Lambert")) || (StrEqual(szBotName, "hAdji")) || (StrEqual(szBotName, "bodyy")) || (StrEqual(szBotName, "SIXER")))
	{
		CS_SetClientClanTag(client, "LDLC");
	}
	
	//GamerLegion Players
	if((StrEqual(szBotName, "dobbo")) || (StrEqual(szBotName, "eraa")) || (StrEqual(szBotName, "Zero")) || (StrEqual(szBotName, "RuStY")) || (StrEqual(szBotName, "Adam9130")))
	{
		CS_SetClientClanTag(client, "GamerLegion");
	}
	
	//DIVIZON Players
	if((StrEqual(szBotName, "devus")) || (StrEqual(szBotName, "akay")) || (StrEqual(szBotName, "striNg")) || (StrEqual(szBotName, "kryptoN")) || (StrEqual(szBotName, "bLooDyyY")))
	{
		CS_SetClientClanTag(client, "DIVIZON");
	}
	
	//Wolsung Players
	if((StrEqual(szBotName, "hyskeee")) || (StrEqual(szBotName, "rAW")) || (StrEqual(szBotName, "Gekons")) || (StrEqual(szBotName, "keen")) || (StrEqual(szBotName, "shield")))
	{
		CS_SetClientClanTag(client, "Wolsung");
	}
	
	//PDucks Players
	if((StrEqual(szBotName, "ChLo")) || (StrEqual(szBotName, "sTaR")) || (StrEqual(szBotName, "wizzem")) || (StrEqual(szBotName, "maxz")) || (StrEqual(szBotName, "Cl34v3rs")))
	{
		CS_SetClientClanTag(client, "PDucks");
	}
	
	//HAVU Players
	if((StrEqual(szBotName, "ZOREE")) || (StrEqual(szBotName, "sLowi")) || (StrEqual(szBotName, "doto")) || (StrEqual(szBotName, "xseveN")) || (StrEqual(szBotName, "sAw")))
	{
		CS_SetClientClanTag(client, "HAVU");
	}
	
	//Lyngby Players
	if((StrEqual(szBotName, "birdfromsky")) || (StrEqual(szBotName, "Twinx")) || (StrEqual(szBotName, "Maccen")) || (StrEqual(szBotName, "Raalz")) || (StrEqual(szBotName, "Cabbi")))
	{
		CS_SetClientClanTag(client, "Lyngby");
	}
	
	//GODSENT Players
	if((StrEqual(szBotName, "maden")) || (StrEqual(szBotName, "farlig")) || (StrEqual(szBotName, "kRYSTAL")) || (StrEqual(szBotName, "zehN")) || (StrEqual(szBotName, "STYKO")))
	{
		CS_SetClientClanTag(client, "GODSENT");
	}
	
	//Nordavind Players
	if((StrEqual(szBotName, "tenzki")) || (StrEqual(szBotName, "NaToSaphiX")) || (StrEqual(szBotName, "sense")) || (StrEqual(szBotName, "HS")) || (StrEqual(szBotName, "cromen")))
	{
		CS_SetClientClanTag(client, "Nordavind");
	}
	
	//SJ Players
	if((StrEqual(szBotName, "arvid")) || (StrEqual(szBotName, "LYNXi")) || (StrEqual(szBotName, "SADDYX")) || (StrEqual(szBotName, "KHRN")) || (StrEqual(szBotName, "jemi")))
	{
		CS_SetClientClanTag(client, "SJ");
	}
	
	//Bren Players
	if((StrEqual(szBotName, "Papichulo")) || (StrEqual(szBotName, "witz")) || (StrEqual(szBotName, "Pro.")) || (StrEqual(szBotName, "JA")) || (StrEqual(szBotName, "Derek")))
	{
		CS_SetClientClanTag(client, "Bren");
	}
	
	//Giants Players
	if((StrEqual(szBotName, "NOPEEj")) || (StrEqual(szBotName, "fox")) || (StrEqual(szBotName, "pr")) || (StrEqual(szBotName, "obj")) || (StrEqual(szBotName, "RIZZ")))
	{
		CS_SetClientClanTag(client, "Giants");
	}
	
	//Lions Players
	if((StrEqual(szBotName, "HooXi")) || (StrEqual(szBotName, "acoR")) || (StrEqual(szBotName, "Sjuush")) || (StrEqual(szBotName, "refrezh")) || (StrEqual(szBotName, "roeJ")))
	{
		CS_SetClientClanTag(client, "Lions");
	}
	
	//Riders Players
	if((StrEqual(szBotName, "mopoz")) || (StrEqual(szBotName, "shokz")) || (StrEqual(szBotName, "steel")) || (StrEqual(szBotName, "alex*")) || (StrEqual(szBotName, "larsen")))
	{
		CS_SetClientClanTag(client, "Riders");
	}
	
	//OFFSET Players
	if((StrEqual(szBotName, "rafaxF")) || (StrEqual(szBotName, "KILLDREAM")) || (StrEqual(szBotName, "EasTor")) || (StrEqual(szBotName, "ZELIN")) || (StrEqual(szBotName, "drifking")))
	{
		CS_SetClientClanTag(client, "OFFSET");
	}
	
	//eSuba Players
	if((StrEqual(szBotName, "NIO")) || (StrEqual(szBotName, "Levi")) || (StrEqual(szBotName, "luko")) || (StrEqual(szBotName, "Blogg1s")) || (StrEqual(szBotName, "The eLiVe")))
	{
		CS_SetClientClanTag(client, "eSuba");
	}
	
	//Nexus Players
	if((StrEqual(szBotName, "BTN")) || (StrEqual(szBotName, "XELLOW")) || (StrEqual(szBotName, "SEMINTE")) || (StrEqual(szBotName, "iM")) || (StrEqual(szBotName, "sXe")))
	{
		CS_SetClientClanTag(client, "Nexus");
	}
	
	//PACT Players
	if((StrEqual(szBotName, "darko")) || (StrEqual(szBotName, "lunAtic")) || (StrEqual(szBotName, "Goofy")) || (StrEqual(szBotName, "MINISE")) || (StrEqual(szBotName, "Sobol")))
	{
		CS_SetClientClanTag(client, "PACT");
	}
	
	//Heretics Players
	if((StrEqual(szBotName, "Python")) || (StrEqual(szBotName, "Maka")) || (StrEqual(szBotName, "xms")) || (StrEqual(szBotName, "kioShiMa")) || (StrEqual(szBotName, "Lucky")))
	{
		CS_SetClientClanTag(client, "Heretics");
	}
	
	//Nemiga Players
	if((StrEqual(szBotName, "speed4k")) || (StrEqual(szBotName, "mds")) || (StrEqual(szBotName, "lollipop21k")) || (StrEqual(szBotName, "Jyo")) || (StrEqual(szBotName, "boX")))
	{
		CS_SetClientClanTag(client, "Nemiga");
	}
	
	//pro100 Players
	if((StrEqual(szBotName, "dimasick")) || (StrEqual(szBotName, "WorldEdit")) || (StrEqual(szBotName, "pipsoN")) || (StrEqual(szBotName, "wayLander")) || (StrEqual(szBotName, "AiyvaN")))
	{
		CS_SetClientClanTag(client, "pro100");
	}
	
	//YaLLa Players
	if((StrEqual(szBotName, "Remind")) || (StrEqual(szBotName, "eku")) || (StrEqual(szBotName, "Kheops")) || (StrEqual(szBotName, "Senpai")) || (StrEqual(szBotName, "Lyhn")))
	{
		CS_SetClientClanTag(client, "YaLLa");
	}
	
	//Yeah Players
	if((StrEqual(szBotName, "tatazin")) || (StrEqual(szBotName, "RCF")) || (StrEqual(szBotName, "f4stzin")) || (StrEqual(szBotName, "Swisher")) || (StrEqual(szBotName, "dumau")))
	{
		CS_SetClientClanTag(client, "Yeah");
	}
	
	//Singularity Players
	if((StrEqual(szBotName, "Casle")) || (StrEqual(szBotName, "notaN")) || (StrEqual(szBotName, "Remoy")) || (StrEqual(szBotName, "TOBIZ")) || (StrEqual(szBotName, "Celrate")))
	{
		CS_SetClientClanTag(client, "Singularity");
	}
	
	//DETONA Players
	if((StrEqual(szBotName, "nak")) || (StrEqual(szBotName, "piria")) || (StrEqual(szBotName, "v$m")) || (StrEqual(szBotName, "Lucaozy")) || (StrEqual(szBotName, "zevy")))
	{
		CS_SetClientClanTag(client, "DETONA");
	}
	
	//Infinity Players
	if((StrEqual(szBotName, "k1Nky")) || (StrEqual(szBotName, "tor1towOw")) || (StrEqual(szBotName, "spamzzy")) || (StrEqual(szBotName, "chuti")) || (StrEqual(szBotName, "points")))
	{
		CS_SetClientClanTag(client, "Infinity");
	}
	
	//Isurus Players
	if((StrEqual(szBotName, "JonY BoY")) || (StrEqual(szBotName, "Noktse")) || (StrEqual(szBotName, "Reversive")) || (StrEqual(szBotName, "decov9jse")) || (StrEqual(szBotName, "caike")))
	{
		CS_SetClientClanTag(client, "Isurus");
	}
	
	//paiN Players
	if((StrEqual(szBotName, "PKL")) || (StrEqual(szBotName, "saffee")) || (StrEqual(szBotName, "NEKIZ")) || (StrEqual(szBotName, "biguzera")) || (StrEqual(szBotName, "hardzao")))
	{
		CS_SetClientClanTag(client, "paiN");
	}
	
	//Sharks Players
	if((StrEqual(szBotName, "supLex")) || (StrEqual(szBotName, "jnt")) || (StrEqual(szBotName, "leo_drunky")) || (StrEqual(szBotName, "exit")) || (StrEqual(szBotName, "Luken")))
	{
		CS_SetClientClanTag(client, "Sharks");
	}
	
	//One Players
	if((StrEqual(szBotName, "prt")) || (StrEqual(szBotName, "Maluk3")) || (StrEqual(szBotName, "malbsMd")) || (StrEqual(szBotName, "pesadelo")) || (StrEqual(szBotName, "b4rtiN")))
	{
		CS_SetClientClanTag(client, "One");
	}
	
	//W7M Players
	if((StrEqual(szBotName, "skullz")) || (StrEqual(szBotName, "raafa")) || (StrEqual(szBotName, "Tuurtle")) || (StrEqual(szBotName, "pancc")) || (StrEqual(szBotName, "realziN")))
	{
		CS_SetClientClanTag(client, "W7M");
	}
	
	//Avant Players
	if((StrEqual(szBotName, "BL1TZ")) || (StrEqual(szBotName, "sterling")) || (StrEqual(szBotName, "apoc")) || (StrEqual(szBotName, "ofnu")) || (StrEqual(szBotName, "HaZR")))
	{
		CS_SetClientClanTag(client, "Avant");
	}
	
	//Chiefs Players
	if((StrEqual(szBotName, "HUGHMUNGUS")) || (StrEqual(szBotName, "Vexite")) || (StrEqual(szBotName, "apocdud")) || (StrEqual(szBotName, "zeph")) || (StrEqual(szBotName, "soju_j")))
	{
		CS_SetClientClanTag(client, "Chiefs");
	}
	
	//ORDER Players
	if((StrEqual(szBotName, "J1rah")) || (StrEqual(szBotName, "aliStair")) || (StrEqual(szBotName, "Rickeh")) || (StrEqual(szBotName, "USTILO")) || (StrEqual(szBotName, "Valiance")))
	{
		CS_SetClientClanTag(client, "ORDER");
	}
	
	//SKADE Players
	if((StrEqual(szBotName, "Duplicate")) || (StrEqual(szBotName, "dennyslaw")) || (StrEqual(szBotName, "Oxygen")) || (StrEqual(szBotName, "Rainwaker")) || (StrEqual(szBotName, "SPELLAN")))
	{
		CS_SetClientClanTag(client, "SKADE");
	}
	
	//Paradox Players
	if((StrEqual(szBotName, "rbz")) || (StrEqual(szBotName, "Versa")) || (StrEqual(szBotName, "ekul")) || (StrEqual(szBotName, "bedonka")) || (StrEqual(szBotName, "dangeR")))
	{
		CS_SetClientClanTag(client, "Paradox");
	}
	
	//Beyond Players
	if((StrEqual(szBotName, "MAIROLLS")) || (StrEqual(szBotName, "Olivia")) || (StrEqual(szBotName, "Kntz")) || (StrEqual(szBotName, "stk")) || (StrEqual(szBotName, "qqGod")))
	{
		CS_SetClientClanTag(client, "Beyond");
	}
	
	//BOOM Players
	if((StrEqual(szBotName, "chelo")) || (StrEqual(szBotName, "yeL")) || (StrEqual(szBotName, "shz")) || (StrEqual(szBotName, "boltz")) || (StrEqual(szBotName, "felps")))
	{
		CS_SetClientClanTag(client, "BOOM");
	}
	
	//NASR Players
	if((StrEqual(szBotName, "proxyyb")) || (StrEqual(szBotName, "Real1ze")) || (StrEqual(szBotName, "BOROS")) || (StrEqual(szBotName, "Dementor")) || (StrEqual(szBotName, "Just1ce")))
	{
		CS_SetClientClanTag(client, "NASR");
	}
	
	//Revolution Players
	if((StrEqual(szBotName, "Rambutan")) || (StrEqual(szBotName, "Fog")) || (StrEqual(szBotName, "Tee")) || (StrEqual(szBotName, "Jaybk")) || (StrEqual(szBotName, "kun")))
	{
		CS_SetClientClanTag(client, "Revolution");
	}
	
	//SHIFT Players
	if((StrEqual(szBotName, "Young KillerS")) || (StrEqual(szBotName, "Kishi")) || (StrEqual(szBotName, "tozz")) || (StrEqual(szBotName, "huyhart")) || (StrEqual(szBotName, "Imcarnus")))
	{
		CS_SetClientClanTag(client, "SHIFT");
	}
	
	//nxl Players
	if((StrEqual(szBotName, "soifong")) || (StrEqual(szBotName, "Foscmorc")) || (StrEqual(szBotName, "frgd[ibtJ]")) || (StrEqual(szBotName, "Lmemore")) || (StrEqual(szBotName, "xera")))
	{
		CS_SetClientClanTag(client, "nxl");
	}
	
	//LLL Players
	if((StrEqual(szBotName, "simix")) || (StrEqual(szBotName, "Stev0se")) || (StrEqual(szBotName, "ritchiEE")) || (StrEqual(szBotName, "rilax")) || (StrEqual(szBotName, "FASHR")))
	{
		CS_SetClientClanTag(client, "LLL");
	}
	
	//Energy Players
	if((StrEqual(szBotName, "pnd")) || (StrEqual(szBotName, "disTroiT")) || (StrEqual(szBotName, "Lichl0rd")) || (StrEqual(szBotName, "Tiaantije")) || (StrEqual(szBotName, "mango")))
	{
		CS_SetClientClanTag(client, "Energy");
	}
	
	//GroundZero Players
	if((StrEqual(szBotName, "BURNRUOk")) || (StrEqual(szBotName, "Laes")) || (StrEqual(szBotName, "Llamas")) || (StrEqual(szBotName, "Noobster")) || (StrEqual(szBotName, "Mayker")))
	{
		CS_SetClientClanTag(client, "GroundZero");
	}
	
	//AVEZ Players
	if((StrEqual(szBotName, "byali")) || (StrEqual(szBotName, "Markoś")) || (StrEqual(szBotName, "tudsoN")) || (StrEqual(szBotName, "Kylar")) || (StrEqual(szBotName, "nawrot")))
	{
		CS_SetClientClanTag(client, "AVEZ");
	}
	
	//Furious Players
	if((StrEqual(szBotName, "nbl")) || (StrEqual(szBotName, "tom1")) || (StrEqual(szBotName, "Owensinho")) || (StrEqual(szBotName, "iKrystal")) || (StrEqual(szBotName, "pablek")))
	{
		CS_SetClientClanTag(client, "Furious");
	}
	
	//GTZ Players
	if((StrEqual(szBotName, "StepA")) || (StrEqual(szBotName, "snapy")) || (StrEqual(szBotName, "slaxx")) || (StrEqual(szBotName, "Dante")) || (StrEqual(szBotName, "fakes2")))
	{
		CS_SetClientClanTag(client, "GTZ");
	}
	
	//x6tence Players
	if((StrEqual(szBotName, "Queenix")) || (StrEqual(szBotName, "zEVES")) || (StrEqual(szBotName, "maNkz")) || (StrEqual(szBotName, "mertz")) || (StrEqual(szBotName, "Nodios")))
	{
		CS_SetClientClanTag(client, "x6tence");
	}
	
	//K23 Players
	if((StrEqual(szBotName, "neaLaN")) || (StrEqual(szBotName, "mou")) || (StrEqual(szBotName, "n0rb3r7")) || (StrEqual(szBotName, "kade0")) || (StrEqual(szBotName, "Keoz")))
	{
		CS_SetClientClanTag(client, "K23");
	}
	
	//Goliath Players
	if((StrEqual(szBotName, "massacRe")) || (StrEqual(szBotName, "Dweezil")) || (StrEqual(szBotName, "adM")) || (StrEqual(szBotName, "ELUSIVE")) || (StrEqual(szBotName, "ZipZip")))
	{
		CS_SetClientClanTag(client, "Goliath");
	}
	
	//Secret Players
	if((StrEqual(szBotName, "juanflatroo")) || (StrEqual(szBotName, "smF")) || (StrEqual(szBotName, "PERCY")) || (StrEqual(szBotName, "sinnopsyy")) || (StrEqual(szBotName, "anarkez")))
	{
		CS_SetClientClanTag(client, "Secret");
	}
	
	//UOL Players
	if((StrEqual(szBotName, "crisby")) || (StrEqual(szBotName, "kzy")) || (StrEqual(szBotName, "Andyy")) || (StrEqual(szBotName, "JDC")) || (StrEqual(szBotName, "P4TriCK")))
	{
		CS_SetClientClanTag(client, "UOL");
	}
	
	//RADIX Players
	if((StrEqual(szBotName, "mrhui")) || (StrEqual(szBotName, "joss")) || (StrEqual(szBotName, "brky")) || (StrEqual(szBotName, "entz")) || (StrEqual(szBotName, "eZo")))
	{
		CS_SetClientClanTag(client, "RADIX");
	}
	
	//Illuminar Players
	if((StrEqual(szBotName, "Vegi")) || (StrEqual(szBotName, "Snax")) || (StrEqual(szBotName, "mouz")) || (StrEqual(szBotName, "reatz")) || (StrEqual(szBotName, "phr")))
	{
		CS_SetClientClanTag(client, "Illuminar");
	}
	
	//Queso Players
	if((StrEqual(szBotName, "TheClaran")) || (StrEqual(szBotName, "thinkii")) || (StrEqual(szBotName, "HUMANZ")) || (StrEqual(szBotName, "mik")) || (StrEqual(szBotName, "Yaba")))
	{
		CS_SetClientClanTag(client, "Queso");
	}
	
	//IG Players
	if((StrEqual(szBotName, "bottle")) || (StrEqual(szBotName, "DeStRoYeR")) || (StrEqual(szBotName, "flying")) || (StrEqual(szBotName, "Viva")) || (StrEqual(szBotName, "XiaosaGe")))
	{
		CS_SetClientClanTag(client, "IG");
	}
	
	//HR Players
	if((StrEqual(szBotName, "kAliNkA")) || (StrEqual(szBotName, "jR")) || (StrEqual(szBotName, "Flarich")) || (StrEqual(szBotName, "ProbLeM")) || (StrEqual(szBotName, "JIaYm")))
	{
		CS_SetClientClanTag(client, "HR");
	}
	
	//Dice Players
	if((StrEqual(szBotName, "XpG")) || (StrEqual(szBotName, "nonick")) || (StrEqual(szBotName, "Kan4")) || (StrEqual(szBotName, "Polox")) || (StrEqual(szBotName, "Djoko")))
	{
		CS_SetClientClanTag(client, "Dice");
	}
	
	//PlanetKey Players
	if((StrEqual(szBotName, "LapeX")) || (StrEqual(szBotName, "Printek")) || (StrEqual(szBotName, "glaVed")) || (StrEqual(szBotName, "ND")) || (StrEqual(szBotName, "impulsG")))
	{
		CS_SetClientClanTag(client, "PlanetKey");
	}
	
	//Vexed Players
	if((StrEqual(szBotName, "dox")) || (StrEqual(szBotName, "shyyne")) || (StrEqual(szBotName, "leafy")) || (StrEqual(szBotName, "shateri")) || (StrEqual(szBotName, "volt")))
	{
		CS_SetClientClanTag(client, "Vexed");
	}
	
	//HLE Players
	if((strcmp(szBotName, "d1Ledez") == 0) || (strcmp(szBotName, "DrobnY") == 0) || (strcmp(szBotName, "Raijin") == 0) || (strcmp(szBotName, "Forester") == 0) || (strcmp(szBotName, "svyat") == 0))
	{
		CS_SetClientClanTag(client, "HLE");
	}
	
	//Gambit Players
	if((strcmp(szBotName, "nafany") == 0) || (strcmp(szBotName, "sh1ro") == 0) || (strcmp(szBotName, "interz") == 0) || (strcmp(szBotName, "Ax1Le") == 0) || (strcmp(szBotName, "Hobbit") == 0))
	{
		CS_SetClientClanTag(client, "Gambit");
	}
	
	//Wisla Players
	if((StrEqual(szBotName, "hades")) || (StrEqual(szBotName, "SZPERO")) || (StrEqual(szBotName, "mynio")) || (StrEqual(szBotName, "ponczek")) || (StrEqual(szBotName, "jedqr")))
	{
		CS_SetClientClanTag(client, "Wisla");
	}
	
	//Imperial Players
	if((StrEqual(szBotName, "fnx")) || (StrEqual(szBotName, "zqk")) || (StrEqual(szBotName, "adr")) || (StrEqual(szBotName, "iDk")) || (StrEqual(szBotName, "SHOOWTiME")))
	{
		CS_SetClientClanTag(client, "Imperial");
	}
	
	//Pompa Players
	if((StrEqual(szBotName, "iso")) || (StrEqual(szBotName, "SKRZYNKA")) || (StrEqual(szBotName, "LAYNER")) || (StrEqual(szBotName, "OLIMP")) || (StrEqual(szBotName, "blacktear5")))
	{
		CS_SetClientClanTag(client, "Pompa");
	}
	
	//Unique Players
	if((StrEqual(szBotName, "crush")) || (StrEqual(szBotName, "H1te")) || (StrEqual(szBotName, "shalfey")) || (StrEqual(szBotName, "SELLTER")) || (StrEqual(szBotName, "fenvicious")))
	{
		CS_SetClientClanTag(client, "Unique");
	}
	
	//Izako Players
	if((StrEqual(szBotName, "Siuhy")) || (StrEqual(szBotName, "szejn")) || (StrEqual(szBotName, "EXUS")) || (StrEqual(szBotName, "avis")) || (StrEqual(szBotName, "TOAO")))
	{
		CS_SetClientClanTag(client, "Izako");
	}
	
	//ATK Players
	if((StrEqual(szBotName, "bLazE")) || (StrEqual(szBotName, "MisteM")) || (StrEqual(szBotName, "SloWye")) || (StrEqual(szBotName, "Fadey")) || (StrEqual(szBotName, "Doru")))
	{
		CS_SetClientClanTag(client, "ATK");
	}
	
	//Chaos Players
	if((StrEqual(szBotName, "Xeppaa")) || (StrEqual(szBotName, "vanity")) || (StrEqual(szBotName, "leaf")) || (StrEqual(szBotName, "MarKE")) || (StrEqual(szBotName, "Jonji")))
	{
		CS_SetClientClanTag(client, "Chaos");
	}
	
	//Wings Players
	if((strcmp(szBotName, "ChildKing") == 0) || (strcmp(szBotName, "lan") == 0) || (strcmp(szBotName, "MarT1n") == 0) || (strcmp(szBotName, "DD") == 0) || (strcmp(szBotName, "gas") == 0))
	{
		CS_SetClientClanTag(client, "Wings");
	}
	
	//Lynn Players
	if((StrEqual(szBotName, "XG")) || (StrEqual(szBotName, "mitsuha")) || (StrEqual(szBotName, "Aree")) || (StrEqual(szBotName, "EXPRO")) || (StrEqual(szBotName, "XinKoiNg")))
	{
		CS_SetClientClanTag(client, "Lynn");
	}
	
	//Triumph Players
	if((StrEqual(szBotName, "Shakezullah")) || (StrEqual(szBotName, "Junior")) || (StrEqual(szBotName, "ryann")) || (StrEqual(szBotName, "penny")) || (StrEqual(szBotName, "moose")))
	{
		CS_SetClientClanTag(client, "Triumph");
	}
	
	//FATE Players
	if((StrEqual(szBotName, "blocker")) || (StrEqual(szBotName, "Patrick")) || (StrEqual(szBotName, "harn")) || (StrEqual(szBotName, "Mar")) || (StrEqual(szBotName, "niki1")))
	{
		CS_SetClientClanTag(client, "FATE");
	}
	
	//Canids Players
	if((StrEqual(szBotName, "DeStiNy")) || (StrEqual(szBotName, "nythonzinho")) || (StrEqual(szBotName, "heat")) || (StrEqual(szBotName, "latto")) || (StrEqual(szBotName, "KHTEX")))
	{
		CS_SetClientClanTag(client, "Canids");
	}
	
	//ESPADA Players
	if((StrEqual(szBotName, "Patsanchick")) || (StrEqual(szBotName, "degster")) || (StrEqual(szBotName, "FinigaN")) || (StrEqual(szBotName, "S0tF1k")) || (StrEqual(szBotName, "Dima")))
	{
		CS_SetClientClanTag(client, "ESPADA");
	}
	
	//OG Players
	if((StrEqual(szBotName, "NBK-")) || (StrEqual(szBotName, "mantuu")) || (StrEqual(szBotName, "Aleksib")) || (StrEqual(szBotName, "valde")) || (StrEqual(szBotName, "ISSAA")))
	{
		CS_SetClientClanTag(client, "OG");
	}
	
	//Wizards Players
	if((StrEqual(szBotName, "Bernard")) || (StrEqual(szBotName, "blackie")) || (StrEqual(szBotName, "kzealos")) || (StrEqual(szBotName, "eneshan")) || (StrEqual(szBotName, "dreez")))
	{
		CS_SetClientClanTag(client, "Wizards");
	}
	
	//Tricked Players
	if((StrEqual(szBotName, "kiR")) || (StrEqual(szBotName, "kwezz")) || (StrEqual(szBotName, "Luckyv1")) || (StrEqual(szBotName, "sycrone")) || (StrEqual(szBotName, "PR1mE")))
	{
		CS_SetClientClanTag(client, "Tricked");
	}
	
	//Gen.G Players
	if((StrEqual(szBotName, "autimatic")) || (StrEqual(szBotName, "koosta")) || (StrEqual(szBotName, "daps")) || (StrEqual(szBotName, "s0m")) || (StrEqual(szBotName, "BnTeT")))
	{
		CS_SetClientClanTag(client, "Gen.G");
	}
	
	//Endpoint Players
	if((strcmp(szBotName, "Surreal") == 0) || (strcmp(szBotName, "CRUC1AL") == 0) || (strcmp(szBotName, "MiGHTYMAX") == 0) || (strcmp(szBotName, "robiin") == 0) || (strcmp(szBotName, "flameZ") == 0))
	{
		CS_SetClientClanTag(client, "Endpoint");
	}
	
	//sAw Players
	if((StrEqual(szBotName, "arki")) || (StrEqual(szBotName, "stadodo")) || (StrEqual(szBotName, "JUST")) || (StrEqual(szBotName, "MUTiRiS")) || (StrEqual(szBotName, "rmn")))
	{
		CS_SetClientClanTag(client, "sAw");
	}
	
	//DIG Players
	if((StrEqual(szBotName, "H4RR3")) || (StrEqual(szBotName, "hallzerk")) || (StrEqual(szBotName, "f0rest")) || (StrEqual(szBotName, "friberg")) || (StrEqual(szBotName, "HEAP")))
	{
		CS_SetClientClanTag(client, "DIG");
	}
	
	//D13 Players
	if((StrEqual(szBotName, "Tamiraarita")) || (StrEqual(szBotName, "hasteka")) || (StrEqual(szBotName, "shinobi")) || (StrEqual(szBotName, "sK0R")) || (StrEqual(szBotName, "ANNIHILATION")))
	{
		CS_SetClientClanTag(client, "D13");
	}
	
	//ZIGMA Players
	if((StrEqual(szBotName, "NIFFY")) || (StrEqual(szBotName, "Reality")) || (StrEqual(szBotName, "JUSTCAUSE")) || (StrEqual(szBotName, "PPOverdose")) || (StrEqual(szBotName, "RoLEX")))
	{
		CS_SetClientClanTag(client, "ZIGMA");
	}
	
	//Ambush Players
	if((StrEqual(szBotName, "Inzta")) || (StrEqual(szBotName, "Ryxxo")) || (StrEqual(szBotName, "zeq")) || (StrEqual(szBotName, "Typos")) || (StrEqual(szBotName, "IceBerg")))
	{
		CS_SetClientClanTag(client, "Ambush");
	}
	
	//KOVA Players
	if((StrEqual(szBotName, "pietola")) || (StrEqual(szBotName, "spargo")) || (StrEqual(szBotName, "uli")) || (StrEqual(szBotName, "peku")) || (StrEqual(szBotName, "Twixie")))
	{
		CS_SetClientClanTag(client, "KOVA");
	}
	
	//eXploit Players
	if((StrEqual(szBotName, "pizituh")) || (StrEqual(szBotName, "BuJ")) || (StrEqual(szBotName, "sark")) || (StrEqual(szBotName, "renatoohaxx")) || (StrEqual(szBotName, "BLOODZ")))
	{
		CS_SetClientClanTag(client, "eXploit");
	}
	
	//AGF Players
	if((StrEqual(szBotName, "fr0slev")) || (StrEqual(szBotName, "Kristou")) || (StrEqual(szBotName, "netrick")) || (StrEqual(szBotName, "TMB")) || (StrEqual(szBotName, "Lukki")))
	{
		CS_SetClientClanTag(client, "AGF");
	}
	
	//GameAgents Players
	if((StrEqual(szBotName, "markk")) || (StrEqual(szBotName, "renne")) || (StrEqual(szBotName, "s0und")) || (StrEqual(szBotName, "regali")) || (StrEqual(szBotName, "smekk-")))
	{
		CS_SetClientClanTag(client, "GameAgents");
	}
	
	//Keyd Players
	if((StrEqual(szBotName, "bnc")) || (StrEqual(szBotName, "mawth")) || (StrEqual(szBotName, "tifa")) || (StrEqual(szBotName, "jota")) || (StrEqual(szBotName, "puni")))
	{
		CS_SetClientClanTag(client, "Keyd");
	}
	
	//Epsilon Players
	if((StrEqual(szBotName, "ALEXJ")) || (StrEqual(szBotName, "smogger")) || (StrEqual(szBotName, "Celebrations")) || (StrEqual(szBotName, "Masti")) || (StrEqual(szBotName, "Blytz")))
	{
		CS_SetClientClanTag(client, "Epsilon");
	}
	
	//TIGER Players
	if((StrEqual(szBotName, "erkaSt")) || (StrEqual(szBotName, "nin9")) || (StrEqual(szBotName, "dobu")) || (StrEqual(szBotName, "kabal")) || (StrEqual(szBotName, "rate")))
	{
		CS_SetClientClanTag(client, "TIGER");
	}
	
	//LEISURE Players
	if((StrEqual(szBotName, "stefank0k0")) || (StrEqual(szBotName, "BischeR")) || (StrEqual(szBotName, "farmaG")) || (StrEqual(szBotName, "FabeeN")) || (StrEqual(szBotName, "bustrex")))
	{
		CS_SetClientClanTag(client, "LEISURE");
	}
	
	//PENTA Players
	if((StrEqual(szBotName, "pdy")) || (StrEqual(szBotName, "red")) || (StrEqual(szBotName, "s1n")) || (StrEqual(szBotName, "xenn")) || (StrEqual(szBotName, "skyye")))
	{
		CS_SetClientClanTag(client, "PENTA");
	}
	
	//PENTA Players
	if((StrEqual(szBotName, "sh1zlEE")) || (StrEqual(szBotName, "Jaepe")) || (StrEqual(szBotName, "brA")) || (StrEqual(szBotName, "plat")) || (StrEqual(szBotName, "Cunha")))
	{
		CS_SetClientClanTag(client, "FTW");
	}
	
	//Titans Players
	if((StrEqual(szBotName, "doublemagic")) || (StrEqual(szBotName, "KalubeR")) || (StrEqual(szBotName, "rafftu")) || (StrEqual(szBotName, "sarenii")) || (StrEqual(szBotName, "viltrex")))
	{
		CS_SetClientClanTag(client, "Titans");
	}
	
	//9INE Players
	if((StrEqual(szBotName, "CyderX")) || (StrEqual(szBotName, "xfl0ud")) || (StrEqual(szBotName, "qRaxs")) || (StrEqual(szBotName, "Izzy")) || (StrEqual(szBotName, "QutionerX")))
	{
		CS_SetClientClanTag(client, "9INE");
	}
	
	//QBF Players
	if((StrEqual(szBotName, "JACKPOT")) || (StrEqual(szBotName, "Quantium")) || (StrEqual(szBotName, "Kas9k")) || (StrEqual(szBotName, "hiji")) || (StrEqual(szBotName, "lesswill")))
	{
		CS_SetClientClanTag(client, "QBF");
	}
	
	//Tigers Players
	if((StrEqual(szBotName, "MAXX")) || (StrEqual(szBotName, "Lastík")) || (StrEqual(szBotName, "zyored")) || (StrEqual(szBotName, "wEAMO")) || (StrEqual(szBotName, "manguss")))
	{
		CS_SetClientClanTag(client, "Tigers");
	}
	
	//9z Players
	if((StrEqual(szBotName, "dgt")) || (StrEqual(szBotName, "try")) || (StrEqual(szBotName, "maxujas")) || (StrEqual(szBotName, "bit")) || (StrEqual(szBotName, "meyern")))
	{
		CS_SetClientClanTag(client, "9z");
	}
	
	//Malvinas Players
	if((StrEqual(szBotName, "ABM")) || (StrEqual(szBotName, "fakzwall")) || (StrEqual(szBotName, "minimal")) || (StrEqual(szBotName, "kary")) || (StrEqual(szBotName, "rushardo")))
	{
		CS_SetClientClanTag(client, "Malvinas");
	}
	
	//Sinister5 Players
	if((StrEqual(szBotName, "zerOchaNce")) || (StrEqual(szBotName, "FreakY")) || (StrEqual(szBotName, "deviaNt")) || (StrEqual(szBotName, "Lately")) || (StrEqual(szBotName, "slayeRyEyE")))
	{
		CS_SetClientClanTag(client, "Sinister5");
	}
	
	//SINNERS Players
	if((StrEqual(szBotName, "ZEDKO")) || (StrEqual(szBotName, "CaNNiE")) || (StrEqual(szBotName, "SHOCK")) || (StrEqual(szBotName, "beastik")) || (StrEqual(szBotName, "NEOFRAG")))
	{
		CS_SetClientClanTag(client, "SINNERS");
	}
	
	//Impact Players
	if((StrEqual(szBotName, "DaneJoris")) || (StrEqual(szBotName, "JoJo")) || (StrEqual(szBotName, "ERIC")) || (StrEqual(szBotName, "Koalanoob")) || (StrEqual(szBotName, "insane")))
	{
		CS_SetClientClanTag(client, "Impact");
	}
	
	//ERN Players
	if((strcmp(szBotName, "j1NZO") == 0) || (strcmp(szBotName, "preet") == 0) || (strcmp(szBotName, "ReacTioNNN") == 0) || (strcmp(szBotName, "FreeZe") == 0) || (strcmp(szBotName, "S3NSEY") == 0))
	{
		CS_SetClientClanTag(client, "ERN");
	}
	
	//BL4ZE Players
	if((strcmp(szBotName, "Rossi") == 0) || (strcmp(szBotName, "Marzil") == 0) || (strcmp(szBotName, "SkRossi") == 0) || (strcmp(szBotName, "Raph") == 0) || (strcmp(szBotName, "cara") == 0))
	{
		CS_SetClientClanTag(client, "BL4ZE");
	}
	
	//Global Players
	if((strcmp(szBotName, "HellrangeR") == 0) || (strcmp(szBotName, "Karam1L") == 0) || (strcmp(szBotName, "hellff") == 0) || (strcmp(szBotName, "DEATHMAKER") == 0) || (strcmp(szBotName, "Lightningfast") == 0))
	{
		CS_SetClientClanTag(client, "Global");
	}
	
	//Conquer Players
	if((strcmp(szBotName, "NiNLeX") == 0) || (strcmp(szBotName, "RONDE") == 0) || (strcmp(szBotName, "S1rva") == 0) || (strcmp(szBotName, "jelo") == 0) || (strcmp(szBotName, "KonZero") == 0))
	{
		CS_SetClientClanTag(client, "Conquer");
	}
	
	//Rooster Players
	if((strcmp(szBotName, "DannyG") == 0) || (strcmp(szBotName, "nettik") == 0) || (strcmp(szBotName, "chelleos") == 0) || (strcmp(szBotName, "ADK") == 0) || (strcmp(szBotName, "asap") == 0))
	{
		CS_SetClientClanTag(client, "Rooster");
	}
	
	//Flames Players
	if((strcmp(szBotName, "nicoodoz") == 0) || (strcmp(szBotName, "AcilioN") == 0) || (strcmp(szBotName, "Basso") == 0) || (strcmp(szBotName, "Jabbi") == 0) || (strcmp(szBotName, "Daffu") == 0))
	{
		CS_SetClientClanTag(client, "Flames");
	}
	
	//Baecon Players
	if((strcmp(szBotName, "emp") == 0) || (strcmp(szBotName, "vts") == 0) || (strcmp(szBotName, "kst") == 0) || (strcmp(szBotName, "whatz") == 0) || (strcmp(szBotName, "shellzi") == 0))
	{
		CS_SetClientClanTag(client, "Baecon");
	}
	
	//KPI Players
	if((strcmp(szBotName, "pounh") == 0) || (strcmp(szBotName, "SAYN") == 0) || (strcmp(szBotName, "Aaron") == 0) || (strcmp(szBotName, "Butters") == 0) || (strcmp(szBotName, "ztr") == 0))
	{
		CS_SetClientClanTag(client, "KPI");
	}
	
	//hREDS Players
	if((strcmp(szBotName, "eDi") == 0) || (strcmp(szBotName, "oopee") == 0) || (strcmp(szBotName, "VORMISTO") == 0) || (strcmp(szBotName, "Samppa") == 0) || (strcmp(szBotName, "xartE") == 0))
	{
		CS_SetClientClanTag(client, "hREDS");
	}
	
	//Lemondogs Players
	if((strcmp(szBotName, "xelos") == 0) || (strcmp(szBotName, "kaktus") == 0) || (strcmp(szBotName, "hemzk9") == 0) || (strcmp(szBotName, "Mann3n") == 0) || (strcmp(szBotName, "gamersdont") == 0))
	{
		CS_SetClientClanTag(client, "Lemondogs");
	}
	
	//Alpha Players
	if((strcmp(szBotName, "Medi") == 0) || (strcmp(szBotName, "dez1per") == 0) || (strcmp(szBotName, "LeguliaS") == 0) || (strcmp(szBotName, "NolderN") == 0) || (strcmp(szBotName, "fakeZ") == 0))
	{
		CS_SetClientClanTag(client, "Alpha");
	}
	
	//CeX Players
	if((strcmp(szBotName, "JackB") == 0) || (strcmp(szBotName, "Impact") == 0) || (strcmp(szBotName, "RezzeD") == 0) || (strcmp(szBotName, "fluFFS") == 0) || (strcmp(szBotName, "ifan") == 0))
	{
		CS_SetClientClanTag(client, "CeX");
	}
}

public void SetCustomPrivateRank(int client)
{
	char szClan[64];
	
	CS_GetClientClanTag(client, szClan, sizeof(szClan));
	
	if (StrEqual(szClan, "NiP"))
	{
		g_iProfileRank[client] = 41;
	}
	
	if (StrEqual(szClan, "MIBR"))
	{
		g_iProfileRank[client] = 42;
	}
	
	if (StrEqual(szClan, "FaZe"))
	{
		g_iProfileRank[client] = 43;
	}
	
	if (StrEqual(szClan, "Astralis"))
	{
		g_iProfileRank[client] = 44;
	}
	
	if (StrEqual(szClan, "C9"))
	{
		g_iProfileRank[client] = 45;
	}
	
	if (StrEqual(szClan, "G2"))
	{
		g_iProfileRank[client] = 46;
	}
	
	if (StrEqual(szClan, "fnatic"))
	{
		g_iProfileRank[client] = 47;
	}
	
	if (StrEqual(szClan, "North"))
	{
		g_iProfileRank[client] = 48;
	}
	
	if (StrEqual(szClan, "mouz"))
	{
		g_iProfileRank[client] = 49;
	}
	
	if (StrEqual(szClan, "TYLOO"))
	{
		g_iProfileRank[client] = 50;
	}
	
	if (StrEqual(szClan, "EG"))
	{
		g_iProfileRank[client] = 51;
	}
	
	if (strcmp(szClan, "Vireo.Pro") == 0)
	{
		g_iProfileRank[client] = 52;
	}
	
	if (StrEqual(szClan, "Na´Vi"))
	{
		g_iProfileRank[client] = 53;
	}
	
	if (StrEqual(szClan, "Liquid"))
	{
		g_iProfileRank[client] = 54;
	}
	
	if (StrEqual(szClan, "AGO"))
	{
		g_iProfileRank[client] = 55;
	}
	
	if (StrEqual(szClan, "ENCE"))
	{
		g_iProfileRank[client] = 56;
	}
	
	if (StrEqual(szClan, "Vitality"))
	{
		g_iProfileRank[client] = 57;
	}
	
	if (StrEqual(szClan, "BIG"))
	{
		g_iProfileRank[client] = 58;
	}
	
	if (StrEqual(szClan, "Triumph"))
	{
		g_iProfileRank[client] = 59;
	}
	
	if (strcmp(szClan, "Rooster") == 0)
	{
		g_iProfileRank[client] = 60;
	}
	
	if (StrEqual(szClan, "FURIA"))
	{
		g_iProfileRank[client] = 61;
	}
	
	if (StrEqual(szClan, "c0ntact"))
	{
		g_iProfileRank[client] = 62;
	}
	
	if (StrEqual(szClan, "coL"))
	{
		g_iProfileRank[client] = 63;
	}
	
	if (StrEqual(szClan, "ViCi"))
	{
		g_iProfileRank[client] = 64;
	}
	
	if (StrEqual(szClan, "forZe"))
	{
		g_iProfileRank[client] = 65;
	}
	
	if (StrEqual(szClan, "Winstrike"))
	{
		g_iProfileRank[client] = 66;
	}
	
	if (StrEqual(szClan, "Sprout"))
	{
		g_iProfileRank[client] = 67;
	}
	
	if (StrEqual(szClan, "Heroic"))
	{
		g_iProfileRank[client] = 68;
	}
	
	if (StrEqual(szClan, "INTZ"))
	{
		g_iProfileRank[client] = 69;
	}
	
	if (StrEqual(szClan, "VP"))
	{
		g_iProfileRank[client] = 70;
	}
	
	if (StrEqual(szClan, "Apeks"))
	{
		g_iProfileRank[client] = 71;
	}
	
	if (StrEqual(szClan, "aTTaX"))
	{
		g_iProfileRank[client] = 72;
	}
	
	if (StrEqual(szClan, "RNG"))
	{
		g_iProfileRank[client] = 73;
	}
	
	if (strcmp(szClan, "BL4ZE") == 0)
	{
		g_iProfileRank[client] = 74;
	}
	
	if (StrEqual(szClan, "Envy"))
	{
		g_iProfileRank[client] = 75;
	}
	
	if (StrEqual(szClan, "Spirit"))
	{
		g_iProfileRank[client] = 76;
	}
	
	if (strcmp(szClan, "ERN") == 0)
	{
		g_iProfileRank[client] = 77;
	}
	
	if (StrEqual(szClan, "LDLC"))
	{
		g_iProfileRank[client] = 78;
	}
	
	if (StrEqual(szClan, "Impact"))
	{
		g_iProfileRank[client] = 79;
	}
	
	if (StrEqual(szClan, "GamerLegion"))
	{
		g_iProfileRank[client] = 80;
	}
	
	if (StrEqual(szClan, "DIVIZON"))
	{
		g_iProfileRank[client] = 81;
	}
	
	if (strcmp(szClan, "CeX") == 0)
	{
		g_iProfileRank[client] = 82;
	}
	
	if (StrEqual(szClan, "Tricked"))
	{
		g_iProfileRank[client] = 83;
	}
	
	if (StrEqual(szClan, "Wolsung"))
	{
		g_iProfileRank[client] = 84;
	}
	
	if (StrEqual(szClan, "PDucks"))
	{
		g_iProfileRank[client] = 85;
	}
	
	if (StrEqual(szClan, "HAVU"))
	{
		g_iProfileRank[client] = 86;
	}
	
	if (StrEqual(szClan, "Lyngby"))
	{
		g_iProfileRank[client] = 87;
	}
	
	if (StrEqual(szClan, "GODSENT"))
	{
		g_iProfileRank[client] = 88;
	}
	
	if (StrEqual(szClan, "Nordavind"))
	{
		g_iProfileRank[client] = 89;
	}
	
	if (StrEqual(szClan, "SJ"))
	{
		g_iProfileRank[client] = 90;
	}
	
	if (StrEqual(szClan, "Bren"))
	{
		g_iProfileRank[client] = 91;
	}
	
	if (StrEqual(szClan, "SINNERS"))
	{
		g_iProfileRank[client] = 92;
	}
	
	if (StrEqual(szClan, "Giants"))
	{
		g_iProfileRank[client] = 93;
	}
	
	if (StrEqual(szClan, "Lions"))
	{
		g_iProfileRank[client] = 94;
	}
	
	if (StrEqual(szClan, "Riders"))
	{
		g_iProfileRank[client] = 95;
	}
	
	if (StrEqual(szClan, "OFFSET"))
	{
		g_iProfileRank[client] = 96;
	}
	
	if (StrEqual(szClan, "Sinister5"))
	{
		g_iProfileRank[client] = 97;
	}
	
	if (StrEqual(szClan, "eSuba"))
	{
		g_iProfileRank[client] = 98;
	}
	
	if (StrEqual(szClan, "Nexus"))
	{
		g_iProfileRank[client] = 99;
	}
	
	if (StrEqual(szClan, "PACT"))
	{
		g_iProfileRank[client] = 100;
	}
	
	if (StrEqual(szClan, "Heretics"))
	{
		g_iProfileRank[client] = 101;
	}
	
	if (StrEqual(szClan, "Lynn"))
	{
		g_iProfileRank[client] = 102;
	}
	
	if (StrEqual(szClan, "Nemiga"))
	{
		g_iProfileRank[client] = 103;
	}
	
	if (StrEqual(szClan, "pro100"))
	{
		g_iProfileRank[client] = 104;
	}
	
	if (StrEqual(szClan, "YaLLa"))
	{
		g_iProfileRank[client] = 105;
	}
	
	if (StrEqual(szClan, "Yeah"))
	{
		g_iProfileRank[client] = 106;
	}
	
	if (StrEqual(szClan, "Singularity"))
	{
		g_iProfileRank[client] = 107;
	}
	
	if (StrEqual(szClan, "DETONA"))
	{
		g_iProfileRank[client] = 108;
	}
	
	if (StrEqual(szClan, "Infinity"))
	{
		g_iProfileRank[client] = 109;
	}
	
	if (StrEqual(szClan, "Isurus"))
	{
		g_iProfileRank[client] = 110;
	}
	
	if (StrEqual(szClan, "paiN"))
	{
		g_iProfileRank[client] = 111;
	}
	
	if (StrEqual(szClan, "Sharks"))
	{
		g_iProfileRank[client] = 112;
	}
	
	if (StrEqual(szClan, "One"))
	{
		g_iProfileRank[client] = 113;
	}
	
	if (StrEqual(szClan, "W7M"))
	{
		g_iProfileRank[client] = 114;
	}
	
	if (StrEqual(szClan, "Avant"))
	{
		g_iProfileRank[client] = 115;
	}
	
	if (StrEqual(szClan, "Chiefs"))
	{
		g_iProfileRank[client] = 116;
	}
	
	if (StrEqual(szClan, "DIG"))
	{
		g_iProfileRank[client] = 117;
	}
	
	if (StrEqual(szClan, "ORDER"))
	{
		g_iProfileRank[client] = 118;
	}
	
	if (StrEqual(szClan, "SKADE"))
	{
		g_iProfileRank[client] = 120;
	}
	
	if (StrEqual(szClan, "Paradox"))
	{
		g_iProfileRank[client] = 121;
	}
	
	if (StrEqual(szClan, "PENTA"))
	{
		g_iProfileRank[client] = 122;
	}
	
	if (StrEqual(szClan, "FTW"))
	{
		g_iProfileRank[client] = 123;
	}
	
	if (StrEqual(szClan, "Beyond"))
	{
		g_iProfileRank[client] = 124;
	}
	
	if (StrEqual(szClan, "BOOM"))
	{
		g_iProfileRank[client] = 125;
	}
	
	if (StrEqual(szClan, "sAw"))
	{
		g_iProfileRank[client] = 126;
	}
	
	if (strcmp(szClan, "Wings") == 0)
	{
		g_iProfileRank[client] = 128;
	}
	
	if (strcmp(szClan, "Global") == 0)
	{
		g_iProfileRank[client] = 129;
	}
	
	if (StrEqual(szClan, "NASR"))
	{
		g_iProfileRank[client] = 130;
	}
	
	if (StrEqual(szClan, "LEISURE"))
	{
		g_iProfileRank[client] = 131;
	}
	
	if (StrEqual(szClan, "Revolution"))
	{
		g_iProfileRank[client] = 132;
	}
	
	if (StrEqual(szClan, "SHIFT"))
	{
		g_iProfileRank[client] = 133;
	}
	
	if (StrEqual(szClan, "nxl"))
	{
		g_iProfileRank[client] = 134;
	}
	
	if (strcmp(szClan, "LLL") == 0)
	{
		g_iProfileRank[client] = 135;
	}
	
	if (StrEqual(szClan, "Energy"))
	{
		g_iProfileRank[client] = 136;
	}
	
	if (StrEqual(szClan, "Titans"))
	{
		g_iProfileRank[client] = 137;
	}
	
	if (strcmp(szClan, "Conquer") == 0)
	{
		g_iProfileRank[client] = 138;
	}
	
	if (StrEqual(szClan, "TIGER"))
	{
		g_iProfileRank[client] = 139;
	}
	
	if (StrEqual(szClan, "GroundZero"))
	{
		g_iProfileRank[client] = 140;
	}
	
	if (StrEqual(szClan, "AVEZ"))
	{
		g_iProfileRank[client] = 141;
	}
	
	if (StrEqual(szClan, "Gen.G"))
	{
		g_iProfileRank[client] = 143;
	}
	
	if (StrEqual(szClan, "Furious"))
	{
		g_iProfileRank[client] = 144;
	}
	
	if (StrEqual(szClan, "GTZ"))
	{
		g_iProfileRank[client] = 145;
	}
	
	if (StrEqual(szClan, "x6tence"))
	{
		g_iProfileRank[client] = 146;
	}
	
	if (StrEqual(szClan, "Epsilon"))
	{
		g_iProfileRank[client] = 147;
	}
	
	if (StrEqual(szClan, "9INE"))
	{
		g_iProfileRank[client] = 149;
	}
	
	if (StrEqual(szClan, "K23"))
	{
		g_iProfileRank[client] = 150;
	}
	
	if (StrEqual(szClan, "QBF"))
	{
		g_iProfileRank[client] = 151;
	}
	
	if (StrEqual(szClan, "Goliath"))
	{
		g_iProfileRank[client] = 152;
	}
	
	if (StrEqual(szClan, "Secret"))
	{
		g_iProfileRank[client] = 153;
	}
	
	if (strcmp(szClan, "hREDS") == 0)
	{
		g_iProfileRank[client] = 154;
	}
	
	if (strcmp(szClan, "Endpoint") == 0)
	{
		g_iProfileRank[client] = 155;
	}
	
	if (StrEqual(szClan, "UOL"))
	{
		g_iProfileRank[client] = 156;
	}
	
	if (StrEqual(szClan, "GameAgents"))
	{
		g_iProfileRank[client] = 157;
	}
	
	if (StrEqual(szClan, "RADIX"))
	{
		g_iProfileRank[client] = 158;
	}
	
	if (strcmp(szClan, "KPI") == 0)
	{
		g_iProfileRank[client] = 159;
	}
	
	if (StrEqual(szClan, "Keyd"))
	{
		g_iProfileRank[client] = 160;
	}
	
	if (StrEqual(szClan, "Illuminar"))
	{
		g_iProfileRank[client] = 161;
	}
	
	if (StrEqual(szClan, "Queso"))
	{
		g_iProfileRank[client] = 162;
	}
	
	if (strcmp(szClan, "Wizards") == 0)
	{
		g_iProfileRank[client] = 163;
	}
	
	if (StrEqual(szClan, "AGF"))
	{
		g_iProfileRank[client] = 164;
	}
	
	if (StrEqual(szClan, "eXploit"))
	{
		g_iProfileRank[client] = 165;
	}
	
	if (StrEqual(szClan, "IG"))
	{
		g_iProfileRank[client] = 166;
	}
	
	if (StrEqual(szClan, "HR"))
	{
		g_iProfileRank[client] = 167;
	}
	
	if (StrEqual(szClan, "Dice"))
	{
		g_iProfileRank[client] = 168;
	}
	
	if (StrEqual(szClan, "Tigers"))
	{
		g_iProfileRank[client] = 169;
	}
	
	if (StrEqual(szClan, "9z"))
	{
		g_iProfileRank[client] = 170;
	}
	
	if (StrEqual(szClan, "PlanetKey"))
	{
		g_iProfileRank[client] = 171;
	}
	
	if (strcmp(szClan, "Vexed") == 0)
	{
		g_iProfileRank[client] = 172;
	}
	
	if (StrEqual(szClan, "Malvinas"))
	{
		g_iProfileRank[client] = 173;
	}
	
	if (strcmp(szClan, "HLE") == 0)
	{
		g_iProfileRank[client] = 174;
	}
	
	if (strcmp(szClan, "Gambit") == 0)
	{
		g_iProfileRank[client] = 175;
	}
	
	if (StrEqual(szClan, "Wisla"))
	{
		g_iProfileRank[client] = 176;
	}
	
	if (StrEqual(szClan, "Imperial"))
	{
		g_iProfileRank[client] = 177;
	}
	
	if (StrEqual(szClan, "Pompa"))
	{
		g_iProfileRank[client] = 178;
	}
	
	if (StrEqual(szClan, "Unique"))
	{
		g_iProfileRank[client] = 179;
	}
	
	if (StrEqual(szClan, "D13"))
	{
		g_iProfileRank[client] = 180;
	}
	
	if (StrEqual(szClan, "Izako"))
	{
		g_iProfileRank[client] = 181;
	}
	
	if (StrEqual(szClan, "ATK"))
	{
		g_iProfileRank[client] = 182;
	}
	
	if (StrEqual(szClan, "Chaos"))
	{
		g_iProfileRank[client] = 183;
	}
	
	if (StrEqual(szClan, "FATE"))
	{
		g_iProfileRank[client] = 184;
	}
	
	if (StrEqual(szClan, "Canids"))
	{
		g_iProfileRank[client] = 185;
	}
	
	if (StrEqual(szClan, "ESPADA"))
	{
		g_iProfileRank[client] = 186;
	}
	
	if (StrEqual(szClan, "OG"))
	{
		g_iProfileRank[client] = 187;
	}
	
	if (StrEqual(szClan, "ZIGMA"))
	{
		g_iProfileRank[client] = 188;
	}
	
	if (StrEqual(szClan, "Ambush"))
	{
		g_iProfileRank[client] = 189;
	}
	
	if (StrEqual(szClan, "KOVA"))
	{
		g_iProfileRank[client] = 190;
	}
	
	if (strcmp(szClan, "Flames") == 0)
	{
		g_iProfileRank[client] = 191;
	}
	
	if (strcmp(szClan, "Baecon") == 0)
	{
		g_iProfileRank[client] = 192;
	}
	
	if (strcmp(szClan, "Lemondogs") == 0)
	{
		g_iProfileRank[client] = 193;
	}
	
	if (strcmp(szClan, "Alpha") == 0)
	{
		g_iProfileRank[client] = 194;
	}
}