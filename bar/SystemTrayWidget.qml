import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../components"
import "../services"

Pill {
    id: root
    property bool expanded: false
    headerBackground: "transparent"
    contentBackground: "transparent"

    header: Item {
        implicitWidth: root.height
        implicitHeight: root.height
        readonly property real iconMargin: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)

        HoverHandler {
            id: headerHover
        }

        IconImage {
            id: icon
            anchors.centerIn: parent
            width: Math.max(root.height - iconMargin * 2, 0)
            height: width
            implicitSize: root.height
            source: Quickshell.iconPath(root.expanded ? "pan-end" : "pan-start")
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
            onTapped: root.expanded = !root.expanded
        }
    }

    Item {
        id: trayContainer
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredHeight: root.height
        implicitHeight: root.height
        readonly property real expandedWidth: trayList ? Math.max(trayList.contentWidth, 0) : 0
        width: root.expanded ? expandedWidth : 0
        Layout.preferredWidth: width
        opacity: root.expanded ? 1 : 0
        scale: root.expanded ? 1 : 0.92
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        ListView {
            id: trayList
            anchors.fill: parent
            anchors.margins: 2
            orientation: ListView.Horizontal
            spacing: 6
            boundsBehavior: Flickable.StopAtBounds
            interactive: false
            model: SystemTray.items
            implicitHeight: root.height
            implicitWidth: contentWidth
            clip: false

            delegate: Item {
                readonly property var tray: modelData

                width: 24
                height: 24
                transformOrigin: Item.Center
                opacity: 1
                scale: 1

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
                        anchors.margins: 4
                        implicitSize: Math.min(root.height - 8, 24)
                        source: tray.icon
                        mipmap: true
                    }

                    ThemedDbusMenuOpener {
                        id: menuAnchor
                        menu: tray.menu
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onTapped: (point, button) => {
                        if (button === Qt.LeftButton) {
                            if (tray.onlyMenu && tray.hasMenu)
                                menuAnchor.open();
                            else
                                tray.activate();
                        } else if (button === Qt.MiddleButton) {
                            tray.secondaryActivate();
                        } else if (button === Qt.RightButton && tray.hasMenu) {
                            menuAnchor.open();
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
