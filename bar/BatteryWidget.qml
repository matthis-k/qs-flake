import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import "../theme"
import "../components"

Item {
    id: root
    property UPowerDevice bat: UPower.displayDevice
    implicitWidth: parent.height
    implicitHeight: parent.height
    IconImage {
        id: icon
        anchors.centerIn: parent
        anchors.fill: parent
        anchors.margins: 4
        implicitSize: 24
        source: Quickshell.iconPath(root.bat.iconName, "battery-full")
    }

    GenericTooltip {
        anchors.centerIn: parent
        anchors.fill: parent
        background: Theme.crust
        canEnterTooltip: true

        tooltipContent: ColumnLayout {
            spacing: 0
            Text {
                text: `Battery status: ${Math.floor(root.bat.percentage * 100)}%`
                color: Theme.text
                font.pixelSize: 24
            }
            Text {
                visible: root.bat.state == UPowerDeviceState.Charging
                color: Theme.text
                text: {
                    let time = root.bat.timeToFull;
                    let h = Math.floor(time / 60 / 60);
                    let m = Math.floor(time / 60) % 60;
                    return `Full in: ${h}h${m}m`;
                }
            }
            Text {
                visible: root.bat.state != UPowerDeviceState.Charging
                color: Theme.text
                text: {
                    let time = root.bat.timeToEmpty;
                    let h = Math.floor(time / 60 / 60);
                    let m = Math.floor(time / 60) % 60;
                    return `Empty in ${h}h${m}m`;
                }
            }
            MouseArea {
                id: powerProfileArea
                hoverEnabled: false
                cursorShape: Qt.PointingHandCursor
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                acceptedButtons: Qt.LeftButton
                onClicked: rotateProfile(+1)

                property int accumulatedScroll: 0
                property int scrollThreshold: 120

                function rotateProfile(direction) {
                    const order = [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance];
                    let current = PowerProfiles.profile;
                    let index = order.indexOf(current);
                    let nextIndex = (index + direction + order.length) % order.length;
                    PowerProfiles.profile = order[nextIndex];
                }

                onWheel: {
                    accumulatedScroll += wheel.angleDelta.y;

                    if (accumulatedScroll >= scrollThreshold) {
                        rotateProfile(-1);
                        accumulatedScroll = 0;
                    } else if (accumulatedScroll <= -scrollThreshold) {
                        rotateProfile(+1);
                        accumulatedScroll = 0;
                    }
                }

                RowLayout {
                    spacing: 8
                    anchors.fill: parent
                    anchors.margins: 4
                    Layout.alignment: Qt.AlignLeft

                    ColorOverlay {
                        id: powerProfileIcon
                        property string iconName: ({
                                [PowerProfile.Performance]: "power-profile-performance-symbolic",
                                [PowerProfile.Balanced]: "power-profile-balanced-symbolic",
                                [PowerProfile.PowerSaver]: "power-profile-power-saver-symbolic"
                            })[PowerProfiles.profile]
                        color: ({
                                [PowerProfile.Performance]: Theme.red,
                                [PowerProfile.Balanced]: Theme.yellow,
                                [PowerProfile.PowerSaver]: Theme.green
                            })[PowerProfiles.profile]
                        implicitWidth: 32
                        implicitHeight: 32
                        source: IconImage {
                            source: Quickshell.iconPath(powerProfileIcon.iconName)
                            implicitSize: 32
                        }
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "Power profile"
                            font.pixelSize: 16
                            color: Theme.text
                            font.bold: true
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: PowerProfile.toString(PowerProfiles.profile)
                            color: Theme.subtext1
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
