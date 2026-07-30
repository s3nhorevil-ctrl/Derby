// =============================================================================
// DERBY_ENGINE.INC - Motor principal do Derby
// Gerencia estados da partida, eliminacao, vencedor
// =============================================================================

// --- Estados da partida ---
enum E_DERBY_STATE
{
    DERBY_IDLE,         // sem partida (esperando jogadores)
    DERBY_COUNTDOWN,    // contagem regressiva
    DERBY_RUNNING,      // partida em andamento
    DERBY_FINISHED      // partida acabou (exibindo vencedor)
};

// --- Dados da partida atual ---
enum E_MATCH_DATA
{
    E_DERBY_STATE:mState,
    mMapID,
    mPlayers,           // total de jogadores na partida
    mAlivePlayers,      // jogadores vivos
    mWinner,            // id do vencedor
    mCountdown,         // contagem regressiva atual
    mTimeLeft,          // tempo restante do round
    mTimerCountdown,
    mTimerRound,
    mStartTime          // gettime() do inicio
};

new Match[E_MATCH_DATA];

// Forwards
forward Derby_CountdownTick();
forward Derby_RoundTick();
forward Derby_FinishDelay();

// =============================================================================
// INICIAR NOVA PARTIDA
// =============================================================================

stock Derby_StartMatch(mapid)
{
    if(Maps_Load(mapid) == 0) return 0;

    Match[mMapID] = mapid;
    Match[mState] = DERBY_COUNTDOWN;
    Match[mPlayers] = 0;
    Match[mAlivePlayers] = 0;
    Match[mWinner] = INVALID_PLAYER_ID;
    Match[mCountdown] = COUNTDOWN_SECONDS;
    Match[mTimeLeft] = ROUND_TIMEOUT;
    Match[mStartTime] = gettime();

    // Posicionar todos os jogadores do modo FUN
    new slot = 0;
    Loop(i, pool)
    {
        if(!IsPlayerInDerby(i)) continue;
        if(slot >= MAX_DERBY_SLOTS) break;

        Player[i][pMatchState] = PSTATE_ALIVE;
        Player[i][pSpawnSlot] = slot;
        Player[i][pAfkSeconds] = 0;

        Derby_SpawnPlayerVehicle(i, mapid, slot);

        // Congelar durante countdown
        TogglePlayerControllable(i, false);
        SetVehicleParamsEx(Player[i][pVehicleID], 0, 0, 0, 1, 0, 0, 0);

        Match[mPlayers]++;
        Match[mAlivePlayers]++;
        slot++;
    }

    // Iniciar countdown
    KillTimer(Match[mTimerCountdown]);
    Match[mTimerCountdown] = SetTimer("Derby_CountdownTick", 1000, true);

    // Anunciar mapa
    new msg[128];
    format(msg, sizeof(msg), C_DERBY ">> " C_WHITE "Mapa: " C_GOLD "%s " C_WHITE "| Veiculo: " C_GOLD "%d " C_WHITE "| Iniciando em %ds",
        MapInfo[mapid][mapName], MapInfo[mapid][mapVehicle], COUNTDOWN_SECONDS);
    Derby_Broadcast(COL_DERBY, msg);

    // HUD
    HUD_ShowMatch();
    return 1;
}

// =============================================================================
// COUNTDOWN
// =============================================================================

public Derby_CountdownTick()
{
    if(Match[mState] != DERBY_COUNTDOWN)
    {
        KillTimer(Match[mTimerCountdown]);
        return 1;
    }

    Match[mCountdown]--;

    // Som de contagem
    if(Match[mCountdown] > 0 && Match[mCountdown] <= 3)
    {
        Loop(i, pool)
        {
            if(IsPlayerInDerby(i) && IsPlayerAlive(i))
                PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
        }
    }

    // Atualizar HUD
    HUD_UpdateCountdown(Match[mCountdown]);

    if(Match[mCountdown] <= 0)
    {
        KillTimer(Match[mTimerCountdown]);
        Derby_Go();
    }
    return 1;
}

// =============================================================================
// GO! - Libera os jogadores
// =============================================================================

