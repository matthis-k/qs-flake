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
    property string expandedBssid: ""
    property var currentNetwork: {
        for (let i = 0; i < nm.networks.length; ++i) {
            if (nm.networks[i].inUse)
                return nm.networks[i];
        }
        return null;
    }

component NetworkItem: ColumnLayout {
    id: contentColumn
    spacing: 4
    // ---- properties/signals belong to the root object ----
    required property var network               // expects { ssid, icon, inUse, band, bssid, security }
    property string expandedBssid: ""
    signal requestToggle(string bssid)
    signal requestDisconnect(string ssid)
    signal requestConnectOpen(string ssid)
    signal requestConnectPsk(string ssid, string password)

    RowLayout {
        id: headerRow
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        spacing: 8

        IconImage {
            source: Quickshell.iconPath(network?.icon, "network-wireless-signal-none-symbolic")
            width: 16; height: 16
        }
        Text {
            text: network?.ssid ?? ""
            color: network?.inUse ? Theme.green : Theme.text
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Text {
            visible: !!network?.band && network.band !== "2.4GHz"
            Layout.alignment: Qt.AlignRight
            text: network?.band ?? ""
            color: network?.inUse ? Theme.green : Theme.subtext0
        }
    }

    TapHandler {
        target: headerRow
        onSingleTapped: requestToggle(network?.bssid ?? "")
    }

    RowLayout {
        id: actionRow
        visible: expandedBssid === (network?.bssid ?? "")
        Layout.fillWidth: true
        spacing: 8

        TextField {
            id: pwField
            visible: !network?.inUse && (network?.security ?? "").toLowerCase() !== "open"
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
                border.color: pwField.activeFocus ? Theme.lavender
                                : (pwField.hovered ? Theme.overlay1 : Theme.overlay0)
            }
        }

        Button {
            id: connectBtn
            text: network?.inUse ? "Disconnect" : "Connect"
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
                border.color: connectBtn.down ? Theme.blue
                                : (connectBtn.hovered ? Theme.overlay1 : Theme.overlay0)
            }
            onClicked: {
                if (network?.inUse) {
                    requestDisconnect(network.ssid)
                } else {
                    const sec = (network?.security ?? "").toLowerCase()
                    if (sec === "open") requestConnectOpen(network.ssid)
                    else requestConnectPsk(network.ssid, pwField.text)
                }
            }
        }
    }
}

    onExpandedChanged: if (expanded)
        nm.scan()

    NetworkManager {
        id: nm
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
                    id: headerArea
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    IconImage {
                        source: Quickshell.iconPath(root.currentNetwork ? root.currentNetwork.icon : "network-wireless-offline-symbolic", "network-wireless-offline-symbolic")
                        implicitSize: 16
                    }
                    Text {
                        text: root.currentNetwork ? root.currentNetwork.ssid : `State: ${nm.managerState}`
                        color: Theme.text
                        Layout.fillWidth: true
                    }
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
                    delegate: Item {
                        required property var modelData
                        width: networksList.width
                        height: contentColumn.implicitHeight

                        ColumnLayout {
                            id: contentColumn
                            anchors.fill: parent
                            spacing: 4

                            RowLayout {
                                id: headerRow
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
                                    visible: modelData.band != "2.4GHz"
                                    Layout.alignment: Qt.AlignRight
                                    text: modelData.band
                                    color: modelData.inUse ? Theme.green : Theme.subtext0
                                    Layout.fillWidth: true
                                }
                            }

                            TapHandler {
                                target: actionRow
                                onSingleTapped: {
                                    root.expandedBssid = root.expandedBssid === modelData.bssid ? "" : modelData.bssid;
                                }
                            }
                            RowLayout {
                                id: actionRow
                                visible: root.expandedBssid === modelData.bssid
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
                                    leftPadding: 4 + Theme.rounded * 8
                                    rightPadding: 4 + Theme.rounded * 8
                                    topPadding: 4 + Theme.rounded * 4
                                    bottomPadding: 4 + Theme.rounded * 4
                                    background: Rectangle {
                                        id: bg
                                        radius: Theme.rounded ? 8 : 0
                                        color: Theme.base
                                        border.width: pwField.activeFocus ? 2 : 1
                                        border.color: pwField.activeFocus ? Theme.lavender : (pwField.hovered ? Theme.overlay1 : Theme.overlay0)
                                    }
                                }
                                Button {
                                    id: connectBtn
                                    text: modelData.inUse ? "Disconnect" : "Connect"
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
                                        if (modelData.inUse) {
                                            nm.disconnect(modelData.ssid);
                                        } else {
                                            if (modelData.security.toLowerCase() === "open")
                                                nm.connectOpen(modelData.ssid);
                                            else
                                                nm.connectPsk(modelData.ssid, pwField.text);
                                        }
                                        root.expandedBssid = "";
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
