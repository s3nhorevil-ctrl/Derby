/*
    DERBY V3 - ROOM DATA
    
    Funcoes de inicializacao, reset e consulta de dados das salas.
    Gerencia a estrutura de dados de cada sala.
*/

#if defined _room_data_included
    #endinput
#endif
#define _room_data_included

// =============================================================================
// INICIALIZACAO
// =============================================================================

stock InitAllRooms()
{
    for(new i = 0; i < MAX_ROOMS; i++)
    {
        ResetRoomData(i);
    }
    
    // Sala FUN sempre ativa
    InitFunRoom();
}

stock ResetRoomData(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    RoomData[roomid][ROOM_ID] = roomid;
    RoomData[roomid][ROOM_NAME] = '\0';
    RoomData[roomid][ROOM_HOST] = INVALID_PLAYER;
    RoomData[roomid][ROOM_MODE] = MODE_FUN;
    RoomData[roomid][ROOM_STATE] = ROOM_STATE_EMPTY;
    RoomData[roomid][ROOM_PASSWORD] = '\0';
    RoomData[roomid][ROOM_MAX_PLAYERS] = MAX_ROOM_PLAYERS;
    RoomData[roomid][ROOM_PRIVATE] = false;
    
    RoomData[roomid][ROOM_VEHICLE] = 495;
    RoomData[roomid][ROOM_TOTAL_ROUNDS] = 1;
    RoomData[roomid][ROOM_CURRENT_ROUND] = 0;
    RoomData[roomid][ROOM_MAP_COUNT] = 0;
    RoomData[roomid][ROOM_CURRENT_MAP_INDEX] = 0;
    
    RoomData[roomid][ROOM_PLAYER_COUNT] = 0;
    RoomData[roomid][ROOM_ALIVE_COUNT] = 0;
    RoomData[roomid][ROOM_WINNER] = NO_WINNER;
    
    RoomData[roomid][ROOM_SCORE_ALPHA] = 0;
    RoomData[roomid][ROOM_SCORE_BETA] = 0;
    
    RoomData[roomid][ROOM_COUNTDOWN_VALUE] = 0;
    RoomData[roomid][ROOM_COUNTDOWN_TIMER] = -1;
    RoomData[roomid][ROOM_TIMEOUT_VALUE] = 0;
    RoomData[roomid][ROOM_TIMEOUT_TIMER] = -1;
    RoomData[roomid][ROOM_TRANSITION_TIMER] = -1;
    
    RoomData[roomid][ROOM_TICK_START] = 0;
    
    for(new i = 0; i < MAX_ROOM_MAPS; i++)
        RoomData[roomid][ROOM_SELECTED_MAPS][i] = -1;
    
    for(new i = 0; i < MAX_ROOM_PLAYERS; i++)
        RoomSlotUsed[roomid][i] = false;
    
    return 1;
}

stock InitFunRoom()
{
    RoomData[FUN_ROOM_ID][ROOM_ID] = FUN_ROOM_ID;
    format(RoomData[FUN_ROOM_ID][ROOM_NAME], 32, "FUN Publica");
    RoomData[FUN_ROOM_ID][ROOM_HOST] = INVALID_PLAYER;
    RoomData[FUN_ROOM_ID][ROOM_MODE] = MODE_FUN;
    RoomData[FUN_ROOM_ID][ROOM_STATE] = ROOM_STATE_LOBBY;
    RoomData[FUN_ROOM_ID][ROOM_MAX_PLAYERS] = MAX_ROOM_PLAYERS;
    RoomData[FUN_ROOM_ID][ROOM_PRIVATE] = false;
    RoomData[FUN_ROOM_ID][ROOM_TOTAL_ROUNDS] = 999;
    RoomData[FUN_ROOM_ID][ROOM_VEHICLE] = 0; // 0 = definido pelo mapa
    
    // Selecionar todos os mapas para FUN
    RoomData[FUN_ROOM_ID][ROOM_MAP_COUNT] = TotalMaps;
    for(new i = 0; i < TotalMaps && i < MAX_ROOM_MAPS; i++)
    {
        RoomData[FUN_ROOM_ID][ROOM_SELECTED_MAPS][i] = i;
    }
}