stock Derby_Go()
{
    Match[mState] = DERBY_RUNNING;
    Match[mStartTime] = gettime();

    Loop(i, pool)
    {
        if(!IsPlayerInDerby(i) || !IsPlayerAlive(i)) continue;

        // Ligar motor e liberar
        TogglePlayerControllable(i, true);
        CancelSelectTextDraw(i);
        SetVehicleParamsEx(Player[i][pVehicleID], 1, 1, 0, 1, 0, 0, 0);
        PlayerPlaySound(i, 3200, 0.0, 0.0, 0.0);

        // Nitro controlavel
        AddVehicleComponent(Player[i][pVehicleID], NITRO_COMPONENT);
    }

    Derby_Broadcast(COL_GREEN, C_GREEN ">> GO! GO! GO!");
    HUD_UpdateCountdown(-1); // esconde countdown

    // Timer do round
    KillTimer(Match[mTimerRound]);
    Match[mTimerRound] = SetTimer("Derby_RoundTick", 1000, true);
    return 1;
}

// =============================================================================
// ROUND TICK - Atualiza tempo e detecta queda
// =============================================================================

public Derby_RoundTick()
{
    if(Match[mState] != DERBY_RUNNING)
    {
        KillTimer(Match[mTimerRound]);
        return 1;
    }

    Match[mTimeLeft]--;
    HUD_UpdateTimer(Match[mTimeLeft]);

    // Timeout
    if(Match[mTimeLeft] <= 0)
    {
        KillTimer(Match[mTimerRound]);
        Derby_Broadcast(COL_YELLOW, C_YELLOW ">> Tempo esgotado! Ninguem venceu.");
        Derby_EndMatch(INVALID_PLAYER_ID);
        return 1;
    }

    // Detectar queda de cada jogador
    Loop(i, pool)
    {
        if(!IsPlayerInDerby(i) || !IsPlayerAlive(i)) continue;
        if(GetPlayerState(i) != PLAYER_STATE_DRIVER) continue;
        if(Player[i][pVehicleID] == INVALID_VEHICLE_ID) continue;

        new Float:x, Float:y, Float:z;
        GetVehiclePos(Player[i][pVehicleID], x, y, z);

        if(z <= MapInfo[Match[mMapID]][mapZKill])
        {
            Derby_EliminatePlayer(i);
        }
    }
    return 1;
}

// =============================================================================
// ELIMINAR JOGADOR
// =============================================================================

stock Derby_EliminatePlayer(playerid)
{
    if(Player[playerid][pMatchState] != PSTATE_ALIVE) return 0;

    Player[playerid][pMatchState] = PSTATE_DEAD;
    Player[playerid][pDeaths]++;
    DestroyPlayerVehicle(playerid);
    Match[mAlivePlayers]--;

    // Frase comica
    new phrase[64], msg[145];
    GetDeathPhrase(phrase, sizeof(phrase));
    format(msg, sizeof(msg), C_ORANGE ">> " C_WHITE "%s " C_ORANGE "%s " C_GREY "(pos: %d/%d)",
        Player[playerid][pName], phrase, Match[mAlivePlayers] + 1, Match[mPlayers]);
    Derby_Broadcast(COL_ORANGE, msg);

    // Score baseado na posicao
    new score = Match[mPlayers] - Match[mAlivePlayers];
    Player[playerid][pScore] += score;
    SetPlayerScore(playerid, Player[playerid][pScore]);

    // Som de eliminacao
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

    // Verificar fim da partida
    if(Match[mAlivePlayers] <= 1)
    {
        // Encontrar o vencedor
        new winner = INVALID_PLAYER_ID;
        Loop(i, pool)
        {
            if(IsPlayerInDerby(i) && IsPlayerAlive(i))
            {
                winner = i;
                break;
            }
        }
        Derby_EndMatch(winner);
        return 1;
    }

    // Colocar em spectate
    Derby_SetSpectate(playerid);
    return 1;
}

// =============================================================================
// FIM DA PARTIDA
// =============================================================================

