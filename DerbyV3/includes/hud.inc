/*
    DERBY V3 - HUD SYSTEM
    
    TextDraws globais e per-player:
    - Timer (tempo restante)
    - Jogadores vivos / total
    - Nome do mapa
    - Round X/Y
    - Vehicle HP per-player (PlayerTextDraw)
    - Spectate info
    - Placar CLA VS CLA
*/

#if defined _hud_included
    #endinput
#endif
#define _hud_included

// =============================================================================
// TEXTDRAWS GLOBAIS
// =============================================================================

new Text:TD_Timer;
new Text:TD_MapName;
new Text:TD_PlayersAlive;
new Text:TD_PlayersTotal;
new Text:TD_RoundInfo;
new Text:TD_Message;
new Text:TD_SpectateInfo;
new Text:TD_ScoreAlpha;
new Text:TD_ScoreBeta;


// =============================================================================
// CRIACAO DOS TEXTDRAWS
// =============================================================================

stock CreateAllTextDraws()
{
    // Timer - canto superior direito
    TD_Timer = TextDrawCreate(548.0, 310.0, "3:00");
    TextDrawLetterSize(TD_Timer, 0.6, 2.8);
    TextDrawAlignment(TD_Timer, 1);
    TextDrawColor(TD_Timer, 0xFFFFFFFF);
    TextDrawSetShadow(TD_Timer, 1);
    TextDrawSetOutline(TD_Timer, 1);
    TextDrawBackgroundColor(TD_Timer, 0x000000AA);
    TextDrawFont(TD_Timer, 3);
    TextDrawSetProportional(TD_Timer, 1);
    
    // Nome do mapa - topo centro
    TD_MapName = TextDrawCreate(320.0, 5.0, "Mapa: ---");
    TextDrawLetterSize(TD_MapName, 0.35, 1.4);
    TextDrawAlignment(TD_MapName, 2);
    TextDrawColor(TD_MapName, 0xFFFF00FF);
    TextDrawSetShadow(TD_MapName, 1);
    TextDrawSetOutline(TD_MapName, 1);
    TextDrawFont(TD_MapName, 2);
    TextDrawSetProportional(TD_MapName, 1);
    
    // Jogadores Vivos
    TD_PlayersAlive = TextDrawCreate(548.0, 345.0, "Vivos: 0");
    TextDrawLetterSize(TD_PlayersAlive, 0.3, 1.4);
    TextDrawAlignment(TD_PlayersAlive, 1);
    TextDrawColor(TD_PlayersAlive, 0x00FF00FF);
    TextDrawSetShadow(TD_PlayersAlive, 1);
    TextDrawSetOutline(TD_PlayersAlive, 1);
    TextDrawFont(TD_PlayersAlive, 1);
    TextDrawSetProportional(TD_PlayersAlive, 1);
    
    // Total jogadores
    TD_PlayersTotal = TextDrawCreate(548.0, 360.0, "Total: 0");
    TextDrawLetterSize(TD_PlayersTotal, 0.3, 1.4);
    TextDrawAlignment(TD_PlayersTotal, 1);
    TextDrawColor(TD_PlayersTotal, 0xCCCCCCFF);
    TextDrawSetShadow(TD_PlayersTotal, 1);
    TextDrawSetOutline(TD_PlayersTotal, 1);
    TextDrawFont(TD_PlayersTotal, 1);
    TextDrawSetProportional(TD_PlayersTotal, 1);
    
    // Round info
    TD_RoundInfo = TextDrawCreate(548.0, 375.0, "Round: 1/1");
    TextDrawLetterSize(TD_RoundInfo, 0.3, 1.4);
    TextDrawAlignment(TD_RoundInfo, 1);
    TextDrawColor(TD_RoundInfo, 0xCCCCCCFF);
    TextDrawSetShadow(TD_RoundInfo, 1);
    TextDrawSetOutline(TD_RoundInfo, 1);
    TextDrawFont(TD_RoundInfo, 1);
    TextDrawSetProportional(TD_RoundInfo, 1);

    
    // Mensagem central (countdown, vencedor, etc)
    TD_Message = TextDrawCreate(320.0, 150.0, " ");
    TextDrawLetterSize(TD_Message, 0.45, 2.0);
    TextDrawAlignment(TD_Message, 2);
    TextDrawColor(TD_Message, 0xFFFFFFFF);
    TextDrawSetShadow(TD_Message, 0);
    TextDrawSetOutline(TD_Message, 1);
    TextDrawFont(TD_Message, 3);
    TextDrawSetProportional(TD_Message, 1);
    
    // Spectate info
    TD_SpectateInfo = TextDrawCreate(320.0, 420.0, "Pressione ~g~ENTER~w~ para trocar");
    TextDrawLetterSize(TD_SpectateInfo, 0.28, 1.2);
    TextDrawAlignment(TD_SpectateInfo, 2);
    TextDrawColor(TD_SpectateInfo, 0xFFFFFFFF);
    TextDrawSetShadow(TD_SpectateInfo, 0);
    TextDrawSetOutline(TD_SpectateInfo, 1);
    TextDrawFont(TD_SpectateInfo, 2);
    TextDrawSetProportional(TD_SpectateInfo, 1);
    
    // Placar Alpha
    TD_ScoreAlpha = TextDrawCreate(260.0, 25.0, "ALPHA: 0");
    TextDrawLetterSize(TD_ScoreAlpha, 0.35, 1.6);
    TextDrawAlignment(TD_ScoreAlpha, 2);
    TextDrawColor(TD_ScoreAlpha, 0xFF4444FF);
    TextDrawSetShadow(TD_ScoreAlpha, 1);
    TextDrawSetOutline(TD_ScoreAlpha, 1);
    TextDrawFont(TD_ScoreAlpha, 2);
    TextDrawSetProportional(TD_ScoreAlpha, 1);
    
    // Placar Beta
    TD_ScoreBeta = TextDrawCreate(380.0, 25.0, "BETA: 0");
    TextDrawLetterSize(TD_ScoreBeta, 0.35, 1.6);
    TextDrawAlignment(TD_ScoreBeta, 2);
    TextDrawColor(TD_ScoreBeta, 0x4444FFFF);
    TextDrawSetShadow(TD_ScoreBeta, 1);
    TextDrawSetOutline(TD_ScoreBeta, 1);
    TextDrawFont(TD_ScoreBeta, 2);
    TextDrawSetProportional(TD_ScoreBeta, 1);
}

