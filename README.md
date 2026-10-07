# dock-caelestia

A macOS-style dock for the [Caelestia](https://github.com/caelestia-dots/shell) shell on Hyprland, with a **magnification wave** on hover.

It runs as its own [Quickshell](https://quickshell.org) config alongside Caelestia and uses **the same colours and fonts**. When the theme or wallpaper changes, the dock follows.

> Based on **[macOS Magnify Dock](https://github.com/wisangdg/omarchy-magnify-dock)** (`wdg.dock` v1.8.1) by **Wisang Drillian Geni (wdg)**, MIT licensed. The original is an Omarchy Shell plugin; this project adapts it to run without Omarchy. See [Credits and license](#credits-and-license).

## Features

- Magnification wave: the hovered icon grows and its neighbours follow
- Pinned apps + running apps, with an indicator dot
- Click focuses the open window or launches the app
- Auto-hide: appears when the pointer touches the bottom edge
- Floats over windows and never reserves screen space
- Colours from Caelestia's current scheme, updated live
- One dock per monitor
- The apps button opens Caelestia's launcher

Carried over from the original but **not yet tested** in this port: right-click menu, drag-to-reorder, per-app mute, notification badges and the settings panel. Window previews have a known issue (see [Known issues](#known-issues)).

## Requirements

- Hyprland, with the session started by **UWSM**; the dock launches apps through `uwsm-app`
- `quickshell` (tested with `quickshell-git` 0.3.1)
- `caelestia-shell` (tested with `caelestia-shell-git` 2.5.0); the dock uses the `Caelestia.Config` plugin and `~/.local/state/caelestia/scheme.json`
- Optional, only for the extras: `python3`, `pactl` (per-app mute), `dbus-monitor` (notification badges)

## Installation

```sh
git clone https://github.com/cristhianocunha/caelestia-dock.git ~/code/dock_caelestia
mkdir -p ~/.config/quickshell ~/.config/dock-caelestia
ln -sfn ~/code/dock_caelestia ~/.config/quickshell/dock-caelestia
```

Try it without adding it to autostart:

```sh
qs -c dock-caelestia -n
```

### Hyprland (`hyprland.lua`)

Start it with the session, inside `hl.on("hyprland.start", ...)`:

```lua
hl.exec_cmd("qs -c dock-caelestia -n -d")
```

Frosted-glass blur behind the dock:

```lua
hl.layer_rule({
    name  = "dock-blur",
    match = { namespace = "^dock-caelestia$" },

    blur         = true,
    ignore_alpha = 0.1,
})
```

If you used another dock before (for example `nwg-dock-hyprland`), comment out its autostart line so you don't end up with two docks on the bottom edge.

## Configuration

Settings live in `~/.config/dock-caelestia/pinned.json`. The dock reloads the file when it changes, and rewrites it when you change something from the dock itself (pinning an app, the settings panel).

```json
{
  "version": 1,
  "autoHide": true,
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

| Key | What it does | Values |
|---|---|---|
| `pinned` | Pinned apps, by `.desktop` file name without the extension | list of IDs |
| `autoHide` | Hides the dock until the pointer touches the bottom edge | `true` / `false` |
| `reserveSpace` | **Ignored.** This port never reserves screen space: the dock always floats over windows. | — |
| `settings.iconSize` | Icon size | 24–64 px |
| `settings.magnification` | Maximum magnification on hover | 1 (off) – 2 |
| `settings.spacing` | Space between icons | 2–16 px |
| `settings.opacity` | Background opacity | 0.2–1 |
| `settings.revealDelay` | Delay before showing | 0–1000 ms |
| `settings.hideDelay` | Delay before hiding | 100–2000 ms |
| `settings.windowScope` | Which windows count as running | `all`, `monitor`, `workspace` |
| `settings.showWindowPreviews` | Window previews on hover | `true` / `false` |
| `settings.showNotificationBadges` | Notification counters on icons | `true` / `false` |

To find an app's ID: `ls /usr/share/applications ~/.local/share/applications ~/.local/share/flatpak/exports/share/applications`.

## How it works

The original dock imports Omarchy Shell modules (`qs.Commons`, `qs.Ui`). This project provides stand-ins with the same names, so the original code runs almost unchanged:

```
dock_caelestia/
├── shell.qml        # Quickshell config root: loads the dock
├── Commons/         # replaces Omarchy's qs.Commons
│   ├── Color.qml    #   colours read from Caelestia's scheme.json
│   ├── Style.qml    #   fonts from Caelestia.Config Tokens
│   └── Util.qml     #   alpha, shellQuote, execDetached, fileUrl
├── Ui/              # the dock only imports qs.Ui; a placeholder is enough
└── dock/            # macOS Magnify Dock code (with LICENSE and ORIGEM.md)
```

The `Commons/` and `Ui/` names must stay exactly like this: in Quickshell, `import qs.Commons` resolves to the `Commons/` folder at the config root.

Changes made in `dock/` compared with the original:

- paths `~/.config/omarchy/...` → `~/.config/dock-caelestia/...`
- Python helper scripts located via `Quickshell.shellDir`
- layer namespace `omarchy-dock` → `dock-caelestia`
- apps button: `omarchy-menu` → Caelestia's launcher
- screen-space reservation removed (`exclusiveZone` dropped, menu item hidden): in Quickshell, setting `exclusiveZone` switches the layer to `ExclusionMode.Normal`, so resizing icons used to reserve space even with auto-hide on

The unmodified original is tagged `upstream-v1.8.1`. To see everything that changed:

```sh
git diff upstream-v1.8.1 -- dock/
```

## Known issues

- **Window previews:** the log shows `ScreencopyView ... Cannot capture frame, as no recording context is ready`, and previews most likely don't render. To turn them off, set `"showWindowPreviews": false`.
- **Suspend:** after resuming from suspend the dock could stay stuck hidden. `shell.qml` now detects the resume (a jump in wall-clock time between timer ticks) and reloads the dock by itself.
- **Quickshell `-git`:** updates can change APIs and break the dock (the same applies to Caelestia). After updating, run `qs -c dock-caelestia -n` in a terminal and check for errors.

## Uninstall / go back to your previous dock

```sh
pkill -f '^qs -c dock-caelestia'
pkill -f 'dock-caelestia/dock/dock-notifications.py'
rm ~/.config/quickshell/dock-caelestia
```

In `hyprland.lua`, remove the `qs -c dock-caelestia` autostart line and re-enable your previous dock. The settings in `~/.config/dock-caelestia/` can be deleted or kept.

## Credits and license

The code in `dock/` is **macOS Magnify Dock** by Wisang Drillian Geni (wdg), distributed under the MIT license. The original notice is in [`dock/LICENSE`](dock/LICENSE), and the exact source (commit `29c5856`) is recorded in [`dock/ORIGEM.md`](dock/ORIGEM.md).

The compatibility layer (`Commons/`, `Ui/`, `shell.qml`) and the adaptations are by Cristhiano Cunha, also under the MIT license (see [`LICENSE`](LICENSE)).
