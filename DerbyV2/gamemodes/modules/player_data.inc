// =============================================================================
// PLAYER_DATA.INC - Dados e estado de cada jogador
// =============================================================================

// --- Modos disponiveis ---
enum E_PLAYER_MODE
{
    MODE_NONE,          // no lobby / boas-vindas
    MODE_FUN,           // modo fun (derby automatico)
    MODE_CLA,           // modo cla vs cla
    MODE_TRAIN          // modo treinamento
};

// --- Estado dentro da partida ---
enum E_MATCH_STATE
{
    PSTATE_ALIVE,       // jogando normalmente
    PSTATE_DEAD,        // eliminado
    PSTATE_SPECTATING   // assistindo
};

// --- Dados persistentes do jogador ---
enum E_PLAYER_DATA
{
    // Identidade
    pName[MAX_PLAYER_NAME],

    // Estado atual
    E_PLAYER_MODE:pMode,
    E_MATCH_STATE:pMatchState,

    // Derby
    pVehicleID,
    pSpawnSlot,
    pScore,
    pKills,             // quantos empurrou (futuro)
    pDeaths,            // quantas vezes caiu

    // CLA
    pClaTeam,           // -1=nenhum, 0=time1, 1=time2

    // Anti-AFK
    pLastPosHash,
    pAfkSeconds,

    // Spectate
    pSpectateTarget,

    // Timers
    pTimerRespawn
};

new Player[MAX_PLAYERS][E_PLAYER_DATA];

// =============================================================================
// FUNCOES DE PLAYER DATA
// =============================================================================

stock ResetPlayerData(playerid)
{
    GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
    Player[playerid][pMode] = MODE_NONE;
    Player[playerid][pMatchState] = PSTATE_ALIVE;
    Player[playerid][pVehicleID] = INVALID_VEHICLE_ID;
    Player[playerid][pSpawnSlot] = 0;
    Player[playerid][pScore] = 0;
    Player[playerid][pKills] = 0;
    Player[playerid][pDeaths] = 0;
    Player[playerid][pClaTeam] = -1;
    Player[playerid][pLastPosHash] = 0;
    Player[playerid][pAfkSeconds] = 0;
    Player[playerid][pSpectateTarget] = INVALID_PLAYER_ID;
    Player[playerid][pTimerRespawn] = -1;
}

stock bool:IsPlayerInDerby(playerid)
{
    return (Player[playerid][pMode] == MODE_FUN);
}

stock bool:IsPlayerInCla(playerid)
{
    return (Player[playerid][pMode] == MODE_CLA);
}

stock bool:IsPlayerInTrain(playerid)
{
    return (Player[playerid][pMode] == MODE_TRAIN);
}

stock bool:IsPlayerAlive(playerid)
{
    return (Player[playerid][pMatchState] == PSTATE_ALIVE);
}

stock DestroyPlayerVehicle(playerid)
{
    if(Player[playerid][pVehicleID] != INVALID_VEHICLE_ID)
    {
        if(IsValidVehicle(Player[playerid][pVehicleID]))
            DestroyVehicle(Player[playerid][pVehicleID]);
        Player[playerid][pVehicleID] = INVALID_VEHICLE_ID;
    }
}
