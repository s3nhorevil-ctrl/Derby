// =============================================================================
// HUD.INC - Interface visual (TextDraws)
// Design limpo e moderno para o Derby
// =============================================================================

// TextDraws globais
new Text:TD_Timer;          // Timer do round (canto superior direito)
new Text:TD_Alive;          // Jogadores vivos
new Text:TD_MapName;        // Nome do mapa atual
new Text:TD_Countdown;      // Contagem regressiva central
new Text:TD_WinnerMsg;      // Mensagem do vencedor
new Text:TD_ServerTitle;    // Titulo do servidor (topo)

// =============================================================================
// CRIAR TEXTDRAWS
// =============================================================================

stock HUD_Create()
{
    // --- Titulo do servidor (topo central) ---
    TD_ServerTitle = TextDrawCreate(320.0, 2.0, "~w~DERBY ~r~DESTRUCTION");
    TextDrawAlignment(TD_ServerTitle, 2);
    TextDrawLetterSize(TD_ServerTitle, 0.35, 1.2);
    TextDrawFont(TD_ServerTitle, 2);
    TextDrawColor(TD_ServerTitle, 0xFFFFFFFF);
    TextDrawSetShadow(TD_ServerTitle, 1);
    TextDrawSetOutline(TD_ServerTitle, 0);

    // --- Timer (canto superior direito) ---
    TD_Timer = TextDrawCreate(577.0, 20.0, "3:00");
    TextDrawLetterSize(TD_Timer, 0.6, 2.5);
    TextDrawAlignment(TD_Timer, 2);
    TextDrawFont(TD_Timer, 3);
    TextDrawColor(TD_Timer, 0xFFFFFFFF);
    TextDrawSetShadow(TD_Timer, 1);
    TextDrawSetOutline(TD_Timer, 1);
    TextDrawBackgroundColor(TD_Timer, 0x000000AA);

    // --- Jogadores vivos ---
    TD_Alive = TextDrawCreate(577.0, 45.0, "~w~Vivos: ~g~10/10");
    TextDrawLetterSize(TD_Alive, 0.28, 1.3);
    TextDrawAlignment(TD_Alive, 2);
    TextDrawFont(TD_Alive, 1);
    TextDrawColor(TD_Alive, 0xFFFFFFFF);
    TextDrawSetShadow(TD_Alive, 0);
    TextDrawSetOutline(TD_Alive, 1);

    // --- Nome do mapa ---
    TD_MapName = TextDrawCreate(320.0, 430.0, "~w~Mapa: ~y~Demolition");
    TextDrawAlignment(TD_MapName, 2);
    TextDrawLetterSize(TD_MapName, 0.25, 1.1);
    TextDrawFont(TD_MapName, 1);
    TextDrawColor(TD_MapName, 0xCCCCCCFF);
    TextDrawSetShadow(TD_MapName, 0);
    TextDrawSetOutline(TD_MapName, 1);

    // --- Countdown central (grande) ---
    TD_Countdown = TextDrawCreate(320.0, 180.0, "5");
    TextDrawAlignment(TD_Countdown, 2);
    TextDrawLetterSize(TD_Countdown, 1.2, 5.0);
    TextDrawFont(TD_Countdown, 3);
    TextDrawColor(TD_Countdown, 0xFF6600FF);
    TextDrawSetShadow(TD_Countdown, 2);
    TextDrawSetOutline(TD_Countdown, 2);

    // --- Mensagem do vencedor ---
    TD_WinnerMsg = TextDrawCreate(320.0, 150.0, " ");
    TextDrawAlignment(TD_WinnerMsg, 2);
    TextDrawLetterSize(TD_WinnerMsg, 0.45, 2.0);
    TextDrawFont(TD_WinnerMsg, 3);
    TextDrawColor(TD_WinnerMsg, 0xFFD700FF);
    TextDrawSetShadow(TD_WinnerMsg, 1);
    TextDrawSetOutline(TD_WinnerMsg, 1);
}

