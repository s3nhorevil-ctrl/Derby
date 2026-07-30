// =============================================================================
// MODE_CLA.INC - Modo CLA VS CLA (competitivo, controlado por RCON)
// =============================================================================

// --- Estado do CLA ---
enum E_CLA_STATE
{
    CLA_OFF,            // sala fechada
    CLA_LOBBY,          // sala aberta, aguardando config
    CLA_COUNTDOWN,      // contagem regressiva
    CLA_RUNNING,        // round em andamento
    CLA_PAUSED,         // round pausado
    CLA_TRAINING        // modo treinamento livre
};

enum E_CLA_DATA
{
    E_CLA_STATE:cState,
    cMapID,
    cVehicle,
    cRounds,
    cCurrentRound,
    cScore[2],          // placar [time0, time1]
    cTimer
};

new Cla[E_CLA_DATA];

// Cores dos times
#define CLA_TEAM1_COLOR     0xFF3333FF  // Vermelho
#define CLA_TEAM2_COLOR     0x3399FFFF  // Azul

forward Cla_CountdownTick();
forward Cla_RespawnPlayer(playerid);

// =============================================================================
// FUNCOES AUXILIARES
// =============================================================================

stock Cla_CountTeam(team)
{
    new count = 0;
    Loop(i, pool) if(IsPlayerInCla(i) && Player[i][pClaTeam] == team) count++;
    return count;
}

stock Cla_CountAlive(team)
{
    new count = 0;
    Loop(i, pool) if(IsPlayerInCla(i) && Player[i][pClaTeam] == team && IsPlayerAlive(i)) count++;
    return count;
}

stock Cla_CountAll()
{
    new count = 0;
    Loop(i, pool) if(IsPlayerInCla(i)) count++;
    return count;
}

stock Cla_Broadcast(color, const msg[])
{
    Loop(i, pool) if(IsPlayerInCla(i)) SCM(i, color, msg);
}

// =============================================================================
// ENTRAR NO CLA
// =============================================================================

stock ModeCla_Join(playerid)
{
    if(Player[playerid][pMode] != MODE_NONE)
    {
        SCM(playerid, COL_RED, C_RED "Saia do modo atual primeiro (/sair).");
        return 0;
    }

    Player[playerid][pMode] = MODE_CLA;
    Player[playerid][pClaTeam] = -1;
    Player[playerid][pMatchState] = PSTATE_ALIVE;
    Player[playerid][pVehicleID] = INVALID_VEHICLE_ID;

    if(Cla[cState] == CLA_OFF)
        Cla[cState] = CLA_LOBBY;

    // Se tem mapa carregado, spawnar com carro (modo livre)
    if(Cla[cMapID] >= 0 && Cla[cMapID] < TotalMaps && MapInfo[Cla[cMapID]][mapVW] > 0)
    {
        Cla_SpawnPlayer(playerid);
    }
    else
    {
        SetPlayerPos(playerid, 0.0, 0.0, 20.0);
        SetPlayerVirtualWorld(playerid, VW_CLA);
    }

    SCM(playerid, COL_GREEN, C_GREEN ">> Voce entrou no " C_BLUE "CLA VS CLA" C_GREEN "!");
    SCM(playerid, COL_GREY, C_GREY "   Modo livre ativado. Aguarde o admin configurar (/cla).");

    new msg[100];
    format(msg, sizeof(msg), C_BLUE ">> " C_WHITE "%s entrou no CLA. Total: %d",
        Player[playerid][pName], Cla_CountAll());
    Cla_Broadcast(COL_BLUE, msg);
    return 1;
}

// =============================================================================
// SAIR DO CLA
// =============================================================================

stock ModeCla_Leave(playerid)
{
    if(!IsPlayerInCla(playerid)) return 0;

    DestroyPlayerVehicle(playerid);
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
        TogglePlayerSpectating(playerid, false);
    TogglePlayerControllable(playerid, true);

    Player[playerid][pMode] = MODE_NONE;
    Player[playerid][pClaTeam] = -1;
    Player[playerid][pMatchState] = PSTATE_ALIVE;

    // Checar fim de round se estava em partida
    if(Cla[cState] == CLA_RUNNING)
        Cla_CheckRoundEnd();

    return 1;
}

