/*****************************************************************************************************

    GAMEMODE: DERBY STANDALONE
    
    Extraido e adaptado do Brasil Mundo Supremo 2020
    Sistema completo de Derby (mata-mata de carros em plataformas)
    
    Includes necessarios:
        - a_samp.inc
        - sscanf2.inc
    
    Funcionamento:
        - Jogadores entram no Derby automaticamente ao conectar
        - O sistema carrega mapas de arquivos .sfr na pasta DERBY/
        - Quem cai da plataforma e eliminado e fica assistindo
        - Ultimo sobrevivente vence, e o proximo mapa inicia

******************************************************************************************************/

#include <a_samp>
#include <sscanf2>
#include <streamer>

#pragma tabsize 0
#pragma dynamic 65536

native IsValidVehicle(vehicleid);

// =============================================================================
// SISTEMA DE DETECCAO DE PAUSE (substitui OnPlayerPause)
// =============================================================================
new PlayerLastUpdate[MAX_PLAYERS];

stock IsPlayerPaused(playerid)
{
    if(GetTickCount() - PlayerLastUpdate[playerid] > 2000) return 1;
    return 0;
}

// =============================================================================
// MACRO FOREACH (substitui include foreach)
// =============================================================================
#define foreach(%0) for(new %0 = 0, __j = GetPlayerPoolSize(); %0 <= __j; %0++) if(IsPlayerConnected(%0))


// =============================================================================
// CONFIGURACOES
// =============================================================================

#undef MAX_PLAYERS
#define MAX_PLAYERS             (50)

#define GAMEMODETEXT            "Derby Destruicao"
#define HOSTNAME                "Servidor Derby - Mata-Mata de Carros"

#define MAX_DERBY_PLAYERS       (20)
#define MAX_DERBYS              (200)
#define NO_WINNER               (-1)

#define DERBY_VW_BASE           (50)   // VW base (bate com SFRDERBY)
#define AFK_WARNING_SECONDS     (10)
#define AFK_KICK_SECONDS        (20)
#define DERBY_TIMEOUT_SECONDS   (180)
#define DERBY_COUNTDOWN_SECONDS (10)

// --- Compatibilidade de estilos de dialogo (caso a_samp seja antigo) ---
#if !defined DIALOG_STYLE_TABLIST
    #define DIALOG_STYLE_TABLIST         (4)
#endif
#if !defined DIALOG_STYLE_TABLIST_HEADERS
    #define DIALOG_STYLE_TABLIST_HEADERS (5)
#endif

// --- IDs dos dialogos ---
#define DLG_MODO            (9100)
#define DLG_CLA_CONFIG      (9101)
#define DLG_CLA_MAPA        (9102)
#define DLG_CLA_TEMPO       (9103)
#define DLG_CLA_ROUNDS      (9104)
#define DLG_CLA_COR1        (9105)
#define DLG_CLA_COR2        (9106)
#define DLG_CLA_VEICULO     (9107)
#define DLG_CLA_TIME        (9108)
#define DLG_CLA_PLAYERS     (9109)
#define DLG_CLA_SETTEAM     (9110)

#define SCM SendClientMessage
#define SCMToAll SendClientMessageToAll

// =============================================================================
// CORES
// =============================================================================

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x00FF00FF
#define COLOR_RED       0xFF0000FF
#define COLOR_YELLOW    0xFFFF00FF
#define COLOR_ORANGE    0xFF9900FF
#define COLOR_GREY      0x999999FF
#define COLOR_INFO      0x00FF00FF


// =============================================================================
// ENUMERADORES
// =============================================================================

enum
{
    DERBY_CLOSED,
    DERBY_RUNNING,
    DERBY_WAIT
};

enum
{
    PD_NORMAL,
    PD_DEAD,
    PD_SPECTATE
};

// Modos de jogo do servidor
enum
{
    MODO_FUN,
    MODO_CLA
};

// Configuracao do modo CLA VS CLA
enum CLAINFO
{
    CL_CONFIGURADO,
    CL_RODANDO,
    CL_MAPA,
    CL_TEMPO,
    CL_ROUNDS,
    CL_ROUND_ATUAL,
    CL_VEICULO,
    CL_COR[2],
    CL_PONTOS[2],
    CL_ADMIN
};

enum DINFO
{
    D_PLAYERS,
    D_RUNNINGPLAYERS,
    D_WINNER,
    D_STATUS,

    D_ID,
    D_NAME[24],
    D_WEATHER,
    D_HOUR,
    D_VEHICLE,
    Float:D_ZPOS,
    D_VW,               // virtual world do mapa (bate com o filterscript SFRDERBY)

    D_TICKCOUNT,
    D_COUNTDOWN_COUNTER,
    D_COUNTDOWN_TIMER,
    D_NEXTDSTATUS_TIMER,
    D_TIMEOUT_COUNTER,
    D_TIMEOUT_TIMER,
    D_MAX_PRIZE,
    D_MAX2_PRIZE,
    D_DERBYGOD_VOTES[2],
    D_DERBYGODCAR
};

enum PINFO
{
    P_NAME[MAX_PLAYER_NAME],
    P_DERBY_VEHICLEID,
    P_DERBY_POSITION,
    P_DERBY_STATUS,
    P_DERBY_SPECTATEPLAYER,
    bool:P_DERBY_VOTED,
    bool:P_IN_DERBY,
    P_CLA,              // -1 = nenhum, 0 = CLA 1, 1 = CLA 2
    P_SCORE,
    P_TIMER_PAUSE
};


// =============================================================================
// VARIAVEIS GLOBAIS
// =============================================================================

new DI[DINFO];
new Float:DERBY_SPAWN[MAX_DERBY_PLAYERS][4];
new DERBY_SLOT_USED[MAX_DERBY_PLAYERS];
new TOTAL_DERBYS;
new File_String[512];
new DERBY_FILENAMES[MAX_DERBYS][32];

// Tabela de virtual worlds (arquivo -> VW do filterscript)
new VW_FILE[MAX_DERBYS][32];
new VW_ID[MAX_DERBYS];
new VW_TOTAL;

// Nome amigavel de cada mapa (lido do cabecalho do .sfr)
new DERBY_MAPNAME[MAX_DERBYS][24];

// Modo atual do servidor
new DERBY_MODO = MODO_FUN;

// Estado do CLA VS CLA
new CL[CLAINFO];

// Jogador selecionado pelo admin na tela de gerenciamento de times
new ClaSelPlayer[MAX_PLAYERS];

// TextDraws
new Text:TD_DERBY[9];
new Text:TD_DerbyMessage;
new Text:TD_DERBY_GodCar[4];
new Text:TD_ESPEC_DERBY;

// GodCar
new bool:DerbyAtivarGod = false;

// Anti-AFK
new Float:DerbyLastPosHash[MAX_PLAYERS];
new DerbyAwaySeconds[MAX_PLAYERS];

// Info dos jogadores
new PI[MAX_PLAYERS][PINFO];

// Database (SQLite)
new DB:Database;
new DB_Query[512];


// =============================================================================
// FORWARDS
// =============================================================================

forward NextDerbyStatus();
forward DerbyCountdown();
forward DerbyTimeOutCountdown();
forward HideDerbyMessage();
forward GodDerbyTimer();
forward AntiAFKTimer();

// --- modo CLA VS CLA ---
forward ClaNextRoundTimer();
forward ClaFinishTimer();
forward ClaCleanupTimer();
forward ClaAfterDeath(playerid);
forward ClaCheckRoundEnd();
forward ClaEndRound(team);
forward ClaCountAlive(team);
forward ClaCountTeam(team);
forward ClaStopAll(const motivo[]);
forward ClaResetConfig();
forward ClaJoin(playerid, team);
forward ClaShowConfig(playerid);
forward ClaShowPlayerList(playerid);
forward ShowModeSelect(playerid);

// =============================================================================
// FUNCOES UTILITARIAS
// =============================================================================

stock pNome(playerid)
{
    new sNick[MAX_PLAYER_NAME+1];
    GetPlayerName(playerid, sNick, sizeof(sNick));
    return sNick;
}

stock TimeConvert(seconds)
{
    new tmp[16];
    new minutes = floatround(seconds/60);
    seconds -= minutes*60;
    format(tmp, sizeof(tmp), "%d:%02d", minutes, seconds);
    return tmp;
}

stock minrand(min, max)
{
    return random(max - min) + min;
}

stock StripNewLine(string[])
{
    new len = strlen(string);
    if(len > 0 && string[len-1] == '\n') string[len-1] = '\0';
    if(len > 1 && string[len-2] == '\r') string[len-2] = '\0';
    return 1;
}

stock SendMessageToAllDerby(color, const message[])
{
    foreach(i)
    {
        if(PI[i][P_IN_DERBY])
        {
            SCM(i, color, message);
        }
    }
}


stock GivePlayerScoreEx(playerid, score)
{
    PI[playerid][P_SCORE] += score;
    SetPlayerScore(playerid, PI[playerid][P_SCORE]);
    return 1;
}

stock DestroyVehicleEx(vehicleid)
{
    if(1 <= vehicleid <= MAX_VEHICLES)
    {
        DestroyVehicle(vehicleid);
        return 1;
    }
    return 0;
}

stock PutPlayerInVehicleEx(playerid, vehicleid, seatid)
{
    return PutPlayerInVehicle(playerid, vehicleid, seatid);
}

stock TogglePlayerSpectatingEx(playerid, toggle)
{
    return TogglePlayerSpectating(playerid, toggle);
}

stock PlayerPlaySoundEx(playerid, id, Float:X, Float:Y, Float:Z)
{
    return PlayerPlaySound(playerid, id, X, Y, Z);
}

stock GetPositionHashDerby(playerid)
{
    new Float:ppx, Float:ppy, Float:ppz;
    GetVehiclePos(GetPlayerVehicleID(playerid), ppx, ppy, ppz);
    return floatround(ppx * ppy * ppz / 3);
}

stock ResetAwayDerbyStatus(playerid)
{
    DerbyLastPosHash[playerid] = DerbyLastPosHash[playerid] + 900.0;
}


// =============================================================================
// SISTEMA DE CARREGAMENTO DE MAPAS
// =============================================================================

// =============================================================================
// TABELA DE VIRTUAL WORLDS
// Cada mapa tem um VW fixo que corresponde ao filterscript SFRDERBY.
// Arquivo: DERBY/vworlds.txt   ->   formato:  nomedoarquivo.sfr,VW
// =============================================================================

LoadVirtualWorlds()
{
    VW_TOTAL = 0;
    new File:Handler = fopen("DERBY/vworlds.txt", io_read);
    if(!Handler)
    {
        printf("[DERBY] AVISO: DERBY/vworlds.txt nao encontrado. Usando VW = indice + %d", DERBY_VW_BASE);
        return 0;
    }
    while(fread(Handler, File_String))
    {
        StripNewLine(File_String);
        if(strlen(File_String) < 3) continue;
        if(VW_TOTAL >= MAX_DERBYS) break;

        new nome[32], vw;
        if(!sscanf(File_String, "p<,>s[32]d", nome, vw))
        {
            format(VW_FILE[VW_TOTAL], 32, "%s", nome);
            VW_ID[VW_TOTAL] = vw;
            VW_TOTAL++;
        }
    }
    fclose(Handler);
    printf("[DERBY] Tabela de virtual worlds carregada: %d entradas", VW_TOTAL);
    return 1;
}

// Retorna o VW de um caminho tipo "DERBY/rampa2.sfr"
GetMapVirtualWorld(const path[], fallback)
{
    new base[32], len = strlen(path), start = 0;
    for(new i = 0; i < len; i++)
    {
        if(path[i] == '/' || path[i] == '\\') start = i + 1;
    }
    format(base, sizeof(base), "%s", path[start]);

    for(new i = 0; i < VW_TOTAL; i++)
    {
        if(!strcmp(VW_FILE[i], base, true)) return VW_ID[i];
    }
    return fallback;
}

// =============================================================================
// CARREGAMENTO DA LISTA DE MAPAS
// =============================================================================

LoadDerbyNames(const mapname[])
{
    new File:Handler = fopen(mapname, io_read);
    if(!Handler)
    {
        printf("[DERBY] ERRO: nao foi possivel abrir a lista de mapas: %s", mapname);
        return 0;
    }

    TOTAL_DERBYS = 0;
    for(new i = 0; i != MAX_DERBYS; i++) DERBY_FILENAMES[i] = "";

    while(fread(Handler, File_String))
    {
        StripNewLine(File_String);
        if(strlen(File_String) < 3) continue;
        if(File_String[0] == ';') continue;
        if(TOTAL_DERBYS < MAX_DERBYS)
        {
            format(DERBY_FILENAMES[TOTAL_DERBYS], 32, "%s", File_String);
            TOTAL_DERBYS++;
        }
    }
    fclose(Handler);
    return 1;
}

// Tenta varios caminhos possiveis para a lista de mapas
LoadDerbyMapList()
{
    if(LoadDerbyNames("DERBY/derbys.sfr") && TOTAL_DERBYS > 0)
    {
        printf("[DERBY] Lista carregada de DERBY/derbys.sfr (%d mapas)", TOTAL_DERBYS);
        return 1;
    }
    if(LoadDerbyNames("derbys.sfr") && TOTAL_DERBYS > 0)
    {
        printf("[DERBY] Lista carregada de derbys.sfr (%d mapas)", TOTAL_DERBYS);
        return 1;
    }
    if(LoadDerbyNames("DERBY/derbysSSS.sfr") && TOTAL_DERBYS > 0)
    {
        printf("[DERBY] Lista carregada de DERBY/derbysSSS.sfr (%d mapas)", TOTAL_DERBYS);
        return 1;
    }

    print("[DERBY] ***********************************************************");
    print("[DERBY] ERRO CRITICO: NENHUM MAPA FOI CARREGADO!");
    print("[DERBY] Verifique se existe: scriptfiles/DERBY/derbys.sfr");
    print("[DERBY] O modo Derby ficara DESATIVADO ate isso ser corrigido.");
    print("[DERBY] ***********************************************************");
    return 0;
}

// Le o cabecalho de cada mapa para guardar o nome amigavel
CacheMapNames()
{
    for(new i = 0; i < TOTAL_DERBYS; i++)
    {
        format(DERBY_MAPNAME[i], 24, "");
        new File:h = fopen(DERBY_FILENAMES[i], io_read);
        if(!h) continue;
        if(fread(h, File_String))
        {
            StripNewLine(File_String);
            new nome[24], a, b, c;
            new Float:d;
            if(!sscanf(File_String, "p<,>s[24]dddf", nome, a, b, c, d))
                format(DERBY_MAPNAME[i], 24, "%s", nome);
        }
        fclose(h);
    }
    return 1;
}

// =============================================================================
// CARREGAR UM MAPA
// =============================================================================

