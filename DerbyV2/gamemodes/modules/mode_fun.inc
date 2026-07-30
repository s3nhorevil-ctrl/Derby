// =============================================================================
// MODE_FUN.INC - Modo Derby automatico (mapas em rotacao)
// =============================================================================

new ModeFun_CurrentMap = 0;
new ModeFun_WaitTimer = -1;

forward ModeFun_WaitCheck();

// =============================================================================
// JOGADOR ENTRA NO MODO FUN
// =============================================================================

stock ModeFun_Join(playerid)
{
    if(Player[playerid][pMode] != MODE_NONE) return 0;

    Player[playerid][pMode] = MODE_FUN;
    Player[playerid][pMatchState] = PSTATE_ALIVE;

    SCM(playerid, COL_GREEN, C_GREEN ">> Voce entrou no " C_DERBY "MODO FUN" C_GREEN "!");
    SCM(playerid, COL_GREY, C_GREY "   Ultimo a sobreviver na plataforma vence. Boa sorte!");

    // Se tem partida rodando, entrar como spectate
    if(Match[mState] == DERBY_RUNNING || Match[mState] == DERBY_COUNTDOWN)
    {
        Player[playerid][pMatchState] = PSTATE_SPECTATING;
        Derby_SetSpectate(playerid);
        HUD_ShowForPlayer(playerid);
        SCM(playerid, COL_GREY, C_GREY "   Partida em andamento. Voce entra na proxima!");
        return 1;
    }

    // Se esta em IDLE ou FINISHED, tentar iniciar
    if(Match[mState] == DERBY_IDLE || Match[mState] == DERBY_FINISHED)
    {
        ModeFun_TryStart();
    }
    return 1;
}

// =============================================================================
// JOGADOR SAI DO MODO FUN
// =============================================================================

stock ModeFun_Leave(playerid)
{
    if(!IsPlayerInDerby(playerid)) return 0;

    // Se estava vivo, reduzir contagem
    if(Player[playerid][pMatchState] == PSTATE_ALIVE && Match[mState] == DERBY_RUNNING)
    {
        Match[mAlivePlayers]--;
    }

    DestroyPlayerVehicle(playerid);

    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
        TogglePlayerSpectating(playerid, false);

    HUD_HideMatch(playerid);
    Player[playerid][pMode] = MODE_NONE;
    Player[playerid][pMatchState] = PSTATE_ALIVE;

    // Verificar se a partida precisa terminar
    if(Match[mState] == DERBY_RUNNING && Match[mAlivePlayers] <= 1)
    {
        new winner = INVALID_PLAYER_ID;
        for(new i = 0, i_j = GetPlayerPoolSize(); i <= i_j; i++) if(IsPlayerConnected(i))
        {
            if(IsPlayerInDerby(i) && IsPlayerAlive(i))
            {
                winner = i;
                break;
            }
        }
        Derby_EndMatch(winner);
    }
    return 1;
}

// =============================================================================
// TENTAR INICIAR PARTIDA
// =============================================================================

stock ModeFun_TryStart()
{
    // Contar jogadores no modo FUN
    new count = 0;
    for(new i = 0, i_j = GetPlayerPoolSize(); i <= i_j; i++) if(IsPlayerConnected(i))
    {
        if(IsPlayerInDerby(i)) count++;
    }

    if(count < 1) return 0; // precisa de pelo menos 1

    // Carregar proximo mapa e iniciar
    new mapid = Maps_FindNext(ModeFun_CurrentMap);
    if(mapid == -1) return 0;

    ModeFun_CurrentMap = mapid;
    Derby_StartMatch(mapid);
    return 1;
}

// =============================================================================
// PROXIMO MAPA (chamado apos o delay de fim de partida)
// =============================================================================

stock ModeFun_NextMap()
{
    // Resetar estados dos jogadores
    for(new i = 0, i_j = GetPlayerPoolSize(); i <= i_j; i++) if(IsPlayerConnected(i))
    {
        if(!IsPlayerInDerby(i)) continue;
        Player[i][pMatchState] = PSTATE_ALIVE;
        if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            TogglePlayerSpectating(i, false);
    }

    Match[mState] = DERBY_IDLE;

    // Avancar mapa
    ModeFun_CurrentMap = (ModeFun_CurrentMap + 1) % TotalMaps;
    ModeFun_TryStart();
}
