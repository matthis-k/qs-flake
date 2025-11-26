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
import "../quickSettings"

Item {
    id: root
    implicitWidth: root.height
    implicitHeight: root.height

    Component {
        id: powerMenuPopupComponent
        PowerMenuView {}
    }
    readonly property real iconMargin: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)

    Item {
        id: iconWrapper
        anchors.fill: parent
        anchors.margins: iconMargin
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

        IconImage {
            id: icon
            anchors.fill: parent
            source: Quickshell.iconPath("system-shutdown-symbolic", "system-shutdown")
        }

        ColorOverlay {
            anchors.fill: parent
            color: Config.styling.critical
            source: icon
        }
    }

    property bool peeking: false

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                PopupManager.anchors.topRight.show(powerMenuPopupComponent, { peeking: peeking });
            } else if (peeking) {
                PopupManager.anchors.topRight.hide(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            peeking = false;
            PopupManager.anchors.topRight.toggle(powerMenuPopupComponent, { peeking: peeking });
        }
    }
}
