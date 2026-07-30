/*
    DERBY V3 - ROOM MANAGER
    
    Gerenciamento do ciclo de vida das salas:
    criacao, destruicao, entrada/saida de jogadores,
    transicoes de estado, spawn de veiculos.
*/

#if defined _room_manager_included
    #endinput
#endif
#define _room_manager_included

// =============================================================================
// FORWARDS
// =============================================================================

forward RoomCountdown(roomid);
forward RoomTimeout(roomid);
forward RoomTransition(roomid);
forward NitroUpdateTimer();
forward AntiAFKCheck();
forward VehicleHPUpdate();


// =============================================================================
// CRIAR SALA
// =============================================================================

stock CreateRoom(playerid, mode, const roomname[], rounds, vehiclemodel)
{
    new roomid = GetFreeRoomSlot();
    if(roomid == INVALID_ROOM_ID)
    {
        SCM(playerid, COLOR_RED, "[ERRO] Nao ha salas disponiveis. Tente novamente mais tarde.");
        return INVALID_ROOM_ID;
    }
    
    ResetRoomData(roomid);
    
    format(RoomData[roomid][ROOM_NAME], 32, "%s", roomname);
    RoomData[roomid][ROOM_HOST] = playerid;
    RoomData[roomid][ROOM_MODE] = mode;
    RoomData[roomid][ROOM_STATE] = ROOM_STATE_LOBBY;
    RoomData[roomid][ROOM_VEHICLE] = vehiclemodel;
    RoomData[roomid][ROOM_TOTAL_ROUNDS] = rounds;
    RoomData[roomid][ROOM_CURRENT_ROUND] = 0;
    RoomData[roomid][ROOM_MAX_PLAYERS] = MAX_ROOM_PLAYERS;
    
    // Jogador entra automaticamente
    JoinRoom(playerid, roomid);
    
    new str[128];
    format(str, sizeof(str), "{00FF00}| DERBY | Sala '%s' criada! Modo: %s | Rounds: %d",
        roomname, GetModeName(mode), rounds);
    SCM(playerid, COLOR_INFO, str);
    
    return roomid;
}


// =============================================================================
// DESTRUIR SALA
// =============================================================================

stock DestroyRoom(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(roomid == FUN_ROOM_ID) return 0; // Nao pode destruir sala FUN
    
    // Remover todos os jogadores
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerData[i][PL_ROOM_ID] == roomid)
        {
            LeaveRoom(i);
        }
    }
    
    KillRoomTimers(roomid);
    ResetRoomData(roomid);
    return 1;
}

// =============================================================================
// ENTRAR NA SALA
// =============================================================================

stock JoinRoom(playerid, roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(!IsRoomActive(roomid)) return 0;
    if(IsRoomFull(roomid))
    {
        SCM(playerid, COLOR_RED, "[ERRO] Sala lotada!");
        return 0;
    }
    
    // Se ja esta em outra sala, sair primeiro
    if(PlayerData[playerid][PL_ROOM_ID] != INVALID_ROOM_ID)
    {
        LeaveRoom(playerid);
    }
    
    PlayerData[playerid][PL_ROOM_ID] = roomid;
    PlayerData[playerid][PL_IN_DERBY] = true;
    PlayerData[playerid][PL_VEHICLE_ID] = INVALID_VEHICLE_ID;
    PlayerData[playerid][PL_AFK_SECONDS] = 0;
    PlayerData[playerid][PL_NITRO_FUEL] = 100.0;
    PlayerData[playerid][PL_NITRO_ACTIVE] = false;
    
    RoomData[roomid][ROOM_PLAYER_COUNT]++;
    
    // Definir estado baseado no estado da sala
    switch(RoomData[roomid][ROOM_STATE])
    {
        case ROOM_STATE_LOBBY, ROOM_STATE_COUNTDOWN:
        {
            PlayerData[playerid][PL_STATE] = PL_ST_LOBBY;
            SetPlayerVirtualWorld(playerid, GetRoomVirtualWorld(roomid));
        }
        case ROOM_STATE_RUNNING:
        {
            // Entrou durante partida - spectate
            PlayerData[playerid][PL_STATE] = PL_ST_SPECTATING;
            SetPlayerVirtualWorld(playerid, GetRoomVirtualWorld(roomid));
            StartSpectating(playerid, roomid);
        }
    }

    
    new str[128];
    format(str, sizeof(str), "{00FF00}| DERBY | %s entrou na sala (%d/%d)",
        PlayerData[playerid][PL_NAME], RoomData[roomid][ROOM_PLAYER_COUNT],
        RoomData[roomid][ROOM_MAX_PLAYERS]);
    SendRoomMessage(roomid, COLOR_INFO, str);
    
    return 1;
}

