import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import "../theme"

Item {
    id: root
    width: implicitWidth
    height: implicitHeight
    implicitWidth: columnLayout.implicitWidth
    implicitHeight: columnLayout.implicitHeight
    property UPowerDevice bat: UPower.displayDevice

    property color stateColor: {
        let percentage = Math.floor(bat.percentage * 100);
        return [
            {
                max: 10,
                col: Theme.red
            },
            {
                max: 20,
                col: Theme.yellow
            },
            {
                max: 60,
                col: Theme.text
            },
            {
                max: 100,
                col: Theme.green
            }
        ].find(({
                max,
                col
            }) => percentage <= max).col;
    }

    ColumnLayout {
        id: columnLayout
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: `Battery status:`
                color: Theme.text
                font.pixelSize: 24
            }
            Text {
                text: `${Math.floor(bat.percentage * 100)}%`
                color: stateColor
                font.pixelSize: 24
                font.bold: true
            }
        }

        Text {
            visible: bat.state == UPowerDeviceState.Charging
            color: Theme.text
            text: {
                let time = bat.timeToFull;
                let h = Math.floor(time / 60 / 60);
                let m = Math.floor(time / 60) % 60;
                return `Full in: ${h}h${m}m`;
            }
        }

        Text {
            visible: bat.state != UPowerDeviceState.Charging
            color: Theme.text
            text: {
                let time = bat.timeToEmpty;
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
                    id: powerProfileIcon2
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
                        source: Quickshell.iconPath(powerProfileIcon2.iconName)
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
