import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../components"
import "../services"
import "../managers"
import "../quickSettings"

Item {
    id: root

    Component {
        id: networkPopupComponent
        NetworkView {}
    }

    implicitWidth: root.height
    implicitHeight: root.height
    readonly property real iconMargin: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)

    IconImage {
        id: icon
        anchors.centerIn: parent
        width: Math.max(root.height - iconMargin * 2, 0)
        height: width
        implicitSize: root.height
        source: Quickshell.iconPath(NetworkManager.currentNetwork ? NetworkManager.currentNetwork.icon : "network-wireless-offline-symbolic", "network-wireless-offline-symbolic")
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

    property bool peeking: false

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                PopupManager.anchors.topRight.show(networkPopupComponent, {
                    peeking: peeking
                });
            } else if (peeking) {
                PopupManager.anchors.topRight.hide(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            peeking = false;
            PopupManager.anchors.topRight.toggle(networkPopupComponent, {
                peeking: peeking
            });
        }
    }
}
