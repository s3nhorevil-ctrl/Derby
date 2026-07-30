# Derby Gamemode - Standalone (SA-MP)

Gamemode independente de Derby extraido do Brasil Mundo Supremo 2020, com **2 modos de jogo**.

## IMPORTANTE - por que os carros caiam no vazio

Os arquivos `.sfr` guardam **somente as posicoes de spawn dos carros**. As **plataformas** sao
objetos criados pelo filterscript `SFRDERBY`. Sem ele os carros nascem no ar e caem.

Alem disso cada mapa vive em um **virtual world** proprio. O filterscript usa `50 + indice`.
Para garantir que o gamemode e o filterscript apontem para o mesmo lugar existe o arquivo
`scriptfiles/DERBY/vworlds.txt`, que associa cada mapa ao seu virtual world correto.

**Resumo: o filterscript `SFRDERBY` + o plugin `streamer` sao obrigatorios.**

---

## Modos de jogo

Ao digitar `/derby` aparece uma tela com dois modos:

### MODO FUN
Modo classico. Os mapas trocam automaticamente em loop, o ultimo sobrevivente vence
e o proximo mapa carrega. Inclui votacao de God Car antes de cada partida.

### CLA VS CLA
Sala configurada por quem esta logado no **RCON**. O admin define tudo por uma tela:

| Opcao | Descricao |
|---|---|
| Mapa | escolhe entre os 50 mapas disponiveis |
| Tempo por round | 30 a 900 segundos |
| Quantidade de rounds | 1 a 30 |
| Veiculo | digita o ID do veiculo (400 a 611) |
| Cor do CLA 1 | 8 cores disponiveis |
| Cor do CLA 2 | 8 cores disponiveis |
| Definir times dos jogadores | o admin escolhe manualmente quem fica no CLA 1 ou CLA 2 |
| INICIAR PARTIDA | comeca a disputa |
| CANCELAR / RESETAR | volta tudo para o MODO FUN |

Regras do CLA VS CLA:
- Cada round termina quando um dos clas e totalmente eliminado
- Se o tempo acabar, ganha o cla com mais sobreviventes
- O cla que vencer mais rounds e o campeao
- Nao tem votacao de God Car
- Quem cai fica assistindo e volta no round seguinte

---

## Requisitos

**Includes** (pasta `pawno/include/`):
- `a_samp.inc` (ja vem com o servidor)
- `sscanf2.inc` - [Download](https://github.com/Y-Less/sscanf)

**Plugin** (pasta `plugins/`):
- `streamer` - [Download](https://github.com/samp-incognito/samp-streamer-plugin) (usado pelo filterscript dos mapas)

O gamemode em si **nao** precisa de Pawn.CMD, foreach, YSI nem OnPlayerPause.

---

## Instalacao

1. `derby_gamemode.pwn` -> pasta `gamemodes/` e compile
2. Pasta `scriptfiles/DERBY/` -> pasta `scriptfiles/` do servidor
3. `filterscripts/SFRDERBY.amx` -> pasta `filterscripts/` do servidor
4. Plugin `streamer` -> pasta `plugins/`
5. Use o `server.cfg.exemplo` como base do seu `server.cfg`

### Estrutura final

```
servidor/
├── gamemodes/
│   └── derby_gamemode.amx
├── filterscripts/
│   └── SFRDERBY.amx            <- cria as plataformas (OBRIGATORIO)
├── plugins/
│   └── streamer.dll / .so      <- OBRIGATORIO
├── scriptfiles/
│   └── DERBY/
│       ├── derbys.sfr          <- lista dos mapas da rotacao
│       ├── vworlds.txt         <- mapa -> virtual world (NAO APAGUE)
│       ├── rampa2.sfr
│       ├── swat.sfr
│       └── ... (130 mapas)
└── server.cfg
```

---

## Comandos

### Jogadores
| Comando | Descricao |
|---|---|
| `/derby` | Abre a tela de escolha de modo |
| `/sair` | Sai da partida |
| `/stats` | Suas estatisticas |
| `/top` | Ranking top 10 |
| `/ajuda` | Lista de comandos |

### Administradores (RCON)
| Comando | Descricao |
|---|---|
| `/cla` | Abre o painel do CLA VS CLA |
| `/reloadmaps` | Recarrega a lista de mapas e a tabela de virtual worlds |
| `/skimap` | Pula o mapa atual (MODO FUN) |
| `/setmap [id]` | Define o proximo mapa (MODO FUN) |

---

## Arquivos de mapa

### `derbys.sfr` - rotacao do MODO FUN
Um caminho por linha. Linhas comecando com `;` sao ignoradas, entao voce pode desativar
um mapa sem apagar:

```
DERBY/rampa2.sfr
;DERBY/swat.sfr        <- desativado
DERBY/demolition.sfr
```

### `vworlds.txt` - virtual world de cada mapa
```
rampa2.sfr,50
swat.sfr,51
demolition.sfr,53
```
Se um mapa nao estiver nessa tabela, o gamemode usa `50 + indice` como fallback.
**Nao apague esse arquivo** — sem ele os mapas podem sair desalinhados do filterscript.

### Formato de um `.sfr`
```
NomeDoMapa,Hora,Clima,ModeloVeiculo,ZMinimo
X1,Y1,Z1,Angulo1
...
```
- `ZMinimo` = altura de eliminacao (abaixo disso o jogador esta morto)
- Ate 20 posicoes de spawn. Se tiver menos, o gamemode repete as existentes.

---

## Diagnostico

Ao ligar o servidor o console mostra:

```
[DERBY] Tabela de virtual worlds carregada: 50 entradas
[DERBY] Lista carregada de DERBY/derbys.sfr (50 mapas)
[DERBY] Mapa carregado: Rampas2 | VW 50 | veiculo 506 | Zmin 75.0 | spawns 20
```

Se aparecer isso, algo esta errado:

| Mensagem | Causa |
|---|---|
| `ERRO CRITICO: NENHUM MAPA FOI CARREGADO` | a pasta `scriptfiles/DERBY/` nao esta no lugar |
| `ERRO: mapa nao encontrado: DERBY/x.sfr` | o arquivo listado em `derbys.sfr` nao existe |
| `ERRO: mapa X nao possui spawns validos` | arquivo `.sfr` corrompido ou vazio |
| Carros caem no vazio | o filterscript `SFRDERBY` nao esta carregado, ou falta o plugin `streamer` |

---

## Configuracoes

No inicio do `.pwn`:

```pawn
#define MAX_PLAYERS             (50)
#define MAX_DERBY_PLAYERS       (20)
#define DERBY_VW_BASE           (50)    // precisa bater com o SFRDERBY
#define AFK_WARNING_SECONDS     (10)
#define AFK_KICK_SECONDS        (20)
#define DERBY_TIMEOUT_SECONDS   (180)   // tempo do round no MODO FUN
#define DERBY_COUNTDOWN_SECONDS (10)
```

---

## Creditos

- Sistema original: Brasil Mundo Supremo 2020 (FlaTz, Dean, Guilherme, Adrian)
- Mapas: filterscript `SFRDERBY` (-GDD- SFR)
- Extracao, correcoes e modo CLA VS CLA: Kiro
