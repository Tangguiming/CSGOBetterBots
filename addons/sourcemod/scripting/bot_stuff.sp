#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#pragma newdecls required

bool g_bShouldAttack[MAXPLAYERS + 1];
Handle g_hShouldAttackTimer[MAXPLAYERS + 1];
int g_iaGrenadeOffsets[] = {15, 17, 16, 14, 18, 17};
int g_iProfileRank[MAXPLAYERS+1], g_iCoin[MAXPLAYERS+1],g_iProfileRankOffset, g_iCoinOffset;

char g_sTRngGrenadesList[][] = {
    "weapon_flashbang",
    "weapon_smokegrenade",
    "weapon_hegrenade",
    "weapon_molotov"
};

char g_sCTRngGrenadesList[][] = {
    "weapon_flashbang",
    "weapon_smokegrenade",
    "weapon_hegrenade",
    "weapon_incgrenade"
};

char g_BotName[][] = {
	//MIBR Players
	"coldzera",
	"FalleN",
	"fer",
	"TACO",
	"LUCAS1",
	//FaZe Players
	"olofmeister",
	"GuardiaN",
	"NiKo",
	"rain",
	"NEO",
	//Astralis Players
	"Xyp9x",
	"device",
	"gla1ve",
	"Magisk",
	"dupreeh",
	//NiP Players
	"GeT_RiGhT",
	"Plopski",
	"f0rest",
	"Lekr0",
	"REZ",
	//C9 Players
	"autimatic",
	"mixwell",
	"daps",
	"koosta",
	"TenZ",
	//G2 Players
	"shox",
	"kennyS",
	"Lucky",
	"JaCkz",
	"AMANEK",
	//fnatic Players
	"twist",
	"JW",
	"KRiMZ",
	"Brollan",
	"Xizt",
	//North Players
	"JUGi",
	"Kjaerbye",
	"aizy",
	"valde",
	"gade",
	//mouz Players
	"karrigan",
	"chrisJ",
	"woxic",
	"frozen",
	"ropz",
	//TYLOO Players
	"Summer",
	"DANK1NG",
	"BnTneT",
	"somebody",
	"Attacker",
	//NRG Players
	"stanislaw",
	"tarik",
	"Brehze",
	"nahtE",
	"CeRq",
	//RNG Players
	"AZR",
	"jks",
	"jkaem",
	"Gratisfaction",
	"Liazz",
	//Na´Vi Players
	"electronic",
	"s1mple",
	"flamie",
	"Boombl4",
	"Zeus",
	//Liquid Players
	"Stewie2K",
	"NAF",
	"nitr0",
	"ELiGE",
	"Twistzz",
	//HR Players
	"ANGE1",
	"oskar",
	"nukkye",
	"loWel",
	"ISSAA",
	//AGO Players
	"innocent",
	"STOMP",
	"reatz",
	"oskarish",
	"mono",
	//ENCE Players
	"Aleksib",
	"allu",
	"sergej",
	"Aerial",
	"xseveN",
	//Vitality Players
	"NBK-",
	"ZywOo",
	"apEX",
	"RpK",
	"ALEX",
	//BIG Players
	"tiziaN",
	"denis",
	"XANTARES",
	"tabseN",
	"gob b",
	//AVANGAR Players
	"buster",
	"Jame",
	"qikert",
	"AdreN",
	"SANJI",
	//Windigo Players
	"SHiPZ",
	"bubble",
	"v1c7oR",
	"blocker",
	"poizon",
	//FURIA Players
	"yuurih",
	"arT",
	"VINI",
	"kscerato",
	"ableJ",
	//CR4ZY Players
	"LETN1",
	"ottoNd",
	"huNter",
	"nexa",
	"EspiranTo",
	//coL Players
	"dephh",
	"ShahZaM",
	"oBo",
	"Rickeh",
	"SicK",
	//ViCi Players
	"zhokiNg",
	"kaze",
	"aumaN",
	"Freeman",
	"advent",
	//forZe Players
	"facecrack",
	"xsepower",
	"FL1T",
	"almazer",
	"Jerry",
	//Winstrike Players
	"Edward",
	"Kvik",
	"n0rb3r7",
	"El1an",
	"bondik",
	//OpTic Players
	"k0nfig",
	"MSL",
	"nikozan",
	"Snappi",
	"refrezh",
	//Sprout Players
	"k1to",
	"syrsoN",
	"Spiidi",
	"faveN",
	"mirbit",
	//Heroic Players
	"es3tag",
	"NaToSaphiX",
	"friberg",
	"blameF",
	"stavn",
	//INTZ Players
	"chelo",
	"kNgV-",
	"xand",
	"destinyy",
	"yeL",
	//VP Players
	"MICHU",
	"snatchie",
	"phr",
	"Snax",
	"Vegi",
	//Apeks Players
	"aNdz",
	"truth",
	"Grusarn",
	"akEz",
	"Polly",
	//aTTaX Players
	"stfN",
	"slaxz",
	"DuDe",
	"kressy",
	"mantuu",
	//Grayhound Players
	"erkaSt",
	"sico",
	"dexter",
	"DickStacy",
	"malta",
	//LG Players
	"NEKIZ",
	"HEN1",
	"steel",
	"felps",
	"boltz",
	//MVP.PK Players
	"zeff",
	"xeta",
	"XigN",
	"Jinx",
	"stax",
	//Envy Players
	"Nifty",
	"Sonic",
	"s0m",
	"ANDROID",
	"FugLy",
	//Spirit Players
	"COLDYY1",
	"iDISBALANCE",
	"somedieyoung",
	"chopper",
	"S0tF1k",
	//Vega Players
	"seized",
	"jR",
	"crush",
	"scoobyxie",
	"Dima",
	//Lazarus Players
	"Zellsis",
	"swag",
	"yay",
	"Infinite",
	"Subroza",
	//CeX Players
	"LiamjS",
	"resu",
	"Nukeddog",
	"JamesBT",
	"znx-",
	//LDLC Players
	"rodeN",
	"Happy",
	"MAJ3R",
	"xms",
	"SIXER",
	//Defusekids Player
	"v1N",
	"G1DO",
	"FASHR",
	"Monu",
	"rilax",
	//Epsilon Players
	"Surreal",
	"CRUC1AL",
	"DroW",
	"SPELLAN",
	"broky",
	//GamerLegion Players
	"dennis",
	"nawwk",
	"ScreaM",
	"HS",
	"hampus",
	//DIVIZON Players
	"TR1P",
	"glaVed",
	"hyped",
	"n1kista",
	"MajoRR",
	//EURONICS Players
	"arno",
	"boostey",
	"PerX",
	"Seeeya",
	"Krimbo",
	//expert Players
	"ScrunK",
	"Andyy",
	"chrissK",
	"JDC",
	"PREET",
	//PANTHERS Players
	"zonixx",
	"LyGHT",
	"ecfN",
	"pdy",
	"red",
	//Planetkey Players
	"xenn",
	"delkore",
	"neviZ",
	"s1n",
	"Krabbe",
	//PDucks Players
	"Aika",
	"syncD",
	"BMLN",
	"HighKitty",
	"VENIQ",
	//Chaos Players
	"FREDDyFROG",
	"Relaxa",
	"PlesseN",
	"Bååten",
	"djL",
	//HAVU Players
	"ZOREE",
	"sLowi",
	"Twixie",
	"Hoody",
	"sAw",
	//Lyngby Players
	"birdfromsky",
	"Twinx",
	"Daffu",
	"zyp",
	"Cabbi",
	//NoChance Players
	"Thomas",
	"Maikelele",
	"kRYSTAL",
	"zehN",
	"STYKO",
	//Nordavind Players
	"tenzki",
	"hallzerk",
	"RUBINO",
	"H4RR3",
	"cromen",
	//SJ Players
	"arvid",
	"Jamppi",
	"SADDYX",
	"KHRN",
	"xartE",
	//SkitLite Players
	"emilz",
	"Derkeps",
	"OSKU",
	"zks",
	"Vladimus",
	//Tricked Players
	"b0RUP",
	"acoR",
	"HUNDEN",
	"Sjuush",
	"Lukki",
	//Baskonia Players
	"tatin",
	"PabLo",
	"LittlesataN1",
	"dixon",
	"jJavi",
	//Dragons Players
	"Enanoks",
	"Cr0n0s",
	"DonQ",
	"meisoN",
	"xikii",
	//Giants Players
	"romeM",
	"foxj",
	"KILLDREAM",
	"MUTiRiS",
	"ZELIN",
	//K1CK Players
	"Cunha",
	"MISK",
	"plat",
	"psh",
	"fakes2",
	//Lions Players
	"TorPe",
	"dragunov",
	"NaOw",
	"HUMANZ",
	"oW",
	//Riders Players
	"mopoz",
	"EasTor",
	"SOKER",
	"alëx",
	"DeathZz",
	//OFFSET Players
	"zlynx",
	"obj",
	"JUST",
	"stadodo",
	"pr",
	//x6tence Players
	"FlipiN",
	"JonY BoY",
	"TheClaran",
	"Meco",
	"Vares",
	//eSuba Players
	"HenkkyG",
	"CaNNiE",
	"daxen",
	"Fraged",
	"SHOCK",
	//Nexus Players
	"BTN",
	"XELLOW",
	"SEMINTE",
	"sXe",
	"COSMEEEN",
	//PACT Players
	"darko",
	"lunAtic",
	"morelz",
	"Sidney",
	"Sobol",
	//DreamEaters Players
	"kinqie",
	"speed4k",
	"Krad",
	"Forester",
	"svyat",
	//FCDB Players
	"razOk",
	"matusik",
	"Ao-",
	"Cludi",
	"vrs",
	//Nemiga Players
	"ROBO",
	"mds",
	"lollipop21k",
	"Jyo",
	"boX",
	//pro100 Players
	"Flarich",
	"AiyvaN",
	"YEKINDAR",
	"kenzor",
	"NickelBack",
	//eUnited Players
	"moose",
	"Cooper-",
	"MarKE",
	"food",
	"vanity",
	//Mythic Players
	"Polen",
	"fl0m",
	"anger",
	"hazed",
	"zNf",
	//Singularity Players
	"oSee",
	"floppy",
	"Hydrex",
	"ryann",
	"Shakezullah",
	//Rejected Players
	"vickt0r",
	"Tio",
	"rochet",
	"akz",
	"elemeNt",
	//DETONA Players
	"prt",
	"tiburci0",
	"v$m",
	"hardzao",
	"Tuurtle",
	//Infinity Players
	"cruzN",
	"malbsMd",
	"spamzzy",
	"points",
	"Daveys",
	//Isurus Players
	"1962",
	"Noktse",
	"Reversive",
	"meyern",
	"maxujas",
	//paiN Players
	"PKL",
	"land1n",
	"tatazin",
	"biguzera",
	"f4stzin",
	//Sharks Players
	"nak",
	"jnt",
	"leo_drunky",
	"exit",
	"RCF",
	//One Players
	"iDk",
	"Maluk3",
	"trk",
	"bit",
	"b4rtiN",
	//W7M Players
	"YJ",
	"raafa",
	"ryotzz",
	"pancc",
	"realziN",
	//Avant Players
	"soju_j",
	"RaZ",
	"badge",
	"eLUSIVE",
	"mizu",
	//Chiefs Players
	"tucks",
	"BL1TZ",
	"Texta",
	"ofnu",
	"zewsy",
	//LEISURE Players
	"rome",
	"neyzin",
	"get",
	"gimpen",
	"remixdb",
	//BDragons Players
	"deM0",
	"cqntrl",
	"dukka",
	"SpyDaemoN",
	"psy",
	//ORDER Players
	"emagine",
	"aliStair",
	"hatz",
	"INS",
	"Valiance",
	//Paradox Players
	"Chub",
	"Vexite",
	"Laes",
	"Noobster",
	"Kingfisher",
	//eXtatus Players
	"luko",
	"Blogg1s",
	"desty",
	"hones",
	"Pechyn",
	//SYF Players
	"ino",
	"cookie",
	"ekul",
	"bedonka",
	"urbz",
	//5Power Players
	"dobu",
	"kabal",
	"xiaosaGe",
	"shuadapai",
	"Viva",
	//EHOME Players
	"insane",
	"originalheart",
	"Marek",
	"SLOWLY",
	"lamplight",
	//ALPHA Red Players
	"MAIROLLS",
	"Olivia",
	"Kntz",
	"stk",
	"foxz",
	//dream[S]cape Players
	"Bobosaur",
	"splashske",
	"alecks",
	"Benkai",
	"d4v41",
	//Beyond Players
	"TOR",
	"bnwGiggs",
	"RoLEX",
	"veta",
	"JohnOlsen",
	//ETG Players
	"Amaterasu",
	"Psy",
	"Excali",
	"Dav",
	"DJOXiC",
	//FrostFire Players
	"aimaNNN",
	"Nutr1x",
	"acAp",
	"Subbey",
	"Avirity",
	//LucidDream Players
	"wannafly",
	"PTC",
	"cbbk",
	"Geniuss",
	"qqGod",
	//MiTH Players
	"CigaretteS",
	"JinNy",
	"viperdemon",
	"j9",
	"HSK",
	//NASR Players
	"breAker",
	"Nami",
	"kitkat",
	"havoK",
	"kAzoo",
	//PES Players
	"traNz",
	"soulm8",
	"Shooter",
	"PokemoN",
	"HARMZ",
	//Recca Players
	"roseau",
	"Eeyore",
	"Sys",
	"asteriskk",
	"kr0",
	//Brutals Players
	"V3nom",
	"RiX",
	"Juventa",
	"astaRR",
	"Fox",
	//iNvictus Players
	"ribbiZ",
	"Manan",
	"Pashasahil",
	"BinaryBUG",
	"blackhawk",
	//nxl Players
	"soifong",
	"RamCikiciew",
	"Qbo",
	"Vask0",
	"smoof",
	//APG Players
	"Kaspar0v",
	"SchizzY",
	"Backstabber",
	"FreakY",
	"zdrAg",
	//ATK Players
	"TenZ",
	"blackpoisoN",
	"JT",
	"Fadey",
	"Domsterr",
	//Energy Players
	"MisteM",
	"Dweezil",
	"SandpitTurtle",
	"adM",
	"bLazE",
	//Furious Players
	"laser",
	"iKrystal",
	"PREDI",
	"TISAN",
	"GATICA",
	//MongolZ Players
	"Machinegun",
	"neuz",
	"maaRaa",
	"temk4wow",
	"Annihilation",
	//BLUEJAYS Players
	"dEE",
	"sarenii",
	"Maden",
	"DiMKE",
	"HOLMES",
	//MK Players
	"spyleadeR",
	"nk4y",
	"niki1",
	"SAIKY",
	"Oxygen",
	//EXECUTIONERS Players
	"ZesBeeW",
	"FamouZ",
	"maestro",
	"Snyder",
	"bali",
	//Vexed Players
	"mezii",
	"Kray",
	"Adam9130",
	"L1NK",
	"frazehh",
	//GroundZero Players
	"BURNRUOk",
	"void",
	"zemp",
	"MoeycQ",
	"pan1K",
	//Aristocracy Players
	"mouz",
	"rallen",
	"TaZ",
	"MINISE",
	"dycha",
	//BTRO Players
	"fejtZ",
	"Drea3er",
	"Cate",
	"ImpressioN",
	"adrnkiNg",
	//Ancient Players
	"disco doplan",
	"draken",
	"freddieb",
	"RuStY",
	"grux",
	//Keyd Players
	"SHOOWTiME",
	"zqk",
	"shz",
	"dzt",
	"RMN",
	//GTZ Players
	"emp",
	"abr",
	"CarboN",
	"Kustom",
	"shellzy",
	//Flames Players
	"Basso",
	"farlig",
	"HooXi",
	"roeJ",
	"Console",
	//GameAgents Players
	"FliP1",
	"shadow",
	"pounh",
	"Butters",
	"jayzaR",
	//eu4ia Players
	"mik",
	"rai",
	"Ar4gorN",
	"drogo",
	"sh0wz",
	//Maple Players
	"NIFFY",
	"Leaf",
	"JUSTCAUSE",
	"Reality",
	"PPOverdose",
	//Fierce Players
	"Astroo",
	"ec1s",
	"frei",
	"stan1ey",
	"AlekS",
	//Trident Players
	"TEX",
	"zorboT",
	"Rackem",
	"jhd",
	"jtr"
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
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	HookEvent("round_start", OnRoundStart);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnMapStart()
{
	g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	g_iCoinOffset = FindSendPropInfo("CCSPlayerResource", "m_nActiveCoinRank");
	
	CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, Hook_OnThinkPost);
}

