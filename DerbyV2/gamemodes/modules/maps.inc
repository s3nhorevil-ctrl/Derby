// =============================================================================
// MAPS.INC - Carregamento e gerenciamento de mapas
// =============================================================================

enum E_MAP_INFO
{
    mapName[24],
    mapHour,
    mapWeather,
    mapVehicle,
    Float:mapZKill,     // Z de eliminacao (abaixo disso = morto)
    mapVW,              // virtual world deste mapa
    mapSpawnCount       // quantos spawns este mapa tem
};

new MapInfo[MAX_MAPS][E_MAP_INFO];
new Float:MapSpawns[MAX_MAPS][MAX_DERBY_SLOTS][4]; // [mapa][slot][x,y,z,a]
new MapFilenames[MAX_MAPS][32];
new TotalMaps = 0;

// VW lookup table
new MapVW[MAX_MAPS];

// =============================================================================
// CARREGAR LISTA DE MAPAS
// =============================================================================

stock Maps_LoadList(const filename[])
{
    new File:f = fopen(filename, io_read);
    if(!f)
    {
        printf("[MAPS] ERRO: nao encontrou %s", filename);
        return 0;
    }

    TotalMaps = 0;
    new line[64];
    while(fread(f, line) && TotalMaps < MAX_MAPS)
    {
        StripNewLine(line);
        if(strlen(line) < 3 || line[0] == ';') continue;
        format(MapFilenames[TotalMaps], 32, "%s", line);
        TotalMaps++;
    }
    fclose(f);
    printf("[MAPS] Lista carregada: %d mapas", TotalMaps);
    return TotalMaps;
}

// =============================================================================
// CARREGAR VW TABLE
// =============================================================================

stock Maps_LoadVWTable(const filename[])
{
    new File:f = fopen(filename, io_read);
    if(!f)
    {
        // Fallback: VW = base + indice
        for(new i = 0; i < TotalMaps; i++)
            MapVW[i] = VW_DERBY_BASE + i;
        printf("[MAPS] vworlds.txt nao encontrado, usando fallback");
        return 0;
    }

    new line[64], idx = 0;
    while(fread(f, line) && idx < MAX_MAPS)
    {
        StripNewLine(line);
        new nome[32], vw;
        if(!sscanf(line, "p<,>s[32]d", nome, vw))
        {
            MapVW[idx] = vw;
            idx++;
        }
    }
    fclose(f);
    printf("[MAPS] VW table carregada: %d entradas", idx);
    return idx;
}

// =============================================================================
// CARREGAR UM MAPA ESPECIFICO (le o .sfr)
// =============================================================================

stock Maps_Load(mapid)
{
    if(mapid < 0 || mapid >= TotalMaps) return 0;

    new File:f = fopen(MapFilenames[mapid], io_read);
    if(!f)
    {
        printf("[MAPS] ERRO: nao abriu %s", MapFilenames[mapid]);
        return 0;
    }

    new line[256], count = 0, spawns = 0;
    while(fread(f, line))
    {
        StripNewLine(line);
        if(strlen(line) < 3) continue;

        if(count == 0)
        {
            // Header: Nome,Hora,Clima,Veiculo,ZKill
            if(sscanf(line, "p<,>s[24]dddf",
                MapInfo[mapid][mapName],
                MapInfo[mapid][mapHour],
                MapInfo[mapid][mapWeather],
                MapInfo[mapid][mapVehicle],
                MapInfo[mapid][mapZKill]))
            {
                fclose(f);
                return 0;
            }
        }
        else if(spawns < MAX_DERBY_SLOTS)
        {
            if(!sscanf(line, "p<,>ffff",
                MapSpawns[mapid][spawns][0],
                MapSpawns[mapid][spawns][1],
                MapSpawns[mapid][spawns][2],
                MapSpawns[mapid][spawns][3]))
            {
                spawns++;
            }
        }
        count++;
    }
    fclose(f);

    if(spawns < 1) return 0;

    MapInfo[mapid][mapSpawnCount] = spawns;
    MapInfo[mapid][mapVW] = MapVW[mapid];

    // Preencher slots extras repetindo
    for(new i = spawns; i < MAX_DERBY_SLOTS; i++)
    {
        MapSpawns[mapid][i][0] = MapSpawns[mapid][i % spawns][0];
        MapSpawns[mapid][i][1] = MapSpawns[mapid][i % spawns][1];
        MapSpawns[mapid][i][2] = MapSpawns[mapid][i % spawns][2];
        MapSpawns[mapid][i][3] = MapSpawns[mapid][i % spawns][3];
    }

    return 1;
}

// =============================================================================
// PRE-CARREGAR NOMES DE TODOS OS MAPAS (para exibir em listas)
// =============================================================================

stock Maps_CacheNames()
{
    new line[256];
    for(new i = 0; i < TotalMaps; i++)
    {
        new File:f = fopen(MapFilenames[i], io_read);
        if(!f) continue;
        if(fread(f, line))
        {
            StripNewLine(line);
            new nome[24], a, b, c;
            new Float:d;
            if(!sscanf(line, "p<,>s[24]dddf", nome, a, b, c, d))
                format(MapInfo[i][mapName], 24, "%s", nome);
        }
        fclose(f);
    }
}

// =============================================================================
// ENCONTRAR PROXIMO MAPA VALIDO
// =============================================================================

stock Maps_FindNext(startid)
{
    new id = startid;
    if(id < 0 || id >= TotalMaps) id = 0;

    for(new tries = 0; tries < TotalMaps; tries++)
    {
        if(Maps_Load(id)) return id;
        id = (id + 1) % TotalMaps;
    }
    return -1; // nenhum mapa valido
}