LoadDerby(derbyid)
{
    if(derbyid < 0 || derbyid >= TOTAL_DERBYS) return 0;
    if(strlen(DERBY_FILENAMES[derbyid]) < 3) return 0;

    new File:Handler = fopen(DERBY_FILENAMES[derbyid], io_read);
    if(!Handler)
    {
        printf("[DERBY] ERRO: mapa nao encontrado: %s", DERBY_FILENAMES[derbyid]);
        return 0;
    }

    new Count = 0;
    new spawns = 0;
    while(fread(Handler, File_String))
    {
        StripNewLine(File_String);
        if(strlen(File_String) < 3) continue;

        if(Count == 0)
        {
            if(sscanf(File_String, "p<,>s[24]dddf", DI[D_NAME], DI[D_HOUR], DI[D_WEATHER], DI[D_VEHICLE], DI[D_ZPOS]))
            {
                fclose(Handler);
                printf("[DERBY] ERRO: cabecalho invalido em %s", DERBY_FILENAMES[derbyid]);
                return 0;
            }
        }
        else if(spawns < MAX_DERBY_PLAYERS)
        {
            if(!sscanf(File_String, "p<,>ffff", DERBY_SPAWN[spawns][0], DERBY_SPAWN[spawns][1], DERBY_SPAWN[spawns][2], DERBY_SPAWN[spawns][3]))
            {
                spawns++;
            }
        }
        Count++;
    }
    fclose(Handler);

    if(spawns < 1)
    {
        printf("[DERBY] ERRO: mapa %s nao possui spawns validos", DERBY_FILENAMES[derbyid]);
        return 0;
    }

    if(spawns < MAX_DERBY_PLAYERS)
    {
        for(new i = spawns; i < MAX_DERBY_PLAYERS; i++)
        {
            DERBY_SPAWN[i][0] = DERBY_SPAWN[i % spawns][0];
            DERBY_SPAWN[i][1] = DERBY_SPAWN[i % spawns][1];
            DERBY_SPAWN[i][2] = DERBY_SPAWN[i % spawns][2];
            DERBY_SPAWN[i][3] = DERBY_SPAWN[i % spawns][3];
        }
    }

    DI[D_VW] = GetMapVirtualWorld(DERBY_FILENAMES[derbyid], DERBY_VW_BASE + derbyid);

    DI[D_RUNNINGPLAYERS] = 0;
    DI[D_WINNER] = NO_WINNER;
    DI[D_TICKCOUNT] = 0;
    DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
    KillTimer(DI[D_NEXTDSTATUS_TIMER]);
    KillTimer(DI[D_COUNTDOWN_TIMER]);
    KillTimer(DI[D_TIMEOUT_TIMER]);
    for(new i = 0; i != sizeof(DERBY_SLOT_USED); i++) DERBY_SLOT_USED[i] = false;

    printf("[DERBY] Mapa carregado: %s | VW %d | veiculo %d | Zmin %.1f | spawns %d",
        DI[D_NAME], DI[D_VW], DI[D_VEHICLE], DI[D_ZPOS], spawns);
    return 1;
}

// Carrega o proximo mapa valido a partir de um indice (evita loop infinito)
LoadNextValidDerby(startid)
{
    if(TOTAL_DERBYS <= 0) return 0;
    new id = startid;
    if(id < 0 || id >= TOTAL_DERBYS) id = 0;

    for(new tries = 0; tries < TOTAL_DERBYS; tries++)
    {
        if(LoadDerby(id))
        {
            DI[D_ID] = id;
            return 1;
        }
        id++;
        if(id >= TOTAL_DERBYS) id = 0;
    }
    print("[DERBY] ERRO: nenhum mapa da lista pode ser carregado!");
    return 0;
}


// =============================================================================
// FUNCOES PRINCIPAIS DO DERBY
// =============================================================================

GetFreeDerbySlot()
{
    for(new i = 0; i != sizeof(DERBY_SLOT_USED); i++)
    {
        if(!DERBY_SLOT_USED[i])
        {
            return i;
        }
    }
    return -1;
}

SpawnDerbyCarForPlayer(playerid, Float:X, Float:Y, Float:Z, Float:Angle, vehicleid)
{
    if(IsValidVehicle(PI[playerid][P_DERBY_VEHICLEID]) && PI[playerid][P_DERBY_VEHICLEID] != INVALID_VEHICLE_ID)
    {
        DestroyVehicleEx(PI[playerid][P_DERBY_VEHICLEID]);
        PI[playerid][P_DERBY_VEHICLEID] = INVALID_VEHICLE_ID;
    }
    PI[playerid][P_DERBY_VEHICLEID] = CreateVehicle(vehicleid, X, Y, Z, Angle, minrand(128, 255), minrand(128, 255), 99999, false);
    SetVehicleVirtualWorld(PI[playerid][P_DERBY_VEHICLEID], GetPlayerVirtualWorld(playerid));
    PutPlayerInVehicleEx(playerid, PI[playerid][P_DERBY_VEHICLEID], 0);
    return PI[playerid][P_DERBY_VEHICLEID];
}

CloseDerby()
{
    KillTimer(DI[D_TIMEOUT_TIMER]);
    KillTimer(DI[D_COUNTDOWN_TIMER]);
    KillTimer(DI[D_NEXTDSTATUS_TIMER]);
    DI[D_STATUS] = DERBY_CLOSED;
    DI[D_PLAYERS] = 0;
    DI[D_RUNNINGPLAYERS] = 0;
    DI[D_WINNER] = NO_WINNER;
    format(DI[D_NAME], 24, "");
    DI[D_WEATHER] = 0;
    DI[D_HOUR] = 0;
    DI[D_VEHICLE] = 0;
    DI[D_ZPOS] = 0.0;
    DI[D_TICKCOUNT] = 0;
    DI[D_COUNTDOWN_COUNTER] = 0;
    DI[D_MAX_PRIZE] = 0;
    DI[D_TIMEOUT_COUNTER] = 0;
    TextDrawSetString(TD_DerbyMessage, "_");
    DI[D_DERBYGOD_VOTES][0] = 0;
    DI[D_DERBYGOD_VOTES][1] = 0;
    TextDrawSetString(TD_DERBY_GodCar[3], "SIM_GOD_CAR:_0~n~NAO_GOD_CAR:_0~n~_");
    DerbyAtivarGod = false;
    return 1;
}


// =============================================================================
// PLAYERDERBY DEAD - Quando o jogador e eliminado
// =============================================================================

PlayerDerbyDead(playerid)
{
    if(PI[playerid][P_DERBY_STATUS] == PD_DEAD) return 1;
    PI[playerid][P_DERBY_STATUS] = PD_DEAD;

    // Destroi o veiculo do jogador
    if(IsValidVehicle(PI[playerid][P_DERBY_VEHICLEID]) && PI[playerid][P_DERBY_VEHICLEID] != INVALID_VEHICLE_ID)
    {
        DestroyVehicleEx(PI[playerid][P_DERBY_VEHICLEID]);
        PI[playerid][P_DERBY_VEHICLEID] = INVALID_VEHICLE_ID;
    }

    PlayerPlaySoundEx(playerid, 1057, 0.0, 0.0, 0.0);

    // Score baseado na posicao
    new score_gain = DI[D_MAX2_PRIZE] - DI[D_RUNNINGPLAYERS];
    GivePlayerScoreEx(playerid, score_gain);

    // Salvar estatisticas no banco
    if(Database != DB:0)
    {
        format(DB_Query, sizeof(DB_Query), "UPDATE derby_stats SET losses = losses + 1, score_total = score_total + %d, last_played = CURRENT_TIMESTAMP WHERE player_name = '%s'",
            score_gain, PI[playerid][P_NAME]);
        db_query(Database, DB_Query);
    }

    // Mensagem de posicao
    new str[128];
    format(str, sizeof(str), "~n~~n~~n~~n~~b~~h~~h~posicao %d/%d~n~~n~~n~~n~~w~+%d score",
        DI[D_RUNNINGPLAYERS], DI[D_PLAYERS], score_gain);
    GameTextForPlayer(playerid, str, 2000, 3);

    // Mensagem para todos no Derby
    new msg[145];
    format(msg, sizeof(msg), "{00FF00}| DERBY | %s (%i) Foi eliminado (posicao: %d/%d - Tempo: %s - Premio: +%d Score)",
        pNome(playerid), playerid, DI[D_RUNNINGPLAYERS], DI[D_PLAYERS],
        TimeConvert(gettime() - DI[D_TICKCOUNT]), score_gain);
    SendMessageToAllDerby(COLOR_INFO, msg);

    DI[D_RUNNINGPLAYERS] -= 1;

    // No modo CLA VS CLA o fim de round e decidido por equipe
    if(DERBY_MODO == MODO_CLA)
    {
        ClaAfterDeath(playerid);
        return 1;
    }

    // Ninguem sobrou (partida solo) -> encerra e troca de mapa
    if(DI[D_RUNNINGPLAYERS] <= 0)
    {
        DI[D_RUNNINGPLAYERS] = 0;
        SendMessageToAllDerby(COLOR_YELLOW, "| DERBY | Rodada encerrada. Carregando proximo mapa...");
        TextDrawSetString(TD_DerbyMessage, "~y~rodada encerrada");
        DerbyAtivarGod = false;
        DI[D_DERBYGOD_VOTES][0] = 0;
        DI[D_DERBYGOD_VOTES][1] = 0;
        KillTimer(DI[D_TIMEOUT_TIMER]);
        KillTimer(DI[D_NEXTDSTATUS_TIMER]);
        DI[D_NEXTDSTATUS_TIMER] = SetTimer("NextDerbyStatus", 3000, false);
        return 1;
    }

    // Verificar se sobrou apenas 1 jogador (VENCEDOR)
    if(DI[D_RUNNINGPLAYERS] == 1)
    {
        foreach(i)
        {
            if(PI[i][P_IN_DERBY] && PI[i][P_DERBY_STATUS] == PD_NORMAL)
            {
                DI[D_WINNER] = i;
                new money = DI[D_MAX_PRIZE] / DI[D_RUNNINGPLAYERS];
                GivePlayerScoreEx(i, money);

                new win_msg[145];
                format(win_msg, sizeof(win_msg), "{00FF00}| DERBY | %s (%i) Venceu a partida!", pNome(i), i);
                SendMessageToAllDerby(COLOR_INFO, win_msg);

                DerbyAtivarGod = false;
                DI[D_DERBYGOD_VOTES][0] = 0;
                DI[D_DERBYGOD_VOTES][1] = 0;

                // Salvar vitoria no banco
                if(Database != DB:0)
                {
                    format(DB_Query, sizeof(DB_Query), "UPDATE derby_stats SET wins = wins + 1, score_total = score_total + %d, last_played = CURRENT_TIMESTAMP WHERE player_name = '%s'",
                        money, PI[i][P_NAME]);
                    db_query(Database, DB_Query);
                }
                break;
            }
        }

        format(str, 128, "~g~~h~ganhador: ~y~%s~n~~g~~h~+%d score",
            PI[DI[D_WINNER]][P_NAME], DI[D_MAX_PRIZE] / DI[D_RUNNINGPLAYERS]);
        TextDrawSetString(TD_DerbyMessage, str);
        PlayerPlaySoundEx(DI[D_WINNER], 1057, 0.0, 0.0, 0.0);

        // O eliminado assiste o vencedor
        TogglePlayerSpectatingEx(playerid, true);
        PlayerSpectateVehicle(playerid, PI[DI[D_WINNER]][P_DERBY_VEHICLEID]);

        KillTimer(DI[D_NEXTDSTATUS_TIMER]);
        DI[D_NEXTDSTATUS_TIMER] = SetTimer("NextDerbyStatus", 3000, false);
        return 1;
    }


    else
    {
        // Jogador morreu mas ainda tem mais de 1 ativo - modo spectate
        PI[playerid][P_DERBY_STATUS] = PD_SPECTATE;
        new alvo = -1;
        foreach(i)
        {
            if(PI[i][P_IN_DERBY] && PI[i][P_DERBY_STATUS] == PD_NORMAL)
            {
                alvo = i;
                break;
            }
        }
        if(alvo != -1 && IsValidVehicle(PI[alvo][P_DERBY_VEHICLEID]))
        {
            PI[playerid][P_DERBY_SPECTATEPLAYER] = alvo;
            TogglePlayerSpectatingEx(playerid, true);
            PlayerSpectateVehicle(playerid, PI[alvo][P_DERBY_VEHICLEID]);
            SCM(playerid, COLOR_WHITE, "{FFFFFF}| DERBY | Pressione a tecla {FF0000}ENTER {FFFFFF}para mudar de jogador.");
            TextDrawShowForPlayer(playerid, TD_ESPEC_DERBY);
        }
    }
    return 1;
}

// =============================================================================
// CHECK DERBY - Verifica estado apos saida de jogador
// =============================================================================

CheckDerby()
{
    if(DI[D_PLAYERS] <= 0 && DI[D_STATUS] != DERBY_CLOSED) return CloseDerby();
    switch(DI[D_STATUS])
    {
        case DERBY_CLOSED: return 1;
        case DERBY_RUNNING:
        {
            if(DI[D_RUNNINGPLAYERS] == 1)
            {
                foreach(i)
                {
                    if(PI[i][P_IN_DERBY] && PI[i][P_DERBY_STATUS] == PD_NORMAL)
                    {
                        DI[D_WINNER] = i;
                        new money = DI[D_MAX_PRIZE] / DI[D_RUNNINGPLAYERS];
                        GivePlayerScoreEx(i, money);

                        if(Database != DB:0)
                        {
                            format(DB_Query, sizeof(DB_Query), "UPDATE derby_stats SET wins = wins + 1, score_total = score_total + %d, last_played = CURRENT_TIMESTAMP WHERE player_name = '%s'",
                                money, PI[i][P_NAME]);
                            db_query(Database, DB_Query);
                        }
                        break;
                    }
                }


                new str[128];
                format(str, 128, "~g~~h~ganhador: ~y~%s~n~~g~~h~+%d score",
                    PI[DI[D_WINNER]][P_NAME], DI[D_MAX_PRIZE] / DI[D_RUNNINGPLAYERS]);
                TextDrawSetString(TD_DerbyMessage, str);
                PlayerPlaySoundEx(DI[D_WINNER], 1057, 0.0, 0.0, 0.0);

                new win_str[128];
                format(win_str, sizeof(win_str), "~b~~h~~h~posicao %d/%d~n~~w~+%d score",
                    DI[D_RUNNINGPLAYERS], DI[D_PLAYERS], DI[D_MAX_PRIZE] / DI[D_RUNNINGPLAYERS]);
                GameTextForPlayer(DI[D_WINNER], win_str, 2000, 3);

                KillTimer(DI[D_NEXTDSTATUS_TIMER]);
                DI[D_NEXTDSTATUS_TIMER] = SetTimer("NextDerbyStatus", 5000, false);
            }
            return 1;
        }
    }
    return 1;
}

// =============================================================================
// UPDATE PLAYERS DERBY STATUS - Posiciona todos os jogadores
// =============================================================================

