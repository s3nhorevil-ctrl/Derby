/*
    DERBY V3 - HOST CONTROLS
    
    Controles administrativos do Host dentro da sala:
    iniciar, cancelar, alterar config, kick, transfer host.
*/

#if defined _host_controls_included
    #endinput
#endif
#define _host_controls_included

// =============================================================================
// VERIFICAR SE E HOST
// =============================================================================

stock IsPlayerHost(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID) return 0;
    if(roomid == FUN_ROOM_ID) return 0;
    return (RoomData[roomid][ROOM_HOST] == playerid);
}


// =============================================================================
// MENU DO HOST
// =============================================================================

stock ShowHostMenu(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID || !IsPlayerHost(playerid))
    {
        SCM(playerid, COLOR_RED, "[ERRO] Voce nao e Host de nenhuma sala!");
        return 0;
    }
    
    new str[512];
    str = "{00FF00}Iniciar Partida\n";
    strcat(str, "{FF0000}Cancelar Partida\n");
    strcat(str, "{FFFF00}Alterar Veiculo\n");
    strcat(str, "{FFFF00}Alterar Rounds\n");
    strcat(str, "{FFFF00}Alterar Mapas\n");
    strcat(str, "{FF9900}Expulsar Jogador\n");
    strcat(str, "{00FFFF}Transferir Host\n");
    strcat(str, "{FF0000}Fechar Sala");
    
    ShowPlayerDialog(playerid, DIALOG_HOST_MENU, DIALOG_STYLE_LIST,
        "{FFFFFF}Host Controls", str, "Selecionar", "Fechar");
    return 1;
}

// =============================================================================
// HANDLER DO MENU DO HOST
// =============================================================================

stock HandleHostDialogs(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused inputtext
    
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    
    switch(dialogid)
    {
        case DIALOG_HOST_MENU:
        {
            if(!response) return 1;
            if(!IsPlayerHost(playerid)) return 1;
            
            switch(listitem)
            {
                case 0: // Iniciar Partida
                {
                    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_LOBBY)
                    {
                        SCM(playerid, COLOR_RED, "[ERRO] A sala nao esta no lobby!");
                        return 1;
                    }
                    if(RoomData[roomid][ROOM_PLAYER_COUNT] < 1)
                    {
                        SCM(playerid, COLOR_RED, "[ERRO] Precisa de pelo menos 1 jogador!");
                        return 1;
                    }
                    if(RoomData[roomid][ROOM_MAP_COUNT] < 1)
                    {
                        SCM(playerid, COLOR_RED, "[ERRO] Nenhum mapa selecionado!");
                        return 1;
                    }
                    StartRoomMatch(roomid);
                }
                case 1: // Cancelar Partida
                {
                    if(RoomData[roomid][ROOM_STATE] == ROOM_STATE_RUNNING ||
                       RoomData[roomid][ROOM_STATE] == ROOM_STATE_COUNTDOWN)
                    {
                        CancelRoomMatch(roomid);
                    }
                    else
                    {
                        SCM(playerid, COLOR_ORANGE, "[AVISO] Nenhuma partida em andamento.");
                    }
                }

                case 2: // Alterar Veiculo
                {
                    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_LOBBY)
                    {
                        SCM(playerid, COLOR_RED, "[ERRO] Apenas no lobby!");
                        return 1;
                    }
                    ShowHostVehicleSelection(playerid);
                }
                case 3: // Alterar Rounds
                {
                    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_LOBBY)
                    {
                        SCM(playerid, COLOR_RED, "[ERRO] Apenas no lobby!");
                        return 1;
                    }
                    ShowHostRoundsSelection(playerid);
                }
                case 4: // Alterar Mapas
                {
                    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_LOBBY)
                    {
                        SCM(playerid, COLOR_RED, "[ERRO] Apenas no lobby!");
                        return 1;
                    }
                    // Copiar mapas atuais para o buffer de criacao
                    RoomCreation[playerid][RC_MAP_COUNT] = RoomData[roomid][ROOM_MAP_COUNT];
                    for(new i = 0; i < RoomData[roomid][ROOM_MAP_COUNT]; i++)
                        RoomCreation[playerid][RC_SELECTED_MAPS][i] = RoomData[roomid][ROOM_SELECTED_MAPS][i];
                    ShowMapSelection(playerid, 0);
                }
                case 5: // Expulsar Jogador
                {
                    ShowKickPlayerList(playerid, roomid);
                }
                case 6: // Transferir Host
                {
                    ShowTransferHostList(playerid, roomid);
                }
                case 7: // Fechar Sala
                {
                    SendRoomMessage(roomid, COLOR_RED, "{FF0000}| DERBY | Host fechou a sala!");
                    DestroyRoom(roomid);
                }
            }
            return 1;
        }
        
        case DIALOG_HOST_VEHICLE:
        {
            if(!response) { ShowHostMenu(playerid); return 1; }
            if(!IsPlayerHost(playerid)) return 1;
            if(listitem >= 0 && listitem < TOTAL_DERBY_VEHICLES)
            {
                RoomData[roomid][ROOM_VEHICLE] = DerbyVehicles[listitem][VEH_MODEL];
                new str[128];
                format(str, sizeof(str), "{00FF00}| DERBY | Host alterou o veiculo para: %s",
                    DerbyVehicles[listitem][VEH_NAME]);
                SendRoomMessage(roomid, COLOR_GREEN, str);
            }
            return 1;
        }
        
        case DIALOG_HOST_ROUNDS:
        {
            if(!response) { ShowHostMenu(playerid); return 1; }
            if(!IsPlayerHost(playerid)) return 1;
            new rounds[] = {1, 3, 5, 7, 10, 15, 20};
            if(listitem >= 0 && listitem < sizeof(rounds))
            {
                RoomData[roomid][ROOM_TOTAL_ROUNDS] = rounds[listitem];
                new str[64];
                format(str, sizeof(str), "{00FF00}| DERBY | Host alterou rounds para: %d", rounds[listitem]);
                SendRoomMessage(roomid, COLOR_GREEN, str);
            }
            return 1;
        }

        
        case DIALOG_HOST_KICK:
        {
            if(!response) { ShowHostMenu(playerid); return 1; }
            if(!IsPlayerHost(playerid)) return 1;
            
            new count = 0;
            for(new i = 0; i < MAX_PLAYERS; i++)
            {
                if(!IsPlayerConnected(i)) continue;
                if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
                if(i == playerid) continue;
                
                if(count == listitem)
                {
                    new str[128];
                    format(str, sizeof(str), "{FF0000}| DERBY | %s foi expulso pelo Host!", PlayerData[i][PL_NAME]);
                    SendRoomMessage(roomid, COLOR_RED, str);
                    SCM(i, COLOR_RED, "{FF0000}| DERBY | Voce foi expulso da sala pelo Host!");
                    LeaveRoom(i);
                    break;
                }
                count++;
            }
            return 1;
        }
        
        case DIALOG_HOST_TRANSFER:
        {
            if(!response) { ShowHostMenu(playerid); return 1; }
            if(!IsPlayerHost(playerid)) return 1;
            
            new count = 0;
            for(new i = 0; i < MAX_PLAYERS; i++)
            {
                if(!IsPlayerConnected(i)) continue;
                if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
                if(i == playerid) continue;
                
                if(count == listitem)
                {
                    RoomData[roomid][ROOM_HOST] = i;
                    new str[128];
                    format(str, sizeof(str), "{00FFFF}| DERBY | %s transferiu o Host para %s!",
                        PlayerData[playerid][PL_NAME], PlayerData[i][PL_NAME]);
                    SendRoomMessage(roomid, COLOR_CYAN, str);
                    break;
                }
                count++;
            }
            return 1;
        }
    }
    return 0;
}

