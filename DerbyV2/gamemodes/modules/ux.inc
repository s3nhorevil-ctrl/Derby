// =============================================================================
// UX.INC - Experiencia do jogador: boas-vindas, sons, fluxo
// =============================================================================

stock UX_ShowWelcome(playerid)
{
    new info[700];
    strcat(info, C_WHITE "Bem-vindo ao " C_DERBY "DERBY DESTRUCTION!" C_WHITE "\n\n");
    strcat(info, C_GREEN "Como jogar:" C_WHITE "\n");
    strcat(info, "Voce e colocado em uma plataforma com um carro.\n");
    strcat(info, "Empurre os outros para fora! Quem cai, morre.\n");
    strcat(info, "Ultimo sobrevivente vence a rodada.\n\n");
    strcat(info, C_GREEN "Modos disponiveis:" C_WHITE "\n");
    strcat(info, C_GOLD "MODO FUN" C_WHITE " - Mapas automaticos, partidas rapidas\n");
    strcat(info, C_BLUE "CLA VS CLA" C_WHITE " - Competitivo (config. pelo admin)\n");
    strcat(info, C_CYAN "TREINAMENTO" C_WHITE " - Pratique sem eliminacao\n\n");
    strcat(info, C_GREY "Use NITRO segurando o botao do mouse!\n");
    strcat(info, C_GREY "Comandos: /derby /sair /stats /top /ajuda\n");

    ShowPlayerDialog(playerid, DLG_WELCOME, DIALOG_STYLE_MSGBOX,
        C_DERBY "DERBY DESTRUCTION " C_WHITE "- Bem-vindo!", info, "Jogar!", "");
}

// UX_ShowModeSelect removido - /derby vai direto pro FUN
// /modo mostra livre/treino via dialog em commands.inc
