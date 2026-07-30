// =============================================================================
// CONFIG.INC - Configuracoes globais do servidor
// =============================================================================

// --- Servidor ---
#define SERVER_NAME             "DERBY DESTRUCTION"
#define SERVER_VERSION          "2.0"
#define SERVER_GAMEMODE_TEXT    "Derby v2.0"

// --- Limites ---
#undef  MAX_PLAYERS
#define MAX_PLAYERS             (50)
#define MAX_DERBY_SLOTS         (20)        // max jogadores por partida
#define MAX_MAPS                (200)       // max mapas carregaveis
#define MAX_MAP_OBJECTS         (500)       // max objetos por mapa (se inline)

// --- Gameplay ---
#define COUNTDOWN_SECONDS       (5)         // contagem regressiva antes de GO
#define ROUND_TIMEOUT           (180)       // tempo max de um round (segundos)
#define AFK_WARN_TIME           (10)        // segundos parado para avisar
#define AFK_KICK_TIME           (20)        // segundos parado para eliminar
#define NITRO_COMPONENT         (1010)      // NOS controlavel (segura mouse)
#define RESPAWN_DELAY_MS        (1500)      // delay antes de respawn no treino

// --- Virtual Worlds ---
#define VW_LOBBY                (0)         // mundo do lobby
#define VW_DERBY_BASE           (50)        // base para VW dos mapas (50 + indice)
#define VW_CLA                  (300)       // mundo do CLA

// --- Dialogos ---
#define DLG_WELCOME             (5000)
#define DLG_MODE_SELECT         (5001)
#define DLG_CLA_PANEL           (5010)
#define DLG_CLA_VEHICLE         (5011)
#define DLG_CLA_MAP             (5012)
#define DLG_CLA_ROUNDS          (5013)
#define DLG_CLA_MEMBERS         (5014)

// --- Cores ---
#define COL_WHITE               0xFFFFFFFF
#define COL_RED                 0xFF4444FF
#define COL_GREEN               0x44FF44FF
#define COL_BLUE                0x4488FFFF
#define COL_YELLOW              0xFFFF00FF
#define COL_ORANGE              0xFF8800FF
#define COL_GREY                0xAAAAAAFF
#define COL_PURPLE              0xAA44FFFF
#define COL_CYAN                0x00FFFFFF
#define COL_GOLD                0xFFD700FF
#define COL_DERBY               0xFF6600FF  // cor identidade do servidor

// Cores em HEX string (para usar em format/chat)
#define C_WHITE                 "{FFFFFF}"
#define C_RED                   "{FF4444}"
#define C_GREEN                 "{44FF44}"
#define C_BLUE                  "{4488FF}"
#define C_YELLOW                "{FFFF00}"
#define C_ORANGE                "{FF8800}"
#define C_GREY                  "{AAAAAA}"
#define C_DERBY                 "{FF6600}"
#define C_GOLD                  "{FFD700}"

// --- Macros ---
#define SCM                     SendClientMessage
#define SCMAll                  SendClientMessageToAll
#define Loop(%0,%1)             for(new %0 = 0, %0##_max = GetPlayerPoolSize(); %0 <= %0##_max; %0++) if(IsPlayerConnected(%0))

// --- Compatibilidade ---
#if !defined DIALOG_STYLE_TABLIST
    #define DIALOG_STYLE_TABLIST         (4)
#endif
#if !defined DIALOG_STYLE_TABLIST_HEADERS
    #define DIALOG_STYLE_TABLIST_HEADERS (5)
#endif

native IsValidVehicle(vehicleid);