public void OnMapEnd()
{
	SDKUnhook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, Hook_OnThinkPost);
}

public void OnClientPostAdminCheck(int client)
{
	char botname[512];
	GetClientName(client, botname, sizeof(botname));
	
	for(int i = 0; i <= sizeof(g_BotName) - 1; i++)
	{
		if(StrEqual(botname, g_BotName[i]))
		{
			FakeClientCommand(client, "say !aimbot");
		}
	}
	
	Pro_Players(botname, client);
	
	g_iProfileRank[client] = GetRandomInt(1,40);
}

public void OnRoundStart(Handle event, char[] name, bool dbc)
{
	for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i))
        {
            if(g_hShouldAttackTimer[i] != INVALID_HANDLE)
			{
				KillTimer(g_hShouldAttackTimer[i]);
				g_hShouldAttackTimer[i] = INVALID_HANDLE;
			}
        }
    }
}

public void Hook_OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS+1);
	SetEntDataArray(iEnt, g_iCoinOffset, g_iCoin, MAXPLAYERS+1);
}

public Action CS_OnBuyCommand(int client, const char[] weapon)
{
	if(IsFakeClient(client))
	{
		int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		if(StrEqual(weapon,"m4a1"))
		{ 
			int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			
			if(GetRandomInt(1,3) == 1)
			{
				if (iWeapon != -1)
				{
					RemovePlayerItem(client, iWeapon);
				}
				
				m_iAccount -= 3100;
				GivePlayerItem(client, "weapon_m4a1_silencer");
				if ((m_iAccount > 16000) || (m_iAccount < 0))
					m_iAccount = 1500;
				SetClientMoney(client, m_iAccount);
				return Plugin_Handled; 
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
	else
	{
		return Plugin_Continue;
	}
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{  
    if (!IsFakeClient(client)) return Plugin_Continue;

    int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
    if (ActiveWeapon == -1)  return Plugin_Continue;

    int index = GetEntProp(ActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");  
    
    if (index == 43 || index == 44 || index == 45 || index == 46 || index == 48)
    {
        if (buttons & IN_ATTACK && g_bShouldAttack[client]) {
            // release attack
            buttons &= ~IN_ATTACK; 
            g_bShouldAttack[client] = false;
        }
        else {
            buttons |= IN_ATTACK; 

            if (g_hShouldAttackTimer[client] == null) {
                CreateTimer(2.0, Timer_ShouldAttack, GetClientSerial(client));
            }
        }

        return Plugin_Changed;
    } else if (g_hShouldAttackTimer[client] != null) {
        // kill timer since the client has switch weapon and it's pointless to continue
        KillTimer(g_hShouldAttackTimer[client]);
        g_hShouldAttackTimer[client] = null;
        return Plugin_Continue;
    }

    return Plugin_Continue;
}

public Action Timer_CheckPlayer(Handle Timer, any data)
{
	for (int i = 1; i <= GetMaxClients(); i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i))
		{
			int m_iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			
			
			if(GetRandomInt(1,10) == 1)
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			
			if(m_iAccount == 800)
			{
				FakeClientCommand(i, "buy vest");
			}
			else if(m_iAccount > 3000)
			{
				FakeClientCommand(i, "buy vesthelm");
				FakeClientCommand(i, "buy vest");
			}
		}
	}	
}  

public Action Timer_ShouldAttack(Handle timer, int serial) {
    int client = GetClientFromSerial(serial);

    // check if client is the same has the one before when the timer started
    if (client != 0) {
        // set variable so next frame knows that client need to release attack
        g_bShouldAttack[client] = true;
    }

    g_hShouldAttackTimer[client] = null;
    return Plugin_Handled;
}  

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	int rnd = GetRandomInt(1,15);
	
	switch(rnd)
	{
		case 1:
		{
			g_iCoin[client] = GetRandomInt(874,970);
		}
		case 2:
		{
			g_iCoin[client] = GetRandomInt(1001,1010);
		}
		case 3:
		{
			g_iCoin[client] = GetRandomInt(1013,1022);
		}
		case 4:
		{
			g_iCoin[client] = GetRandomInt(1024,1026);
		}
		case 5:
		{
			g_iCoin[client] = GetRandomInt(1028,1055);
		}
		case 6:
		{
			g_iCoin[client] = GetRandomInt(1316,1318);
		}
		case 7:
		{
			g_iCoin[client] = GetRandomInt(1327,1329);
		}
		case 8:
		{
			g_iCoin[client] = GetRandomInt(1331,1332);
		}
		case 9:
		{
			g_iCoin[client] = GetRandomInt(1336,1344);
		}
		case 10:
		{
			g_iCoin[client] = GetRandomInt(1357,1363);
		}
		case 11:
		{
			g_iCoin[client] = GetRandomInt(1367,1372);
		}
		case 12:
		{
			g_iCoin[client] = GetRandomInt(1376,1381);
		}
		case 13:
		{
			g_iCoin[client] = GetRandomInt(4353,4356);
		}
		case 14:
		{
			g_iCoin[client] = GetRandomInt(6001,6033);
		}
		case 15:
		{
			g_iCoin[client] = GetRandomInt(4555,4558);
		}
	}

	int team = GetClientTeam(client);
	
	if (!client) return;

	if(IsFakeClient(client))
    {
        CreateTimer(0.1, RFrame_CheckBuyZoneValue, GetClientSerial(client)); 
		
        if(GetRandomInt(1,10) == 1)
        {
            if(team == 3)
            {
                char usp[32];
                
                GetClientWeapon(client, usp, sizeof(usp));
                
                if(StrEqual(usp, "weapon_usp_silencer"))
                {
                    int uspslot = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
                    
                    if (uspslot != -1)
                    {
                        RemovePlayerItem(client, uspslot);
                    }
                    GivePlayerItem(client, "weapon_hkp2000");
                }
            }
        }
    }
}

public Action RFrame_CheckBuyZoneValue(Handle timer, int serial) 
{
	int client = GetClientFromSerial(serial);

	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
	int team = GetClientTeam(client);
	if (team < 2) return Plugin_Stop;

	int m_iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	
	bool m_bInBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
	
	if (!m_bInBuyZone) return Plugin_Stop;

	if((m_iAccount > 1500) && (m_iAccount < 3000))
	{
		int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
		
		if (iWeapon != -1)
		{
			RemovePlayerItem(client, iWeapon);
		}
		
		int rndpistol = GetRandomInt(1,3);
		
		switch(rndpistol)
		{
			case 1:
			{
				GivePlayerItem(client, "weapon_p250");
				SetClientMoney(client, m_iAccount - 300);
			}
			case 2:
			{
				if(team == 3)
				{
					int ctcz = GetRandomInt(1,2);
					
					switch(ctcz)
					{
						case 1:
						{
							GivePlayerItem(client, "weapon_fiveseven");
							SetClientMoney(client, m_iAccount - 500);
						}
						case 2:
						{
							GivePlayerItem(client, "weapon_cz75a");
							SetClientMoney(client, m_iAccount - 500);
						}
					}
				}
				else if(team == 2)
				{
					int tcz = GetRandomInt(1,2);
					
					switch(tcz)
					{
						case 1:
						{
							GivePlayerItem(client, "weapon_tec9");
							SetClientMoney(client, m_iAccount - 500);
						}
						case 2:
						{
							GivePlayerItem(client, "weapon_cz75a");
							SetClientMoney(client, m_iAccount - 500);
						}
					}
				}
			}
			case 3:
			{
				GivePlayerItem(client, "weapon_deagle");
				SetClientMoney(client, m_iAccount - 700);
			}
		}
	}
	else if(m_iAccount > 3000)
	{
		RemoveNades(client);

		if (team == 2) { 
            GivePlayerItem(client, g_sTRngGrenadesList[GetRandomInt(0, sizeof(g_sTRngGrenadesList) - 1)]); 
        }
		else { 
            GivePlayerItem(client, g_sCTRngGrenadesList[GetRandomInt(0, sizeof(g_sTRngGrenadesList) - 1)]); 
            SetEntProp(client, Prop_Send, "m_bHasDefuser", 1); 
        } 
		
	}
	return Plugin_Stop;
}

public void OnClientDisconnect(int client)
{
	if(client)
	{
		g_iCoin[client] = 0;
		g_iProfileRank[client] = 0;
	}
}

public void OnPluginEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsFakeClient(client))
		{
			OnClientDisconnect(client);
		}
	}
}

