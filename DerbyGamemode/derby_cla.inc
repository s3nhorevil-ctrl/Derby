// =============================================================================
// SISTEMA CLA VS CLA - Totalmente manual controlado por RCON
// =============================================================================

// Enums e defines
#define CLA_VW          (200)

enum CLAINFO
{
    bool:CLA_ATIVO,         // sala CLA esta aberta?
    bool:CLA_RODANDO,       // round em andamento?
    bool:CLA_PAUSADO,       // round pausado?
    CLA_MAPA,               // indice do mapa selecionado
    CLA_VEICULO,            // id do veiculo
    CLA_ROUNDS,             // total de rounds configurado
    CLA_ROUND_ATUAL,        // round atual
    CLA_PONTOS[2],          // placar CLA1 x CLA2
    CLA_TIMEOUT_TIMER,      // timer do round
    bool:CLA_TREINO         // modo treinamento (respawn automatico)
};

new CLA[CLAINFO];

// Cores dos clas
#define CLA1_COLOR  0xFF0000FF  // Vermelho
#define CLA2_COLOR  0x0066FFFF  // Azul

// Estado do jogador no CLA
new CLA_TEAM[MAX_PLAYERS];          // -1=nenhum, 0=CLA1, 1=CLA2
new bool:CLA_INSCRITO[MAX_PLAYERS]; // esta na sala CLA?
new CLA_VEHICLEID[MAX_PLAYERS];     // veiculo no CLA
new CLA_POSITION[MAX_PLAYERS];      // slot de spawn

// =============================================================================
// FUNCOES AUXILIARES
// =============================================================================

ClaCountTeam(team)
{
    new count = 0;
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
        if(IsPlayerConnected(i) && CLA_INSCRITO[i] && CLA_TEAM[i] == team)
            count++;
    return count;
}

ClaCountAlive(team)
{
    new count = 0;
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
        if(IsPlayerConnected(i) && CLA_INSCRITO[i] && CLA_TEAM[i] == team && GetPlayerState(i) == PLAYER_STATE_DRIVER)
            count++;
    return count;
}

ClaCountTotal()
{
    new count = 0;
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
        if(IsPlayerConnected(i) && CLA_INSCRITO[i])
            count++;
    return count;
}

ClaReset()
{
    CLA[CLA_ATIVO] = false;
    CLA[CLA_TREINO] = false;
    CLA[CLA_RODANDO] = false;
    CLA[CLA_PAUSADO] = false;
    CLA[CLA_MAPA] = 0;
    CLA[CLA_VEICULO] = 411;
    CLA[CLA_ROUNDS] = 5;
    CLA[CLA_ROUND_ATUAL] = 0;
    CLA[CLA_PONTOS][0] = 0;
    CLA[CLA_PONTOS][1] = 0;
    KillTimer(CLA[CLA_TIMEOUT_TIMER]);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        CLA_TEAM[i] = -1;
        CLA_INSCRITO[i] = false;
        CLA_VEHICLEID[i] = INVALID_VEHICLE_ID;
    }
    return 1;
}

// =============================================================================
// PAINEL PRINCIPAL (/cla)
// =============================================================================

ClaShowPanel(playerid)
{
    new info[600], linha[120];

    format(linha, sizeof(linha), "{FFFFFF}Veiculo\t{00FF00}%d\n", CLA[CLA_VEICULO]);
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFFFF}Mapa\t{00FF00}%s\n",
        (CLA[CLA_MAPA] >= 0 && CLA[CLA_MAPA] < TOTAL_DERBYS) ? DERBY_MAPNAME[CLA[CLA_MAPA]] : "nenhum");
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFFFF}Rounds\t{00FF00}%d\n", CLA[CLA_ROUNDS]);
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFFFF}Membros\t{00FF00}CLA1: %d | CLA2: %d | Total: %d\n",
        ClaCountTeam(0), ClaCountTeam(1), ClaCountTotal());
    strcat(info, linha);

    if(CLA[CLA_RODANDO] && !CLA[CLA_PAUSADO])
        strcat(info, "{FFFF00}>> PAUSAR ROUND\t{FFFF00}-\n");
    else if(CLA[CLA_RODANDO] && CLA[CLA_PAUSADO])
        strcat(info, "{00FF00}>> DESPAUSAR ROUND\t{00FF00}-\n");
    else
        strcat(info, "{00FF00}>> INICIAR ROUND\t{00FF00}-\n");

    if(!CLA[CLA_TREINO])
        strcat(info, "{00FFFF}>> INICIAR TREINAMENTO\t{00FFFF}(respawn ao cair)\n");
    else
        strcat(info, "{FF6600}>> PARAR TREINAMENTO\t{FF6600}-\n");

    format(linha, sizeof(linha), "{CCCCCC}Placar: {FF0000}CLA1 %d {FFFFFF}x {0066FF}%d CLA2 {CCCCCC}| Round %d/%d\t-\n",
        CLA[CLA_PONTOS][0], CLA[CLA_PONTOS][1], CLA[CLA_ROUND_ATUAL], CLA[CLA_ROUNDS]);
    strcat(info, linha);

    strcat(info, "{FF0000}>> ENCERRAR TUDO\t{FF0000}-\n");

    ShowPlayerDialog(playerid, DLG_CLA_CONFIG, DIALOG_STYLE_TABLIST,
        "CLA VS CLA - Painel RCON", info, "OK", "Fechar");
    return 1;
}

