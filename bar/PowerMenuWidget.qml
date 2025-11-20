import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../services"
import "../components"
import "../managers"

Item {
    id: root
    implicitWidth: root.height
    implicitHeight: root.height

    IconImage {
        id: icon
        anchors.fill: parent
        anchors.margins: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)
        implicitSize: root.height
        source: Quickshell.iconPath("system-shutdown-symbolic", "system-shutdown")
    }

    ColorOverlay {
        anchors.fill: icon
        color: Config.styling.critical
        source: icon
    }

    property bool peeking: false

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                QuickSettingsManager.open("powermenu", peeking);
            } else if (peeking) {
                QuickSettingsManager.close(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            peeking = false;
            QuickSettingsManager.toggle("powermenu", peeking);
        }
    }
}