// =============================================================================
// SPAWNAR JOGADOR NO MAPA DO CLA (modo livre)
// =============================================================================

stock Cla_SpawnPlayer(playerid)
{
    DestroyPlayerVehicle(playerid);

    new mapid = Cla[cMapID];
    new slot = Cla_CountAll() % MAX_DERBY_SLOTS;
    Player[playerid][pSpawnSlot] = slot;

    new Float:x = MapSpawns[mapid][slot][0];
    new Float:y = MapSpawns[mapid][slot][1];
    new Float:z = MapSpawns[mapid][slot][2] + 2.0;
    new Float:a = MapSpawns[mapid][slot][3];
    new veh = (Cla[cVehicle] >= 400) ? Cla[cVehicle] : MapInfo[mapid][mapVehicle];

    SetPlayerVirtualWorld(playerid, MapInfo[mapid][mapVW]);
    SetPlayerInterior(playerid, 0);
    SetPlayerHealth(playerid, 100.0);

    Player[playerid][pVehicleID] = CreateVehicle(veh, x, y, z, a, -1, -1, 99999, false);
    SetVehicleVirtualWorld(Player[playerid][pVehicleID], MapInfo[mapid][mapVW]);
    PutPlayerInVehicle(playerid, Player[playerid][pVehicleID], 0);
    SetVehicleParamsEx(Player[playerid][pVehicleID], 1, 1, 0, 1, 0, 0, 0);
    AddVehicleComponent(Player[playerid][pVehicleID], NITRO_COMPONENT);
    TogglePlayerControllable(playerid, true);
    SetPlayerTime(playerid, MapInfo[mapid][mapHour], 0);
    SetPlayerWeather(playerid, MapInfo[mapid][mapWeather]);
}

// =============================================================================
// CARREGAR MAPA E TELEPORTAR TODOS
// =============================================================================

stock Cla_LoadMap(mapid)
{
    if(!Maps_Load(mapid)) return 0;
    Cla[cMapID] = mapid;

    // Teleportar todos
    Loop(i, pool)
    {
        if(!IsPlayerInCla(i)) continue;
        if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            TogglePlayerSpectating(i, false);
        Player[i][pMatchState] = PSTATE_ALIVE;
        Cla_SpawnPlayer(i);
    }

    new msg[100];
    format(msg, sizeof(msg), C_BLUE ">> " C_WHITE "Mapa carregado: " C_GOLD "%s " C_WHITE "| Todos teleportados!",
        MapInfo[mapid][mapName]);
    Cla_Broadcast(COL_BLUE, msg);
    return 1;
}

// =============================================================================
// INICIAR ROUND
// =============================================================================

stock Cla_StartRound(adminid)
{
    if(Cla[cState] == CLA_RUNNING)
        return SCM(adminid, COL_RED, C_RED "Round ja em andamento.");

    if(Cla[cMapID] < 0 || Cla[cMapID] >= TotalMaps)
        return SCM(adminid, COL_RED, C_RED "Selecione um mapa primeiro.");

    Cla[cState] = CLA_COUNTDOWN;
    Cla[cCurrentRound]++;

    // Reposicionar todos
    new slot = 0;
    Loop(i, pool)
    {
        if(!IsPlayerInCla(i)) continue;
        if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            TogglePlayerSpectating(i, false);
        Player[i][pMatchState] = PSTATE_ALIVE;
        Player[i][pSpawnSlot] = slot % MAX_DERBY_SLOTS;
        DestroyPlayerVehicle(i);
        Cla_SpawnPlayer(i);
        TogglePlayerControllable(i, false);
        SetVehicleParamsEx(Player[i][pVehicleID], 0, 0, 0, 1, 0, 0, 0);
        slot++;
    }

    // Countdown de 3 segundos
    new msg[80];
    format(msg, sizeof(msg), C_GREEN ">> Round %d/%d iniciando em 3...", Cla[cCurrentRound], Cla[cRounds]);
    Cla_Broadcast(COL_GREEN, msg);

    KillTimer(Cla[cTimer]);
    Cla[cTimer] = SetTimer("Cla_CountdownTick", 3000, false);
    return 1;
}

