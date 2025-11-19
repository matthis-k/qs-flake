import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../components"
import "../services" 1.0
import "../managers"

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
                width: 16
                height: 16
            }
            Text {
                text: network?.ssid ?? ""
                color: network?.inUse ? Config.styling.good : Config.styling.text0
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Text {
                visible: !!network?.band && network.band !== "2.4GHz"
                Layout.alignment: Qt.AlignRight
                text: network?.band ?? ""
                color: network?.inUse ? Config.styling.good : Config.styling.text1
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
                color: Config.styling.text0
                placeholderTextColor: Config.styling.bg7
                selectionColor: Config.styling.bg5
                selectedTextColor: Config.styling.text0
                leftPadding: 4 + Config.styling.rounded * 8
                rightPadding: 4 + Config.styling.rounded * 8
                topPadding: 4 + Config.styling.rounded * 4
                bottomPadding: 4 + Config.styling.rounded * 4
                background: Rectangle {
                    radius: Config.styling.rounded ? 8 : 0
                    color: Config.styling.bg2
                    border.width: pwField.activeFocus ? 2 : 1
                    border.color: pwField.activeFocus ? Config.colors.lavender : (pwField.hovered ? Config.styling.bg7 : Config.styling.bg6)
                }
            }

            Button {
                id: connectBtn
                text: network?.inUse ? "Disconnect" : "Connect"
                leftPadding: 8 + Config.styling.rounded * 8
                rightPadding: 8 + Config.styling.rounded * 8
                topPadding: 4 + Config.styling.rounded * 4
                bottomPadding: 4 + Config.styling.rounded * 4

                contentItem: Text {
                    text: connectBtn.text
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    color: Config.styling.text0
                }
                background: Rectangle {
                    radius: Config.styling.rounded ? 8 : 0
                    color: connectBtn.hovered ? Config.styling.bg3 : Config.styling.bg2
                    border.width: 1
                    border.color: connectBtn.down ? Config.styling.primaryAccent : (connectBtn.hovered ? Config.styling.bg7 : Config.styling.bg6)
                }
                onClicked: {
                    if (network?.inUse) {
                        requestDisconnect(network.ssid);
                    } else {
                        const sec = (network?.security ?? "").toLowerCase();
                        if (sec === "open")
                            requestConnectOpen(network.ssid);
                        else
                            requestConnectPsk(network.ssid, pwField.text);
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

    property bool peeking: false

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                peeking = true;
                QuickSettingsManager.open("network", peeking);
            } else if (peeking) {
                QuickSettingsManager.close(500);
            }
        }
    }

    TapHandler {
        onSingleTapped: {
            peeking = false;
            QuickSettingsManager.toggle("network", peeking);
        }
    }
}
