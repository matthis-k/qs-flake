import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../theme"
import "../services"

Item {
    id: root
    width: implicitWidth
    height: implicitHeight
    implicitWidth: columnLayout.implicitWidth
    implicitHeight: columnLayout.implicitHeight
    NetworkManager {
        id: nm
    }

    ColumnLayout {
        id: columnLayout
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 10

            IconImage {
                source: Quickshell.iconPath(nm.networks.find(n => n.inUse)?.icon || "network-wireless-offline-symbolic", "network-wireless-offline-symbolic")
                implicitSize: 32
            }

            Text {
                text: nm.networks.find(n => n.inUse)?.ssid || `State: ${nm.managerState}`
                color: Theme.text
                font.pixelSize: 24
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        RowLayout {
            spacing: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Text {
                text: "Show more"
                color: Theme.text
                Layout.fillWidth: true
            }
            IconImage {
                source: Quickshell.iconPath("pan-down-symbolic", "pan-down-symbolic")
                implicitSize: 16
            }
            TapHandler {
                onSingleTapped: expanded = !expanded
            }
        }

        ListView {
            id: networksList
            visible: expanded
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 200)
            model: nm.networks
            clip: true
            delegate: Item {
                required property var modelData
                width: networksList.width
                height: contentColumn.implicitHeight

                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        spacing: 8
                        IconImage {
                            source: Quickshell.iconPath(modelData.icon, "network-wireless-signal-none-symbolic")
                            implicitSize: 16
                        }
                        Text {
                            text: modelData.ssid
                            color: modelData.inUse ? Theme.green : Theme.text
                            Layout.fillWidth: true
                        }
                        Text {
                            visible: modelData.band !== "2.4GHz"
                            Layout.alignment: Qt.AlignRight
                            text: modelData.band
                            color: modelData.inUse ? Theme.green : Theme.subtext0
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: pwField
                            visible: !modelData.inUse && modelData.security.toLowerCase() !== "open"
                            Layout.fillWidth: true
                            placeholderText: "Password"
                            echoMode: TextInput.Password
                            color: Theme.text
                            placeholderTextColor: Theme.overlay1
                            selectionColor: Theme.surface2
                            selectedTextColor: Theme.text
                            leftPadding: 4
                            rightPadding: 4
                            topPadding: 4
                            bottomPadding: 4
                            background: Rectangle {
                                radius: 8
                                color: Theme.base
                                border.width: pwField.activeFocus ? 2 : 1
                                border.color: pwField.activeFocus ? Theme.lavender : (pwField.hovered ? Theme.overlay1 : Theme.overlay0)
                            }
                        }

                        Button {
                            id: connectBtn
                            text: modelData.inUse ? "Disconnect" : "Connect"
                            leftPadding: 8
                            rightPadding: 8
                            topPadding: 4
                            bottomPadding: 4

                            contentItem: Text {
                                text: connectBtn.text
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                color: Theme.text
                            }
                            background: Rectangle {
                                radius: 8
                                color: connectBtn.hovered ? Theme.surface0 : Theme.base
                                border.width: 1
                                border.color: connectBtn.down ? Theme.blue : (connectBtn.hovered ? Theme.overlay1 : Theme.overlay0)
                            }
                            onClicked: {
                                if (modelData.inUse) {
                                    nm.disconnect(modelData.ssid);
                                } else {
                                    const sec = modelData.security.toLowerCase();
                                    if (sec === "open") nm.connectOpen(modelData.ssid);
                                    else nm.connectPsk(modelData.ssid, pwField.text);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    property bool expanded: false
}