stock Derby_EndMatch(winner)
{
    KillTimer(Match[mTimerRound]);
    Match[mState] = DERBY_FINISHED;
    Match[mWinner] = winner;

    if(winner != INVALID_PLAYER_ID)
    {
        // Premiar vencedor
        new prize = Match[mPlayers] * 2;
        Player[winner][pScore] += prize;
        SetPlayerScore(winner, Player[winner][pScore]);
        PlayerPlaySound(winner, 1057, 0.0, 0.0, 0.0);

        new msg[128];
        format(msg, sizeof(msg), C_GOLD ">> " C_WHITE "%s " C_GOLD "VENCEU! " C_WHITE "(+%d score | Tempo: %s)",
            Player[winner][pName], prize, FormatTime(gettime() - Match[mStartTime]));
        Derby_Broadcast(COL_GOLD, msg);
    }
    else
    {
        Derby_Broadcast(COL_YELLOW, C_YELLOW ">> Partida encerrada sem vencedor.");
    }

    HUD_ShowWinner(winner);

    // Delay antes de carregar proximo mapa
    SetTimer("Derby_FinishDelay", 5000, false);
    return 1;
}

public Derby_FinishDelay()
{
    // Proximo mapa (modo FUN vai chamar isso)
    ModeFun_NextMap();
    return 1;
}

// =============================================================================
// SPECTATE
// =============================================================================

stock Derby_SetSpectate(playerid)
{
    Player[playerid][pMatchState] = PSTATE_SPECTATING;

    // Encontrar alguem vivo para assistir
    Loop(i, pool)
    {
        if(i == playerid) continue;
        if(!IsPlayerInDerby(i) || !IsPlayerAlive(i)) continue;
        if(Player[i][pVehicleID] == INVALID_VEHICLE_ID) continue;

        Player[playerid][pSpectateTarget] = i;
        TogglePlayerSpectating(playerid, true);
        PlayerSpectateVehicle(playerid, Player[i][pVehicleID]);
        SCM(playerid, COL_GREY, C_GREY "Pressione " C_GREEN "ENTER " C_GREY "para trocar de camera.");
        return 1;
    }
    return 0;
}

stock Derby_NextSpectate(playerid)
{
    new current = Player[playerid][pSpectateTarget];
    new found = INVALID_PLAYER_ID;

    Loop(i, pool)
    {
        if(i == playerid || i == current) continue;
        if(!IsPlayerInDerby(i) || !IsPlayerAlive(i)) continue;
        if(Player[i][pVehicleID] == INVALID_VEHICLE_ID) continue;

        if(i > current || found == INVALID_PLAYER_ID)
        {
            found = i;
            if(i > current) break;
        }
    }

    if(found != INVALID_PLAYER_ID && found != current)
    {
        Player[playerid][pSpectateTarget] = found;
        PlayerSpectateVehicle(playerid, Player[found][pVehicleID]);
    }
}

// =============================================================================
// SPAWNAR VEICULO PARA JOGADOR
// =============================================================================

stock Derby_SpawnPlayerVehicle(playerid, mapid, slot)
{
    DestroyPlayerVehicle(playerid);

    new Float:x = MapSpawns[mapid][slot][0];
    new Float:y = MapSpawns[mapid][slot][1];
    new Float:z = MapSpawns[mapid][slot][2] + 2.0;
    new Float:a = MapSpawns[mapid][slot][3];
    new veh = MapInfo[mapid][mapVehicle];
    new vw = MapInfo[mapid][mapVW];

    Player[playerid][pVehicleID] = CreateVehicle(veh, x, y, z, a,
        RandomInt(1, 255), RandomInt(1, 255), 99999, false);
    SetVehicleVirtualWorld(Player[playerid][pVehicleID], vw);
    SetPlayerVirtualWorld(playerid, vw);
    SetPlayerInterior(playerid, 0);
    PutPlayerInVehicle(playerid, Player[playerid][pVehicleID], 0);
    SetPlayerTime(playerid, MapInfo[mapid][mapHour], 0);
    SetPlayerWeather(playerid, MapInfo[mapid][mapWeather]);
    return Player[playerid][pVehicleID];
}

// =============================================================================
// BROADCAST para todos no modo FUN
// =============================================================================

stock Derby_Broadcast(color, const msg[])
{
    Loop(i, pool)
    {
        if(IsPlayerInDerby(i))
            SCM(i, color, msg);
    }
}
