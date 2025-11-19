import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import "../services" 1.0
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
                col: Config.styling.critical
            },
            {
                max: 20,
                col: Config.colors.yellow
            },
            {
                max: 60,
                col: Config.styling.text0
            },
            {
                max: 100,
                col: Config.styling.good
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

    property bool peeking: false

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                QuickSettingsManager.open("battery", peeking);
            } else if (peeking) {
                QuickSettingsManager.close(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            peeking = false;
            QuickSettingsManager.toggle("battery", peeking);
        }
    }
}
