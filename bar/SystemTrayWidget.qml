import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../components"
import "../services"
import "../managers"

Item {
    id: root
    implicitHeight: parent.height
    implicitWidth: trayList.contentWidth + trayPadding * 2
    property int trayPadding: 4

    Item {
        id: trayContainer
        anchors.fill: parent
        anchors.margins: trayPadding
        clip: false

        ListView {
            id: trayList
            anchors.fill: parent
            orientation: ListView.Horizontal
            spacing: 6
            boundsBehavior: Flickable.StopAtBounds
            interactive: false
            model: SystemTray.items
            implicitHeight: root.height - trayPadding * 2
            implicitWidth: contentWidth
            clip: false

            delegate: Item {
                readonly property var tray: modelData

                width: root.height - trayPadding * 2
                height: width
                transformOrigin: Item.Center
                opacity: 1
                scale: 1

                ThemedDbusMenuOpener {
                    id: menuAnchor
                    menu: tray.menu
                    popupAnchor: PopupManager.topRight
                }

                function showTrayMenu(toggle) {
                    if (!tray.hasMenu || !tray.menu)
                        return;
                    menuAnchor.open(toggle);
                }

                HoverHandler {
                    id: trayHover
                }

                Item {
                    id: trayIconWrapper
                    anchors.fill: parent
                    transformOrigin: Item.Center
                    scale: trayHover.hovered ? 1.25 : 1

                    Behavior on scale {
                        enabled: Config.styling.animation.enabled
                        NumberAnimation {
                            duration: Config.styling.animation.calc(0.1)
                            easing.type: Easing.Bezier
                            easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                        }
                    }

                    IconImage {
                        anchors.fill: parent
                        anchors.margins: Math.max(4, trayPadding)
                        implicitSize: Math.min(root.height - trayPadding * 2, 24)
                        source: tray.icon
                        mipmap: true
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onTapped: (point, button) => {
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
}
