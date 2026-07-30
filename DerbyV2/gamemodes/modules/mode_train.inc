// =============================================================================
// MODE_TRAIN.INC - Modo Treinamento (respawn automatico, pratica livre)
// =============================================================================

new Train_MapID = 0;

forward Train_RespawnPlayer(playerid);

// =============================================================================
// ENTRAR NO TREINAMENTO
// =============================================================================

stock ModeTrain_Join(playerid)
{
    if(Player[playerid][pMode] != MODE_NONE)
    {
        SCM(playerid, COL_RED, C_RED "Saia do modo atual primeiro (/sair).");
        return 0;
    }

    Player[playerid][pMode] = MODE_TRAIN;
    Player[playerid][pMatchState] = PSTATE_ALIVE;

    // Usar o primeiro mapa disponivel se nao tem um selecionado
    if(Train_MapID < 0 || Train_MapID >= TotalMaps)
        Train_MapID = Maps_FindNext(0);

    if(Train_MapID < 0)
    {
        SCM(playerid, COL_RED, C_RED "Nenhum mapa disponivel para treino.");
        Player[playerid][pMode] = MODE_NONE;
        return 0;
    }

    Maps_Load(Train_MapID);
    Train_SpawnPlayer(playerid);

    SCM(playerid, COL_CYAN, C_CYAN ">> Voce entrou no " C_WHITE "TREINAMENTO" C_CYAN "!");
    SCM(playerid, COL_GREY, C_GREY "   Ao cair, voce volta automaticamente. Pratique a vontade!");
    SCM(playerid, COL_GREY, C_GREY "   Use /sair para voltar ao lobby.");
    return 1;
}

// =============================================================================
// SAIR DO TREINAMENTO
// =============================================================================

stock ModeTrain_Leave(playerid)
{
    if(!IsPlayerInTrain(playerid)) return 0;

    DestroyPlayerVehicle(playerid);
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
        TogglePlayerSpectating(playerid, false);

    Player[playerid][pMode] = MODE_NONE;
    Player[playerid][pMatchState] = PSTATE_ALIVE;
    KillTimer(Player[playerid][pTimerRespawn]);
    return 1;
}

// =============================================================================
// SPAWNAR NO TREINO
// =============================================================================

stock Train_SpawnPlayer(playerid)
{
    DestroyPlayerVehicle(playerid);

    new mapid = Train_MapID;
    new slot = playerid % MapInfo[mapid][mapSpawnCount];

    new Float:x = MapSpawns[mapid][slot][0];
    new Float:y = MapSpawns[mapid][slot][1];
    new Float:z = MapSpawns[mapid][slot][2] + 2.0;
    new Float:a = MapSpawns[mapid][slot][3];
    new veh = MapInfo[mapid][mapVehicle];

    SetPlayerVirtualWorld(playerid, MapInfo[mapid][mapVW]);
    SetPlayerInterior(playerid, 0);
    SetPlayerHealth(playerid, 100.0);

    Player[playerid][pVehicleID] = CreateVehicle(veh, x, y, z, a, -1, -1, 99999, false);
    SetVehicleVirtualWorld(Player[playerid][pVehicleID], MapInfo[mapid][mapVW]);
    PutPlayerInVehicle(playerid, Player[playerid][pVehicleID], 0);
    SetVehicleParamsEx(Player[playerid][pVehicleID], 1, 1, 0, 1, 0, 0, 0);
    AddVehicleComponent(Player[playerid][pVehicleID], NITRO_COMPONENT);
    TogglePlayerControllable(playerid, true);
    SetPlayerTime(playerid, MapInfo[mapid][mapHour], 0);
    SetPlayerWeather(playerid, MapInfo[mapid][mapWeather]);
}

// =============================================================================
// JOGADOR CAIU NO TREINO (respawn automatico)
// =============================================================================

stock Train_PlayerFell(playerid)
{
    DestroyPlayerVehicle(playerid);

    new phrase[50];
    GetRespawnPhrase(phrase, sizeof(phrase));
    GameTextForPlayer(playerid, phrase, 2000, 3);
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

    Player[playerid][pTimerRespawn] = SetTimerEx("Train_RespawnPlayer", RESPAWN_DELAY_MS, false, "i", playerid);
}

public Train_RespawnPlayer(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerInTrain(playerid)) return 0;
    Train_SpawnPlayer(playerid);
    return 1;
}