// =============================================================================
// SAIR DA SALA
// =============================================================================

stock LeaveRoom(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID) return 0;
    
    // Destruir veiculo se existir
    if(PlayerData[playerid][PL_VEHICLE_ID] != INVALID_VEHICLE_ID)
    {
        DestroyVehicleSafe(PlayerData[playerid][PL_VEHICLE_ID]);
        PlayerData[playerid][PL_VEHICLE_ID] = INVALID_VEHICLE_ID;
    }
    
    // Liberar slot de spawn
    new slot = PlayerData[playerid][PL_SPAWN_SLOT];
    if(slot >= 0 && slot < MAX_ROOM_PLAYERS)
        RoomSlotUsed[roomid][slot] = false;
    
    // Se estava vivo, decrementar
    if(PlayerData[playerid][PL_STATE] == PL_ST_ALIVE)
    {
        RoomData[roomid][ROOM_ALIVE_COUNT]--;
    }
    
    // Parar spectate
    if(GetPlayerState(playerid) == 9) // PL_ST_SPECTATING
        TogglePlayerSpectating(playerid, false);
    
    // Esconder HUD
    HideRoomHUD(playerid);
    
    // Resetar dados do jogador
    PlayerData[playerid][PL_ROOM_ID] = INVALID_ROOM_ID;
    PlayerData[playerid][PL_STATE] = PL_ST_NONE;
    PlayerData[playerid][PL_IN_DERBY] = false;
    PlayerData[playerid][PL_TEAM] = TEAM_NONE;
    PlayerData[playerid][PL_SPAWN_SLOT] = -1;
    PlayerData[playerid][PL_NITRO_ACTIVE] = false;
    
    RoomData[roomid][ROOM_PLAYER_COUNT]--;
    
    new str[128];
    format(str, sizeof(str), "{FF9900}| DERBY | %s saiu da sala (%d/%d)",
        PlayerData[playerid][PL_NAME], RoomData[roomid][ROOM_PLAYER_COUNT],
        RoomData[roomid][ROOM_MAX_PLAYERS]);
    SendRoomMessage(roomid, COLOR_ORANGE, str);

    
    // Se era o host, transferir ou fechar
    if(RoomData[roomid][ROOM_HOST] == playerid && roomid != FUN_ROOM_ID)
    {
        TransferHost(roomid);
    }
    
    // Verificar se a sala deve ser fechada
    if(RoomData[roomid][ROOM_PLAYER_COUNT] <= 0 && roomid != FUN_ROOM_ID)
    {
        DestroyRoom(roomid);
    }
    else if(RoomData[roomid][ROOM_STATE] == ROOM_STATE_RUNNING)
    {
        CheckRoomWinner(roomid);
    }
    
    // Teleportar jogador para posicao neutra
    SetPlayerPos(playerid, 0.0, 0.0, 5.0);
    SetPlayerVirtualWorld(playerid, 0);
    
    return 1;
}

// =============================================================================
// TRANSFERIR HOST
// =============================================================================

stock TransferHost(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(roomid == FUN_ROOM_ID) return 0;
    
    new newhost = INVALID_PLAYER;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerData[i][PL_ROOM_ID] == roomid && i != RoomData[roomid][ROOM_HOST])
        {
            newhost = i;
            break;
        }
    }
    
    if(newhost == INVALID_PLAYER)
    {
        // Ninguem para ser host
        RoomData[roomid][ROOM_HOST] = INVALID_PLAYER;
        return 0;
    }
    
    RoomData[roomid][ROOM_HOST] = newhost;
    
    new str[128];
    format(str, sizeof(str), "{00FFFF}| DERBY | %s agora e o Host da sala!", PlayerData[newhost][PL_NAME]);
    SendRoomMessage(roomid, COLOR_CYAN, str);
    return 1;
}