public Cla_CountdownTick()
{
    Cla[cState] = CLA_RUNNING;

    Loop(i, pool)
    {
        if(!IsPlayerInCla(i) || !IsPlayerAlive(i)) continue;
        TogglePlayerControllable(i, true);
        SetVehicleParamsEx(Player[i][pVehicleID], 1, 1, 0, 1, 0, 0, 0);
        PlayerPlaySound(i, 3200, 0.0, 0.0, 0.0);
        GameTextForPlayer(i, "~g~GO!", 2000, 3);
    }
    Cla_Broadcast(COL_GREEN, C_GREEN ">> GO! GO! GO!");
    return 1;
}

// =============================================================================
// PAUSAR / DESPAUSAR
// =============================================================================

stock Cla_TogglePause(adminid)
{
    if(Cla[cState] == CLA_RUNNING)
    {
        Cla[cState] = CLA_PAUSED;
        Loop(i, pool) if(IsPlayerInCla(i)) TogglePlayerControllable(i, false);
        Cla_Broadcast(COL_YELLOW, C_YELLOW ">> Round PAUSADO.");
    }
    else if(Cla[cState] == CLA_PAUSED)
    {
        Cla[cState] = CLA_RUNNING;
        Loop(i, pool) if(IsPlayerInCla(i) && IsPlayerAlive(i)) TogglePlayerControllable(i, true);
        Cla_Broadcast(COL_GREEN, C_GREEN ">> Round RETOMADO!");
    }
    else
    {
        SCM(adminid, COL_RED, C_RED "Nenhum round para pausar.");
    }
    return 1;
}

// =============================================================================
// JOGADOR MORREU NO CLA
// =============================================================================

stock Cla_PlayerDied(playerid)
{
    // MODO TREINAMENTO: respawn automatico
    if(Cla[cState] == CLA_TRAINING || Cla[cState] == CLA_LOBBY)
    {
        DestroyPlayerVehicle(playerid);
        new phrase[50];
        GetRespawnPhrase(phrase, sizeof(phrase));
        GameTextForPlayer(playerid, phrase, 2000, 3);
        // Respawn com pequeno delay
        SetTimerEx("Cla_RespawnPlayer", RESPAWN_DELAY_MS, false, "i", playerid);
        return 1;
    }

    // MODO COMPETITIVO
    Player[playerid][pMatchState] = PSTATE_DEAD;
    DestroyPlayerVehicle(playerid);

    new msg[100];
    format(msg, sizeof(msg), C_RED ">> " C_WHITE "%s " C_RED "foi eliminado!", Player[playerid][pName]);
    Cla_Broadcast(COL_RED, msg);

    // Spectate
    TogglePlayerSpectating(playerid, true);
    Loop(i, pool)
    {
        if(i == playerid) continue;
        if(IsPlayerInCla(i) && IsPlayerAlive(i) && Player[i][pVehicleID] != INVALID_VEHICLE_ID)
        {
            PlayerSpectateVehicle(playerid, Player[i][pVehicleID]);
            break;
        }
    }

    Cla_CheckRoundEnd();
    return 1;
}

public Cla_RespawnPlayer(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerInCla(playerid)) return 0;
    Cla_SpawnPlayer(playerid);
    return 1;
}

// =============================================================================
// VERIFICAR FIM DO ROUND
// =============================================================================

stock Cla_CheckRoundEnd()
{
    if(Cla[cState] != CLA_RUNNING) return 0;

    new alive0 = Cla_CountAlive(0);
    new alive1 = Cla_CountAlive(1);

    if(alive0 > 0 && alive1 > 0) return 0; // ainda tem dos dois

    new winner = -1;
    if(alive0 == 0 && alive1 == 0) winner = -1; // empate
    else if(alive0 == 0) winner = 1;
    else if(alive1 == 0) winner = 0;

    Cla_EndRound(winner);
    return 1;
}

