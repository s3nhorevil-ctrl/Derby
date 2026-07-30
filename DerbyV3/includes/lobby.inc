/*
    DERBY V3 - LOBBY SYSTEM
    
    Menu principal /derby, criacao de salas,
    listagem de salas, entrada por dialogs.
*/

#if defined _lobby_included
    #endinput
#endif
#define _lobby_included

// =============================================================================
// VARIAVEIS TEMPORARIAS DE CRIACAO
// =============================================================================

enum E_ROOM_CREATION
{
    RC_MODE,
    RC_ROUNDS,
    RC_VEHICLE,
    RC_VEHICLE_INDEX,
    RC_MAP_COUNT,
    RC_SELECTED_MAPS[50],
    RC_NAME[32],
    RC_MAP_PAGE
};

new RoomCreation[MAX_PLAYERS][E_ROOM_CREATION];
new PlayerTargetRoom[MAX_PLAYERS]; // Sala que o jogador quer entrar


// =============================================================================
// MOSTRAR MENU PRINCIPAL
// =============================================================================

stock ShowDerbyMenu(playerid)
{
    new str[256];
    str = "{00FF00}FUN{FFFFFF} - Entrada rapida (rotacao automatica)\n";
    strcat(str, "{FFFF00}Treinamento{FFFFFF} - Treino livre (respawn)\n");
    strcat(str, "{00FFFF}Criar Sala{FFFFFF} - Sala personalizada\n");
    strcat(str, "{FF9900}Listar Salas{FFFFFF} - Ver salas abertas");
    
    ShowPlayerDialog(playerid, DIALOG_DERBY_MENU, DIALOG_STYLE_LIST,
        "{FFFFFF}DERBY V3 - Menu Principal", str, "Selecionar", "Fechar");
}

// =============================================================================
// MOSTRAR LISTA DE SALAS
// =============================================================================

stock ShowRoomList(playerid)
{
    new str[1024], line[128];
    str = "Sala\tModo\tJogadores\tStatus\n";
    
    new count = 0;
    for(new i = 0; i < MAX_ROOMS; i++)
    {
        if(RoomData[i][ROOM_STATE] == ROOM_STATE_EMPTY) continue;
        
        new lock[4];
        if(RoomData[i][ROOM_PRIVATE]) format(lock, sizeof(lock), "[P]");
        else lock[0] = '\0';
        
        new modename[20], statename[20];
        GetModeName(RoomData[i][ROOM_MODE], modename);
        GetRoomStateName(RoomData[i][ROOM_STATE], statename);
        
        // Build line in parts to avoid format argument limit
        line[0] = '\0';
        strcat(line, lock);
        strcat(line, RoomData[i][ROOM_NAME]);
        strcat(line, "\t");
        strcat(line, modename);
        strcat(line, "\t");
        
        new tmp2[16];
        format(tmp2, sizeof(tmp2), "%d/%d", RoomData[i][ROOM_PLAYER_COUNT], RoomData[i][ROOM_MAX_PLAYERS]);
        strcat(line, tmp2);
        strcat(line, "\t");
        strcat(line, statename);
        strcat(line, "\n");
        strcat(str, line);
        count++;
    }
    
    if(count == 0)
    {
        str = "Nenhuma sala ativa no momento.\nUse 'Criar Sala' no menu principal.";
        ShowPlayerDialog(playerid, DIALOG_ROOM_LIST, DIALOG_STYLE_MSGBOX,
            "{FFFFFF}Salas Abertas", str, "Voltar", "");
        return 1;
    }
    
    ShowPlayerDialog(playerid, DIALOG_ROOM_LIST, DIALOG_STYLE_TABLIST_HEADERS,
        "{FFFFFF}Salas Abertas", str, "Entrar", "Voltar");
    return 1;
}

// =============================================================================
// FLUXO DE CRIACAO - ESCOLHER MODO
// =============================================================================

stock ShowModeSelection(playerid)
{
    new str[128];
    str = "{FFFF00}Treinamento{FFFFFF} - Sem eliminacao, respawn livre\n";
    strcat(str, "{FF0000}CLA vs CLA{FFFFFF} - Competitivo por rounds");
    
    ShowPlayerDialog(playerid, DIALOG_ROOM_MODE, DIALOG_STYLE_LIST,
        "{FFFFFF}Criar Sala - Modo", str, "Selecionar", "Voltar");
}


// =============================================================================
// FLUXO DE CRIACAO - ESCOLHER ROUNDS
// =============================================================================