// =============================================================================
// INICIAR PARTIDA NA SALA
// =============================================================================

stock StartRoomMatch(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_LOBBY) return 0;
    
    new mapid = GetNextMapForRoom(roomid);
    if(mapid < 0 || mapid >= TotalMaps)
    {
        SendRoomMessage(roomid, COLOR_RED, "[ERRO] Nenhum mapa valido selecionado!");
        return 0;
    }
    
    RoomData[roomid][ROOM_STATE] = ROOM_STATE_COUNTDOWN;
    RoomData[roomid][ROOM_COUNTDOWN_VALUE] = DERBY_COUNTDOWN_SECONDS;
    RoomData[roomid][ROOM_CURRENT_ROUND]++;
    
    // Spawn todos os jogadores da sala no mapa
    SpawnRoomPlayers(roomid, mapid);
    
    // Iniciar countdown
    RoomData[roomid][ROOM_COUNTDOWN_TIMER] = SetTimerEx("RoomCountdown", 1000, true, "d", roomid);
    
    new str[128];
    format(str, sizeof(str), "{FFFF00}| DERBY | Round %d/%d | Mapa: %s | Iniciando em %ds...",
        RoomData[roomid][ROOM_CURRENT_ROUND], RoomData[roomid][ROOM_TOTAL_ROUNDS],
        MapPool[mapid][MAP_NAME], DERBY_COUNTDOWN_SECONDS);
    SendRoomMessage(roomid, COLOR_YELLOW, str);
    
    return 1;
}

// =============================================================================
// SPAWN JOGADORES NO MAPA
// =============================================================================

stock SpawnRoomPlayers(roomid, mapid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(mapid < 0 || mapid >= TotalMaps) return 0;
    
    new vehiclemodel = GetRoomVehicleModel(roomid, mapid);
    new slot = 0;
    
    // Reset slots
    for(new i = 0; i < MAX_ROOM_PLAYERS; i++)
        RoomSlotUsed[roomid][i] = false;
    
    RoomData[roomid][ROOM_ALIVE_COUNT] = 0;
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        if(slot >= MapPool[mapid][MAP_SPAWNS]) break;
        
        // Parar spectate se necessario
        if(GetPlayerState(i) == 9)
            TogglePlayerSpectating(i, false);
        
        PlayerData[i][PL_STATE] = PL_ST_ALIVE;
        PlayerData[i][PL_SPAWN_SLOT] = slot;
        RoomSlotUsed[roomid][slot] = true;
        
        SetPlayerVirtualWorld(i, GetRoomVirtualWorld(roomid));
        SetPlayerHealth(i, 100.0);
        SetPlayerArmour(i, 0.0);
        ResetPlayerWeapons(i);

        
        // Criar veiculo
        if(PlayerData[i][PL_VEHICLE_ID] != INVALID_VEHICLE_ID)
        {
            DestroyVehicleSafe(PlayerData[i][PL_VEHICLE_ID]);
            PlayerData[i][PL_VEHICLE_ID] = INVALID_VEHICLE_ID;
        }
        
        new vid = CreateVehicle(vehiclemodel,
            MapPool[mapid][MAP_SPAWN_X][slot],
            MapPool[mapid][MAP_SPAWN_Y][slot],
            MapPool[mapid][MAP_SPAWN_Z][slot] + 2.0,
            MapPool[mapid][MAP_SPAWN_A][slot],
            RandomEx(1, 255), RandomEx(1, 255), 99999, false);
        
        SetVehicleVirtualWorld(vid, GetRoomVirtualWorld(roomid));
        PutPlayerInVehicle(i, vid, 0);
        PlayerData[i][PL_VEHICLE_ID] = vid;
        
        // Motor desligado durante countdown
        SetVehicleParamsEx(vid, 0, 0, 0, 1, 0, 0, 0);
        
        // Tempo e clima do mapa
        SetPlayerTime(i, MapPool[mapid][MAP_HOUR], 0);
        SetPlayerWeather(i, MapPool[mapid][MAP_WEATHER]);
        
        // Reset nitro
        PlayerData[i][PL_NITRO_FUEL] = 100.0;
        PlayerData[i][PL_NITRO_ACTIVE] = false;
        PlayerData[i][PL_AFK_SECONDS] = 0;
        
        // Mostrar HUD
        ShowRoomHUD(i, roomid);
        
        RoomData[roomid][ROOM_ALIVE_COUNT]++;
        slot++;
    }
    
    return 1;
}