// =============================================================================
// FIM DO ROUND
// =============================================================================

stock Cla_EndRound(winner)
{
    Cla[cState] = CLA_LOBBY;
    KillTimer(Cla[cTimer]);

    if(winner >= 0 && winner <= 1)
    {
        Cla[cScore][winner]++;
        new msg[120];
        format(msg, sizeof(msg), C_GOLD ">> CLA %d venceu o round %d! " C_WHITE "Placar: " C_RED "%d " C_WHITE "x " C_BLUE "%d",
            winner + 1, Cla[cCurrentRound], Cla[cScore][0], Cla[cScore][1]);
        Cla_Broadcast(COL_GOLD, msg);
    }
    else
    {
        Cla_Broadcast(COL_YELLOW, C_YELLOW ">> Round empatou!");
    }

    // Verificar fim da serie
    if(Cla[cCurrentRound] >= Cla[cRounds])
    {
        new final_msg[120];
        if(Cla[cScore][0] > Cla[cScore][1])
            format(final_msg, sizeof(final_msg), C_RED ">> CLA 1 E O CAMPEAO! " C_WHITE "%d x %d", Cla[cScore][0], Cla[cScore][1]);
        else if(Cla[cScore][1] > Cla[cScore][0])
            format(final_msg, sizeof(final_msg), C_BLUE ">> CLA 2 E O CAMPEAO! " C_WHITE "%d x %d", Cla[cScore][0], Cla[cScore][1]);
        else
            format(final_msg, sizeof(final_msg), C_YELLOW ">> EMPATE GERAL! " C_WHITE "%d x %d", Cla[cScore][0], Cla[cScore][1]);
        Cla_Broadcast(COL_GOLD, final_msg);
    }
    else
    {
        Cla_Broadcast(COL_GREY, C_GREY "   Aguardando admin iniciar proximo round...");
    }

    // Descongelar todos e parar spectate
    Loop(i, pool)
    {
        if(!IsPlayerInCla(i)) continue;
        if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            TogglePlayerSpectating(i, false);
        Player[i][pMatchState] = PSTATE_ALIVE;
        TogglePlayerControllable(i, true);
        Cla_SpawnPlayer(i); // volta pra plataforma
    }
    return 1;
}

// =============================================================================
// INICIAR/PARAR TREINAMENTO
// =============================================================================

stock Cla_ToggleTraining(adminid)
{
    if(Cla[cState] == CLA_TRAINING)
    {
        Cla[cState] = CLA_LOBBY;
        Cla_Broadcast(COL_ORANGE, C_ORANGE ">> Treinamento DESATIVADO.");
    }
    else
    {
        if(Cla[cMapID] < 0 || Cla[cMapID] >= TotalMaps)
            return SCM(adminid, COL_RED, C_RED "Selecione um mapa primeiro.");
        Cla[cState] = CLA_TRAINING;
        Cla_LoadMap(Cla[cMapID]);
        Cla_Broadcast(COL_CYAN, C_CYAN ">> TREINAMENTO ativado! Ao cair, voce volta automaticamente.");
    }
    return 1;
}

// =============================================================================
// ENCERRAR TUDO
// =============================================================================

stock Cla_Shutdown()
{
    KillTimer(Cla[cTimer]);
    Loop(i, pool)
    {
        if(!IsPlayerInCla(i)) continue;
        DestroyPlayerVehicle(i);
        if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            TogglePlayerSpectating(i, false);
        TogglePlayerControllable(i, true);
        Player[i][pMode] = MODE_NONE;
        Player[i][pClaTeam] = -1;
        SetPlayerVirtualWorld(i, VW_LOBBY);
        SetPlayerPos(i, 0.0, 0.0, 20.0);
    }
    Cla[cState] = CLA_OFF;
    Cla[cMapID] = -1;
    Cla[cCurrentRound] = 0;
    Cla[cScore][0] = 0;
    Cla[cScore][1] = 0;
    Cla_Broadcast(COL_RED, C_RED ">> CLA VS CLA encerrado pelo administrador.");
    return 1;
}

