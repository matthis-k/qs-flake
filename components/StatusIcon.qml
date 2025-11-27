import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import "../services"
import "../managers"

Item {
    id: root

    property var iconName: "dialog-warning"
    property var iconPath: Quickshell.iconPath(iconName, "dialog-warning")
    property var overlayColor: Config.styling.text0
    property Component popupComponent: null
    property bool enableHover: true
    property bool enableTap: true
    property bool mipmap: false
    property bool hovered: hoverHandler.hovered

    IconImage {
        id: icon
        anchors.centerIn: parent
        width: Math.round(parent.height * Config.styling.statusIconScaler / 2) * 2
        height: width
        source: root.iconPath
        mipmap: root.mipmap
        scale: root.hovered ? 1.25 : 1

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
        visible: !!root.overlayColor
        anchors.fill: icon
        color: visible && root.overlayColor
        source: icon
        scale: icon.scale
    }

    property bool peeking: false

    HoverHandler {
        id: hoverHandler
        enabled: root.enableHover
        onHoveredChanged: {
            if (hovered && root.popupComponent) {
                peeking = true;
                PopupManager.anchors.topRight.show(root.popupComponent, {
                    peeking: peeking
                });
            } else if (peeking) {
                peeking = false;
                PopupManager.anchors.topRight.hide(500);
            }
        }
    }

    TapHandler {
        enabled: root.enableTap
        onSingleTapped: {
            if (root.popupComponent) {
                peeking = false;
                PopupManager.anchors.topRight.toggle(root.popupComponent, {
                    peeking: peeking
                });
            }
        }
    }
}
