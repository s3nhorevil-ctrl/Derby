/*
    DERBY V3 - MAP SELECTOR / LOADER
    
    Carregamento de mapas do formato .sfr,
    gerenciamento do pool de mapas global.
*/

#if defined _map_selector_included
    #endinput
#endif
#define _map_selector_included

// =============================================================================
// CARREGAR LISTA DE MAPAS
// =============================================================================

stock LoadMapList(const filename[])
{
    new File:f = fopen(filename, io_read);
    if(!f)
    {
        printf("[DERBY] ERRO: Nao foi possivel abrir %s", filename);
        return 0;
    }
    
    TotalMaps = 0;
    new line[64];
    
    while(fread(f, line) && TotalMaps < MAX_DERBYS)
    {
        StripNewLine(line);
        if(strlen(line) < 3) continue;
        
        format(MapFilenames[TotalMaps], 48, "%s", line);
        TotalMaps++;
    }
    
    fclose(f);
    printf("[DERBY] Lista de mapas carregada: %d mapas encontrados.", TotalMaps);
    return TotalMaps;
}


// =============================================================================
// CARREGAR DADOS DE UM MAPA
// =============================================================================

stock LoadMapData(mapid)
{
    if(mapid < 0 || mapid >= TotalMaps) return 0;
    
    new File:f = fopen(MapFilenames[mapid], io_read);
    if(!f)
    {
        printf("[DERBY] ERRO: Nao foi possivel abrir mapa %s", MapFilenames[mapid]);
        return 0;
    }
    
    new line[256];
    new count = 0;
    
    MapPool[mapid][MAP_SPAWNS] = 0;
    format(MapPool[mapid][MAP_FILENAME], 48, "%s", MapFilenames[mapid]);
    
    while(fread(f, line))
    {
        StripNewLine(line);
        if(strlen(line) < 3) continue;
        
        if(count == 0)
        {
            // Primeira linha: Nome,Hora,Clima,Veiculo,ZMin
            new name[32];
            new hour, weather, vehicle;
            new Float:zmin;
            
            if(sscanf(line, "p<,>s[32]dddf", name, hour, weather, vehicle, zmin))
            {
                // Tentar formato alternativo (espaco apos virgula)
                if(sscanf(line, "p<,>s[32] d d d f", name, hour, weather, vehicle, zmin))
                {
                    printf("[DERBY] ERRO: Formato invalido no mapa %s", MapFilenames[mapid]);
                    fclose(f);
                    return 0;
                }
            }
            
            // Limpar espacos do nome
            new trimmed[32];
            new j = 0;
            for(new i = 0; i < strlen(name) && j < 31; i++)
            {
                if(name[i] != ' ' || j > 0)
                {
                    trimmed[j] = name[i];
                    j++;
                }
            }
            trimmed[j] = '\0';
            
            format(MapPool[mapid][MAP_NAME], 32, "%s", trimmed);
            MapPool[mapid][MAP_HOUR] = hour;
            MapPool[mapid][MAP_WEATHER] = weather;
            MapPool[mapid][MAP_VEHICLE] = vehicle;
            MapPool[mapid][MAP_ZMIN] = zmin;
        }
        else
        {
            // Linhas de spawn: X,Y,Z,Angulo
            new spawnidx = count - 1;
            if(spawnidx < MAX_ROOM_PLAYERS)
            {
                new Float:x, Float:y, Float:z, Float:a;
                if(!sscanf(line, "p<,>ffff", x, y, z, a))
                {
                    MapPool[mapid][MAP_SPAWN_X][spawnidx] = x;
                    MapPool[mapid][MAP_SPAWN_Y][spawnidx] = y;
                    MapPool[mapid][MAP_SPAWN_Z][spawnidx] = z;
                    MapPool[mapid][MAP_SPAWN_A][spawnidx] = a;
                    MapPool[mapid][MAP_SPAWNS]++;
                }
            }
        }
        count++;
    }
    
    fclose(f);
    return 1;
}

// =============================================================================
// CARREGAR TODOS OS MAPAS DA LISTA
// =============================================================================

stock LoadAllMaps()
{
    new loaded = 0;
    for(new i = 0; i < TotalMaps; i++)
    {
        if(LoadMapData(i))
            loaded++;
        else
            printf("[DERBY] AVISO: Falha ao carregar mapa ID %d (%s)", i, MapFilenames[i]);
    }
    printf("[DERBY] Mapas carregados com sucesso: %d/%d", loaded, TotalMaps);
    return loaded;
}
