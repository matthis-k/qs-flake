import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../../services"
import "../../components"

// ActiveIndicator + HoverScaler are assumed to be in ../../components or similar
// (adjust imports as needed)

Item {
    id: root
    implicitWidth: opts.implicitWidth
    implicitHeight: opts.implicitHeight

    Process {
        id: runner
    }

    // ------------------------------------------------------------------------
    // PowerOption: one row in the power menu
    // ------------------------------------------------------------------------
    component PowerOption: Item {
        id: option
        required property list<string> command
        required property string icon
        required property color optionColor
        required property string text

        readonly property int iconSize: 32
        readonly property int gutter: 12
        readonly property int accentMaxWidth: 8
        readonly property int trailingPadding: 16

        implicitWidth: accentMaxWidth + iconSize + gutter + (label ? label.implicitWidth : 0) + trailingPadding
        implicitHeight: iconSize

        Process {
            id: runner
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: runner.exec({
                "command": option.command
            })
        }

        // Single hover/scale controller for the whole option
        HoverScaler {
            id: hoverScaler
            anchors.fill: parent
            hoverTarget: option        // hover on the entire row
            scaleTarget: label         // scale the text
            baseScale: 0.8
            hoveredScale: 1.0
            unhoveredScale: 0.8
        }

        // Left active indicator (accent + hover background)
        ActiveIndicator {
            anchors.fill: parent

            side: ActiveIndicator.Side.Left
            color: option.optionColor
            bgActive: hoverScaler.hovered
            active: hoverScaler.hovered

            duration: Config.behaviour.animation.calc(0.2)
            thickness: 8
            animationMode: ActiveIndicator.AnimationMode.GrowAlong
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

                    ColorOverlay {
                        anchors.fill: parent
                        color: option.optionColor
                        source: Icon {
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
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: option.text
                    color: Config.styling.text0
                    font.bold: true
                    font.pixelSize: 24
                    transformOrigin: Item.Left   // grow to the right

                    // Optional: keep a nice animation on the scale set by HoverScaler
                    Behavior on scale {
                        enabled: Config.behaviour.animation.enabled
                        NumberAnimation {
                            duration: Config.behaviour.animation.calc(0.1)
                            easing.type: Easing.Bezier
                            easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                        }
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------------
    // Options list
    // ------------------------------------------------------------------------
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