UpdatePlayersDerbyStatus()
{
    switch(DI[D_STATUS])
    {
        case DERBY_WAIT:
        {
            foreach(players)
            {
                if(PI[players][P_IN_DERBY])
                {
                    if(GetPlayerState(players) == PLAYER_STATE_SPECTATING)
                        TogglePlayerSpectatingEx(players, false);

                    PI[players][P_DERBY_STATUS] = PD_NORMAL;
                    PI[players][P_DERBY_POSITION] = GetFreeDerbySlot();
                    DERBY_SLOT_USED[PI[players][P_DERBY_POSITION]] = true;

                    SetPlayerArmour(players, 0.0);
                    SetPlayerHealth(players, 100.0);
                    SetPlayerVirtualWorld(players, DI[D_VW]);
                    TogglePlayerControllable(players, true);


                    SpawnDerbyCarForPlayer(players,
                        DERBY_SPAWN[PI[players][P_DERBY_POSITION]][0],
                        DERBY_SPAWN[PI[players][P_DERBY_POSITION]][1],
                        DERBY_SPAWN[PI[players][P_DERBY_POSITION]][2] + 2.0,
                        DERBY_SPAWN[PI[players][P_DERBY_POSITION]][3],
                        DI[D_VEHICLE]);

                    // Motor desligado durante espera
                    SetVehicleParamsEx(PI[players][P_DERBY_VEHICLEID], VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, 1, 0, 0, 0);
                    SetPlayerTime(players, DI[D_HOUR], 0);
                    SetPlayerWeather(players, DI[D_WEATHER]);
                    DerbyAwaySeconds[players] = 0;

                    // Votacao de GodCar existe apenas no MODO FUN
                    if(DERBY_MODO == MODO_FUN)
                    {
                        for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
                            TextDrawShowForPlayer(players, TD_DERBY_GodCar[i]);
                        if(!PI[players][P_DERBY_VOTED])
                            SelectTextDraw(players, 0x999999FF);
                    }
                }
            }
        }
        case DERBY_RUNNING:
        {
            foreach(players)
            {
                if(PI[players][P_IN_DERBY])
                {
                    PI[players][P_DERBY_STATUS] = PD_NORMAL;
                    RepairVehicle(PI[players][P_DERBY_VEHICLEID]);

                    if(GetPlayerVehicleID(players) != PI[players][P_DERBY_VEHICLEID])
                        PutPlayerInVehicleEx(players, PI[players][P_DERBY_VEHICLEID], 0);

                    // Verificar se caiu antes de comecar
                    new Float:p[3];
                    GetVehiclePos(PI[players][P_DERBY_VEHICLEID], p[0], p[1], p[2]);
                    if(p[2] <= (DERBY_SPAWN[PI[players][P_DERBY_POSITION]][2] - 0.5))
                    {
                        SetVehiclePos(PI[players][P_DERBY_VEHICLEID],
                            DERBY_SPAWN[PI[players][P_DERBY_POSITION]][0],
                            DERBY_SPAWN[PI[players][P_DERBY_POSITION]][1],
                            DERBY_SPAWN[PI[players][P_DERBY_POSITION]][2]);
                        SetVehicleZAngle(PI[players][P_DERBY_VEHICLEID],
                            DERBY_SPAWN[PI[players][P_DERBY_POSITION]][3]);
                    }


                    // Ligar motor
                    SetVehicleParamsEx(PI[players][P_DERBY_VEHICLEID], VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, 1, 0, 0, 0);
                    PlayerPlaySoundEx(players, 3200, 0.0, 0.0, 0.0);

                    // Mostrar HUD do derby
                    for(new i; i < sizeof(TD_DERBY); ++i)
                        TextDrawShowForPlayer(players, TD_DERBY[i]);

                    // Esconder votacao GodCar
                    for(new x; x < sizeof(TD_DERBY_GodCar); ++x)
                        TextDrawHideForPlayer(players, TD_DERBY_GodCar[x]);
                    CancelSelectTextDraw(players);

                    // Placar do CLA VS CLA na tela
                    if(DERBY_MODO == MODO_CLA)
                    {
                        new sc[128];
                        format(sc, sizeof(sc), "~w~round ~y~%d~w~/~y~%d~n~~w~cla1 ~y~%d ~w~x ~y~%d ~w~cla2",
                            CL[CL_ROUND_ATUAL], CL[CL_ROUNDS], CL[CL_PONTOS][0], CL[CL_PONTOS][1]);
                        TextDrawSetString(TD_DerbyMessage, sc);
                        TextDrawShowForPlayer(players, TD_DerbyMessage);
                    }

                    // Salvar participacao no banco
                    if(Database != DB:0)
                    {
                        format(DB_Query, sizeof(DB_Query), "UPDATE derby_stats SET plays = plays + 1, last_played = CURRENT_TIMESTAMP WHERE player_name = '%s'",
                            PI[players][P_NAME]);
                        db_query(Database, DB_Query);
                    }
                }
            }
        }
    }
    return 1;
}


// =============================================================================
// UPDATE PLAYER DERBY STATUS - Para um unico jogador entrando
// =============================================================================

UpdatePlayerDerbyStatus(playerid)
{
    switch(DI[D_STATUS])
    {
        case DERBY_WAIT:
        {
            PI[playerid][P_DERBY_STATUS] = PD_NORMAL;
            PI[playerid][P_DERBY_POSITION] = GetFreeDerbySlot();
            DERBY_SLOT_USED[PI[playerid][P_DERBY_POSITION]] = true;
            SetPlayerVirtualWorld(playerid, DI[D_VW]);
            TogglePlayerControllable(playerid, true);
            SpawnDerbyCarForPlayer(playerid,
                DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][0],
                DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][1],
                DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][2] + 2.0,
                DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][3],
                DI[D_VEHICLE]);
            SetVehicleParamsEx(PI[playerid][P_DERBY_VEHICLEID], VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, 1, 0, 0, 0);
            SetPlayerTime(playerid, DI[D_HOUR], 0);
            SetPlayerWeather(playerid, DI[D_WEATHER]);
            DerbyAwaySeconds[playerid] = 0;

            if(DERBY_MODO == MODO_FUN)
            {
                for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
                    TextDrawShowForPlayer(playerid, TD_DERBY_GodCar[i]);
                if(!PI[playerid][P_DERBY_VOTED])
                    SelectTextDraw(playerid, 0x999999FF);
            }
        }
        case DERBY_RUNNING:
        {
            // Entrou durante partida - modo spectate
            SetPlayerVirtualWorld(playerid, DI[D_VW]);
            PI[playerid][P_DERBY_STATUS] = PD_SPECTATE;
            foreach(i)
            {
                if(PI[i][P_IN_DERBY] && PI[i][P_DERBY_STATUS] == PD_NORMAL)
                {
                    PI[playerid][P_DERBY_SPECTATEPLAYER] = i;
                    break;
                }
            }
            TogglePlayerSpectatingEx(playerid, true);
            PlayerSpectateVehicle(playerid, PI[PI[playerid][P_DERBY_SPECTATEPLAYER]][P_DERBY_VEHICLEID]);
            SCM(playerid, COLOR_WHITE, "{FFFFFF}| DERBY | Pressione a tecla {FF0000}ENTER {FFFFFF}para mudar de jogador.");
            TextDrawShowForPlayer(playerid, TD_ESPEC_DERBY);
            SetPlayerTime(playerid, DI[D_HOUR], 0);
            SetPlayerWeather(playerid, DI[D_WEATHER]);


            // Mostrar HUD
            for(new i; i < sizeof(TD_DERBY); ++i)
                TextDrawShowForPlayer(playerid, TD_DERBY[i]);
        }
    }
    return 1;
}

// =============================================================================
// NEXT DERBY STATUS - Controla transicao de estados
// =============================================================================

public NextDerbyStatus()
{
    switch(DI[D_STATUS])
    {
        case DERBY_CLOSED:
        {
            if(DERBY_MODO == MODO_CLA)
            {
                if(!LoadDerby(CL[CL_MAPA]))
                {
                    print("[DERBY] CLA: mapa escolhido e invalido.");
                    return 1;
                }
                DI[D_ID]      = CL[CL_MAPA];
                DI[D_VEHICLE] = CL[CL_VEICULO];
            }
            else if(!LoadNextValidDerby(DI[D_ID]))
            {
                print("[DERBY] Nao foi possivel iniciar: nenhum mapa valido.");
                return 1;
            }

            new str[64];
            format(str, 64, "~w~mapa: %s~n~~y~esperando_jogadores", DI[D_NAME]);
            TextDrawSetString(TD_DerbyMessage, str);
            DI[D_STATUS] = DERBY_WAIT;
            DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
            KillTimer(DI[D_COUNTDOWN_TIMER]);
            DI[D_COUNTDOWN_TIMER] = SetTimer("DerbyCountdown", 900, true);

            TextDrawSetString(TD_DERBY_GodCar[3], "SIM_GOD_CAR:_0~n~NAO_GOD_CAR:_0~n~_");

            if(DERBY_MODO == MODO_FUN)
            {
                foreach(players)
                {
                    if(PI[players][P_IN_DERBY])
                    {
                        for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
                            TextDrawShowForPlayer(players, TD_DERBY_GodCar[i]);
                        SelectTextDraw(players, 0x999999FF);
                    }
                }
            }

            UpdatePlayersDerbyStatus();
        }
        case DERBY_RUNNING:
        {
            if(DERBY_MODO == MODO_CLA)
            {
                if(!LoadDerby(CL[CL_MAPA])) return 1;
                DI[D_ID]      = CL[CL_MAPA];
                DI[D_VEHICLE] = CL[CL_VEICULO];
            }
            else
            {
                new nextid = DI[D_ID] + 1;
                if(nextid >= TOTAL_DERBYS) nextid = 0;
                if(!LoadNextValidDerby(nextid))
                {
                    print("[DERBY] Nao foi possivel trocar de mapa.");
                    return 1;
                }
            }

            for(new i; i < sizeof(TD_DERBY); ++i)
                TextDrawHideForAll(TD_DERBY[i]);


            KillTimer(DI[D_TIMEOUT_TIMER]);
            DI[D_STATUS] = DERBY_WAIT;
            DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
            KillTimer(DI[D_COUNTDOWN_TIMER]);
            DI[D_COUNTDOWN_TIMER] = SetTimer("DerbyCountdown", 900, true);

            TextDrawSetString(TD_DERBY_GodCar[3], "SIM_GOD_CAR:_0~n~NAO_GOD_CAR:_0~n~_");

            if(DERBY_MODO == MODO_FUN)
            {
                foreach(players)
                {
                    if(PI[players][P_IN_DERBY])
                    {
                        for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
                            TextDrawShowForPlayer(players, TD_DERBY_GodCar[i]);
                        SelectTextDraw(players, 0x999999FF);
                    }
                }
            }

            UpdatePlayersDerbyStatus();
        }
        case DERBY_WAIT:
        {
            SendMessageToAllDerby(COLOR_INFO, "{00FF00}| DERBY | Partida iniciada!");
            TextDrawSetString(TD_DerbyMessage, "~g~go! ~r~go! ~w~go!");
            SetTimer("HideDerbyMessage", 2000, false);

            foreach(i)
            {
                PI[i][P_DERBY_VOTED] = false;
            }

            DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
            DI[D_MAX_PRIZE] = 1 * DI[D_PLAYERS];
            DI[D_MAX2_PRIZE] = 1 + DI[D_PLAYERS];
            DI[D_RUNNINGPLAYERS] = DI[D_PLAYERS];
            DI[D_TIMEOUT_COUNTER] = (DERBY_MODO == MODO_CLA) ? CL[CL_TEMPO] : DERBY_TIMEOUT_SECONDS;
            KillTimer(DI[D_TIMEOUT_TIMER]);
            DI[D_TIMEOUT_TIMER] = SetTimer("DerbyTimeOutCountdown", 1000, true);
            DI[D_TICKCOUNT] = gettime();
            DI[D_STATUS] = DERBY_RUNNING;
            UpdatePlayersDerbyStatus();

            // Definir GodCar pela votacao
            if(DI[D_DERBYGOD_VOTES][0] > DI[D_DERBYGOD_VOTES][1])
                DerbyAtivarGod = true;
            else if(DI[D_DERBYGOD_VOTES][1] > DI[D_DERBYGOD_VOTES][0])
                DerbyAtivarGod = false;
            else
                DerbyAtivarGod = bool:random(2);
        }
    }
    return 1;
}


// =============================================================================
// DERBY TIMEOUT COUNTDOWN
// =============================================================================

public DerbyTimeOutCountdown()
{
    if(DI[D_STATUS] != DERBY_RUNNING)
    {
        KillTimer(DI[D_TIMEOUT_TIMER]);
        return 1;
    }

    DI[D_TIMEOUT_COUNTER]--;

    // Detector de ESC/Pause
    foreach(p)
    {
        if(PI[p][P_IN_DERBY] && DI[D_PLAYERS] > 1 && PI[p][P_DERBY_STATUS] == PD_NORMAL)
        {
            if(IsPlayerPaused(p))
            {
                new remov[128];
                if(DERBY_MODO == MODO_CLA)
                {
                    SCM(p, COLOR_INFO, "| CLA | {FFFFFF}Voce entrou em ESC e foi eliminado do round.");
                    format(remov, sizeof(remov), "| CLA | %s (%i) entrou em ESC e foi eliminado.", PI[p][P_NAME], p);
                    SendMessageToAllDerby(COLOR_GREEN, remov);
                    PlayerDerbyDead(p);
                }
                else
                {
                    SCM(p, COLOR_INFO, "| MODO | {FFFFFF}Voce foi removido do derby por entrar em ESC.");
                    RemovePlayerFromDerby(p);
                    JoinPlayerDerby(p);
                    format(remov, sizeof(remov), "| DERBY | %s (%i) Foi removido por ficar em ESC.", PI[p][P_NAME], p);
                    SendMessageToAllDerby(COLOR_GREEN, remov);
                }
            }
        }
    }

    // Tempo esgotado
    if(DI[D_TIMEOUT_COUNTER] < 0)
    {
        KillTimer(DI[D_TIMEOUT_TIMER]);

        // No CLA VS CLA quem tiver mais sobreviventes ganha o round
        if(DERBY_MODO == MODO_CLA)
        {
            new a0 = ClaCountAlive(0), a1 = ClaCountAlive(1);
            SendMessageToAllDerby(COLOR_YELLOW, "| CLA | Tempo do round esgotado!");
            if(a0 > a1)      ClaEndRound(0);
            else if(a1 > a0) ClaEndRound(1);
            else             ClaEndRound(-1);
            return 1;
        }

        if(DI[D_WINNER] == NO_WINNER)
        {
            foreach(playerid)
            {
                if(PI[playerid][P_IN_DERBY] && PI[playerid][P_DERBY_STATUS] == PD_NORMAL)
                {
                    PlayerPlaySoundEx(playerid, 1057, 0.0, 0.0, 0.0);
                    TextDrawHideForPlayer(playerid, TD_ESPEC_DERBY);
                }
            }

            SendMessageToAllDerby(COLOR_YELLOW, "| DERBY | Partida finalizada - tempo limite excedido!");
            DerbyAtivarGod = false;
            DI[D_DERBYGOD_VOTES][0] = 0;
            DI[D_DERBYGOD_VOTES][1] = 0;
            DI[D_RUNNINGPLAYERS] = 0;
            KillTimer(DI[D_NEXTDSTATUS_TIMER]);
            DI[D_NEXTDSTATUS_TIMER] = SetTimer("NextDerbyStatus", 3000, false);
            return 1;
        }
        return 1;
    }

    // Atualizar HUD
    TextDrawSetString(TD_DERBY[0], TimeConvert(DI[D_TIMEOUT_COUNTER]));
    new str[10];
    format(str, 10, "%d", DI[D_RUNNINGPLAYERS]);
    TextDrawSetString(TD_DERBY[3], str);
    format(str, 10, "%d", DI[D_PLAYERS]);
    TextDrawSetString(TD_DERBY[6], str);
    return 1;
}


