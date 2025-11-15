import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import "../theme"
import "../components"
import "../managers"

Item {
    id: root
    property UPowerDevice bat: UPower.displayDevice
    implicitWidth: parent.height
    implicitHeight: parent.height

    property color stateColor: {
        let percentage = Math.floor(root.bat.percentage * 100);
        return [
            {
                max: 10,
                col: Theme.red
            },
            {
                max: 20,
                col: Theme.yellow
            },
            {
                max: 60,
                col: Theme.text
            },
            {
                max: 100,
                col: Theme.green
            }
        ].find(({
                max,
                col
            }) => percentage <= max).col;
    }

    ColorOverlay {
        id: powerProfileIcon
        color: root.stateColor
        anchors.fill: parent
        source: IconImage {
            id: icon
            anchors.centerIn: parent
            anchors.fill: parent
            implicitSize: 24
            source: Quickshell.iconPath(root.bat.iconName, "battery-full")
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
            QuickSettingsManager.open("battery");
            timerTriggered = true;
        }
    }
    TapHandler {
        onSingleTapped: {
            QuickSettingsManager.toggle("battery");
        }
    }
}
