# Derby Gamemode - Standalone (SA-MP)

Gamemode independente de Derby (mata-mata de carros em plataformas) extraido e adaptado do Brasil Mundo Supremo 2020.

## Como Funciona

- Jogadores entram no Derby automaticamente ao conectar
- Cada partida acontece em um mapa (plataforma) diferente
- Os jogadores recebem veiculos e devem empurrar os adversarios para fora
- Quem cai da plataforma (posicao Z abaixo do limite) e eliminado
- Eliminados ficam assistindo (spectate) os sobreviventes
- O ultimo jogador sobrevivente vence a partida
- Apos o vencedor ser definido, o proximo mapa carrega automaticamente (loop infinito)

## Sistemas Incluidos

| Sistema | Descricao |
|---------|-----------|
| **Derby Core** | Carregamento de mapas, spawns, eliminacao, vencedor, transicao de estados |
| **GodCar (Votacao)** | Antes de cada partida, jogadores votam SIM/NAO para reparo automatico |
| **Anti-AFK** | Jogadores parados por 10s recebem aviso; 20s sao removidos |
| **Anti-ESC/Pause** | Jogadores em ESC/pause sao removidos automaticamente |
| **Spectate** | Eliminados assistem os vivos, podem trocar de camera com ENTER |
| **Database (SQLite)** | Estatisticas de vitorias, derrotas, partidas e score |
| **TextDraws** | HUD com timer, jogadores ativos, total, votacao GodCar |

## Requisitos (Includes)

Coloque na pasta `pawno/include/`:

- `a_samp.inc` (ja vem com o servidor SA-MP)
- `sscanf2.inc` - [Download](https://github.com/Y-Less/sscanf)
- `Pawn.CMD.inc` - [Download](https://github.com/katursis/Pawn.CMD)
- `foreach.inc` (ou YSI y_iterate) - [Download](https://github.com/pawn-lang/YSI-Includes)
- `OnPlayerPause.inc` - [Download](https://github.com/Starter00/OnPlayerPause)

## Instalacao

1. Copie `derby_gamemode.pwn` para a pasta `gamemodes/` do seu servidor
2. Copie a pasta `DERBY/` (com os mapas .sfr) para a pasta `scriptfiles/` do servidor
3. Compile o .pwn usando o compilador Pawn (pawno ou pawncc)
4. No `server.cfg`, altere a linha gamemode:
   ```
   gamemode0 derby_gamemode
   ```
5. Inicie o servidor

## Estrutura de Arquivos

```
servidor/
├── gamemodes/
│   └── derby_gamemode.pwn      <- Gamemode principal
├── scriptfiles/
│   └── DERBY/
│       ├── derbys.sfr          <- Lista de mapas (um por linha)
│       ├── mapa_plataforma_alta.sfr
│       ├── mapa_arena_circular.sfr
│       ├── mapa_ponte_destruida.sfr
│       ├── mapa_torre_queda.sfr
│       └── mapa_rampa_caos.sfr
└── server.cfg
```

## Formato dos Mapas (.sfr)

Cada arquivo de mapa segue o formato:

```
NomeDoMapa,Hora,Clima,ModeloVeiculo,ZMinimo
X1,Y1,Z1,Angulo1
X2,Y2,Z2,Angulo2
...
X20,Y20,Z20,Angulo20
```

### Explicacao dos campos:

| Campo | Descricao |
|-------|-----------|
| `NomeDoMapa` | Nome exibido na tela (max 24 chars) |
| `Hora` | Hora do dia (0-23) |
| `Clima` | ID do clima/weather (0-20) |
| `ModeloVeiculo` | ID do modelo do carro (ex: 495=Sandking, 411=Infernus) |
| `ZMinimo` | Posicao Z de eliminacao (abaixo disso = morto) |
| `X,Y,Z,Angulo` | Posicao de spawn de cada jogador (max 20 posicoes) |

### Exemplo:

```
Plataforma Alta,12,1,495,-50.0
2500.0,1200.0,50.0,0.0
2510.0,1200.0,50.0,0.0
...
```

## Comandos

### Jogadores
| Comando | Descricao |
|---------|-----------|
| `/derby` | Entrar no Derby |
| `/sair` | Sair do Derby |
| `/stats` | Ver estatisticas pessoais |
| `/top` | Ver ranking top 10 |
| `/ajuda` ou `/help` | Lista de comandos |

### Administradores (RCON)
| Comando | Descricao |
|---------|-----------|
| `/reloadmaps` | Recarregar lista de mapas |
| `/skimap` | Pular mapa atual |
| `/setmap [id]` | Definir proximo mapa |

## Configuracoes

No inicio do arquivo `.pwn`, voce pode alterar:

```pawn
#define MAX_PLAYERS             (50)      // Max jogadores no servidor
#define MAX_DERBY_PLAYERS       (20)      // Max jogadores por partida
#define MAX_DERBYS              (200)     // Max mapas carregaveis
#define AFK_WARNING_SECONDS     (10)      // Segundos para aviso AFK
#define AFK_KICK_SECONDS        (20)      // Segundos para remover AFK
#define DERBY_TIMEOUT_SECONDS   (180)     // Tempo max da partida (3 min)
#define DERBY_COUNTDOWN_SECONDS (10)      // Contagem regressiva
```

## Como Adicionar Novos Mapas

1. Crie um arquivo `.sfr` na pasta `scriptfiles/DERBY/`
2. Adicione o caminho do arquivo em `DERBY/derbys.sfr`
3. Use `/reloadmaps` no servidor (ou reinicie)

**Dica:** Use o SA-MP Map Editor ou ferramentas como MTA Map Editor para criar plataformas e anotar as coordenadas de spawn.

## Veiculos Populares para Derby

| ID | Veiculo | Observacao |
|----|---------|------------|
| 495 | Sandking | Pesado, bom para empurrar |
| 411 | Infernus | Rapido, leve |
| 451 | Turismo | Equilibrado |
| 560 | Sultan | Popular |
| 468 | Sanchez | Moto (desafiador) |
| 444 | Monster | Muito pesado |
| 502 | Hotring A | Corrida |
| 541 | Bullet | Esportivo |

## Creditos

- Sistema original: Brasil Mundo Supremo 2020 (FlaTz, Dean, Guilherme, Adrian)
- Extracao e adaptacao: Kiro AI