// =============================================================================
// HIDE DERBY MESSAGE
// =============================================================================

public HideDerbyMessage()
{
    return TextDrawSetString(TD_DerbyMessage, "_");
}

// =============================================================================
// DERBY COUNTDOWN - Contagem regressiva para iniciar
// =============================================================================

public DerbyCountdown()
{
    if(DI[D_STATUS] == DERBY_CLOSED) return KillTimer(DI[D_COUNTDOWN_TIMER]);

    if(DI[D_PLAYERS] == 0)
    {
        KillTimer(DI[D_COUNTDOWN_TIMER]);
        CloseDerby();
        return 1;
    }

    if(DI[D_PLAYERS] <= 0)
    {
        DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
        new str[64];
        format(str, 64, "~w~mapa: %s~n~~y~esperando_jogadores", DI[D_NAME]);
        TextDrawSetString(TD_DerbyMessage, str);
        TextDrawHideForAll(TD_ESPEC_DERBY);
        return 1;
    }

    DI[D_COUNTDOWN_COUNTER]--;
    new str[145];
    format(str, 145, "~w~mapa: ~r~~h~%s~n~~w~iniciando em: ~r~~h~%d", DI[D_NAME], DI[D_COUNTDOWN_COUNTER]);
    TextDrawSetString(TD_DerbyMessage, str);
    TextDrawHideForAll(TD_ESPEC_DERBY);

    if(DI[D_COUNTDOWN_COUNTER] <= 0)
    {
        KillTimer(DI[D_COUNTDOWN_TIMER]);
        if(DI[D_PLAYERS] == 0)
        {
            CloseDerby();
            return 1;
        }
        // Inicia a partida mesmo com 1 jogador
        NextDerbyStatus();
    }
    return 1;
}


// =============================================================================
// GOD CAR TIMER - Reparo automatico quando ativado
// =============================================================================

public GodDerbyTimer()
{
    if(DerbyAtivarGod == true && DI[D_STATUS] == DERBY_RUNNING)
    {
        foreach(i)
        {
            if(PI[i][P_IN_DERBY] && PI[i][P_DERBY_STATUS] == PD_NORMAL)
            {
                if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
                {
                    RepairVehicle(GetPlayerVehicleID(i));
                }
            }
        }
    }
    return 1;
}

// =============================================================================
// ANTI-AFK TIMER - Detector de jogadores parados
// =============================================================================

public AntiAFKTimer()
{
    if(DI[D_STATUS] != DERBY_RUNNING || DI[D_PLAYERS] <= 1) return 1;

    foreach(i)
    {
        if(PI[i][P_IN_DERBY] && PI[i][P_DERBY_STATUS] == PD_NORMAL)
        {
            new hash = GetPositionHashDerby(i);
            if(DerbyLastPosHash[i] == hash)
                DerbyAwaySeconds[i]++;
            else
                DerbyAwaySeconds[i] = 0;
            DerbyLastPosHash[i] = hash;

            if(DerbyAwaySeconds[i] >= AFK_WARNING_SECONDS && DerbyAwaySeconds[i] < AFK_KICK_SECONDS)
            {
                GameTextForPlayer(i, "~g~Mexa-se ou sera removido", 2000, 3);
            }
            if(DerbyAwaySeconds[i] >= AFK_KICK_SECONDS)
            {
                if(DERBY_MODO == MODO_CLA)
                {
                    // no CLA apenas elimina o jogador do round, sem remover da partida
                    DerbyAwaySeconds[i] = 0;
                    SCM(i, COLOR_YELLOW, "| CLA | Voce ficou parado e foi eliminado do round!");
                    PlayerDerbyDead(i);
                }
                else
                {
                    SCM(i, COLOR_YELLOW, "| DERBY | Voce foi removido por ficar parado!");
                    RemovePlayerFromDerby(i);
                    JoinPlayerDerby(i);
                }
            }
        }
    }
    return 1;
}


// =============================================================================
// JOIN / REMOVE PLAYER DO DERBY
// =============================================================================

JoinPlayerDerby(playerid)
{
    if(PI[playerid][P_IN_DERBY]) return 1; // ja esta no derby

    // Sem mapas carregados nao da para entrar (evitaria spawn em 0,0,0 = mar)
    if(TOTAL_DERBYS <= 0)
    {
        SCM(playerid, COLOR_RED, "[ERRO]: Nenhum mapa de Derby carregado. Avise um administrador.");
        return 0;
    }

    if(DI[D_PLAYERS] >= MAX_DERBY_PLAYERS)
    {
        SCM(playerid, COLOR_RED, "[ERRO]: O Derby esta lotado. Aguarde a proxima partida.");
        return 0;
    }

    DI[D_PLAYERS] += 1;
    PI[playerid][P_IN_DERBY] = true;
    PI[playerid][P_DERBY_VEHICLEID] = INVALID_VEHICLE_ID;
    PI[playerid][P_DERBY_VOTED] = false;

    SetPlayerArmour(playerid, 0.0);
    SetPlayerHealth(playerid, 100.0);
    ResetPlayerWeapons(playerid);
    DerbyAwaySeconds[playerid] = 0;

    TextDrawShowForPlayer(playerid, TD_DerbyMessage);

    new string[128];
    format(string, sizeof(string), "{00FF00}| DERBY | %s (%i) entrou na sala (jogadores: %d/%d)",
        PI[playerid][P_NAME], playerid, DI[D_PLAYERS], MAX_DERBY_PLAYERS);
    SendMessageToAllDerby(COLOR_INFO, string);

    switch(DI[D_STATUS])
    {
        case DERBY_CLOSED: NextDerbyStatus();
        case DERBY_RUNNING: UpdatePlayerDerbyStatus(playerid);
        case DERBY_WAIT: UpdatePlayerDerbyStatus(playerid);
    }
    return 1;
}


RemovePlayerFromDerby(playerid)
{
    if(!PI[playerid][P_IN_DERBY]) return 1;

    KillTimer(PI[playerid][P_TIMER_PAUSE]);

    if((DI[D_STATUS] == DERBY_RUNNING) && PI[playerid][P_DERBY_STATUS] == PD_NORMAL)
    {
        DI[D_RUNNINGPLAYERS] -= 1;
    }
    DI[D_PLAYERS] -= 1;

    // Esconder TextDraws
    for(new ii; ii < sizeof(TD_DERBY); ++ii)
        TextDrawHideForPlayer(playerid, TD_DERBY[ii]);
    TextDrawHideForPlayer(playerid, TD_DerbyMessage);
    TextDrawHideForPlayer(playerid, TD_ESPEC_DERBY);
    for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
        TextDrawHideForPlayer(playerid, TD_DERBY_GodCar[i]);
    CancelSelectTextDraw(playerid);

    // Liberar slot
    DERBY_SLOT_USED[PI[playerid][P_DERBY_POSITION]] = false;
    DerbyAwaySeconds[playerid] = 0;
    PI[playerid][P_DERBY_POSITION] = 0;
    PI[playerid][P_DERBY_STATUS] = PD_NORMAL;

    // Parar spectate se necessario
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
        TogglePlayerSpectatingEx(playerid, false);

    // Destruir veiculo
    if(IsValidVehicle(PI[playerid][P_DERBY_VEHICLEID]) && PI[playerid][P_DERBY_VEHICLEID] != INVALID_VEHICLE_ID)
    {
        DestroyVehicleEx(PI[playerid][P_DERBY_VEHICLEID]);
        PI[playerid][P_DERBY_VEHICLEID] = INVALID_VEHICLE_ID;
    }

    PI[playerid][P_IN_DERBY] = false;

    // Mensagem de saida
    new string2[128];
    format(string2, sizeof(string2), "{00FF00}| DERBY | %s (%i) saiu da sala (jogadores: %d/%d)",
        PI[playerid][P_NAME], playerid, DI[D_PLAYERS], MAX_DERBY_PLAYERS);
    SendMessageToAllDerby(COLOR_INFO, string2);

    if(DERBY_MODO == MODO_CLA)
    {
        if(CL[CL_RODANDO]) ClaCheckRoundEnd();
        return 1;
    }

    CheckDerby();
    return 1;
}


// =============================================================================
// CRIACAO DE TEXTDRAWS
// =============================================================================

CreateDerbyTextDraws()
{
    // Timer (tempo restante)
    TD_DERBY[0] = TextDrawCreate(521.000000, 306.480072, "5:00");
    TextDrawLetterSize(TD_DERBY[0], 0.804499, 3.666400);
    TextDrawAlignment(TD_DERBY[0], 1);
    TextDrawColor(TD_DERBY[0], -1);
    TextDrawSetShadow(TD_DERBY[0], 10);
    TextDrawSetOutline(TD_DERBY[0], 1);
    TextDrawBackgroundColor(TD_DERBY[0], 255);
    TextDrawFont(TD_DERBY[0], 3);
    TextDrawSetProportional(TD_DERBY[0], 1);

    // Contagem jogadores ativos
    TD_DERBY[3] = TextDrawCreate(594.500000, 365.839996, "5");
    TextDrawLetterSize(TD_DERBY[3], 0.400000, 1.600000);
    TextDrawAlignment(TD_DERBY[3], 1);
    TextDrawColor(TD_DERBY[3], -1);
    TextDrawSetShadow(TD_DERBY[3], 1);
    TextDrawSetOutline(TD_DERBY[3], 1);
    TextDrawBackgroundColor(TD_DERBY[3], 255);
    TextDrawFont(TD_DERBY[3], 3);
    TextDrawSetProportional(TD_DERBY[3], 1);

    // Texto "ATIVOS:"
    TD_DERBY[4] = TextDrawCreate(526.000000, 363.599975, "ATIVOS:");
    TextDrawLetterSize(TD_DERBY[4], 0.464997, 2.126398);
    TextDrawAlignment(TD_DERBY[4], 1);
    TextDrawColor(TD_DERBY[4], -1);
    TextDrawSetShadow(TD_DERBY[4], 1);
    TextDrawSetOutline(TD_DERBY[4], 1);
    TextDrawBackgroundColor(TD_DERBY[4], 255);
    TextDrawFont(TD_DERBY[4], 3);
    TextDrawSetProportional(TD_DERBY[4], 1);

    // Numero total de jogadores
    TD_DERBY[6] = TextDrawCreate(594.000000, 346.239807, "0");
    TextDrawLetterSize(TD_DERBY[6], 0.418499, 1.790399);
    TextDrawAlignment(TD_DERBY[6], 1);
    TextDrawColor(TD_DERBY[6], -1);
    TextDrawSetShadow(TD_DERBY[6], 2);
    TextDrawSetOutline(TD_DERBY[6], 1);
    TextDrawBackgroundColor(TD_DERBY[6], 255);
    TextDrawFont(TD_DERBY[6], 3);
    TextDrawSetProportional(TD_DERBY[6], 1);


    // Texto "JOGADORES:"
    TD_DERBY[7] = TextDrawCreate(511.000000, 345.679962, "JOGADORES:");
    TextDrawLetterSize(TD_DERBY[7], 0.371500, 1.924799);
    TextDrawAlignment(TD_DERBY[7], 1);
    TextDrawColor(TD_DERBY[7], -1);
    TextDrawSetShadow(TD_DERBY[7], 2);
    TextDrawSetOutline(TD_DERBY[7], 1);
    TextDrawBackgroundColor(TD_DERBY[7], 255);
    TextDrawFont(TD_DERBY[7], 3);
    TextDrawSetProportional(TD_DERBY[7], 1);

    // TextDraws nao usados (reservados para compatibilidade)
    TD_DERBY[1] = TextDrawCreate(0.0, 0.0, "_");
    TD_DERBY[2] = TextDrawCreate(0.0, 0.0, "_");
    TD_DERBY[5] = TextDrawCreate(0.0, 0.0, "_");
    TD_DERBY[8] = TextDrawCreate(0.0, 0.0, "_");

    // Mensagem central (mapa, countdown, ganhador)
    TD_DerbyMessage = TextDrawCreate(242.500000, 143.520111, "_");
    TextDrawLetterSize(TD_DerbyMessage, 0.430999, 1.795999);
    TextDrawAlignment(TD_DerbyMessage, 1);
    TextDrawColor(TD_DerbyMessage, -1);
    TextDrawSetShadow(TD_DerbyMessage, 0);
    TextDrawSetOutline(TD_DerbyMessage, 1);
    TextDrawFont(TD_DerbyMessage, 3);
    TextDrawSetProportional(TD_DerbyMessage, 1);

    // Box do GodCar
    TD_DERBY_GodCar[2] = TextDrawCreate(525.000000, 355.000000, "box");
    TextDrawLetterSize(TD_DERBY_GodCar[2], 0.000000, 6.566666);
    TextDrawTextSize(TD_DERBY_GodCar[2], 613.000000, 0.000000);
    TextDrawAlignment(TD_DERBY_GodCar[2], 1);
    TextDrawColor(TD_DERBY_GodCar[2], -1);
    TextDrawUseBox(TD_DERBY_GodCar[2], 1);
    TextDrawBoxColor(TD_DERBY_GodCar[2], 90);
    TextDrawSetShadow(TD_DERBY_GodCar[2], 0);
    TextDrawSetOutline(TD_DERBY_GodCar[2], 0);
    TextDrawBackgroundColor(TD_DERBY_GodCar[2], 255);
    TextDrawFont(TD_DERBY_GodCar[2], 1);
    TextDrawSetProportional(TD_DERBY_GodCar[2], 1);


    // Botao SIM (GodCar)
    TD_DERBY_GodCar[0] = TextDrawCreate(545.000000, 391.000000, "~g~~h~~h~SIM");
    TextDrawLetterSize(TD_DERBY_GodCar[0], 0.400000, 1.600000);
    TextDrawTextSize(TD_DERBY_GodCar[0], 15.000000, 25.000000);
    TextDrawAlignment(TD_DERBY_GodCar[0], 2);
    TextDrawColor(TD_DERBY_GodCar[0], -1);
    TextDrawUseBox(TD_DERBY_GodCar[0], 1);
    TextDrawBoxColor(TD_DERBY_GodCar[0], -1600085852);
    TextDrawSetShadow(TD_DERBY_GodCar[0], 0);
    TextDrawSetOutline(TD_DERBY_GodCar[0], 1);
    TextDrawBackgroundColor(TD_DERBY_GodCar[0], 255);
    TextDrawFont(TD_DERBY_GodCar[0], 1);
    TextDrawSetProportional(TD_DERBY_GodCar[0], 1);
    TextDrawSetSelectable(TD_DERBY_GodCar[0], true);

    // Botao NAO (GodCar)
    TD_DERBY_GodCar[1] = TextDrawCreate(591.000000, 391.000000, "~r~NAO");
    TextDrawLetterSize(TD_DERBY_GodCar[1], 0.400000, 1.600000);
    TextDrawTextSize(TD_DERBY_GodCar[1], 15.000000, 30.000000);
    TextDrawAlignment(TD_DERBY_GodCar[1], 2);
    TextDrawColor(TD_DERBY_GodCar[1], -1);
    TextDrawUseBox(TD_DERBY_GodCar[1], 1);
    TextDrawBoxColor(TD_DERBY_GodCar[1], -1600085852);
    TextDrawSetShadow(TD_DERBY_GodCar[1], 0);
    TextDrawSetOutline(TD_DERBY_GodCar[1], 1);
    TextDrawBackgroundColor(TD_DERBY_GodCar[1], 255);
    TextDrawFont(TD_DERBY_GodCar[1], 1);
    TextDrawSetProportional(TD_DERBY_GodCar[1], 1);
    TextDrawSetSelectable(TD_DERBY_GodCar[1], true);

    // Texto de contagem dos votos
    TD_DERBY_GodCar[3] = TextDrawCreate(600.000000, 359.000000, "SIM_GOD_CAR:_0~n~NAO_GOD_CAR:_0~n~_");
    TextDrawLetterSize(TD_DERBY_GodCar[3], 0.266333, 1.197629);
    TextDrawAlignment(TD_DERBY_GodCar[3], 3);
    TextDrawColor(TD_DERBY_GodCar[3], -65281);
    TextDrawSetShadow(TD_DERBY_GodCar[3], 0);
    TextDrawSetOutline(TD_DERBY_GodCar[3], 1);
    TextDrawBackgroundColor(TD_DERBY_GodCar[3], 255);
    TextDrawFont(TD_DERBY_GodCar[3], 1);
    TextDrawSetProportional(TD_DERBY_GodCar[3], 1);

    // Texto de spectate
    TD_ESPEC_DERBY = TextDrawCreate(639.299972, 420.000000, "~W~PRESSIONE ~G~ENTER ~W~PARA VER OUTROS JOGADORES");
    TextDrawLetterSize(TD_ESPEC_DERBY, 0.270000, 1.200000);
    TextDrawAlignment(TD_ESPEC_DERBY, 3);
    TextDrawColor(TD_ESPEC_DERBY, 0x00FF00FF);
    TextDrawSetShadow(TD_ESPEC_DERBY, 0);
    TextDrawSetOutline(TD_ESPEC_DERBY, 1);
    TextDrawBackgroundColor(TD_ESPEC_DERBY, 255);
    TextDrawFont(TD_ESPEC_DERBY, 2);
    TextDrawSetProportional(TD_ESPEC_DERBY, 3);
}


