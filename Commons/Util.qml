pragma Singleton

import QtQuick
import Quickshell

// Substitui o qs.Commons.Util do Omarchy (só as funções que o dock usa).
Singleton {
    function alpha(color, opacity) {
        return Qt.rgba(color.r, color.g, color.b, opacity);
    }

    // Aspas simples para sh: 'a'\''b'
    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    // O dock passa comandos como texto de shell.
    function execDetached(command) {
        Quickshell.execDetached(["sh", "-c", String(command)]);
    }

    function fileUrl(path) {
        return "file://" + encodeURI(String(path));
    }
}
