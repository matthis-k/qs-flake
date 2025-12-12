import QtQuick
import Quickshell
import "../../services"

StatusIcon {
    iconName: NetworkManager.currentNetwork ? NetworkManager.currentNetwork.icon : "network-wireless-offline-symbolic"
    quickmenuName: "network"
}