public void SetClientMoney(int client, int money)
{
	SetEntProp(client, Prop_Send, "m_iAccount", money);
	
	int moneyEntity = CreateEntityByName("game_money");
	
	DispatchKeyValue(moneyEntity, "Award Text", "");
	
	DispatchSpawn(moneyEntity);
	
	AcceptEntityInput(moneyEntity, "SetMoneyAmount 0");

	AcceptEntityInput(moneyEntity, "AddMoneyPlayer", client);
	
	AcceptEntityInput(moneyEntity, "Kill");
}

public void RemoveNades(int client)
{
    while(RemoveWeaponBySlot(client, 3)){}
    for(int i = 0; i < 6; i++)
        SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, g_iaGrenadeOffsets[i]);
}

public bool RemoveWeaponBySlot(int client, int iSlot)
{
    int iEntity = GetPlayerWeaponSlot(client, iSlot);
    if(IsValidEdict(iEntity)) {
        RemovePlayerItem(client, iEntity);
        AcceptEntityInput(iEntity, "Kill");
        return true;
    }
    return false;
} 

public void Pro_Players(char[] botname, int client)
{

	//MIBR Players
	if((StrEqual(botname, "coldzera")) || (StrEqual(botname, "FalleN")) || (StrEqual(botname, "fer")) || (StrEqual(botname, "TACO")) || (StrEqual(botname, "LUCAS1")))
	{
		CS_SetClientClanTag(client, "MIBR");
	}
	
	//FaZe Players
	if((StrEqual(botname, "olofmeister")) || (StrEqual(botname, "GuardiaN")) || (StrEqual(botname, "NiKo")) || (StrEqual(botname, "rain")) || (StrEqual(botname, "NEO")))
	{
		CS_SetClientClanTag(client, "FaZe");
	}
	
	//Astralis Players
	if((StrEqual(botname, "Xyp9x")) || (StrEqual(botname, "device")) || (StrEqual(botname, "gla1ve")) || (StrEqual(botname, "Magisk")) || (StrEqual(botname, "dupreeh")))
	{
		CS_SetClientClanTag(client, "Astralis");
	}
	
	//NiP Players
	if((StrEqual(botname, "GeT_RiGhT")) || (StrEqual(botname, "Plopski")) || (StrEqual(botname, "f0rest")) || (StrEqual(botname, "Lekr0")) || (StrEqual(botname, "REZ")))
	{
		CS_SetClientClanTag(client, "NiP");
	}
	
	//C9 Players
	if((StrEqual(botname, "autimatic")) || (StrEqual(botname, "mixwell")) || (StrEqual(botname, "daps")) || (StrEqual(botname, "koosta")) || (StrEqual(botname, "TenZ")))
	{
		CS_SetClientClanTag(client, "C9");
	}
	
	//G2 Players
	if((StrEqual(botname, "shox")) || (StrEqual(botname, "kennyS")) || (StrEqual(botname, "Lucky")) || (StrEqual(botname, "JaCkz")) || (StrEqual(botname, "AMANEK")))
	{
		CS_SetClientClanTag(client, "G2");
	}
	
	//fnatic Players
	if((StrEqual(botname, "twist")) || (StrEqual(botname, "JW")) || (StrEqual(botname, "KRiMZ")) || (StrEqual(botname, "Brollan")) || (StrEqual(botname, "Xizt")))
	{
		CS_SetClientClanTag(client, "fnatic");
	}
	
	//North Players
	if((StrEqual(botname, "JUGi")) || (StrEqual(botname, "Kjaerbye")) || (StrEqual(botname, "aizy")) || (StrEqual(botname, "valde")) || (StrEqual(botname, "gade")))
	{
		CS_SetClientClanTag(client, "North");
	}
	
	//mouz Players
	if((StrEqual(botname, "karrigan")) || (StrEqual(botname, "chrisJ")) || (StrEqual(botname, "woxic")) || (StrEqual(botname, "frozen")) || (StrEqual(botname, "ropz")))
	{
		CS_SetClientClanTag(client, "mouz");
	}
	
	//TYLOO Players
	if((StrEqual(botname, "Summer")) || (StrEqual(botname, "DANK1NG")) || (StrEqual(botname, "BnTneT")) || (StrEqual(botname, "somebody")) || (StrEqual(botname, "Attacker")))
	{
		CS_SetClientClanTag(client, "TYLOO");
	}
	
	//NRG Players
	if((StrEqual(botname, "stanislaw")) || (StrEqual(botname, "tarik")) || (StrEqual(botname, "Brehze")) || (StrEqual(botname, "nahtE")) || (StrEqual(botname, "CeRq")))
	{
		CS_SetClientClanTag(client, "NRG");
	}
	
	//RNG Players
	if((StrEqual(botname, "AZR")) || (StrEqual(botname, "jks")) || (StrEqual(botname, "jkaem")) || (StrEqual(botname, "Gratisfaction")) || (StrEqual(botname, "Liazz")))
	{
		CS_SetClientClanTag(client, "RNG");
	}
	
	//Na´Vi Players
	if((StrEqual(botname, "electronic")) || (StrEqual(botname, "s1mple")) || (StrEqual(botname, "flamie")) || (StrEqual(botname, "Boombl4")) || (StrEqual(botname, "Zeus")))
	{
		CS_SetClientClanTag(client, "Na´Vi");
	}
	
	//Liquid Players
	if((StrEqual(botname, "Stewie2K")) || (StrEqual(botname, "NAF")) || (StrEqual(botname, "nitr0")) || (StrEqual(botname, "ELiGE")) || (StrEqual(botname, "Twistzz")))
	{
		CS_SetClientClanTag(client, "Liquid");
	}
	
	//HR Players
	if((StrEqual(botname, "ANGE1")) || (StrEqual(botname, "oskar")) || (StrEqual(botname, "nukkye")) || (StrEqual(botname, "loWel")) || (StrEqual(botname, "ISSAA")))
	{
		CS_SetClientClanTag(client, "HR");
	}
	
	//AGO Players
	if((StrEqual(botname, "innocent")) || (StrEqual(botname, "STOMP")) || (StrEqual(botname, "reatz")) || (StrEqual(botname, "oskarish")) || (StrEqual(botname, "mono")))
	{
		CS_SetClientClanTag(client, "AGO");
	}
	
	//ENCE Players
	if((StrEqual(botname, "Aleksib")) || (StrEqual(botname, "Aerial")) || (StrEqual(botname, "allu")) || (StrEqual(botname, "sergej")) || (StrEqual(botname, "xseveN")))
	{
		CS_SetClientClanTag(client, "ENCE");
	}
	
	//Vitality Players
	if((StrEqual(botname, "NBK-")) || (StrEqual(botname, "ZywOo")) || (StrEqual(botname, "apEX")) || (StrEqual(botname, "RpK")) || (StrEqual(botname, "ALEX")))
	{
		CS_SetClientClanTag(client, "Vitality");
	}
	
	//BIG Players
	if((StrEqual(botname, "tiziaN")) || (StrEqual(botname, "denis")) || (StrEqual(botname, "XANTARES")) || (StrEqual(botname, "tabseN")) || (StrEqual(botname, "gob b")))
	{
		CS_SetClientClanTag(client, "BIG");
	}
	
	//AVANGAR Players
	if((StrEqual(botname, "buster")) || (StrEqual(botname, "Jame")) || (StrEqual(botname, "qikert")) || (StrEqual(botname, "AdreN")) || (StrEqual(botname, "SANJI")))
	{
		CS_SetClientClanTag(client, "AVANGAR");
	}
	
	//Windigo Players
	if((StrEqual(botname, "SHiPZ")) || (StrEqual(botname, "bubble")) || (StrEqual(botname, "v1c7oR")) || (StrEqual(botname, "blocker")) || (StrEqual(botname, "poizon")))
	{
		CS_SetClientClanTag(client, "Windigo");
	}
	
	//FURIA Players
	if((StrEqual(botname, "yuurih")) || (StrEqual(botname, "arT")) || (StrEqual(botname, "VINI")) || (StrEqual(botname, "kscerato")) || (StrEqual(botname, "ableJ")))
	{
		CS_SetClientClanTag(client, "FURIA");
	}
	
	//CR4ZY Players
	if((StrEqual(botname, "LETN1")) || (StrEqual(botname, "ottoNd")) || (StrEqual(botname, "huNter")) || (StrEqual(botname, "nexa")) || (StrEqual(botname, "EspiranTo")))
	{
		CS_SetClientClanTag(client, "CR4ZY");
	}
	
	//coL Players
	if((StrEqual(botname, "dephh")) || (StrEqual(botname, "ShahZaM")) || (StrEqual(botname, "oBo")) || (StrEqual(botname, "Rickeh")) || (StrEqual(botname, "SicK")))
	{
		CS_SetClientClanTag(client, "coL");
	}
	
	//ViCi Players
	if((StrEqual(botname, "zhokiNg")) || (StrEqual(botname, "kaze")) || (StrEqual(botname, "aumaN")) || (StrEqual(botname, "Freeman")) || (StrEqual(botname, "advent")))
	{
		CS_SetClientClanTag(client, "ViCi");
	}
	
	//forZe Players
	if((StrEqual(botname, "facecrack")) || (StrEqual(botname, "xsepower")) || (StrEqual(botname, "FL1T")) || (StrEqual(botname, "almazer")) || (StrEqual(botname, "Jerry")))
	{
		CS_SetClientClanTag(client, "forZe");
	}
	
	//Winstrike Players
	if((StrEqual(botname, "Edward")) || (StrEqual(botname, "Kvik")) || (StrEqual(botname, "n0rb3r7")) || (StrEqual(botname, "El1an")) || (StrEqual(botname, "bondik")))
	{
		CS_SetClientClanTag(client, "Winstrike");
	}
	
	//OpTic Players
	if((StrEqual(botname, "k0nfig")) || (StrEqual(botname, "MSL")) || (StrEqual(botname, "nikozan")) || (StrEqual(botname, "Snappi")) || (StrEqual(botname, "refrezh")))
	{
		CS_SetClientClanTag(client, "OpTic");
	}
	
	//Sprout Players
	if((StrEqual(botname, "k1to")) || (StrEqual(botname, "syrsoN")) || (StrEqual(botname, "Spiidi")) || (StrEqual(botname, "faveN")) || (StrEqual(botname, "mirbit")))
	{
		CS_SetClientClanTag(client, "Sprout");
	}
	
	//Heroic Players
	if((StrEqual(botname, "es3tag")) || (StrEqual(botname, "NaToSaphiX")) || (StrEqual(botname, "friberg")) || (StrEqual(botname, "blameF")) || (StrEqual(botname, "stavn")))
	{
		CS_SetClientClanTag(client, "Heroic");
	}
	
	//INTZ Players
	if((StrEqual(botname, "chelo")) || (StrEqual(botname, "kNgV-")) || (StrEqual(botname, "xand")) || (StrEqual(botname, "destinyy")) || (StrEqual(botname, "yeL")))
	{
		CS_SetClientClanTag(client, "INTZ");
	}
	
	//VP Players
	if((StrEqual(botname, "MICHU")) || (StrEqual(botname, "snatchie")) || (StrEqual(botname, "phr")) || (StrEqual(botname, "Snax")) || (StrEqual(botname, "Vegi")))
	{
		CS_SetClientClanTag(client, "VP");
	}
	
	//Apeks Players
	if((StrEqual(botname, "aNdz")) || (StrEqual(botname, "truth")) || (StrEqual(botname, "Grusarn")) || (StrEqual(botname, "akEz")) || (StrEqual(botname, "Polly")))
	{
		CS_SetClientClanTag(client, "Apeks");
	}
	
	//aTTaX Players
	if((StrEqual(botname, "stfN")) || (StrEqual(botname, "slaxz")) || (StrEqual(botname, "DuDe")) || (StrEqual(botname, "kressy")) || (StrEqual(botname, "mantuu")))
	{
		CS_SetClientClanTag(client, "aTTaX");
	}
	
	//Grayhound Players
	if((StrEqual(botname, "erkaSt")) || (StrEqual(botname, "sico")) || (StrEqual(botname, "dexter")) || (StrEqual(botname, "DickStacy")) || (StrEqual(botname, "malta")))
	{
		CS_SetClientClanTag(client, "Grayhound");
	}
	
	//LG Players
	if((StrEqual(botname, "NEKIZ")) || (StrEqual(botname, "HEN1")) || (StrEqual(botname, "steelega")) || (StrEqual(botname, "felps")) || (StrEqual(botname, "boltz")))
	{
		CS_SetClientClanTag(client, "LG");
	}
	
	//MVP.PK Players
	if((StrEqual(botname, "zeff")) || (StrEqual(botname, "xeta")) || (StrEqual(botname, "XigN")) || (StrEqual(botname, "Jinx")) || (StrEqual(botname, "stax")))
	{
		CS_SetClientClanTag(client, "MVP.PK");
	}
	
	//Envy Players
	if((StrEqual(botname, "Nifty")) || (StrEqual(botname, "Sonic")) || (StrEqual(botname, "s0m")) || (StrEqual(botname, "ANDROID")) || (StrEqual(botname, "FugLy")))
	{
		CS_SetClientClanTag(client, "Envy");
	}
	
	//Spirit Players
	if((StrEqual(botname, "COLDYY1")) || (StrEqual(botname, "iDISBALANCE")) || (StrEqual(botname, "somedieyoung")) || (StrEqual(botname, "chopper")) || (StrEqual(botname, "S0tF1k")))
	{
		CS_SetClientClanTag(client, "Spirit");
	}
	
	//Vega Players
	if((StrEqual(botname, "seized")) || (StrEqual(botname, "jR")) || (StrEqual(botname, "crush")) || (StrEqual(botname, "scoobyxie")) || (StrEqual(botname, "Dima")))
	{
		CS_SetClientClanTag(client, "Vega");
	}
	
	//Lazarus Players
	if((StrEqual(botname, "Zellsis")) || (StrEqual(botname, "swag")) || (StrEqual(botname, "yay")) || (StrEqual(botname, "Infinite")) || (StrEqual(botname, "Subroza")))
	{
		CS_SetClientClanTag(client, "Lazarus");
	}
	
	//CeX Players
	if((StrEqual(botname, "LiamjS")) || (StrEqual(botname, "resu")) || (StrEqual(botname, "Nukeddog")) || (StrEqual(botname, "JamesBT")) || (StrEqual(botname, "znx-")))
	{
		CS_SetClientClanTag(client, "CeX");
	}
	
	//LDLC Players
	if((StrEqual(botname, "rodeN")) || (StrEqual(botname, "Happy")) || (StrEqual(botname, "MAJ3R")) || (StrEqual(botname, "xms")) || (StrEqual(botname, "SIXER")))
	{
		CS_SetClientClanTag(client, "LDLC");
	}
	
	//Defusekids Players
	if((StrEqual(botname, "v1N")) || (StrEqual(botname, "G1DO")) || (StrEqual(botname, "FASHR")) || (StrEqual(botname, "Monu")) || (StrEqual(botname, "rilax")))
	{
		CS_SetClientClanTag(client, "Defusekids");
	}
	
	//Epsilon Players
	if((StrEqual(botname, "Surreal")) || (StrEqual(botname, "CRUC1AL")) || (StrEqual(botname, "DroW")) || (StrEqual(botname, "SPELLAN")) || (StrEqual(botname, "broky")))
	{
		CS_SetClientClanTag(client, "Epsilon");
	}
	
	//GamerLegion Players
	if((StrEqual(botname, "dennis")) || (StrEqual(botname, "nawwk")) || (StrEqual(botname, "ScreaM")) || (StrEqual(botname, "HS")) || (StrEqual(botname, "hampus")))
	{
		CS_SetClientClanTag(client, "GamerLegion");
	}
	
	//DIVIZON Players
	if((StrEqual(botname, "TR1P")) || (StrEqual(botname, "glaVed")) || (StrEqual(botname, "hyped")) || (StrEqual(botname, "n1kista")) || (StrEqual(botname, "MajoRR")))
	{
		CS_SetClientClanTag(client, "DIVIZON");
	}
	
	//EURONICS Players
	if((StrEqual(botname, "arno")) || (StrEqual(botname, "Krimbo")) || (StrEqual(botname, "PerX")) || (StrEqual(botname, "Seeeya")) || (StrEqual(botname, "boostey")))
	{
		CS_SetClientClanTag(client, "EURONICS");
	}
	
	//expert Players
	if((StrEqual(botname, "ScrunK")) || (StrEqual(botname, "Andyy")) || (StrEqual(botname, "chrissK")) || (StrEqual(botname, "JDC")) || (StrEqual(botname, "PREET")))
	{
		CS_SetClientClanTag(client, "expert");
	}
	
	//PANTHERS Players
	if((StrEqual(botname, "zonixx")) || (StrEqual(botname, "LyGHT")) || (StrEqual(botname, "ecfN")) || (StrEqual(botname, "pdy")) || (StrEqual(botname, "red")))
	{
		CS_SetClientClanTag(client, "PANTHERS");
	}
	
	//Planetkey Players
	if((StrEqual(botname, "xenn")) || (StrEqual(botname, "delkore")) || (StrEqual(botname, "neviZ")) || (StrEqual(botname, "s1n")) || (StrEqual(botname, "Krabbe")))
	{
		CS_SetClientClanTag(client, "Planetkey");
	}
	
	//PDucks Players
	if((StrEqual(botname, "Aika")) || (StrEqual(botname, "syncD")) || (StrEqual(botname, "BMLN")) || (StrEqual(botname, "HighKitty")) || (StrEqual(botname, "VENIQ")))
	{
		CS_SetClientClanTag(client, "PDucks");
	}
	
	//Chaos Players
	if((StrEqual(botname, "FREDDyFROG")) || (StrEqual(botname, "Relaxa")) || (StrEqual(botname, "PlesseN")) || (StrEqual(botname, "Bååten")) || (StrEqual(botname, "djL")))
	{
		CS_SetClientClanTag(client, "Chaos");
	}
	
	//HAVU Players
	if((StrEqual(botname, "ZOREE")) || (StrEqual(botname, "sLowi")) || (StrEqual(botname, "Twixie")) || (StrEqual(botname, "Hoody")) || (StrEqual(botname, "sAw")))
	{
		CS_SetClientClanTag(client, "HAVU");
	}
	
	//Lyngby Players
	if((StrEqual(botname, "birdfromsky")) || (StrEqual(botname, "Twinx")) || (StrEqual(botname, "Daffu")) || (StrEqual(botname, "zyp")) || (StrEqual(botname, "Cabbi")))
	{
		CS_SetClientClanTag(client, "Lyngby");
	}
	
	//NoChance Players
	if((StrEqual(botname, "Thomas")) || (StrEqual(botname, "Maikelele")) || (StrEqual(botname, "kRYSTAL")) || (StrEqual(botname, "zehN")) || (StrEqual(botname, "STYKO")))
	{
		CS_SetClientClanTag(client, "NoChance");
	}
	
	//Nordavind Players
	if((StrEqual(botname, "tenzki")) || (StrEqual(botname, "hallzerk")) || (StrEqual(botname, "RUBINO")) || (StrEqual(botname, "H4RR3")) || (StrEqual(botname, "cromen")))
	{
		CS_SetClientClanTag(client, "Nordavind");
	}
	
	//SJ Players
	if((StrEqual(botname, "arvid")) || (StrEqual(botname, "Jamppi")) || (StrEqual(botname, "SADDYX")) || (StrEqual(botname, "KHRN")) || (StrEqual(botname, "xartE")))
	{
		CS_SetClientClanTag(client, "SJ");
	}
	
	//SkitLite Players
	if((StrEqual(botname, "emilz")) || (StrEqual(botname, "Derkeps")) || (StrEqual(botname, "OSKU")) || (StrEqual(botname, "zks")) || (StrEqual(botname, "Vladimus")))
	{
		CS_SetClientClanTag(client, "SkitLite");
	}
	
	//Tricked Players
	if((StrEqual(botname, "b0RUP")) || (StrEqual(botname, "acoR")) || (StrEqual(botname, "HUNDEN")) || (StrEqual(botname, "Sjuush")) || (StrEqual(botname, "Lukki")))
	{
		CS_SetClientClanTag(client, "SkitLite");
	}
	
	//Baskonia Players
	if((StrEqual(botname, "tatin")) || (StrEqual(botname, "PabLo")) || (StrEqual(botname, "LittlesataN1")) || (StrEqual(botname, "dixon")) || (StrEqual(botname, "jJavi")))
	{
		CS_SetClientClanTag(client, "Baskonia");
	}
	
	//Dragons Players
	if((StrEqual(botname, "Enanoks")) || (StrEqual(botname, "Cr0n0s")) || (StrEqual(botname, "DonQ")) || (StrEqual(botname, "meisoN")) || (StrEqual(botname, "xikii")))
	{
		CS_SetClientClanTag(client, "Dragons");
	}
	
	//Giants Players
	if((StrEqual(botname, "romeM")) || (StrEqual(botname, "foxj")) || (StrEqual(botname, "KILLDREAM")) || (StrEqual(botname, "MUTiRiS")) || (StrEqual(botname, "ZELIN")))
	{
		CS_SetClientClanTag(client, "Giants");
	}
	
	//K1CK Players
	if((StrEqual(botname, "Cunha")) || (StrEqual(botname, "MISK")) || (StrEqual(botname, "plat")) || (StrEqual(botname, "psh")) || (StrEqual(botname, "fakes2")))
	{
		CS_SetClientClanTag(client, "K1CK");
	}
	
	//Lions Players
	if((StrEqual(botname, "TorPe")) || (StrEqual(botname, "dragunov")) || (StrEqual(botname, "NaOw")) || (StrEqual(botname, "HUMANZ")) || (StrEqual(botname, "oW")))
	{
		CS_SetClientClanTag(client, "Lions");
	}
	
	//Riders Players
	if((StrEqual(botname, "mopoz")) || (StrEqual(botname, "EasTor")) || (StrEqual(botname, "SOKER")) || (StrEqual(botname, "alëx")) || (StrEqual(botname, "DeathZz")))
	{
		CS_SetClientClanTag(client, "Riders");
	}
	
	//OFFSET Players
	if((StrEqual(botname, "zlynx")) || (StrEqual(botname, "obj")) || (StrEqual(botname, "JUST")) || (StrEqual(botname, "stadodo")) || (StrEqual(botname, "pr")))
	{
		CS_SetClientClanTag(client, "OFFSET");
	}
	
	//x6tence Players
	if((StrEqual(botname, "FlipiN")) || (StrEqual(botname, "JonY BoY")) || (StrEqual(botname, "TheClaran")) || (StrEqual(botname, "Meco")) || (StrEqual(botname, "Vares")))
	{
		CS_SetClientClanTag(client, "x6tence");
	}
	
	//eSuba Players
	if((StrEqual(botname, "HenkkyG")) || (StrEqual(botname, "CaNNiE")) || (StrEqual(botname, "SHOCK")) || (StrEqual(botname, "Fraged")) || (StrEqual(botname, "daxen")))
	{
		CS_SetClientClanTag(client, "eSuba");
	}
	
	//Nexus Players
	if((StrEqual(botname, "BTN")) || (StrEqual(botname, "XELLOW")) || (StrEqual(botname, "SEMINTE")) || (StrEqual(botname, "sXe")) || (StrEqual(botname, "COSMEEEN")))
	{
		CS_SetClientClanTag(client, "Nexus");
	}
	
	//PACT Players
	if((StrEqual(botname, "darko")) || (StrEqual(botname, "lunAtic")) || (StrEqual(botname, "morelz")) || (StrEqual(botname, "Sidney")) || (StrEqual(botname, "Sobol")))
	{
		CS_SetClientClanTag(client, "PACT");
	}
	
	//DreamEaters Players
	if((StrEqual(botname, "kinqie")) || (StrEqual(botname, "speed4k")) || (StrEqual(botname, "Krad")) || (StrEqual(botname, "Forester")) || (StrEqual(botname, "svyat")))
	{
		CS_SetClientClanTag(client, "DreamEaters");
	}
	
	//FCDB Players
	if((StrEqual(botname, "razOk")) || (StrEqual(botname, "matusik")) || (StrEqual(botname, "Ao-")) || (StrEqual(botname, "Cludi")) || (StrEqual(botname, "vrs")))
	{
		CS_SetClientClanTag(client, "FCDB");
	}
	
	//Nemiga Players
	if((StrEqual(botname, "ROBO")) || (StrEqual(botname, "mds")) || (StrEqual(botname, "lollipop21k")) || (StrEqual(botname, "Jyo")) || (StrEqual(botname, "boX")))
	{
		CS_SetClientClanTag(client, "Nemiga");
	}
	
	//pro100 Players
	if((StrEqual(botname, "Flarich")) || (StrEqual(botname, "AiyvaN")) || (StrEqual(botname, "YEKINDAR")) || (StrEqual(botname, "kenzor")) || (StrEqual(botname, "NickelBack")))
	{
		CS_SetClientClanTag(client, "pro100");
	}
	
	//eUnited Players
	if((StrEqual(botname, "moose")) || (StrEqual(botname, "Cooper-")) || (StrEqual(botname, "MarKE")) || (StrEqual(botname, "food")) || (StrEqual(botname, "vanity")))
	{
		CS_SetClientClanTag(client, "eUnited");
	}
	
	//Mythic Players
	if((StrEqual(botname, "Polen")) || (StrEqual(botname, "fl0m")) || (StrEqual(botname, "anger")) || (StrEqual(botname, "hazed")) || (StrEqual(botname, "zNf")))
	{
		CS_SetClientClanTag(client, "Mythic");
	}
	
	//Singularity Players
	if((StrEqual(botname, "oSee")) || (StrEqual(botname, "floppy")) || (StrEqual(botname, "Hydrex")) || (StrEqual(botname, "ryann")) || (StrEqual(botname, "Shakezullah")))
	{
		CS_SetClientClanTag(client, "Singularity");
	}
	
	//Rejected Players
	if((StrEqual(botname, "vickt0r")) || (StrEqual(botname, "Tio")) || (StrEqual(botname, "rochet")) || (StrEqual(botname, "akz")) || (StrEqual(botname, "elemeNt")))
	{
		CS_SetClientClanTag(client, "Rejected");
	}
	
	//DETONA Players
	if((StrEqual(botname, "prt")) || (StrEqual(botname, "tiburci0")) || (StrEqual(botname, "v$m")) || (StrEqual(botname, "hardzao")) || (StrEqual(botname, "Tuurtle")))
	{
		CS_SetClientClanTag(client, "DETONA");
	}
	
	//Infinity Players
	if((StrEqual(botname, "cruzN")) || (StrEqual(botname, "malbsMd")) || (StrEqual(botname, "spamzzy")) || (StrEqual(botname, "points")) || (StrEqual(botname, "Daveys")))
	{
		CS_SetClientClanTag(client, "Infinity");
	}
	
	//Isurus Players
	if((StrEqual(botname, "1962")) || (StrEqual(botname, "Noktse")) || (StrEqual(botname, "Reversive")) || (StrEqual(botname, "meyern")) || (StrEqual(botname, "maxujas")))
	{
		CS_SetClientClanTag(client, "Isurus");
	}
	
	//paiN Players
	if((StrEqual(botname, "PKL")) || (StrEqual(botname, "land1n")) || (StrEqual(botname, "tatazin")) || (StrEqual(botname, "biguzera")) || (StrEqual(botname, "f4stzin")))
	{
		CS_SetClientClanTag(client, "paiN");
	}
	
	//Sharks Players
	if((StrEqual(botname, "nak")) || (StrEqual(botname, "jnt")) || (StrEqual(botname, "leo_drunky")) || (StrEqual(botname, "exit")) || (StrEqual(botname, "RCF")))
	{
		CS_SetClientClanTag(client, "Sharks");
	}
	
	//One Players
	if((StrEqual(botname, "iDk")) || (StrEqual(botname, "Maluk3")) || (StrEqual(botname, "trk")) || (StrEqual(botname, "bit")) || (StrEqual(botname, "b4rtiN")))
	{
		CS_SetClientClanTag(client, "One");
	}
	
	//W7M Players
	if((StrEqual(botname, "YJ")) || (StrEqual(botname, "raafa")) || (StrEqual(botname, "ryotzz")) || (StrEqual(botname, "pancc")) || (StrEqual(botname, "realziN")))
	{
		CS_SetClientClanTag(client, "W7M");
	}
	
	//Avant Players
	if((StrEqual(botname, "soju_j")) || (StrEqual(botname, "RaZ")) || (StrEqual(botname, "badge")) || (StrEqual(botname, "eLUSIVE")) || (StrEqual(botname, "mizu")))
	{
		CS_SetClientClanTag(client, "Avant");
	}
	
	//Chiefs Players
	if((StrEqual(botname, "tucks")) || (StrEqual(botname, "BL1TZ")) || (StrEqual(botname, "Texta")) || (StrEqual(botname, "ofnu")) || (StrEqual(botname, "zewsy")))
	{
		CS_SetClientClanTag(client, "Chiefs");
	}
	
	//LEISURE Players
	if((StrEqual(botname, "rome")) || (StrEqual(botname, "remixdb")) || (StrEqual(botname, "neyzin")) || (StrEqual(botname, "get")) || (StrEqual(botname, "gimpen")))
	{
		CS_SetClientClanTag(client, "LEISURE");
	}
	
	//BDragons Players
	if((StrEqual(botname, "deM0")) || (StrEqual(botname, "cqntrl")) || (StrEqual(botname, "dukka")) || (StrEqual(botname, "SpyDaemoN")) || (StrEqual(botname, "psy")))
	{
		CS_SetClientClanTag(client, "BDragons");
	}
	
	//ORDER Players
	if((StrEqual(botname, "emagine")) || (StrEqual(botname, "aliStair")) || (StrEqual(botname, "hatz")) || (StrEqual(botname, "INS")) || (StrEqual(botname, "Valiance")))
	{
		CS_SetClientClanTag(client, "ORDER");
	}
	
	//Paradox Players
	if((StrEqual(botname, "Chub")) || (StrEqual(botname, "Vexite")) || (StrEqual(botname, "Laes")) || (StrEqual(botname, "Noobster")) || (StrEqual(botname, "Kingfisher")))
	{
		CS_SetClientClanTag(client, "Paradox");
	}
	
	//eXtatus Players
	if((StrEqual(botname, "luko")) || (StrEqual(botname, "Blogg1s")) || (StrEqual(botname, "desty")) || (StrEqual(botname, "hones")) || (StrEqual(botname, "Pechyn")))
	{
		CS_SetClientClanTag(client, "eXtatus");
	}
	
	//SYF Players
	if((StrEqual(botname, "ino")) || (StrEqual(botname, "cookie")) || (StrEqual(botname, "ekul")) || (StrEqual(botname, "bedonka")) || (StrEqual(botname, "urbz")))
	{
		CS_SetClientClanTag(client, "SYF");
	}
	
	//5Power Players
	if((StrEqual(botname, "bottle")) || (StrEqual(botname, "Savage")) || (StrEqual(botname, "xiaosaGe")) || (StrEqual(botname, "shuadapai")) || (StrEqual(botname, "Viva")))
	{
		CS_SetClientClanTag(client, "5Power");
	}
	
	//EHOME Players
	if((StrEqual(botname, "insane")) || (StrEqual(botname, "originalheart")) || (StrEqual(botname, "Marek")) || (StrEqual(botname, "SLOWLY")) || (StrEqual(botname, "lamplight")))
	{
		CS_SetClientClanTag(client, "EHOME");
	}
	
	//ALPHA Red Players
	if((StrEqual(botname, "MAIROLLS")) || (StrEqual(botname, "Olivia")) || (StrEqual(botname, "Kntz")) || (StrEqual(botname, "stk")) || (StrEqual(botname, "foxz")))
	{
		CS_SetClientClanTag(client, "ALPHA Red");
	}
	
	//dream[S]cape Players
	if((StrEqual(botname, "Bobosaur")) || (StrEqual(botname, "splashske")) || (StrEqual(botname, "alecks")) || (StrEqual(botname, "Benkai")) || (StrEqual(botname, "d4v41")))
	{
		CS_SetClientClanTag(client, "dream[S]cape");
	}
	
	//Beyond Players
	if((StrEqual(botname, "TOR")) || (StrEqual(botname, "bnwGiggs")) || (StrEqual(botname, "RoLEX")) || (StrEqual(botname, "veta")) || (StrEqual(botname, "JohnOlsen")))
	{
		CS_SetClientClanTag(client, "Beyond");
	}
	
	//ETG Players
	if((StrEqual(botname, "Amaterasu")) || (StrEqual(botname, "Psy")) || (StrEqual(botname, "Excali")) || (StrEqual(botname, "Dav")) || (StrEqual(botname, "DJOXiC")))
	{
		CS_SetClientClanTag(client, "ETG");
	}
	
	//FrostFire Players
	if((StrEqual(botname, "aimaNNN")) || (StrEqual(botname, "Nutr1x")) || (StrEqual(botname, "acAp")) || (StrEqual(botname, "Subbey")) || (StrEqual(botname, "Avirity")))
	{
		CS_SetClientClanTag(client, "FrostFire");
	}
	
	//LucidDream Players
	if((StrEqual(botname, "wannafly")) || (StrEqual(botname, "PTC")) || (StrEqual(botname, "cbbk")) || (StrEqual(botname, "Geniuss")) || (StrEqual(botname, "qqGod")))
	{
		CS_SetClientClanTag(client, "LucidDream");
	}
	
	//MiTH Players
	if((StrEqual(botname, "CigaretteS")) || (StrEqual(botname, "JinNy")) || (StrEqual(botname, "viperdemon")) || (StrEqual(botname, "j9")) || (StrEqual(botname, "HSK")))
	{
		CS_SetClientClanTag(client, "MiTH");
	}
	
	//NASR Players
	if((StrEqual(botname, "breAker")) || (StrEqual(botname, "Nami")) || (StrEqual(botname, "kitkat")) || (StrEqual(botname, "havoK")) || (StrEqual(botname, "kAzoo")))
	{
		CS_SetClientClanTag(client, "NASR");
	}
	
	//PES Players
	if((StrEqual(botname, "traNz")) || (StrEqual(botname, "soulm8")) || (StrEqual(botname, "Shooter")) || (StrEqual(botname, "PokemoN")) || (StrEqual(botname, "HARMZ")))
	{
		CS_SetClientClanTag(client, "PES");
	}
	
	//Recca Players
	if((StrEqual(botname, "roseau")) || (StrEqual(botname, "Eeyore")) || (StrEqual(botname, "Sys")) || (StrEqual(botname, "asteriskk")) || (StrEqual(botname, "kr0")))
	{
		CS_SetClientClanTag(client, "Recca");
	}
	
	//Brutals Players
	if((StrEqual(botname, "V3nom")) || (StrEqual(botname, "RiX")) || (StrEqual(botname, "Juventa")) || (StrEqual(botname, "astaRR")) || (StrEqual(botname, "Fox")))
	{
		CS_SetClientClanTag(client, "Brutals");
	}
	
	//iNvictus Players
	if((StrEqual(botname, "ribbiZ")) || (StrEqual(botname, "Manan")) || (StrEqual(botname, "Pashasahil")) || (StrEqual(botname, "BinaryBUG")) || (StrEqual(botname, "blackhawk")))
	{
		CS_SetClientClanTag(client, "iNvictus");
	}
	
	//nxl Players
	if((StrEqual(botname, "soifong")) || (StrEqual(botname, "RamCikiciew")) || (StrEqual(botname, "Qbo")) || (StrEqual(botname, "Vask0")) || (StrEqual(botname, "smoof")))
	{
		CS_SetClientClanTag(client, "nxl");
	}
	
	//APG Players
	if((StrEqual(botname, "Kaspar0v")) || (StrEqual(botname, "SchizzY")) || (StrEqual(botname, "Backstabber")) || (StrEqual(botname, "FreakY")) || (StrEqual(botname, "zdrAg")))
	{
		CS_SetClientClanTag(client, "APG");
	}
	
	//ATK Players
	if((StrEqual(botname, "TenZ")) || (StrEqual(botname, "blackpoisoN")) || (StrEqual(botname, "JT")) || (StrEqual(botname, "Fadey")) || (StrEqual(botname, "Domsterr")))
	{
		CS_SetClientClanTag(client, "ATK");
	}
	
	//Energy Players
	if((StrEqual(botname, "MisteM")) || (StrEqual(botname, "Dweezil")) || (StrEqual(botname, "SandpitTurtle")) || (StrEqual(botname, "adM")) || (StrEqual(botname, "bLazE")))
	{
		CS_SetClientClanTag(client, "Energy");
	}
	
	//MongolZ Players
	if((StrEqual(botname, "Machinegun")) || (StrEqual(botname, "neuz")) || (StrEqual(botname, "maaRaa")) || (StrEqual(botname, "temk4wow")) || (StrEqual(botname, "Annihilation")))
	{
		CS_SetClientClanTag(client, "MongolZ");
	}
	
	//BLUEJAYS Players
	if((StrEqual(botname, "dEE")) || (StrEqual(botname, "sarenii")) || (StrEqual(botname, "Maden")) || (StrEqual(botname, "DiMKE")) || (StrEqual(botname, "HOLMES")))
	{
		CS_SetClientClanTag(client, "BLUEJAYS");
	}
	
	//MK Players
	if((StrEqual(botname, "spyleadeR")) || (StrEqual(botname, "nk4y")) || (StrEqual(botname, "niki1")) || (StrEqual(botname, "SAIKY")) || (StrEqual(botname, "Oxygen")))
	{
		CS_SetClientClanTag(client, "MK");
	}
	
	//EXECUTIONERS Players
	if((StrEqual(botname, "ZesBeeW")) || (StrEqual(botname, "FamouZ")) || (StrEqual(botname, "maestro")) || (StrEqual(botname, "Snyder")) || (StrEqual(botname, "bali")))
	{
		CS_SetClientClanTag(client, "EXECUTIONERS");
	}
	
	//Vexed Players
	if((StrEqual(botname, "mezii")) || (StrEqual(botname, "Kray")) || (StrEqual(botname, "Adam9130")) || (StrEqual(botname, "L1NK")) || (StrEqual(botname, "frazehh")))
	{
		CS_SetClientClanTag(client, "Vexed");
	}
	
	//GroundZero Players
	if((StrEqual(botname, "BURNRUOk")) || (StrEqual(botname, "void")) || (StrEqual(botname, "zemp")) || (StrEqual(botname, "MoeycQ")) || (StrEqual(botname, "pan1K")))
	{
		CS_SetClientClanTag(client, "GroundZero");
	}
	
	//Aristocracy Players
	if((StrEqual(botname, "mouz")) || (StrEqual(botname, "rallen")) || (StrEqual(botname, "TaZ")) || (StrEqual(botname, "MINISE")) || (StrEqual(botname, "dycha")))
	{
		CS_SetClientClanTag(client, "Aristocracy");
	}
	
	//BTRO Players
	if((StrEqual(botname, "fejtZ")) || (StrEqual(botname, "Drea3er")) || (StrEqual(botname, "Cate")) || (StrEqual(botname, "ImpressioN")) || (StrEqual(botname, "adrnkiNg")))
	{
		CS_SetClientClanTag(client, "BTRO");
	}
	
	//Ancient Players
	if((StrEqual(botname, "disco doplan")) || (StrEqual(botname, "draken")) || (StrEqual(botname, "freddieb")) || (StrEqual(botname, "RuStY")) || (StrEqual(botname, "grux")))
	{
		CS_SetClientClanTag(client, "Ancient");
	}
	
	//Keyd Players
	if((StrEqual(botname, "SHOOWTiME")) || (StrEqual(botname, "zqk")) || (StrEqual(botname, "shz")) || (StrEqual(botname, "dzt")) || (StrEqual(botname, "RMN")))
	{
		CS_SetClientClanTag(client, "Keyd");
	}
	
	//Furious Players
	if((StrEqual(botname, "laser")) || (StrEqual(botname, "iKrystal")) || (StrEqual(botname, "PREDI")) || (StrEqual(botname, "TISAN")) || (StrEqual(botname, "GATICA")))
	{
		CS_SetClientClanTag(client, "Furious");
	}
	
	//GTZ Players
	if((StrEqual(botname, "emp")) || (StrEqual(botname, "abr")) || (StrEqual(botname, "CarboN")) || (StrEqual(botname, "Kustom")) || (StrEqual(botname, "shellzy")))
	{
		CS_SetClientClanTag(client, "GTZ");
	}
	
	//Flames Players
	if((StrEqual(botname, "Basso")) || (StrEqual(botname, "farlig")) || (StrEqual(botname, "HooXi")) || (StrEqual(botname, "roeJ")) || (StrEqual(botname, "Console")))
	{
		CS_SetClientClanTag(client, "Flames");
	}
	
	//GameAgents Players
	if((StrEqual(botname, "FliP1")) || (StrEqual(botname, "shadow")) || (StrEqual(botname, "pounh")) || (StrEqual(botname, "Butters")) || (StrEqual(botname, "jayzaR")))
	{
		CS_SetClientClanTag(client, "GameAgents");
	}
	
	//eu4ia Players
	if((StrEqual(botname, "mik")) || (StrEqual(botname, "rai")) || (StrEqual(botname, "Ar4gorN")) || (StrEqual(botname, "drogo")) || (StrEqual(botname, "sh0wz")))
	{
		CS_SetClientClanTag(client, "eu4ia");
	}
	
	//Maple Players
	if((StrEqual(botname, "NIFFY")) || (StrEqual(botname, "Leaf")) || (StrEqual(botname, "JUSTCAUSE")) || (StrEqual(botname, "Reality")) || (StrEqual(botname, "PPOverdose")))
	{
		CS_SetClientClanTag(client, "Maple");
	}
	
	//Fierce Players
	if((StrEqual(botname, "Astroo")) || (StrEqual(botname, "ec1s")) || (StrEqual(botname, "frei")) || (StrEqual(botname, "stan1ey")) || (StrEqual(botname, "AlekS")))
	{
		CS_SetClientClanTag(client, "Fierce");
	}
	
	//Trident Players
	if((StrEqual(botname, "TEX")) || (StrEqual(botname, "zorboT")) || (StrEqual(botname, "Rackem")) || (StrEqual(botname, "jhd")) || (StrEqual(botname, "jtr")))
	{
		CS_SetClientClanTag(client, "Trident");
	}
}