// =============================================================================
// LISTA DE MAPAS
// =============================================================================

ClaShowMapList(playerid)
{
    new info[4000], linha[64];
    for(new i = 0; i < TOTAL_DERBYS; i++)
    {
        format(linha, sizeof(linha), "%d - %s\n", i, DERBY_MAPNAME[i]);
        if(strlen(info) + strlen(linha) >= sizeof(info) - 2) break;
        strcat(info, linha);
    }
    ShowPlayerDialog(playerid, DLG_CLA_MAPA, DIALOG_STYLE_LIST,
        "CLA VS CLA - Escolha o mapa (carrega imediato!)", info, "Selecionar", "Voltar");
    return 1;
}

// =============================================================================
// LISTA DE MEMBROS (admin define os times)
// =============================================================================

ClaShowMembers(playerid)
{
    new info[3000], linha[100];
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(!CLA_INSCRITO[i]) continue;

        new team_txt[20];
        if(CLA_TEAM[i] == 0) team_txt = "{FF0000}CLA 1";
        else if(CLA_TEAM[i] == 1) team_txt = "{0066FF}CLA 2";
        else team_txt = "{999999}Sem time";

        format(linha, sizeof(linha), "%s {FFFFFF}(%d)\t%s\n", PI[i][P_NAME], i, team_txt);
        if(strlen(info) + strlen(linha) >= sizeof(info) - 2) break;
        strcat(info, linha);
    }

    if(strlen(info) < 2)
        strcat(info, "Nenhum jogador inscrito\n");

    ShowPlayerDialog(playerid, DLG_CLA_MEMBERS, DIALOG_STYLE_TABLIST,
        "Membros - Clique para trocar de time", info, "Trocar Time", "Voltar");
    return 1;
}

// =============================================================================
// CARREGAR MAPA E TELEPORTAR TODOS
// =============================================================================

ClaLoadMapAndTP(mapid)
{
    if(mapid < 0 || mapid >= TOTAL_DERBYS) return 0;

    CLA[CLA_MAPA] = mapid;

    // Carregar dados do mapa (.sfr) para pegar spawns
    if(!LoadDerby(mapid))
    {
        printf("[CLA] Erro ao carregar mapa %d", mapid);
        return 0;
    }
    DI[D_ID] = mapid;

    // Destruir veiculos antigos e reposicionar todos
    new slot = 0;
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i) || !CLA_INSCRITO[i]) continue;

        // Destruir veiculo anterior
        if(CLA_VEHICLEID[i] != INVALID_VEHICLE_ID && IsValidVehicle(CLA_VEHICLEID[i]))
        {
            DestroyVehicle(CLA_VEHICLEID[i]);
            CLA_VEHICLEID[i] = INVALID_VEHICLE_ID;
        }

        // Parar spectate se estiver
        if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            TogglePlayerSpectating(i, false);

        // Spawnar no mapa
        CLA_POSITION[i] = slot % MAX_DERBY_PLAYERS;
        SetPlayerVirtualWorld(i, DI[D_VW]);
        SetPlayerInterior(i, 0);
        SetPlayerHealth(i, 100.0);
        SetPlayerArmour(i, 0.0);

        // Criar veiculo
        new Float:x = DERBY_SPAWN[CLA_POSITION[i]][0];
        new Float:y = DERBY_SPAWN[CLA_POSITION[i]][1];
        new Float:z = DERBY_SPAWN[CLA_POSITION[i]][2] + 2.0;
        new Float:a = DERBY_SPAWN[CLA_POSITION[i]][3];

        CLA_VEHICLEID[i] = CreateVehicle(CLA[CLA_VEICULO], x, y, z, a, -1, -1, 99999, false);
        SetVehicleVirtualWorld(CLA_VEHICLEID[i], DI[D_VW]);
        PutPlayerInVehicle(i, CLA_VEHICLEID[i], 0);

        // Motor desligado ate iniciar
        SetVehicleParamsEx(CLA_VEHICLEID[i], VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, 1, 0, 0, 0);
        TogglePlayerControllable(i, false);

        SetPlayerTime(i, DI[D_HOUR], 0);
        SetPlayerWeather(i, DI[D_WEATHER]);

        slot++;
    }

    new msg[128];
    format(msg, sizeof(msg), "{FFFF00}| CLA | Mapa carregado: {FFFFFF}%s {FFFF00}| Todos teleportados!", DERBY_MAPNAME[mapid]);
    ClaSendMsg(COLOR_YELLOW, msg);
    return 1;
}

