import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../services" 1.0
import "../components"
import "../managers"

PanelWindow {
    id: barWin
    property var modelData
    screen: modelData

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

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        QuickSettingsManager.qs.closeTimer.stop();
                    }
                }
            }

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

    Rectangle {
        id: sep
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 1
        implicitWidth: 1920 - (QuickSettingsManager.qs.visible * QuickSettingsManager.qs.implicitWidth)

        color: Config.styling.primaryAccent
    }
}