stock ShowRoundsSelection(playerid)
{
    new str[256];
    str = "1 Round\n3 Rounds\n5 Rounds\n7 Rounds\n10 Rounds\n15 Rounds\n20 Rounds";
    
    ShowPlayerDialog(playerid, DIALOG_ROOM_ROUNDS, DIALOG_STYLE_LIST,
        "{FFFFFF}Criar Sala - Rounds", str, "Selecionar", "Voltar");
}

// =============================================================================
// FLUXO DE CRIACAO - ESCOLHER VEICULO
// =============================================================================

stock ShowVehicleSelection(playerid)
{
    new str[1200], line[64];
    str = "";
    
    for(new i = 0; i < TOTAL_DERBY_VEHICLES; i++)
    {
        format(line, sizeof(line), "%s (ID: %d)\n",
            DerbyVehicles[i][VEH_NAME], DerbyVehicles[i][VEH_MODEL]);
        strcat(str, line);
    }
    
    ShowPlayerDialog(playerid, DIALOG_ROOM_VEHICLE, DIALOG_STYLE_LIST,
        "{FFFFFF}Criar Sala - Veiculo", str, "Selecionar", "Voltar");
}

// =============================================================================
// FLUXO DE CRIACAO - SELECIONAR MAPAS
// =============================================================================

#define MAPS_PER_PAGE 15

stock ShowMapSelection(playerid, page)
{
    RoomCreation[playerid][RC_MAP_PAGE] = page;
    
    new str[2048], line[80];
    new start = page * MAPS_PER_PAGE;
    new end = start + MAPS_PER_PAGE;
    if(end > TotalMaps) end = TotalMaps;
    
    str = "";
    
    for(new i = start; i < end; i++)
    {
        // Verificar se ja esta selecionado
        new bool:selected = false;
        for(new j = 0; j < RoomCreation[playerid][RC_MAP_COUNT]; j++)
        {
            if(RoomCreation[playerid][RC_SELECTED_MAPS][j] == i)
            {
                selected = true;
                break;
            }
        }
        
        if(selected)
            format(line, sizeof(line), "{00FF00}[X] %s\n", MapPool[i][MAP_NAME]);
        else
            format(line, sizeof(line), "{FFFFFF}[ ] %s\n", MapPool[i][MAP_NAME]);
        strcat(str, line);
    }
    
    // Opcoes de navegacao
    if(end < TotalMaps)
        strcat(str, "{FFFF00}>>> Proxima Pagina >>>\n");
    
    strcat(str, "{00FFFF}--- CONFIRMAR SELECAO ---");
    
    new title[64];
    format(title, sizeof(title), "{FFFFFF}Mapas (Pag %d/%d) - %d selecionados",
        page + 1, (TotalMaps / MAPS_PER_PAGE) + 1, RoomCreation[playerid][RC_MAP_COUNT]);
    
    ShowPlayerDialog(playerid, DIALOG_ROOM_MAPS, DIALOG_STYLE_LIST,
        title, str, "Selecionar", "Voltar");
}


// =============================================================================
// FLUXO DE CRIACAO - NOME DA SALA
// =============================================================================

stock ShowRoomNameInput(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_ROOM_NAME, DIALOG_STYLE_INPUT,
        "{FFFFFF}Criar Sala - Nome",
        "Digite o nome da sala (max 24 caracteres):\n\nDeixe vazio para nome automatico.",
        "Criar", "Voltar");
}

// =============================================================================
// CONFIRMACAO FINAL
// =============================================================================

stock ShowRoomConfirmation(playerid)
{
    new str[512], vehname[24], modename[20];
    GetVehicleNameByModel(RoomCreation[playerid][RC_VEHICLE], vehname);
    GetModeName(RoomCreation[playerid][RC_MODE], modename);
    
    format(str, sizeof(str),
        "{FFFFFF}Confirme as configuracoes da sala:\n\n"\
        "{00FF00}Modo:{FFFFFF} %s\n"\
        "{00FF00}Rounds:{FFFFFF} %d\n"\
        "{00FF00}Veiculo:{FFFFFF} %s\n"\
        "{00FF00}Mapas:{FFFFFF} %d selecionados\n"\
        "{00FF00}Nome:{FFFFFF} %s\n\n"\
        "Deseja criar a sala?",
        modename,
        RoomCreation[playerid][RC_ROUNDS],
        vehname,
        RoomCreation[playerid][RC_MAP_COUNT],
        RoomCreation[playerid][RC_NAME]);
    
    ShowPlayerDialog(playerid, DIALOG_ROOM_CONFIRM, DIALOG_STYLE_MSGBOX,
        "{FFFFFF}Criar Sala - Confirmacao", str, "Criar", "Cancelar");
}