// =============================================================================
// RESET (chamado no init)
// =============================================================================

stock Cla_Reset()
{
    Cla[cState] = CLA_OFF;
    Cla[cMapID] = -1;
    Cla[cVehicle] = 411;
    Cla[cRounds] = 5;
    Cla[cCurrentRound] = 0;
    Cla[cScore][0] = 0;
    Cla[cScore][1] = 0;
    Cla[cTimer] = -1;
}

// =============================================================================
// PAINEL DO ADMIN (/cla)
// =============================================================================

stock Cla_ShowPanel(playerid)
{
    new info[500], tmp[100];

    format(tmp, sizeof(tmp), C_WHITE "Veiculo\t" C_GREEN "%d\n", Cla[cVehicle]);
    strcat(info, tmp);

    format(tmp, sizeof(tmp), C_WHITE "Mapa\t" C_GREEN "%s\n",
        (Cla[cMapID] >= 0 && Cla[cMapID] < TotalMaps) ? MapInfo[Cla[cMapID]][mapName] : "Nenhum");
    strcat(info, tmp);

    format(tmp, sizeof(tmp), C_WHITE "Rounds\t" C_GREEN "%d\n", Cla[cRounds]);
    strcat(info, tmp);

    format(tmp, sizeof(tmp), C_WHITE "Membros\t" C_GREEN "T1:%d | T2:%d | Total:%d\n",
        Cla_CountTeam(0), Cla_CountTeam(1), Cla_CountAll());
    strcat(info, tmp);

    if(Cla[cState] == CLA_RUNNING || Cla[cState] == CLA_PAUSED)
        strcat(info, C_YELLOW "INICIAR/PAUSAR ROUND\t" C_YELLOW "-\n");
    else
        strcat(info, C_GREEN "INICIAR ROUND\t" C_GREEN "-\n");

    if(Cla[cState] != CLA_TRAINING)
        strcat(info, C_CYAN "TREINAMENTO (ON)\t" C_CYAN "respawn ao cair\n");
    else
        strcat(info, C_ORANGE "TREINAMENTO (OFF)\t" C_ORANGE "desativar\n");

    format(tmp, sizeof(tmp), C_GREY "Placar: %d x %d | Round %d/%d\t-\n",
        Cla[cScore][0], Cla[cScore][1], Cla[cCurrentRound], Cla[cRounds]);
    strcat(info, tmp);

    strcat(info, C_RED "ENCERRAR TUDO\t-\n");

    ShowPlayerDialog(playerid, DLG_CLA_PANEL, DIALOG_STYLE_TABLIST,
        C_BLUE "CLA VS CLA - Painel Admin", info, "OK", "Fechar");
    return 1;
}

stock Cla_ShowMapList(playerid)
{
    new info[3000], tmp[50];
    for(new i = 0; i < TotalMaps && strlen(info) < 2900; i++)
    {
        format(tmp, sizeof(tmp), "%s\n", MapInfo[i][mapName]);
        strcat(info, tmp);
    }
    ShowPlayerDialog(playerid, DLG_CLA_MAP, DIALOG_STYLE_LIST,
        C_BLUE "Selecione o mapa (carrega instantaneo!)", info, "Selecionar", "Voltar");
    return 1;
}

stock Cla_ShowMembers(playerid)
{
    new info[2000], tmp[80];
    Loop(i, pool)
    {
        if(!IsPlayerInCla(i)) continue;
        new team_txt[16];
        if(Player[i][pClaTeam] == 0) team_txt = C_RED "CLA 1";
        else if(Player[i][pClaTeam] == 1) team_txt = C_BLUE "CLA 2";
        else team_txt = C_GREY "Sem time";
        format(tmp, sizeof(tmp), "%s " C_WHITE "(%d)\t%s\n", Player[i][pName], i, team_txt);
        if(strlen(info) + strlen(tmp) >= sizeof(info) - 2) break;
        strcat(info, tmp);
    }
    if(strlen(info) < 2) strcat(info, "Nenhum jogador\n");
    ShowPlayerDialog(playerid, DLG_CLA_MEMBERS, DIALOG_STYLE_TABLIST,
        C_BLUE "Membros (clique para trocar time)", info, "Trocar", "Voltar");
    return 1;
}

