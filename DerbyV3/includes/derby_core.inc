/*
    DERBY V3 - CORE DEFINITIONS
    
    Modulo central com todas as definicoes, enumeradores, constantes,
    estruturas de dados e funcoes utilitarias compartilhadas.
*/

#if defined _derby_core_included
    #endinput
#endif
#define _derby_core_included

// Definicoes de seguranca caso nao existam no include
#if !defined DIALOG_STYLE_TABLIST_HEADERS
    #define DIALOG_STYLE_TABLIST_HEADERS 5
#endif

// =============================================================================
// CONFIGURACOES GLOBAIS
// =============================================================================

#undef MAX_PLAYERS
#define MAX_PLAYERS             50

#define GAMEMODETEXT            "Derby V3 - Salas"
#define HOSTNAME                "Derby V3 - Sistema de Salas Personalizadas"

#define MAX_ROOMS               10
#define MAX_ROOM_PLAYERS        20
#define MAX_DERBYS              200
#define MAX_ROOM_MAPS           50
#define MAX_ROUNDS              20

#define DERBY_BASE_VW           100
#define DERBY_TIMEOUT_SECONDS   180
#define DERBY_COUNTDOWN_SECONDS 10
#define AFK_WARNING_SECONDS     10
#define AFK_KICK_SECONDS        20

#define INVALID_ROOM_ID         (-1)
#define NO_WINNER               (-1)
#define INVALID_PLAYER          (-1)

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
#define COLOR_BLUE      0x0080FFFF
#define COLOR_PURPLE    0xCC00FFFF
#define COLOR_CYAN      0x00FFFFFF
#define COLOR_LIME      0x80FF00FF

// =============================================================================
// MODOS DE JOGO
// =============================================================================

enum
{
    MODE_FUN = 0,        // Modo publico com rotacao automatica
    MODE_TRAINING,       // Treino: respawn, sem pontuacao
    MODE_CLA_VS_CLA      // Competitivo: rounds, times, placar
};

// =============================================================================
// ESTADOS DA SALA
// =============================================================================

enum
{
    ROOM_STATE_EMPTY = 0,    // Sala nao existe
    ROOM_STATE_LOBBY,        // Aguardando jogadores / configurando
    ROOM_STATE_COUNTDOWN,    // Contagem regressiva
    ROOM_STATE_RUNNING,      // Partida em andamento
    ROOM_STATE_ROUND_END,    // Fim de round (entre rounds)
    ROOM_STATE_FINISHED      // Partida finalizada (mostrando resultado)
};

// =============================================================================
// ESTADOS DO JOGADOR
// =============================================================================

enum
{
    PL_ST_NONE = 0,       // Nao esta em nenhuma sala
    PL_ST_LOBBY,          // Na sala, aguardando inicio
    PL_ST_ALIVE,          // Vivo na partida
    PL_ST_DEAD,           // Eliminado
    PL_ST_SPECTATING      // Assistindo
};

// =============================================================================
// TIMES (CLA VS CLA)
// =============================================================================

enum
{
    TEAM_NONE = 0,
    TEAM_ALPHA,
    TEAM_BETA
};

// =============================================================================
// ESTRUTURA DO MAPA
// =============================================================================

enum E_MAP_DATA
{
    MAP_NAME[32],
    MAP_FILENAME[48],
    MAP_HOUR,
    MAP_WEATHER,
    MAP_VEHICLE,
    Float:MAP_ZMIN,
    MAP_SPAWNS,
    Float:MAP_SPAWN_X[20],
    Float:MAP_SPAWN_Y[20],
    Float:MAP_SPAWN_Z[20],
    Float:MAP_SPAWN_A[20]
};

// =============================================================================
// ESTRUTURA DA SALA
// =============================================================================

enum E_ROOM_DATA
{
    // Configuracao
    ROOM_ID,
    ROOM_NAME[32],
    ROOM_HOST,
    ROOM_MODE,
    ROOM_STATE,
    ROOM_PASSWORD[16],
    ROOM_MAX_PLAYERS,
    bool:ROOM_PRIVATE,
    