// =============================================================================
// DATABASE (SQLite)
// =============================================================================

InitDatabase()
{
    Database = db_open("derby.db");
    if(Database == DB:0)
    {
        printf("[DERBY] ERRO: Nao foi possivel abrir o banco de dados!");
        return 0;
    }

    db_query(Database, "CREATE TABLE IF NOT EXISTS derby_stats (\
        player_name VARCHAR(24) PRIMARY KEY, \
        wins INTEGER DEFAULT 0, \
        losses INTEGER DEFAULT 0, \
        plays INTEGER DEFAULT 0, \
        score_total INTEGER DEFAULT 0, \
        last_played TIMESTAMP DEFAULT CURRENT_TIMESTAMP \
    )");

    printf("[DERBY] Banco de dados inicializado com sucesso.");
    return 1;
}

RegisterPlayerStats(playerid)
{
    if(Database == DB:0) return 0;
    format(DB_Query, sizeof(DB_Query), "INSERT OR IGNORE INTO derby_stats (player_name) VALUES ('%s')", PI[playerid][P_NAME]);
    db_query(Database, DB_Query);
    return 1;
}


// =============================================================================
// CALLBACKS DO SA-MP
// =============================================================================

#include "derby_objects.inc"

main()
{
    print("\n========================================");
    print("       DERBY GAMEMODE - STANDALONE");
    print("========================================\n");
}

public OnGameModeInit()
{
    SetGameModeText(GAMEMODETEXT);
    SendRconCommand("hostname "HOSTNAME);

    // Classes de jogador (skins)
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(1, 1958.3783, 1343.1572, 15.3746, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(2, 1958.3783, 1343.1572, 15.3746, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(29, 1958.3783, 1343.1572, 15.3746, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(47, 1958.3783, 1343.1572, 15.3746, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(60, 1958.3783, 1343.1572, 15.3746, 270.0, 0, 0, 0, 0, 0, 0);

    // Desabilitar interior entrances e stunt bonuses
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    ShowPlayerMarkers(1);
    ShowNameTags(1);
    SetNameTagDrawDistance(40.0);
    UsePlayerPedAnims();

    // Criar TextDraws
    CreateDerbyTextDraws();

    // Carregar mapas
    LoadAllDerbyObjects();
    LoadVirtualWorlds();
    LoadDerbyMapList();
    CacheMapNames();
    ClaResetConfig();

    // Inicializar banco de dados
    InitDatabase();

    // Timers globais
    SetTimer("GodDerbyTimer", 997, true);
    SetTimer("AntiAFKTimer", 1000, true);

    // Iniciar o Derby
    DI[D_STATUS] = DERBY_CLOSED;
    DI[D_PLAYERS] = 0;
    DI[D_WINNER] = NO_WINNER;

    return 1;
}

public OnGameModeExit()
{
    if(Database != DB:0)
        db_close(Database);
    return 1;
}


public OnPlayerConnect(playerid)
{
    // Inicializar dados do jogador
    GetPlayerName(playerid, PI[playerid][P_NAME], MAX_PLAYER_NAME);
    PI[playerid][P_IN_DERBY] = false;
    PI[playerid][P_DERBY_VEHICLEID] = INVALID_VEHICLE_ID;
    PI[playerid][P_DERBY_POSITION] = 0;
    PI[playerid][P_DERBY_STATUS] = PD_NORMAL;
    PI[playerid][P_DERBY_SPECTATEPLAYER] = 0;
    PI[playerid][P_DERBY_VOTED] = false;
    PI[playerid][P_CLA] = -1;
    PI[playerid][P_SCORE] = 0;
    ClaSelPlayer[playerid] = INVALID_PLAYER_ID;
    DerbyAwaySeconds[playerid] = 0;
    DerbyLastPosHash[playerid] = 0.0;

    // Registrar no banco de dados
    RegisterPlayerStats(playerid);

    // Mensagem de boas vindas
    SCM(playerid, COLOR_GREEN, "==============================================");
    SCM(playerid, COLOR_WHITE, "   Bem-vindo ao servidor de DERBY!");
    SCM(playerid, COLOR_WHITE, "   Ultimo a sobreviver na plataforma vence!");
    SCM(playerid, COLOR_GREEN, "==============================================");
    SCM(playerid, COLOR_GREY, "Comandos: /derby /sair /stats /top");

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(PI[playerid][P_IN_DERBY])
    {
        RemovePlayerFromDerby(playerid);
    }
    return 1;
}


public OnPlayerSpawn(playerid)
{
    // Spawna no mundo - jogador deve usar /derby para entrar
    if(!PI[playerid][P_IN_DERBY])
    {
        SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746); // Las Venturas
        SetPlayerFacingAngle(playerid, 270.0);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetCameraBehindPlayer(playerid);
        SCM(playerid, COLOR_YELLOW, "| INFO | Digite /derby para entrar no modo Derby!");
    }
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraPos(playerid, 1958.3783, 1338.1572, 17.0);
    SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerFacingAngle(playerid, 180.0);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    // Se morreu no derby (improvavel, mas caso de seguranca)
    if(PI[playerid][P_IN_DERBY] && PI[playerid][P_DERBY_STATUS] == PD_NORMAL)
    {
        if(DI[D_STATUS] == DERBY_RUNNING && DI[D_RUNNINGPLAYERS] >= 1)
        {
            PlayerDerbyDead(playerid);
        }
    }
    return 1;
}


public OnPlayerStateChange(playerid, newstate, oldstate)
{
    // Jogador saiu do veiculo durante o derby (caiu)
    if(PI[playerid][P_IN_DERBY] && PI[playerid][P_DERBY_STATUS] == PD_NORMAL)
    {
        if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
        {
            if(DI[D_STATUS] == DERBY_RUNNING && DI[D_RUNNINGPLAYERS] >= 1)
            {
                PlayerDerbyDead(playerid);
            }
        }
    }
    return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    if(PI[playerid][P_IN_DERBY] && PI[playerid][P_DERBY_STATUS] == PD_NORMAL)
    {
        if(DI[D_STATUS] == DERBY_RUNNING)
        {
            // Verificar se caiu (posicao Z abaixo do limite)
            new Float:p[3];
            GetVehiclePos(PI[playerid][P_DERBY_VEHICLEID], p[0], p[1], p[2]);
            if(p[2] <= DI[D_ZPOS])
            {
                PlayerDerbyDead(playerid);
            }
        }
    }
    return 1;
}


public OnPlayerUpdate(playerid)
{
    // Atualizar timestamp para deteccao de pause
    PlayerLastUpdate[playerid] = GetTickCount();

    // Verificacao continua de queda durante o derby
    if(PI[playerid][P_IN_DERBY] && PI[playerid][P_DERBY_STATUS] == PD_NORMAL)
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            if(DI[D_STATUS] == DERBY_RUNNING && DI[D_RUNNINGPLAYERS] >= 1)
            {
                new Float:p[3];
                GetVehiclePos(PI[playerid][P_DERBY_VEHICLEID], p[0], p[1], p[2]);
                if(p[2] <= DI[D_ZPOS])
                    PlayerDerbyDead(playerid);
            }
            else if(DI[D_STATUS] == DERBY_WAIT)
            {
                // Manter o jogador no veiculo durante espera
                if(!IsValidVehicle(PI[playerid][P_DERBY_VEHICLEID]) && PI[playerid][P_DERBY_VEHICLEID] != INVALID_VEHICLE_ID)
                {
                    SpawnDerbyCarForPlayer(playerid,
                        DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][0],
                        DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][1],
                        DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][2] + 2.0,
                        DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][3],
                        DI[D_VEHICLE]);
                }
                if(GetPlayerVehicleID(playerid) != PI[playerid][P_DERBY_VEHICLEID])
                {
                    SetVehicleVirtualWorld(PI[playerid][P_DERBY_VEHICLEID], GetPlayerVirtualWorld(playerid));
                    SetVehiclePos(PI[playerid][P_DERBY_VEHICLEID],
                        DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][0],
                        DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][1],
                        DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][2] + 2.0);
                    SetVehicleZAngle(PI[playerid][P_DERBY_VEHICLEID],
                        DERBY_SPAWN[PI[playerid][P_DERBY_POSITION]][3]);
                    PutPlayerInVehicleEx(playerid, PI[playerid][P_DERBY_VEHICLEID], 0);
                }
            }
        }
    }
    return 1;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    // NOS (turbo) quando GodCar esta ativado
    if(PI[playerid][P_IN_DERBY] && PI[playerid][P_DERBY_STATUS] == PD_NORMAL)
    {
        if((newkeys & KEY_FIRE) && !(oldkeys & KEY_FIRE))
        {
            if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && DerbyAtivarGod == true)
            {
                AddVehicleComponent(GetPlayerVehicleID(playerid), 1009);
                return 1;
            }
        }
    }

    // Trocar de spectate (tecla ENTER/SPRINT)
    if(PI[playerid][P_IN_DERBY] && PI[playerid][P_DERBY_STATUS] == PD_SPECTATE)
    {
        if((newkeys & KEY_SPRINT) && !(oldkeys & KEY_SPRINT))
        {
            // Encontrar proximo jogador para assistir
            new found = -1;
            new current = PI[playerid][P_DERBY_SPECTATEPLAYER];

            foreach(i)
            {
                if(PI[i][P_IN_DERBY] && PI[i][P_DERBY_STATUS] == PD_NORMAL && i != current)
                {
                    if(i > current || found == -1)
                    {
                        found = i;
                        if(i > current) break;
                    }
                }
            }

            if(found != -1 && found != current)
            {
                PI[playerid][P_DERBY_SPECTATEPLAYER] = found;
                PlayerSpectateVehicle(playerid, PI[found][P_DERBY_VEHICLEID]);
            }
        }
    }
    return 1;
}


public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    // Votacao GodCar - Botao SIM
    if(clickedid == TD_DERBY_GodCar[0])
    {
        if(PI[playerid][P_IN_DERBY] && DI[D_STATUS] == DERBY_WAIT)
        {
            if(PI[playerid][P_DERBY_VOTED])
                return SCM(playerid, COLOR_RED, "[ERRO]: Voce ja votou.");

            DI[D_DERBYGOD_VOTES][0]++;
            new str[50];
            format(str, sizeof str, "SIM_GOD_CAR:_%d~n~NAO_GOD_CAR:_%d~n~_",
                DI[D_DERBYGOD_VOTES][0], DI[D_DERBYGOD_VOTES][1]);
            TextDrawSetString(TD_DERBY_GodCar[3], str);
            CancelSelectTextDraw(playerid);
            PI[playerid][P_DERBY_VOTED] = true;
            SCM(playerid, COLOR_GREEN, "| DERBY | Voce votou SIM para God Car!");
            return 1;
        }
    }

    // Votacao GodCar - Botao NAO
    if(clickedid == TD_DERBY_GodCar[1])
    {
        if(PI[playerid][P_IN_DERBY] && DI[D_STATUS] == DERBY_WAIT)
        {
            if(PI[playerid][P_DERBY_VOTED])
                return SCM(playerid, COLOR_RED, "[ERRO]: Voce ja votou.");

            DI[D_DERBYGOD_VOTES][1]++;
            new str[50];
            format(str, sizeof str, "SIM_GOD_CAR:_%d~n~NAO_GOD_CAR:_%d~n~_",
                DI[D_DERBYGOD_VOTES][0], DI[D_DERBYGOD_VOTES][1]);
            TextDrawSetString(TD_DERBY_GodCar[3], str);
            CancelSelectTextDraw(playerid);
            PI[playerid][P_DERBY_VOTED] = true;
            SCM(playerid, COLOR_GREEN, "| DERBY | Voce votou NAO para God Car!");
            return 1;
        }
    }
    return 1;
}


