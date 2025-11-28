import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../services"
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
        required property color optionColor
        required property string text

        readonly property int iconSize: 32
        readonly property int gutter: 12
        readonly property int accentMaxWidth: 6
        readonly property int trailingPadding: 16
        implicitWidth: accentMaxWidth + iconSize + gutter + (label ? label.implicitWidth : 0) + trailingPadding
        implicitHeight: iconSize

        HoverHandler {
            id: hoverHandler
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: runner.exec({
                command
            })
        }

        Item {
            id: visual
            anchors.fill: parent

            Rectangle {
                id: bg
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: hoverHandler.hovered ? parent.width : 0
                color: option.optionColor
                opacity: Config.styling.hoverBgOpacity

                Behavior on width {
                    enabled: Config.styling.animation.enabled
                    NumberAnimation {
                        duration: Config.styling.animation.calc(0.1)
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                    }
                }
            }

            Rectangle {
                id: accent
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: hoverHandler.hovered ? accentMaxWidth : 0
                color: option.optionColor

                Behavior on width {
                    enabled: Config.styling.animation.enabled
                    NumberAnimation {
                        duration: Config.styling.animation.calc(0.1)
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                    }
                }
            }

            RowLayout {
                id: row
                anchors.fill: parent
                anchors.leftMargin: accentMaxWidth + gutter
                anchors.rightMargin: trailingPadding
                spacing: gutter

                Item {
                    id: iconWrapper
                    Layout.preferredWidth: iconSize
                    Layout.minimumWidth: iconSize
                    Layout.maximumWidth: iconSize
                    Layout.preferredHeight: iconSize
                    Layout.alignment: Qt.AlignVCenter

                    Item {
                        id: iconContent
                        width: iconSize
                        height: iconSize
                        anchors.centerIn: parent
                        transformOrigin: Item.Center
                        scale: hoverHandler.hovered ? 1 : 0.8

                        Behavior on scale {
                            enabled: Config.styling.animation.enabled
                            NumberAnimation {
                                duration: Config.styling.animation.calc(0.1)
                                easing.type: Easing.Bezier
                                easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                            }
                        }

                        ColorOverlay {
                            anchors.fill: parent
                            color: option.optionColor
                            source: IconImage {
                                anchors.fill: parent
                                implicitSize: iconSize
                                source: Quickshell.iconPath(option.icon)
                                smooth: true
                            }
                        }
                    }
                }

                Item {
                    id: textWrapper
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitWidth: label.implicitWidth
                    implicitHeight: label.implicitHeight

                    Text {
                        id: label
                        anchors.verticalCenter: parent.verticalCenter
                        text: option.text
                        color: Config.styling.text0
                        font.bold: true
                        font.pixelSize: 24
                        transformOrigin: Item.Center
                        scale: hoverHandler.hovered ? 1 : 0.8

                        Behavior on scale {
                            enabled: Config.styling.animation.enabled
                            NumberAnimation {
                                duration: Config.styling.animation.calc(0.1)
                                easing.type: Easing.Bezier
                                easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                            }
                        }
                    }
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
            optionColor: Config.colors.yellow
            icon: "system-log-out-symbolic"
            text: "Logout"
        }

        PowerOption {
            Layout.fillWidth: true
            command: ["systemctl", "hibernate"]
            optionColor: Config.colors.sapphire
            icon: "system-suspend-hibernate-symbolic"
            text: "Hibernate"
        }

        PowerOption {
            Layout.fillWidth: true
            command: ["systemctl", "reboot"]
            optionColor: Config.colors.peach
            icon: "system-reboot-symbolic"
            text: "Reboot"
        }
        PowerOption {
            Layout.fillWidth: true
            command: ["systemctl", "poweroff"]
            optionColor: Config.colors.red
            icon: "system-shutdown-symbolic"
            text: "Shutdown"
        }
    }
}
