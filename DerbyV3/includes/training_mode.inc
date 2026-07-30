/*
    DERBY V3 - TRAINING MODE
    
    Modo treinamento:
    - Respawn automatico ao cair
    - Sem pontuacao competitiva
    - Mesmo veiculo escolhido
    - Mesmo mapa escolhido
    - Entrada e saida livre
*/

#if defined _training_mode_included
    #endinput
#endif
#define _training_mode_included

// =============================================================================
// ELIMINACAO NO TREINAMENTO (Respawn em vez de morte)
// =============================================================================

stock TrainingModeElimination(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID) return 0;
    if(RoomData[roomid][ROOM_MODE] != MODE_TRAINING) return 0;
    
    // Apenas respawnar
    GameTextForPlayer(playerid, "~y~Respawnando...", 1500, 3);
    
    // Timer curto para respawn (1 segundo)
    SetTimerEx("TrainingRespawn", 1000, false, "d", playerid);
    
    return 1;
}

forward TrainingRespawn(playerid);
public TrainingRespawn(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(PlayerData[playerid][PL_ROOM_ID] == INVALID_ROOM_ID) return 0;
    if(RoomData[PlayerData[playerid][PL_ROOM_ID]][ROOM_MODE] != MODE_TRAINING) return 0;
    
    RespawnPlayerTraining(playerid);
    return 1;
}
