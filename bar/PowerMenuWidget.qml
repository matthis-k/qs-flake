import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Qt5Compat.GraphicalEffects
import "../services"
import "../components"
import "../managers"
import "../quickSettings"

Item {
    id: root
    implicitWidth: root.height
    implicitHeight: root.height

    Component {
        id: powerMenuPopupComponent
        PowerMenuView {}
    }

    readonly property real iconMargin: Math.floor(root.height * (1 - Config.styling.statusIconScaler) / 2)

    StatusIcon {
        anchors.fill: parent
        iconName: "system-shutdown-symbolic"
        overlayColor: Config.styling.critical
        popupComponent: powerMenuPopupComponent
    }
}
