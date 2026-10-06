pragma Singleton

import QtQuick
import Quickshell
import Caelestia.Config

// Substitui o qs.Commons.Style do Omarchy usando as fontes do Caelestia
// (Tokens do plugin Caelestia.Config, as mesmas que a barra usa).
Singleton {
    function px(f: font): int {
        return f.pixelSize > 0 ? f.pixelSize : Math.round(f.pointSize * 4 / 3);
    }

    readonly property QtObject font: QtObject {
        readonly property string family: Tokens.font.body.small.family
        readonly property int bodySmall: px(Tokens.font.body.small)
        readonly property int caption: px(Tokens.font.label.small)
        readonly property int title: px(Tokens.font.title.medium)
    }
}