// =============================================================================
// INICIAR ROUND
// =============================================================================

ClaStartRound(playerid)
{
    if(CLA[CLA_RODANDO])
        return SCM(playerid, COLOR_RED, "[ERRO]: Ja tem um round em andamento. Pause ou espere terminar.");

    if(ClaCountTeam(0) < 1 || ClaCountTeam(1) < 1)
        return SCM(playerid, COLOR_RED, "[ERRO]: Precisa de pelo menos 1 jogador em cada CLA.");

    if(CLA[CLA_VEICULO] < 400 || CLA[CLA_VEICULO] > 611)
        return SCM(playerid, COLOR_RED, "[ERRO]: ID de veiculo invalido (400-611).");

    CLA[CLA_RODANDO] = true;
    CLA[CLA_PAUSADO] = false;
    CLA[CLA_ROUND_ATUAL]++;

    // Recarregar mapa e posicionar todos
    ClaLoadMapAndTP(CLA[CLA_MAPA]);

    // Ligar motores e descongelar apos 3 segundos
    SetTimer("ClaGoTimer", 3000, false);

    new msg[128];
    format(msg, sizeof(msg), "{00FF00}| CLA | Round %d/%d iniciando em 3 segundos...",
        CLA[CLA_ROUND_ATUAL], CLA[CLA_ROUNDS]);
    ClaSendMsg(COLOR_GREEN, msg);
    return 1;
}

forward ClaGoTimer();
public ClaGoTimer()
{
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i) || !CLA_INSCRITO[i]) continue;
        if(CLA_TEAM[i] == -1) continue;

        TogglePlayerControllable(i, true);
        if(CLA_VEHICLEID[i] != INVALID_VEHICLE_ID)
            SetVehicleParamsEx(CLA_VEHICLEID[i], VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, 1, 0, 0, 0);

        GameTextForPlayer(i, "~g~GO!", 2000, 3);
        PlayerPlaySound(i, 3200, 0.0, 0.0, 0.0);
    }
    ClaSendMsg(COLOR_GREEN, "{00FF00}| CLA | GO! GO! GO!");
    return 1;
}

// =============================================================================
// PAUSAR / DESPAUSAR
// =============================================================================

ClaTogglePause(playerid)
{
    if(!CLA[CLA_RODANDO])
        return SCM(playerid, COLOR_RED, "[ERRO]: Nenhum round em andamento.");

    CLA[CLA_PAUSADO] = !CLA[CLA_PAUSADO];

    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i) || !CLA_INSCRITO[i]) continue;
        TogglePlayerControllable(i, !CLA[CLA_PAUSADO]);
    }

    if(CLA[CLA_PAUSADO])
        ClaSendMsg(COLOR_YELLOW, "{FFFF00}| CLA | Round PAUSADO pelo administrador.");
    else
        ClaSendMsg(COLOR_GREEN, "{00FF00}| CLA | Round DESPAUSADO! Continuem!");

    return 1;
}

// =============================================================================
// VERIFICAR FIM DO ROUND (chamado quando alguem cai)
// =============================================================================

