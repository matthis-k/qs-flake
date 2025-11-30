import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../components"
import "../services"
import "../panels"

Item {
    id: root

    Component {
        id: networkPopupComponent
        NetworkPanel {}
    }

    implicitWidth: root.height
    implicitHeight: root.height
    readonly property real iconMargin: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)

    StatusIcon {
        anchors.fill: parent
        iconName: NetworkManager.currentNetwork ? NetworkManager.currentNetwork.icon : "network-wireless-offline-symbolic"
        popupComponent: networkPopupComponent
    }
}