// =============================================================================
// COUNTDOWN CALLBACK
// =============================================================================

public RoomCountdown(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_COUNTDOWN)
    {
        KillTimer(RoomData[roomid][ROOM_COUNTDOWN_TIMER]);
        RoomData[roomid][ROOM_COUNTDOWN_TIMER] = -1;
        return 0;
    }
    
    RoomData[roomid][ROOM_COUNTDOWN_VALUE]--;
    
    if(RoomData[roomid][ROOM_COUNTDOWN_VALUE] <= 0)
    {
        // INICIAR PARTIDA
        KillTimer(RoomData[roomid][ROOM_COUNTDOWN_TIMER]);
        RoomData[roomid][ROOM_COUNTDOWN_TIMER] = -1;
        
        RoomData[roomid][ROOM_STATE] = ROOM_STATE_RUNNING;
        RoomData[roomid][ROOM_TICK_START] = gettime();
        RoomData[roomid][ROOM_TIMEOUT_VALUE] = DERBY_TIMEOUT_SECONDS;
        RoomData[roomid][ROOM_TIMEOUT_TIMER] = SetTimerEx("RoomTimeout", 1000, true, "d", roomid);

        
        // Ligar motores e liberar jogadores
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(!IsPlayerConnected(i)) continue;
            if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
            if(PlayerData[i][PL_STATE] != PL_ST_ALIVE) continue;
            
            // Ligar motor
            SetVehicleParamsEx(PlayerData[i][PL_VEHICLE_ID], 1, 1, 0, 0, 0, 0, 0);
            PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
            GameTextForPlayer(i, "~g~GO! ~r~GO! ~w~GO!", 2000, 3);
        }
        
        SendRoomMessage(roomid, COLOR_GREEN, "{00FF00}| DERBY | Partida iniciada! GO GO GO!");
        return 1;
    }
    
    // Mostrar countdown para jogadores
    new str[64];
    format(str, sizeof(str), "~w~%d", RoomData[roomid][ROOM_COUNTDOWN_VALUE]);
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        if(PlayerData[i][PL_STATE] != PL_ST_ALIVE) continue;
        
        GameTextForPlayer(i, str, 1100, 3);
        PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
    }
    
    return 1;
}

// =============================================================================
// TIMEOUT CALLBACK
// =============================================================================

public RoomTimeout(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_RUNNING)
    {
        KillTimer(RoomData[roomid][ROOM_TIMEOUT_TIMER]);
        RoomData[roomid][ROOM_TIMEOUT_TIMER] = -1;
        return 0;
    }
    
    RoomData[roomid][ROOM_TIMEOUT_VALUE]--;
    
    // Atualizar HUD timer
    UpdateRoomTimerHUD(roomid);
    
    if(RoomData[roomid][ROOM_TIMEOUT_VALUE] <= 0)
    {
        // Tempo esgotado
        KillTimer(RoomData[roomid][ROOM_TIMEOUT_TIMER]);
        RoomData[roomid][ROOM_TIMEOUT_TIMER] = -1;
        
        SendRoomMessage(roomid, COLOR_YELLOW, "{FFFF00}| DERBY | Tempo esgotado! Empate.");
        EndRound(roomid, NO_WINNER);
        return 1;
    }
    
    return 1;
}


// =============================================================================
// ELIMINACAO DE JOGADOR
// =============================================================================