    // Partida
    ROOM_VEHICLE,
    ROOM_TOTAL_ROUNDS,
    ROOM_CURRENT_ROUND,
    ROOM_MAP_COUNT,
    ROOM_SELECTED_MAPS[50],
    ROOM_CURRENT_MAP_INDEX,
    
    // Jogadores
    ROOM_PLAYER_COUNT,
    ROOM_ALIVE_COUNT,
    ROOM_WINNER,
    
    // Placar CLA VS CLA
    ROOM_SCORE_ALPHA,
    ROOM_SCORE_BETA,
    
    // Timers
    ROOM_COUNTDOWN_VALUE,
    ROOM_COUNTDOWN_TIMER,
    ROOM_TIMEOUT_VALUE,
    ROOM_TIMEOUT_TIMER,
    ROOM_TRANSITION_TIMER,
    
    // Tempo
    ROOM_TICK_START
};

// =============================================================================
// ESTRUTURA DO JOGADOR
// =============================================================================

enum E_PLAYER_DATA
{
    // Info basica
    PL_NAME[MAX_PLAYER_NAME],
    PL_ROOM_ID,
    PL_STATE,
    PL_TEAM,
    
    // Derby
    PL_VEHICLE_ID,
    PL_SPAWN_SLOT,
    PL_SPECTATE_TARGET,
    bool:PL_IN_DERBY,
    
    // Nitro
    Float:PL_NITRO_FUEL,
    bool:PL_NITRO_ACTIVE,
    PL_NITRO_TIMER,
    
    // HUD
    PlayerText:PL_TD_VEHICLE_HP,
    
    // Stats
    PL_WINS,
    PL_LOSSES,
    PL_SCORE,
    
    // Anti-AFK
    Float:PL_LAST_POS_HASH,
    PL_AFK_SECONDS
};

// =============================================================================
// VARIAVEIS GLOBAIS
// =============================================================================

new RoomData[MAX_ROOMS][E_ROOM_DATA];
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];
new bool:RoomSlotUsed[MAX_ROOMS][MAX_ROOM_PLAYERS];

// Mapas globais (banco de mapas)
new MapPool[MAX_DERBYS][E_MAP_DATA];
new TotalMaps;
new MapFilenames[MAX_DERBYS][48];

// Sala FUN publica (sempre existe)
#define FUN_ROOM_ID     0

// =============================================================================
// LISTA DE VEICULOS PERMITIDOS
// =============================================================================

enum E_VEHICLE_INFO
{
    VEH_MODEL,
    VEH_NAME[24]
};

new const DerbyVehicles[][E_VEHICLE_INFO] = {
    {495, "Sandking"},
    {411, "Infernus"},
    {451, "Turismo"},
    {560, "Sultan"},
    {541, "Bullet"},
    {415, "Cheetah"},
    {502, "Hotring A"},
    {503, "Hotring B"},
    {504, "Bloodring"},
    {444, "Monster"},
    {556, "Monster B"},
    {557, "Monster A"},
    {468, "Sanchez"},
    {522, "NRG-500"},
    {461, "PCJ-600"},
    {429, "Banshee"},
    {402, "Buffalo"},
    {405, "Sentinel"},
    {477, "ZR-350"},
    {480, "Comet"},
    {506, "Super GT"},
    {559, "Jester"},
    {558, "Uranus"},
    {562, "Elegy"},
    {565, "Flash"},
    {587, "Euros"},
    {589, "Club"},
    {603, "Phoenix"},
    {400, "Landstalker"},
    {579, "Huntley"},
    {489, "Rancher"},
    {505, "Rancher Lure"},
    {470, "Patriot"},
    {500, "Mesa"},
    {568, "Bandito"},
    {424, "BF Injection"},
    {457, "Caddy"},
    {571, "Kart"}
};

#define TOTAL_DERBY_VEHICLES (sizeof(DerbyVehicles))

