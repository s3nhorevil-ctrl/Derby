// =============================================================================
// UTILS.INC - Funcoes utilitarias reutilizaveis
// =============================================================================

stock GetPlayerNameEx(playerid)
{
    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

stock FormatTime(seconds)
{
    new buf[10];
    format(buf, sizeof(buf), "%d:%02d", seconds / 60, seconds % 60);
    return buf;
}

stock RandomInt(min, max)
{
    return random(max - min) + min;
}

stock StripNewLine(string[])
{
    new len = strlen(string);
    while(len > 0 && (string[len-1] == '\n' || string[len-1] == '\r'))
    {
        string[--len] = '\0';
    }
}

// Mensagem para um grupo de jogadores baseado em condicao
stock SendGroupMessage(color, const msg[], bool:condition[MAX_PLAYERS])
{
    Loop(i, pool)
    {
        if(condition[i]) SCM(i, color, msg);
    }
}

// Frase comica aleatoria para eliminacao
stock GetDeathPhrase(dest[], size)
{
    switch(random(15))
    {
        case 0:  format(dest, size, "foi comido pelo tubarao!");
        case 1:  format(dest, size, "CAIU! Muito ruim!");
        case 2:  format(dest, size, "virou comida de peixe!");
        case 3:  format(dest, size, "esqueceu que nao tem asas!");
        case 4:  format(dest, size, "tentou voar... nao deu certo!");
        case 5:  format(dest, size, "olhou pro lado errado!");
        case 6:  format(dest, size, "foi empurrado com carinho!");
        case 7:  format(dest, size, "mergulhou de cabeca!");
        case 8:  format(dest, size, "disse adeus ao mundo!");
        case 9:  format(dest, size, "achou que era passaro!");
        case 10: format(dest, size, "escorregou na banana!");
        case 11: format(dest, size, "fez um salto mortal... e morreu!");
        case 12: format(dest, size, "perdeu o equilibrio!");
        case 13: format(dest, size, "foi pro abraco do mar!");
        case 14: format(dest, size, "nao aguentou a pressao!");
    }
}

// Frase de respawn no treinamento
stock GetRespawnPhrase(dest[], size)
{
    switch(random(6))
    {
        case 0: format(dest, size, "~r~CAIU! ~w~Tenta de novo!");
        case 1: format(dest, size, "~r~FAIL! ~w~Mais uma vez!");
        case 2: format(dest, size, "~r~OPS! ~w~Voltando...");
        case 3: format(dest, size, "~r~TOMBOU! ~w~Vai la!");
        case 4: format(dest, size, "~r~MERGULHOU! ~w~De novo!");
        case 5: format(dest, size, "~r~NAO FOI DESSA VEZ!");
    }
}
