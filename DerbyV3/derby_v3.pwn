/*****************************************************************************************************

    DERBY V3 - SISTEMA DE SALAS PERSONALIZADAS
    
    Reformulacao completa do Derby com sistema de lobbies/salas.
    
    Modos:
        - FUN (publico, rotacao automatica)
        - Treinamento (respawn, sem pontuacao)
        - CLA VS CLA (competitivo, rounds, times)
    
    Sistemas:
        - Room Manager (criacao/destruicao de salas)
        - Nitro on-click (ativa ao pressionar, desativa ao soltar)
        - Vehicle HP TextDraw (vida do carro por jogador)
        - Host Controls (iniciar, cancelar, kick, transfer)
        - Multi-map selection (checkboxes)
        - Vehicle preview (TextDraw 3D model)
        - Anti-AFK
        - Spectate
    
    Includes necessarios:
        - a_samp.inc
        - sscanf2.inc
        - Pawn.CMD.inc
        - foreach.inc

******************************************************************************************************/

#include <a_samp>
#include <sscanf2>
#include <Pawn.CMD>
#include <foreach>

#pragma dynamic 65536

native IsValidVehicle(vehicleid);


// =============================================================================
// INCLUDES MODULARES
// =============================================================================

#include "includes/derby_core.inc"
#include "includes/map_selector.inc"
#include "includes/room_data.inc"
#include "includes/hud.inc"
#include "includes/nitro.inc"
#include "includes/room_manager.inc"
#include "includes/fun_mode.inc"
#include "includes/training_mode.inc"
#include "includes/cla_mode.inc"
#include "includes/vehicle_selector.inc"
#include "includes/lobby.inc"
#include "includes/host_controls.inc"

// =============================================================================
// MAIN
// =============================================================================

main()
{
    print("\n=============================================");
    print("    DERBY V3 - SISTEMA DE SALAS");
    print("    Modos: FUN | Treinamento | CLA vs CLA");
    print("=============================================\n");
}

// =============================================================================
// DATABASE - REMOVIDO (sem SQL)
// =============================================================================

// =============================================================================
// OnGameModeInit
// =============================================================================

public OnGameModeInit()
{
    SetGameModeText(GAMEMODETEXT);
    SendRconCommand("hostname "HOSTNAME);
    
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    ShowPlayerMarkers(1);
    ShowNameTags(1);
    SetNameTagDrawDistance(40.0);
    UsePlayerPedAnims();
    
    // Criar TextDraws globais
    CreateAllTextDraws();
    CreateVehiclePreviewTextDraws();
    
    // Carregar mapas
    LoadMapList("DERBY/derbys.sfr");
    LoadAllMaps();
    
    // Inicializar salas
    InitAllRooms();
    
    // Timers globais
    SetTimer("NitroUpdateTimer", NITRO_UPDATE_INTERVAL, true);
    SetTimer("AntiAFKCheck", 1000, true);
    SetTimer("VehicleHPUpdate", 500, true);
    
    printf("[DERBY] Gamemode Derby V3 inicializado com sucesso!");
    printf("[DERBY] Mapas: %d | Veiculos: %d | Salas: %d", TotalMaps, TOTAL_DERBY_VEHICLES, MAX_ROOMS);
    
    // Adicionar classe padrao
    AddPlayerClass(0, 0.0, 0.0, 5.0, 0.0, 0, 0, 0, 0, 0, 0);
    
    return 1;
}

public OnGameModeExit()
{
    return 1;
}

// =============================================================================
// OnPlayerConnect
// =============================================================================

