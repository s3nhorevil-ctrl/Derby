// =============================================================================
//
//   DERBY DESTRUCTION - SA-MP Gamemode
//   Versao 2.0 - Reformulacao Total
//
//   Arquitetura modular. Cada sistema em seu proprio arquivo.
//   Compilar este arquivo gera o .amx final.
//
// =============================================================================

#include <a_samp>
#include <sscanf2>
#include <streamer>

#pragma tabsize 0
#pragma dynamic 131072

// =============================================================================
// MODULOS (ordem importa - dependencias primeiro)
// =============================================================================

#include "modules/config.inc"          // Configuracoes globais e defines
#include "modules/utils.inc"           // Funcoes utilitarias
#include "modules/player_data.inc"     // Dados do jogador
#include "modules/maps.inc"            // Carregamento e gerenciamento de mapas
#include "modules/hud.inc"             // TextDraws e interface visual
#include "modules/derby_engine.inc"    // Motor do Derby (estados, partidas, eliminacao)
#include "modules/mode_fun.inc"        // Modo FUN (gameplay dinamico)
#include "modules/mode_cla.inc"        // Modo CLA VS CLA (competitivo)
#include "modules/mode_train.inc"      // Modo Treinamento
#include "modules/ux.inc"              // Experiencia: sons, cameras, mensagens
#include "modules/commands.inc"        // Comandos do jogador
#include "modules/callbacks.inc"       // Callbacks do SA-MP
#include "modules/objects.inc"         // Objetos 3D dos mapas (plataformas)

// =============================================================================
// ENTRY POINT
// =============================================================================

main()
{
    print(" ");
    print("  ===================================================");
    print("   DERBY DESTRUCTION v2.0");
    print("   Servidor profissional de Derby para SA-MP");
    print("  ===================================================");
    print(" ");
}
