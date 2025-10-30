import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"

PanelWindow {
    id: barWin

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
    color: Theme.crust
    implicitHeight: 32

    Rectangle {
        id: bar
        anchors.fill: parent
        anchors.margins: 4
        color: "transparent"

        RowLayout {
            id: left
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            HyprlandWidget {
                Layout.fillHeight: true
            }
        }

        RowLayout {
            id: center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            ClockWidget {}
        }

        RowLayout {
            id: right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Pill {
                Layout.fillHeight: true
                SystemTrayWidget {
                    Layout.fillHeight: true
                }
                VolumeWidget {}
                BluetoothWidget {}
                NetworkWidget {}
                BatteryWidget {}
                PowerMenuWidget {}
            }
        }
    }
}
