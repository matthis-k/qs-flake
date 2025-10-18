import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../components"
import "../theme"

Pill {
    id: pill
    property bool expanded: false
    headerBackground: "transparent"
    contentBackground: "transparent"

    header: Item {
        implicitHeight: 28
        implicitWidth: implicitHeight
        ColorOverlay {
            anchors.centerIn: parent
            anchors.fill: parent
            color: Theme.text
            source: IconImage {
                anchors.fill: parent
                anchors.margins: 4
                implicitSize: 24
                source: Quickshell.iconPath(pill.expanded ? "pan-end" : "pan-start")
            }
        }
        TapHandler {
            target: parent
            acceptedButtons: Qt.LeftButton
            onTapped: pill.expanded = !pill.expanded
        }
    }

    Repeater {
        id: rep
        model: pill.expanded ? SystemTray.items : null

        // this is where the passing happends, rest is essentially an expander
        delegate: Item {
            required property var modelData
            readonly property var tray: modelData

            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            width: 24
            height: 24

            IconImage {
                anchors.fill: parent
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
