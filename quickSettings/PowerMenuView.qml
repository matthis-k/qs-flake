import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../services" 1.0
import "../components"

Item {
    id: root
    implicitWidth: opts.implicitWidth
    implicitHeight: opts.implicitHeight

    Process {
        id: runner
    }

    component PowerOption: Item {
        id: option
        required property list<string> command
        required property string icon
        required property color icon_color
        required property string text
        required property string subtext
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight
        HoverHandler {
            id: hhLogout
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onTapped: runner.exec({
                command
            })
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            radius: 8
            color: hhLogout.hovered ? Config.styling.bg4 : "transparent"
        }

        RowLayout {
            id: row
            spacing: 8
            ColorOverlay {
                id: icon
                implicitWidth: 36
                implicitHeight: 36
                color: option.icon_color
                source: IconImage {
                    implicitSize: 36
                    source: Quickshell.iconPath(option.icon)
                }
            }
            ColumnLayout {
                id: texts
                spacing: 0
                Text {
                    text: option.text
                    color: Config.styling.text0
                    font.bold: true
                    font.pixelSize: 16
                }
                Text {
                    text: option.subtext
                    color: Config.styling.text2
                    font.pixelSize: 12
                }
            }
        }
    }

    ColumnLayout {
        id: opts
        spacing: 8

        PowerOption {
            Layout.fillWidth: true
            command: ["uwsm", "stop"]
            icon_color: Config.colors.yellow
            icon: "system-log-out-symbolic"
            text: "Logout"
            subtext: "End current session"
        }

        PowerOption {
            Layout.fillWidth: true
            command: ["systemctl", "hibernate"]
            icon_color: Config.colors.teal
            icon: "system-suspend-hibernate-symbolic"
            text: "Hibernate"
            subtext: "Save to disk"
        }

        PowerOption {
            Layout.fillWidth: true
            command: ["systemctl", "reboot"]
            icon_color: Config.styling.warning
            icon: "system-reboot-symbolic"
            text: "Reboot"
            subtext: "Restart system"
        }
        PowerOption {
            Layout.fillWidth: true
            command: ["systemctl", "poweroff"]
            icon_color: Config.styling.critical
            icon: "system-reboot-symbolic"
            text: "Power off"
            subtext: "Shut down system"
        }
    }
}
