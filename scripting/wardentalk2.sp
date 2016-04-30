#include <sourcemod>
#include <basecomm>
#include <warden>
#include <voiceannounce_ex>

new Handle:g_hWardenOnly = INVALID_HANDLE;
new Handle:g_wardentalk2_enabled = INVALID_HANDLE;

new bool:isEnabled = false;

public OnPluginStart()
{
    g_hWardenOnly = CreateConVar("sm_warden_only", "1.0", "1 for warden on mic only. 0 to allow other CTs too", 0, true, 0.0, true, 1.0);
    g_wardentalk2_enabled = CreateConVar("sm_wardentalk2_enabled", "1", "Enable Warden Talk (0 off, 1 on, def. 1)");
    HookConVarChange(g_wardentalk2_enabled, ConVarChange_enabled);
}

public ConVarChange_enabled(Handle:convar, const String:oldValue[], const String:newValue[])
{
  isEnabled = bool:StringToInt(newValue) ;
}

public bool:OnClientSpeakingEx(client)
{
    if (!isEnabled)
      return true;
    
    if(BaseComm_IsClientMuted(client))
        return false;

    if(!warden_exist())
        return true;

    new speaking = 0;
    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && IsClientSpeaking(i) && !BaseComm_IsClientMuted(i) && warden_iswarden(i))
        {
            ++speaking;
        }
    }
    if((speaking > 0 ) && (!warden_iswarden(client)))
    {
        if(GetConVarBool(g_hWardenOnly)) //Mute if not warden
        {
            BaseComm_SetClientMute(client, true);
            CreateTimer(1.0, unmute, client);
            PrintCenterText(client, "Warden is giving orders, everyone else is muted");
            return false;
        }
        else
        {
            if(!(GetClientTeam(client) == 3)) // Mute if not warden or CT
            {
                BaseComm_SetClientMute(client, true);
                CreateTimer(1.0, unmute, client);
                PrintCenterText(client, "Warden is giving orders, everyone else is muted");
                return false;
            }
            else
                return true
        }
    }
    else 
        return true;
}

public Action:unmute(Handle:timer, any:client)
{
    if (!isEnabled)
      return;
    
    if (IsClientInGame(client) && !IsFakeClient(client) && BaseComm_IsClientMuted(client))
        BaseComm_SetClientMute(client, false);
}  