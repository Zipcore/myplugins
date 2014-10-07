#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include "left4downtown"
 
#define TEAM_INFECTED					3
#define TAUNT_HIGH_THRESHOLD			0.4
#define TAUNT_MID_THRESHOLD				0.2
#define TAUNT_LOW_THRESHOLD				0.04

enum SIClasses
{
        SMOKER_CLASS=1,
        BOOMER_CLASS,
        HUNTER_CLASS,
        SPITTER_CLASS,
        JOCKEY_CLASS,
        CHARGER_CLASS,
        WITCH_CLASS,
        TANK_CLASS,
        NOTINFECTED_CLASS
}
 
static String:SINames[_:SIClasses][] =
{
        "",
        "gas",          // smoker
        "exploding",    // boomer
        "hunter",
        "spitter",
        "jockey",
        "charger",
        "witch",
        "tank",
        ""
};
 
new Handle: hCvarDamageFromCaps = INVALID_HANDLE;
new Handle: hSpecialInfectedHP[_:SIClasses] = INVALID_HANDLE;
new Handle: hCvarSurvivorCount = INVALID_HANDLE;
//new Handle: hPrintTaunts;
//new Handle: hLowTauntPrint;
//new Handle: hMidTauntPrint;
//new Handle: hHighTauntPrint;
new PlayersCapped;
new SurvivorCount;
new DamageFromCaps;

public Plugin:myinfo =
{
        name = "Capper Removal",
        author = "Jacob",
        description = "Better cap removal control. Supports any number of players.",
        version = "1.0",
        url = "https://github.com/jacob404/myplugins"
}


public OnPluginStart()
{      
        decl String:buffer[17];
        for (new i = 1; i < _:SIClasses; i++)
        {
            Format(buffer, sizeof(buffer), "z_%s_health", SINames[i]);
            hSpecialInfectedHP[i] = FindConVar(buffer);
        }
		
	//Cvars and whatnot
		hCvarDamageFromCaps = CreateConVar("damage_from_caps", "20", "Amount of damage done (at once) before SI suicides.", FCVAR_PLUGIN, true, 1.0);
		//hCvarLedgeHangCounts = CreateConVar("ledge_hang_counts", "0", "Should ledge hangs increase the capped survivor count?", FCVAR_PLUGIN);
		hCvarSurvivorCount = CreateConVar("survivors_count", "3", "Amount of damage done (at once) before SI suicides.", FCVAR_PLUGIN, true, 1.0);
		DamageFromCaps = GetConVarInt(hCvarDamageFromCaps);
		SurvivorCount = GetConVarInt(hCvarSurvivorCount);
		
	//Hooks
        HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
        HookEvent("lunge_pounce", Event_Survivor_Pounced);
        HookEvent("tongue_grab", Event_Survivor_Pulled);
        HookEvent("jockey_ride", Event_Survivor_Rode);
        HookEvent("charger_pummel_start", Event_Survivor_Charged);
        HookEvent("pounce_stopped", Event_Pounce_End);
        HookEvent("tongue_release", Event_Pull_End);
        HookEvent("jockey_ride_end", Event_Ride_End);
        HookEvent("charger_pummel_end", Event_Charge_End);
        //HookEvent("player_ledge_grab", survivor_hung);
}

public Event_Survivor_Pounced (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PlayersCapped = (PlayersCapped + 1);
	PrintToChatAll("Pounce Landed %i", PlayersCapped);
	if (PlayersCapped >= SurvivorCount)
	{
		PrintToChatAll("Cappers should be dead. %i", DamageFromCaps);
	}
}

public Event_Pounce_End (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PlayersCapped = (PlayersCapped - 1);
	PrintToChatAll("Pounce Ended %i", PlayersCapped);
	if (PlayersCapped < 0)
	{
		PlayersCapped = 0;
	}
}

public Event_Survivor_Rode (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PlayersCapped = (PlayersCapped + 1);
	PrintToChatAll("Jock Landed %i", PlayersCapped);
	if (PlayersCapped >= SurvivorCount)
	{
		PrintToChatAll("Cappers should be dead. %i", DamageFromCaps);
	}
}

public Event_Ride_End (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PlayersCapped = (PlayersCapped - 1);
	PrintToChatAll("Jock Ended %i", PlayersCapped);
	if (PlayersCapped < 0)
	{
		PlayersCapped = 0;
	}
}

public Event_Survivor_Charged (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PlayersCapped = (PlayersCapped + 1);
	PrintToChatAll("Charge Landed %i", PlayersCapped);
	if (PlayersCapped >= SurvivorCount)
	{
		PrintToChatAll("Cappers should be dead. %i", DamageFromCaps);
	}
}

public Event_Charge_End (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PlayersCapped = (PlayersCapped - 1);
	PrintToChatAll("Charge Ended %i", PlayersCapped);
	if (PlayersCapped < 0)
	{
		PlayersCapped = 0;
	}
}

public Event_Survivor_Pulled (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PlayersCapped = (PlayersCapped + 1);
	PrintToChatAll("Pull Landed %i", PlayersCapped);
	if (PlayersCapped >= SurvivorCount)
	{
		PrintToChatAll("Cappers should be dead. %i", DamageFromCaps);
	}
}

public Event_Pull_End (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PlayersCapped = (PlayersCapped - 1);
	PrintToChatAll("Pull Ended %i", PlayersCapped);
	if (PlayersCapped < 0)
	{
		PlayersCapped = 0;
	}
}

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
        new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
       
        if (!IsClientAndInGame(attacker))
                return;
       
        new zombie_class = GetZombieClass(attacker);
       
        if (GetClientTeam(attacker) == TEAM_INFECTED && zombie_class != _:TANK_CLASS && PlayersCapped >= SurvivorCount)
        {
				CreateTimer(0.5, ForcePlayerSuicide(attacker), INVALID_HANDLE);
        }
}


stock GetZombieClass(client) return GetEntProp(client, Prop_Send, "m_zombieClass");

stock GetSpecialInfectedHP(class)
{
    if (hSpecialInfectedHP[class] != INVALID_HANDLE)
            return GetConVarInt(hSpecialInfectedHP[class]);
    
    return 0;
}

stock bool:IsClientAndInGame(index)
{
        if (index > 0 && index < MaxClients)
        {
            return IsClientInGame(index);
        }
        return false;
}
