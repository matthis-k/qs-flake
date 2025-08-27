import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../theme"
import "../components"
import "../services"

Item {
    id: root
    implicitWidth: parent.height
    implicitHeight: parent.height

    property bool expanded: false
    property var currentNetwork: {
        for (let i = 0; i < nm.networks.length; ++i) {
            if (nm.networks[i].inUse)
                return nm.networks[i];
        }
        return null;
    }
    onExpandedChanged: if (expanded)
        nm.scan()

    NetworkManager {
        id: nm
    }

    // Reusable entry for a network with optional actions
    component NetworkItem: Item {
        id: networkItem
        required property var network
        required property var nm
        property bool expanded: false
        width: parent ? parent.width : implicitWidth
        height: col.implicitHeight

        ColumnLayout {
            id: col
            anchors.fill: parent
            spacing: 4

            RowLayout {
                id: headerRow
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                spacing: 8
                IconImage {
                    source: Quickshell.iconPath(networkItem.network.icon, "network-wireless-signal-none-symbolic")
                    implicitSize: 16
                }
                Text {
                    text: networkItem.network.ssid
                    color: networkItem.network.inUse ? Theme.green : Theme.text
                    Layout.fillWidth: true
                }
                Text {
                    visible: networkItem.network.band !== "2.4GHz"
                    Layout.alignment: Qt.AlignRight
                    text: networkItem.network.band
                    color: networkItem.network.inUse ? Theme.green : Theme.subtext0
                }
            }

            TapHandler {
                target: headerRow
                onSingleTapped: networkItem.expanded = !networkItem.expanded
            }

            RowLayout {
                id: actionRow
                visible: networkItem.expanded
                Layout.fillWidth: true
                spacing: 8
                TextField {
                    id: pwField
                    visible: !networkItem.network.inUse && networkItem.network.security.toLowerCase() !== "open"
                    Layout.fillWidth: true
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    color: Theme.text
                    placeholderTextColor: Theme.overlay1
                    selectionColor: Theme.surface2
                    selectedTextColor: Theme.text
                    leftPadding: 4 + Theme.rounded * 8
                    rightPadding: 4 + Theme.rounded * 8
                    topPadding: 4 + Theme.rounded * 4
                    bottomPadding: 4 + Theme.rounded * 4
                    background: Rectangle {
                        radius: Theme.rounded ? 8 : 0
                        color: Theme.base
                        border.width: pwField.activeFocus ? 2 : 1
                        border.color: pwField.activeFocus ? Theme.lavender : (pwField.hovered ? Theme.overlay1 : Theme.overlay0)
                    }
                }
                Button {
                    id: connectBtn
                    text: networkItem.network.inUse ? "Disconnect" : "Connect"
                    leftPadding: 8 + Theme.rounded * 8
                    rightPadding: 8 + Theme.rounded * 8
                    topPadding: 4 + Theme.rounded * 4
                    bottomPadding: 4 + Theme.rounded * 4
                    contentItem: Text {
                        text: connectBtn.text
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        color: Theme.text
                    }
                    background: Rectangle {
                        radius: Theme.rounded ? 8 : 0
                        color: connectBtn.hovered ? Theme.surface0 : Theme.base
                        border.width: 1
                        border.color: connectBtn.down ? Theme.blue : (connectBtn.hovered ? Theme.overlay1 : Theme.overlay0)
                    }
                    onClicked: {
                        if (networkItem.network.inUse) {
                            networkItem.nm.disconnect(networkItem.network.ssid);
                        } else {
                            if (networkItem.network.security.toLowerCase() === "open")
                                networkItem.nm.connectOpen(networkItem.network.ssid);
                            else
                                networkItem.nm.connectPsk(networkItem.network.ssid, pwField.text);
                        }
                        networkItem.expanded = false;
                    }
                }
            }
        }
    }

    IconImage {
        id: icon
        anchors.centerIn: parent
        anchors.fill: parent
        anchors.margins: 4
        implicitSize: 24
        source: Quickshell.iconPath(root.currentNetwork ? root.currentNetwork.icon : "network-wireless-offline-symbolic", "network-wireless-offline-symbolic")
    }

    GenericTooltip {
        anchors.centerIn: parent
        anchors.fill: parent
        background: Theme.crust
        canEnterTooltip: true

        tooltipContent: Rectangle {
            implicitWidth: 200
            implicitHeight: col.implicitHeight
            color: "transparent"

            ColumnLayout {
                id: col
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Text {
                        text: "Network:"
                        color: Theme.text
                        font.pixelSize: 24
                    }
                    Text {
                        text: root.currentNetwork ? root.currentNetwork.ssid : `State: ${nm.managerState}`
                        color: root.currentNetwork ? Theme.green : Theme.red
                        font.pixelSize: 24
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                NetworkItem {
                    visible: !!root.currentNetwork
                    network: root.currentNetwork
                    nm: nm
                }

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    Text {
                        text: root.expanded ? "Show less" : "Show more"
                        color: Theme.text
                        Layout.fillWidth: true
                    }
                    IconImage {
                        source: Quickshell.iconPath(root.expanded ? "pan-up-symbolic" : "pan-down-symbolic", root.expanded ? "pan-up-symbolic" : "pan-down-symbolic")
                        implicitSize: 16
                    }
                    TapHandler {
                        onSingleTapped: root.expanded = !root.expanded
                    }
                }

                ListView {
                    id: networksList
                    visible: root.expanded
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 200)
                    model: nm.networks
                    clip: true
                    delegate: NetworkItem {
                        width: networksList.width
                        network: modelData
                        nm: nm
                    }
                }
            }
        }
    }
}
