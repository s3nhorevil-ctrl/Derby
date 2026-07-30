/*
    DERBY V3 - CLA VS CLA MODE
    
    Modo competitivo:
    - Sistema de rounds
    - Placar por time
    - Times (ALPHA / BETA)
    - Vitoria por rounds ganhos
    - HUD competitivo
    - Spectator entre rounds
    - Reinicio automatico entre rounds
*/

#if defined _cla_mode_included
    #endinput
#endif
#define _cla_mode_included

// =============================================================================
// DISTRIBUIR TIMES
// =============================================================================

stock DistributeTeams(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    if(RoomData[roomid][ROOM_MODE] != MODE_CLA_VS_CLA) return 0;
    
    new count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        
        if(count % 2 == 0)
            PlayerData[i][PL_TEAM] = TEAM_ALPHA;
        else
            PlayerData[i][PL_TEAM] = TEAM_BETA;
        
        count++;
    }
    
    // Notificar times
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        
        if(PlayerData[i][PL_TEAM] == TEAM_ALPHA)
            SCM(i, 0xFF4444FF, "{FF4444}| DERBY | Voce esta no Time ALPHA!");
        else
            SCM(i, 0x4444FFFF, "{4444FF}| DERBY | Voce esta no Time BETA!");
    }
    
    return 1;
}


// =============================================================================
// VERIFICAR VENCEDOR DO ROUND (CLA VS CLA)
// =============================================================================

stock CheckClaRoundWinner(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return TEAM_NONE;
    if(RoomData[roomid][ROOM_MODE] != MODE_CLA_VS_CLA) return TEAM_NONE;
    
    new alpha_alive = 0, beta_alive = 0;
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        if(PlayerData[i][PL_STATE] != PL_ST_ALIVE) continue;
        
        if(PlayerData[i][PL_TEAM] == TEAM_ALPHA) alpha_alive++;
        else if(PlayerData[i][PL_TEAM] == TEAM_BETA) beta_alive++;
    }
    
    if(alpha_alive == 0 && beta_alive > 0) return TEAM_BETA;
    if(beta_alive == 0 && alpha_alive > 0) return TEAM_ALPHA;
    
    return TEAM_NONE; // Ambos ainda tem jogadores
}

// =============================================================================
// ELIMINACAO CLA VS CLA
// =============================================================================

stock ClaModeElimination(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID) return 0;
    if(RoomData[roomid][ROOM_MODE] != MODE_CLA_VS_CLA) return 0;
    
    new teamname[8];
    if(PlayerData[playerid][PL_TEAM] == TEAM_ALPHA)
        teamname = "ALPHA";
    else
        teamname = "BETA";
    
    new str[128];
    format(str, sizeof(str), "{FF0000}| DERBY | %s [%s] foi eliminado!",
        PlayerData[playerid][PL_NAME], teamname);
    SendRoomMessage(roomid, COLOR_RED, str);
    
    // Eliminar normalmente
    PlayerEliminated(playerid);
    
    // Verificar se um time inteiro foi eliminado
    new winning_team = CheckClaRoundWinner(roomid);
    if(winning_team != TEAM_NONE)
    {
        if(winning_team == TEAM_ALPHA)
        {
            RoomData[roomid][ROOM_SCORE_ALPHA]++;
            SendRoomMessage(roomid, 0xFF4444FF, "{FF4444}| DERBY | Time ALPHA venceu o round!");
        }
        else
        {
            RoomData[roomid][ROOM_SCORE_BETA]++;
            SendRoomMessage(roomid, 0x4444FFFF, "{4444FF}| DERBY | Time BETA venceu o round!");
        }
        
        // Mostrar placar
        format(str, sizeof(str), "{FFFFFF}Placar: {FF4444}ALPHA %d{FFFFFF} x {4444FF}%d BETA",
            RoomData[roomid][ROOM_SCORE_ALPHA], RoomData[roomid][ROOM_SCORE_BETA]);
        SendRoomMessage(roomid, COLOR_WHITE, str);
    }
    
    return 1;
}

// =============================================================================
// VERIFICAR VENCEDOR DA PARTIDA (CLA VS CLA)
// =============================================================================

stock GetClaMatchWinner(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return TEAM_NONE;
    
    new needed = (RoomData[roomid][ROOM_TOTAL_ROUNDS] / 2) + 1;
    
    if(RoomData[roomid][ROOM_SCORE_ALPHA] >= needed) return TEAM_ALPHA;
    if(RoomData[roomid][ROOM_SCORE_BETA] >= needed) return TEAM_BETA;
    
    return TEAM_NONE;
}
