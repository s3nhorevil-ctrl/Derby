// =============================================================================
// COMMANDS.INC - Todos os comandos do jogador
// =============================================================================

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[32], params[128], idx = 0;
    // Parse command
    while(cmdtext[idx] && cmdtext[idx] != ' ' && idx < 31)
    {
        cmd[idx] = cmdtext[idx];
        idx++;
    }
    cmd[idx] = '\0';
    if(cmdtext[idx] == ' ') idx++;
    format(params, sizeof(params), "%s", cmdtext[idx]);

    // --- Comandos ---
    if(!strcmp(cmd, "/derby", true))
    {
        UX_ShowModeSelect(playerid);
        return 1;
    }

    if(!strcmp(cmd, "/sair", true))
    {
        if(IsPlayerInDerby(playerid))
            ModeFun_Leave(playerid);
        else if(IsPlayerInCla(playerid))
            ModeCla_Leave(playerid);
        else if(IsPlayerInTrain(playerid))
            ModeTrain_Leave(playerid);
        else
            return SCM(playerid, COL_RED, C_RED "Voce nao esta em nenhum modo.");

        SetPlayerPos(playerid, 0.0, 0.0, 20.0);
        SetPlayerVirtualWorld(playerid, VW_LOBBY);
        SCM(playerid, COL_YELLOW, C_YELLOW ">> Voce saiu. Use /derby para voltar.");
        return 1;
    }

    if(!strcmp(cmd, "/stats", true))
    {
        new str[256];
        format(str, sizeof(str),
            C_DERBY "=== SUAS STATS ===" C_WHITE "\n" \
            "Score: " C_GREEN "%d\n" C_WHITE \
            "Mortes: " C_RED "%d\n" C_WHITE,
            Player[playerid][pScore], Player[playerid][pDeaths]);
        SCM(playerid, COL_WHITE, str);
        return 1;
    }

    if(!strcmp(cmd, "/ajuda", true) || !strcmp(cmd, "/help", true))
    {
        SCM(playerid, COL_DERBY, C_DERBY "=== COMANDOS ===");
        SCM(playerid, COL_WHITE, "/derby - Escolher modo de jogo");
        SCM(playerid, COL_WHITE, "/sair  - Sair do modo atual");
        SCM(playerid, COL_WHITE, "/stats - Ver suas estatisticas");
        SCM(playerid, COL_WHITE, "/top   - Ranking dos melhores");
        SCM(playerid, COL_WHITE, "/cla   - Painel CLA VS CLA (RCON)");
        return 1;
    }

    if(!strcmp(cmd, "/cla", true))
    {
        if(!IsPlayerAdmin(playerid))
            return SCM(playerid, COL_RED, C_RED "Apenas RCON pode usar /cla.");
        return Cla_ShowPanel(playerid);
    }

    if(!strcmp(cmd, "/top", true))
    {
        SCM(playerid, COL_GREY, C_GREY "Sistema de ranking sera implementado em breve.");
        return 1;
    }

    SCM(playerid, COL_RED, C_RED "Comando desconhecido. Use /ajuda.");
    return 1;
}