// =============================================================================
// DIALOG IDS
// =============================================================================

#define DIALOG_DERBY_MENU       3000
#define DIALOG_CREATE_ROOM      3001
#define DIALOG_ROOM_MODE        3002
#define DIALOG_ROOM_ROUNDS      3003
#define DIALOG_ROOM_VEHICLE     3004
#define DIALOG_ROOM_MAPS        3005
#define DIALOG_ROOM_NAME        3006
#define DIALOG_ROOM_PASSWORD    3007
#define DIALOG_ROOM_CONFIRM     3008
#define DIALOG_JOIN_ROOM        3009
#define DIALOG_ROOM_LIST        3010
#define DIALOG_HOST_MENU        3011
#define DIALOG_HOST_KICK        3012
#define DIALOG_HOST_TRANSFER    3013
#define DIALOG_HOST_VEHICLE     3014
#define DIALOG_HOST_ROUNDS      3015
#define DIALOG_HOST_MAPS        3016
#define DIALOG_ROOM_ENTER_PASS  3017
#define DIALOG_TRAINING_MENU    3018

// =============================================================================
// FUNCOES UTILITARIAS
// =============================================================================

stock GetPlayerNameEx(playerid, dest[], len)
{
    GetPlayerName(playerid, dest, len);
    return 1;
}

stock TimeToString(seconds, dest[], len)
{
    new minutes = seconds / 60;
    seconds -= minutes * 60;
    format(dest, len, "%d:%02d", minutes, seconds);
    return 1;
}

stock RandomEx(min, max)
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

stock GetVehicleNameByModel(modelid, dest[], len)
{
    format(dest, len, "Desconhecido");
    for(new i = 0; i < TOTAL_DERBY_VEHICLES; i++)
    {
        if(DerbyVehicles[i][VEH_MODEL] == modelid)
        {
            format(dest, len, "%s", DerbyVehicles[i][VEH_NAME]);
            break;
        }
    }
    return 1;
}

stock GetVehicleModelByIndex(index)
{
    if(index < 0 || index >= TOTAL_DERBY_VEHICLES) return 411;
    return DerbyVehicles[index][VEH_MODEL];
}

stock SendRoomMessage(roomid, color, const message[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerData[i][PL_ROOM_ID] == roomid)
        {
            SCM(i, color, message);
        }
    }
}

stock GetRoomVirtualWorld(roomid)
{
    return DERBY_BASE_VW + roomid;
}

stock Float:GetVehicleHealthEx(vehicleid)
{
    new Float:hp;
    GetVehicleHealth(vehicleid, hp);
    return hp;
}

stock DestroyVehicleSafe(vehicleid)
{
    if(vehicleid != 0 && vehicleid != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(vehicleid);
    }
}

stock GetModeName(mode, dest[], len)
{
    switch(mode)
    {
        case MODE_FUN: strmid(dest, "FUN", 0, 3, len);
        case MODE_TRAINING: strmid(dest, "Treinamento", 0, 11, len);
        case MODE_CLA_VS_CLA: strmid(dest, "CLA vs CLA", 0, 10, len);
        default: strmid(dest, "Desconhecido", 0, 12, len);
    }
    return 1;
}

stock GetRoomStateName(state, dest[], len)
{
    switch(state)
    {
        case ROOM_STATE_EMPTY: strmid(dest, "Vazia", 0, 5, len);
        case ROOM_STATE_LOBBY: strmid(dest, "Aguardando", 0, 10, len);
        case ROOM_STATE_COUNTDOWN: strmid(dest, "Iniciando", 0, 9, len);
        case ROOM_STATE_RUNNING: strmid(dest, "Em Partida", 0, 10, len);
        case ROOM_STATE_ROUND_END: strmid(dest, "Fim de Round", 0, 12, len);
        case ROOM_STATE_FINISHED: strmid(dest, "Finalizada", 0, 10, len);
        default: strmid(dest, "---", 0, 3, len);
    }
    return 1;
}
