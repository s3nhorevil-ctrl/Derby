# Derby V3 - Sistema de Salas Personalizadas

Reformulacao completa do gamemode Derby com sistema de lobbies/salas configuráveis.

## Novidades do V3

| Feature | Descricao |
|---------|-----------|
| **Sistema de Salas** | Crie salas personalizadas com configuracoes unicas |
| **Modo FUN** | Publico, rotacao automatica, frases comicas |
| **Modo Treinamento** | Respawn infinito, sem pontuacao, treino livre |
| **Modo CLA vs CLA** | Competitivo com times, rounds e placar |
| **Nitro On-Click** | Ativa ao pressionar, desativa ao soltar (sem nitro infinito) |
| **Vehicle HP** | TextDraw per-player mostrando vida do carro |
| **Multi-Map Selection** | Selecione multiplos mapas com checkbox |
| **Vehicle Preview** | Preview 3D do veiculo na selecao |
| **Host Controls** | Iniciar, cancelar, alterar config, kick, transferir host |
| **Arquitetura Modular** | 12 modulos .inc independentes |

## Estrutura de Arquivos

```
DerbyV3/
├── derby_v3.pwn              <- Gamemode principal
├── includes/
│   ├── derby_core.inc        <- Definicoes, enums, constantes, veiculos
│   ├── room_data.inc         <- Estruturas de dados das salas
│   ├── room_manager.inc      <- Ciclo de vida das salas (criar/destruir/spawn)
│   ├── nitro.inc             <- Sistema de nitro on-click
│   ├── hud.inc               <- TextDraws (timer, HP, placar, info)
│   ├── lobby.inc             <- Menu /derby, criacao de sala, dialogs
│   ├── host_controls.inc     <- Controles administrativos do host
│   ├── map_selector.inc      <- Carregador de mapas .sfr
│   ├── vehicle_selector.inc  <- Selecao de veiculo com preview 3D
│   ├── fun_mode.inc          <- Modo FUN (publico + anti-AFK)
│   ├── training_mode.inc     <- Modo Treinamento (respawn)
│   └── cla_mode.inc          <- Modo CLA vs CLA (competitivo)
├── README.md
```

## Comandos

### Jogadores
| Comando | Descricao |
|---------|-----------|
| `/derby` | Menu principal (FUN / Treino / Criar Sala / Listar) |
| `/sair` | Sair da sala atual |
| `/host` | Menu do Host (se for host) |
| `/iniciar` | Iniciar partida (host) |
| `/stats` | Estatisticas pessoais |
| `/top` | Ranking top 10 |
| `/sala` | Info da sala atual |
| `/ajuda` | Lista de comandos |

### Admin (RCON)
| Comando | Descricao |
|---------|-----------|
| `/reloadmaps` | Recarregar lista de mapas |
| `/skimap` | Pular mapa na sala FUN |
| `/fechar [id]` | Fechar uma sala especifica |

## Fluxo de Criacao de Sala

1. `/derby` → Menu Principal
2. "Criar Sala" → Escolher Modo (Treinamento / CLA vs CLA)
3. Escolher Rounds (1, 3, 5, 7, 10, 15, 20)
4. Escolher Veiculo (38 veiculos com nome)
5. Selecionar Mapas (checkbox, multiplas paginas)
6. Definir Nome da Sala
7. Confirmar → Sala criada!

## Sistema de Nitro

- **Ativar:** Pressionar tecla de TIRO (botao esquerdo)
- **Desativar:** Soltar a tecla
- **Consumo:** Gradual enquanto ativado
- **Recarga:** Gradual enquanto desativado
- **Sem nitro infinito** - precisa esperar recarregar

## Requisitos (Includes)

- `a_samp.inc`
- `sscanf2.inc` - [Download](https://github.com/Y-Less/sscanf)
- `Pawn.CMD.inc` - [Download](https://github.com/katursis/Pawn.CMD)
- `foreach.inc` - [Download](https://github.com/pawn-lang/YSI-Includes)

**Nota:** O include `OnPlayerPause` foi removido nesta versao.

## Instalacao

1. Copie a pasta `DerbyV3/` para dentro da pasta do servidor
2. Copie os mapas `.sfr` para `scriptfiles/DERBY/`
3. Compile `derby_v3.pwn` com o compilador Pawn
4. No `server.cfg`: `gamemode0 DerbyV3/derby_v3`
5. Inicie o servidor

## Compatibilidade

- Compativel com todos os 130+ mapas `.sfr` do Derby V1
- Formato de mapa identico (nao precisa converter)
- Banco de dados SQLite separado (`derby_v3.db`)
