pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Substitui o qs.Commons.Color do Omarchy: lê o esquema de cores atual do
// Caelestia e acompanha as trocas de tema/wallpaper em tempo real.
Singleton {
    id: root

    property var scheme: ({})

    readonly property color background: "#" + (scheme.surface ?? "131317")
    readonly property color foreground: "#" + (scheme.onSurface ?? "e4e1e7")
    readonly property color accent: "#" + (scheme.primary ?? "bac3ff")
    readonly property color urgent: "#" + (scheme.error ?? "ffb4ab")

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/caelestia/scheme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.scheme = JSON.parse(text()).colours ?? {};
            } catch (e) {
                console.warn("dock-caelestia: scheme.json inválido:", e);
            }
        }
    }
}