// =============================================================================
// HANDLER DE DIALOGS
// =============================================================================

stock HandleDerbyDialogs(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_DERBY_MENU:
        {
            if(!response) return 1;
            switch(listitem)
            {
                case 0: // FUN
                {
                    JoinRoom(playerid, FUN_ROOM_ID);
                    // Auto-iniciar se ha jogadores suficientes
                    if(RoomData[FUN_ROOM_ID][ROOM_STATE] == ROOM_STATE_LOBBY
                        && RoomData[FUN_ROOM_ID][ROOM_PLAYER_COUNT] >= 2)
                    {
                        StartRoomMatch(FUN_ROOM_ID);
                    }
                }
                case 1: // Treinamento
                {
                    // Criar sala de treinamento rapida
                    RoomCreation[playerid][RC_MODE] = MODE_TRAINING;
                    RoomCreation[playerid][RC_ROUNDS] = 999;
                    RoomCreation[playerid][RC_MAP_COUNT] = 0;
                    ShowVehicleSelection(playerid);
                }
                case 2: // Criar Sala
                {
                    RoomCreation[playerid][RC_MAP_COUNT] = 0;
                    ShowModeSelection(playerid);
                }
                case 3: // Listar Salas
                {
                    ShowRoomList(playerid);
                }
            }
            return 1;
        }
        
        case DIALOG_ROOM_MODE:
        {
            if(!response) { ShowDerbyMenu(playerid); return 1; }
            switch(listitem)
            {
                case 0: RoomCreation[playerid][RC_MODE] = MODE_TRAINING;
                case 1: RoomCreation[playerid][RC_MODE] = MODE_CLA_VS_CLA;
            }
            ShowRoundsSelection(playerid);
            return 1;
        }
        
        case DIALOG_ROOM_ROUNDS:
        {
            if(!response) { ShowModeSelection(playerid); return 1; }
            new rounds[] = {1, 3, 5, 7, 10, 15, 20};
            if(listitem >= 0 && listitem < sizeof(rounds))
                RoomCreation[playerid][RC_ROUNDS] = rounds[listitem];
            else
                RoomCreation[playerid][RC_ROUNDS] = 5;
            ShowVehicleSelection(playerid);
            return 1;
        }
        
        case DIALOG_ROOM_VEHICLE:
        {
            if(!response)
            {
                if(RoomCreation[playerid][RC_MODE] == MODE_TRAINING)
                    ShowDerbyMenu(playerid);
                else
                    ShowRoundsSelection(playerid);
                return 1;
            }
            if(listitem >= 0 && listitem < TOTAL_DERBY_VEHICLES)
            {
                RoomCreation[playerid][RC_VEHICLE] = DerbyVehicles[listitem][VEH_MODEL];
                RoomCreation[playerid][RC_VEHICLE_INDEX] = listitem;
            }
            ShowMapSelection(playerid, 0);
            return 1;
        }

        
        case DIALOG_ROOM_MAPS:
        {
            if(!response) { ShowVehicleSelection(playerid); return 1; }
            
            new page = RoomCreation[playerid][RC_MAP_PAGE];
            new start = page * MAPS_PER_PAGE;
            new end = start + MAPS_PER_PAGE;
            if(end > TotalMaps) end = TotalMaps;
            
            new totalitems = (end - start);
            new hasNextPage = (end < TotalMaps) ? 1 : 0;
            
            // "Proxima Pagina"
            if(hasNextPage && listitem == totalitems)
            {
                ShowMapSelection(playerid, page + 1);
                return 1;
            }
            
            // "CONFIRMAR SELECAO"
            new confirmIndex = totalitems + hasNextPage;
            if(listitem == confirmIndex)
            {
                if(RoomCreation[playerid][RC_MAP_COUNT] == 0)
                {
                    SCM(playerid, COLOR_RED, "[ERRO] Selecione pelo menos 1 mapa!");
                    ShowMapSelection(playerid, page);
                    return 1;
                }
                
                if(RoomCreation[playerid][RC_MODE] == MODE_TRAINING)
                {
                    // Treinamento - criar direto com nome auto
                    format(RoomCreation[playerid][RC_NAME], 32, "Treino de %s", PlayerData[playerid][PL_NAME]);
                    FinalizeRoomCreation(playerid);
                }
                else
                {
                    ShowRoomNameInput(playerid);
                }
                return 1;
            }
            
            // Toggle mapa
            new mapindex = start + listitem;
            if(mapindex >= 0 && mapindex < TotalMaps)
            {
                ToggleMapSelection(playerid, mapindex);
            }
            ShowMapSelection(playerid, page);
            return 1;
        }
        
        case DIALOG_ROOM_NAME:
        {
            if(!response) { ShowMapSelection(playerid, 0); return 1; }
            
            if(strlen(inputtext) > 0 && strlen(inputtext) <= 24)
                format(RoomCreation[playerid][RC_NAME], 32, "%s", inputtext);
            else
                format(RoomCreation[playerid][RC_NAME], 32, "Sala de %s", PlayerData[playerid][PL_NAME]);
            
            ShowRoomConfirmation(playerid);
            return 1;
        }
        
        case DIALOG_ROOM_CONFIRM:
        {
            if(!response) { ShowDerbyMenu(playerid); return 1; }
            FinalizeRoomCreation(playerid);
            return 1;
        }

        
        case DIALOG_ROOM_LIST:
        {
            if(!response) { ShowDerbyMenu(playerid); return 1; }
            
            // Encontrar a sala selecionada
            new count = 0;
            for(new i = 0; i < MAX_ROOMS; i++)
            {
                if(RoomData[i][ROOM_STATE] == ROOM_STATE_EMPTY) continue;
                if(count == listitem)
                {
                    PlayerTargetRoom[playerid] = i;
                    
                    // Verificar se e privada
                    if(RoomData[i][ROOM_PRIVATE] && strlen(RoomData[i][ROOM_PASSWORD]) > 0)
                    {
                        ShowPlayerDialog(playerid, DIALOG_ROOM_ENTER_PASS, DIALOG_STYLE_PASSWORD,
                            "{FFFFFF}Sala Privada - Senha",
                            "Esta sala requer senha para entrar:",
                            "Entrar", "Voltar");
                    }
                    else
                    {
                        JoinRoom(playerid, i);
                    }
                    break;
                }
                count++;
            }
            return 1;
        }
        
        case DIALOG_ROOM_ENTER_PASS:
        {
            if(!response) { ShowRoomList(playerid); return 1; }
            
            new roomid = PlayerTargetRoom[playerid];
            if(roomid == INVALID_ROOM_ID) return 1;
            
            if(strcmp(inputtext, RoomData[roomid][ROOM_PASSWORD], false) == 0)
            {
                JoinRoom(playerid, roomid);
            }
            else
            {
                SCM(playerid, COLOR_RED, "[ERRO] Senha incorreta!");
                ShowRoomList(playerid);
            }
            return 1;
        }
    }
    return 0;
}