stock PlayerEliminated(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID) return 0;
    if(PlayerData[playerid][PL_STATE] != PL_ST_ALIVE) return 0;
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_RUNNING) return 0;
    
    PlayerData[playerid][PL_STATE] = PL_ST_DEAD;
    RoomData[roomid][ROOM_ALIVE_COUNT]--;
    
    // Destruir veiculo
    if(PlayerData[playerid][PL_VEHICLE_ID] != INVALID_VEHICLE_ID)
    {
        DestroyVehicleSafe(PlayerData[playerid][PL_VEHICLE_ID]);
        PlayerData[playerid][PL_VEHICLE_ID] = INVALID_VEHICLE_ID;
    }
    
    // Desativar nitro
    PlayerData[playerid][PL_NITRO_ACTIVE] = false;
    
    // Mostrar posicao
    new str[128];
    format(str, sizeof(str), "~r~Eliminado!~n~~w~Posicao: %d/%d",
        RoomData[roomid][ROOM_ALIVE_COUNT] + 1, RoomData[roomid][ROOM_PLAYER_COUNT]);
    GameTextForPlayer(playerid, str, 3000, 3);
    
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    
    // Mensagem para a sala
    format(str, sizeof(str), "{FF0000}| DERBY | %s foi eliminado! (%d restantes)",
        PlayerData[playerid][PL_NAME], RoomData[roomid][ROOM_ALIVE_COUNT]);
    SendRoomMessage(roomid, COLOR_RED, str);
    
    // Colocar em spectate
    PlayerData[playerid][PL_STATE] = PL_ST_SPECTATING;
    StartSpectating(playerid, roomid);
    
    // Verificar vencedor
    CheckRoomWinner(roomid);
    
    return 1;
}

// =============================================================================
// VERIFICAR VENCEDOR
// =============================================================================

stock CheckRoomWinner(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_RUNNING) return 0;
    
    new alive = GetRoomAliveCount(roomid);
    RoomData[roomid][ROOM_ALIVE_COUNT] = alive;
    
    if(alive <= 1)
    {
        // Encontrar o vencedor
        new winner = NO_WINNER;
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && PlayerData[i][PL_ROOM_ID] == roomid
                && PlayerData[i][PL_STATE] == PL_ST_ALIVE)
            {
                winner = i;
                break;
            }
        }
        
        EndRound(roomid, winner);
    }
    return 1;
}


// =============================================================================
// FIM DE ROUND
// =============================================================================

stock EndRound(roomid, winner)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    KillTimer(RoomData[roomid][ROOM_TIMEOUT_TIMER]);
    RoomData[roomid][ROOM_TIMEOUT_TIMER] = -1;
    
    RoomData[roomid][ROOM_STATE] = ROOM_STATE_ROUND_END;
    RoomData[roomid][ROOM_WINNER] = winner;
    
    new str[128];
    
    if(winner != NO_WINNER)
    {
        // Atualizar placar CLA VS CLA
        if(RoomData[roomid][ROOM_MODE] == MODE_CLA_VS_CLA)
        {
            if(PlayerData[winner][PL_TEAM] == TEAM_ALPHA)
                RoomData[roomid][ROOM_SCORE_ALPHA]++;
            else if(PlayerData[winner][PL_TEAM] == TEAM_BETA)
                RoomData[roomid][ROOM_SCORE_BETA]++;
        }
        
        format(str, sizeof(str), "{00FF00}| DERBY | %s venceu o round %d!",
            PlayerData[winner][PL_NAME], RoomData[roomid][ROOM_CURRENT_ROUND]);
        SendRoomMessage(roomid, COLOR_GREEN, str);
        
        // Score
        PlayerData[winner][PL_WINS]++;
        PlayerData[winner][PL_SCORE] += RoomData[roomid][ROOM_PLAYER_COUNT];
        SetPlayerScore(winner, PlayerData[winner][PL_SCORE]);
        
        GameTextForPlayer(winner, "~g~VENCEDOR!", 3000, 3);
        PlayerPlaySound(winner, 1057, 0.0, 0.0, 0.0);
    }
    else
    {
        SendRoomMessage(roomid, COLOR_YELLOW, "{FFFF00}| DERBY | Round sem vencedor!");
    }
    
    // Verificar se a partida acabou
    if(RoomData[roomid][ROOM_CURRENT_ROUND] >= RoomData[roomid][ROOM_TOTAL_ROUNDS])
    {
        // Partida finalizada
        EndMatch(roomid);
        return 1;
    }
    
    // Proximo round em 5 segundos
    RoomData[roomid][ROOM_TRANSITION_TIMER] = SetTimerEx("RoomTransition", 5000, false, "d", roomid);
    return 1;
}