// =============================================================================
// =====================   MODO CLA VS CLA   ===================================
// Configurado apenas por quem esta logado no RCON.
// Reutiliza o motor do Derby (mesmo spawn/eliminacao), mudando:
//   - mapa fixo escolhido pelo admin
//   - veiculo fixo escolhido pelo admin
//   - tempo por round e quantidade de rounds
//   - 2 clas com cores configuraveis
// =============================================================================

// Paleta de cores disponiveis para os clas
new CLA_COR_NOME[8][16] = {"Vermelho", "Azul", "Verde", "Amarelo", "Laranja", "Roxo", "Rosa", "Ciano"};
new CLA_COR_VAL[8] = {0xFF0000FF, 0x1E90FFFF, 0x00C000FF, 0xFFFF00FF, 0xFF8000FF, 0x9932CCFF, 0xFF69B4FF, 0x00FFFFFF};

ClaResetConfig()
{
    CL[CL_CONFIGURADO] = 0;
    CL[CL_RODANDO]     = 0;
    CL[CL_MAPA]        = 0;
    CL[CL_TEMPO]       = 120;
    CL[CL_ROUNDS]      = 5;
    CL[CL_ROUND_ATUAL] = 0;
    CL[CL_VEICULO]     = 411;
    CL[CL_COR][0]      = 0;   // Vermelho
    CL[CL_COR][1]      = 1;   // Azul
    CL[CL_PONTOS][0]   = 0;
    CL[CL_PONTOS][1]   = 0;
    CL[CL_ADMIN]       = INVALID_PLAYER_ID;
    return 1;
}

// Nome amigavel do mapa (usa o cache lido dos arquivos)
ClaMapName(mapid)
{
    new nome[24];
    if(mapid >= 0 && mapid < TOTAL_DERBYS && strlen(DERBY_MAPNAME[mapid]) > 0)
        format(nome, sizeof(nome), "%s", DERBY_MAPNAME[mapid]);
    else
        format(nome, sizeof(nome), "mapa %d", mapid);
    return nome;
}

// Quantos jogadores vivos em um cla
ClaCountAlive(team)
{
    new total = 0;
    foreach(i)
    {
        if(PI[i][P_IN_DERBY] && PI[i][P_CLA] == team && PI[i][P_DERBY_STATUS] == PD_NORMAL)
            total++;
    }
    return total;
}

// Quantos jogadores inscritos em um cla
ClaCountTeam(team)
{
    new total = 0;
    foreach(i)
    {
        if(PI[i][P_IN_DERBY] && PI[i][P_CLA] == team) total++;
    }
    return total;
}

// =============================================================================
// TELA DE CONFIGURACAO (RCON)
// =============================================================================

ClaShowConfig(playerid)
{
    new info[1200], linha[160];

    format(linha, sizeof(linha), "{FFFFFF}Mapa\t{00FF00}%s\n", ClaMapName(CL[CL_MAPA]));
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFFFF}Tempo por round\t{00FF00}%d segundos\n", CL[CL_TEMPO]);
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFFFF}Quantidade de rounds\t{00FF00}%d\n", CL[CL_ROUNDS]);
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFFFF}Veiculo (ID)\t{00FF00}%d\n", CL[CL_VEICULO]);
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFFFF}Cor do CLA 1\t{00FF00}%s\n", CLA_COR_NOME[ CL[CL_COR][0] ]);
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFFFF}Cor do CLA 2\t{00FF00}%s\n", CLA_COR_NOME[ CL[CL_COR][1] ]);
    strcat(info, linha);

    format(linha, sizeof(linha), "{00FFFF}Definir times dos jogadores\t{00FF00}CLA1: %d  |  CLA2: %d\n",
        ClaCountTeam(0), ClaCountTeam(1));
    strcat(info, linha);

    format(linha, sizeof(linha), "{FFFF00}>> INICIAR PARTIDA\t{FFFF00}%d inscritos\n", DI[D_PLAYERS]);
    strcat(info, linha);

    strcat(info, "{FF0000}>> CANCELAR / RESETAR\t{FF0000}-\n");

    ShowPlayerDialog(playerid, DLG_CLA_CONFIG, DIALOG_STYLE_TABLIST_HEADERS,
        "CLA VS CLA - Configuracao\tValor atual", info, "Selecionar", "Fechar");
    return 1;
}

ClaShowMapList(playerid)
{
    new info[4000], linha[64];
    for(new i = 0; i < TOTAL_DERBYS; i++)
    {
        format(linha, sizeof(linha), "%d - %s\n", i, ClaMapName(i));
        if(strlen(info) + strlen(linha) >= sizeof(info) - 2) break;
        strcat(info, linha);
    }
    if(strlen(info) < 2) format(info, sizeof(info), "Nenhum mapa carregado\n");

    ShowPlayerDialog(playerid, DLG_CLA_MAPA, DIALOG_STYLE_LIST,
        "CLA VS CLA - Escolha o mapa", info, "Escolher", "Voltar");
    return 1;
}

ClaShowColorList(playerid, team)
{
    new info[400], linha[48];
    for(new i = 0; i < sizeof(CLA_COR_NOME); i++)
    {
        format(linha, sizeof(linha), "%s\n", CLA_COR_NOME[i]);
        strcat(info, linha);
    }
    new titulo[48];
    format(titulo, sizeof(titulo), "Cor do CLA %d", team + 1);
    ShowPlayerDialog(playerid, (team == 0) ? DLG_CLA_COR1 : DLG_CLA_COR2,
        DIALOG_STYLE_LIST, titulo, info, "Escolher", "Voltar");
    return 1;
}

// =============================================================================
// ADMIN DEFINE O TIME DE CADA JOGADOR
// =============================================================================

// Nome do cla de um jogador (para exibir na lista)
ClaTeamLabel(playerid)
{
    new txt[24];
    if(PI[playerid][P_CLA] == 0)      format(txt, sizeof(txt), "{00FF00}CLA 1");
    else if(PI[playerid][P_CLA] == 1) format(txt, sizeof(txt), "{00FF00}CLA 2");
    else                              format(txt, sizeof(txt), "{999999}sem time");
    return txt;
}

// Lista todos os jogadores conectados para o admin distribuir nos times
ClaShowPlayerList(playerid)
{
    new info[3500], linha[128];
    new total = 0;

    foreach(i)
    {
        format(linha, sizeof(linha), "%d\t{FFFFFF}%s\t%s\n", i, PI[i][P_NAME], ClaTeamLabel(i));
        if(strlen(info) + strlen(linha) >= sizeof(info) - 2) break;
        strcat(info, linha);
        total++;
    }

    if(total == 0)
    {
        SCM(playerid, COLOR_ORANGE, "| CLA | Nenhum jogador conectado.");
        return ClaShowConfig(playerid);
    }

    ShowPlayerDialog(playerid, DLG_CLA_PLAYERS, DIALOG_STYLE_TABLIST_HEADERS,
        "ID\tJogador\tTime atual", info, "Definir", "Voltar");
    return 1;
}

// Menu para escolher em qual time colocar o jogador selecionado
ClaShowSetTeam(playerid, target)
{
    new info[300], titulo[64];

    format(info, sizeof(info), "{FFFFFF}Colocar no {%06x}CLA 1{FFFFFF} (%s)\n{FFFFFF}Colocar no {%06x}CLA 2{FFFFFF} (%s)\n{FF0000}Remover da partida\n",
        CLA_COR_VAL[ CL[CL_COR][0] ] >>> 8, CLA_COR_NOME[ CL[CL_COR][0] ],
        CLA_COR_VAL[ CL[CL_COR][1] ] >>> 8, CLA_COR_NOME[ CL[CL_COR][1] ]);

    format(titulo, sizeof(titulo), "Time de %s", PI[target][P_NAME]);

    ShowPlayerDialog(playerid, DLG_CLA_SETTEAM, DIALOG_STYLE_LIST,
        titulo, info, "Confirmar", "Voltar");
    return 1;
}

// Aplica o time escolhido pelo admin
ClaSetTeam(adminid, target, team)
{
    if(!IsPlayerConnected(target))
        return SCM(adminid, COLOR_RED, "[ERRO]: Jogador nao esta mais conectado.");

    // Remover da partida
    if(team == -1)
    {
        if(PI[target][P_IN_DERBY]) RemovePlayerFromDerby(target);
        PI[target][P_CLA] = -1;
        SetPlayerColor(target, COLOR_WHITE);
        SetPlayerTeam(target, NO_TEAM);
        SpawnPlayer(target);

        new m1[128];
        format(m1, sizeof(m1), "| CLA | %s removeu voce da partida.", PI[adminid][P_NAME]);
        SCM(target, COLOR_YELLOW, m1);
        format(m1, sizeof(m1), "| CLA | %s foi removido da partida.", PI[target][P_NAME]);
        SCM(adminid, COLOR_YELLOW, m1);
        return 1;
    }

    DERBY_MODO = MODO_CLA;

    // Ainda nao esta na partida -> inscreve
    if(!PI[target][P_IN_DERBY])
    {
        ClaJoin(target, team);
    }
    else
    {
        PI[target][P_CLA] = team;
        SetPlayerColor(target, CLA_COR_VAL[ CL[CL_COR][team] ]);
        SetPlayerTeam(target, team);
    }

    new msg[144];
    format(msg, sizeof(msg), "| CLA | %s colocou voce no {%06x}CLA %d{FFFFFF}.",
        PI[adminid][P_NAME], CLA_COR_VAL[ CL[CL_COR][team] ] >>> 8, team + 1);
    SCM(target, COLOR_WHITE, msg);

    format(msg, sizeof(msg), "| CLA | %s definido para o CLA %d.", PI[target][P_NAME], team + 1);
    SCM(adminid, COLOR_GREEN, msg);
    return 1;
}

// =============================================================================
// ENTRADA DOS JOGADORES NO CLA
// =============================================================================

ClaShowTeamSelect(playerid)
{
    new info[256];
    format(info, sizeof(info), "{%06x}CLA 1{FFFFFF} (%s)\t%d jogadores\n{%06x}CLA 2{FFFFFF} (%s)\t%d jogadores\n",
        CLA_COR_VAL[ CL[CL_COR][0] ] >>> 8, CLA_COR_NOME[ CL[CL_COR][0] ], ClaCountTeam(0),
        CLA_COR_VAL[ CL[CL_COR][1] ] >>> 8, CLA_COR_NOME[ CL[CL_COR][1] ], ClaCountTeam(1));

    ShowPlayerDialog(playerid, DLG_CLA_TIME, DIALOG_STYLE_TABLIST,
        "CLA VS CLA - Escolha seu cla", info, "Entrar", "Cancelar");
    return 1;
}

ClaJoin(playerid, team)
{
    if(PI[playerid][P_IN_DERBY])
        return SCM(playerid, COLOR_ORANGE, "| CLA | Voce ja esta em uma partida. Use /sair primeiro.");

    if(TOTAL_DERBYS <= 0)
        return SCM(playerid, COLOR_RED, "[ERRO]: Nenhum mapa carregado.");

    if(DI[D_PLAYERS] >= MAX_DERBY_PLAYERS)
        return SCM(playerid, COLOR_RED, "[ERRO]: Partida lotada.");

    DERBY_MODO = MODO_CLA;

    DI[D_PLAYERS] += 1;
    PI[playerid][P_IN_DERBY]        = true;
    PI[playerid][P_CLA]            = team;
    PI[playerid][P_DERBY_VEHICLEID] = INVALID_VEHICLE_ID;
    PI[playerid][P_DERBY_STATUS]    = PD_NORMAL;
    PI[playerid][P_DERBY_VOTED]     = true;   // sem votacao de GodCar no CLA
    DerbyAwaySeconds[playerid]      = 0;

    SetPlayerColor(playerid, CLA_COR_VAL[ CL[CL_COR][team] ]);
    SetPlayerTeam(playerid, team);
    SetPlayerArmour(playerid, 0.0);
    SetPlayerHealth(playerid, 100.0);
    ResetPlayerWeapons(playerid);
    TextDrawShowForPlayer(playerid, TD_DerbyMessage);

    new msg[144];
    format(msg, sizeof(msg), "{FFFFFF}| CLA | %s entrou no {%06x}CLA %d{FFFFFF} (CLA1: %d | CLA2: %d)",
        PI[playerid][P_NAME], CLA_COR_VAL[ CL[CL_COR][team] ] >>> 8, team + 1,
        ClaCountTeam(0), ClaCountTeam(1));
    SendMessageToAllDerby(COLOR_WHITE, msg);

    if(CL[CL_RODANDO])
    {
        // partida em andamento -> entra assistindo
        UpdatePlayerDerbyStatus(playerid);
    }
    else
    {
        SCM(playerid, COLOR_YELLOW, "| CLA | Aguardando o administrador iniciar a partida...");
        TextDrawSetString(TD_DerbyMessage, "~y~cla vs cla~n~~w~aguardando admin");
    }
    return 1;
}

// =============================================================================
// INICIAR / ROUNDS
// =============================================================================

ClaStart(playerid)
{
    if(TOTAL_DERBYS <= 0)
        return SCM(playerid, COLOR_RED, "[ERRO]: Nenhum mapa carregado.");

    if(CL[CL_VEICULO] < 400 || CL[CL_VEICULO] > 611)
        return SCM(playerid, COLOR_RED, "[ERRO]: ID de veiculo invalido (400 a 611).");

    if(DI[D_PLAYERS] < 1)
        return SCM(playerid, COLOR_RED, "[ERRO]: Nenhum jogador inscrito. Peca para entrarem com /derby.");

    DERBY_MODO         = MODO_CLA;
    CL[CL_CONFIGURADO] = 1;
    CL[CL_RODANDO]     = 1;
    CL[CL_ROUND_ATUAL] = 1;
    CL[CL_PONTOS][0]   = 0;
    CL[CL_PONTOS][1]   = 0;
    CL[CL_ADMIN]       = playerid;

    // aplica as cores atuais em todos
    foreach(i)
    {
        if(PI[i][P_IN_DERBY] && PI[i][P_CLA] >= 0)
        {
            SetPlayerColor(i, CLA_COR_VAL[ CL[CL_COR][ PI[i][P_CLA] ] ]);
            SetPlayerTeam(i, PI[i][P_CLA]);
        }
    }

    new msg[144];
    format(msg, sizeof(msg), "{FFFF00}| CLA VS CLA | Partida iniciada! Mapa: %s | %d rounds | %ds por round",
        ClaMapName(CL[CL_MAPA]), CL[CL_ROUNDS], CL[CL_TEMPO]);
    SendMessageToAllDerby(COLOR_YELLOW, msg);

    // usa o motor normal: CLOSED -> WAIT (spawna) -> RUNNING
    DI[D_STATUS] = DERBY_CLOSED;
    NextDerbyStatus();
    return 1;
}

