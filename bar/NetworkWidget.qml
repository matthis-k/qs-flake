import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../components"
import "../services"
import "../managers"

Item {
    id: root

    implicitWidth: root.height
    implicitHeight: root.height

    IconImage {
        anchors.fill: parent
        anchors.margins: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)
        implicitSize: root.height
        source: Quickshell.iconPath(NetworkManager.currentNetwork ? NetworkManager.currentNetwork.icon : "network-wireless-offline-symbolic", "network-wireless-offline-symbolic")
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