// =============================================================================
// VEHICLE HP TEXTDRAW (PER-PLAYER)
// =============================================================================

stock CreateVehicleHPTextDraw(playerid)
{
    // Mostra a vida do veiculo acima do carro do jogador
    PlayerData[playerid][PL_TD_VEHICLE_HP] = CreatePlayerTextDraw(playerid, 320.0, 395.0, "HP: 1000");
    PlayerTextDrawLetterSize(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP], 0.35, 1.6);
    PlayerTextDrawAlignment(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP], 2);
    PlayerTextDrawColor(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP], 0x00FF00FF);
    PlayerTextDrawSetShadow(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP], 0);
    PlayerTextDrawSetOutline(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP], 1);
    PlayerTextDrawBackgroundColor(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP], 0x000000AA);
    PlayerTextDrawFont(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP], 2);
    PlayerTextDrawSetProportional(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP], 1);
}


// =============================================================================
// MOSTRAR / ESCONDER HUD
// =============================================================================

stock ShowRoomHUD(playerid, roomid)
{
    TextDrawShowForPlayer(playerid, TD_Timer);
    TextDrawShowForPlayer(playerid, TD_MapName);
    TextDrawShowForPlayer(playerid, TD_PlayersAlive);
    TextDrawShowForPlayer(playerid, TD_PlayersTotal);
    TextDrawShowForPlayer(playerid, TD_RoundInfo);
    
    // Vehicle HP
    PlayerTextDrawShow(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP]);
    
    // Placar CLA VS CLA
    if(RoomData[roomid][ROOM_MODE] == MODE_CLA_VS_CLA)
    {
        TextDrawShowForPlayer(playerid, TD_ScoreAlpha);
        TextDrawShowForPlayer(playerid, TD_ScoreBeta);
    }
}