// Placar em texto
ClaScoreText()
{
    new txt[128];
    format(txt, sizeof(txt), "~w~round ~y~%d~w~/~y~%d~n~~w~cla1 ~y~%d ~w~x ~y~%d ~w~cla2",
        CL[CL_ROUND_ATUAL], CL[CL_ROUNDS], CL[CL_PONTOS][0], CL[CL_PONTOS][1]);
    return txt;
}

// Encerra o round. team = 0/1 vencedor, -1 = empate
ClaEndRound(team)
{
    if(!CL[CL_RODANDO]) return 0;

    KillTimer(DI[D_TIMEOUT_TIMER]);
    KillTimer(DI[D_NEXTDSTATUS_TIMER]);

    new msg[160];
    if(team == 0 || team == 1)
    {
        CL[CL_PONTOS][team] += 1;
        format(msg, sizeof(msg), "{FFFF00}| CLA | Round %d vencido pelo {%06x}CLA %d{FFFF00}!  Placar: %d x %d",
            CL[CL_ROUND_ATUAL], CLA_COR_VAL[ CL[CL_COR][team] ] >>> 8, team + 1,
            CL[CL_PONTOS][0], CL[CL_PONTOS][1]);
    }
    else
    {
        format(msg, sizeof(msg), "{FFFF00}| CLA | Round %d terminou empatado. Placar: %d x %d",
            CL[CL_ROUND_ATUAL], CL[CL_PONTOS][0], CL[CL_PONTOS][1]);
    }
    SendMessageToAllDerby(COLOR_YELLOW, msg);
    TextDrawSetString(TD_DerbyMessage, ClaScoreText());

    if(CL[CL_ROUND_ATUAL] >= CL[CL_ROUNDS])
    {
        SetTimer("ClaFinishTimer", 4000, false);
        return 1;
    }

    CL[CL_ROUND_ATUAL] += 1;
    SetTimer("ClaNextRoundTimer", 4000, false);
    return 1;
}

// Verifica se algum cla foi eliminado
ClaCheckRoundEnd()
{
    if(!CL[CL_RODANDO] || DI[D_STATUS] != DERBY_RUNNING) return 0;

    new v0 = ClaCountAlive(0);
    new v1 = ClaCountAlive(1);

    if(v0 == 0 && v1 == 0) return ClaEndRound(-1);
    if(v0 == 0) return ClaEndRound(1);
    if(v1 == 0) return ClaEndRound(0);
    return 0;
}

// Chamado quando um jogador e eliminado no modo CLA
ClaAfterDeath(playerid)
{
    // coloca para assistir alguem vivo
    new alvo = -1;
    foreach(i)
    {
        if(PI[i][P_IN_DERBY] && PI[i][P_DERBY_STATUS] == PD_NORMAL)
        {
            alvo = i;
            break;
        }
    }

    PI[playerid][P_DERBY_STATUS] = PD_SPECTATE;

    if(alvo != -1 && IsValidVehicle(PI[alvo][P_DERBY_VEHICLEID]))
    {
        PI[playerid][P_DERBY_SPECTATEPLAYER] = alvo;
        TogglePlayerSpectatingEx(playerid, true);
        PlayerSpectateVehicle(playerid, PI[alvo][P_DERBY_VEHICLEID]);
        TextDrawShowForPlayer(playerid, TD_ESPEC_DERBY);
    }

    ClaCheckRoundEnd();
    return 1;
}

// Zera tudo e volta para o modo FUN
ClaStopAll(const motivo[])
{
    // desliga o flag ANTES de remover ninguem para nao reentrar em ClaCheckRoundEnd
    CL[CL_RODANDO] = 0;

    KillTimer(DI[D_TIMEOUT_TIMER]);
    KillTimer(DI[D_COUNTDOWN_TIMER]);
    KillTimer(DI[D_NEXTDSTATUS_TIMER]);

    new msg[144];
    format(msg, sizeof(msg), "{FF0000}| CLA | %s", motivo);
    SendMessageToAllDerby(COLOR_RED, msg);

    foreach(i)
    {
        if(PI[i][P_IN_DERBY])
        {
            RemovePlayerFromDerby(i);
            PI[i][P_CLA] = -1;
            SetPlayerColor(i, COLOR_WHITE);
            SetPlayerTeam(i, NO_TEAM);
            SpawnPlayer(i);
        }
    }

    ClaResetConfig();
    DERBY_MODO = MODO_FUN;
    CloseDerby();
    return 1;
}


// =============================================================================
// TIMERS DO MODO CLA
// =============================================================================

public ClaNextRoundTimer()
{
    if(!CL[CL_RODANDO]) return 1;

    // libera slots e reativa todos os inscritos
    for(new i = 0; i != sizeof(DERBY_SLOT_USED); i++) DERBY_SLOT_USED[i] = false;

    foreach(i)
    {
        if(PI[i][P_IN_DERBY])
        {
            PI[i][P_DERBY_STATUS] = PD_NORMAL;
            DerbyAwaySeconds[i] = 0;
            TextDrawHideForPlayer(i, TD_ESPEC_DERBY);
        }
    }

    new msg[96];
    format(msg, sizeof(msg), "{FFFF00}| CLA | Preparando round %d de %d...", CL[CL_ROUND_ATUAL], CL[CL_ROUNDS]);
    SendMessageToAllDerby(COLOR_YELLOW, msg);

    DI[D_STATUS] = DERBY_CLOSED;
    NextDerbyStatus();
    return 1;
}

public ClaFinishTimer()
{
    new campeao = -1;
    if(CL[CL_PONTOS][0] > CL[CL_PONTOS][1]) campeao = 0;
    else if(CL[CL_PONTOS][1] > CL[CL_PONTOS][0]) campeao = 1;

    new msg[176];
    if(campeao == -1)
    {
        format(msg, sizeof(msg), "{FFFF00}| CLA VS CLA | FIM! Empate %d x %d", CL[CL_PONTOS][0], CL[CL_PONTOS][1]);
        SendMessageToAllDerby(COLOR_YELLOW, msg);
        TextDrawSetString(TD_DerbyMessage, "~y~empate!");
    }
    else
    {
        format(msg, sizeof(msg), "{FFFF00}| CLA VS CLA | FIM! {%06x}CLA %d{FFFF00} campeao com %d x %d",
            CLA_COR_VAL[ CL[CL_COR][campeao] ] >>> 8, campeao + 1,
            CL[CL_PONTOS][0], CL[CL_PONTOS][1]);
        SendMessageToAllDerby(COLOR_YELLOW, msg);

        new td[96];
        format(td, sizeof(td), "~g~cla %d campeao!~n~~w~%d x %d", campeao + 1, CL[CL_PONTOS][0], CL[CL_PONTOS][1]);
        TextDrawSetString(TD_DerbyMessage, td);

        // premia os vencedores
        foreach(i)
        {
            if(PI[i][P_IN_DERBY] && PI[i][P_CLA] == campeao)
            {
                GivePlayerScoreEx(i, 10);
                PlayerPlaySoundEx(i, 1057, 0.0, 0.0, 0.0);
                if(Database != DB:0)
                {
                    format(DB_Query, sizeof(DB_Query), "UPDATE derby_stats SET wins = wins + 1, score_total = score_total + 10, last_played = CURRENT_TIMESTAMP WHERE player_name = '%s'", PI[i][P_NAME]);
                    db_query(Database, DB_Query);
                }
            }
        }
    }

    SetTimer("ClaCleanupTimer", 6000, false);
    return 1;
}

public ClaCleanupTimer()
{
    ClaStopAll("Partida encerrada. O servidor voltou para o MODO FUN.");
    return 1;
}


// =============================================================================
// TELA INICIAL DE ESCOLHA DE MODO (/derby)
// =============================================================================

ShowModeSelect(playerid)
{
    new info[512], linha[200];

    format(linha, sizeof(linha), "{FFFFFF}MODO FUN\t{00FF00}%d jogando\t{CCCCCC}Mapas trocando automaticamente\n",
        (DERBY_MODO == MODO_FUN) ? DI[D_PLAYERS] : 0);
    strcat(info, linha);

    if(CL[CL_RODANDO])
    {
        format(linha, sizeof(linha), "{FFFFFF}CLA VS CLA\t{FFFF00}EM ANDAMENTO\t{CCCCCC}Round %d/%d - %d x %d\n",
            CL[CL_ROUND_ATUAL], CL[CL_ROUNDS], CL[CL_PONTOS][0], CL[CL_PONTOS][1]);
    }
    else if(IsPlayerAdmin(playerid))
    {
        format(linha, sizeof(linha), "{FFFFFF}CLA VS CLA\t{00FF00}CONFIGURAR\t{CCCCCC}Voce e RCON: pode configurar\n");
    }
    else
    {
        format(linha, sizeof(linha), "{FFFFFF}CLA VS CLA\t{FF0000}FECHADO\t{CCCCCC}Aguarde um admin configurar\n");
    }
    strcat(info, linha);

    ShowPlayerDialog(playerid, DLG_MODO, DIALOG_STYLE_TABLIST_HEADERS,
        "DERBY - Escolha o modo\tStatus\tInfo", info, "Selecionar", "Sair");
    return 1;
}

// =============================================================================
// RESPOSTAS DOS DIALOGOS
// =============================================================================

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        // ------------------------- escolha do modo -------------------------
        case DLG_MODO:
        {
            if(!response) return 1;

            if(listitem == 0) // MODO FUN
            {
                if(CL[CL_RODANDO])
                    return SCM(playerid, COLOR_RED, "[ERRO]: Existe um CLA VS CLA em andamento. Aguarde terminar.");

                DERBY_MODO = MODO_FUN;
                PI[playerid][P_CLA] = -1;
                SetPlayerColor(playerid, COLOR_WHITE);
                SetPlayerTeam(playerid, NO_TEAM);
                JoinPlayerDerby(playerid);
                return 1;
            }

            if(listitem == 1) // CLA VS CLA
            {
                if(CL[CL_RODANDO]) return ClaShowTeamSelect(playerid);
                if(CL[CL_CONFIGURADO]) return ClaShowTeamSelect(playerid);

                if(IsPlayerAdmin(playerid))
                {
                    CL[CL_ADMIN] = playerid;
                    return ClaShowConfig(playerid);
                }
                return SCM(playerid, COLOR_ORANGE, "| CLA | Nenhuma partida configurada. Aguarde um administrador.");
            }
            return 1;
        }

        // ------------------------- config principal -------------------------
        case DLG_CLA_CONFIG:
        {
            if(!response) return 1;
            if(!IsPlayerAdmin(playerid))
                return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON pode configurar.");

            switch(listitem)
            {
                case 0: ClaShowMapList(playerid);
                case 1:
                {
                    ShowPlayerDialog(playerid, DLG_CLA_TEMPO, DIALOG_STYLE_INPUT,
                        "Tempo por round",
                        "Digite o tempo de cada round em SEGUNDOS.\n\nMinimo: 30   Maximo: 900\n\nExemplo: 120", "Salvar", "Voltar");
                }
                case 2:
                {
                    ShowPlayerDialog(playerid, DLG_CLA_ROUNDS, DIALOG_STYLE_INPUT,
                        "Quantidade de rounds",
                        "Digite quantos rounds a partida tera.\n\nMinimo: 1   Maximo: 30\n\nExemplo: 5", "Salvar", "Voltar");
                }
                case 3:
                {
                    ShowPlayerDialog(playerid, DLG_CLA_VEICULO, DIALOG_STYLE_INPUT,
                        "Veiculo da partida",
                        "{FFFFFF}DIGITE O ID DO VEICULO\n\n{CCCCCC}Faixa valida: 400 a 611\n\nSugestoes:\n411 Infernus | 451 Turismo | 495 Sandking\n560 Sultan | 444 Monster | 541 Bullet", "Salvar", "Voltar");
                }
                case 4: ClaShowColorList(playerid, 0);
                case 5: ClaShowColorList(playerid, 1);
                case 6: ClaShowPlayerList(playerid);
                case 7: ClaStart(playerid);
                case 8:
                {
                    if(CL[CL_RODANDO]) ClaStopAll("Partida cancelada pelo administrador.");
                    else
                    {
                        ClaResetConfig();
                        SCM(playerid, COLOR_YELLOW, "| CLA | Configuracao resetada.");
                        ClaShowConfig(playerid);
                    }
                }
            }
            return 1;
        }

        // ------------------------- escolha do mapa -------------------------
        case DLG_CLA_MAPA:
        {
            if(!response) return ClaShowConfig(playerid);
            if(listitem >= 0 && listitem < TOTAL_DERBYS) CL[CL_MAPA] = listitem;
            return ClaShowConfig(playerid);
        }

        // ------------------------- tempo do round -------------------------
        case DLG_CLA_TEMPO:
        {
            if(!response) return ClaShowConfig(playerid);
            new v = strval(inputtext);
            if(v < 30 || v > 900)
            {
                SCM(playerid, COLOR_RED, "[ERRO]: Valor invalido. Use entre 30 e 900 segundos.");
                return ClaShowConfig(playerid);
            }
            CL[CL_TEMPO] = v;
            return ClaShowConfig(playerid);
        }

        // ------------------------- quantidade de rounds -------------------------
        case DLG_CLA_ROUNDS:
        {
            if(!response) return ClaShowConfig(playerid);
            new v = strval(inputtext);
            if(v < 1 || v > 30)
            {
                SCM(playerid, COLOR_RED, "[ERRO]: Valor invalido. Use entre 1 e 30 rounds.");
                return ClaShowConfig(playerid);
            }
            CL[CL_ROUNDS] = v;
            return ClaShowConfig(playerid);
        }

        // ------------------------- id do veiculo -------------------------
        case DLG_CLA_VEICULO:
        {
            if(!response) return ClaShowConfig(playerid);
            new v = strval(inputtext);
            if(v < 400 || v > 611)
            {
                SCM(playerid, COLOR_RED, "[ERRO]: ID de veiculo invalido. Use entre 400 e 611.");
                return ClaShowConfig(playerid);
            }
            CL[CL_VEICULO] = v;
            return ClaShowConfig(playerid);
        }

        // ------------------------- cores -------------------------
        case DLG_CLA_COR1:
        {
            if(!response) return ClaShowConfig(playerid);
            if(listitem == CL[CL_COR][1])
            {
                SCM(playerid, COLOR_RED, "[ERRO]: Essa cor ja e do CLA 2. Escolha outra.");
                return ClaShowConfig(playerid);
            }
            CL[CL_COR][0] = listitem;
            return ClaShowConfig(playerid);
        }
        case DLG_CLA_COR2:
        {
            if(!response) return ClaShowConfig(playerid);
            if(listitem == CL[CL_COR][0])
            {
                SCM(playerid, COLOR_RED, "[ERRO]: Essa cor ja e do CLA 1. Escolha outra.");
                return ClaShowConfig(playerid);
            }
            CL[CL_COR][1] = listitem;
            return ClaShowConfig(playerid);
        }

        // ------------------------- jogador escolhe o cla -------------------------
        case DLG_CLA_TIME:
        {
            if(!response) return 1;
            if(listitem == 0 || listitem == 1) ClaJoin(playerid, listitem);
            return 1;
        }

        // ------------------------- admin escolhe o jogador -------------------------
        case DLG_CLA_PLAYERS:
        {
            if(!response) return ClaShowConfig(playerid);
            if(!IsPlayerAdmin(playerid))
                return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON pode fazer isso.");

            // descobre qual jogador corresponde ao item selecionado
            new idx = 0, escolhido = INVALID_PLAYER_ID;
            foreach(i)
            {
                if(idx == listitem) { escolhido = i; break; }
                idx++;
            }

            if(escolhido == INVALID_PLAYER_ID)
                return ClaShowPlayerList(playerid);

            ClaSelPlayer[playerid] = escolhido;
            return ClaShowSetTeam(playerid, escolhido);
        }

        // ------------------------- admin define o time -------------------------
        case DLG_CLA_SETTEAM:
        {
            if(!response) return ClaShowPlayerList(playerid);
            if(!IsPlayerAdmin(playerid))
                return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON pode fazer isso.");

            new alvo = ClaSelPlayer[playerid];
            if(alvo == INVALID_PLAYER_ID || !IsPlayerConnected(alvo))
            {
                SCM(playerid, COLOR_RED, "[ERRO]: Jogador invalido.");
                return ClaShowPlayerList(playerid);
            }

            if(listitem == 0)      ClaSetTeam(playerid, alvo, 0);
            else if(listitem == 1) ClaSetTeam(playerid, alvo, 1);
            else if(listitem == 2) ClaSetTeam(playerid, alvo, -1);

            ClaSelPlayer[playerid] = INVALID_PLAYER_ID;
            return ClaShowPlayerList(playerid);
        }
    }
    return 0;
}


