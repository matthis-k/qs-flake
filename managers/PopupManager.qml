pragma Singleton
import QtQuick
import Quickshell
import "../popup"

Singleton {
    id: root

    readonly property PopupPanel panel: PopupPanel {}

    readonly property QtObject anchors: QtObject {
        readonly property QtObject topLeft: root.panel.topLeft
        readonly property QtObject topCenter: root.panel.topCenter
        readonly property QtObject topRight: root.panel.topRight
        readonly property QtObject middleLeft: root.panel.middleLeft
        readonly property QtObject middleCenter: root.panel.middleCenter
        readonly property QtObject middleRight: root.panel.middleRight
        readonly property QtObject bottomLeft: root.panel.bottomLeft
        readonly property QtObject bottomCenter: root.panel.bottomCenter
        readonly property QtObject bottomRight: root.panel.bottomRight
    }

    readonly property alias topLeft: root.panel.topLeft
    readonly property alias topCenter: root.panel.topCenter
    readonly property alias topRight: root.panel.topRight
    readonly property alias middleLeft: root.panel.middleLeft
    readonly property alias middleCenter: root.panel.middleCenter
    readonly property alias middleRight: root.panel.middleRight
    readonly property alias bottomLeft: root.panel.bottomLeft
    readonly property alias bottomCenter: root.panel.bottomCenter
    readonly property alias bottomRight: root.panel.bottomRight

    function hideAll(timeout_ms) {
        panel.hideAll(timeout_ms);
    }
}