// =============================================================================
// TOGGLE MAPA NA SELECAO
// =============================================================================

stock ToggleMapSelection(playerid, mapindex)
{
    // Verificar se ja esta selecionado
    for(new i = 0; i < RoomCreation[playerid][RC_MAP_COUNT]; i++)
    {
        if(RoomCreation[playerid][RC_SELECTED_MAPS][i] == mapindex)
        {
            // Remover
            for(new j = i; j < RoomCreation[playerid][RC_MAP_COUNT] - 1; j++)
                RoomCreation[playerid][RC_SELECTED_MAPS][j] = RoomCreation[playerid][RC_SELECTED_MAPS][j+1];
            RoomCreation[playerid][RC_MAP_COUNT]--;
            return 0;
        }
    }
    
    // Adicionar
    if(RoomCreation[playerid][RC_MAP_COUNT] < MAX_ROOM_MAPS)
    {
        RoomCreation[playerid][RC_SELECTED_MAPS][RoomCreation[playerid][RC_MAP_COUNT]] = mapindex;
        RoomCreation[playerid][RC_MAP_COUNT]++;
        return 1;
    }
    
    SCM(playerid, COLOR_ORANGE, "[AVISO] Limite maximo de mapas atingido!");
    return 0;
}


// =============================================================================
// FINALIZAR CRIACAO DA SALA
// =============================================================================

stock FinalizeRoomCreation(playerid)
{
    new roomid = CreateRoom(playerid,
        RoomCreation[playerid][RC_MODE],
        RoomCreation[playerid][RC_NAME],
        RoomCreation[playerid][RC_ROUNDS],
        RoomCreation[playerid][RC_VEHICLE]);
    
    if(roomid == INVALID_ROOM_ID) return 0;
    
    // Copiar mapas selecionados para a sala
    RoomData[roomid][ROOM_MAP_COUNT] = RoomCreation[playerid][RC_MAP_COUNT];
    for(new i = 0; i < RoomCreation[playerid][RC_MAP_COUNT]; i++)
    {
        RoomData[roomid][ROOM_SELECTED_MAPS][i] = RoomCreation[playerid][RC_SELECTED_MAPS][i];
    }
    
    return 1;
}