// =============================================================================
// SISTEMA DE COMANDOS (sem include externo)
// =============================================================================

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[32], params[128], idx;
    cmd = strtok(cmdtext, idx);
    format(params, sizeof(params), "%s", cmdtext[idx]);

    // Remover espaco inicial dos params
    if(strlen(params) > 0 && params[0] == ' ')
    {
        strdel(params, 0, 1);
    }

    if(!strcmp(cmd, "/derby", true)) return dcmd_derby(playerid, params);
    if(!strcmp(cmd, "/cla", true)) return dcmd_cla(playerid, params);
    if(!strcmp(cmd, "/sair", true)) return dcmd_sair(playerid, params);
    if(!strcmp(cmd, "/stats", true)) return dcmd_stats(playerid, params);
    if(!strcmp(cmd, "/top", true)) return dcmd_top(playerid, params);
    if(!strcmp(cmd, "/ajuda", true)) return dcmd_ajuda(playerid, params);
    if(!strcmp(cmd, "/help", true)) return dcmd_help(playerid, params);
    if(!strcmp(cmd, "/diag", true)) return dcmd_diag(playerid, params);
    if(!strcmp(cmd, "/reloadmaps", true)) return dcmd_reloadmaps(playerid, params);
    if(!strcmp(cmd, "/skimap", true)) return dcmd_skimap(playerid, params);
    if(!strcmp(cmd, "/setmap", true)) return dcmd_setmap(playerid, params);

    SCM(playerid, COLOR_RED, "[ERRO]: Comando desconhecido. Use /ajuda.");
    return 1;
}

stock strtok(const string[], &index)
{
    new length = strlen(string);
    new result[32];
    new pos = 0;

    // Pular espacos iniciais
    while(index < length && string[index] == ' ') index++;

    // Extrair token
    while(index < length && string[index] != ' ' && pos < 31)
    {
        result[pos] = string[index];
        pos++;
        index++;
    }
    result[pos] = '\0';
    return result;
}

// =============================================================================
// COMANDOS
// =============================================================================

dcmd_derby(playerid, const params[])
{
    #pragma unused params
    if(PI[playerid][P_IN_DERBY])
        return SCM(playerid, COLOR_ORANGE, "| DERBY | Voce ja esta jogando. Use /sair para sair.");

    if(DI[D_PLAYERS] >= MAX_DERBY_PLAYERS)
        return SCM(playerid, COLOR_RED, "[ERRO]: A sala esta lotada.");

    return ShowModeSelect(playerid);
}

// Reabre o painel de configuracao do CLA VS CLA (somente RCON)
dcmd_cla(playerid, const params[])
{
    #pragma unused params
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO]: Apenas administradores RCON podem usar este comando.");

    CL[CL_ADMIN] = playerid;
    return ClaShowConfig(playerid);
}

dcmd_sair(playerid, const params[])
{
    #pragma unused params
    if(!PI[playerid][P_IN_DERBY])
        return SCM(playerid, COLOR_ORANGE, "| DERBY | Voce nao esta no Derby!");

    RemovePlayerFromDerby(playerid);
    PI[playerid][P_CLA] = -1;
    SetPlayerColor(playerid, COLOR_WHITE);
    SetPlayerTeam(playerid, NO_TEAM);
    SCM(playerid, COLOR_YELLOW, "| DERBY | Voce saiu. Use /derby para voltar.");
    // Spawna o jogador numa posicao neutra
    SetPlayerPos(playerid, 0.0, 0.0, 5.0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}

dcmd_stats(playerid, const params[])
{
    #pragma unused params
    if(Database == DB:0)
        return SCM(playerid, COLOR_RED, "[ERRO]: Banco de dados indisponivel.");

    format(DB_Query, sizeof(DB_Query), "SELECT wins, losses, plays, score_total FROM derby_stats WHERE player_name = '%s'",
        PI[playerid][P_NAME]);
    new DBResult:result = db_query(Database, DB_Query);

    if(db_num_rows(result) > 0)
    {
        new wins[10], losses[10], plays[10], score[10];
        db_get_field_assoc(result, "wins", wins, sizeof(wins));
        db_get_field_assoc(result, "losses", losses, sizeof(losses));
        db_get_field_assoc(result, "plays", plays, sizeof(plays));
        db_get_field_assoc(result, "score_total", score, sizeof(score));

        new str[256];
        SCM(playerid, COLOR_GREEN, "============ SUAS ESTATISTICAS ============");
        format(str, sizeof(str), "   Vitorias: {00FF00}%s  {FFFFFF}| Derrotas: {FF0000}%s  {FFFFFF}| Partidas: {FFFF00}%s", wins, losses, plays);
        SCM(playerid, COLOR_WHITE, str);
        format(str, sizeof(str), "   Score Total: {00FF00}%s", score);
        SCM(playerid, COLOR_WHITE, str);
        SCM(playerid, COLOR_GREEN, "============================================");
    }
    else
    {
        SCM(playerid, COLOR_ORANGE, "| DERBY | Nenhuma estatistica encontrada.");
    }
    db_free_result(result);
    return 1;
}


dcmd_top(playerid, const params[])
{
    #pragma unused params
    if(Database == DB:0)
        return SCM(playerid, COLOR_RED, "[ERRO]: Banco de dados indisponivel.");

    format(DB_Query, sizeof(DB_Query), "SELECT player_name, wins, score_total FROM derby_stats ORDER BY wins DESC LIMIT 10");
    new DBResult:result = db_query(Database, DB_Query);

    if(db_num_rows(result) > 0)
    {
        SCM(playerid, COLOR_GREEN, "========== TOP 10 JOGADORES ==========");
        new pos = 1;
        new name[24], wins[10], score[10], str[128];

        while(db_num_rows(result) > 0)
        {
            db_get_field_assoc(result, "player_name", name, sizeof(name));
            db_get_field_assoc(result, "wins", wins, sizeof(wins));
            db_get_field_assoc(result, "score_total", score, sizeof(score));

            format(str, sizeof(str), "  #%d - %s | Vitorias: %s | Score: %s", pos, name, wins, score);
            SCM(playerid, COLOR_WHITE, str);

            pos++;
            if(!db_next_row(result)) break;
        }
        SCM(playerid, COLOR_GREEN, "======================================");
    }
    else
    {
        SCM(playerid, COLOR_ORANGE, "| DERBY | Nenhuma estatistica encontrada.");
    }
    db_free_result(result);
    return 1;
}

dcmd_ajuda(playerid, const params[])
{
    #pragma unused params
    SCM(playerid, COLOR_GREEN, "============ COMANDOS DO DERBY ============");
    SCM(playerid, COLOR_WHITE, "  /derby   - Escolher modo (FUN ou CLA VS CLA)");
    SCM(playerid, COLOR_WHITE, "  /cla     - Painel do CLA VS CLA (somente RCON)");
    SCM(playerid, COLOR_WHITE, "  /sair    - Sair do Derby");
    SCM(playerid, COLOR_WHITE, "  /stats   - Ver suas estatisticas");
    SCM(playerid, COLOR_WHITE, "  /top     - Ver ranking dos melhores");
    SCM(playerid, COLOR_WHITE, "  /ajuda   - Mostrar esta lista");
    SCM(playerid, COLOR_GREEN, "===========================================");
    SCM(playerid, COLOR_GREY, "Dica: Durante a espera, vote SIM ou NAO para God Car!");
    SCM(playerid, COLOR_GREY, "God Car = reparo automatico do veiculo durante a partida.");
    return 1;
}

dcmd_help(playerid, const params[])
{
    #pragma unused params
    return dcmd_ajuda(playerid, "");
}


// =============================================================================
// ADMIN COMMANDS (Opcional)
// =============================================================================

// Diagnostico: mostra tudo que importa para descobrir por que o mapa nao aparece
dcmd_diag(playerid, const params[])
{
    #pragma unused params
    new str[160];
    new pvw = GetPlayerVirtualWorld(playerid);

    SCM(playerid, COLOR_GREEN, "========== DIAGNOSTICO DERBY ==========");

    format(str, sizeof(str), "Mapas na lista: {FFFF00}%d{FFFFFF}   Tabela vworlds: {FFFF00}%d", TOTAL_DERBYS, VW_TOTAL);
    SCM(playerid, COLOR_WHITE, str);

    if(TOTAL_DERBYS <= 0)
    {
        SCM(playerid, COLOR_RED, ">> scriptfiles/DERBY/ NAO foi encontrado. Nada mais vai funcionar.");
        return 1;
    }

    format(str, sizeof(str), "Mapa atual: id {FFFF00}%d{FFFFFF}  nome {FFFF00}%s", DI[D_ID], DI[D_NAME]);
    SCM(playerid, COLOR_WHITE, str);

    format(str, sizeof(str), "Arquivo: {FFFF00}%s", DERBY_FILENAMES[DI[D_ID]]);
    SCM(playerid, COLOR_WHITE, str);

    format(str, sizeof(str), "VW do mapa: {FFFF00}%d{FFFFFF}   Seu VW: {FFFF00}%d{FFFFFF}   %s",
        DI[D_VW], pvw, (DI[D_VW] == pvw) ? ("{00FF00}(iguais - OK)") : ("{FF0000}(DIVERGENTE!)"));
    SCM(playerid, COLOR_WHITE, str);

    format(str, sizeof(str), "Veiculo do mapa: {FFFF00}%d{FFFFFF}   Z de eliminacao: {FFFF00}%.1f", DI[D_VEHICLE], DI[D_ZPOS]);
    SCM(playerid, COLOR_WHITE, str);

    format(str, sizeof(str), "Spawn 1 do mapa: {FFFF00}%.1f, %.1f, %.1f",
        DERBY_SPAWN[0][0], DERBY_SPAWN[0][1], DERBY_SPAWN[0][2]);
    SCM(playerid, COLOR_WHITE, str);

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    format(str, sizeof(str), "Sua posicao agora: {FFFF00}%.1f, %.1f, %.1f", px, py, pz);
    SCM(playerid, COLOR_WHITE, str);

    SCM(playerid, COLOR_GREEN, "---------------- como ler ----------------");
    if(DERBY_SPAWN[0][0] == 0.0 && DERBY_SPAWN[0][1] == 0.0)
        SCM(playerid, COLOR_RED, ">> Spawn zerado: o arquivo .sfr nao foi lido.");
    else
        SCM(playerid, COLOR_GREY, ">> Spawn tem coordenadas: o .sfr foi lido corretamente.");

    if(DI[D_VW] != pvw)
        SCM(playerid, COLOR_RED, ">> Seu VW nao bate com o do mapa. Avise o desenvolvedor.");
    else
        SCM(playerid, COLOR_GREY, ">> VW correto. Se nao ha plataforma, o filterscript SFRDERBY nao esta ativo.");

    SCM(playerid, COLOR_GREY, ">> No console deve aparecer: MAPAS DERBY CARGADOS || MAPAS: 52");
    SCM(playerid, COLOR_GREY, ">> Se nao aparecer: falta 'plugins streamer' ou 'filterscripts SFRDERBY'.");
    return 1;
}

dcmd_reloadmaps(playerid, const params[])
{
    #pragma unused params
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON admins podem usar este comando.");

    LoadVirtualWorlds();
    LoadDerbyMapList();
    CacheMapNames();
    new str[64];
    format(str, sizeof(str), "| ADMIN | Mapas recarregados. Total: %d mapas.", TOTAL_DERBYS);
    SCM(playerid, COLOR_GREEN, str);
    return 1;
}

dcmd_skimap(playerid, const params[])
{
    #pragma unused params
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON admins podem usar este comando.");

    if(DI[D_STATUS] == DERBY_RUNNING)
    {
        SendMessageToAllDerby(COLOR_YELLOW, "| ADMIN | Mapa foi pulado pelo administrador!");
        DI[D_RUNNINGPLAYERS] = 0;
        KillTimer(DI[D_NEXTDSTATUS_TIMER]);
        DI[D_NEXTDSTATUS_TIMER] = SetTimer("NextDerbyStatus", 1000, false);
    }
    else
    {
        SCM(playerid, COLOR_ORANGE, "| DERBY | Nenhuma partida em andamento.");
    }
    return 1;
}

dcmd_setmap(playerid, const params[])
{
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON admins podem usar este comando.");

    new mapid;
    if(sscanf(params, "d", mapid))
        return SCM(playerid, COLOR_GREY, "Uso: /setmap [id do mapa (0 a N)]");

    if(mapid < 0 || mapid >= TOTAL_DERBYS)
        return SCM(playerid, COLOR_RED, "[ERRO]: ID de mapa invalido.");

    DI[D_ID] = mapid;
    new str[64];
    format(str, sizeof(str), "| ADMIN | Proximo mapa definido para ID %d.", mapid);
    SCM(playerid, COLOR_GREEN, str);
    return 1;
}

// =============================================================================
// FIM DO GAMEMODE
// =============================================================================
