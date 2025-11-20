import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import "../services"
import "../components"
import "../managers"

Item {
    id: root
    property UPowerDevice bat: UPower.displayDevice
    implicitWidth: height
    implicitHeight: height

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

    IconImage {
        id: icon
        anchors.fill: parent
        anchors.margins: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)
        implicitSize: root.height
        source: Quickshell.iconPath(root.bat.iconName, "battery-full")
    }

    ColorOverlay {
        color: root.stateColor
        anchors.fill: icon
        source: icon
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
