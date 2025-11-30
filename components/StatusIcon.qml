import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import "../services"

Item {
    id: root

    // Utility function to find the inheritance node
    function findInheritanceNode(obj) {
        if (obj && obj.inheritanceNode) {
            return obj.inheritanceNode;
        }
        if (obj && obj.parent) {
            return findInheritanceNode(obj.parent);
        }
        return null;
    }

    // Property to hold the found screen
    property var barScreen: {
        var node = findInheritanceNode(parent);
        return node ? node.lookup("screen") : null;
    }

    // Find the panel for this screen
    property var myPanel: popups.getPanelForScreen(barScreen)

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
            if (hovered && root.popupComponent && root.myPanel) {
                peeking = true;
                root.myPanel.topRight.show(root.popupComponent, {
                    peeking: peeking,
                    autoClose: false
                });
            }
        }
    }

    TapHandler {
        enabled: root.enableTap
        onSingleTapped: {
            if (root.popupComponent && root.myPanel) {
                peeking = false;
                root.myPanel.topRight.toggle(root.popupComponent, {
                    peeking: peeking
                });
            }
        }
    }
}