stock HideRoomHUD(playerid)
{
    TextDrawHideForPlayer(playerid, TD_Timer);
    TextDrawHideForPlayer(playerid, TD_MapName);
    TextDrawHideForPlayer(playerid, TD_PlayersAlive);
    TextDrawHideForPlayer(playerid, TD_PlayersTotal);
    TextDrawHideForPlayer(playerid, TD_RoundInfo);
    TextDrawHideForPlayer(playerid, TD_Message);
    TextDrawHideForPlayer(playerid, TD_SpectateInfo);
    TextDrawHideForPlayer(playerid, TD_ScoreAlpha);
    TextDrawHideForPlayer(playerid, TD_ScoreBeta);
    
    PlayerTextDrawHide(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP]);
}

// =============================================================================
// ATUALIZAR HUD
// =============================================================================

stock UpdateRoomTimerHUD(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    new str[32];
    format(str, sizeof(str), "%s", TimeToString(RoomData[roomid][ROOM_TIMEOUT_VALUE]));
    TextDrawSetString(TD_Timer, str);
    
    // Vivos
    format(str, sizeof(str), "Vivos: %d", RoomData[roomid][ROOM_ALIVE_COUNT]);
    TextDrawSetString(TD_PlayersAlive, str);
    
    // Total
    format(str, sizeof(str), "Total: %d", RoomData[roomid][ROOM_PLAYER_COUNT]);
    TextDrawSetString(TD_PlayersTotal, str);
    
    // Round
    format(str, sizeof(str), "Round: %d/%d", RoomData[roomid][ROOM_CURRENT_ROUND],
        RoomData[roomid][ROOM_TOTAL_ROUNDS]);
    TextDrawSetString(TD_RoundInfo, str);
    
    // Placar
    if(RoomData[roomid][ROOM_MODE] == MODE_CLA_VS_CLA)
    {
        format(str, sizeof(str), "ALPHA: %d", RoomData[roomid][ROOM_SCORE_ALPHA]);
        TextDrawSetString(TD_ScoreAlpha, str);
        format(str, sizeof(str), "BETA: %d", RoomData[roomid][ROOM_SCORE_BETA]);
        TextDrawSetString(TD_ScoreBeta, str);
    }
    
    return 1;
}

stock UpdateMapNameHUD(roomid, mapid)
{
    if(mapid < 0 || mapid >= TotalMaps) return 0;
    
    new str[48];
    format(str, sizeof(str), "Mapa: %s", MapPool[mapid][MAP_NAME]);
    TextDrawSetString(TD_MapName, str);
    return 1;
}


// =============================================================================
// VEHICLE HP UPDATE (Timer global - 500ms)
// =============================================================================

public VehicleHPUpdate()
{
    new str[24];
    new Float:hp;
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] == INVALID_ROOM_ID) continue;
        if(PlayerData[i][PL_STATE] != PL_ST_ALIVE) continue;
        if(PlayerData[i][PL_VEHICLE_ID] == INVALID_VEHICLE_ID) continue;
        
        GetVehicleHealth(PlayerData[i][PL_VEHICLE_ID], hp);
        
        // Formatar HP como inteiro
        new hpint = floatround(hp);
        if(hpint < 0) hpint = 0;
        
        // Cor baseada na vida
        if(hp > 700.0)
            format(str, sizeof(str), "~g~HP: %d", hpint);
        else if(hp > 400.0)
            format(str, sizeof(str), "~y~HP: %d", hpint);
        else
            format(str, sizeof(str), "~r~HP: %d", hpint);
        
        PlayerTextDrawSetString(i, PlayerData[i][PL_TD_VEHICLE_HP], str);
    }
    return 1;
}