// =============================================================================
// DIALOGS AUXILIARES DO HOST
// =============================================================================

stock ShowHostVehicleSelection(playerid)
{
    new str[1200], line[64];
    str = "";
    for(new i = 0; i < TOTAL_DERBY_VEHICLES; i++)
    {
        format(line, sizeof(line), "%s (ID: %d)\n", DerbyVehicles[i][VEH_NAME], DerbyVehicles[i][VEH_MODEL]);
        strcat(str, line);
    }
    ShowPlayerDialog(playerid, DIALOG_HOST_VEHICLE, DIALOG_STYLE_LIST,
        "{FFFFFF}Host - Alterar Veiculo", str, "Selecionar", "Voltar");
}

stock ShowHostRoundsSelection(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_HOST_ROUNDS, DIALOG_STYLE_LIST,
        "{FFFFFF}Host - Alterar Rounds",
        "1 Round\n3 Rounds\n5 Rounds\n7 Rounds\n10 Rounds\n15 Rounds\n20 Rounds",
        "Selecionar", "Voltar");
}


stock ShowKickPlayerList(playerid, roomid)
{
    new str[512], line[64];
    str = "";
    new count = 0;
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        if(i == playerid) continue;
        
        format(line, sizeof(line), "%s (ID: %d)\n", PlayerData[i][PL_NAME], i);
        strcat(str, line);
        count++;
    }
    
    if(count == 0)
    {
        SCM(playerid, COLOR_ORANGE, "[AVISO] Nenhum outro jogador na sala.");
        return 0;
    }
    
    ShowPlayerDialog(playerid, DIALOG_HOST_KICK, DIALOG_STYLE_LIST,
        "{FFFFFF}Expulsar Jogador", str, "Expulsar", "Voltar");
    return 1;
}

stock ShowTransferHostList(playerid, roomid)
{
    new str[512], line[64];
    str = "";
    new count = 0;
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] != roomid) continue;
        if(i == playerid) continue;
        
        format(line, sizeof(line), "%s (ID: %d)\n", PlayerData[i][PL_NAME], i);
        strcat(str, line);
        count++;
    }
    
    if(count == 0)
    {
        SCM(playerid, COLOR_ORANGE, "[AVISO] Nenhum outro jogador na sala.");
        return 0;
    }
    
    ShowPlayerDialog(playerid, DIALOG_HOST_TRANSFER, DIALOG_STYLE_LIST,
        "{FFFFFF}Transferir Host", str, "Transferir", "Voltar");
    return 1;
}

// =============================================================================
// CANCELAR PARTIDA
// =============================================================================

stock CancelRoomMatch(roomid)
{
    if(roomid < 0 || roomid >= MAX_ROOMS) return 0;
    
    KillRoomTimers(roomid);
    
    // Destruir todos os veiculos e resetar jogadores
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
        
        PlayerData[i][PL_STATE] = PLAYER_STATE_LOBBY;
        PlayerData[i][PL_NITRO_ACTIVE] = false;
        HideRoomHUD(i);
    }
    
    RoomData[roomid][ROOM_STATE] = ROOM_STATE_LOBBY;
    RoomData[roomid][ROOM_ALIVE_COUNT] = 0;
    
    SendRoomMessage(roomid, COLOR_YELLOW, "{FFFF00}| DERBY | Partida cancelada pelo Host!");
    return 1;
}
