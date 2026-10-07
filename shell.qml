//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import "dock"

// Dock estilo macOS integrado ao visual do Caelestia.
// Rodar com: qs -c dock-caelestia
ShellRoot {
    Dock {}

    // Depois de suspender, o dock ficava preso escondido (a borda parava de
    // revelá-lo). O relógio do Timer para durante a suspensão e o de parede
    // não, então um salto grande entre ticks indica que o sistema voltou;
    // aí recriamos as janelas do dock.
    Timer {
        property real lastTick: Date.now()

        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            const now = Date.now();
            const gap = now - lastTick;
            lastTick = now;
            if (gap > 30000) {
                console.log("dock-caelestia: voltou da suspensão (" + Math.round(gap / 1000) + " s), recarregando");
                Quickshell.reload(true);
            }
        }
    }
}