public OnPlayerConnect(playerid)
{
    // Inicializar dados do jogador
    GetPlayerName(playerid, PlayerData[playerid][PL_NAME], MAX_PLAYER_NAME);
    PlayerData[playerid][PL_ROOM_ID] = INVALID_ROOM_ID;
    PlayerData[playerid][PL_STATE] = PL_ST_NONE;
    PlayerData[playerid][PL_TEAM] = TEAM_NONE;
    PlayerData[playerid][PL_VEHICLE_ID] = INVALID_VEHICLE_ID;
    PlayerData[playerid][PL_SPAWN_SLOT] = -1;
    PlayerData[playerid][PL_SPECTATE_TARGET] = INVALID_PLAYER;
    PlayerData[playerid][PL_IN_DERBY] = false;
    PlayerData[playerid][PL_NITRO_FUEL] = NITRO_MAX_FUEL;
    PlayerData[playerid][PL_NITRO_ACTIVE] = false;
    PlayerData[playerid][PL_WINS] = 0;
    PlayerData[playerid][PL_LOSSES] = 0;
    PlayerData[playerid][PL_SCORE] = 0;
    PlayerData[playerid][PL_AFK_SECONDS] = 0;
    PlayerData[playerid][PL_LAST_POS_HASH] = 0.0;
    
    PlayerTargetRoom[playerid] = INVALID_ROOM_ID;
    
    // Criar textdraw per-player (Vehicle HP)
    CreateVehicleHPTextDraw(playerid);
    
    // Mensagem de boas vindas
    SCM(playerid, COLOR_GREEN, "=============================================");
    SCM(playerid, COLOR_WHITE, "  Bem-vindo ao {00FF00}DERBY V3{FFFFFF} - Sistema de Salas!");
    SCM(playerid, COLOR_WHITE, "  Use {FFFF00}/derby{FFFFFF} para entrar no menu principal.");
    SCM(playerid, COLOR_GREEN, "=============================================");
    SCM(playerid, COLOR_GREY, "Comandos: /derby /sair /host /stats /top /ajuda");
    
    return 1;
}


// =============================================================================
// OnPlayerDisconnect
// =============================================================================

public OnPlayerDisconnect(playerid, reason)
{
    if(PlayerData[playerid][PL_ROOM_ID] != INVALID_ROOM_ID)
    {
        LeaveRoom(playerid);
    }
    
    // Destruir textdraw per-player
    PlayerTextDrawDestroy(playerid, PlayerData[playerid][PL_TD_VEHICLE_HP]);
    
    return 1;
}

// =============================================================================
// OnPlayerSpawn
// =============================================================================

public OnPlayerSpawn(playerid)
{
    // Se nao esta em sala, mostrar menu
    if(PlayerData[playerid][PL_ROOM_ID] == INVALID_ROOM_ID)
    {
        SetPlayerPos(playerid, 0.0, 0.0, 5.0);
        SetPlayerVirtualWorld(playerid, 0);
        ShowDerbyMenu(playerid);
    }
    return 1;
}

// =============================================================================
// OnPlayerRequestClass
// =============================================================================

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 0.0, 0.0, 5.0);
    SetPlayerCameraPos(playerid, 0.0, 0.0, 50.0);
    SetPlayerCameraLookAt(playerid, 0.0, 0.0, 5.0);
    return 1;
}

// =============================================================================
// OnPlayerDeath
// =============================================================================

public OnPlayerDeath(playerid, killerid, reason)
{
    if(PlayerData[playerid][PL_ROOM_ID] != INVALID_ROOM_ID &&
       PlayerData[playerid][PL_STATE] == PL_ST_ALIVE)
    {
        HandlePlayerFall(playerid);
    }
    return 1;
}

// =============================================================================
// OnPlayerStateChange
// =============================================================================

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    // Jogador saiu do veiculo durante partida
    if(PlayerData[playerid][PL_ROOM_ID] != INVALID_ROOM_ID &&
       PlayerData[playerid][PL_STATE] == PL_ST_ALIVE)
    {
        if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
        {
            new roomid = PlayerData[playerid][PL_ROOM_ID];
            if(RoomData[roomid][ROOM_STATE] == ROOM_STATE_RUNNING)
            {
                HandlePlayerFall(playerid);
            }
        }
    }
    return 1;
}


// =============================================================================
// OnPlayerUpdate - Verificacao de queda
// =============================================================================

public OnPlayerUpdate(playerid)
{
    if(PlayerData[playerid][PL_ROOM_ID] == INVALID_ROOM_ID) return 1;
    if(PlayerData[playerid][PL_STATE] != PL_ST_ALIVE) return 1;
    
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_RUNNING) return 1;
    
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vid = PlayerData[playerid][PL_VEHICLE_ID];
        if(vid != INVALID_VEHICLE_ID)
        {
            new Float:px, Float:py, Float:pz;
            GetVehiclePos(vid, px, py, pz);
            
            // Verificar queda (Z abaixo do limite do mapa)
            new mapid = GetCurrentMapID(roomid);
            if(mapid >= 0 && mapid < TotalMaps)
            {
                if(pz <= MapPool[mapid][MAP_ZMIN])
                {
                    HandlePlayerFall(playerid);
                }
            }
        }
    }
    return 1;
}

// =============================================================================
// HANDLER DE QUEDA (Decide qual modo processar)
// =============================================================================

