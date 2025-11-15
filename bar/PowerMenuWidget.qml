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

    property bool keepOpen: false
    property bool timerTriggered: false

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                keepOpen = false;
                timerTriggered = false;
                if (!hoverTimer.runngin) {
                    hoverTimer.start();
                }
            } else {
                if (keepOpen) {
                    hoverTimer.stop();
                } else if (!timerTriggered) {
                    QuickSettingsManager.close();
                }
            }
        }
    }

    Timer {
        id: hoverTimer
        interval: 500
        onTriggered: {
            QuickSettingsManager.open("powermenu");
            timerTriggered = true;
        }
    }
    TapHandler {
        onSingleTapped: {
            QuickSettingsManager.toggle("powermenu");
        }
    }
}
