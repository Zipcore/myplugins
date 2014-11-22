#pragma semicolon 1

#include <sourcemod>
#include <left4downtown>

public Plugin:myinfo = 
{
    name = "Boomer Horde Equalizer",
    author = "Jacob + Visor",
    version = "0.1",
    description = "Fixes boomer hordes being different sizes based on wandering commons."
};

new Handle:boomer_horde_size;

public OnPluginStart()
{
	boomer_horde_size = CreateConVar("boomer_horde_size", "25", "How many commons should spawn per mob.", FCVAR_PLUGIN, true, 0.0, true, 40.0);
}

public Action:L4D_OnSpawnITMob(&amount)
{
	PrintToChatAll("Horde Size Pre-Fix: %d", amount);
	amount = GetConVarInt(boomer_horde_size);
	PrintToChatAll("Horde Size Post-Fix: %d", amount);
}