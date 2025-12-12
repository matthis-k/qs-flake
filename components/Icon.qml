import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import "../services"

Item {
    property var iconName: "dialog-warning"
    property var iconPath: Quickshell.iconPath(iconName, "dialog-warning")
    property color color: Config.styling.text0

    implicitHeight: parent.height
    implicitWidth: parent.height

    IconImage {
        id: icon
        anchors.centerIn: parent
        width: root.height
        height: root.height
        source: root.iconPath
    }

    ColorOverlay {
        visible: !!root.color
        anchors.fill: icon
        color: visible ? root.color : undefined
        source: icon
        scale: icon.scale
    }
}