stock HandlePlayerFall(playerid)
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID) return 0;
    if(PlayerData[playerid][PL_STATE] != PL_ST_ALIVE) return 0;
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_RUNNING) return 0;
    
    switch(RoomData[roomid][ROOM_MODE])
    {
        case MODE_FUN:
        {
            FunModeElimination(playerid);
        }
        case MODE_TRAINING:
        {
            TrainingModeElimination(playerid);
        }
        case MODE_CLA_VS_CLA:
        {
            ClaModeElimination(playerid);
        }
        default:
        {
            PlayerEliminated(playerid);
        }
    }
    return 1;
}

// =============================================================================
// OnPlayerKeyStateChange - Nitro + Spectate
// =============================================================================

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    // Nitro (ativa/desativa por tecla)
    HandleNitroKeyChange(playerid, newkeys, oldkeys);
    
    // Spectate - trocar de alvo (SPRINT / ENTER)
    if(PlayerData[playerid][PL_STATE] == PL_ST_SPECTATING)
    {
        if((newkeys & KEY_SPRINT) && !(oldkeys & KEY_SPRINT))
        {
            NextSpectateTarget(playerid);
        }
    }
    
    return 1;
}


// =============================================================================
// OnDialogResponse
// =============================================================================

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    // Processar dialogs do lobby
    if(HandleDerbyDialogs(playerid, dialogid, response, listitem, inputtext))
        return 1;
    
    // Processar dialogs do host
    if(HandleHostDialogs(playerid, dialogid, response, listitem, inputtext))
        return 1;
    
    // Dialog de mapas do host (reusa o mesmo handler)
    if(dialogid == DIALOG_ROOM_MAPS && IsPlayerHost(playerid))
    {
        // Ao confirmar selecao de mapas pelo host, atualizar sala
        new roomid = PlayerData[playerid][PL_ROOM_ID];
        if(roomid != INVALID_ROOM_ID)
        {
            RoomData[roomid][ROOM_MAP_COUNT] = RoomCreation[playerid][RC_MAP_COUNT];
            for(new i = 0; i < RoomCreation[playerid][RC_MAP_COUNT]; i++)
                RoomData[roomid][ROOM_SELECTED_MAPS][i] = RoomCreation[playerid][RC_SELECTED_MAPS][i];
            
            new str[64];
            format(str, sizeof(str), "{00FF00}| DERBY | Mapas atualizados: %d selecionados.",
                RoomData[roomid][ROOM_MAP_COUNT]);
            SendRoomMessage(roomid, COLOR_GREEN, str);
        }
    }
    
    return 0;
}

// =============================================================================
// COMANDOS PRINCIPAIS
// =============================================================================

CMD:derby(playerid, params[])
{
    ShowDerbyMenu(playerid);
    return 1;
}

CMD:sair(playerid, params[])
{
    if(PlayerData[playerid][PL_ROOM_ID] == INVALID_ROOM_ID)
    {
        SCM(playerid, COLOR_ORANGE, "| DERBY | Voce nao esta em nenhuma sala!");
        return 1;
    }
    
    LeaveRoom(playerid);
    SCM(playerid, COLOR_YELLOW, "| DERBY | Voce saiu da sala. Use /derby para voltar.");
    return 1;
}

CMD:host(playerid, params[])
{
    if(PlayerData[playerid][PL_ROOM_ID] == INVALID_ROOM_ID)
    {
        SCM(playerid, COLOR_RED, "[ERRO] Voce precisa estar em uma sala!");
        return 1;
    }
    
    if(!IsPlayerHost(playerid))
    {
        SCM(playerid, COLOR_RED, "[ERRO] Voce nao e o Host desta sala!");
        return 1;
    }
    
    ShowHostMenu(playerid);
    return 1;
}

CMD:iniciar(playerid, params[])
{
    if(!IsPlayerHost(playerid))
    {
        SCM(playerid, COLOR_RED, "[ERRO] Apenas o Host pode iniciar a partida!");
        return 1;
    }
    
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_LOBBY)
    {
        SCM(playerid, COLOR_RED, "[ERRO] A sala nao esta no lobby!");
        return 1;
    }
    
    StartRoomMatch(roomid);
    return 1;
}


CMD:stats(playerid, params[])
{
    new str[256];
    SCM(playerid, COLOR_GREEN, "============ SUAS ESTATISTICAS ============");
    format(str, sizeof(str), "   Vitorias: {00FF00}%d  {FFFFFF}| Derrotas: {FF0000}%d  {FFFFFF}| Score: {FFFF00}%d",
        PlayerData[playerid][PL_WINS], PlayerData[playerid][PL_LOSSES], PlayerData[playerid][PL_SCORE]);
    SCM(playerid, COLOR_WHITE, str);
    SCM(playerid, COLOR_GREEN, "============================================");
    return 1;
}