// =============================================================================
// CONSULTAS
// =============================================================================

stock GetFreeRoomSlot()
{
    // Slot 0 e reservado para FUN
    for(new i = 1; i < MAX_ROOMS; i++)
    {
        if(RoomData[i][ROOM_STATE] == ROOM_STATE_EMPTY)
            return i;
    }
    return INVALID_ROOM_ID;
}

stock GetFreeSpawnSlot(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return -1;
    for(new i = 0; i < MAX_ROOM_PLAYERS; i++)
    {
        if(!RoomSlotUsed[roomid][i])
            return i;
    }
    return -1;
}

stock GetRoomPlayerCount(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    return RoomData[roomid][ROOM_PLAYER_COUNT];
}

stock GetRoomAliveCount(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    new count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerData[i][PL_ROOM_ID] == roomid && PlayerData[i][PL_STATE] == PLAYER_STATE_ALIVE)
            count++;
    }
    return count;
}

stock GetCurrentMapID(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    new idx = RoomData[roomid][ROOM_CURRENT_MAP_INDEX];
    if(idx < 0 || idx >= RoomData[roomid][ROOM_MAP_COUNT]) return 0;
    return RoomData[roomid][ROOM_SELECTED_MAPS][idx];
}

stock GetNextMapForRoom(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    new count = RoomData[roomid][ROOM_MAP_COUNT];
    if(count <= 0) return 0;
    
    if(RoomData[roomid][ROOM_MODE] == MODE_FUN)
    {
        // Modo FUN: aleatorio
        return RoomData[roomid][ROOM_SELECTED_MAPS][random(count)];
    }
    else
    {
        // Outros modos: sequencial com loop
        RoomData[roomid][ROOM_CURRENT_MAP_INDEX]++;
        if(RoomData[roomid][ROOM_CURRENT_MAP_INDEX] >= count)
            RoomData[roomid][ROOM_CURRENT_MAP_INDEX] = 0;
        return RoomData[roomid][ROOM_SELECTED_MAPS][RoomData[roomid][ROOM_CURRENT_MAP_INDEX]];
    }
}

stock IsRoomFull(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 1;
    return (RoomData[roomid][ROOM_PLAYER_COUNT] >= RoomData[roomid][ROOM_MAX_PLAYERS]);
}

stock IsRoomActive(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    return (RoomData[roomid][ROOM_STATE] != ROOM_STATE_EMPTY);
}

stock GetRoomVehicleModel(roomid, mapid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 411;
    
    // Se a sala tem veiculo fixo, usar ele
    if(RoomData[roomid][ROOM_VEHICLE] > 0)
        return RoomData[roomid][ROOM_VEHICLE];
    
    // Caso contrario, usar o veiculo do mapa
    if(mapid >= 0 && mapid < TotalMaps)
        return MapPool[mapid][MAP_VEHICLE];
    
    return 411;
}

// =============================================================================
// TIMERS CLEANUP
// =============================================================================

stock KillRoomTimers(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    if(RoomData[roomid][ROOM_COUNTDOWN_TIMER] != -1)
    {
        KillTimer(RoomData[roomid][ROOM_COUNTDOWN_TIMER]);
        RoomData[roomid][ROOM_COUNTDOWN_TIMER] = -1;
    }
    if(RoomData[roomid][ROOM_TIMEOUT_TIMER] != -1)
    {
        KillTimer(RoomData[roomid][ROOM_TIMEOUT_TIMER]);
        RoomData[roomid][ROOM_TIMEOUT_TIMER] = -1;
    }
    if(RoomData[roomid][ROOM_TRANSITION_TIMER] != -1)
    {
        KillTimer(RoomData[roomid][ROOM_TRANSITION_TIMER]);
        RoomData[roomid][ROOM_TRANSITION_TIMER] = -1;
    }
    return 1;
}