ClaPlayerDied(playerid)
{
    // Destruir veiculo
    if(CLA_VEHICLEID[playerid] != INVALID_VEHICLE_ID && IsValidVehicle(CLA_VEHICLEID[playerid]))
    {
        DestroyVehicle(CLA_VEHICLEID[playerid]);
        CLA_VEHICLEID[playerid] = INVALID_VEHICLE_ID;
    }

    // MODO TREINAMENTO: respawna automaticamente na plataforma
    if(CLA[CLA_TREINO])
    {
        new slot = CLA_POSITION[playerid];
        new Float:x = DERBY_SPAWN[slot][0];
        new Float:y = DERBY_SPAWN[slot][1];
        new Float:z = DERBY_SPAWN[slot][2] + 2.0;
        new Float:a = DERBY_SPAWN[slot][3];

        CLA_VEHICLEID[playerid] = CreateVehicle(CLA[CLA_VEICULO], x, y, z, a, -1, -1, 99999, false);
        SetVehicleVirtualWorld(CLA_VEHICLEID[playerid], DI[D_VW]);
        PutPlayerInVehicle(playerid, CLA_VEHICLEID[playerid], 0);
        SetVehicleParamsEx(CLA_VEHICLEID[playerid], VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, 1, 0, 0, 0);
        AddVehicleComponent(CLA_VEHICLEID[playerid], 1010); // Nitro
        TogglePlayerControllable(playerid, true);

        // Frase comica de respawn
        new frase[50];
        switch(random(5))
        {
            case 0: frase = "~r~CAIU! ~w~Tenta de novo!";
            case 1: frase = "~r~FAIL! ~w~Mais uma vez!";
            case 2: frase = "~r~OPS! ~w~Voltando...";
            case 3: frase = "~r~MERGULHOU! ~w~De novo!";
            case 4: frase = "~r~TOMBOU! ~w~Vai la!";
        }
        GameTextForPlayer(playerid, frase, 2000, 3);
        return 1;
    }

    // MODO COMPETITIVO: eliminado de verdade
    new msg[128];
    format(msg, sizeof(msg), "{FF0000}| CLA | %s foi eliminado!", PI[playerid][P_NAME]);
    ClaSendMsg(COLOR_RED, msg);

    // Spectate
    TogglePlayerSpectating(playerid, true);
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i) || !CLA_INSCRITO[i] || i == playerid) continue;
        if(CLA_VEHICLEID[i] != INVALID_VEHICLE_ID && GetPlayerState(i) == PLAYER_STATE_DRIVER)
        {
            PlayerSpectateVehicle(playerid, CLA_VEHICLEID[i]);
            break;
        }
    }

    // Verificar se algum cla foi eliminado
    new alive0 = ClaCountAlive(0);
    new alive1 = ClaCountAlive(1);

    if(alive0 == 0 && alive1 == 0)
        ClaEndRound(-1);
    else if(alive0 == 0)
        ClaEndRound(1);
    else if(alive1 == 0)
        ClaEndRound(0);

    return 1;
}

// =============================================================================
// FIM DO ROUND
// =============================================================================

ClaEndRound(winner)
{
    CLA[CLA_RODANDO] = false;
    CLA[CLA_PAUSADO] = false;

    new msg[160];
    if(winner == 0)
    {
        CLA[CLA_PONTOS][0]++;
        format(msg, sizeof(msg), "{FF0000}| CLA | CLA 1 venceu o round %d! {FFFFFF}Placar: {FF0000}%d {FFFFFF}x {0066FF}%d",
            CLA[CLA_ROUND_ATUAL], CLA[CLA_PONTOS][0], CLA[CLA_PONTOS][1]);
    }
    else if(winner == 1)
    {
        CLA[CLA_PONTOS][1]++;
        format(msg, sizeof(msg), "{0066FF}| CLA | CLA 2 venceu o round %d! {FFFFFF}Placar: {FF0000}%d {FFFFFF}x {0066FF}%d",
            CLA[CLA_ROUND_ATUAL], CLA[CLA_PONTOS][0], CLA[CLA_PONTOS][1]);
    }
    else
    {
        format(msg, sizeof(msg), "{FFFF00}| CLA | Round %d empatou! {FFFFFF}Placar: {FF0000}%d {FFFFFF}x {0066FF}%d",
            CLA[CLA_ROUND_ATUAL], CLA[CLA_PONTOS][0], CLA[CLA_PONTOS][1]);
    }
    ClaSendMsg(COLOR_WHITE, msg);

    // Verificar se acabou todos os rounds
    if(CLA[CLA_ROUND_ATUAL] >= CLA[CLA_ROUNDS])
    {
        new final_msg[160];
        if(CLA[CLA_PONTOS][0] > CLA[CLA_PONTOS][1])
            format(final_msg, sizeof(final_msg), "{FF0000}| CLA | FIM! CLA 1 E O CAMPEAO! {FFFFFF}%d x %d", CLA[CLA_PONTOS][0], CLA[CLA_PONTOS][1]);
        else if(CLA[CLA_PONTOS][1] > CLA[CLA_PONTOS][0])
            format(final_msg, sizeof(final_msg), "{0066FF}| CLA | FIM! CLA 2 E O CAMPEAO! {FFFFFF}%d x %d", CLA[CLA_PONTOS][0], CLA[CLA_PONTOS][1]);
        else
            format(final_msg, sizeof(final_msg), "{FFFF00}| CLA | FIM! EMPATE GERAL! {FFFFFF}%d x %d", CLA[CLA_PONTOS][0], CLA[CLA_PONTOS][1]);

        ClaSendMsg(COLOR_WHITE, final_msg);
        ClaSendMsg(COLOR_GREY, "| CLA | O admin pode iniciar novos rounds ou encerrar com /cla.");
    }
    else
    {
        ClaSendMsg(COLOR_GREY, "| CLA | Aguardando admin iniciar o proximo round...");
    }

    // Parar spectate de todos
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i) || !CLA_INSCRITO[i]) continue;
        if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            TogglePlayerSpectating(i, false);
        TogglePlayerControllable(i, false); // congela ate proximo round
    }
    return 1;
}

