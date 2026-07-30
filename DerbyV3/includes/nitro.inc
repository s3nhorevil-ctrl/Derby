/*
    DERBY V3 - NITRO SYSTEM
    
    Sistema de nitro ativado por tecla:
    - Nitro liga ao pressionar a tecla (KEY_FIRE / botao esquerdo)
    - Nitro desliga ao soltar a tecla
    - Consumo gradual enquanto ativado
    - Recarga gradual enquanto desativado
    - Sem nitro infinito
*/

#if defined _nitro_included
    #endinput
#endif
#define _nitro_included

// =============================================================================
// CONFIGURACOES DO NITRO
// =============================================================================

#define NITRO_MAX_FUEL          100.0   // Combustivel maximo
#define NITRO_CONSUME_RATE      2.5     // Consumo por tick (200ms)
#define NITRO_RECHARGE_RATE     0.8     // Recarga por tick (200ms)
#define NITRO_MIN_TO_ACTIVATE   10.0    // Minimo para ativar
#define NITRO_UPDATE_INTERVAL   200     // Intervalo de update em ms

#define NITRO_COMPONENT_ID      1009    // NOS componente SA-MP


// =============================================================================
// ATIVAR NITRO (Quando pressiona a tecla)
// =============================================================================

stock ActivateNitro(playerid)
{
    if(PlayerData[playerid][PL_ROOM_ID] == INVALID_ROOM_ID) return 0;
    if(PlayerData[playerid][PL_STATE] != PLAYER_STATE_ALIVE) return 0;
    if(PlayerData[playerid][PL_NITRO_ACTIVE]) return 0;
    
    if(PlayerData[playerid][PL_NITRO_FUEL] < NITRO_MIN_TO_ACTIVATE)
    {
        // Sem combustivel suficiente
        PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
        return 0;
    }
    
    PlayerData[playerid][PL_NITRO_ACTIVE] = true;
    
    // Adicionar componente NOS ao veiculo
    new vid = PlayerData[playerid][PL_VEHICLE_ID];
    if(vid != INVALID_VEHICLE_ID)
    {
        AddVehicleComponent(vid, NITRO_COMPONENT_ID);
    }
    
    return 1;
}

// =============================================================================
// DESATIVAR NITRO (Quando solta a tecla)
// =============================================================================

stock DeactivateNitro(playerid)
{
    if(!PlayerData[playerid][PL_NITRO_ACTIVE]) return 0;
    
    PlayerData[playerid][PL_NITRO_ACTIVE] = false;
    
    // Remover NOS do veiculo
    new vid = PlayerData[playerid][PL_VEHICLE_ID];
    if(vid != INVALID_VEHICLE_ID)
    {
        RemoveVehicleComponent(vid, NITRO_COMPONENT_ID);
    }
    
    return 1;
}

// =============================================================================
// UPDATE DO NITRO (Chamado pelo timer global)
// =============================================================================

stock UpdateNitroForPlayer(playerid)
{
    if(PlayerData[playerid][PL_ROOM_ID] == INVALID_ROOM_ID) return 0;
    if(PlayerData[playerid][PL_STATE] != PLAYER_STATE_ALIVE) return 0;
    
    if(PlayerData[playerid][PL_NITRO_ACTIVE])
    {
        // Consumir combustivel
        PlayerData[playerid][PL_NITRO_FUEL] -= NITRO_CONSUME_RATE;
        
        if(PlayerData[playerid][PL_NITRO_FUEL] <= 0.0)
        {
            PlayerData[playerid][PL_NITRO_FUEL] = 0.0;
            DeactivateNitro(playerid);
            PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
        }
    }
    else
    {
        // Recarregar combustivel
        if(PlayerData[playerid][PL_NITRO_FUEL] < NITRO_MAX_FUEL)
        {
            PlayerData[playerid][PL_NITRO_FUEL] += NITRO_RECHARGE_RATE;
            if(PlayerData[playerid][PL_NITRO_FUEL] > NITRO_MAX_FUEL)
                PlayerData[playerid][PL_NITRO_FUEL] = NITRO_MAX_FUEL;
        }
    }
    
    return 1;
}


// =============================================================================
// TIMER GLOBAL DE NITRO (200ms)
// =============================================================================

public NitroUpdateTimer()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(PlayerData[i][PL_ROOM_ID] == INVALID_ROOM_ID) continue;
        if(PlayerData[i][PL_STATE] != PLAYER_STATE_ALIVE) continue;
        
        UpdateNitroForPlayer(i);
    }
    return 1;
}

// =============================================================================
// HANDLER DE TECLAS PARA NITRO
// =============================================================================

stock HandleNitroKeyChange(playerid, newkeys, oldkeys)
{
    if(PlayerData[playerid][PL_ROOM_ID] == INVALID_ROOM_ID) return 0;
    if(PlayerData[playerid][PL_STATE] != PLAYER_STATE_ALIVE) return 0;
    if(GetPlayerState(playerid) != 2) return 0; // PLAYER_STATE_DRIVER
    
    new roomid = PlayerData[playerid][PL_ROOM_ID];
    if(RoomData[roomid][ROOM_STATE] != ROOM_STATE_RUNNING) return 0;
    
    // KEY_FIRE (botao esquerdo do mouse / tecla de tiro)
    if((newkeys & KEY_FIRE) && !(oldkeys & KEY_FIRE))
    {
        // Pressionou - ativar nitro
        ActivateNitro(playerid);
    }
    else if(!(newkeys & KEY_FIRE) && (oldkeys & KEY_FIRE))
    {
        // Soltou - desativar nitro
        DeactivateNitro(playerid);
    }
    
    return 1;
}