// =============================================================================
// FIM DA PARTIDA COMPLETA
// =============================================================================

stock EndMatch(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    RoomData[roomid][ROOM_STATE] = ROOM_STATE_FINISHED;
    
    new str[128];
    
    if(RoomData[roomid][ROOM_MODE] == MODE_CLA_VS_CLA)
    {
        if(RoomData[roomid][ROOM_SCORE_ALPHA] > RoomData[roomid][ROOM_SCORE_BETA])
            format(str, sizeof(str), "{00FF00}| DERBY | ALPHA venceu! Placar: %d x %d",
                RoomData[roomid][ROOM_SCORE_ALPHA], RoomData[roomid][ROOM_SCORE_BETA]);
        else if(RoomData[roomid][ROOM_SCORE_BETA] > RoomData[roomid][ROOM_SCORE_ALPHA])
            format(str, sizeof(str), "{0080FF}| DERBY | BETA venceu! Placar: %d x %d",
                RoomData[roomid][ROOM_SCORE_ALPHA], RoomData[roomid][ROOM_SCORE_BETA]);
        else
            format(str, sizeof(str), "{FFFF00}| DERBY | Empate! Placar: %d x %d",
                RoomData[roomid][ROOM_SCORE_ALPHA], RoomData[roomid][ROOM_SCORE_BETA]);
    }
    else
    {
        format(str, sizeof(str), "{00FF00}| DERBY | Partida finalizada! Rounds: %d",
            RoomData[roomid][ROOM_CURRENT_ROUND]);
    }
    
    SendRoomMessage(roomid, COLOR_GREEN, str);

    
    // Para modo FUN, reiniciar automaticamente
    if(roomid == FUN_ROOM_ID)
    {
        RoomData[roomid][ROOM_CURRENT_ROUND] = 0;
        RoomData[roomid][ROOM_TRANSITION_TIMER] = SetTimerEx("RoomTransition", 5000, false, "d", roomid);
        return 1;
    }
    
    // Para salas privadas, voltar ao lobby em 10 segundos
    RoomData[roomid][ROOM_TRANSITION_TIMER] = SetTimerEx("RoomTransition", 10000, false, "d", roomid);
    return 1;
}

// =============================================================================
// TRANSICAO (Proximo round ou voltar ao lobby)
// =============================================================================

public RoomTransition(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    RoomData[roomid][ROOM_TRANSITION_TIMER] = -1;
    
    // Destruir veiculos restantes
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        
        if(PlayerData[i][PL_VEHICLE_ID] != INVALID_VEHICLE_ID)
        {
            DestroyVehicleSafe(PlayerData[i][PL_VEHICLE_ID]);
            PlayerData[i][PL_VEHICLE_ID] = INVALID_VEHICLE_ID;
        }
        
        if(GetPlayerState(i) == 9) // spectating
            TogglePlayerSpectating(i, false);
        
        PlayerData[i][PL_STATE] = PL_ST_LOBBY;
    }
    
    if(RoomData[roomid][ROOM_STATE] == ROOM_STATE_FINISHED && roomid != FUN_ROOM_ID)
    {
        // Voltar ao lobby
        RoomData[roomid][ROOM_STATE] = ROOM_STATE_LOBBY;
        RoomData[roomid][ROOM_CURRENT_ROUND] = 0;
        RoomData[roomid][ROOM_SCORE_ALPHA] = 0;
        RoomData[roomid][ROOM_SCORE_BETA] = 0;
        SendRoomMessage(roomid, COLOR_CYAN, "{00FFFF}| DERBY | Sala voltou ao lobby. Host pode iniciar nova partida.");
    }
    else
    {
        // Proximo round
        RoomData[roomid][ROOM_STATE] = ROOM_STATE_LOBBY;
        
        if(RoomData[roomid][ROOM_PLAYER_COUNT] >= 2 || roomid == FUN_ROOM_ID)
        {
            StartRoomMatch(roomid);
        }
        else
        {
            SendRoomMessage(roomid, COLOR_YELLOW, "{FFFF00}| DERBY | Aguardando mais jogadores...");
        }
    }
    
    return 1;
}