CMD:top(playerid, params[])
{
    SCM(playerid, COLOR_GREEN, "========== TOP JOGADORES (sessao) ==========");
    
    // Ordenar por wins na sessao atual
    new topPlayers[10], topWins[10], count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_WINS] <= 0) continue;
        
        // Inserir ordenado
        new inserted = false;
        for(new j = 0; j < count && j < 10; j++)
        {
            if(PlayerData[i][PL_WINS] > topWins[j])
            {
                // Deslocar para baixo
                for(new k = 9; k > j; k--)
                {
                    topPlayers[k] = topPlayers[k-1];
                    topWins[k] = topWins[k-1];
                }
                topPlayers[j] = i;
                topWins[j] = PlayerData[i][PL_WINS];
                inserted = true;
                break;
            }
        }
        if(!inserted && count < 10)
        {
            topPlayers[count] = i;
            topWins[count] = PlayerData[i][PL_WINS];
        }
        if(count < 10) count++;
    }
    
    if(count == 0)
    {
        SCM(playerid, COLOR_ORANGE, "  Nenhuma vitoria registrada nesta sessao.");
    }
    else
    {
        new str[128];
        for(new i = 0; i < count; i++)
        {
            format(str, sizeof(str), "  #%d - %s | Vitorias: %d | Score: %d",
                i + 1, PlayerData[topPlayers[i]][PL_NAME], topWins[i], PlayerData[topPlayers[i]][PL_SCORE]);
            SCM(playerid, COLOR_WHITE, str);
        }
    }
    SCM(playerid, COLOR_GREEN, "=============================================");
    return 1;
}

CMD:ajuda(playerid, params[])
{
    SCM(playerid, COLOR_GREEN, "============ DERBY V3 - COMANDOS ============");
    SCM(playerid, COLOR_WHITE, "  /derby    - Menu principal (FUN/Treino/Criar Sala)");
    SCM(playerid, COLOR_WHITE, "  /sair     - Sair da sala atual");
    SCM(playerid, COLOR_WHITE, "  /host     - Controles do Host (se for Host)");
    SCM(playerid, COLOR_WHITE, "  /iniciar  - Iniciar partida (Host)");
    SCM(playerid, COLOR_WHITE, "  /stats    - Ver suas estatisticas");
    SCM(playerid, COLOR_WHITE, "  /top      - Ranking top 10");
    SCM(playerid, COLOR_WHITE, "  /sala     - Info da sala atual");
    SCM(playerid, COLOR_GREEN, "=============================================");
    SCM(playerid, COLOR_GREY, "Nitro: Segure o botao de TIRO para ativar!");
    return 1;
}

CMD:help(playerid, params[])
{
    SCM(playerid, COLOR_GREEN, "============ DERBY V3 - COMANDOS ============");
    SCM(playerid, COLOR_WHITE, "  /derby    - Menu principal (FUN/Treino/Criar Sala)");
    SCM(playerid, COLOR_WHITE, "  /sair     - Sair da sala atual");
    SCM(playerid, COLOR_WHITE, "  /host     - Controles do Host (se for Host)");
    SCM(playerid, COLOR_WHITE, "  /iniciar  - Iniciar partida (Host)");
    SCM(playerid, COLOR_WHITE, "  /stats    - Ver suas estatisticas");
    SCM(playerid, COLOR_WHITE, "  /top      - Ranking top 10");
    SCM(playerid, COLOR_WHITE, "  /sala     - Info da sala atual");
    SCM(playerid, COLOR_GREEN, "=============================================");
    SCM(playerid, COLOR_GREY, "Nitro: Segure o botao de TIRO para ativar!");
    return 1;
}


