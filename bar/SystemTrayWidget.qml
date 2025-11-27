import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../components"
import "../services"
import "../managers"

Pill {
    property bool expanded: true
    headerBackground: contentBackground
    header: Item {
        implicitWidth: parent.height
        implicitHeight: 0
        height: 0
        readonly property real iconMargin: Math.floor(parent.height * (1 - Config.styling.statusIconScaler) / 2)

        HoverHandler {
            id: headerHover
        }

        IconImage {
            id: icon
            anchors.centerIn: parent
            width: Math.max(parent.height - iconMargin * 2, 0)
            height: width
            implicitSize: parent.height
            source: Quickshell.iconPath(expanded ? "pan-end" : "pan-start")
            transformOrigin: Item.Center
            scale: headerHover.hovered ? 1.25 : 1

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
            anchors.fill: icon
            color: Config.styling.text0
            source: icon
        }

        TapHandler {
            target: parent
            acceptedButtons: Qt.LeftButton
            onTapped: expanded = !expanded
        }
    }

    ListView {
        id: trayList
        implicitHeight: parent.height
        width: expanded ? contentWidth : 0
        visible: expanded
        scale: expanded ? 1 : 0.92
        orientation: ListView.Horizontal
        interactive: false
        model: SystemTray.items
        implicitWidth: contentWidth

        delegate: Item {
            readonly property var tray: modelData

            height: !!parent && parent.height
            width: height
            implicitWidth: height
            transformOrigin: Item.Center

            property bool peeking: false

            ThemedDbusMenuOpener {
                id: menuAnchor
                menu: tray ? tray.menu : null
                popupAnchor: PopupManager.topRight
            }

            function showTrayMenu(toggle) {
                if (!tray || !tray.hasMenu || !tray.menu)
                    return;
                menuAnchor.open(toggle);
            }

            HoverHandler {
                id: trayHover
                onHoveredChanged: {
                    if (hovered && tray && tray.hasMenu) {
                        peeking = true;
                        menuAnchor.peek();
                    } else if (peeking) {
                        menuAnchor.close(500);
                    }
                }
            }

            StatusIcon {
                id: trayIconWrapper
                anchors.fill: parent
                iconPath: tray ? tray.icon : ""
            }

            TapHandler {
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onTapped: (point, button) => {
                    if (!tray)
                        return;
                    peeking = false;
                    if (button === Qt.LeftButton) {
                        if (tray.onlyMenu && tray.hasMenu)
                            showTrayMenu(false);
                        else
                            tray.activate();
                    } else if (button === Qt.MiddleButton) {
                        tray.secondaryActivate();
                    } else if (button === Qt.RightButton && tray.hasMenu) {
                        showTrayMenu(true);
                    }
                }
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        add: Transition {
            NumberAnimation {
                properties: "opacity,scale"
                from: 0.2
                to: 1
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        remove: Transition {
            NumberAnimation {
                properties: "opacity,scale"
                from: 1
                to: 0
                duration: 150
                easing.type: Easing.InCubic
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
    }
}
