# Dock Caelestia — plano

Dock estilo macOS, com **ampliação em onda** ao passar o mouse, integrado ao visual do Caelestia, rodando no Hyprland.

Criado em 2026-10-05. Status: **planejamento**.

## Por que

- O `nwg-dock-hyprland` (dock atual) é GTK3 e não consegue ampliar ícones; foi testado e `-gtk-icon-transform` é ignorado.
- Docks com zoom (Plank, Plank Reloaded) são X11 e não funcionam direito no Hyprland.
- O Caelestia é feito em Quickshell (QML), que tem animação de escala nativa. Um dock em Quickshell resolve o zoom e combina com o resto do shell.

## Ponto de partida: dock do Omarchy já existente

Em `~/.config/quickshell/` existe um dock em Quickshell: o **macOS Magnify Dock** (`wdg.dock` v1.8.1, autor `wdg`, **licença MIT**), plugin do **Omarchy Shell**, com cerca de 4.200 linhas. Ele **já tem ampliação em onda**, preview de janelas, menu de contexto, reordenar arrastando, badges de notificação e configurações.

- **Origem:** <https://github.com/wisangdg/omarchy-magnify-dock>
- **Como chegou aqui:** em 2026-10-03 (22:05), numa sessão anterior do Claude, o repositório foi clonado e copiado para `~/.config/quickshell/`. Como não rodou sem o Omarchy, a tentativa foi abandonada pelo nwg-dock e os arquivos ficaram ali.
- **Licença MIT:** pode adaptar e usar; manter o aviso de copyright/licença do autor no projeto (arquivo `LICENSE` + crédito no README).

Ele não roda sozinho, porque depende do Omarchy:

| Dependência | Uso | Substituto no Caelestia |
|---|---|---|
| `qs.Commons` → `Color.*` | `foreground`, `accent`, `urgent`, `background` | cores de `~/.local/state/caelestia/scheme.json` (`onSurface`, `primary`, `error`, `surface`…) |
| `qs.Commons` → `Style.font` | fontes | fonte do Caelestia (ou fixa) |
| `qs.Ui` | componentes visuais (3 arquivos) | reescrever ou usar `Quickshell.Widgets` |
| objeto `shell` injetado | `iconPath`, `execDetached`, `screens`, `env` | APIs diretas do `Quickshell` |
| `~/.config/omarchy/...` | caminhos de notificações e configurações | `~/.config/dock-caelestia/` |

**Decisão:** portar esse dock (trocar as dependências acima por uma camada fina de compatibilidade) em vez de escrever do zero.

## Arquitetura

Duas formas de "adicionar ao Caelestia":

1. **Config separada, visual integrado (recomendado).** O dock roda como uma segunda instância do Quickshell (`qs -c dock-caelestia`) ao lado do Caelestia. Ele lê o mesmo `scheme.json` (cores mudam junto com o wallpaper/tema) e usa o plugin `Caelestia.Config` quando for útil.
   - ✅ Atualizações do `caelestia-shell-git` (pacman/AUR) não quebram nem apagam o dock.
   - ✅ Se o dock travar, a barra do Caelestia continua de pé.
2. **Módulo dentro do Caelestia.** Copiar o Caelestia de `/etc/xdg/quickshell/caelestia` para `~/.config/quickshell/caelestia` e adicionar `modules/dock` + uma linha no `shell.qml`.
   - ✅ Acesso direto a `qs.services` (`Hypr`, `Colours`) e ao sistema de painéis.
   - ❌ A cópia "congela" o Caelestia: cada atualização exige reaplicar as mudanças (script de patch).

Começar pela 1; se fizer falta algo que só existe por dentro, migrar para a 2.

## Estrutura do projeto

```
~/code/dock_caelestia/
├── PLANO.md
├── README.md            # instalar, configurar, desinstalar
├── shell.qml            # raiz da config Quickshell
├── compat/              # Commons/Ui falsos → cores e fontes do Caelestia
├── dock/                # arquivos portados do wdg.dock
└── install.sh           # symlink → ~/.config/quickshell/dock-caelestia
```

O código fica em `~/code` (versionado com git); o Quickshell enxerga por symlink.

## Etapas

1. **Preparar:** `git init`, clonar o repositório original (versão 1.8.1, com o `LICENSE`) para `dock/`, sem alterar, e fazer o primeiro commit (referência original). Depois, remover as cópias soltas em `~/.config/quickshell/`.
2. **Camada de compatibilidade:** criar `compat/` com `Color`, `Style` e componentes de `Ui`, lendo o `scheme.json` com `FileView`.
3. **Primeiro boot:** `qs -c dock-caelestia` abrindo o dock na borda de baixo, com apps fixados e ícones.
4. **Hyprland:** apps abertos e pontinhos via `Quickshell.Hyprland`, clicar para focar ou abrir.
5. **Zoom:** validar a ampliação em onda e ajustar intensidade, raio e duração.
6. **Auto-esconder:** aparecer ao encostar o mouse na borda de baixo, como o nwg-dock hoje.
7. **Extras do original:** preview, menu de contexto, reordenar, badges (cada um opcional).
8. **Trocar o dock:** no `hyprland.lua`, substituir o `nwg-dock-hyprland` pelo `qs -c dock-caelestia -d` e adicionar uma regra de blur para a layer do dock.

## Riscos

- **Quickshell em `-git`:** APIs podem mudar entre versões e quebrar o dock (o mesmo risco do Caelestia).
- **Tamanho do código original:** 4.200 linhas; portar tudo dá mais trabalho que portar o essencial (etapas 3–6).
- **Desempenho:** a ampliação em onda recalcula a escala de cada ícone a cada movimento do mouse; o original já otimiza isso ("fixed slots").

## Como desfazer

Parar o `qs -c dock-caelestia`, apagar o symlink em `~/.config/quickshell/dock-caelestia` e voltar a linha do `nwg-dock-hyprland` no `hyprland.lua`. O nwg-dock continua instalado e configurado.
