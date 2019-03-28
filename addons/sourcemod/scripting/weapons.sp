/*  CS:GO Weapons&Knives SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <PTaH>

#pragma semicolon 1
#pragma newdecls required

#include "weapons/globals.sp"
#include "weapons/forwards.sp"
#include "weapons/hooks.sp"
#include "weapons/helpers.sp"
#include "weapons/database.sp"
#include "weapons/config.sp"
#include "weapons/menus.sp"

public Plugin myinfo = 
{
	name = "Weapons & Knives",
	author = "kgns | oyunhost.net",
	description = "All in one custom weapon management",
	version = "1.3.2",
	url = "https://www.oyunhost.net"
};

public void OnPluginStart()
{
	LoadTranslations("weapons.phrases");
	
	g_Cvar_DBConnection 			= CreateConVar("sm_weapons_db_connection", 			"storage-local", 	"Database connection name in databases.cfg to use");
	g_Cvar_TablePrefix 				= CreateConVar("sm_weapons_table_prefix", 			"", 				"Prefix for database table (example: 'xyz_')");
	g_Cvar_ChatPrefix 				= CreateConVar("sm_weapons_chat_prefix", 			"[oyunhost.net]", 	"Prefix for chat messages");
	g_Cvar_KnifeStatTrakMode 		= CreateConVar("sm_weapons_knife_stattrak_mode", 	"0", 				"0: All knives show the same StatTrak counter (total knife kills) 1: Each type of knife shows its own separate StatTrak counter");
	g_Cvar_EnableFloat 				= CreateConVar("sm_weapons_enable_float", 			"1", 				"Enable/Disable weapon float options");
	g_Cvar_EnableNameTag 			= CreateConVar("sm_weapons_enable_nametag", 		"1", 				"Enable/Disable name tag options");
	g_Cvar_EnableStatTrak 			= CreateConVar("sm_weapons_enable_stattrak", 		"1", 				"Enable/Disable StatTrak options");
	g_Cvar_FloatIncrementSize 		= CreateConVar("sm_weapons_float_increment_size", 	"0.05", 			"Increase/Decrease by value for weapon float");
	g_Cvar_EnableWeaponOverwrite 	= CreateConVar("sm_weapons_enable_overwrite", 		"1", 				"Enable/Disable players overwriting other players' weapons (picked up from the ground) by using !ws command");
	g_Cvar_GracePeriod 				= CreateConVar("sm_weapons_grace_period", 			"0", 				"Grace period in terms of seconds counted after round start for allowing the use of !ws command. 0 means no restrictions");
	g_Cvar_InactiveDays 			= CreateConVar("sm_weapons_inactive_days", 			"30", 				"Number of days before a player (SteamID) is marked as inactive and his data is deleted. (0 or any negative value to disable deleting)");
	
	AutoExecConfig(true, "weapons");
	
	RegConsoleCmd("buyammo1", CommandWeaponSkins);
	RegConsoleCmd("sm_ws", CommandWeaponSkins);
	RegConsoleCmd("buyammo2", CommandKnife);
	RegConsoleCmd("sm_knife", CommandKnife);
	RegConsoleCmd("sm_nametag", CommandNameTag);
	RegConsoleCmd("sm_wslang", CommandWSLang);
	
	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItem, Hook, GiveNamedItem);
	
	ConVar g_cvGameType = FindConVar("game_type");
	ConVar g_cvGameMode = FindConVar("game_mode");
	
	if(g_cvGameType != null && g_cvGameMode != null && g_cvGameType.IntValue == 1 && g_cvGameMode.IntValue == 2)
	{
		PTaH(PTaH_WeaponCanUse, Hook, WeaponCanUse);
	}
	
	AddCommandListener(ChatListener, "say");
	AddCommandListener(ChatListener, "say2");
	AddCommandListener(ChatListener, "say_team");
}

public Action CommandWeaponSkins(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateMainMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandKnife(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateKnifeMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandWSLang(int client, int args)
{
	if (IsValidClient(client))
	{
		int menuTime;
		if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
		{
			CreateLanguageMenu(client).Display(client, menuTime);
		}
		else
		{
			PrintToChat(client, " %s \x02%t", g_ChatPrefix, "GracePeriod", g_iGracePeriod);
		}
	}
	return Plugin_Handled;
}

public Action CommandNameTag(int client, int args)
{
	if(!g_bEnableNameTag)
	{
		ReplyToCommand(client, " %s \x02%T", g_ChatPrefix, "NameTagDisabled", client);
		return Plugin_Handled;
	}
	ReplyToCommand(client, " %s \x04%T", g_ChatPrefix, "NameTagNew", client);
	return Plugin_Handled;
}

void SetWeaponProps(int client, int entity)
{
	int index = GetWeaponIndex(entity);
	if (index > -1 && g_iSkins[client][index] != 0)
	{
		static int IDHigh = 16384;
		SetEntProp(entity, Prop_Send, "m_iItemIDLow", -1);
		SetEntProp(entity, Prop_Send, "m_iItemIDHigh", IDHigh++);
		SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", g_iSkins[client][index] == -1 ? GetRandomSkin(client, index) : g_iSkins[client][index]);
		SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", !g_bEnableFloat || g_fFloatValue[client][index] == 0.0 ? 0.000001 : g_fFloatValue[client][index] == 1.0 ? 0.999999 : g_fFloatValue[client][index]);
		SetEntProp(entity, Prop_Send, "m_nFallbackSeed", GetRandomInt(0, 8192));
		if(!IsKnife(entity))
		{
			if(g_bEnableStatTrak)
			{
				SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", g_iStatTrak[client][index] == 1 ? g_iStatTrakCount[client][index] : -1);
				SetEntProp(entity, Prop_Send, "m_iEntityQuality", g_iStatTrak[client][index] == 1 ? 9 : 0);
			}
		}
		else
		{
			if(g_bEnableStatTrak)
			{
				SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", g_iStatTrak[client][index] == 0 ? -1 : g_iKnifeStatTrakMode == 0 ? GetTotalKnifeStatTrakCount(client) : g_iStatTrakCount[client][index]);
			}
			SetEntProp(entity, Prop_Send, "m_iEntityQuality", 3);
		}
		if (g_bEnableNameTag && strlen(g_NameTag[client][index]) > 0)
		{
			SetEntDataString(entity, FindSendPropInfo("CBaseAttributableItem", "m_szCustomName"), g_NameTag[client][index], 128);
		}
		if(IsFakeClient(client))
		{
			SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
			switch(GetEntProp(entity, Prop_Send, "m_nFallbackPaintKit"))
			{
				case 562, 561, 560, 559, 558, 806, 696, 694, 693, 665, 610, 521, 462:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.65));
				}
				case 572, 571, 570, 569, 568, 413, 418, 419, 420, 421, 416, 415, 417, 618, 619, 617, 409, 38, 856, 855, 854, 853, 852, 453, 445, 213, 210, 197, 196, 71, 67, 61, 51, 48, 37, 36, 34, 33, 32, 28:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.08));
				}
				case 577, 576, 575, 574, 573, 808, 644:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.85));
				}
				case 582, 581, 580:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.48));
				}
				case 579, 578, 410, 411, 858, 857, 817, 807, 803, 802, 718, 710, 685, 664, 662, 654, 650, 645, 641, 626, 624, 622, 616, 599, 590, 549, 547, 542, 786, 785, 784, 783, 782, 781, 780, 779, 778, 777, 776, 775, 534, 518, 499, 498, 482, 452, 451, 450, 423, 407, 406, 405, 402, 399, 393, 360, 355, 354, 349, 345, 337, 313, 312, 311, 310, 306, 305, 280, 263, 257, 238, 237, 228, 224, 223:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.50));
				}
				case 98, 12, 40, 143, 5, 77, 72, 175, 735, 755, 753, 621, 620, 333, 332, 322, 297, 277:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.80));
				}
				case 414, 552:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.40, 1.00));
				}
				case 59:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.01, 0.26));
				}
				case 851, 813, 584, 793, 536, 523, 522, 438, 369, 362, 358, 339, 309, 295, 291, 269, 260, 256, 252, 249, 248, 246, 227, 225, 218:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.40));
				}
				case 850, 483:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.14, 0.65));
				}
				case 849, 842, 836, 809, 804, 642, 636, 627, 557, 470, 469, 468, 400, 394, 388:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.75));
				}
				case 848, 837, 723, 721, 715, 712, 706, 687, 681, 678, 672, 653, 649, 646, 638, 632, 628, 585, 789, 488, 460, 435, 374, 372, 353, 344, 336, 315, 275, 270, 266:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.70));
				}
				case 847, 551, 288:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 1.00));
				}
				case 845, 655:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 1.00));
				}
				case 844, 839, 810, 720, 719, 707, 704, 699, 692, 667, 663, 611, 601, 600, 587, 799, 797, 529, 512, 507, 502, 495, 479, 467, 466, 465, 464, 457, 456, 454, 426, 401, 384, 378, 273:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.80));
				}
				case 843:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.25, 0.80));
				}
				case 841, 814, 812, 695, 501, 494, 493, 379, 376, 302, 301:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.90));
				}
				case 835, 708, 702, 698, 688, 661, 656, 647, 640, 637, 444, 442, 434, 375:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.55));
				}
				case 816:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.14, 1.00));
				}
				case 815:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.80));
				}
				case 805, 686, 682, 679, 659, 658, 598, 593, 550, 796, 795, 794, 537, 492, 477, 471, 459, 458, 404, 389, 371, 370, 338, 308, 250, 244, 243, 242, 241, 240, 236, 235:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.60));
				}
				case 801, 380:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.70));
				}
				case 703, 359:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.92));
				}
				case 691, 533, 503:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.64));
				}
				case 690, 591:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.63));
				}
				case 800, 443, 335:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.35));
				}
				case 689:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.72));
				}
				case 683:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.03, 0.70));
				}
				case 670:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.51));
				}
				case 666, 648, 639, 633, 630, 606, 597, 544, 535, 433, 424, 307, 285, 234:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.45));
				}
				case 657:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.86));
				}
				case 651, 545, 480, 182:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.52));
				}
				case 643, 348:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.56));
				}
				case 634, 448, 356, 351, 298, 294, 286, 265, 262, 219, 217, 215, 184, 181, 3:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.30));
				}
				case 608, 509:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.44));
				}
				case 603:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 1.00));
				}
				case 592:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.80));
				}
				case 586:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.54));
				}
				case 583:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.66));
				}
				case 556:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.77));
				}
				case 555, 319:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.43));
				}
				case 553:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.81));
				}
				case 548:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.99));
				}
				case 752, 387, 382, 221:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.25));
				}
				case 790, 788, 373:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.83));
				}
				case 530:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.61));
				}
				case 527, 180:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.76));
				}
				case 515, 437, 299, 274, 272, 271, 268, 231, 230, 220:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.20));
				}
				case 511:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.14, 0.85));
				}
				case 506:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.67));
				}
				case 500:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.62));
				}
				case 490:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.87));
				}
				case 489, 425, 386:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.46));
				}
				case 481:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.32));
				}
				case 449:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.33));
				}
				case 441:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.39));
				}
				case 440, 326, 325:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.10));
				}
				case 436:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.25, 0.35));
				}
				case 432, 395:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.20));
				}
				case 428:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.85));
				}
				case 427:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.90));
				}
				case 398:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.35, 0.80));
				}
				case 396:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.47));
				}
				case 392:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.35));
				}
				case 385:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.49));
				}
				case 383:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.68));
				}
				case 381:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.25));
				}
				case 366, 365, 276:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.58));
				}
				case 330, 329, 327, 191:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.22));
				}
				case 328:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.01, 0.70));
				}
				case 320, 293, 251:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.08, 0.50));
				}
				case 314:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.03, 0.50));
				}
				case 304:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.15, 0.80));
				}
				case 296, 162:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.18));
				}
				case 290:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.38));
				}
				case 289, 282:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.70));
				}
				case 287, 264:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.60));
				}
				case 283:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.08, 0.75));
				}
				case 281:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.75));
				}
				case 279, 255:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.18, 1.00));
				}
				case 278:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.06, 0.58));
				}
				case 267:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.45));
				}
				case 261:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.05, 0.50));
				}
				case 259:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.40));
				}
				case 253:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.03));
				}
				case 229, 174:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.28));
				}
				case 226, 154:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.40));
				}
				case 214, 212, 211, 185, 70:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.12));
				}
				case 189:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.22));
				}
				case 187:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.42));
				}
				case 178:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.08, 0.22));
				}
				case 177:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.18));
				}
				case 156:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.08, 0.32));
				}
				case 155:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.02, 0.46));
				}
				case 153:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.26, 0.60));
				}
				case 73:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 0.14));
				}
				case 60, 11:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.10, 0.26));
				}
				case 10:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.12, 0.38));
				}
				default:
				{
					SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", GetRandomFloat(0.00, 1.00));
				}
			}
			SetEntProp(client, Prop_Send, "m_unMusicID", GetRandomInt(1,38));
		}
		SetEntProp(entity, Prop_Send, "m_iAccountID", g_iSteam32[client]);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);
	}
}

void RefreshWeapon(int client, int index, bool defaultKnife = false)
{
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
	
	for (int i = 0; i < size; i++)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if (IsValidWeapon(weapon))
		{
			bool isKnife = IsKnife(weapon);
			if ((!defaultKnife && GetWeaponIndex(weapon) == index) || (isKnife && (defaultKnife || IsKnifeClass(g_WeaponClasses[index]))))
			{
				if(!g_bOverwriteEnabled)
				{
					int previousOwner;
					if ((previousOwner = GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner")) != INVALID_ENT_REFERENCE && previousOwner != client)
					{
						return;
					}
				}
				
				int clip = -1;
				int ammo = -1;
				int offset = -1;
				int reserve = -1;
				
				if (!isKnife)
				{
					offset = FindDataMapInfo(client, "m_iAmmo") + (GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
					ammo = GetEntData(client, offset);
					clip = GetEntProp(weapon, Prop_Send, "m_iClip1");
					reserve = GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
				}
				
				RemovePlayerItem(client, weapon);
				AcceptEntityInput(weapon, "KillHierarchy");
				
				if (!isKnife)
				{
					weapon = GivePlayerItem(client, g_WeaponClasses[index]);
					if (clip != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
					}
					if (reserve != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", reserve);
					}
					if (offset != -1 && ammo != -1)
					{
						DataPack pack;
						CreateDataTimer(0.1, ReserveAmmoTimer, pack);
						pack.WriteCell(GetClientUserId(client));
						pack.WriteCell(offset);
						pack.WriteCell(ammo);
					}
				}
				else
				{
					GivePlayerItem(client, "weapon_knife");
				}
				break;
			}
		}
	}
}

public Action ReserveAmmoTimer(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int clientIndex = GetClientOfUserId(pack.ReadCell());
	int offset = pack.ReadCell();
	int ammo = pack.ReadCell();
	
	if(clientIndex > 0 && IsClientInGame(clientIndex))
	{
		SetEntData(clientIndex, offset, ammo, 4, true);
	}
}