/*
    DERBY V3 - FUN MODE
    
    Modo publico com rotacao automatica de mapas.
    Caracteristicas:
    - Entrada rapida
    - Rotacao automatica de mapas (aleatorio)
    - Sistema de pontuacao
    - HUD completo
    - Spectator
    - Countdown
    - Eliminacao por queda
    - Vitoria automatica (ultimo sobrevivente)
    - Anti-AFK
*/

#if defined _fun_mode_included
    #endinput
#endif
#define _fun_mode_included

// =============================================================================
// FRASES COMICAS DE ELIMINACAO
// =============================================================================

new const FunPhrases[][] = {
    "foi passear nas nuvens!",
    "esqueceu o paraquedas!",
    "foi dar um mergulho!",
    "quicou pra fora!",
    "nao aguentou a pressao!",
    "foi lancado como foguete!",
    "derrapou pra eternidade!",
    "caiu feito batata quente!",
    "voou mais alto que aviao!",
    "escapou pela tangente... errada!",
    "foi pra outra dimensao!",
    "deu um rasante no chao!",
    "perdeu o controle total!",
    "saiu pela porta dos fundos!",
    "rodou no estilo beyblade!"
};

#define TOTAL_FUN_PHRASES (sizeof(FunPhrases))

// =============================================================================
// ELIMINACAO NO MODO FUN
// =============================================================================

stock FunModeElimination(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid != FUN_ROOM_ID) return 0;
    
    // Frase comica aleatoria
    new phrase = random(TOTAL_FUN_PHRASES);
    new str[128];
    format(str, sizeof(str), "{FF6600}| DERBY | %s %s (%d restantes)",
        PlayerData[playerid][PL_NAME], FunPhrases[phrase],
        RoomData[FUN_ROOM_ID][ROOM_ALIVE_COUNT] - 1);
    SendRoomMessage(FUN_ROOM_ID, COLOR_ORANGE, str);
    
    // Pontuacao baseada na posicao
    new score = RoomData[FUN_ROOM_ID][ROOM_PLAYER_COUNT] - RoomData[FUN_ROOM_ID][ROOM_ALIVE_COUNT] + 1;
    PlayerData[playerid][PL_SCORE] += score;
    SetPlayerScore(playerid, PlayerData[playerid][PL_SCORE]);
    
    // Eliminar
    PlayerEliminated(playerid);
    
    return 1;
}


// =============================================================================
// ANTI-AFK (MODO FUN)
// =============================================================================

public AntiAFKCheck()
{
    // Verifica apenas na sala FUN e em salas RUNNING
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] == INVALID_ROOM_ID) continue;
        if(PlayerData[i][PL_STATE] != PLAYER_STATE_ALIVE) continue;
        
        new roomid = PlayerData[i][PL_ROOM_ID];
        if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_RUNNING) continue;
        if(RoomData[roomid][ROOM_PLAYER_COUNT] <= 1) continue;
        
        // Calcular hash de posicao
        new Float:px, Float:py, Float:pz;
        if(PlayerData[i][PL_VEHICLE_ID] != INVALID_VEHICLE_ID)
            GetVehiclePos(PlayerData[i][PL_VEHICLE_ID], px, py, pz);
        else
            GetPlayerPos(i, px, py, pz);
        
        new Float:hash = px * py * pz / 3.0;
        
        if(PlayerData[i][PL_LAST_POS_HASH] == hash)
            PlayerData[i][PL_AFK_SECONDS]++;
        else
            PlayerData[i][PL_AFK_SECONDS] = 0;
        
        PlayerData[i][PL_LAST_POS_HASH] = hash;
        
        if(PlayerData[i][PL_AFK_SECONDS] >= AFK_WARNING_SECONDS && PlayerData[i][PL_AFK_SECONDS] < AFK_KICK_SECONDS)
        {
            GameTextForPlayer(i, "~r~Mexa-se ou sera removido!", 2000, 3);
        }
        
        if(PlayerData[i][PL_AFK_SECONDS] >= AFK_KICK_SECONDS)
        {
            SCM(i, COLOR_YELLOW, "{FFFF00}| DERBY | Voce foi removido por ficar parado!");
            PlayerEliminated(i);
            PlayerData[i][PL_AFK_SECONDS] = 0;
        }
    }
    return 1;
}

// =============================================================================
// AUTO-START FUN MODE (quando jogadores entram)
// =============================================================================

stock CheckFunRoomAutoStart()
{
    if(RoomData[FUN_ROOM_ID][ROOM_STATE] == ROOM_STATE_LOBBY)
    {
        if(RoomData[FUN_ROOM_ID][ROOM_PLAYER_COUNT] >= 2)
        {
            StartRoomMatch(FUN_ROOM_ID);
        }
    }
}
