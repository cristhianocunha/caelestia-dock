# dock-caelestia

Dock estilo macOS para o [Caelestia](https://github.com/caelestia-dots/shell) no Hyprland, com **ampliação em onda** ao passar o mouse.

Ele roda como uma config própria do [Quickshell](https://quickshell.org), ao lado do Caelestia, e usa as **mesmas cores e fontes** dele. Quando o tema ou o wallpaper muda, o dock muda junto.

> Baseado no **[macOS Magnify Dock](https://github.com/wisangdg/omarchy-magnify-dock)** (`wdg.dock` v1.8.1), de **Wisang Drillian Geni (wdg)**, licença MIT. O original é um plugin do Omarchy Shell; este projeto adapta o dock para rodar sem o Omarchy. Veja [Créditos e licença](#créditos-e-licença).

## Recursos

- Ampliação em onda: o ícone sob o mouse cresce e os vizinhos acompanham
- Apps fixados + apps abertos, com pontinho indicador
- Clique foca a janela aberta ou abre o app
- Auto-esconder: aparece ao encostar o mouse na borda de baixo
- Cores do esquema atual do Caelestia, atualizadas ao vivo
- Um dock por monitor
- Botão de apps abre o launcher do Caelestia

Vieram do original, mas **ainda não foram testados** neste port: menu do botão direito, reordenar arrastando, silenciar o som por app, contador de notificações e painel de configurações. A prévia das janelas tem um problema conhecido (veja [Problemas conhecidos](#problemas-conhecidos)).

## Requisitos

- Hyprland, com a sessão iniciada pelo **UWSM**; o dock abre apps com `uwsm-app`
- `quickshell` (testado com `quickshell-git` 0.3.1)
- `caelestia-shell` (testado com `caelestia-shell-git` 2.5.0); o dock usa o plugin `Caelestia.Config` e o `~/.local/state/caelestia/scheme.json`
- Opcionais, só para os extras: `python3`, `pactl` (silenciar som), `dbus-monitor` (contador de notificações)

## Instalação

```sh
git clone <url-deste-repo> ~/code/dock_caelestia
mkdir -p ~/.config/quickshell ~/.config/dock-caelestia
ln -sfn ~/code/dock_caelestia ~/.config/quickshell/dock-caelestia
```

Testar sem instalar no autostart:

```sh
qs -c dock-caelestia -n
```

### Hyprland (`hyprland.lua`)

Iniciar junto com a sessão, dentro do `hl.on("hyprland.start", ...)`:

```lua
hl.exec_cmd("qs -c dock-caelestia -n -d")
```

Desfoque de vidro atrás do dock:

```lua
hl.layer_rule({
    name  = "dock-blur",
    match = { namespace = "^dock-caelestia$" },

    blur         = true,
    ignore_alpha = 0.1,
})
```

Se você usava outro dock (por exemplo `nwg-dock-hyprland`), comente a linha dele no autostart para não ter dois docks na borda de baixo.

## Configuração

Fica em `~/.config/dock-caelestia/pinned.json`. O dock relê o arquivo sozinho quando ele muda, e também o regrava quando você altera algo pelo próprio dock (fixar app, painel de configurações).

```json
{
  "version": 1,
  "autoHide": true,
  "reserveSpace": false,
  "pinned": ["google-chrome", "brave-browser", "kitty", "io.dbeaver.DBeaver"],
  "settings": {
    "iconSize": 34,
    "magnification": 1.6,
    "spacing": 6,
    "opacity": 0.76,
    "revealDelay": 0,
    "hideDelay": 220,
    "windowScope": "all",
    "showWindowPreviews": true,
    "showNotificationBadges": true
  }
}
```

| Chave | O que faz | Valores |
|---|---|---|
| `pinned` | Apps fixados, pelo nome do arquivo `.desktop` sem a extensão | lista de IDs |
| `autoHide` | Esconde o dock até o mouse encostar na borda de baixo | `true` / `false` |
| `reserveSpace` | Reserva uma faixa embaixo para as janelas não ficarem por baixo do dock. **Ignorado quando `autoHide` está ligado.** | `true` / `false` |
| `settings.iconSize` | Tamanho dos ícones | 24–64 px |
| `settings.magnification` | Ampliação máxima ao passar o mouse | 1 (desligada) – 2 |
| `settings.spacing` | Espaço entre os ícones | 2–16 px |
| `settings.opacity` | Opacidade do fundo | 0.2–1 |
| `settings.revealDelay` | Atraso para aparecer | 0–1000 ms |
| `settings.hideDelay` | Atraso para esconder | 100–2000 ms |
| `settings.windowScope` | Quais janelas contam como abertas | `all`, `monitor`, `workspace` |
| `settings.showWindowPreviews` | Prévia das janelas ao passar o mouse | `true` / `false` |
| `settings.showNotificationBadges` | Contador de notificações nos ícones | `true` / `false` |

Para descobrir o ID de um app: `ls /usr/share/applications ~/.local/share/applications ~/.local/share/flatpak/exports/share/applications`.

## Como funciona

O dock original importa módulos do Omarchy Shell (`qs.Commons`, `qs.Ui`). Este projeto fornece substitutos com os mesmos nomes, para o código original rodar quase sem mudanças:

```
dock_caelestia/
├── shell.qml        # raiz da config Quickshell: carrega o dock
├── Commons/         # substitui qs.Commons do Omarchy
│   ├── Color.qml    #   cores lidas do scheme.json do Caelestia
│   ├── Style.qml    #   fontes dos Tokens do Caelestia.Config
│   └── Util.qml     #   alpha, shellQuote, execDetached, fileUrl
├── Ui/              # o dock só importa qs.Ui; um placeholder basta
└── dock/            # código do macOS Magnify Dock (com LICENSE e ORIGEM.md)
```

Os nomes `Commons/` e `Ui/` precisam ser exatamente esses: no Quickshell, `import qs.Commons` aponta para a pasta `Commons/` na raiz da config.

Mudanças feitas em `dock/` em relação ao original:

- caminhos `~/.config/omarchy/...` → `~/.config/dock-caelestia/...`
- scripts Python localizados via `Quickshell.shellDir`
- namespace da layer `omarchy-dock` → `dock-caelestia`
- botão de apps: `omarchy-menu` → launcher do Caelestia

O primeiro commit do repositório é o original sem alterações. Para ver tudo o que mudou:

```sh
git diff $(git rev-list --max-parents=0 HEAD) -- dock/
```

## Problemas conhecidos

- **Prévia das janelas:** o log mostra `ScreencopyView ... Cannot capture frame, as no recording context is ready`, e a prévia provavelmente não aparece. Para desligar, use `"showWindowPreviews": false`.
- **Quickshell em versão `-git`:** atualizações podem mudar APIs e quebrar o dock (o mesmo vale para o Caelestia). Depois de atualizar, rode `qs -c dock-caelestia -n` no terminal e veja se aparecem erros.

## Desinstalar / voltar ao dock anterior

```sh
pkill -f 'qs -c dock-caelestia'
rm ~/.config/quickshell/dock-caelestia
```

No `hyprland.lua`, remova a linha `qs -c dock-caelestia` do autostart e reative o dock anterior. As configurações em `~/.config/dock-caelestia/` podem ser apagadas ou mantidas.

## Créditos e licença

O código em `dock/` é do **macOS Magnify Dock**, de Wisang Drillian Geni (wdg), distribuído sob a licença MIT. O aviso original está em [`dock/LICENSE`](dock/LICENSE), e a origem exata (commit `29c5856`) está em [`dock/ORIGEM.md`](dock/ORIGEM.md).

A camada de compatibilidade (`Commons/`, `Ui/`, `shell.qml`) e as adaptações são de Cristhiano Cunha.
