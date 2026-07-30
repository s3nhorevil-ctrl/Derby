// =============================================================================
// CALLBACKS.INC - Callbacks do SA-MP
// =============================================================================

public OnGameModeInit()
{
    SetGameModeText(SERVER_GAMEMODE_TEXT);
    SendRconCommand("hostname " SERVER_NAME " v" SERVER_VERSION);

    // Configuracoes do servidor
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    ShowPlayerMarkers(1);
    ShowNameTags(1);
    SetNameTagDrawDistance(40.0);
    UsePlayerPedAnims();

    // Classe unica (pula selecao de skin)
    AddPlayerClass(0, 0.0, 0.0, 20.0, 0.0, 0, 0, 0, 0, 0, 0);

    // Criar HUD
    HUD_Create();

    // Carregar mapas
    Maps_LoadList("DERBY/derbys.sfr");
    Maps_LoadVWTable("DERBY/vworlds.txt");
    Maps_CacheNames();

    // Carregar objetos dos mapas
    LoadAllDerbyObjects();

    // Estado inicial
    Match[mState] = DERBY_IDLE;

    print("[DERBY] Gamemode inicializado com sucesso!");
    return 1;
}

public OnGameModeExit()
{
    return 1;
}

public OnPlayerConnect(playerid)
{
    ResetPlayerData(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(IsPlayerInDerby(playerid))
        ModeFun_Leave(playerid);
    else if(IsPlayerInCla(playerid))
        ModeCla_Leave(playerid);
    else if(IsPlayerInTrain(playerid))
        ModeTrain_Leave(playerid);

    DestroyPlayerVehicle(playerid);
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    // Pula selecao de skin, spawn direto
    SpawnPlayer(playerid);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(Player[playerid][pMode] != MODE_NONE)
        return 1; // ja esta num modo, nao fazer nada

    // Primeiro spawn: mostrar boas-vindas
    SetPlayerPos(playerid, 0.0, 0.0, 20.0);
    SetPlayerVirtualWorld(playerid, playerid + 500); // mundo isolado
    TogglePlayerControllable(playerid, false);
    SetCameraBehindPlayer(playerid);

    UX_ShowWelcome(playerid);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    // Trocar spectate com SPRINT (ENTER)
    if((newkeys & KEY_SPRINT) && !(oldkeys & KEY_SPRINT))
    {
        if(Player[playerid][pMatchState] == PSTATE_SPECTATING)
        {
            Derby_NextSpectate(playerid);
            return 1;
        }
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    // Jogador saiu do veiculo durante partida = morreu
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
    {
        if(IsPlayerInDerby(playerid) && IsPlayerAlive(playerid))
        {
            if(Match[mState] == DERBY_RUNNING)
                Derby_EliminatePlayer(playerid);
        }
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DLG_WELCOME:
        {
            TogglePlayerControllable(playerid, true);
            SetPlayerVirtualWorld(playerid, VW_LOBBY);
            UX_ShowModeSelect(playerid);
            return 1;
        }
        case DLG_MODE_SELECT:
        {
            if(!response) return 1;
            switch(listitem)
            {
                case 0: ModeFun_Join(playerid);
                case 1: ModeCla_Join(playerid);
                case 2: ModeTrain_Join(playerid);
            }
            return 1;
        }
    }
    return 0;
}

public OnPlayerUpdate(playerid)
{
    return 1;
}
