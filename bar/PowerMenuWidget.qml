import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../theme"
import "../components"
import "../managers"

Item {
    id: root
    implicitWidth: parent ? parent.height : 48
    implicitHeight: parent ? parent.height : 48

    ColorOverlay {
        anchors.fill: parent
        color: Theme.red
        source: IconImage {
            anchors.centerIn: parent
            implicitSize: 24
            source: Quickshell.iconPath("system-shutdown-symbolic", "system-shutdown")
        }
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
