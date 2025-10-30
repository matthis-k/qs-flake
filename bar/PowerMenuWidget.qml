import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../theme"
import "../components"

Item {
    id: root
    implicitWidth: parent ? parent.height : 48
    implicitHeight: parent ? parent.height : 48

    Process {
        id: runner
        function run(cmd) {
            runner.command = cmd;
            runner.startDetached();
        }
        function sh(cmd) {
            runner.command = ["sh", "-c", cmd];
            runner.startDetached();
        }
    }

    ColorOverlay {
        anchors.fill: parent
        color: Theme.red
        source: IconImage {
            anchors.centerIn: parent
            implicitSize: 24
            source: Quickshell.iconPath("system-shutdown-symbolic", "system-shutdown")
        }
    }

    GenericTooltip {
        anchors.fill: parent
        anchors.centerIn: parent
        background: Theme.crust
        canEnterTooltip: true
        popupWidth: 180

        tooltipContent: ColumnLayout {
            spacing: 6

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                HoverHandler {
                    id: hhLogout
                }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onTapped: runner.sh(`uwsm stop`)
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: hhLogout.hovered ? Theme.surface1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        spacing: 8

                        ColorOverlay {
                            implicitWidth: 28
                            implicitHeight: 28
                            color: Theme.yellow
                            source: IconImage {
                                implicitSize: 28
                                source: Quickshell.iconPath("system-log-out-symbolic", "system-log-out")
                            }
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Logout"
                                color: Theme.text
                                font.bold: true
                            }
                            Text {
                                text: "End current session"
                                color: Theme.subtext1
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }

            Item {
                visible: false
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                HoverHandler {
                    id: hhHibernate
                }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onTapped: runner.run(["systemctl", "hibernate"])
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: hhHibernate.hovered ? Theme.surface1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        spacing: 8

                        ColorOverlay {
                            implicitWidth: 28
                            implicitHeight: 28
                            color: Theme.mauve
                            source: IconImage {
                                implicitSize: 28
                                source: Quickshell.iconPath("system-suspend-hibernate-symbolic", "system-suspend-hibernate")
                            }
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Hibernate"
                                color: Theme.text
                                font.bold: true
                            }
                            Text {
                                text: "Save to disk"
                                color: Theme.subtext1
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                HoverHandler {
                    id: hhReboot
                }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onTapped: runner.run(["systemctl", "reboot"])
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: hhReboot.hovered ? Theme.surface1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        spacing: 8

                        ColorOverlay {
                            implicitWidth: 28
                            implicitHeight: 28
                            color: Theme.peach
                            source: IconImage {
                                implicitSize: 28
                                source: Quickshell.iconPath("system-reboot-symbolic", "system-reboot")
                            }
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Reboot"
                                color: Theme.text
                                font.bold: true
                            }
                            Text {
                                text: "Restart the system"
                                color: Theme.subtext1
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                HoverHandler {
                    id: hhPoweroff
                }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onTapped: runner.run(["systemctl", "poweroff"])
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: hhPoweroff.hovered ? Theme.surface1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        spacing: 8

                        ColorOverlay {
                            implicitWidth: 28
                            implicitHeight: 28
                            color: Theme.red
                            source: IconImage {
                                implicitSize: 28
                                source: Quickshell.iconPath("system-shutdown-symbolic", "system-shutdown")
                            }
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Power Off"
                                color: Theme.text
                                font.bold: true
                            }
                            Text {
                                text: "Shut down safely"
                                color: Theme.subtext1
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }
}
