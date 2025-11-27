import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../services"
import "../components"
import "../managers"

PanelWindow {
    id: barWin
    property var modelData
    screen: modelData

    property real barHeight: Screen.devicePixelRatio * 96 / 2.54

    function open(): void {
        barWin.visible = true;
    }
    function close(): void {
        barWin.visible = false;
    }
    function toggle(): void {
        barWin.visible = !barWin.visible;
    }

    anchors {
        top: true
        left: true
        right: true
    }
    color: Config.styling.bg0
    implicitHeight: barHeight

    Rectangle {
        id: bar
        anchors.fill: parent
        color: "transparent"
    }

    RowLayout {
        id: left
        anchors.left: parent.left
        anchors.topMargin: (barHeight / 8) - 1
        anchors.bottomMargin: (barHeight / 8) + 1
        anchors.top: parent.top
        anchors.bottom: sep.top

        HyprlandWidget {
            Layout.fillHeight: true
        }
    }

    RowLayout {
        id: center
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: sep.top
        anchors.topMargin: (barHeight / 8) - 1
        anchors.bottomMargin: (barHeight / 8) + 1
        ClockWidget {
            Layout.fillHeight: true
        }
    }

    RowLayout {
        id: right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: sep.top
        anchors.topMargin: (barHeight / 8) - 1
        anchors.bottomMargin: (barHeight / 8) + 1
        spacing: 0

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    PopupManager.anchors.topRight.cancelHide();
                }
            }
        }

        SystemTrayWidget {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            Layout.fillHeight: true
        }
        Pill {
            id: statusIcons
            Layout.fillHeight: true
            VolumeWidget {
                Layout.fillHeight: true
            }
            BluetoothWidget {
                Layout.fillHeight: true
            }
            NetworkWidget {
                Layout.fillHeight: true
            }
            BatteryWidget {
                Layout.fillHeight: true
            }
            PowerMenuWidget {
                Layout.fillHeight: true
            }
        }
    }

    Rectangle {
        id: sep
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 1
        implicitWidth: 1920 - (PopupManager.anchors.topRight.visible ? PopupManager.anchors.topRight.width : 0)

        color: Config.styling.primaryAccent
    }
}
