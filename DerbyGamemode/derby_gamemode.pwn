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
#define DLG_CLA_ROUNDS      (9103)
#define DLG_CLA_VEICULO     (9104)
#define DLG_CLA_MEMBERS     (9105)
#define DLG_WELCOME         (9110)

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
};

enum PINFO
{
    P_NAME[MAX_PLAYER_NAME],
    P_DERBY_VEHICLEID,
    P_DERBY_POSITION,
    P_DERBY_STATUS,
    P_DERBY_SPECTATEPLAYER,
    bool:P_IN_DERBY,
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



// TextDraws
new Text:TD_DERBY[9];
new Text:TD_DerbyMessage;
new Text:TD_ESPEC_DERBY;

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
forward AntiAFKTimer();



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
    AddVehicleComponent(PI[playerid][P_DERBY_VEHICLEID], 1010); // Nitro controlavel
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

    // Mensagem comica para todos no Derby
    new msg[145];
    new frase[60];
    switch(random(12))
    {
        case 0: frase = "foi comido pelo tubarao! hahaha";
        case 1: frase = "CAIU! Muito ruim!";
        case 2: frase = "foi pro fundo do mar!";
        case 3: frase = "esqueceu que nao tem asas!";
        case 4: frase = "tentou voar... nao deu certo!";
        case 5: frase = "virou comida de peixe!";
        case 6: frase = "olhou pro lado errado e CAIU!";
        case 7: frase = "tropeou no proprio carro!";
        case 8: frase = "achou que era passaro!";
        case 9: frase = "foi empurrado com carinho!";
        case 10: frase = "disse adeus ao mundo!";
        case 11: frase = "mergulhou de cabeca!";
    }
    format(msg, sizeof(msg), "{FF6600}| DERBY | {FFFFFF}%s {FF6600}%s {999999}(pos: %d/%d | +%d score)",
        pNome(playerid), frase, DI[D_RUNNINGPLAYERS], DI[D_PLAYERS], score_gain);
    SendMessageToAllDerby(COLOR_ORANGE, msg);

    DI[D_RUNNINGPLAYERS] -= 1;

    // Ninguem sobrou (partida solo) -> encerra e troca de mapa
    if(DI[D_RUNNINGPLAYERS] <= 0)
    {
        DI[D_RUNNINGPLAYERS] = 0;
        SendMessageToAllDerby(COLOR_YELLOW, "| DERBY | Rodada encerrada. Carregando proximo mapa...");
        TextDrawSetString(TD_DerbyMessage, "~y~rodada encerrada");
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
            if(!LoadNextValidDerby(DI[D_ID]))
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


            foreach(players)
            {
                if(PI[players][P_IN_DERBY])
                {
                    SelectTextDraw(players, 0x999999FF);
                }
            }

            UpdatePlayersDerbyStatus();
        }
        case DERBY_RUNNING:
        {
            new nextid = DI[D_ID] + 1;
            if(nextid >= TOTAL_DERBYS) nextid = 0;
            if(!LoadNextValidDerby(nextid))
            {
                print("[DERBY] Nao foi possivel trocar de mapa.");
                return 1;
            }

            for(new i; i < sizeof(TD_DERBY); ++i)
                TextDrawHideForAll(TD_DERBY[i]);


            KillTimer(DI[D_TIMEOUT_TIMER]);
            DI[D_STATUS] = DERBY_WAIT;
            DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
            KillTimer(DI[D_COUNTDOWN_TIMER]);
            DI[D_COUNTDOWN_TIMER] = SetTimer("DerbyCountdown", 900, true);


            foreach(players)
            {
                if(PI[players][P_IN_DERBY])
                {
                    SelectTextDraw(players, 0x999999FF);
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
            }

            DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
            DI[D_MAX_PRIZE] = 1 * DI[D_PLAYERS];
            DI[D_MAX2_PRIZE] = 1 + DI[D_PLAYERS];
            DI[D_RUNNINGPLAYERS] = DI[D_PLAYERS];
            DI[D_TIMEOUT_COUNTER] = DERBY_TIMEOUT_SECONDS;
            KillTimer(DI[D_TIMEOUT_TIMER]);
            DI[D_TIMEOUT_TIMER] = SetTimer("DerbyTimeOutCountdown", 1000, true);
            DI[D_TICKCOUNT] = gettime();
            DI[D_STATUS] = DERBY_RUNNING;
            UpdatePlayersDerbyStatus();

                        else
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
                SCM(p, COLOR_INFO, "| MODO | {FFFFFF}Voce foi removido do derby por entrar em ESC.");
                RemovePlayerFromDerby(p);
                JoinPlayerDerby(p);
                format(remov, sizeof(remov), "| DERBY | %s (%i) Foi removido por ficar em ESC.", PI[p][P_NAME], p);
                SendMessageToAllDerby(COLOR_GREEN, remov);
            }
        }
    }

    // Tempo esgotado
    if(DI[D_TIMEOUT_COUNTER] < 0)
    {
        KillTimer(DI[D_TIMEOUT_TIMER]);

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
                SCM(i, COLOR_YELLOW, "| DERBY | Voce foi removido por ficar parado!");
                RemovePlayerFromDerby(i);
                JoinPlayerDerby(i);
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
#include "derby_cla.inc"

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
    ClaReset();

    // Inicializar banco de dados
    InitDatabase();

    // Timers globais
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
    PI[playerid][P_SCORE] = 0;
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
        RemovePlayerFromDerby(playerid);

    // Sair do CLA se estava inscrito
    if(CLA_INSCRITO[playerid])
    {
        if(CLA_VEHICLEID[playerid] != INVALID_VEHICLE_ID && IsValidVehicle(CLA_VEHICLEID[playerid]))
            DestroyVehicle(CLA_VEHICLEID[playerid]);
        CLA_INSCRITO[playerid] = false;
        CLA_TEAM[playerid] = -1;
        CLA_VEHICLEID[playerid] = INVALID_VEHICLE_ID;
    }
    return 1;
}


