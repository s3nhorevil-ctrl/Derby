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
    Cla_Reset();

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

    CancelSelectTextDraw(playerid);
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
            // Entrar direto no FUN apos boas-vindas
            ModeFun_Join(playerid);
            return 1;
        }
        case DLG_MODE_SELECT:
        {
            if(!response) return 1;
            switch(listitem)
            {
                case 0: ModeCla_Join(playerid);   // LIVRE (modo CLA sem competicao = livre)
                case 1: ModeTrain_Join(playerid); // TREINAMENTO
            }
            return 1;
        }
    }
    // Dialogos do CLA
    if(dialogid >= DLG_CLA_PANEL && dialogid <= DLG_CLA_MEMBERS)
        return Cla_HandleDialog(playerid, dialogid, response, listitem, inputtext);

    return 0;
}

public OnPlayerUpdate(playerid)
{
    // Detectar queda no CLA
    if(IsPlayerInCla(playerid) && IsPlayerAlive(playerid) &&
       (Cla[cState] == CLA_RUNNING || Cla[cState] == CLA_TRAINING || Cla[cState] == CLA_LOBBY))
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && Player[playerid][pVehicleID] != INVALID_VEHICLE_ID)
        {
            new Float:cx, Float:cy, Float:cz;
            GetVehiclePos(Player[playerid][pVehicleID], cx, cy, cz);
            if(Cla[cMapID] >= 0 && cz <= MapInfo[Cla[cMapID]][mapZKill])
                Cla_PlayerDied(playerid);
        }
    }

    // Detectar queda no Treino
    if(IsPlayerInTrain(playerid) && Player[playerid][pVehicleID] != INVALID_VEHICLE_ID)
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            new Float:tx, Float:ty, Float:tz;
            GetVehiclePos(Player[playerid][pVehicleID], tx, ty, tz);
            if(Train_MapID >= 0 && tz <= MapInfo[Train_MapID][mapZKill])
                Train_PlayerFell(playerid);
        }
    }
    return 1;
}