// =============================================================================
// ENCERRAR TUDO
// =============================================================================

ClaEncerrar()
{
    // Destruir veiculos e spawnar todos
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i) || !CLA_INSCRITO[i]) continue;

        if(CLA_VEHICLEID[i] != INVALID_VEHICLE_ID && IsValidVehicle(CLA_VEHICLEID[i]))
        {
            DestroyVehicle(CLA_VEHICLEID[i]);
            CLA_VEHICLEID[i] = INVALID_VEHICLE_ID;
        }
        if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
            TogglePlayerSpectating(i, false);

        CLA_INSCRITO[i] = false;
        CLA_TEAM[i] = -1;
        TogglePlayerControllable(i, true);
        SetPlayerColor(i, COLOR_WHITE);
        SetPlayerVirtualWorld(i, 0);
        SpawnPlayer(i);
    }

    ClaReset();
    ClaSendMsg(COLOR_RED, "{FF0000}| CLA | Partida encerrada pelo administrador.");
    return 1;
}

// =============================================================================
// ENTRAR NO CLA
// =============================================================================

ClaEntrar(playerid)
{
    if(CLA_INSCRITO[playerid])
        return SCM(playerid, COLOR_ORANGE, "| CLA | Voce ja esta inscrito!");

    if(PI[playerid][P_IN_DERBY])
    {
        RemovePlayerFromDerby(playerid);
    }

    CLA_INSCRITO[playerid] = true;
    CLA_TEAM[playerid] = -1;
    CLA_VEHICLEID[playerid] = INVALID_VEHICLE_ID;
    CLA[CLA_ATIVO] = true;

    // Mover para o VW do CLA
    SetPlayerVirtualWorld(playerid, DI[D_VW] > 0 ? DI[D_VW] : CLA_VW);
    SetPlayerPos(playerid, 0.0, 0.0, 10.0); // posicao temporaria

    SCM(playerid, COLOR_GREEN, "| CLA | Voce entrou na sala CLA VS CLA!");
    SCM(playerid, COLOR_GREY, "| CLA | Aguarde o admin definir seu time e iniciar.");

    new msg[128];
    format(msg, sizeof(msg), "{FFFFFF}| CLA | %s entrou na sala. Total: %d", PI[playerid][P_NAME], ClaCountTotal());
    ClaSendMsg(COLOR_WHITE, msg);
    return 1;
}

// =============================================================================
// MENSAGEM PARA TODOS NO CLA
// =============================================================================

ClaSendMsg(color, const message[])
{
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(IsPlayerConnected(i) && CLA_INSCRITO[i])
            SCM(i, color, message);
    }
    return 1;
}

// =============================================================================
// DIALOGS DO CLA
// =============================================================================