CMD:sala(playerid, params[])
{
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(roomid == INVALID_ROOM_ID)
    {
        SCM(playerid, COLOR_ORANGE, "| DERBY | Voce nao esta em nenhuma sala!");
        return 1;
    }
    
    new str[256], modename[20], statename[20], vehname[24];
    SCM(playerid, COLOR_CYAN, "============ INFO DA SALA ============");
    
    format(str, sizeof(str), "  Nome: {FFFF00}%s", RoomData[roomid][ROOM_NAME]);
    SCM(playerid, COLOR_WHITE, str);
    
    GetModeName(RoomData[roomid][ROOM_MODE], modename);
    format(str, sizeof(str), "  Modo: {00FF00}%s", modename);
    SCM(playerid, COLOR_WHITE, str);
    
    GetRoomStateName(RoomData[roomid][ROOM_STATE], statename);
    format(str, sizeof(str), "  Status: {00FF00}%s", statename);
    SCM(playerid, COLOR_WHITE, str);
    
    format(str, sizeof(str), "  Jogadores: {FFFF00}%d/%d",
        RoomData[roomid][ROOM_PLAYER_COUNT], RoomData[roomid][ROOM_MAX_PLAYERS]);
    SCM(playerid, COLOR_WHITE, str);
    
    format(str, sizeof(str), "  Rounds: {FFFF00}%d/%d",
        RoomData[roomid][ROOM_CURRENT_ROUND], RoomData[roomid][ROOM_TOTAL_ROUNDS]);
    SCM(playerid, COLOR_WHITE, str);
    
    GetVehicleNameByModel(RoomData[roomid][ROOM_VEHICLE], vehname);
    format(str, sizeof(str), "  Veiculo: {FFFF00}%s", vehname);
    SCM(playerid, COLOR_WHITE, str);
    
    format(str, sizeof(str), "  Mapas: {FFFF00}%d selecionados", RoomData[roomid][ROOM_MAP_COUNT]);
    SCM(playerid, COLOR_WHITE, str);
    
    if(RoomData[roomid][ROOM_HOST] != INVALID_PLAYER && IsPlayerConnected(RoomData[roomid][ROOM_HOST]))
    {
        format(str, sizeof(str), "  Host: {00FFFF}%s", PlayerData[RoomData[roomid][ROOM_HOST]][PL_NAME]);
        SCM(playerid, COLOR_WHITE, str);
    }
    
    if(RoomData[roomid][ROOM_MODE] == MODE_CLA_VS_CLA)
    {
        format(str, sizeof(str), "  Placar: {FF4444}ALPHA %d{FFFFFF} x {4444FF}%d BETA",
            RoomData[roomid][ROOM_SCORE_ALPHA], RoomData[roomid][ROOM_SCORE_BETA]);
        SCM(playerid, COLOR_WHITE, str);
    }
    
    SCM(playerid, COLOR_CYAN, "======================================");
    return 1;
}

// =============================================================================
// ADMIN COMMANDS
// =============================================================================

CMD:reloadmaps(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO] Apenas RCON admins.");
    
    LoadMapList("DERBY/derbys.sfr");
    LoadAllMaps();
    
    // Atualizar sala FUN com novos mapas
    RoomData[FUN_ROOM_ID][ROOM_MAP_COUNT] = TotalMaps;
    for(new i = 0; i < TotalMaps && i < MAX_ROOM_MAPS; i++)
        RoomData[FUN_ROOM_ID][ROOM_SELECTED_MAPS][i] = i;
    
    new str[64];
    format(str, sizeof(str), "| ADMIN | Mapas recarregados: %d mapas.", TotalMaps);
    SCM(playerid, COLOR_GREEN, str);
    return 1;
}

CMD:skimap(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO] Apenas RCON admins.");
    
    if(RoomData[FUN_ROOM_ID][ROOM_STATE] == ROOM_STATE_RUNNING)
    {
        SendRoomMessage(FUN_ROOM_ID, COLOR_YELLOW, "| ADMIN | Mapa pulado!");
        RoomData[FUN_ROOM_ID][ROOM_ALIVE_COUNT] = 0;
        EndRound(FUN_ROOM_ID, NO_WINNER);
    }
    else
    {
        SCM(playerid, COLOR_ORANGE, "| DERBY | Sala FUN nao esta em partida.");
    }
    return 1;
}

CMD:fechar(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO] Apenas RCON admins.");
    
    new roomid;
    if(sscanf(params, "d", roomid))
        return SCM(playerid, COLOR_GREY, "Uso: /fechar [room_id]");
    
    if(roomid <= 0 || roomid >= MAX_ROOMS)
        return SCM(playerid, COLOR_RED, "[ERRO] ID de sala invalido (1-9).");
    
    if(RoomData[roomid][ROOM_STATE] == ROOM_STATE_EMPTY)
        return SCM(playerid, COLOR_ORANGE, "| DERBY | Sala ja esta vazia.");
    
    SendRoomMessage(roomid, COLOR_RED, "| ADMIN | Sala fechada pelo administrador!");
    DestroyRoom(roomid);
    SCM(playerid, COLOR_GREEN, "| ADMIN | Sala fechada com sucesso.");
    return 1;
}

// =============================================================================
// FIM DO GAMEMODE
// =============================================================================
