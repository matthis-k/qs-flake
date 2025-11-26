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
import "../quickSettings"

Item {
    id: root
    property UPowerDevice bat: UPower.displayDevice
    implicitWidth: height

    Component {
        id: batteryPopupComponent
        BatteryView {}
    }
    implicitHeight: height
    readonly property real iconMargin: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)

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
        anchors.centerIn: parent
        width: Math.max(root.height - iconMargin * 2, 0)
        height: width
        implicitSize: root.height
        source: Quickshell.iconPath(root.bat.iconName, "battery-full")
        transformOrigin: Item.Center
        scale: hoverHandler.hovered ? 1.25 : 1

        Behavior on scale {
            enabled: Config.styling.animation.enabled
            NumberAnimation {
                duration: Config.styling.animation.calc(0.1)
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
            }
        }
    }

    ColorOverlay {
        color: root.stateColor
        anchors.fill: icon
        source: icon
    }

    property bool peeking: false

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                PopupManager.anchors.topRight.show(batteryPopupComponent, { peeking: peeking });
            } else if (peeking) {
                PopupManager.anchors.topRight.hide(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            peeking = false;
            PopupManager.anchors.topRight.toggle(batteryPopupComponent, { peeking: peeking });
        }
    }
}