// =============================================================================
// MOSTRAR/ESCONDER HUD DA PARTIDA
// =============================================================================

stock HUD_ShowMatch_Ex(const mapname[], alive, total)
{
    new str[64];
    format(str, sizeof(str), "~w~Mapa: ~y~%s", mapname);
    TextDrawSetString(TD_MapName, str);

    format(str, sizeof(str), "~w~Vivos: ~g~%d/%d", alive, total);
    TextDrawSetString(TD_Alive, str);

    TextDrawSetString(TD_Timer, FormatTime(ROUND_TIMEOUT));

    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(IsPlayerInDerby(i))
        {
            TextDrawShowForPlayer(i, TD_Timer);
            TextDrawShowForPlayer(i, TD_Alive);
            TextDrawShowForPlayer(i, TD_MapName);
            TextDrawShowForPlayer(i, TD_ServerTitle);
        }
    }
}

stock HUD_HideMatch(playerid)
{
    TextDrawHideForPlayer(playerid, TD_Timer);
    TextDrawHideForPlayer(playerid, TD_Alive);
    TextDrawHideForPlayer(playerid, TD_MapName);
    TextDrawHideForPlayer(playerid, TD_ServerTitle);
    TextDrawHideForPlayer(playerid, TD_Countdown);
    TextDrawHideForPlayer(playerid, TD_WinnerMsg);
}

// =============================================================================
// ATUALIZAR HUD
// =============================================================================

stock HUD_UpdateCountdown(seconds)
{
    if(seconds > 0)
    {
        new str[4];
        format(str, sizeof(str), "%d", seconds);
        TextDrawSetString(TD_Countdown, str);

        for(new i = 0, i_j = GetPlayerPoolSize(); i <= i_j; i++) if(IsPlayerConnected(i))
        {
            if(IsPlayerInDerby(i))
                TextDrawShowForPlayer(i, TD_Countdown);
        }
    }
    else
    {
        TextDrawSetString(TD_Countdown, "~g~GO!");
        for(new i = 0, i_j = GetPlayerPoolSize(); i <= i_j; i++) if(IsPlayerConnected(i))
        {
            if(IsPlayerInDerby(i))
                TextDrawShowForPlayer(i, TD_Countdown);
        }
        // Esconder apos 1.5s
        SetTimer("HUD_HideCountdown", 1500, false);
    }
}

forward HUD_HideCountdown();
public HUD_HideCountdown()
{
    TextDrawHideForAll(TD_Countdown);
    return 1;
}

stock HUD_UpdateTimer(seconds)
{
    TextDrawSetString(TD_Timer, FormatTime(seconds));

    new str[32];
    format(str, sizeof(str), "~w~Vivos: ~g~%d~w~/%d", Match[mAlivePlayers], Match[mPlayers]);
    TextDrawSetString(TD_Alive, str);
}

stock HUD_ShowWinner(winner)
{
    new str[64];
    if(winner != INVALID_PLAYER_ID)
        format(str, sizeof(str), "~g~VENCEDOR:~n~~w~%s", Player[winner][pName]);
    else
        format(str, sizeof(str), "~y~TEMPO ESGOTADO");

    TextDrawSetString(TD_WinnerMsg, str);
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(IsPlayerInDerby(i))
            TextDrawShowForPlayer(i, TD_WinnerMsg);
    }
    SetTimer("HUD_HideWinner", 5000, false);
}

forward HUD_HideWinner();
public HUD_HideWinner()
{
    TextDrawHideForAll(TD_WinnerMsg);
    return 1;
}

// =============================================================================
// MOSTRAR HUD PARA UM JOGADOR ESPECIFICO (quando entra)
// =============================================================================

stock HUD_ShowForPlayer(playerid)
{
    TextDrawShowForPlayer(playerid, TD_Timer);
    TextDrawShowForPlayer(playerid, TD_Alive);
    TextDrawShowForPlayer(playerid, TD_MapName);
    TextDrawShowForPlayer(playerid, TD_ServerTitle);
}
