// TrayPill.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
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
        Text {
            anchors.centerIn: parent
            text: pill.expanded ? ">" : "<"
            font.pixelSize: Math.round(parent.height * 0.6)
            color: Theme.text
        }
        MouseArea {
            anchors.fill: parent
            onClicked: pill.expanded = !pill.expanded
        }
    }

    Repeater {
        id: rep
        model: pill.expanded ? SystemTray.items : null 

        delegate: Item {
            required property var modelData       // SystemTrayItem
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

            QsMenuAnchor {
                id: menuAnchor
                anchor.item: parent
                menu: tray.menu
            }

            TapHandler {
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onTapped: (point, button) => {
                    console.log("asdfasdf")
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
