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

#define DERBY_VW                (50)
#define AFK_WARNING_SECONDS     (10)
#define AFK_KICK_SECONDS        (20)
#define DERBY_TIMEOUT_SECONDS   (180)
#define DERBY_COUNTDOWN_SECONDS (10)

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
new DERBY_FILENAMES[MAX_DERBYS][24];

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

LoadDerbyNames(const mapname[])
{
    new File:Handler = fopen(mapname, io_read);
    if(!Handler) return 0;
    TOTAL_DERBYS = 0;
    for(new i = 0; i != MAX_DERBYS; i++) DERBY_FILENAMES[i] = "";
    while(fread(Handler, File_String))
    {
        if(TOTAL_DERBYS < MAX_DERBYS)
        {
            StripNewLine(File_String);
            format(DERBY_FILENAMES[TOTAL_DERBYS], 24, "%s", File_String);
            TOTAL_DERBYS++;
        }
    }
    fclose(Handler);
    return 1;
}

LoadDerby(derbyid)
{
    new File:Handler = fopen(DERBY_FILENAMES[derbyid], io_read);
    if(!Handler) return 0;
    new Count;
    while(fread(Handler, File_String))
    {
        StripNewLine(File_String);
        if(Count == 0)
        {
            if(sscanf(File_String, "p<,>s[24]dddf", DI[D_NAME], DI[D_HOUR], DI[D_WEATHER], DI[D_VEHICLE], DI[D_ZPOS]))
                return 0;
        }
        else
        {
            if(sscanf(File_String, "p<,>ffff", DERBY_SPAWN[Count-1][0], DERBY_SPAWN[Count-1][1], DERBY_SPAWN[Count-1][2], DERBY_SPAWN[Count-1][3]))
                return 0;
        }
        Count++;
    }
    fclose(Handler);
    DI[D_RUNNINGPLAYERS] = 0;
    DI[D_WINNER] = NO_WINNER;
    DI[D_TICKCOUNT] = 0;
    DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
    KillTimer(DI[D_NEXTDSTATUS_TIMER]);
    KillTimer(DI[D_COUNTDOWN_TIMER]);
    KillTimer(DI[D_TIMEOUT_TIMER]);
    for(new i = 0; i != sizeof(DERBY_SLOT_USED); i++) DERBY_SLOT_USED[i] = false;
    return 1;
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
                    SetPlayerVirtualWorld(players, DI[D_ID] + DERBY_VW);
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

                    // Mostrar TextDraws de votacao GodCar
                    for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
                        TextDrawShowForPlayer(players, TD_DERBY_GodCar[i]);
                    if(!PI[players][P_DERBY_VOTED])
                        SelectTextDraw(players, 0x999999FF);
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
            SetPlayerVirtualWorld(playerid, DI[D_ID] + DERBY_VW);
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

            for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
                TextDrawShowForPlayer(playerid, TD_DERBY_GodCar[i]);
            if(!PI[playerid][P_DERBY_VOTED])
                SelectTextDraw(playerid, 0x999999FF);
        }
        case DERBY_RUNNING:
        {
            // Entrou durante partida - modo spectate
            SetPlayerVirtualWorld(playerid, DI[D_ID] + DERBY_VW);
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
            if(!LoadDerby(DI[D_ID]))
            {
                DI[D_ID] = 0;
                LoadDerby(DI[D_ID]);
            }

            new str[64];
            format(str, 64, "~w~mapa: %s~n~~y~esperando_jogadores", DI[D_NAME]);
            TextDrawSetString(TD_DerbyMessage, str);
            DI[D_STATUS] = DERBY_WAIT;
            DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
            KillTimer(DI[D_COUNTDOWN_TIMER]);
            DI[D_COUNTDOWN_TIMER] = SetTimer("DerbyCountdown", 900, true);

            TextDrawSetString(TD_DERBY_GodCar[3], "SIM_GOD_CAR:_0~n~NAO_GOD_CAR:_0~n~_");

            foreach(players)
            {
                if(PI[players][P_IN_DERBY])
                {
                    for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
                        TextDrawShowForPlayer(players, TD_DERBY_GodCar[i]);
                    SelectTextDraw(players, 0x999999FF);
                }
            }

            UpdatePlayersDerbyStatus();
        }
        case DERBY_RUNNING:
        {
            DI[D_ID] += 1;
            if(!LoadDerby(DI[D_ID]))
            {
                DI[D_ID] = 0;
                LoadDerby(DI[D_ID]);
            }

            for(new i; i < sizeof(TD_DERBY); ++i)
                TextDrawHideForAll(TD_DERBY[i]);


            KillTimer(DI[D_TIMEOUT_TIMER]);
            DI[D_STATUS] = DERBY_WAIT;
            DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
            KillTimer(DI[D_COUNTDOWN_TIMER]);
            DI[D_COUNTDOWN_TIMER] = SetTimer("DerbyCountdown", 900, true);

            TextDrawSetString(TD_DERBY_GodCar[3], "SIM_GOD_CAR:_0~n~NAO_GOD_CAR:_0~n~_");

            foreach(players)
            {
                if(PI[players][P_IN_DERBY])
                {
                    for(new i = 0; i != sizeof TD_DERBY_GodCar; i++)
                        TextDrawShowForPlayer(players, TD_DERBY_GodCar[i]);
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
                PI[i][P_DERBY_VOTED] = false;
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
                SCM(p, COLOR_INFO, "| MODO | {FFFFFF}Voce foi removido do derby por entrar em ESC.");
                RemovePlayerFromDerby(p);
                JoinPlayerDerby(p); // Re-entra como spectate na proxima
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

    if(DI[D_PLAYERS] <= 1)
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
        else if(DI[D_PLAYERS] == 1)
        {
            format(str, 64, "~w~mapa: %s~n~~y~esperando_jogadores", DI[D_NAME]);
            TextDrawSetString(TD_DerbyMessage, str);
            TextDrawHideForAll(TD_ESPEC_DERBY);
            DI[D_COUNTDOWN_COUNTER] = DERBY_COUNTDOWN_SECONDS + 1;
            KillTimer(DI[D_COUNTDOWN_TIMER]);
            DI[D_COUNTDOWN_TIMER] = SetTimer("DerbyCountdown", 900, true);
        }
        else NextDerbyStatus();
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
    LoadDerbyNames("DERBY/derbys.sfr");
    printf("[DERBY] Total de mapas carregados: %d", TOTAL_DERBYS);

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
    {
        RemovePlayerFromDerby(playerid);
    }
    return 1;
}


public OnPlayerSpawn(playerid)
{
    // Se nao esta no derby, entrar automaticamente
    if(!PI[playerid][P_IN_DERBY])
    {
        JoinPlayerDerby(playerid);
    }
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    // Spawn direto sem selecao de skin
    SetPlayerPos(playerid, 0.0, 0.0, 5.0);
    SetPlayerCameraPos(playerid, 0.0, 0.0, 50.0);
    SetPlayerCameraLookAt(playerid, 0.0, 0.0, 5.0);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    // Se morreu no derby (improvavel, mas caso de seguranca)
    if(PI[playerid][P_IN_DERBY] && PI[playerid][P_DERBY_STATUS] == PD_NORMAL)
    {
        if(DI[D_STATUS] == DERBY_RUNNING && DI[D_RUNNINGPLAYERS] > 1)
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
            if(DI[D_STATUS] == DERBY_RUNNING && DI[D_RUNNINGPLAYERS] > 1)
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
            if(DI[D_STATUS] == DERBY_RUNNING && DI[D_RUNNINGPLAYERS] > 1)
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
    if(!strcmp(cmd, "/sair", true)) return dcmd_sair(playerid, params);
    if(!strcmp(cmd, "/stats", true)) return dcmd_stats(playerid, params);
    if(!strcmp(cmd, "/top", true)) return dcmd_top(playerid, params);
    if(!strcmp(cmd, "/ajuda", true)) return dcmd_ajuda(playerid, params);
    if(!strcmp(cmd, "/help", true)) return dcmd_help(playerid, params);
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
        return SCM(playerid, COLOR_ORANGE, "| DERBY | Voce ja esta no Derby!");

    if(DI[D_PLAYERS] >= MAX_DERBY_PLAYERS)
        return SCM(playerid, COLOR_RED, "[ERRO]: O Derby esta lotado.");

    JoinPlayerDerby(playerid);
    return 1;
}

dcmd_sair(playerid, const params[])
{
    #pragma unused params
    if(!PI[playerid][P_IN_DERBY])
        return SCM(playerid, COLOR_ORANGE, "| DERBY | Voce nao esta no Derby!");

    RemovePlayerFromDerby(playerid);
    SCM(playerid, COLOR_YELLOW, "| DERBY | Voce saiu do Derby. Use /derby para voltar.");
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
    SCM(playerid, COLOR_WHITE, "  /derby   - Entrar no Derby");
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

dcmd_reloadmaps(playerid, const params[])
{
    #pragma unused params
    if(!IsPlayerAdmin(playerid))
        return SCM(playerid, COLOR_RED, "[ERRO]: Apenas RCON admins podem usar este comando.");

    LoadDerbyNames("DERBY/derbys.sfr");
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