// =============================================================================
// HANDLER DE DIALOGOS DO CLA
// =============================================================================

stock Cla_HandleDialog(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DLG_CLA_PANEL)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0: // Veiculo
            {
                ShowPlayerDialog(playerid, DLG_CLA_VEHICLE, DIALOG_STYLE_INPUT,
                    C_BLUE "Veiculo", C_WHITE "Digite o ID do veiculo (400-611):", "OK", "Voltar");
            }
            case 1: Cla_ShowMapList(playerid);
            case 2: // Rounds
            {
                ShowPlayerDialog(playerid, DLG_CLA_ROUNDS, DIALOG_STYLE_INPUT,
                    C_BLUE "Rounds", C_WHITE "Quantos rounds? (1-30):", "OK", "Voltar");
            }
            case 3: Cla_ShowMembers(playerid);
            case 4: // Iniciar/Pausar
            {
                if(Cla[cState] == CLA_RUNNING || Cla[cState] == CLA_PAUSED)
                    Cla_TogglePause(playerid);
                else
                    Cla_StartRound(playerid);
                Cla_ShowPanel(playerid);
            }
            case 5: // Treinamento
            {
                Cla_ToggleTraining(playerid);
                Cla_ShowPanel(playerid);
            }
            case 6: Cla_ShowPanel(playerid); // placar
            case 7: Cla_Shutdown(); // encerrar
        }
        return 1;
    }

    if(dialogid == DLG_CLA_VEHICLE)
    {
        if(!response) return Cla_ShowPanel(playerid);
        new v = strval(inputtext);
        if(v < 400 || v > 611) SCM(playerid, COL_RED, C_RED "ID invalido (400-611).");
        else { Cla[cVehicle] = v; SCM(playerid, COL_GREEN, C_GREEN "Veiculo definido!"); }
        return Cla_ShowPanel(playerid);
    }

    if(dialogid == DLG_CLA_ROUNDS)
    {
        if(!response) return Cla_ShowPanel(playerid);
        new v = strval(inputtext);
        if(v < 1 || v > 30) SCM(playerid, COL_RED, C_RED "Valor invalido (1-30).");
        else { Cla[cRounds] = v; SCM(playerid, COL_GREEN, C_GREEN "Rounds definidos!"); }
        return Cla_ShowPanel(playerid);
    }

    if(dialogid == DLG_CLA_MAP)
    {
        if(!response) return Cla_ShowPanel(playerid);
        if(listitem >= 0 && listitem < TotalMaps)
            Cla_LoadMap(listitem);
        return Cla_ShowPanel(playerid);
    }

    if(dialogid == DLG_CLA_MEMBERS)
    {
        if(!response) return Cla_ShowPanel(playerid);
        // Encontrar o jogador clicado
        new idx = 0, target = INVALID_PLAYER_ID;
        Loop(i, pool)
        {
            if(!IsPlayerInCla(i)) continue;
            if(idx == listitem) { target = i; break; }
            idx++;
        }
        if(target != INVALID_PLAYER_ID)
        {
            // Ciclar: -1 -> 0 -> 1 -> -1
            Player[target][pClaTeam]++;
            if(Player[target][pClaTeam] > 1) Player[target][pClaTeam] = -1;

            if(Player[target][pClaTeam] == 0)
            {
                SetPlayerColor(target, CLA_TEAM1_COLOR);
                SCM(target, COL_RED, C_RED ">> Voce esta no CLA 1 (Vermelho)!");
            }
            else if(Player[target][pClaTeam] == 1)
            {
                SetPlayerColor(target, CLA_TEAM2_COLOR);
                SCM(target, COL_BLUE, C_BLUE ">> Voce esta no CLA 2 (Azul)!");
            }
            else
            {
                SetPlayerColor(target, COL_WHITE);
                SCM(target, COL_GREY, C_GREY ">> Voce foi removido do time.");
            }
        }
        return Cla_ShowMembers(playerid);
    }
    return 0;
}
