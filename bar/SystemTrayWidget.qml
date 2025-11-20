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
        IconImage {
            id: icon
            anchors.fill: parent
            anchors.margins: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)
            implicitSize: root.height
            source: Quickshell.iconPath(root.expanded ? "pan-end" : "pan-start")
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

    Repeater {
        id: rep
        model: root.expanded ? SystemTray.items : null

        delegate: Item {
            required property var modelData
            readonly property var tray: modelData

            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            width: 24
            height: 24

            IconImage {
                anchors.fill: parent
                anchors.margins: 4
                implicitSize: Math.min(parent.parent.parent.parent.parent.barHeight - 8, 24)
                source: tray.icon
                mipmap: true
            }

            ThemedDbusMenuOpener {
                id: menuAnchor
                menu: tray.menu
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
    }
}