public OnPlayerSpawn(playerid)
{
    // Se ja esta no derby ou CLA, nao fazer nada
    if(PI[playerid][P_IN_DERBY] || CLA_INSCRITO[playerid])
        return 1;

    // Mostrar tela de boas-vindas/changelog automaticamente
    SetPlayerPos(playerid, 0.0, 0.0, 20.0);
    SetPlayerVirtualWorld(playerid, playerid + 500); // mundo isolado
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, false);

    new info[800];
    strcat(info, "{FFFFFF}Bem-vindo ao {FF0000}SERVIDOR DERBY!{FFFFFF}\n\n");
    strcat(info, "{00FF00}Como funciona:{FFFFFF}\n");
    strcat(info, "- Voce escolhe entre {FFFF00}MODO FUN{FFFFFF} (mapas automaticos)\n");
    strcat(info, "  ou {0066FF}CLA VS CLA{FFFFFF} (competitivo)\n\n");
    strcat(info, "{00FF00}MODO FUN:{FFFFFF}\n");
    strcat(info, "- Mapas trocam automaticamente\n");
    strcat(info, "- Ultimo a sobreviver na plataforma vence\n");
    strcat(info, "- Quem cai e eliminado e assiste\n\n");
    strcat(info, "{00FF00}CLA VS CLA:{FFFFFF}\n");
    strcat(info, "- Configurado pelo administrador (RCON)\n");
    strcat(info, "- Admin define: mapa, veiculo, times e rounds\n");
    strcat(info, "- Voce pode treinar livremente ate o round comecar\n\n");
    strcat(info, "{999999}Comandos: /derby /sair /stats /top /ajuda\n");
    strcat(info, "{999999}CLA VS CLA e configurado apenas pelo RCON.\n");

    ShowPlayerDialog(playerid, DLG_WELCOME, DIALOG_STYLE_MSGBOX,
        "{FFFFFF}DERBY - Bem-vindo!", info, "Jogar", "");
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    // Pula selecao de skin - spawn direto
    SpawnPlayer(playerid);
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
    // Verificar queda no CLA VS CLA
    if(CLA_INSCRITO[playerid] && CLA[CLA_RODANDO] && !CLA[CLA_PAUSADO])
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && CLA_VEHICLEID[playerid] != INVALID_VEHICLE_ID)
        {
            new Float:cx, Float:cy, Float:cz;
            GetVehiclePos(CLA_VEHICLEID[playerid], cx, cy, cz);
            if(cz <= DI[D_ZPOS])
            {
                ClaPlayerDied(playerid);
            }
        }
    }

    return 1;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{


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





// =============================================================================
// DIALOGOS
// =============================================================================

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    // Tela de boas-vindas -> abre selecao de modo
    if(dialogid == DLG_WELCOME)
    {
        TogglePlayerControllable(playerid, true);
        SetPlayerVirtualWorld(playerid, 0);
        // Mostrar painel de escolha de modo automaticamente
        ShowPlayerDialog(playerid, DLG_MODO, DIALOG_STYLE_LIST,
            "{FFFFFF}DERBY - Escolha o modo",
            "MODO FUN (mapas automaticos)\nCLA VS CLA (competitivo)",
            "Entrar", "");
        return 1;
    }

    // Tela de escolha de modo
    if(dialogid == DLG_MODO)
    {
        if(!response) return 1;
        if(listitem == 0) // MODO FUN
        {
            if(PI[playerid][P_IN_DERBY])
                return SCM(playerid, COLOR_ORANGE, "| DERBY | Voce ja esta no modo FUN!");
            JoinPlayerDerby(playerid);
            return 1;
        }
        if(listitem == 1) // CLA VS CLA
        {
            ClaEntrar(playerid);
            return 1;
        }
        return 1;
    }

    // Dialogos do CLA (delegados para o handler no include)
    if(dialogid >= DLG_CLA_CONFIG && dialogid <= DLG_CLA_MEMBERS)
    {
        if(!IsPlayerAdmin(playerid) && dialogid != DLG_CLA_MEMBERS)
            return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON.");
        return ClaHandleDialog(playerid, dialogid, response, listitem, inputtext);
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

    // Mostrar tela de escolha de modo
    ShowPlayerDialog(playerid, DLG_MODO, DIALOG_STYLE_LIST,
        "{FFFFFF}DERBY - Escolha o modo",
        "MODO FUN (mapas automaticos)\nCLA VS CLA (competitivo)",
        "Entrar", "Fechar");
    return 1;
}

dcmd_sair(playerid, const params[])
{
    #pragma unused params
    if(!PI[playerid][P_IN_DERBY])
        return SCM(playerid, COLOR_ORANGE, "| DERBY | Voce nao esta no Derby!");

    RemovePlayerFromDerby(playerid);
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
    SCM(playerid, COLOR_WHITE, "  /derby   - Entrar no Derby (FUN ou CLA VS CLA)");
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

dcmd_cla(playerid, const params[])
{
    #pragma unused params
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON pode usar /cla.");
    return ClaShowPanel(playerid);
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