// =============================================================================
// SPECTATE
// =============================================================================

stock StartSpectating(playerid, roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    new target = INVALID_PLAYER;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerData[i][PL_ROOM_ID] == roomid
            && PlayerData[i][PL_STATE] == PL_ST_ALIVE && i != playerid)
        {
            target = i;
            break;
        }
    }
    
    if(target == INVALID_PLAYER) return 0;
    
    PlayerData[playerid][PL_SPECTATE_TARGET] = target;
    TogglePlayerSpectating(playerid, true);
    
    if(PlayerData[target][PL_VEHICLE_ID] != INVALID_VEHICLE_ID)
        PlayerSpectateVehicle(playerid, PlayerData[target][PL_VEHICLE_ID]);
    else
        PlayerSpectatePlayer(playerid, target);
    
    SCM(playerid, COLOR_WHITE, "{FFFFFF}Pressione {00FF00}ENTER{FFFFFF} para trocar de jogador.");
    return 1;
}

stock NextSpectateTarget(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID) return 0;
    
    new current = PlayerData[playerid][PL_SPECTATE_TARGET];
    new found = INVALID_PLAYER;
    new first = INVALID_PLAYER;
    new pastcurrent = false;
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        if(PlayerData[i][PL_STATE] != PL_ST_ALIVE) continue;
        if(i == playerid) continue;
        
        if(first == INVALID_PLAYER) first = i;
        
        if(i == current) { pastcurrent = true; continue; }
        
        if(pastcurrent)
        {
            found = i;
            break;
        }
    }
    
    if(found == INVALID_PLAYER) found = first;
    if(found == INVALID_PLAYER || found == current) return 0;
    
    PlayerData[playerid][PL_SPECTATE_TARGET] = found;
    
    if(PlayerData[found][PL_VEHICLE_ID] != INVALID_VEHICLE_ID)
        PlayerSpectateVehicle(playerid, PlayerData[found][PL_VEHICLE_ID]);
    else
        PlayerSpectatePlayer(playerid, found);
    
    return 1;
}

// =============================================================================
// RESPAWN (TREINAMENTO)
// =============================================================================

stock RespawnPlayerTraining(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID) return 0;
    if(RoomData[roomid][ROOM_MODE] != MODE_TRAINING) return 0;
    
    new mapid = GetCurrentMapID(roomid);
    if(mapid < 0 || mapid >= TotalMaps) return 0;
    
    new slot = PlayerData[playerid][PL_SPAWN_SLOT];
    if(slot < 0 || slot >= MapPool[mapid][MAP_SPAWNS])
        slot = random(MapPool[mapid][MAP_SPAWNS]);
    
    new vehiclemodel = GetRoomVehicleModel(roomid, mapid);
    
    // Destruir veiculo antigo
    if(PlayerData[playerid][PL_VEHICLE_ID] != INVALID_VEHICLE_ID)
    {
        DestroyVehicleSafe(PlayerData[playerid][PL_VEHICLE_ID]);
        PlayerData[playerid][PL_VEHICLE_ID] = INVALID_VEHICLE_ID;
    }

    
    // Criar novo veiculo
    new vid = CreateVehicle(vehiclemodel,
        MapPool[mapid][MAP_SPAWN_X][slot],
        MapPool[mapid][MAP_SPAWN_Y][slot],
        MapPool[mapid][MAP_SPAWN_Z][slot] + 2.0,
        MapPool[mapid][MAP_SPAWN_A][slot],
        RandomEx(1, 255), RandomEx(1, 255), 99999, false);
    
    SetVehicleVirtualWorld(vid, GetRoomVirtualWorld(roomid));
    PutPlayerInVehicle(playerid, vid, 0);
    PlayerData[playerid][PL_VEHICLE_ID] = vid;
    PlayerData[playerid][PL_STATE] = PL_ST_ALIVE;
    PlayerData[playerid][PL_NITRO_FUEL] = 100.0;
    PlayerData[playerid][PL_NITRO_ACTIVE] = false;
    
    SetVehicleParamsEx(vid, 1, 1, 0, 0, 0, 0, 0);
    
    GameTextForPlayer(playerid, "~g~Respawn!", 1500, 3);
    return 1;
}