ClaHandleDialog(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DLG_CLA_CONFIG:
        {
            if(!response) return 1;
            switch(listitem)
            {
                case 0: // Veiculo
                {
                    ShowPlayerDialog(playerid, DLG_CLA_VEICULO, DIALOG_STYLE_INPUT,
                        "CLA - Veiculo",
                        "{FFFFFF}DIGITE O ID DO VEICULO (400 a 611)\n\n{CCCCCC}Sugestoes: 411 Infernus | 451 Turismo | 495 Sandking | 560 Sultan",
                        "Salvar", "Voltar");
                }
                case 1: ClaShowMapList(playerid);  // Mapa
                case 2: // Rounds
                {
                    ShowPlayerDialog(playerid, DLG_CLA_ROUNDS, DIALOG_STYLE_INPUT,
                        "CLA - Rounds",
                        "{FFFFFF}Quantos rounds tera a partida? (1 a 30)",
                        "Salvar", "Voltar");
                }
                case 3: ClaShowMembers(playerid); // Membros
                case 4: // INICIAR ou PAUSAR
                {
                    if(CLA[CLA_RODANDO])
                        ClaTogglePause(playerid);
                    else
                        ClaStartRound(playerid);
                    ClaShowPanel(playerid);
                }
                case 5: // TREINAMENTO
                {
                    CLA[CLA_TREINO] = !CLA[CLA_TREINO];
                    if(CLA[CLA_TREINO])
                    {
                        ClaSendMsg(COLOR_GREEN, "{00FFFF}| CLA | TREINAMENTO ativado! Ao cair voce volta automaticamente.");
                        // Se tem mapa carregado, libera todos
                        if(CLA[CLA_MAPA] >= 0 && CLA[CLA_MAPA] < TOTAL_DERBYS)
                            ClaLoadMapAndTP(CLA[CLA_MAPA]);
                    }
                    else
                    {
                        ClaSendMsg(COLOR_ORANGE, "{FF6600}| CLA | TREINAMENTO desativado.");
                    }
                    ClaShowPanel(playerid);
                }
                case 6: ClaShowPanel(playerid); // Placar (nao faz nada, so info)
                case 7: // ENCERRAR
                {
                    ClaEncerrar();
                }
            }
            return 1;
        }

        case DLG_CLA_VEICULO:
        {
            if(!response) return ClaShowPanel(playerid);
            new v = strval(inputtext);
            if(v < 400 || v > 611)
                SCM(playerid, COLOR_RED, "[ERRO]: ID invalido (400-611).");
            else
            {
                CLA[CLA_VEICULO] = v;
                new msg[64];
                format(msg, sizeof(msg), "| CLA | Veiculo definido: %d", v);
                SCM(playerid, COLOR_GREEN, msg);
            }
            return ClaShowPanel(playerid);
        }

        case DLG_CLA_ROUNDS:
        {
            if(!response) return ClaShowPanel(playerid);
            new v = strval(inputtext);
            if(v < 1 || v > 30)
                SCM(playerid, COLOR_RED, "[ERRO]: Valor invalido (1-30).");
            else
            {
                CLA[CLA_ROUNDS] = v;
                new msg[64];
                format(msg, sizeof(msg), "| CLA | Rounds definidos: %d", v);
                SCM(playerid, COLOR_GREEN, msg);
            }
            return ClaShowPanel(playerid);
        }

        case DLG_CLA_MAPA:
        {
            if(!response) return ClaShowPanel(playerid);
            if(listitem >= 0 && listitem < TOTAL_DERBYS)
            {
                // Carrega o mapa E teleporta todos imediatamente
                ClaLoadMapAndTP(listitem);
            }
            return ClaShowPanel(playerid);
        }

        case DLG_CLA_MEMBERS:
        {
            if(!response) return ClaShowPanel(playerid);

            // Encontrar o jogador selecionado
            new idx = 0, target = INVALID_PLAYER_ID;
            for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
            {
                if(!IsPlayerConnected(i) || !CLA_INSCRITO[i]) continue;
                if(idx == listitem) { target = i; break; }
                idx++;
            }

            if(target == INVALID_PLAYER_ID)
                return ClaShowMembers(playerid);

            // Trocar de time: -1 -> 0 -> 1 -> -1
            if(CLA_TEAM[target] == -1)
            {
                CLA_TEAM[target] = 0;
                SetPlayerColor(target, CLA1_COLOR);
                SCM(target, CLA1_COLOR, "| CLA | Voce foi colocado no CLA 1 (Vermelho)!");
            }
            else if(CLA_TEAM[target] == 0)
            {
                CLA_TEAM[target] = 1;
                SetPlayerColor(target, CLA2_COLOR);
                SCM(target, CLA2_COLOR, "| CLA | Voce foi colocado no CLA 2 (Azul)!");
            }
            else
            {
                CLA_TEAM[target] = -1;
                SetPlayerColor(target, COLOR_WHITE);
                SCM(target, COLOR_GREY, "| CLA | Voce foi removido do time.");
            }

            return ClaShowMembers(playerid);
        }
    }
    return 0;
}
